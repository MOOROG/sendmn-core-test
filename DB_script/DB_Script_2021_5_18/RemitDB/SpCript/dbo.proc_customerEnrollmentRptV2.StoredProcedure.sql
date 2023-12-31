USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerEnrollmentRptV2]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_customerEnrollmentRptV2](
	 @flag				VARCHAR(50)=NULL
	,@user				VARCHAR(30)=NULL		
	,@fromDate			VARCHAR(30)=NULL
	,@toDate			VARCHAR(30)=NULL
	,@sZone				VARCHAR(30)=NULL
	,@sAgent			VARCHAR(10)=NULL
	,@memberShipId		VARCHAR(50)=NULL
	,@ageGrp			VARCHAR(50)= NULL
	,@agentGrp			VARCHAR(50)= NULL
	
)AS
BEGIN
DECLARE @FilterList TABLE(head VARCHAR(200), value VARCHAR(100))
IF OBJECT_ID('tempdb..#TEMP_CUSTOMER_TXN') IS NOT NULL 
	DROP TABLE #TEMP_CUSTOMER_TXN
CREATE TABLE #TEMP_CUSTOMER_TXN(membershipId VARCHAR(16), tranType CHAR(1))
DECLARE 
		 @table			VARCHAR(MAX)	= NULL	
		,@gobalFilter	VARCHAR(MAX)	=' WHERE ISNULL(cm.isDeleted,''N'') <> ''Y'' AND cm.rejectedDate IS NULL and cm.isKyc is null ' 
		,@sql			VARCHAR(MAX)	= NULL
		,@url			VARCHAR(MAX)	= NULL

	IF @fromDate IS NOT NULL AND @toDate IS NOT NULL 
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'From Date',@fromDate 
		INSERT INTO @FilterList 
		SELECT 'To Date',@toDate 
		SET @gobalFilter=@gobalFilter+' AND cm.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	END
	IF @sZone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Zone',@sZone 
		SET @gobalFilter=@gobalFilter+' AND am.agentState ='''+@sZone+''''
	END
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent 
		SET @gobalFilter=@gobalFilter+' AND am.agentId ='''+@sAgent+''''
	END	
	IF @agentGrp IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Agent Group',detailTitle FROM dbo.staticDataValue WITH(NOLOCK) WHERE valueId=@agentGrp 
		SET @gobalFilter=@gobalFilter+' AND am.agentGrp ='''+@agentGrp+''''
	END	
	IF @memberShipId IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Membership Id',@memberShipId
		SET @gobalFilter=@gobalFilter+' AND cm.memberShipId ='''+@memberShipId+''''
	END
	INSERT INTO @FilterList 
	SELECT 'Report By',case when @flag ='sz' then 'ZONE WISE' 
							when @flag ='sa' then 'AGENT WISE' 
							when @flag ='c' then 'CARD WISE' 
							when @flag ='b' then 'SLAB WISE' 
							when @flag ='s' then 'DETAIL'
							when @flag ='age' then 'AGE WISE' end


	SET @sql = 'insert into #TEMP_CUSTOMER_TXN(membershipId,tranType)
				select 
					distinct cm.membershipId ,tranType = ''P'' 
				from customerMaster cm with(nolock) 
				INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId 
				inner join vwTranReceiversArchive rec with(nolock) on cm.membershipId = rec.membershipId and cm.customerId = rec.customerId
				'+@gobalFilter +' and cm.approvedDate is not null ;
				insert into #TEMP_CUSTOMER_TXN(membershipId,tranType)
				select 
					distinct cm.membershipId ,tranType = ''S''
				from customerMaster cm with(nolock) 
				INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId 
				inner join vwTranSendersArchive rec with(nolock) on cm.membershipId = rec.membershipId and cm.customerId = rec.customerId
				'+@gobalFilter +' and cm.approvedDate is not null 
				'


	IF @flag='sz'
	BEGIN
		SET @url ='<a href="#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=inactive&fromDate='+@fromDate+'&toDate='+@toDate+'&user='+@user
		SET @gobalFilter=@gobalFilter+' GROUP BY am.agentState,cm.approvedDate,r.membershipId,s.membershipId,t.membershipId'	
		exec(@sql)
		SET @table='
		SELECT 
			[S.N.]				= ROW_NUMBER() OVER(ORDER BY zone),
			[ZONE]				= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=s&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+zone+''&membershipId='+ISNULL(@membershipId,'')+'&sAgent='+ISNULL(@sAgent,'')+'")>''+zone+''</a>'',
			[Enrolled]			= sum(tot),
			[Approved]			= sum(appCusCount),
			[Pending]			= sum(penCusCount),
			[Send Active]		= sum(sendActive),
			[Paid Active]		= sum(paidActive),			
			[Total Active]		= sum(totalActive),
			[Total Inactive]	= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=inactive&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+zone+''&membershipId='+ISNULL(@membershipId,'')+'&sAgent='+ISNULL(@sAgent,'')+'")>''+cast(sum(appCusCount) - sum(totalActive) as varchar)+''</a>''
		FROM
		(
			SELECT 	
				 zone			= am.agentState
				,tot			= count(''x'') 
				,appCusCount	= case when cm.approvedDate is not null then count(''x'') else 0 end
				,penCusCount	= case when cm.approvedDate is null then count(''x'') else 0 end
				,paidActive		= case when r.membershipId is not null then count(''x'') else 0 end	
				,sendActive		= case when s.membershipId is not null then count(''x'') else 0 end
				,totalActive	= case when t.membershipId is not null then count(''x'') else 0 end
			FROM customerMaster cm with(nolock)
			INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId 
			LEFT JOIN 
			(
				select membershipId FROM #TEMP_CUSTOMER_TXN WHERE tranType =''P''
			)r on r.membershipId = cm.membershipId
			left join 
			(
				select membershipId FROM #TEMP_CUSTOMER_TXN WHERE tranType =''S''
			)s on s.membershipId = cm.membershipId 
			LEFT JOIN 
			(
				select distinct membershipId FROM #TEMP_CUSTOMER_TXN 
			)t on cm.membershipId = t.membershipId
			'+@gobalFilter+'
		)X GROUP BY zone'
		print @table
		EXEC (@table)
		
			
	END
	IF @flag='sa'
	BEGIN
		SET @gobalFilter=@gobalFilter+' GROUP BY am.agentState,am.agentId,am.agentName,cm.approvedDate,r.membershipId,s.membershipId,t.membershipId '
		exec(@sql)
		SET @table='
		SELECT 
			 [S.N.]				= row_number()over(order by zone)
			,[Zone]				= zone  
			,[Agent]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=s&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId='+ISNULL(@membershipId,'')+'&sAgent=''+cast(agentId as varchar(50))+''")>''+agent+''</a>''
			,[No. of Customer]	= sum(tot)
			,[No. of Approved]  = sum(appCusCount)
			,[No. of Pending]   = sum(PenCusCount)
			,[Send Active]		= sum(sendActive)
			,[Paid Active]		= sum(paidActive)			
			,[Total Active]		= sum(totalActive)
			,[Total Inactive]	= sum(appCusCount) - sum(totalActive)
		FROM 
		(
			SELECT
				agentId			= am.agentId
			   ,zone			= am.agentState 
			   ,agent			= am.agentName
			   ,tot				= count(''x'')
			   ,appCusCount		= case when cm.approvedDate is not null then count(''x'') else 0 end
			   ,PenCusCount		= case when cm.approvedDate is null then count(''x'') else 0 end
			   ,paidActive		= case when r.membershipId is not null then count(''x'') else 0 end	
			   ,sendActive		= case when s.membershipId is not null then count(''x'') else 0 end
			   ,totalActive		= case when t.membershipId is not null then count(''x'') else 0 end
			FROM customerMaster cm with(nolock)
			INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId 
			LEFT JOIN 
			(
				select membershipId FROM #TEMP_CUSTOMER_TXN WHERE tranType =''P''
			)r on r.membershipId = cm.membershipId
			left join 
			(
				select membershipId FROM #TEMP_CUSTOMER_TXN WHERE tranType =''S''
			)s on s.membershipId = cm.membershipId 
			LEFT JOIN 
			(
				select distinct membershipId FROM #TEMP_CUSTOMER_TXN 
			)t on cm.membershipId = t.membershipId
			'+@gobalFilter+' 
		)X group by zone,agent,agentId ORDER BY agent ASC'

		print @table
		EXEC (@table)
	END
	IF @flag='c'
	BEGIN
		SET @table='
		SELECT
			[S.N.]		= row_number()over(order by am.agentName )	
		   ,[Agent]		= am.agentName
		   ,[Membership ID]	= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=s&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId=''+cm.membershipId+''&sAgent='+ISNULL(@sAgent,'')+'")>''+cm.membershipId+''</a>''
		   ,[Send TXN]	= ISNULL(sendTxn,0)
		   ,[Paid TXN]	= ISNULL(payTxn,0)
		   ,[Total TXN] = ISNULL(sendTxn,0) + ISNULL(payTxn,0)
		FROM customerMaster cm with(nolock)
		INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId
		LEFT JOIN 
		(
			SELECT 
				membershipId	= cm.membershipId,
				sendTxn			= count(''x'')
			FROM customerMaster cm with(nolock)
			INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId
			INNER JOIN tranSenders sen with(nolock) on cm.customerId = sen.customerId and cm.membershipId = sen.membershipId
			'+@gobalFilter+' and cm.approvedDate is not null  GROUP BY cm.membershipId

		)X ON X.membershipId = cm.membershipId
		LEFT JOIN 
		(
			SELECT 
				membershipId	= cm.membershipId,
				payTxn			= count(''x'')
			FROM customerMaster cm with(nolock)
			INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId
			INNER JOIN tranReceivers rec with(nolock) on cm.customerId = rec.customerId and cm.membershipId = rec.membershipId
			'+@gobalFilter+' and cm.approvedDate is not null  GROUP BY cm.membershipId
		)Y ON Y.membershipId = cm.membershipId		
		'+@gobalFilter

		print @table
		EXEC (@table)
	END
	IF @flag='s'
	BEGIN
	SET @gobalFilter=@gobalFilter+' ORDER BY am.agentName ASC'
		SET @table='SELECT
		   [S.N.]					=row_number()over(order by am.agentName)
		  ,[Membership Id]			=cm.membershipId
		  ,[Customer Name]			=ISNULL('' '' + cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName, '''') 
		  ,[Country]				=cm.tCountry
		  ,[Zone]					=cm.tZone   
		  ,[District]				=cm.tDistrict
		  ,[VDC\MNC]				=cm.tMunicipality+'' ''+ISNULL(tWardNo,'''') 
		  ,[Place Of Issue]			=cm.placeOfIssue		  
		  ,[Mobile]					=cm.mobile 		  
		  ,[Occupation]				=ISNULL(sdv.detailTitle, cm.occupation)
		  ,[Date Of Birth]			=cm.dobEng    
		  ,[Created By]				=cm.createdBy
		  ,[Created Date]			=cm.createdDate
		  ,[Approved By]			=cm.approvedBy
		  ,[Approved Date]			=cm.approvedDate
		  ,[Email]					=cm.email 	
		  ,[Issuing Agent]			=am.agentName		   
		FROM customerMaster cm with(nolock)
		LEFT JOIN staticDataValue sdv (NOLOCK) ON cm.occupation = CAST(sdv.valueId AS VARCHAR)
		INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId'+@gobalFilter
	
		
		print @table
		EXEC (@table)
	END	
	IF @flag='detail'
	BEGIN	
		SET @table='SELECT 
				 [S.N.]					= row_number() over(order by rt.sAgentName)
				,[Agent Name]			= rt.sAgentName
				,[Control No]			= ''<span class = "link" onclick ="ViewTranDetailByControlNo('''''' + dbo.fnadecryptstring(rt.controlNo) + '''''');">'' + dbo.fnadecryptstring(rt.controlNo) + ''</span>'' 
				,[Total Amount]			= dbo.ShowDecimal(rt.pAmt)
				,[Total bonus Point]	= rt.bonusPoint 
				,[Membership Id]		= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx?membershipId='' + cm.membershipId + '''''')">'' + cm.membershipId + ''</a>''
				,[Sender Name]			= rt.senderName
				,[Receiver Name]		= rt.receiverName
				,[Pay Status]			= rt.payStatus
				,[TXN Date]				= rt.createdDateLocal
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 			
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId 
			INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId			
			'+@gobalFilter
		PRINT @Table
		EXEC(@Table)
		
	END
	IF @flag = 'inactive'
	BEGIN
		IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL 
		DROP TABLE #TEMP
		IF OBJECT_ID('tempdb..#temp_send') IS NOT NULL 
		DROP TABLE #temp_send
		IF OBJECT_ID('tempdb..#temp_paid') IS NOT NULL 
		DROP TABLE #temp_paid

		CREATE TABLE #TEMP(membershipId VARCHAR(16),agentName varchar(500))
		CREATE TABLE #temp_send(membershipId VARCHAR(16))
		CREATE TABLE #temp_paid(membershipId VARCHAR(16))

		SET @table = ' 
		insert into #TEMP(membershipId,agentName)
		select membershipId,am.agentName
		from customerMaster cm with(nolock)
		inner join agentMaster am with(nolock) on cm.agentId = am.agentId
		'+@gobalFilter+'
		and cm.approvedDate is not null

		insert into #temp_send
		select distinct cm.membershipId from customerMaster cm with(nolock) 
			inner join agentMaster am with(nolock) on cm.agentId = am.agentId
			inner join tranSenders sen with(nolock) on cm.membershipId = sen.membershipId and sen.customerId = cm.customerId
			'+@gobalFilter+'
			and cm.approvedDate is not null

		insert into #temp_paid
		select distinct cm.membershipId from customerMaster cm with(nolock) 
			inner join agentMaster am with(nolock) on cm.agentId = am.agentId
			inner join tranReceivers rec with(nolock) on cm.membershipId = rec.membershipId and rec.customerId = cm.customerId
			'+@gobalFilter+'
			and cm.approvedDate is not null

		DELETE FROM #TEMP 						
		FROM #TEMP t INNER JOIN 
		(
			select membershipId from #temp_send 
		)sen ON t.membershipId = sen.membershipId

		DELETE FROM #TEMP 						
		FROM #TEMP t INNER JOIN 
		(
			select membershipId from #temp_paid 
		)sen ON t.membershipId = sen.membershipId

		select 
		   [S.N.]					=row_number()over(order by t.agentName)
		  ,[Membership Id]			= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx?membershipId='' + cm.membershipId + '''''')">'' + cm.membershipId + ''</a>''
		  ,[Customer Name]			=ISNULL('' '' + cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName, '''') 
		  ,[Country]				=cm.tCountry
		  ,[Zone]					=cm.tZone   
		  ,[District]				=cm.tDistrict
		  ,[VDC\MNC]				=cm.tMunicipality+'' ''+ISNULL(tWardNo,'''') 
		  ,[Place Of Issue]			=cm.placeOfIssue		  
		  ,[Mobile]					=cm.mobile 		  
		  
		  ,[Occupation]				=ISNULL(sdv.detailTitle, cm.occupation)
		  ,[Date Of Birth]			=cm.dobEng    
		  ,[Created By]				=cm.createdBy
		  ,[Created Date]			=cm.createdDate
		  ,[Approved By]			=cm.approvedBy
		  ,[Approved Date]			=cm.approvedDate
		  ,[Email]					=cm.email 	
		  ,[Issuing Agent]			=t.agentName	
		from customerMaster cm with(nolock) 
		LEFT JOIN staticDataValue sdv (NOLOCK) ON cm.occupation = CAST(sdv.valueId AS VARCHAR)
		inner join #TEMP t on t.membershipId = cm.membershipId'
		PRINT(@table);
		EXEC(@table);
	END
	IF @flag='age'
	BEGIN
		CREATE TABLE #temp_table(ageGrp VARCHAR(50), membershipId VARCHAR(16),agentId int,
		approvedDate datetime,customerId INT,createdDate datetime,isDeleted char(1),rejectedDate datetime,isKyc char(1))
		INSERT into #temp_table(ageGrp,membershipId,agentId,approvedDate,customerId,createdDate,isDeleted,rejectedDate,isKyc)
		SELECT 'a',membershipId,agentId,approvedDate,customerId,createdDate,isDeleted,rejectedDate,cm.isKyc
		FROM dbo.customerMaster cm WITH(NOLOCK) WHERE DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 25
		AND cm.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND cm.isDeleted IS NULL AND cm.rejectedDate IS NULL and cm.isKyc is null
		UNION ALL
		SELECT 'b',membershipId,agentId,approvedDate,customerId,createdDate,isDeleted,rejectedDate,cm.isKyc
		FROM dbo.customerMaster cm WITH(NOLOCK) WHERE DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 25 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 30 
		AND cm.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND cm.isDeleted IS NULL AND cm.rejectedDate IS NULL and cm.isKyc is null
		UNION ALL
		SELECT 'c',membershipId,agentId,approvedDate,customerId,createdDate,isDeleted,rejectedDate,cm.isKyc
		FROM dbo.customerMaster cm WITH(NOLOCK) WHERE DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 30 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 35 
		AND cm.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND cm.isDeleted IS NULL AND cm.rejectedDate IS NULL and cm.isKyc is null
		UNION ALL
		SELECT 'd',membershipId,agentId,approvedDate,customerId,createdDate,isDeleted,rejectedDate,cm.isKyc
		FROM dbo.customerMaster cm WITH(NOLOCK) WHERE DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 35 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 40 and
		cm.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND cm.isDeleted IS NULL AND cm.rejectedDate IS NULL and cm.isKyc is null
		UNION all
		SELECT 'e',membershipId,agentId,approvedDate,customerId,createdDate,isDeleted,rejectedDate,cm.isKyc
		FROM dbo.customerMaster cm WITH(NOLOCK) WHERE DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 40 AND 
		cm.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND cm.isDeleted IS NULL AND cm.rejectedDate IS NULL and cm.isKyc is null

		SET @sql = 'insert into #TEMP_CUSTOMER_TXN(membershipId,tranType)
			select 
				distinct cm.membershipId ,tranType = ''p'' 
			from #temp_table cm with(nolock) 
			INNER JOIN agentMaster am with(nolock) ON cm.agentId = am.agentId 
			inner join tranReceivers rec with(nolock) on cm.membershipId = rec.membershipId and cm.customerId = rec.customerId
			'+@gobalFilter +' and cm.approvedDate is not null ;
			insert into #TEMP_CUSTOMER_TXN(membershipId,tranType)
			select 
				distinct cm.membershipId ,tranType = ''s''
			from #temp_table cm with(nolock) 
			INNER JOIN agentMaster am with(nolock) ON cm.agentId = am.agentId 
			inner join tranSenders rec with(nolock) on cm.membershipId = rec.membershipId and cm.customerId = rec.customerId
			'+@gobalFilter +' and cm.approvedDate is not null'

		SET @gobalFilter=@gobalFilter+' GROUP BY cm.ageGrp,cm.approvedDate,r.membershipId,s.membershipId,t.membershipId'	
		PRINT @sql
		exec(@sql)
		SET @table='
		SELECT 
			[S.N.]				= ROW_NUMBER() OVER(ORDER BY ageGrp),
			[Age Group]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=s-age&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId='+ISNULL(@membershipId,'')+'&sAgent='+ISNULL(@sAgent,'')+'&ageGrp=''+ageGrp+''")>''
									+ CASE WHEN ageGrp = ''a'' THEN ''Below 18 to 25'' 
									WHEN ageGrp = ''b'' THEN ''25 to 30'' 
									WHEN ageGrp = ''c'' THEN ''30 to 35''
									WHEN ageGrp = ''d'' THEN ''35 to 40''
									WHEN ageGrp = ''e'' THEN ''40 and above'' END +''</a>'',
			[Enrolled]			= sum(tot),
			[Approved]			= sum(appCusCount),
			[Pending]			= sum(penCusCount),
			[Send Active]		= sum(sendActive),
			[Paid Active]		= sum(paidActive),			
			[Total Active]		= sum(totalActive),
			[Total Inactive]	= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerptenrollment&searchBy=inactive-age&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId='+ISNULL(@membershipId,'')+'&sAgent='+ISNULL(@sAgent,'')+'&ageGrp=''+ageGrp+''")>''+cast(sum(appCusCount) - sum(totalActive) as varchar)+''</a>''
		FROM
		(
			SELECT 	
				 ageGrp			= cm.ageGrp
				,tot			= count(''x'') 
				,appCusCount	= case when cm.approvedDate is not null then count(''x'') else 0 end
				,penCusCount	= case when cm.approvedDate is null then count(''x'') else 0 end
				,paidActive		= case when r.membershipId is not null then count(''x'') else 0 end	
				,sendActive		= case when s.membershipId is not null then count(''x'') else 0 end
				,totalActive	= case when t.membershipId is not null then count(''x'') else 0 end
			FROM #temp_table cm with(nolock)
			INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId 
			LEFT JOIN 
			(
				select membershipId FROM #TEMP_CUSTOMER_TXN WHERE tranType =''P''
			)r on r.membershipId = cm.membershipId
			left join 
			(
				select membershipId FROM #TEMP_CUSTOMER_TXN WHERE tranType =''S''
			)s on s.membershipId = cm.membershipId 
			LEFT JOIN 
			(
				select distinct membershipId FROM #TEMP_CUSTOMER_TXN 
			)t on cm.membershipId = t.membershipId
			'+@gobalFilter+'
		)X GROUP BY ageGrp'
		print @table
		EXEC (@table)	
			
	END
	IF @flag='s-age'
	BEGIN
		
		if @ageGrp = 'a' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 25'
		if @ageGrp = 'b' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 25 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 30 '
		if @ageGrp = 'c' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 30 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 35'
		if @ageGrp = 'd' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 35 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 40'
		if @ageGrp = 'e' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 40'

		SET @gobalFilter=@gobalFilter+' ORDER BY am.agentName ASC'
		SET @table='SELECT
		   [S.N.]					=row_number()over(order by am.agentName)
		  ,[Membership Id]			=cm.membershipId
		  ,[Customer Name]			=ISNULL('' '' + cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName, '''') 
		  ,[Country]				=cm.tCountry
		  ,[Zone]					=cm.tZone   
		  ,[District]				=cm.tDistrict
		  ,[VDC\MNC]				=cm.tMunicipality+'' ''+ISNULL(tWardNo,'''') 
		  ,[Place Of Issue]			=cm.placeOfIssue		  
		  ,[Mobile]					=cm.mobile 		  
		  ,[Occupation]				=ISNULL(sdv.detailTitle, cm.occupation)
		  ,[Age]					=DATEDIFF(YEAR,cm.dobEng,GETDATE())
		  ,[Date Of Birth]			=cm.dobEng   
		  ,[Date Of Birth(B.S.)]	=cm.dobNep    
		  ,[Created By]				=cm.createdBy
		  ,[Created Date]			=cm.createdDate
		  ,[Approved By]			=cm.approvedBy
		  ,[Approved Date]			=cm.approvedDate
		  ,[Email]					=cm.email 	
		  ,[Issuing Agent]			=am.agentName		  	   
		FROM customerMaster cm with(nolock)
		LEFT JOIN staticDataValue sdv (NOLOCK) ON cm.occupation = CAST(sdv.valueId AS VARCHAR)
		INNER JOIN agentMaster am with(nolock) ON cm.agentId=am.agentId'+@gobalFilter
	
		
		print @table
		EXEC (@table)
	END	
	IF @flag = 'inactive-age'
	BEGIN
		IF OBJECT_ID('tempdb..#TEMP_1') IS NOT NULL 
		DROP TABLE #TEMP_1
		IF OBJECT_ID('tempdb..#temp_send_1') IS NOT NULL 
		DROP TABLE #temp_send_1
		IF OBJECT_ID('tempdb..#temp_paid_1') IS NOT NULL 
		DROP TABLE #temp_paid_1

		CREATE TABLE #TEMP_1(membershipId VARCHAR(16),agentName varchar(500))
		CREATE TABLE #temp_send_1(membershipId VARCHAR(16))
		CREATE TABLE #temp_paid_1(membershipId VARCHAR(16))

		if @ageGrp = 'a' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 25'
		if @ageGrp = 'b' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 25 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 30 '
		if @ageGrp = 'c' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 30 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 35 '
		if @ageGrp = 'd' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 35 and DATEDIFF(YEAR,cm.dobEng,GETDATE()) < 40'
		if @ageGrp = 'e' 		
			set @gobalFilter = @gobalFilter+' AND DATEDIFF(YEAR,cm.dobEng,GETDATE()) >= 40'

		SET @table = ' 
		insert into #TEMP_1(membershipId,agentName)
		select membershipId,am.agentName
		from customerMaster cm with(nolock)
		inner join agentMaster am with(nolock) on cm.agentId = am.agentId
		'+@gobalFilter+'
		and cm.approvedDate is not null

		insert into #temp_send_1
		select distinct cm.membershipId from customerMaster cm with(nolock) 
			inner join agentMaster am with(nolock) on cm.agentId = am.agentId
			inner join tranSenders sen with(nolock) on cm.membershipId = sen.membershipId and sen.customerId = cm.customerId
			'+@gobalFilter+'
			and cm.approvedDate is not null

		insert into #temp_paid_1
		select distinct cm.membershipId from customerMaster cm with(nolock) 
			inner join agentMaster am with(nolock) on cm.agentId = am.agentId
			inner join tranReceivers rec with(nolock) on cm.membershipId = rec.membershipId and rec.customerId = cm.customerId
			'+@gobalFilter+'
			and cm.approvedDate is not null

		DELETE FROM #TEMP_1 						
		FROM #TEMP_1 t INNER JOIN 
		(
			select membershipId from #temp_send_1
		)sen ON t.membershipId = sen.membershipId

		DELETE FROM #TEMP_1 						
		FROM #TEMP_1 t INNER JOIN 
		(
			select membershipId from #temp_paid_1
		)sen ON t.membershipId = sen.membershipId

		select 
		   [S.N.]					=row_number()over(order by t.agentName)
		  ,[Membership Id]			= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx?membershipId='' + cm.membershipId + '''''')">'' + cm.membershipId + ''</a>''
		  ,[Customer Name]			=ISNULL('' '' + cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName, '''') 
		  ,[Country]				=cm.tCountry
		  ,[Zone]					=cm.tZone   
		  ,[District]				=cm.tDistrict
		  ,[VDC\MNC]				=cm.tMunicipality+'' ''+ISNULL(tWardNo,'''') 
		  ,[Place Of Issue]			=cm.placeOfIssue		  
		  ,[Mobile]					=cm.mobile 		  
		  ,[Occupation]				=ISNULL(sdv.detailTitle, cm.occupation)
		  ,[Date Of Birth]			=cm.dobEng    
		  ,[Created By]				=cm.createdBy
		  ,[Created Date]			=cm.createdDate
		  ,[Approved By]			=cm.approvedBy
		  ,[Approved Date]			=cm.approvedDate
		  ,[Email]					=cm.email 	
		  ,[Issuing Agent]			=t.agentName	
		from customerMaster cm with(nolock) 
		LEFT JOIN staticDataValue sdv (NOLOCK) ON cm.occupation = CAST(sdv.valueId AS VARCHAR)
		inner join #TEMP_1 t on t.membershipId = cm.membershipId'
		PRINT(@table);
		EXEC(@table);
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	SELECT * FROM @FilterList	
	
	SELECT 'CUSTOMER ENROLLMENT REPORT' title

END


GO
