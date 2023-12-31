USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerBonusRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_customerBonusRpt]
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
	,@gobalFilter	VARCHAR(MAX)	= ' WHERE rt.bonusPoint is not null and rt.isBonusUpdated =''Y'' and cm.approvedDate is not null '	
	
	IF @fromDate IS NOT NULL AND @toDate IS NOT NULL 
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'From Date',@fromDate 
		INSERT INTO @FilterList 
		SELECT 'To Date',@toDate 
		SET @gobalFilter=@gobalFilter+' AND rt.paidDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
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
	
	IF @flag='sz'
	BEGIN	
		SET @gobalFilter=@gobalFilter+' group by ts.state order by ts.state ASC'				
		SET @table='SELECT 
			 [S.N.]			= row_number()over(order by ts.state)
			,[Zone]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822100_bonus&searchBy=sa&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+ts.state+''")>''+ts.state+''</a>''						 
			,[Total Txn]	= CAST(count(*) AS VARCHAR(10))
		FROM remitTran rt WITH(NOLOCK)    
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId' +@gobalFilter 		
		PRINT @table
		EXEC(@table)
					
	END

	IF @flag='sa'
	BEGIN
		SET @gobalFilter=@gobalFilter+' group by ts.state,rt.sAgentName,rt.sAgent order by ts.state ASC'				
		SET @table='SELECT 
			 [S.N.]			= row_number()over(order by ts.state)
			,[Zone]			= ts.state
			,[Agent]		= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822100_bonus&searchBy=c&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+ts.state+''&sAgent=''+cast(rt.sAgent as varchar)+''")>''+rt.sAgentName	+''</a>''						 
			,[Total Txn]	= CAST(count(*) AS VARCHAR(10))
		FROM remitTran rt WITH(NOLOCK)    
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId' +@gobalFilter 
		
		PRINT @table
		EXEC(@table) 
	 END	

	IF @flag='c' AND @slab IS NULL
	BEGIN
		SET @gobalFilter = @gobalFilter+' GROUP BY cm.membershipId ORDER BY cm.membershipId ASC'
		SET @table='
		SELECT 
		         [S.N.]				= row_number() over(order by cm.membershipId)
				,[Card No]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822100_bonus&searchBy=detail&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId=''+cm.membershipId+''&sAgent='+ISNULL(@sAgent,'')+'")>''+cm.membershipId+''</a>''		
				,[Total Txn]		= CAST(count(*) AS VARCHAR(10))
				,[Total Amount]		= sum(rt.pAmt)			
				,[Total Bonus Point]= SUM(rt.bonusPoint)
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId '+@gobalFilter 				
		
		 PRINT @table
		 EXEC(@table)
	END
	
	IF @flag='detail'
	BEGIN	
		SET @url = DBO.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx'
		SET @table='SELECT 
				 [S.N.]					= row_number() over(order by rt.sAgentName)
				,[Agent Name]			= rt.sAgentName
				,[Control No]			= ''<span class = "link" onclick ="ViewTranDetailByControlNo('''''' + dbo.fnadecryptstring(rt.controlNo) + '''''');">'' + dbo.fnadecryptstring(rt.controlNo) + ''</span>'' 
				,[Total Amount]			= rt.pAmt
				,[Total bonus Point]	= rt.bonusPoint 
				,[Membership Id]		= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/Display.aspx?membershipId='' + cm.membershipId + '''''')">'' + cm.membershipId + ''</a>''
				,[Sender Name]			= rt.senderName
				,[Receiver Name]		= rt.receiverName
				,[Pay Status]			= rt.payStatus
				,[TXN Date]				= rt.createdDateLocal
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId '+@gobalFilter
		PRINT @Table
		EXEC(@Table)		
	END

	IF @flag='b'
	BEGIN
		DECLARE @tempTable 	TABLE(SLAB varchar(10),BPOINT VARCHAR(50),TCUSTOMER varchar(10))

		INSERT INTO @tempTable(SLAB,BPOINT)
		SELECT 's1','0-50000' UNION ALL
		SELECT 's2','50001-300000' UNION ALL
		SELECT 's3','300001-500000' UNION ALL
		SELECT 's4','Above 500000' 

		IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
			DROP TABLE #TEMP		

		SELECT s1 = sum(s1),s2 = sum(s2),s3 =sum(s3),s4 = sum(s4)
		INTO #TEMP
		FROM 
		(
			select 
			CASE WHEN bonusPoint between 0 and 50000 then count('x') else 0 end 's1',
			CASE WHEN bonusPoint between 50001 and 300000 then count('x') else 0 end 's2',
			CASE WHEN bonusPoint between 300001 and 500000 then count('x') else 0 end 's3',
			CASE WHEN bonusPoint > 500000 then count('x') else 0 end 's4'
			from 
			(
				SELECT membershipId = CM.MEMBERSHIPID,
				bonusPoint = sum(rt.bonusPoint)
				FROM remitTran rt WITH(NOLOCK) 
				INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
				INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId  
				WHERE rt.paidDate BETWEEN @fromDate AND @toDate+' 23:59:59'
				AND rt.bonusPoint is not null 
				AND rt.isBonusUpdated ='Y' 
				AND cm.approvedDate is not null 
				group by cm.membershipId
			)x group by bonusPoint
		)y 

		UPDATE @tempTable SET TCUSTOMER = s1 FROM #TEMP WHERE SLAB = 's1'
		UPDATE @tempTable SET TCUSTOMER = s2 FROM #TEMP WHERE SLAB = 's2'
		UPDATE @tempTable SET TCUSTOMER = s3 FROM #TEMP WHERE SLAB = 's3'
		UPDATE @tempTable SET TCUSTOMER = s4 FROM #TEMP WHERE SLAB = 's4'

		SELECT 
				[S.N.] = row_number() over(order by SLAB),
				[Bonus Point] = BPOINT, 
				[Total Customer]='<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822100_bonus&searchBy=c&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&sAgent='+ISNULL(@sAgent,'')+'&slab='+SLAB+'")>'+CAST(TCUSTOMER AS VARCHAR(10))+'</a>'		   
		FROM @tempTable
	
	END

	IF @flag='c' AND @slab IS NOT NULL 
	BEGIN
	SET @gobalFilter = @gobalFilter+' GROUP BY cm.membershipId '
		SET @table='
		SELECT 
			 [S.N.]			= row_number() over(order by membershipId)
			,[Card No]
			,[Total Txn]
			,[Total Amount]
			,[Total Bonus Point]
		FROM 
		(
			SELECT 
				 membershipId		= cm.membershipId
		        ,[Card No]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20822100_bonus&searchBy=detail&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&membershipId=''+cm.membershipId+''&sAgent='+ISNULL(@sAgent,'')+'")>''+cm.membershipId+''</a>''		
				,[Total Txn]		= CAST(count(*) AS VARCHAR(10))
				,[Total Amount]		= sum(rt.pAmt)			
				,[Total Bonus Point]= SUM(rt.bonusPoint)
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId '+@gobalFilter+' )x  '				
		
		IF @slab IS NOT NULL 
		BEGIN
			IF @slab ='s1'
			BEGIN
				INSERT INTO @FilterList 
				SELECT 'SLAB-1',' 0-50000'
				SET @table=@table+' WHERE [Total Bonus Point] BETWEEN 0 AND 50000'	
			END	
			IF @slab ='s2'
			BEGIN
				INSERT INTO @FilterList 
				SELECT 'SLAB-2','50001-300000'
				SET @table=@table+' WHERE [Total Bonus Point] BETWEEN 50001 AND 300000'	
			END	
			IF @slab ='s3'
			BEGIN
				INSERT INTO @FilterList 
				SELECT 'SLAB-3','300001-500000'
				SET @table=@table+' WHERE  [Total Bonus Point] BETWEEN 300001 AND 500000'	
			END	
			IF @slab ='s4'
			BEGIN
				INSERT INTO @FilterList 
				SELECT 'SLAB-4','Above 500000'
				SET @table=@table+' WHERE [Total Bonus Point] > 500000'	
			END	
		END

		PRINT @table
		EXEC(@table)		
	END
		
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	SELECT * FROM @FilterList
	
	SELECT 'CUSTOMER BONUS REPORT' title	
END


GO
