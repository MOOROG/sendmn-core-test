USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentGroup]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_agentGroup]') AND TYPE IN (N'P', N'PC'))
--      DROP PROCEDURE [dbo].proc_agentGroup
--GO

/*
    Exec [proc_agentGroup] @flag = 'l', @rowid = '1'
    exec proc_agentGroup @flag = 'agentVsGroup'  ,@pageNumber='1', @pageSize='10', @sortBy='rowId', @sortOrder='ASC', @user = 'admin', @fromDate = '12/02/2014', @toDate = '12/30/2014'
*/
CREATE PROC [dbo].[proc_agentGroup]
	 @flag                          VARCHAR(50)		= NULL
	,@user                          VARCHAR(30)		= NULL
    ,@rowid							INT				= NULL
    ,@GroupCat						VARCHAR(200)	= NULL
	,@GroupDetail					INT				= NULL
    ,@SubGroup						VARCHAR(200)	= NULL
	,@agentid						INT				= NULL
    ,@agentName						VARCHAR(200)	= NULL	
    ,@isDeleted                     CHAR(1)			= NULL     
    ,@sortBy                        VARCHAR(50)		= NULL
    ,@sortOrder                     VARCHAR(5)		= NULL
    ,@pageSize                      INT				= NULL
    ,@pageNumber                    INT				= NULL
    ,@fromDate						VARCHAR(50)		= NULL
    ,@toDate						VARCHAR(50)		= NULL
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
		,@ApprovedFunctionId VARCHAR(MAX)

		DECLARE 
		 @selectFieldList	VARCHAR(MAX)
		,@extraFieldList	VARCHAR(MAX)
		,@sqlFilter		VARCHAR(MAX)

		SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'agentGroupMaping'
		,@tableAlias = 'Agent Group Maping'
		,@module = 10
		,@ApprovedFunctionId = '20101060'

IF @flag = 'a'
BEGIN 
    SELECT * From agentGroupMaping with (nolock) where rowid= @rowid
END

ELSE IF @flag = 'd'
BEGIN 
   
   	IF EXISTS (
			SELECT 'X' FROM agentGroupMaping WITH(NOLOCK)
			WHERE rowId = @rowid  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @rowid
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentGroupMapingHistory  WITH(NOLOCK)
			WHERE rowId = @rowid AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @rowid
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM agentGroupMaping WITH(NOLOCK) WHERE rowId = @rowid AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM agentGroupMaping WHERE rowId = @rowid
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
		
		INSERT INTO agentGroupMapingHistory(
					 rowId
					,agentId
					,groupCat
					,groupDetail
					,createdBy
					,createdDate
					,status
					,modType
				)
				SELECT
					 rowId
					,agentId
					,GroupCat
					,groupDetail
					,@user
					,GETDATE()
					,'Requested'
					,'D'
				FROM agentGroupMaping WHERE rowId = @rowid
				SET @modType = 'delete'	
					
    --UPDATE agentGroupMaping 
	   --SET isDeleted = 'Y', ModifiedBy = @user, ModifiedDate = GETDATE()
    --WHERE rowid = @rowid

	INSERT INTO #msg(errorCode, msg, id)
	EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
	
	IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
	BEGIN
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		EXEC proc_errorHandler 1, 'Failed to delete record.', @rowid
		RETURN
	END
	EXEC proc_errorHandler 0, 'Record has been deleted successfully.', @rowid
END


ELSE IF @flag = 'u'
BEGIN 
    --SELECT * FROM agentGroupMaping
    IF EXISTS(SELECT 'A' FROM agentGroupMaping WITH(NOLOCK) WHERE agentId = @agentid AND groupCat = @GroupCat AND ISNULL(isDeleted,'N') = 'N' 
							--AND groupCat<>'6900' 
							AND rowId <> @rowid)
	BEGIN
		EXEC proc_errorHandler 1, 'Group already added.', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT 'A' FROM agentGroupMaping WITH(NOLOCK) WHERE agentId = @agentid AND groupCat = @GroupCat AND groupDetail = @GroupDetail 
						AND rowId <> @rowid AND ISNULL(isDeleted,'N') = 'N' )
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN;
	END
	
BEGIN TRANSACTION
	IF EXISTS(SELECT 'X' FROM agentGroupMapingHistory WHERE approvedBy IS NULL AND rowId = @rowid)			
	BEGIN
		  UPDATE agentGroupMapingHistory 
		   set agentid = @agentid, 
			  groupCat = @GroupCat,
			  GroupDetail = @GroupDetail,	 
			  ModifiedBy = @user, 
			  ModifiedDate = GETDATE()
		  WHERE rowId = @rowid AND  approvedBy IS NULL	
	END
	ELSE
	BEGIN		  
		DELETE FROM agentGroupMapingHistory WHERE rowId = @rowid AND approvedBy IS NULL
		INSERT INTO 
		 agentGroupMapingHistory(
			 rowId
			,agentId
			,groupCat
			,groupDetail
			,createdBy
			,createdDate
			,status
			,modType
		)
		SELECT
			 @rowid
			,@agentId
			,@GroupCat
			,@groupDetail
			,@user
			,GETDATE()
			,'Requested'
			,'U'
	END

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
		
	-- ### checking for agent & branch while assigning group
	if ((select agentType from agentMaster WITH(NOLOCK) where agentId=@agentid) not in (2903,2904) and @GroupCat<>'6900')
	begin
		EXEC proc_errorHandler 1, 'Group can not assign except agent & branch!', @rowid
		return;
	end
	
	-- ### checking for agent while assigning group in branches
	DECLARE @parentId AS INT
	SELECT @parentId =parentId FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentid
	IF EXISTS(SELECT agentType,actAsBranch 
		from agentMaster where agentId= @parentId AND ISNULL(actAsBranch,'N')<>'Y' AND agentType=2903 and @GroupCat<>'6900')
	BEGIN
		IF EXISTS(SELECT 'X' FROM agentGroupMaping WITH(NOLOCK) WHERE agentId = @parentId AND groupCat <> 6900 AND groupCat = @GroupCat AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Group already added in agent!', @rowid
			RETURN;
		END
	END
	
	-- ### checking for agent while assigning group in branches
	IF EXISTS(select 'X' from agentGroupMaping a with(nolock) INNER JOIN agentMaster b with(nolock) on a.agentId=b.parentId
			WHERE b.parentId=@agentid and a.groupCat = @groupCat AND a.groupCat <> 6900 AND ISNULL(a.isDeleted, 'N') = 'N')
	BEGIN
		EXEC proc_errorHandler 1, 'Group already added in branch!', @rowid
		RETURN;
	
	END
	--select * from staticDataValue where valueId=2902
	

	
	IF EXISTS(SELECT 'A' FROM agentGroupMaping WITH(NOLOCK) 
		WHERE agentId = @agentid 
			 AND groupCat = @GroupCat 
			 AND ISNULL(isDeleted,'N') = 'N' 
			 --AND groupCat<>'6900'
			 )
	BEGIN
		EXEC proc_errorHandler 1, 'Group already added.', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT 'A' FROM agentGroupMaping WITH(NOLOCK) WHERE agentId = @agentid AND groupCat = @GroupCat AND groupDetail = @GroupDetail 
				AND ISNULL(isDeleted,'N') = 'N')
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN;
	END
	
	BEGIN TRANSACTION
			INSERT INTO 
			 agentGroupMaping (
				 agentId
				,groupCat
				,groupDetail
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@GroupCat
				,@groupDetail
				,@user
				,GETDATE()
			SET @rowid = SCOPE_IDENTITY()
				
			--IF @GroupCat = '6600'
			--BEGIN
				INSERT INTO 
				 agentGroupMapingHistory (
					rowId
					,agentId
					,groupCat
					,groupDetail
					,createdBy
					,createdDate
					,status
					,modType
				)
				SELECT
					@rowid
					,@agentId
					,@GroupCat
					,@groupDetail
					,@user
					,GETDATE()
					,'Requested'
					,'I'
			--END    

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
						   g.rowID
						  ,g.rowID as ValueId
						  ,typeDesc as GroupCat
						  ,Det.detailDesc as SubGroup 
						  ,Am.agentName 
						  ,G.createdBy
						  ,G.createdDate
						  ,G.agentId
						  ,modifiedDate	 = CASE WHEN G.approvedBy IS NULL THEN G.createdDate ELSE ISNULL(mode.createdDate, G.modifiedDate) END
						  ,modifiedBy	 = CASE WHEN G.approvedBy IS NULL THEN G.createdBy ELSE ISNULL(mode.createdBy, G.modifiedBy) END
						  ,hasChanged = CASE WHEN (G.approvedBy IS NULL) OR 
												(mode.status <> ''Approved'') 
											THEN ''Y'' ELSE ''N'' END
											
					   FROM agentGroupMaping G
					   join staticDataType Cat on G.groupCat=Cat.typeID
					   join staticDataValue Det on G.groupDetail =Det.valueId
					   join agentMaster Am on Am.agentId = G.agentId
					   LEFT JOIN agentGroupMapingHistory mode on mode.rowId = G.rowId
					   WHERE isnull(G.isDeleted,''N'') <> ''Y''
			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID,ValueId
						  ,GroupCat
						  ,SubGroup 
						  ,agentName 
						  ,createdBy
						  ,createdDate
						  ,agentId
						  ,modifiedDate	
						  ,modifiedBy							  
						  ,hasChanged
						'
			
		IF @GroupCat IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND GroupCat LIKE ''' + @GroupCat + '%'''		

	     IF @SubGroup IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND SubGroup LIKE ''' + @SubGroup + '%'''		

		IF @agentName IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND agentName LIKE ''' + @agentName + '%'''		
		
		IF @agentid IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND AGENTID = ' + CAST(@agentid AS VARCHAR)+ ''
		
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
						   rowID
						  ,groupCatiD = groupCat
						  ,groupDetailId = groupDetail
						  ,typeDesc as GroupCat
						  ,Det.detailDesc as SubGroup 
						  ,Am.agentName 
						  ,G.createdBy
						  ,G.createdDate
						  ,G.agentId
					   FROM agentGroupMaping G
					   join staticDataType Cat on G.groupCat=Cat.typeID
					   join staticDataValue Det on G.groupDetail =Det.valueId
					   join agentMaster Am on Am.agentId = G.agentId
					   WHERE isnull(G.isDeleted,''N'') <> ''Y''
						'
						
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,GroupCat
						  ,SubGroup 
						  ,agentName 
						  ,createdBy
						  ,createdDate
						  ,agentId
						  ,groupCatiD
						  ,groupDetailId
						'
			
		IF @GroupCat IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND groupCatiD = ''' + @GroupCat + ''''		

	     IF @SubGroup IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND groupDetailId = ''' + CAST(@SubGroup AS VARCHAR) + ''''		

		IF @agentName IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND agentName LIKE ''' + @agentName + '%'''		
		
		IF @agentid IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND AGENTID = ' + CAST(@agentid AS VARCHAR)+ ''

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

IF @flag = 'l'
BEGIN 
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
					SELECT 
						    Det.detailDesc as GroupName
						   ,Am.agentName 
						   ,G.createdBy
						   ,G.createdDate
						   ,valueId
					 FROM agentGroup G
					 join staticDataValue Det on G.groupId =Det.valueId
					 join agentMaster Am on Am.agentId = G.agentId
					 WHERE isnull(G.isDeleted,''N'') <> ''Y''
					 

			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						  GroupName
						  ,agentName 
						  ,createdBy
						  ,createdDate
						  ,valueId
						'
			
		IF @GroupCat IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND GroupName LIKE ''' + @GroupCat + '%'''		

		IF @agentName IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND agentName LIKE ''' + @agentName + '%'''		


		
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

IF @flag = 'approve'
BEGIN
		IF NOT EXISTS(SELECT 'X' FROM agentGroupMaping WITH(NOLOCK) WHERE rowId = @rowid AND approvedBy IS NULL)
		   AND 
		  NOT EXISTS(SELECT 'X' FROM agentGroupMapingHistory WITH(NOLOCK) WHERE rowId = @rowid)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rowid
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM agentGroupMaping WHERE approvedBy IS NULL AND rowId = @rowid)
					SET @modType = 'I'
		ELSE
			SELECT @modType = modType FROM agentGroupMapingHistory WHERE rowId = @rowid
		
		BEGIN TRANSACTION
		IF @modType = 'I'
		BEGIN --New record
			UPDATE agentGroupMaping SET
				 approvedBy = @user
				,approvedDate= GETDATE()
			WHERE rowId = @rowid
			
			UPDATE agentGroupMapingHistory SET					 
					 approvedBy = @user
					,approvedDate= GETDATE()
					,status='Approved'
				WHERE rowId = @rowid
				
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowid, @newValue OUTPUT
			
		END
		
		ELSE IF @modType = 'U'
		BEGIN
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowid, @oldValue OUTPUT
			UPDATE main SET
				 main.agentId = mode.agentId
				,main.groupCat = mode.groupCat
				,main.groupDetail =  mode.groupDetail
				,main.modifiedDate = GETDATE()
				,main.modifiedBy = @user
			FROM agentGroupMaping main
			INNER JOIN agentGroupMapingHistory mode ON mode.rowId = main.rowId
			WHERE mode.rowId = @rowid AND mode.approvedBy IS NULL
			
			UPDATE agentGroupMapingHistory SET					 
				 approvedBy = @user
				,approvedDate= GETDATE()
				,status='Approved'
			WHERE rowId = @rowid

			EXEC [dbo].proc_GetColumnToRow  'agentGroupMaping', 'rowid', @rowid, @newValue OUTPUT
		END
		
		ELSE IF @modType = 'D'
		BEGIN
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowid, @oldValue OUTPUT
			UPDATE agentGroupMaping SET
				 isDeleted = 'Y'
				,modifiedDate = GETDATE()
				,modifiedBy = @user					
			WHERE rowId = @rowid
			
			UPDATE agentGroupMapingHistory SET					 
				 approvedBy = @user
				,approvedDate= GETDATE()
				,status = 'Approved'
			WHERE rowId = @rowid
		END
		
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Could not approve the changes.', @rowid
			RETURN
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @rowid
			
END

ELSE IF @flag = 'reject'
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM agentGroupMaping WITH(NOLOCK) WHERE rowId = @rowid AND approvedBy IS NULL)
	   OR 
	   NOT EXISTS(SELECT 'X' FROM agentGroupMapingHistory WITH(NOLOCK) WHERE rowId = @rowid)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rowid
		RETURN
	END
		
	IF EXISTS (SELECT 'X' FROM agentGroupMaping WHERE approvedBy IS NULL AND rowId = @rowid)
	BEGIN --New record
		BEGIN TRANSACTION
			SET @modType = 'Reject'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowid, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowid, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rowid
				RETURN
			END
		DELETE FROM agentGroupMaping WHERE rowId =  @rowid
		UPDATE agentGroupMapingHistory SET status='Rejected',approvedBy=@user,approvedDate=GETDATE() where rowId =  @rowid
		--update FROM creditLimit WHERE crLimitId =  @crLimitId
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION
			SET @modType = 'Reject'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowid, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowid, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rowid
				RETURN
			END
			--DELETE FROM creditLimitHistory WHERE crLimitId = @crLimitId AND approvedBy IS NULL
			
			UPDATE agentGroupMapingHistory SET status='Rejected',approvedBy=@user,approvedDate=GETDATE() where rowId =  @rowid
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	END
	EXEC proc_errorHandler 0, 'Changes rejected successfully.', @rowid
END

IF @flag = 'agentVsGroup'
BEGIN
	IF @sortBy IS NULL  
	SET @sortBy = 'createdDate'
	
	IF @sortOrder IS NULL  
	SET @sortOrder = 'DESC'					
	
	SET @table = '(SELECT 
						   rowID
						  ,Am.agentName 
						  ,typeDesc as GroupCat
						  ,Det.detailDesc as SubGroup 
						  ,G.createdBy
						  ,G.createdDate
						  ,G.approvedBy
						  ,G.approvedDate
					   FROM agentGroupMapingHistory G
					   join staticDataType Cat on G.groupCat=Cat.typeID
					   join staticDataValue Det on G.groupDetail =Det.valueId
					   join agentMaster Am on Am.agentId = G.agentId
					   WHERE isnull(G.isDeleted,''N'') <> ''Y'' 
					) x'
		SET @sqlFilter = ''	
		
		 IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		  SET @sqlFilter = @sqlFilter + ' AND createdDate BETWEEN '''+@fromDate+''' and '''+@toDate+' 23:59:59'' '
		
		SET @selectFieldList = '
						   rowID
						  ,GroupCat
						  ,SubGroup 
						  ,agentName 
						  ,createdBy
						  ,createdDate
						  ,approvedBy
						  ,approvedDate
						'
			
		
		  
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
