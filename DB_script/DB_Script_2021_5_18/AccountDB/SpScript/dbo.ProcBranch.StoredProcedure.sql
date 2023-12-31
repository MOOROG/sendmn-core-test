USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcBranch]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
    
    
--EXEC ProcBranch @FLAG='V',@ID=1,@CURR_CODE='USD'    
--exec ProcBranch 'I',null,'Kantipath',  'kanti',null,null,  null,'jamal','1','1',  'swift@hotmail.com','bhim','123' null    
/*    
EXEC [ProcBranch] @FLAG = 'u', @USER = '1039', @ID = '1', @BRANCH_NAME = 'Medan Pasar test', @BRANCH_SHORT_NAME = 'A00068', @BRANCH_ZONE = 'IME Branch', @BRANCH_DISTRICT = 'Jalan Stesen Sentral 5, 50470', @BRANCH_ADDRESS = 'No.22,Ground Floor,Medan Pasart
  
est', @BRANCH_PHONE = '320727260', @BRANCH_FAX = '3207220', @BRANCH_EMAIL = 'medan@imeremit.com.np', @CONTACT_PERSON = 'erer', @BRANCH_TYPE = 'B',@BRANCH_MOBILE = '2500' ,@receiptPrint = 's', @lineadj = Null, @mainbranch = 'Y'     
    
 alter table branches add headMsg varchar(max)    
    
*/    
CREATE PROCEDURE [dbo].[ProcBranch]    
    
   @FLAG    VARCHAR(10),    
   @ID    INT   = null,    
      @USER    VARCHAR(50) =NULL,    
   @BRANCH_NAME  VARCHAR(500)= NULL,    
      @BRANCH_SHORT_NAME VARCHAR(200) = NULL,    
      @BRANCH_ZONE  VARCHAR(50) = NULL,    
      @BRANCH_DISTRICT VARCHAR(50) = NULL,    
      @BRANCH_ADDRESS VARCHAR(200)= NULL,    
      @BRANCH_PHONE  VARCHAR(50) = NULL,    
      @BRANCH_FAX  VARCHAR(50) = NULL,    
      @BRANCH_EMAIL  VARCHAR(150)= NULL,    
      @CONTACT_PERSON VARCHAR(200)= NULL,    
      @BRANCH_MOBILE VARCHAR(50) = NULL,    
      @BRANCH_TYPE  CHAR(2)  = null,    
      @CURR_CODE  VARCHAR(10) = null,    
      @hotel   INT   = NULL,    
      @receiptPrint  VARCHAR(1) = NULL,    
      @lineadj   INT   = NULL,    
      @mainbranch  CHAR(1)  = NULL,    
      @headMsg    VARCHAR(MAX)= NULL,    
      @mapCode   VARCHAR(50) = NULL    
      
AS    
BEGIN    
    
  SET NOCOUNT ON;    
  create table #tempACnum (acct_num varchar(20))    
    
       
       
IF @FLAG='S'    
BEGIN    
 SELECT     
    BRANCH_NAME,    
    BRANCH_SHORT_NAME,    
    BRANCH_ZONE,    
    BRANCH_DISTRICT,    
    BRANCH_ADDRESS,    
    BRANCH_PHONE,    
    BRANCH_FAX,    
    BRANCH_EMAIL,    
    CONTACT_PERSON,    
    BRANCH_MOBILE,    
    BRANCH_TYPE    
         
 FROM BRANCHES    
 WHERE BRANCH_ID=@ID     
END    
    
IF @FLAG='I'    
BEGIN    
 IF EXISTS(SELECT TOP 1 'A' FROM Branches WHERE isMainBranch IS NOT NULL AND ISNULL(@mainbranch,'N') = 'Y')    
 BEGIN    
  SELECT 1 CODE,'Main Branch is already assigned!' msg    
  RETURN;    
 END    
  INSERT INTO Branches    
    (    
    BRANCH_NAME,    
    BRANCH_SHORT_NAME,    
    BRANCH_ZONE,    
    BRANCH_DISTRICT,    
    BRANCH_ADDRESS,    
    BRANCH_PHONE,    
    BRANCH_FAX,    
    BRANCH_EMAIL,    
    CONTACT_PERSON,    
    BRANCH_MOBILE,    
    BRANCH_TYPE,    
    [CREATED_BY],    
    [CREATED_DATE],    
    receiptPrint,    
    lineadj,    
    isMainBranch,    
    headMsg    
   )    
          
   VALUES    
   (    
    @BRANCH_NAME    
    ,@BRANCH_SHORT_NAME    
    ,@BRANCH_ZONE    
    ,@BRANCH_DISTRICT    
    ,@BRANCH_ADDRESS    
    ,@BRANCH_PHONE    
    ,@BRANCH_FAX    
    ,@BRANCH_EMAIL    
    ,@CONTACT_PERSON    
    ,@BRANCH_MOBILE    
    ,@BRANCH_TYPE    
    ,@USER,GETDATE()     
    ,@receiptPrint    
    ,@lineadj    
    ,@mainbranch    
    ,@headMsg    
     )    
     
     
      
set @ID=SCOPE_IDENTITY()    
    
DECLARE @glcode varchar(5), @acct_num  varchar(20)    
DECLARE @acct_num_fcy varchar(20)    
DECLARE @acct_num_lcy varchar(20)    
    
    
IF  @BRANCH_TYPE='AP'    
 BEGIN    
    
  set @glcode='14'    
  insert into #tempACnum    
  exec spa_createAccountNumber 'a', @glcode    
    
  select @acct_num_lcy=acct_num from #tempACnum    
      
  truncate table #tempACnum    
      
  insert into ac_master (acct_num    
  , acct_name    
  , gl_code    
  , agent_id    
  , branch_id    
  , acct_ownership    
  , dr_bal_lim    
  , lim_expiry    
  , acct_rpt_code    
  , acct_type_code    
  , frez_ref_code    
  , acct_opn_date    
  , clr_bal_amt    
  , system_reserved_amt    
  , system_reserver_remarks    
  , lien_amt, lien_remarks    
  , utilised_amt    
  , available_amt    
  ,created_date    
  ,created_by    
  ,company_id    
  ,ac_currency )    
      
SELECT @acct_num_lcy    
    ,@BRANCH_NAME+'-Receivable'    
    ,10    
    , null    
    ,@ID    
    ,'c'    
    ,0    
    ,null,null,null,null,getdate(),0,0,null,0,null,0,0,getdate(),@USER,1,'MYR'    
 end    
    
    
SELECT  0 CODE,'Operation Completed Successfully' AS MSG    
     
END    
    
IF @FLAG='U'    
BEGIN    
 IF EXISTS(SELECT TOP 1 'A' FROM Branches WHERE isMainBranch IS NOT NULL AND BRANCH_ID <> @ID AND ISNULL(@mainbranch,'N') = 'Y' )    
 BEGIN    
  SELECT 1 CODE,'Main Branch is already assigned!' msg    
  RETURN;    
 END    
  UPDATE Branches     
  SET     
   [BRANCH_NAME]  = @BRANCH_NAME,    
   [BRANCH_SHORT_NAME] =@BRANCH_SHORT_NAME,    
   [BRANCH_ZONE]  =@BRANCH_ZONE,    
   [BRANCH_DISTRICT] =@BRANCH_DISTRICT,    
   BRANCH_ADDRESS  =@BRANCH_ADDRESS,    
   [BRANCH_PHONE]  =@BRANCH_PHONE,    
   [BRANCH_FAX]  =@BRANCH_FAX,    
   [BRANCH_EMAIL]  =@BRANCH_EMAIL,    
   [CONTACT_PERSON] =@CONTACT_PERSON,    
   [BRANCH_MOBILE]  =@BRANCH_MOBILE,    
   [BRANCH_TYPE]  =@BRANCH_TYPE,    
   [MODIFIED_BY]  =@USER,    
   [MODIFIED_DATE]  =GETDATE(),    
   receiptPrint  =@receiptPrint,    
   lineadj    = @lineadj,    
   isMainBranch  = @mainbranch,    
   headMsg    = @headMsg    
   WHERE     
   [BRANCH_ID] = @ID    
       
  SELECT 0 CODE,'Record updated successfully!' msg    
    
IF @BRANCH_TYPE='AP'    
 BEGIN    
 IF EXISTS(SELECT 'A' FROM ac_master WHERE gl_code='14' AND branch_id = @ID)    
 BEGIN    
  -- ## For LCY CASH BALANCE a/c    
    set @glcode='10'    
    insert into #tempACnum    
    exec spa_createAccountNumber 'a', @glcode    
    
    select @acct_num_lcy=acct_num from #tempACnum    
        
    truncate table #tempACnum    
        
    insert into ac_master (acct_num    
    , acct_name    
    , gl_code    
    , agent_id    
    , branch_id    
    , acct_ownership    
    , dr_bal_lim    
    , lim_expiry    
    , acct_rpt_code    
    , acct_type_code    
    , frez_ref_code    
    , acct_opn_date    
    , clr_bal_amt    
    , system_reserved_amt    
    , system_reserver_remarks    
    , lien_amt, lien_remarks    
    , utilised_amt    
    , available_amt    
    ,created_date    
    ,created_by    
    ,company_id     
    ,ac_currency)    
       
    SELECT @acct_num_lcy    
    ,@BRANCH_NAME+'-LCY_CASH'    
    ,10    
    , null    
    ,@ID    
    ,'c'    
    ,0    
    ,null,null,null,null,getdate(),0,0,null,0,null,0,0,getdate(),@USER,1,'MYR'    
       
   delete from #tempACnum    
  END    
   -----------------------------    
  SELECT  0 CODE,'Operation Completed Successfully' AS MSG    
 END    
END     
IF @FLAG='D'    
BEGIN    
  DELETE FROM Branches WHERE BRANCH_ID=@ID;    
      
 SELECT 0 CODE , 'Operation Completed Successfully' AS MSG    
END    
IF @FLAG = 'B'    
BEGIN    
     
 if @ID IS NOT NULL    
 BEGIN    
  select c.curr_code+'('+c.curr_name+')' [curr_name],c.curr_code from Branch_Currency b    
  INNER JOIN currency_setup c on b.curr_code=c.rowid    
  where b.branch_id= @ID AND C.curr_code<>'MYR'    
  ORDER BY C.curr_code    
 END    
 ELSE    
 BEGIN    
  select rowid,curr_code from currency_setup ORDER BY curr_code    
 END    
    
END    
IF @FLAG = 'V'    
BEGIN    
    
    
     
   select distinct e.BuyRate,e.Buytoleranceminus,e.RevRate,e.Buytoleranceplus from Branches b with (nolock)    
    inner join RateCodeTable r with (nolock) on b.cashId =r.ratecodeId    
    inner join ExchangeRateTable e with (nolock) on r.ratecodeId=e.RateCode    
    where b.BRANCH_ID = @ID and e.CurFixed=@CURR_CODE    
        
       
END    
    
IF @FLAG = 'p'    
BEGIN    
     
     
  select c.curr_code from Branch_Currency b    
  inner join currency_setup c on b.curr_code=c.rowid    
  where b.branch_id= @ID AND C.curr_code<>'MYR'    
     
    
END    
    
IF @FLAG = 'A'--for agent currency selection    
BEGIN    
  ------select CurFixed,exrateId from ExchangeRateTable E    
  ------inner join Branches B on B.cashId = E.RateCode where BRANCH_ID = @ID    
     
 select distinct x.* from (    
  select CurFixed,exrateId from ExchangeRateTable E    
  inner join Branches B on B.cashId = E.RateCode and B.BRANCH_ID=@ID    
 )x    
 inner join HotelBuyHistory h on h.curr=x.CurFixed where h.HotelId=@hotel    
 and h.messsageId is null    
    
     
    
END    
END 
GO
