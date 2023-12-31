USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryGroupMapping]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Exec [proc_countryGroupMapping] @flag = 'l', @rowid = '1'
*/
CREATE proc [dbo].[proc_countryGroupMapping]
	@flag                       VARCHAR(50)	= NULL
	,@user                      VARCHAR(30)	= NULL
    ,@rowid						int			= NULL
    ,@GroupCat					varchar(200)= null
	,@GroupDetail				int			= NULL
    ,@SubGroup					varchar(200)= null
	,@countryId					int			= null
    ,@countryName				varchar(200)= null	
    ,@isDeleted                 CHAR(1)		= NULL     
    ,@sortBy                    VARCHAR(50)	= NULL
    ,@sortOrder                 VARCHAR(5)	= NULL
    ,@pageSize                  INT			= NULL
    ,@pageNumber                INT			= NULL


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

	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)


IF @flag = 'gl' -- Populate Group according to country
BEGIN
	SELECT 
		 groupId = groupDetail
		,groupName = sdv.detailTitle
	FROM countryGroupMaping cgm
	INNER JOIN staticDataValue sdv ON cgm.groupDetail = sdv.valueId
	WHERE cgm.countryId = @countryId AND cgm.groupCat = @GroupCat AND ISNULL(cgm.isDeleted, 'N') = 'N'
END

IF @flag = 'a'
BEGIN 
    
    SELECT * From countryGroupMaping with (nolock)
    where rowid= @rowid

END

ELSE IF @flag = 'd'
BEGIN 
    BEGIN TRANSACTION
    UPDATE countryGroupMaping 
	   set isDeleted ='Y', ModifiedBy=@user, ModifiedDate=GETDATE()
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

    --SELECT * FROM countryGroupMaping
    IF EXISTS(SELECT 'X' FROM countryGroupMaping WHERE 
					countryId = @countryId 
				AND groupCat = @GroupCat
				AND groupDetail = @GroupDetail 
				AND ISNULL(isDeleted,'N') <> 'Y' 
				AND groupCat <> '6900' AND rowId <> @rowid)
	BEGIN
		EXEC proc_errorHandler 1, 'Group already added.', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT 'X' FROM countryGroupMaping WHERE 
					countryId = @countryId 
				AND groupCat = @GroupCat 
				AND groupDetail = @GroupDetail 
				AND rowId <> @rowid AND ISNULL(isDeleted,'N') <> 'Y' )
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN;
	END
	
BEGIN TRANSACTION
    UPDATE countryGroupMaping 
	   SET countryId	=	@countryId, 
		  groupCat		=	@GroupCat,
		  GroupDetail	=	@GroupDetail,	 
		  ModifiedBy	=	@user, 
		  ModifiedDate	=	GETDATE()
    WHERE rowid	= @rowid


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
	IF EXISTS(SELECT 'A' FROM countryGroupMaping WHERE 
					countryId = @countryId 
				AND groupCat = @GroupCat
				AND groupDetail = @GroupDetail 
				AND ISNULL(isDeleted,'N') <> 'Y' 
				AND groupCat <> '6900'
				)
	BEGIN
		EXEC proc_errorHandler 1, 'Group already added.', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT 'A' FROM countryGroupMaping WHERE 
					countryId = @countryId 
				AND groupCat = @GroupCat 
				AND groupDetail = @GroupDetail 
				AND ISNULL(isDeleted,'N') <> 'Y'
				)
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN;
	END
	
	BEGIN TRANSACTION
	     INSERT INTO 
		 countryGroupMaping (
			 countryId
			,groupCat
			,groupDetail
			,createdBy
			,createdDate
		)
		SELECT
			 @countryId
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
	
	  -- DECLARE 
			-- @selectFieldList	VARCHAR(MAX)
			--,@extraFieldList	VARCHAR(MAX)
			--,@sqlFilter		VARCHAR(MAX)
			--,@createdBy varchar(200)
			--,@createdDate datetime
			
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
						  ,Am.countryName 
						  ,G.createdBy
						  ,G.createdDate
						  ,G.countryId
					   FROM countryGroupMaping G
					   join staticDataType Cat on G.groupCat=Cat.typeID
					   join staticDataValue Det on G.groupDetail =Det.valueId
					   join countryMaster Am on Am.countryId = G.countryId
					   WHERE isnull(G.isDeleted,''N'') <> ''Y''
					 

			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,ValueId
						  ,GroupCat
						  ,SubGroup 
						  ,countryName 
						  ,createdBy
						  ,createdDate
						  ,countryId
						'
			
		IF @GroupCat IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND GroupCat LIKE ''' + @GroupCat + '%'''		

	     IF @SubGroup IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND SubGroup LIKE ''' + @SubGroup + '%'''		

		IF @countryName IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND countryName LIKE ''' + @countryName + '%'''		
		
		IF @countryId IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND countryId = ' + CAST(@countryId AS VARCHAR)+ ''

		
		  SET @table =  @table +') x '



		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
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
