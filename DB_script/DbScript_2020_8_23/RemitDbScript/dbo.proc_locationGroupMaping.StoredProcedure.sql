USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_locationGroupMaping]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Exec [proc_locationGroupMaping] @flag = 'l', @rowid = '1'
*/
CREATE PROC [dbo].[proc_locationGroupMaping]
	@flag                       VARCHAR(50)	= NULL
	,@user                      VARCHAR(30)	= NULL
    ,@rowId						int			= NULL
    ,@GroupCat					VARCHAR(20) = NULL
	,@GroupDetail				VARCHAR(20) = NULL
	,@locationCode				VARCHAR(MAX) = NULL
	,@districtName				VARCHAR(100)= NULL
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

IF @flag = 'a'
BEGIN 
    
    SELECT * From locationGroupMaping with (nolock)
    where rowid= @rowid

END

ELSE IF @flag = 'd'
BEGIN 
    BEGIN TRANSACTION
		UPDATE locationGroupMaping SET 
			 isDeleted		= 'Y'
			,modifiedBy		= @user
			,modifiedDate	= GETDATE()
		WHERE rowId = @rowId

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
DECLARE @district_list TABLE(districtId INT)
    SET @sql = '
			SELECT 
				districtId 
			FROM zoneDistrictMap WITH(NOLOCK) 
			WHERE districtId IN (' + @locationCode + ')
			'
			
		INSERT @district_list
		EXEC (@sql)
		BEGIN TRANSACTION
			--DELETE FROM agentGroupMod WHERE groupId = @groupId
			INSERT locationGroupMaping(districtCode, groupCat,groupDetail, createdBy, createdDate)
			SELECT  districtId,@GroupCat,@GroupDetail, @user, GETDATE() FROM @district_list
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		EXEC proc_errorHandler 0, 'Location mapped successfully.', @GroupCat

END

ELSE IF @flag = 'i'
BEGIN 
	
	--IF EXISTS(SELECT 'A' FROM locationGroupMaping WHERE districtCode = @locationCode AND groupCat = @GroupCat AND groupDetail = @GroupDetail AND ISNULL(isDeleted,'N') <> 'Y')
	--BEGIN
	--	EXEC proc_errorHandler 1, 'Record already added.', @rowid
	--	RETURN;
	--END
	
	BEGIN TRANSACTION
	     INSERT INTO 
		 locationGroupMaping (
			 districtCode
			,groupCat
			,groupDetail
			,createdBy
			,createdDate
		)
		SELECT
			 @locationCode
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



IF @flag = 's'
BEGIN 
	
			
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
					SELECT 
						   lgm.rowID
						  ,GroupCat
						  ,GroupDetail
						  ,lgm.createdBy
						  ,lgm.createdDate
						  ,dist.districtId
						  ,dist.districtName
					FROM locationGroupMaping lgm
					INNER JOIN zoneDistrictMap dist on lgm.districtCode = dist.districtId
					WHERE ISNULL(lgm.isDeleted,''N'') = ''N''
					AND GroupCat = ''' + ISNULL(@GroupCat,'0') + '''
					AND GroupDetail = ''' + ISNULL(@GroupDetail,'0') + '''
				'	
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,GroupCat
						  ,GroupDetail 
						  ,districtName 
						  ,createdBy
						  ,createdDate
						  ,districtId
						'
			
		--IF @GroupCat IS NOT NULL
		--	SET @sqlFilter = @sqlFilter + ' AND GroupCat = ''' + @GroupCat + ''''		

	 --    IF @GroupDetail IS NOT NULL
		--	SET @sqlFilter = @sqlFilter + ' AND GroupDetail = ''' + @GroupDetail + ''''		

		IF @districtName IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND districtName LIKE ''' + @districtName + '%'''		
		
		IF @locationCode IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND districtId = ' + CAST(@locationCode AS VARCHAR)+ ''

		
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

IF @flag = 'sG'
BEGIN 
			
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
	SET @table = '(		
					SELECT 
						 districtId
						,districtName
						,createdBy
						,createdDate
					FROM zoneDistrictMap 
					WHERE districtId NOT IN (
						SELECT districtCode FROM locationGroupMaping 
						WHERE  ISNULL(isDeleted,''N'') <> ''Y''
						AND GroupCat = ''' + @GroupCat + ''')
						'
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   districtId
						  ,districtName
						  ,createdBy
						  ,createdDate
						'
						
		IF @districtName IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND districtName LIKE ''' + @districtName + '%'''		
		
		IF @locationCode IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND districtId = ' + CAST(@locationCode AS VARCHAR)+ ''

		
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
