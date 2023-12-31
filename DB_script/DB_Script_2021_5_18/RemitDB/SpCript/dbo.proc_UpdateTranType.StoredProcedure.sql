USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_UpdateTranType]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_UpdateTranType]
(
     @flag			    VARCHAR(200)
    ,@user			    VARCHAR(200)		= NULL
    ,@tranType			VARCHAR(200)		= NULL
    ,@controlNo			VARCHAR(200)		= NULL
    ,@newControlNo		VARCHAR(200)		= NULL

)
AS
SET NOCOUNT ON;
BEGIN TRY
IF @flag = 'u'							
BEGIN
	DECLARE @id BIGINT, @oldTranType VARCHAR(30), @tAmt MONEY, @DomInt VARCHAR(50)
	SELECT 
		 @id = id
		,@tAmt = tAmt
		,@oldTranType = paymentMethod		
	FROM remitTran (NOLOCK) 
	WHERE controlNo = dbo.encryptdb(@controlNo)

	IF @tranType = 'Cash Payment' AND @tAmt > 100000 AND RIGHT(@controlNo,1) = 'D' 
	BEGIN
		SELECT 1 error_code, 'Can not update the Mode of payment to CASH PAYMENT. Transfer amount exceeds Limit (Greater than 1,00,000).' mes, null id
		RETURN
	END 
	
	BEGIN TRANSACTION	
		INSERT tranModifyLog(tranId, controlNo, message, createdBy, createdDate, msgType)
		SELECT @id, dbo.encryptdb(@controlNo), 'Mode of payment has been changed from ' + @oldTranType + ' to ' + @tranType + '.', @user, GETDATE(), 'M'
		
		UPDATE remitTRAN SET paymentMethod = @tranType WHERE controlNo = dbo.encryptdb(@controlNo)

		IF @tranType='Cash Payment' 
			SET @tranType='Cash Pay'
		IF @tranType='Bank Deposit' 
			SET @tranType='Bank Transfer'		

		UPDATE SendMnPro_Account.dbo.remit_trn_master SET trn_type = @tranType WHERE trn_ref_no = dbo.fnaencryptstring(@controlNo)
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

   SELECT 0 error_code, 'Record updated successfully.' mes, null id

END
IF @flag='uc'
BEGIN
	SELECT 0 error_code, 'Record updated successfully.' mes, null id
END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
