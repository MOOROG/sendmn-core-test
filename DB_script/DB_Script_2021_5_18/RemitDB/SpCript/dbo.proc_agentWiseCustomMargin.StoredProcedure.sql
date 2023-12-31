USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentWiseCustomMargin]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentWiseCustomMargin]
	 @flag                                    VARCHAR(50)    = NULL
	,@user                                    VARCHAR(30)    = NULL
	,@agentWiseCustomMarginId				  VARCHAR(30)    = NULL
	,@sAgentId                                INT            = NULL
	,@sRate                                   FLOAT          = NULL
	,@sMargin                                 FLOAT          = NULL
	,@sMin                                    FLOAT          = NULL
	,@sMax                                    FLOAT          = NULL
	,@pAgentId                                INT            = NULL
	,@pRate                                   FLOAT          = NULL
	,@pMargin                                 FLOAT          = NULL
	,@pMin                                    FLOAT          = NULL
	,@pMax                                    FLOAT          = NULL
	,@SCRCRate                                FLOAT          = NULL
	,@SCRCMargin                              FLOAT          = NULL
	,@rndSExRate                              INT            = NULL
	,@rndPAmount                              INT            = NULL
	,@createDate                              DATETIME       = NULL
	,@rowId									  INT			 = NULL
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
		 @logIdentifier = 'agentWiseCustomMarginId'
		,@logParamMain = 'agentWiseCustomMargin'
		,@logParamMod = 'agentWiseCustomMarginHistory'
		,@module = '10'
		,@tableAlias = 'Agent - Agent Exchange Rate'
	
	
	
	IF @flag IN ('approve', 'reject')
	BEGIN
		SET @agentWiseCustomMarginId = NULL
		SELECT @agentWiseCustomMarginId = agentWiseCustomMarginId FROM agentWiseCustomMarginHistory WHERE rowId = @rowId AND approvedBy IS NULL
	END
		
	IF @flag = 'u'
	BEGIN
		SELECT 
			 @pRate = pRate
			,@sRate = sRate
			,@SCRCRate = SCRCRate	
		FROM agentWiseCustomMargin WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId
	END	
	
	SET @SCRCMargin = CAST(ISNULL(ISNULL(@pRate, 0) + ISNULL(@pMargin, 0) / NULLIF(ISNULL(@sRate, 0) + ISNULL(@sMargin, 0), 0), 0) - ISNULL(@SCRCRate, 0) AS DECIMAL(38, 4))
		
	
	IF @flag = 'i'
	BEGIN
		
		IF EXISTS(SELECT 'X' FROM agentWiseCustomMargin WITH(NOLOCK) WHERE sAgentId = @sAgentId AND pAgentId = @pAgentId)
		BEGIN
			EXEC proc_errorHandler 1, 'Duplicate agent - agent combination.', @agentWiseCustomMarginId
			RETURN;			
		END
		
		IF @sAgentId IS NULL OR @pAgentId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Sending Agent and Payout agent can not be empty.', @agentWiseCustomMarginId
			RETURN;			
		END
		
		BEGIN TRANSACTION
			INSERT INTO agentWiseCustomMargin (
				 sAgentId
				,sRate
				,SMargin
				,sMin
				,sMax
				,pAgentId
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
				,@pAgentId
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
				
			SET @agentWiseCustomMarginId = SCOPE_IDENTITY()			
			
			INSERT INTO agentWiseCustomMarginHistory(
					 agentWiseCustomMarginId
					,sAgentId
					,sRate
					,sMargin
					,sMin
					,sMax
					,pAgentId
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
					 @agentWiseCustomMarginId
					,@sAgentId
					,@sRate
					,@sMargin
					,@sMin
					,@sMax
					,@pAgentId
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
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentWiseCustomMarginId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentWiseCustomMarginHistory WITH(NOLOCK)
				WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND createdBy = @user
		)		
		BEGIN
			SELECT
				mode.*
			FROM agentWiseCustomMarginHistory mode WITH(NOLOCK)
			INNER JOIN agentWiseCustomMargin main WITH(NOLOCK) ON mode.agentWiseCustomMarginId = main.agentWiseCustomMarginId
			WHERE mode.agentWiseCustomMarginId = @agentWiseCustomMarginId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM agentWiseCustomMargin WITH(NOLOCK) WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId
		END
	END
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentWiseCustomMargin WITH(NOLOCK)
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentWiseCustomMarginId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentWiseCustomMarginId  = @agentWiseCustomMarginId AND (createdBy <> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentWiseCustomMarginId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (
				SELECT 'X' FROM agentWiseCustomMargin WITH(NOLOCK)
				WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND ( createdBy = @user AND approvedBy IS NULL)
			)
			BEGIN
				UPDATE agentWiseCustomMargin SET
					 sMargin = @sMargin					
					,pMargin = @pMargin
					,SCRCMargin = @SCRCMargin								
					,createdDate = GETDATE()
					,createdBy = @user					
				FROM agentWiseCustomMargin 
				WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId 
			END			
				
			DELETE FROM agentWiseCustomMarginHistory WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND approvedBy IS NULL
			
			INSERT INTO agentWiseCustomMarginHistory(
				 agentWiseCustomMarginId
				,sAgentId
				,sRate
				,sMargin
				,sMin
				,sMax
				,pAgentId
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
				 @agentWiseCustomMarginId
				,sAgentId
				,sRate
				,@sMargin
				,sMin
				,sMax
				,pAgentId
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
			FROM agentWiseCustomMargin
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentWiseCustomMarginId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentWiseCustomMargin WITH(NOLOCK)
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @agentWiseCustomMarginId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentWiseCustomMarginHistory  WITH(NOLOCK)
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @agentWiseCustomMarginId
			RETURN
		END
		
		INSERT INTO agentWiseCustomMarginHistory(
			 agentWiseCustomMarginId
			,sAgentId
			,sRate
			,sMargin
			,sMin
			,sMax
			,pAgentId
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
			 @agentWiseCustomMarginId
			,sAgentId
			,sRate
			,sMargin
			,sMin
			,sMax
			,pAgentId
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
		FROM agentWiseCustomMarginHistory 
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentWiseCustomMarginId
	END
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentWiseCustomMarginId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM agentWiseCustomMargin WHERE approvedBy IS NULL AND agentWiseCustomMarginId = @agentWiseCustomMarginId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseCustomMarginId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentWiseCustomMarginId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentWiseCustomMarginId
					RETURN
				END
				DELETE FROM agentWiseCustomMargin WHERE agentWiseCustomMarginId=  @agentWiseCustomMarginId
				DELETE FROM agentWiseCustomMarginHistory WHERE agentWiseCustomMarginId =  @agentWiseCustomMarginId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseCustomMarginId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentWiseCustomMarginId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentWiseCustomMarginId
					RETURN
				END
				DELETE FROM agentWiseCustomMarginHistory WHERE agentWiseCustomMarginId=  @agentWiseCustomMarginId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @agentWiseCustomMarginId
	END
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentWiseCustomMarginHistory WITH(NOLOCK)
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentWiseCustomMarginId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentWiseCustomMargin WHERE approvedBy IS NULL AND agentWiseCustomMarginId = @agentWiseCustomMarginId )
				SET @modType = 'insert'
			ELSE
				SELECT @modType = modType FROM agentWiseCustomMarginHistory WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND approvedBy IS NULL
			IF @modType = 'insert'
			BEGIN --New record
				UPDATE agentWiseCustomMargin SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId				
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseCustomMarginId, @newValue OUTPUT
			END
			ELSE IF @modType = 'update'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseCustomMarginId, @oldValue OUTPUT
				UPDATE main SET
					 main.sMargin = mode.SMargin					
					,main.pMargin = mode.pMargin									
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				FROM agentWiseCustomMargin main
				INNER JOIN agentWiseCustomMarginHistory mode ON mode.agentWiseCustomMarginId = main.agentWiseCustomMarginId
				WHERE mode.agentWiseCustomMarginId = @agentWiseCustomMarginId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'agentWiseCustomMargin', 'agentWiseCustomMarginId', @agentWiseCustomMarginId, @newValue OUTPUT
			END
			ELSE IF @modType = 'delete'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseCustomMarginId, @oldValue OUTPUT
				UPDATE agentWiseCustomMargin SET
					isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId
			END
			
			UPDATE agentWiseCustomMarginHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE agentWiseCustomMarginId = @agentWiseCustomMarginId AND approvedBy IS NULL 
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentWiseCustomMarginId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @agentWiseCustomMarginId
				RETURN
			END			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @agentWiseCustomMarginId
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
	ELSE IF @flag = 'al'
		BEGIN
		SELECT
			 x.agentWiseCustomMarginId 
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
			,pAgent = pa.agentName
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
				acwcmh.agentWiseCustomMarginId 
				,acwcmh.sAgentId
				,acwcmh.pAgentId
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
			FROM agentWiseCustomMarginHistory acwcmh WITH(NOLOCK)
			INNER JOIN agentWiseCustomMargin acwcm WITH(NOLOCK) ON acwcmh.agentWiseCustomMarginId = acwcm.agentWiseCustomMarginId AND acwcmh.approvedBy IS NULL AND acwcmh.createdBy = @user	
			WHERE acwcm.sAgentId = @sAgentId AND  acwcmh.approvedBy IS NULL
			
			UNION ALL
			SELECT 
				 agentWiseCustomMarginId
				,sAgentId
				,pAgentId
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
			FROM agentWiseCustomMargin WITH(NOLOCK) WHERE sAgentId = @sAgentId
			AND agentWiseCustomMarginId NOT IN (SELECT agentWiseCustomMarginId FROM agentWiseCustomMarginHistory WHERE sAgentId = @sAgentId AND approvedBy IS NULL AND createdBy = @user)
			
		) x
		INNER JOIN countryCurrencyMaster p WITH(NOLOCK) ON x.pAgentId = p.countryId
		INNER JOIN agentMaster s WITH(NOLOCK) ON x.sAgentId = s.agentId
		INNER JOIN agentMaster pa WITH(NOLOCK) ON x.pAgentId = pa.agentId
		INNER JOIN countryCurrencyMaster s1 WITH(NOLOCK) ON s.agentCountry = s1.countryId
	END
	ELSE IF @flag = 'p'
	BEGIN
		SELECT
			 awcmh.rowId
			,awcmh.agentWiseCustomMarginId
			,s.agentId
			,sAgent = s.agentName
			,sCurr = sc.currCode
			,sCountry = sc.countryName		
			,awcmh.sRate
			,sMargin = ISNULL(awcmh.sMargin, 0)
			,sBid = ISNULL(awcmh.sRate, 0) + ISNULL(awcmh.sMargin, 0)
			,awcmh.sMax
			,awcmh.sMin
			
			,pc.countryId
			,pCountry = pc.countryName
			,pCurr = pc.currCode
			,p.agentId
			,pAgent = p.agentName						
			
			,awcmh.pRate
			,pMargin = ISNULL(awcmh.pMargin, 0)
			,pBid = ISNULL(awcmh.pRate, 0) + ISNULL(awcmh.pMargin, 0)
			,awcmh.pMax 
			,awcmh.pMin		
					
			,awcmh.SCRCRate
			,SCRCMargin = ISNULL(awcmh.SCRCMargin, 0)
			,SCRCBid = ISNULL(awcmh.SCRCRate, 0) + ISNULL(awcmh.SCRCMargin, 0)
			,awcmh.createdBy
			,awcmh.createdDate
		FROM agentWiseCustomMarginHistory awcmh WITH(NOLOCK)
		INNER JOIN agentMaster p WITH(NOLOCK) ON awcmh.pAgentId = p.agentId
		INNER JOIN countryCurrencyMaster pc WITH(NOLOCK) ON p.agentCountry = pc.countryId
		INNER JOIN agentMaster s WITH(NOLOCK) ON awcmh.sAgentId = s.agentId
		INNER JOIN countryCurrencyMaster sc WITH(NOLOCK) ON sc.countryId = s.agentCountry
		WHERE awcmh.approvedBy IS NULL
		ORDER BY awcmh.createdDate DESC	
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentWiseCustomMarginId
END CATCH


GO
