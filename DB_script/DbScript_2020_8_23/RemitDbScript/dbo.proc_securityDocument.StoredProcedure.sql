USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_securityDocument]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_securityDocument]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@sdId                              VARCHAR(30)		= NULL
	,@sdIds								VARCHAR(MAX)	= NULL
	,@securityTypeId                    INT				= NULL
	,@securityType						CHAR(1)			= NULL
	,@fileName							VARCHAR(50)		= NULL
	,@fileDescription                   VARCHAR(100)	= NULL
	,@fileType                          VARCHAR(10)		= NULL
	,@sessionId							VARCHAR(50)		= NULL
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
		 @logIdentifier = 'sdId'
		,@logParamMain = 'securityDocument'
		,@logParamMod = 'securityDocumentMod'
		,@module = '20'
		,@tableAlias = ''
		
	IF @flag = 'i'
	BEGIN
		-- ALTER TABLE securityDocument ADD sessionId VARCHAR(50)
		BEGIN TRANSACTION
			SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType
			INSERT INTO securityDocument (
				 securityTypeId
				,securityType
				,[fileName]
				,fileDescription
				,fileType
				,createdBy
				,createdDate
				,sessionId
			)
			SELECT
				 @securityTypeId
				,@securityType
				,@fileName
				,@fileDescription
				,@fileType
				,@user
				,GETDATE()
				,@sessionId
			
			SET @sdId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sdId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @sdId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		DECLARE @string VARCHAR(100)
		SET @string = 'File Uploaded as ' + @fileName
		EXEC proc_errorHandler 0, @string, @fileName
	END

	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM securityDocument WITH(NOLOCK) WHERE sdId = @sdId
	END

	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			--SELECT CAST(sdId AS VARCHAR) + '.' + fileType AS [fileName] from securityDocument WHERE sdId IN (@sdIds)
			SET @sql='SELECT fileName FROM securityDocument WHERE sdId IN (' + @sdIds + ')'
			EXEC(@sql)
			set @sql='DELETE FROM securityDocument where sdId in (' + @sdIds + ')'
			EXEC(@sql)
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @sdId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @sdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					RETURN
			END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	END

	ELSE IF @flag = 's'
	BEGIN
		SELECT 
			 sdId
			,securityTypeId
			,securityType
			,[fileName]
			,fileDescription
			,fileType
			,createdBy
			,createdDate
			,isDeleted
		FROM securityDocument WITH(NOLOCK)
		WHERE securityTypeId = @securityTypeId 
			AND securityType = @securityType
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sdId
END CATCH



GO
