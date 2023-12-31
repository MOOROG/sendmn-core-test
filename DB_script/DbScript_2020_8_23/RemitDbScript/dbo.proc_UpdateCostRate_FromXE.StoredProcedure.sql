USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_UpdateCostRate_FromXE]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_UpdateCostRate_FromXE]
@FromCurr	 VARCHAR(5) = NULL,
@toCurr		 VARCHAR(5) = NULL,
@LiveRate	 FLOAT = NULL,
@requestXml	 VARCHAR(MAX) = NULL,
@responseXml VARCHAR(MAX) = NULL,
@flag		varchar(10)

AS
SET NOCOUNT ON;

	--select @FromCurr,@toCurr,@cRate
	--return

BEGIN TRY
	declare @defExRateId int ,@user varchar(50) = 'system',@msg varchar(max) = ''

	INSERT INTO tlbExrateApilogs(requestXml,responseXml,createdBy)
	SELECT @requestXml,@responseXml,@user

	IF @FromCurr = 'error'
	BEGIN
		EXEC proc_errorHandler 1,@responseXml, NULL
		----## SEND SMS THROUGH KT NETWORK
		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		select 'globalmoney',0,'XE',left(@responseXml,90),format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
		union all 
		select 'globalmoney',0,'XE',left(@responseXml,90),format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

		RETURN
	END

	
	IF ISNULL(@LiveRate, 0) = 0
	BEGIN
		
		SET @MSG = 'Sorry 0 ex rate for ' + @toCurr + ' can not be updated';

		
		----## SEND SMS THROUGH KT NETWORK
		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		select 'globalmoney',0,'XE','Sorry 0 ex rate can not be updated',format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','1^01021958106'
		union all 
		select 'globalmoney',0,'XE',@MSG,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','1^01068992183'

		EXEC proc_errorHandler 1, 'Sorry 0 ex rate can not be updated.', NULL
		RETURN
	END

	DECLARE @currency VARCHAR(5),@cRate FLOAT,@cMargin FLOAT,@pRate FLOAT,@pMargin FLOAT
	DECLARE @tolCMax FLOAT, @tolCMin FLOAT, @tolPMax FLOAT, @tolPMin FLOAT, @errorMsg VARCHAR(200), @id INT

	SELECT @defExRateId = defExRateId,@currency = currency,@cRate = cRate, @cMargin = ISNULL(cMargin,0),@pRate = ISNULL(pRate,0) ,@pMargin = ISNULL(pMargin,0)
	FROM defExRate WITH(NOLOCK) 
	WHERE currency = @toCurr and baseCurrency = @FromCurr

	IF ISNULL(@defExRateId,0) = 0
	BEGIN
		set @msg = 'No cost rate setup found for currency '+@FromCurr+' and '+@toCurr
		EXEC proc_errorHandler 1, @msg, NULL
		----## SEND SMS THROUGH KT NETWORK
		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		select 'globalmoney',0,'XE',@msg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
		union all 
		select 'globalmoney',0,'XE',@msg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

		RETURN
	END

	SELECT 
		@tolCMax = ISNULL(cMax, 0.0)
		,@tolCMin = ISNULL(cMin, 0.0)
		,@tolPMax = ISNULL(pMax, 0.0)
		,@tolPMin = ISNULL(pMin, 0.0)
	FROM rateMask WITH(NOLOCK) WHERE currency = @toCurr AND baseCurrency = @FromCurr

	IF NOT EXISTS(SELECT 'X' FROM rateMask WITH(NOLOCK) WHERE currency = @currency)
	BEGIN
		SET @msg = 'Please define rate mask for currency ' + @currency
		EXEC proc_errorHandler 1, @msg, NULL

		----## SEND SMS THROUGH KT NETWORK
		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		select 'globalmoney',0,'XE',@msg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
		union all 
		select 'globalmoney',0,'XE',@msg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

		RETURN
	END

IF @flag ='BNI'
BEGIN

	SET @cRate = round(@LiveRate,2) - 0.09
			
	IF((@cRate + ISNULL(@pMargin, 0)) > @tolPMax)
	BEGIN
		SET @errorMsg = 'Rate exceeds Max tolerance Rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)	
		EXEC proc_errorHandler 1, @errorMsg, NULL
				
		----## SEND SMS THROUGH KT NETWORK
		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
		union all 
		select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'
		RETURN
	END 
	IF((@cRate + ISNULL(@pMargin, 0)) < @tolPMin)
	BEGIN
		SET @errorMsg = 'Rate exceeds Min tolerance Rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
		EXEC proc_errorHandler 1, @errorMsg, NULL

		----## SEND SMS THROUGH KT NETWORK
		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
		union all 
		select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

		RETURN
	END

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
		,@cRate,pMargin,pMax,pMin
		,isEnable,@user,GETDATE(),@user,GETDATE(),'U'
	FROM defExRate main WITH(NOLOCK) WHERE defExRateId = @defExRateId

	UPDATE defExRate SET pRate = @cRate WHERE defExRateId = @defExRateId

	EXEC proc_errorHandler 0, 'Record updated successfully.', @defExRateId

	RETURN
END	
		
		IF @flag = 'C'
		BEGIN
			--Collection
			SET @cRate = round(@LiveRate,2) + 1
			
			IF((@cRate + ISNULL(@cMargin, 0)) > @tolCMax)
			BEGIN
				SET @errorMsg = 'Rate exceeds Max tolerance Rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' AND ' + CAST(@tolCMax AS VARCHAR)	
				EXEC proc_errorHandler 1, @errorMsg, NULL
				
				----## SEND SMS THROUGH KT NETWORK
				--INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
				--union all 
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'
				RETURN
			END 
			IF((@cRate + ISNULL(@cMargin, 0)) < @tolCMin)
			BEGIN
				SET @errorMsg = 'Rate exceeds Min tolerance Rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' AND ' + CAST(@tolCMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL

				----## SEND SMS THROUGH KT NETWORK
				--INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
				--union all 
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

				RETURN
			END
		END	
		IF @flag = 'P'
		BEGIN
			--Collection
			SET @pRate = round(@LiveRate,2) - 0.70
			
			IF((@pRate - ISNULL(@pMargin, 0)) > @tolPMax)
			BEGIN
				SET @errorMsg = 'Rate exceeds Max tolerance Rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL

				----## SEND SMS THROUGH KT NETWORK
				--INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
				--union all 
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

				RETURN
			END
			IF((@pRate - ISNULL(@pMargin, 0)) < @tolPMin)
			BEGIN
				SET @errorMsg = 'Rate exceeds Min tolerance Rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL

				----## SEND SMS THROUGH KT NETWORK
				--INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01021958106'
				--union all 
				--select 'globalmoney',0,'XE',@errorMsg,format(getdate(),'yyyyMMddHHmmss'),format(getdate(),'yyyyMMddHHmmss'),'1588-6864','gme^01068992183'

				RETURN
			END
		END	

		CREATE TABLE #exRateIdTempMain(exRateTreasuryId INT)
		CREATE TABLE #exRateIdTempMod(exRateTreasuryId INT)

		BEGIN TRANSACTION	
				--Currency Rate/ Agent Rate Update------------------------------------------------------------------------------------		
				UPDATE defExRate SET
					cRate				= @cRate
					,pRate				= @pRate
					,modifiedBy			= @user
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
					,@cRate,@cMargin,cMax,cMin
					,@pRate,@pMargin,pMax,pMin
					,isEnable,@user,GETDATE(),@user,GETDATE(),'U'
				FROM defExRate main WITH(NOLOCK) WHERE defExRateId = @defExRateId
			
			IF @flag = 'C'
			BEGIN
				--1. Get All Corridor records affected by send cost rate change
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
						,cMargin		= @cMargin
						,maxCrossRate	= ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
						,crossRate		= ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0)
											END
						,createdBy		= @user
						,createdDate	= GETDATE()
					FROM exRateTreasuryMod ert
					INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
					INNER JOIN #exRateIdTempMod temp ON ert.exRateTreasuryId = temp.exRateTreasuryId
				END
				
				--3. Update Record in main table for modType Insert.
				UPDATE ert SET
					 cRate			= @cRate
					,cMargin		= @cMargin
					,maxCrossRate	= ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
					,crossRate		= ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					--,customerRate	= ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0)
											END
					,createdBy		= @user
					,createdDate	= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
				WHERE cRateId = @defExRateId AND ert.approvedBy IS NULL

				--4. Insert records in mod table for modType Update.
				INSERT INTO exRateTreasuryMod(
					 exRateTreasuryId
					,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
					,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
					,sharingType,sharingValue,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
					,crossRate,customerRate,maxCrossRate,agentCrossRateMargin,tolerance,crossRateFactor,isActive
					,modType,createdBy,createdDate
				)
				SELECT 
					 exRateTreasuryId
					,ert.cRateId,ert.cCurrency,cCountry,cAgent,cRateFactor,@cRate,@cMargin,cHoMargin,cAgentMargin
					,ert.pRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,def.pRate,def.pMargin,pHoMargin,pAgentMargin
					,ert.sharingType,ert.sharingValue,ert.toleranceOn,ert.agentTolMin,ert.agentTolMax,ert.customerTolMin
					,ert.customerTolMax
					,ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) 
						WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0)  END
					,ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,ert.agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,ert.isActive
					,'U',@user,GETDATE()
				FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN defExRate def WITH(NOLOCK) ON ert.pRateId = def.defExRateId
				WHERE ert.cRateId = @defExRateId AND ert.approvedBy IS NOT NULL AND ISNULL(ert.isActive, 'N') = 'Y'
				AND ert.exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)

				--5. Mark Records as "has been updated"-----------------------------------------------------------------
				UPDATE exRateTreasury SET
					 isUpdated = 'Y'
				WHERE cRateId = @defExRateId AND approvedBy IS NOT NULL AND ISNULL(isActive, 'N') = 'Y'
				AND exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)

			END

			IF @flag = 'P'
			BEGIN
				--1. Get All Corridor records affected by receive cost rate change
				DELETE FROM #exRateIdTempMain
				INSERT INTO #exRateIdTempMain
				SELECT exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE pRateId = @defExRateId
				
				--2. Update Records in Mod Table if data already exist in mod table	
				IF EXISTS(SELECT 'X' FROM exRateTreasuryMod mode WITH(NOLOCK) INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId)
				BEGIN
					DELETE FROM #exRateIdTempMod
					INSERT INTO #exRateIdTempMod
					SELECT mode.exRateTreasuryId FROM exRateTreasuryMod mode WITH(NOLOCK)
					INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId
					
					UPDATE ert SET
						 pRate			= @pRate
						,pMargin		= @pMargin
						,maxCrossRate	= ROUND(@pRate/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
						,crossRate		= ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
						,createdBy		= @user
						,createdDate	= GETDATE()
					FROM exRateTreasuryMod ert
					INNER JOIN defExRate def ON ert.cRateId = def.defExRateId
					INNER JOIN #exRateIdTempMod temp ON ert.exRateTreasuryId = temp.exRateTreasuryId
				END
				
				--3. Update Record in main table for modType Insert.
				UPDATE ert SET
					 pRate			= @pRate
					,pMargin		= @pMargin
					,maxCrossRate	= ROUND(@pRate/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
					,crossRate		= ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					--,customerRate	= ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
					,createdBy		= @user
					,createdDate	= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN defExRate def ON ert.cRateId = def.defExRateId
				WHERE pRateId = @defExRateId AND ert.approvedBy IS NULL
				
				INSERT INTO exRateTreasuryMod(
					 exRateTreasuryId
					,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
					,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
					,sharingType
					,sharingValue
					,toleranceOn
					,agentTolMin
					,agentTolMax
					,customerTolMin
					,customerTolMax
					,crossRate
					,customerRate
					,maxCrossRate
					,agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,isActive
					,modType,createdBy,createdDate
				)
				SELECT 
					 exRateTreasuryId
					,ert.cRateId,ert.cCurrency,cCountry,cAgent,cRateFactor,def.cRate,def.cMargin,cHoMargin,cAgentMargin
					,ert.pRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,@pRate,@pMargin,pHoMargin,pAgentMargin
					,ert.sharingType
					,ert.sharingValue
					,ert.toleranceOn
					,ert.agentTolMin
					,ert.agentTolMax
					,ert.customerTolMin
					,ert.customerTolMax
					,ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(ert.agentCrossRateMargin, 0) END
					,ROUND(@pRate/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,ert.agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,ert.isActive
					,'U',@user,GETDATE()
				FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN defExRate def WITH(NOLOCK) ON ert.cRateId = def.defExRateId
				WHERE ert.pRateId = @defExRateId AND ert.approvedBy IS NOT NULL AND ISNULL(ert.isActive, 'N') = 'Y'
				AND ert.exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)
				
				UPDATE exRateTreasury SET
					 isUpdated = 'Y'
				WHERE pRateId = @defExRateId AND approvedBy IS NOT NULL AND ISNULL(isActive, 'N') = 'Y'
				AND exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)
				
			END
				
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @defExRateId
		
		declare @exRateTreasuryIds varchar(max)=''

		select @exRateTreasuryIds = @exRateTreasuryIds+cast(exRateTreasuryId as varchar)+',' from exRateTreasuryMod(nolock) where createdBy='system'

		set @exRateTreasuryIds = left(@exRateTreasuryIds,len(@exRateTreasuryIds)-1)

		EXEC proc_exRateTreasury @flag = 'approve' , @user ='system',@exRateTreasuryIds = @exRateTreasuryIds

end try
begin catch
	set @errorMsg = error_Message()
	EXEC proc_errorHandler 1,@errorMsg, @defExRateId

end catch


GO
