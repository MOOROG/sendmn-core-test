USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendTranDomesticRegional]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_sendTranDomesticRegional] (
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)
	,@id				BIGINT		= NULL
	,@membershipId		VARCHAR(20) = NULL
	,@agentUniqueRefId	VARCHAR(30)	= NULL
	,@senderId			BIGINT		= NULL
	,@sMemId			VARCHAR(20)	= NULL
	,@sFirstName		VARCHAR(50) = NULL
	,@sMiddleName		VARCHAR(50) = NULL
	,@sLastName1		VARCHAR(50) = NULL
	,@sLastName2		VARCHAR(50)	= NULL
	,@sAddress			VARCHAR(200)= NULL
	,@sContactNo		VARCHAR(20)	= NULL
	,@sIdType			VARCHAR(50)	= NULL
	,@sIdNo				VARCHAR(30)	= NULL
	,@sEmail			VARCHAR(50)	= NULL
	
	,@receiverId		BIGINT		= NULL
	,@rMemId			VARCHAR(20)	= NULL
	,@rFirstName		VARCHAR(50)	= NULL
	,@rMiddleName		VARCHAR(50)	= NULL
	,@rLastName1		VARCHAR(50)	= NULL
	,@rLastName2		VARCHAR(50)	= NULL
	,@rAddress			VARCHAR(200)= NULL
	,@rContactNo		VARCHAR(20)	= NULL
	,@rIdType			VARCHAR(50)	= NULL
	,@rIdNo				VARCHAR(30)	= NULL
	,@remarks			VARCHAR(200)= NULL

	,@sBranch			INT			= NULL
	,@pBranch			INT			= NULL
	,@pBank				INT			= NULL
	,@pBankBranch		INT			= NULL
	,@accountNo			VARCHAR(30)	= NULL
	,@pCountry			VARCHAR(100)= NULL  
	,@pState			VARCHAR(100)= NULL  
	,@pDistrict			VARCHAR(100)= NULL	
	,@pLocation			INT			= NULL	
	,@collMode			VARCHAR(50)	= NULL
	,@collCurr			VARCHAR(3)	= NULL
	,@transferAmt		MONEY		= NULL
	,@serviceCharge		MONEY		= NULL
	,@handlingFee		MONEY		= NULL
	,@cAmt				MONEY		= NULL
	,@exRate			MONEY		= NULL
	,@pAmt				MONEY		= NULL
	,@payoutCurr		VARCHAR(3)	= NULL
	,@deliveryMethod	VARCHAR(50)	= NULL
	,@purpose			VARCHAR(100)= NULL
	,@sourceOfFund		VARCHAR(100)= NULL
	,@Occupation		VARCHAR(200)= NULL
	,@relationship		VARCHAR(100)= NULL
	,@controlNo			VARCHAR(20)	= NULL
	,@txnId				INT			= NULL
	,@enableApi			CHAR(1)		= NULL
	,@sDcInfo			VARCHAR(50)		= NULL
	,@sIpAddress		VARCHAR(50)		= NULL
	,@fromSendTrnTime	VARCHAR(20)		= NULL
	,@toSendTrnTime		VARCHAR(20)		= NULL
	,@txtPass			VARCHAR(50)		= NULL
)

AS

SET XACT_ABORT ON
BEGIN TRY
	DECLARE
		 @sCurrCostRate				DECIMAL(15, 9)
		,@sCurrHoMargin				DECIMAL(15, 9)
		,@pCurrCostRate				DECIMAL(15, 9)
		,@pCurrHoMargin				DECIMAL(15, 9)
		,@sCurrAgentMargin			DECIMAL(15, 9)
		,@pCurrAgentMargin			DECIMAL(15, 9)
		,@sCurrSuperAgentMargin		DECIMAL(15, 9)
		,@pCurrSuperAgentMargin		DECIMAL(15, 9)
		,@customerRate				DECIMAL(15, 9)
		,@sAgentSettRate			DECIMAL(15, 9)
		,@pDateCostRate				DECIMAL(15, 9)
		,@sAgentComm				MONEY
		,@sAgentCommCurrency		VARCHAR(3)
		,@sSuperAgentComm			MONEY
		,@sSuperAgentCommCurrency	VARCHAR(3)
		,@sHubComm					MONEY
		,@sHubCommCurrency			VARCHAR(3)
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@pHubComm					MONEY
		,@pHubCommCurrency			VARCHAR(3)
		,@pBankName					VARCHAR(100)
		,@pBankBranchName			VARCHAR(100)
		,@promotionCode				INT
		,@promotionType				INT		
		,@sSuperAgent				INT
		,@sSuperAgentName			VARCHAR(100)
		,@sAgent					INT
		,@sAgentName				VARCHAR(100)
		,@sBranchName				VARCHAR(100)
		,@sCountry					VARCHAR(100)
		,@pSuperAgent				INT
		,@pSuperAgentName			VARCHAR(100)
		,@pAgent					INT
		,@pAgentName				VARCHAR(100)
		,@pBranchName				VARCHAR(100)
		
		,@settlingAgent				INT				= NULL
		
		,@code						VARCHAR(50)
		,@userName					VARCHAR(50)
		,@password					VARCHAR(50)
	
	DECLARE 
		 @limitBal MONEY
		,@sendingCustType INT
		,@sendingCurrency VARCHAR(3)
		,@receivingCurrency VARCHAR(3)
		,@receivingCustType INT
	
	DECLARE 			 
		 @sendingCount		INT
		,@sendingAmount		MONEY
		,@receivingCount	INT
		,@receivingAmount	MONEY
		,@tranCount			INT
		,@tranAmount		MONEY
		,@period			INT
		,@nextAction		INT
	
	DECLARE 
		 @pCountryId		INT
		,@deliveryMethodId	INT
		,@agentType			INT
		,@actAsBranchFlag	CHAR(1)
		,@approveFlag		CHAR(1)
		,@sCountryId		VARCHAR(30)
		,@sFullName			VARCHAR(200)
		,@rFullName			VARCHAR(200)
			
	DECLARE @controlNoEncrypted VARCHAR(20)	
	IF @flag = 'i'			
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
		IF (
			(ISNULL(@pLocation, 0) = 0 and ISNULL(@deliveryMethod, '')='Cash Payment')
			OR ISNULL(@deliveryMethod, '') = ''
			OR ISNULL(@transferAmt,0) = 0
			OR @sFirstName IS NULL
			OR @rFirstName IS NULL
			)
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END

		SET @controlNo = '7' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 9) + 'B'
		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		
		IF EXISTS(SELECT 'X' FROM dbo.controlNoListDomestic WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Technical error occured. Please try again.', NULL
			RETURN
		END
		
		IF (@pBranch IS NOT NULL)
		BEGIN
			SELECT @pAgent = parentId, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
			SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		END
		IF (@pBankBranch IS NOT NULL)
		BEGIN
			SELECT @pBank = parentId, @pBankBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
			SELECT @pBankName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBank
		END
		SET @sCountry = 'Nepal'
		SET @sCountryId = '151'
		SET @pCountry = 'Nepal'		
		SET @pCountryId = '151'			
		
		IF (@sBranch IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END
		
		SELECT @agentType = agentType, @sAgent = parentId, @sBranchName = agentName, @sCountry = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
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
		
	
		SELECT @collCurr = 'NPR', @payoutCurr = 'NPR'				
		SELECT @sendingCurrency = @collCurr
		SELECT @receivingCurrency = @payoutCurr
		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
		DECLARE @currentDate DATETIME 
		SET @currentDate = dbo.FNAGetDateInNepalTz()
		IF EXISTS(SELECT 'X' FROM remitTran trn WITH(NOLOCK)
					LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE 
							sen.firstName = @sFirstName
						AND ISNULL(sen.middleName, '') = ISNULL(@sMiddleName, '') 
						AND ISNULL(sen.lastName1, '') = ISNULL(@sLastName1, '')
						AND ISNULL(sen.lastName2, '') = ISNULL(@sLastName2, '')
						AND rec.firstName = @rFirstName
						AND ISNULL(rec.middleName, '') = ISNULL(@rMiddleName, '')
						AND ISNULL(rec.lastName1, '') = ISNULL(@rLastName1, '')
						AND ISNULL(rec.lastName2, '') = ISNULL(@rLastName2, '')
						AND trn.tAmt = @transferAmt
						AND trn.pLocation = @pLocation
						AND DATEDIFF(MI, trn.createdDate, @currentDate) <= 5
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Similar Transaction Found', NULL
			RETURN
		END
		
		IF @transferAmt > @limitBal
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
				AND ISNULL(minLimitAmt, 0) > @transferAmt
				AND ISNULL(maxLimitAmt, 0) < @transferAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN	
			EXEC [proc_errorHandler] 2, 'Agent Sending limit is exceeded.', NULL
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
				AND ISNULL(minLimitAmt, 0) <= @transferAmt
				AND ISNULL(maxLimitAmt, 0) >= @transferAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN		
			EXEC [proc_errorHandler] 3, 'Country Sending limit is not defined or exceeds.', NULL
			RETURN
		END					

		SELECT @deliveryMethodId = serviceTypeId 
			FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
			
			SET @pAgentComm = 0
			SET @pSuperAgentComm = 0
		END
		ELSE
		BEGIN
			SELECT
				  @pAgentComm		= ISNULL(pAgentComm, 0)
				 ,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
			FROM dbo.FNAGetDomesticPayCommForCancel(@sBranch, @pLocation, @deliveryMethodId, @transferAmt)
		END
		
		SELECT 
			 @serviceCharge		= ISNULL(serviceCharge, 0)
			,@sAgentComm		= ISNULL(sAgentComm, 0)
			,@sSuperAgentComm	= ISNULL(ssAgentComm, 0)
		FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @transferAmt)
		
		SELECT @sSuperAgentCommCurrency = 'NPR', @sAgentCommCurrency = 'NPR', @pAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR'
		IF (@cAmt IS NULL)
		BEGIN
			SET @cAmt = @transferAmt + @serviceCharge	
		END
		
		DECLARE @iCollectAmount MONEY
		SET @iCollectAmount = @transferAmt + @serviceCharge
		IF(@cAmt <> @iCollectAmount)
		BEGIN
			EXEC proc_errorHandler 1, 'Collection Amount not match', NULL
			RETURN
		END
		IF @transferAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END
		
		SET @sFullName = @sFirstName + ISNULL( ' ' + @sMiddleName, '') + ISNULL( ' ' + @sLastName1, '') + ISNULL( ' ' + @sLastName2, '')
		SET @rFullName = @rFirstName + ISNULL( ' ' + @rMiddleName, '') + ISNULL( ' ' + @rLastName1, '') + ISNULL( ' ' + @rLastName2, '')

		BEGIN TRANSACTION
			
			UPDATE creditLimit SET 
				todaysSent = ISNULL(todaysSent, 0) + ISNULL(@cAmt, 0) 
			WHERE agentId = @settlingAgent

			IF (ISNULL(@senderId, 0) <> 0)
			BEGIN
				DECLARE @maxPointsPerTxn INT, @bonusSchemeId INT, @bonusUnit INT, @bonusPoint INT
				SELECT @bonusSchemeId = bonusId
					  ,@maxPointsPerTxn = maxPointsPerTxn 
				FROM dbo.FNAGetBonusSetupDetail(@sCountryId, @sAgent, @sBranch, @pCountryId, @pAgent)
				SELECT @bonusUnit = unit, @bonusPoint = points FROM bonusOperationSetup WITH(NOLOCK) WHERE bonusSchemeId = @bonusSchemeId

				IF @bonusSchemeId IS NOT NULL
				BEGIN
					DECLARE @txnBonusPoint FLOAT
					SET @txnBonusPoint = @pAmt * (CAST(@bonusPoint AS FLOAT)/CAST(@bonusUnit AS FLOAT))
					SET @txnBonusPoint = CASE WHEN @txnBonusPoint > ISNULL(@maxPointsPerTxn, 0) THEN ISNULL(@maxPointsPerTxn, 0) ELSE ISNULL(@txnBonusPoint, 0) END
					UPDATE customerMaster SET
						 bonusPointPending = ISNULL(bonusPointPending, 0) + @txnBonusPoint
						--,bonusTxnCount		  = ISNULL(bonusTxnCount, 0) + 1
						--,bonusTxnAmount		  = ISNULL(bonusTxnAmount, 0) + @pAmt
					WHERE customerId = @senderId
				END
				-- ## update total send & activate txn date
				UPDATE customerMaster SET 
					--sendTxn = ISNULL(sendTxn,0)+1,
					firstTxnDate = ISNULL(firstTxnDate,GETDATE())
				WHERE customerId = @senderId 
			END			
			INSERT INTO remitTran(
				 controlNo
				,sCurrCostRate
				,sCurrHoMargin
				,pCurrCostRate
				,pCurrHoMargin
				,sCurrAgentMargin
				,pCurrAgentMargin
				,sCurrSuperAgentMargin
				,pCurrSuperAgentMargin
				,customerRate
				,sAgentSettRate
				,pDateCostRate
				,serviceCharge
				,handlingFee
				,sAgentComm
				,sAgentCommCurrency
				,sSuperAgentComm
				,sSuperAgentCommCurrency
				,sHubComm
				,sHubCommCurrency
				,pAgentComm
				,pAgentCommCurrency
				,pSuperAgentComm
				,pSuperAgentCommCurrency
				,pHubComm
				,pHubCommCurrency
				,promotionCode
				,promotionType
				,pMessage
				,sSuperAgent
				,sSuperAgentName
				,sAgent
				,sAgentName
				,sBranch
				,sBranchName
				,sCountry
				,pSuperAgent
				,pSuperAgentName
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,pCountry
				,pState
				,pDistrict
				,pLocation
				,paymentMethod
				,pBank
				,pBankName
				,pBankBranch
				,pBankBranchName
				,accountNo
				,collMode
				,collCurr
				,tAmt
				,cAmt
				,pAmt
				,payoutCurr
				,relWithSender
				,purposeOfRemit
				,sourceOfFund
				,tranStatus
				,payStatus
				,createdDate
				,createdDateLocal
				,createdBy	
				,tranType		
				,senderName
				,receiverName	
				,bonusPoint	
				,approvedDate
				,approvedDateLocal
				,approvedBy
			)				
						
			SELECT
				 @controlNoEncrypted
				,@sCurrCostRate
				,@sCurrHoMargin
				,@pCurrCostRate
				,@pCurrHoMargin
				,@sCurrAgentMargin
				,@pCurrAgentMargin
				,@sCurrSuperAgentMargin
				,@pCurrSuperAgentMargin
				,@customerRate
				,@sAgentSettRate
				,@pDateCostRate
				,@serviceCharge
				,@handlingFee
				,@sAgentComm
				,@sAgentCommCurrency
				,@sSuperAgentComm
				,@sSuperAgentCommCurrency
				,@sHubComm
				,@sHubCommCurrency
				,@pAgentComm
				,@pAgentCommCurrency
				,@pSuperAgentComm
				,@pSuperAgentCommCurrency
				,@pHubComm
				,@pHubCommCurrency
				,@promotionCode
				,@promotionType
				,@remarks
				,@sSuperAgent
				,@sSuperAgentName
				,@sAgent
				,@sAgentName
				,@sBranch
				,@sBranchName
				,@sCountry
				,@pSuperAgent
				,@pSuperAgentName
				,@pAgent
				,@pAgentName
				,@pBranch
				,@pBranchName
				,@pCountry
				,@pState
				,@pDistrict
				,@pLocation
				,@deliveryMethod
				,@pBank
				,@pBankName
				,@pBankBranch
				,@pBankBranchName
				,@accountNo
				,@collMode
				,@collCurr
				,@transferAmt
				,@cAmt
				,@pAmt
				,@payoutCurr
				,@relationship
				,@purpose
				,@sourceOfFund
				,'Payment'
				,'Unpaid'
				,dbo.FNAGetDateInNepalTZ()
				,dbo.FNAGetDateInNepalTZ()
				,@user
				,'D'
				,@sFullName
				,@rFullName
				,@txnBonusPoint
				,dbo.FNAGetDateInNepalTZ()
				,dbo.FNAGetDateInNepalTZ()
				,@user
				
			SET @id = SCOPE_IDENTITY()	
			
			IF (ISNULL(@senderId, 0) <> 0)
			BEGIN
				INSERT INTO tranSenders(
					 tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2
					,country,[address],[state],district,email,mobile
					,dob,idPlaceOfIssue,idType,idNumber,dcInfo,ipAddress,occupation
				)
				SELECT top 1
					 @id,@senderId,membershipId,@sFirstName,@sMiddleName,@sLastName1,@sLastName2
					,''--pCountry
					,@sAddress
					,''--pZone
					,''--pDistrict
					,@sEmail,@sContactNo
					,''--dobEng
					,placeOfIssue,@sIdType,@sIdNo,@sDcInfo,@sIpAddress,@occupation
				FROM customerMaster c WITH(NOLOCK)
				WHERE c.customerId = @senderId	
			END
			ELSE
			BEGIN
				INSERT INTO tranSenders(
					 tranId,membershipId,firstName,middleName,lastName1,lastName2
					,country,[address],[state],zipCode,city,email,homePhone,workPhone,mobile,nativeCountry
					,dob,placeOfIssue,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,dcInfo,ipAddress,occupation
				)
				
				SELECT
					 @id,@sMemId,@sFirstName,@sMiddleName,@sLastName1,@sLastName2
					,'Nepal',@sAddress,NULL,NULL,NULL,@sEmail,NULL,NULL,@sContactNo,NULL
					,NULL,NULL,@sIdType,@sIdNo,NULL,NULL,NULL,@sDcInfo,@sIpAddress,@occupation
			END
			IF (ISNULL(@receiverId, 0) <> 0)
			BEGIN
				INSERT INTO tranReceivers(
					 tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2
					,country,[address],[state],district,email,mobile
					,dob,idPlaceOfIssue,idType,idNumber
				)
				SELECT  top 1
					 @id,@receiverId,membershipId,@rFirstName,@rMiddleName,@rLastName1,@rLastName2
					,''--pCountry
					,@rAddress
					,''--pZone
					,''--pDistrict
					,email,@rContactNo 
					,''--dobEng
					,c.placeOfIssue,@rIdType,@rIdNo		
				FROM customerMaster c WITH(NOLOCK)
				WHERE c.customerId = @receiverId	
			END
			ELSE
			BEGIN
				INSERT INTO tranReceivers(
					 tranId,membershipId,firstName,middleName,lastName1,lastName2
					,country,[address],[state],zipCode,city,email,homePhone,workPhone,mobile,nativeCountry
					,dob,placeOfIssue,idType,idNumber,idPlaceOfIssue,issuedDate,validDate
				)
				SELECT
					 @id,@rMemId,@rFirstName,@rMiddleName,@rLastName1,@rLastName2
					,'Nepal',@rAddress,NULL,NULL,NULL,NULL,NULL,NULL,@rContactNo,NULL
					,NULL,NULL,@rIdType,@rIdNo,NULL,NULL,NULL
			END
			
			INSERT INTO controlNoListDomestic(controlNo)
			SELECT @controlNo
						
			DECLARE @mapCodeDom VARCHAR(20)
			SELECT @mapCodeDom = mapCodeDom FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
			
			IF NOT EXISTS(SELECT 'X' FROM SendMnPro_Account.dbo.REMIT_TRN_LOCAL WITH(NOLOCK) WHERE TRN_REF_NO = dbo.encryptDbLocal(@controlNo))
			BEGIN
				EXEC SendMnPro_Account.dbo.[PROC_REMIT_DATA_UPDATE] 
						 @flag = 's'
						,@controlNo = @controlNo
						,@mapCode = @mapCodeDom
						,@sFirstName = @sFirstName
						,@sMiddleName = @sMiddleName
						,@sLastName1 = @sLastName1
						,@sLastName2 = @sLastName2
						,@rFirstName = @rFirstName
						,@rMiddleName = @rMiddleName
						,@rLastName1 = @rLastName1
						,@rLastName2 = @rLastName2
						,@cAmt = @cAmt
						,@pAmt = @pAmt
						,@serviceCharge = @serviceCharge
						,@sAgentComm = @sAgentComm
						,@pAgentComm = @pAgentComm
						,@pBank = @pBank
						,@pBankName = @pBankName
						,@pBankBranch = @pBankBranch
						,@deliveryMethod = @deliveryMethod
						,@user = @user
						,@tranId = @id
			END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
				
		EXEC [proc_errorHandler] 0, 'Transaction has been sent successfully', @controlNo
		
		IF @remarks IS NOT NULL
		BEGIN
			INSERT INTO tranModifyLog(tranId,[message],createdBy,createdDate,MsgType,[status])
			SELECT @id,@remarks,@user,dbo.FNAGetDateInNepalTZ(),'','Not Resolved'
		END
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
