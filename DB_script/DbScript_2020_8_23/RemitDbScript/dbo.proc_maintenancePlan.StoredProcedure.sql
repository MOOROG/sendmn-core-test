USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_maintenancePlan]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_maintenancePlan]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@mpId								VARCHAR(30)		= NULL
	,@fromDate							DATETIME		= NULL
	,@toDate							DATETIME		= NULL
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
		 @logIdentifier = 'mpId'
		,@logParamMain = 'maintenancePlan'
		,@tableAlias = 'Maintenance Plan'
		,@module = 10
		,@ApprovedFunctionId = 10131130
		
	IF @flag IN ('s') 
	BEGIN
		SET @table = '(
					SELECT
						 mpId				= ISNULL(mode.mpId, main.mpId)
						,fromDate			= ISNULL(mode.fromDate, main.fromDate)
						,toDate				= ISNULL(mode.toDate, main.toDate)
						,msg				= ISNULL(mode.msg,main.msg)
						,reason				= ISNULL(mode.reason,main.reason)
						,isActive			= ISNULL(main.isActive,'''')
						,isEnable			= ISNULL(mode.isEnable,main.isEnable)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy	END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.mpId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM maintenancePlan main WITH(NOLOCK)
					LEFT JOIN maintenancePlanMod mode ON main.mpId = mode.mpId 
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
			INSERT INTO maintenancePlan (
				 fromDate
				,toDate
				,msg
				,reason
				,isEnable
				,createdDate
				,createdBy

			)
			SELECT
				 @fromDate
				,@toDate
				,@msg
				,@reason
				,@isEnable
				,GETDATE()
				,@user


			SET @mpId = SCOPE_IDENTITY()
		
			INSERT INTO maintenancePlanMod (
					 mpId
					,fromDate
					,toDate
					,reason  
					,isEnable
					,msg           
					,createdDate
					,createdBy
					,modType                    
				)
				SELECT
					 @mpId
					,@fromDate
					,@toDate
					,@reason 
					,@isEnable	
					,@msg		           
					,GETDATE()
					,@user
					,'I'  
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @mpId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM maintenancePlan WITH(NOLOCK) WHERE mpId = @mpId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @mpId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM maintenancePlanMod WITH(NOLOCK) WHERE mpId = @mpId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @mpId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM maintenancePlan WITH(NOLOCK) WHERE mpId = @mpId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN

				UPDATE maintenancePlan SET
					 fromDate					= @fromDate
					,toDate						= @toDate
					,msg						= @msg
					,reason                     = @reason	
					,isEnable					= @isEnable				
				WHERE mpId = @mpId
				END 
			ELSE
			BEGIN
				DELETE FROM maintenancePlanMod WHERE mpId = @mpId
					
				INSERT INTO maintenancePlanMod (
					 mpId
					,fromDate
					,toDate
					,reason  
					,msg
					,isEnable           
					,createdDate
					,createdBy
					,modType                    
				)
				SELECT
					 @mpId
					,@fromDate
					,@toDate
					,@reason 
					,@msg
					,@isEnable			           
					,GETDATE()
					,@user
					,'U'            
			END
        COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @mpId
     END
			
	
ELSE IF @flag='a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM maintenancePlanMod WITH(NOLOCK) WHERE mpId = @mpId AND createdBy = @user)
		BEGIN
			SELECT 
				 mpId
					,convert(varchar(10), fromDate , 101) as fromDate
					,convert(varchar(10), toDate , 101) as toDate 
				     ,convert(varchar(10), fromDate , 108) as fromTime
					,convert(varchar(10), toDate , 108) as toTime 
					,reason  
					,msg
					,isEnable           
					,createdDate
					,createdBy
				     ,modType
			FROM maintenancePlanMod WHERE mpId = @mpId	
		END
		ELSE
		BEGIN

			SELECT 
				 mpId
					,convert(varchar(10), fromDate , 101) as fromDate
					,convert(varchar(10), toDate , 101) as toDate 
				     ,convert(varchar(10), fromDate , 108) as fromTime
					,convert(varchar(10), toDate , 108) as toTime 
					,reason  
					,msg
					,isEnable           
					,createdDate
					,createdBy
			FROM maintenancePlan 
			where mpId = @mpId		

		END
	END

	
ELSE IF @flag='dt'
BEGIN
		
			SELECT top 1 
				 mpId
					,convert(varchar(10), fromDate , 101) as fromDate
					,convert(varchar(10), toDate , 101) as toDate 
				     ,convert(varchar(10), fromDate , 108) as fromTime
					,convert(varchar(10), toDate , 108) as toTime 
					,reason  
					,msg
					,isEnable           
					,createdDate
					,createdBy
			FROM maintenancePlan 
			where GETDATE() between fromDate and toDate		

END
ELSE IF @flag = 'd'
     BEGIN
		IF EXISTS (SELECT 'X' FROM maintenancePlan WITH(NOLOCK) WHERE mpId = @mpId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @mpId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM maintenancePlanMod WITH(NOLOCK) WHERE mpId = @mpId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @mpId
			RETURN
		END
		
		BEGIN TRANSACTION	
		IF EXISTS (SELECT 'X' FROM maintenancePlan WITH(NOLOCK) WHERE mpId = @mpId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM maintenancePlan WHERE mpId = @mpId
		END
		ELSE
		BEGIN
			INSERT INTO maintenancePlanMod (
				 mpId
				,fromDate
				,toDate
				,msg
				,reason
				,isEnable       		                 
				,createdDate
				,createdBy
				,modType                  
			)
			SELECT
				 mpId
				,fromDate
				,toDate
				,msg
				,reason 
				,isEnable         		                 				           
				,GETDATE()
				,@user
				,'D'
			FROM maintenancePlan WHERE mpId = @mpId
		END
		
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @mpId
	END	
	
    ELSE IF @flag = 's'
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'mpId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.mpId
							,main.fromDate
							,main.toDate
							,main.msg
							,main.reason
							,main.isEnable 
							,main.modifiedDate   
							,main.modifiedBy                                
							,main.haschanged				
						FROM ' + @table + ' main 
					) x'
					
		SET @sql_filter = ''		
		
		IF @fromDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(fromDate, '''') LIKE ''%' + @fromDate + '%'''
		
		IF @toDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(toDate, '''') LIKE ''%' + @toDate + '%'''

		
		SET @select_field_list ='
				 mpId
				,fromDate
				,toDate
				,msg             
				,reason  
				,isEnable
				,modifiedDate
				,modifiedBy         
				,haschanged
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
		IF NOT EXISTS (SELECT 'X' FROM maintenancePlan WITH(NOLOCK) WHERE mpId = @mpId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM maintenancePlanMod WITH(NOLOCK) WHERE mpId = @mpId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @mpId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM maintenancePlan WHERE mpId = @mpId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mpId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mpId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @mpId
					RETURN
				END
				DELETE FROM maintenancePlan WHERE mpId = @mpId				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mpId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mpId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @mpId
					RETURN
				END
				DELETE FROM maintenancePlanMod WHERE @mpId = @mpId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @mpId
	END
	
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM maintenancePlan WITH(NOLOCK) WHERE mpId = @mpId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM maintenancePlanMod WITH(NOLOCK) WHERE mpId = @mpId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @mpId
			RETURN
		END
		BEGIN TRANSACTION		
			IF EXISTS (SELECT 'X' FROM maintenancePlan WHERE approvedBy IS NULL AND mpId = @mpId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM maintenancePlanMod WHERE mpId = @mpId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE maintenancePlan SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE mpId = @mpId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mpId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mpId, @oldValue OUTPUT				
				
				UPDATE main SET
					 main.fromDate						= mode.fromDate
					,main.toDate						= mode.toDate
					,main.msg							= mode.msg
					,main.reason						= mode.reason	
					,main.isEnable						 = mode.isEnable            
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM maintenancePlan main
				INNER JOIN maintenancePlanMod mode ON mode.mpId= main.mpId
					WHERE mode.mpId = @mpId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mpId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mpId, @oldValue OUTPUT
				UPDATE maintenancePlan SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user

				WHERE mpId = @mpId
				
			END
			
			DELETE FROM maintenancePlanMod WHERE mpId = @mpId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mpId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @mpId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @mpId
	END	
				
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @mpId
END CATCH



GO
