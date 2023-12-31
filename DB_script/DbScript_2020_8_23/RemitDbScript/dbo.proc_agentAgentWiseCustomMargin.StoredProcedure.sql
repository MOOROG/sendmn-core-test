USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentAgentWiseCustomMargin]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentAgentWiseCustomMargin]
	 @flag                                    VARCHAR(50)    = NULL
	,@user                                    VARCHAR(30)    = NULL
	,@agentAgentWiseCustomMarginId          VARCHAR(30)    = NULL
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
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql			VARCHAR(MAX)
		,@oldValue		VARCHAR(MAX)
		,@newValue		VARCHAR(MAX)
		,@module		VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table			VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@functionId		INT
		,@id			VARCHAR(10)
		,@modType		VARCHAR(6)
		
	SELECT
		 @logIdentifier = 'agentAgentWiseCustomMarginId'
		,@logParamMain = 'agentAgentWiseCustomMargin'
		,@logParamMod = 'agentAgentWiseCustomMarginHistory'
		,@module = '10'
		,@tableAlias = 'Agent Country Exchange Rate'
		
	
	
	IF @flag = 'u'
	BEGIN
		SELECT 
			 @pRate = pRate
			,@sRate = sRate
			,@SCRCRate = SCRCRate	
		FROM agentAgentWiseCustomMargin WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId
		
		SET @SCRCMargin = CAST(ISNULL(ISNULL(@pRate, 0) + ISNULL(@pMargin, 0) / NULLIF(ISNULL(@sRate, 0) + ISNULL(@sMargin, 0), 0), 0) - ISNULL(@SCRCRate, 0) AS DECIMAL(38, 4))
	
	END
	
	IF @flag = 'i'
	BEGIN
		
		IF EXISTS(SELECT 'X' FROM agentAgentWiseCustomMargin WITH(NOLOCK) WHERE sAgentId = @sAgentId AND pCountryId = @pCountryId)
		BEGIN
			EXEC proc_errorHandler 1, 'Duplicate agent - country combination.', @agentAgentWiseCustomMarginId
			RETURN;			
		END
		BEGIN TRANSACTION
			INSERT INTO agentAgentWiseCustomMargin (
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
				
			SET @agentAgentWiseCustomMarginId = SCOPE_IDENTITY()			
			
			INSERT INTO agentAgentWiseCustomMarginHistory(
					 agentAgentWiseCustomMarginId
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
					 @agentAgentWiseCustomMarginId
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
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentAgentWiseCustomMarginId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMarginHistory WITH(NOLOCK)
				WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND createdBy = @user
		)		
		BEGIN
			SELECT
				mode.*
			FROM agentAgentWiseCustomMarginHistory mode WITH(NOLOCK)
			INNER JOIN agentAgentWiseCustomMargin main WITH(NOLOCK) ON mode.agentAgentWiseCustomMarginId = main.agentAgentWiseCustomMarginId
			WHERE mode.agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM agentAgentWiseCustomMargin WITH(NOLOCK) WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId
		END
	END
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMargin WITH(NOLOCK)
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentAgentWiseCustomMarginId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentAgentWiseCustomMarginId  = @agentAgentWiseCustomMarginId AND (createdBy <> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentAgentWiseCustomMarginId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (
				SELECT 'X' FROM agentAgentWiseCustomMargin WITH(NOLOCK)
				WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND ( createdBy = @user AND approvedBy IS NULL)
			)
			BEGIN
				UPDATE agentAgentWiseCustomMargin SET
					 sMargin = @sMargin					
					,pMargin = @pMargin
					,SCRCMargin = @SCRCMargin								
					,createdDate = GETDATE()
					,createdBy = @user					
				FROM agentAgentWiseCustomMargin 
				WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId 
			END			
				
			DELETE FROM agentAgentWiseCustomMarginHistory WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL
			
			INSERT INTO agentAgentWiseCustomMarginHistory(
				 agentAgentWiseCustomMarginId
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
				 @agentAgentWiseCustomMarginId
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
			FROM agentAgentWiseCustomMargin
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentAgentWiseCustomMarginId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMargin WITH(NOLOCK)
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @agentAgentWiseCustomMarginId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMarginHistory  WITH(NOLOCK)
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @agentAgentWiseCustomMarginId
			RETURN
		END
		
		INSERT INTO agentAgentWiseCustomMarginHistory(
			 agentAgentWiseCustomMarginId
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
			 @agentAgentWiseCustomMarginId
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
		FROM agentAgentWiseCustomMarginHistory 
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentAgentWiseCustomMarginId
	END
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentAgentWiseCustomMarginId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM agentAgentWiseCustomMargin WHERE approvedBy IS NULL AND agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentAgentWiseCustomMarginId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentAgentWiseCustomMarginId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentAgentWiseCustomMarginId
					RETURN
				END
				DELETE FROM agentAgentWiseCustomMargin WHERE agentAgentWiseCustomMarginId=  @agentAgentWiseCustomMarginId
				DELETE FROM agentAgentWiseCustomMarginHistory WHERE agentAgentWiseCustomMarginId =  @agentAgentWiseCustomMarginId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentAgentWiseCustomMarginId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentAgentWiseCustomMarginId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentAgentWiseCustomMarginId
					RETURN
				END
				DELETE FROM agentAgentWiseCustomMarginHistory WHERE agentAgentWiseCustomMarginId=  @agentAgentWiseCustomMarginId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @agentAgentWiseCustomMarginId
	END
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentAgentWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentAgentWiseCustomMarginId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentAgentWiseCustomMargin WHERE approvedBy IS NULL AND agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId )
				SET @modType = 'insert'
			ELSE
				SELECT @modType = modType FROM agentAgentWiseCustomMarginHistory WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL
			IF @modType = 'insert'
			BEGIN --New record
				UPDATE agentAgentWiseCustomMargin SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId				
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentAgentWiseCustomMarginId, @newValue OUTPUT
			END
			ELSE IF @modType = 'update'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentAgentWiseCustomMarginId, @oldValue OUTPUT
				UPDATE main SET
					 main.sMargin = mode.SMargin					
					,main.pMargin = mode.pMargin									
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				FROM agentAgentWiseCustomMargin main
				INNER JOIN agentAgentWiseCustomMarginHistory mode ON mode.agentAgentWiseCustomMarginId = main.agentAgentWiseCustomMarginId
				WHERE mode.agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'agentAgentWiseCustomMargin', 'agentAgentWiseCustomMarginId', @agentAgentWiseCustomMarginId, @newValue OUTPUT
			END
			ELSE IF @modType = 'delete'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentAgentWiseCustomMarginId, @oldValue OUTPUT
				UPDATE agentAgentWiseCustomMargin SET
					isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId
			END
			DELETE FROM agentAgentWiseCustomMarginHistory WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentAgentWiseCustomMarginId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @agentAgentWiseCustomMarginId
				RETURN
			END
			
			UPDATE agentAgentWiseCustomMarginHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE agentAgentWiseCustomMarginId = @agentAgentWiseCustomMarginId AND approvedBy IS NULL 
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @agentAgentWiseCustomMarginId
	END	
	ELSE IF @flag = 's'
	BEGIN
		SELECT
			 COUNTRY_ID
			,ccm.COUNTRY_NAME
			,AGENT_ID	
			,am.AGENT_NAME	
		FROM agentMaster am WITH(NOLOCK)
		INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON am.AGENT_COUNTRY = ccm.COUNTRY_ID
		ORDER BY ccm.COUNTRY_NAME, am.AGENT_NAME
	END
	ELSE IF @flag = 'cl'
	BEGIN
	SELECT
		 x.agentAgentWiseCustomMarginId 
		,s.AGENT_ID
		,sAgent = s.AGENT_NAME
		,sCurr = s1.CURR_CODE
		,sCountry = s1.COUNTRY_NAME		
		,x.sRate
		,sMargin = ISNULL(x.sMargin, 0)
		,sBid = ISNULL(x.sRate, 0) + ISNULL(x.sMargin, 0)
		,x.sMax
		,x.sMin
		
		,p.COUNTRY_ID
		,pCountry = p.COUNTRY_NAME
		,pCurr = p.CURR_CODE
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
			acwcmh.agentAgentWiseCustomMarginId 
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
		FROM agentAgentWiseCustomMarginHistory acwcmh WITH(NOLOCK)
		INNER JOIN agentAgentWiseCustomMargin acwcm WITH(NOLOCK) ON acwcmh.agentAgentWiseCustomMarginId = acwcm.agentAgentWiseCustomMarginId AND acwcmh.approvedBy IS NULL AND acwcmh.createdBy = @user	
		WHERE acwcm.sAgentId = @sAgentId AND  acwcmh.approvedBy IS NULL
		
		UNION ALL
		SELECT 
			 agentAgentWiseCustomMarginId
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
		FROM agentAgentWiseCustomMargin WITH(NOLOCK) WHERE sAgentId = @sAgentId
		AND agentAgentWiseCustomMarginId NOT IN (SELECT agentAgentWiseCustomMarginId FROM agentAgentWiseCustomMarginHistory WHERE sAgentId = @sAgentId AND approvedBy IS NULL AND createdBy = @user)
		
	) x
	INNER JOIN countryCurrencyMaster p WITH(NOLOCK) ON x.pCountryId = p.COUNTRY_ID
	INNER JOIN agentMaster s WITH(NOLOCK) ON x.sAgentId = s.AGENT_ID
	INNER JOIN countryCurrencyMaster s1 WITH(NOLOCK) ON s.AGENT_COUNTRY = s1.COUNTRY_ID
END
	

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentAgentWiseCustomMarginId
END CATCH



GO
