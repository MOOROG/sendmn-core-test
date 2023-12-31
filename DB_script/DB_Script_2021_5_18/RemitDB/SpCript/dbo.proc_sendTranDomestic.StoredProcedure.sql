USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendTranDomestic]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_sendTranDomestic] (
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
	,@sBranchName		VARCHAR(100)= NULL
	,@sAgent			INT			= NULL
	,@sAgentName		VARCHAR(100)= NULL
	,@sSuperAgent		INT			= NULL
	,@sSuperAgentName	VARCHAR(100)= NULL
	,@settlingAgent		INT			= NULL
	,@mapCode			VARCHAR(8)	= NULL
	,@mapCodeDom		VARCHAR(8)	= NULL
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
	,@relationship		VARCHAR(100)= NULL
	,@controlNo			VARCHAR(20)	= NULL
	,@txnId				INT			= NULL
	,@enableApi			CHAR(1)		= NULL
)

AS

SET XACT_ABORT ON
BEGIN
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
		,@sCountry					VARCHAR(100)
		,@pSuperAgent				INT
		,@pSuperAgentName			VARCHAR(100)
		,@pAgent					INT
		,@pAgentName				VARCHAR(100)
		,@pBranchName				VARCHAR(100)
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
	
	DECLARE @controlNoEncrypted VARCHAR(20)
	
	IF @flag = 'm'				--Select Customer according to membership Id
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
	
	ELSE IF @flag = 'v'			--Verify Transaction
	BEGIN
		--Necessary Parameter: @user, @sBranch, @sAgent, @sSuperAgent, @settlingAgent, @transferAmt
		--1. Find Sender Information
		SELECT @sCountry = 'Nepal'
		
		--2. Check Limit starts--------------------------------------------------------------------------------------------
		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
		IF @transferAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END

		EXEC proc_errorHandler 0, 'Verification Successful', NULL
	END
	
	ELSE IF @flag = 'i'			--Local DB Insert
	BEGIN
		--Field Validation-----------------------------------------------------------
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
		--End Field Validation------------------------------------------------------
		
		SET @controlNo = '777' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '00000000', 8) + 'B'
		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		
		IF EXISTS(SELECT 'X' FROM dbo.controlNoListDomestic WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Technical error occured. Please try again.', NULL
			RETURN
		END

		--1. Find Branch, Agent, Super Agent and Hub
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
		SELECT @pCountry = 'Nepal'

		IF (@sBranch IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END
		
		SELECT @sCountry = 'Nepal'
		/*
		SELECT @agentType = agentType, @sAgent = parentId, @sBranchName = agentName, @sCountry = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		--Check for Branch or Agent Acting as Branch
		IF @agentType = 2903	--Agent
		BEGIN
			SET @sAgent = @sBranch
		END
		SELECT DISTINCT @sSuperAgent = parentId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		SELECT DISTINCT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
		*/
		/*
		--2. Find Settling Agent--------------------------------------------------------------------------------------
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		*/
		
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
		--3. Check Limit starts--------------------------------------------------------------------------------------------
		
		SELECT @collCurr = 'NPR', @payoutCurr = 'NPR'				
		SELECT @sendingCustType = customerType FROM customers WHERE customerId = @senderId
		SELECT @sendingCurrency = @collCurr
		SELECT @receivingCustType = customerType FROM customers WHERE customerId = @receiverId
		SELECT @receivingCurrency = @payoutCurr
		
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		
		DECLARE @currentDate DATETIME 
		SET @currentDate = GETDATE()
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
						AND DATEDIFF(MI, trn.createdDate, @currentDate) <= 2
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
		
		/*
		IF NOT EXISTS(SELECT 'X' FROM creditLimit WHERE agentId = @settlingAgent AND expiryDate >= GETDATE() AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC [proc_errorHandler] 1, 'Your credit limit has been expired. Please contact HO', NULL
			RETURN
		END
		*/
		
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
			WHERE countryId = @sCountry
				AND (tranType = @collMode OR tranType IS NULL)
				AND (paymentType = @deliveryMethod OR paymentType IS NULL)
				AND (customerType = @sendingCustType OR customerType IS NULL)
				AND currency = @sendingCurrency
				AND (receivingCountry = @pCountry OR receivingCountry IS NULL)
				AND ISNULL(minLimitAmt, 0) <= @transferAmt
				AND ISNULL(maxLimitAmt, 0) >= @transferAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN		
			EXEC [proc_errorHandler] 3, 'Country Sending limit is not defined or exceeds.', NULL
			RETURN
		END
		
		--End of Limit Checking-----------------------------------------------------------------------------------		
		
		--4.Compliance Checking-----------------------------------------------------------------------------------
		SELECT
			 @tranCount = 1000 --tranCount
			,@tranAmount = 1000000-- amount
			,@period = 5 --period
			--,@nextAction = nextAction
		--FROM csDetail 
		--WHERE
		--ISNULL(isActive, 'N') = 'Y'
		--AND ISNULL(isDeleted, 'N') <> 'Y'
		--AND condition = 4600

		--Sending Customer
		SELECT 
			 @sendingCount = COUNT(*)
			,@sendingAmount = SUM(tAmt)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		WHERE ts.customerId = @senderId
		AND rt.createdDate BETWEEN CONVERT(VARCHAR, (GETDATE() - @period), 101) AND GETDATE()

		--Receiving Customer
		SELECT 
			 @receivingCount = COUNT(*)
			,@receivingAmount = SUM(pAmt)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		WHERE ts.customerId = @receiverId
		AND rt.createdDate BETWEEN CONVERT(VARCHAR, (GETDATE() - @period), 101) AND GETDATE()

		IF @sendingCount > @tranCount
		BEGIN
			EXEC [proc_errorHandler] 11, 'Sending transaction count limit exceeds.', NULL
			RETURN
		END

		IF @sendingAmount > @tranAmount
		BEGIN
			EXEC [proc_errorHandler] 12, 'Sending transaction amount limit exceeds.', NULL
			RETURN
		END

		IF @receivingCount > @tranCount
		BEGIN
			EXEC [proc_errorHandler] 13, 'Receiving transaction count limit exceeds.', NULL
			RETURN
		END

		IF @receivingAmount > @tranAmount
		BEGIN
			EXEC [proc_errorHandler] 14, 'Receiving transaction amount limit exceeds.', NULL
			RETURN
		END
		
		-----------------------------------------------------------------------------------------------
		
		--Compliance Check Starts
		
		--Compliance Check Ends		
								
		-- select * from csMaster
		-- select * from csDetail
		--End of Compliance Checking-----------------------------------------------------------------------------------
		
		--5.Txn Amount and Service Charge Validation-------------------------------------------------------------------
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WHERE agentId = @pBankBranch
		END
		ELSE
		BEGIN
			SELECT
				  @pAgentComm		= ISNULL(pAgentComm, 0)
				 ,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
			FROM dbo.FNAGetDomesticPayCommForCancel(@sBranch, @pLocation, @deliveryMethodId, @transferAmt)
		END
		SELECT @pCountryId = 151
		
		--6.Domestic Service Charge and Commission Calculation
		SELECT 
			 @serviceCharge		= ISNULL(serviceCharge, 0)
			,@sAgentComm		= ISNULL(sAgentComm, 0)
			,@sSuperAgentComm	= ISNULL(ssAgentComm, 0)
		FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @transferAmt)
		
		SELECT @sSuperAgentCommCurrency = 'NPR', @sAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR', @pAgentCommCurrency = 'NPR'
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
		--End of Txn Amount and Service Charge Validation--------------------------------------------------------------

		--7.Transaction Insert-----------------------------------------------------------------------------------------------
		BEGIN TRANSACTION
			/*
			--8.Update A/C Balance-------------------------------------------------------------------------------------------
			UPDATE creditLimit SET 
				todaysSent = ISNULL(todaysSent, 0) + ISNULL(@cAmt, 0) 
			WHERE agentId = @settlingAgent
			---------------------------------------------------------------------------------------------------------------
			*/
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
				,approvedBy
				,approvedDate
				,approvedDateLocal
				,tranType			
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
				,GETDATE()
				,DBO.FNADateFormatTZ(GETDATE(), @user)
				,@user
				,@user
				,GETDATE()
				,DBO.FNADateFormatTZ(GETDATE(), @user)
				,'D'
				
			SET @id = SCOPE_IDENTITY()	
			
			---End of Transaction Insert-----------------------------------------------------------------------------------
			
			---9.Customer Insert---------------------------------------------------------------------------------------------
			IF (ISNULL(@senderId, 0) <> 0)
			BEGIN
				INSERT INTO tranSenders(
					 tranId
					,customerId
					,membershipId
					,firstName
					,middleName
					,lastName1
					,lastName2
					,country
					,[address]
					,[state]
					,zipCode
					,city
					,email
					,homePhone
					,workPhone
					,mobile
					,nativeCountry
					,dob
					,placeOfIssue
					,idType
					,idNumber
					,idPlaceOfIssue
					,issuedDate
					,validDate
				)
				
				SELECT
					 @id
					,@senderId
					,membershipId
					,@sFirstName
					,@sMiddleName
					,@sLastName1
					,@sLastName2
					,sc.countryName
					,@sAddress
					,ss.stateName
					,zipCode
					,city
					,@sEmail
					,homePhone
					,workPhone
					,@sContactNo
					,nativeCountry = nc.countryName
					,dob
					,c.placeOfIssue
					,@sIdType
					,@sIdNo
					,ci.PlaceOfIssue
					,ci.issuedDate
					,ci.validDate
				FROM customers c WITH(NOLOCK)
				LEFT JOIN customerIdentity ci WITH(NOLOCK) ON c.customerId = ci.customerId AND ci.isPrimary = 'Y' AND ISNULL(ci.isDeleted,'N')<>'Y'
				LEFT JOIN countryMaster sc WITH(NOLOCK) ON c.country = sc.countryId
				LEFT JOIN countryMaster nc WITH(NOLOCK) ON c.nativeCountry = nc.countryId
				LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON c.state = ss.stateId
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON ci.idType = sdv.valueId
				WHERE c.customerId = @senderId
			END
			ELSE
			BEGIN
				INSERT INTO tranSenders(
					 tranId
					,membershipId
					,firstName
					,middleName
					,lastName1
					,lastName2
					,country
					,[address]
					,[state]
					,zipCode
					,city
					,email
					,homePhone
					,workPhone
					,mobile
					,nativeCountry
					,dob
					,placeOfIssue
					,idType
					,idNumber
					,idPlaceOfIssue
					,issuedDate
					,validDate
				)
				
				SELECT
					 @id
					,@sMemId
					,@sFirstName
					,@sMiddleName
					,@sLastName1
					,@sLastName2
					,'Nepal'
					,@sAddress
					,NULL
					,NULL
					,NULL
					,@sEmail
					,NULL
					,NULL
					,@sContactNo
					,NULL
					,NULL
					,NULL
					,@sIdType
					,@sIdNo
					,NULL
					,NULL
					,NULL
			END
			IF (ISNULL(@receiverId, 0) <> 0)
			BEGIN
				INSERT INTO tranReceivers(
					 tranId
					,customerId
					,membershipId
					,firstName
					,middleName
					,lastName1
					,lastName2
					,country
					,[address]
					,[state]
					,zipCode
					,city
					,email
					,homePhone
					,workPhone
					,mobile
					,nativeCountry
					,dob
					,placeOfIssue
					,idType
					,idNumber
					,idPlaceOfIssue
					,issuedDate
					,validDate
				)
				SELECT
					 @id
					,@receiverId
					,membershipId
					,@rFirstName
					,@rMiddleName
					,@rLastName1
					,@rLastName2
					,sc.countryName
					,@rAddress
					,ss.stateName
					,zipCode
					,city
					,email
					,homePhone
					,workPhone
					,@rContactNo
					,nativeCountry = nc.countryName
					,dob
					,c.placeOfIssue
					,@rIdType
					,@rIdNo
					,ci.PlaceOfIssue
					,ci.issuedDate
					,ci.validDate
				FROM customers c WITH(NOLOCK)
				LEFT JOIN customerIdentity ci WITH(NOLOCK) ON c.customerId = ci.customerId AND ci.isPrimary = 'Y' AND ISNULL(ci.isDeleted,'N')<>'Y'
				LEFT JOIN countryMaster sc WITH(NOLOCK) ON c.country = sc.countryId
				LEFT JOIN countryMaster nc WITH(NOLOCK) ON c.nativeCountry = nc.countryId
				LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON c.state = ss.stateId
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON ci.idType = sdv.valueId
				WHERE c.customerId = @receiverId
			END
			ELSE
			BEGIN
				INSERT INTO tranReceivers(
					 tranId
					,membershipId
					,firstName
					,middleName
					,lastName1
					,lastName2
					,country
					,[address]
					,[state]
					,zipCode
					,city
					,email
					,homePhone
					,workPhone
					,mobile
					,nativeCountry
					,dob
					,placeOfIssue
					,idType
					,idNumber
					,idPlaceOfIssue
					,issuedDate
					,validDate
				)
				SELECT
					 @id
					,@rMemId
					,@rFirstName
					,@rMiddleName
					,@rLastName1
					,@rLastName2
					,'Nepal'
					,@rAddress
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,@rContactNo
					,NULL
					,NULL
					,NULL
					,@rIdType
					,@rIdNo
					,NULL
					,NULL
					,NULL
			END
		--End of Customer Insert-----------------------------------------------------------------------------------------
		
		INSERT INTO controlNoListDomestic(controlNo)
		SELECT @controlNo
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
				
		EXEC [proc_errorHandler] 0, 'Transaction has been sent successfully', @controlNo
		
		--11. Accounting Server------------------------------------------------------------------------------------------
		--SELECT * FROM [192.168.1.234].IME_TEST.dbo.[REMIT_TRN_LOCAL] WHERE TRN_REF_NO = dbo.encryptDBlocal('7115830246D') ORDER BY tran_id DESC
		--UPDATE [192.168.1.234].IME_TEST.dbo.[REMIT_TRN_LOCAL] SET S_BRANCH = S_AGENT WHERE TRN_REF_NO = dbo.encryptDBlocal('7115830246D')
		--SELECT * FROM [192.168.1.234].IME_TEST.dbo.[REMIT_TRN_MASTER]
		--SELECT * FROM [192.168.1.234].IME_TEST.dbo.[ac_master] ORDER BY tran_id DESC
		
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
		
		/*		
		INSERT INTO [192.168.1.234].IME_TEST.dbo.[REMIT_TRN_LOCAL] (
			  [TRN_REF_NO],[S_AGENT]
			 ,[SENDER_NAME]
			 ,[RECEIVER_NAME]
			 ,[S_AMT],[P_AMT],[ROUND_AMT],[TOTAL_SC],[OTHER_SC],[S_SC], [R_SC]
			 ,[R_BANK],[R_BANK_NAME],[R_BRANCH]
			 ,[TRN_TYPE]
			 ,TRN_STATUS,PAY_STATUS
			 ,[TRN_DATE],CONFIRM_DATE
			 ,SEMPID
		)
		SELECT
			 dbo.encryptDBlocal(@controlNo),@mapCodeDom
			,@sFirstName + ISNULL(' ' + @sMiddleName, '') + ISNULL(' ' + @sLastName1, '') + ISNULL(' ' + @sLastName2, '')
			,@rFirstName + ISNULL(' ' + @rMiddleName, '') + ISNULL(' ' + @rLastName1, '') + ISNULL(' ' + @rLastName2, '')
			,@cAmt,@pAmt,@pAmt,@serviceCharge,0,@sAgentComm,0
			,@pBank,@pBankName,@pBankBranch
			,CASE WHEN @deliveryMethod = 'Cash Payment' THEN 'Cash Pay' WHEN @deliveryMethod = 'Bank Deposit' THEN 'Bank Transfer' END
			,'Unpaid','Payment'
			,GETDATE(),GETDATE()
			,@user
		*/
			
	END
	
	ELSE IF @flag = 'scTBL'
	BEGIN
		DECLARE @masterId INT
		
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
		--EXEC proc_sendTranDomestic @flag = 'sc', @transferAmt = '10000', @pLocation = '109', @sBranch = '10004', @user = 'imeadmin'
		--EXEC proc_sendTranDomestic @flag = 'sc', @pLocation = null, @deliveryMethod = 'Bank Deposit', @transferAmt = '1000', @sBranch = '10011', @pBankBranch = '10004', @user = 'imeadmin'
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
		--EXEC proc_sendTranDomestic @flag = 'acBal', @settlingAgent = '1227', @user = 'bajrasub123'
		SELECT 
			 availableBal	= ISNULL(dbo.FNAGetLimitBal(@settlingAgent), 0)
			,balCurrency	= cm.currencyCode
			,limExpiry		= ISNULL(CONVERT(VARCHAR, expiryDate, 101), 'N/A')
		FROM creditLimit cl
		LEFT JOIN currencyMaster cm WITH(NOLOCK) ON cl.currency = cm.currencyId
		WHERE agentId = @settlingAgent
	END
	
	-- ## Get Service Charge V2
	IF @flag = 'sc-v2'
	BEGIN		
		-- ## transaction varification
		SET @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)		
		IF @transferAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END

		-- ## service charge calculation
		SELECT @deliveryMethodId = serviceTypeId 
			FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation 
				FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
		END		
		ELSE IF @deliveryMethod = 'Cash Payment' AND @transferAmt > dbo.FNAGetDomesticSendLimit() --AND @transferAmt > 100000
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit.', NULL
			RETURN	
		END	


		SELECT @serviceCharge = ISNULL(serviceCharge, 0) 
			FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @transferAmt)	

		if @serviceCharge = 0
		BEGIN
			EXEC [proc_errorHandler] 1, 'Service Charge not defined.', NULL
			RETURN	
		END

		IF (@transferAmt + @serviceCharge) > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', NULL
			RETURN		
		END

		-- ## invoice print
		DECLARE 
			 @method		VARCHAR(20) = NULL
			,@userId		INT
			,@sendLimit		MONEY
			,@invPrint		CHAR(1)
		
		SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT @sendLimit = sendLimit FROM userLimit WITH(NOLOCK) 
		WHERE 
			userId = @userId 
			AND ISNULL(isDeleted, 'N') <> 'Y' 
			AND ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isEnable, 'N') = 'Y'  

		SELECT @method = invoicePrintMethod
		FROM agentBusinessFunction WITH(NOLOCK)
		WHERE agentId = (SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)
		
		IF(@sendLimit > @transferAmt)
			SELECT @invPrint = 'Y'
		ELSE IF(@method = 'ba')
			SELECT @invPrint ='Y'
		ELSE
			SELECT @invPrint = 'N'

		SET @cAmt = @transferAmt + @serviceCharge
		SELECT 0 errorCode, dbo.ShowDecimal(@serviceCharge) serviceCharge, dbo.ShowDecimal(@cAmt) cAmt,@invPrint invoiceMethod
		RETURN 						
	END
END





GO
