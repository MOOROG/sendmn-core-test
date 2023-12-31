USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ReconcileReport]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Proc_ReconcileReport]
	@flag char(1),
	@date varchar(20),
	@date2 varchar(20)

as

SET NOCOUNT ON;
begin

	----set @date2 = cast( YEAR(@date2) as varchar) +'/'+ 
	----	cast(MONTH(@date2) as varchar) +'/'+ cast(DAY(@date2) as varchar) 
	----	+' 23:59:59'

select 
	agent_name as [AGENT NAME],
	--S_AGENT , 
	c.curr_name as Country,
	CASE WHEN S_AGENT ='21295' THEN 0 ELSE isnull(sum(UNPAID_TOTAL_TRN),0) END [Unpaid Opening_TRN] ,
	CASE WHEN S_AGENT ='21295' THEN 0 ELSE isnull(sum(UNPAID_NPR_AMT),0) END [Unpaid Opening_NPR AMT], 
	isnull(sum(SEND_TRN),0) [Send Transaction_TRN],
	isnull(sum(SEND_AMT),0) [Send Transaction_NPR AMT],
	isnull(sum(PAID_TRN),0) [Paid Transaction_TRN],
	isnull(sum(PAID_AMT),0) [Paid Transaction_NPR AMT],
	isnull(sum(CANCEL_TRN),0) [Cancel Transaction_TRN],
	isnull(sum(CANCEL_AMT),0) [Cancel Transaction_NPR AMT],
	sum(CASE WHEN S_AGENT ='21295' THEN 0 ELSE isnull(UNPAID_TOTAL_TRN,0) end+isnull(SEND_TRN,0)
		 - (isnull(PAID_TRN,0)+isnull(CANCEL_TRN,0))) [Closing Un-paid_TRN],
	sum(CASE WHEN S_AGENT ='21295' THEN 0 ELSE isnull(UNPAID_NPR_AMT,0) end +isnull(SEND_AMT,0) 
		- (isnull(PAID_AMT,0)+isnull(CANCEL_AMT,0))) [Closing Un-paid_NPR AMT]
from (
		SELECT S_AGENT,SUM(UNPAID_TOTAL_TRN) UNPAID_TOTAL_TRN,SUM(UNPAID_NPR_AMT) UNPAID_NPR_AMT
		, 0 SEND_TRN,0 SEND_AMT,0 PAID_TRN,0 PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		 FROM (
			SELECT 
			S_AGENT = CASE when TRN_DATE  >= '2015-6-18' AND S_AGENT IN ('10100000','33300082')  then '21295' ELSE S_AGENT END
			, 1 UNPAID_TOTAL_TRN ,(P_AMT)as  UNPAID_NPR_AMT
			from remit_trn_master r with (nolock)
			where (TRN_DATE < @date 
			  and PAY_STATUS ='Paid' and PAID_DATE > @date )
			 OR
			  (
			  TRN_DATE < @date  
			  and PAY_STATUS ='Un-Paid' and TRN_STATUS <>'Cancel'
			  )
			  OR
			  (
			  TRN_DATE < @date  
			  and TRN_STATUS ='Cancel' and CANCEL_DATE > @date 
			  )
		)X GROUP BY S_AGENT

		union all 

		--SEND 
		SELECT 
		S_AGENT 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT
		,SEND_TRN = COUNT(*),sum(P_AMT) SEND_AMT
		,0 PAID_TRN,0 PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		from remit_trn_master r with (nolock)
		where TRN_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT NOT IN ('10100000','33300082')
		group by S_AGENT

		UNION ALL
		--SEND 
		SELECT 
		S_AGENT 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT
		,SEND_TRN = COUNT(*),sum(P_AMT) SEND_AMT
		,0 PAID_TRN,0 PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		from remit_trn_master r with (nolock)
		where TRN_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT IN ('10100000','33300082')
		AND TRN_DATE < '2015-6-18'
		group by S_AGENT

		UNION ALL
		--SEND 
		SELECT 
		S_AGENT ='21295' 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT
		,SEND_TRN = COUNT(*),sum(P_AMT) SEND_AMT
		,0 PAID_TRN,0 PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		from remit_trn_master r with (nolock)
		where PAID_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT IN ('10100000','33300082')
		AND TRN_DATE >= '2015-6-18'
		group by S_AGENT

		union all 

		--------------------------
		--PAID 
		SELECT 
		S_AGENT 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT
		,0 SEND_TRN ,0 SEND_AMT
		,COUNT(*) PAID_TRN,sum(P_AMT)PAID_AMT
		,0 CANCEL_TRN,0 CANCEL_AMT
		from remit_trn_master r with (nolock)
		where PAID_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT NOT IN ('10100000','33300082')
		group by S_AGENT

		UNION ALL
		--PAID 
		SELECT 
		S_AGENT 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT
		,0 SEND_TRN ,0 SEND_AMT
		,COUNT(*) PAID_TRN,sum(P_AMT)PAID_AMT
		,0 CANCEL_TRN,0 CANCEL_AMT
		from remit_trn_master r with (nolock)
		where PAID_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT IN ('10100000','33300082')
		AND TRN_DATE < '2015-6-18'
		group by S_AGENT

		UNION ALL
		--PAID 
		SELECT 
		S_AGENT ='21295' 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT
		,0 SEND_TRN ,0 SEND_AMT
		,COUNT(*) PAID_TRN,sum(P_AMT)PAID_AMT
		,0 CANCEL_TRN,0 CANCEL_AMT
		from remit_trn_master r with (nolock)
		where PAID_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT IN ('10100000','33300082')
		AND TRN_DATE >= '2015-6-18'
		group by S_AGENT

		union all 

		----------------------------

		--CANCEL 
		SELECT 
		S_AGENT
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT, 0 SEND_TRN,0 SEND_AMT,0 PAID_TRN,0 PAID_AMT
		,COUNT(*) CANCEL_TRN,sum(P_AMT) CANCEL_AMT
		from remit_trn_master r with (nolock)
		where CANCEL_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT NOT IN ('10100000','33300082') 
		group by S_AGENT

		UNION ALL 

		--CANCEL 
		SELECT 
		S_AGENT 
		,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT, 0 SEND_TRN,0 SEND_AMT,0 PAID_TRN,0 PAID_AMT
		,COUNT(*) CANCEL_TRN,sum(P_AMT) CANCEL_AMT
		from remit_trn_master r with (nolock)
		where CANCEL_DATE  between @date  and @date2 +' 23:59:59'
		AND S_AGENT IN ('10100000','33300082') 
		AND TRN_DATE < '2015-6-18' 
		group by S_AGENT
		
) r , 
agentTable a with (nolock), currency_setup c with (nolock)
where r.S_AGENT =a.map_code and c.rowid=a.agent_address
group by r.S_AGENT,c.curr_name,a.agent_name
--order by curr_name

union all

SELECT 
	'Domestic Txn ' as AGENT_NAME,
	--'Domestic' as S_AGENT, 
	'Nepal' as curr_name,
	sum(UNPAID_TOTAL_TRN) UNPAID_TOTAL_TRN,
	sum(UNPAID_NPR_AMT) UNPAID_NPR_AMT, 
	sum(SEND_TRN) SEND_TRN,
	sum(SEND_AMT) SEND_AMT,
	sum(PAID_TRN) PAID_TRN,
	sum(PAID_AMT) PAID_AMT,
	sum(CANCEL_TRN) CANCEL_TRN,
	sum(CANCEL_AMT) CANCEL_AMT,
	sum(UNPAID_TOTAL_TRN+SEND_TRN - (PAID_TRN+CANCEL_TRN)) CLOSING_UNPAID_TRN,
	sum(UNPAID_NPR_AMT+SEND_AMT - (PAID_AMT+CANCEL_AMT)) CLOSING_UNPAID_AMT
FROM (
		
		SELECT 
			S_AGENT, COUNT(*) UNPAID_TOTAL_TRN ,
			SUM( CASE WHEN CONFIRM_DATE<'2009-10-11' THEN P_AMT+R_SC ELSE P_AMT END )AS  UNPAID_NPR_AMT, 0 SEND_TRN,
			0 SEND_AMT,0 PAID_TRN,0 PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		from REMIT_TRN_LOCAL r with (nolock)
		where 
		----(CONFIRM_DATE <= '2009-10-18 23:59'
		----and PAY_STATUS ='Paid' and P_DATE >= @date)
		----OR
		----(CONFIRM_DATE between '2009-10-19' and @date
		----and PAY_STATUS ='Paid' and P_DATE >= @date)
		----OR
		----(CONFIRM_DATE between '2009-10-19' and @date 
		----and PAY_STATUS ='Un-Paid' and TRN_STATUS <>'Cancel')
		----OR
		----(CONFIRM_DATE <= '2009-10-18 23:59'
		----and PAY_STATUS ='Un-Paid' and TRN_STATUS <>'Cancel')
		----OR
		----(CONFIRM_DATE between '2009-10-19' and @date 
		----and TRN_STATUS ='Cancel' and CANCEL_DATE >= @date)
		----OR
		----(CONFIRM_DATE <= '2009-10-18 23:59'
		----and TRN_STATUS ='Cancel' and CANCEL_DATE >= @date)
		
			CONFIRM_DATE<@date

			AND ( 
			(TRN_STATUS <>'Cancel')   AND (PAY_STATUS <>'PAID')
			OR 
			(PAY_STATUS='PAID' AND P_DATE  > @date) 
			OR 
			(TRN_STATUS='Cancel' AND CANCEL_DATE > @date) 
			)  

		group by S_AGENT 

		union all 

		--SEND 
		SELECT 
		S_AGENT,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT, COUNT(*) SEND_TRN,sum(P_AMT) SEND_AMT,0 PAID_TRN,0 PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		from REMIT_TRN_LOCAL r with (nolock)
		where CONFIRM_DATE  between @date  and @date +' 23:59:59'
		group by S_AGENT

		union all 

		--PAID 
		SELECT 
		S_AGENT,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT, 0 SEND_TRN,0 SEND_AMT,COUNT(*) PAID_TRN,sum(P_AMT)PAID_AMT,0 CANCEL_TRN,0 CANCEL_AMT
		from REMIT_TRN_LOCAL r with (nolock)
		where P_DATE between @date  and @date +' 23:59:59' 
		group by S_AGENT

		union all 

		--CANCEL 
		SELECT 
		S_AGENT,0 UNPAID_TOTAL_TRN , 0 UNPAID_NPR_AMT, 0 SEND_TRN,0 SEND_AMT,0 PAID_TRN,0 PAID_AMT,COUNT(*) CANCEL_TRN,sum(P_AMT) CANCEL_AMT
		from REMIT_TRN_LOCAL r with (nolock)
		where CANCEL_DATE  between @date  and @date +' 23:59:59'
		group by S_AGENT
) r 

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', ''

SELECT 'From Date' head, CONVERT(VARCHAR, @date, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR, @date2, 101) value

SELECT 'Transaction Reconciliation Report' title



end


GO
