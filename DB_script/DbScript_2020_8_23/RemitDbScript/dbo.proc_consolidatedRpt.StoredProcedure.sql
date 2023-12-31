USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_consolidatedRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
 exec proc_consolidatedRpt @flag='rpt',@user ='dipesh',@fromDate = '2014-10-10',@toDate ='2014-12-01'
 */
 CREATE proc [dbo].[proc_consolidatedRpt](  
	  @flag			VARCHAR(10)		= NULL  
	 ,@user			VARCHAR(20)		= NULL  
	 ,@fromDate		VARCHAR(40)		= NULL    
	 ,@toDate		VARCHAR(40)		= NULL   
)
AS   
IF @flag='rpt'  
BEGIN
	set @toDate = @toDate+' 23:59:59'
	select 
			agentId = sAgent,
			sendCount = count('x'),
			sendAmt = sum(tAmt),
			sendCom = sum(sAgentComm)
	into #send_txn_dom
	from remitTran rt with(nolock) 
	inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
	inner join agentMaster am with(nolock) on rt.sAgent = am.agentId
	where rt.approvedDate between @fromDate and @toDate
		and am.agentCountry = 'Nepal'
		and tranType = 'D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		AND ISNULL(am.agentBlock,'U') <>'B'
	group by sAgent,sAgentName,am.agentGrp

	select 
			agentId = pAgent,
			payCount = count('x'),
			payAmt = sum(pAmt),
			payCom = sum(pAgentComm)
	into #pay_txn_intl
	from remitTran rt with(nolock) 
	inner join agentMaster am with(nolock) on rt.sAgent = am.agentId
	where rt.paidDate between @fromDate and @toDate
		and tranType ='I'
		AND ISNULL(am.agentBlock,'U') <>'B'
	group by pAgent

	select 
			agentId = pAgent,
			payCount = count('x'), 
			payAmt = sum(pAmt),
			payCom = sum(pAgentComm)
	into #pay_txn_dom
	from remitTran rt with(nolock) 
	inner join agentMaster am with(nolock) on rt.sAgent = am.agentId
	where rt.paidDate between @fromDate and @toDate
		and tranType ='D'
		AND ISNULL(am.agentBlock,'U') <>'B'
	group by pAgent

	SELECT 
		[S.N.] = ROW_NUMBER() over(order by sdv.detailTitle,am.agentName),
		[Agent Information_Name] = am.agentName,
		[Agent Information_Group] = sdv.detailTitle,
		[International Transaction_Paid] = isnull(ip.payCount,0),
		[International Transaction_Paid Amt] = isnull(ip.payAmt,0),
		[International Transaction_RC] = isnull(ip.payCom,0),
		[Domestic Transaction_Send] = isnull(ds.sendCount,0),
		[Domestic Transaction_Paid] = isnull(dp.payCount,0),
		[Domestic Transaction_Send Amt] = isnull(ds.sendAmt,0),	
		[Domestic Transaction_Paid Amt] = isnull(dp.payAmt,0),
		[Domestic Transaction_SC] = isnull(ds.sendCom,0),
		[Domestic Transaction_RC] = isnull(dp.payCom,0),
		[Domestic Transaction_SC+RC] = isnull(ds.sendCom,0) + isnull(dp.payCom,0),
		[Total_Total TXN] = isnull(ip.payCount,0) + isnull(ds.sendCount,0) + isnull(dp.payCount,0),
		[Total_Total Com] = isnull(ip.payCom,0) + isnull(ds.sendCom,0) + isnull(dp.payCom,0)
	FROM agentMaster am 
	LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON am.agentGrp = sdv.valueId
	LEFT JOIN #pay_txn_intl ip ON am.agentId = ip.agentId
	LEFT JOIN #send_txn_dom ds ON am.agentId = ds.agentId
	LEFT JOIN #pay_txn_dom dp  ON am.agentId = dp.agentId
	WHERE am.agentType = 2903 
	and am.agentCountry ='Nepal' 
	and am.parentId not in (5576,4641)	
	and isnull(am.agentBlock,'U') <> 'B' 
	order by sdv.detailTitle,am.agentName

	DROP TABLE #pay_txn_intl
	DROP TABLE #send_txn_dom
	DROP TABLE #pay_txn_dom  
	  
	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id   
	SELECT 'Date Range' head,@fromDate+'-'+@toDate VALUE    
	SELECT 'Consolidated Report' title   
END  


GO
