USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_msgBroadCast]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_msgBroadCast]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@msgBroadCastId                     VARCHAR(30)    = NULL
     ,@countryId                          INT            = NULL
     ,@agentId                            INT            = NULL
     ,@branchId                           INT            = NULL
     ,@countryName						  VARCHAR(50)	 = NULL	
     ,@agentName						  VARCHAR(50)	 = NULL	
     ,@branchName						  VARCHAR(50)	 = NULL	
     ,@msgTitle                           NVARCHAR(500)   = NULL
     ,@msgDetail                          NVARCHAR(MAX)  = NULL
     ,@sortBy                             VARCHAR(50)    = NULL
     ,@isActive                           VARCHAR(2)     = NULL
	 ,@userType							  VARCHAR(50)	 = NULL
     ,@sortOrder                          VARCHAR(5)     = NULL
     ,@pageSize                           INT            = NULL
     ,@pageNumber                         INT            = NULL


AS
/*
		flag		Purpose
		----------------------------
		d			Delete
		a			Select by id
		i			Insert
		u			Update
		s			Select
*/

SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
     DECLARE
           @sql           VARCHAR(MAX)
     DECLARE
           @select_field_list VARCHAR(MAX)
          ,@extra_field_list  VARCHAR(MAX)
          ,@table             VARCHAR(MAX)
          ,@sql_filter        VARCHAR(MAX)
          ,@newValue		  VARCHAR(MAX)
          ,@oldValue		  VARCHAR(MAX)		
          ,@modType			  VARCHAR(6)
     IF @flag = 'i'
     BEGIN
		--IF EXISTS (SELECT 'X' FROM msgBroadCast WHERE countryId = @countryId AND agentId = @agentId AND branchId = @branchId 
		--					AND ISNULL(isDeleted, 'N') <> 'Y')
		--	BEGIN
		--		EXEC proc_errorHandler 1, 'Cannot Insert  Duplicate  Message For Same Branch', NULL
		--		RETURN
		--	END
		
          BEGIN TRANSACTION
               INSERT INTO msgBroadCast (
                     countryId
                    ,agentId
                    ,branchId
                    ,msgTitle
                    ,msgDetail
                    ,isActive
                    ,createdBy
                    ,createdDate
					,userType
               )
               SELECT
                     @countryId
                    ,@agentId
                    ,@branchId
                    ,@msgTitle
                    ,@msgDetail
                    ,@isActive
                    ,@user
                    ,GETDATE()
					,@userType
				SET @msgBroadCastId = SCOPE_IDENTITY()
				SET @modType = 'insert'
					
			EXEC [dbo].proc_GetColumnToRow  'msgBroadCast', 'msgBroadCastId', @msgBroadCastId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)

			EXEC proc_applicationLogs 'i', NULL, @modType, 'Message Broadcast Setup', @msgBroadCastId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to Insert.', @msgBroadCastId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record has been Inserted successfully.', @msgBroadCastId
     END

     ELSE IF @flag = 'u'
     BEGIN
		--IF EXISTS (SELECT 'X' FROM msgBroadCast WHERE countryId = @countryId AND agentId = @agentId AND branchId = @branchId
		--						AND msgBroadCastId <> @msgBroadCastId AND ISNULL(isDeleted, 'N') <> 'Y')
		--	BEGIN
		--		EXEC proc_errorHandler 1, 'Cannot Update  Message For Already Existed Branch ', NULL
		--		RETURN
		--	END
          BEGIN TRANSACTION
               UPDATE msgBroadCast SET
                          countryId                     = @countryId
                         ,agentId                       = @agentId
                         ,branchId                      = @branchId
                         ,msgTitle                      = @msgTitle
                         ,msgDetail                     = @msgDetail
                         ,isActive						= @isActive
                         ,modifiedBy					= @user
                         ,modifiedDate					= GETDATE()
						 ,userType						= @userType
                    WHERE msgBroadCastId = @msgBroadCastId
                    
           	SET @modType = 'update'
					
			EXEC [dbo].proc_GetColumnToRow  'msgBroadCast', 'msgBroadCastId', @msgBroadCastId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)

			EXEC proc_applicationLogs 'i', NULL, @modType, 'Message Broadcast Setup', @msgBroadCastId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to Update.', @msgBroadCastId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record has been Updated successfully.', @msgBroadCastId         
           
     END

	ELSE IF @flag = 'd'
    BEGIN
          BEGIN TRANSACTION
               UPDATE msgBroadCast SET
                      isDeleted = 'Y'
               WHERE msgBroadCastId = @msgBroadCastId         
           	SET @modType = 'delete'
					
			EXEC [dbo].proc_GetColumnToRow  'msgBroadCast', 'msgBroadCastId', @msgBroadCastId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)

			EXEC proc_applicationLogs 'i', NULL, @modType, 'Message Broadcast Setup', @msgBroadCastId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to Delete.', @msgBroadCastId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record has been Deleted successfully.', @msgBroadCastId       
     END

     ELSE IF @flag = 's'
     BEGIN
          IF @sortBy IS NULL
               SET @sortBy = 'msgBroadCastId'
          IF @sortOrder IS NULL
               SET @sortOrder = 'ASC'
          SET @table = '(
               	SELECT
               		 main.msgBroadCastId
                    ,countryName = ISNULL(cm.countryName,''All'')
                    ,agentName	 = ISNULL(am.agentName,''All'')
                    ,branchName  = ISNULL(am1.agentName,''All'')
                    ,main.msgTitle
                    ,main.msgDetail
                    ,main.createdBy
                    ,main.createdDate
					,isActive = case when main.isActive=''N'' then ''Inactive'' else ''Active'' end
					,userType = case when main.userType is null then ''All'' else main.userType end
                    FROM msgBroadCast main WITH(NOLOCK)
						LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = main.countryId
						LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = main.agentId
						LEFT JOIN agentMaster am1 WITH(NOLOCK) ON am1.agentId = main.branchId
                    WHERE ISNULL(main.isDeleted, ''N'') <> ''Y''
          ) x'
          SET @sql_filter = ''
          
          IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
			
		  IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
			
		  IF @branchName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND branchName LIKE ''%' + @branchName + '%'''
          
          SET @select_field_list ='
                msgBroadCastId
               ,countryName
               ,agentName
               ,branchName
               ,msgTitle
               ,msgDetail
               ,createdDate
               ,createdBy
			   ,isActive
			   ,userType
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
     
   ELSE IF @flag = 'a'
   BEGIN
		SELECT
			 main.countryId
			,main.agentId
			,main.branchId
			,countryName  = cm.countryName
			,agentName	 = am.agentName
			,branchName  = am1.agentName
			,main.msgTitle
			,main.msgDetail
			,main.isActive
			,main.userType
		FROM msgBroadCast main WITH(NOLOCK)  
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = main.countryId
		LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = main.agentId
		LEFT JOIN agentMaster am1 WITH(NOLOCK) ON am1.agentId = main.branchId
		WHERE msgBroadCastId = @msgBroadCastId
   END
END TRY


BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errorCode, ERROR_MESSAGE() mes, null id
END CATCH



GO
