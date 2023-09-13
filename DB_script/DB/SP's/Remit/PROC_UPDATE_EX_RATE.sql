
ALTER PROC PROC_UPDATE_EX_RATE
(
	@FLAG VARCHAR(20)
	,@USER VARCHAR(60) = NULL
	,@XML NVARCHAR(MAX)	= NULL
	,@SESSION_ID VARCHAR(30) = NULL
	,@IDS VARCHAR(MAX) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @FLAG = 'CLEAR'
	BEGIN
		DELETE FROM TEMP_RATE_UPLOAD WHERE SESSION_ID = @SESSION_ID
	END
	ELSE IF @FLAG = 'U'
	BEGIN
		IF OBJECT_ID('tempdb..#exRate') IS NOT NULL 
			DROP TABLE #exRate

		DELETE FROM TEMP_RATE_UPLOAD WHERE SESSION_ID = @SESSION_ID
		DELETE FROM TEMP_RATE_UPLOAD WHERE DATEDIFF(DAY, UPLOAD_DATE, GETDATE()) >= 1
		
		DECLARE @XMLDATA XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@CODE','VARCHAR(20)') AS 'Code'
					,p.value('@COUNTRY','VARCHAR(100)') AS 'Country'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@CURRENCYPAIR','varchar(10)') AS 'CurrencyPair'
					,p.value('@SETTLMENTRATE','varchar(10)') AS 'SettlementRate'
		INTO #exRate
		FROM @XMLDATA.nodes('/root/row') AS apiStates(p)
		
		SELECT Country,CurrencyPair,SettlementRate 
		INTO #exRate1
		FROM #exRate
		GROUP BY Country,CurrencyPair,SettlementRate

		ALTER TABLE #exRate1 ADD pCountryId INT, sendingCurrency VARCHAR(5), payoutCurrency VARCHAR(5)

		UPDATE ER SET ER.pCountryId = CM.countryId, sendingCurrency = (SELECT fname FROM dbo.SplitToRow('/',CurrencyPair)), 
					payoutCurrency = (SELECT MNAME FROM dbo.SplitToRow('/',CurrencyPair))	
		FROM #exRate1 ER(NOLOCK)
		INNER JOIN dbo.countryMaster CM(NOLOCK) ON CM.countryName = ER.Country

		DELETE FROM #exRate1 WHERE ISNULL(SettlementRate, '') = ''

		INSERT INTO TEMP_RATE_UPLOAD(P_COUNTRY_ID, S_CURRENCY, P_CURRENCY, RATE, UPLOAD_DATE, SESSION_ID)
		SELECT pCountryId, sendingCurrency, payoutCurrency, settlementRate, GETDATE(), @SESSION_ID
		FROM #exRate1
		
		IF NOT EXISTS(SELECT 1 FROM TEMP_RATE_UPLOAD (NOLOCK) WHERE SESSION_ID = @SESSION_ID)
			EXEC PROC_ERRORHANDLER 1, 'No data found!', NULL
		ELSE 
			EXEC PROC_ERRORHANDLER 0, 'Success!', NULL

		SELECT CM.countryName, T.S_CURRENCY, T.P_CURRENCY, D.pRate OldRate, T.RATE NewRate, ROW_ID
		FROM TEMP_RATE_UPLOAD T(NOLOCK)
		INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYID = T.P_COUNTRY_ID
		INNER JOIN defExRate D(NOLOCK) ON T.P_COUNTRY_ID = D.country AND T.S_CURRENCY = D.baseCurrency AND T.P_CURRENCY = D.currency
		WHERE T.SESSION_ID = @SESSION_ID
		ORDER BY OldRate
	END
	ELSE IF @FLAG = 'APPROVE'
	BEGIN	
		DECLARE @TEMP_RATE TABLE(ROW_ID INT)
		DECLARE @sql VARCHAR(MAX) = 'SELECT ROW_ID FROM TEMP_RATE_UPLOAD WITH(NOLOCK) WHERE ROW_ID IN (' + @IDS + ')'

		INSERT @TEMP_RATE
		EXEC (@sql)
		
		BEGIN TRANSACTION
			CREATE TABLE #DEF_EXRATE_IDS(DEF_EXRATE_ID INT, SETTLEMENT_RATE MONEY)
			CREATE TABLE #EXRATE_TREASURY(EXRATE_TREASURY_ID INT)
			CREATE TABLE #EXRATE_TREASURY_MOD(EXRATE_TREASURY_ID INT)

			INSERT INTO #DEF_EXRATE_IDS
			SELECT defExRateId, T.RATE
			FROM defExRate D(NOLOCK)
			INNER JOIN TEMP_RATE_UPLOAD T(NOLOCK) ON T.P_COUNTRY_ID = D.country AND T.S_CURRENCY = D.baseCurrency AND T.P_CURRENCY = D.currency
			INNER JOIN @TEMP_RATE TMP ON TMP.ROW_ID = T.ROW_ID
			WHERE T.SESSION_ID = @SESSION_ID

			WHILE EXISTS (SELECT * FROM #DEF_EXRATE_IDS)
			BEGIN
				DECLARE @DEF_EX_RATE_ID INT, @P_RATE MONEY

				SELECT @DEF_EX_RATE_ID = DEF_EXRATE_ID, @P_RATE = SETTLEMENT_RATE
				FROM #DEF_EXRATE_IDS

				--Currency Rate/ Agent Rate Update------------------------------------------------------------------------------------		
				UPDATE defExRate SET
					pRate				= ISNULL(@P_RATE, 0)
					,modifiedBy			= @USER
					,modifiedDate		= GETDATE()					
				WHERE defExRateId = @DEF_EX_RATE_ID			
				
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
						@DEF_EX_RATE_ID
					,main.setupType
					,main.currency,main.country,main.agent,main.baseCurrency,main.tranType,factor
					,cRate,cMargin,cMax,cMin
					,@P_RATE,pMargin,pMax,pMin
					,isEnable,@USER,GETDATE(),@USER,GETDATE(),'U'
				FROM defExRate main WITH(NOLOCK) WHERE defExRateId = @DEF_EX_RATE_ID

				--GET ALL THE TREASURY DATA THAT IS AFFECTED BY THIS EXRATE
				DELETE FROM #EXRATE_TREASURY

				INSERT INTO #EXRATE_TREASURY
				SELECT exRateTreasuryId 
				FROM exRateTreasury WITH(NOLOCK) 
				WHERE pRateId = @DEF_EX_RATE_ID

				--UPDATE MODE TABLE IF RECORD IS ALREADY IN MODIFIED STATE(MODIFY REQUEST)
				IF EXISTS(SELECT 'X' FROM exRateTreasuryMod mode WITH(NOLOCK) INNER JOIN #EXRATE_TREASURY temp ON mode.exRateTreasuryId = temp.EXRATE_TREASURY_ID)
				BEGIN
					DELETE FROM #EXRATE_TREASURY_MOD
					
					INSERT INTO #EXRATE_TREASURY_MOD
					SELECT mode.exRateTreasuryId 
					FROM exRateTreasuryMod mode WITH(NOLOCK)
					INNER JOIN #EXRATE_TREASURY temp ON mode.exRateTreasuryId = temp.EXRATE_TREASURY_ID
					
					UPDATE ert SET
						 pRate			= @P_RATE
						,pMargin		= def.pMargin
						,maxCrossRate	= ROUND(@P_RATE/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
						,crossRate		= ROUND((@P_RATE - def.pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@P_RATE - def.pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@P_RATE - def.pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
						,createdBy		= @user
						,createdDate	= GETDATE()
					FROM exRateTreasuryMod ert
					INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
					INNER JOIN #EXRATE_TREASURY_MOD temp ON ert.exRateTreasuryId = temp.EXRATE_TREASURY_ID
				END

				--UPDATE IN MAIN TABLE
				UPDATE ert SET
					maxCrossRate	= ROUND(@P_RATE/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
					,crossRate		= ROUND((@P_RATE - def.pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					--,customerRate	= ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@P_RATE - def.pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@P_RATE - def.pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
					,createdBy		= @user
					,createdDate	= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN defExRate def ON ert.cRateId = def.defExRateId
				WHERE pRateId = @DEF_EX_RATE_ID AND ert.approvedBy IS NULL

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
					,ert.pRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,@P_RATE,def.pMargin,pHoMargin,pAgentMargin
					,ert.sharingType
					,ert.sharingValue
					,ert.toleranceOn
					,ert.agentTolMin
					,ert.agentTolMax
					,ert.customerTolMin
					,ert.customerTolMax
					,ROUND((@P_RATE - def.pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@P_RATE - def.pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@P_RATE - def.pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(ert.agentCrossRateMargin, 0) END
					,ROUND(@P_RATE/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,ert.agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,ert.isActive
					,'U',@user,GETDATE()
				FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN defExRate def WITH(NOLOCK) ON ert.cRateId = def.defExRateId
				WHERE ert.pRateId = @DEF_EX_RATE_ID AND ert.approvedBy IS NOT NULL AND ISNULL(ert.isActive, 'N') = 'Y'
				AND ert.exRateTreasuryId NOT IN (SELECT EXRATE_TREASURY_ID FROM #EXRATE_TREASURY_MOD)

				UPDATE exRateTreasury SET
					 isUpdated = 'Y'
				WHERE pRateId = @DEF_EX_RATE_ID AND approvedBy IS NOT NULL AND ISNULL(isActive, 'N') = 'Y'
				AND exRateTreasuryId NOT IN (SELECT EXRATE_TREASURY_ID FROM #EXRATE_TREASURY_MOD)

				DELETE FROM #DEF_EXRATE_IDS WHERE DEF_EXRATE_ID = @DEF_EX_RATE_ID
			END

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
			
			DELETE FROM TEMP_RATE_UPLOAD WHERE SESSION_ID = @SESSION_ID

			EXEC proc_errorHandler 0, 'Record updated successfully.', @DEF_EX_RATE_ID
		
			DECLARE @EXRATE_TREASURY_IDS VARCHAR(MAX) = ''

			SELECT @EXRATE_TREASURY_IDS = @EXRATE_TREASURY_IDS + CAST(exRateTreasuryId AS VARCHAR) + ',' FROM exRateTreasuryMod(NOLOCK) 

			SET @EXRATE_TREASURY_IDS = LEFT(@EXRATE_TREASURY_IDS, LEN(@EXRATE_TREASURY_IDS)-1)

			EXEC proc_exRateTreasury @flag = 'approve' , @user ='system',@exRateTreasuryIds = @EXRATE_TREASURY_IDS
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT <> 0
			ROLLBACK TRAN
    DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH

--CREATE TABLE TEMP_RATE_UPLOAD
--(
--	ROW_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY
--	,P_COUNTRY_ID INT NULL
--	,S_CURRENCY VARCHAR(10)
--	,P_CURRENCY VARCHAR(10)
--	,RATE FLOAT
--	,UPLOAD_DATE DATETIME
--	,SESSION_ID VARCHAR(30)
--)

