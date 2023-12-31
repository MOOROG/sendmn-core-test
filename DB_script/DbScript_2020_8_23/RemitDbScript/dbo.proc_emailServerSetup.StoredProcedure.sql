USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_emailServerSetup]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_emailServerSetup]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId                             VARCHAR(30)		= NULL
	,@smtpServer						VARCHAR(200)	= NULL
	,@smtpPort							VARCHAR(200)	= NULL
	,@sendID							VARCHAR(200)	= NULL
	,@sendPSW							VARCHAR(200)	= NULL
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
		,@modType		VARCHAR(6)
	SELECT
		 @logIdentifier = 'id'
		,@logParamMain = 'emailServerSetup'
		,@logParamMod = 'emailServerSetupMod'
		,@module = '10'
		,@tableAlias = ''
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION

		INSERT INTO emailServerSetup (
			 smtpServer
			,smtpPort
			,sendId
			,sendPSW
			,createdBy
			,createdDate
		)
		SELECT
			 @smtpServer
			,@smtpPort
			,@sendID
			,@sendPSW
			,@user
			,GETDATE()
			
		SET @rowId = SCOPE_IDENTITY()
		SET @modType = 'Insert'
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue

		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
			RETURN
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END

	if @flag='u'
	begin
			UPDATE emailServerSetup SET
				 smtpServer		= @smtpServer
				,smtpPort		= @smtpPort
				,sendId			= @sendID
				,sendPSW		= @sendPSW
				,modifiedBy		= @user
				,modifiedDate	= GETDATE()
			WHERE id = @rowId
			
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowId

	end

	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM emailServerSetup WITH(NOLOCK)
	END
	ELSE IF @flag='s'
	BEGIN
		SELECT smtpServer,smtpPort,sendId,createdBy,createdDate FROM emailServerSetup
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH



GO
