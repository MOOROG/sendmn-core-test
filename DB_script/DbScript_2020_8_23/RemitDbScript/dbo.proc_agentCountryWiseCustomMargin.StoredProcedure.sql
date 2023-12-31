USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentCountryWiseCustomMargin]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

	EXEC proc_agentCountryWiseCustomMargin @flag = 'approve', @user = 'admin', @agentCountryWiseCustomMarginId = '12'


*/

CREATE proc [dbo].[proc_agentCountryWiseCustomMargin]
	 @flag                                    VARCHAR(50)    = NULL
	,@user                                    VARCHAR(30)    = NULL
	,@agentCountryWiseCustomMarginId          VARCHAR(30)    = NULL
	,@sAgentId                                INT            = NULL
	,@sRate                                   FLOAT          = NULL
	,@sMargin                                 FLOAT          = NULL
	,@sMin                                    FLOAT          = NULL
	,@sMax                                    FLOAT          = NULL
	,@pCountryId                              INT            = NULL
	,@pRate                                   FLOAT          = NULL
	,@pMargin                                 FLOAT          = NULL
	,@pMin                                    FLOAT          = NULL
	,@pMax                                    FLOAT          = NULL
	,@SCRCRate                                FLOAT          = NULL
	,@SCRCMargin                              FLOAT          = NULL
	,@rndSExRate                              INT            = NULL
	,@rndPAmount                              INT            = NULL
	,@createDate                              DATETIME       = NULL
	,@rowId									  INT			= NULL	
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
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
		,@functionId		INT
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		
	SELECT
		 @logIdentifier = 'agentCountryWiseCustomMarginId'
		,@logParamMain = 'agentCountryWiseCustomMargin'
		,@logParamMod = 'agentCountryWiseCustomMarginHistory'
		,@module = '10'
		,@tableAlias = 'Agent Country Exchange Rate'
		
	
	IF @flag IN ('approve', 'reject')
	BEGIN
		SET @agentCountryWiseCustomMarginId = NULL
		SELECT @agentCountryWiseCustomMarginId = agentCountryWiseCustomMarginId FROM agentCountryWiseCustomMarginHistory WHERE rowId = @rowId AND approvedBy IS NULL
	END
	
	IF @flag = 'u'
	BEGIN
		SELECT 
			 @pRate = pRate
			,@sRate = sRate
			,@SCRCRate = SCRCRate	
		FROM agentCountryWiseCustomMargin WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId
		
		SET @SCRCMargin = CAST(ISNULL(ISNULL(@pRate, 0) + ISNULL(@pMargin, 0) / NULLIF(ISNULL(@sRate, 0) + ISNULL(@sMargin, 0), 0), 0) - ISNULL(@SCRCRate, 0) AS DECIMAL(38, 4))
	
	END
	
	IF @flag = 'i'
	BEGIN
		
		IF EXISTS(SELECT 'X' FROM agentCountryWiseCustomMargin WITH(NOLOCK) WHERE sAgentId = @sAgentId AND pCountryId = @pCountryId)
		BEGIN
			EXEC proc_errorHandler 1, 'Duplicate agent - country combination.', @agentCountryWiseCustomMarginId
			RETURN;			
		END
		BEGIN TRANSACTION
			INSERT INTO agentCountryWiseCustomMargin (
				 sAgentId
				,sRate
				,SMargin
				,sMin
				,sMax
				,pCountryId
				,pRate
				,pMargin
				,pMin
				,pMax
				,SCRCRate
				,SCRCMargin
				,rndSExRate
				,rndPAmount
				,createdBy
				,createdDate
			)
			SELECT
				 @sAgentId
				,@sRate
				,@SMargin
				,@sMin
				,@sMax
				,@pCountryId
				,@pRate
				,@pMargin
				,@pMin
				,@pMax
				,@SCRCRate
				,@SCRCMargin
				,@rndSExRate
				,@rndPAmount				
				,@user
				,GETDATE()
				
			SET @agentCountryWiseCustomMarginId = SCOPE_IDENTITY()			
			
			INSERT INTO agentCountryWiseCustomMarginHistory(
					 agentCountryWiseCustomMarginId
					,sAgentId
					,sRate
					,sMargin
					,sMin
					,sMax
					,pCountryId
					,pRate
					,pMargin
					,pMin
					,pMax
					,SCRCRate
					,SCRCMargin
					,rndSExRate
					,rndPAmount
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @agentCountryWiseCustomMarginId
					,@sAgentId
					,@sRate
					,@sMargin
					,@sMin
					,@sMax
					,@pCountryId
					,@pRate
					,@pMargin
					,@pMin
					,@pMax
					,@SCRCRate
					,@SCRCMargin
					,@rndSExRate
					,@rndPAmount
					,@user
					,GETDATE()
					,'insert'			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentCountryWiseCustomMarginId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMarginHistory WITH(NOLOCK)
				WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND createdBy = @user
		)		
		BEGIN
			SELECT
				mode.*
			FROM agentCountryWiseCustomMarginHistory mode WITH(NOLOCK)
			INNER JOIN agentCountryWiseCustomMargin main WITH(NOLOCK) ON mode.agentCountryWiseCustomMarginId = main.agentCountryWiseCustomMarginId
			WHERE mode.agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM agentCountryWiseCustomMargin WITH(NOLOCK) WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId
		END
	END
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMargin WITH(NOLOCK)
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentCountryWiseCustomMarginId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentCountryWiseCustomMarginId  = @agentCountryWiseCustomMarginId AND (createdBy <> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentCountryWiseCustomMarginId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (
				SELECT 'X' FROM agentCountryWiseCustomMargin WITH(NOLOCK)
				WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND ( createdBy = @user AND approvedBy IS NULL)
			)
			BEGIN
				UPDATE agentCountryWiseCustomMargin SET
					 sMargin = @sMargin					
					,pMargin = @pMargin
					,SCRCMargin = @SCRCMargin								
					,createdDate = GETDATE()
					,createdBy = @user					
				FROM agentCountryWiseCustomMargin 
				WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId 
			END			
				
			DELETE FROM agentCountryWiseCustomMarginHistory WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND approvedBy IS NULL
			
			INSERT INTO agentCountryWiseCustomMarginHistory(
				 agentCountryWiseCustomMarginId
				,sAgentId
				,sRate
				,sMargin
				,sMin
				,sMax
				,pCountryId
				,pRate
				,pMargin
				,pMin
				,pMax
				,SCRCRate
				,SCRCMargin
				,rndSExRate
				,rndPAmount
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 @agentCountryWiseCustomMarginId
				,sAgentId
				,sRate
				,@sMargin
				,sMin
				,sMax
				,pCountryId
				,pRate
				,@pMargin
				,pMin
				,pMax
				,SCRCRate
				,SCRCMargin
				,rndSExRate
				,rndPAmount
				,@user
				,GETDATE()
				,'update'
			FROM agentCountryWiseCustomMargin
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentCountryWiseCustomMarginId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMargin WITH(NOLOCK)
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @agentCountryWiseCustomMarginId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMarginHistory  WITH(NOLOCK)
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @agentCountryWiseCustomMarginId
			RETURN
		END
		
		INSERT INTO agentCountryWiseCustomMarginHistory(
			 agentCountryWiseCustomMarginId
			,sAgentId
			,sRate
			,sMargin
			,sMin
			,sMax
			,pCountryId
			,pRate
			,pMargin
			,pMin
			,pMax
			,SCRCRate
			,SCRCMargin
			,rndSExRate
			,rndPAmount
			,createdBy
			,createdDate
			,modType
		)
		SELECT
			 @agentCountryWiseCustomMarginId
			,sAgentId
			,sRate
			,sMargin
			,sMin
			,sMax
			,pCountryId
			,pRate
			,pMargin
			,pMin
			,pMax
			,SCRCRate
			,SCRCMargin
			,rndSExRate
			,rndPAmount
			,@user
			,GETDATE()
			,'delete'
		FROM agentCountryWiseCustomMarginHistory 
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentCountryWiseCustomMarginId
	END
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentCountryWiseCustomMarginId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM agentCountryWiseCustomMargin WHERE approvedBy IS NULL AND agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCountryWiseCustomMarginId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentCountryWiseCustomMarginId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentCountryWiseCustomMarginId
					RETURN
				END
				DELETE FROM agentCountryWiseCustomMargin WHERE agentCountryWiseCustomMarginId=  @agentCountryWiseCustomMarginId
				DELETE FROM agentCountryWiseCustomMarginHistory WHERE agentCountryWiseCustomMarginId =  @agentCountryWiseCustomMarginId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCountryWiseCustomMarginId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentCountryWiseCustomMarginId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentCountryWiseCustomMarginId
					RETURN
				END
				DELETE FROM agentCountryWiseCustomMarginHistory WHERE agentCountryWiseCustomMarginId=  @agentCountryWiseCustomMarginId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @agentCountryWiseCustomMarginId
	END
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentCountryWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentCountryWiseCustomMarginId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentCountryWiseCustomMargin WHERE approvedBy IS NULL AND agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId )
				SET @modType = 'insert'
			ELSE
				SELECT @modType = modType FROM agentCountryWiseCustomMarginHistory WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND approvedBy IS NULL
			IF @modType = 'insert'
			BEGIN --New record
				UPDATE agentCountryWiseCustomMargin SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId				
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCountryWiseCustomMarginId, @newValue OUTPUT
			END
			ELSE IF @modType = 'update'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCountryWiseCustomMarginId, @oldValue OUTPUT
				UPDATE main SET
					 main.sMargin = mode.SMargin					
					,main.pMargin = mode.pMargin									
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				FROM agentCountryWiseCustomMargin main
				INNER JOIN agentCountryWiseCustomMarginHistory mode ON mode.agentCountryWiseCustomMarginId = main.agentCountryWiseCustomMarginId
				WHERE mode.agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'agentCountryWiseCustomMargin', 'agentCountryWiseCustomMarginId', @agentCountryWiseCustomMarginId, @newValue OUTPUT
			END
			ELSE IF @modType = 'delete'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCountryWiseCustomMarginId, @oldValue OUTPUT
				UPDATE agentCountryWiseCustomMargin SET
					isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId
			END
			
			UPDATE agentCountryWiseCustomMarginHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE agentCountryWiseCustomMarginId = @agentCountryWiseCustomMarginId AND approvedBy IS NULL 
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentCountryWiseCustomMarginId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @agentCountryWiseCustomMarginId
				RETURN
			END
			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @agentCountryWiseCustomMarginId
	END	
	ELSE IF @flag = 's'
	BEGIN
		SELECT
			 countryId
			,ccm.countryName
			,agentId	
			,am.agentName	
		FROM agentMaster am WITH(NOLOCK)
		INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON am.agentCountry = ccm.countryId
		ORDER BY ccm.countryName, am.agentName
	END
	ELSE IF @flag = 'cl'
	BEGIN
		SELECT
			 x.agentCountryWiseCustomMarginId 
			,s.agentId
			,sAgent = s.agentName
			,sCurr = s1.currCode
			,sCountry = s1.countryName		
			,x.sRate
			,sMargin = ISNULL(x.sMargin, 0)
			,sBid = ISNULL(x.sRate, 0) + ISNULL(x.sMargin, 0)
			,x.sMax
			,x.sMin
			
			,p.countryId
			,pCountry = p.countryName
			,pCurr = p.currCode
			,x.pRate
			,pMargin = ISNULL(x.pMargin, 0)
			,pBid = ISNULL(x.pRate, 0) + ISNULL(x.pMargin, 0)
			,x.pMax 
			,x.pMin		
					
			,x.SCRCRate
			,SCRCMargin = ISNULL(x.SCRCMargin, 0)
			,SCRCBid = ISNULL(x.SCRCRate, 0) + ISNULL(x.SCRCMargin, 0)
			,x.modifiedBy
			,x.modifiedDate
		FROM (
			SELECT 
				acwcmh.agentCountryWiseCustomMarginId 
				,acwcmh.sAgentId
				,acwcmh.pCountryId
				,acwcmh.sRate
				,acwcmh.sMargin
				,acwcmh.sMax
				,acwcmh.sMin
				,acwcmh.pRate		
				,acwcmh.pMargin
				,acwcmh.pMax 
				,acwcmh.pMin
				,acwcmh.SCRCRate
				,acwcmh.SCRCMargin
				,acwcm.modifiedBy
				,acwcm.modifiedDate
			FROM agentCountryWiseCustomMarginHistory acwcmh WITH(NOLOCK)
			INNER JOIN agentCountryWiseCustomMargin acwcm WITH(NOLOCK) ON acwcmh.agentCountryWiseCustomMarginId = acwcm.agentCountryWiseCustomMarginId AND acwcmh.approvedBy IS NULL AND acwcmh.createdBy = @user	
			WHERE acwcm.sAgentId = @sAgentId AND  acwcmh.approvedBy IS NULL
			
			UNION ALL
			SELECT 
				 agentCountryWiseCustomMarginId
				,sAgentId
				,pCountryId
				,sRate
				,sMargin
				,sMax
				,sMin
				,pRate
				,pMargin
				,pMax 
				,pMin	
				,SCRCRate
				,SCRCMargin
				,modifiedBy
				,modifiedDate
			FROM agentCountryWiseCustomMargin WITH(NOLOCK) WHERE sAgentId = @sAgentId
			AND agentCountryWiseCustomMarginId NOT IN (SELECT agentCountryWiseCustomMarginId FROM agentCountryWiseCustomMarginHistory WHERE sAgentId = @sAgentId AND approvedBy IS NULL AND createdBy = @user)
			
		) x
		INNER JOIN countryCurrencyMaster p WITH(NOLOCK) ON x.pCountryId = p.countryId
		INNER JOIN agentMaster s WITH(NOLOCK) ON x.sAgentId = s.agentId
		INNER JOIN countryCurrencyMaster s1 WITH(NOLOCK) ON s.agentCountry = s1.countryId
		ORDER BY p.countryName ASC
	END
	
	ELSE IF @flag IN ('p') --change approval pedning
	BEGIN
		SELECT
			 acwcmh.rowId
			,acwcmh.agentCountryWiseCustomMarginId 
			,s.agentId
			,sAgent = s.agentName
			,sCurr = sc.currCode
			,sCountry = sc.countryName		
			,acwcmh.sRate
			,sMargin = ISNULL(acwcmh.sMargin, 0)
			,sBid = ISNULL(acwcmh.sRate, 0) + ISNULL(acwcmh.sMargin, 0)
			,acwcmh.sMax
			,acwcmh.sMin
			
			,p.countryId
			,pCountry = p.countryName
			,pCurr = p.currCode
			,acwcmh.pRate
			,pMargin = ISNULL(acwcmh.pMargin, 0)
			,pBid = ISNULL(acwcmh.pRate, 0) + ISNULL(acwcmh.pMargin, 0)
			,acwcmh.pMax 
			,acwcmh.pMin		
					
			,acwcmh.SCRCRate
			,SCRCMargin = ISNULL(acwcmh.SCRCMargin, 0)
			,SCRCBid = ISNULL(acwcmh.SCRCRate, 0) + ISNULL(acwcmh.SCRCMargin, 0)
			,acwcmh.createdBy
			,acwcmh.createdDate
		FROM agentCountryWiseCustomMarginHistory acwcmh WITH(NOLOCK)
		INNER JOIN countryCurrencyMaster p WITH(NOLOCK) ON acwcmh.pCountryId = p.countryId
		INNER JOIN agentMaster s WITH(NOLOCK) ON acwcmh.sAgentId = s.agentId
		INNER JOIN countryCurrencyMaster sc WITH(NOLOCK) ON sc.countryId = s.agentCountry

		WHERE acwcmh.approvedBy IS NULL
		ORDER BY acwcmh.createdDate DESC
	END	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentCountryWiseCustomMarginId
END CATCH





GO
