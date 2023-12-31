USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_IPBlacklist]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_IPBlacklist]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@blId								VARCHAR(30)		= NULL
	,@IPAddress							VARCHAR(30)		= NULL
	,@msg								VARCHAR(500)	= NULL
	,@reason							VARCHAR(500)	= NULL
	,@isEnable							CHAR(1)			= NULL
	,@isActive							CHAR(1)			= NULL
	,@isDeleted							CHAR(1)			= NULL
	,@createdDate                       DATETIME		= NULL
	,@createdBy							VARCHAR(100)	= NULL
	,@modifiedDate                      DATETIME		= NULL
	,@modifiedBy                        VARCHAR(100)	= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@ipAdrs							VARCHAR(50)		= NULL
	,@fieldValues						VARCHAR(100)	= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@ApprovedFunctionId INT
	SELECT
		 @logIdentifier = 'blId'
		,@logParamMain = 'IPBlacklist'
		,@tableAlias = 'IP Blacklist'
		,@module = 10
		,@ApprovedFunctionId = 10131030
	
	
	IF @flag = 'cadmin'							--Check if IPAddress exist
	BEGIN		
		--IF NOT EXISTS (SELECT 'X' from IPBlacklist	WHERE @IPAddress between IPaddress and msg)
		--BEGIN		 
			--Exec proc_IpAccessLogs @flag = 'i', @fieldValue = @fieldValues, @ip = @ipAdrs
			--SELECT 1 ErrorCode, 'Sorry, Invalid Access !' Msg, @IPAddress  Id
			--RETURN			
		--END		

		EXEC proc_errorHandler 0, 'IP Address exist', @IPAddress
		RETURN;

	END	
	
	IF @flag = 'c'							--Check if IPAddress exist
	BEGIN		
		IF NOT EXISTS (SELECT 'X' from IPBlacklist with (nolock)	
			WHERE @IPAddress between IPaddress and msg)
		BEGIN
		 
		Exec proc_IpAccessLogs @flag = 'i', @fieldValue = @fieldValues, @ip = @ipAdrs
		SELECT 1 ErrorCode, 'Invalid Ip Address: '+ @ipAdrs Msg, @IPAddress Id
		RETURN			
		END
		EXEC proc_errorHandler 0, 'IP Address exist', @IPAddress
		RETURN;
	END	
	
	IF @flag IN ('s') 
	BEGIN
		SET @table = '(
					SELECT
						 blId				= ISNULL(mode.blId, main.blId)
						,IPAddress			= ISNULL(mode.IPAddress,main.IPAddress)
						,msg				= ISNULL(mode.msg,main.msg)
						,reason				= ISNULL(mode.reason,main.reason)
						,isEnable			= ISNULL(mode.isEnable, main.isEnable)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.blId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM IPBlacklist main WITH(NOLOCK)
					LEFT JOIN IPBlacklistMod mode ON main.blId = mode.blId 
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
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
				) '
	
	END	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO IPBlacklist (
				 IPAddress
				,msg
				,reason
				,isEnable
				,createdDate
				,createdBy

			)
			SELECT
				 @IPAddress
				,@msg
				,@reason
				,@isEnable
				,GETDATE()
				,@user


			SET @blId = SCOPE_IDENTITY()
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @blId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM IPBlacklist WITH(NOLOCK) WHERE blId = @blId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @blId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM IPBlacklistMod WITH(NOLOCK) WHERE blId = @blId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @blId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM IPBlacklist WITH(NOLOCK) WHERE blId = @blId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN

				UPDATE IPBlacklist SET
					 IPAddress                  = @IPAddress
					,msg						= @msg
					,reason                     = @reason	
					,isEnable					= @isEnable				
				WHERE blId = @blId
				END 
			ELSE
			BEGIN
				DELETE FROM IPBlacklistMod WHERE blId = @blId
					
				INSERT INTO IPBlacklistMod (
					 blId
					,IPAddress
					,msg
					,reason
					,isEnable             
					,createdDate
					,createdBy
					,modType                    
				)
				SELECT
					 @blId
					,@IPAddress
					,@msg
					,@reason 
					,@isEnable			           
					,GETDATE()
					,@user
					,'U'            
			END
        COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @blId
     END
			
	
ELSE IF @flag='a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM IPBlacklistMod WITH(NOLOCK) WHERE blId = @blId AND createdBy = @user)
		BEGIN
			SELECT 
				*
			FROM IPBlacklistMod WHERE blId = @blId	
		END
		ELSE
		BEGIN
			SELECT 
				*
			FROM IPBlacklist where blId = @blId		
		END
	END
		
ELSE IF @flag = 'd'
     BEGIN
		IF EXISTS (SELECT 'X' FROM IPBlacklist WITH(NOLOCK) WHERE blId = @blId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @blId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM IPBlacklistMod WITH(NOLOCK) WHERE blId = @blId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @blId
			RETURN
		END
		
		BEGIN TRANSACTION	
		IF EXISTS (SELECT 'X' FROM IPBlacklist WITH(NOLOCK) WHERE blId = @blId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM IPBlacklist WHERE blId = @blId
		END
		ELSE
		BEGIN
			DELETE FROM IPBlacklistMod WHERE blId = @blId
			INSERT INTO IPBlacklistMod (
				 blId
				,IPAddress
				,msg
				,reason 
				,isEnable      		                 
				,createdDate
				,createdBy
				,modType                  
			)
			SELECT
				 blId
				,IPAddress
				,msg
				,reason  
				,isEnable        		                 				           
				,GETDATE()
				,@user
				,'D'
			FROM IPBlacklist WHERE blId = @blId
		END
		
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @blId
	END	
	
	ELSE IF @flag = 's'
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'blId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.blId
							,main.msg
							,main.IPAddress
							,main.reason  
							,main.isEnable
							,main.modifiedBy                                  
							,main.haschanged				
						FROM ' + @table + ' main 
					) x'
					
		SET @sql_filter = ''		
		
		IF @IPAddress IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(IPAddress, '''') LIKE ''%' + @IPAddress + '%'''

		
		SET @select_field_list ='
				blId
			   ,msg
			   ,IPAddress               
			   ,reason           
			   ,haschanged
			   ,modifiedBy
			   ,isEnable
			   '        	
			
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
	
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM IPBlacklist WITH(NOLOCK) WHERE blId = @blId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM IPBlacklistMod WITH(NOLOCK) WHERE blId = @blId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @blId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM IPBlacklist WHERE blId = @blId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @blId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @blId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @blId
					RETURN
				END
				DELETE FROM IPBlacklist WHERE blId = @blId				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @blId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @blId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @blId
					RETURN
				END
				DELETE FROM IPBlacklistMod WHERE @blId = @blId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @blId
	END
	
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM IPBlacklist WITH(NOLOCK) WHERE blId = @blId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM IPBlacklistMod WITH(NOLOCK) WHERE blId = @blId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @blId
			RETURN
		END
		BEGIN TRANSACTION		
			IF EXISTS (SELECT 'X' FROM IPBlacklist WHERE approvedBy IS NULL AND blId = @blId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM IPBlacklistMod WHERE blId = @blId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE IPBlacklist SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE blId = @blId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @blId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @blId, @oldValue OUTPUT				
				
				UPDATE main SET
					 main.IPAddress						= mode.IPAddress
					,main.msg							= mode.msg
					,main.reason						= mode.reason
					,main.isEnable						= mode.isEnable	            
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM IPBlacklist main
				INNER JOIN IPBlacklistMod mode ON mode.blId= main.blId
					WHERE mode.blId = @blId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @blId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @blId, @oldValue OUTPUT
				UPDATE IPBlacklist SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user

				WHERE blId = @blId
				
			END
			
			DELETE FROM IPBlacklistMod WHERE blId = @blId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @blId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @blId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @blId
	END	
				
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @blId
END CATCH


GO
