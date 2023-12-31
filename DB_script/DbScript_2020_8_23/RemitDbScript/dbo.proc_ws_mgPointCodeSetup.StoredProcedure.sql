USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ws_mgPointCodeSetup]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_ws_mgPointCodeSetup] (	 
	 @flag				VARCHAR(50)	
	,@rowId				INT				= NULL
	,@branchId			INT				= NULL
	,@user				VARCHAR(30)		= NULL	
	,@agentId			VARCHAR(50)		= NULL
	,@agentName			VARCHAR(200)	= NULL
	,@zone				VARCHAR(50)		= NULL
	,@district			VARCHAR(50)		= NULL
	,@location			VARCHAR(50)		= NULL
	,@tokenId			VARCHAR(50)		= NULL
	,@mgAgentId			VARCHAR(50)		= NULL
	,@agentSequence		VARCHAR(50)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@pageSize			VARCHAR(50)		= NULL
	,@pageNumber		VARCHAR(50)		= NULL
	
) 
AS
SET NOCOUNT ON;


	IF @flag = 'pointcode'
	BEGIN
		IF @branchId IS NULL
			SELECT @branchId = agentId  FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

		IF NOT EXISTS(SELECT 'x' FROM mgPointCodeSetup WITH(NOLOCK) WHERE agentId = @branchId)
			SET @branchId = -1

		IF @branchId = -1 --admin
		BEGIN
			SELECT '3' AgentSequence, '43750935' AgentId, '818397' Token
			--SELECT '1' AgentSequence, '30053755' AgentId, 'TEST' Token
			RETURN		
		END
		SELECT agentSequence, mgAgentId, Token FROM mgPointCodeSetup  WITH(NOLOCK) WHERE agentId = @branchId
		RETURN
	END

	DECLARE 
		 @selectFieldList	VARCHAR(MAX)
		,@extraFieldList	VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@sqlFilter			VARCHAR(MAX)	
		,@modeType			VARCHAR(50)		
		,@newValue			VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)

	IF @flag = 's' 	
	BEGIN 	
		SET @sortBy = 'agentName'
		SET @sortOrder = 'desc'					
	
		SET @table = '
			(
				select 
					rowId = mg.rowId,
					agentId = mg.agentId,
					agentName = am.agentName,
					zone = am.agentState,
					district = am.agentDistrict,
					location = al.districtName,	
					tokenId = mg.token,	
					MGAgentId = mg.mgAgentId,
					agentSequence = mg.agentSequence
				from mgPointCodeSetup mg with(nolock)
				inner join agentMaster am with(nolock) on mg.agentId = am.agentId
				inner join api_districtList al with(nolock) on am.agentLocation = al.districtCode 
				where 1=1
			'		
										
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			   rowId
			 , agentId
			 , agentName
			 , zone
			 , district
			 , location
			 , tokenId
			 , MGAgentId
			 , agentSequence
			'
			
		IF @agentName IS NOT NULL
			SET @table = @table + ' AND am.agentName = ''' + @agentName + ''''

		IF @zone IS NOT NULL
			SET @table = @table + ' AND am.agentState LIKE ''' + @zone + '%'''

		IF @district IS NOT NULL
			SET @table = @table + ' AND al.districtName LIKE ''' + @district + '%'''

		IF @location IS NOT NULL
			SET @table = @table + ' AND am.agentDistrict LIKE ''' + @location + '%'''

		IF @tokenId IS NOT NULL
			SET @table = @table + ' AND mg.token = ''' + @tokenId + ''''

		SET @table = @table+' )x'
		 
		PRINT @table
		 
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

	IF @flag = 'i'
	BEGIN	
		IF EXISTS(SELECT 'x' FROM mgPointCodeSetup WITH(NOLOCK) WHERE agentId = @agentId)
		BEGIN
			EXEC proc_errorHandler 1, 'Token Id has already been assigned to this agent.', '' 
			RETURN;
		END

		INSERT INTO mgPointCodeSetup(mgAgentId,agentId,agentSequence,Token,createdBy,createdDate)VALUES
		(@mgAgentId,@agentId,@agentSequence,@tokenId,@user,GETDATE()) 	
			
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentId
	END

	IF @flag = 'u'
	BEGIN
	
		IF EXISTS(SELECT 'x' FROM mgPointCodeSetup WITH(NOLOCK) WHERE agentId = @agentId AND rowId <> @rowId)
		BEGIN
			EXEC proc_errorHandler 1, 'Token Id has already been assigned to this agent.', '' 
			RETURN;
		END
		UPDATE mgPointCodeSetup
			SET mgAgentId = @mgAgentId,
				agentId = @agentId,
				agentSequence = @agentSequence,
				Token = @tokenId,
				modifiedBy = @user,
				modifiedDate = GETDATE()
		WHERE rowId = @rowId
			
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @agentId
		RETURN
	END

	IF @flag = 'd'
	BEGIN
		UPDATE mgPointCodeSetup SET 
				isDeleted = 'Y',
				modifiedBy = @user,
				modifiedDate = GETDATE()
		WHERE rowId = @rowId
			
		EXEC proc_errorHandler 0, 'Record has been deleted successfully.', @agentId
		RETURN
	END

	IF @flag = 'a'
	BEGIN
		SELECT mg.rowId,mg.mgAgentId,mg.agentId,mg.agentSequence,mg.Token,am.agentName 
		FROM mgPointCodeSetup mg WITH(NOLOCK) 
		INNER JOIN agentMaster am with(nolock) on mg.agentId = am.agentId
		WHERE rowId = @rowId
		RETURN
	END


GO
