

ALTER proc [dbo].[spa_branchstatement]
	@flag varchar(10),
	@acnum varchar(20),
	@startDate varchar(20),
	@endDate varchar(20),
	@company_id varchar(20)=null,
	@Currency varchar(3)=null,
	@gl_code varchar(20)=null,
	@user varchar(20) = null
AS

set nocount on;

if @flag='a-new'
begin

	Declare @sql varchar(6000)

	set @endDate=@endDate +' 23:59:59'
	set @sql=''

	set @acnum = '111004028'

	SELECT '' tran_date,'Balance Brought Forward' tran_particular, acc_num,@currency fcy_Curr
		, tran_amt= ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,usd_amt = ISNULL(SUM(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
		,'' tran_type,'' ref_num
		,part_tran_type =case when SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) >0 then 'cr' else 'dr' end
		,'' dt
	FROM tran_master(NOLOCK) 
	WHERE tran_date < @startDate and acc_num = @acnum
	and isnull(fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	group by acc_num
	UNION ALL
	SELECT convert(varchar,tran_date,102) tran_date,tran_particular,acc_num,fcy_Curr
		, tran_amt= ISNULL((case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,usd_amt = ISNULL((case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
		,t.tran_type,t.ref_num,t.part_tran_type
		,created_date as dt
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	ORDER BY tran_date,part_tran_type desc
end

if @flag='a'
begin

	set @endDate=@endDate +' 23:59:59'
	set @sql=''


	SELECT '' tran_date,'Balance Brought Forward' tran_particular, acc_num,@currency fcy_Curr
		, tran_amt= ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,usd_amt = ISNULL(SUM(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
		,'' tran_type,'' ref_num
		,part_tran_type =case when SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) >0 then 'cr' else 'dr' end
		,'' dt
	FROM tran_master(NOLOCK) 
	WHERE tran_date < @startDate and acc_num = @acnum
	and isnull(fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	group by acc_num
	UNION ALL
	SELECT convert(varchar,tran_date,102) tran_date,tran_particular,acc_num,fcy_Curr
		, tran_amt= ISNULL((case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,usd_amt = ISNULL((case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
		,t.tran_type,t.ref_num,t.part_tran_type
		,created_date as dt
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	ORDER BY tran_date,part_tran_type desc
end
else if @flag='a-agent'
begin
	set @endDate=@endDate +' 23:59:59'
	set @sql=''


	SELECT '' tran_date,'Balance Brought Forward' tran_particular, acc_num,@currency fcy_Curr
		, tran_amt= ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,usd_amt = ISNULL(SUM(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
		,'' tran_type,'' ref_num
		,part_tran_type =case when SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) >0 then 'cr' else 'dr' end
		,'' dt
	FROM tran_master(NOLOCK) 
	WHERE tran_date < @startDate and acc_num = @acnum
	and isnull(fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	group by acc_num
	UNION ALL
	SELECT convert(varchar,tran_date,102) tran_date,tran_particular,acc_num,fcy_Curr
		, tran_amt= ISNULL((case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,usd_amt = ISNULL((case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
		,t.tran_type,t.ref_num,t.part_tran_type
		,created_date as dt
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	ORDER BY tran_date
end

ELSE if @flag='l'
begin


 select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,tran_rmks,DRTotal,
	cRTotal,end_clr_balance,
	cast(ref_num as float) as ref_num, 
	TD,tran_type from ( select 1 as tran_id, 
	acc_num,'' TRNDate, 'Balance Brought Forward' tran_rmks, 0 DRTotal,0 cRTotal, 
	isnull(end_clr_balance,0) end_clr_balance, '0.0' ref_num, '' TD,'' tran_type
	from (

		select  2 as tran_id, acc_num, 
			sum (case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) end_clr_balance
		from tran_master  WITH (NOLOCK) 
		where 1=1
		--and acc_num='101017129' 
		and tran_date < '1/12/2012'
		group by acc_num
		) ca	 
		union all 
		select  tran_id , acc_num,tran_date as TRNDate,isnull(tran_particular,'')+' ' +isnull(tran_rmks,'') as tran_rmks ,
			case when part_tran_type='dr' then tran_amt else 0 end as DRTotal,
			case when part_tran_type='cr' then tran_amt else 0 end as cRTotal,
			0 Balance, t.ref_num, tran_date as TD,t.tran_type
		from tran_master t WITH (NOLOCK), tran_masterDetail d with (nolock)
		where t.ref_num=d.ref_num and t.tran_type=d.tran_type 
			--and acc_num='101017129' 
			and tran_date between '1/12/2012' and '1/12/2012 23:59:59' 
		
	) 
	a order by td, cast(ref_num as float) 



end

ELSE if @flag='g'
begin

	set @endDate=@endDate +' 23:59:59'
	set @sql=''

	set @sql=@sql +' select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,tran_rmks,DRTotal,
	cRTotal,end_clr_balance,cast(ref_num as float) as ref_num, TD,tran_type from ( '

	
	set @sql= @sql + 'select 1 as tran_id, acc_num,'''' TRNDate, ''Balance Brought Forward'' tran_rmks, 0 DRTotal,0 cRTotal, 
	isnull(end_clr_balance,0) end_clr_balance, ''0.0'' ref_num, '''' TD,'''' tran_type
	from (

	select  2 as tran_id, acc_num, 
		sum (case when part_tran_type=''dr'' then tran_amt*-1 else tran_amt end) end_clr_balance
	from CustomerInfo  WITH (NOLOCK) where acc_num='''+@acnum +''' and
	tran_date < '''+ @startDate+'''
	group by acc_num
	) ca	 
	union all'

	
	--print @sql
	--return

	set @sql=@sql +' 
	select  tran_id , acc_num,tran_date as TRNDate,isnull(tran_particular,'''')+'' '' +isnull(tran_rmks,'''') as tran_rmks ,
		case when part_tran_type=''dr'' then tran_amt else 0 end as DRTotal,
		case when part_tran_type=''cr'' then tran_amt else 0 end as cRTotal,
		0 Balance, t.ref_num, tran_date as TD,t.tran_type
	from CustomerInfo t WITH (NOLOCK), CustomerInfoDetail d with (nolock)
	where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id 
		and acc_num='''+@acnum +''' 
		and t.company_id='+@company_id +' 
		and tran_date between '''+@startDate +''' and '''+@endDate +''' 
	
	) 
	a order by td, cast(ref_num as float) '
	
	--print(@sql)
	execute(@sql)

	--select * from CustomerInfo
	--select * from CustomerInfoDetail
	
end

ELSE if @flag='s' ---- Statement for customer
begin


	set @endDate=@endDate +' 23:59:59'
	set @sql=''

	set @sql=@sql +' select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,tran_rmks,DRTotal,
	cRTotal,end_clr_balance,cast(ref_num as float) as ref_num, TD,tran_type,field1,field2 from ( '

	
	set @sql= @sql + 'select 1 as tran_id, acc_num,'''' TRNDate, ''Balance Brought Forward'' tran_rmks, 0 DRTotal,0 cRTotal, 
	isnull(end_clr_balance,0) end_clr_balance, ''0.0'' ref_num, '''' TD,'''' tran_type,'''' field1,'''' field2
	from (

	select  2 as tran_id, acc_num, 
		sum (case when part_tran_type=''dr'' then tran_amt*-1 else tran_amt end) end_clr_balance
	from tran_master  WITH (NOLOCK) where acc_num='''+ @acnum +''' and
	tran_date < '''+ @startDate +'''
	group by acc_num
	) ca	 
	union all'

	
	--print @sql
	--return

	set @sql=@sql +' 
	select  tran_id , acc_num,tran_date as TRNDate,isnull(tran_particular,'''')+'' '' +isnull(tran_rmks,'''') as tran_rmks ,
		case when part_tran_type=''dr'' then tran_amt else 0 end as DRTotal,
		case when part_tran_type=''cr'' then tran_amt else 0 end as cRTotal,
		0 Balance, t.ref_num, tran_date as TD,t.tran_type,t.field1,t.field2
	from tran_master t WITH (NOLOCK), tran_masterDetail d with (nolock)
	where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id 
		and acc_num='''+ @acnum +''' 
		and t.company_id='+ @company_id +' 
		and tran_date between '''+ @startDate +''' and '''+ @endDate +''' 
	
	) 
	a order by td, cast(ref_num as float) '
	
	--print(@sql)
	execute(@sql)

	
end

ELSE if @flag='D'
begin

	set @endDate = @endDate +' 23:59:59'
	set @sql=''

	SELECT '' tran_date,'Balance Brought Forward' tran_particular, acc_num,@currency fcy_Curr
		,tran_amt= SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end)
		,usd_amt = ISNULL(SUM(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
	FROM tran_master(NOLOCK) 
	WHERE tran_date < @startDate and acc_num = @acnum
	and isnull(fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	group by acc_num
	
	UNION ALL

	SELECT convert(varchar,tran_date,102) tran_date,'Send Remittance Transaction',acc_num,fcy_Curr
		, tran_amt= sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end)
		,usd_amt = ISNULL(sum(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and t.tran_type = 'j'
	and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	--and entry_user_id='system'
	AND FIELD2 = 'REMITTANCE VOUCHER'
	AND ACCT_TYPE_CODE IS NULL
	GROUP BY convert(varchar,tran_date,102),acc_num,fcy_Curr

	UNION ALL

	SELECT convert(varchar,tran_date,102) tran_date,'Cancel Remittance Transaction',acc_num,fcy_Curr
		, tran_amt= sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end)
		,usd_amt = ISNULL(sum(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and t.tran_type = 'j'
	and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	--and entry_user_id='system'
	AND FIELD2 = 'REMITTANCE VOUCHER'
	AND ACCT_TYPE_CODE IS NOT NULL
	GROUP BY convert(varchar,tran_date,102),acc_num,fcy_Curr

	UNION ALL

	SELECT convert(varchar,tran_date,102) tran_date,'Transit Cash Settled',acc_num,fcy_Curr
		, tran_amt= sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end)
		,usd_amt = ISNULL(sum(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and t.tran_type = 'j'
	and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	--and entry_user_id='system'
	AND FIELD2 = 'Transit Cash Settle'
	GROUP BY convert(varchar,tran_date,102),acc_num,fcy_Curr

	UNION ALL

	SELECT convert(varchar,tran_date,102) tran_date,'Vault Transfer By Teller''s',acc_num,fcy_Curr
		, tran_amt= sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end)
		,usd_amt = ISNULL(sum(case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0)
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum and t.tran_type = 'j'
	and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	--and entry_user_id='system'
	AND FIELD2 = 'Vault Transfer'
	GROUP BY convert(varchar,tran_date,102),acc_num,fcy_Curr

	UNION ALL
	SELECT convert(varchar,tran_date,102) tran_date,D.tran_particular,acc_num,fcy_Curr
		, tran_amt= SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end)
		,usd_amt = SUM(ISNULL((case when part_tran_type='dr' then usd_amt*-1 else usd_amt end),0))
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @startDate AND @endDate
	and acc_num = @acnum --and t.tran_type = 'j'
	and isnull(t.fcy_Curr,'JPY') = ISNULL(@currency,isnull(fcy_Curr,'JPY'))
	--and ISNULL(entry_user_id,'') <> 'system'
	AND ISNULL(FIELD2, '') NOT IN ('REMITTANCE VOUCHER', 'Transit Cash Settle', 'Vault Transfer')
	GROUP BY convert(varchar,tran_date,102),D.tran_particular,acc_num,fcy_Curr
	ORDER BY tran_date
end

--select * from tran_master where ref_num='187251'


