  
ALTER PROC PROC_CUSTOMER_DEPOSITS  
(  
  @flag   VARCHAR(20)  
 ,@user   VARCHAR(50)  
 ,@customerId BIGINT   = NULL  
 ,@tranId  BIGINT   = NULL  
 ,@isSkipped  CHAR(1)   = NULL  
 ,@bankId  INT    = NULL  
 ,@trnDate  varchar(10)  = NULL  
 ,@particulars varchar(100) = NULL  
 ,@tranIds  varchar(100) = NULL  
 ,@pageSize  VARCHAR(50)  = NULL  
 ,@pageNumber VARCHAR(50)  = NULL  
 ,@sortBy  VARCHAR(50)  = NULL  
 ,@sortOrder  VARCHAR(50)  = NULL  
 ,@from   varchar(10)  = NULL  
 ,@to   varchar(19)  = NULL  
 ,@status  VARCHAR(50)  = NULL  
 ,@remmitTranTempId  VARCHAR(50) = NULL  
 ,@amount  MONEY   = NULL  
 ,@id			BIGINT			= NULL
)  
AS;  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
BEGIN TRY  
 DECLARE @noOfTranIds int  
    ,@RECEIVER_ACC_NUM VARCHAR(30) = NULL    
    ,@customer_Acc_num varchar(30) = null  
    ,@NARRATION NVARCHAR(200)  
    ,@TRAN_DATE VARCHAR(20)  
    ,@SESSION_ID VARCHAR(50) = NEWID()  
  
 IF @FLAG = 'S'  
 BEGIN  
  SELECT TOP 10   
     tranId  
    ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
    ,depositAmount  
    ,paymentAmount  
    ,particulars   
    ,bankName  
  FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)  
  WHERE processedBy IS NULL  
  AND processedDate IS NULL  
  AND customerId IS NULL  
  AND ISNULL(isSkipped, 0) = @isSkipped  
          
 END  
 ELSE IF @FLAG = 's-detail'  
 BEGIN  
  IF @status = 'all'  
  BEGIN  
   --GET MAPPED AND APPROVED  BUT COULD OR COULD NOT BE MAPPED WITH TRANSACTION  
   SELECT   tranId  
     ,cm.fullName  
     ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
     ,depositAmount  
     ,paymentAmount  
     ,particulars   
     ,cdl.approvedby  
     ,cdl.bankName  
     ,processedBy  
     , CASE WHEN TBD.HOLD_TRAN_ID IS NULL THEN 'Mapped,Approved But Not Mapped With Transaction' ELSE CAST(RT.id AS varchar) END [TransactionId]  
   FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
   INNER JOIN customerMaster CM (NOLOCK) ON CM.customerId = CDL.customerId  
   LEFT JOIN TBL_BANK_DEPOSIT_TXN_MAPPING TBD (NOLOCK) ON TBD.DEPOSIT_LOG_ID = CDL.tranId  
   LEFT JOIN REMITTRAN RT (NOLOCK) ON CAST(RT.holdTranId AS varchar) = TBD.HOLD_TRAN_ID  
   WHERE processedBy is not null and  cdl.approvedBy IS NOT NULL  
   and cdl.isSkipped = 0  
   AND cdl.tranDate between @from and @to + ' 23:59:59'  
  
   UNION ALL  
   --GET MAPPED DATA  BUT UNAPPROVED  
   SELECT   tranId  
     ,cm.fullName  
     ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
     ,depositAmount  
     ,paymentAmount  
     ,particulars   
     ,cdl.approvedby  
     ,cdl.bankName  
     ,processedBy  
     ,'Mapped But Unapproved' [TransactionId]  
   FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
   INNER JOIN customerMaster CM (NOLOCK) ON CM.customerId = CDL.customerId  
   WHERE processedBy is not null and  cdl.approvedBy IS NULL  
   and cdl.isSkipped = 0  
   AND cdl.tranDate between @from and @to + ' 23:59:59'  
  
   UNION ALL  
   --GET UNMAPPED  
   SELECT   tranId  
     ,'' fullName  
     ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
     ,depositAmount  
     ,paymentAmount  
     ,particulars   
     ,cdl.approvedby  
     ,cdl.bankName  
     ,processedBy  
     ,NULL [TransactionId]  
   FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
   WHERE processedBy is null and cdl.approvedBy IS NULL  
   and cdl.isSkipped = 0  
   AND cdl.tranDate between @from and @to + ' 23:59:59'  
  
  END  
  ELSE IF @status = 'unmapped'  
  BEGIN  
	   SELECT   tranId  
		 ,'' fullName  
		 ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
		 ,depositAmount  
		 ,paymentAmount  
		 ,particulars   
		 ,cdl.approvedby  
		 ,cdl.bankName  
		 ,processedBy  
		 ,'Unmapped' [TransactionId]  
	   FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
	   WHERE processedBy is null and cdl.approvedBy IS NULL  
	   and cdl.isSkipped = 0  
	   AND cdl.tranDate between @from and @to + ' 23:59:59'  
  END  
  ELSE  
  BEGIN  
   ----GET MAPPED DATA,APPROVED  
   --SELECT   tranId  
   --  ,cm.fullName  
   --  ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
   --  ,depositAmount  
   --  ,paymentAmount  
   --  ,particulars   
   --  ,cdl.approvedby  
   --  ,cdl.bankName  
   --  ,processedBy  
   --  ,cast(RT.ID as varchar) [TransactionId]  
   --FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
   --INNER JOIN customerMaster CM (NOLOCK) ON CM.customerId = CDL.customerId  
   --INNER JOIN TBL_BANK_DEPOSIT_TXN_MAPPING DM ON DM.DEPOSIT_LOG_ID = cast(CDL.TRANID as varchar)  
   --INNER JOIN REMITTRAN RT ON RT.HOLDTRANID = DM.HOLD_TRAN_ID  
   --WHERE cdl.isSkipped = 0  
   --and cdl.tranDate between @from and @to + ' 23:59:59'  
  
   --UNION ALL  
   --GET MAPPED AND APPROVED  BUT COULD OR COULD NOT BE MAPPED WITH TRANSACTION  
   SELECT   tranId  
     ,cm.fullName  
     ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
     ,depositAmount  
     ,paymentAmount  
     ,particulars   
     ,cdl.approvedby  
     ,cdl.bankName  
     ,processedBy  
     , CASE WHEN TBD.HOLD_TRAN_ID IS NULL THEN 'Mapped,Approved But Not Mapped With Transaction' ELSE CAST(RT.id AS varchar) END [TransactionId]  
   FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
   INNER JOIN customerMaster CM (NOLOCK) ON CM.customerId = CDL.customerId  
   LEFT JOIN TBL_BANK_DEPOSIT_TXN_MAPPING TBD (NOLOCK) ON TBD.DEPOSIT_LOG_ID = CDL.tranId  
   LEFT JOIN REMITTRAN RT (NOLOCK) ON CAST(RT.holdTranId AS varchar) = TBD.HOLD_TRAN_ID  
   WHERE processedBy is not null and  cdl.approvedBy IS NOT NULL  
   and cdl.isSkipped = 0  
   AND cdl.tranDate between @from and @to + ' 23:59:59'  
  
   UNION ALL  
   --GET MAPPED DATA  BUT UNAPPROVED  
   SELECT   tranId  
     ,cm.fullName  
     ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
     ,depositAmount  
     ,paymentAmount  
     ,particulars   
     ,cdl.approvedby  
     ,cdl.bankName  
     ,processedBy  
     ,'Mapped But Unapproved' [TransactionId]  
   FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) cdl  
   INNER JOIN customerMaster CM (NOLOCK) ON CM.customerId = CDL.customerId  
   WHERE processedBy is not null and  cdl.approvedBy IS NULL  
   and cdl.isSkipped = 0  
   AND cdl.tranDate between @from and @to + ' 23:59:59'  
  END  
          
 END  
 ELSE IF @FLAG = 's-filteredList'  
 BEGIN  
  DECLARE @sql VARCHAR(500)  
  SET @sql='SELECT   
    tblName = ''unmapped''   
     ,tranId  
    ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
    ,depositAmount  
    ,paymentAmount  
    ,particulars   
    ,bankName  
  FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)  
  WHERE processedBy IS NULL  
  AND processedDate IS NULL  
  AND ISSKIPPED = 0  
  AND customerId IS NULL '  
  IF @trnDate IS NOT NULL  
   SET @sql = @sql + ' AND tranDate = convert(datetime,'''+@trnDate+''')'  
  If @particulars IS NOT NULL  
   SET @sql = @sql + ' AND particulars like ''%'' + '''+@particulars+''' +''%'' '  
  If @amount IS NOT NULL  
   SET @sql = @sql + ' AND depositAmount = '''+cast(@amount as varchar)+''' '  
  SET @sql = @sql + 'order by tranId desc'  
  
  EXEC(@sql)  
  
  SET @sql='SELECT   
    tblName = ''pending''   
    ,tranId  
    ,tranDate = CONVERT(VARCHAR, tranDate, 105)  
    ,depositAmount  
    ,paymentAmount  
    ,particulars   
    ,bankName  
  FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)  
  WHERE processedBy IS NOT NULL  
  AND processedDate IS NOT NULL  
  AND APPROVEDBY IS NULL  
  AND ISSKIPPED = 0  
  AND CUSTOMERID = '''+CAST(ISNULL(@customerId, 0) AS VARCHAR)+''''  
  IF @trnDate IS NOT NULL  
   SET @sql = @sql + ' AND tranDate = convert(datetime,'''+@trnDate+''')'  
  If @particulars IS NOT NULL  
   SET @sql = @sql + ' AND particulars like ''%'' + '''+@particulars+''' +''%'' '  
  SET @sql = @sql + 'order by tranId desc'  
     
  EXEC(@sql)  
  
 END  
 ELSE IF @FLAG = 'DETAIL'  
 BEGIN  
  SELECT fullName  
    ,mobile  
    ,IdTypeName = SV.detailTitle  
    ,idNumber  
    ,state  
    ,city  
    ,street  
    ,membershipId  
    ,email  
    ,dob  
  FROM customerMaster CM(NOLOCK)   
  INNER JOIN staticDataValue SV(NOLOCK) ON  SV.valueId = CM.idType  
  WHERE customerId = @customerId  
 END  
 ELSE IF @FLAG = 'I'  
 BEGIN  
  IF NOT EXISTS (SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE tranId = @tranId AND processedDate IS NULL AND customerId IS NULL)  
  BEGIN  
   EXEC proc_errorHandler 1, 'The log you are trying to Map does not exists or already mapped!', null  
   RETURN;  
  END  
  IF EXISTS (SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE tranId = @tranId AND ISSKIPPED = 1)  
  BEGIN  
   EXEC proc_errorHandler 1, 'The log you are trying to Map does not exists or already skipped!', null  
   RETURN;  
  END  
  IF NOT EXISTS (SELECT 1 FROM CUSTOMERMASTER (NOLOCK) WHERE customerId = @customerId AND approvedDate IS NOT NULL)  
  BEGIN  
   EXEC proc_errorHandler 1, 'The customer you are trying to map does not exists or is not approved yet!', null  
   RETURN;  
  END  
    
  BEGIN TRANSACTION  
   DECLARE @isSettled BIT  
   --UPDATE LOG TABLE AS PROCESSED  
   UPDATE CUSTOMER_DEPOSIT_LOGS SET processedBy = @user  
           ,processedDate = GETDATE()  
           ,customerId = @customerId  
           ,approvedBy = @user  
           ,approvedDate = GETDATE()  
   WHERE tranId = @tranId  
     
   --INSERT INTO TRANSACTION TABLE(MAP DEPOSIT TXN WITH CUSTOMER)  
   INSERT INTO CUSTOMER_TRANSACTIONS (customerId, tranDate, particulars, deposit, withdraw, refereceId, head, createdBy, createdDate,bankId)  
   SELECT @customerId, tranDate, particulars, depositAmount, paymentAmount, tranId, 'Customer Deposit', @user, GETDATE(),@bankId  
   FROM CUSTOMER_DEPOSIT_LOGS  
   WHERE tranId = @tranId  
  
   SELECT @AMOUNT = depositAmount, @TRAN_DATE = tranDate  
   FROM CUSTOMER_DEPOSIT_LOGS  
   WHERE tranId = @tranId  
  
   SET @TRAN_DATE = GETDATE()  
     
   UPDATE CUSTOMERMASTER SET AVAILABLEBALANCE = ISNULL(AVAILABLEBALANCE, 0) + @AMOUNT  
   WHERE CUSTOMERID = @customerId  
  
   --ac num of jp-post   
   SET @RECEIVER_ACC_NUM = '100241011536'  
   IF EXISTS(SELECT * FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE ISEODDONE = 1 AND TRANID = @tranId)    
    SET @RECEIVER_ACC_NUM = '101139273793'   
  
   --get customer ac number  
   SELECT @customer_Acc_num = walletAccountNo   
   FROM CUSTOMERMASTER (NOLOCK)   
   where CUSTOMERID = @customerId  
  
   --voucher entry for TRANSIT ACC    
   INSERT INTO Fastmoneypro_Account.DBO.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date    
    ,rpt_code,trn_currency,field1,field2)     
   SELECT @SESSION_ID,@user,@customer_Acc_num,'j','cr',@AMOUNT,@AMOUNT,1,@TRAN_DATE    
    ,'USDVOUCHER','JPY',@tranId,'Customer Deposit'    
      
   --voucher entry for JP POST   
   INSERT INTO Fastmoneypro_Account.DBO.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date    
    ,rpt_code,trn_currency,field1,field2)     
   SELECT @SESSION_ID,@user,@RECEIVER_ACC_NUM,'j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE    
    ,'USDVOUCHER','JPY',@tranId,'Customer Deposit'    
  
   SET @NARRATION = 'Customer deposit mapping dtd: '+@TRAN_DATE  
     
   IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION  
  
   EXEC proc_errorHandler 0, 'Data Mapped Successfully!', null  
  
   EXEC FastmoneyPro_Account.DBO.[spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@TRAN_DATE,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@user    
   --EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_DEPOSIT_REFUND_VOUCHER_ENTRY @flag = 'D', @user = @user, @rowId = @tranId, @isSettled = @isSettled  
 END  
 ELSE IF @flag='skipped'  
 BEGIN  
     UPDATE dbo.CUSTOMER_DEPOSIT_LOGS  
   SET isSkipped=@isSkipped,skippedBy=@user,skippedDate=GETDATE()  
   WHERE tranId=@tranId  
  EXEC proc_errorHandler 0, 'Data updated successfully!', null  
  RETURN  
 END  
 ELSE IF @flag = 'deposit-approve'  
 BEGIN  
  IF EXISTS(SELECT * FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE TRANID = @tranId AND APPROVEDDATE IS NOT NULL)  
  BEGIN  
   EXEC proc_errorHandler 1, 'This mapping either does not exist or is already approved!', null  
   RETURN  
  END  
  
  SELECT @isSettled = isSettled, @AMOUNT = depositAmount, @NARRATION = particulars ,@TRAN_DATE = tranDate, @customerId = customerId  
  FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)  
  WHERE tranId = @tranId  
  
  SET @TRAN_DATE = GETDATE()  
  
  UPDATE CUSTOMER_DEPOSIT_LOGS SET APPROVEDBY = @USER, APPROVEDDATE = GETDATE()  
  WHERE tranId = @tranId  
          
  UPDATE CUSTOMERMASTER SET AVAILABLEBALANCE = ISNULL(AVAILABLEBALANCE, 0) + @AMOUNT  
  WHERE CUSTOMERID = @customerId  
  
  --start process for voucher entry  
  --ac num of jp-post   
  SET @RECEIVER_ACC_NUM = '100241011536'  
  IF EXISTS(SELECT * FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE ISEODDONE = 1 AND TRANID = @tranId)    
   SET @RECEIVER_ACC_NUM = '101139273793'  
    
  --get customer ac number  
  SELECT @customer_Acc_num = AC.ACCT_NUM FROM FastmoneyPro_Account.DBO.ac_master (NOLOCK) AC  
  INNER JOIN FastMoneyPro_Remit.DBO.CUSTOMERMASTER (NOLOCK) CM ON CM.walletAccountNo = AC.acct_num  
  where CM.CUSTOMERID = @customerId  
  
  --voucher entry for TRANSIT ACC    
  INSERT INTO Fastmoneypro_Account.DBO.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date    
   ,rpt_code,trn_currency,field1,field2)     
  SELECT @SESSION_ID,@user,@customer_Acc_num,'j','cr',@AMOUNT,@AMOUNT,1,@TRAN_DATE    
   ,'USDVOUCHER','JPY',@tranId,CASE WHEN @RECEIVER_ACC_NUM = '101139273793' THEN 'Customer Deposit Untransected' ELSE 'Customer Deposit' END  
      
  --voucher entry for JP POST   
  INSERT INTO Fastmoneypro_Account.DBO.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date    
   ,rpt_code,trn_currency,field1,field2)     
  SELECT @SESSION_ID,@user,@RECEIVER_ACC_NUM,'j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE    
   ,'USDVOUCHER','JPY',@tranId,CASE WHEN @RECEIVER_ACC_NUM = '101139273793' THEN 'Customer Deposit Untransected' ELSE 'Customer Deposit' END  
  
  SET @NARRATION = LTRIM(RTRIM(@NARRATION))    
      
  EXEC FastmoneyPro_Account.DBO.[spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@TRAN_DATE,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@user    
 END  
 ELSE IF @flag = 'reject'  
 BEGIN  
    
  INSERT INTO TBL_UNMAP_DEPOSIT_LOGS  
  SELECT CUSTOMERID, tranId, processedBy, processedDate, @USER, GETDATE()  
  FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)  
  WHERE tranId = @tranId  
  
  --UPDATE LOG TABLE AS PROCESSED  
  UPDATE CUSTOMER_DEPOSIT_LOGS SET processedBy = NULL  
         ,processedDate = NULL  
         ,customerId = NULL  
  WHERE tranId = @tranId  
      
  DELETE FROM CUSTOMER_TRANSACTIONS WHERE refereceId = @tranId AND head = 'Customer Deposit'  
  
  --DELETE FROM  TBL_BANK_DEPOSIT_TXN_MAPPING where deposit_log_id = @tranId and customer_Id  = @customerId  
  
  EXEC proc_errorHandler 0, 'Data Unmapped Successfully!', null  
 END  
 ELSE IF @flag = 'unmap'  
 BEGIN  
    
  select * INTO #Temp5 FROM DBO.SPLIT(',',@tranIds)  
  SELECT @noOfTranIds = COUNT(*) FROM #Temp5  
  WHILE(@noOfTranIds > 0)  
  BEGIN  
   SELECT @tranId = value   
   FROM #Temp5   
   WHERE id = @noOfTranIds  
  
   BEGIN TRANSACTION  
    INSERT INTO TBL_UNMAP_DEPOSIT_LOGS  
    SELECT CUSTOMERID, tranId, processedBy, processedDate, @USER, GETDATE()  
    FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)  
    WHERE tranId = @tranId  
  
    --UPDATE LOG TABLE AS PROCESSED  
    UPDATE CUSTOMER_DEPOSIT_LOGS SET processedBy = NULL  
           ,processedDate = NULL  
           ,customerId = NULL  
    WHERE tranId = @tranId  
      
    DELETE FROM CUSTOMER_TRANSACTIONS WHERE refereceId = @tranId AND head = 'Customer Deposit'  
  
    IF @@TRANCOUNT > 0  
     COMMIT TRANSACTION  
    --EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_DEPOSIT_REFUND_VOUCHER_ENTRY @flag = 'D', @user = @user, @rowId = @tranId, @isSettled = @isSettled  
    SET @noOfTranIds = @noOfTranIds - 1  
   END  
  EXEC proc_errorHandler 0, 'Data Unmapped Successfully!', null  
 END  
 ELSE IF @flag = 'i-multiple'  
 BEGIN  
  select * INTO #Temp4 FROM DBO.SPLIT(',',@tranIds)  
  
  SELECT @noOfTranIds = COUNT(*) FROM #Temp4  
  WHILE(@noOfTranIds > 0)  
  BEGIN  
   SELECT @tranId=value FROM #Temp4 WHERE id = @noOfTranIds  
  
   IF NOT EXISTS (SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE tranId = @tranId AND processedDate IS NULL AND customerId IS NULL)  
   BEGIN  
    EXEC proc_errorHandler 1, 'The log you are trying to Map does not exists or already mapped!', null  
    RETURN;  
   END  
  
   IF NOT EXISTS (SELECT 1 FROM CUSTOMERMASTER (NOLOCK) WHERE customerId = @customerId AND approvedDate IS NOT NULL )  
   BEGIN  
    EXEC proc_errorHandler 1, 'The customer you are trying to map does not exists or is not approved yet!', null  
    RETURN;  
   END  
      
   BEGIN TRANSACTION  
    --UPDATE LOG TABLE AS PROCESSED  
    UPDATE CUSTOMER_DEPOSIT_LOGS SET processedBy = @user  
           ,processedDate = GETDATE()  
           ,customerId = @customerId  
    WHERE tranId = @tranId  
      
    --INSERT INTO TRANSACTION TABLE(MAP DEPOSIT TXN WITH CUSTOMER)  
    INSERT INTO CUSTOMER_TRANSACTIONS (customerId, tranDate, particulars, deposit, withdraw, refereceId, head, createdBy, createdDate,bankId)  
    SELECT @customerId, tranDate, particulars, depositAmount, paymentAmount, tranId, 'Customer Deposit', @user, GETDATE(),@bankId  
    FROM CUSTOMER_DEPOSIT_LOGS  
    WHERE tranId = @tranId  
  
      
    IF @@TRANCOUNT > 0  
     COMMIT TRANSACTION  
    --EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_DEPOSIT_REFUND_VOUCHER_ENTRY @flag = 'D', @user = @user, @rowId = @tranId, @isSettled = @isSettled  
    SET @noOfTranIds = @noOfTranIds - 1  
   END  
   EXEC proc_errorHandler 0, 'Data Mapped Successfully!', null  
  END   
 ELSE IF @flag = 'getMappedDeposits'  
 BEGIN  
  
  DECLARE  @table    VARCHAR(MAX)  
   ,@select_field_list VARCHAR(MAX)  
   ,@extra_field_list VARCHAR(MAX)  
   ,@sql_filter  VARCHAR(MAX)  
 SET @sortBy = 'tranId'  
 SET @sortOrder = 'desc'  
  
 SET @table ='(  
  SELECT   
    TS.customerId  
    ,TS.fullName  
    ,CSL.particulars  
    ,CSL.depositAmount  
    ,CSL.tranId  
  FROM remittrantemp rt (NOLOCK)  
  INNER JOIN transenderstemp ts (NOLOCK) ON ts.tranid = rt.id  
  INNER JOIN customer_deposit_logs csl (NOLOCK) ON csl.customerid = ts.customerid  
  WHERE rt.id = '''+CAST(@tranId AS VARCHAR)+'''  
  AND CSL.APPROVEDBY IS NULL'  
  
 SET @table = @table + ')x'  
 SET @sql_filter = ''  
   
 SET @select_field_list ='  
     customerId,tranId,fullName,particulars,depositAmount  
    '   
 EXEC dbo.proc_paging  
   @table,@sql_filter,@select_field_list,@extra_field_list  
   ,@sortBy,@sortOrder,@pageSize,@pageNumber  
  
 END  
 ELSE IF @flag = 'refund'  
 BEGIN  
  IF NOT EXISTS(SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS where tranid = @tranId)  
  BEGIN  
   EXEC proc_errorHandler 1, 'The deposit trying to map does not exists!', null  
   RETURN;  
  END  
    
  IF EXISTS(SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS where tranid = @tranId AND (APPROVEDDATE IS NOT NULL OR PROCESSEDDATE IS NOT NULL OR ISSKIPPED = 1))  
  BEGIN  
   EXEC proc_errorHandler 1, 'The deposit trying to map does not exists or already processed!', null  
   RETURN;  
  END  
  
  UPDATE CUSTOMER_DEPOSIT_LOGS SET isSkipped = 1   
     ,skippedDate = GETDATE()  
     ,skippedBy= @user   
     ,SKIPREMARKS = ISNULL(@particulars, 'Refund')  
  WHERE tranid = @tranId  
  
  EXEC proc_errorHandler 0, 'Deposit Refunded Successfully!', null  
  
 END  
 ELSE IF @flag = 'skip'  
 BEGIN  
  IF NOT EXISTS(SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS where tranid = @tranId)  
  BEGIN  
   EXEC proc_errorHandler 1, 'The deposit trying to map does not exists!', null  
   RETURN;  
  END  
    
  IF EXISTS(SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS where tranid = @tranId AND (APPROVEDDATE IS NOT NULL OR PROCESSEDDATE IS NOT NULL OR ISSKIPPED = 1))  
  BEGIN  
   EXEC proc_errorHandler 1, 'The deposit trying to map does not exists or already processed!', null  
   RETURN;  
  END  
  
  UPDATE CUSTOMER_DEPOSIT_LOGS SET isSkipped = 1   
     ,skippedDate = GETDATE()  
     ,skippedBy= @user   
  WHERE tranid = @tranId  
  
  EXEC proc_errorHandler 0, 'Deposit Skippend Successfully!', null  
  
 END  
 ELSE IF @flag = 'available-balance'  
 BEGIN  
  SELECT @customerId = customerId  
  FROM TRANSENDERSTEMP S(NOLOCK)  
  WHERE S.TRANID = @tranId  
  
  SELECT DBO.FNAGetCustomerAvailableBalance_New(@customerId)  
 END 
 ELSE IF @flag = 'map-txn'
	BEGIN
		DECLARE @CAMT MONEY, @AVAILABLEBALANCE MONEY

		SELECT @customerId = ST.customerId, @CAMT = RT.CAMT
		FROM REMITTRANTEMP RT(NOLOCK)
		INNER JOIN TRANSENDERSTEMP ST(NOLOCK) ON ST.TRANID = RT.ID
		WHERE RT.ID = @ID

		IF @customerId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is either approved or invalid!', null
			RETURN
		END	

		SELECT @amount = depositAmount
		FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) 
		WHERE TRANID = @TRANID AND APPROVEDDATE IS NULL

		IF @amount = 0
		BEGIN
			EXEC proc_errorHandler 1, 'This is not a valid customer deposit!', null
			RETURN
		END
		IF @amount IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Mapping is either mapped or invalid!', null
			RETURN
		END
		
		EXEC PROC_CUSTOMER_DEPOSITS @flag = 'i-multiple', @user = @user, @tranIds = @TRANID, @customerId = @customerId
		
		EXEC PROC_INSERT_JP_DEPOSIT_TXN_LOG @FLAG = 'I', @TRANID = @ID, @CUSTOMERID = @customerId, @CAMT = @CAMT


		update REMITTRANTEMP set collmode = 'Bank Deposit' WHERE ID = @ID

		EXEC proc_errorHandler 1, 'Changes made successfuly!', null
	END 
END TRY  
BEGIN CATCH  
 IF @@TRANCOUNT > 0  
  ROLLBACK TRAN  
 SELECT 1 errorCode, ERROR_MESSAGE() Msg, NULL Id  
END CATCH  
  
  
--CREATE TABLE TBL_UNMAP_DEPOSIT_LOGS  
--(  
-- ROW_ID INT IDENTITY(1,1) PRIMARY KEY  
-- ,CUSTOMER_ID BIGINT  
-- ,TRAN_ID BIGINT  
-- ,MAPPED_BY VARCHAR(50)  
-- ,MAPPED_DATE DATETIME  
-- ,UNMAPPED_BY VARCHAR(50)  
-- ,UNMAPPED_DATE DATETIME  
--)  

