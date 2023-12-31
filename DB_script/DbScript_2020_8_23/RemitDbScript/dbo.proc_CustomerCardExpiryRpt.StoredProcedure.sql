USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_CustomerCardExpiryRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_CustomerCardExpiryRpt](
	@flag VARCHAR(20)=NULL
	,@asOnDate		VARCHAR(20)=NULL
	,@zone		VARCHAR(20)=NULL
	,@district	VARCHAR(50)=NULL
	,@agent		VARCHAR(20)=NULL
	,@agentGrp	VARCHAR(20)=NULL
	,@idType	VARCHAR(20)=NULL	
	,@user		VARCHAR(20)=NULL	
)AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN	
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))
	DECLARE 
		 @table			VARCHAR(MAX)	= NULL
		,@url			VARCHAR(max)	= ''			
		,@gobalFilter	VARCHAR(MAX)	= ''
		,@groupBy		VARCHAR(MAX)	= ''	
		,@tempSql		VARCHAR(MAX)	= ''

		SET @table='SELECT 
				 [Zone]=cm.pZone
				,[District]=cm.pDistrict
				,[Agent]=am.agentName
				,[AgentId]=am.agentId
				,[Agent Group]=CASE WHEN sv.detailTitle is NULL THEN ''IME HO'' ELSE sv.detailTitle END
				,[AgentGroupId]=am.agentGrp
				,[Id Type]=cm.idType
				,[Expired]=CASE WHEN cm.expiryDate<=''' + @asOnDate + ''' THEN COUNT(''x'') ELSE ''0'' END
				,[Active]=CASE WHEN ISNULL(cm.isActive,''N'')=''Y'' THEN COUNT(''x'') ELSE ''0'' END
				,[Black Listed]=CASE WHEN ISNULL(cm.isBlackListed,''N'')=''Y'' THEN COUNT(''x'') ELSE ''0'' END
			FROM customerMaster cm WITH(NOLOCK)
			INNER JOIN agentMaster am WITH (NOLOCK) ON am.agentId=cm.agentId
			LEFT JOIN staticDataValue sv WITH (NOLOCK) on am.agentGrp=sv.valueId
			WHERE 1=1 '
			-------AND cm.expiryDate between isnull(@date,convert(varchar,cm.expiryDate,101)) and isnull(@date+'' 23:59:59'',convert(varchar,cm.expiryDate,101)+'' 23:59:59'')				
			SET @groupBy='GROUP BY cm.pZone,cm.pDistrict,am.agentName,am.agentId,am.agentGrp,sv.detailTitle,cm.idType,cm.expiryDate,cm.isActive,cm.isBlackListed'

	
	
	IF @asOnDate IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Till Date',@asOnDate 		

		SET @url=@url+'&asOnDate='+@asOnDate
		SET @gobalFilter=@gobalFilter+' AND cm.expiryDate < '''+@asOnDate+' 23:59:59'''
	END
	IF @zone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Zone',@zone 
		SET @url=@url+'&zone='+@zone
		SET @gobalFilter=@gobalFilter+' AND cm.pZone =isnull('''+@zone+''',cm.pZone)'
	END

	IF @district IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'District',@zone 
		SET @url=@url+'&district='+@district
		SET @gobalFilter=@gobalFilter+' AND cm.pDistrict =isnull('''+@district+''',cm.pDistrict)'
	END

	IF @agent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agent 
		SET @url=@url+'&agentId='+@agent
		SET @gobalFilter=@gobalFilter+' AND cm.agentId =isnull('''+@agent+''',cm.agentId)'
	END	

	IF @idType IS NOT NULL
	BEGIN
		DECLARE @idType1 VARCHAR(50)=null
		SET @idType1=REPLACE(@idType,'_',' ')

		INSERT INTO @FilterList 
		SELECT 'ID Type',@idType1 
		SET @url=@url+'&idType='+@idType
		SET @gobalFilter=@gobalFilter+' AND cm.idType =isnull('''+@idType1+''',cm.idType)'
	END	
	
	 
	IF @agentGrp IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Agent Group',detailTitle FROM dbo.staticDataValue WITH(NOLOCK) WHERE valueId=@agentGrp 
		SET @url=@url+'&agentGrp='+@agentGrp
		SET @gobalFilter=@gobalFilter+' AND am.agentGrp =isnull('''+@agentGrp+''',am.agentGrp)'
	END
	
	IF @flag='zw'
	BEGIN			
								
		SET @tempSql='SELECT 
			 [Zone]=''<a href="javascript:void(0)" onclick=OpenInNewWindow("Reports.aspx?reportName=customercardexpiryrpt&flag=dw'+@url+'")>''+[Zone]+''</a>''
			,[Expired]=SUM([Expired])
			,[Active]=SUM([Active])
			,[Black Listed]=SUM([Black Listed]) 
		FROM('+@table+@gobalFilter+@groupBy+') 
		x GROUP BY [Zone] ORDER BY [Zone]'


		--PRINT @tempSql
		--EXEC (@tempSql)
	END

	ELSE IF @flag='dw'
	BEGIN

		SET @tempSql='SELECT 
			 [District]=''<a href="javascript:void(0)" onclick=OpenInNewWindow("Reports.aspx?reportName=customercardexpiryrpt&flag=gw'+@url+'")>''+[District]+''</a>''
			,[Expired]=SUM([Expired])
			,[Active]=SUM([Active])
			,[Black Listed]=SUM([Black Listed]) 
		FROM('+@table+@gobalFilter+@groupBy+') 
		x GROUP BY [District] ORDER BY [District]'


		--PRINT @tempSql
		--EXEC (@tempSql)

	END

	ELSE IF @flag='aw'
	BEGIN

		SET @tempSql='SELECT 
			 [Agent]=''<a href="javascript:void(0)" onclick=OpenInNewWindow("Reports.aspx?reportName=customercardexpiryrpt&flag=detail'+@url+'")>''+[Agent]+''</a>''
			,[Expired]=SUM([Expired])
			,[Active]=SUM([Active])
			,[Black Listed]=SUM([Black Listed]) 
		FROM('+@table+@gobalFilter+@groupBy+') 
		x GROUP BY [Agent] ORDER BY [Agent]'


		--PRINT @tempSql
		--EXEC (@tempSql)
	END

	ELSE IF @flag='gw'
	BEGIN

		SET @tempSql='SELECT 
			 [Agent Group]=''<a href="javascript:void(0)" onclick=OpenInNewWindow("Reports.aspx?reportName=customercardexpiryrpt&flag=aw'+@url+'")>''+[Agent Group]+''</a>''
			,[Expired]=SUM([Expired])
			,[Active]=SUM([Active])
			,[Black Listed]=SUM([Black Listed]) 
		FROM('+@table+@gobalFilter+@groupBy+') 
		x GROUP BY [Agent Group] ORDER BY [Agent Group]'


		--PRINT @tempSql
		--EXEC (@tempSql)		
	END

	ELSE IF @flag='detail'
	BEGIN

		SET @table='SELECT 
			 [Membership Id]=cm.membershipId 
			,[Name]=isnull(cm.firstName,'''')+isnull(('' ''+cm.middleName),'''')+isnull(('' ''+cm.lastName),'''')
			,[Zone]=cm.pZone
			,[Address]=cm.pDistrict
			,[Mobile NO]=cm.mobile
			,[ID Type]=cm.idType
			,[Issue Date]= CONVERT(VARCHAR, cm.issueDate, 101)
			,[Expiry Date]= CONVERT(VARCHAR, cm.expiryDate, 101)
			,[Agent AND User]=am.agentName+'' \ ''+cm.createdBy			
		FROM customerMaster cm WITH(NOLOCK)
		INNER JOIN agentMaster am WITH (NOLOCK) on am.agentId=cm.agentId		
		LEFT JOIN staticDataValue sv WITH (NOLOCK) on am.agentGrp=sv.valueId WHERE 1=1 ' +@gobalFilter

		SET @tempSql='SELECT * FROM ('+@table+') x WHERE 1=1'

		--PRINT @tempSql
		--EXEC (@tempSql)
		
	END

	ELSE IF @flag='sumamry'
	BEGIN

		SET @tempSql='SELECT 
			 [Id Type]=''<a href="javascript:void(0)" onclick=OpenInNewWindow("Reports.aspx?reportName=customercardexpiryrpt&flag=detail'+@url+'")>''+[Id Type]+''</a>''
			,[Expired]=SUM([Expired])
			,[Active]=SUM([Active])
			,[Black Listed]=SUM([Black Listed]) 
		FROM('+@table+@gobalFilter+@groupBy+') 
		x GROUP BY [Id Type] ORDER BY [Id Type]'
				
	END

	PRINT @tempSql
	EXEC (@tempSql)

	INSERT INTO @FilterList
	SELECT 'Report Type',CASE WHEN @flag='zw' THEN 'ZONE WISE'
							  WHEN @flag='dw' THEN 'DISTRICT WISE'
							  WHEN @flag='aw' THEN 'AGENT WISE'
							  WHEN @flag='gw' THEN 'GROUP WISE'
							  WHEN @flag='sumamry' THEN 'SUMMARY'
							  WHEN @flag='detail' THEN 'DETAIL' ELSE '' END
							

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	SELECT * FROM @FilterList	
	
	SELECT 'CUSTOMER CARD EXPIRY REPORT' title

END


GO
