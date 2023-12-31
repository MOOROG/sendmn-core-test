USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentMasterTempReport]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_agentMasterTempReport](
      @functionID		VARCHAR(100)
	,@user				VARCHAR(30)
	,@pageFrom			INT
	,@pageTo			INT
	,@branch			INT
	,@agent				INT	
	,@fxml				XML = NULL
	,@qxml				XML = NULL
	,@dxml				XML = NULL
	,@downloadAll		CHAR(1) = NULL
)AS

SET NOCOUNT ON
SET @pageFrom = ISNULL(NULLIF(@pageFrom, 0), 1)
SET @pageTo = ISNULL(@pageTo, @pageFrom)
DECLARE @pageSize INT = 50

IF @functionID='20168100'
BEGIN
	DECLARE @fromDate VARCHAR(50),	
		@toDate varchar(20),
		@templateId varchar(20),
		@rptType varchar(50),
		@fields varchar(max),
		@sql varchar(max),
		@agentStatus varchar(10),
		@agentGrp varchar(10)

	SELECT
		  @fromDate = p.value('@fromdate','VARCHAR(50)')
		 ,@toDate = p.value('@todate','VARCHAR(50)')	
		 ,@rptType = p.value('@reporttype','VARCHAR(50)')	
		 ,@templateId = p.value('@templateid','VARCHAR(50)')	
		 ,@agentStatus = p.value('@agentstatus','varchar(50)')	
		 ,@agentGrp = p.value('@agentgrp','varchar(50)')	
	FROM @fxml.nodes('/root/row') AS tmp(p)

	SELECT @fields = fieldsAlias FROM ReportTemplate with(nolock) WHERE id = @templateId

	SET @sql='
		SELECT 
			'+@fields+' 
		FROM DBO.vw_agentMaster vam WITH(NOLOCK) 
		WHERE [Created Date] between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''

	IF @agentStatus IS NOT NULL AND @agentStatus IN ('Unblock','Block')
		--SET @sql = @sql+ ' AND [Agent Block] ='''+@agentStatus+''' and agentBlock1  = '''+@agentStatus+''' '
		SET @sql = @sql+ ' AND [Agent Block] ='''+@agentStatus+''''
		
	IF @agentStatus IS NOT NULL AND @agentStatus IN ('Active','Inactive')
		--SET @sql = @sql+ ' AND [Is Active] ='''+@agentStatus+''' and isActive1 = '''+@agentStatus+''''
		SET @sql = @sql+ ' AND [Is Active] ='''+@agentStatus+''''

	IF @agentGrp IS NOT NULL 
		SET @sql = @sql+ ' AND agentGrp ='''+@agentGrp+''''
		
	if @rptType ='all-dom'
		SET @sql = @sql+ ' AND (agentType = 2904 or (agentType = 2903 and actAsBranch = ''Y'') )
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND agentCountry = ''Nepal'''


	if @rptType ='all-int'
		SET @sql = @sql+ ' AND (agentType = 2904 or (agentType = 2903 and actAsBranch = ''Y'') )
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND agentCountry <> ''Nepal'''

	if @rptType ='all-sending-dom'
		SET @sql = @sql+ ' AND (agentType = 2904 or (agentType = 2903 and actAsBranch = ''Y'') )
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND agentCountry = ''Nepal''
							AND isnull(agentRole ,''B'') <> ''R'''

	if @rptType ='all-sending-int'
		SET @sql = @sql+ ' AND (agentType = 2904 or (agentType = 2903 and actAsBranch = ''Y'') )
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND agentCountry <> ''Nepal''
							AND isnull(agentRole ,''B'') <> ''R'''

	if @rptType ='all-sending'
		SET @sql = @sql+ ' AND (agentType = 2904 or (agentType = 2903 and actAsBranch = ''Y'') )
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND isnull(agentRole ,''B'') <> ''R'''

	if @rptType ='all-paying'
		SET @sql = @sql+ ' AND (agentType = 2904 or (agentType = 2903 and actAsBranch = ''Y'') )
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND isnull(agentRole ,''B'') <> ''S'''

	if @rptType ='private-agent'
		SET @sql = @sql+ ' AND agentType = 2903 
							AND actAsBranch = ''Y''
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND agentCountry=''Nepal'''

	if @rptType ='bank-finance'
		SET @sql = @sql+ ' AND agentType = 2904 
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId <> 5576
							AND agentCountry=''Nepal'''

	if @rptType ='college'
		SET @sql = @sql+ ' AND agentType = 2903 
							AND actAsBranch = ''Y''
							AND isnull(isDeleted,''N'')=''N'' 
							AND parentId = 5576
							AND agentCountry=''Nepal'''

	IF @downloadAll = 'y'
	BEGIN
		SET @sql = '
		
			SELECT 
				ROW_NUMBER() OVER (ORDER BY [AGENT NAME]) AS [S.N.],*
			FROM 
			(
				'+@sql+'
			)X '
	

		SET  @sql =@sql +'
			ORDER BY [AGENT NAME]'
	END
	ELSE
	BEGIN
		SET @sql = '
		SELECT 
			*			
		FROM (		
			SELECT 
				ROW_NUMBER() OVER (ORDER BY [AGENT NAME]) AS [S.N.],*
			FROM 
			(
				'+@sql+'
			)X 
		)x WHERE [S.N.] BETWEEN (('+CAST(@pageFrom AS VARCHAR)+' - 1) * '+CAST(@pageSize AS VARCHAR)+' + 1) AND '+CAST(@pageTo AS VARCHAR)+' * '+CAST(@pageSize AS VARCHAR)+''

		SET  @sql =@sql +'
		ORDER BY [AGENT NAME]'
	END
	PRINT(@sql)
	EXEC(@sql)	
		
	UPDATE #params SET 
		 ReportTitle='Agent Master Report'
		,Filters= 'From Date =' +@fromDate+'|To Date='+@toDate
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END		
		,IncludeSerialNo=0
		,PageNumber=@pageFrom
		,PageSize=@pageSize
		,LoadMode = 2

	SELECT * FROM #params
	RETURN



END




GO
