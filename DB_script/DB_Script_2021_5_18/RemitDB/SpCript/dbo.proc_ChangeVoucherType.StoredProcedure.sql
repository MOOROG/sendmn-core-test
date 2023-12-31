USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ChangeVoucherType]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec proc_ChangeVoucherType 'c','3','y','y'

CREATE procEDURE [dbo].[proc_ChangeVoucherType]
	@flag char(1),
	@vno varchar(20),
	@vt1 varchar(10),
	@vt2 varchar(10),
	@user varchar(20)=null
AS
SET NOCOUNT ON;
IF @flag = 'c'
BEGIN


	set @vt2=lower(@vt2)
	
	declare @ref_num varchar(20)
		
	if @vt2='j'
		select @ref_num=journal_voucher from billSetting

	if @vt2='c'
		select @ref_num=contra_voucher from billSetting

	if @vt2='p'
		select @ref_num=purchase_voucher from billSetting
		
	if @vt2='y'
		select @ref_num=payment_voucher from billSetting

	if @vt2='r'
		select @ref_num=receipt_voucher from billSetting


BEGIN TRANSACTION

	if @vt2='p'
		update billSetting set purchase_voucher=cast(purchase_voucher as float)+1 
		
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
	if @vt2='j'
		update billSetting set journal_voucher=cast(journal_voucher as float)+1 
		
		IF (@@ERROR <> 0) GOTO QuitWithRollback 

	if @vt2='y'
		update billSetting set payment_voucher=cast(payment_voucher as float)+1 
		
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
	if @vt2='r'
		update billSetting set receipt_voucher=cast(receipt_voucher as float)+1 
		
		IF (@@ERROR <> 0) GOTO QuitWithRollback 

	if @vt2='c'
		update billSetting set contra_voucher=cast(contra_voucher as float)+1 
		
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
			
	IF EXISTS (Select tran_id from tran_master with (nolock) where tran_type = @vt1 and ref_num = @vno)
		BEGIN
				Update tran_master set tran_type = @vt2, ref_num=@ref_num 
				where  tran_type = @vt1 and ref_num = @vno
				
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				update tran_masterDetail set tran_type = @vt2, ref_num=@ref_num 
				where  tran_type = @vt1 and ref_num = @vno
				
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				Select 'UPDATE SUCCESS NEW VOUCHER NO: '+ @ref_num
				
				Exec JobHistoryRecord 'i','VOUCHER TYPE CHANGED',@vt1,@vt2,@vno ,'',@user
				
		END
	ELSE
		 Select 'Voucher not Exists or type mismatched!!!'


COMMIT TRANSACTION


GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 



EndSave: 


END


GO
