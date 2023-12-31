USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_DomesticSettelmentReport]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[proc_DomesticSettelmentReport]
	@flag char(1), 
	@date as varchar(20)
as
begin
declare @Title VARCHAR(150) = 'Domestic Settlement Report'
SELECT
	[S.No.],TRAN_TYPE,ISNULL(TRN,0) TRN, ISNULL(AMT,0) AMT
FROM (
	SELECT 1 as [S.No.],'Total Txn. Send For The Day' as TRAN_TYPE, count(*) TRN, SUM(ROUND_AMT)AS AMT
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE  CONFIRM_DATE between @date and @date + ' 23:59' 
	
	UNION ALL
	
	SELECT 2, 'Less : Total Txn. Send Today & Paid Today', count(*) PAID_TRN, SUM(ROUND_AMT)AS PAID_AMT  
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE  CONFIRM_DATE between @date and @date + ' 23:59' 
	and P_DATE between @date  and @date + ' 23:59'
	AND PAY_STATUS='Paid'
	UNION ALL
	
	SELECT 3, 'Total Txn. Send Today & Cancel Today', count(*) , SUM(ROUND_AMT)   
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE  CONFIRM_DATE between @date and @date + ' 23:59'  
	and CANCEL_DATE between @date and @date + ' 23:59'
	
	UNION ALL
	
	-- (Confirmed between 2009-02-19 to Previous Day)
	
	SELECT 4, 'Less : Total Txn. Paid From Unpaid Txn.' as TRAN_TYPE, count(*) TRN, SUM(ROUND_AMT)AS AMT
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE  P_DATE between @date and @date + ' 23:59' 
	and CONFIRM_DATE between '2009-10-19' and cast(dateadd(DAY,-1,@date) + ' 23:59' as datetime)
	
	UNION ALL
	
	SELECT 5 , 'Total Txn. Paid From Unpaid Txn.' as TRAN_TYPE, 
	count(*) TRN, SUM(ROUND_AMT+R_SC)AS AMT
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE P_DATE  between @date and @date + ' 23:59' 
	and CONFIRM_DATE between '2000-1-1' and dateadd(DAY,-1,'2009-10-19') 
	
	UNION ALL
	
	SELECT 6, 'Less : Total Txn. Cancelled From Unpaid Txn.' as TRAN_TYPE, count(*) TRN, SUM(ROUND_AMT)AS AMT
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE CONFIRM_DATE between '2009-10-19' and dateadd(DAY,-1,@date) + ' 23:59' 
	and CANCEL_DATE between @date and @date + ' 23:59'  
	
	UNION ALL
	
	SELECT 7, 'Total Txn. Cancelled From Unpaid Txn.' as TRAN_TYPE, 
	count(*) TRN, SUM(ROUND_AMT+R_SC)AS AMT
	FROM REMIT_TRN_LOCAL with (nolock)
	WHERE CONFIRM_DATE between '2000-1-1' and dateadd(DAY,-1,'2009-10-19') 
	and CANCEL_DATE between @date and @date + ' 23:59'
	
)a order by [S.No.]

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

  SELECT 'From Date' head, CONVERT(VARCHAR(10), @date, 101) value
  
  SELECT title = @Title

end



GO
