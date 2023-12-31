USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerRpt]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_customerRpt]
(
	 @flag				VARCHAR(10)=NULL
	,@user				VARCHAR(30)=NULL		
	,@fromDate			VARCHAR(30)=NULL
	,@toDate			VARCHAR(30)=NULL
	,@sZone				VARCHAR(30)=NULL
	,@sAgent			VARCHAR(10)=NULL
	,@memberShipId		VARCHAR(50)=NULL
	,@slab				VARCHAR(10)=NULL
	
)AS
BEGIN
DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))

DECLARE 
	 @table			VARCHAR(MAX)	= NULL
	,@url			VARCHAR(max)	= NULL			
	,@gobalFilter	VARCHAR(MAX)	= ' WHERE rt.bonusPoint is not null'	
	
	IF @fromDate IS NOT NULL AND @toDate IS NOT NULL 
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'From Date',@fromDate 
		INSERT INTO @FilterList 
		SELECT 'To Date',@toDate 
		SET @gobalFilter=@gobalFilter+' AND rt.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	END
	IF @sZone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Zone',@sZone 
		SET @gobalFilter=@gobalFilter+' AND ts.state ='''+@sZone+''''
	END
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent 
		SET @gobalFilter=@gobalFilter+' AND rt.sAgent ='''+@sAgent+''''
	END	
	IF @memberShipId IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Membership Id',@memberShipId
		SET @gobalFilter=@gobalFilter+' AND cast(cm.memberShipId as varchar) ='''+@memberShipId+''''
	END
	
	IF @slab IS NOT NULL
	BEGIN	
		INSERT INTO @FilterList 
		SELECT 'Slab',CASE WHEN @slab ='s1' THEN '0-50000'
						   WHEN @slab ='s2' THEN '500001-300000'
						   WHEN @slab ='s3' THEN 'Above 300000' END
	END	
				
	IF @flag='sb'
	BEGIN		
		SELECT 'sz'		ddlValue,'ZONE WISE' ddlText UNION ALL	
		SELECT 'sa'		ddlValue,'AGENT WISE' ddlText UNION ALL	
		SELECT 'c'		ddlValue,'CARD WISE' ddlText UNION ALL	
		SELECT 'detail' ddlValue,'DETAIL' UNION ALL
		SELECT 'age' ddlValue,'AGE WISE' ddlText
	END
	IF @flag='ddl-bonus'
	BEGIN		
		SELECT 'sz' ddlValue,'ZONE WISE' ddlText UNION ALL	
		SELECT 'sa' ddlValue,'AGENT WISE' ddlText UNION ALL	
		SELECT 'c' ddlValue,'CARD WISE' ddlText UNION ALL	
		SELECT 'b' ddlValue,'SLAB WISE' ddlText UNION ALL
		SELECT 'detail' ddlValue,'DETAIL' ddlText
	END
	IF @flag='sz'
	BEGIN	
		SET @gobalFilter=@gobalFilter+' group by ts.state,rt.sAgentName,rt.sAgent order by ts.state ASC'				
		SET @table='SELECT 
			 [S.N.]			= row_number()over(order by ts.state )
			,[Zone]			=ts.state
			,[Agent]		=''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerpt&searchBy=s&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+ts.state+''&membershipId='+ISNULL(@membershipId,'')+'&slab='+ISNULL(@slab,'')+'&sAgent=''+cast(rt.sAgent as varchar)+''")>''+rt.sAgentName	+''</a>''						 
			,[Total Txn]	=CAST(count(*) AS VARCHAR(10))
		FROM remitTran rt WITH(NOLOCK)    
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.customerId=cm.customerId' +@gobalFilter 
		
		print @table
		exec(@table)
					
	END
	IF @flag='sa'
	BEGIN
		SET @gobalFilter=@gobalFilter+' group by rt.sAgentName,rt.sAgent order by rt.sAgentName'
		SET @table='SELECT 
				 [S.N.]			= row_number()over(order by rt.sAgentName)
				,[Agent]		= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerpt&searchBy=s&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId='+ISNULL(@membershipId,'')+'&slab='+ISNULL(@slab,'')+'&sAgent=''+cast(rt.sAgent as varchar(50))+''")>''+rt.sAgentName+''</a>''
				,[Txn Count]	= CAST(count(*) AS VARCHAR(10))	
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.customerId=cm.customerId' +@gobalFilter
			
		 print @table
		 exec(@table)
	 
	 END	
	IF @flag='c'
	BEGIN
		SET @gobalFilter=@gobalFilter+' GROUP BY cm.membershipId ORDER BY cm.membershipId ASC'
		SET @table='SELECT 
		         [S.N.]				= row_number() over(order by cm.membershipId)
				,[Card No]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerpt&searchBy=cdd&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId=''+cm.membershipId+''&sAgent='+ISNULL(@sAgent,'')+'&slab='+ISNULL(@slab,'')+'")>''+cm.membershipId+''</a>''		
				,[Total Txn]		= CAST(count(*) AS VARCHAR(10))
				,[Total Amount]		= sum(rt.pAmt)			
				,[Total Bonus Point]= SUM(rt.bonusPoint)
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.customerId=cm.customerId '+@gobalFilter 				
		
		 print @table
		 exec(@table)
	
	END
	IF @flag='b'
	BEGIN
		--## Table for slab determination		
		DECLARE @tempTable 	TABLE(SLAB varchar(10),BPOINT VARCHAR(50),TCUSTOMER varchar(10))

		INSERT INTO @tempTable(SLAB,BPOINT)
		SELECT 's1','0-50000' UNION ALL
		SELECT 's2','500001-300000' UNION ALL
		SELECT 's3','Above 300000' 

		UPDATE @tempTable SET TCUSTOMER = X.CNT FROM @tempTable A,
		(
			SELECT CNT = ISNULL(COUNT('X'),0)   		 
			FROM customerMaster WITH(NOLOCK)
			WHERE bonusPoint BETWEEN 0 AND 50000 
		)X WHERE SLAB = 's1'

		UPDATE @tempTable SET TCUSTOMER = X.CNT FROM @tempTable A,
		(
			SELECT CNT = ISNULL(COUNT('X'),0)   		 
			FROM customerMaster WITH(NOLOCK)
			WHERE bonusPoint BETWEEN 500001 AND 300000 
		)X WHERE SLAB = 's2'

		UPDATE @tempTable SET TCUSTOMER = X.CNT FROM @tempTable A,
		(
			SELECT CNT = ISNULL(COUNT('X'),0)   		 
			FROM customerMaster WITH(NOLOCK)
			WHERE bonusPoint > 300000
		)X WHERE SLAB = 's3'

		SELECT 
				[S.N.] = row_number() over(order by SLAB),
				[Bonus Point] = BPOINT, 
				[Total Customer]='<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerpt&searchBy=s&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&sAgent='+ISNULL(@sAgent,'')+'&slab='+SLAB+'")>'+CAST(TCUSTOMER AS VARCHAR(10))+'</a>'		   
		FROM @tempTable
	
	END
	IF @flag='s'
	BEGIN	
	
	SET @gobalFilter=@gobalFilter +'GROUP BY cm.membershipId'
			
	SET @table='SELECT 	
		 [S.N.]	= row_number() over(order by cm.membershipId)
		,[Membership Id]		=''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=customerpt&searchBy=detail&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId=''+cm.membershipId+''&sAgent='+ISNULL(@sAgent,'')+'")>''+CAST(cm.membershipId AS VARCHAR(10))+''</a>''	
		,[Txn Count]			=count(*)
		,[Total Txn Amt]		=SUM(rt.pAmt)
		,[Total Bonus Point]	=SUM(rt.bonusPoint) 
	FROM remittran rt WITH(NOLOCK)
	INNER JOIN transenders ts WITH(NOLOCK) on rt.id=ts.tranId 
	INNER JOIN customerMaster cm WITH(NOLOCK) on ts.membershipId=cm.memberShipId' 		
	
	IF @slab is not null and @slab='s1'
		SET @gobalFilter=@gobalFilter+' having SUM(rt.bonusPoint) BETWEEN 0 AND 50000' 
	IF @slab is not null and @slab='s2'
		SET @gobalFilter=@gobalFilter+' having SUM(rt.bonusPoint) BETWEEN 500001 AND 300000' 
	IF @slab is not null and @slab='s3'
		SET @gobalFilter=@gobalFilter+' having SUM(rt.bonusPoint) > 300000' 				

	SET @table=@table+@gobalFilter+' ORDER BY cm.membershipId ASC'	
	PRINT @Table
	EXEC(@Table)
		
	END	
	IF @flag='cdd'
	BEGIN
		SET @gobalFilter=@gobalFilter +'group by rt.sAgentName,rt.controlNo ORDER BY rt.sAgentName ASC'		
		SET @table='SELECT
				 [S.N.]			= row_number() over(order by rt.sAgentName)
				,[Control No]	= dbo.FNADecryptString(rt.controlNo)
				,[AGENT]		= rt.sAgentName
				,[Txn Amount]	= sum(rt.pAmt)
				,[Bonus Point]	= SUM(rt.bonusPoint) 
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.customerId=cm.customerId'+@gobalFilter
			
			
		PRINT @Table
		EXEC(@Table)				
	END
	IF @flag='detail'
	BEGIN	
		--SET @gobalFilter=@gobalFilter 
		SET @url = DBO.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx'
		SET @table='SELECT 
				 [S.N.]					= row_number() over(order by rt.sAgentName)
				,[Agent Name]			= rt.sAgentName
				,[Control No]			= ''<span class = "link" onclick ="ViewTranDetailByControlNo('''''' + dbo.fnadecryptstring(rt.controlNo) + '''''');">'' + dbo.fnadecryptstring(rt.controlNo) + ''</span>'' 
				,[Total Amount]			= rt.pAmt
				,[Total bonus Point]	= rt.bonusPoint 
				--,[Membership Id]		= ''<a href="#" onclick="OpenInNewWindow('''+@url+'?membershipId=''+cm.membershipId+'')">''+cm.membershipId+''</a>''
				,[Membership Id]		= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx?membershipId='' + cm.membershipId + '''''')">'' + cm.membershipId + ''</a>''
				,[Sender Name]			= rt.senderName
				,[Receiver Name]		= rt.receiverName
				,[Pay Status]			= rt.payStatus
				,[TXN Date]				= rt.createdDateLocal
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.customerId=cm.customerId '+@gobalFilter
		PRINT @Table
		EXEC(@Table)
		
	END
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	select * from @FilterList
	
	SELECT 'CUSTOMER BONUS REPORT' title	
END

GO
