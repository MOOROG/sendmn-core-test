ALTER  PROC [dbo].[proc_online_PushFromKjBank] 
 @flag						VARCHAR(50)		
,@processId					VARCHAR(50)
,@obpId						VARCHAR(30)     
,@customerName				NVARCHAR(100)     
,@virtualAccountNo			VARCHAR(30)		
,@amount				    VARCHAR(50)		
,@receivedOn				VARCHAR(30)		
,@partnerServiceKey			VARCHAR(5)		
,@institution				VARCHAR(5)		
,@depositor					NVARCHAR(100)		
,@no			            VARCHAR(50)    	
   
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  

IF @flag = 'i'  
BEGIN
	declare @rowId int
	if not exists(select 'a' from customerMaster(nolock) where walletAccountNo = @virtualAccountNo)
	BEGIN 
		INSERT INTO dbo.tblRejectLogVirtualBankDepositRequest( processId ,obpId ,customerName ,virtualAccountNo ,amount ,receivedOn ,partnerServiceKey ,
			institution ,depositor ,[no] ,reason ,logDate)
		SELECT @processId, @obpId, @customerName, @virtualAccountNo, @amount, @receivedOn, @partnerServiceKey,
			@institution, @depositor, @no, 'Invalid Virtual Account Found.', GETDATE()
		SELECT '1' ErrorCode , 'Invalid Virtual Account Found.' Msg , NULL
		return
	END 
	if not exists(select 'a' from customerMaster(nolock) where bankAccountNo = @no)
	begin
		--insert into log
		INSERT INTO dbo.tblRejectLogVirtualBankDepositRequest( processId ,obpId ,customerName ,virtualAccountNo ,amount ,receivedOn ,partnerServiceKey ,
			institution ,depositor ,[no] ,reason ,logDate)
		SELECT @processId, @obpId, @customerName, @virtualAccountNo, @amount, @receivedOn, @partnerServiceKey,
			@institution, @depositor, @no, 'Invalid Primary Bank Account Found.', GETDATE()
		SELECT '1' ErrorCode , 'Invalid Primary Bank Account Found.' Msg , NULL
		return
	END
    IF EXISTS (SELECT 'a' FROM dbo.TblVirtualBankDepositDetail TV (NOLOCK) WHERE TV.depositor = @depositor AND TV.receivedOn = @receivedOn
				AND TV.virtualAccountNo = @virtualAccountNo AND TV.amount = @amount)
	BEGIN
		--insert into log
		INSERT INTO dbo.tblRejectLogVirtualBankDepositRequest( processId ,obpId ,customerName ,virtualAccountNo ,amount ,receivedOn ,partnerServiceKey ,
			institution ,depositor ,[no] ,reason ,logDate)
		SELECT @processId, @obpId, @customerName, @virtualAccountNo, @amount, @receivedOn, @partnerServiceKey,
			@institution, @depositor, @no, 'Duplicate Data', GETDATE()

	    SELECT '1' ErrorCode , 'Same record already exists.' Msg , NULL
		return
	END
	begin tran
		
		----##send sms to customer
		DECLARE @SMSBody VARCHAR(90) = 'Your GME Wallet is successfully credited by KRW '+FORMAT(cast(@amount AS MONEY),'0,00')+' Thank you for using GME.'
		DECLARE @Mobile VARCHAR(20)

		SELECT @Mobile = mobile FROM customerMaster(NOLOCK) WHERE walletAccountNo = @virtualAccountNo
		
		exec proc_CallToSendSMS @FLAG = 'I',@SMSBody = @SMSBody,@MobileNo = @Mobile

		INSERT INTO TblVirtualBankDepositDetail (processId,obpId,customerName,virtualAccountNo,amount,receivedOn  
			,partnerServiceKey,institution,depositor,[no],logDate)   
      
		SELECT  @processId,@obpId,@customerName,@virtualAccountNo,@amount,@receivedOn  
			,@partnerServiceKey ,@institution ,@depositor ,@no ,GETDATE()   
		
		set @rowId = @@IDENTITY

		UPDATE cm SET cm.availableBalance = ISNULL(cm.availableBalance,0) + @amount  
		FROM dbo.customerMaster cm WHERE walletAccountNo=@virtualAccountNo AND bankAccountNo = @no

		INSERT INTO SendMnPro_Account.dbo.temp_tran(entry_user_id,acct_num,part_tran_type,tran_amt,field1,field2,sessionID,refrence,emp_name)
		SELECT 'system','100241011536','dr',@amount,@virtualAccountNo,'Fund Deposit',@virtualAccountNo,@rowId,@depositor union all
		SELECT 'system',@virtualAccountNo,'cr',@amount,@virtualAccountNo,'Fund Deposit',@virtualAccountNo,@rowId,@depositor

    commit tran
	SELECT '0' ErrorCode , 'Record has been added successfully.' Msg , NULL
	SELECT @receivedOn = convert(varchar,getdate(),101),@depositor='being amount deposited on virtual ac : '+@virtualAccountNo
	exec SendMnPro_Account.dbo.[spa_saveTempTrn] @flag='i',@sessionID= @virtualAccountNo,@date=@receivedOn,@narration=@depositor,@company_id=1,@v_type='j',@user='kjBank'

END 

GO
