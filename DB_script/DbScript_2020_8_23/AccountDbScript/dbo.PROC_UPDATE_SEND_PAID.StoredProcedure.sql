USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_UPDATE_SEND_PAID]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_UPDATE_SEND_PAID]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @date varchar(20)
    SET @date = cast(GETDATE() as DATE)

    --select @date

    UPDATE agentTable 
    SET todaysSend=isnull(S_AMT,0)
	   ,todaysPaid=isnull(P_AMT,0)+ isnull(INT_P_AMT,0)
	   ,todaysCancel=isnull(C_AMT,0)
    FROM agentTable A WITH (NOLOCK), 
    (
	   select A.agent_id, S.S_AGENT
			 , isnull(sum(S.S_AMT),0)S_AMT 
			 , isnull(sum(P.P_AMT),0)P_AMT
			 , isnull(sum(C.C_AMT),0)C_AMT
			 , isnull(sum(I.INT_P_AMT),0) INT_P_AMT
	   from  agentTable A WITH (NOLOCK)
	   left join 
	   (
		  select 
			 S_AGENT, sum(S_AMT) AS S_AMT
			 from REMIT_TRN_LOCAL WITH (NOLOCK)
		  WHERE CONFIRM_DATE between @date and @date +' 23:59'
		  --AND F_SENDTRN IS NULL
		  group by S_AGENT

		  union all

		  select 
			  central_sett_code, sum(S_AMT) AS S_AMT
		  from REMIT_TRN_LOCAL T WITH (NOLOCK)
			 join agentTable A WITH (NOLOCK)on T.S_AGENT = A.AGENT_IME_CODE
		  WHERE CONFIRM_DATE between @date and @date +' 23:59'
			   and isnull(central_sett,'')='y' --and central_sett_code ='33300379' 
			   --AND F_SENDTRN IS NULL
		  group by central_sett_code

	   )S on A.AGENT_IME_CODE = S.S_AGENT

	   LEFT JOIN
	   (
		  select 
			 R_AGENT, sum(P_AMT)as P_AMT 
			 from REMIT_TRN_LOCAL WITH (NOLOCK)
		  WHERE P_DATE between @date and @date +' 23:59'
		  --AND F_STODAY_PTODAY IS NULL 
		  --AND F_PTODAY_SYESTERDAY IS NULL
		  group by R_AGENT

		  union all

		  select 
			  central_sett_code, sum(P_AMT) AS S_AMT
		  from REMIT_TRN_LOCAL T WITH (NOLOCK)
			 join agentTable A on T.R_AGENT = A.AGENT_IME_CODE
		  WHERE P_DATE between @date and @date +' 23:59'
			   and isnull(central_sett,'')='y' --and central_sett_code ='33300379' 
			   --AND F_STODAY_PTODAY IS NULL AND F_PTODAY_SYESTERDAY IS NULL
		  group by central_sett_code


	   )P on A.AGENT_IME_CODE = P.R_AGENT
	   left join
	   (
		  select 
			 S_AGENT, sum(S_AMT) as C_AMT
			 from REMIT_TRN_LOCAL WITH (NOLOCK)
		  WHERE CANCEL_DATE between @date and @date +' 23:59'
		  --AND F_CODAY_SYESTERDAY IS NULL AND F_CODAY_SYESTERDAY IS NULL
		  group by S_AGENT
	   
		  union all

		  select 
			  central_sett_code, sum(S_AMT) AS S_AMT
		  from REMIT_TRN_LOCAL T WITH (NOLOCK)
			 join agentTable A WITH (NOLOCK) on T.S_AGENT = A.AGENT_IME_CODE
		  WHERE CANCEL_DATE between @date and @date +' 23:59'
			   and isnull(central_sett,'')='y' --and central_sett_code ='33300379' 
			  -- AND F_CODAY_SYESTERDAY IS NULL AND F_CODAY_SYESTERDAY IS NULL
		  group by central_sett_code

	   )C on A.AGENT_IME_CODE = C.S_AGENT
	   left join
	   (
		  select P_AGENT, sum(INT_P_AMT)INT_P_AMT
		  from(
			  select 
			  P_AGENT, sum(P_AMT)as INT_P_AMT 
			  from REMIT_TRN_MASTER WITH (NOLOCK)
				    WHERE PAID_DATE between @date and @date +' 23:59'
					AND (TRN_TYPE='Bank Transfer')
					--AND F_PAID IS NULL
				    group by P_AGENT

			  UNION ALL
            	
			  select 
			  P_BRANCH, sum(P_AMT)as P_AMT 
			  from REMIT_TRN_MASTER WITH (NOLOCK)
				    WHERE PAID_DATE between @date and @date +' 23:59'
					AND TRN_TYPE='Cash Pay'
					--AND F_PAID IS NULL
				    group by P_BRANCH
            	 
			  UNION ALL
            	
			  select 
			  P_AGENT, sum(P_AMT)as P_AMT 
			  from REMIT_TRN_MASTER WITH (NOLOCK)
			  WHERE PAID_DATE between @date and @date +' 23:59'
			  AND TRN_TYPE='Cash Pay'
			  --AND F_PAID IS NULL
			  AND P_AGENT <> P_BRANCH
			  group by P_AGENT
			  
		  )N group by P_AGENT

	   )I on A.map_code = I.P_AGENT 
 
       Group by A.agent_id, S.S_AGENT

    )B
    WHERE A.agent_id = B.agent_id



 UPDATE agentTable 
	
	SET  todaysEP=isnull(AMT,0)

 FROM agentTable A WITH (NOLOCK), 
 (
	   select 
		  map_code, SUM([TRAN_AMT])AMT
	   FROM(
		  SELECT 
				  map_code,
				  (e.Amount) [TRAN_AMT]
		   FROM agentTable a with (nolock),
		   (	SELECT * 
			  FROM ErroneouslyPaymentNew with (nolock)
			  WHERE EP_date = @date
			  --AND EP_vo IS NULL
		   )e

		  WHERE case when isnull(a.central_sett,'n')='y' 
			  then e.EP_AgentCode else e.EP_BranchCode  end =a.map_code
	   )A
	   GROUP by map_code
)B
WHERE A.map_code = B.map_code



 UPDATE agentTable 
	SET  todaysPO=isnull(AMT,0)
 FROM agentTable A WITH (NOLOCK), 
 (
	   select 
		  map_code, SUM([TRAN_AMT])AMT
	   FROM(
		  SELECT 
				  map_code,
				  (e.Amount) [TRAN_AMT]
		   FROM agentTable a with (nolock),
		   (	SELECT * 
			  FROM ErroneouslyPaymentNew with (nolock)
			  WHERE PO_date = @date
			  --and PO_VO is null
		   )e

		  WHERE case when isnull(a.central_sett,'n')='y' 
			  then e.PO_AgentCode else e.PO_BranchCode  end =a.map_code
	   )A
	   GROUP by map_code
)B
WHERE A.map_code = B.map_code


END


GO
