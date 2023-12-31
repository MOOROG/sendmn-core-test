USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendTranIntl]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_sendTranIntl] (
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)
	,@txnId				VARCHAR(30)	= NULL
	,@controlNo			VARCHAR(20)	= NULL
	,@id				BIGINT		= NULL
	,@senderId			BIGINT		= NULL
	,@benId				INT			= NULL
	,@agentId			INT			= NULL  --payout
	,@pBank				INT			= NULL
	,@pBankBranch		INT			= NULL
	,@accountNo			VARCHAR(30)	= NULL
	,@pSuperAgent		INT			= NULL  --payout Super Agent
	,@pCountry			VARCHAR(100)= NULL  --payout Country
	,@pLocation			INT			= NULL
	,@pState			VARCHAR(100)= NULL  --payout State
	,@pDistrict			VARCHAR(100)= NULL	--payout District
	,@pBranch			INT			= NULL
	,@collMode			INT			= NULL
	,@collCurr			VARCHAR(3)	= NULL
	,@transferAmt		FLOAT		= NULL
	,@serviceCharge		MONEY		= NULL
	,@handlingFee		MONEY		= NULL
	,@cAmt				FLOAT		= NULL
	,@exRate			FLOAT		= NULL
	,@pAmt				FLOAT		= NULL
	,@payoutCurr		VARCHAR(3)	= NULL
	,@remarks			VARCHAR(500)= NULL
	,@deliveryMethod	VARCHAR(100)= NULL
	,@purpose			VARCHAR(100)= NULL
	,@sourceOfFund		VARCHAR(100)= NULL
	,@relationship		VARCHAR(100)= NULL
	,@mode				VARCHAR(10)	= NULL
)

AS

SET NOCOUNT ON
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
		,@sCountryId				INT
		,@sSuperAgent				INT
		,@sSuperAgentName			VARCHAR(100)
		,@sAgent					INT
		,@sAgentName				VARCHAR(100)
		,@sBranch					INT
		,@sBranchName				VARCHAR(100)
		,@pAgent					INT
		,@pAgentName				VARCHAR(100)
		,@pSuperAgentName			VARCHAR(100)
		,@pBranchName				VARCHAR(100)
		,@pCountryId				INT
		,@pStateId					INT
		,@deliveryMethodId			INT
		,@settlingAgent				INT
		,@agentType					INT
		,@senderName				VARCHAR(100)

	DECLARE 
		 @xAmt			MONEY
		,@baseCurrency	INT
	DECLARE 
			 @limitBal MONEY
			,@sendingCustType		INT
			,@sendingCurrency		VARCHAR(3)
			,@sendingCurrencyId		INT
			,@receivingCustType		INT
			,@receivingCurrency		VARCHAR(3)
			,@receivingCurrencyId	INT
			,@baseCurrencyId		INT
	
	DECLARE @currentDate DATETIME 
	DECLARE @iServiceCharge MONEY	
	DECLARE @cisMasterId INT, @compIdResult VARCHAR(300)
	
	DECLARE @controlNoEncrypted VARCHAR(20)
	SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	
	IF @flag = 'v' -- Validation
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END
		IF ISNULL(@senderId, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Please choose Sender', NULL
			RETURN
		END
		IF ISNULL(@benId, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Please choose beneficiary', NULL
			RETURN
		END
		IF ISNULL(@deliveryMethod, '') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Please choose delivery method', NULL
			RETURN
		END
		IF @serviceCharge IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Service Charge missing', NULL
			RETURN
		END
		IF ISNULL(@transferAmt, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Transfer Amount missing', NULL
			RETURN
		END
		IF ISNULL(@exRate, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Exchange Rate missing', NULL
			RETURN
		END
		
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') <> 'Y'
		--Payout Agent
		IF @agentId IS NOT NULL
		BEGIN
			SET @pBranch = @agentId
			SELECT @agentType = agentType, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			IF @agentType = 2903 
				SET @pAgent = @pBranch
			ELSE
				SELECT DISTINCT @pAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			
			SELECT DISTINCT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
			SELECT DISTINCT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		END
		
		--Check Compliance ID Rule---------------------------------------------------------------------------------------------------------------------------
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry
		SELECT @pStateId = stateId FROM countryStateMaster WITH(NOLOCK) WHERE stateName = @pState
		SELECT @cisMasterId = masterId FROM dbo.FNAGetComplianceIDRuleMaster(@sBranch, @pCountryId, @pStateId, @pBranch, NULL, @senderId, @benId)
		EXEC proc_complianceIDRuleDetail @user, @senderId, @transferAmt, @sourceOfFund, @purpose, @relationship, @deliveryMethodId, NULL, @cisMasterId, @compIdResult OUTPUT
		IF(@compIdResult <> '')
		BEGIN
			EXEC proc_errorHandler 1, @compIdResult, NULL
			RETURN
		END
		--Check Compliance ID Rule--------------------------------------------------------------------------------------------------------------------------
		
		--4. Find Branch, Agent, Super Agent and Hub
		--Payout Agent
		IF @agentId IS NOT NULL
		BEGIN
			SET @pBranch = @agentId
			SELECT @agentType = agentType, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			IF @agentType = 2903 
				SET @pAgent = @pBranch
			ELSE
				SELECT DISTINCT @pAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			
			SELECT DISTINCT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
			SELECT DISTINCT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		END
		
		IF (@pBankBranch IS NOT NULL)
		BEGIN
			SELECT @pBank = parentId, @pBankBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
			SELECT @pBankName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBank
		END
		
		--Sending Agent
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT @agentType = agentType, @sBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		IF @agentType = 2903
			SET @sAgent = @sBranch
		ELSE
			SELECT DISTINCT @sAgent = parentId, @sBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		SELECT DISTINCT @sSuperAgent = parentId, @sCountry = agentCountry, @sCountryId = agentCountryId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		SELECT DISTINCT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
		
		--5. Find Settling Agent--------------------------------------------------------------------------------------
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		--End of Find Settling Agent----------------------------------------------------------------------------------
				
		--6. Check Limit starts
		SELECT @sendingCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @senderId
		SELECT @sendingCurrency = @collCurr
		SELECT @sendingCurrencyId = currencyId FROM currencyMaster WITH(NOLOCK) WHERE currencyCode = @collCurr
		SELECT @receivingCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @benId
		SELECT @receivingCurrency = @payoutCurr
		SELECT @receivingCurrencyId = currencyId FROM currencyMaster WITH(NOLOCK) WHERE currencyCode = @payoutCurr
		
		SET @currentDate = CONVERT(VARCHAR, GETDATE(), 101)
		IF EXISTS(SELECT 'X' FROM remitTran trn WITH(NOLOCK)
					LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE 
							sen.customerId = ISNULL(@senderId, 0)
						AND rec.customerId = ISNULL(@benId, 0)
						AND trn.tAmt = @transferAmt
						AND trn.createdDate BETWEEN @currentDate + '00:00:00' AND @currentDate + '23:59:59'
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Similar Transaction Found', NULL
			RETURN
		END
		
		-----------------------------------------------------------------------------------------------------------------------------------------
		SELECT @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		SELECT @baseCurrency = currency FROM creditLimit WITH(NOLOCK) WHERE agentId = @settlingAgent AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @baseCurrency = @sendingCurrencyId
			SELECT @xAmt = @transferAmt
		ELSE
			SELECT @xAmt = amount FROM dbo.FNAGetExchangeAmount(@sBranch, NULL, @collCurr, @transferAmt, @deliveryMethodId, 'C', @user)

		IF @xAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', @controlNo
			RETURN		
		END
		
		IF EXISTS(SELECT 'X' FROM creditLimit WHERE agentId = @settlingAgent AND expiryDate < GETDATE() AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC [proc_errorHandler] 1, 'Your credit limit has been expired. Please contact HO', @controlNo
			RETURN
		END
		
		IF((SELECT expiryDate FROM creditLimit WHERE agentId = @settlingAgent AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y') <
			(SELECT topUpExpiryDate = ISNULL(topUpExpiryDate, '1900-01-01') FROM balanceTopUp WHERE agentId = @settlingAgent)) 
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM balanceTopUp WHERE agentId = @settlingAgent AND topUpExpiryDate >= GETDATE())
			BEGIN
				EXEC [proc_errorHandler] 1, 'Your Top-up has been expired. Please contact HO', @controlNo
				RETURN
			END
		END
		
		IF EXISTS (
			SELECT 
				'X'
			FROM sendTranLimit
			WHERE agentId = @settlingAgent
				AND (tranType = @collMode OR tranType IS NULL)
				AND (paymentType = @deliveryMethod OR paymentType IS NULL)
				AND (customerType = @sendingCustType OR customerType IS NULL)
				AND (receivingCountry = @pCountry OR receivingCountry IS NULL)
				AND ISNULL(minLimitAmt, 0) > @transferAmt
				AND ISNULL(maxlimitAmt, 0) < @transferAmt
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
				AND (receivingCountry = @pCountry OR receivingCountry IS NULL)
				AND ISNULL(minLimitAmt, 0) <= @transferAmt
				AND ISNULL(maxLimitAmt, 0) >= @transferAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN		
			EXEC [proc_errorHandler] 3, 'Country Sending limit is not defined or exceeds.', NULL
			RETURN
		END
		
		IF @baseCurrency = @receivingCurrencyId
			SELECT @xAmt = @pAmt
		ELSE
			SELECT @xAmt = amount FROM dbo.FNAGetExchangeAmount(@sBranch, @pCountryId, @payoutCurr, @pAmt, @deliveryMethodId, 'C', @user)
		--SELECT * FROM receiveTranLimit
				
		--IF NOT EXISTS (
		--	SELECT 
		--		'X'
		--	FROM receiveTranLimit
		--	WHERE agentId = @sAgent
		--		AND (tranType = @collMode OR tranType IS NULL) 
		--		AND (customerType = @sendingCustType OR customerType IS NULL)
		--		AND currency = @receivingCurrency
		--		AND (sendingCountry = @sCountry OR sendingCountry IS NULL)
		--		AND ISNULL(limitAmt, 0) >= @pAmt
		--)
		--BEGIN		
		--	EXEC [proc_errorHandler] 1, 'Receiving Agent limit is not defined or exceeds.', @controlNo
		--	RETURN
		--END
						
		IF NOT EXISTS (
			SELECT
				'X'
			FROM receiveTranLimit
			WHERE countryId = @pCountry
				AND (tranType = @collMode OR tranType IS NULL)
				AND (customerType = @receivingCustType OR customerType IS NULL)
				AND (sendingCountry = @sCountry OR sendingCountry IS NULL)
				AND ISNULL(maxLimitAmt, 0) >= @pAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN
			EXEC [proc_errorHandler] 1, 'Receiving country limit is not defined or exceeds.', @controlNo
			RETURN
		END	
		
		-----------------------------------------------------------------------------------------------
		--7. Exchange Rate Details------------------------------------------------------------------------------------------------------------------
		SELECT @id = id FROM dbo.FNAGetExRateForTran(@sBranch, @pBranch, @pCountryId, @collCurr, @payoutCurr, @deliveryMethodId, @user)
		IF @id IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Exchange Rate not defined', NULL
			RETURN
		END
		SELECT 
			 @sCurrCostRate = cCurrCostRate
			,@sCurrHoMargin = cCurrHOMargin
			,@sCurrAgentMargin = cCurrAgentMargin
			,@pCurrCostRate = pCurrCostRate
			,@pCurrHoMargin = pCurrHOMargin
			,@pCurrAgentMargin = pCurrAgentMargin
			,@customerRate = customerCrossRate
		FROM dbo.FNAGetCrossRate(@id)
		--------------------------------------------------------------------------------------------------------------------------------------------
		--7. Service Charge Calculation-------------------------------------------------------------------------------------------------------------
		SELECT @iServiceCharge = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @pLocation, @agentId , @deliveryMethodId, @transferAmt, @collCurr) 
		IF @iServiceCharge = -1
		BEGIN
			EXEC proc_errorHandler 1, 'Service Charge is not defined', NULL
			RETURN
		END
		
		--End of service charge calculation---------------------------------------------------------------------------------------------------------
		--Commission Calculation Start
		SELECT @sSuperAgentComm = amount, @sSuperAgentCommCurrency = commissionCurrency FROM dbo.FNAGetSendComm(@sBranch, @pSuperAgent, @pCountryId, NULL, @pBranch, @collCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL)
		SELECT @sAgentComm = amount, @sAgentCommCurrency = commissionCurrency FROM dbo.FNAGetSendComm(@sBranch, @pSuperAgent, @pCountryId, NULL, @pBranch, @collCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, @sSuperAgentComm) 
		
		IF (@sSuperAgentComm IS NULL OR @sAgentComm IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Commission is not defined', NULL
			RETURN
		END
		--Commission Calculation End
				
		EXEC proc_errorHandler 0, 'Validation successful', NULL
		
	END
	
	IF @flag = 'i'
	BEGIN
		--1. Field Validation-----------------------------------------------------------
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END
		IF (
			ISNULL(@deliveryMethod, '') = ''
			OR @serviceCharge IS NULL
			OR ISNULL(@transferAmt,0) = 0
			OR ISNULL(@senderId, 0) = 0
			OR ISNULL(@benId, 0) = 0
			OR ISNULL(@exRate, 0) = 0
			)
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END
		--2. Select Ids----------------------------------------------------------------------------------------------------------------------------------------
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WHERE ISNULL(isDeleted, 'N') = 'N' AND typeTitle = @deliveryMethod
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND countryName = @pCountry
		SELECT @pStateId = stateId FROM countryStateMaster WITH(NOLOCK) WHERE stateName = @pState
		----------------------------------------------------------------------------------------------------------------------------------------------------
		
		--3. Check Compliance ID Rule---------------------------------------------------------------------------------------------------------------------------
		SELECT @cisMasterId = masterId FROM dbo.FNAGetComplianceIDRuleMaster(@sBranch, @pCountryId, @pStateId, @pBranch, NULL, @senderId, @benId)
		EXEC proc_complianceIDRuleDetail @user, @senderId, @transferAmt, @sourceOfFund, @purpose, @relationship, @deliveryMethodId, NULL, @cisMasterId, @compIdResult OUTPUT
		IF(@compIdResult <> '')
		BEGIN
			EXEC proc_errorHandler 1, @compIdResult, NULL
			RETURN
		END
		--End of Check Compliance ID Rule--------------------------------------------------------------------------------------------------------------------------
		
		--End Field Validation------------------------------------------------------
		
		SET @controlNo = '9' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 10) + 'I'
		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		
		--4. Find Branch, Agent, Super Agent and Hub
		--Payout Agent
		IF @agentId IS NOT NULL
		BEGIN
			SET @pBranch = @agentId
			SELECT @agentType = agentType, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			IF @agentType = 2903 
				SET @pAgent = @pBranch
			ELSE
				SELECT DISTINCT @pAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			
			SELECT DISTINCT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
			SELECT DISTINCT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		END
		
		IF (@pBankBranch IS NOT NULL)
		BEGIN
			SELECT @pBank = parentId, @pBankBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
			SELECT @pBankName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBank
		END
		
		--Sending Agent
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT @agentType = agentType, @sBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		IF @agentType = 2903
			SET @sAgent = @sBranch
		ELSE
			SELECT DISTINCT @sAgent = parentId, @sBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		SELECT DISTINCT @sSuperAgent = parentId, @sCountry = agentCountry, @sCountryId = agentCountryId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		SELECT DISTINCT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
		
		--5. Find Settling Agent--------------------------------------------------------------------------------------
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		--End of Find Settling Agent----------------------------------------------------------------------------------
				
		--6. Check Limit starts
		SELECT @sendingCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @senderId
		SELECT @sendingCurrency = @collCurr
		SELECT @sendingCurrencyId = currencyId FROM currencyMaster WITH(NOLOCK) WHERE currencyCode = @collCurr
		SELECT @receivingCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @benId
		SELECT @receivingCurrency = @payoutCurr
		SELECT @receivingCurrencyId = currencyId FROM currencyMaster WITH(NOLOCK) WHERE currencyCode = @payoutCurr
		
		SET @currentDate = CONVERT(VARCHAR, GETDATE(), 101)
		IF EXISTS(SELECT 'X' FROM remitTran trn WITH(NOLOCK)
					LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE 
							sen.customerId = ISNULL(@senderId, 0)
						AND rec.customerId = ISNULL(@benId, 0)
						AND trn.tAmt = @transferAmt
						AND trn.createdDate BETWEEN @currentDate + '00:00:00' AND @currentDate + '23:59:59'
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Similar Transaction Found', NULL
			RETURN
		END
		
		-----------------------------------------------------------------------------------------------------------------------------------------
		SELECT @limitBal = [dbo].FNAGetLimitBal(@settlingAgent)
		SELECT @baseCurrency = currency FROM creditLimit WITH(NOLOCK) WHERE agentId = @settlingAgent AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @baseCurrency = @sendingCurrencyId
			SELECT @xAmt = @transferAmt
		ELSE
			SELECT @xAmt = amount FROM dbo.FNAGetExchangeAmount(@sBranch, NULL, @collCurr, @transferAmt, @deliveryMethodId, 'C', @user)

		IF @xAmt > @limitBal
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', @controlNo
			RETURN		
		END
		
		IF EXISTS(SELECT 'X' FROM creditLimit WHERE agentId = @settlingAgent AND expiryDate < GETDATE() AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC [proc_errorHandler] 1, 'Your credit limit has been expired. Please contact HO', @controlNo
			RETURN
		END
		
		/*
		IF((SELECT expiryDate FROM creditLimit WHERE agentId = @settlingAgent AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y') <
			(SELECT topUpExpiryDate = ISNULL(topUpExpiryDate, '1900-01-01') FROM balanceTopUp WHERE agentId = @settlingAgent)) 
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM balanceTopUp WHERE agentId = @settlingAgent AND topUpExpiryDate >= GETDATE())
			BEGIN
				EXEC [proc_errorHandler] 1, 'Your Top-up has been expired. Please contact HO', @controlNo
				RETURN
			END
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
				AND (receivingCountry = @pCountry OR receivingCountry IS NULL)
				AND ISNULL(minLimitAmt, 0) <= @transferAmt
				AND ISNULL(maxLimitAmt, 0) >= @transferAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN		
			EXEC [proc_errorHandler] 3, 'Country Sending limit is not defined or exceeds.', NULL
			RETURN
		END
		
		IF @baseCurrency = @receivingCurrencyId
			SELECT @xAmt = @pAmt
		ELSE
			SELECT @xAmt = amount FROM dbo.FNAGetExchangeAmount(@sBranch, @pCountryId, @payoutCurr, @pAmt, @deliveryMethodId, 'C', @user)
		--SELECT * FROM receiveTranLimit
				
		--IF NOT EXISTS (
		--	SELECT 
		--		'X'
		--	FROM receiveTranLimit
		--	WHERE agentId = @sAgent
		--		AND (tranType = @collMode OR tranType IS NULL) 
		--		AND (customerType = @sendingCustType OR customerType IS NULL)
		--		AND currency = @receivingCurrency
		--		AND (sendingCountry = @sCountry OR sendingCountry IS NULL)
		--		AND ISNULL(limitAmt, 0) >= @pAmt
		--)
		--BEGIN		
		--	EXEC [proc_errorHandler] 1, 'Receiving Agent limit is not defined or exceeds.', @controlNo
		--	RETURN
		--END
						
		IF NOT EXISTS (
			SELECT
				'X'
			FROM receiveTranLimit
			WHERE countryId = @pCountry
				AND (tranType = @collMode OR tranType IS NULL)
				AND (customerType = @receivingCustType OR customerType IS NULL)
				AND (sendingCountry = @sCountry OR sendingCountry IS NULL)
				AND ISNULL(maxLimitAmt, 0) >= @pAmt
				AND ISNULL(isActive, 'N') = 'Y'
		)
		BEGIN
			EXEC [proc_errorHandler] 1, 'Receiving country limit is not defined or exceeds.', @controlNo
			RETURN
		END	
		
		-----------------------------------------------------------------------------------------------
		--7. Exchange Rate Details------------------------------------------------------------------------------------------------------------------
		SELECT @id = id FROM dbo.FNAGetExRateForTran(@sBranch, @pBranch, @pCountryId, @collCurr, @payoutCurr, @deliveryMethodId, @user)
		IF @id IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction failed. Exchange Rate not defined', NULL
			RETURN
		END
		SELECT 
			 @sCurrCostRate = cCurrCostRate
			,@sCurrHoMargin = cCurrHOMargin
			,@sCurrAgentMargin = cCurrAgentMargin
			,@pCurrCostRate = pCurrCostRate
			,@pCurrHoMargin = pCurrHOMargin
			,@pCurrAgentMargin = pCurrAgentMargin
			,@customerRate = customerCrossRate
		FROM dbo.FNAGetCrossRate(@id)
		--------------------------------------------------------------------------------------------------------------------------------------------
		--7. Service Charge Calculation-------------------------------------------------------------------------------------------------------------
		SELECT @iServiceCharge = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @pLocation, @agentId , @deliveryMethodId, @transferAmt, @collCurr) 
		IF @iServiceCharge = -1
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction failed. Service Charge is not defined', NULL
			RETURN
		END
		
		--End of service charge calculation---------------------------------------------------------------------------------------------------------
		--Commission Calculation Start
		SELECT @sSuperAgentComm = amount, @sSuperAgentCommCurrency = commissionCurrency FROM dbo.FNAGetSendCommSA(@sBranch, @pSuperAgent, @pCountryId, NULL, @pBranch, @collCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL)
		SELECT @sAgentComm = amount, @sAgentCommCurrency = commissionCurrency FROM dbo.FNAGetSendComm(@sBranch, @pSuperAgent, @pCountryId, NULL, @pBranch, @collCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, @sSuperAgentComm) 
		
		IF (@sSuperAgentComm IS NULL OR @sAgentComm IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction failed. Commission is not defined', NULL
			RETURN
		END
		--Commission Calculation End
		
		--OFAC--------------------------------------------------------------------------------------------------------------------------
		DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @ofacRes VARCHAR(MAX), @totalRows INT, @count INT, @compFinalRes VARCHAR(20)
		DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
		INSERT @csMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetComplianceRuleMaster(@sBranch, @pCountryId, @pStateId, @pBranch, NULL, @senderId, @benId)
		SELECT @totalRows = COUNT(*) FROM @csMasterRec
		
		SELECT @senderName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName1, '') + ISNULL(' ' + lastName2, '') 
		FROM customers WITH(NOLOCK) WHERE customerId = @senderId
		
		EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @ofacRes OUTPUT
		--------------------------------------------------------------------------------------------------------------------------------
		
		BEGIN TRANSACTION
			--A/C Master
			UPDATE creditLimit SET 
				todaysSent = todaysSent + ISNULL(@xAmt, 0) 
			WHERE agentId = @settlingAgent
			
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
				,GETDATE()
				,DBO.FNADateFormatTZ(GETDATE(), @user)
				,@user
				,'I'
				
			SET @id = SCOPE_IDENTITY()	
			
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
				,firstName
				,middleName
				,lastName1
				,lastName2
				,sc.countryName
				,[address]
				,ss.stateName
				,zipCode
				,city
				,email
				,homePhone
				,workPhone
				,mobile
				,nativeCountry = nc.countryName
				,dob
				,c.placeOfIssue
				,sdv.detailTitle
				,ci.idNumber
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
				,@benId
				,membershipId
				,firstName
				,middleName
				,lastName1
				,lastName2
				,sc.countryName
				,[address]
				,ss.stateName
				,zipCode
				,city
				,email
				,homePhone
				,workPhone
				,mobile
				,nativeCountry = nc.countryName
				,dob
				,c.placeOfIssue
				,sdv.detailTitle
				,ci.idNumber
				,ci.PlaceOfIssue
				,ci.issuedDate
				,ci.validDate
			FROM customers c WITH(NOLOCK)
			LEFT JOIN customerIdentity ci WITH(NOLOCK) ON c.customerId = ci.customerId AND ci.isPrimary = 'Y' AND ISNULL(ci.isDeleted,'N')<>'Y'
			LEFT JOIN countryMaster sc WITH(NOLOCK) ON c.country = sc.countryId
			LEFT JOIN countryMaster nc WITH(NOLOCK) ON c.nativeCountry = nc.countryId
			LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON c.state = ss.stateId
			LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON ci.idType = sdv.valueId
			WHERE c.customerId = @benId
		
		--10. Compliance----------------------------------------------------------------------------------------------------
		SET @count = 1
		WHILE(@count <= @totalRows)
		BEGIN
			SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
			EXEC proc_complianceRuleDetail @user, @id, @transferAmt, @senderId, @benId, @accountNo, @csMasterId, @deliveryMethodId, @complianceRes OUTPUT
			SET @compFinalRes = @compFinalRes + @complianceRes
			SET @count = @count + 1
		END
		
		IF(@compFinalRes <> '' OR @ofacRes <> '')
		BEGIN
			IF(@ofacRes <> '')
			BEGIN
				INSERT remitTranOfac(TranId, blackListId)
				SELECT @id, @ofacRes
			END
			
			UPDATE remitTran SET
				 tranStatus	= 'Compliance'
			WHERE controlNo = @controlNoEncrypted
		END
		ELSE
		BEGIN
			--11.Check User Approve Limit---------------------------------------------------------------------------------------
			DECLARE @userId INT, @sendLimit MONEY, @payLimit MONEY, @approveFlag CHAR(1)
			SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
			SELECT @sendLimit = ISNULL(sendLimit, 0) FROM userLimit WITH(NOLOCK) 
				WHERE userId = @userId 
				AND ISNULL(isDeleted, 'N') <> 'Y' 
				AND ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isEnable, 'N') = 'Y'
			IF @sendLimit > @transferAmt
			BEGIN
				SET @approveFlag = 'Y'
				UPDATE remitTran SET
					  tranStatus				= 'Payment'					--Payment
					 ,approvedBy				= @user
					 ,approvedDate				= GETDATE()
					 ,approvedDateLocal			= DBO.FNADateFormatTZ(GETDATE(), @user)
				WHERE controlNo = @controlNoEncrypted
			END
			--End of Approve Limit Checking
		END
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		IF(@complianceRes = 'C' OR @ofacRes <> '')
		BEGIN
			EXEC proc_errorHandler 101, 'Transaction under compliance', @controlNo
			RETURN
		END
		IF @approveFlag = 'Y'
			EXEC [proc_errorHandler] 0, 'Transaction has been sent successfully', @controlNo
		ELSE
			EXEC [proc_errorHandler] 100, 'Transaction waiting for approval', @controlNo	
		
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
	
	ELSE IF @flag = 'exRate'
	BEGIN
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT customerCrossRate = CAST(ISNULL(customerCrossRate, 0) AS DECIMAL(11, 6)) FROM dbo.FNAGetExRateForTran(@sBranch, @pBranch, @pCountry, @collCurr, @payoutCurr, @deliveryMethod, @user)
	END
	
	ELSE IF @flag = 'sc'
	BEGIN
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod
		--EXEC proc_sendTransactionLoadData @flag = 'sc', @amount= '100000', @pLocation = '109'
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT SC = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @pLocation, @agentId , @deliveryMethodId, @transferAmt, @collCurr) 
	END
	
	ELSE IF @flag = 'scTBL'
	BEGIN
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry
		DECLARE 
			 @masterId INT
			,@masterType CHAR(1)
			,@sc MONEY
		
		IF @sBranch IS NULL
			SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
		END
		
		SELECT 
			 @masterId = masterId
			,@masterType = masterType 
			,@sc = amount
		FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @pLocation, @agentId , @deliveryMethodId, @transferAmt, @collCurr)
		
		IF(@masterType = 'S')
		BEGIN
			SELECT fromAmt, toAmt, pcnt, maxAmt, minAmt FROM sscDetail WHERE sscMasterId = @masterId
		END
		ELSE
		BEGIN
			SELECT fromAmt, toAmt, pcnt, maxAmt, minAmt FROM dscDetail WHERE dscMasterId = @masterId 
		END	
	END
	
	ELSE IF @flag = 'cti' --All transaction information (sender, receiver, payout)
	BEGIN
		SELECT DISTINCT
			 c.customerId
			,c.membershipId
			,Name = c.firstName + ISNULL(' ' + c.middleName, '') + ISNULL(' ' + c.lastName1, '') + ISNULL(' ' + c.lastName2, '')
			,Country = ccm.countryName
			,Address
			,[State]
			,Phone = COALESCE(mobile, homePhone, workPhone)
			,city
		FROM customers c WITH(NOLOCK)	
		LEFT JOIN countryMaster ccm WITH(NOLOCK) ON c.country = ccm.countryId
		WHERE c.customerId = @senderId
		
		SELECT DISTINCT
			 c.customerId
			,c.membershipId
			,Name = c.firstName + ISNULL( ' ' + c.middleName, '') + ISNULL( ' ' + c.lastName1, '') + ISNULL( ' ' + c.lastName2, '')
			,Country = ccm.countryName
			,Address
			,[State]
			,Phone = COALESCE(mobile, homePhone, workPhone)
			,city
		FROM customers c WITH(NOLOCK)	
		LEFT JOIN countryMaster ccm WITH(NOLOCK) ON c.country = ccm.countryId
		WHERE c.customerId = @benId
		
		IF @agentId > 0
		BEGIN
			SELECT
				DISTINCT
				 am.agentId
				,am.agentCode
				,name = am.agentName
				,address = am.agentAddress
				,city = agentCity
				,[State] = agentState
				,Phone = COALESCE(agentMobile1, agentMobile2, agentPhone1, agentPhone2)
				,Country = @pCountry
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentCurrency ac WITH(NOLOCK) ON am.agentId = ac.agentId
			WHERE am.agentId = @agentId
		END
		ELSE
		BEGIN
			SELECT
				 agentId = NULL
				,agentCode = NULL
				,name = 'Any'
				,address = NULL
				,city = NULL
				,state = NULL
				,Phone = NULL
				,country = @pCountry
		END
	END
	
	ELSE IF @flag = 'pcl'
	BEGIN
		SELECT DISTINCT
			 cm.countryId
			,cm.countryName
		FROM countryMaster cm
		INNER JOIN rsList1 rsl ON cm.countryId = rsl.rsCountryId AND roleType = 's' AND listType <> 'ex'
		WHERE agentId = 3882 OR rsCountryId = 151
	END
	
	ELSE IF @flag = 'scl'						--Sender Country List
	BEGIN
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT
			 countryId
			,countryName
		FROM countryMaster cm
		INNER JOIN agentMaster am WITH(NOLOCK) ON cm.countryId = am.agentCountryId
		WHERE am.agentId = @sBranch
	END
	
	ELSE IF @flag = 'controlNo'
	BEGIN
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		SELECT
			  senderId = sen.customerId
			 ,benId = ben.customerId
			 ,pCountry = cm.countryId
			 ,deliveryMethod = stm.serviceTypeId
			 ,tAmt = trn.tAmt
			 ,cAmt = trn.cAmt
			 ,pAmt = trn.pAmt
			 ,customerRate = trn.customerRate
			 ,serviceCharge = trn.serviceCharge
			 ,trn.collCurr
			 ,trn.payoutCurr
			 ,agentId = pBranch
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers ben WITH(NOLOCK) ON trn.id = ben.tranId
		INNER JOIN countryMaster cm WITH(NOLOCK) ON trn.pCountry = cm.countryName
		INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
		WHERE controlNo = @controlNoEncrypted
	END
	
	ELSE IF @flag = 'senderId'
	BEGIN
		SELECT TOP 1
			 senderId = sen.customerId
			,benId = ben.customerId
			,pCountry = cm.countryId
			,deliveryMethod = stm.serviceTypeId
			,tAmt = trn.tAmt
			,cAmt = trn.cAmt
			,pAmt = trn.pAmt
			,customerRate = trn.customerRate
			,serviceCharge = trn.serviceCharge
			,trn.collCurr
			,trn.payoutCurr
			,agentId = pBranch
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers ben WITH(NOLOCK) ON trn.id = ben.tranId
		INNER JOIN countryMaster cm WITH(NOLOCK) ON trn.pCountry = cm.countryName
		INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
		WHERE sen.customerId = @senderId ORDER BY trn.id DESC
	END
END

GO
