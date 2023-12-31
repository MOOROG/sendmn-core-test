USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_emailTemplate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_emailTemplate]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								VARCHAR(30)		= NULL
	,@templateName						VARCHAR(200)	= NULL
	,@emailSubject						VARCHAR(500)	= NULL
	,@templateFor						VARCHAR(500)	= NULL
	,@isEnabled							VARCHAR(1)		= NULL
	,@isResponseToAgent					VARCHAR(1)		= NULL
	,@emailFormat						NVARCHAR(MAX)	= NULL
	,@replyTo							VARCHAR(20)		= NULL
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
		
	SELECT
		 @logIdentifier = 'id'
		,@logParamMain = 'emailTemplate'
		,@module = '10'
		,@tableAlias = 'Email Template'
	IF @flag = 'i'
	BEGIN
	
	IF EXISTS(SELECT 'A' FROM emailTemplate WHERE ISNULL(isEnabled,'Y')='Y' AND templateFor = @templateFor AND replyTo = 'Both')
	BEGIN
		EXEC proc_errorHandler 1, 'Tepmlate already contain replyTo : Both.', @id
		RETURN
	END
	IF EXISTS(SELECT 'A' FROM emailTemplate WHERE ISNULL(isEnabled,'Y')='Y' AND templateFor = @templateFor AND replyTo = @replyTo)
	BEGIN
		EXEC proc_errorHandler 1, 'Tepmlate already contain replyTo.', @id
		RETURN
	END
	IF EXISTS(SELECT 'A' FROM emailTemplate WHERE ISNULL(isEnabled,'Y')='Y' AND templateFor = @templateFor AND @replyTo = 'Both')
	BEGIN
		EXEC proc_errorHandler 1, 'ReplyTo already contain for Tepmlate.', @id
		RETURN
	END
	
		BEGIN TRANSACTION
			-- select * from emailTemplate 
	
			INSERT INTO emailTemplate 
			(
				 templateName
				,emailSubject
				,templateFor
				,isEnabled
				,isResponseToAgent
				,emailFormat
				,replyTo
				,createdBy
				,createdDate
			)
			SELECT
				 @templateName
				,@emailSubject
				,@templateFor
				,@isEnabled
				,@isResponseToAgent
				,@emailFormat
				,@replyTo
				,@user
				,GETDATE()
			
			SET @id = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @id , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @id, @user, @oldValue, @newValue, @module
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
		SELECT * FROM emailTemplate WITH(NOLOCK) WHERE id = @id
	END
	ELSE IF @flag = 'keyword'
	BEGIN  
			SELECT letter_key_words [Key Word],key_desc [Key Description] FROM letterKeywordSetting WHERE 1=1
	END
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'A' FROM emailTemplate WHERE ISNULL(isEnabled,'Y')='Y' AND templateFor = @templateFor AND replyTo = 'Both' AND id <> @id)
		BEGIN
			EXEC proc_errorHandler 1, 'Tepmlate already contain replyTo : Both.', @id
			RETURN
		END
		IF EXISTS(SELECT 'A' FROM emailTemplate WHERE ISNULL(isEnabled,'Y')='Y' AND templateFor = @templateFor AND replyTo = @replyTo  AND id <> @id)
		BEGIN
			EXEC proc_errorHandler 1, 'Tepmlate already contain replyTo.', @id
			RETURN
		END
		IF EXISTS(SELECT 'A' FROM emailTemplate WHERE ISNULL(isEnabled,'Y')='Y' AND templateFor = @templateFor AND @replyTo = 'Both' AND id<> @id)
		BEGIN
			EXEC proc_errorHandler 1, 'ReplyTo already contain for Tepmlate.', @id
			RETURN
		END
		BEGIN TRANSACTION
			EXEC [dbo].proc_GetColumnToRow	@logParamMain, @logIdentifier,@id, @oldValue OUTPUT
			
			UPDATE emailTemplate SET
				 templateName = @templateName
				,emailSubject = @emailSubject
				,templateFor=@templateFor
				,isEnabled = @isEnabled
				,isResponseToAgent = @isResponseToAgent
				,emailFormat = @emailFormat
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				,replyTo = @replyTo
			WHERE id = @id
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @id, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @id, @user, @oldValue, @newValue, @module
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
			UPDATE emailTemplate SET
				isDeleted =	'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy	= @user
			WHERE id	= @id
			SET	@modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow	@logParamMain, @logIdentifier,@id, @oldValue OUTPUT
			INSERT INTO	#msg(errorCode,	msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,	 @id, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg	WHERE errorCode	<> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete	record.', @id
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
	END	  

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 id
					,templateName
					,emailSubject
					,templateFor
					,isEnabled =case when isEnabled=''Y'' then ''Yes'' else ''No'' end
					,isResponseToAgent =case when isResponseToAgent=''Y'' then ''Yes'' else ''No'' end
					,emailFormat
					,replyTo
					,createdBy
					,createdDate
					,isDeleted
				FROM emailTemplate WITH(NOLOCK)
				WHERE isnull(isDeleted,''N'')<>''Y''
					) x'
	END

	
	IF @flag IN('s')
	BEGIN
		set @sql_filter=''
		
		IF @templateName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND templateName LIKE ''%' + @templateName + '%'''

		IF @emailSubject IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND emailSubject LIKE ''%' + @emailSubject + '%'''

		SET @select_field_list ='
			 id
			,templateName
			,emailSubject
			,templateFor
			,isEnabled 
			,isResponseToAgent
			,emailFormat
			,replyTo
			,createdBy
			,createdDate
			,isDeleted
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
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH


GO
