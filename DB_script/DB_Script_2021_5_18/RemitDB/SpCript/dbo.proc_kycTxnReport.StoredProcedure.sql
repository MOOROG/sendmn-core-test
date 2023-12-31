USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_kycTxnReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_kycTxnReport]
(
	 @rptType			VARCHAR(10)=NULL
	,@user				VARCHAR(30)=NULL		
	,@fromDate			VARCHAR(30)=NULL
	,@toDate			VARCHAR(30)=NULL
	,@sZone				VARCHAR(30)=NULL
	,@sAgent			VARCHAR(10)=NULL
	,@remitCardNo		VARCHAR(50)=NULL
	,@slab				VARCHAR(10)=NULL
	
)AS
BEGIN
DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))

DECLARE 
	 @table			VARCHAR(MAX)	= NULL
	,@url			VARCHAR(max)	= NULL			
	,@gobalFilter	VARCHAR(MAX)	= ' WHERE rt.paymentMethod = ''IME Remit Card'''	
	
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
		SET @gobalFilter=@gobalFilter+' AND am.agentState ='''+@sZone+''''
	END
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent 
		SET @gobalFilter=@gobalFilter+' AND rt.sBranch ='''+@sAgent+''''
	END	
	IF @remitCardNo IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'IME Remit Card Number',@remitCardNo
		SET @gobalFilter=@gobalFilter+' AND cm.remitCardNo ='''+@remitCardNo+''''
	END

	IF @rptType='zone'
	BEGIN	
		SET @gobalFilter=@gobalFilter+' group by am.agentState order by am.agentState ASC'				
		SET @table='SELECT 
			 [S.N.]			= row_number()over(order by am.agentState)
			,[Zone]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300&rptType=district&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+am.agentState+''")>''+am.agentState+''</a>''						 
			,[Total Txn]	= CAST(count(''x'') AS VARCHAR(10))
		FROM remitTran rt WITH(NOLOCK)  
		INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sBranch = am.agentId   
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN kycMaster cm WITH(NOLOCK)ON ts.membershipId=cm.remitCardNo' +@gobalFilter 		
		PRINT @table
		EXEC(@table)					
	END

	IF @rptType='district'
	BEGIN	
		SET @gobalFilter=@gobalFilter+' group by am.agentState,am.agentDistrict order by am.agentDistrict ASC'				
		SET @table='SELECT 
			 [S.N.]			= row_number()over(order by am.agentDistrict)
			,[District]		= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300&rptType=agent&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+am.agentState+''")>''+am.agentDistrict+''</a>''						 
			,[Total Txn]	= CAST(count(''x'') AS VARCHAR(10))
		FROM remitTran rt WITH(NOLOCK)    
		INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sBranch = am.agentId 
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN kycMaster cm WITH(NOLOCK)ON ts.membershipId=cm.remitCardNo' +@gobalFilter 		
		PRINT @table
		EXEC(@table)		
		
		--SELECT * FROM 	kycMaster		
	END

	IF @rptType='agent'
	BEGIN
		SET @gobalFilter=@gobalFilter+' group by am.agentState,rt.sAgentName,rt.sAgent order by am.agentState ASC'				
		SET @table='SELECT 
			 [S.N.]			= row_number()over(order by am.agentState)
			,[Zone]			= am.agentState
			,[Agent]		= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300&rptType=remit&fromDate='+ISNULL(@fromDate,'')+'&toDate='+ISNULL(@toDate,'')+'&sZone=''+am.agentState+''&sAgent=''+cast(rt.sAgent as varchar)+''")>''+rt.sAgentName	+''</a>
''						 
			,[Total Txn]	= CAST(count(*) AS VARCHAR(10))
		FROM remitTran rt WITH(NOLOCK)    
		INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sBranch = am.agentId 
		INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
		INNER JOIN kycMaster cm WITH(NOLOCK)ON ts.membershipId=cm.remitCardNo' +@gobalFilter 
		
		PRINT @table
		EXEC(@table)
	 
	 END	

	IF @rptType='remit'
	BEGIN
		SET @gobalFilter = @gobalFilter+' GROUP BY cm.remitCardNo ORDER BY cm.remitCardNo ASC'
		SET @table='SELECT 
		         [S.N.]				= row_number() over(order by cm.remitCardNo)
				,[Card No]			= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=20832300&rptType=detail&fromDate='+ISNULL(@fromDate,'')+'&toDate='+isnull(@toDate,'')+'&sZone='+ISNULL(@sZone,'')+'&remitCardNo=''+cm.remitCardNo+''&sAgent='+ISNULL
(@sAgent,'')+'")>''+cm.remitCardNo+''</a>''		
				,[Total Txn]		= CAST(count(*) AS VARCHAR(10))
				,[Total Amount]		= sum(rt.pAmt)			
				,[Total Bonus Point]= SUM(rt.bonusPoint)
			FROM remitTran rt WITH(NOLOCK)			
			INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sBranch = am.agentId
			INNER JOIN tranReceivers rs WITH(NOLOCK) ON rt.id=rs.tranId 
			INNER JOIN kycMaster cm WITH(NOLOCK)ON rs.membershipId=cm.remitCardNo '+@gobalFilter 				
		
		 PRINT @table
		 EXEC(@table)
	
	END

	IF @rptType='detail'
	BEGIN	
		SET @table='SELECT 
				 [S.N.]					= row_number() over(order by rt.sAgentName)
				,[Agent Name]			= rt.sAgentName
				,[Control No]			= ''<span class = "link" onclick ="ViewTranDetailByControlNo('''''' + dbo.fnadecryptstring(rt.controlNo) + '''''');">'' + dbo.fnadecryptstring(rt.controlNo) + ''</span>'' 
				,[Total Amount]			= rt.pAmt
				,[Total bonus Point]	= rt.bonusPoint 
				,[IME Remit Card No.]	= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/CustomerSetup/KYC/View.aspx?customerId='' + cast(cm.rowId as varchar)+ '''''')">'' + cm.remitCardNo + ''</a>''
				,[Sender Name]			= rt.senderName
				,[Receiver Name]		= rt.receiverName
				,[Pay Status]			= rt.payStatus
				,[TXN Date]				= rt.createdDateLocal
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sBranch = am.agentId
			INNER JOIN tranReceivers rs WITH(NOLOCK) ON rt.id = rs.tranId 
			INNER JOIN kycMaster cm WITH(NOLOCK)ON rs.membershipId=cm.remitCardNo '+@gobalFilter
		PRINT @Table
		EXEC(@Table)
		
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	SELECT * FROM @FilterList
	
	SELECT 'IME Remit Card Txn Report' title	
END



GO
