USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_slabwiseRpt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_slabwiseRpt]
(  
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
			basedOn,
			ReportType = flag,
			sum([0-10000]) [0-10000], 
			sum([10001-25000]) [10001-25000], 
			sum([25001-50000]) [25001-50000], 
			sum([50001-100000]) [50001-100000], 
			sum([100001-200000]) [100001-200000], 
			sum([200001-300000]) [200001-300000],
			sum([Above 300000]) [Above 300000]
		into #temp
		from 
		(
				SELECT  
					'tAmt' basedOn,
					'ak' flag,
					case when tAmt BETWEEN '0' AND '10000' then count('x') else '0' end '0-10000' ,
					case when tAmt BETWEEN '10001' AND '25000' then count('x') else '0' end '10001-25000' ,
					case when tAmt BETWEEN '25001' AND '50000' then count('x') else '0' end '25001-50000' ,
					case when tAmt BETWEEN '50001' AND '100000' then count('x') else '0' end '50001-100000' ,
					case when tAmt BETWEEN '100001' AND '200000' then count('x') else '0' end '100001-200000' ,
					case when tAmt BETWEEN '200001' AND '300000' then count('x') else '0' end '200001-300000' ,
					case when tAmt > 300000 then count('x') else '0' end 'Above 300000'  
				FROM remitTran rt with(nolock)
				WHERE pLocation in (177,137,225) 
				AND tranType = 'D'
				AND createddate between @fromDate and @toDate
				group by tAmt

				UNION ALL

				SELECT  
					'tAmt' basedOn,
					'Ka' flag,
					case when tAmt BETWEEN '0' AND '10000' then count('x') else '0' end '0-10000' ,
					case when tAmt BETWEEN '10001' AND '25000' then count('x') else '0' end '10001-25000' ,
					case when tAmt BETWEEN '25001' AND '50000' then count('x') else '0' end '25001-50000' ,
					case when tAmt BETWEEN '50001' AND '100000' then count('x') else '0' end '50001-100000' ,
					case when tAmt BETWEEN '100001' AND '200000' then count('x') else '0' end '100001-200000' ,
					case when tAmt BETWEEN '200001' AND '300000' then count('x') else '0' end '200001-300000' ,
					case when tAmt > 300000 then count('x') else '0' end 'Above 300000'  
				FROM remitTran rt with(nolock)
				inner join agentMaster am with(nolock) on rt.sBranch = am.agentId
				where am.agentLocation in (177,137,225)
				AND tranType = 'D'
				AND rt.createddate between @fromDate and @toDate
				group by tAmt

				UNION ALL

				SELECT  
					'tAmt' basedOn,
					'aa' flag,
					case when tAmt BETWEEN '0' AND '10000' then count('x') else '0' end '0-10000' ,
					case when tAmt BETWEEN '10001' AND '25000' then count('x') else '0' end '10001-25000' ,
					case when tAmt BETWEEN '25001' AND '50000' then count('x') else '0' end '25001-50000' ,
					case when tAmt BETWEEN '50001' AND '100000' then count('x') else '0' end '50001-100000' ,
					case when tAmt BETWEEN '100001' AND '200000' then count('x') else '0' end '100001-200000' ,
					case when tAmt BETWEEN '200001' AND '300000' then count('x') else '0' end '200001-300000' ,
					case when tAmt > 300000 then count('x') else '0' end 'Above 300000'  
				FROM remitTran rt with(nolock)
				inner join agentMaster am with(nolock) on rt.sBranch = am.agentId
					where am.agentLocation not in (177,137,225) 
					and rt.pLocation not in (177,137,225)		
					AND tranType = 'D'
					AND rt.createddate between @fromDate and @toDate
				group by tAmt

				union all

				--cAmt basis

				SELECT  
					'cAmt' basedOn,
					'ak' flag,
					case when cAmt BETWEEN '0' AND '10000' then count('x') else '0' end '0-10000' ,
					case when cAmt BETWEEN '10001' AND '25000' then count('x') else '0' end '10001-25000' ,
					case when cAmt BETWEEN '25001' AND '50000' then count('x') else '0' end '25001-50000' ,
					case when cAmt BETWEEN '50001' AND '100000' then count('x') else '0' end '50001-100000' ,
					case when cAmt BETWEEN '100001' AND '200000' then count('x') else '0' end '100001-200000' ,
					case when cAmt BETWEEN '200001' AND '300000' then count('x') else '0' end '200001-300000' ,
					case when cAmt > 300000 then count('x') else '0' end 'Above 300000'  
				FROM remitTran rt with(nolock)
				WHERE pLocation in (177,137,225) 
				AND tranType = 'D'
				AND createddate between @fromDate and @toDate 
				group by cAmt

				UNION ALL

				SELECT  
					'cAmt' basedOn,
					'Ka' flag,
					case when cAmt BETWEEN '0' AND '10000' then count('x') else '0' end '0-10000' ,
					case when cAmt BETWEEN '10001' AND '25000' then count('x') else '0' end '10001-25000' ,
					case when cAmt BETWEEN '25001' AND '50000' then count('x') else '0' end '25001-50000' ,
					case when cAmt BETWEEN '50001' AND '100000' then count('x') else '0' end '50001-100000' ,
					case when cAmt BETWEEN '100001' AND '200000' then count('x') else '0' end '100001-200000' ,
					case when cAmt BETWEEN '200001' AND '300000' then count('x') else '0' end '200001-300000' ,
					case when cAmt > 300000 then count('x') else '0' end 'Above 300000'  
				FROM remitTran rt with(nolock)
				inner join agentMaster am with(nolock) on rt.sBranch = am.agentId
				where am.agentLocation in (177,137,225)
				AND tranType = 'D'
				AND rt.createddate between @fromDate and @toDate
				group by cAmt

				UNION ALL

				SELECT  
					'cAmt' basedOn,
					'aa' flag,
					case when cAmt BETWEEN '0' AND '10000' then count('x') else '0' end '0-10000' ,
					case when cAmt BETWEEN '10001' AND '25000' then count('x') else '0' end '10001-25000' ,
					case when cAmt BETWEEN '25001' AND '50000' then count('x') else '0' end '25001-50000' ,
					case when cAmt BETWEEN '50001' AND '100000' then count('x') else '0' end '50001-100000' ,
					case when cAmt BETWEEN '100001' AND '200000' then count('x') else '0' end '100001-200000' ,
					case when cAmt BETWEEN '200001' AND '300000' then count('x') else '0' end '200001-300000' ,
					case when cAmt > 300000 then count('x') else '0' end 'Above 300000'  
				FROM remitTran rt with(nolock)
				inner join agentMaster am with(nolock) on rt.sBranch = am.agentId
					where am.agentLocation not in (177,137,225) 
					and rt.pLocation not in (177,137,225)		
					AND tranType = 'D'
					AND rt.createddate between @fromDate and @toDate
				group by cAmt

		)a group by basedOn,flag

		SELECT
			[Count Based On]= [Based On],
			[Count Type] = [Report Type],
			Slab,
			[Transaction Count] = Orders 
		INTO #result
		FROM 
		   (
			SELECT  
					case when basedOn ='tAmt' then 'Transaction Amount' 
						when basedOn = 'cAmt' then 'Collection Amount' end [Based On],
					case when ReportType ='ak' then 'Agent To Kathmandu' 
						when ReportType = 'ka' then 'Kathmandu To Agent'
						when ReportType = 'aa' then 'Agent To Agent' end [Report Type],
					[0-10000], [10001-25000], [25001-50000], [50001-100000], [100001-200000], [200001-300000],[Above 300000]
			FROM #temp) p 
		UNPIVOT
		   (Orders FOR Slab IN 
			  ([0-10000], [10001-25000], [25001-50000], [50001-100000], [100001-200000], [200001-300000],[Above 300000])
		)AS unpvt;

		select * from #result order by [Count Based On],[Count Type]
		drop table #temp
		drop table #result
		
		SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id   
		SELECT 'Date Range' head,@fromDate+'-'+@toDate VALUE    
		SELECT 'Slab Wise Report' title   
END  


GO
