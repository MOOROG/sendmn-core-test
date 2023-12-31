USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userLoginAgingRpt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_userLoginAgingRpt]
	@flag				VARCHAR(20),
	@agentType			VARCHAR(20)	= NULL,
	@days				INT			= NULL,
	@chkInactiveAgent	VARCHAR(1)	= NULL,
	@agingFor			CHAR(1)		= NULL,
	@user				VARCHAR(50)	= NULL,	
	@PageSize			VARCHAR(20) = NULL,
    @PageNumber			VARCHAR(20) = NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;
DECLARE @SQL AS VARCHAR(MAX),@SQL1 AS VARCHAR(MAX)
IF @FLAG='a'
BEGIN
	IF @agingFor = 'a'
	BEGIN			
		IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL
		DROP TABLE #tempTable
		
		IF OBJECT_ID('tempdb..#tempTable1') IS NOT NULL
		DROP TABLE #tempTable1

		CREATE TABLE #tempTable
		(
			agentId VARCHAR(200)	NULL
		)

	
		CREATE TABLE #tempTable2
		(
			agentId VARCHAR(200)	NULL,
			lastLoginDate	VARCHAR(50) NULL
		)
		
		insert into #tempTable2
		select distinct agentId,MAX(createdDate) lastLoginDate from LoginLogs A WITH(NOLOCK) 
		WHERE logType='Login'
		group by agentId
		
		insert into #tempTable
		select distinct agentId
			from LoginLogs with(nolock)
			where createdDate between  dateadd(D,-@days,CONVERT(VARCHAR,GETDATE(),101))  and CONVERT(VARCHAR,GETDATE(),101)+' 23:59:59'  
			and logType='Login' and datediff(day,createdDate,CONVERT(VARCHAR,GETDATE(),101))<>@days
		
		insert into #tempTable
		select distinct sBranch
			from remitTran with(nolock)
			where approvedDate between  dateadd(D,-@days,CONVERT(VARCHAR,GETDATE(),101))  and CONVERT(VARCHAR,GETDATE(),101)+' 23:59:59'  
			and datediff(day,approvedDate,CONVERT(VARCHAR,GETDATE(),101))<>@days
			
		insert into #tempTable
		select distinct pBranch
			from remitTran with(nolock)
			where paidDate between  dateadd(D,-@days,CONVERT(VARCHAR,GETDATE(),101))  and CONVERT(VARCHAR,GETDATE(),101)+' 23:59:59'  
			and datediff(day,paidDate,CONVERT(VARCHAR,GETDATE(),101))<>@days
				
		DELETE FROM #tempTable2
		FROM #tempTable2 A
		INNER JOIN #tempTable B ON A.agentId=B.agentId
		
		SET @SQL='SELECT 				
				 [Agent Name]		= C.agentName 
				,[Address]			= C.agentAddress
				,[Zone]				= C.agentState
				,[District]			= c.agentDistrict
				,[Contact]			= isnull(C.agentPhone1,'''')+'',''+isnull(C.agentPhone2,'''')
				,[Location]			= D.districtName 
				,[Last Login Date]	= A.lastLoginDate
				,[Inactive Days]	= datediff(day,A.lastLoginDate,CONVERT(VARCHAR,GETDATE(),101))
		FROM #tempTable2 A WITH(NOLOCK) 
		INNER JOIN AGENTMASTER C WITH(NOLOCK) ON A.agentId=C.agentId 
		INNER JOIN api_DistrictList D with(nolock) on C.agentLocation=D.districtCode 
		WHERE ISNULL(C.agentBlock,''U'') <>''B'''	
		
		IF @agentType IS NOT NULL
			SET @SQL=@SQL+' AND C.agentGrp='''+@agentType+''''
			
			
		IF @chkInactiveAgent ='Y'	
			SET @SQL=@SQL+' AND ISNULL(C.isActive,''Y'')=''Y''' 
				
		SET @SQL1='
		SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @SQL +') AS tmp;

		SELECT * FROM 
		(
		SELECT ROW_NUMBER() OVER (ORDER BY [Agent Name]) AS [S.N],* 
		FROM 
		(
			'+ @SQL +'
		) AS aa
		) AS tmp WHERE 1 = 1 AND  tmp.[S.N] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''

		EXEC(@SQL1)
	END
	ELSE
	BEGIN
		SET @SQL='SELECT 
			[S.N.] = row_number()over(order by am.agentName),
			[Agent Name]	= CASE WHEN bm.agentType = 2903 AND bm.actAsBranch =''Y'' THEN  bm.agentName ELSE am.agentName END,
			[Branch Name]	= bm.agentName,	
			[Country]		= cm.countryName,
			[User Name]		= au.userName,
			[User Full Name] = au.firstName + ISNULL( '' '' + au.middleName, '''') + ISNULL( '' '' + au.lastName, ''''),
			[Inactive Days] = DATEDIFF(day,lastLoginTs,CONVERT(VARCHAR,GETDATE(),101)) ,
			[Phone No] = au.telephoneNo,	
			[Active Status] = CASE WHEN au.isActive = ''N'' THEN ''Inactive'' ELSE ''Active'' END,
			[Lock Status] = CASE WHEN au.isLocked = ''Y'' THEN ''Locked'' ELSE ''Unlocked'' END,
			[Created By] = au.createdBy,
			[Created Date] = au.createdDate,
			[Last Login Time] = au.lastLoginTs
		FROM dbo.applicationUsers au WITH(NOLOCK) 
		LEFT JOIN dbo.agentMaster bm WITH(NOLOCK) ON au.agentId = bm.agentId
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON bm.parentId = am.agentId
		LEFT JOIN dbo.countryMaster cm WITH(NOLOCK) ON au.countryId = cm.countryId
		WHERE 1=1 '

		IF @days IS NOT NULL
			SET @SQL = @SQL+ ' AND ISNULL(bm.agentBlock,''U'') <>''B'' AND ISNULL(DATEDIFF(day,lastLoginTs,CONVERT(VARCHAR,GETDATE(),101)),'+CAST(@days AS VARCHAR)+'+1) > ='+CAST(@days AS VARCHAR)+''
		IF @agentType IS NOT NULL
			SET @SQL = @SQL+ ' AND bm.agentGrp = '''+@agentType+''''			 
			
		PRINT(@SQL)
		EXEC(@SQL)	
	END
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'Agent Type' head,isnull(@agentType,'All') value
		
	UNION ALL
		
	SELECT 'Inactive Within' head,case when cast(@days as varchar)='3' then 'More than 3 days' when cast(@days as varchar)='7' then 'More than a week' 
	else 'More than a month' end value
		
	UNION ALL
		
	SELECT 'Ignore Blocked Agents' head,case when @chkInactiveAgent='Y' then 'Yes' else 'No' end value
		
	SELECT 'AGENT/USER LOGIN AGING REPORT' title
END
	



GO
