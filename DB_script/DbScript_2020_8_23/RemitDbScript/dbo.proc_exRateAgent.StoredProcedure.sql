USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_exRateAgent]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec proc_exRateAgent @flag='v',@agentId='3885',@cCurrency='MYR',@pCountry='151',@pCurrency='NPR',@tranType='1'
EXEC proc_serviceTypeMaster 'l2'
*/
CREATE proc [dbo].[proc_exRateAgent]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@cRate								FLOAT			= NULL
	,@pRate								FLOAT			= NULL
	,@cCurrency							VARCHAR(30)		= NULL	
	,@pCountry							INT				= NULL
	,@pCurrency							VARCHAR(50)		= NULL
	,@tranType							INT				= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


BEGIN TRY

	IF @flag = 'v'
	BEGIN	
			DECLARE @pCountryName AS VARCHAR(200),@tranTypeName AS VARCHAR(200)
			SELECT 	@pCountryName=countryName FROM countryMaster WHERE countryId=@pCountry
			SELECT 	@tranTypeName=typeTitle FROM serviceTypeMaster WHERE serviceTypeId=@tranType
			
			SELECT @cCurrency cCurrency
					,@pCountryName pCountry
					,@pCurrency pCurrency
					,ISNULL(@tranTypeName,'Any') tranType
					,CAST(ISNULL(customerCrossRate, 0) AS DECIMAL(11, 6)) customerCrossRate
			FROM dbo.FNAGetExRateForTran(@agentId, NULL,@pCountry, @cCurrency,@pCurrency,null,@user)
	
	END
	
	ELSE IF @flag = 'lr'
	BEGIN
		DECLARE @defExRateId INT, @agentCountryId INT
		SELECT @agentCountryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
		
		SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @agentId AND country = @agentCountryId
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent IS NULL AND country = @agentCountryId
		
		SELECT 
			 cRate = ag.cRate
			,pRate = ag.pRate - ag.pMargin
			,ag.currency
			,rm.cMin
			,rm.cMax
			,rm.pMin
			,rm.pMax
			,rateMaskBd = ISNULL(CASE WHEN ag.factor = 'M' THEN rm.rateMaskMulBd ELSE rm.rateMaskDivBd END, 6)
			,rateMaskAd = ISNULL(CASE WHEN ag.factor = 'M' THEN rm.rateMaskMulAd ELSE rm.rateMaskDivAd END, 6)
		FROM defExRate ag WITH(NOLOCK)
		LEFT JOIN rateMask rm WITH(NOLOCK) ON ag.currency = rm.currency
		WHERE defExRateId = @defExRateId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		DECLARE @cMax FLOAT, @cMin FLOAT, @pMax FLOAT, @pMin FLOAT
		SELECT 
			@cMax = cu.cMax, @cMin = cu.cMin, @pMax = cu.pMax, @pMin = cu.pMin
		FROM defExRate ag WITH(NOLOCK)
		INNER JOIN defExRate cu WITH(NOLOCK) ON ag.currency = cu.currency AND cu.setupType = 'CU'
		WHERE ag.setupType = 'AG'
		AND ag.agent = @agentId
		AND ISNULL(ag.isEnable, 'N') = 'Y' 
		AND ISNULL(ag.isActive, 'N') = 'Y'
		
		IF @cRate > @cMax
		BEGIN
			EXEC proc_errorHandler 1, 'Collection rate exceeds max tolerance rate', NULL
			RETURN
		END
		IF @cRate < @cMin
		BEGIN
			EXEC proc_errorHandler 1, 'Collection rate deceeds min tolerance rate', NULL
			RETURN
		END
		IF @pRate > @pMax
		BEGIN
			EXEC proc_errorHandler 1, 'Payment rate exceeds max tolerance rate', NULL
			RETURN
		END
		IF @pRate < @pMin
		BEGIN
			EXEC proc_errorHandler 1, 'Payment rate exceeds min tolerance rate', NULL
			RETURN
		END
		
		BEGIN TRANSACTION
			UPDATE defExRate SET
				 cRate		= @cRate
				--,cMargin	= 0
				,pRate		= @pRate
				--,pMargin	= 0
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE setupType = 'AG' 
			AND agent = @agentId 
			AND ISNULL(isEnable, 'N') = 'Y' 
			AND ISNULL(isActive, 'N') = 'Y'
			
			INSERT INTO defExRateHistory(
				 defExRateId
				,setupType
				,currency
				,country
				,agent
				,baseCurrency
				,cRate
				,cMargin
				,pRate
				,pMargin
				,cMax
				,cMin
				,pMax
				,pMin
				,factor
				,isEnable
				,modType
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
			)
			SELECT
				 defExRateId
				,setupType
				,currency
				,country
				,agent
				,baseCurrency
				,@cRate
				,cMargin
				,@pRate
				,pMargin
				,cMax
				,cMin
				,pMax
				,pMin
				,factor
				,isEnable
				,'U'
				,@user
				,GETDATE()
				,@user
				,GETDATE()
			FROM defExRate WITH(NOLOCK) 
			WHERE setupType = 'AG' 
			AND agent = @agentId 
			AND ISNULL(isEnable, 'N') = 'Y' 
			AND ISNULL(isActive, 'N') = 'Y'
		
		COMMIT TRANSACTION
		
		EXEC proc_errorHandler 0, 'Rate updated successfully', NULL
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH



GO
