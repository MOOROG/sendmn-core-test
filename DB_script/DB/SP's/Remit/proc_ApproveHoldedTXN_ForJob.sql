USE FastMoneyPro_Remit
GO

ALTER PROC [dbo].[proc_ApproveHoldedTXN_ForJob] (	 
	 @flag				VARCHAR(50)	
	,@user				VARCHAR(130)
	,@userType			VARCHAR(10)		= NULL
	,@branch			VARCHAR(50)		= NULL	
	,@id				VARCHAR(40)		= NULL
	,@country			VARCHAR(50)		= NULL
	,@sender			VARCHAR(50)		= NULL
	,@receiver			VARCHAR(50)		= NULL
	,@amt				MONEY			= NULL
	,@bank				VARCHAR(50)		= NULL
	,@voucherNo			VARCHAR(50)		= NULL	
	,@branchId			INT				= NULL
	,@pin				VARCHAR(50)		= NULL
	,@errorCode			VARCHAR(10)		= NULL	
	,@msg				VARCHAR(500)	= NULL
	,@idList			XML				= NULL
	,@txnDate			VARCHAR(20)		= NULL
	,@txncreatedBy		VARCHAR(50)		= NULL
	,@xml				VARCHAR(MAX)	= NULL
	,@remarks			VARCHAR(MAX)	= NULL
	,@settlingAgentId	INT				= NULL
    ,@ControlNo			VARCHAR(50)		= NULL
	,@txnType			VARCHAR(1)		= NULL
	,@sendCountry		VARCHAR(50)		= NULL
	,@sendAgent			VARCHAR(50)		= NULL
	,@sendBranch		VARCHAR(50)		= NULL
	,@approvedFrom		VARCHAR(10)		= NULL
	,@tpControlNo1		VARCHAR(30)		= NULL
	,@tpControlNo2		VARCHAR(30)		= NULL
) 

AS
BEGIN TRY

	DECLARE 
		 @table             VARCHAR(MAX)
		,@sql		        VARCHAR(MAX)
		,@sqlSelfTxn		VARCHAR(MAX)
		,@sRouteId VARCHAR(5)
		,@collMode VARCHAR(100)

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE 
		 @pinEncrypted VARCHAR(50) = dbo.FNAEncryptString(@pin)
		,@cAmt MONEY
		,@userId INT		
		,@createdBy	VARCHAR(50)
		,@tranStatus VARCHAR(50)
		,@message	VARCHAR(200)
		,@sBranch	BIGINT			
		,@invicePrintMethod VARCHAR(50)
		,@parentId	BIGINT
		,@tablesql AS VARCHAR(MAX)
		,@branchList VARCHAR(MAX) 
		,@denyAmt	MONEY
		,@C2CAgentID VARCHAR(30) = '1045'
		,@REAgentID VARCHAR(30) = '1100'

	IF @pin IS NULL
	BEGIN
		SELECT @pin = dbo.FNADecryptString(controlNo), @pinEncrypted = controlNo FROM remitTranTemp WITH(NOLOCK) WHERE id = @id		
	END
	ELSE
	BEGIN
		SET @pinEncrypted  = dbo.FNAEncryptString(@pin)
	END
	
	DECLARE @PinList TABLE(id VARCHAR(50), pin VARCHAR(50),hasProcess CHAR(1),isOFAC CHAR(1),errorMsg VARCHAR(MAX),tranId INT,createdBy	VARCHAR(50))
	DECLARE @TempcompTable TABLE(errorCode INT,msg VARCHAR(MAX),id VARCHAR(50))
	DECLARE @isSelfApprove VARCHAR(1)
	
	IF @flag = 'provider'
	BEGIN
		DECLARE @pAgent INT
		SELECT
			@pAgent = pAgent
		FROM remitTranTemp WITH(NOLOCK)
		WHERE id = @id
		
		IF @pAgent IS NULL
		BEGIN
			SELECT
				@pAgent = pAgent
			FROM vwremitTran WITH(NOLOCK)
			WHERE id = @id
		END

		SELECT @pAgent pAgent
		RETURN
	END

	IF @flag = 'reject'
	BEGIN
		
		SELECT @tranStatus = transtatus,
			   @denyAmt = ISNULL(cAmt,0) - ISNULL(sAgentComm,0)	- ISNULL(agentFxGain,0),
			   @sRouteId = sRouteId,
			   @pinEncrypted = controlNo,
			   @ControlNo = dbo.fnaDecryptstring(controlNo),
			   @txncreatedBy = createdBy,
			   @COLLMODE = RT.COLLMODE
		FROM remitTranTemp RT WITH(NOLOCK)
		WHERE id=@id
		
		--IF LEN(@pinEncrypted)<7
		--BEGIN
		--	select TOP 1 @ControlNo = controlNo from Application_Log.dbo.vwtpapilogs(nolock) where requestedby=@txncreatedBy AND ERRORCODE='999' order by rowid desc
		--END
		--IF LEN(@ControlNo) < 7
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Sorry,Cannot Reject Transaction', @id
		--	RETURN
		--END

		BEGIN TRANSACTION
		
		INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,
				createdBy,createdDate,tranStatus,approvedBy,approvedDate,scRefund,isScRefund)
		SELECT id,controlNo,@remarks,'Approved',@user,GETDATE(),tranStatus,@user,GETDATE(),
		cAmt,'Y' FROM remitTranTemp WITH(NOLOCK) WHERE id=@id
		
		UPDATE remitTranTemp SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= dbo.FNAGetDateInNepalTZ()
				 ,cancelRequestBy			= @user
				 ,cancelRequestDate			= GETDATE()
				 ,cancelRequestDateLocal	= dbo.FNADateFormatTZ(GETDATE(), @user)
				 ,trnStatusBeforeCnlReq		= @tranStatus
				 ,controlNo					= dbo.fnaEncryptstring(@ControlNo)
		WHERE id = @id

		IF @COLLMODE = 'Bank Deposit'
		BEGIN
			EXEC proc_UpdateCustomerBalance @controlNo=@pinEncrypted
		END

		INSERT INTO cancelTranHistory(
				tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate,cancelApprovedDateLocal
				,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,trnStatusBeforeCnlReq
			)
			SELECT 
				id,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@remarks,refund,cancelCharge,GETDATE(),dbo.FNADateFormatTZ(GETDATE(), @user)
				,@user,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,trnStatusBeforeCnlReq
			 FROM remitTranTemp WHERE id =  @id
			
			INSERT INTO cancelTranSendersHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer 
			FROM transenderstemp WITH(NOLOCK) WHERE tranId = @id
			
			INSERT INTO cancelTranReceiversHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			state,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			state,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress
			FROM tranReceiversTemp WITH(NOLOCK)	WHERE tranId = @id

				--update balance
			DECLARE @referralCode VARCHAR(15),@sType CHAR(1),@isOnbehalf CHAR(1),@sAgent INT,@senderUserId INT
			SELECT @referralCode = PROMOTIONCODE
					,@sAgent = sAgent 
					,@cAmt = cAmt
					,@isOnbehalf = (CASE WHEN ISNULL(ISONBEHALF,0) = '1' THEN 'Y' ELSE 'N' END)
					,@senderUserId = AU.userId
			FROM dbo.remitTranTemp  RT (NOLOCK)
			INNER JOIN applicationUsers AU (NOLOCK) ON AU.userName = RT.createdBy
			WHERE controlNo = dbo.fnaEncryptstring(@ControlNo)
		
			--select @sAgent,@userId,@referralCode,@cAmt,@isOnbehalf,@ControlNo
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='CANCEL',@S_AGENT = @sAgent,@S_USER = @senderUserId,@REFERRAL_CODE = @referralCode,@C_AMT = @cAmt,@ONBEHALF =@isOnbehalf
				
			DELETE FROM remitTranTemp WHERE id = @id
			DELETE FROM tranSendersTemp WHERE tranId = @id
			DELETE FROM tranReceiversTemp WHERE tranId = @id
			SELECT @message = 'Transaction cancel has been done successfully.'
			
			EXEC proc_transactionLogs @flag='i', @user=@user, @tranId=@id, @message=@message,@msgType='Cancel'	
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Transaction Rejected Successfully', @id
		RETURN
	END
	
	IF @flag = 'approve'
	BEGIN
		declare @pBank int,@paymentMethod varchar(50),@tranType char(1), @externalBankCode INT, @createdDate DATETIME, 
		@senderName VARCHAR(100),@sBranchName VARCHAR(150), @pAgentComm MONEY
		DECLARE @agentFxGain MONEY

		IF @createdBy = @user
		BEGIN
			EXEC proc_errorHandler 1, 'Same user cannot approve the Transaction', @id
			RETURN
		END		
		DECLARE @customerId BIGINT, @tAmt MONEY, @pAmt MONEY, @introducer VARCHAR(50), @payoutPartner INT, @serviceCharge MONEY,@pCurrCostRate FLOAT,@pCurrHoMargin	FLOAT
		,@isFirstTran CHAR(1)

		
		
		SELECT
			 @cAmt = cAmt
			,@customerId = cm.customerId 
			,@userId = A.userId
			,@tAmt = r.tAmt
			,@pAmt = r.pAmt
			,@createdBy = r.createdBy
			,@controlNo = dbo.FNADecryptString(controlNo)
			,@sBranch	= sBranch
			,@sBranchName = sBranchName
			,@pinEncrypted = controlNo
			,@pBank		= pBank
			,@introducer = promotionCode
			,@sAgent	= sAgent
			,@paymentMethod = paymentMethod
			,@tranType	= tranType
			,@sRouteId = sRouteId
			,@collMode = COLLMODE
			,@externalBankCode = externalBankCode
			,@createdDate = r.createdDate
			,@senderName = r.senderName
			,@tranStatus = R.tranStatus
			,@payoutPartner = R.pSuperAgent
			,@serviceCharge = R.serviceCharge
			,@pCurrCostRate = R.pCurrCostRate
			,@pCurrHoMargin = R.pCurrHoMargin
			,@agentFxGain = R.agentFxGain
			,@isFirstTran = ISNULL(T.isFirstTran, 'N')
			,@isOnbehalf = (CASE WHEN ISONBEHALF = '1' THEN 'Y' ELSE 'N' END)
			,@pAgentComm = r.pAgentComm
		FROM remitTranTemp r WITH(NOLOCK)
		INNER JOIN TRANSENDERSTemp T(NOLOCK) ON T.TRANID = R.ID
		LEFT JOIN customerMaster cm(NOLOCK) ON T.customerId = cm.customerId
		LEFT JOIN applicationUsers A(NOLOCK) ON A.USERNAME = R.CREATEDBY
		WHERE r.id = @id

		IF NOT EXISTS(SELECT TOP 1 1 FROM TRANSENDERS TS(NOLOCK) WHERE CUSTOMERID = @customerId)
		BEGIN
			SET @isFirstTran = 'Y'
			UPDATE TRANSENDERSTemp SET isFirstTran = 'Y' WHERE TRANID = @id
		END

		DECLARE @kycStatus INT

		--SELECT TOP 1 @kycStatus = kycStatus
		--FROM TBL_CUSTOMER_KYC (NOLOCK) 
		--WHERE CUSTOMERID = @customerId
		--AND ISDELETED = 0--AND kycStatus=11044
		--ORDER BY rowId DESC

		SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId=@sBranch
		SELECT @invicePrintMethod = invoicePrintMethod FROM agentMaster A WITH(NOLOCK) 
		INNER JOIN agentBusinessFunction B WITH(NOLOCK) ON A.agentId=B.agentId
		WHERE A.agentId=@parentId
		
		BEGIN TRANSACTION
			UPDATE remitTranTemp SET
					tranStatus				=  tranStatus
					--tranStatus				=  CASE tranStatus
					--								WHEN 'Hold' THEN 'Payment'
					--								WHEN 'Compliance Hold' THEN 'Compliance'
					--								WHEN 'OFAC Hold' THEN 'OFAC'
					--								WHEN 'OFAC/Compliance Hold' THEN 'OFAC/Compliance'
					--								WHEN 'Cash Limit Hold' THEN 'Cash Limit'
					--								WHEN 'Cash Limit/Compliance Hold' THEN 'Cash Limit/Compliance'
					--								WHEN 'Cash Limit/OFAC Hold' THEN 'Cash Limit/OFAC'
					--								WHEN 'Cash Limit/OFAC/Compliance Hold' THEN 'Cash Limit/OFAC/Compliance'
					--								ELSE 'Payment'
					--							END
					,approvedBy				= @user
					,approvedDate			= ISNULL(approvedDate, CREATEDDATE)
					,approvedDateLocal		= GETDATE()			     
			WHERE id = @id
			
			--send email to customers
			--INSERT INTO tempTransactionMailQueue(controlNo, createdDate, [status])--tranType is used to know either mail is sent or not, we put 'N' for not sent
			--SELECT rt.controlNo, GETDATE(), 'N' FROM remitTranTemp rt (NOLOCK) where rt.id = @id
		
			--EXEC proc_customerTxnHistory @controlNo = @pinEncrypted

			----## pish temp into main table
			EXEC proc_remitTranTempToMain @id

			DECLARE @TRANID BIGINT

			SELECT @TRANID = ID 
			FROM REMITTRAN (NOLOCK) WHERE controlNo = @pinEncrypted

			SET @remarks = 'Remittance :'+@controlNo+' by:'+@senderName +' from '+@sBranchName+'-branch on dtd: '+cast(@createdDate as VARCHAR)
			SET @txnDate = @createdDate

			EXEC PROC_CALCULATE_REFERRAL_COMM @COMMISSION_AMT = @serviceCharge, @T_AMT = @tAmt, @FX = @agentFxGain, @IS_NEW_CUSTOMER = @isFirstTran,
						@REFERRAL_CODE = @introducer, @PAYOUT_PARTNER = @payoutPartner, @CUSTOMER_ID = @customerId, @TRAN_ID = @TRANID, 
						@S_AGENT = @sAgent, @AMOUNT = @cAmt, @USER = @user, @TRAN_DATE = @txnDate, @COLL_MODE = @collMode, @P_AGENT_COMM_AMT = @pAgentComm


			------INSERT INTO TRANSACTION TABLE(MAP DEPOSIT TXN WITH CUSTOMER)
			----INSERT INTO CUSTOMER_TRANSACTIONS (customerId, tranDate, particulars, deposit, withdraw, refereceId, head, createdBy, createdDate, bankId)
			----SELECT	@customerId, @txnDate, @remarks, 0, @cAmt, @TRANID, 'Send Txn: '+@collMode, @createdBy, @createdDate, @externalBankCode
			
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='SEND',@S_AGENT = @sAgent,@S_USER = @userId,@REFERRAL_CODE = @introducer,@C_AMT = @cAmt

			IF @collMode = 'Cash Collect' AND (EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND REFERRAL_TYPE_CODE = 'RB') OR ISNULL(@introducer, '') = '')
			BEGIN
				IF EXISTS(SELECT 1 FROM AGENTMASTER (NOLOCK) WHERE AGENTID = @sAgent AND ISNULL(ISINTL, 0) = 1)
				BEGIN
					SELECT @userId = USERID
					FROM APPLICATIONUSERS AU(NOLOCK) 
					WHERE AGENTID = @sAgent
				END
				
				IF EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND REFERRAL_TYPE_CODE = 'RB') AND ISNULL(@introducer, '') <> ''
				BEGIN
					IF EXISTS(SELECT 1 FROM APPLICATIONUSERS (NOLOCK) WHERE USERID = @userId AND AGENTID = @sAgent)
					BEGIN
						--INSERT INTO CASH AND VAULT TABLE FOR BRANCH CASH HOLD LIMIT CHECK
						EXEC PROC_PUSH_CASH_IN_OUT @flag='IN', @user=@user,@amount=@cAmt,
													@tranDate=@txnDate,@head='Txn Send',
													@remarks=@remarks,@branchId=@sAgent,
													@isAutoApprove=1,@userId=@userId,@referenceId=@TRANID
					END
					ELSE
					BEGIN
						--INSERT INTO CASH AND VAULT TABLE FOR BRANCH CASH HOLD LIMIT CHECK
						EXEC PROC_PUSH_CASH_IN_OUT @flag='IN', @user=@user,@amount=@cAmt,
													@tranDate=@txnDate,@head='Txn Send',
													@remarks=@remarks,@branchId=@sAgent,
													@isAutoApprove=1,@userId=0,@referenceId=@TRANID
					END
				END
				ELSE 
				BEGIN
					--INSERT INTO CASH AND VAULT TABLE FOR BRANCH CASH HOLD LIMIT CHECK
					EXEC PROC_PUSH_CASH_IN_OUT @flag='IN', @user=@user,@amount=@cAmt,
												@tranDate=@txnDate,@head='Txn Send',
												@remarks=@remarks,@branchId=@sAgent,
												@isAutoApprove=1,@userId=@userId,@referenceId=@TRANID
				END
			END

			--IF ISNULL(@kycStatus, 0) <> 11044
			--BEGIN
			--	UPDATE REMITTRAN SET tranStatus = CASE tranStatus WHEN 'Payment' THEN 'Hold' ELSE tranStatus END
			--	WHERE CONTROLNO = @pinEncrypted
			
			--	INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			--	SELECT @TRANID,'Transaction Auto Hold By System: Customer KYC Status not matched(i.e. KYC Completed)','system',GETDATE(),'TXN HOLD: CUSTOMER KYC NOT APPROVED'
			--END
			--IF @collMode = 'Bank Deposit'
			--BEGIN
			--	SELECT @DENYAMT = DBO.FNAGetCustomerAvailableBalance(@customerId)
			
			--	IF @DENYAMT < 0 
			--		UPDATE REMITTRAN SET tranStatus = CASE tranStatus WHEN 'Payment' THEN 'Hold' ELSE tranStatus END
			--		WHERE CONTROLNO = @pinEncrypted

			--	IF @DENYAMT < 0 
			--		INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			--		SELECT @TRANID,'Transaction Auto Hold By System: Insufficient Balance seen in system for this customer','system',GETDATE(),'TXN HOLD: Invalid balance'
			--END
			--IF @tranStatus = 'Cash Limit Hold'
			--BEGIN
			--	INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			--	SELECT @TRANID,'Transaction Auto Hold By System: User/Branch cash hold limit exceeded','system',GETDATE(),'TXN HOLD: Cash hold limit'
			--END

			INSERT INTO PinQueueList(ICN)
			SELECT @pinEncrypted
		
			--IF @approvedFrom ='tpApi'
			--BEGIN
			--	IF ISNULL(@tpControlNo1, '') <> ''
			--	BEGIN
			--		SET @controlNo = @tpControlNo1
			--		UPDATE dbo.remitTran SET payStatus ='POST'
			--								, controlNo = DBO.FNAENCRYPTSTRING(@tpControlNo1)
			--								, CONTROLNO2 = @pinEncrypted
			--								, CONTNO = DBO.FNAENCRYPTSTRING(@tpControlNo2)
			--								, postedBy = @user
			--								, postedDate = GETDATE()
			--								, postedDateLocal = GETDATE()
			--		WHERE id=@TRANID
			--	END
			--	ELSE
			--	BEGIN
			--		UPDATE dbo.remitTran SET payStatus ='POST', postedBy = @user, postedDate = GETDATE(), postedDateLocal = GETDATE()
			--		WHERE id=@TRANID
			--	END
			--END
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			
		IF @invicePrintMethod = 'aa'
			EXEC proc_errorHandler 11, 'Transaction Approved Successfully', @controlNo	
		ELSE
			EXEC proc_errorHandler 0, 'Transaction Approved Successfully', @controlNo	
		
		--## generate voucher entry 
		--EXEC FastMoneyPro_Account.dbo.proc_transactionVoucherEntry @controlNo= @controlNo	
		RETURN
	END

	IF @flag ='verifyTxnSendFromTabPage'
	BEGIN
		IF EXISTS  (SELECT 1 FROM dbo.remitTranTemp WHERE id=@id)
		BEGIN
			UPDATE dbo.remitTranTemp SET sRouteId='0' WHERE id=@id
			EXEC proc_errorHandler 0, 'Transaction Verify Successfully', @id
			RETURN;
		END
		ELSE
		BEGIN
		    EXEC proc_errorHandler 1, 'Transaction Not Found', @id
			RETURN;
		END
	END

	IF @flag = 'approve-all'
	BEGIN
		EXEC proc_ApproveHoldedTXN_Sub @user = @user, @idList = @idList
		RETURN
	END

	DECLARE @cdTable VARCHAR(MAX) = ''
	
	SET @cdTable = '
	LEFT JOIN (
					SELECT
						DISTINCT
						 tranId
						,cb.bankName
						,cd.countryBankId
					FROM collectionDetails cd WITH(NOLOCK)
					LEFT JOIN countryBanks cb WITH(NOLOCK) ON cd.countryBankId = cb.countryBankId
					INNER JOIN remitTranTemp trn WITH(NOLOCK) ON cd.tranId = trn.id
						AND (trn.tranStatus = ''Hold'' OR trn.tranStatus = ''Compliance Hold'' OR trn.tranStatus = ''OFAC Hold'' ) 
						AND trn.payStatus = ''Unpaid'' 
						AND trn.approvedBy IS NULL							
				) cd ON cd.tranId = trn.id '
	
	IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[#collModeList]') AND type = 'D')
	BEGIN
		DROP TABLE #collModeList
	END

	CREATE TABLE #collModeList(tranId INT, hasProcess CHAR(1), proMode varchar(50))
	DECLARE @tranId1 INT
		
	IF @flag = 's-admin'
	BEGIN
		SET @table = '
						SELECT DISTINCT
							 trn.id
							 ,controlNo = dbo.fnadecryptstring(controlNo)
							,branch = am.agentName							
							,country = trn.pCountry
							,senderId = sen.customerId
							,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')						
							,receiverId = rec.customerId
							,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
							,amt = CAST(trn.cAmt AS DECIMAL(18, 2))
							,trn.paymentMethod 
							,voucherNo = trn.voucherNo
							,txnDate = CAST(trn.createdDate AS DATE)
							,txncreatedBy = trn.createdBy
						FROM remitTranTemp trn WITH(NOLOCK) ' + @cdTable + '
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId														
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'', ''Cash Limit Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL AND ISNULL(sRouteId,''0'') =''0''
							  AND trn.tranType=''I''
					'
			
			IF @id IS NOT NULL			
				SET @table = @table + ' AND trn.id = ''' + @id + '''' 
				
			IF @branch IS NOT NULL
				SET @table = @table + ' AND am.agentId = ''' + @branch + '''' 
			
			IF @country IS NOT NULL
				SET @table = @table + ' AND trn.pCountry LIKE ''' + @country + '%''' 
			
			IF @sendCountry IS NOT NULL
				SET @table = @table + ' AND trn.sCountry LIKE ''' + @sendCountry + '%''' 

			IF @amt IS NOT NULL
				SET @table = @table + ' AND trn.pAmt = ' + CAST(@amt AS VARCHAR(20))+ '' 	
			
			IF @voucherNo IS NOT NULL
				SET @table = @table + ' AND trn.voucherNo = ''' + @voucherNo + ''''
				
			IF @txncreatedBy IS NOT NULL
				SET @table = @table + '  AND trn.createdBy = '''+@txncreatedBy+''''
				
			IF @txnDate IS NOT NULL
				SET @table = @table + ' AND CAST(trn.createdDate AS DATE)='''+@txnDate +''''
			
			IF @ControlNo IS NOT NULL
				SET @table = @table + ' AND trn.controlNo = dbo.fnaEncryptString('''+@ControlNo+''')'
						
			IF @sendAgent IS NOT NULL
				SET @table = @table + ' AND trn.sAgent  = '''+@sendAgent+''''
				
			IF @sendBranch IS NOT NULL
				SET @table = @table + ' AND trn.sBranch = '''+@sendBranch+''''
			
			
			SET @sql = '
				SELECT 
					* 
				FROM (
					' + @table + '
				) x
				WHERE 1 = 1 '
				
			IF @sender IS NOT NULL
				SET @sql = @sql + ' AND sender LIKE ''' + @sender + '%'''
			IF @receiver IS NOT NULL
				SET @sql = @sql + ' AND receiver LIKE ''' + @receiver + '%'''					

			PRINT @sql
			EXEC (@sql)		
		RETURN	
	END

	IF @flag = 's-admin-online'
	BEGIN
		SET @table = '
						SELECT DISTINCT
							 trn.id
							,branch = am.agentName							
							,country = trn.pCountry
							,senderId = sen.customerId
							,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')						
							,receiverId = rec.customerId
							,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
							,amt = CAST(trn.cAmt AS DECIMAL(18, 2))
							
							,txnDate = CAST(trn.createdDate AS DATE)
							,txncreatedBy = trn.createdBy
							,CASE WHEN trn.pAgent=1100 OR trn.pAgent = 1043 THEN 1 ELSE 0 END isThirdPartyTran
						FROM remitTranTemp trn WITH(NOLOCK) ' + @cdTable + '
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId														
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL  AND ISNULL(trn.isOnlineTxn,''N'') =''Y'' 
							  AND trn.tranType=''O''
					'
			
			IF @id IS NOT NULL			
				SET @table = @table + ' AND trn.id = ''' + @id + '''' 
				
			IF @branch IS NOT NULL
				SET @table = @table + ' AND am.agentId = ''' + @branch + '''' 
			
			IF @country IS NOT NULL
				SET @table = @table + ' AND trn.pCountry LIKE ''' + @country + '%''' 
			
			IF @sendCountry IS NOT NULL
				SET @table = @table + ' AND trn.sCountry LIKE ''' + @sendCountry + '%''' 

			IF @amt IS NOT NULL
				SET @table = @table + ' AND trn.pAmt = ' + CAST(@amt AS VARCHAR(20))+ '' 	
			
			IF @voucherNo IS NOT NULL
				SET @table = @table + ' AND trn.voucherNo = ''' + @voucherNo + ''''
				
			IF @txncreatedBy IS NOT NULL
				SET @table = @table + '  AND trn.createdBy = '''+@txncreatedBy+''''
				
			IF @txnDate IS NOT NULL
				SET @table = @table + ' AND CAST(trn.createdDate AS DATE)='''+@txnDate +''''
			
			IF @ControlNo IS NOT NULL
				SET @table = @table + ' AND trn.controlNo = dbo.fnaEncryptString('''+@ControlNo+''')'
						
			IF @sendAgent IS NOT NULL
				SET @table = @table + ' AND trn.sAgent  = '''+@sendAgent+''''
				
			IF @sendBranch IS NOT NULL
				SET @table = @table + ' AND trn.sBranch = '''+@sendBranch+''''
			
			SET @sql = '
				SELECT 
					* , STUFF((SELECT '''' + US.voucherNo +'' - ''+ CONVERT(VARCHAR(11),US.voucherDate,6) +'' - ''+ CAST(US.voucherAmt AS VARCHAR)+'' || ''
          FROM bankCollectionVoucherDetail US
          WHERE US.tempTranId = x.id
          FOR XML PATH('''')), 1, 1, '''') [voucherDetail]
				FROM (
					' + @table + '
				) x
				WHERE 1 = 1 '
				
			IF @sender IS NOT NULL
				SET @sql = @sql + ' AND sender LIKE ''' + @sender + '%'''
			IF @receiver IS NOT NULL
				SET @sql = @sql + ' AND receiver LIKE ''' + @receiver + '%'''					

			PRINT @sql
			EXEC (@sql)		
		RETURN	
	END
	
	IF @flag = 's-agent'
	BEGIN		
		SELECT 
			@isSelfApprove = ISNULL(b.isSelfTxnApprove,'N') 
		FROM agentmaster a WITH(NOLOCK)
		LEFT JOIN agentBusinessFunction b WITH(NOLOCK) ON a.parentId=b.agentId
		WHERE a.agentId= @branchId

		SET @branchList = '
			INNER JOIN ( 
				SELECT ' + CAST(@branchId AS VARCHAR) + ' agentId '
				
		IF @userType = 'RH'
		BEGIN
			SET @branchList = @branchList + '
							UNION ALL 	
							SELECT
								 am.agentId 			
							FROM agentMaster am WITH(NOLOCK)
							INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
							WHERE rba.agentId = ' + CAST(@branchId AS VARCHAR) + '
							AND ISNULL(rba.isDeleted, ''N'') = ''N''
							AND ISNULL(rba.isActive, ''N'') = ''Y''
							AND memberAgentId <> ' + CAST(@branchId AS VARCHAR) + ''
		END
		IF @userType = 'AH'
		BEGIN
			SET @branchList = @branchList + '
							UNION ALL 	
							select agentId from agentMaster with(nolock) where parentId = 
							(select parentId from agentmaster with(nolock) where agentId=' + CAST(@branchId AS VARCHAR) + ')
							and agentId <> ' + CAST(@branchId AS VARCHAR) + ''
		END

		SET @branchList = @branchList + '			
			) bl ON trn.sBranch = bl.agentId			
			'

		SET @table = '
						SELECT DISTINCT
							 trn.id
							,branch = am.agentName							
							,country = trn.pCountry
							,senderId = sen.customerId
							,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')						
							,receiverId = rec.customerId
							,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
							,amt = CAST(trn.cAmt AS DECIMAL(18, 3))
							,voucherNo = trn.voucherNo
							,trn.createdBy
							,collMode = ''Cash''
							,txnDate = CAST(trn.createdDate AS DATE)
							,txncreatedBy = trn.createdBy		
							,CASE WHEN trn.pAgent = 1100 OR trn.pAgent = 1043 THEN 1 ELSE 0 END isThirdPartyTran					
						FROM remitTranTemp trn WITH(NOLOCK) 
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						' + @branchList + '	
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL 
					'
			
			IF @txnType IS NOT NULL			
				SET @table = @table + ' AND trn.tranType = ''' + @txnType + '''' 
			else
				SET @table = @table + ' AND trn.tranType=''I''' 

			IF @id IS NOT NULL			
				SET @table = @table + ' AND trn.id = ''' + @id + '''' 
				
			IF @branch IS NOT NULL
				SET @table = @table + ' AND am.agentId = ''' + @branch + '''' 
			
			IF @country IS NOT NULL
				SET @table = @table + ' AND trn.pCountry LIKE ''' + @country + '%''' 
			
			IF @amt IS NOT NULL
				SET @table = @table + ' AND trn.cAmt = ' + CAST(@amt AS VARCHAR(50))
			
			IF @voucherNo IS NOT NULL
				SET @table = @table + ' AND trn.voucherNo = ''' + @voucherNo + ''''				
			
			IF @txnDate IS NOT NULL
				SET @table = @table + ' AND CAST(trn.createdDate AS DATE)='''+@txnDate +''''	
						
			if @isSelfApprove = 'N'			
				SET @table = @table + '  AND trn.createdBy <> '''+ @user +''''
			
			SET @sql = '
				SELECT 
					* 
				FROM (
					' + @table + ' 
				) x
				WHERE 1 = 1 '

			IF @txncreatedBy IS NOT NULL
				SET @sql = @sql + '  AND txncreatedBy = '''+@txncreatedBy+''''
				
			
			IF @sender IS NOT NULL
				SET @sql = @sql + ' AND sender LIKE ''' + @sender + '%'''

			IF @receiver IS NOT NULL
				SET @sql = @sql + ' AND receiver LIKE ''' + @receiver + '%'''			
					
			--PRINT @sql
			EXEC (@sql)
		RETURN	
	END
	
	IF @flag = 's-agent-self-txn'
	BEGIN		
		SET @branchList = '
			INNER JOIN ( 
				SELECT ' + CAST(@branchId AS VARCHAR) + ' agentId '
				
		IF @userType = 'RH'
		BEGIN
			SET @branchList = @branchList + '
							UNION ALL 	
							SELECT
								 am.agentId 			
							FROM agentMaster am WITH(NOLOCK)
							INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
							WHERE rba.agentId = ' + CAST(@branchId AS VARCHAR) + '
							AND ISNULL(rba.isDeleted, ''N'') = ''N''
							AND ISNULL(rba.isActive, ''N'') = ''Y'''
		END
		SET @branchList = @branchList + '			
			) bl ON trn.sBranch = bl.agentId			
			'

		SET @table = '
						SELECT DISTINCT
							 trn.id
							,branch = am.agentName							
							,country = trn.pCountry
							,senderId = sen.customerId
							,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')						
							,receiverId = rec.customerId
							,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
							,amt = CAST(trn.cAmt AS DECIMAL(18, 3))
							,voucherNo = trn.voucherNo
							,trn.createdBy
							,collMode = ''''
							,txnDate = CAST(trn.createdDate AS DATE)
							,txncreatedBy = trn.createdBy
						FROM remitTranTemp trn WITH(NOLOCK) 
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						' + @branchList + '	
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId
						--INNER JOIN #collModeList T ON T.tranId = trn.id
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL 
					'
			IF @txnType IS NOT NULL			
				SET @table = @table + ' AND trn.tranType = ''' + @txnType + '''' 
			else
				SET @table = @table + ' AND trn.tranType=''I''' 

			IF @id IS NOT NULL			
				SET @table = @table + ' AND trn.id = ''' + @id + '''' 
				
			IF @branch IS NOT NULL
				SET @table = @table + ' AND am.agentId = ''' + @branch + '''' 
			
			IF @country IS NOT NULL
				SET @table = @table + ' AND trn.pCountry LIKE ''' + @country + '%''' 
			
			IF @amt IS NOT NULL
				SET @table = @table + ' AND trn.cAmt = ' + CAST(@amt AS VARCHAR(50))
			
			IF @voucherNo IS NOT NULL
				SET @table = @table + ' AND trn.voucherNo = ''' + @voucherNo + ''''
				
			
			IF @txnDate IS NOT NULL
				SET @table = @table + ' AND CAST(trn.createdDate AS DATE)='''+@txnDate +''''
				
			SET @sqlSelfTxn = '
				SELECT 
					* 
				FROM (
					' + @table + ' AND trn.createdBy = '''+@user+'''
				) x
				WHERE 1 = 1 '
				
			IF @sender IS NOT NULL
				SET @sqlSelfTxn = @sqlSelfTxn + ' AND sender LIKE ''' + @sender + '%'''
			IF @receiver IS NOT NULL
				SET @sqlSelfTxn = @sqlSelfTxn + ' AND receiver LIKE ''' + @receiver + '%'''
	
			EXEC (@sqlSelfTxn)
		RETURN	
	END
	
	IF @flag = 's_txn_summary'
	BEGIN
			
			SET @branchList = '
			INNER JOIN ( 
				SELECT ' + CAST(@branchId AS VARCHAR) + ' agentId '
				
			IF @userType = 'RH'
			BEGIN
				SET @branchList = @branchList + '
								UNION ALL 	
								SELECT
									 am.agentId 			
								FROM agentMaster am WITH(NOLOCK)
								INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
								WHERE rba.agentId = ' + CAST(@branchId AS VARCHAR) + '
								AND ISNULL(rba.isDeleted, ''N'') = ''N''
								AND ISNULL(rba.isActive, ''N'') = ''Y'''
			END
			IF @userType = 'AH'
			BEGIN
				SET @branchList = @branchList + '
								UNION ALL 	
								select agentId from agentMaster with(nolock) where parentId = 
								(select parentId from agentmaster with(nolock) where agentId=' + CAST(@branchId AS VARCHAR) + ')
								and agentId <> ' + CAST(@branchId AS VARCHAR) + ''
			END

			SET @branchList = @branchList + '			
				) bl ON trn.sBranch = bl.agentId			
				'
			
			SET @tablesql = '
				select country,sum(txnCount) txnCount,sum(txnHoldCount) txnHoldCount from 
				(
					select country,txnCount,txnHoldCount from 
					(
						SELECT 					
							 country = CASE WHEN trn.tranType = ''B'' then pCountry+''(B2B)'' else  pCountry end
							,txnCount = case when trn.createdBy <> '''+@user+''' then 1 else 0 end
							,txnHoldCount = case when trn.createdBy = '''+@user+''' then 1 else 0 end
						FROM remitTranTemp trn WITH(NOLOCK) 						
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						' + @branchList + '	
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId
						WHERE  trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL AND trn.tranType IN (''I'',''B'')
					)z
				)x group by country'
			
			--print(@tablesql)
			EXEC(@tablesql)
	END
	
	IF @flag = 's_admin_txn_summary'
	BEGIN
			
			SET @tablesql = '
						SELECT 
							 sn = row_number() over(order by trn.sCountry)						
							,country = upper(trn.sCountry)
							,txnCount = count(''x'')
						FROM remitTranTemp trn WITH(NOLOCK) 						
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL AND trn.tranType=''I''  AND 
							  trn.tranType <> ''O'' AND isOnlineTxn <> ''Y''
						group by trn.sCountry
					'
			EXEC(@tablesql)
			--print @tablesql
	END

	IF @flag = 'OnlineTxn-waitingList'
	BEGIN
			
			SET @tablesql = '
						SELECT 
							 sn = row_number() over(order by trn.sCountry)						
							,country = upper(trn.sCountry)
							,txnCount = count(''x'')
						FROM remitTranTemp trn WITH(NOLOCK) 						
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL AND trn.tranType=''O'' AND isOnlineTxn =''Y''
						group by trn.sCountry
					'
			EXEC(@tablesql)
			--print @tablesql
	END
	IF @flag = 'getTxnForApproveByAgent'
	BEGIN
		SET @table = '
						SELECT DISTINCT
							 trn.id
							 ,controlNo = dbo.fnadecryptstring(controlNo)
							,branch = am.agentName							
							,country = trn.pCountry
							,senderId = sen.customerId
							,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')						
							,receiverId = rec.customerId
							,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
							,amt = CAST(trn.cAmt AS DECIMAL(18, 2))
							,trn.paymentMethod 
							,voucherNo = trn.voucherNo
							,txnDate = CAST(trn.createdDate AS DATE)
							,txncreatedBy = trn.createdBy
						FROM remitTranTemp trn WITH(NOLOCK) ' + @cdTable + '
						LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
						INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
						INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId														
						WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'', ''Cash Limit Hold'') AND 
							  trn.payStatus = ''Unpaid'' AND
							  trn.approvedBy IS NULL  AND 
							  ISNULL(trn.isOnlineTxn,''N'') <>''Y'' AND trn.tranType<>''O''
					'
			
			IF @user IS NOT NULL			
				SET @table = @table + ' AND trn.createdBy <> ''' + @user + '''' 

			IF @id IS NOT NULL			
				SET @table = @table + ' AND trn.id = ''' + @id + '''' 
				
			IF @branch IS NOT NULL
				SET @table = @table + ' AND am.agentId = ''' + @branch + '''' 
			
			IF @country IS NOT NULL
				SET @table = @table + ' AND trn.pCountry LIKE ''' + @country + '%''' 
			
			IF @sendCountry IS NOT NULL
				SET @table = @table + ' AND trn.sCountry LIKE ''' + @sendCountry + '%''' 

			IF @amt IS NOT NULL
				SET @table = @table + ' AND trn.pAmt = ' + CAST(@amt AS VARCHAR(20))+ '' 	
			
			IF @voucherNo IS NOT NULL
				SET @table = @table + ' AND trn.voucherNo = ''' + @voucherNo + ''''
				
			IF @txncreatedBy IS NOT NULL
				SET @table = @table + '  AND trn.createdBy = '''+@txncreatedBy+''''
				
			IF @txnDate IS NOT NULL
				SET @table = @table + ' AND CAST(trn.createdDate AS DATE)='''+@txnDate +''''
			
			IF @ControlNo IS NOT NULL
				SET @table = @table + ' AND trn.controlNo = dbo.fnaEncryptString('''+@ControlNo+''')'
						
			IF @sendAgent IS NOT NULL
				SET @table = @table + ' AND trn.sAgent  = '''+@sendAgent+''''
				
			IF @sendBranch IS NOT NULL
				SET @table = @table + ' AND trn.sBranch = '''+@sendBranch+''''
			
			
			SET @sql = '
				SELECT 
					* 
				FROM (
					' + @table + '
				) x
				WHERE 1 = 1 '
				
			IF @sender IS NOT NULL
				SET @sql = @sql + ' AND sender LIKE ''' + @sender + '%'''
			IF @receiver IS NOT NULL
				SET @sql = @sql + ' AND receiver LIKE ''' + @receiver + '%'''					

			PRINT @sql
			EXEC (@sql)		
		RETURN	
	END

IF @flag ='getTxnForVerify'
	BEGIN
    SET @table = '
					SELECT DISTINCT
						 trn.id
						 ,controlNo = dbo.fnadecryptstring(controlNo)
						,branch = am.agentName							
						,country = trn.pCountry
						,senderId = sen.customerId
						,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')						
						,receiverId = rec.customerId
						,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,amt = CAST(trn.cAmt AS DECIMAL(18, 2))
						,trn.paymentMethod 
						,voucherNo = trn.voucherNo
						,txnDate = CAST(trn.createdDate AS DATE)
						,txncreatedBy = trn.createdBy
					FROM remitTranTemp trn WITH(NOLOCK) ' + @cdTable + '
					LEFT JOIN apiRoutingTable art WITH(NOLOCK) ON trn.pAgent = art.agentId
					INNER JOIN agentMaster am WITH(NOLOCK) ON trn.sBranch = am.agentId	
					INNER JOIN tranSendersTemp sen WITH(NOLOCK) ON trn.id = sen.tranId
					INNER JOIN tranReceiversTemp rec WITH(NOLOCK) ON trn.id = rec.tranId														
					WHERE trn.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'',''OFAC/Compliance Hold'', ''Cash Limit Hold'') AND 
						  trn.payStatus = ''Unpaid'' AND
						  trn.approvedBy IS NULL AND ISNULL(sRouteId,''0'') =''1''
				'
	IF @sAgent IS NOT NULL
	BEGIN
	    SET @table = @table + '  AND trn.sAgent = '''+@sendAgent+''''
	END

	SET @sql = '
		SELECT 
			* 
		FROM (
			' + @table + '
		) x
		WHERE 1 = 1 '
	PRINT @sql
	EXEC (@sql)	
END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() msg, NULL id
END CATCH
