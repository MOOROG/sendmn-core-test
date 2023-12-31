USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_paidToUnpaid]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[Proc_paidToUnpaid] 
	@controlNo varchar(15) 
	,@user      varchar(50)
 
AS 
SET NOCOUNT ON 
	DECLARE @controlNoEncrypted VARCHAR(25) ,@viewMsg varchar(200), @REF_NUM VARCHAR(30)
	DECLARE @tranIdNew VARCHAR(10)
	SET @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	SELECT @tranIdNew = id FROM dbo.remitTran(NOLOCK) WHERE controlNo = @controlNoEncrypted

	IF @tranIdNew IS NULL
	BEGIN
	    exec proc_errorHandler 1,'INVALID TRANSACTION',null
	END

	IF NOT EXISTS(SELECT 'X' FROM remitTran (NOLOCK) WHERE id = @tranIdNew AND tranStatus = 'Paid' and payStatus ='Paid')
	BEGIN
		EXEC proc_errorHandler 1,'ONLY PAID TRANSACTION ALLOW TO UPDATE',null
		RETURN
	END
	BEGIN TRY 
		BEGIN TRANSACTION
		SET @viewMsg = 'PAID TRANSACTION HAS CHANGED TO UNPAID BY : '+@user
		EXEC proc_tranViewHistory 'i', @user, @tranIdNew, @controlNo, NULL,'PaidToUnpaid',@viewMsg

		
		SELECT @REF_NUM = REF_NUM 
		FROM SendMnPro_Account.dbo.tran_master (NOLOCK)
		WHERE FIELD1 = '33TF038325328'
		AND FIELD2 = 'Remittance Voucher'
		AND ISNULL(ACCT_TYPE_CODE, 'SEND') = 'Paid'

		IF @REF_NUM IS NOT NULL
		BEGIN
			DELETE FROM SendMnPro_Account.dbo.tran_master WHERE REF_NUM = @REF_NUM
			DELETE FROM SendMnPro_Account.dbo.tran_masterDetail WHERE REF_NUM = @REF_NUM
		END

		UPDATE remitTran SET
				 tranStatus					= 'Payment'
				,payStatus					= 'Post'
				,paidDate					= null
				,paidDateLocal				= null
				,paidBy						= null
			WHERE id = @tranIdNew

			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'PAID TRANSACTION HAS CHANGED TO UNPAID', NULL
        END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'UNABLE TO PROCESS THE REQUEST THIS TIME', NULL
		END CATCH
RETURN


GO
