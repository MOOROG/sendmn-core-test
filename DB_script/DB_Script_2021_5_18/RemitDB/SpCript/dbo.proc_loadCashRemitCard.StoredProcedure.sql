USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_loadCashRemitCard]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_loadCashRemitCard]
(
	 @flag				VARCHAR(50)		= NULL
	,@user				VARCHAR(50)		= NULL
	,@id				INT				= NULL
	,@controlNo			VARCHAR(50)		= NULL
    ,@agentUniqueRefId	VARCHAR(20)		= NULL
	,@sBranch			INT				= NULL
	,@sBranchName		VARCHAR(100)	= NULL
	,@sAgent			INT				= NULL
	,@sAgentName		VARCHAR(100)	= NULL
	,@sSuperAgent		INT				= NULL
	,@sSuperAgentName	VARCHAR(100)	= NULL
	,@settlingAgent		INT				= NULL
	,@mapCode			VARCHAR(8)		= NULL
	,@mapCodeDom		VARCHAR(8)		= NULL

	,@remitCardNo		VARCHAR(50)		= NULL
	,@benefName			VARCHAR(200)	= NULL
	,@benefAddress		VARCHAR(500)	= NULL
	,@benefMobile		VARCHAR(50)		= NULL
	,@benefIdType		VARCHAR(50)		= NULL
	,@benefIdNo			VARCHAR(50)		= NULL

	,@senderName		VARCHAR(200)	= NULL
	,@senderAddress		VARCHAR(500)	= NULL		
	,@senderMobile		VARCHAR(50)		= NULL
	,@senderIdType		VARCHAR(50)		= NULL
	,@senderIdNo		VARCHAR(50)		= NULL
	,@senderRemitCardNo	VARCHAR(50)		= NULL

	,@tAmt				MONEY			= NULL
    ,@serviceCharge		MONEY			= NULL
    ,@cAmt				MONEY			= NULL
    ,@pAmt				MONEY			= NULL

	,@purposeOfRemit	VARCHAR(200)	= NULL 
    ,@sourceOfFund		VARCHAR(200)	= NULL
    ,@remarks			VARCHAR(MAX)	= NULL

	,@fromSendTrnTime	VARCHAR(20)		= NULL
	,@toSendTrnTime		VARCHAR(20)		= NULL
	,@txtPass			VARCHAR(50)		= NULL
	,@sDcInfo			VARCHAR(50)		= NULL
	,@sIpAddress		VARCHAR(50)		= NULL
	,@payResponseCode	VARCHAR(200)	= NULL
	,@payResponseMsg	VARCHAR(200)	= NULL
	,@isKycApprove		CHAR(1)			= NULL
	,@refNo				VARCHAR(50)		= NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), membershipId INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@errorMsg			VARCHAR(MAX)
		,@controlNoEncrypted VARCHAR(50)
		,@benefAcNo			VARCHAR(50)

		,@sCountry			VARCHAR(100)
		,@sCountryId		VARCHAR(30)
		,@pCountry			VARCHAR(100)
		,@pCountryId		VARCHAR(30)

		,@deliveryMethod	VARCHAR(50) 
		,@collMode			VARCHAR(50)
		,@sendingCustType	VARCHAR(50)
		,@sendingCurrency	CHAR(3)
		,@iCollectAmount	MONEY
		,@kycApproveFlag	CHAR(1)
		,@limitBal			MONEY
		,@agentType			INT
		

	IF @flag='selectByRemitCardNo'	
	BEGIN
		IF NOT EXISTS(SELECT 'x' FROM kycMaster WITH(NOLOCK) 
			WHERE remitCardNo = @remitCardNo AND ISNULL(isDeleted,'N') = 'N' AND ISNULL(isActive,'Y') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'KYC Customer Not Found.', NULL
			RETURN
		END
		
		SELECT 
			errorCode = 0 ,
			fullName = ISNULL(' '+km.firstName,'')+ ISNULL(' '+km.middleName,'')+ ISNULL(' '+km.lastName,''),
			pAddress = ISNULL(' '+vdcMP,'') + ISNULL(' '+wardNoT,'')+ISNULL(' '+districtP,'')+ISNULL(' '+sm.stateName,'')+ISNULL(' '+cm.countryName,''),
			mobileP,
			idCardType = 'Citizenship',
			idCardNo = citizenshipNo,
			remitCardNo
		FROM kycMaster km WITH(NOLOCK) 
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON km.countryP = cm.countryId
		LEFT JOIN countryStateMaster sm WITH(NOLOCK) ON km.zoneP = sm.stateId
		WHERE remitCardNo = @remitCardNo
	END

	--## load starter
	IF @flag = 'ls'
	BEGIN	
		DECLARE 
			@pBranchName VARCHAR(200),
			@receiverName VARCHAR(200),
			@availableLimit MONEY

		SELECT 
			@pBranchName = pBranchName,
			@sBranch = pBranch,
			@receiverName = receiverName,
			@pAmt = pAmt,
			@remitCardNo = CASE WHEN LEN(ISNULL(rec.membershipId,'')) = 16 THEN rec.membershipId ELSE '' END
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN dbo.tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE controlNo = dbo.FNAEncryptString(@controlNo)

		SELECT @sAgent = parentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		IF @agentType = 2903
			SET @sAgent = @sBranch
		
		SELECT @sSuperAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		
		SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		
		SELECT 
			 @availableLimit	= ISNULL(dbo.FNAGetLimitBal(@settlingAgent), 0)
		FROM creditLimit cl
		LEFT JOIN currencyMaster cm WITH(NOLOCK) ON cl.currency = cm.currencyId
		WHERE agentId = @settlingAgent

		IF EXISTS(SELECT 'x' FROM kycMaster WITH(NOLOCK) 
			WHERE remitCardNo = @remitCardNo AND ISNULL(isDeleted,'N') = 'N' AND ISNULL(isActive,'Y') = 'Y')
		BEGIN
			SELECT 
				@benefName = ISNULL(' '+km.firstName,'')+ ISNULL(' '+km.middleName,'')+ ISNULL(' '+km.lastName,''),
				@benefAddress = ISNULL(' '+vdcMP,'') + ISNULL(' '+wardNoT,'')+ISNULL(' '+districtP,'')+ISNULL(' '+sm.stateName,'')+ISNULL(' '+cm.countryName,''),
				@benefMobile = mobileP,
				@benefIdType = 'Citizenship',
				@benefIdNo = citizenshipNo
			FROM kycMaster km WITH(NOLOCK) 
			LEFT JOIN countryMaster cm WITH(NOLOCK) ON km.countryP = cm.countryId
			LEFT JOIN countryStateMaster sm WITH(NOLOCK) ON km.zoneP = sm.stateId
			WHERE remitCardNo = @remitCardNo
		END			

		SELECT 
			remitCardNo = @remitCardNo,
			controlNo = @controlNo,
			pBranchName = @pBranchName,
			pBranch = @sBranch,
			receiverName = @receiverName,
			pAmt = @pAmt,
			availableBal = @availableLimit,
			benefName = @benefName,
			benefAddress = @benefAddress,
			benefMobile = @benefMobile,
			benefIdType = @benefIdType,
			benefIdNo = @benefIdNo
	END
	
	--## save history
	IF @flag='sh'
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END
		SET @txtPass = dbo.FNAEncryptString(@txtPass)
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE PWD = @txtPass AND userName = @user)
		BEGIN
			EXEC proc_errorHandler 1, 'TXN password is invalid !', @user
			RETURN
		END
		IF(DATEDIFF(MI,CAST(dbo.FNAGetDateInNepalTZ() AS TIME), CAST(@fromSendTrnTime AS TIME))) > 0
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorized to send at this time', NULL
			RETURN
		END
		IF(DATEDIFF(MI,CAST(dbo.FNAGetDateInNepalTZ() AS TIME), CAST(@toSendTrnTime AS TIME))) < 0
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorized to send at this time', NULL
			RETURN
		END
			
		IF NOT EXISTS(SELECT 'x' FROM kycMaster WITH(NOLOCK) 
			WHERE remitCardNo = @remitCardNo 
			AND ISNULL(isDeleted,'N') = 'N' 
			AND ISNULL(isActive,'Y') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'KYC Customer Not Found.', NULL
			RETURN
		END

		SELECT  @agentType = agentType, 
				@sAgent = parentId, 
				@sBranchName = agentName
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		IF @agentType = 2903	
		BEGIN
			SET @sAgent = @sBranch
		END
		SELECT DISTINCT @sSuperAgent = parentId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		SELECT DISTINCT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
		
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'


		SELECT @pCountry = 'Nepal'
		SELECT @sCountry = 'Nepal'
		SELECT @pCountryId = '151'
		SELECT @sCountryId = '151'

		SET @deliveryMethod	= 'IME Remit Card' 
		SET @collMode = NULL
		SET @sendingCustType = NULL
		SET @sendingCurrency = 'NPR'

		DECLARE @currentDate DATETIME
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		SET @currentDate = dbo.FNAGetDateInNepalTz()

		IF EXISTS(SELECT 'X' FROM remitTran trn WITH(NOLOCK)
					LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE 
						trn.createdDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101)+' 23:59:59'
						AND trn.senderName = @senderName
						AND trn.receiverName = @benefName
						AND trn.tAmt = @tAmt
						AND trn.serviceCharge = @serviceCharge
						AND trn.cAmt = @cAmt
						AND DATEDIFF(MI, trn.createdDate, @currentDate) <= 5)
		BEGIN
			EXEC proc_errorHandler 1, 'Similar Transaction Found', NULL
			RETURN
		END
		
		IF @tAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END

		IF EXISTS (
			SELECT 
				'X'
			FROM sendTranLimit
			WHERE agentId = @settlingAgent
				AND (tranType = @collMode OR tranType IS NULL)
				AND (paymentType = @deliveryMethod OR paymentType IS NULL)
				AND (customerType = @sendingCustType OR customerType IS NULL)
				AND currency = @sendingCurrency
				AND (receivingCountry = @pCountry OR receivingCountry IS NULL)
				AND ISNULL(minLimitAmt, 0) > @tAmt
				AND ISNULL(maxLimitAmt, 0) < @tAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN	
			EXEC [proc_errorHandler] 1, 'Agent Sending limit is exceeded.', NULL
			RETURN
		END

		IF NOT EXISTS (
			SELECT 
				'X' 
			FROM sendTranLimit
			WHERE countryId = @sCountryId
				AND (tranType = @collMode OR tranType IS NULL)
				AND (paymentType = @deliveryMethod OR paymentType IS NULL)
				AND (customerType = @sendingCustType OR customerType IS NULL)
				AND currency = @sendingCurrency
				AND (receivingCountry = @pCountryId OR receivingCountry IS NULL)
				AND ISNULL(minLimitAmt, 0) <= @tAmt
				AND ISNULL(maxLimitAmt, 0) >= @tAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN		
			EXEC [proc_errorHandler] 1, 'Country Sending limit is not defined or exceeds.', NULL
			RETURN
		END	

		DECLARE @sAgentComm MONEY,@sSuperAgentComm MONEY
		SELECT 
			 @serviceCharge		= 0
			,@sAgentComm		= 0
			,@sSuperAgentComm	= 0

		IF (@cAmt IS NULL)
		BEGIN	
			SET @cAmt = @tAmt + @serviceCharge	
		END

		SET @iCollectAmount = @tAmt + @serviceCharge
		IF(@cAmt <> @iCollectAmount)
		BEGIN
			EXEC [proc_errorHandler] 1, 'Collection Amount not match.', NULL
			RETURN
		END

		SELECT @kycApproveFlag = CASE WHEN approvedDate IS NULL THEN 'N' ELSE 'Y' END,
				@benefAcNo = accountNo
		FROM kycMaster WITH(NOLOCK) WHERE remitCardNo = @remitCardNo

		BEGIN TRANSACTION
		INSERT INTO globalCardServiceHistory
		(
			 remitCardNo
			,controlNo
			,sAgent
			,sAgentName
			,sSuperAgent
			,sSuperAgentName
			,sBranch
			,sBranchName
			,benefName
			,benefAddress
			,benefMobile
			,benefIdType
			,benefIdNo
			,benefAcNo
			,senderName
			,senderAddress
			,senderMobile
			,senderIdType
			,senderIdNo
			,senderRemitCardNo
			,collCurr
			,payoutCurr
			,tAmt
			,cAmt
			,serviceCharge
			,sAgentComm
			,dollarRate
			,purposeOfRemit
			,sourceOfFund
			,remarks
			,paymentMethod
			,tranType
			,tranStatus
			,createdBy
			,createdDate
			,createdDateLocal
			,approvedBy
			,approvedDate
			,approvedDateLocal	
			,dcInfo
			,ipAddress
			,refNo
		)
		VALUES
		(
			 @remitCardNo
			,@controlNoEncrypted
			,@sAgent
			,@sAgentName
			,@sSuperAgent
			,@sSuperAgentName
			,@sBranch
			,@sBranchName
			,@benefName
			,@benefAddress
			,@benefMobile
			,@benefIdType
			,@benefIdNo
			,@benefAcNo
			,@senderName
			,@senderAddress
			,@senderMobile
			,@senderIdType
			,@senderIdNo
			,@senderRemitCardNo
			,'NPR'
			,'NPR'
			,@tAmt
			,@cAmt
			,@serviceCharge
			,@sAgentComm
			,'0'
			,@purposeOfRemit
			,@sourceOfFund
			,@remarks
			,'Card Deposit'
			,'C'
			,'Processing'
			,@user
			,GETDATE()
			,DBO.FNAGetDateInNepalTZ()
			,@user
			,GETDATE()
			,DBO.FNAGetDateInNepalTZ()	
			,@sDcInfo
			,@sIpAddress
			,@refNo
		)		
		
		SET @id = @@IDENTITY
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION			
		SELECT 0 errorCode, 'Transaction has been proceed successfully.' msg, @id id, @kycApproveFlag extra 	
	
	END

	--## txn detail
	IF @flag ='td'
	BEGIN
		SELECT 
			  controlNo			= CAST(id AS VARCHAR)+'D'
			 ,benefName			= benefName
			 ,benefAddress		= benefAddress
			 ,benefMobile		= benefMobile
			 ,benefIdType		= benefIdType
			 ,benefIdNo			= benefIdNo
			 ,benefAccNo		= benefAcNo
			 ,senderName		= senderName
			 ,senderAddress		= senderAddress
			 ,senderMobile		= senderMobile
			 ,senderIdType		= senderIdType
			 ,senderIdNo		= senderIdNo
			 ,purpose			= purposeOfRemit
			 ,remitType			= 'BANK'
			 ,payingBankBranchCd= '14'
			 ,rCurrency			= 'NPR'
			 ,localAmount		= tAmt
			 ,amount			= tAmt
			 ,serviceCharge		= serviceCharge
			 ,pCommission		= sAgentComm
			 ,dollarRate		= 1
			 ,refNo				= remitCardNo
			 ,remarks			= remarks
			 ,[source]			= sourceOfFund
			 ,txnType			= 'C'
			 ,HitApi			= '1'
			 ,refTranNo			= refNo
		FROM globalCardServiceHistory WITH(NOLOCK) 
		WHERE id = @id AND tranStatus = 'Processing'	
	END

	--## api error 
	IF @flag='ae'
	BEGIN		
		UPDATE globalCardServiceHistory SET tranStatus='sendError' WHERE id = @id
		EXEC proc_errorHandler 1, @payResponseMsg, @id
		RETURN
	END

	--## receipt
	IF @flag = 'r'
	BEGIN	
		
		IF RIGHT(@controlNo,1) = 'D'
		BEGIN		
			SELECT 
				 tranNo = trn.id
				,benefRemitCardNo = rec.membershipId
				,controlNo = DBO.FNADecryptString(controlNo)			
				,benefName  = trn.receiverName
				,benefAddress = rec.address
				,benefMobile = rec.mobile
				,benefIdType = rec.idType
				,benefIdNo = rec.idNumber
				,senderName = trn.senderName
				,senderAddress = sen.address
				,senderMobile = sen.mobile
				,senderIdType = sen.idType
				,senderIdNo = sen.idNumber
				,senderRemitCardNo = sen.membershipId
				,collCurr = 'NPR'
				,tAmt
				,cAmt
				,serviceCharge
				,sAgentComm
				,dollarRate =''
				,rec.purposeOfRemit
				,sourceOfFund
				,pMessage
				,modeOfPayment = paymentMethod
				,tranType
				,tranStatus
				,trn.createdDate		
				,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END
				,sBranchName = trn.sBranchName
				,sAgentCountry = sa.agentCountry
				,sAgentLocation = sLoc.districtName	
				,sAgentAddress = sa.agentAddress
				,agentPhone1 = sa.agentPhone1
			FROM remitTran trn WITH(NOLOCK) 
				INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				INNER JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
				LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
			WHERE trn.controlNo = dbo.FNAEncryptString(@controlNo)
		END
		ELSE
		BEGIN
			SELECT 
				 tranNo = trn.id
				,benefRemitCardNo = trn.remitCardNo
				,controlNo = trn.id			
				,benefName  = trn.benefName
				,benefAddress = trn.benefAddress
				,benefMobile = trn.benefMobile
				,benefIdType = trn.benefIdType
				,benefIdNo = trn.benefIdNo
				,senderName = trn.senderName
				,senderAddress = trn.senderAddress
				,senderMobile = trn.senderMobile
				,senderIdType = trn.senderIdType
				,senderIdNo = trn.senderIdNo
				,senderRemitCardNo = trn.senderRemitCardNo
				,collCurr = 'NPR'
				,tAmt
				,cAmt
				,serviceCharge
				,sAgentComm
				,dollarRate =''
				,purposeOfRemit
				,sourceOfFund
				,pMessage = 'Transaction has been sent but waiting for approval from HO.'
				,modeOfPayment = paymentMethod
				,tranType
				,tranStatus
				,trn.createdDate		
				,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END
				,sBranchName = trn.sBranchName
				,sAgentCountry = sa.agentCountry
				,sAgentLocation = sLoc.districtName	
				,sAgentAddress = sa.agentAddress
				,agentPhone1 = sa.agentPhone1
			FROM globalCardServiceHistory trn WITH(NOLOCK) 
				INNER JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
				LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
			WHERE trn.id = @controlNo
		END
		DECLARE @sUserFullName VARCHAR(200),
			@sUser VARCHAR(50),
			@headMsg VARCHAR(MAX),
			@commonMsg VARCHAR(MAX),
			@countrySpecificMsg VARCHAR(MAX),
			@msgType CHAR(1) = 'S'
		-->> 6.Message	
		SELECT
			@sUserFullName = ISNULL(''+firstName,'') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
		FROM applicationUsers WITH(NOLOCK) WHERE userName = @User
	
		SELECT @sCountry = countryId FROM countryMaster WITH(NOLOCK) 
			WHERE countryName = (SELECT agentCountry FROM agentMaster WHERE agentId = @sAgent)
	
		--Head Message
		SELECT @headMsg = headMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
		IF(@headMsg IS NULL)
			SELECT @headMsg = headMsg FROM message WHERE countryId IS NULL AND headMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
		
		--Common Message
		SELECT @commonMsg = commonMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y'
		IF(@commonMsg IS NULL)
			SELECT @commonMsg = commonMsg FROM message WHERE countryId IS NULL AND commonMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
		--Country Specific Message
		SELECT @countrySpecificMsg = countrySpecificMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
		IF(@countrySpecificMsg IS NULL)
			SELECT @countrySpecificMsg = countrySpecificMsg FROM message WHERE countryId IS NULL AND countrySpecificMsg IS NOT NULL AND msgType = @msgType AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
		SELECT @headMsg AS headMsg,@commonMsg AS commonMsg, @countrySpecificMsg AS countrySpecificMsg, @sUserFullName AS sUserFullName
	END

	--## Send & Pay
	IF @flag='sp'
	BEGIN
		
		IF @user IS NULL
		BEGIN
			UPDATE globalCardServiceHistory SET tranStatus='sendError' WHERE id = @id
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END

		SET @controlNo = CAST(@id AS VARCHAR(10))+ 'D'		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

		DECLARE 
			@tranId INT,
			@customerId INT,
			@ReceiverRemitCardNo VARCHAR(16),
			@benefFirstName	VARCHAR(200),
			@benefMiddleName VARCHAR(200),
			@benefLastName	VARCHAR(200),
			@benefPhone		VARCHAR(50),
			@benefEmail		VARCHAR(50),
			@benefCountry	VARCHAR(50),
			@senderFirstName	VARCHAR(200),
			@senderMiddleName VARCHAR(200),
			@senderLastName	VARCHAR(200),
			@senderPhone		VARCHAR(50),
			@senderEmail		VARCHAR(50),
			@senderCountry	VARCHAR(50),
			@sFullName		VARCHAR(500),
			@rFullName		VARCHAR(500)	

		SELECT 
			@ReceiverRemitCardNo = remitCardNo,
			@senderRemitCardNo = senderRemitCardNo,
			@sBranch = sBranch,
			@tAmt = tAmt,
			@rFullName = benefName,
			@sFullName = senderName,
			@serviceCharge = serviceCharge,
			@pAmt = tAmt,
			@cAmt = cAmt,
			@sAgentComm = sAgentComm,
			@mapCodeDom = am.mapCodeDom
		FROM globalCardServiceHistory gh WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON gh.sBranch = am.agentId
		WHERE gh.id = @id

		SELECT 
			@benefFirstName	= firstName,
			@benefMiddleName = middleName,
			@benefLastName	= lastName,
			@benefPhone		= phoneNoP,
			@benefEmail		= emailP,
			@benefCountry	= cm.countryName
		FROM kycMaster km WITH(NOLOCK)
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = km.countryP 
		WHERE remitCardNo = @ReceiverRemitCardNo

		SELECT 
			@customerId = customerId 
		FROM customerMaster WITH(NOLOCK) WHERE membershipId = @ReceiverRemitCardNo
		
		SELECT @pCountry = 'Nepal'
		SELECT @sCountry = 'Nepal'
		SELECT @pCountryId = '151'
		SELECT @sCountryId = '151'

			--## Start Bonus Point
		IF (ISNULL(@customerId, 0) <> 0)
		BEGIN
			DECLARE @maxPointsPerTxn INT, @bonusSchemeId INT, @bonusUnit INT, @bonusPoint INT
			SELECT @bonusSchemeId = bonusId
				  ,@maxPointsPerTxn = maxPointsPerTxn 
			FROM dbo.FNAGetBonusSetupDetail(@sCountryId, @sAgent, @sBranch, @pCountryId, '')
			SELECT @bonusUnit = unit, @bonusPoint = points FROM bonusOperationSetup WITH(NOLOCK) WHERE bonusSchemeId = @bonusSchemeId

			IF @bonusSchemeId IS NOT NULL
			BEGIN
				DECLARE @txnBonusPoint FLOAT
				SET @txnBonusPoint = @tAmt * (CAST(@bonusPoint AS FLOAT)/CAST(@bonusUnit AS FLOAT))
				SET @txnBonusPoint = CASE WHEN @txnBonusPoint > ISNULL(@maxPointsPerTxn, 0) THEN ISNULL(@maxPointsPerTxn, 0) ELSE ISNULL(@txnBonusPoint, 0) END
				UPDATE customerMaster SET
					 bonusPointPending	  = ISNULL(bonusPointPending, 0) + @txnBonusPoint
					--,bonusTxnCount		  = ''--ISNULL(bonusTxnCount, 0) + 1
					--,bonusTxnAmount		  = ''--ISNULL(bonusTxnAmount, 0) + @tAmt
				WHERE customerId = @customerId
			END
		END

		BEGIN TRANSACTION
		INSERT INTO remitTran
		(
			controlNo,
			serviceCharge,
			sAgentComm,
			pMessage,
			sCountry,
			sSuperAgent,
			sSuperAgentName,
			sAgent,
			sAgentName,
			sBranch,
			sBranchName,
			pCountry,
			pSuperAgent,
			pSuperAgentName,
			pAgent,
			pAgentName,
			pBranch,
			pBranchName,
			pState,
			pDistrict,
			pLocation,
			collCurr,
			tAmt,
			cAmt,
			pAmt,
			payoutCurr,
			purposeOfRemit,
			sourceOfFund,
			tranStatus,
			payStatus,
			paymentMethod,
			createdDate,
			createdDateLocal,
			createdBy,
			approvedDate,
			approvedDateLocal,
			approvedBy,
			paidDate,
			paidDateLocal,
			paidBy,
			tranType,
			senderName,
			receiverName,
			bonusPoint,
			holdTranId,
			accountNo,
			controlNo2
		)
		SELECT
			@controlNoEncrypted,
			serviceCharge,
			sAgentComm,
			remarks,
			'Nepal',
			sSuperAgent,
			sSuperAgentName,
			sAgent,
			sAgentName,
			sBranch,
			sBranchName,
			'Nepal',
			'1002',
			'INTERNATIONAL MONEY EXPRESS (IME) PVT. LTD',
			'20733',
			'GIBL Remit Card',
			'20733',
			'GIBL Remit Card',
			'Bagmati',
			'Kathmandu',
			'137',
			collCurr,
			tAmt,
			cAmt,
			tAmt,
			payoutCurr,
			purposeOfRemit,
			sourceOfFund,
			'Paid',
			'Paid',
			'IME Remit Card',
			GETDATE(),
			DBO.FNAGetDateInNepalTZ(),
			@user,
			GETDATE(),
			DBO.FNAGetDateInNepalTZ(),
			@user,
			GETDATE(),
			DBO.FNAGetDateInNepalTZ(),
			@user,
			'D',
			senderName,
			benefName,
			@bonusPoint,
			@id,
			benefAcNo,
			refNo			
		FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id		
		
		SET @tranId = SCOPE_IDENTITY()

		INSERT INTO tranReceivers
			(
				 tranId
				,customerId
				,membershipId
				,firstName
				,middleName
				,lastName1
				,country
				,[address]
				,email
				,homePhone
				,mobile
				,nativeCountry
				,idType
				,idNumber
			)
		SELECT 
			 @tranId
			,@customerId
			,@ReceiverRemitCardNo
			,@benefFirstName
			,@benefMiddleName
			,@benefLastName
			,@benefCountry
			,benefAddress
			,@benefEmail
			,@benefPhone
			,benefMobile
			,@benefCountry
			,benefIdType
			,benefIdNo
		FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id

		IF @senderRemitCardNo IS NOT NULL
		BEGIN					
			SELECT 
				@senderFirstName	= firstName,
				@senderMiddleName	= middleName,
				@senderLastName		= lastName,
				@senderPhone		= phoneNoP,
				@senderCountry		= cm.countryName,
				@senderEmail		= emailP
			FROM kycMaster km WITH(NOLOCK) 
			LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = km.countryP 
			WHERE RemitCardNo = @senderRemitCardNo

			SELECT 
				@customerId = customerId 
			FROM customerMaster WITH(NOLOCK) WHERE membershipId = @senderRemitCardNo
			INSERT INTO tranSenders
			(
				 tranId
				,customerId
				,membershipId
				,firstName
				,middleName
				,lastName1
				,country
				,[address]
				,email
				,homePhone
				,mobile
				,nativeCountry
				,idType
				,idNumber
			)
			SELECT 
				 @tranId
				,@customerId
				,@senderRemitCardNo
				,@senderFirstName
				,@senderMiddleName
				,@senderLastName
				,@senderCountry
				,benefAddress
				,@senderEmail
				,@senderPhone
				,senderMobile
				,@senderCountry
				,senderIdType
				,senderIdNo
			FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id
		END
		ELSE
		BEGIN
			INSERT INTO tranSenders
			(
				 tranId
				,firstName
				,[address]
				,mobile
				,idType
				,idNumber
				,ipAddress
				,dcInfo
			)
			SELECT 
				 @tranId
				,senderName
				,senderAddress
				,senderMobile
				,senderIdType
				,senderIdNo
				,ipAddress
				,dcInfo
			FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id
		END

		EXEC SendMnPro_Account.dbo.[PROC_REMIT_DATA_UPDATE] 
					 @flag = 's'
					,@controlNo = @controlNo
					,@mapCode = @mapCodeDom
					,@sFirstName = @sFullName
					,@rFirstName = @rFullName
					,@cAmt = @cAmt
					,@pAmt = @pAmt
					,@serviceCharge = @serviceCharge
					,@sAgentComm = @sAgentComm
					,@pAgentComm = 0
					,@deliveryMethod = 'Bank Deposit'
					,@user = @user
					,@tranId = @tranId

		EXEC SendMnPro_Account.dbo.PROC_REMIT_DATA_UPDATE
			 @flag			= 'p'
			,@mapCode		= '20733'
			,@user			= @user
			,@pAgentComm	= 0
			,@controlNo		= @controlNo

		DELETE FROM globalCardServiceHistory WHERE id = @id
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION			
		EXEC [proc_errorHandler] 0, 'Transaction has been sent successfully.', @controlNo		
	
	END

	--## send unpaid (unapproved customer)
	IF @flag='su'
	BEGIN
		
		IF @user IS NULL
		BEGIN
			UPDATE globalCardServiceHistory SET tranStatus='sendError' WHERE id = @id
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END

		--SET @controlNo = '7' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 9) + 'D'		
		--SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

		SET @controlNo = CAST(@id AS VARCHAR(10))+ 'D'		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

		SELECT 
			@ReceiverRemitCardNo = remitCardNo,
			@senderRemitCardNo = senderRemitCardNo,
			@sBranch = sBranch,
			@tAmt = tAmt,
			@rFullName = benefName,
			@sFullName = senderName,
			@serviceCharge = serviceCharge,
			@pAmt = tAmt,
			@cAmt = cAmt,
			@sAgentComm = sAgentComm,
			@mapCodeDom = am.mapCodeDom
		FROM globalCardServiceHistory gh WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON gh.sBranch = am.agentId
		WHERE gh.id = @id

		SELECT 
			@benefFirstName	= firstName,
			@benefMiddleName = middleName,
			@benefLastName	= lastName,
			@benefPhone		= phoneNoP,
			@benefEmail		= emailP,
			@benefCountry	= cm.countryName
		FROM kycMaster km WITH(NOLOCK)
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = km.countryP 
		WHERE remitCardNo = @ReceiverRemitCardNo

		SELECT 
			@customerId = customerId 
		FROM customerMaster WITH(NOLOCK) WHERE membershipId = @ReceiverRemitCardNo
		
		SELECT @pCountry = 'Nepal'
		SELECT @sCountry = 'Nepal'
		SELECT @pCountryId = '151'
		SELECT @sCountryId = '151'

			--## Start Bonus Point
		IF (ISNULL(@customerId, 0) <> 0)
		BEGIN
			SELECT @bonusSchemeId = bonusId
				  ,@maxPointsPerTxn = maxPointsPerTxn 
			FROM dbo.FNAGetBonusSetupDetail(@sCountryId, @sAgent, @sBranch, @pCountryId, '')
			SELECT @bonusUnit = unit, @bonusPoint = points FROM bonusOperationSetup WITH(NOLOCK) WHERE bonusSchemeId = @bonusSchemeId

			IF @bonusSchemeId IS NOT NULL
			BEGIN
				SET @txnBonusPoint = @tAmt * (CAST(@bonusPoint AS FLOAT)/CAST(@bonusUnit AS FLOAT))
				SET @txnBonusPoint = CASE WHEN @txnBonusPoint > ISNULL(@maxPointsPerTxn, 0) THEN ISNULL(@maxPointsPerTxn, 0) ELSE ISNULL(@txnBonusPoint, 0) END
				UPDATE customerMaster SET
					 bonusPointPending	  = ISNULL(bonusPointPending, 0) + @txnBonusPoint
				--	,bonusTxnCount		  = ISNULL(bonusTxnCount, 0) + 1
				--	,bonusTxnAmount		  = ISNULL(bonusTxnAmount, 0) + @tAmt
				WHERE customerId = @customerId
			END
		END

		BEGIN TRANSACTION
		INSERT INTO remitTran
		(
			controlNo,
			serviceCharge,
			sAgentComm,
			pMessage,
			sCountry,
			sSuperAgent,
			sSuperAgentName,
			sAgent,
			sAgentName,
			sBranch,
			sBranchName,

			collCurr,
			tAmt,
			cAmt,
			pAmt,
			payoutCurr,
			purposeOfRemit,
			sourceOfFund,
			tranStatus,
			payStatus,
			paymentMethod,
			createdDate,
			createdDateLocal,
			createdBy,
			approvedDate,
			approvedDateLocal,
			approvedBy,
			tranType,
			senderName,
			receiverName,
			bonusPoint,
			holdTranId,
			accountNo
		)
		SELECT
			@controlNoEncrypted,
			serviceCharge,
			sAgentComm,
			remarks,
			'Nepal',
			sSuperAgent,
			sSuperAgentName,
			sAgent,
			sAgentName,
			sBranch,
			sBranchName,
			
			collCurr,
			tAmt,
			cAmt,
			tAmt,
			payoutCurr,
			purposeOfRemit,
			sourceOfFund,
			'Payment',
			'Unpaid',
			'IME Remit Card',
			GETDATE(),
			DBO.FNAGetDateInNepalTZ(),
			@user,
			GETDATE(),
			DBO.FNAGetDateInNepalTZ(),
			@user,
			'D',
			senderName,
			benefName,
			@bonusPoint,
			@id,
			benefAcNo
		FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id		
		
		SET @tranId = SCOPE_IDENTITY()

		INSERT INTO tranReceivers
			(
				 tranId
				,customerId
				,membershipId
				,firstName
				,middleName
				,lastName1
				,country
				,[address]
				,email
				,homePhone
				,mobile
				,nativeCountry
				,idType
				,idNumber
			)
		SELECT 
			 @tranId
			,@customerId
			,@ReceiverRemitCardNo
			,@benefFirstName
			,@benefMiddleName
			,@benefLastName
			,@benefCountry
			,benefAddress
			,@benefEmail
			,@benefPhone
			,benefMobile
			,@benefCountry
			,benefIdType
			,benefIdNo
		FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id

		IF @senderRemitCardNo IS NOT NULL
		BEGIN					
			SELECT 
				@senderFirstName	= firstName,
				@senderMiddleName	= middleName,
				@senderLastName		= lastName,
				@senderPhone		= phoneNoP,
				@senderCountry		= cm.countryName,
				@senderEmail		= emailP
			FROM kycMaster km WITH(NOLOCK) 
			LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = km.countryP 
			WHERE RemitCardNo = @senderRemitCardNo

			SELECT 
				@customerId = customerId 
			FROM customerMaster WITH(NOLOCK) WHERE membershipId = @senderRemitCardNo

			INSERT INTO tranSenders
			(
				 tranId
				,customerId
				,membershipId
				,firstName
				,middleName
				,lastName1
				,country
				,[address]
				,email
				,homePhone
				,mobile
				,nativeCountry
				,idType
				,idNumber
			)
			SELECT 
				 @tranId
				,@customerId
				,@senderRemitCardNo
				,@senderFirstName
				,@senderMiddleName
				,@senderLastName
				,@senderCountry
				,senderAddress
				,@senderEmail
				,@senderPhone
				,senderMobile
				,@senderCountry
				,senderIdType
				,senderIdNo
			FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id
		END
		ELSE
		BEGIN
			INSERT INTO tranSenders
			(
				 tranId
				,firstName
				,[address]
				,mobile
				,idType
				,idNumber
				,ipAddress
				,dcInfo
			)
			SELECT 
				 @tranId
				,senderName
				,senderAddress
				,senderMobile
				,senderIdType
				,senderIdNo
				,ipAddress
				,dcInfo
			FROM globalCardServiceHistory WITH(NOLOCK) WHERE id = @id
		END

		EXEC SendMnPro_Account.dbo.[PROC_REMIT_DATA_UPDATE] 
					 @flag = 's'
					,@controlNo = @controlNo
					,@mapCode = @mapCodeDom
					,@sFirstName = @sFullName
					,@rFirstName = @rFullName
					,@cAmt = @cAmt
					,@pAmt = @pAmt
					,@serviceCharge = @serviceCharge
					,@sAgentComm = @sAgentComm
					,@pAgentComm = 0
					,@deliveryMethod = 'Bank Deposit'
					,@user = @user
					,@tranId = @tranId

		UPDATE globalCardServiceHistory SET tranStatus='Unpaid' WHERE id = @id
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION			
		EXEC [proc_errorHandler] 0, 'Transaction has been sent successfully, Waiting for approval. Please contact Head Office.', @controlNo		
	
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sBranch
END CATCH



GO
