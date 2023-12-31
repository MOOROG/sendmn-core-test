USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_approveCustomerRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_approveCustomerRpt]
 	 @flag              VARCHAR(50)		= NULL
	,@user              VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@agentId			VARCHAR(100)	= NULL
	,@agent				VARCHAR(100)	= NULL
	,@status			VARCHAR(200)	= NULL
	,@membershipId		VARCHAR(10)		= NULL
	,@isDoc				VARCHAR(10)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(10)		= NULL
	,@mode				CHAR(2)			= NULL
	,@zone				VARCHAR(50)		= NULL
	,@agentGrp			VARCHAR(50)		= NULL
	,@district			VARCHAR(100)	= NULL
	
            
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))
DECLARE 
	 @table			VARCHAR(MAX)	= NULL
	,@url			VARCHAR(max)	= ''			
	,@gobalFilter	VARCHAR(MAX)	= ''	
    ,@tempSql		VARCHAR(MAX)    = ''

	IF @fromDate IS NOT NULL AND @toDate IS NOT NULL 
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'From Date',@fromDate 
		INSERT INTO @FilterList 
		SELECT 'To Date',@toDate 

		SET @url=@url+'&fromDate='+@fromDate+'&toDate='+@toDate
		SET @gobalFilter=@gobalFilter+' AND main.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	END	
	IF @agentId IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId 
		SET @url=@url+'&agentId='+@agentId
		SET @gobalFilter=@gobalFilter+' AND am.agentId ='''+@agentId+''''
	END	
	IF @agentGrp IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Agent Group',detailTitle FROM dbo.staticDataValue WITH(NOLOCK) WHERE valueId=@agentGrp 
		SET @url=@url+'&agentGrp='+@agentGrp
		SET @gobalFilter=@gobalFilter+' AND am.agentGrp ='''+@agentGrp+''''
	END	
	IF @memberShipId IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Membership Id',@memberShipId
		SET @url=@url+'&memberShipId='+@memberShipId
		SET @gobalFilter=@gobalFilter+' AND cast(main.memberShipId as varchar) ='''+@memberShipId+''''
	END
	IF @status IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Status',@status
		SET @url=@url+'&status='+@status
		SET @gobalFilter=@gobalFilter+' AND ISNULL(main.customerStatus, ''Pending'') ='''+@status+''''
	END	
	IF @zone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Zone',@zone
		SET @url=@url+'&sZone='+@zone
		SET @gobalFilter=@gobalFilter+' AND main.pZone ='''+@zone+''''
	END	
	IF @district IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'District',@district
		SET @url=@url+'&district='+@district
		SET @gobalFilter=@gobalFilter+' AND main.pDistrict ='''+@district+''''
	END	
	IF @isDoc IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Document Uploaded',@isDoc
		SET @url=@url+'&isDoc='+@isDoc

		IF @isDoc='Yes'
		BEGIN
			SET @gobalFilter=@gobalFilter+' AND cd.customerId is not null and cd.cdId is not null'
		END

		IF @isDoc='NO'
		BEGIN
			SET @gobalFilter=@gobalFilter+' AND cd.customerId is null and cd.cdId is null'
		END

	END	
IF @flag = 's_summary'
	BEGIN
	    SET @gobalFilter=@gobalFilter+'  group by am.agentState,main.pZone,cd.customerId'
		IF @zone IS NOT NULL			
		SET @url='''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822000_sc&flag=dis'+@url+'")>''+zone+''</a>'''
		ELSE 
		SET @url='''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822000_sc&flag=dis&sZone=''+zone+'''+@url+'")>''+zone+''</a>'''
		SET @table='
		SELECT 
			zone=main.pZone
			,[Is Uploaded] = case when cd.customerId is null then ''No'' else ''Yes'' end	
			,[Enrolled]    = count(''x'') 
			,[Uploaded]=CASE WHEN cd.customerId is not null	THEN COUNT(''x'') ELSE 0 END
			,[NotUploaded]=CASE WHEN cd.customerId is null	THEN COUNT(''x'') ELSE 0 END						
			FROM customerMaster main WITH(NOLOCK)
				--LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
			LEFT JOIN  (
				SELECT customerId, MAX(cdId) cdId FROM customerDocument WITH(NOLOCK) GROUP BY customerId
			) cd on main.customerId = cd.customerId

			LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
			LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = ''Y''
			WHERE ISNULL(main.isDeleted,''N'') = ''N'' AND rejectedDate IS NULL'  + @gobalFilter	

			SET @tempSql='SELECT '+@url+' As Zone,Enrolled=SUM([Enrolled]),SUM([Uploaded])  as ''Doc Uploaded'',SUM([NotUploaded]) as ''Doc Not Uploaded''  FROM ('+@table+') x 
			GROUP BY zone ORDER BY zone'

		PRINT @tempSql
		EXEC(@tempSql)
    END
IF @flag = 'dis'
	BEGIN
	  SET @gobalFilter=@gobalFilter +' group by main.pDistrict ,cd.customerId'
	  IF @district IS NOT NULL
	  SET @url='''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822000_sc&flag=agent'+@url+'")>''+District+''</a>'''
	  ELSE
	  SET @url='''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822000_sc&flag=agent&district=''+District+'''+@url+'")>''+District+''</a>'''
	  SET @table=' 	
		SELECT  
			District				=main.pDistrict	
		   ,[Is Uploaded]			= case when cd.customerId is null then ''No'' else ''Yes'' end	
		   ,[Uploaded]				=CASE WHEN cd.customerId is not null	THEN COUNT(''x'') ELSE 0 END
		   ,[NotUploaded]			=CASE WHEN cd.customerId is null	THEN COUNT(''x'') ELSE 0 END	
		   ,[Enrolled]				= count(''x'')
		   	FROM customerMaster main WITH(NOLOCK)
			LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId

			LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
			LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = ''Y''
			WHERE 1=1 AND ISNULL(main.isDeleted,''N'') = ''N'' AND rejectedDate IS NULL'  + @gobalFilter 

		SET @tempSql='SELECT '+@url+' as District,Enrolled=SUM([Enrolled]),SUM([Uploaded])  as ''Doc Uploaded'',SUM([NotUploaded]) as ''Doc Not Uploaded''
		FROM ('+@table+') x GROUP BY District
		ORDER BY District'	

		PRINT @tempSql
		EXEC(@tempSql)
	END
IF @flag = 'agent'
	BEGIN
	  SET @gobalFilter=@gobalFilter +' group by am.agentId,am.agentName ,cd.customerId'	
	  IF @agentId IS NOT NULL
	  SET @url='''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822000_sc&flag=custDetails'+@url+'")>''+AgentName+''</a>'''
	  ELSE
	  SET @url='''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822000_sc&flag=custDetails&sAgent=''+cast(x.AgentId as varchar)+'''+@url+'")>''+AgentName+''</a>'''
	  SET @table='
		SELECT 
				AgentName = am.agentName
				,AgentId=am.agentId
				,[Enroled] = COUNT(''x'')	
				,[Uploaded Yes] = case when cd.customerId is not null then count(''x'') else 0 end	
				,[Is Uploaded NO] = case when cd.customerId is null then count(''x'') else 0 end
			FROM customerMaster main WITH(NOLOCK)
			--LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
			LEFT JOIN  (
				SELECT customerId, MAX(cdId) cdId FROM customerDocument WITH(NOLOCK) GROUP BY customerId
			) cd on main.customerId = cd.customerId
			LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
			LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = ''Y''
			 WHERE 1=1 AND ISNULL(main.isDeleted,''N'') = ''N'' AND rejectedDate IS NULL'  + @gobalFilter 

		SET @tempSql='SELECT '+@url+' as [Agent Name],SUM(CAST([Enroled] as INT)) [Enrolled],SUM(CAST([Uploaded YEs] as INT)) [Doc Uploaded],SUM(CAST([Is Uploaded NO] AS INT)) [Doc Not Uploaded] FROM('+@table+') x GROUP BY AgentId,AgentName
		ORDER BY  AgentName'
	    PRINT @tempSql
		EXEC(@tempSql)

	END
IF @flag = 'custDetails'
	BEGIN
	  SET @gobalFilter=@gobalFilter 
	  SET @url = '<a href="javascript:void(0)" onclick=OpenInNewWindow("../../Remit/Administration/CustomerSetup/Manage.aspx?&customerId=''+cast(main.customerId as varchar)+''&mode=1''''")>View Details</a>'
	  SET @table='
			SELECT 
				 customerId = main.customerId
				,[Mem. Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '''') + ISNULL( main.middleName, '''')+ ISNULL(main.lastName, '''')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created Date] = main.createdDate
				,[Is Doc. Uploaded] = case when cd.customerId is null then ''No'' else ''Yes'' end
				,[Status] = customerStatus
				,[Subject] = ci.subject
				,[HO-Complain] = ci.description
				,[ ]='''+@url+'''
			FROM customerMaster main WITH(NOLOCK)
			LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
			LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
			LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = ''Y''
			WHERE 1=1 AND ISNULL(main.isDeleted,''N'') = ''N'' AND rejectedDate IS NULL'  + @gobalFilter 

			PRINT @table
		    EXEC(@table)
	END
	IF @flag = 'detail'
	BEGIN
	  SET @gobalFilter=@gobalFilter 
	  SET @url = '<a href="javascript:void(0)" onclick=OpenInNewWindow("../../Remit/Administration/CustomerSetup/Manage.aspx?&customerId=''+cast(main.customerId as varchar)+''&mode=1''''")>View Details</a>'
	   SET @table=' 
		SELECT  --Distinct	 

				-- customerId = main.customerId,
				[Mem. Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '''') + ISNULL( main.middleName, '''')+ ISNULL(main.lastName, '''')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created Date] = main.createdDate
				,[Is Doc. Uploaded] = case when cd.customerId is null then ''No'' else ''Yes'' end	
				,[Status] = customerStatus
				,[Subject] = ci.subject
				,[HO-Complain] = ci.description
				,[ ]='''+@url+'''
			  FROM customerMaster main WITH(NOLOCK)
				--LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
				LEFT JOIN  (
					SELECT customerId, MAX(cdId) cdId FROM customerDocument WITH(NOLOCK) GROUP BY customerId
				) cd on main.customerId = cd.customerId
				LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
				LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = ''Y''
			WHERE 1=1 AND ISNULL(main.isDeleted,''N'') = ''N'' AND rejectedDate IS NULL'  + @gobalFilter 

			PRINT @table
		  EXEC(@table)
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	

	SELECT * FROM @FilterList	

	SELECT 'CUSTOMER SEARCH REPORT' title		

END





GO
