use fastmoneypro_remit
go

ALTER PROC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS
(
	@FLAG VARCHAR(50)
	,@USER VARCHAR(50) = NULL
	,@XML NVARCHAR(MAX)	= NULL
	,@TRAN_ID BIGINT = NULL
	,@REFERRAL_CODE VARCHAR(30) = NULL
	,@FILTER1 VARCHAR(10) = NULL
	,@DATE VARCHAR(100) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN
		IF @FLAG = 'SYNC-PAID'
		BEGIN
			DECLARE @TOTAL_COUNT INT, @AFTER_DELETE_COUNT INT, @XMLDATA XML, @MSG VARCHAR(250)
			
			IF OBJECT_ID('tempdb..#TEMP_TRAN_SYNC_PAID') IS NOT NULL DROP TABLE #TEMP_TRAN_SYNC
		
			SELECT @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(tranno)[1]','VARCHAR(20)') AS 'tranno'
						,p.value('(cancel_date)[1]','VARCHAR(150)') AS 'cancel_date'
						,p.value('(paiddate)[1]','VARCHAR(150)') AS 'paiddate'
						,p.value('(paidBy)[1]','VARCHAR(150)') AS 'paidBy'
						,p.value('(transtatus)[1]','VARCHAR(150)') AS 'transtatus'
						,p.value('(status)[1]','VARCHAR(150)') AS 'status'
			INTO #TEMP_TRAN_SYNC_PAID
			FROM @XMLDATA.nodes('/ArrayOfTransactionSync/TransactionSync') AS TEMP_TRAN(p)

			SELECT @TOTAL_COUNT = COUNT(0) 
			FROM #TEMP_TRAN_SYNC_PAID

			DELETE FROM #TEMP_TRAN_SYNC_PAID WHERE transtatus = 'CANCEL' OR status = 'CANCEL'

			ALTER TABLE #TEMP_TRAN_SYNC_PAID ADD CONTROLNO VARCHAR(30), REFNO_ENC VARCHAR(30)

			UPDATE T SET T.CONTROLNO = DBO.DECRYPTDB(R.CONTROLNO), T.REFNO_ENC = R.CONTROLNO
			FROM #TEMP_TRAN_SYNC_PAID T
			INNER JOIN REMITTRAN R(NOLOCK) ON R.UPLOADLOGID = T.tranno

			UPDATE #TEMP_TRAN_SYNC_PAID SET paidDate = CASE WHEN paidDate = '0001-01-01' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01' THEN NULL ELSE cancel_date END

			UPDATE #TEMP_TRAN_SYNC_PAID SET paidDate = CASE WHEN paidDate = '0001-01-01T00:00:00' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01T00:00:00' THEN NULL ELSE cancel_date END

			DELETE S
			FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER P(NOLOCK)
			INNER JOIN #TEMP_TRAN_SYNC_PAID S ON S.CONTROLNO = P.FIELD1
			WHERE ACCT_TYPE_CODE = 'PAID'
			AND FIELD2 = 'REMITTANCE VOUCHER'

			SELECT @AFTER_DELETE_COUNT = COUNT(0) 
			FROM #TEMP_TRAN_SYNC_PAID 
				
			UPDATE S SET S.CANCELAPPROVEDDATE = T.cancel_date, S.PAIDBY = T.paidBy, S.PAIDDATE = T.paidDate, S.TranStatus = T.transtatus, S.PayStatus = T.status,
					S.VOUCHER_GEN = 0,--CASE WHEN S.TranStatus <> T.TranStatus OR S.PayStatus <> T.PayStatus THEN 0 ELSE 1 END,
					S.STATUS_CHANGE_ON_UPDATE = CASE WHEN S.TranStatus <> T.transtatus OR S.PayStatus <> T.status THEN 0 ELSE 1 END,
					sync_date = GETDATE(),
					S.OLD_TRAN_STATUS = S.TranStatus, S.OLD_PAY_STATUS = S.PayStatus,
					S.NO_VOUCHER = 0
			FROM TXN_SYNC_STATUS S
			INNER JOIN #TEMP_TRAN_SYNC_PAID T ON T.CONTROLNO = S.CONTROLNO
			
			DELETE T
			FROM TXN_SYNC_STATUS S 
			INNER JOIN #TEMP_TRAN_SYNC_PAID T ON T.CONTROLNO = S.CONTROLNO
			
			----CREATE TABLE TXN_SYNC_STATUS(CONTROLNO VARCHAR(30), CONTROLNO_ENC VARCHAR(30), CANCELAPPROVEDDATE DATETIME, PAIDDATE DATETIME, PAIDBY VARCHAR(50), TranStatus VARCHAR(30), PayStatus VARCHAR(30), VOUCHER_GEN BIT)
			INSERT INTO TXN_SYNC_STATUS(CONTROLNO, CONTROLNO_ENC, CANCELAPPROVEDDATE, PAIDDATE, PAIDBY, TranStatus, PayStatus, VOUCHER_GEN, NO_VOUCHER, sync_date)
			SELECT t.CONTROLNO, t.REFNO_ENC, t.cancel_date, t.paidDate, t.paidBy, t.TranStatus, t.status, 0, 0, GETDATE()
			FROM #TEMP_TRAN_SYNC_PAID T
			INNER JOIN REMITTRAN R(NOLOCK) ON T.REFNO_ENC = R.CONTROLNO
			
			UPDATE T SET T.OLD_CANCEL_DATE = R.CANCELAPPROVEDDATE, T.OLD_PAID_DATE = R.PAIDDATE, T.old_status = R.TRANSTATUS, T.old_paystatus = R.PAYSTATUS, T.createddaate = R.CREATEDDATE
			FROM REMITTRAN R(NOLOCK)
			INNER JOIN #TEMP_TRAN_SYNC_PAID TMP ON TMP.REFNO_ENC = R.controlno
			INNER JOIN TXN_SYNC_STATUS T(NOLOCK) ON T.CONTROLNO_ENC = TMP.REFNO_ENC
			
			SET @MSG = 'Download successful for Total: '+CAST(@TOTAL_COUNT AS VARCHAR) +' DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR)
			
			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
		IF @FLAG = 'I-STATUS'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_TRAN_SYNC_NEW') IS NOT NULL DROP TABLE #TEMP_TRAN_SYNC_NEW
		
			SELECT @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(tranno)[1]','VARCHAR(20)') AS 'tranno'
						,p.value('(cancel_date)[1]','VARCHAR(150)') AS 'cancel_date'
						,p.value('(paiddate)[1]','VARCHAR(150)') AS 'paiddate'
						,p.value('(paidBy)[1]','VARCHAR(150)') AS 'paidBy'
						,p.value('(transtatus)[1]','VARCHAR(150)') AS 'transtatus'
						,p.value('(status)[1]','VARCHAR(150)') AS 'status'
			INTO #TEMP_TRAN_SYNC_NEW
			FROM @XMLDATA.nodes('/ArrayOfTransactionSync/TransactionSync') AS TEMP_TRAN(p)

			UPDATE #TEMP_TRAN_SYNC_NEW SET paidDate = CASE WHEN paidDate = '0001-01-01' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01' THEN NULL ELSE cancel_date END

			
			UPDATE #TEMP_TRAN_SYNC_NEW SET paidDate = CASE WHEN paidDate = '0001-01-01T00:00:00' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01T00:00:00' THEN NULL ELSE cancel_date END
			
			
			INSERT INTO REMIT_TRAN_STATUS_FROM_INFICARE
			SELECT tranno, transtatus, [status], paidDate, cancel_date
			FROM #TEMP_TRAN_SYNC_NEW

			EXEC PROC_ERRORHANDLER 0, 'Success!!', null
		END
		IF @FLAG = 'SYNC-CANCEL'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_TRAN_SYNC_CANCEL') IS NOT NULL DROP TABLE #TEMP_TRAN_SYNC
		
			SELECT @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(tranno)[1]','VARCHAR(20)') AS 'tranno'
						,p.value('(cancel_date)[1]','VARCHAR(150)') AS 'cancel_date'
						,p.value('(paidDate)[1]','VARCHAR(150)') AS 'paiddate'
						,p.value('(paidBy)[1]','VARCHAR(150)') AS 'paidBy'
						,p.value('(transtatus)[1]','VARCHAR(150)') AS 'transtatus'
						,p.value('(status)[1]','VARCHAR(150)') AS 'status'
			INTO #TEMP_TRAN_SYNC_CANCEL
			FROM @XMLDATA.nodes('/ArrayOfTransactionSync/TransactionSync') AS TEMP_TRAN(p)

			SELECT @TOTAL_COUNT = COUNT(0) 
			FROM #TEMP_TRAN_SYNC_CANCEL

			ALTER TABLE #TEMP_TRAN_SYNC_CANCEL ADD CONTROLNO VARCHAR(30), REFNO_ENC VARCHAR(30)


			UPDATE T SET T.CONTROLNO = DBO.DECRYPTDB(R.CONTROLNO), T.REFNO_ENC = R.CONTROLNO
			FROM #TEMP_TRAN_SYNC_CANCEL T
			INNER JOIN REMITTRAN R(NOLOCK) ON R.UPLOADLOGID = T.tranno


			UPDATE #TEMP_TRAN_SYNC_CANCEL SET paidDate = CASE WHEN paidDate = '0001-01-01' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01' THEN NULL ELSE cancel_date END

			
			UPDATE #TEMP_TRAN_SYNC_CANCEL SET paidDate = CASE WHEN paidDate = '0001-01-01T00:00:00' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01T00:00:00' THEN NULL ELSE cancel_date END
				
			DELETE S
			FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER C(NOLOCK) 
			INNER JOIN #TEMP_TRAN_SYNC_CANCEL S ON S.CONTROLNO = C.FIELD1
			WHERE ACCT_TYPE_CODE = 'REVERSE'
			AND FIELD2 = 'REMITTANCE VOUCHER'

			SELECT @AFTER_DELETE_COUNT = COUNT(0) 
			FROM #TEMP_TRAN_SYNC_CANCEL 

			UPDATE S SET S.CANCELAPPROVEDDATE = T.cancel_date, S.PAIDBY = T.paidBy, S.PAIDDATE = T.paidDate, S.TranStatus = T.transtatus, S.PayStatus = T.status,
					S.VOUCHER_GEN = 0,--CASE WHEN S.TranStatus <> T.TranStatus OR S.PayStatus <> T.PayStatus THEN 0 ELSE 1 END,
					S.STATUS_CHANGE_ON_UPDATE = CASE WHEN S.TranStatus <> T.transtatus OR S.PayStatus <> T.status THEN 0 ELSE 1 END,
					sync_date = GETDATE(),
					S.OLD_TRAN_STATUS = S.TranStatus, S.OLD_PAY_STATUS = S.PayStatus,
					S.NO_VOUCHER = 0
			FROM TXN_SYNC_STATUS S
			INNER JOIN #TEMP_TRAN_SYNC_CANCEL T ON T.CONTROLNO = S.CONTROLNO
			
			DELETE T
			FROM TXN_SYNC_STATUS S 
			INNER JOIN #TEMP_TRAN_SYNC_CANCEL T ON T.CONTROLNO = S.CONTROLNO
			
			----CREATE TABLE TXN_SYNC_STATUS(CONTROLNO VARCHAR(30), CONTROLNO_ENC VARCHAR(30), CANCELAPPROVEDDATE DATETIME, PAIDDATE DATETIME, PAIDBY VARCHAR(50), TranStatus VARCHAR(30), PayStatus VARCHAR(30), VOUCHER_GEN BIT)
			INSERT INTO TXN_SYNC_STATUS(CONTROLNO, CONTROLNO_ENC, CANCELAPPROVEDDATE, PAIDDATE, PAIDBY, TranStatus, PayStatus, VOUCHER_GEN, NO_VOUCHER, sync_date)
			SELECT t.CONTROLNO, t.REFNO_ENC, t.cancel_date, t.paidDate, t.paidBy, t.TranStatus, t.status, 0, 0, GETDATE()
			FROM #TEMP_TRAN_SYNC_CANCEL T
			INNER JOIN REMITTRAN R(NOLOCK) ON T.REFNO_ENC = R.CONTROLNO
			
			UPDATE T SET T.OLD_CANCEL_DATE = R.CANCELAPPROVEDDATE, T.OLD_PAID_DATE = R.PAIDDATE, T.old_status = R.TRANSTATUS, T.old_paystatus = R.PAYSTATUS, T.createddaate = R.CREATEDDATE
			FROM REMITTRAN R(NOLOCK)
			INNER JOIN #TEMP_TRAN_SYNC_CANCEL TMP ON TMP.REFNO_ENC = R.controlno
			INNER JOIN TXN_SYNC_STATUS T(NOLOCK) ON T.CONTROLNO_ENC = TMP.REFNO_ENC
			
			SET @MSG = 'Download successful for Total: '+CAST(@TOTAL_COUNT AS VARCHAR) +' DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR)
			
			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
		IF @FLAG = 'TRANSACTION-DOWNLOAD'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_TRAN_TRAN') IS NOT NULL DROP TABLE #TEMP_TRAN_TRAN
		
			SET @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(RefNo)[1]','VARCHAR(20)') AS 'RefNo'
						,p.value('(pCurrCostRate)[1]','FLOAT') AS 'pCurrCostRate'
						,p.value('(PCurrMargin)[1]','FLOAT') AS 'PCurrMargin'
						,p.value('(custRate)[1]','FLOAT') AS 'custRate'
						,p.value('(SCharge)[1]','MONEY') AS 'SCharge'
						,p.value('(senderCommission)[1]','VARCHAR(20)') AS 'senderCommission'
						,p.value('(pAgentComm)[1]','VARCHAR(20)') AS 'pAgentComm'
						,p.value('(pAgentCommCurr)[1]','VARCHAR(5)') AS 'pAgentCommCurr'
						,p.value('(AgentCode)[1]','VARCHAR(20)') AS 'AgentCode'
						,p.value('(Branch1)[1]','VARCHAR(150)') AS 'Branch1'
						,p.value('(Branch_Code)[1]','VARCHAR(150)') AS 'Branch_Code'
						,p.value('(Branch)[1]','VARCHAR(150)') AS 'Branch'
						,p.value('(ReceiverCountry)[1]','VARCHAR(50)') AS 'ReceiverCountry'
						,p.value('(paymentType)[1]','VARCHAR(50)') AS 'paymentType'
						,p.value('(ben_bank_id_BANK)[1]','VARCHAR(150)') AS 'ben_bank_id_BANK'
						,p.value('(ben_bank_name_BANK)[1]','VARCHAR(150)') AS 'ben_bank_name_BANK'
						,p.value('(ben_bank_id)[1]','VARCHAR(150)') AS 'ben_bank_id'
						,p.value('(ben_bank_name)[1]','VARCHAR(150)') AS 'ben_bank_name'
						,p.value('(rBankAcNo)[1]','VARCHAR(150)') AS 'rBankAcNo'
						,p.value('(collMode)[1]','VARCHAR(50)') AS 'collMode'
						,p.value('(paidAmt)[1]','MONEY') AS 'paidAmt'
						,p.value('(receiveAmt)[1]','MONEY') AS 'receiveAmt'
						,p.value('(TotalRountAmt)[1]','MONEY') AS 'TotalRountAmt'
						,p.value('(receiveCType)[1]','VARCHAR(20)') AS 'receiveCType'
						,p.value('(ReceiverRelation)[1]','VARCHAR(150)') AS 'ReceiverRelation'
						,p.value('(reason_for_remittance)[1]','VARCHAR(150)') AS 'reason_for_remittance'
						,p.value('(source_of_income)[1]','VARCHAR(150)') AS 'source_of_income'
						,p.value('(TranStatus)[1]','VARCHAR(50)') AS 'TranStatus'
						,p.value('(PayStatus)[1]','VARCHAR(50)') AS 'PayStatus'
						,p.value('(sTime)[1]','VARCHAR(50)') AS 'sTime'
						,p.value('(sempid)[1]','VARCHAR(50)') AS 'sempid'
						,p.value('(approve_by)[1]','VARCHAR(50)') AS 'approve_by'
						,p.value('(confirmdate)[1]','VARCHAR(50)') AS 'confirmdate'
						,p.value('(sendername)[1]','VARCHAR(250)') AS 'sendername'
						,p.value('(receivername)[1]','VARCHAR(250)') AS 'receivername'
						,p.value('(TranNo)[1]','VARCHAR(50)') AS 'TranNo'
						,p.value('(firstName)[1]','VARCHAR(250)') AS 'firstName'
						,p.value('(fullName)[1]','VARCHAR(250)') AS 'fullName'
						,p.value('(senderstate)[1]','VARCHAR(150)') AS 'senderstate'
						,p.value('(sendercity)[1]','VARCHAR(150)') AS 'sendercity'
						,p.value('(senderAddress)[1]','VARCHAR(250)') AS 'senderAddress'
						,p.value('(SenderPhoneno)[1]','VARCHAR(50)') AS 'SenderPhoneno'
						,p.value('(sender_mobile)[1]','VARCHAR(50)') AS 'sender_mobile'
						,p.value('(senderNativeCountry)[1]','VARCHAR(50)') AS 'senderNativeCountry'
						,p.value('(senderFax)[1]','VARCHAR(50)') AS 'senderFax'
						,p.value('(senderPassport)[1]','VARCHAR(50)') AS 'senderPassport'
						,p.value('(ID_issue_Date)[1]','VARCHAR(50)') AS 'ID_issue_Date'
						,p.value('(senderVisa)[1]','VARCHAR(50)') AS 'senderVisa'
						,p.value('(ip_address)[1]','VARCHAR(50)') AS 'ip_address'
						,p.value('(dateofbirth)[1]','VARCHAR(50)') AS 'dateofbirth'
						,p.value('(senderzipcode)[1]','VARCHAR(50)') AS 'senderzipcode'
						,p.value('(customer_sno)[1]','VARCHAR(50)') AS 'customer_sno'
						,p.value('(senderemail)[1]','VARCHAR(50)') AS 'senderemail'
						,p.value('(rfirstName)[1]','VARCHAR(250)') AS 'rfirstName'
						,p.value('(rFullName)[1]','VARCHAR(250)') AS 'rFullName'
						,p.value('(rCountry)[1]','VARCHAR(50)') AS 'rCountry'
						,p.value('(receiverAddress)[1]','VARCHAR(150)') AS 'receiverAddress'
						,p.value('(receiver_mobile)[1]','VARCHAR(150)') AS 'receiver_mobile'
						,p.value('(ReceiverId)[1]','VARCHAR(150)') AS 'ReceiverId'
						,p.value('(rRel)[1]','VARCHAR(150)') AS 'rRel'
						,p.value('(receiver_sno)[1]','VARCHAR(150)') AS 'receiver_sno'
			INTO #TEMP_TRAN
			FROM @XMLDATA.nodes('/ArrayOfTransactionResponse/TransactionResponse') AS TEMP_TRAN(p)

			--UPDATE #TEMP_TRAN_TRAN SET sTime = dbo.fn_ConvertToDateTime(sTime), dateofbirth = dbo.fn_ConvertToDateTime(dateofbirth)
			--		, ID_issue_Date = dbo.fn_ConvertToDateTime(ID_issue_Date)

			--SELECT * FROM #TEMP_TRAN_TRAN
			ALTER TABLE #TEMP_TRAN ADD pCurr VARCHAR(5), REFNO_ENC VARCHAR(30)

			SELECT @TOTAL_COUNT = COUNT(0) 
			FROM #TEMP_TRAN
			
			UPDATE T SET T.pCurr = C.CURRENCYCODE, REFNO_ENC = DBO.FNAENCRYPTSTRING(REFNO)
			FROM #TEMP_TRAN	 T
			INNER JOIN COUNTRYMASTER CM ON CM.COUNTRYNAME = T.RECEIVERCOUNTRY
			INNER JOIN COUNTRYCURRENCY CC ON CC.COUNTRYID = CM.COUNTRYID
			INNER JOIN CURRENCYMASTER C ON C.CURRENCYID = CC.CURRENCYID
			WHERE CC.isDefault = 'Y'

			DELETE T 
			FROM #TEMP_TRAN T
			INNER JOIN remitTranTEMP R(NOLOCK) ON R.CONTROLNO = T.REFNO_ENC

			DELETE T 
			FROM #TEMP_TRAN T
			INNER JOIN remitTran R(NOLOCK) ON R.CONTROLNO = T.REFNO_ENC

			DELETE T 
			FROM #TEMP_TRAN T
			INNER JOIN TEMP_TRAN R(NOLOCK) ON R.RefNo = T.RefNo

			UPDATE #TEMP_TRAN SET confirmDate = CASE WHEN confirmDate = '0001-01-01' THEN NULL ELSE confirmDate END,
				sTime = CASE WHEN sTime = '0001-01-01' THEN NULL ELSE sTime END,
				dateofbirth = CASE WHEN dateofbirth = '0001-01-01' THEN NULL ELSE dateofbirth END,
				ID_issue_Date = CASE WHEN ID_issue_Date = '0001-01-01' THEN NULL ELSE ID_issue_Date END,
				senderPassport = CASE WHEN senderPassport = '0001-01-01' THEN NULL ELSE senderPassport END,
				senderVisa = CASE WHEN senderVisa = '0001-01-01' THEN NULL ELSE senderVisa END

			UPDATE #TEMP_TRAN SET confirmDate = CASE WHEN confirmDate = '0001-01-01T00:00:00' THEN NULL ELSE confirmDate END,
				sTime = CASE WHEN sTime = '0001-01-01T00:00:00' THEN NULL ELSE sTime END,
				dateofbirth = CASE WHEN dateofbirth = '0001-01-01T00:00:00' THEN NULL ELSE dateofbirth END,
				ID_issue_Date = CASE WHEN ID_issue_Date = '0001-01-01T00:00:00' THEN NULL ELSE ID_issue_Date END,
				senderPassport = CASE WHEN senderPassport = '0001-01-01T00:00:00' THEN NULL ELSE senderPassport END,
				senderVisa = CASE WHEN senderVisa = '0001-01-01T00:00:00' THEN NULL ELSE senderVisa END

			SELECT @AFTER_DELETE_COUNT = COUNT(0) 
			FROM #TEMP_TRAN
			
			INSERT INTO TEMP_TRAN(RefNo, pCurrCostRate, PCurrMargin, custRate, SCharge, senderCommission, pAgentComm, pAgentCommCurr, AgentCode, Branch1, Branch_Code, Branch, ReceiverCountry, paymentType
								, ben_bank_id_BANK, ben_bank_name_BANK, ben_bank_id, ben_bank_name, rBankAcNo, collMode, paidAmt, receiveAmt, TotalRountAmt, receiveCType, ReceiverRelation, reason_for_remittance
								, source_of_income, TranStatus, PayStatus, sTime, sempid, approve_by, confirmdate, sendername, receivername, TranNo, firstName, fullName, senderstate, sendercity, senderAddress
								, SenderPhoneno, sender_mobile, senderNativeCountry, senderFax, senderPassport, ID_issue_Date, senderVisa, ip_address, dateofbirth, senderzipcode, customer_sno, senderemail
								, rfirstName, rFullName, rCountry, receiverAddress, receiver_mobile, ReceiverId, rRel, receiver_sno, pCurr, REFNO_ENC)
			SELECT RefNo, pCurrCostRate, PCurrMargin, custRate, SCharge, senderCommission, pAgentComm, pAgentCommCurr, AgentCode, Branch1, Branch_Code, Branch, ReceiverCountry, paymentType
								, ben_bank_id_BANK, ben_bank_name_BANK, ben_bank_id, ben_bank_name, rBankAcNo, collMode, paidAmt, receiveAmt, TotalRountAmt, receiveCType, ReceiverRelation, reason_for_remittance
								, source_of_income, TranStatus, PayStatus, sTime, sempid, approve_by, confirmdate, sendername, receivername, TranNo, firstName, fullName, senderstate, sendercity, senderAddress
								, SenderPhoneno, sender_mobile, senderNativeCountry, senderFax, senderPassport, ID_issue_Date, senderVisa, ip_address, dateofbirth, senderzipcode, customer_sno, senderemail
								, rfirstName, rFullName, rCountry, receiverAddress, receiver_mobile, ReceiverId, rRel, receiver_sno, pCurr, REFNO_ENC 
			FROM #TEMP_TRAN
			SET @MSG = 'Download successful Total: '+CAST(@TOTAL_COUNT AS VARCHAR)+' DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR)

			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
		IF @FLAG = 'MAIN-SAVE'
		BEGIN
			BEGIN TRANSACTION
				INSERT INTO remitTranTEMP
					(
						controlNo,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,customerRate,
						serviceCharge,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,SBRANCHNAME,
						pCountry,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName,
						paymentMethod,
						pBank,pBankName,pBankBranch,pBankBranchName,accountNo,
						collMode,collCurr,cAmt,TAMT,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,
						payStatus,createdBy,createdDate,approvedDate,approvedBy,tranType,senderName,receiverName,agentCrossSettRate,
						agentFxGain,controlNo2,isScMaunal,originalSC,promotionCode,uploadLogId
					)	

				SELECT REFNO_ENC
					,0 ,0 ,0
					,pCurrCostRate
					,pCurrMargin, 0 
					,custRate
					,SCharge,senderCommission, 'JPY',pAgentComm, pAgentCommCurr = CASE WHEN RECEIVERCOUNTRY IN ('VIETNAM') THEN 'VND' ELSE 'JPY' END 
					,'JAPAN', 393877, 'Japan Money Express Co., Ltd.',AGENTCODE,BRANCH1,Branch_CODE,Branch
					,RECEIVERCOUNTRY
					,psagetn = CASE WHEN RECEIVERCOUNTRY = 'NEPAL' THEN 393880
						WHEN RECEIVERCOUNTRY = 'Vietnam' THEN 394132
						ELSE 394130 END
					,psagentName = CASE WHEN RECEIVERCOUNTRY = 'NEPAL' THEN 'JME Nepal'
						WHEN RECEIVERCOUNTRY = 'Vietnam' THEN 'Donga bank'
						ELSE 'TransFast' END
					,pagent = CASE WHEN RECEIVERCOUNTRY = 'NEPAL' THEN 393882
						WHEN RECEIVERCOUNTRY = 'Vietnam' THEN 394133
						ELSE 394131 END
					,pagentName = CASE WHEN RECEIVERCOUNTRY = 'NEPAL' THEN 'JME Nepal-HO'
						WHEN RECEIVERCOUNTRY = 'Vietnam' THEN 'Donga Bank Settling Agent'
						ELSE 'TransFast Settling Agent' END
					,pbranch = CASE WHEN RECEIVERCOUNTRY = 'NEPAL' THEN 393882
					WHEN RECEIVERCOUNTRY = 'Vietnam' THEN 394133
					ELSE 394131 END
					,pbranchName = CASE WHEN RECEIVERCOUNTRY = 'NEPAL' THEN 'JME Nepal-HO'
						WHEN RECEIVERCOUNTRY = 'Vietnam' THEN 'Donga Bank Settling Agent'
						ELSE 'TransFast Settling Agent' END
					,paymentType
					,ben_bank_id_BANK = case when isnumeric(ben_bank_id) = 1 then ben_bank_id else 0 end,ben_bank_name_BANK,ben_bank_id = case when isnumeric(ben_bank_id) = 1 then ben_bank_id else 0 end,ben_bank_name,rBankACNo
					,collMode,'JPY',paidAmt, tamt = paidAmt - ISNULL(SCharge, 0),floor(receiveAmt) --TotalRoundAmt
					,pCurr,ReceiverRelation,reason_for_remittance,source_of_income
					,TranStatus, PayStatus,sempid,sTime,confirmDate
					,approve_by, 'I',SenderName,ReceiverName,0 agentCrossSettRate
					,0, NULL, CASE WHEN ISNULL(SCharge, 0) = 0 THEN 0 ELSE 1 END isScMaunal, 0, PROMOTIONCODE,Tranno
				from TEMP_TRAN

				INSERT INTO dbo.tranSendersTEMP
				(
					tranId,customerId,firstName,fullName,country,[state],city,address,email,
					homePhone,mobile,nativeCountry,idType,idNumber,issuedDate,validDate,ipAddress,zipCode,extCustomerId,dob
				)
				SELECT 
				r.id,0,t.firstName, fullName, 'JAPAN', senderstate, sendercity,senderaddress,senderemail,sender_mobile,SenderPhoneno
				,SenderNativeCountry,senderFax,senderPassport,ID_Issue_date
				,senderVisa,ip_address,SENDERZIPCODE,customer_sno,dateofbirth
				from TEMP_TRAN t
				inner join remittranTEMP r (nolock)on r.uploadLogId=t.Tranno

				INSERT INTO tranReceiversTemp
				(
					tranId,customerId,firstName,fullName,country,[address],mobile,relationType,oldSysCustId
				)
				SELECT 
				r.id,0,rfirstName,rFullName,receivercountry rCountry,receiveraddress,receiver_mobile,ReceiverRelation rRel,receiver_sno
				from TEMP_TRAN t
				inner join remittranTEMP r (nolock)on r.uploadLogId=t.Tranno
				
				UPDATE T SET T.CUSTOMERID = C.CUSTOMERID, T.MEMBERSHIPID = C.MEMBERSHIPID 
				FROM tranSendersTemp T(NOLOCK)
				INNER JOIN REMITTRANtemp RT(NOLOCK) ON RT.ID = T.TRANID
				LEFT JOIN customerMaster C(NOLOCK) ON C.OBPID = T.extCustomerId
				WHERE RT.UPLOADLOGID IS NOT NULL
				
				--UPDATE T SET T.CUSTOMERID = C.CUSTOMERID, T.MEMBERSHIPID = C.MEMBERSHIPID 
				----SELECT T.FULLNAME, C.FULLNAME,RT.SENDERNAME,T.CUSTOMERID,C.CUSTOMERID
				--FROM tranSenders T(NOLOCK)
				--INNER JOIN REMITTRAN RT(NOLOCK) ON RT.ID = T.TRANID
				--LEFT JOIN customerMaster C(NOLOCK) ON C.OBPID = T.extCustomerId
				--WHERE RT.UPLOADLOGID IS NOT NULL
				----AND T.CUSTOMERID<>C.CUSTOMERID
				--AND T.CUSTOMERID IS NULL
				--AND C.POSTALCODE IS NOT NULL

				UPDATE T SET T.CUSTOMERID=RECEIVERID, T.MEMBERSHIPID=R.MEMBERSHIPID 
				FROM TRANRECEIVERstemp T(NOLOCK)
				INNER JOIN REMITTRANtemp RT(NOLOCK) ON RT.ID = T.TRANID
				LEFT JOIN RECEIVERINFORMATION R(NOLOCK) ON R.tempRId = T.oldSysCustId
				WHERE RT.UPLOADLOGID IS NOT NULL

				INSERT INTO controlNoList(controlNo)
				SELECT controlno from remittrantemp
				where uploadlogid is not null

				UPDATE RT
				SET RT.PAGENTCOMM = CASE WHEN RT.PSUPERAGENT IN (393880, 394130) AND ISNULL(RT.SERVICECHARGE, 0) > 0 
													THEN CASE WHEN RT.PSUPERAGENT=393880 THEN (RT.SERVICECHARGE)*0.25 
													WHEN (RT.PSUPERAGENT=394130 AND RT.PCOUNTRY IN ('Indonesia')) THEN RT.SERVICECHARGE*0.65
													WHEN (RT.PSUPERAGENT=394130 AND RT.PCOUNTRY NOT IN ('Indonesia')) THEN RT.SERVICECHARGE*0.60
									ELSE 0 END
									END
					,pagentcommcurrency = 'JPY'
				FROM REMITTRANTEMP RT
				WHERE UPLOADLOGID IS NOT NULL
			
				UPDATE remittranTEMP SET pagentcomm = CASE WHEN PAYMENTMETHOD = 'HOME DELIVERY' THEN PAMT * 0.004 ELSE pamt * 0.0017 END
					, pagentcommcurrency = 'VND' 
				WHERE 1=1
				AND PCOUNTRY = 'VIETNAM'
				AND UPLOADLOGID IS NOT NULL

				--UPDATE REMITTRANTEMP SET agentFxGain = CASE WHEN PCOUNTRY = 'Nepal' THEN (tAmt - (pAmt / pCurrCostRate))
				--											ELSE (pCurrCostRate - customerRate) * (tAmt / pCurrCostRate)
				--										END
				--WHERE PCOUNTRY <> 'VIETNAM'
		
				UPDATE REMITTRANTEMP SET agentFxGain = tamt - (ROUND((pamt / pCurrCostRate), 2))
				WHERE PCOUNTRY <> 'VIETNAM'
				AND UPLOADLOGID IS NOT NULL

				
				UPDATE R SET R.SAGENT = AM.AGENTID, R.SAGENTNAME = AM.AGENTNAME, R.SBRANCH = AM.AGENTID, R.SBRANCHNAME = AM.AGENTNAME 
				FROM REMITTRANTEMP R
				INNER JOIN REFERRAL_AGENT_WISE A ON A.REFERRAL_CODE = R.promotionCode
				INNER JOIN AGENTMASTER AM ON AM.AGENTID = A.BRANCH_ID
				WHERE UPLOADLOGID IS NOT NULL

				UPDATE R SET R.SAGENT = 394392, R.SAGENTNAME = 'Tokyo Main-Head Office', R.SBRANCH = 394392, R.SBRANCHNAME = 'Tokyo Main-Head Office'
				FROM REMITTRANTEMP R
				WHERE COLLMODE = 'BANK DEPOSIT'
				AND UPLOADLOGID IS NOT NULL

				--UPDATE ALLL THE TRANSACTIONS OF OUR INTERNAL AGENTS
				update rt set rt.sbranch = 394394, rt.sagent = 394394, rt.sagentname = 'Amrita KC Lamichhane,Gunma', rt.promotionCode = null,
				rt.sbranchname = 'Amrita KC Lamichhane,Gunma'
				FROM remittrantemp rt
				WHERE RT.promotionCode = 'JME0029'
				AND UPLOADLOGID IS NOT NULL

				update rt set rt.sbranch = 394393, rt.sagent = 394393, rt.sagentname = 'Sanjog Duwadi,Yokohama', rt.promotionCode = null,
				rt.sbranchname = 'Sanjog Duwadi,Yokohama' 
				FROM remittrantemp rt 
				WHERE RT.promotionCode = 'JME0017'
				AND UPLOADLOGID IS NOT NULL

				
				update t set t.sagentname = am.agentname, t.sagent = am.agentId, 
							t.sbranchname = am.agentname, t.sbranch = am.agentId
				from remittrantemp t(NOLOCK)
				inner join TEMP_TRAN tt on tt.REFNO_ENC = t.controlno
				inner join applicationusers a(NOLOCK) on a.username = t.createdby
				inner join agentmaster am(NOLOCK) on am.agentid = a.agentid
				where (t.sagent not in (select agentid from agentmaster) OR T.SAGENT IS NULL)
				AND UPLOADLOGID IS NOT NULL
				
				INSERT INTO send_voucher 
				SELECT DBO.DECRYPTDB(CONTROLNO) CONTROLNO, ID, cancelApproveddate, 0 voucher_gen, 
						is_cancel = 0, paidDate 
				FROM REMITTRANTEMP (NOLOCK) 
				where uploadlogid is not null
				
				DELETE T
				FROM TEMP_TRAN T(NOLOCK)
				INNER JOIN remitTranTemp R(NOLOCK) ON R.CONTROLNO = T.REFNO_ENC

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION

			EXEC PROC_ERRORHANDLER 0, 'Data moved successfully!', null
		END
		IF @FLAG = 'SHOW'
		BEGIN
			IF @FILTER1 IS NULL
			BEGIN 
				SELECT TOTAL_COUNT = COUNT(0), REFERRAL_MAPPED = ISNULL(SUM(CASE WHEN ISNULL(T.PROMOTIONCODE, '') <> '' THEN 1 ELSE 0 END), 0)
						, UNMAPPED = ISNULL(SUM(CASE WHEN ISNULL(T.PROMOTIONCODE, '') = '' THEN 1 ELSE 0 END), 0)
				FROM TEMP_TRAN T(NOLOCK)
				WHERE T.sempid = (CASE WHEN (SELECT USERTYPE FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER) = 'A' THEN @USER ELSE T.sempid END)

				SELECT RefNo CONTROLNO, sempid, collMode, Tranno TRANID, REFERRAL_NAME REFERRAL, SENDERNAME, RECEIVERNAME
						, ReceiverCountry RECEIVERCOUNTRY, paidAmt COLLECTAMOUNT, paidAmt - ISNULL(SCharge, 0) SENTAMOUNT, floor(receiveAmt) PAYOUTAMOUNT, PROMOTIONCODE 
				FROM TEMP_TRAN T(NOLOCK)
				LEFT JOIN REFERRAL_AGENT_WISE A(NOLOCK) ON A.REFERRAL_CODE = T.PROMOTIONCODE
				WHERE T.sempid = (CASE WHEN (SELECT USERTYPE FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER) = 'A' THEN @USER ELSE T.sempid END)

				SELECT COUNT(0) TXN_NEED_TO_BE_APPROVED
				FROM send_voucher (NOLOCK)
				WHERE voucher_gen = 0
				RETURN;
			END
			ELSE IF @FILTER1 = 'M'
			BEGIN
				SELECT TOTAL_COUNT = COUNT(0), REFERRAL_MAPPED = SUM(CASE WHEN ISNULL(T.PROMOTIONCODE, '') <> '' THEN 1 ELSE 0 END)
						, UNMAPPED = SUM(CASE WHEN ISNULL(T.PROMOTIONCODE, '') = '' THEN 1 ELSE 0 END)
				FROM TEMP_TRAN T(NOLOCK)
				WHERE PROMOTIONCODE IS NOT NULL
				AND T.sempid = (CASE WHEN (SELECT USERTYPE FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER) = 'A' THEN @USER ELSE T.sempid END)

				SELECT RefNo CONTROLNO, sempid, collMode, Tranno TRANID, REFERRAL_NAME REFERRAL, SENDERNAME, RECEIVERNAME
						, ReceiverCountry RECEIVERCOUNTRY, paidAmt COLLECTAMOUNT, paidAmt - ISNULL(SCharge, 0) SENTAMOUNT, floor(receiveAmt) PAYOUTAMOUNT, PROMOTIONCODE 
				FROM TEMP_TRAN T(NOLOCK)
				LEFT JOIN REFERRAL_AGENT_WISE A(NOLOCK) ON A.REFERRAL_CODE = T.PROMOTIONCODE
				WHERE PROMOTIONCODE IS NOT NULL
				AND T.sempid = (CASE WHEN (SELECT USERTYPE FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER) = 'A' THEN @USER ELSE T.sempid END)
				
				SELECT COUNT(0) TXN_NEED_TO_BE_APPROVED
				FROM send_voucher (NOLOCK)
				WHERE voucher_gen = 0
				RETURN;
			END
			ELSE
			BEGIN	
				SELECT TOTAL_COUNT = COUNT(0), REFERRAL_MAPPED = SUM(CASE WHEN ISNULL(T.PROMOTIONCODE, '') <> '' THEN 1 ELSE 0 END)
						, UNMAPPED = SUM(CASE WHEN ISNULL(T.PROMOTIONCODE, '') = '' THEN 1 ELSE 0 END)
				FROM TEMP_TRAN T(NOLOCK)
				WHERE PROMOTIONCODE IS NULL
				AND T.sempid = (CASE WHEN (SELECT USERTYPE FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER) = 'A' THEN @USER ELSE T.sempid END)

				SELECT RefNo CONTROLNO, sempid, collMode, Tranno TRANID, REFERRAL_NAME REFERRAL, SENDERNAME, RECEIVERNAME
						, ReceiverCountry RECEIVERCOUNTRY, paidAmt COLLECTAMOUNT, paidAmt - ISNULL(SCharge, 0) SENTAMOUNT, floor(receiveAmt) PAYOUTAMOUNT, PROMOTIONCODE 
				FROM TEMP_TRAN T(NOLOCK)
				LEFT JOIN REFERRAL_AGENT_WISE A(NOLOCK) ON A.REFERRAL_CODE = T.PROMOTIONCODE
				WHERE PROMOTIONCODE IS NULL
				AND T.sempid = (CASE WHEN (SELECT USERTYPE FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER) = 'A' THEN @USER ELSE T.sempid END)

				SELECT COUNT(0) TXN_NEED_TO_BE_APPROVED
				FROM send_voucher (NOLOCK)
				WHERE voucher_gen = 0
				RETURN;
			END
		END
		IF @FLAG = 'MAP'
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM TEMP_TRAN(NOLOCK) WHERE Tranno = @TRAN_ID)
			BEGIN
				EXEC PROC_ERRORHANDLER 1, 'No txn found!', null
				RETURN
			END	
			IF NOT EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE(NOLOCK) WHERE REFERRAL_CODE = @REFERRAL_CODE)
			BEGIN
				EXEC PROC_ERRORHANDLER 1, 'Invalid referral!', null
				RETURN
			END	

			UPDATE TEMP_TRAN SET PROMOTIONCODE = @REFERRAL_CODE
			WHERE Tranno = @TRAN_ID

			EXEC PROC_ERRORHANDLER 0, 'Success mapping referral!', null
		END
		IF @FLAG = 'DELETE-TRAN'
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM remitTranTemp(NOLOCK))
			BEGIN
				EXEC PROC_ERRORHANDLER 1, 'No txn found in remittrantemp table for delete!', null
				RETURN
			END	
			
			SELECT @TOTAL_COUNT = COUNT(0) FROM remitTranTemp(NOLOCK)

			--DELETE FROM remitTranTemp 
			--DELETE FROM tranSendersTemp
			--DELETE FROM tranReceiversTemp

			SELECT @MSG = 'Total '+CAST(@TOTAL_COUNT AS VARCHAR)+' records delete from remittrantemp table'

			EXEC PROC_ERRORHANDLER 0, 'You can not delete transaction''s now', null
		END
		IF @FLAG = 'BULK-MAP'
		BEGIN
			SET @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  AGENTNAME = p.value('@AGENTNAME', 'varchar(150)') ,
					CONTROLNO = p.value('@CONTROLNO', 'varchar(30)') 
			INTO #MAP_DATA
			FROM    @XMLDATA.nodes('/root/row') AS tmp ( p );

			ALTER TABLE #MAP_DATA ADD CONTROLNO_ENC VARCHAR(30)

			UPDATE #MAP_DATA SET AgentName = LTRIM(RTRIM(AGENTNAME)), CONTROLNO_ENC = DBO.FNAENCRYPTSTRING(LTRIM(RTRIM(CONTROLNO)))
			
			SELECT R.REFERRAL_CODE, M.*
			INTO #MAIN_DATA 
			FROM #MAP_DATA M
			INNER JOIN REFERRAL_AGENT_WISE R(NOLOCK) ON LTRIM(RTRIM(R.REFERRAL_NAME)) = M.AGENTNAME

			--UPDATE R SET R.PROMOTIONCODE = M.REFERRAL_CODE 
			--FROM #MAIN_DATA M
			--INNER JOIN REMITTRANTEMP R ON R.CONTROLNO = M.CONTROLNO_ENC
			--WHERE ISNULL(R.PROMOTIONCODE, '') = ''

			UPDATE R SET R.PROMOTIONCODE = M.REFERRAL_CODE 
			FROM #MAIN_DATA M
			INNER JOIN TEMP_TRAN R ON R.REFNO_ENC = M.CONTROLNO_ENC
			WHERE ISNULL(R.PROMOTIONCODE, '') = ''

			EXEC PROC_ERRORHANDLER 0, 'Success mapping referral!', null
		END
		IF @FLAG = 'DELETE'
		BEGIN
			DELETE FROM TEMP_TRAN
		END
		IF @FLAG = 'CUSTOMER-DOWNLOAD'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_CUSTOMER_DATA') IS NOT NULL DROP TABLE #TEMP_CUSTOMER_DATA
		
			SET @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(SenderName)[1]','VARCHAR(200)') AS 'SenderName'
						,p.value('(SenderMiddleName)[1]','VARCHAR(100)') AS 'SenderMiddleName'
						,p.value('(SenderLastName)[1]','VARCHAR(100)') AS 'SenderLastName'
						,p.value('(Country)[1]','VARCHAR(50)') AS 'Country'
						,p.value('(SenderZipCode)[1]','VARCHAR(50)') AS 'SenderZipCode'
						,p.value('(SenderCity)[1]','VARCHAR(50)') AS 'SenderCity'
						,p.value('(SenderState)[1]','VARCHAR(50)') AS 'SenderState'
						,p.value('(SenderEmail)[1]','VARCHAR(50)') AS 'SenderEmail'
						,p.value('(SenderMobile2)[1]','VARCHAR(30)') AS 'SenderMobile2'
						,p.value('(SenderMobile)[1]','VARCHAR(30)') AS 'SenderMobile'
						,p.value('(SenderNativeCountry)[1]','VARCHAR(50)') AS 'SenderNativeCountry'
						,p.value('(Date_of_birth)[1]','VARCHAR(50)') AS 'Date_of_birth'
						,p.value('(Sender_Occupation)[1]','VARCHAR(150)') AS 'Sender_Occupation'
						,p.value('(Gender)[1]','VARCHAR(30)') AS 'Gender'
						,p.value('(FullName)[1]','VARCHAR(250)') AS 'FullName'
						,p.value('(Create_by)[1]','VARCHAR(50)') AS 'Create_by'
						,p.value('(create_ts)[1]','VARCHAR(50)') AS 'create_ts'
						,p.value('(id_issue_DATE)[1]','VARCHAR(50)') AS 'id_issue_DATE'
						,p.value('(SENDERVISA)[1]','VARCHAR(100)') AS 'SENDERVISA'
						,p.value('(SenderFax)[1]','VARCHAR(100)') AS 'SenderFax'
						,p.value('(SenderPassport)[1]','VARCHAR(100)') AS 'SenderPassport'
						,p.value('(Is_ACT)[1]','VARCHAR(50)') AS 'Is_ACT'
						,p.value('(approve_by)[1]','VARCHAR(50)') AS 'approve_by'
						,p.value('(approve_ts)[1]','VARCHAR(50)') AS 'approve_ts'
						,p.value('(cust_type)[1]','VARCHAR(50)') AS 'cust_type'
						,p.value('(is_enable)[1]','VARCHAR(50)') AS 'is_enable'
						,p.value('(Force_Change_Pwd)[1]','VARCHAR(50)') AS 'Force_Change_Pwd'
						,p.value('(source_of_income)[1]','VARCHAR(150)') AS 'source_of_income'
						,p.value('(SenderAddress)[1]','VARCHAR(150)') AS 'SenderAddress'
						,p.value('(CustomerType)[1]','VARCHAR(50)') AS 'CustomerType'
						,p.value('(EmploymentType)[1]','VARCHAR(50)') AS 'EmploymentType'
						,p.value('(NameOfEmp)[1]','VARCHAR(150)') AS 'NameOfEmp'
						,p.value('(SSN_cardId)[1]','VARCHAR(50)') AS 'SSN_cardId'
						,p.value('(Is_Active)[1]','VARCHAR(50)') AS 'Is_Active'
						,p.value('(Customer_remarks)[1]','VARCHAR(250)') AS 'Customer_remarks'
						,p.value('(sendercompany)[1]','VARCHAR(250)') AS 'sendercompany'
						,p.value('(RegdNo)[1]','VARCHAR(50)') AS 'RegdNo'
						,p.value('(Org_Type)[1]','VARCHAR(50)') AS 'Org_Type'
						,p.value('(Date_OfInc)[1]','VARCHAR(50)') AS 'Date_OfInc'
						,p.value('(Nature_OD_Company)[1]','VARCHAR(150)') AS 'Nature_OD_Company'
						,p.value('(Position)[1]','VARCHAR(150)') AS 'Position'
						,p.value('(NameOfAuthorizedPerson)[1]','VARCHAR(100)') AS 'NameOfAuthorizedPerson'
						,p.value('(Income)[1]','VARCHAR(100)') AS 'Income'
						,p.value('(SNo)[1]','VARCHAR(50)') AS 'SNo'
						,p.value('(CustomerId)[1]','VARCHAR(50)') AS 'CustomerId'
			INTO #TEMP_CUSTOMER_DATA
			FROM @XMLDATA.nodes('/ArrayOfCustomerData/CustomerData') AS TEMP_TRAN(p)
			
			UPDATE #TEMP_CUSTOMER_DATA set SenderNativeCountry = 'South Korea' where SenderNativeCountry = 'KOREA, REPUBLIC OF'
			
			ALTER TABLE #TEMP_CUSTOMER_DATA ADD SenderNativeCountryid INT

			UPDATE T SET T.SenderNativeCountryid = C.countryId 
			FROM #TEMP_CUSTOMER_DATA T
			LEFT JOIN countrymaster C ON C.countryname = T.SenderNativeCountry

			ALTER TABLE #TEMP_CUSTOMER_DATA ADD sender_occupationId INT

			update #TEMP_CUSTOMER_DATA
			SET sender_occupationId = CASE 
										WHEN sender_occupation IN ('Skil', 'Skilled Labor', 'BUSINESS MANAGER') THEN '8088'
											   WHEN sender_occupation IN  ('Business', 'BUSINESS OWNER') THEN '2004'
											   WHEN sender_occupation IN  ('DEPENDENT') THEN '11143'
											   WHEN sender_occupation IN  ('COMPANY EMPLOYEE') THEN '11143'
											   WHEN sender_occupation IN  ('UNEMPLOYED') THEN '11144'
											   WHEN sender_occupation IN  ('TRAINEE') THEN '2012'
											   WHEN sender_occupation IN  ('Others (please specific in remark)') THEN '8088'
											   WHEN sender_occupation IN  ('Part Time Job Holder') THEN '4701'
											   WHEN sender_occupation IN  ('HOUSE WIFE') THEN '8085'
											ELSE '2012' END

			ALTER TABLE #TEMP_CUSTOMER_DATA ADD genderid INT

			UPDATE #TEMP_CUSTOMER_DATA SET 
			genderid = CASE gender WHEN 'Male' THEN 97
								WHEN 'female' THEN 98
								ELSE NULL END
			
			ALTER TABLE #TEMP_CUSTOMER_DATA ADD senderfaxid INT 

			UPDATE #TEMP_CUSTOMER_DATA SET 
			senderfaxid = CASE senderfax 
							WHEN 'Drivers licence' THEN '11079'
							WHEN 'Passport' THEN '10997'
							WHEN 'National IC' THEN '8008'
							WHEN 'Driver License' THEN '11079'
							WHEN 'Tohon' THEN '11080'
							WHEN 'Residence Card' THEN '11168'
							WHEN 'Company Registration No' THEN '11172'
							WHEN 'Insurance Card' THEN '11078'
							WHEN 'Other Gov. Issued' THEN '11302'
							ELSE NULL END;

			ALTER TABLE #TEMP_CUSTOMER_DATA ADD source_of_incomeid INT

			UPDATE #TEMP_CUSTOMER_DATA SET 
			source_of_incomeid = CASE source_of_income 
								WHEN 'Salary' THEN '3901'
								WHEN 'Salary  Wages' THEN '3901'
								WHEN 'Others' THEN '11070'
								WHEN 'Loan (Borrow from others)' THEN '8079'
								WHEN 'Accumulated Salary' THEN '3901'
								WHEN 'Business Income' THEN '3902'
								WHEN 'Investment' THEN '11167'
								ELSE NULL END;

			ALTER TABLE #TEMP_CUSTOMER_DATA ADD CUSTOMERTYPEid INT

			UPDATE #TEMP_CUSTOMER_DATA SET 
			CUSTOMERTYPEid = CASE CUSTOMERTYPE 
								WHEN 'Individual' THEN '4700'
								WHEN 'Organizational' THEN '4701'
								WHEN 'Business Visa' THEN '4700'
								WHEN 'student' THEN '4700'
								WHEN 'Company Employee' THEN '4700'
								WHEN 'Designated Activities' THEN '4700'
								WHEN 'Resident' THEN '4700'
								WHEN 'Dependent' THEN '4700'
								WHEN 'Dependent of Japanese' THEN '4700'
								WHEN 'Other' THEN '4700'
								WHEN 'Permanent Resident, Non-Resident' THEN '4700'									 
								WHEN 'Non-Resident' THEN '4700'
								WHEN 'Sole Proprietor' THEN '4700'
								WHEN 'Dependent, Non-Resident' THEN '4700'
								WHEN 'Permanent Resident' THEN '4700'
								WHEN 'Training' THEN '4700'
								WHEN 'Japanese Citizen' THEN '4700'
								WHEN 'Designated Activities, Non-Resident' THEN '4700'
								WHEN 'Other, Non-Resident' THEN '4700'
								WHEN 'Company Employee, Non-Resident' THEN '4700'
								WHEN 'Skilled Labour' THEN '4700'
								WHEN 'student, Non-Resident' THEN '4700'
								WHEN 'Long Term resident' THEN '4700'
								WHEN 'Spouse or Child of  Japanese National' THEN '4700'
								WHEN 'Training, Non-Resident' THEN '4700'
								ELSE NULL END;

			ALTER TABLE #TEMP_CUSTOMER_DATA ADD employmentTypeid INT

			UPDATE #TEMP_CUSTOMER_DATA SET 
			employmentTypeid = CASE employmentType 
								WHEN 'Emplyeed' THEN '11007'
								WHEN 'Self-Employee' THEN '11008'
								WHEN 'Unemployee' THEN '11009'
								ELSE null END;
			
			SELECT @TOTAL_COUNT = COUNT(0)
			FROM #TEMP_CUSTOMER_DATA

			DELETE T
			FROM #TEMP_CUSTOMER_DATA T
			INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.postalcode = T.CustomerId

			SELECT @AFTER_DELETE_COUNT = COUNT(0)
			FROM #TEMP_CUSTOMER_DATA

			ALTER TABLE #TEMP_CUSTOMER_DATA ADD CITY VARCHAR(100), STREET VARCHAR(200), STATE_ID VARCHAR(20)

			UPDATE TMP SET TMP.CITY = T.CITY_NAME, TMP.STATE_ID = T.STATE_ID, TMP.STREET = T.STREET_NAME
			FROM #TEMP_CUSTOMER_DATA TMP(NOLOCK)
			INNER JOIN TBL_JAPAN_ADDRESS_DETAIL T(NOLOCK) ON T.ZIP_CODE = CAST(TMP.SenderZipCode AS INT)
			
			DECLARE @FROM_DATE VARCHAR(20), @TO_DATE VARCHAR(20)

			SELECT @FROM_DATE = MIN(CAST(create_ts AS DATE)), @TO_DATE = MAX(CAST(create_ts AS DATE))
			FROM #TEMP_CUSTOMER_DATA

			--DELETE FROM FASTMONEYPRO_REMIT.DBO.customerMaster
			--WHERE createddate BETWEEN @FROM_DATE AND @TO_DATE + ' 23:59:59'
			--AND OBPID IS NULL

			INSERT  INTO FASTMONEYPRO_REMIT.DBO.customerMaster(
				middleName
				,firstName,lastName1,country,zipCode,city,[state],email,homePhone,mobile,nativeCountry,dob,
				occupation,gender,
				fullName,
				createdBy,createdDate,idIssueDate,idExpiryDate,idType,idNumber,onlineUser,customerPassword,
				APPROVEDBY, APPROVEDDATE,customerType,isActive,isForcedPwdChange,sourceOfFund,street,
				visaStatus,employeeBusinessType,nameOfEmployeer,SSNNO,remittanceAllowed,remarks,companyname,
				registerationNo,organizationType,
				dateofIncorporation,natureOfCompany,position,nameOfAuthorizedPerson,monthlyIncome,obpid,postalCode
			)

			SELECT SENDERMIDDLENAME,SENDERNAME,SENDERLASTNAME,CAST(COUNTRY AS INT),CAST(SenderZipCode AS INT),CITY,STATE_ID,senderemail,SenderMobile2,CAST(sendermobile AS BIGINT),SenderNativeCountryid,date_of_birth
				,sender_occupationid, genderid
				, FULLNAME
				,create_by, create_ts, id_issue_date, sendervisa,senderFaxid,senderPassport,'Y', dbo.fnaencryptstring('jme@12345')
				,approve_by,approve_ts,CUST_TYPE,is_enable,FORCE_CHANGE_PWD,source_of_incomeid,STREET
				,null,employmentTypeid,null NAME_OF_EMP,SSN_cardId, IS_ACTIVE,customer_remarks,sendercompany
				,RegdNo, ORG_TYPE
				,Date_OfInc,NATURE_OD_COMPANY,POSITION,nameOfAuthorizedPerson
				,INCOME 
				,CAST(sno AS BIGINT),CAST(CustomerId AS INT)
			from #TEMP_CUSTOMER_DATA
			
			SET @MSG = 'Download successful Total: '+CAST(@TOTAL_COUNT AS VARCHAR)+' DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR)

			INSERT INTO CUSTOMER_DOWNLOAD_LOG(DOWNLOAD_COUNT, DUPLICATE_COUNT, MSG, DOWNLOAD_TYPE, CREATED_DATE, CREATED_BY)
			SELECT @TOTAL_COUNT, @TOTAL_COUNT - @AFTER_DELETE_COUNT, 'Download successful Total: '+CAST(@TOTAL_COUNT AS VARCHAR)+' 
						DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR) + ' (Download Date ' + @DATE + ')'
						, 'Customer', GETDATE(), @USER

			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
		IF @FLAG = 'RECEIVER-DOWNLOAD'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_RECEIVER_DATA') IS NOT NULL DROP TABLE #TEMP_RECEIVER_DATA
			
			SET @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(Col1)[1]','VARCHAR(100)') AS 'Col1'
						,p.value('(Sender_SNo)[1]','VARCHAR(20)') AS 'Sender_SNo'
						,p.value('(ReceiverName)[1]','VARCHAR(200)') AS 'ReceiverName'
						,p.value('(ReceiverMiddleName)[1]','VARCHAR(100)') AS 'ReceiverMiddleName'
						,p.value('(ReceiverLastName)[1]','VARCHAR(100)') AS 'ReceiverLastName'
						,p.value('(ReceiverCountry)[1]','VARCHAR(50)') AS 'ReceiverCountry'
						,p.value('(ReceiverAddress)[1]','VARCHAR(200)') AS 'ReceiverAddress'
						,p.value('(Col2)[1]','VARCHAR(100)') AS 'Col2'
						,p.value('(Col3)[1]','VARCHAR(100)') AS 'Col3'
						,p.value('(ReceiverCity)[1]','VARCHAR(100)') AS 'ReceiverCity'
						,p.value('(ReceiverEmail)[1]','VARCHAR(100)') AS 'ReceiverEmail'
						,p.value('(Col4)[1]','VARCHAR(100)') AS 'Col4'
						,p.value('(ReceiverFax)[1]','VARCHAR(100)') AS 'ReceiverFax'
						,p.value('(ReceiverMobile)[1]','VARCHAR(50)') AS 'ReceiverMobile'
						,p.value('(Relation)[1]','VARCHAR(50)') AS 'Relation'
						,p.value('(CustomerbenificiarType)[1]','VARCHAR(50)') AS 'CustomerbenificiarType'
						,p.value('(ReceiverIdDescription)[1]','VARCHAR(100)') AS 'ReceiverIdDescription'
						,p.value('(ReceiverId)[1]','VARCHAR(50)') AS 'ReceiverId'
						,p.value('(PaymentType)[1]','VARCHAR(50)') AS 'PaymentType'
						,p.value('(Commercial_bank_Id)[1]','VARCHAR(100)') AS 'Commercial_bank_Id'
						,p.value('(PayOutPartner)[1]','VARCHAR(100)') AS 'PayOutPartner'
						,p.value('(Api_partnet_bank_name)[1]','VARCHAR(100)') AS 'Api_partnet_bank_name'
						,p.value('(AccountNo)[1]','VARCHAR(50)') AS 'AccountNo'
						,p.value('(CustomerRemarks)[1]','VARCHAR(250)') AS 'CustomerRemarks'
						,p.value('(Reason_for_remittance)[1]','VARCHAR(50)') AS 'Reason_for_remittance'
						,p.value('(CreateBy)[1]','VARCHAR(50)') AS 'CreateBy'
						,p.value('(Create_TS)[1]','VARCHAR(50)') AS 'Create_TS'
						,p.value('(Col5)[1]','VARCHAR(150)') AS 'Col5'
						,p.value('(Col6)[1]','VARCHAR(150)') AS 'Col6'
						,p.value('(Col7)[1]','VARCHAR(150)') AS 'Col7'
						,p.value('(SNo)[1]','VARCHAR(50)') AS 'SNo'
			INTO #TEMP_RECEIVER_DATA
			FROM @XMLDATA.nodes('/ArrayOfReceiverData/ReceiverData') AS TEMP_TRAN(p)
			
			ALTER TABLE #TEMP_RECEIVER_DATA ADD relationship INT
			
			UPDATE #TEMP_RECEIVER_DATA SET relationship = CASE WHEN Relation IN ('Air Ticket', 'Air tikat', 'tikat fair') THEN 11089
															when Relation IN ('anti', 'aunt', 'Aunti', 'Aunty') THEN 2116
															when Relation IN ('borther in law', 'Brother in Law', 'BROTHR IN LAW') THEN 2110
															when Relation IN ('BROTHER', 'Brothers') THEN 2109
															when Relation IN ('Brother/ Sister', 'Brother Sister') THEN 11083
															when Relation IN ('Business Partner') THEN 11085
															when Relation IN ('Children') THEN 11082
															when Relation IN ('COUISN', 'Cousin') THEN 2117
															when Relation IN ('DAUGHTER') THEN 2114
															when Relation IN ('Daughter in Law') THEN 10998
															when Relation IN ('Donee') THEN 11090
															when Relation IN ('Employee') THEN 11087
															when Relation IN ('Employer') THEN 11086
															when Relation IN ('Family') THEN 11088
															when Relation IN ('father in law') THEN 2107
															when Relation IN ('FRIEND', 'Friends') THEN 2120
															when Relation IN ('Grand Father') THEN 2103
															when Relation IN ('husband') THEN 2105
															when Relation IN ('Motehr', 'mother') THEN 2102
															when Relation IN ('Parents') THEN 11081
												
															when Relation IN ('Relative') THEN 11303

															when Relation IN ('SELF') THEN 2121
															when Relation IN ('siser', 'SISTER') THEN 2111
															when Relation IN ('Sister in Law') THEN 2112
															when Relation IN ('son') THEN 2113

															when Relation IN ('Son in Law') THEN 11304
												
															when Relation IN ('Spouse') THEN 11305
															when Relation IN ('Student') THEN 11306

															when Relation IN ('UNCLE') THEN 2115
															when Relation IN ('Uncle/ Auntie', 'Uncle Auntie') THEN 11084
															when Relation IN ('wife') THEN 2106
															ELSE 11065
															end

			ALTER TABLE #TEMP_RECEIVER_DATA ADD purposeOfRemit INT

			UPDATE #TEMP_RECEIVER_DATA SET purposeOfRemit = CASE Reason_for_remittance 
															when 'Advertisement' then '11140'
															when 'BUSINESS TRAVEL' then '8055'
															when 'DONATION' then '11069'
															when 'EDUCATIONAL EXPENSES' then  '8057'
															when 'FAMILY MAINTAINANCE' then '8060'
															when 'FAMILY MAINTENANCE' then '8060'
															when 'FAMILY MAINTENANCE/SAVINGS' then '8060'
															when 'GIFT' then '11068'
															when 'INSURANCE PAYMENT' then '8062'
															when 'INVESTMENT IN REAL ESTATE' then '8066'
															when 'MEDICAL EXPENSES' then '8058'
															when 'Payment of House Construction Cost' then '8068'
															when 'Payment of import goods' then '11307'
															when 'PERSONAL TRAVELS  EXPENSES' then '8056'
															when 'PERSONAL TRAVELS AND TOURS' then '8056'
															when 'REPAYMENT OF LOANS' then '8063'
															when 'SALARY PAYMENT' then '8064'
															when 'TRADE REMITTANCE' then '11067'
															when 'Trading' then '11141'
															ELSE 11308
															end
			
			SELECT @TOTAL_COUNT = COUNT(0)
			FROM #TEMP_RECEIVER_DATA

			DELETE T
			FROM #TEMP_RECEIVER_DATA T
			INNER JOIN RECEIVERINFORMATION CM(NOLOCK) ON CM.tempRId = T.sno

			SELECT @AFTER_DELETE_COUNT = COUNT(0)
			FROM #TEMP_RECEIVER_DATA

			ALTER TABLE #TEMP_RECEIVER_DATA ADD membershipId VARCHAR(30), CUSTOMERID BIGINT

			UPDATE R SET R.CUSTOMERID = C.customerid, R.membershipId = C.membershipid
			FROM #TEMP_RECEIVER_DATA R(NOLOCK)
			INNER JOIN FastMoneyPro_Remit.DBO.customerMaster C(NOLOCK) ON C.obpid = R.sender_sno

			SELECT @FROM_DATE = MIN(CAST(Create_TS AS DATE)), @TO_DATE = MAX(CAST(Create_TS AS DATE))
			FROM #TEMP_RECEIVER_DATA

			--DELETE FROM FASTMONEYPRO_REMIT.DBO.RECEIVERINFORMATION
			--WHERE CREATEDDATE BETWEEN @FROM_DATE AND @TO_DATE + ' 23:59:59'
			--AND tempRId IS NULL

			INSERT INTO FastMoneyPro_Remit.DBO.RECEIVERINFORMATION
								(
								  membershipId ,customerId ,firstName ,middleName ,lastName1 ,country,[address] ,[state] ,zipCode ,city ,email ,
								  homePhone ,workPhone ,mobile ,relationship ,receiverType ,idType ,idNumber  ,paymentMode ,bankLocation ,payOutPartner ,
								  bankName ,receiverAccountNo ,remarks ,purposeOfRemit ,createdBy ,createdDate,otherRelationDesc,modifiedBy,modifiedDate,tempRId, OLD_CUSTOMERID
								)

			SELECT membershipId, ISNULL(CUSTOMERID, 0), RECEIVERNAME, RECEIVERMIDDLENAME, RECEIVERLASTNAME,RECEIVERCOUNTRY,RECEIVERADDRESS,Col2, Col3, RECEIVERCITY,RECEIVEREMAIL,
								Col4, RECEIVERFAX, RECEIVERMOBILE,relationship,CustomerbenificiarType,
								ReceiverIDDescription
								,ReceiverID,PAYMENTTYPE				
								,commercial_bank_id,payOutPartner,
								Api_partnet_bank_name, ACCOUNTNO, CustomerRemarks,purposeOfRemit,CreateBy,Create_TS,Col5,Col6,Col7,SNO, sender_sno
			FROM #TEMP_RECEIVER_DATA
			
			SET @MSG = 'Download successful Total: '+CAST(@TOTAL_COUNT AS VARCHAR)+' DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR)

			INSERT INTO CUSTOMER_DOWNLOAD_LOG(DOWNLOAD_COUNT, DUPLICATE_COUNT, MSG, DOWNLOAD_TYPE, CREATED_DATE, CREATED_BY)
			SELECT @TOTAL_COUNT, @TOTAL_COUNT - @AFTER_DELETE_COUNT, 'Download successful Total: '+CAST(@TOTAL_COUNT AS VARCHAR)+' 
						DUPLICATE: '+CAST((@TOTAL_COUNT - @AFTER_DELETE_COUNT) AS VARCHAR) + ' (Download Date ' + @DATE + ')'
					, 'Receiver', GETDATE(), @USER

			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
		IF @FLAG = 'DOWNLOAD-DETAIL'
		BEGIN
			SELECT TOP 15 DOWNLOAD_COUNT, DUPLICATE_COUNT, DOWNLOAD_TYPE, CREATED_DATE, CREATED_BY,
						MSG
			FROM CUSTOMER_DOWNLOAD_LOG (NOLOCK) 
			ORDER BY ROW_ID DESC
				
			SELECT COUNT(0) 
			FROM CUSTOMERMASTER (NOLOCK)
			WHERE MEMBERSHIPID IS NULL
		END
		IF @FLAG = 'SYNC-PAID-MITATSU'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_TRAN_SYNC_PAID_MITATSU') IS NOT NULL DROP TABLE #TEMP_TRAN_SYNC_PAID_MITATSU
		
			SELECT @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(tranno)[1]','VARCHAR(20)') AS 'tranno'
						,p.value('(cancel_date)[1]','VARCHAR(150)') AS 'cancel_date'
						,p.value('(paiddate)[1]','VARCHAR(150)') AS 'paiddate'
						,p.value('(paidBy)[1]','VARCHAR(150)') AS 'paidBy'
						,p.value('(transtatus)[1]','VARCHAR(150)') AS 'transtatus'
						,p.value('(status)[1]','VARCHAR(150)') AS 'status'
			INTO #TEMP_TRAN_SYNC_PAID_MITATSU
			FROM @XMLDATA.nodes('/ArrayOfTransactionSync/TransactionSync') AS TEMP_TRAN(p)

			SELECT @TOTAL_COUNT = COUNT(0) 
			FROM #TEMP_TRAN_SYNC_PAID_MITATSU

			DELETE FROM #TEMP_TRAN_SYNC_PAID_MITATSU WHERE transtatus = 'CANCEL' OR status = 'CANCEL'

			ALTER TABLE #TEMP_TRAN_SYNC_PAID_MITATSU ADD CONTROLNO VARCHAR(30), REFNO_ENC VARCHAR(30)

			UPDATE T SET T.CONTROLNO = DBO.DECRYPTDB(R.CONTROLNO), T.REFNO_ENC = R.CONTROLNO
			FROM #TEMP_TRAN_SYNC_PAID_MITATSU T
			INNER JOIN REMITTRAN R(NOLOCK) ON R.UPLOADLOGID = T.tranno

			UPDATE #TEMP_TRAN_SYNC_PAID_MITATSU SET paidDate = CASE WHEN paidDate = '0001-01-01' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01' THEN NULL ELSE cancel_date END

			UPDATE #TEMP_TRAN_SYNC_PAID_MITATSU SET paidDate = CASE WHEN paidDate = '0001-01-01T00:00:00' THEN NULL ELSE paidDate END,
				cancel_date = CASE WHEN cancel_date = '0001-01-01T00:00:00' THEN NULL ELSE cancel_date END

			DELETE FROM #TEMP_TRAN_SYNC_PAID_MITATSU WHERE paidDate IS NULL

			--DELETE T
			--FROM #TEMP_TRAN_SYNC_PAID_MITATSU T
			--INNER JOIN REMITTRAN R(NOLOCK) ON R.CONTROLNO = T.REFNO_ENC AND CAST(R.PAIDDATE AS DATE) = CAST(T.PAIDDATE AS DATE)

			DELETE T
			FROM #TEMP_TRAN_SYNC_PAID_MITATSU T
			INNER JOIN REMITTRAN R(NOLOCK) ON R.CONTROLNO = T.REFNO_ENC 
			WHERE CAST(R.PAIDDATE AS DATE) = CAST(T.PAIDDATE AS DATE)

			UPDATE R SET R.PAIDDATE = CAST(T.PAIDDATE AS DATETIME), R.PAIDDATELOCAL = CAST(T.PAIDDATE AS DATETIME)
			FROM #TEMP_TRAN_SYNC_PAID_MITATSU T
			INNER JOIN REMITTRAN R(NOLOCK) ON R.CONTROLNO = T.REFNO_ENC 

			UPDATE R SET R.TRAN_DATE = CAST(T.PAIDDATE AS DATETIME)
			FROM #TEMP_TRAN_SYNC_PAID_MITATSU T
			INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER R(NOLOCK) ON R.FIELD1 = T.CONTROLNO
			WHERE R.ACCT_TYPE_CODE = 'PAID'

			SELECT @AFTER_DELETE_COUNT = COUNT(0) 
			FROM #TEMP_TRAN_SYNC_PAID_MITATSU 
				
			SET @MSG = 'Total transactions downloaded: '+CAST(@TOTAL_COUNT AS VARCHAR) +' Total paiddate updated: '+CAST(@AFTER_DELETE_COUNT AS VARCHAR)
			
			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
		IF @FLAG = 'CUSTOMER-UPDATE'
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_CUSTOMER_DATA_UPDATE') IS NOT NULL DROP TABLE #TEMP_CUSTOMER_DATA_UPDATE
		
			SET @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(SenderName)[1]','VARCHAR(200)') AS 'SenderName'
						,p.value('(SenderMiddleName)[1]','VARCHAR(100)') AS 'SenderMiddleName'
						,p.value('(SenderLastName)[1]','VARCHAR(100)') AS 'SenderLastName'
						,p.value('(Country)[1]','VARCHAR(50)') AS 'Country'
						,p.value('(SenderZipCode)[1]','VARCHAR(50)') AS 'SenderZipCode'
						,p.value('(SenderCity)[1]','VARCHAR(50)') AS 'SenderCity'
						,p.value('(SenderState)[1]','VARCHAR(50)') AS 'SenderState'
						,p.value('(SenderEmail)[1]','VARCHAR(50)') AS 'SenderEmail'
						,p.value('(SenderMobile2)[1]','VARCHAR(30)') AS 'SenderMobile2'
						,p.value('(SenderMobile)[1]','VARCHAR(30)') AS 'SenderMobile'
						,p.value('(SenderNativeCountry)[1]','VARCHAR(50)') AS 'SenderNativeCountry'
						,p.value('(Date_of_birth)[1]','VARCHAR(50)') AS 'Date_of_birth'
						,p.value('(Sender_Occupation)[1]','VARCHAR(150)') AS 'Sender_Occupation'
						,p.value('(Gender)[1]','VARCHAR(30)') AS 'Gender'
						,p.value('(FullName)[1]','VARCHAR(250)') AS 'FullName'
						,p.value('(Create_by)[1]','VARCHAR(50)') AS 'Create_by'
						,p.value('(create_ts)[1]','VARCHAR(50)') AS 'create_ts'
						,p.value('(id_issue_DATE)[1]','VARCHAR(50)') AS 'id_issue_DATE'
						,p.value('(SENDERVISA)[1]','VARCHAR(100)') AS 'SENDERVISA'
						,p.value('(SenderFax)[1]','VARCHAR(100)') AS 'SenderFax'
						,p.value('(SenderPassport)[1]','VARCHAR(100)') AS 'SenderPassport'
						,p.value('(Is_ACT)[1]','VARCHAR(50)') AS 'Is_ACT'
						,p.value('(approve_by)[1]','VARCHAR(50)') AS 'approve_by'
						,p.value('(approve_ts)[1]','VARCHAR(50)') AS 'approve_ts'
						,p.value('(cust_type)[1]','VARCHAR(50)') AS 'cust_type'
						,p.value('(is_enable)[1]','VARCHAR(50)') AS 'is_enable'
						,p.value('(Force_Change_Pwd)[1]','VARCHAR(50)') AS 'Force_Change_Pwd'
						,p.value('(source_of_income)[1]','VARCHAR(150)') AS 'source_of_income'
						,p.value('(SenderAddress)[1]','VARCHAR(150)') AS 'SenderAddress'
						,p.value('(CustomerType)[1]','VARCHAR(50)') AS 'CustomerType'
						,p.value('(EmploymentType)[1]','VARCHAR(50)') AS 'EmploymentType'
						,p.value('(NameOfEmp)[1]','VARCHAR(150)') AS 'NameOfEmp'
						,p.value('(SSN_cardId)[1]','VARCHAR(50)') AS 'SSN_cardId'
						,p.value('(Is_Active)[1]','VARCHAR(50)') AS 'Is_Active'
						,p.value('(Customer_remarks)[1]','VARCHAR(250)') AS 'Customer_remarks'
						,p.value('(sendercompany)[1]','VARCHAR(250)') AS 'sendercompany'
						,p.value('(RegdNo)[1]','VARCHAR(50)') AS 'RegdNo'
						,p.value('(Org_Type)[1]','VARCHAR(50)') AS 'Org_Type'
						,p.value('(Date_OfInc)[1]','VARCHAR(50)') AS 'Date_OfInc'
						,p.value('(Nature_OD_Company)[1]','VARCHAR(150)') AS 'Nature_OD_Company'
						,p.value('(Position)[1]','VARCHAR(150)') AS 'Position'
						,p.value('(NameOfAuthorizedPerson)[1]','VARCHAR(100)') AS 'NameOfAuthorizedPerson'
						,p.value('(Income)[1]','VARCHAR(100)') AS 'Income'
						,p.value('(SNo)[1]','VARCHAR(50)') AS 'SNo'
						,p.value('(CustomerId)[1]','VARCHAR(50)') AS 'CustomerId'
			INTO #TEMP_CUSTOMER_DATA_UPDATE
			FROM @XMLDATA.nodes('/ArrayOfCustomerData/CustomerData') AS TEMP_TRAN(p)
			
			UPDATE #TEMP_CUSTOMER_DATA_UPDATE set SenderNativeCountry = 'South Korea' where SenderNativeCountry = 'KOREA, REPUBLIC OF'
			
			ALTER TABLE #TEMP_CUSTOMER_DATA_UPDATE ADD sender_occupationId INT

			update #TEMP_CUSTOMER_DATA_UPDATE
			SET sender_occupationId = CASE 
										WHEN sender_occupation IN ('Skil', 'Skilled Labor', 'BUSINESS MANAGER') THEN '8088'
											   WHEN sender_occupation IN  ('Business', 'BUSINESS OWNER') THEN '2004'
											   WHEN sender_occupation IN  ('DEPENDENT') THEN '11143'
											   WHEN sender_occupation IN  ('COMPANY EMPLOYEE') THEN '11143'
											   WHEN sender_occupation IN  ('UNEMPLOYED') THEN '11144'
											   WHEN sender_occupation IN  ('TRAINEE') THEN '2012'
											   WHEN sender_occupation IN  ('Others (please specific in remark)') THEN '8088'
											   WHEN sender_occupation IN  ('Part Time Job Holder') THEN '4701'
											   WHEN sender_occupation IN  ('HOUSE WIFE') THEN '8085'
											ELSE '2012' END

			
			ALTER TABLE #TEMP_CUSTOMER_DATA_UPDATE ADD senderfaxid INT 

			UPDATE #TEMP_CUSTOMER_DATA_UPDATE SET 
			senderfaxid = CASE senderfax 
							WHEN 'Drivers licence' THEN '11079'
							WHEN 'Passport' THEN '10997'
							WHEN 'National IC' THEN '8008'
							WHEN 'Driver License' THEN '11079'
							WHEN 'Tohon' THEN '11080'
							WHEN 'Residence Card' THEN '11168'
							WHEN 'Company Registration No' THEN '11172'
							WHEN 'Insurance Card' THEN '11078'
							WHEN 'Other Gov. Issued' THEN '11302'
							ELSE NULL END;

			ALTER TABLE #TEMP_CUSTOMER_DATA_UPDATE ADD source_of_incomeid INT

			UPDATE #TEMP_CUSTOMER_DATA_UPDATE SET 
			source_of_incomeid = CASE source_of_income 
								WHEN 'Salary' THEN '3901'
								WHEN 'Salary  Wages' THEN '3901'
								WHEN 'Others' THEN '11070'
								WHEN 'Loan (Borrow from others)' THEN '8079'
								WHEN 'Accumulated Salary' THEN '3901'
								WHEN 'Business Income' THEN '3902'
								WHEN 'Investment' THEN '11167'
								ELSE NULL END;

			ALTER TABLE #TEMP_CUSTOMER_DATA_UPDATE ADD CUSTOMERTYPEid INT

			UPDATE #TEMP_CUSTOMER_DATA_UPDATE SET 
			CUSTOMERTYPEid = CASE CUSTOMERTYPE 
								WHEN 'Individual' THEN '4700'
								WHEN 'Organizational' THEN '4701'
								WHEN 'Business Visa' THEN '4700'
								WHEN 'student' THEN '4700'
								WHEN 'Company Employee' THEN '4700'
								WHEN 'Designated Activities' THEN '4700'
								WHEN 'Resident' THEN '4700'
								WHEN 'Dependent' THEN '4700'
								WHEN 'Dependent of Japanese' THEN '4700'
								WHEN 'Other' THEN '4700'
								WHEN 'Permanent Resident, Non-Resident' THEN '4700'									 
								WHEN 'Non-Resident' THEN '4700'
								WHEN 'Sole Proprietor' THEN '4700'
								WHEN 'Dependent, Non-Resident' THEN '4700'
								WHEN 'Permanent Resident' THEN '4700'
								WHEN 'Training' THEN '4700'
								WHEN 'Japanese Citizen' THEN '4700'
								WHEN 'Designated Activities, Non-Resident' THEN '4700'
								WHEN 'Other, Non-Resident' THEN '4700'
								WHEN 'Company Employee, Non-Resident' THEN '4700'
								WHEN 'Skilled Labour' THEN '4700'
								WHEN 'student, Non-Resident' THEN '4700'
								WHEN 'Long Term resident' THEN '4700'
								WHEN 'Spouse or Child of  Japanese National' THEN '4700'
								WHEN 'Training, Non-Resident' THEN '4700'
								ELSE NULL END;

			ALTER TABLE #TEMP_CUSTOMER_DATA_UPDATE ADD employmentTypeid INT

			UPDATE #TEMP_CUSTOMER_DATA_UPDATE SET 
			employmentTypeid = CASE employmentType 
								WHEN 'Emplyeed' THEN '11007'
								WHEN 'Self-Employee' THEN '11008'
								WHEN 'Unemployee' THEN '11009'
								ELSE null END;
			
			SELECT @TOTAL_COUNT = COUNT(0)
			FROM #TEMP_CUSTOMER_DATA_UPDATE

			DELETE T
			FROM #TEMP_CUSTOMER_DATA_UPDATE T
			INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.postalcode = T.CustomerId

			SELECT @AFTER_DELETE_COUNT = COUNT(0)
			FROM #TEMP_CUSTOMER_DATA_UPDATE

			ALTER TABLE #TEMP_CUSTOMER_DATA_UPDATE ADD CITY VARCHAR(100), STREET VARCHAR(200), STATE_ID VARCHAR(20)

			UPDATE TMP SET TMP.CITY = T.CITY_NAME, TMP.STATE_ID = T.STATE_ID, TMP.STREET = T.STREET_NAME
			FROM #TEMP_CUSTOMER_DATA_UPDATE TMP(NOLOCK)
			INNER JOIN TBL_JAPAN_ADDRESS_DETAIL T(NOLOCK) ON T.ZIP_CODE = CAST(TMP.SenderZipCode AS INT)
			
			
			INSERT  INTO FASTMONEYPRO_REMIT.DBO.customerMaster_temp(
				middleName
				,firstName,lastName1,country,zipCode,city,[state],email,homePhone,mobile,nativeCountry,dob,
				occupation,gender,
				fullName,
				createdBy,createdDate,idIssueDate,idExpiryDate,idType,idNumber,onlineUser,customerPassword,
				APPROVEDBY, APPROVEDDATE,customerType,isActive,isForcedPwdChange,sourceOfFund,street,
				visaStatus,employeeBusinessType,nameOfEmployeer,SSNNO,remittanceAllowed,remarks,companyname,
				registerationNo,organizationType,
				dateofIncorporation,natureOfCompany,position,nameOfAuthorizedPerson,monthlyIncome,obpid,postalCode,ADDITIONALADDRESS
			)

			SELECT SENDERMIDDLENAME,SENDERNAME,SENDERLASTNAME,CAST(COUNTRY AS INT),CAST(SenderZipCode AS INT),CITY,STATE_ID,senderemail,SenderMobile2,CAST(sendermobile AS BIGINT),SenderNativeCountryid,date_of_birth
				,sender_occupationid, genderid
				, FULLNAME
				,create_by, create_ts, id_issue_date, sendervisa,senderFaxid,senderPassport,'Y', dbo.fnaencryptstring('jme@12345')
				,approve_by,approve_ts,CUST_TYPE,is_enable,FORCE_CHANGE_PWD,source_of_incomeid,STREET
				,null,employmentTypeid,null NAME_OF_EMP,SSN_cardId, IS_ACTIVE,customer_remarks,sendercompany
				,RegdNo, ORG_TYPE
				,Date_OfInc,NATURE_OD_COMPANY,POSITION,nameOfAuthorizedPerson
				,INCOME 
				,CAST(sno AS BIGINT),CAST(CustomerId AS INT), SenderAddress
			from #TEMP_CUSTOMER_DATA
			
			EXEC PROC_ERRORHANDLER 0, @MSG, null
		END
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH

--EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS @flag = 'SHOW',@user = null
--CREATE TABLE CUSTOMER_DOWNLOAD_LOG
--(
--	ROW_ID INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
--	,DOWNLOAD_COUNT INT
--	,DUPLICATE_COUNT INT
--	,MSG VARCHAR(250)
--	,DOWNLOAD_TYPE VARCHAR(20)
--	,CREATED_DATE DATETIME
--	,CREATED_BY VARCHAR(50)
--);


