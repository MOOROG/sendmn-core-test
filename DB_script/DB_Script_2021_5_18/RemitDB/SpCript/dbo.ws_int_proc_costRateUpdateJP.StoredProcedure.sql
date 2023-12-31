USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_costRateUpdateJP]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_int_proc_costRateUpdateJP]
	 @accesscode	VARCHAR(50)
	,@username		VARCHAR(50)
	,@password		VARCHAR(50)
	,@AGENT_REFID	VARCHAR(50)
	,@cost			FLOAT

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	DECLARE @errorTable TABLE(AGENT_REFID VARCHAR(150), cost FLOAT)
	INSERT INTO @errorTable(AGENT_REFID, cost)
	SELECT @AGENT_REFID, @cost
	
	DECLARE @errCode INT, @autMsg	VARCHAR(500), @errorCode VARCHAR(10), @errorMsg VARCHAR(MAX)
	EXEC ws_int_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT
	
	IF (@errCode = 1 )
	BEGIN     --1002
		SELECT @errorCode = '102', @errorMsg = ISNULL(@autMsg, 'Authentication Fail')
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	CREATE TABLE #defExRateIdTemp(defExRateId INT)
	CREATE TABLE #exRateIdTempMain(exRateTreasuryId INT)
	CREATE TABLE #exRateIdTempMod(exRateTreasuryId INT)

	DECLARE @cCountry INT, @cAgent INT, @defExRateId INT
	SELECT @cCountry = 113
	SELECT @cAgent = 4846

	SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE country = @cCountry AND agent = @cAgent AND currency = 'JPY'
	DECLARE @cRate FLOAT
	SET @cRate = @cost
	IF @defExRateId IS NULL
		RETURN
	
	BEGIN TRAN
		--Currency Rate/ Agent Rate Update------------------------------------------------------------------------------------		
		UPDATE defExRate SET
			 cRate				= ISNULL(@cost, 0)
			,modifiedBy			= @username
			,modifiedDate		= GETDATE()					
		WHERE defExRateId = @defExRateId			

		--Change Record History-----------------------------------------------------------------------------------------------
		INSERT INTO defExRateHistory(						
			 defExRateId 
			,setupType
			,currency,country,agent,baseCurrency,tranType,factor
			,cRate,cMargin,cMax,cMin
			,pRate,pMargin,pMax,pMin
			,isEnable,createdBy,createdDate,approvedBy,approvedDate,modType
		)
		SELECT
			 @defExRateId
			,main.setupType
			,main.currency,main.country,main.agent,main.baseCurrency,main.tranType,factor
			,cRate,cMargin,cMax,cMin
			,pRate,pMargin,pMax,pMin
			,isEnable,@username,GETDATE(),@username,GETDATE(),'U'
		FROM defExRate main WITH(NOLOCK) WHERE defExRateId = @defExRateId


		--1. Get All Corridor records affected by receive cost rate change
		DELETE FROM #exRateIdTempMain
		INSERT INTO #exRateIdTempMain
		SELECT exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE cRateId = @defExRateId

		--2. Update Records in Mod Table if data already exist in mod table	
		IF EXISTS(SELECT 'X' FROM exRateTreasuryMod mode WITH(NOLOCK) INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId)
		BEGIN
			DELETE FROM #exRateIdTempMod
			INSERT INTO #exRateIdTempMod
			SELECT mode.exRateTreasuryId FROM exRateTreasuryMod mode WITH(NOLOCK)
			INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId
			
			UPDATE ert SET
				 cRate			= @cRate
				,cMargin		= ert.cMargin
				,maxCrossRate	= ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
				,crossRate		= ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + ert.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((def.pRate - ert.pMargin - pHoMargin - pAgentMargin)/(@cRate + ert.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
									WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + ert.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
				,createdBy		= @username
				,createdDate	= GETDATE()
			FROM exRateTreasuryMod ert
			INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
			INNER JOIN #exRateIdTempMod temp ON ert.exRateTreasuryId = temp.exRateTreasuryId
		END

		--3. Update Record in main table
		UPDATE ert SET
			 cRate				= @cRate
			,pMargin			= ert.cMargin
			,maxCrossRate		= ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
			,crossRate			= ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + ert.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
			--,customerRate		= ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
			,customerRate		= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + ert.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
									WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + ert.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
			,modifiedBy			= @username
			,modifiedDate		= GETDATE()
		FROM exRateTreasury ert
		INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
		WHERE cRateId = @defExRateId
	COMMIT TRAN
	
	SELECT @cRate COST
END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
ROLLBACK TRAN

SELECT @errorCode = '9001', @errorMsg = 'Technical Error : ' + ERROR_MESSAGE()
SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, * FROM @errorTable
			
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_int_proc_costRateUpdateJP', @USERNAME, GETDATE()

END CATCH 
    


GO
