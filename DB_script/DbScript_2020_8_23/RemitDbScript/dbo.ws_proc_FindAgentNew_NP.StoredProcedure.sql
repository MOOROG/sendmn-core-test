USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_FindAgentNew_NP]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_proc_FindAgentNew_NP]
	@AGENT_CODE			varchar(50),
	@USER_ID			varchar(50),
	@PASSWORD			varchar(50),
	@AGENT_SESSION_ID	varchar(50),
	@ZONE				varchar(50),
	@DISTRICT			varchar(50)= null	,
	@SEARCH_TEXT		varchar(50)= null	,
	@PAGE_NUMBER		varchar(50),
	@COUNTRY			varchar(50),
	@AGENT_NAME			VARCHAR(50) = null	


AS
SET NOCOUNT ON
SET XACT_ABORT ON
/*


EXEC [ws_proc_FindAgentNew_NP]  
	 @USER_ID = 'n3p@lU$er'
	,@AGENT_CODE = '1001'
	,@PASSWORD = '36928c11f93d6b0cbf573d0e1ac350f7'
	,@AGENT_SESSION_ID	= ''
	,@ZONE				= 'Bagmati'
	,@DISTRICT			= null
	,@SEARCH_TEXT		= null
	,@PAGE_NUMBER		= '1'
	,@COUNTRY			= 'Nepal'
	,@AGENT_NAME		= 'ABI'
						
*/




IF @USER_ID IS NULL
BEGIN
	SELECT '1001' CODE, 'USER_ID Field is Empty' MESSAGE, NULL id
	RETURN
END
IF @AGENT_CODE IS NULL
BEGIN
	SELECT '1001' CODE, 'AGENT_CODE Field is Empty' MESSAGE, NULL id
	RETURN
END
	
IF @PASSWORD IS NULL
BEGIN
	SELECT '1001' CODE, 'PASSWORD Field is Empty' MESSAGE, NULL id
	RETURN
END
	
IF @USER_ID <> 'n3p@lU$er' OR @AGENT_CODE <> '1001' OR @PASSWORD <> '36928c11f93d6b0cbf573d0e1ac350f7'
BEGIN
	SELECT '1002' CODE,'Authentication Failed' MESSAGE, NULL id
	RETURN
END
DECLARE @sortBy VARCHAR(30) = 'AGENT_NAME'
DECLARE @sortOrder VARCHAR(30) = 'ASC'
DECLARE @table VARCHAR(MAX), @select_field_list VARCHAR(MAX)

SET @table = '(
		SELECT 
			CODE = ''0'' 
			,MESSAGE = ''Success''
			,AGENT_NAME = agentName
			,ADDRESS = agentAddress
			,CITY = agentCity
			,PHONE =  COALESCE(agentPhone1, agentPhone2, agentMobile1)
			,LAT = ''''
			,LAN = ''''
			,GMAP_URL = ''''
		FROM dbo.agentMaster WITH(NOLOCK)
		WHERE (agentType = 2904 OR (agentType = 2903 and actAsBranch = ''Y'') )
		AND ISNULL(isDeleted,''N'')=''N'' 
		AND ISNULL(isActive,''Y'')=''Y''
		AND ISNULL(agentBlock,''U'')=''U''
		AND parentId <>5576
		AND agentCountry = ''Nepal'''
			
		IF @ZONE IS NOT NULL
			SET @table = @table + '	AND agentState LIKE ''' + @ZONE + '%' + ''''

		IF @DISTRICT IS NOT NULL
			SET @table = @table + '	AND agentDistrict LIKE ''' + @DISTRICT + '%' + ''''
		
		IF @AGENT_NAME IS NOT NULL
			SET @table = @table + '	AND (agentName LIKE ''' + @AGENT_NAME + '%'')'

		IF @SEARCH_TEXT IS NOT NULL
			SET @table = @table + '	AND (agentName LIKE ''' + @SEARCH_TEXT + '%'' OR agentAddress LIKE ''' + @SEARCH_TEXT + '%'')'

		SET @table = @table + '	) x'		
			 
		EXEC dbo.proc_paging
			@table
			,''
			,'CODE, MESSAGE, AGENT_NAME, ADDRESS, CITY, PHONE, LAT, LAN, GMAP_URL'
			,''
			,@sortBy
			,@sortOrder
			,25
			,@PAGE_NUMBER





GO
