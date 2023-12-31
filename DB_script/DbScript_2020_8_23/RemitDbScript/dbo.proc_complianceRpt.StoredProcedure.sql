USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_complianceRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_complianceRpt]
(
	 @flag VARCHAR(20)=NULL
	,@date VARCHAR(20)=NULL
	,@rName VARCHAR(50)=NULL
	,@fromDate VARCHAR(20)=NULL
	,@toDate VARCHAR(20)=NULL
)
AS
BEGIN	
	IF @flag='rdd'
	BEGIN
		SELECT 
		 [Receiver Name]				=tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+' '+ISNULL(tr.lastName2,'')
		,[Id Type]						= ISNULL(tr.idType2,tr.idType)
		,[Id Number]					= ISNULL(tr.idNumber2,tr.idNumber)
		,[Control No]					='<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+CAST(rt.id AS VARCHAR)+''')">'+dbo.FNADecryptString(controlNo)+'</a>'
		,[Amount]						=rt.pAmt
		,[Payout Agent]					=am.agentName
		,[Tran Status]					=rt.tranStatus
		,[Pay Status]					=rt.payStatus
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranreceivers tr WITH(NOLOCK) ON rt.id=tr.tranId 
		LEFT JOIN agentMaster am ON am.agentId=rt.pAgent
		WHERE rt.createdDate BETWEEN @date AND @date+' 23:59:59'
		AND rt.tranStatus <>'Cancel'
		AND rt.tranType = 'I'
		AND ltrim(rtrim(replace(tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+' '+ISNULL(tr.lastName2,''),'  ',' ')))
		= replace(rtrim(ltrim(@rName)),'  ',' ')	
		
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT  'Date ' head, @date  value UNION ALL
		SELECT 'Report By' head, 'Receiver Wise Tranaction Detail' value UNION ALL
		SELECT 'Receiver Name' head, @rName value

		SELECT 'Single Day Transaction ' title			
		RETURN
	END
	IF (@flag='muls')
	BEGIN
		IF OBJECT_ID('tempdb..#temp4') IS NOT NULL
				DROP TABLE #temp4
			IF OBJECT_ID('tempdb..#temp5') IS NOT NULL
				DROP TABLE #temp5
				
			SELECT 				
				 [Sender Name]					='Name: '+ts.firstName+' '+ISNULL(ts.middleName,'')+' '+ISNULL(ts.lastName1,'')	+ '<br/>'
														 +ISNULL(ts.idType,'')+' :'+ISNULL(ts.idNumber,'')+'<br/>Phone: '+ISNULL(ts.homePhone,ISNULL(ts.mobile,''))			 	 
				,[Receiver Name]				='Name: '+tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+ '<br/>Cell: '
														 +ISNULL(tr.mobile,'')+'<br/>Address: '+ISNULL(tr.address,'')+ISNULL(','+tr.address2,'')
														 +'<br/>'+CASE WHEN ISNULL(tr.idType2,tr.idType) IS NULL OR ISNULL(tr.idNumber2,tr.idNumber) IS NULL THEN '' ELSE ISNULL(tr.idType2,tr.idType)+': '+ISNULL(tr.idNumber2,tr.idNumber) END
				,[Control No]					='<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+CAST(rt.id AS VARCHAR)+''')">'+dbo.FNADecryptString(controlNo)+'</a>'
				,[Tran Date]					= rt.createdDate
				,[Sending Country]				= rt.sCountry
				,[Payment Method]				= rt.paymentMethod --+ '-'+ dbo.decryptDb(rt.controlNo)
				
				,[Money source]					= ISNULL(rt.sourceOfFund,'Salary and Savings')
				,pAmt							= (rt.pAmt)
				,[Payout currency]				= ISNULL(rt.payoutCurr,'')
				,[Payout Location]				= ISNULL(rt.pBranchName,'')+'<b>('+ISNULL(ploc.districtName,'')+'</b>'
				,[sName]						= ts.firstName+' '+ISNULL(ts.middleName,'')+' '+ISNULL(ts.lastName1,'')+'-'+ ISNULL(ts.idNumber,'')
			INTO #temp4
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN tranreceivers tr WITH(NOLOCK) ON rt.id=tr.tranId 
			LEFT JOIN dbo.api_districtList ploc WITH(NOLOCK) ON rt.pLocation = ploc.districtCode
			WHERE  
			rt.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
			AND rt.tranType = 'I'
			AND rt.tranStatus <>'Cancel'
						
			SELECT sName 
				INTO #temp5
			FROM #temp4
				GROUP BY sName 
			HAVING SUM(pAmt)> = 1000.00 ORDER BY sName

			SELECT [Sender Name],[Receiver Name],[Tran Date],[Control No],[Sending Country],[Payout Location]
				,[Payment Method],dbo.ShowDecimal(pAmt)[Payout Amount],[Payout currency]
				,a.[sName]
			FROM #temp4 a INNER JOIN #temp5 b ON a.sName = b.sName ORDER BY a.sName

			SELECT * FROM #temp5 ORDER BY sName
			
			
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT  'From Date ' head, @fromDate  value UNION ALL
		SELECT  'To Date ' head, @toDate  value UNION ALL
		SELECT 'Report By' head, (SELECT CASE WHEN @flag = 'muls' THEN 'Sender Wise Multiple Tranaction' WHEN @flag ='mulr' THEN 'Receiver Wise Multiple Tranaction' END) value
		SELECT 'Multiple Day Transaction ' title		
		
		RETURN	 
			  
	END
	IF @flag='mulr'
	BEGIN
		IF OBJECT_ID('tempdb..#temp3') IS NOT NULL
				DROP TABLE #temp3
		SELECT 
		 [Receiver Name]				=tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+' '+ISNULL(tr.lastName2,'')
		,Amount							=rt.pAmt
		,AmountInUSD					=rt.pAmt / ISNULL(rt.pCurrCostRate,1) - ISNULL(rt.pCurrHoMargin, 0)
		,Remarks						=CAST(rt.createdDate AS DATE)
		,rName							=tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+' '+ISNULL(tr.lastName2,'')
		,pAmt
		,txnDate=CAST(rt.createdDate AS DATE)
		INTO #temp3
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranreceivers tr WITH(NOLOCK) ON rt.id=tr.tranId 
		WHERE rt.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		AND rt.tranType = 'I'
		AND rt.tranStatus <>'Cancel'	
			 		 
		SELECT [SNO] = ROW_NUMBER() OVER (ORDER BY rName ASC)
				,'Receiver Name'		='<a href = "#" onclick="OpenInNewWindow(''Reports.aspx?reportName=nrb_report&flag=rdd&rName='+rName+'&type=r&date='+CAST(txnDate AS VARCHAR)+''')">'+rName+'</a>'				
				,'Remitance in NPR_Txn Count'		=COUNT(rName)
				,'Remitance in NPR_Total Amount(NPR)'=SUM(Amount)
				,'Remitance in USD_Txn Count'		=COUNT(rName)
				,'Remitance in USD_Total Amount(USD)'=SUM(AmountInUSD)
				,'Date'			=txnDate
		FROM #temp3 GROUP BY rName,txnDate
		HAVING SUM(pAmt)> = 1000.00 
		ORDER BY rName 

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT  'From Date ' head, @fromDate  value UNION ALL
		SELECT  'To Date ' head, @toDate  value UNION ALL
		SELECT 'Report By' head, (SELECT CASE WHEN @flag = 'muls' THEN 'Sender Wise Multiple Tranaction' WHEN @flag ='mulr' THEN 'Receiver Wise Multiple Tranaction' END) value
		SELECT 'Multiple Day Transaction ' title	

		RETURN
	END
	IF @flag='r'
	BEGIN		
		SELECT 
		 [Receiver Name]				=tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+' '+ISNULL(tr.lastName2,'')
		,Amount							=rt.pAmt
		,AmountInUSD					=rt.pAmt / ISNULL(rt.pCurrCostRate,1) - ISNULL(rt.pCurrHoMargin, 0)
		,Remarks						=rt.createdDate
		,rName							=tr.firstName+' '+ISNULL(tr.middleName,'')+' '+ISNULL(tr.lastName1,'')+' '+ISNULL(tr.lastName2,'')
		,pAmt
		INTO #temp2
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranreceivers tr WITH(NOLOCK) ON rt.id=tr.tranId 
		WHERE rt.createdDate BETWEEN @date AND @date+' 23:59:59'
			AND rt.tranType = 'I'
			AND rt.tranStatus <>'Cancel'
			
		update #temp2 set rName = REPLACE(rName,'  ',' ')
			
		 SELECT [SNO] = ROW_NUMBER() OVER (ORDER BY rName ASC)
				,'Receiver Name'		='<a href = "#" onclick="OpenInNewWindow(''Reports.aspx?reportName=nrb_report&flag=rdd&rName='+rName+'&type=r&date='+@date+''')">'+rName+'</a>'				
				,'Remitance in NPR_Txn Count'		=COUNT(rName)
				,'Remitance in NPR_Total Amount(NPR)'=SUM(Amount)
				,'Remitance in USD_Txn Count'		=COUNT(rName)
				,'Remitance in USD_Total Amount(USD)'=SUM(AmountInUSD)
				,'Date'			=@date
		FROM #temp2 GROUP BY rName 
		HAVING SUM(pAmt)> = 1000.00 
		ORDER BY rName 
		
	END
	IF @flag='s'
	BEGIN			
			IF OBJECT_ID('tempdb..#temp') IS NOT NULL
				DROP TABLE #temp
			IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
				DROP TABLE #temp1
				
			SELECT 				
				 [Sender Name]					='Name: '+rt.senderName+ '<br/>'
														 +ISNULL(ts.idType,'')+' :'+ISNULL(ts.idNumber,'')+'<br/>Phone: '+ISNULL(ts.homePhone,ISNULL(ts.mobile,''))			 	 
				,[Receiver Name]				='Name: '+rt.receiverName+ '<br/>Cell: '
														 +ISNULL(tr.mobile,'')+'<br/>Address: '+ISNULL(tr.address,'')+ISNULL(','+tr.address2,'')
														 +'<br/>'+CASE WHEN ISNULL(tr.idType2,tr.idType) IS NULL OR ISNULL(tr.idNumber2,tr.idNumber) IS NULL THEN '' ELSE ISNULL(tr.idType2,tr.idType)+': '+ISNULL(tr.idNumber2,tr.idNumber) END
				,[Control No]					='<a href = "#" onclick="OpenInNewWindow('''+dbo.dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId='+CAST(rt.id AS VARCHAR)+''')">'+ dbo.dbo.FNADecryptString(rt.controlNo) +'</a>'
				,[Tran Date]					= rt.createdDate
				,[Sending Country]				= rt.sCountry
				,[Payment Method]				= rt.paymentMethod			
				,[Money source]					= ISNULL(rt.sourceOfFund,'Salary and Savings')
				,[pAmt]							= rt.pAmt
				,[Payout currency]				= ISNULL(rt.payoutCurr,'')
				,[Payout Location]				= ISNULL(rt.pBranchName,'')+'<b>('+ISNULL(ploc.districtName,'')+'</b>'
				,[sName]						= rt.senderName+'-'+ ISNULL(ts.idNumber,'')
			INTO #temp
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
			INNER JOIN tranreceivers tr WITH(NOLOCK) ON rt.id=tr.tranId 
			LEFT JOIN dbo.api_districtList ploc WITH(NOLOCK) ON rt.pLocation = ploc.districtCode
			WHERE rt.createdDate BETWEEN @date AND @date+' 23:59:59'
				AND rt.tranType = 'I'
				AND tranStatus <> 'Cancel'

			SELECT sName 
				INTO #temp1
			FROM #temp 
				GROUP BY sName 
			HAVING SUM(pAmt)> = 1000.00 ORDER BY sName

			SELECT 
				[Sender Name],
				[Receiver Name],
				[Tran Date],
				[Control No],
				[Sending Country],
				[Payout Location],
				[Payment Method],
				[Payout Amount] = dbo.ShowDecimal(pAmt),
				[Payout currency],				
				sName = a.[sName]
			FROM #temp a INNER JOIN #temp1 b ON a.sName = b.sName ORDER BY a.sName

			SELECT * FROM #temp1 ORDER BY sName	
	END
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT  'Date ' head, @date  value UNION ALL
	SELECT 'Report By' head, (SELECT CASE WHEN @flag = 's' THEN 'Sender Wise Tranaction' WHEN @flag ='r' THEN 'Receiver Wise Tranaction' END) value
	SELECT 'Single Day Transaction ' title
	
END
 

GO
