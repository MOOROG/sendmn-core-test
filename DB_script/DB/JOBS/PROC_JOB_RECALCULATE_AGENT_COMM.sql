USE FASTMONEYPRO_REMIT
GO

ALTER PROC PROC_JOB_RECALCULATE_AGENT_COMM
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @COMMISSION_AMT MONEY = NULL
		,@T_AMT MONEY = NULL
		,@FX MONEY = NULL
		,@IS_NEW_CUSTOMER CHAR(1) = NULL
		,@REFERRAL_CODE VARCHAR(50) = NULL
		,@PAYOUT_PARTNER INT = NULL
		,@CUSTOMER_ID BIGINT = NULL
		,@TRAN_ID BIGINT = NULL
		,@S_AGENT INT = NULL
		,@USER VARCHAR(60) = NULL
		,@TRAN_DATE VARCHAR(25) = NULL
		,@COLL_MODE VARCHAR(30) = NULL
		,@CONTROLNO VARCHAR(30) = NULL
		,@TOTAL_COMM MONEY = NULL
		,@IS_CANCEL BIT = 0
		,@CANCEL_APPROVED_DATE VARCHAR(30)
		,@REF_NUM VARCHAR(20) = NULL
		,@pAgentComm MONEY
		,@DEDUCT_TAX_ON_SC BIT
		,@DEDUCT_P_COMM_ON_SC BIT

	DECLARE @FX_INCENTIVE MONEY, @COMM_INCENTIVE MONEY, @NEW_CUSTOMER_INCENTIVE MONEY, @FLAT_INCENTIVE MONEY, @marketingIncentivePayableAcc VARCHAR(30) = '9539277135'
	DECLARE @FX_PCNT DECIMAL(5,2), @COMM_PCNT DECIMAL(5,2), @REFERRAL_ID INT, @UPDATE_TRN CHAR(1) = 'N', @NEW_CUSTOMER_RATE MONEY, @FLAT_RATE MONEY, @marketPromotionAcc VARCHAR(30) = '910639248385'

	WHILE EXISTS(SELECT TOP 1 1 FROM REFERRAL_COMM_UPDATE WHERE IS_GEN = 0)
	BEGIN
		SELECT @COMMISSION_AMT = COMMISSION_AMT, @T_AMT = T_AMT, @FX = FX, @IS_NEW_CUSTOMER = CASE WHEN IS_NEW_CUSTOMER = 1 THEN 'Y' ELSE 'N' END,
				@REFERRAL_CODE = REFERRAL_CODE, @PAYOUT_PARTNER = PAYOUT_PARTNER, @CUSTOMER_ID = CUSTOMER_ID,
				@TRAN_ID = TRAN_ID, @S_AGENT = S_AGENT, @USER = 'SYSTEM', @TRAN_DATE = TRAN_DATE,
				@COLL_MODE = COLL_MODE, @CONTROLNO = CONTROLNO, @IS_CANCEL = IS_CANCEL, @CANCEL_APPROVED_DATE = CANCEL_APPROVED_DATE
		FROM REFERRAL_COMM_UPDATE
		WHERE IS_GEN = 0

		IF ISNULL(@REFERRAL_CODE, '') = '' AND EXISTS (SELECT 'X' FROM agentMaster(NOLOCK) WHERE agentId = @S_AGENT	AND ISNULL(isSettlingAgent,	'N') = 'Y' 
					AND ISNULL(isIntl, 0) = 1 AND isApiPartner = 0 AND ISNULL(ACTASBRANCH, 'N') = 'N')
		BEGIN
			SET @UPDATE_TRN = 'Y'
		
			SELECT @REFERRAL_ID = ROW_ID FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE AGENT_ID = @S_AGENT 

			IF NOT EXISTS (SELECT 1 FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) WHERE REFERRAL_ID = @REFERRAL_ID AND PARTNER_ID = @PAYOUT_PARTNER AND IS_ACTIVE = 1)
			BEGIN
				SELECT TOP 1 @FX_PCNT = FX_PCNT, 
						@COMM_PCNT = COMM_PCNT, 
						@FLAT_INCENTIVE = FLAT_TXN_WISE, 
						@NEW_CUSTOMER_RATE = NEW_CUSTOMER,
						@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
						@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC
				FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
				WHERE REFERRAL_ID = 0
				AND IS_ACTIVE = 1
				AND PARTNER_ID = @PAYOUT_PARTNER
				AND EFFECTIVE_FROM <= @TRAN_DATE
				ORDER BY EFFECTIVE_FROM DESC
			END
			ELSE
			BEGIN
				SELECT TOP 1 @FX_PCNT = FX_PCNT, 
						@COMM_PCNT = COMM_PCNT, 
						@FLAT_INCENTIVE = FLAT_TXN_WISE, 
						@NEW_CUSTOMER_RATE = NEW_CUSTOMER,
						@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
						@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC 
				FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
				WHERE REFERRAL_ID = @REFERRAL_ID
				AND IS_ACTIVE = 1
				AND PARTNER_ID = @PAYOUT_PARTNER
				AND EFFECTIVE_FROM <= @TRAN_DATE
				ORDER BY EFFECTIVE_FROM DESC
			END
		END
		ELSE IF ISNULL(@REFERRAL_CODE, '') <> ''
		BEGIN
			DECLARE @REFERRAL_TYPE CHAR(2) 

			SELECT @REFERRAL_TYPE = REFERRAL_TYPE_CODE, @REFERRAL_ID = ROW_ID
			FROM REFERRAL_AGENT_WISE (NOLOCK) 
			WHERE REFERRAL_CODE = @REFERRAL_CODE

			IF @REFERRAL_TYPE = 'RB'
			BEGIN
				UPDATE REFERRAL_COMM_UPDATE SET IS_GEN = 1 WHERE TRAN_ID = @TRAN_ID
				CONTINUE;
			END
		
			IF @REFERRAL_TYPE = 'RC'
			BEGIN
				UPDATE REFERRAL_COMM_UPDATE SET IS_GEN = 1 WHERE TRAN_ID = @TRAN_ID
				CONTINUE;
			END
		
			IF NOT EXISTS (SELECT 1 FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) WHERE REFERRAL_ID = @REFERRAL_ID AND PARTNER_ID = @PAYOUT_PARTNER AND IS_ACTIVE = 1)
			BEGIN
				SELECT TOP 1 @FX_PCNT = FX_PCNT, 
						@COMM_PCNT = COMM_PCNT, 
						@FLAT_INCENTIVE = FLAT_TXN_WISE, 
						@NEW_CUSTOMER_RATE = NEW_CUSTOMER,
						@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
						@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC
				FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
				WHERE REFERRAL_ID = 0
				AND PARTNER_ID = @PAYOUT_PARTNER
				AND IS_ACTIVE = 1
				AND EFFECTIVE_FROM <= @TRAN_DATE
				ORDER BY EFFECTIVE_FROM DESC
			END
			BEGIN
				SELECT TOP 1 @FX_PCNT = FX_PCNT, 
						@COMM_PCNT = COMM_PCNT, 
						@FLAT_INCENTIVE = FLAT_TXN_WISE, 
						@NEW_CUSTOMER_RATE = NEW_CUSTOMER,
						@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
						@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC 
				FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
				WHERE REFERRAL_ID = @REFERRAL_ID
				AND PARTNER_ID = @PAYOUT_PARTNER
				AND IS_ACTIVE = 1
				AND EFFECTIVE_FROM <= @TRAN_DATE
				ORDER BY EFFECTIVE_FROM DESC
			END
		END
		ELSE
		BEGIN
			UPDATE REFERRAL_COMM_UPDATE SET IS_GEN = 1 WHERE TRAN_ID = @TRAN_ID
			CONTINUE;
		END

		IF ISNULL(@DEDUCT_P_COMM_ON_SC, 0) = 1
		BEGIN
			SELECT @pAgentComm = ISNULL(PAGENTCOMM, 0)
			FROM REMITTRAN (NOLOCK)
			WHERE ID=@TRAN_ID

			SET @COMMISSION_AMT = @COMMISSION_AMT - @pAgentComm
		END

		IF ISNULL(@FX_PCNT, 0) <> 0
		BEGIN
			IF @PAYOUT_PARTNER = 393880
				SET @FX_INCENTIVE = (@FX_PCNT * @T_AMT) / 100
			ELSE 
				SET @FX_INCENTIVE = (@FX_PCNT * @FX) / 100
		END
	
		IF ISNULL(@COMM_PCNT, 0) <> 0
		BEGIN
			IF ISNULL(@DEDUCT_TAX_ON_SC, 0) = 0
				SET @COMM_INCENTIVE = (@COMM_PCNT * @COMMISSION_AMT) / 100
			ELSE 
				SET @COMM_INCENTIVE = (@COMM_PCNT * (@COMMISSION_AMT / 1.1)) / 100
		END

		IF ISNULL(@IS_NEW_CUSTOMER, 'N') = 'N'
			SET @NEW_CUSTOMER_INCENTIVE = 0
		ELSE 
			SET @NEW_CUSTOMER_INCENTIVE = @NEW_CUSTOMER_RATE

		SET @TOTAL_COMM = ISNULL(@FX_INCENTIVE, 0) + ISNULL(@COMM_INCENTIVE, 0) + ISNULL(@NEW_CUSTOMER_INCENTIVE, 0) + ISNULL(@FLAT_INCENTIVE, 0)

		
		--SELECT ISNULL(@FX_INCENTIVE, 0), ISNULL(@COMM_INCENTIVE, 0), ISNULL(@NEW_CUSTOMER_INCENTIVE, 0), ISNULL(@FLAT_INCENTIVE, 0), @FX_PCNT
		--RETURN
		IF @UPDATE_TRN = 'Y'
		BEGIN
			DECLARE @agentCommPayableAcc VARCHAR(30), @sendingCommExpences VARCHAR(30) = '910139266612'

			SELECT @agentCommPayableAcc = ACCT_NUM
			FROM FASTMONEYPRO_ACCOUNT.DBO.ac_master AC(NOLOCK)
			WHERE agent_id = @S_AGENT
			AND acct_rpt_code='ACP'
			

			UPDATE REMITTRAN SET SAGENTCOMM = ISNULL(@TOTAL_COMM, 0), SAGENTCOMMCURRENCY = 'JPY' WHERE ID = @TRAN_ID

			UPDATE FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER SET TRAN_AMT = ISNULL(@TOTAL_COMM, 0),
					USD_AMT = ISNULL(@TOTAL_COMM, 0)
			WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN (@agentCommPayableAcc, @sendingCommExpences)
			AND FIELD2 = 'Remittance Voucher'
			
			IF NOT EXISTS(SELECT * FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER(NOLOCK) WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN (@agentCommPayableAcc, @sendingCommExpences) AND FIELD2 = 'Remittance Voucher')
			BEGIN
				UPDATE REFERRAL_COMM_UPDATE SET NO_ACC_VOUCHER = 1 WHERE TRAN_ID = @TRAN_ID
				
				--SELECT @REF_NUM = REF_NUM 
				--FROM fastmoneypro_account.dbo.tran_master
				--WHERE FIELD1 = @CONTROLNO
				--AND FIELD2 = 'Remittance Voucher'
				--AND ISNULL(ACCT_TYPE_CODE, '') = ''

				--insert into fastmoneypro_account.dbo.tran_master (acc_num, entry_user_id, gl_sub_head_code, part_tran_srl_num, part_tran_type, ref_num, tran_amt, tran_date
				--		, tran_type, created_date, company_id, runningbalance, usd_amt, usd_rate, field1, field2, fcy_curr, dept_id, branch_id, acct_type_code)
				--SELECT @sendingCommExpences, 'SYSTEM', 97, 11, 'dr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @TRAN_DATE
				--			, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, NULL	UNION ALL
				--SELECT @agentCommPayableAcc, 'SYSTEM', 65, 12, 'cr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @TRAN_DATE
				--			, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, NULL

				--IF @IS_CANCEL = 1 AND NOT EXISTS(SELECT * FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER(NOLOCK) WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN ('9539277135', '910639248385') AND FIELD2 = 'Remittance Voucher' AND ISNULL(ACCT_TYPE_CODE, '') = 'Reverse') 
				--BEGIN
				--	SELECT @REF_NUM = REF_NUM 
				--	FROM fastmoneypro_account.dbo.tran_master
				--	WHERE FIELD1 = @CONTROLNO
				--	AND FIELD2 = 'Remittance Voucher'
				--	AND ISNULL(ACCT_TYPE_CODE, '') = 'Reverse'

				--	insert into fastmoneypro_account.dbo.tran_master (acc_num, entry_user_id, gl_sub_head_code, part_tran_srl_num, part_tran_type, ref_num, tran_amt, tran_date
				--			, tran_type, created_date, company_id, runningbalance, usd_amt, usd_rate, field1, field2, fcy_curr, dept_id, branch_id, acct_type_code)
				--	SELECT @agentCommPayableAcc, 'SYSTEM', 97, 11, 'dr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @CANCEL_APPROVED_DATE
				--				, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, 'Reverse'	UNION ALL
				--	SELECT @sendingCommExpences, 'SYSTEM', 65, 12, 'cr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @CANCEL_APPROVED_DATE
				--				, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, 'Reverse'
				--END
			END
		END
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT * FROM REFERRAL_INCENTIVE_TRANSACTION_WISE(NOLOCK) WHERE TRAN_ID = @TRAN_ID AND IS_CANCEL = 0)
			BEGIN
				INSERT INTO REFERRAL_INCENTIVE_TRANSACTION_WISE
						(REFERRAL_ID, TRAN_ID, COMMISSION_PCNT, PAID_COMMISSION, FX_PCNT, PAID_FX, FLAT_RATE, PAID_FLAT, 
							PAID_NEW_CUSTOMER_RATE, PAID_NEW_CUSTOMER, CUSTOMER_ID, CREATED_DATE, PARTNER_ID, IS_CANCEL, TXN_DATE)

				SELECT @REFERRAL_ID, @TRAN_ID, ISNULL(@COMM_PCNT, 0), ISNULL(@COMM_INCENTIVE, 0), ISNULL(@FX_PCNT, 0), ISNULL(@FX_INCENTIVE, 0), ISNULL(@FLAT_INCENTIVE, 0), ISNULL(@FLAT_INCENTIVE, 0), 
							ISNULL(@NEW_CUSTOMER_RATE, 0), ISNULL(@NEW_CUSTOMER_INCENTIVE, 0), @CUSTOMER_ID, GETDATE(), @PAYOUT_PARTNER, 0, @TRAN_DATE
			END
			ELSE
			BEGIN
				SELECT ISNULL(@FX_INCENTIVE, 0)
				UPDATE REFERRAL_INCENTIVE_TRANSACTION_WISE SET COMMISSION_PCNT = ISNULL(@COMM_PCNT, 0), PAID_COMMISSION = ISNULL(@COMM_INCENTIVE, 0), FX_PCNT = ISNULL(@FX_PCNT, 0),
						PAID_FX = ISNULL(@FX_INCENTIVE, 0), FLAT_RATE = ISNULL(@FLAT_INCENTIVE, 0), PAID_FLAT = ISNULL(@FLAT_INCENTIVE, 0), PAID_NEW_CUSTOMER_RATE = ISNULL(@NEW_CUSTOMER_RATE, 0),
						PAID_NEW_CUSTOMER = ISNULL(@NEW_CUSTOMER_INCENTIVE, 0), TXN_DATE = @TRAN_DATE
				WHERE TRAN_ID = @TRAN_ID AND IS_CANCEL = 0
			END

			IF @IS_CANCEL = 1
			BEGIN
				IF NOT EXISTS(SELECT * FROM REFERRAL_INCENTIVE_TRANSACTION_WISE(NOLOCK) WHERE TRAN_ID = @TRAN_ID AND IS_CANCEL = 1)
				BEGIN
					INSERT INTO REFERRAL_INCENTIVE_TRANSACTION_WISE
							(REFERRAL_ID, TRAN_ID, COMMISSION_PCNT, PAID_COMMISSION, FX_PCNT, PAID_FX, FLAT_RATE, PAID_FLAT, 
								PAID_NEW_CUSTOMER_RATE, PAID_NEW_CUSTOMER, CUSTOMER_ID, CREATED_DATE, PARTNER_ID, IS_CANCEL, TXN_DATE)

					SELECT REFERRAL_ID, TRAN_ID, COMMISSION_PCNT, PAID_COMMISSION*-1, FX_PCNT, PAID_FX*-1, FLAT_RATE, PAID_FLAT*-1, 
								PAID_NEW_CUSTOMER_RATE, PAID_NEW_CUSTOMER*-1, CUSTOMER_ID, GETDATE(), PARTNER_ID, 1, @CANCEL_APPROVED_DATE
					FROM REFERRAL_INCENTIVE_TRANSACTION_WISE (NOLOCK) 
					WHERE TRAN_ID = @TRAN_ID AND IS_CANCEL = 0
				END
				ELSE
				BEGIN
					UPDATE REFERRAL_INCENTIVE_TRANSACTION_WISE SET COMMISSION_PCNT = ISNULL(@COMM_PCNT, 0), PAID_COMMISSION = ISNULL(@COMM_INCENTIVE, 0)*-1, FX_PCNT = ISNULL(@FX_PCNT, 0),
							PAID_FX = ISNULL(@FX_INCENTIVE, 0)*-1, FLAT_RATE = ISNULL(@FLAT_INCENTIVE, 0), PAID_FLAT = ISNULL(@FLAT_INCENTIVE, 0)*-1, PAID_NEW_CUSTOMER_RATE = ISNULL(@NEW_CUSTOMER_RATE, 0),
							PAID_NEW_CUSTOMER = ISNULL(@NEW_CUSTOMER_INCENTIVE, 0)*-1, TXN_DATE = @CANCEL_APPROVED_DATE
					WHERE TRAN_ID = @TRAN_ID AND IS_CANCEL = 1
				END
			END

			DECLARE @REFERRAL_COMM_ACC VARCHAR(30)

			SELECT @REFERRAL_COMM_ACC = ACCT_NUM
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK)
			WHERE  ACCT_RPT_CODE = 'RAC'
			AND AGENT_ID = @REFERRAL_ID

			UPDATE FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER SET TRAN_AMT = ISNULL(@TOTAL_COMM, 0),
					USD_AMT = ISNULL(@TOTAL_COMM, 0)
			WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN ('9539277135', '910639248385', @REFERRAL_COMM_ACC)
			AND FIELD2 = 'Remittance Voucher'

			IF NOT EXISTS(SELECT * FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER(NOLOCK) WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN ('9539277135', '910639248385') AND FIELD2 = 'Remittance Voucher')
			BEGIN
				UPDATE REFERRAL_COMM_UPDATE SET NO_ACC_VOUCHER = 1 WHERE TRAN_ID = @TRAN_ID
				--SELECT @REF_NUM = REF_NUM 
				--FROM fastmoneypro_account.dbo.tran_master
				--WHERE FIELD1 = @CONTROLNO
				--AND FIELD2 = 'Remittance Voucher'
				--AND ISNULL(ACCT_TYPE_CODE, '') = ''

				--insert into fastmoneypro_account.dbo.tran_master (acc_num, entry_user_id, gl_sub_head_code, part_tran_srl_num, part_tran_type, ref_num, tran_amt, tran_date
				--		, tran_type, created_date, company_id, runningbalance, usd_amt, usd_rate, field1, field2, fcy_curr, dept_id, branch_id, acct_type_code)
				--SELECT '9539277135', 'SYSTEM', 97, 11, 'cr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @TRAN_DATE
				--			, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, NULL	UNION ALL
				--SELECT '910639248385', 'SYSTEM', 65, 12, 'dr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @TRAN_DATE
				--			, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, NULL

				--IF @IS_CANCEL = 1 AND NOT EXISTS(SELECT * FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER(NOLOCK) WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN ('9539277135', '910639248385') AND FIELD2 = 'Remittance Voucher' AND ISNULL(ACCT_TYPE_CODE, '') = 'Reverse') 
				--BEGIN
				--	SELECT @REF_NUM = REF_NUM 
				--	FROM fastmoneypro_account.dbo.tran_master
				--	WHERE FIELD1 = @CONTROLNO
				--	AND FIELD2 = 'Remittance Voucher'
				--	AND ISNULL(ACCT_TYPE_CODE, '') = 'Reverse'

				--	insert into fastmoneypro_account.dbo.tran_master (acc_num, entry_user_id, gl_sub_head_code, part_tran_srl_num, part_tran_type, ref_num, tran_amt, tran_date
				--			, tran_type, created_date, company_id, runningbalance, usd_amt, usd_rate, field1, field2, fcy_curr, dept_id, branch_id, acct_type_code)
				--	SELECT '9539277135', 'SYSTEM', 97, 11, 'dr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @CANCEL_APPROVED_DATE
				--				, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, 'Reverse'	UNION ALL
				--	SELECT '910639248385', 'SYSTEM', 65, 12, 'cr', @REF_NUM, ISNULL(@TOTAL_COMM, 0), @CANCEL_APPROVED_DATE
				--				, 'j', GETDATE(), 1, 0, ISNULL(@TOTAL_COMM, 0), 1, @CONTROLNO, 'Remittance Voucher', 'JPY', NULL, NULL, 'Reverse'
				--END
				
			END
		END

		UPDATE REFERRAL_COMM_UPDATE SET IS_GEN = 1 WHERE TRAN_ID = @TRAN_ID
	END
END

