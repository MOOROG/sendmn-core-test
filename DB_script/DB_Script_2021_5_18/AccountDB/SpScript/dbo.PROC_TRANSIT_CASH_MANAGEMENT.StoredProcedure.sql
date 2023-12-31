USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRANSIT_CASH_MANAGEMENT]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[PROC_TRANSIT_CASH_MANAGEMENT]  
(  
 @FLAG VARCHAR(20)  
 ,@USER VARCHAR(50)  
 ,@REFERRAL_CODE VARCHAR(50) = NULL  
 ,@RECEIVING_MODE CHAR(2) = NULL  
 ,@RECEIVER_ACC_NUM VARCHAR(30) = NULL  
 ,@AMOUNT MONEY = NULL  
 ,@TRAN_DATE VARCHAR(30) = NULL  
 ,@NARRATION VARCHAR(250) = NULL  
)  
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
BEGIN  
 IF @FLAG = 'I'  
 BEGIN  
  DECLARE @TRANSIT_CASH_ACC VARCHAR(30), @REFERAL_AC VARCHAR(30)  
   , @REFERRAL_ID INT, @SESSION_ID VARCHAR(50) = NEWID(), @AGENT_ID INT  
  
  
  SELECT @REFERRAL_ID = ROW_ID, @AGENT_ID = BRANCH_ID  
  FROM SendMnPro_Remit.dbo.REFERRAL_AGENT_WISE (NOLOCK)   
  WHERE REFERRAL_CODE = @REFERRAL_CODE  
  
  SELECT @TRANSIT_CASH_ACC = ACCT_NUM  
  FROM AC_MASTER (NOLOCK) WHERE AGENT_ID = @AGENT_ID AND ACCT_RPT_CODE = 'CTA'  
  
  IF @REFERRAL_ID IS NULL  
  BEGIN  
   EXEC PROC_ERRORHANDLER 1, 'Invalid Referral Selected!', NULL  
   RETURN;  
  END  
  IF @RECEIVING_MODE NOT IN ('CV', 'B')  
  BEGIN  
   EXEC PROC_ERRORHANDLER 1, 'Invalid Receiving Mode Selected!', NULL  
   RETURN;  
  END  
  
  INSERT INTO TRANSIT_CASH_SETTLEMENT(REFERRAL_CODE, RECEIVING_MODE, RECEIVING_ACCOUNT, IN_AMOUNT, OUT_AMOUNT, TRAN_DATE, CREATED_BY, CREATED_DATE, REFERENCE_ID)  
  SELECT @REFERRAL_CODE, @RECEIVING_MODE, @RECEIVER_ACC_NUM, 0, @AMOUNT, @TRAN_DATE, @USER, GETDATE(), 0  
    
  DECLARE @ROW_ID INT = @@IDENTITY  
  
  IF @RECEIVING_MODE = 'CV'  
  BEGIN  
   DECLARE @BRANCH_ID INT   
  
   SELECT @BRANCH_ID = AGENT_ID  
   FROM AC_MASTER(NOLOCK)  
   WHERE ACCT_NUM = @RECEIVER_ACC_NUM  
  
   DECLARE @remarks VARCHAR(250) = 'Transit Cash received for referral: ' + @REFERRAL_CODE  
  
   EXEC SendMnPro_Remit.dbo.PROC_PUSH_CASH_IN_OUT @flag='IN', @user=@USER,@amount=@AMOUNT,@tranDate=@TRAN_DATE,@head='Transit Received',@remarks=@remarks,  
    @branchId=@BRANCH_ID,@userId=0,@isAutoApprove=1,@referenceId=@ROW_ID,@mode=@RECEIVING_MODE,@fromAcc=@TRANSIT_CASH_ACC,@toAcc=@RECEIVER_ACC_NUM  

   EXEC SendMnPro_Remit.dbo.PROC_UPDATE_AVAILABALE_BALANCE @FLAG='TRANSIT_CASH_TRANSFER_TO_VAULT',@S_AGENT=@BRANCH_ID,@S_USER=@REFERRAL_ID,@C_AMT=@AMOUNT  
  END  
  ELSE  
  BEGIN  
   EXEC SendMnPro_Remit.dbo.PROC_UPDATE_AVAILABALE_BALANCE @FLAG='TRANSIT_CASH_TRANSFER_TO_BANK',@S_USER=@REFERRAL_ID,@C_AMT=@AMOUNT  
  END  
  
  SELECT @REFERAL_AC = ACCT_NUM  
  FROM AC_MASTER (NOLOCK)  
  WHERE AGENT_ID = @REFERRAL_ID  
  AND ACCT_RPT_CODE = 'RA'  
  AND ACCT_NAME = @REFERRAL_CODE  
   
 

  IF @REFERAL_AC IS NULL OR @RECEIVER_ACC_NUM IS NULL  
  BEGIN  
   EXEC PROC_ERRORHANDLER 1, 'No account found for either Referal or bank/branch!', NULL  
   RETURN;  
  END  
  CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))  
  
  --voucher entry for TRANSIT ACC  
  INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
   ,rpt_code,trn_currency,field1,field2)   
  SELECT @SESSION_ID,@user,@TRANSIT_CASH_ACC,'j','cr',@AMOUNT,@AMOUNT,1,@TRAN_DATE  
   ,'USDVOUCHER','JPY',@ROW_ID,'Transit Cash Settle'  
  
  --voucher entry for VAULT OR BANK ACC  
  INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
   ,rpt_code,trn_currency,field1,field2)   
  SELECT @SESSION_ID,@user,@RECEIVER_ACC_NUM,'j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE  
   ,'USDVOUCHER','JPY',@ROW_ID,'Transit Cash Settle'  
  
  --voucher entry for REFERRAL ACC (ONLY FOR BACKEND PURPOSE)  
  INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
   ,rpt_code,trn_currency,field1,field2)   
  SELECT @SESSION_ID,@user,@REFERAL_AC,'j','cr',@AMOUNT,@AMOUNT,1,@TRAN_DATE  
   ,'USDVOUCHER','JPY',@ROW_ID,'Transit Cash Settle'  
  
  SET @NARRATION = LTRIM(RTRIM(@NARRATION))  
  
  IF ISNULL(@NARRATION, '') = ''  
   SET @NARRATION = 'Transit Cash Settled'  
  ELSE   
   SET @NARRATION = 'Transit Cash Settled - ' + @NARRATION  
  
  INSERT INTO #TEMP_ERROR_CODE  
  EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@TRAN_DATE,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@user  
  
  IF NOT EXISTS(SELECT * FROM #TEMP_ERROR_CODE WHERE LTRIM(RTRIM(ERROR_CODE)) = '0')  
  BEGIN  
   DELETE FROM TRANSIT_CASH_SETTLEMENT WHERE ROW_ID = @ROW_ID  
   DELETE FROM SendMnPro_Remit.dbo.BRANCH_CASH_IN_OUT WHERE REFERENCEID = @ROW_ID AND HEAD = 'Transit Received'  
  END  
    
  SELECT * FROM #TEMP_ERROR_CODE  
 END  
END  
  
  
  


GO
