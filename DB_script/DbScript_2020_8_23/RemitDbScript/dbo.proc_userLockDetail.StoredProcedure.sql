USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userLockDetail]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_userLockDetail]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@userLockId						INT				= NULL
	,@userId                             VARCHAR(30)	= NULL
	,@startDate                         VARCHAR(20)		= NULL
	,@endDate                           VARCHAR(20)				= NULL
	,@lockDesc							VARCHAR(MAX)	= NULL
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
		 @logIdentifier = 'userLockId'
		,@logParamMain = 'userLockDetail'
		,@logParamMod = 'messageMod'
		,@module = '10'
		,@tableAlias = ''
	IF @flag = 'i'
	BEGIN
	--select userLockId,userId,startDate,endDate,startExec,startExecDate,endExec,endExecDate,createdBy,createdDate from userLockDetail

		BEGIN TRANSACTION
			INSERT INTO userLockDetail (
				 userId
				,startDate
				,endDate
				,lockDesc
				,createdBy
				,createdDate
			)
			SELECT
				 @userId
				,@startDate
				,@endDate
				,@lockDesc
				,@user
				,GETDATE()
			
			SET @userLockId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLockId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userLockId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @userLockId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @userLockId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT userLockId,userId,CONVERT(VARCHAR,startDate,101) startDate,CONVERT(VARCHAR,endDate,101) endDate,lockDesc,createdBy,createdDate
		FROM userLockDetail WITH(NOLOCK) WHERE userLockId = @userLockId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE userLockDetail SET
				 userId = @userId
				,startDate = @startDate
				,endDate = @endDate
				,lockDesc = @lockDesc
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE userLockId = @userLockId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLockId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userLockId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @userLockId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @userLockId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE userLockDetail SET
				isDeleted =	'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy	= @user
			WHERE userLockId	= @userLockId
			SET	@modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow	@logParamMain, @logIdentifier,	@userLockId,	@oldValue OUTPUT
			INSERT INTO	#msg(errorCode,	msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,	 @userLockId, @user,	@oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg	WHERE errorCode	<> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete	record.', @userLockId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @userLockId
	END	  
--EXEC [proc_applicationUsers] @flag = 's'  ,@pageNumber='1', @pageSize='40', @sortBy='userId', @sortOrder='ASC', @user = 'admin'
	ELSE IF @flag IN ('s')			--Common Message
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'userLockId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.userLockId
					,main.userId
					,AU.userName
					,startDate = CONVERT(VARCHAR,main.startDate,101)
					,endDate = CONVERT(VARCHAR,main.endDate,101)
					,main.lockDesc 
					,agentName = AM.agentName
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM userLockDetail main WITH(NOLOCK)
				INNER JOIN applicationUsers AU WITH(NOLOCK) ON main.userId = AU.userId
				INNER JOIN agentMaster AM WITH(NOLOCK) ON AM.agentId=AU.agentId
				WHERE 1=1
					) x'
	END

	--select * from userLockDetail
	--select * from applicationUsers
	IF @flag IN('s')
	BEGIN
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, ''N'') <> ''Y'''
		
		IF @userId IS NOT NULL
			SET @sql_filter=@sql_filter + ' AND userId ='''+@userId+''''
		SET @select_field_list ='
			 userLockId
			,userId
			,userName
			,startDate 
			,endDate
			,lockDesc
			,agentName
			,createdBy
			,createdDate
			,isDeleted '
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
			
			SELECT 1
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @userLockId
END CATCH



GO
