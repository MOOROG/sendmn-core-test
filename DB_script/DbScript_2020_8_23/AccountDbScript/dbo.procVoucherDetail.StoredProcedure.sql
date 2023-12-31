USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procVoucherDetail]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from tran_master  
--select * from tran_masterDetail  
  
  
CREATE proc [dbo].[procVoucherDetail]  
 @flag char(1),  
 @UserID varchar(50),  
 @StartDate datetime,  
 @EndDate DateTime,  
 @TranType varchar(5)  
   
as  
set nocount on;  
  
  
if @flag ='a'  
begin  
  
  
select * from (  
select distinct t.ref_num, t.tran_type   
FROM tran_master t WITH (NOLOCK) ,   
 ac_master a  WITH (NOLOCK),   
  tran_masterDetail d WITH (NOLOCK)  
WHERE t.ref_num=d.ref_num AND t.tran_type=d.tran_type AND t.company_id=d.company_id   
  AND acc_num=acct_num  
  AND t.entry_user_id=@UserID  
  and t.tran_date between @StartDate and @EndDate   
  and t.tran_type=ISNULL(@TranType,t.tran_type)  
) a  
ORDER BY cast(ref_num as float) ASC,tran_type  
   
end  
   
if @flag ='b'  
begin  
  
  
SELECT * FROM (  
 SELECT DISTINCT t.ref_num AS TRNno, t.tran_type , CONVERT(VARCHAR,tran_date,102) TRNDate,  
  acc_num,acct_name,    
  part_tran_srl_num,tran_rmks,tran_particular,t.billno,  
  CASE WHEN part_tran_type='dr' THEN tran_amt ELSE 0 END  AS DRTotal,  
  CASE WHEN part_tran_type='cr' THEN tran_amt ELSE 0 END  AS cRTotal, tran_date AS TD,  
  entry_user_id,rpt_code  
 FROM tran_master t WITH (NOLOCK) , ac_master a  WITH (NOLOCK), tran_masterDetail d WITH (NOLOCK)  
 WHERE t.ref_num=d.ref_num AND t.tran_type=d.tran_type AND t.company_id=d.company_id   
  AND acc_num=acct_num  
  AND t.entry_user_id=@UserID  
  and t.tran_date between @StartDate and @EndDate   
  and t.tran_type=ISNULL(@TranType,t.tran_type)  
 ) a ORDER BY cast(TRNno as float) ASC,CAST(part_tran_srl_num AS INT)  
   
  
end  
GO
