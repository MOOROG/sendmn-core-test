SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER Procedure [dbo].[proc_fraudAnalysisLogin](
	 @flag			VARCHAR(20)
	,@fromDate 		VARCHAR(10)	= NULL
	,@toDate	  	VARCHAR(10)	= NULL
	,@count	  		INT			= NULL
	,@sCountry		VARCHAR(30)	= NULL
	,@operator		VARCHAR(30)	= NULL
	,@User			VARCHAR(50)
	,@agentId		INT			= NULL	
	,@userName		VARCHAR(50)	= NULL
	,@agentConName	VARCHAR(200) = null

)AS 

SET NOCOUNT ON
DECLARE @title VARCHAR(100)
------------------- START ######## SAME USER DIFF IP SUMMARY
--select @fromDate = '2011-2-22', @toDate ='2014-2-22'

DECLARE @SQL VARCHAR(MAX)
SET @title = 'Fraud Login Analysis Report'

-->>Same User Login by Multiple IP Address
IF @flag = 'MIP'
BEGIN
	SET @title = 'Fraud Login Analysis Report - SAME USER MULTIPLE IP'
	IF ISNULL(@count,0) =  0	
	BEGIN
		SELECT 'Count parameter is missing' [Agent Name], NULL [Branch Name], NULL [Username], NULL [IP Count]
	END
	ELSE 
	BEGIN
	SET @SQL = 'SELECT 
					 bm.agentId
					,agentName			= ISNULL(am.agentName, ''Mongolia Head Office'')
					,branchName			= bm.agentName
					,CreatedBy			= l.CreatedBy
					,IPCount			= IP
					,agentCountryId		= am.agentCountryId
				FROM LoginLogs l WITH(NOLOCK) 
				INNER JOIN agentMaster bm WITH(NOLOCK) ON l.agentId = bm.agentId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON bm.parentId = am.agentId
				WHERE l.createdDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ' 23:59:59''
				AND (bm.agentRole = ''s'' OR bm.agentRole = ''b'' OR bm.agentRole IS NULL)
				GROUP BY bm.agentId, am.agentName, bm.AgentName, l.createdBy, l.IP, am.agentCountryId
			   '
				
		IF ISNULL(@count,0) > 0 
		BEGIN
			SET @SQL = ' 
				 SELECT 
					 [Agent Name]	= agentName
					,[Branch Name]	= branchName
					,[Username]		= CreatedBy 
					,[IP Count]		= ''<a href="reports.aspx?reportName=10122200_login&reportBy=MIPDDN&sCountry='+ISNULL(@sCountry,'')+
					'&fromDate='+CONVERT(varchar,cast(@fromDate as date),101)+'&toDate='+CONVERT(varchar,cast(@toDate as date),101)
					+'&UserName=''+CreatedBy+''&agentId=''+CAST(AgentID AS VARCHAR)+''">''+CAST(count(IPCount) AS VARCHAR)+''</a>''
				FROM ( ' 
					+ @SQL +
					') x 
				WHERE 1=1 '
		END
		
		IF @sCountry IS NOT NULL
		BEGIN
			SET @SQL =  @SQL + ' AND agentCountryId = ''' + @sCountry + ''''
		END
		
		SET @SQL = @SQL + '  
							GROUP BY agentName, branchName, createdBy, agentId
							HAVING COUNT(IPCount) ' + @operator + ' ' + CAST(@count AS VARCHAR) + '
							ORDER BY AgentName 
						'
		
		--PRINT @SQL
		EXEC(@SQL)			
	END
END

-->>Same User Login by Multiple IP Address DRILL DOWN
ELSE IF @flag = 'MIPDDN'
BEGIN
	--select top 100  * From LoginLogs where createdDate between '2014-2-24' and '2014-2-24'+' 23:59:59'
	SET @title = 'Fraud Login Analysis Report - DETAIL'
	
	SELECT DISTINCT
		 [Agent Name]		= agentName
		,[Branch Name]		= BranchName
		,[Username]			= CreatedBy
		,[IP Address]		= IP
		,[DC Serial Number] = dcSerialNumber
		,[DC User Name]		= dcUserName
		,[Login Date]		= LoginDate
		,[Log Type]			= logType 
	FROM (
		SELECT 
			 am.agentId
			,agentName		= 'Mongolia HO'
			,branchName		= 'Head Office'
			,l.CreatedBy
			,IP
			,dcSerialNumber
			,dcUserName
			,loginDate		= l.createdDate 
			,logType
		FROM LoginLogs l WITH(NOLOCK) 
		INNER JOIN agentMaster am WITH (NOLOCK) ON l.agentId = am.agentId
		Where l.createdDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
		AND L.createdBy = @userName
		AND am.agentId = 1001
		
		UNION ALL

		SELECT  
			 am.agentId
			,agentName		= am.agentName
			,branchName		= bm.AgentName
			,l.CreatedBy
			,IP
			,dcSerialNumber
			,dcUserName
			,loginDate		= l.createdDate
			,logType
		FROM LoginLogs l WITH(NOLOCK) 
		INNER JOIN agentMaster bm WITH(NOLOCK) ON l.agentId = bm.agentId	
		INNER JOIN agentMaster am WITH(NOLOCK) ON bm.parentId = am.agentId
		WHERE l.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND L.createdBy = @userName
		AND bm.agentId = @agentId
	) x 
	ORDER BY LoginDate
END

-->>Same User Login by Multiple Certificate
ELSE IF @flag = 'MCert'
BEGIN
	SET @title = 'Fraud Login Analysis Report - SAME USER MULTIPLE CERTIFICATE'
	-- ############## SAME USER DIFF Certificate
	IF ISNULL(@count,0) =  0	
	BEGIN
		SELECT 'Count parameter is missing' [Agent Name], NULL [Branch Name], NULL [Username], NULL [IP Count]
	END
	ELSE 
	BEGIN
	SET @SQL = '
				SELECT 
					 bm.agentId
					,agentName			= ISNULL(am.agentName, ''Mongolia Head Office'')
					,branchName			= bm.agentName
					,createdBy			= l.CreatedBy
					,IPCount			= dcSerialNumber
					,agentCountryId		= am.agentCountryId
				FROM LoginLogs l WITH(NOLOCK) 
				INNER JOIN agentMaster bm WITH(NOLOCK) ON l.agentId = bm.agentId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON bm.parentId = am.agentId
				WHERE l.createdDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ' 23:59:59''
				AND (bm.agentRole = ''s'' OR bm.agentRole = ''b'' OR bm.agentRole IS NULL)
				GROUP BY bm.agentId, am.agentName, bm.AgentName, l.createdBy, l.dcSerialNumber, am.agentCountryId
				'
				
		IF ISNULL(@count,0) > 0 
		BEGIN
			SET @SQL = ' 
				 SELECT 
					 [Agent Name]	= agentName
					,[Branch Name]	= branchName
					,[Username]		= CreatedBy 
					,[Cert. Count]	= ''<a href="reports.aspx?reportName=10122200_login&reportBy=MIPDDN&sCountry='+ISNULL(@sCountry,'')+
					'&fromDate='+CONVERT(varchar,cast(@fromDate as date),101)+'&toDate='+CONVERT(varchar,cast(@toDate as date),101)+'&UserName=''+CreatedBy
					+''&agentId=''+CAST(AgentID AS VARCHAR)+''">''+CAST(count(IPCount) AS VARCHAR)+''</a>''
				FROM ( ' 
					+ @SQL +
					') x 
				WHERE 1=1 '
		END
		
		IF @sCountry IS NOT NULL
		BEGIN
			SET @SQL =  @SQL + ' AND agentCountryId = ''' + @sCountry + ''''
		END
		
		SET @SQL = @SQL + '  
							GROUP BY agentName, branchName, createdBy, agentId
							HAVING COUNT(IPCount) ' + @operator + ' ' + CAST(@count AS VARCHAR) + '
							ORDER BY AgentName 
							'
		--PRINT @SQL
		EXEC(@SQL)			
	END
END

ELSE IF @flag = 'MCertDdl'
BEGIN
SET @title = 'Fraud Login Analysis Report - SAME USER MULTIPLE CERTIFICATE DETAIL'

	-- ############## Multiple Login Attempts
	
	select AgentName ,BranchName,CreatedBy UserName, IPCount attemptCount from (
	SELECT distinct a.AgentID,b.AgentName,a.agentName BranchName,	
	l.CreatedBy,dcSerialNumber as IPCount
	from LoginLogs l with (nolock) 
	inner join agentMaster a with (nolock) on l.agentId=a.agentId
	inner join agentMaster b with (nolock) on a.ParentId=b.agentId
	Where l.createdDate between @fromDate and @toDate+' 23:59:59'
	AND L.createdBy = @userName
	AND A.agentId = @agentId

	UNION ALL

	SELECT distinct a.AgentID,b.AgentName,a.AgentName,l.CreatedBy,dcSerialNumber as IPCount
	from LoginLogs l with (nolock) 
	inner join agentMaster a with (nolock) on l.agentId=a.agentId	
	inner join agentMaster b with (nolock) on a.agentId	= b.parentId
	Where l.createdDate between @fromDate and @toDate+' 23:59:59'
	AND L.createdBy = @userName
	AND A.agentId = @agentId
	) x 
	group by AgentName,CreatedBy, IPCount,BranchName
	order by IPCount
	

End

-->>Failed login Attempt
ELSE IF @flag = 'FLogin'
BEGIN
	SET @title = 'Fraud Login Analysis Report - FAIL LOGIN ATTEMPT'
	IF ISNULL(@count,0) =  0	
	BEGIN
		select 'Count parameter is missing'  AgentName,NULL CreatedBy,NULL IPCount
	END
	ELSE 
	BEGIN
	SET @SQL = '
				SELECT 
					 bm.agentId
					,agentName		= ISNULL(am.agentName, ''Mongolia Head Office'')
					,branchName		= bm.AgentName 
					,l.CreatedBy
					,am.agentCountryId
					,CNT			= COUNT(l.CreatedBy) 
				FROM LoginLogs l WITH(NOLOCK) 
				INNER JOIN agentMaster bm WITH(NOLOCK) ON l.agentId = bm.agentId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON bm.parentId = am.agentId
				WHERE l.createdDate between ''' + @fromDate + ''' AND ''' + @toDate + ' 23:59:59''
				AND logType = ''Login fails'' 
				AND (bm.agentRole = ''s'' OR bm.agentRole = ''b'' OR bm.agentRole IS NULL)
				GROUP BY bm.agentId, am.AgentName, bm.agentName, l.CreatedBy, am.agentCountryId
				
				'
				
		IF ISNULL(@count,0) > 0 
		BEGIN
			SET @SQL = '
				SELECT 
					 [Agent Name]	= agentName
					,[Branch Name]	= branchName
					,[Username]		= CreatedBy 
					,[Fail Count]	= ''<a href="reports.aspx?reportName=10122200_login&reportBy=MIPDDN&sCountry='+ISNULL(@sCountry,'')+
					'&fromDate='+CONVERT(varchar,cast(@fromDate as date),101)+'&toDate='+CONVERT(varchar,cast(@toDate as date),101)+'&UserName=''+CreatedBy+
					''&agentId=''+CAST(AgentID AS VARCHAR)+''">''+CAST(SUM(CNT) AS VARCHAR)+''</a>''
				FROM ( ' 
					+ @SQL +
					') x 
				WHERE 1=1 '
		END
		
		IF @sCountry IS NOT NULL
		BEGIN
			SET @SQL =  @SQL + ' AND agentCountryId = ''' + @sCountry + ''''
		END
		
		SET @SQL = @SQL + ' 
							GROUP BY agentName, branchName, createdBy, agentId
							HAVING SUM(CNT) ' + @operator + ' ' + CAST(@count AS VARCHAR) + '
							ORDER BY agentName
						'
		
		--PRINT @SQL
		EXEC(@SQL)			
	END
END

-->>Login Frequency
ELSE IF @flag = 'LoginFreq'
BEGIN
	SET @title = 'Fraud Login Analysis Report - LOGIN FREQUENCY'
	IF ISNULL(@count,0) =  0	
	BEGIN
		select 'Count parameter is missing'  AgentName,NULL CreatedBy,NULL IPCount
	END
	ELSE 
	BEGIN
	SET @SQL = 'SELECT 
					a.AgentID,ISNULL(b.AgentName, '' HO User'') AgentName,l.CreatedBy,B.agentCountryId
					,SCNT = CASE WHEN logType =''Login'' THEN COUNT(l.CreatedBy) ELSE 0 END
					,FCNT = CASE WHEN logType =''Login fails'' THEN COUNT(l.CreatedBy) ELSE 0 END
				from LoginLogs l with (nolock) 
				inner join agentMaster a with (nolock) on l.agentId = a.agentId
				inner join agentMaster b with (nolock) on a.ParentId = b.agentId
				Where l.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''
				and (a.agentRole =''s'' OR a.agentRole =''b'' OR a.agentRole is null)
				group by a.AgentID,b.AgentName,l.CreatedBy,B.agentCountryId,logType
				
				 '
				
		IF ISNULL(@count,0) > 0 
		BEGIN
			
			SET @SQL = ' select AgentName,CreatedBy UserName
				,[Success Count] = ''<a href="reports.aspx?reportName=10122200_login&reportBy=MIPDDN&sCountry='+ISNULL(@sCountry,'')+'&fromDate='+@fromDate+'&toDate='+@toDate+'&UserName=''+CreatedBy+''&agentId=''+CAST(AgentID AS VARCHAR)+''">''+CAST(SUM(SCNT) AS VARCHAR)+''</a>''
				,[Fail Count] = ''<a href="reports.aspx?reportName=10122200_login&reportBy=MIPDDN&sCountry='+ISNULL(@sCountry,'')+'&fromDate='+@fromDate+'&toDate='+@toDate+'&UserName=''+CreatedBy+''&agentId=''+CAST(AgentID AS VARCHAR)+''">''+CAST(SUM(FCNT) AS VARCHAR

)+''</a>''
			from ( ' 
				+ @SQL
				+') x 
					 WHERE 1=1 '
		END
		IF @sCountry IS NOT NULL
		BEGIN
			SET @SQL =  @SQL + ' AND agentCountryId='''+@sCountry+''''
		END
		
		SET @SQL = @SQL + '  group by AgentName,CreatedBy,AgentID
							HAVING SUM(SCNT) '+@operator+' '+CAST( @count AS VARCHAR)+'
							AND SUM(FCNT) '+@operator+' '+CAST( @count AS VARCHAR)+'
							order by AgentName '
		
		--PRINT @SQL
		EXEC(@SQL)			
	END
end

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT 'From Date' head, @fromDate value
UNION ALL
SELECT 'To Date' head, @toDate value
	   
SELECT @title title
GO