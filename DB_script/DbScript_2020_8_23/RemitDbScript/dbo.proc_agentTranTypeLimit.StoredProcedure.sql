USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentTranTypeLimit]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentTranTypeLimit]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@agentTranTypeLimitId				INT				= NULL
     ,@agentId                          INT				= NULL
     ,@serviceType                      INT				= NULL
     ,@tranLimitMax                     MONEY			= NULL
     ,@tranLimitMin						MONEY			= NULL
     ,@isDefaultDepositMode				CHAR(1)			= NULL
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(error_code INT, msg VARCHAR(100), id INT)
     DECLARE
           @sql           VARCHAR(MAX)
          ,@oldValue      VARCHAR(MAX)
          ,@newValue      VARCHAR(MAX)
          ,@tableName     VARCHAR(50)
     DECLARE
           @select_field_list VARCHAR(MAX)
          ,@extra_field_list  VARCHAR(MAX)
          ,@table             VARCHAR(MAX)
          ,@sql_filter        VARCHAR(MAX)
     DECLARE
           @gridName              VARCHAR(50)
          ,@modType               VARCHAR(6)
     SELECT
           @gridName          = 'grid_agentTranTypeLimit'
           
     IF @flag='a'
     BEGIN
			SELECT * FROM agentTranTypeLimit WHERE (isDeleted IS NULL OR isDeleted = '')
			AND agentTranTypeLimitId = @agentTranTypeLimitId
     END      
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO agentTranTypeLimit (
					 agentId
                    ,serviceType
                    ,tranLimitMax
                    ,tranLimitMin
                    ,[isDefaultDepositMode]
                    ,createdDate
                    ,createdBy
               )
               SELECT
					 @agentId
                    ,@serviceType
                    ,@tranLimitMax
                    ,@tranLimitMin
                    ,@isDefaultDepositMode
                    ,GETDATE()
                    ,@user
               SET @agentTranTypeLimitId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'agentTranTypeLimit', 'agentTranTypeLimitId', @agentTranTypeLimitId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'agentTranTypeLimit', @agentTranTypeLimitId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @agentTranTypeLimitId id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @agentTranTypeLimitId id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'agentTranTypeLimit', 'agentTranTypeLimitId', @agentTranTypeLimitId, @oldValue OUTPUT
               UPDATE agentTranTypeLimit SET
                          serviceType					= @serviceType
                         ,tranLimitMax                  = @tranLimitMax
                         ,tranLimitMin					= @tranLimitMin
                         ,[isDefaultDepositMode]        = @isDefaultDepositMode
                         ,modifiedDate					= GETDATE()
                         ,modifiedBy					= @user
                    WHERE agentTranTypeLimitId = @agentTranTypeLimitId
                    EXEC [dbo].proc_GetColumnToRow  'agentTranTypeLimit', 'agentTranTypeLimitId', @agentTranTypeLimitId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'agentTranTypeLimit', @agentTranTypeLimitId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @agentTranTypeLimitId id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @agentTranTypeLimitId id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE agentTranTypeLimit SET
                     isDeleted = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE agentTranTypeLimitId = @agentTranTypeLimitId
               EXEC [dbo].proc_GetColumnToRow  'agentTranTypeLimit', 'agentTranTypeLimitId', @agentTranTypeLimitId, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'agentTranTypeLimit', @agentTranTypeLimitId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @agentTranTypeLimitId id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @agentTranTypeLimitId id
     END

 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
