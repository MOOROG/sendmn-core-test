USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetRunningBalance]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.[FNAGetRunningBalance]('151025534','4500','dr')  
  
CREATE FUNCTION [dbo].[FNAGetRunningBalance]  
(  
 @StrAcc as varchar(20),  
 @CurrentAmount money,  
 @TranType as varchar(20)  
)  
RETURNS varchar(20) AS    
BEGIN   
  
  
 declare @clr_bal_amt money,  @available_amt money, @Result money  
   
 SELECT @clr_bal_amt=clr_bal_amt,@available_amt=available_amt   
 FROM ac_master with (nolock) WHERE acct_num=@StrAcc  
  
 set @Result = @clr_bal_amt  
   
  
 return @Result  
   
END  
GO
