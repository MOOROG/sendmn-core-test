SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

/*
EXEC proc_paidTranReportInternational @FLAG='A',@FROMDATE='10/1/2012',@TODATE='10/31/2012'
EXEC proc_paidTranReportInternational @FLAG='C',@FROMDATE='09/20/2012',@TODATE='09/12/2012'
*/
ALTER PROCEDURE [dbo].[proc_paidTranReportInternational]
	@flag				VARCHAR(20),
	@fromDate			VARCHAR(20)	= NULL,
	@toDate				VARCHAR(30) = NULL,
	@sCountry			VARCHAR(50)	= NULL,
	@sZone				VARCHAR(50)	= NULL,
	@sDistrict			VARCHAR(50)	= NULL,
	@sLocation			VARCHAR(50) = NULL,
	@sAgent				VARCHAR(50) = NULL,
	@sBranch			VARCHAR(50) = NULL,
	@rCountry			VARCHAR(50)	= NULL,
	@rZone				VARCHAR(50) = NULL,
	@rDistrict			VARCHAR(50)	= NULL,
	@rLocation			VARCHAR(50) = NULL,
	@rAgent				VARCHAR(50)	= NULL,
	@rBranch			VARCHAR(50)	= NULL,
	@tranType			VARCHAR(50) = NULL,
	@user				VARCHAR(50)	= NULL
	                                        
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

	IF @rZone ='All'
		set @rZone = null
	if @sZone ='All'
		set @sZone= null
		
	IF @rDistrict ='All'
		set @rDistrict = null
	if @sDistrict ='All'
		set @sDistrict= null
	
	IF @rLocation ='All'
		set @rLocation = null
	if @sLocation ='All'
		set @sLocation= null
		
	SET @TODATE  = @TODATE + ' 23:59:59'

	IF @FLAG='A'
	BEGIN
			
			IF OBJECT_ID('tempdb..#TEMP_TABLE') IS NOT NULL 
			DROP TABLE #TEMP_TABLE

			select dbo.GetAgentNameFromId(isnull(pBranch,pBankBranch)) [Payout Agent]
			,ltrim(rtrim(dbo.GetAgentNameFromId(sBranch)))+' ('+sCountry+') : '+dbo.FNADecryptString(controlNo)+'</br>'+isnull(sen.firstName,'')+' '+isnull(sen.middleName,'')+' '+isnull(sen.lastName1,'')+' '+isnull(sen.lastName2,'') [Sending Details]
			,isnull(rec.firstName,'')+' '+isnull(rec.middleName,'')+' '+isnull(rec.lastName1,'')+' '+isnull(rec.lastName2,'') [Receiver Name]
			,paidBy+'<br/>'+ convert(varchar,paidDate,107) [Paid Date]
			,cast(dbo.ShowDecimal(cAmt) as varchar)+' '+collCurr [Send Amount]
			,cast(dbo.ShowDecimal(pAmt) as varchar) [Receive Amount]
			INTO #TEMP_TABLE
			from remitTran A with(nolock) 
			LEFT JOIN tranReceivers rec WITH(NOLOCK) ON a.id = rec.tranId
			LEFT JOIN tranSenders sen WITH(NOLOCK) ON a.id=sen.tranId
			LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
			LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
			LEFT JOIN api_districtList D WITH(NOLOCK) ON D.ROWID=B.agentLocation
			LEFT JOIN api_districtList E WITH(NOLOCK) ON E.ROWID=C.agentLocation
					
			WHERE tranStatus='Paid' 
			
			AND paidDate BETWEEN @fromDate AND @toDate 
			AND sCountry<>'Nepal'					
			AND sCountry = ISNULL(@sCountry,sCountry)
			AND isnull(B.agentState,'') =ISNULL(@sZone,isnull(B.agentState,''))
			AND isnull(B.agentDistrict,'') =ISNULL(@sDistrict,isnull(B.agentDistrict,''))
			AND isnull(B.agentLocation,'') =ISNULL(@sLocation,isnull(B.agentLocation,''))			
			AND isnull(sAgent,'') =  ISNULL(@sAgent,isnull(sAgent,''))
			AND isnull(sBranch,'') = ISNULL(@sBranch,isnull(sBranch,''))
			
			AND isnull(pCountry,'') = ISNULL(@rCountry,isnull(pCountry,''))
			AND isnull(C.agentState,'') =ISNULL(@rZone,isnull(C.agentState,''))
			AND isnull(C.agentDistrict,'') =ISNULL(@rDistrict,isnull(C.agentDistrict,''))
			AND isnull(C.agentLocation,'') =ISNULL(@rLocation,isnull(C.agentLocation,''))			
			AND isnull(pAgent,'') =  ISNULL(@rAgent,isnull(pAgent,''))
			AND isnull(pBranch,pBankBranch) = ISNULL(@rBranch,isnull(pBranch,''))			
			order by pBranch

			SELECT DISTINCT ISNULL([Payout Agent],'') HEAD FROM #TEMP_TABLE

			SELECT ISNULL([Payout Agent],'') HEAD,[Sending Details],[Receiver Name],[Paid Date],[Send Amount],[Receive Amount] FROM #TEMP_TABLE

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		
				
			SELECT 'From Date ' head, CONVERT(VARCHAR, @fromDate, 101) value
			UNION ALL
			SELECT 'To Date ' head, CONVERT(VARCHAR, @toDate, 101) value
			UNION ALL
			SELECT 'Sending Country ' head,ISNULL(@sCountry,'All')
			UNION ALL
			SELECT 'Sending Zone ' head,ISNULL(@sZone,'All')
			UNION ALL
			SELECT 'Sending District ' head,ISNULL(@sDistrict,'All')
			UNION ALL
			SELECT 'Sending Location ' head,ISNULL((select districtName from api_districtList where districtCode=@sLocation),'All')
			UNION ALL
			SELECT 'Sending Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @sAgent),'All')
			UNION ALL
			SELECT 'Sending Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @rAgent),'All')
			UNION ALL
			SELECT 'Receiving Country ' head,ISNULL(@rCountry,'All')
			UNION ALL
			SELECT 'Receiving Zone ' head,ISNULL(@rZone,'All')
			UNION ALL
			SELECT 'Receiving District ' head,ISNULL(@rDistrict,'All')
			UNION ALL
			SELECT 'Receiving Location ' head,ISNULL((select districtName from api_districtList where districtCode=@rLocation),'All')
			UNION ALL
			SELECT 'Receiving Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @sAgent),'All')
			UNION ALL
			SELECT 'Receiving Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @rAgent),'All')

			SELECT 'PAID TRANSACTION REPORT DETAIL (INTERNATIONAL)' title

		
	END
	
	IF @flag='B'
	BEGIN
			select dbo.GetAgentNameFromId(isnull(pBranch,pBankBranch)) [Payout Agent]
			,count(*) [Total Count]
			,dbo.ShowDecimal(sum(pAmt)) [Payout Amount]
			from remitTran a with(nolock) 
			LEFT JOIN tranReceivers rec WITH(NOLOCK) ON a.id = rec.tranId
			LEFT JOIN tranSenders sen WITH(NOLOCK) ON a.id=sen.tranId
			--LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
			--LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
			--LEFT JOIN api_districtList D WITH(NOLOCK) ON D.ROWID=B.agentLocation
			--LEFT JOIN api_districtList E WITH(NOLOCK) ON E.ROWID=C.agentLocation
			
			where tranStatus='Paid'
			AND paidDate BETWEEN @fromDate AND @toDate 
			--AND sCountry<>'Nepal'					
			AND sCountry = ISNULL(@sCountry,sCountry)
			--AND isnull(B.agentState,'') =ISNULL(@sZone,isnull(B.agentState,''))
			--AND isnull(B.agentDistrict,'') =ISNULL(@sDistrict,isnull(B.agentDistrict,''))
			--AND isnull(B.agentLocation,'') =ISNULL(@sLocation,isnull(B.agentLocation,''))			
			AND isnull(sAgent,'') =  ISNULL(@sAgent,isnull(sAgent,''))
			AND isnull(sBranch,'') = ISNULL(@sBranch,isnull(sBranch,''))
			
			AND isnull(pCountry,'') = ISNULL(@rCountry,isnull(pCountry,''))
			--AND isnull(C.agentState,'') =ISNULL(@rZone,isnull(C.agentState,''))
			--AND isnull(C.agentDistrict,'') =ISNULL(@rDistrict,isnull(C.agentDistrict,''))
			--AND isnull(C.agentLocation,'') =ISNULL(@rLocation,isnull(C.agentLocation,''))			
			AND isnull(pAgent,'') =  ISNULL(@rAgent,isnull(pAgent,''))
			AND isnull(pBranch,'') = ISNULL(@rBranch,isnull(pBranch,''))	
			
			group by pBranch,pBankBranch
			
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	
			
			SELECT 'From Date ' head, CONVERT(VARCHAR, @fromDate, 101) value
			UNION ALL
			SELECT 'To Date ' head, CONVERT(VARCHAR, @toDate, 101) value
			UNION ALL
			SELECT 'Sending Country ' head,ISNULL(@sCountry,'All')
			UNION ALL
			SELECT 'Sending Zone ' head,ISNULL(@sZone,'All')
			UNION ALL
			SELECT 'Sending District ' head,ISNULL(@sDistrict,'All')
			UNION ALL
			SELECT 'Sending Location ' head,ISNULL((select districtName from api_districtList where districtCode=@sLocation),'All')
			UNION ALL
			SELECT 'Sending Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @sAgent),'All')
			UNION ALL
			SELECT 'Sending Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @rAgent),'All')
			UNION ALL
			SELECT 'Receiving Country ' head,ISNULL(@rCountry,'All')
			UNION ALL
			SELECT 'Receiving Zone ' head,ISNULL(@rZone,'All')
			UNION ALL
			SELECT 'Receiving District ' head,ISNULL(@rDistrict,'All')
			UNION ALL
			SELECT 'Receiving Location ' head,ISNULL((select districtName from api_districtList where districtCode=@rLocation),'All')
			UNION ALL
			SELECT 'Receiving Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @sAgent),'All')
			UNION ALL
			SELECT 'Receiving Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @rAgent),'All')

			SELECT 'PAID TRANSACTION REPORT SUMMARY (INTERNATIONAL)' title
	END
	
	IF @flag='C'
	BEGIN
			IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL 
			DROP TABLE #tempTable
			IF OBJECT_ID('tempdb..#tempTable1') IS NOT NULL 
			DROP TABLE #tempTable1	
			
			CREATE TABLE #tempTable
			(
				agentId int null,
				sendCount int null,
				sendAmount money null,			
				sendHOmargin money null,
				sendServiceCharge money null,
				sendAgentComm money null,
				sendSuperAgentComm money	null,	
				paidCount int null,
				paidAmount money null,			
				paidHOmargin money null,
				paidServiceCharge money null,
				paidAgentComm money null,
				paidSuperAgentComm money null
			)	
			CREATE TABLE #tempTable1
			(
				agentId int null,
				sendCount int null,
				sendAmount money null,			
				sendHOmargin money null,
				sendServiceCharge money null,
				sendAgentComm money null,
				sendSuperAgentComm money	null,	
				paidCount int null,
				paidAmount money null,			
				paidHOmargin money null,
				paidServiceCharge money null,
				paidAgentComm money null,
				paidSuperAgentComm money null
			)		
		
			insert into #tempTable(agentId,sendCount,sendAmount,sendHOmargin,sendServiceCharge,sendAgentComm,sendSuperAgentComm
			,paidCount,paidAmount,paidHOmargin,paidServiceCharge,paidAgentComm,paidSuperAgentComm)
			select sBranch,sendCount,sendAmount,sendHOMargin,sendServiceCharge,sendAgentComm,sendSuperAgentComm,
			paidCount,paidAmount,paidHOMargin,paidServiceCharge,paidAgentComm,paidSuperAgentComm
			from 
			(
				select sBranch
					,count(*) sendCount
					,SUM(cAmt) sendAmount
					,sum(isnull(serviceCharge,0)-isnull(sAgentComm,0)-isnull(sSuperAgentComm,0)-isnull(pAgentComm,0)-isnull(pSuperAgentComm,0)) sendHOMargin
					,sum(isnull(serviceCharge,0)) sendServiceCharge
					,sum(isnull(sAgentComm,0)) sendAgentComm
					,sum(isnull(sSuperAgentComm,0)) sendSuperAgentComm
				from remitTran a with(nolock)				
				LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
				LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
				LEFT JOIN api_districtList D WITH(NOLOCK) ON D.ROWID=B.agentLocation
				LEFT JOIN api_districtList E WITH(NOLOCK) ON E.ROWID=C.agentLocation
				
				where tranStatus='Paid'
				and paidDate between @fromDate and @toDate 
				AND sCountry<>'Nepal'	
				
				AND sCountry = ISNULL(@sCountry,sCountry)
				AND isnull(B.agentState,'') =ISNULL(@sZone,isnull(B.agentState,''))
				AND isnull(B.agentDistrict,'') =ISNULL(@sDistrict,isnull(B.agentDistrict,''))
				AND isnull(B.agentLocation,'') =ISNULL(@sLocation,isnull(B.agentLocation,''))			
				AND isnull(sAgent,'') =  ISNULL(@sAgent,isnull(sAgent,''))
				AND isnull(sBranch,'') = ISNULL(@sBranch,isnull(sBranch,''))
				
				AND isnull(pCountry,'') = ISNULL(@rCountry,isnull(pCountry,''))
				AND isnull(C.agentState,'') =ISNULL(@rZone,isnull(C.agentState,''))
				AND isnull(C.agentDistrict,'') =ISNULL(@rDistrict,isnull(C.agentDistrict,''))
				AND isnull(C.agentLocation,'') =ISNULL(@rLocation,isnull(C.agentLocation,''))			
				AND isnull(pAgent,'') =  ISNULL(@rAgent,isnull(pAgent,''))
				AND isnull(pBranch,'') = ISNULL(@rBranch,isnull(pBranch,''))	
				
				group by sBranch,pBankBranch
			)x
			inner join 
			(					
				select pBranch
					,count(*) paidCount
					,SUM(pAmt) paidAmount
					,sum(isnull(serviceCharge,0)-isnull(sAgentComm,0)-isnull(sSuperAgentComm,0)-isnull(pAgentComm,0)-isnull(pSuperAgentComm,0)) paidHOMargin
					,sum(isnull(serviceCharge,0)) paidServiceCharge
					,sum(isnull(pAgentComm,0)) paidAgentComm
					,sum(isnull(pSuperAgentComm,0)) paidSuperAgentComm
				from remitTran a with(nolock)
					LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
					LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
					LEFT JOIN api_districtList D WITH(NOLOCK) ON D.ROWID=B.agentLocation
					LEFT JOIN api_districtList E WITH(NOLOCK) ON E.ROWID=C.agentLocation
				where tranStatus='Paid'
				and paidDate between @fromDate and @toDate 
				AND sCountry<>'Nepal'	
				AND sCountry = ISNULL(@sCountry,sCountry)
				AND isnull(B.agentState,'') =ISNULL(@sZone,isnull(B.agentState,''))
				AND isnull(B.agentDistrict,'') =ISNULL(@sDistrict,isnull(B.agentDistrict,''))
				AND isnull(B.agentLocation,'') =ISNULL(@sLocation,isnull(B.agentLocation,''))			
				AND isnull(sAgent,'') =  ISNULL(@sAgent,isnull(sAgent,''))
				AND isnull(sBranch,'') = ISNULL(@sBranch,isnull(sBranch,''))
				
				AND isnull(pCountry,'') = ISNULL(@rCountry,isnull(pCountry,''))
				AND isnull(C.agentState,'') =ISNULL(@rZone,isnull(C.agentState,''))
				AND isnull(C.agentDistrict,'') =ISNULL(@rDistrict,isnull(C.agentDistrict,''))
				AND isnull(C.agentLocation,'') =ISNULL(@rLocation,isnull(C.agentLocation,''))			
				AND isnull(pAgent,'') =  ISNULL(@rAgent,isnull(pAgent,''))
				AND isnull(pBranch,'') = ISNULL(@rBranch,isnull(pBranch,''))	
				
				group by pBranch		
				
			)y on y.pBranch=x.sBranch 
			
			insert into #tempTable1(agentId,paidCount,paidAmount,paidHOmargin,paidServiceCharge,paidAgentComm,paidSuperAgentComm)
			select pBranch,paidCount,paidAmount,paidHOMargin,paidServiceCharge,paidAgentComm,paidSuperAgentComm
			from 
			(
				
				select pBranch
					,count(*) paidCount
					,SUM(pAmt) paidAmount
					,sum(isnull(serviceCharge,0)-isnull(sAgentComm,0)-isnull(sSuperAgentComm,0)-isnull(pAgentComm,0)-isnull(pSuperAgentComm,0)) paidHOMargin
					,sum(isnull(serviceCharge,0)) paidServiceCharge
					,sum(isnull(pAgentComm,0)) paidAgentComm
					,sum(isnull(pSuperAgentComm,0)) paidSuperAgentComm
				from remitTran a with(nolock)
					LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
					LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
					LEFT JOIN api_districtList D WITH(NOLOCK) ON D.ROWID=B.agentLocation
					LEFT JOIN api_districtList E WITH(NOLOCK) ON E.ROWID=C.agentLocation
				where tranStatus='Paid'
				and paidDate between @fromDate and @toDate
				AND sCountry<>'Nepal'	 
				AND sCountry = ISNULL(@sCountry,sCountry)
				AND isnull(B.agentState,'') =ISNULL(@sZone,isnull(B.agentState,''))
				AND isnull(B.agentDistrict,'') =ISNULL(@sDistrict,isnull(B.agentDistrict,''))
				AND isnull(B.agentLocation,'') =ISNULL(@sLocation,isnull(B.agentLocation,''))			
				AND isnull(sAgent,'') =  ISNULL(@sAgent,isnull(sAgent,''))
				AND isnull(sBranch,'') = ISNULL(@sBranch,isnull(sBranch,''))
				
				AND isnull(pCountry,'') = ISNULL(@rCountry,isnull(pCountry,''))
				AND isnull(C.agentState,'') =ISNULL(@rZone,isnull(C.agentState,''))
				AND isnull(C.agentDistrict,'') =ISNULL(@rDistrict,isnull(C.agentDistrict,''))
				AND isnull(C.agentLocation,'') =ISNULL(@rLocation,isnull(C.agentLocation,''))			
				AND isnull(pAgent,'') =  ISNULL(@rAgent,isnull(pAgent,''))
				AND isnull(pBranch,'') = ISNULL(@rBranch,isnull(pBranch,''))	
				group by pBranch	
						
			)b 			
			
			DELETE FROM #tempTable1 						
			FROM #tempTable1 t
			INNER JOIN #tempTable ds ON t.agentId = ds.agentId
			
			insert into #tempTable 
			select * from #tempTable1			
			
			delete from #tempTable1
			
			insert into #tempTable1(agentId,sendCount,sendAmount,sendHOmargin,sendServiceCharge,sendAgentComm,sendSuperAgentComm)
			select sBranch,sendCount,sendAmount,sendHOMargin,sendServiceCharge,sendAgentComm,sendSuperAgentComm
			from 
			(
				select sBranch
					,count(*) sendCount
					,SUM(cAmt) sendAmount
					,sum(isnull(serviceCharge,0)-isnull(sAgentComm,0)-isnull(sSuperAgentComm,0)-isnull(pAgentComm,0)-isnull(pSuperAgentComm,0)) sendHOMargin
					,sum(isnull(serviceCharge,0)) sendServiceCharge
					,sum(isnull(sAgentComm,0)) sendAgentComm
					,sum(isnull(sSuperAgentComm,0)) sendSuperAgentComm
				from remitTran a with(nolock)
					LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
					LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
					LEFT JOIN api_districtList D WITH(NOLOCK) ON D.ROWID=B.agentLocation
					LEFT JOIN api_districtList E WITH(NOLOCK) ON E.ROWID=C.agentLocation
				where tranStatus='Paid'
				AND sCountry<>'Nepal'	
				and paidDate between @fromDate and @toDate 
				AND sCountry = ISNULL(@sCountry,sCountry)
				AND isnull(B.agentState,'') =ISNULL(@sZone,isnull(B.agentState,''))
				AND isnull(B.agentDistrict,'') =ISNULL(@sDistrict,isnull(B.agentDistrict,''))
				AND isnull(B.agentLocation,'') =ISNULL(@sLocation,isnull(B.agentLocation,''))			
				AND isnull(sAgent,'') =  ISNULL(@sAgent,isnull(sAgent,''))
				AND isnull(sBranch,'') = ISNULL(@sBranch,isnull(sBranch,''))
				
				AND isnull(pCountry,'') = ISNULL(@rCountry,isnull(pCountry,''))
				AND isnull(C.agentState,'') =ISNULL(@rZone,isnull(C.agentState,''))
				AND isnull(C.agentDistrict,'') =ISNULL(@rDistrict,isnull(C.agentDistrict,''))
				AND isnull(C.agentLocation,'') =ISNULL(@rLocation,isnull(C.agentLocation,''))			
				AND isnull(pAgent,'') =  ISNULL(@rAgent,isnull(pAgent,''))
				AND isnull(pBranch,'') = ISNULL(@rBranch,isnull(pBranch,''))	
				group by sBranch			
			)b 
			
			DELETE FROM #tempTable1 						
			FROM #tempTable1 t
			INNER JOIN #tempTable ds ON t.agentId = ds.agentId
	
			insert into #tempTable 
			select * from #tempTable1
			
			select 
					 b.agentName [Agent Name]
					,isnull(sendCount,0) [#Send Count]
					,ISNULL(paidCount,0) [#Paid Count]
					,ISNULL(sendAmount,0) [Send Amount]
					,ISNULL(paidAmount,0) [Paid Amount]
					,ISNULL(sendAmount,0)-ISNULL(paidAmount,0) [Net Sattlement Amount]					
					,ISNULL(sendAgentComm,0) [SC]
					,ISNULL(paidAgentComm,0) [RC]
					,ISNULL(sendAgentComm,0)+ISNULL(paidAgentComm,0) [Total Margin]
					,isnull(sendHOmargin,0)+ISNULL(paidHOmargin,0) [HO Margin]
			
			from #tempTable a with(nolock) inner join agentMaster b with(nolock) on a.agentId=b.agentId
			order by b.agentName				

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	
			
			SELECT 'From Date ' head, CONVERT(VARCHAR, @fromDate, 101) value
			UNION ALL
			SELECT 'To Date ' head, CONVERT(VARCHAR, @toDate, 101) value
			UNION ALL
			SELECT 'Sending Country ' head,ISNULL(@sCountry,'All')
			UNION ALL
			SELECT 'Sending Zone ' head,ISNULL(@sZone,'All')
			UNION ALL
			SELECT 'Sending District ' head,ISNULL(@sDistrict,'All')
			UNION ALL
			SELECT 'Sending Location ' head,ISNULL((select districtName from api_districtList where districtCode=@sLocation),'All')
			UNION ALL
			SELECT 'Sending Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @sAgent),'All')
			UNION ALL
			SELECT 'Sending Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @rAgent),'All')
			UNION ALL
			SELECT 'Receiving Country ' head,ISNULL(@rCountry,'All')
			UNION ALL
			SELECT 'Receiving Zone ' head,ISNULL(@rZone,'All')
			UNION ALL
			SELECT 'Receiving District ' head,ISNULL(@rDistrict,'All')
			UNION ALL
			SELECT 'Receiving Location ' head,ISNULL((select districtName from api_districtList where districtCode=@rLocation),'All')
			UNION ALL
			SELECT 'Receiving Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @sAgent),'All')
			UNION ALL
			SELECT 'Receiving Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @rAgent),'All')

			SELECT 'PAID TRANSACTION REPORT SUMMARY WITH COMMISSION (INTERNATIONAL)' title
	END
GO