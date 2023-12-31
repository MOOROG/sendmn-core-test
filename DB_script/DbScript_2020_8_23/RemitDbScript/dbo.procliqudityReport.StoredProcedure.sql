USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procliqudityReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec procliqudityReport '8/24/2011'
-- Exec balancesheetDrilldown2 '1' , '20','8/24/2011',Null 

CREATE proc  [dbo].[procliqudityReport] 
	@date varchar(20)
as
begin

set nocount on;

	Create table #temp_liqudity
	(
		acct_name varchar(500),
		acct_num varchar(20),
		Total money,
		TREE_SAPE varchar(20),
		DR money,
		CR money,
		FLG varchar(2) null
	)
	

-- ############ Liquid Assets :
	-- Sundry Debtors
	insert into #temp_liqudity (acct_name,acct_num,TREE_SAPE, Total,DR,CR)
	Exec balancesheetDrilldown2 '1' , '20',@date,Null 

-- Bacnk Cash, Bank Balances (Dr. Balance only)
	insert into #temp_liqudity (acct_name,acct_num,TREE_SAPE, Total,DR,CR)
	Exec balancesheetDrilldown2 '1' , '21',@date,Null

-- Payable to Receiving Agents (Dr. Balance only)

	insert into #temp_liqudity (acct_name,acct_num, Total,TREE_SAPE,DR,CR)
	Exec balancesheetDrilldown2 '2' , '94',@date,Null,'0024.05',Null


--###########Liquid Liability :
	
	-- Payable to Customers
	insert into #temp_liqudity (acct_name,acct_num, Total,TREE_SAPE,DR,CR)
	Exec balancesheetDrilldown2 '2' , '102',@date,Null,'0024.05.03.01',Null 

	-- Remittance Payable - Domestic
	insert into #temp_liqudity (acct_name,acct_num, Total,TREE_SAPE,DR,CR)
	Exec balancesheetDrilldown2 '2' , '97',@date,Null,'0024.05.03',Null 
	
	-- select * from LiquidityFormat
	
	--select l.acct_name, t.acct_num, 
	--		case when l.type='N' then  t.Total
	--			when l.type='Dr' then DR
	--			else CR
	--			end as AMT,
	--	    t.TREE_SAPE , l.flag
	--from #temp_liqudity t, LiquidityFormat l
	--where t.acct_num=l.ac_code
	--order by l.rowid
	
	select l.acct_name, t.acct_num, 
		case when l.flag='a' then -1 *(	case when l.type='N' then  t.Total
				when l.type='Dr' then DR
				else CR
				end ) else (	case when l.type='N' then  t.Total
				when l.type='Dr' then DR
				else CR
				end ) end as amt ,
		    t.TREE_SAPE , l.flag
	from #temp_liqudity t, LiquidityFormat l
	where t.acct_num=l.ac_code
	order by l.rowid
	
  drop table #temp_liqudity
	
end






GO
