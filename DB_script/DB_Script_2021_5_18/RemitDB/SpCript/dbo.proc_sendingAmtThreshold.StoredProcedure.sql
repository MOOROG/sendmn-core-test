USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendingAmtThreshold]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_sendingAmtThreshold]
 @flag								VARCHAR(50)		= NULL
,@sAmtThresholdId					INT				= NULL
,@user                              VARCHAR(30)		= NULL
,@sCountryId                        VARCHAR(30)		= NULL
,@sCountryName                      VARCHAR(50)		= NULL
,@rCountryId                        VARCHAR(30)		= NULL
,@rCountryName                      VARCHAR(50)		= NULL
,@sAgent							VARCHAR(30)		= NULL
,@Amount							MONEY			= NULL
,@MessageTxt						NVARCHAR(MAX)	= NULL
,@isEnable                          CHAR(1)			= NULL
,@isActive							CHAR(1)			= NULL
,@sortBy                            VARCHAR(50)		= NULL
,@sortOrder                         VARCHAR(5)		= NULL
,@pageSize                          INT				= NULL
,@pageNumber                        INT				= NULL
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
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT

		SELECT
		 @ApprovedFunctionId = 2019520
		,@logIdentifier = 'sAmtThresholdId'
		,@logParamMain = 'sendingAmtThreshold'
		,@logParamMod = 'sendingAmtThresholdHistory'
		,@module = '20'
		,@tableAlias = 'Sending Amt Threshold'

	IF @flag = 'i'
	BEGIN
		
		
		IF EXISTS(SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK) WHERE sCountryId = @sCountryId AND rCountryId = @rCountryId AND ISNULL(sAgent,'') = ISNULL(@sAgent,'') AND ISNULL(isActive, 'Y') <> 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Sending amount threshold rule already added for this country or agent.', NULL
			RETURN
		END
				
		BEGIN TRANSACTION
			
			INSERT INTO sendingAmtThreshold (
				 sCountryId
				,sCountryName
				,rCountryId
				,rCountryName
				,sAgent
				,Amount
				,MessageTxt
				,isActive						
				,createdBy
				,createdDate				
			)
			SELECT
				 @sCountryId
				,@sCountryName
				,@rCountryId
				,@rCountryName
				,@sAgent
				,@Amount
				,@MessageTxt
				,@isActive							
				,@user
				,GETDATE()				
				
			SET @sAmtThresholdId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sAmtThresholdId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sAmtThresholdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @sCountryId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @sCountryId
	END

	ELSE IF @flag = 'u'
	BEGIN
		
		IF EXISTS (SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK) WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @sAmtThresholdId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM sendingAmtThresholdHistory WITH(NOLOCK) WHERE sAmtThresholdId = @sAmtThresholdId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @sAmtThresholdId
			RETURN
		END

		BEGIN TRANSACTION

		IF EXISTS (SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK) WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN

			UPDATE sendingAmtThreshold SET
				 sCountryId = @sCountryId
				,sCountryName = @sCountryName
				,rCountryId = @rCountryId
				,rCountryName = @rCountryName
				,sAgent = @sAgent
				,Amount = @Amount
				,MessageTxt = @MessageTxt
				,isActive=@isActive
				,modifiedBy = @user
				,modifiedDate = GETDATE()				
			WHERE sAmtThresholdId = @sAmtThresholdId
			END
			ELSE
			BEGIN
				DELETE FROM sendingAmtThreshold WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL
				INSERT INTO sendingAmtThresholdHistory(
					 sAmtThresholdId
					,sCountryId
					,sCountryName
					,rCountryId
					,rCountryName
					,sAgent
					,Amount
					,MessageTxt
					,isActive								
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				
				SELECT
					 @sAmtThresholdId
					,@sCountryId
					,@sCountryName
					,@rCountryId
					,@rCountryName
					,@sAgent
					,@Amount
					,@MessageTxt
					,@isActive																	
					,@isEnable
					,@user
					,GETDATE()
					,'U'
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @sAmtThresholdId			
	END

	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE sendingAmtThreshold SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE sAmtThresholdId = @sAmtThresholdId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @sAmtThresholdId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @sAmtThresholdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @sCountryId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @sCountryId
	END

	ELSE IF @flag = 'a'
	BEGIN		
		SELECT sAmtThresholdId
			  ,sCountryId
			  ,sCountryName
			  ,rCountryId
			  ,rCountryName
			  ,sAgent
			  ,Amount
			  ,MessageTxt
			  ,isActive
			  ,createdBy
			  ,createdDate 
			   FROM sendingAmtThreshold WITH(NOLOCK)
			  WHERE sAmtThresholdId = @sAmtThresholdId 
	END	
	ELSE IF @flag = 's'
	BEGIN

		IF @sortBy IS NULL
				SET @sortBy = 'sCountryId'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		DECLARE @m VARCHAR(MAX),@d VARCHAR(MAX)

		SET @m = '(
				SELECT
					 sAmtThresholdId = ISNULL(mode.sAmtThresholdId, main.sAmtThresholdId)	
					,sCountryId = ISNULL(mode.sCountryId, main.sCountryId)									
					,sCountryName = ISNULL(mode.sCountryName, main.sCountryName)
					,rCountryId = ISNULL(mode.rCountryId, main.rCountryId)									
					,rCountryName = ISNULL(mode.rCountryName, main.rCountryName)	
										
					,sAgent = ISNULL(mode.sAgent, main.sAgent)
					,Amount = dbo.ShowDecimal(ISNULL(mode.Amount, main.Amount))
					,MessageTxt = ISNULL(mode.MessageTxt, main.MessageTxt)
						
					,isActive =  CASE WHEN ISNULL(ISNULL(mode.isActive, main.isActive),''N'')=''Y'' then ''Active'' else ''Deactivate'' END	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END								
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.sAmtThresholdId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM sendingAmtThreshold main WITH(NOLOCK)
				LEFT JOIN sendingAmtThresholdHistory mode ON main.sAmtThresholdId = mode.sAmtThresholdId AND mode.approvedBy IS NULL
					AND (
							mode.createdBy = ''' +  @user + ''' 
							OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
						)
					
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
			) '
						

		SET @table = '(
				SELECT  m.sAmtThresholdId
					,m.sCountryId
					,m.sCountryName
					,m.rCountryId
					,m.rCountryName
					,sAgent = ISNULL(agt.agentName,''All'')
					,Amount = dbo.ShowDecimal(m.Amount)
					,m.isActive					
					,modifiedBy = MAX(ISNULL(m.modifiedBy,''''))				
					,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)					
				FROM ' + @m + ' m 
				LEFT JOIN agentMaster agt WITH(NOLOCK)
				ON m.sAgent=agt.agentId	
				GROUP BY
				m.sAmtThresholdId
				,m.sCountryId
				,m.sCountryName
				,m.rCountryId
				,m.rCountryName
				,agt.agentName
				,m.Amount
				,m.isActive				
					) x'

		PRINT @table
		
		SET @sql_filter = ''
		IF @sCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sCountryName LIKE ''%' + @sCountryName + '%'''
				
		IF @rCountryName IS NOT NULL
		   SET @sql_filter = @sql_filter + 'AND rCountryName LIKE ''%' + @rCountryName + '%'' '
			
		SET @select_field_list ='
			  sAmtThresholdId
			 ,sCountryId
			 ,sCountryName
			 ,rCountryId
			 ,rCountryName
			 ,sAgent
			 ,Amount
			 ,isActive			 
			 ,modifiedBy
			 ,hasChanged'

		EXEC dbo.proc_paging
			@table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber

	END
	ELSE IF @flag='getTA'
	BEGIN
		
		SELECT @sCountryID = agentCountryId from agentMaster WITH(NOLOCK) WHERE agentId = @sAgent

		IF EXISTS(SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK) WHERE sCountryId = @sCountryId AND rCountryId = @rCountryId AND ISNULL(sAgent,'') = ISNULL(@sAgent,'') AND ISNULL(isActive, 'Y') <> 'N' AND approvedBy IS NOT NULL)
		BEGIN
			SELECT TOP 1 Amount = dbo.ShowDecimal(Amount),MessageTxt from sendingAmtThreshold WITH(NOLOCK) WHERE sCountryId = @sCountryId AND rCountryId = @rCountryId AND ISNULL(sAgent,'') = ISNULL(@sAgent,'') 
			AND ISNULL(isActive, 'Y') <> 'N' AND approvedBy IS NOT NULL
			ORDER BY createdDate DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 Amount = dbo.ShowDecimal(Amount),MessageTxt from sendingAmtThreshold WITH(NOLOCK) WHERE sCountryId = @sCountryId AND rCountryId = @rCountryId AND ISNULL(sAgent,'')='' 
			AND ISNULL(isActive, 'Y') <> 'N' AND approvedBy IS NOT NULL
			ORDER BY createdDate DESC
		END

		--SELECT * from sendingAmtThreshold 
		--select * from agentMaster where agentId='1226'
	END

	ELSE IF @flag IN ('reject')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK)
			WHERE sAmtThresholdId = @sAmtThresholdId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK)
			WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @sAmtThresholdId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sendingAmtThreshold WHERE approvedBy IS NULL AND sAmtThresholdId = @sAmtThresholdId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sAmtThresholdId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sAmtThresholdId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the modification.', @sAmtThresholdId
					RETURN
				END
			DELETE FROM sendingAmtThreshold WHERE sAmtThresholdId =  @sAmtThresholdId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sAmtThresholdId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sAmtThresholdId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the modification.', @sAmtThresholdId
					RETURN
				END
				DELETE FROM sendingAmtThresholdHistory WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Changes rejected successfully.', @sAmtThresholdId		
		END
				
	END

	ELSE IF @flag IN ('approve')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK)
			WHERE sAmtThresholdId = @sAmtThresholdId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM sendingAmtThreshold WITH(NOLOCK)
			WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @sAmtThresholdId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sendingAmtThreshold WHERE approvedBy IS NULL AND sAmtThresholdId = @sAmtThresholdId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM sendingAmtThresholdHistory WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE sendingAmtThreshold SET
					 isActive = 'Y'
					,isEnable = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE sAmtThresholdId = @sAmtThresholdId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sAmtThresholdId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sAmtThresholdId, @oldValue OUTPUT
				
				-- SELECT * FROM sendingAmtThreshold
				UPDATE main SET
					 main.sCountryId = mode.sCountryId
					,main.sCountryName = mode.sCountryName
					,main.rCountryId = mode.rCountryId
					,main.rCountryName = mode.rCountryName
					,main.sAgent = mode.sAgent
					,main.Amount = mode.Amount
					,main.MessageTxt = mode.MessageTxt
					,main.isActive = mode.isActive								
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM sendingAmtThreshold main
				INNER JOIN sendingAmtThresholdHistory mode ON mode.sAmtThresholdId = main.sAmtThresholdId
				WHERE mode.sAmtThresholdId = @sAmtThresholdId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'sendingAmtThreshold', 'sAmtThresholdId', @sAmtThresholdId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sAmtThresholdId, @oldValue OUTPUT
				UPDATE sendingAmtThreshold SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE sAmtThresholdId = @sAmtThresholdId
			END
			
			UPDATE sendingAmtThresholdHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE sAmtThresholdId = @sAmtThresholdId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sAmtThresholdId, @user, @oldValue, @newValue
			
			DELETE FROM sendingAmtThresholdHistory WHERE sAmtThresholdId = @sAmtThresholdId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sAmtThresholdId, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @sAmtThresholdId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @sAmtThresholdId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sCountryId
END CATCH

GO
