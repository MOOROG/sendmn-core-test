USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procBillByBillRunningBalanceList]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

procBillByBillRunningBalanceList  '891018515','12'

*/


CREATE proc [dbo].[procBillByBillRunningBalanceList] 
	@acct_num varchar(50),
	@BILL_REF varchar(50) = NULL,
	@sessionID varchar(20) = NULL
as
begin

set nocount on;


	select 
		ABS(REMAIN_AMT) as REMAIN_AMT,
		BILL_REF,
		PART_TRN_TYPE = case when REMAIN_AMT < 0 then 'dr'  else 'cr' end,
		convert(varchar,TRN_DATE,107)TRN_DATE	
	from (
	Select 
		REMAIN_AMT =  ((case PART_TRN_TYPE when 'dr' then -1 * REMAIN_AMT else REMAIN_AMT end)
					+ isnull(RunningBal,0)),	
		BBB.BILL_REF,
		TRN_DATE	
	from BILL_BY_BILL as BBB with (nolock) 
		left Join 
			( select 
				RunningBal = sum(case part_tran_type when 'dr' then -1 * tran_amt else tran_amt end),
				BILL_REF = refrence 			
			  from temp_tran with (nolock) 
			   Where ACCT_NUM = @acct_num  and refrence like @BILL_REF + '%' 
					and sessionID=@sessionID
			group by refrence
			) as tblTmp on BBB.BILL_REF=tblTmp.BILL_REF 
	        
		Where BBB.ACC_NUM = @acct_num  and BBB.BILL_REF like @BILL_REF  + '%' 
			and (REMAIN_AMT - isnull(RunningBal,0)) <> 0 
	) as myTable where REMAIN_AMT <> 0 

end	


GO
