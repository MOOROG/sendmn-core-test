USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userZoneMapping]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_userZoneMapping]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@rowId							INT				= NULL
	 ,@zoneName							VARCHAR(100)	= NULL
	 ,@userName							VARCHAR(50)		= NULL       
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL


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
		,@errorMsg			VARCHAR(MAX)

IF @flag = 'a'
BEGIN 
    
    SELECT * FROM userZoneMapping WITH (NOLOCK)
    WHERE id = @rowId

END

IF @flag = 'd'
BEGIN 
	BEGIN TRANSACTION    
    UPDATE userZoneMapping SET isDeleted ='Y'
	   , modifiedBy=@user
	   , modifiedDate=GETDATE()
    WHERE id = @rowId

	INSERT INTO #msg(errorCode, msg, id)
	EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
		
	IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
	BEGIN
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		EXEC proc_errorHandler 1, 'Failed to delete record.', @rowid
		RETURN
	END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Record has been deleted successfully.', @rowid
END

IF @flag = 'u'
BEGIN 
	IF EXISTS(SELECT 'A' FROM userZoneMapping WITH(NOLOCK) WHERE userName = @userName  AND zoneName = @zoneName AND id <> @rowid AND ISNULL(isDeleted,'N') <> 'Y')
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN
	END
	BEGIN TRANSACTION
    UPDATE userZoneMapping 
	SET 
		  userName = @userName,
		  zoneName=@zoneName, 
		  modifiedBy=@user, 
		  modifiedDate=GETDATE()
    WHERE id = @rowid

	INSERT INTO #msg(errorCode, msg, id)
	EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
	IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
	BEGIN
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		EXEC proc_errorHandler 1, 'Failed to update record.', @rowid
		RETURN
	END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowid

END

IF @flag = 'i'
BEGIN 
	IF EXISTS(SELECT 'A' FROM userZoneMapping WHERE userName = @userName  AND zoneName = @zoneName AND ISNULL(isDeleted,'N') <> 'Y')
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN
	END
	BEGIN TRANSACTION
	     INSERT INTO userZoneMapping 
		 (
			 userName
			,zoneName
			,createdBy
			,createdDate
		)
		SELECT
			 @userName
			,@zoneName
			,@user
			,GETDATE()

		SET @rowid = SCOPE_IDENTITY()
	    INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to add new record.', @rowid
			RETURN
		END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowid

END

IF @flag = 's'
BEGIN			
	IF @sortBy IS NULL  
		SET @sortBy = 'createdDate'
	IF @sortOrder IS NULL  
		SET @sortOrder = 'DESC'			
		
	SET @table = '(		
					SELECT 
						 zm.id
						,zm.userName 
						,userFullName = au.firstName+'' ''+ISNULL(au.middleName,'''')+ '' ''+au.lastName
						,zm.zoneName						
						,zm.createdBy
						,zm.createdDate
					FROM userZoneMapping zm with(nolock)
					join applicationUsers au on au.userName = zm.userName
					WHERE isnull(zm.isDeleted,''N'') <> ''Y'''			
					
		SET @sql_filter = ''			
		SET @select_field_list = '
						   id
						  ,userName
						  ,userFullName
						  ,zoneName 
						  ,createdBy 
						  ,createdDate
						'
			
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND userName = ''' + @userName + ''''
		
		IF @zoneName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND zoneName = ''' + @zoneName + ''''		

		  SET @table =  @table +') x '



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
     EXEC proc_errorHandler 1, @errorMessage, @rowid
END CATCH



GO
