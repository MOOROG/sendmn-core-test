USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendTranDomesticHo]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_sendTranDomesticHo] (
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
	,@pCountry			VARCHAR(100)= NULL  --payout Country
	,@pState			VARCHAR(100)= NULL  --payout State
	,@pDistrict			VARCHAR(100)= NULL	--payout District
	,@pLocation			INT			= NULL	--payout Location
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

	,@complianceAction	CHAR(1)			= NULL
	,@compApproveRemark VARCHAR(200)	= NULL
	,@markSuspicious	CHAR(1)			= NULL 
	,@txnbatchId		VARCHAR(50)		= NULL
	,@txnDocFolder		VARCHAR(50)		= NULL
	,@sDOB				VARCHAR(25)		= NULL
	,@sIdIssuedDate		VARCHAR(25)		= NULL
	,@sIdValidDate		VARCHAR(25)		= NULL
	,@sDOBBs			VARCHAR(25)		= NULL
	,@sIdIssuedDateBs	VARCHAR(25)		= NULL
	,@sIdValidDateBs	VARCHAR(25)		= NULL
	,@sIdIssuedPlace	VARCHAR(50)		= NULL
	,@sCustCardId		VARCHAR(25)		= NULL
	,@sGender			VARCHAR(25)		= NULL
	,@sMotherFatherName	VARCHAR(25)		= NULL
	,@sAmountThreshold	MONEY			= NULL
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
		,@sCountryId				VARCHAR(30)
		,@msg						VARCHAR(200)
		,@senderName				VARCHAR(100)
		,@receiverName				VARCHAR(100)

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
		,@currentDate		DATETIME		
		,@sFullName			VARCHAR(200)
		,@rFullName			VARCHAR(200)
			
	DECLARE @controlNoEncrypted VARCHAR(20)
	
	DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20), @result VARCHAR(MAX)
	DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)

	SET @senderName = @sFirstName + ISNULL(' ' + @sMiddleName, '') + ISNULL(' ' + @sLastName1, '') + ISNULL(' ' + @sLastName2, '')
	SET @receiverName = @rFirstName + ISNULL(' ' + @rMiddleName, '') + ISNULL(' ' + @rLastName1, '') + ISNULL(' ' + @rLastName2, '')

	IF @flag = 'm'				
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM customers WITH(NOLOCK) WHERE membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this Membership Id not found', NULL
		END
		ELSE IF EXISTS(SELECT 'X' FROM customers WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND ISNULL(isBlackListed, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'This customer is blacklisted. Cannot proceed for transaction.', NULL
		END
		ELSE
		BEGIN
			EXEC proc_errorHandler 0, 'Customer Found', NULL
		END
		
		SELECT 
			 cust.*
			,ci.idType
			,ci.idNumber
		FROM customers cust WITH(NOLOCK) 
		LEFT JOIN customerIdentity ci WITH(NOLOCK) ON cust.customerId = ci.customerId AND ci.isPrimary = 'Y' AND ISNULL(ci.isDeleted, 'N') <> 'Y' AND ISNULL(ci.isActive, 'Y') = 'Y'
		WHERE cust.membershipId = @membershipId AND ISNULL(cust.isDeleted, 'N') <> 'Y'
		
		RETURN
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		UPDATE remitTran SET
			 modifiedDate = GETDATE()
			,modifiedDateLocal = DBO.FNADateFormatTZ(GETDATE(), @user)
			,modifiedBy = @user
		WHERE id = @id
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM remitTran WITH(NOLOCK) WHERE id = @id
	END
	
	ELSE IF @flag = 'v'		
	BEGIN
		--1. Find Sender Information
		IF (@sBranch IS NULL)
			SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		SELECT @agentType = agentType, @sAgent = parentId, @sBranchName = agentName, @sCountry = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		--Check for Branch or Agent Acting as Branch
		IF @agentType = 2903	
		BEGIN
			SET @sAgent = @sBranch
		END
		SELECT DISTINCT @sSuperAgent = parentId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		SELECT DISTINCT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent

		--2. Find Settling Agent
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		
		--3. Check Limit starts		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
		IF @transferAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END
		EXEC proc_errorHandler 0, 'Verification Successful', NULL
	END
	/*
	IF @flag='validate'
	BEGIN

		SELECT @pCountry = 'Nepal'
		SELECT @sCountry = 'Nepal'
		SELECT @pCountryId = '151'
		SELECT @sCountryId = '151'

	DECLARE @cisMasterId INT, @validationRes VARCHAR(50), @validationFinalRes VARCHAR(100)
	DECLARE @cisMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
	DECLARE @requiredField TABLE (rowId INT IDENTITY(1,1), criteriaId INT,controlId VARCHAR(50),errorMsg VARCHAR(200))
	DECLARE @cisValidationResult TABLE (rowId INT IDENTITY(1,1), cisDetailId VARCHAR(20))
	

	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
	-------Required Validation Check Begin----------

		
		INSERT @cisMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetIdRuleMaster(@sBranch, @pCountryId, NULL, @pBranch, NULL, @senderId, @receiverId)
		SELECT @totalRows = COUNT(*) FROM @cisMasterRec

		IF EXISTS(SELECT 'X' FROM @cisMasterRec)
		BEGIN
			
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				
				SELECT @cisMasterId = masterId FROM @cisMasterRec WHERE rowId = @count
				
				--PRINT CAST (@count AS VARCHAR)+' count'
				--PRINT CAST (@cisMasterId AS VARCHAR)+' cisMasterId'

				EXEC proc_idRuleDetail 
				 @user				= @user
				,@tranId			= @id
				,@tAmt				= @transferAmt
				,@senId				= @senderId				
				,@masterId			= @cisMasterId	
				,@paymentMethod		= @deliveryMethodId
				,@checkingFor		= 'v'				
				,@senderId			= @sIdNo
				,@senderName		= @senderName
				,@senderMobile		= @sContactNo
				,@result			= @validationRes OUTPUT
				
				SET @count = @count + 1

				IF @validationRes IS NOT NULL
				INSERT INTO @cisValidationResult
					SELECT DISTINCT VALUE from dbo.udf_Split(@validationRes,',') 

			END
		END

		--SELECT * FROM @cisValidationResult

		IF EXISTS (SELECT 'X' FROM @cisValidationResult)
		BEGIN			
				SET @msg = 'Field validation failed.'				
				SELECT 101 errorCode, @msg msg, NULL id
				
				SELECT 
				criteriaId
				,controlId
				,errorMsg 
				FROM cisFieldMapping WITH(NOLOCK) where criteriaId in(
					SELECT DISTINCT criteriaId FROM cisCriteria c WITH(NOLOCK) INNER JOIN @cisValidationResult tmpc
				ON c.cisDetailId = tmpc.cisDetailId)
				AND ISNULL(scope,'D')='D' AND ISNULL(IsActive,'Y')='Y'
				ORDER BY ISNULL(controlRankID,0)
				--SELECT DISTINCT * FROM @requiredField
			RETURN
		END 
		
		-------Required Validation Check End----------
		EXEC [proc_errorHandler] 0, 'Compliance Validation Successful.', NULL

	END
	ELSE IF @flag = 'vt'				--Verify Transaction
	BEGIN
		
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END
		
		IF (@pBranch IS NOT NULL)
		BEGIN
			SELECT @pAgent = parentId, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
			SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		END
		SELECT @pCountry = 'Nepal'
		SELECT @sCountry = 'Nepal'
		SELECT @pCountryId = '151'
		SELECT @sCountryId = '151'
		
		--3. Check Limit starts
		SELECT @collCurr = 'NPR', @payoutCurr = 'NPR'				
		SELECT @sendingCurrency = @collCurr
		SELECT @receivingCurrency = @payoutCurr
		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
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
						AND trn.serviceCharge = @serviceCharge
						AND trn.cAmt = @cAmt
						AND DATEDIFF(MI, trn.createdDate, @currentDate) <= 5)
		BEGIN
			EXEC proc_errorHandler 1, 'Similar Transaction Found', NULL
			RETURN
		END
		
		IF @transferAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
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

		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
				
				-------Compliance Check Begin----------

		--DECLARE @result VARCHAR(MAX)
		INSERT @csMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetComplianceRuleMaster(@sBranch, @pCountryId, NULL, @pBranch, NULL, @senderId, @receiverId)
		SELECT @totalRows = COUNT(*) FROM @csMasterRec

		DECLARE @denyTxn CHAR(1) = 'N'
		IF EXISTS(SELECT 'X' FROM @csMasterRec)
		BEGIN
			
			DELETE FROM remitTranComplianceTemp WHERE agentRefId = @agentUniqueRefId
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
				
				EXEC proc_complianceRuleDetail 
				 @user				= @user
				,@tranId			= @id
				,@tAmt				= @transferAmt
				,@senId				= @senderId
				,@benId				= @receiverId
				,@beneficiaryName	= @receiverName
				,@beneficiaryMobile = @rContactNo
				,@benAccountNo		= @accountNo
				,@masterId			= @csMasterId
				,@paymentMethod		= @deliveryMethodId
				,@checkingFor		= 'v'
				,@agentRefId		= @agentUniqueRefId
				,@result			= @complianceRes OUTPUT
				,@senderId			= @sIdNo
				,@senderName		= @senderName
				,@senderMobile		= @sContactNo
				
				SET @compFinalRes = ISNULL(@compFinalRes, '') + ISNULL(@complianceRes, '')
				
				IF @complianceRes = 'M' AND ISNULL(@complianceAction, '') <> 'B' AND ISNULL(@complianceAction, '') <> 'C'
					SET @complianceAction = 'M'
				IF @complianceRes = 'C' AND ISNULL(@complianceAction, '') <> 'B'
					SET @complianceAction = 'C'
				IF @complianceRes = 'B'
					SET @complianceAction = 'B'
				SET @count = @count + 1
			END
			
		END
		
		IF(ISNULL(@compFinalRes, '') <> '')
		BEGIN			
			IF(@compFinalRes <> '')
			BEGIN
				IF @complianceAction = 'B'
					SET @msg = 'WARNING!!! This customer is under compliance'
				ELSE IF @complianceAction = 'M'
				BEGIN
					SET @compApproveRemark = ISNULL(@compApproveRemark, 'Marked for Compliance')
					SET @msg = 'WARNING!!! This customer is under compliance'
				END
				ELSE
					SET @msg = 'WARNING!!! This customer is under compliance'
				
				SELECT 101 errorCode, @msg msg, @complianceAction id, @compApproveRemark compApproveRemark
				--SELECT 101 errorCode, @msg msg, 'B' id, @compApproveRemark compApproveRemark
				--EXEC proc_sendPageLoadData @flag = 'compliance', @user = @user, @agentRefId = @agentUniqueRefId
			END
			RETURN
		END 

		-------Compliance Check End----------
			
		EXEC [proc_errorHandler] 0, 'Transaction verification Successful', NULL

		--*****Check For Same Name*****
		SELECT tranId = rt.id, senderName, sIdType = ISNULL(sdv.detailTitle,sen.IdType), sIdNo = sen.idNumber, pAmt, pCountry 
		FROM vwRemitTran rt WITH(NOLOCK)
		INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
		WHERE senderName = @senderName AND rt.createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
		
		--*****Check For Same Id*****
		SELECT tranId = rt.id, senderName, sIdType = ISNULL(sdv.detailTitle,sen.IdType), sIdNo = sen.idNumber, pAmt, pCountry 
		FROM vwRemitTran rt WITH(NOLOCK)
		INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId 
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
		WHERE idType = @sIdType AND idNumber = @sIdNo AND rt.createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
	
	END
	*/

	IF @flag = 'vt'
	BEGIN
		
		IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @sMemId 
					AND ISNULL(isDeleted, 'N') <> 'Y' AND approvedDate IS NULL)
		BEGIN
			IF ISNULL(@sAmountThreshold,0) <> 0 AND ISNULL(@transferAmt,0)<>0
			BEGIN
				IF @transferAmt >= @sAmountThreshold
				BEGIN					
					SELECT 1 errorCode,'Customer with this membership ID is not approved yet. Unapproved customer cannot send money greater than or equals to threshold amount using customer card. Please contact head office.' msg,NULL id,'custenroll' vtype
					RETURN;
				END
			END
		END

		IF @sIdNo IS NULL AND @sContactNo IS NULL
		BEGIN
			SELECT 0 errorCode,'Transaction verification Successful.' msg,NULL id,'compliance' vtype
			RETURN
		END

		SELECT @pCountry = 'Nepal'
		SELECT @sCountry = 'Nepal'
		SELECT @pCountryId = '151'
		SELECT @sCountryId = '151'
		
		DECLARE @cisMasterId INT, @validationRes VARCHAR(50), @validationFinalRes VARCHAR(100)
		DECLARE @cisMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
		DECLARE @requiredField TABLE (rowId INT IDENTITY(1,1), criteriaId INT,controlId VARCHAR(50),errorMsg VARCHAR(200))
		DECLARE @cisValidationResult TABLE (rowId INT IDENTITY(1,1), cisDetailId VARCHAR(20))

		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		-------Required Validation Check Begin----------
		
		INSERT @cisMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetIdRuleMaster(@sBranch, @pCountryId, NULL, @pBranch, NULL, @senderId, @receiverId)
		SELECT @totalRows = COUNT(*) FROM @cisMasterRec

		IF EXISTS(SELECT 'X' FROM @cisMasterRec)
		BEGIN
			
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				
				SELECT @cisMasterId = masterId FROM @cisMasterRec WHERE rowId = @count				
			
				EXEC proc_idRuleDetail 
				 @user				= @user
				,@tranId			= @id
				,@tAmt				= @transferAmt
				,@senId				= @senderId				
				,@masterId			= @cisMasterId	
				,@paymentMethod		= @deliveryMethodId
				,@checkingFor		= 'v'				
				,@senderId			= @sIdNo
				,@senderName		= @senderName
				,@senderMobile		= @sContactNo
				,@result			= @validationRes OUTPUT
				
				SET @count = @count + 1

				IF @validationRes IS NOT NULL
				INSERT INTO @cisValidationResult
					SELECT DISTINCT VALUE from dbo.udf_Split(@validationRes,',') 

			END
		END

		IF EXISTS (SELECT 'X' FROM @cisValidationResult)
		BEGIN
			DECLARE @FieldValue TABLE (controlId VARCHAR(50) UNIQUE, value VARCHAR(200))
			INSERT @FieldValue
			SELECT 'sof', @sourceOfFund UNION ALL
			SELECT 'por', @purpose UNION ALL
			SELECT 'relWithSender', @relationship UNION ALL
			SELECT 'sIdType', @sIdType UNION ALL
			SELECT 'sIdNo', @sIdNo UNION ALL
			SELECT 'txtSendIdValidDate', @sIdValidDate UNION ALL
			SELECT 'txtSendDOB', @sDOB UNION ALL			
			SELECT 'occupation', @Occupation UNION ALL
			SELECT 'sIdIssuedPlace', @sIdIssuedPlace
			DELETE FROM @FieldValue WHERE NULLIF(LTRIM(value), '') IS NULL 
			OR (value = 'select' AND controlId IN ('sof', 'por', 'relWithSender' , 'occupation','sIdIssuedPlace'))
			--@sIdType
			
			IF '1301' = @sIdType
				DELETE FROM @FieldValue WHERE  controlId = 'txtSendIdValidDate'
			
			SELECT 
				cm.criteriaId
				,cm.controlId
				,errorMsg 
			INTO #final
			FROM cisFieldMapping cm WITH(NOLOCK)
			INNER JOIN cisCriteria c WITH(NOLOCK) ON cm.criteriaId = c.criteriaId
			INNER JOIN @cisValidationResult tmpc ON c.cisDetailId = tmpc.cisDetailId
			LEFT JOIN @FieldValue fv ON cm.controlId = fv.controlId 
			WHERE ISNULL(cm.scope,'B')='B' AND ISNULL(cm.IsActive,'Y')='Y' 
			AND fv.controlId IS NULL AND cm.controlId IS NOT NULL
			ORDER BY ISNULL(controlRankID,0)	

			IF '1301' = @sIdType
				DELETE FROM #final WHERE  controlId = 'txtSendIdValidDate'

			IF EXISTS(SELECT 'X' FROM #final)
			BEGIN
				SET @msg = 'Field validation failed.'								
				SELECT 101 errorCode, @msg msg, NULL id,'idrule' vtype
				SELECT DISTINCT * FROM #final
				RETURN
			END			
						
		END 

		IF @user IS NULL
		BEGIN			
			SELECT 1 errorCode,'Your session has expired. Cannot send transaction.' msg,NULL id,'compliance' vtype
			RETURN
		END
		
		IF (@pBranch IS NOT NULL)
		BEGIN
			SELECT @pAgent = parentId, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
			SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		END
		
		
		--3. Check Limit starts
		SELECT @collCurr = 'NPR', @payoutCurr = 'NPR'				
		SELECT @sendingCurrency = @collCurr
		SELECT @receivingCurrency = @payoutCurr
		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
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
						AND trn.serviceCharge = @serviceCharge
						AND trn.cAmt = @cAmt
						AND DATEDIFF(MI, trn.createdDate, @currentDate) <= 5)
		BEGIN			
			SELECT 1 errorCode,'Similar Transaction Found.' msg,NULL id,'compliance' vtype
			RETURN
		END
		
		IF @transferAmt > @limitBal
		BEGIN			
			SELECT 1 errorCode,'Transfer amount exceeds Limit. Please, Check your available limit.' msg,NULL id,'compliance' vtype
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
			SELECT 3 errorCode,'Country Sending limit is not defined or exceeds.' msg,NULL id,'compliance' vtype
			RETURN
		END

		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
				
		-------Compliance Check Begin----------

		
		INSERT @csMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetComplianceRuleMaster(@sBranch, @pCountryId, NULL, @pBranch, NULL, @senderId, @receiverId)
		SELECT @totalRows = COUNT(*) FROM @csMasterRec

		DECLARE @denyTxn CHAR(1) = 'N'
		IF EXISTS(SELECT 'X' FROM @csMasterRec)
		BEGIN
			DELETE FROM remitTranComplianceTemp WHERE agentRefId = @agentUniqueRefId
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
				
				EXEC proc_complianceRuleDetail 
				 @user				= @user
				,@tranId			= @id
				,@tAmt				= @transferAmt
				,@senId				= @senderId
				,@benId				= @receiverId
				,@beneficiaryName	= @receiverName
				,@beneficiaryMobile = @rContactNo
				,@benAccountNo		= @accountNo
				,@masterId			= @csMasterId
				,@paymentMethod		= @deliveryMethodId
				,@checkingFor		= 'v'
				,@agentRefId		= @agentUniqueRefId
				,@result			= @complianceRes OUTPUT
				,@senderId			= @sIdNo
				,@senderName		= @senderName
				,@senderMobile		= @sContactNo
				
				SET @compFinalRes = ISNULL(@compFinalRes, '') + ISNULL(@complianceRes, '')
				
				IF @complianceRes = 'M' AND ISNULL(@complianceAction, '') <> 'B' AND ISNULL(@complianceAction, '') <> 'C'
					SET @complianceAction = 'M'
				IF @complianceRes = 'C' AND ISNULL(@complianceAction, '') <> 'B'
					SET @complianceAction = 'C'
				IF @complianceRes = 'B'
					SET @complianceAction = 'B'
				SET @count = @count + 1
			END
		END
		
		IF(ISNULL(@compFinalRes, '') <> '')
		BEGIN			
			IF(@compFinalRes <> '')
			BEGIN
				IF @complianceAction = 'B'
					SET @msg = 'WARNING!!! This customer is under compliance'
				ELSE IF @complianceAction = 'M'
				BEGIN
					SET @compApproveRemark = ISNULL(@compApproveRemark, 'Marked for Compliance')
					SET @msg = 'WARNING!!! This customer is under compliance'
				END
				ELSE
					SET @msg = 'WARNING!!! This customer is under compliance'
				
				--SELECT 101 errorCode, @msg msg, @complianceAction id, @compApproveRemark compApproveRemark
				SELECT 101 errorCode,@msg msg, @complianceAction id, @compApproveRemark compApproveRemark,'compliance' vtype

			END
			RETURN
		END 

		-------Compliance Check End----------
			
		--EXEC [proc_errorHandler] 0, 'Transaction verification Successful', NULL
		SELECT 0 errorCode,'Transaction verification Successful.' msg,NULL id,'compliance' vtype

		--*****Check For Same Name*****
		SELECT tranId = rt.id, senderName, sIdType = ISNULL(sdv.detailTitle,sen.IdType), sIdNo = sen.idNumber, pAmt, pCountry 
		FROM vwRemitTran rt WITH(NOLOCK)
		INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
		WHERE senderName = @senderName AND sBranch = @sBranch AND rt.createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
		
		--*****Check For Same Id*****
		SELECT tranId = rt.id, senderName, sIdType = ISNULL(sdv.detailTitle,sen.IdType), sIdNo = sen.idNumber, pAmt, pCountry 
		FROM vwRemitTran rt WITH(NOLOCK)
		INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId 
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
		WHERE idType = @sIdType AND idNumber = @sIdNo AND sBranch = @sBranch AND rt.createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'


	END

	ELSE IF @flag = 'i'			--Local DB Insert
	BEGIN
		--Field Validation
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
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
		--End Field Validation		
		SET @controlNo = '777' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '00000000', 8) + 'B'
		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		
		IF EXISTS(SELECT 'X' FROM dbo.controlNoListDomestic WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Technical error occured. Please try again.', NULL
			RETURN
		END
		
		--Payout
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
		
		--Sender
		IF (@sBranch IS NULL)
			SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		IF (@sBranch IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END
		
		SELECT @agentType = agentType, @sAgent = parentId, @sBranchName = agentName, @sCountry = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		--Check for Branch or Agent Acting as Branch
		IF @agentType = 2903	
		BEGIN
			SET @sAgent = @sBranch
		END
		SELECT DISTINCT @sSuperAgent = parentId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		SELECT DISTINCT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
		
		--2. Find Settling Agent
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		
		--Validation Start
		IF EXISTS(SELECT 'X' FROM customers WHERE mobile = @sContactNo AND ISNULL(isDeleted, 'N') <> 'Y' AND isBlackListed = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Sending Customer is blacklisted. Cannot proceed transaction', NULL
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customers WHERE mobile = @rContactNo AND ISNULL(isDeleted, 'N') <> 'Y' AND isBlackListed = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Receiving Customer is blacklisted. Cannot proceed transaction', NULL
			RETURN
		END
		--3. Check Limit starts		
		SELECT @collCurr = 'NPR', @payoutCurr = 'NPR'				
		SELECT @sendingCurrency = @collCurr
		SELECT @receivingCurrency = @payoutCurr
		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
		
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
					
		--5.Txn Amount and Service Charge Validation		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
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
		
		--6.Domestic Service Charge and Commission Calculation
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
		--End of Txn Amount and Service Charge Validation

		SET @sFullName = @sFirstName + ISNULL( ' ' + @sMiddleName, '') + ISNULL( ' ' + @sLastName1, '') + ISNULL( ' ' + @sLastName2, '')
		SET @rFullName = @rFirstName + ISNULL( ' ' + @rMiddleName, '') + ISNULL( ' ' + @rLastName1, '') + ISNULL( ' ' + @rLastName2, '')

		--7.Transaction Insert
		BEGIN TRANSACTION
			
			--8.Update A/C Balance
			UPDATE creditLimit SET 
				todaysSent = ISNULL(todaysSent, 0) + ISNULL(@cAmt, 0) 
			WHERE agentId = @settlingAgent

			-- ## customer bonus point
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
						----,bonusTxnCount		  = ISNULL(bonusTxnCount, 0) + 1
						--,bonusTxnAmount		  = ISNULL(bonusTxnAmount, 0) + @pAmt
					WHERE customerId = @senderId
				END
				-- ## update total send & activate txn date
				UPDATE customerMaster SET 
					--sendTxn = ISNULL(sendTxn,0)+1,
					firstTxnDate = ISNULL(firstTxnDate,GETDATE())
				WHERE customerId = @senderId 
			END			

			--## Start OFAC / Compliance 
			DECLARE @receiverOfacRes VARCHAR(MAX),
				@ofacRes VARCHAR(MAX),
				@ofacReason VARCHAR(MAX)


			EXEC proc_ofacTrackerDomestic @flag = 't', @name = @sFullName, @Result = @ofacRes OUTPUT
			EXEC proc_ofacTrackerDomestic @flag = 't', @name = @rFullName, @Result = @receiverOfacRes OUTPUT		

			IF ISNULL(@ofacRes, '') <> ''
			BEGIN
				SET @ofacReason = 'Matched by sender name'
			END
			IF ISNULL(@receiverOfacRes, '') <> ''
			BEGIN
				SET @ofacRes = ISNULL(@ofacRes + ',' + @receiverOfacRes, '' + @receiverOfacRes)
				SET @ofacReason = 'Matched by receiver name'
			END
			IF ISNULL(@ofacRes, '') <> '' AND ISNULL(@receiverOfacRes, '') <> ''
			BEGIN
				SET @ofacReason = 'Matched by both sender name and receiver name'
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
				,'Hold'
				,'Unpaid'
				,dbo.FNAGetDateInNepalTZ()
				,dbo.FNAGetDateInNepalTZ()
				,@user
				,'D'
				,@sFullName
				,@rFullName
				,@txnBonusPoint
				
			SET @id = SCOPE_IDENTITY()	
			
			---End of Transaction Insert
			
			---9.Customer Insert
			IF (ISNULL(@senderId, 0) <> 0)
			BEGIN
				INSERT INTO tranSenders(
					 tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2
					,country,[address],[state],district,email,mobile
					,dob,idPlaceOfIssue,idType,idNumber,dcInfo,ipAddress,occupation
				)
				SELECT top 1
					 @id,@senderId,membershipId,@sFirstName,@sMiddleName,@sLastName1,@sLastName2
					,Country,@sAddress,''--pZone
					,''--pDistrict
					,@sEmail,@sContactNo
					,''--dobEng
					,placeOfIssue,@sIdType,@sIdNo,@sDcInfo,@sIpAddress,@Occupation
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
					,@sDOB,@sIdIssuedPlace,@sIdType,@sIdNo,NULL,NULL,NULL,@sDcInfo,@sIpAddress,@Occupation
			END
			IF (ISNULL(@receiverId, 0) <> 0)
			BEGIN
				INSERT INTO tranReceivers(
					 tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2
					,country,[address],[state],district,email,mobile
					,dob
					,idPlaceOfIssue,idType,idNumber
				)
				SELECT  top 1
					 @id,@receiverId,membershipId,@rFirstName,@rMiddleName,@rLastName1,@rLastName2
					,''--pCountry
					,@rAddress,''--pZone
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
		--End of Customer Insert
			
			-- Move Txn Document
			IF EXISTS(SELECT 'x' FROM dbo.txnDocUploadTEMP WITH(NOLOCK) WHERE batchId = @txnbatchId)
			BEGIN
				INSERT INTO txnDocUpload (
					 tranId
					,[fileName]
					,fileType
					,fileDescription
					,txnDocFolder
					,createdBy
					,createdDate
				)
				SELECT
					 @id
					,[fileName]
					,fileType
					,fileDescription
					,@txnDocFolder
					,createdBy
					,createdDate FROM dbo.txnDocUploadTEMP WITH(NOLOCK) WHERE batchId = @txnbatchId

					DELETE FROM dbo.txnDocUploadTEMP WHERE batchId = @txnbatchId
			END

			-------Compliance Check Begin----------

			IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentUniqueRefId)
			BEGIN
				INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
				SELECT @id, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentUniqueRefId
			
				DELETE FROM dbo.remitTranComplianceTemp WHERE agentRefId = @agentUniqueRefId
				SET @compFinalRes = 'C'
			END
			
			---------------------------------

			IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '')			
			BEGIN
				IF(ISNULL(@ofacRes, '') <> '' AND ISNULL(@compFinalRes, '') = '')
				BEGIN
					INSERT remitTranOfac(TranId, blackListId, reason, flag)
					SELECT @id, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
					UPDATE remitTran SET
							tranStatus	= 'OFAC Hold'
					WHERE id = @id	
				END
				ELSE IF(@compFinalRes <> '' AND ISNULL(@ofacRes, '') = '')
				BEGIN

					IF ISNULL(@complianceAction, '') = 'M'
					BEGIN
						UPDATE remitTran SET
							 tranStatus	= 'Hold'
						WHERE id = @id
					
						UPDATE remitTranCompliance SET
							 approvedRemarks	= @compApproveRemark
							,approvedBy			= 'system'
							,approvedDate		= GETDATE()
						WHERE tranId = @id
					END
					ELSE
					BEGIN
						UPDATE remitTran SET
							 tranStatus	= 'Compliance Hold'
						WHERE id = @id
					END
				END
				ELSE IF(ISNULL(@compFinalRes, '') <> '' AND ISNULL(@ofacRes, '') <> '')
				BEGIN

					INSERT remitTranOfac(TranId, blackListId, reason, flag)
					SELECT @id, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)

				IF ISNULL(@complianceAction, '') = 'M'
					BEGIN
						UPDATE remitTran SET
							 tranStatus	= 'OFAC Hold'
						WHERE id = @id
					
						UPDATE remitTranCompliance SET
							 approvedRemarks	= @compApproveRemark
							,approvedBy			= 'system'
							,approvedDate		= GETDATE()
						WHERE tranId = @id
					END
					ELSE
					BEGIN
						UPDATE remitTran SET
							 tranStatus	= 'OFAC/Compliance Hold'
						WHERE id = @id
					END
				END							
			END
			
			-------Compliance Check End----------


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
			EXEC Proc_AgentBalanceUpdate @flag = 's',@tAmt = @cAmt ,@settlingAgent = @settlingAgent
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
				
		EXEC [proc_errorHandler] 0, 'Transaction sent successfully and is waiting for approval', @controlNo
		
		IF @remarks IS NOT NULL
		BEGIN
			INSERT INTO tranModifyLog(tranId,[message],createdBy,createdDate,MsgType,[status])
			SELECT @id,@remarks,@user,dbo.FNAGetDateInNepalTZ(),'','Not Resolved'
		END
		/*Topup Information Send SMS*/
		IF @sMemId IS NOT NULL
		BEGIN
			EXEC proc_topupQueue 
					@flag			= 'a'
				,@user			= @user
				,@tranId		= @id
				,@tranType		= 'D'
				,@mode			= 's'
		END
	END
	
	ELSE IF @flag = 'scTBL'
	BEGIN
		DECLARE @masterId INT
		
		IF @sBranch IS NULL
			SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
		END
		

		SELECT
			 @masterId = masterId
		FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @transferAmt)
		
		SELECT 
			 fromAmt	= fromAmt
			,toAmt		= toAmt
			,pcnt		= serviceChargePcnt
			,maxAmt		= serviceChargeMaxAmt
			,minAmt		= serviceChargeMinAmt
		FROM scDetail WHERE scMasterId = @masterId
		ORDER BY fromAmt
	END
	
	ELSE IF @flag = 'sc'
	BEGIN
		IF @sBranch IS NULL
			SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
			
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
		END
		ELSE IF @deliveryMethod = 'Cash Payment' AND @transferAmt > dbo.FNAGetDomesticSendLimit() 	--AND @transferAmt > 100000
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit.', NULL
			RETURN	
		END	


		SELECT sc = ISNULL(serviceCharge, -1) FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @transferAmt)							
	END
	
	ELSE IF @flag = 'acBal'
	BEGIN
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
			 availableBal	= ISNULL(dbo.FNAGetLimitBal(@settlingAgent), 0)
			,balCurrency	= cm.currencyCode
			,limExpiry		= ISNULL(CONVERT(VARCHAR, expiryDate, 101), 'N/A')
		FROM creditLimit cl
		LEFT JOIN currencyMaster cm WITH(NOLOCK) ON cl.currency = cm.currencyId
		WHERE agentId = @settlingAgent
	END
	
	ELSE IF @flag = 'sc-v2'
	BEGIN
		
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END
		IF @sBranch IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Sending Branch is missing. Cannot send transaction', NULL
			RETURN
		END
		
		IF @deliveryMethod = 'Cash Payment' AND @transferAmt > dbo.FNAGetDomesticSendLimit() 	--AND @transferAmt > 100000
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit.', NULL
			RETURN	
		END	

		--PRINT @deliveryMethod
		--PRINT @transferAmt
		--PRINT dbo.FNAGetDomesticSendLimit() 


		DECLARE @agentLocation INT, @agentGrp INT 
		SELECT 
			@agentType = agentType, 
			@sAgent = parentId, 
			@sBranchName = agentName, 
			@sCountry = agentCountry,
			@agentLocation = agentLocation,
			@agentGrp = agentGrp
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

		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
		IF @transferAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
		END


		SELECT @serviceCharge = ISNULL(serviceCharge, 0) 
			FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @transferAmt)		
		
		if @serviceCharge = 0
		BEGIN
			EXEC [proc_errorHandler] 1, 'Service Charge not defined.', NULL
			RETURN	
		END

		SET @cAmt = @transferAmt + @serviceCharge
		SELECT 
			errorCode = 0, 
			serviceCharge = dbo.ShowDecimal(@serviceCharge), 
			cAmt = dbo.ShowDecimal(@cAmt),
			agentLocation = @agentLocation,
			agentGrp = @agentGrp

		RETURN 	
							
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errorCode, ERROR_MESSAGE() msg, null id
END CATCH



GO
