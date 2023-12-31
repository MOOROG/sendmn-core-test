USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_branchstatement]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec [proc_branchstatement] 'a' ,'311045383','','2011-5-7',1

CREATE proc [dbo].[proc_branchstatement]
	@flag char(1),
	@acnum varchar(20),
	@startDate varchar(20),
	@endDate varchar(20),
	@company_id varchar(20)
AS

SET NOCOUNT ON;

IF @startDate IS NULL
SET @startDate = CAST(@endDate AS DATETIME )-30;


IF @flag='a'
BEGIN

	DECLARE @sql VARCHAR(6000)

	SET @endDate = @endDate + ' 23:59:59'
	SET @sql = ''

	SET @sql=@sql + ' SELECT 
						 CONVERT(VARCHAR,TRNDate,102) [Tran Date]
						,tran_rmks [Description]
						,CONVERT(DECIMAL(9,2)
						,DRTotal,102)[DR Amount]
						,CONVERT(DECIMAL(9,2)
						,cRTotal,102)[CR Amount]
						,CONVERT(DECIMAL(9,2)
						,end_clr_balance,102)[Balance]
						,acc_num as acct_num 
						,cast(ref_num as float) as ref_num
						, TD,tran_type 
					FROM ( '

	
	SET @sql= @sql + 'SELECT 1 AS 
						 tran_id
						,acc_num
						,'''' TRNDate
						,''Balance Brought Forward'' tran_rmks
						,0 DRTotal
						,0 cRTotal
						,ISNULL(end_clr_balance,0) end_clr_balance
						,''0.0'' ref_num
						,'''' TD
						,'''' tran_type
					FROM (

					SELECT  2 AS 
						 tran_id
						 ,acc_num
						 ,SUM (CASE WHEN part_tran_type=''dr'' THEN tran_amt*-1 ELSE tran_amt END) end_clr_balance
					FROM tran_master WITH (NOLOCK) WHERE acc_num='''+@acnum +''' AND
					tran_date < '''+ @startDate+'''
					GROUP BY acc_num
					) ca	 
					UNION ALL'


	SET @sql = @sql +' 
					SELECT  
						 tran_id 
						,acc_num
						,tran_date AS TRNDate
						,ISNULL(tran_particular,'''')+'' '' + ISNULL(tran_rmks,'''') AS tran_rmks 
						,CASE WHEN part_tran_type=''dr'' THEN tran_amt ELSE 0 END AS DRTotal
						,CASE WHEN part_tran_type=''cr'' THEN tran_amt ELSE 0 END AS cRTotal
						,0 Balance
						,t.ref_num
						,tran_date AS TD
						,t.tran_type
					FROM tran_master t WITH (NOLOCK), tran_masterDetail d WITH (NOLOCK)
					WHERE t.ref_num = d.ref_num AND t.tran_type=d.tran_type AND t.company_id = d.company_id 
						AND acc_num = '''+@acnum +''' 
						AND t.company_id = '+@company_id +' 
						AND tran_date BETWEEN '''+@startDate +''' AND '''+@endDate +''' 
	
	) 
	a ORDER BY td, CAST(ref_num AS FLOAT) '
	
	--print(@sql)
	EXECUTE(@sql)

	
end



GO
