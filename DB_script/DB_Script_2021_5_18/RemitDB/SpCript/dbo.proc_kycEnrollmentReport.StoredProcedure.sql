USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_kycEnrollmentReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_kycEnrollmentReport]
(
	 @rptType			VARCHAR(50)=NULL
	,@user				VARCHAR(30)=NULL		
	,@fromDate			VARCHAR(30)=NULL
	,@toDate			VARCHAR(30)=NULL
	,@sZone				VARCHAR(30)=NULL
	,@sAgent			VARCHAR(10)=NULL
	,@remitCardNo		VARCHAR(50)=NULL
	,@sDistrict			VARCHAR(100)=NULL
	
)AS
BEGIN
DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))

DECLARE 
	 @table			VARCHAR(MAX)	= NULL
	,@url			VARCHAR(max)	= NULL			
	,@gobalFilter	VARCHAR(MAX)	= ' WHERE 1=1 '
	,@groupBy		VARCHAR(500)	= NULL
	
	IF @rptType = 'agent-enroll-rpt'
	BEGIN
		SELECT 
			[S.N.]	= ROW_NUMBER() OVER(ORDER BY km.createdDate DESC),
			[IME Remit Card No.] = km.remitCardNo,
			[Customer Name] = ISNULL(' '+km.salutation,'')+' '+ isnull(' '+km.firstName,'')+ isnull(' '+km.middleName,'')+ isnull(' '+km.lastName,''),
			[Created By] = km.createdBy,
			[Created Date] = km.createdDate,
			[Status] = CASE WHEN km.approvedDate IS NULL THEN 'Unapproved' ELSE 'Approved' end
		FROM dbo.kycMaster km WITH(NOLOCK) 
		WHERE km.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59' 
			AND km.agentId = @sAgent 
			AND ISNULL(km.isDeleted,'N') = 'N'
			AND ISNULL(km.isActive,'Y') ='Y'

		RETURN;
	END

	IF @fromDate IS NOT NULL AND @toDate IS NOT NULL 
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'From Date',@fromDate 
		INSERT INTO @FilterList 
		SELECT 'To Date',@toDate 
		SET @gobalFilter=@gobalFilter+' AND ISNULL(km.isDeleted,''N'') = ''N'' AND km.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	END
	IF @sZone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Zone',@sZone 
		SET @gobalFilter=@gobalFilter+' AND am.agentState ='''+@sZone+''''
	END
	IF @sDistrict IS NOT NULL
    BEGIN
		INSERT INTO @FilterList 
		SELECT 'District',@sZone 
		SET @gobalFilter=@gobalFilter+' AND am.agentDistrict ='''+@sDistrict+''''
	END
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent 
		SET @gobalFilter=@gobalFilter+' AND km.agentId ='''+@sAgent+''''
	END	
	IF @remitCardNo IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'IME Remit Card Number',@remitCardNo
		SET @gobalFilter=@gobalFilter+' AND km.remitCardNo ='''+@remitCardNo+''''
	END

	IF @rptType='zone'
	BEGIN	
		--SET @gobalFilter=@gobalFilter+' group by am.agentState order by am.agentState ASC'				
		--SET @table='SELECT 
		--	 [S.N.]			= row_number()over(order by am.agentState)
		--	,[Zone]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300_enroll&rptType=district&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+am.agentState+''")>''+am.agentState+''</a>''						 
		--	,[Total Customer]	= CAST(count(''x'') AS VARCHAR(10))
			
		--FROM kycMaster km WITH(NOLOCK) 		
		--inner join agentMaster am with(nolock) on km.agentId = am.agentId ' +@gobalFilter 		
		--PRINT @table
		--EXEC(@table)

		SET @groupBy = ' GROUP BY km.zoneName'
		SET @gobalFilter = @gobalFilter+' GROUP BY am.agentState,km.cardStatus'
		SET @table='SELECT 
			[S.N.] = row_number()over(order by km.zoneName),
			[Zone Name] = ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300_enroll&rptType=district&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+km.zoneName+''")>''+km.zoneName+''</a>'',
			[Enrolled] = SUM(km.appCnt+km.penCnt),
			[Approved] = SUM(km.appCnt),
			[Pending] = SUM(km.penCnt)	
		FROM 
		(
			SELECT 
				 zoneName	= am.agentState
				,appCnt		= CASE WHEN cardStatus=''Approved'' THEN COUNT(''x'') ELSE ''0'' END
				,penCnt		= CASE WHEN cardStatus IN (''pending'',''Complain'') THEN COUNT(''x'') ELSE ''0'' END
			FROM dbo.kycMaster km WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON km.agentId = am.agentId '+@gobalFilter+' 			
		)km' + @groupBy
		PRINT @table
		EXEC(@table)

					
	END

	IF @rptType='district'
	BEGIN	
		--SET @gobalFilter=@gobalFilter+' group by am.agentDistrict order by am.agentDistrict ASC'				
		--SET @table='SELECT 
		--	 [S.N.]			= row_number()over(order by am.agentDistrict)
		--	,[District]		= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300_enroll&rptType=agent&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sDistrict=''+am.agentDistrict+''")>''+am.agentDistrict+''</a>''						 
		--	,[Total Customer]	= CAST(count(''x'') AS VARCHAR(10))
		--FROM kycMaster km WITH(NOLOCK)    
		--inner join agentMaster am with(nolock) on km.agentId = am.agentId ' +@gobalFilter 			
		--PRINT @table
		--EXEC(@table)		
		
		SET @groupBy = ' GROUP BY km.districtName'
		SET @gobalFilter = @gobalFilter+' GROUP BY am.agentDistrict,km.cardStatus'
		SET @table='SELECT 
			[S.N.] = row_number()over(order by km.districtName),
			[District Name] = ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300_enroll&rptType=agent&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sDistrict=''+km.districtName+''")>''+km.districtName+''</a>'',
			[Enrolled] = SUM(km.appCnt+km.penCnt),
			[Approved] = SUM(km.appCnt),
			[Pending] = SUM(km.penCnt)	
		FROM 
		(
			SELECT 
				 districtName	= am.agentDistrict
				,appCnt		= CASE WHEN cardStatus=''Approved'' THEN COUNT(''x'') ELSE ''0'' END
				,penCnt		= CASE WHEN cardStatus IN (''pending'',''Complain'') THEN COUNT(''x'') ELSE ''0'' END
			FROM dbo.kycMaster km WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON km.agentId = am.agentId '+@gobalFilter+' 			
		)km' + @groupBy
		PRINT @table
		EXEC(@table)		
	END

	IF @rptType='agent'
	BEGIN
--		SET @gobalFilter=@gobalFilter+' group by am.agentState,am.agentName,km.agentId order by am.agentState,am.agentName ASC'				
--		SET @table='SELECT 
--			 [S.N.]			= row_number()over(order by am.agentState,am.agentName)
--			,[Zone]			= am.agentState
--			,[Agent]		= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300_enroll&rptType=detail&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+am.agentState+''&sAgent=''+cast(km.agentId as varchar)+''")>''+am.agentName	+''</a>
--''						 
--			,[Total Customer]	= CAST(count(*) AS VARCHAR(10))
--		FROM kycMaster km WITH(NOLOCK)   
--		INNER JOIN agentMaster am WITH(NOLOCK) ON km.agentId = am.agentId ' +@gobalFilter		
--		PRINT @table
--		EXEC(@table)	 
		SET @groupBy = ' GROUP BY km.zoneName,km.agentName,km.agentId'
		SET @gobalFilter = @gobalFilter+' GROUP BY am.agentId,am.agentState,am.agentName,km.cardStatus'
		SET @table='SELECT 
			[S.N.] = row_number()over(order by km.zoneName,km.agentName),
			[Zone Name] = km.zoneName,
			[Agent Name] = ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300_enroll&rptType=detail&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+km.zoneName+''&sAgent=''+cast(km.agentId as varchar)+''")>''+km.agentName+''</a>'',
			[Enrolled] = SUM(km.appCnt+km.penCnt),
			[Approved] = SUM(km.appCnt),
			[Pending] = SUM(km.penCnt)	
		FROM 
		(
			SELECT 
				 zoneName		= am.agentState
				,agentId		= am.agentId
				,agentName		= am.agentName
				,appCnt		= CASE WHEN cardStatus=''Approved'' THEN COUNT(''x'') ELSE ''0'' END
				,penCnt		= CASE WHEN cardStatus IN (''pending'',''Complain'') THEN COUNT(''x'') ELSE ''0'' END
			FROM dbo.kycMaster km WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON km.agentId = am.agentId '+@gobalFilter+' 			
		)km' + @groupBy
		PRINT @table
		EXEC(@table)
	END	

	IF @rptType='detail'
	BEGIN	
		SET @table='SELECT 
				 [S.N.]					= row_number() over(order by am.agentName)
				,[IME Remit Card No.]	= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/KYC/View.aspx?customerId='' + cast(km.rowId as varchar) + '''''')">'' + km.remitCardNo + ''</a>''
				,[Customer Name]		= isnull('' ''+km.salutation,'''')+'' ''+ isnull('' ''+km.firstName,'''')+ isnull('' ''+km.middleName,'''')+ isnull('' ''+km.lastName,'''')
				,[Agent Name]			= am.agentName
				,[Created By]			= km.createdBy
				,[Created Date]			= km.createdDate
				,[Status]				= CASE WHEN (km.approvedBy IS NULL) THEN ''Unapproved'' ELSE ''Approved'' END
			FROM kycMaster km WITH(NOLOCK)   
			INNER JOIN agentMaster am WITH(NOLOCK) ON km.agentId = am.agentId  ' +@gobalFilter	
		PRINT @Table
		EXEC(@Table)
		
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	SELECT * FROM @FilterList
	
	SELECT 'KYC Enrollment Report' title	
END



GO
