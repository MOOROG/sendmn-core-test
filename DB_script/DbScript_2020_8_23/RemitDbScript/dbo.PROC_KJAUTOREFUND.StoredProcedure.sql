ALTER  PROC [dbo].[PROC_KJAUTOREFUND]
(
	@flag					VARCHAR(20)
	,@pCustomerId			BIGINT			= NULL	
	,@pCustomerSummary  	VARCHAR(20) 	= NULL
	,@pAmount 				MONEY 			= NULL	
	,@pAction 				VARCHAR(10) 	= NULL
	,@pActionDate 			DATETIME 		= NULL
	,@pActionBy 			VARCHAR(50) 	= NULL	
	,@pBankCode				VARCHAR(50)		= NULL
	,@pBankAccountNo		VARCHAR(20)		= NULL			
	,@pRowId				BIGINT			= 0			
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @vRowId 			BIGINT = 0
	DECLARE @vBalance 			MONEY
	DECLARE @TEMPID				BIGINT = 0
	DECLARE @vBankCode			VARCHAR(4)
	DECLARE @vBankAccountNo		VARCHAR(20)
	DECLARE @vRefundAmount		MONEY
	DECLARE @vwalletAccountNo VARCHAR(20)

	DECLARE @tempTbl TABLE (errorcode VARCHAR(5), msg VARCHAR(MAX), id VARCHAR(50))
	------------------------------------------------
	--고객이 입금이체를 신청
	------------------------------------------------
	IF @flag = 'REQ'
	BEGIN
		------------------------------------------------
		-- 실계좌정보를 가져온다.
		------------------------------------------------
		SELECT 		@vBankCode 		= bl.bankCode, 
					@vBankAccountNo	= bankAccountNo,
					@vBalance 		= dbo.FNAGetCustomerACBal(cm.Email),
					@vwalletAccountNo= cm.walletAccountNo
		FROM 		customerMaster 	cm (NOLOCK) 
		INNER JOIN dbo.KoreanBankList bl (NOLOCK) ON cm.bankName=bl.rowId
		WHERE 		customerId=@pCustomerId  
		AND ISNULL(onlineUser,'N')='Y'   
		AND ISNULL(islocked,'N')='N'	
		
		------------------------------------------------
		-- 잔고 체크
		------------------------------------------------
		IF ISNULL(@vBankAccountNo,'') = '' 
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Request Found .', @pCustomerId;
			RETURN;
		END	
		IF (ISNULL(@pAmount,0) > @vBalance)
		BEGIN
			EXEC proc_errorHandler 1, 'Request balance is insufficient!', @pCustomerId;
			RETURN;
		END	
		IF (ISNULL(@pAmount,0) <10000)
		BEGIN
			EXEC proc_errorHandler 1, 'Request amount is invalid', @pCustomerId;
			RETURN;
		END		
		
		------------------------------------------------
		BEGIN TRANSACTION
		------------------------------------------------
		
		-- refundAmount = requestAmount - 수수료(1000)
		SET @vRefundAmount = @pAmount - 1000

		------------------------------------------------
		-- 고객의 잔고 = 잔고 - 입금이체액
		------------------------------------------------
		SET @vBalance = @vBalance - @pAmount

		------------------------------------------------
		-- KJ_AUTO_REFUND 테이블에 'REQ'로 INSERT
		------------------------------------------------
		INSERT INTO KJ_AUTO_REFUND(	customerId, 		bankCode,			bankAccountNo,		customerSummary, 	
									requestAmount, 		refundAmount,		action,				actionDate,			actionBy,Balance,refundType)					
		SELECT 						@pCustomerId, 		@vBankCode,			@vBankAccountNo, 	@pCustomerSummary,	
									@pAmount,			@vRefundAmount,		@pAction,			GETDATE(), 			@pActionBy,@vBalance,'Wallet'					
		
		SET @vRowId = @@IDENTITY

		INSERT INTO @tempTbl(errorcode, msg, id)
		EXEC proc_CustomerTxnStatement @flag = 'refund', @user = 'online', @IdNumber =@vwalletAccountNo, @chargeAmt = 1000, @refundAmt = @pAmount

		IF EXISTS(SELECT '' FROM @tempTbl WHERE errorcode = 1)
		BEGIN
			EXEC proc_errorHandler 1, 'Error occured while requesting.', 0;
		END
		ELSE
		BEGIN
			SELECT '0' errorCode,@vBankCode vBankCode,@vRowId ID
		END
		------------------------------------------------
		COMMIT TRANSACTION
		------------------------------------------------
		

		--EXEC proc_errorHandler 0, 'Data Saved Successfully!', @TEMPID;
		
			
	END	
	IF @flag = 'Autodebit_REQ'
	BEGIN
		------------------------------------------------
		BEGIN TRANSACTION
		------------------------------------------------
		------------------------------------------------
		-- KJ_AUTO_REFUND 테이블에 'Autodebit_REQ'로 INSERT
		------------------------------------------------
		INSERT INTO KJ_AUTO_REFUND(	customerId, 		bankCode,			bankAccountNo,		customerSummary, 	
									requestAmount, 		refundAmount,		action,				actionDate,			actionBy		,Balance		,refundType)					
		SELECT 						@pCustomerId, 		@pBankCode,			@pBankAccountNo, 	@pCustomerSummary,	
									@pAmount,			@pAmount,			'REQ',			GETDATE(), 			@pActionBy		,@pAmount		,'AutoDebit'						
		
		SET @vRowId = @@IDENTITY

		--EXEC proc_errorHandler 0, 'Data Saved Successfully!', @TEMPID;
		SELECT '0' errorCode,@vBankCode vBankCode,@vRowId id
		
		------------------------------------------------
		COMMIT TRANSACTION
		------------------------------------------------	
	END		
	IF @flag = 'SUCCESS'
	BEGIN	
		
		--------------------------------------------------
		---- KJ_AUTO_REFUND 테이블에서 'REQ' 데이타를 가져온다.
		--------------------------------------------------
		--SELECT 	TOP(1) 
		--		@vRefundType	= refundType,
		--		@pActionBy		= actionBy
		--FROM 	KJ_AUTO_REFUND
		--WHERE 	rowId = @pRowId
		--AND 	customerId = @pCustomerId
		--AND 	[action] IN( 'REQ','Autodebit_REQ')
		
		------------------------------------------------
		BEGIN TRANSACTION
		------------------------------------------------
		
		------------------------------------------------
		-- KJ_AUTO_REFUND 테이블에 'SUCCESS'로 UPDATE
		------------------------------------------------
		UPDATE 	KJ_AUTO_REFUND 
		SET 	action = @pAction
		WHERE 	rowId = @pRowId
		AND 	customerId = @pCustomerId

		EXEC proc_errorHandler 0, 'Data Saved Successfully!', @pCustomerId;
		
		------------------------------------------------
		COMMIT TRANSACTION
		------------------------------------------------
	
	END	
	IF @flag = 'FAIL'
	BEGIN			
		----------------------------------------------------
		------ KJ_AUTO_REFUND 테이블에서 'REQ' 데이타를 가져온다.
		----------------------------------------------------
		----SELECT 	TOP(1) 
		----		@vRowId=rowId
		----FROM 	KJ_AUTO_REFUND
		----WHERE 	customerId=@pCustomerId  
		----AND		requestAmount=@pAmount			
		----AND 	CONVERT(VARCHAR(10), actionDate,120) = CONVERT(VARCHAR(10), GETDATE(), 120)
		----AND 	action = 'REQ'
		
		------------------------------------------------
		BEGIN TRANSACTION
		------------------------------------------------
		
		------------------------------------------------
		-- KJ_AUTO_REFUND 테이블에 'FAIL'로 UPDATE
		------------------------------------------------
		UPDATE 	KJ_AUTO_REFUND 
		SET 	action = @pAction
		WHERE 	rowId = @pRowId
		AND 	customerId = @pCustomerId
		AND 	action = 'REQ'
		
		------------------------------------------------
		-- 실계좌정보를 가져온다.
		------------------------------------------------
		SELECT 		@vBalance 		= availableBalance,
					@vwalletAccountNo= cm.walletAccountNo
		FROM 		customerMaster 	cm (NOLOCK) 
		WHERE 		customerId=@pCustomerId  
		AND ISNULL(onlineUser,'N')='Y'   
		AND ISNULL(islocked,'N')='N'	
		
		------------------------------------------------
		-- 고객의 잔고 = 잔고 + 입금이체액
		------------------------------------------------
		SET @vBalance = @vBalance + @pAmount
		
		UPDATE 	customerMaster 
		SET 	availableBalance = @vBalance
		WHERE 	customerId = @pCustomerId
		
		EXEC proc_errorHandler 0, 'Data Saved Successfully!', @pCustomerId;
		
		insert into TblVirtualBankDepositDetail(processId,obpId,customerName,virtualAccountNo,amount,receivedOn,partnerServiceKey
		,institution,depositor,no,logDate)
		select top 1 0,obpId,customerName,virtualAccountNo, @pAmount,getdate(),'000'
		,institution,depositor,no,getdate() from TblVirtualBankDepositDetail (nolock)
		where virtualAccountNo= @vwalletAccountNo

		set @vRowId = @@IDENTITY

		INSERT INTO SendMnPro_Account.dbo.temp_tran(entry_user_id,acct_num,part_tran_type,tran_amt,field1,field2
		,sessionID,refrence)
		SELECT 'system','100241011536','dr',(@pAmount-1000),@vwalletAccountNo,'Refund Reverse',@vwalletAccountNo,@vRowId 
		union all
		SELECT 'system',@vwalletAccountNo,'cr',@pAmount,@vwalletAccountNo,'Refund Reverse',@vwalletAccountNo,@vRowId  

		INSERT INTO SendMnPro_Account.dbo.temp_tran(entry_user_id,acct_num,part_tran_type,tran_amt,field1,field2
		,sessionID,refrence)
		SELECT 'system','910141097092','dr',1000,@vwalletAccountNo,'Refund Reverse',@vwalletAccountNo,@vRowId

		------------------------------------------------
		COMMIT TRANSACTION
		------------------------------------------------
		DECLARE @vDate date = GETDATE(),@vRemarks varchar(200) = 'being refund reversal to primary ac : '+@vwalletAccountNo

		INSERT INTO @tempTbl(errorcode, msg, id)
		exec SendMnPro_Account.dbo.[spa_saveTempTrn] @flag='i',@sessionID= @vwalletAccountNo,@date=@vDate,@narration = @vRemarks,@company_id=1,@v_type='j',@user='system'

	END	
	IF @flag = 'Autodebit_FAIL'
	BEGIN			
		------------------------------------------------
		BEGIN TRANSACTION
		------------------------------------------------
		
		------------------------------------------------
		-- KJ_AUTO_REFUND 테이블에 'FAIL'로 UPDATE
		------------------------------------------------
		UPDATE 	KJ_AUTO_REFUND 
		SET 	action = @pAction
		WHERE 	rowId = @pRowId
		AND 	customerId = @pCustomerId
		AND 	action = 'REQ'
		
		EXEC proc_errorHandler 0, 'Data Saved Successfully!', @pCustomerId;
		
		------------------------------------------------
		COMMIT TRANSACTION
		------------------------------------------------
	
	END	
	ELSE IF @flag = 'CUSTOMER-INFO'
	BEGIN
		SELECT [customerId]  
			  ,[email]
			  ,[mobile]
			  ,obpId
			  ,BL.bankCode
			  ,BL.bankName
			  ,bankAccountNo
		 FROM dbo.customerMaster CM (NOLOCK) 
		 INNER JOIN dbo.KoreanBankList BL (NOLOCK) ON CM.bankName=BL.rowId
		 WHERE customerId=@pCustomerId  
		 AND isnull(onlineUser,'N')='Y'   
		 AND isnull(islocked,'N')='N'  
	END	
END TRY
BEGIN CATCH
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
		
    DECLARE @errorMessage VARCHAR(MAX);
    --SET @errorMessage = ERROR_MESSAGE();
    SET @errorMessage = 'Error Occur while requesting.'
	
    EXEC proc_errorHandler 1, @errorMessage, @pCustomerId;
	
END CATCH;

GO
