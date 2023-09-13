ALTER  PROC [dbo].[PROC_WEEKLY_MITATSUAIMU_REPORT]
(
	@FLAG VARCHAR(20)
	,@USER VARCHAR(50)
	,@FROM_DATE VARCHAR(20) = NULL
	,@TO_DATE VARCHAR(20) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @ERROR_MESSAGE VARCHAR(MAX), @CUSTOMER_DEPOSITS_AMT MONEY, @CASH_COLLECTED_AMT MONEY, @REFUND_AMT MONEY, @PAID_AMT MONEY, @SERVICE_CHARGE_COLLECTED_AMT MONEY
		, @SERVICE_CHARGE_CANCELLED_AMT MONEY, @CANCEL_CASH_AMT MONEY, @OLD_MITATSUAIMU_AMT MONEY, @NEW_MITATSUAIMU_AMT MONEY, @CANCEL_AND_SEND_ON_SAME_DAY MONEY
		, @REFUND_AMT_WALLET MONEY, @REFUND_AMT_UNTRAN MONEY
	IF @FLAG = 'S'
	BEGIN
		SELECT [DAY] = '', [DATE] = '<b>Opening Balance</b>', JP_POST = '', MUFJ = '', CASH_COLLECT = '', INDONESIA_JP_POST = ''
				, [TOTAL_COLLECT] = ''
				, JP_POST_RETURN = '', MUFJ_RETURN = '', INDONESIA_JP_POST_RETURN = '', CASH_COLLECT_RETURN = ''
				, [TOTAL_RETURN] = ''
				, DAILY_PAYOUT = '', [SERVICE_CHARGE] = ''
				, [TOTAL_INCOMING] = ''
				, [TOTAL_PAYOUT] = ''
				, NEW_MITATSUSAIMU_VALUE
				, ROUND(NEW_MITATSUSAIMU_VALUE * 1.05, 0) MITATSUSAIMU_CALC
		FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY (NOLOCK)
		WHERE RPT_DATE = CAST(DATEADD(DAY, -1, @FROM_DATE) AS DATE)

		UNION ALL

		SELECT FORMAT(RPT_DATE, 'ddd') [DAY], CONVERT(VARCHAR(10), RPT_DATE, 101) [DATE], JP_POST, MUFJ, CASH_COLLECT, INDONESIA_JP_POST
				, (JP_POST+MUFJ+CASH_COLLECT+INDONESIA_JP_POST) [TOTAL_COLLECT]
				, JP_POST_RETURN, MUFJ_RETURN, INDONESIA_JP_POST_RETURN, CASH_COLLECT_RETURN
				, (JP_POST_RETURN + MUFJ_RETURN+ INDONESIA_JP_POST_RETURN + CASH_COLLECT_RETURN) [TOTAL_RETURN]
				, DAILY_PAYOUT, (SERVICE_CHARGE_INCOME - SERVICE_CHARGE_CANCEL) [SERVICE_CHARGE]
				, ((JP_POST+MUFJ+CASH_COLLECT+INDONESIA_JP_POST) - (SERVICE_CHARGE_INCOME - SERVICE_CHARGE_CANCEL)) [TOTAL_INCOMING]
				, (DAILY_PAYOUT + (JP_POST_RETURN + MUFJ_RETURN+ INDONESIA_JP_POST_RETURN + CASH_COLLECT_RETURN)) [TOTAL_PAYOUT]
				, NEW_MITATSUSAIMU_VALUE
				, ROUND(NEW_MITATSUSAIMU_VALUE * 1.05, 0) MITATSUSAIMU_CALC
		FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY (NOLOCK)
		WHERE RPT_DATE BETWEEN @FROM_DATE AND @TO_DATE;
	END
	IF @FLAG = 'RE-CALC'
	BEGIN
		IF @FROM_DATE <= '2020-04-30'
		BEGIN
			EXEC proc_errorHandler 1, 'Data till 2019-04-30 are locked, can not be re-calculated!', NULL
			RETURN;
		END

		SELECT @TO_DATE = MAX(RPT_DATE)
		FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY(NOLOCK)

		WHILE CAST(@FROM_DATE AS DATE) <= CAST(@TO_DATE AS DATE)
		BEGIN
			SELECT @OLD_MITATSUAIMU_AMT = NEW_MITATSUSAIMU_VALUE
			FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY(NOLOCK) 
			WHERE RPT_DATE = DATEADD(DAY, -1, @FROM_DATE)

			IF ISNULL(@OLD_MITATSUAIMU_AMT, 0) <> 0
			BEGIN
				-- CUSTOMER DEPOSIT TO JP POST BANK
				IF @FROM_DATE < '2020-02-15'
				BEGIN
					-- CUSTOMER DEPOSIT TO JP POST BANK
					SELECT @CUSTOMER_DEPOSITS_AMT = SUM(TRAN_AMT) 
					FROM SendMnPro_Account.dbo.TRAN_MASTER 
					WHERE ACC_NUM = '101139273793'
					AND part_tran_type = 'CR'
					AND ISNULL(FIELD2, '') <> 'Remittance Voucher'
					AND CAST(TRAN_DATE AS DATE) = @FROM_DATE
					--AND ISNULLAND part_tran_type = 'DR'(FIELD2, '') = 'Customer Deposit(Untransacted)'
				END
				ELSE
				BEGIN
					SELECT @CUSTOMER_DEPOSITS_AMT = SUM(depositAmount)
					FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)
					WHERE CAST(tranDate AS DATE) = @FROM_DATE
					AND (isSkipped = 0 OR ISNULL(skipRemarks, '') = 'Refund')
				END

				--CASH COLLECTED FROM CUSTOMER
				SELECT @CASH_COLLECTED_AMT = SUM(CAMT) --DBO.DECRYPTDB(CONTROLNO) CONTROLNO, CAMT,UPLOADLOGID
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(CREATEDDATE AS DATE) = @FROM_DATE
				--AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
				AND COLLMODE = 'CASH COLLECT'
				--and controlno <> 'LLciKJKLORIOO'

				--REFUND TO JP POST
				IF @FROM_DATE < '2020-02-15'
				BEGIN
					--REFUND TO JP POST
					SELECT @REFUND_AMT = SUM(TRAN_AMT)
					FROM SendMnPro_Account.dbo.TRAN_MASTER 
					WHERE ACC_NUM = '101139273793'
					AND TRAN_DATE = @FROM_DATE
					AND part_tran_type = 'DR'
					AND ISNULL(FIELD2, '') <> 'Remittance Voucher'
					--AND FIELD2 = 'Refund Voucher(Manual)'
				END
				ELSE
				BEGIN
					IF OBJECT_ID('tempdb..#ACC_REFUND') IS NOT NULL
						DROP TABLE #ACC_REFUND

					IF OBJECT_ID('tempdb..#CUSTOMER_WALLET') IS NOT NULL
						DROP TABLE #CUSTOMER_WALLET

					SELECT DISTINCT REF_NUM INTO #ACC_REFUND 
					FROM SendMnPro_Account.dbo.TRAN_MASTER (NOLOCK)
					WHERE acc_num = '100241011536'
				 	AND part_tran_type = 'CR'
					AND CAST(TRAN_DATE AS DATE) = @FROM_DATE 

					SELECT ACCT_NUM INTO #CUSTOMER_WALLET
					FROM SendMnPro_Account.dbo.ac_master (NOLOCK)
					WHERE acct_rpt_code = 'CA'

					SELECT @REFUND_AMT_WALLET = sum(TRAN_AMT) FROM #ACC_REFUND R
					INNER JOIN SendMnPro_Account.dbo.TRAN_MASTER M(NOLOCK) ON M.ref_num = R.REF_NUM
					INNER JOIN #CUSTOMER_WALLET A ON A.acct_num = M.acc_num
					WHERE M.part_tran_type = 'DR'

					SELECT @REFUND_AMT_UNTRAN = sum(TRAN_AMT) FROM #ACC_REFUND R
					INNER JOIN SendMnPro_Account.dbo.TRAN_MASTER M(NOLOCK) ON M.ref_num = R.REF_NUM
					WHERE M.acc_num = '101139273793'
					AND M.part_tran_type = 'DR'

					SET @REFUND_AMT = ISNULL(@REFUND_AMT_UNTRAN, 0) + ISNULL(@REFUND_AMT_WALLET, 0)
				END

				--PAID AMOUNT
				SELECT @PAID_AMT = SUM(TAMT)
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(ISNULL(PAIDDATE, '1990-01-01') AS DATE) = @FROM_DATE
				AND (PAYSTATUS = 'PAID')

				--SERVICE CHARGE
				SELECT @SERVICE_CHARGE_COLLECTED_AMT = SUM(ISNULL(SERVICECHARGE, 0))
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(CREATEDDATE AS DATE) = @FROM_DATE

				SELECT @SERVICE_CHARGE_CANCELLED_AMT = SUM(ISNULL(SERVICECHARGE, 0))
				FROM REMITTRAN (NOLOCK)
				WHERE (CAST(CREATEDDATE AS DATE) = @FROM_DATE OR CAST(ISNULL(CANCELAPPROVEDDATE, '1990-01-01') AS DATE) = @FROM_DATE)
				AND CAST(ISNULL(CANCELAPPROVEDDATE, '1990-01-01') AS DATE) !> @FROM_DATE
				AND TRANSTATUS = 'CANCEL'

				SELECT @CANCEL_CASH_AMT = SUM(CAMT)--dbo.decryptdb(controlno), camt, createddate
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE) = @FROM_DATE
				--AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
				AND COLLMODE = 'CASH COLLECT'
				AND TRANSTATUS = 'CANCEL'

				--IF OBJECT_ID('tempdb..#TEMP_CANCEL_ON_THAT_DAY') IS NOT NULL
				--	DROP TABLE #TEMP_CANCEL_ON_THAT_DAY
				--IF OBJECT_ID('tempdb..#TXN_SEND_AFTER_CANCEL') IS NOT NULL
				--	DROP TABLE #TXN_SEND_AFTER_CANCEL

				--SELECT SUM(R.CAMT) CAMT, S.CUSTOMERID
				--INTO #TEMP_CANCEL_ON_THAT_DAY
				--FROM REMITTRAN R(NOLOCK)
				--INNER JOIN TRANSENDERS S(NOLOCK) ON S.TRANID=R.ID
				--WHERE CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE) = @FROM_DATE
				--AND CAST(CREATEDDATE AS DATE) <> @FROM_DATE
				--AND COLLMODE = 'CASH COLLECT'
				--AND TRANSTATUS = 'CANCEL'
				--GROUP BY S.CUSTOMERID

				--SELECT SUM(R.CAMT) CAMT, S.CUSTOMERID
				--INTO #TXN_SEND_AFTER_CANCEL
				--FROM REMITTRAN R(NOLOCK)
				--INNER JOIN TRANSENDERS S(NOLOCK) ON S.TRANID=R.ID
				--INNER JOIN #TEMP_CANCEL_ON_THAT_DAY TMP ON TMP.CUSTOMERID = S.CUSTOMERID
				--WHERE CAST(CREATEDDATE AS DATE) = @FROM_DATE
				--AND COLLMODE = 'CASH COLLECT'
				--GROUP BY S.CUSTOMERID


				--SELECT @CANCEL_AND_SEND_ON_SAME_DAY = SUM(C.CAMT)
				--FROM #TXN_SEND_AFTER_CANCEL T
				--INNER JOIN #TEMP_CANCEL_ON_THAT_DAY C ON C.CUSTOMERID = T.CUSTOMERID
				----WHERE T.CAMT = C.CAMT

				--SET @CANCEL_CASH_AMT = @CANCEL_CASH_AMT - ISNULL(@CANCEL_AND_SEND_ON_SAME_DAY, 0)
				--SET @CASH_COLLECTED_AMT = @CASH_COLLECTED_AMT - ISNULL(@CANCEL_AND_SEND_ON_SAME_DAY, 0)

				SET @NEW_MITATSUAIMU_AMT = ISNULL(@OLD_MITATSUAIMU_AMT, 0) + ((ISNULL(@CUSTOMER_DEPOSITS_AMT, 0) + ISNULL(@CASH_COLLECTED_AMT, 0))-(ISNULL(@SERVICE_CHARGE_COLLECTED_AMT, 0) - ISNULL(@SERVICE_CHARGE_CANCELLED_AMT, 0))) - (ISNULL(@CANCEL_CASH_AMT, 0) + ISNULL(@REFUND_AMT, 0) + ISNULL(@PAID_AMT, 0))

				IF EXISTS(SELECT * FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY(NOLOCK) WHERE RPT_DATE = @FROM_DATE)
				BEGIN
					UPDATE WEEKLY_MITATSUAIMU_REPORT_HISTORY SET JP_POST = ISNULL(@CUSTOMER_DEPOSITS_AMT, 0),
																MUFJ = 0,
																CASH_COLLECT = ISNULL(@CASH_COLLECTED_AMT, 0),
																INDONESIA_JP_POST = 0,
																JP_POST_RETURN = ISNULL(@REFUND_AMT, 0),
																MUFJ_RETURN = 0,
																INDONESIA_JP_POST_RETURN = 0,
																CASH_COLLECT_RETURN = ISNULL(@CANCEL_CASH_AMT, 0),
																DAILY_PAYOUT = ISNULL(@PAID_AMT, 0),
																SERVICE_CHARGE_INCOME = ISNULL(@SERVICE_CHARGE_COLLECTED_AMT, 0),
																SERVICE_CHARGE_CANCEL = ISNULL(@SERVICE_CHARGE_CANCELLED_AMT, 0),
																OLD_MITATSUSAIMU_VALUE = ISNULL(@OLD_MITATSUAIMU_AMT, 0),
																NEW_MITATSUSAIMU_VALUE = ISNULL(@NEW_MITATSUAIMU_AMT, 0)
					WHERE RPT_DATE = @FROM_DATE
				END
				ELSE
				BEGIN
					INSERT INTO WEEKLY_MITATSUAIMU_REPORT_HISTORY 
					SELECT @FROM_DATE, ISNULL(@CUSTOMER_DEPOSITS_AMT, 0), 0, ISNULL(@CASH_COLLECTED_AMT, 0), 0, ISNULL(@REFUND_AMT, 0), 0, 0, ISNULL(@CANCEL_CASH_AMT, 0)
						, ISNULL(@PAID_AMT, 0), ISNULL(@SERVICE_CHARGE_COLLECTED_AMT, 0), ISNULL(@SERVICE_CHARGE_CANCELLED_AMT, 0), ISNULL(@OLD_MITATSUAIMU_AMT, 0), ISNULL(@NEW_MITATSUAIMU_AMT, 0)
				END
			END

			SET @FROM_DATE = DATEADD(DAY, 1, @FROM_DATE)
		END

		EXEC proc_errorHandler 0, 'Re-calculated succcessfully!', NULL
	END
	IF @FLAG = 'TILL-YESTERDAY'
	BEGIN
		SELECT @FROM_DATE = DATEADD(DAY, 1, MAX(RPT_DATE)), @TO_DATE = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
		FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY(NOLOCK)
		
		IF @FROM_DATE = CAST(GETDATE() AS DATE)
		BEGIN
			EXEC proc_errorHandler 1, 'Data till yesterday already calculated!', NULL
			RETURN;
		END

		WHILE CAST(@FROM_DATE AS DATE) <= CAST(@TO_DATE AS DATE)
		BEGIN
			SELECT @OLD_MITATSUAIMU_AMT = NEW_MITATSUSAIMU_VALUE
			FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY(NOLOCK) 
			WHERE RPT_DATE = DATEADD(DAY, -1, @FROM_DATE)

			IF ISNULL(@OLD_MITATSUAIMU_AMT, 0) <> 0
			BEGIN
				-- CUSTOMER DEPOSIT TO JP POST BANK
				SELECT @CUSTOMER_DEPOSITS_AMT = SUM(TRAN_AMT) 
				FROM SendMnPro_Account.dbo.TRAN_MASTER 
				WHERE ACC_NUM = '101139273793'
				AND part_tran_type = 'CR'
				AND ISNULL(FIELD2, '') <> 'Remittance Voucher'
				AND CAST(TRAN_DATE AS DATE) = @FROM_DATE
				--AND ISNULLAND part_tran_type = 'DR'(FIELD2, '') = 'Customer Deposit(Untransacted)'

				--CASH COLLECTED FROM CUSTOMER
				SELECT @CASH_COLLECTED_AMT = SUM(CAMT) --DBO.DECRYPTDB(CONTROLNO) CONTROLNO, CAMT,UPLOADLOGID
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(CREATEDDATE AS DATE) = @FROM_DATE
				AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
				AND COLLMODE = 'CASH COLLECT'
				--and controlno <> 'LLciKJKLORIOO'

				--REFUND TO JP POST
				SELECT @REFUND_AMT = SUM(TRAN_AMT)
				FROM SendMnPro_Account.dbo.TRAN_MASTER 
				WHERE ACC_NUM = '101139273793'
				AND TRAN_DATE = @FROM_DATE
				AND part_tran_type = 'DR'
				AND ISNULL(FIELD2, '') <> 'Remittance Voucher'
				--AND FIELD2 = 'Refund Voucher(Manual)'

				--PAID AMOUNT
				SELECT @PAID_AMT = SUM(TAMT)
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(ISNULL(PAIDDATE, '1990-01-01') AS DATE) = @FROM_DATE
				AND (PAYSTATUS = 'PAID')

				--SERVICE CHARGE
				SELECT @SERVICE_CHARGE_COLLECTED_AMT = SUM(ISNULL(SERVICECHARGE, 0))
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(CREATEDDATE AS DATE) = @FROM_DATE

				SELECT @SERVICE_CHARGE_CANCELLED_AMT = SUM(ISNULL(SERVICECHARGE, 0))
				FROM REMITTRAN (NOLOCK)
				WHERE (CAST(CREATEDDATE AS DATE) = @FROM_DATE OR CAST(ISNULL(CANCELAPPROVEDDATE, '1990-01-01') AS DATE) = @FROM_DATE)
				AND CAST(ISNULL(CANCELAPPROVEDDATE, '1990-01-01') AS DATE) !> @FROM_DATE
				AND TRANSTATUS = 'CANCEL'

				SELECT @CANCEL_CASH_AMT = SUM(CAMT)--dbo.decryptdb(controlno), camt, createddate
				FROM REMITTRAN (NOLOCK)
				WHERE CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE) = @FROM_DATE
				AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
				AND COLLMODE = 'CASH COLLECT'
				AND TRANSTATUS = 'CANCEL'

				--IF OBJECT_ID('tempdb..#TEMP_CANCEL_ON_THAT_DAY') IS NOT NULL
				--	DROP TABLE #TEMP_CANCEL_ON_THAT_DAY
				--IF OBJECT_ID('tempdb..#TXN_SEND_AFTER_CANCEL') IS NOT NULL
				--	DROP TABLE #TXN_SEND_AFTER_CANCEL

				--SELECT SUM(R.CAMT) CAMT, S.CUSTOMERID
				--INTO #TEMP_CANCEL_ON_THAT_DAY
				--FROM REMITTRAN R(NOLOCK)
				--INNER JOIN TRANSENDERS S(NOLOCK) ON S.TRANID=R.ID
				--WHERE CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE) = @FROM_DATE
				--AND CAST(CREATEDDATE AS DATE) <> @FROM_DATE
				--AND COLLMODE = 'CASH COLLECT'
				--AND TRANSTATUS = 'CANCEL'
				--GROUP BY S.CUSTOMERID

				--SELECT SUM(R.CAMT) CAMT, S.CUSTOMERID
				--INTO #TXN_SEND_AFTER_CANCEL
				--FROM REMITTRAN R(NOLOCK)
				--INNER JOIN TRANSENDERS S(NOLOCK) ON S.TRANID=R.ID
				--INNER JOIN #TEMP_CANCEL_ON_THAT_DAY TMP ON TMP.CUSTOMERID = S.CUSTOMERID
				--WHERE CAST(CREATEDDATE AS DATE) = @FROM_DATE
				--AND COLLMODE = 'CASH COLLECT'
				--GROUP BY S.CUSTOMERID


				--SELECT @CANCEL_AND_SEND_ON_SAME_DAY = SUM(C.CAMT)
				--FROM #TXN_SEND_AFTER_CANCEL T
				--INNER JOIN #TEMP_CANCEL_ON_THAT_DAY C ON C.CUSTOMERID = T.CUSTOMERID
				----WHERE T.CAMT = C.CAMT

				--SET @CANCEL_CASH_AMT = @CANCEL_CASH_AMT - ISNULL(@CANCEL_AND_SEND_ON_SAME_DAY, 0)
				--SET @CASH_COLLECTED_AMT = @CASH_COLLECTED_AMT - ISNULL(@CANCEL_AND_SEND_ON_SAME_DAY, 0)

				SET @NEW_MITATSUAIMU_AMT = ISNULL(@OLD_MITATSUAIMU_AMT, 0) + ((ISNULL(@CUSTOMER_DEPOSITS_AMT, 0) + ISNULL(@CASH_COLLECTED_AMT, 0))-(ISNULL(@SERVICE_CHARGE_COLLECTED_AMT, 0) - ISNULL(@SERVICE_CHARGE_CANCELLED_AMT, 0))) - (ISNULL(@CANCEL_CASH_AMT, 0) + ISNULL(@REFUND_AMT, 0) + ISNULL(@PAID_AMT, 0))

				IF EXISTS(SELECT * FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY(NOLOCK) WHERE RPT_DATE = @FROM_DATE)
				BEGIN
					UPDATE WEEKLY_MITATSUAIMU_REPORT_HISTORY SET JP_POST = ISNULL(@CUSTOMER_DEPOSITS_AMT, 0),
																MUFJ = 0,
																CASH_COLLECT = ISNULL(@CASH_COLLECTED_AMT, 0),
																INDONESIA_JP_POST = 0,
																JP_POST_RETURN = ISNULL(@REFUND_AMT, 0),
																MUFJ_RETURN = 0,
																INDONESIA_JP_POST_RETURN = 0,
																CASH_COLLECT_RETURN = ISNULL(@CANCEL_CASH_AMT, 0),
																DAILY_PAYOUT = ISNULL(@PAID_AMT, 0),
																SERVICE_CHARGE_INCOME = ISNULL(@SERVICE_CHARGE_COLLECTED_AMT, 0),
																SERVICE_CHARGE_CANCEL = ISNULL(@SERVICE_CHARGE_CANCELLED_AMT, 0),
																OLD_MITATSUSAIMU_VALUE = ISNULL(@OLD_MITATSUAIMU_AMT, 0),
																NEW_MITATSUSAIMU_VALUE = ISNULL(@NEW_MITATSUAIMU_AMT, 0)
					WHERE RPT_DATE = @FROM_DATE
				END
				ELSE
				BEGIN
					INSERT INTO WEEKLY_MITATSUAIMU_REPORT_HISTORY 
					SELECT @FROM_DATE, ISNULL(@CUSTOMER_DEPOSITS_AMT, 0), 0, ISNULL(@CASH_COLLECTED_AMT, 0), 0, ISNULL(@REFUND_AMT, 0), 0, 0, ISNULL(@CANCEL_CASH_AMT, 0)
						, ISNULL(@PAID_AMT, 0), ISNULL(@SERVICE_CHARGE_COLLECTED_AMT, 0), ISNULL(@SERVICE_CHARGE_CANCELLED_AMT, 0), ISNULL(@OLD_MITATSUAIMU_AMT, 0), ISNULL(@NEW_MITATSUAIMU_AMT, 0)
				END
			END

			SET @FROM_DATE = DATEADD(DAY, 1, @FROM_DATE)
		END

		EXEC proc_errorHandler 0, 'Data till yesterday calculated succcessfully!', NULL
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION

	SET @ERROR_MESSAGE = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @ERROR_MESSAGE, @USER
END CATCH

GO
