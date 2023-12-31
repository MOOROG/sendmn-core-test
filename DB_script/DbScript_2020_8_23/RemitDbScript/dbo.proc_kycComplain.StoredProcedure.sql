USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_kycComplain]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_kycComplain]
 	 @flag								VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@id								INT				= NULL
	,@customerId                        INT			   = NULL
	,@date                              DATETIME       = NULL
	,@subject                           VARCHAR(100)   = NULL
	,@description                       VARCHAR(MAX)   = NULL
	,@sortBy                            VARCHAR(50)    = NULL
	,@sortOrder                         VARCHAR(5)     = NULL
	,@pageSize                          INT            = NULL
	,@pageNumber                        INT            = NULL
	,@setPrimary						char(1)		   = NULL


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

	IF @flag = 'i'
	BEGIN		
		BEGIN TRANSACTION
			if exists(select 'x' from kycComplain with(nolock) where customerId = @customerId)
			begin
				update kycComplain set setPrimary ='N' where customerId = @customerId
			end
			INSERT INTO kycComplain (
				 customerId
				,[date]
				,[subject]
				,[description]
				,createdBy
				,createdDate
				,setPrimary
			)
			SELECT
				 @customerId
				,@date
				,@subject
				,@description
				,@user
				,GETDATE()
				,'Y'
			IF @setPrimary = 'Y'
				UPDATE kycMaster SET cardStatus = 'Complain' WHERE rowId = @customerId
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @customerId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @id
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			 *
			,CONVERT(VARCHAR,[date],101)date1
		FROM kycComplain WITH(NOLOCK) WHERE id = @id
	END
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			IF @setPrimary ='Y'
			BEGIN
				update kycComplain set setPrimary ='N' where customerId = @customerId
				UPDATE customerMaster SET customerStatus = 'Complain' WHERE customerId = @customerId
			END
			ELSE
			BEGIN
				UPDATE customerMaster SET customerStatus = 'Pending' WHERE customerId = @customerId
			END
			UPDATE kycComplain SET
				 customerId = @customerId
				,[date] = @date
				,[subject] = @subject
				,[description] = @description
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				,setPrimary = @setPrimary

			WHERE id = @id
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @id, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @id, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @id
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @id
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE kycComplain SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE id = @id
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @id, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @id, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @id
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
	END
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'customerInfoId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.id
					,main.customerId
					,date = CONVERT(VARCHAR,main.date,101)
					,main.subject
					,main.description
					,main.createdBy
					,main.createdDate
					,main.isDeleted
					,IsPrimary = case when setPrimary =''N'' then  ''No'' else ''Yes'' end
				FROM kycComplain main WITH(NOLOCK)
					WHERE customerId = ' + CAST(@customerId AS VARCHAR) + ' AND 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 id
			,customerId
			,date
			,subject
			,description
			,createdBy
			,createdDate
			,isDeleted
			,IsPrimary '
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
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH




GO
