ALTER  PROC [dbo].[proc_cancelTranAPI_v2] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
	,@tranId			INT				= NULL	
	,@sCountry			INT				= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL	
	,@sTranId			VARCHAR(50)		= NULL	
	,@rCountry			INT				= NULL
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL
	,@pCountry			INT				= NULL

	,@customerId		INT				= NULL
	,@agentId			INT				= NULL
	,@senderId			INT				= NULL
	,@benId				INT				= NULL
	,@cancelReason		VARCHAR(200)	= NULL
	,@refund			CHAR(1)			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)	
	,@sAgent			INT
	,@tAmt				MONEY
	,@cAmt				MONEY
	,@pAmt				MONEY
	,@message			VARCHAR(200)
	,@payStatus			varchar(20)

SET NOCOUNT ON
SET XACT_ABORT ON
SELECT @pageSize = 1000, @pageNumber = 1

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)

EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT

DECLARE @tranStatus VARCHAR(20)
DECLARE @chargeToCustomer INT
DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(LTRIM(RTRIM(@controlNo))))

if right(@controlNo,1) <> 'D'
	set @flag ='cancelTxnAdmin'

-->> Direct domestic cancel
IF @flag = 'cancel'	
	BEGIN
		DECLARE @sBranch INT, @pLocation INT, @deliveryMethod VARCHAR(100), @deliveryMethodId INT, @pAgentComm MONEY, @cancelCharge MONEY, @returnAmt MONEY
		SELECT 
			 @tranStatus		= tranStatus
			,@sBranch			= sBranch
			,@sAgent			= sAgent
			,@pLocation			= pLocation
			,@deliveryMethod	= paymentMethod
			,@tAmt				= tAmt 
			,@cAmt				= cAmt
			,@pAmt				= pAmt
			,@payStatus			= payStatus
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
			
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction', NULL
			RETURN
		END
		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
			RETURN
		END
		IF (@payStatus = 'Post')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been POST', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Hold')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is hold. Transaction must be approved for cancellation.', NULL
			RETURN
		END
		DECLARE @id BIGINT, @settlingAgent INT, @ssAgent INT
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @pAgentComm = pAgentComm FROM [dbo].FNAGetDomesticPayCommForCancel(@sBranch, @pLocation, @deliveryMethodId, @tAmt)
		SET @returnAmt = @tAmt + @pAgentComm
		SET @cancelCharge = @cAmt - @returnAmt
		BEGIN TRANSACTION
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= dbo.FNAGetDateInNepalTZ()
				 ,cancelApprovedDateLocal	= dbo.FNAGetDateInNepalTZ()
				 ,cancelReason				= @cancelReason
				 ,refund					= @refund
			WHERE controlNo = @controlNoEncrypted

			SELECT @tranId = id	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
			SELECT @message = 'Cancel Request Approved'
			EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Cancel Approved'
			
			SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
			
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
			IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @ssAgent AND isSettlingAgent = 'Y'
		
			IF EXISTS (SELECT 'X' FROM remitTran WITH(NOLOCK) 
					WHERE controlNo = @controlNoEncrypted 
						AND createdDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101) + ' 23:59:59')
			BEGIN				
				UPDATE remitTran SET
					 cancelCharge = 0
				WHERE controlNo = @controlNoEncrypted				
				SET @chargeToCustomer = 0
			END
			ELSE
			BEGIN
				UPDATE remitTran SET
					 cancelCharge = @cancelCharge
				WHERE controlNo = @controlNoEncrypted				
				SET @chargeToCustomer = 1
			END
			
			EXEC SendMnPro_Account.dbo.[PROC_REMIT_DATA_UPDATE] 
				 @flag			= 'c'
				,@user			= @user
				,@controlNo		= @controlNo
			-- ## Limit Update
			EXEC Proc_AgentBalanceUpdate @flag = 'c',@tAmt = @cAmt ,@settlingAgent = @settlingAgent

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	
		EXEC [proc_errorHandler] 0, 'Transaction Cancelled successfully', @tranId
	END

ELSE IF @flag = 'cancelReject'
BEGIN
	--EXEC proc_cancelTran @flag = 'cancelReject', @controlNo = ''
	BEGIN TRANSACTION
		UPDATE remitTran SET
			 tranStatus				= 'Payment'					
		WHERE controlNo = @controlNoEncrypted
	--End-----------------------------------------------------------------------------------------------------------------
	
	--Transaction Log---------------------------
	SELECT @tranId = id	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	SELECT @message = 'Cancel Request for this transaction rejected'
	EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Cancel Reject'
	--------------------------------------------		
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
	EXEC proc_errorHandler 0, 'Cancel Request rejected successfully', @controlNoEncrypted
	select 'a'
	REturn
	--EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @message, @agentRefId = NULL	
END

-->> Direct internation cancel
ELSE IF @flag = 'cancelTxnAdmin'
BEGIN		
	DECLARE @serviceCharge MONEY,@scRefund MONEY,@cancelReason1 VARCHAR(MAX),@canceledAmt MONEY,@createdBy AS VARCHAR(50),@branchId INT,
	@isPaidTxn CHAR(1), @sCountryId INT, @pCountryId INT, @pAgent INT, @bonusPoint INT,@holdTranId bigint
	SELECT 
		 @tranId			= a.id
		,@serviceCharge		= a.serviceCharge
		,@tAmt				= a.tAmt
		,@cAmt				= a.cAmt
		,@createdBy			= a.createdBy
		,@tranStatus		= a.tranStatus
		,@branchId			= a.sBranch
		,@isPaidTxn			= CASE WHEN (paidBy IS NOT NULL OR paidDate IS NOT NULL) THEN 'Y' ELSE 'N' END
		,@sCountryId		= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry)
		,@sAgent			= sAgent
		,@sBranch			= sBranch
		,@pCountryId		= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = pCountry)
		,@pAgent			= pAgent
		,@bonusPoint		= ISNULL(a.bonusPoint, 0)
		,@payStatus			= a.payStatus
	FROM vwRemitTran a WITH(NOLOCK) 
	WHERE a.controlNo = @controlNoEncrypted 
			

	IF @user IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction.', NULL
		RETURN
	END
	IF (@tranStatus IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction not found.', @controlNoEncrypted
		RETURN
	END

	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been cancelled', @controlNoEncrypted
		RETURN
	END
	IF (@payStatus = 'Post')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been POST.', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'CANCELLED')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Cancel Processing')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'ModificationRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been requested for modification.', @controlNoEncrypted
		RETURN
	END

	IF (@tranStatus = 'Lock')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is locked. Please contact HO', @controlNoEncrypted
		RETURN
	END

	IF (@tranStatus = 'Block')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is blocked. Please contact HO', @controlNoEncrypted
		RETURN
	END

	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been requested for cancellation', @controlNoEncrypted
		RETURN
	END

	IF EXISTS(SELECT 'x' FROM trancancelrequest WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND cancelStatus <> 'Rejected')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is already requested for cancel.', @controlNoEncrypted
		RETURN
	END
	BEGIN TRANSACTION
		
	INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,
			createdBy,createdDate,tranStatus,approvedBy,approvedDate,scRefund,isScRefund)
	SELECT @tranId,@controlNoEncrypted,@cancelReason,'Approved',@user,GETDATE(),@tranStatus,@user,GETDATE(),
	CASE WHEN @refund ='D' THEN @cAmt ELSE @tAmt END,@refund
		
	IF @tranStatus NOT LIKE '%HOLD%'
	BEGIN			
		UPDATE remitTran SET
				 tranStatus					= 'Cancel'
				,cancelApprovedBy			= @user
				,cancelApprovedDate			= GETDATE()
				,cancelApprovedDateLocal	= GETDATE()
		WHERE controlNo = @controlNoEncrypted

		UPDATE SendMnPro_Account.dbo.remit_trn_master SET
				trn_status	= 'Cancel'
			,cancel_date	= GETDATE()
		WHERE trn_ref_no = @controlNoEncrypted

		-- ## Limit Update		
		EXEC Proc_AgentBalanceUpdate @flag = 'c',@tAmt = @cAmt, @settlingAgent = @sBranch
	END
				
	IF @tranStatus LIKE '%HOLD%'
	BEGIN	
		-->> UPDATE REMITTRAN				
		UPDATE remitTranTemp SET
				tranStatus				= 'Cancel'
				,cancelApprovedBy			= @user
				,cancelApprovedDate		= GETDATE()
				,cancelApprovedDateLocal	= GETDATE()
		WHERE controlNo = @controlNoEncrypted
			
		INSERT INTO cancelTranHistory(
			tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
			,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
			,treasuryTolerance,customerPremium,schemePremium,sharingValue
			--,sharingType
			,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
			,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
			,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
			,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
			,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
			,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
			,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate,cancelApprovedDateLocal
			,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
			,uploadLogId,voucherNo,controlNo2,pBankType,senderName,receiverName
		)
		SELECT 
			id,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
			,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
			,treasuryTolerance,customerPremium,schemePremium,sharingValue
			--,sharingType
			,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
			,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
			,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
			,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
			,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
			,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
			,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@cancelReason1,refund,cancelCharge,dbo.FNADateFormatTZ(GETDATE(), @user),GETDATE()
			,@user,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
			,uploadLogId,voucherNo,controlNo2,pBankType,senderName,receiverName
			FROM remitTranTemp WHERE controlNo =  @controlNoEncrypted
			
		INSERT INTO cancelTranSendersHistory 
		(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
		zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
		idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
		gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer)
		SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
		zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
		idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
		gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer 
		FROM transenderstemp WITH(NOLOCK) WHERE tranId = @tranId
			
		INSERT INTO cancelTranReceiversHistory 
		(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
		STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
		occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
		validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress)
		SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
		STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
		occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
		validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress
		FROM tranReceiversTemp WITH(NOLOCK)	WHERE tranId = @tranId

		-- ## Limit Update		
		UPDATE creditLimitInt SET 
			todaysSent = ISNULL(todaysSent,0) - @canceledAmt
		WHERE agentId = @sAgent
	

		DELETE FROM remitTranTemp WHERE controlNo = @controlNoEncrypted
		DELETE FROM tranSendersTemp WHERE tranId = @tranId
		DELETE FROM tranReceiversTemp WHERE tranId = @tranId			
	END
		
	SELECT @message = 'Transaction cancel has been done successfully.'
	EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Transaction Cancel Approved'	
		
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC [proc_errorHandler] 0, 'Transaction cancel has been done successfully', @tranId

END


GO
