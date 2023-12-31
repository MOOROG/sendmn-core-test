USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procLedgerMovement]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Exec procLedgerMovement 'm','20','10','111021511, 111010152, 111000495, 111020859'  

CREATE proc  [dbo].[procLedgerMovement]  
 @flag char(1),  
 @moveFrom varchar(20),  
 @moveTo varchar(20),  
 @AcNumbers varchar(5000)  
AS  
 set nocount on;  
  
If @flag='m'  
begin  
   
 declare @ExistOrNot as varchar(20)  
  
 if @moveFrom='' or @moveTo='' or @AcNumbers=''  
 begin  
  SELECT 'INVALID GL CODES TO MOVE' as REMARKS  
  return;  
 end  
   
 set @ExistOrNot=''  
 set @ExistOrNot=''+@AcNumbers+''  
    
 -- UPDATE AC TABLE  
  update ac_master set gl_code=@moveTo where gl_code=@moveFrom
   and acct_num in (select value from dbo.split(',',@AcNumbers))
   
 -- UPDATE TRAN TABLE  
  update tran_master set gl_sub_head_code=@moveTo where gl_sub_head_code=@moveFrom
   and acc_num in (select value from dbo.split(',',@AcNumbers))
    
    
  SELECT '0' ERRORCODE, 'UPDATE SUCCESS' as MSG , NULL ID 
   
end 


GO
