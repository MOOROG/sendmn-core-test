USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendDomestic]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[proc_sendDomestic] (
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)
	,@sBranch			INT			= NULL
	,@settlingAgent		INT			= NULL
	,@pBankBranch		INT			= NULL
	,@pLocation			INT			= NULL	
	,@transferAmt		MONEY		= NULL
	,@deliveryMethod	VARCHAR(50)	= NULL
	,@districtId		INT			= NULL
	,@pLocationId		INT			= NULL
	,@bankId			INT			= NULL
)

AS

SET XACT_ABORT ON
BEGIN
		
	DECLARE 
		  @limitBal MONEY
		 ,@sCountry	VARCHAR(100)
		 ,@deliveryMethodId	INT	
		 ,@controlNoEncrypted VARCHAR(20)
	
	IF @flag = 'pLocation'
	BEGIN
		SELECT DISTINCT
			 id		= districtCode
			,value	= districtName
		FROM api_districtList adl WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
		WHERE ISNULL(isDeleted, 'N') = 'N' AND ISNULL(adl.isActive,'Y')='Y'
		AND alm.districtId = ISNULL(@districtId, alm.districtId)
		ORDER BY districtName
	END

	IF @flag = 'pDistrict'
	BEGIN
		SELECT DISTINCT
			 id		= zdm.districtId
			,value	= zdm.districtName 
		FROM zoneDistrictMap zdm WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON zdm.districtId = alm.districtId		
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(apiDistrictCode, 0) = ISNULL(ISNULL(@pLocationId, apiDistrictCode), 0)
		ORDER BY districtName
	END

	IF @flag = 'bank'
	BEGIN
		SELECT 
			id		= extBankId,
			value	= bankName 
		FROM externalBank b WITH(NOLOCK) 
		WHERE ISNULL(isDeleted,'N') <>'Y'
		ORDER BY bankName
		RETURN
	END

	IF @flag = 'bankBranch'
	BEGIN
		SELECT 
			id		= extBranchId,
			value	= branchName 
		FROM externalBankBranch 
		WHERE extBankId = @bankId
		AND ISNULL(isDeleted,'N') <>'Y'
		AND pLocation IS NOT NULL
		ORDER BY branchName		
		RETURN
	END

	IF @flag = 'sc-tb'
	BEGIN
		DECLARE @masterId INT		
		SELECT @deliveryMethodId = serviceTypeId 
			FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
		END
		ELSE IF @deliveryMethod = 'Cash Payment' AND @transferAmt > 100400
		BEGIN
			EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit.', NULL
			RETURN	
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
	
	IF @flag = 'sc'
	BEGIN
		DECLARE @serviceCharge MONEY,@cAmt MONEY	
	
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
			SELECT @pLocation = pLocation FROM externalBankBranch WITH(NOLOCK) WHERE extBranchId = @pBankBranch
		END		
		ELSE IF @deliveryMethod = 'Cash Payment' AND @transferAmt > 100400
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
	
	IF @flag = 'ac-bal'
	BEGIN
		SELECT 
			 availableBal	= ISNULL(dbo.FNAGetLimitBal(@settlingAgent), 0)
			,balCurrency	= cm.currencyCode
			,limExpiry		= ISNULL(CONVERT(VARCHAR, expiryDate, 101), 'N/A')
		FROM creditLimit cl
		LEFT JOIN currencyMaster cm WITH(NOLOCK) ON cl.currency = cm.currencyId
		WHERE agentId = @settlingAgent
	END
END




GO
