USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AgentBankMapping]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[Proc_AgentBankMapping]
(
 @flag								VARCHAR(50)	
,@user                              VARCHAR(100)	= NULL
,@superAgentId						VARCHAR(20)		= NULL
,@bankpartnerId						VARCHAR(20)		= NULL
,@bankpartnerName					VARCHAR(100)	= NULL
,@agentId							VARCHAR(20)		= NULL
,@agentName							VARCHAR(150)	= NULL
,@countryId                         VARCHAR(30)		= NULL
,@countryName                       VARCHAR(50)		= NULL
,@functionId                        VARCHAR(MAX)	= NULL
,@sortBy                            VARCHAR(50)		= NULL
,@sortOrder                         VARCHAR(5)		= NULL
,@pageSize                          INT				= NULL
,@pageNumber                        INT				= NULL
,@branchAddress						VARCHAR(150)	= NULL
,@branchName						VARCHAR(150)	= NULL

)
AS 
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY 
DECLARE
		 @sql				VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@str				VARCHAR(MAX)




IF @flag = 'agentmappingBank'
BEGIN 
	--IF NOT EXISTS(SELECT 'x' FROM AgetBankMapping WHERE superAgentId = @superAgentId AND bankpartnerId = @bankpartnerId )
	
	select @countryId = agentCountryId from agentMaster(nolock) where agentId = @bankpartnerId
	
	 SELECT
				@str = ISNULL(@str + '<br />', '') 
				+ '<input type = "checkbox"'
				+ ' value = "'				+ CAST(am.agentId AS VARCHAR) + '"'
				+ ' id = "chk_'				+ CAST(am.agentId AS VARCHAR) + '"'
				+ ' name = "functionId"'
				+ CASE WHEN X.bankId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
				+ '> <label class = "rights" for = "chk_'	+ CAST(am.agentId AS VARCHAR) + '">' + am.agentName + '</label>'
			FROM AGENTMASTER AM (NOLOCK) 
			LEFT JOIN (SELECT bankId FROM AgentBankMapping mp (NOLOCK) WHERE MP.bankpartnerId = @bankpartnerId)X ON X.bankId = am.agentId
			WHERE parentId <> @superAgentId AND agentType = 2903 AND IsIntl ='1'
			and agentCountryId = @countryId
			

	 SELECT agentName AS partnerName,@str AS checkbox  
	 FROM agentMaster am WITH(NOLOCK) WHERE agentApiType='Parent' and agentId = @bankpartnerId 		
END

ELSE IF @flag = 's'
BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'condition'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		SET @table = '(
				SELECT 
				rowId,
			bankpartnerId,
			bankpartnerName =am1.agentName,
			bankName = am.agentName,
			bankId,
		--	bankCountry,
			mp.createdBy,
			mp.createdDate
		 FROM AgentBankMapping mp WITH (NOLOCK)
		 INNER JOIN AgentMaster am WITH (NOLOCK) ON mp.bankId = am.agentId 
		 LEFT JOIN  AgentMaster am1 (NOLOCK) ON mp.bankpartnerId = am1.agentId
		 WHERE 1=1 
					
			) x'
			
		SET @sql_filter = ''

	
	
		IF @bankpartnerId IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND bankpartnerId = ''' + CAST(@bankpartnerId AS VARCHAR(50))+''''

		IF @bankpartnerName IS NOT NULL
		SET @sql_filter =  @sql_filter + ' AND bankpartnerName = ''' + CAST(@bankpartnerName AS VARCHAR(50))+''''
	
		SET @select_field_list ='
					rowId,
			bankpartnerId,
			bankpartnerName,
			bankName,
			bankId,
		--	bankCountry,
			createdBy,
			createdDate
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

ELSE IF @flag = 'i'
BEGIN
   IF EXISTS ( SELECT 'x' FROM AgentBankMapping WITH (NOLOCK) WHERE bankpartnerId = @bankpartnerId)
   BEGIN 
	   DELETE FROM AgentBankMapping WHERE bankpartnerId = @bankpartnerId
	   INSERT INTO AgentBankMapping(superAgentId, bankpartnerId, bankId, createdBy, createdDate, isActive)
	   SELECT @superAgentId,@bankpartnerId, value, @user, GETDATE(), 'Y' FROM dbo.Split(',',@functionId)
   END 
   ELSE 
   BEGIN
		INSERT INTO AgentBankMapping(superAgentId, bankpartnerId, bankId, createdBy, createdDate, isActive)
		SELECT @superAgentId,@bankpartnerId, value, @user, GETDATE(), 'Y' FROM dbo.Split(',',@functionId)
   END 
	Set @agentId = SCOPE_IDENTITY()
   	EXEC proc_errorHandler 0, 'Bank Mapping is Done Successfully.',  @agentId
END			

ELSE IF @flag = 'pickBranchById'
BEGIN 
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'branchName'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		SET @table = '(
		SELECT 
		agentId
		,branchName = agentName
		,agentCountry
		,agentAddress
		,agentPhone1 
		FROM AgentMaster am WITH (NOLOCK) 
		WHERE agentType=2904 AND parentId='''+ @agentId +'''
					
			) x'
			
		SET @sql_filter = ''
		IF @branchName IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND agentName like  ''%' + @branchName +'%'''
		IF @branchAddress IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND agentAddress = ''' + @branchAddress +''''
	
		SET @select_field_list ='
			 agentId
			,branchName
			,agentCountry
			,agentAddress
			,agentPhone1
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

END 

END TRY 

BEGIN CATCH 
  IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @countryId
END CATCH 
GO
