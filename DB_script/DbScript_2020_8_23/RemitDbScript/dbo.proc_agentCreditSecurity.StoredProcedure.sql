USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentCreditSecurity]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentCreditSecurity]
      @flag                         VARCHAR(50)		= NULL
     ,@user                         VARCHAR(30)		= NULL
     ,@agentId						VARCHAR(30)		= NULL
     ,@agentName					VARCHAR(100)	= NULL
	 ,@agentState					VARCHAR(100)	= NULL
	 ,@agentDistrict				VARCHAR(100)	= NULL
	 ,@agentLocation				VARCHAR(100)	= NULL
     ,@agentGroup					INT				= NULL   
     ,@sortBy                       VARCHAR(50)		= NULL
     ,@sortOrder                    VARCHAR(5)		= NULL
     ,@pageSize                     INT				= NULL
     ,@pageNumber                   INT				= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)		
	SELECT
		 @logIdentifier = 'agentId'
		,@logParamMain = 'agentMaster'
		,@tableAlias = 'Agent Setup'
		,@module = 20

	IF @flag = 's'
	BEGIN

		SET @table = '(
					SELECT
						 agentId = am.agentId
						,agentName = am.agentName
						,agentAddress = am.agentAddress
						,agentPhone = am.agentPhone1
						,agentState = am.agentState
						,agentDistrict = am.agentDistrict
						,agentLocation = adl.districtName
						,isSettlingAgent = am.isSettlingAgent
						,agentGrp = am.agentGrp
					FROM agentMaster am WITH(NOLOCK)
					LEFT JOIN api_districtList adl WITH(NOLOCK) ON am.agentLocation = adl.districtCode
					WHERE ISNULL(am.isDeleted, ''N'')  <> ''Y''
					AND ISNULL(am.isSettlingAgent, ''N'') = ''Y''
					AND am.agentCountry = ''Nepal''
					AND am.agentType = 2903 
											 
				)X'
		IF @sortBy IS NULL
		   SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
					
		SET @sql_filter = ''		

		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName+'%'''

		IF @agentLocation IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentLocation = ''' + @agentLocation +''''
		
		IF @agentState IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentState = ''' + @agentState +''''

		IF @agentDistrict IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentDistrict = ''' + @agentDistrict +''''

		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentId = ' + CAST(@agentId AS VARCHAR)
			
		SET @select_field_list ='
				 agentId 
				,agentName
				,agentAddress 
				,agentPhone
				,agentState
				,agentDistrict
				,agentLocation 
				,isSettlingAgent 
				,agentGrp 
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

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
