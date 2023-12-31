USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userGroupMapping]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_userGroupMapping]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@rowid							int				= NULL
	 ,@userId							int				= NULL
	 ,@userName							VARCHAR(50)		= NULL
     ,@GroupCat							varchar(200)		=null
	 ,@GroupDetail						int				= NULL
     ,@isDeleted                        CHAR(1)			= NULL     
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
    
    SELECT * From userGroupMapping with (nolock)
    where rowid= @rowid

END

ELSE IF @flag = 'd'
BEGIN 
   BEGIN TRANSACTION
    
    UPDATE userGroupMapping 
	   set isDeleted ='Y'
	   , modefiedBy=@user
	   , modefiedDate=GETDATE()
    where rowid= @rowid

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


ELSE IF @flag = 'u'
BEGIN 
	IF EXISTS(SELECT 'A' FROM userGroupMapping WHERE userId = @userId  AND groupDetail = @GroupDetail AND rowId <> @rowid AND ISNULL(isDeleted,'N') <> 'Y')
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN
	END
    --SELECT * FROM agentGroupMaping
BEGIN TRANSACTION
    UPDATE userGroupMapping 
	   set userId =@userId, 
		  userName = @userName,
		  groupCat=@GroupCat,
		  GroupDetail=@GroupDetail,	 
		  modefiedBy=@user, 
		  modefiedDate=GETDATE()
    WHERE rowid= @rowid


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

ELSE IF @flag = 'i'
BEGIN 
	IF EXISTS(SELECT 'A' FROM userGroupMapping WHERE userId = @userId  AND groupDetail = @GroupDetail AND ISNULL(isDeleted,'N') <> 'Y')
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN
	END
	BEGIN TRANSACTION
	     INSERT INTO 
		 userGroupMapping (
			 userId
			,userName
			,groupCat
			,groupDetail
			,createdBy
			,createdDate
		)
		SELECT
			 @userId
			 ,@userName
			,@GroupCat
			,@groupDetail
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



ELSE IF @flag = 's'
BEGIN 
			
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
						   rowID
						  ,rowID as ValueId
						  ,typeDesc as GroupCat
						  ,Det.detailDesc as SubGroup 
						  ,userName = Au.firstName+'' ''+ISNULL(Au.middleName,'''')+ '' ''+Au.lastName
						  ,G.createdBy
						  ,G.createdDate
						  ,G.userId
					   FROM userGroupMapping G
					   join staticDataType Cat on G.groupCat=Cat.typeID
					   join staticDataValue Det on G.groupDetail =Det.valueId
					   join applicationUsers Au on Au.userId = G.userId
					   WHERE isnull(G.isDeleted,''N'') <> ''Y''
					 

			 '	
		
					
		SET @sql_filter = ''	
		
		SET @select_field_list = '
						   rowID
						   ,ValueId
						  ,GroupCat
						  ,SubGroup 
						  ,userName 
						  ,createdBy
						  ,createdDate
						  ,userId
						'
			
		IF @GroupCat IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND GroupCat LIKE ''' + @GroupCat + '%'''
		
		IF @userId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND userId = ''' + CAST(@userId AS VARCHAR) + ''''		

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
