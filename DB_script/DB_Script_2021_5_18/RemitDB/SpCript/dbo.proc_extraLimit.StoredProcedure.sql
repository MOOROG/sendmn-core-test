USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_extraLimit]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_extraLimit]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId								INT				= NULL
	,@agentId							INT				= NULL
	,@extraLimit						MONEY			= NULL	
	,@approvedDate						DATETIME		= NULL
	,@approvedFromDate					DATETIME		= NULL
	,@approvedToDate					DATETIME		= NULL
	,@agentName							VARCHAR(200)	= NULL
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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT	

	SELECT
		 @ApprovedFunctionId = 20231130
		,@logIdentifier = 'id'
		,@logParamMain = 'extraLimit'
		,@logParamMod = 'extraLimit'
		,@module = '20'
		,@tableAlias = 'Extra Limit'
	
	IF @flag = 'i'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM agentMaster WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Agent is not active', @agentId
			RETURN
		END
		BEGIN TRANSACTION
	
			INSERT INTO extraLimit (
				 agentId
				,amount
				,status
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@extraLimit
				,'Requested'
				,@user
				,GETDATE()
								
			SET @rowId = SCOPE_IDENTITY()	
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END
	
	ELSE IF @flag = 'a1'
	BEGIN
		select * from extraLimit where id=@rowId
	END
	
	ELSE IF @flag = 'a' 
	BEGIN
		select a.maxLimitAmt,b.currencyCode from creditLimit a with(nolock) inner join currencyMaster b with(nolock) 
		on a.currency=b.currencyId where a.agentId=@agentId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM extraLimit WITH(NOLOCK)
			WHERE id = @rowId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @rowId
			RETURN
		END
		
		UPDATE extraLimit SET status='Deleted' WHERE id=@rowId

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
		
	END

	ELSE IF @flag = 's' -- Load History Grid
	BEGIN
	
			IF @sortBy IS NULL
				SET @sortBy = 'createdDate'
			IF @sortOrder IS NULL
				SET @sortOrder = 'ASC'
		
			SET @table = '
			(									
				SELECT a.id
					,b.agentName
					,a.amount  extraLimit
					,a.status
					,a.createdBy
					,a.createdDate
					,a.approvedBy
					,a.approvedDate
				FROM extraLimit a WITH(NOLOCK) INNER JOIN agentMaster b WITH(NOLOCK) ON a.agentId=B.agentId
				WHERE 1=1'			
			
			SET @sql_filter = ''
			
			IF @extraLimit IS NOT NULL
				SET @table = @table + ' AND extraLimit = ''' + CAST(@extraLimit AS VARCHAR) + ''''
				
			IF @approvedDate IS NOT NULL
				SET @table = @table + ' AND a.approvedDate BETWEEN ''' + CONVERT(VARCHAR,@approvedDate,101) + ''' AND ''' + CONVERT(VARCHAR,@approvedDate,101) + ' 23:59'''
			
			IF @approvedFromDate IS NOT NULL AND @approvedToDate IS NOT NULL
				SET @table = @table + ' AND a.approvedDate BETWEEN ''' + CONVERT(VARCHAR,@approvedFromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@approvedToDate,101) + ' 23:59'''
				
			IF @agentId IS NOT NULL
				SET @table = @table + ' AND a.agentId = ''' + CAST(@agentId AS VARCHAR) + ''''
				
			SET @table=@table+' )x'
			
		SET @select_field_list ='
				 id
				,agentName
				,extraLimit
				,status
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
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
	
	ELSE IF @flag = 's1' -- Pending List for approval
	BEGIN
			SELECT
				 b.agentName [Agent]
				,a.amount [Extra Limit]
				,a.status [Status]
				,a.createdBy [Requested User]
				,a.createdDate [Requested Date]
			FROM extraLimit a WITH(NOLOCK) INNER JOIN agentMaster b WITH(NOLOCK) ON a.agentId=b.agentId
			WHERE a.agentId=@agentId AND a.approvedDate is null
	END
	
	IF @flag='S2' -- Approve list
	BEGIN
			IF @sortBy IS NULL
				SET @sortBy = 'createdDate'
			IF @sortOrder IS NULL
				SET @sortOrder = 'ASC'
		
			SET @table = '
			(									
				SELECT 
					 a.id
					,a.agentId
					,b.agentName
					,a.amount  extraLimit
					,a.status
					,a.createdBy
					,a.createdDate
					,a.approvedBy
					,a.approvedDate
					,''Y'' hasChanged
				FROM extraLimit a WITH(NOLOCK) INNER JOIN agentMaster b WITH(NOLOCK) ON a.agentId=B.agentId
				WHERE a.approvedDate is null
			'			
			
			SET @sql_filter = ''
			
			IF @extraLimit IS NOT NULL
				SET @table = @table + ' AND extraLimit = ''' + CAST(@extraLimit AS VARCHAR) + ''''
				
			IF @approvedDate IS NOT NULL
				SET @table = @table + ' AND CAST(approvedDate AS DATE) = ''' + cast(@approvedDate as varchar(11))+ ''''
				
			IF @agentName IS NOT NULL
				SET @table = @table + ' AND b.agentName LIKE ''%' + @agentName + '%'''
			
			SET @table=@table+' )x'
			
		SET @select_field_list =
			'
				 id
				,agentId
				,agentName
				,extraLimit
				,status
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
				,hasChanged
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
	
	IF @flag='approve' 
	BEGIN
		--EXEC proc_extraLimit  @flag = 'approve', @user = 'admin', @rowId = '1'
		BEGIN TRANSACTION

			SELECT @agentId = agentId,@extraLimit=amount FROM extraLimit WHERE id = @rowId
			UPDATE creditLimit SET todaysAddedMaxLimit=@extraLimit WHERE agentId = @agentId
			UPDATE extraLimit SET approvedBy=@user, approvedDate=GETDATE(),status='Approved' WHERE id = @rowId
	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been approved successfully.', @rowId
	END
	
	IF @flag='reject' 
	BEGIN
		--EXEC proc_extraLimit  @flag = 'approve', @user = 'admin', @rowId = '1'
		BEGIN TRANSACTION
			UPDATE extraLimit SET approvedBy=@user, approvedDate=GETDATE(),status='Rejected' WHERE id = @rowId	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been rejected successfully.', @rowId
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
