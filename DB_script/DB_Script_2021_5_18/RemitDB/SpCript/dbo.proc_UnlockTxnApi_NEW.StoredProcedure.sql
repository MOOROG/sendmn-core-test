USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_UnlockTxnApi_NEW]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_UnlockTxnApi_NEW]
			 @flag				VARCHAR(50)
			,@tranNo			VARCHAR(50)		= NULL
			,@controlNo			VARCHAR(50)		= NULL
			,@tranType			VARCHAR(1)		= NULL
			,@user				VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;

DECLARE @table VARCHAR(MAX)
DECLARE @controlNoEncrypted VARCHAR(50)

-- ## Locked Transaction List
IF @flag = 'list'			
BEGIN
		select 
			tranType = 'I',
			Tranno = id,
			refno = dbo.fnadecryptstring(controlNo),
			receiveAmt = pAmt,
			SenderName = senderName,
			ReceiverName = receiverName,
			lock_dot = lockedDate,
			lock_by = lockedBy,
			lock_status = lockStatus from remitTran rt with(nolock) 
		where lockStatus = 'locked' and tranType = 'I' 
		and tranStatus = 'Payment' and payStatus = 'Unpaid'	

END

-- ## Unlock Transaction
IF @flag = 'u'			
BEGIN		
	update remitTran
		set lockStatus	= 'unlocked'
	where id = @tranNo
	select 0 Code,'Transaction is Unlocked' as Msg
END



GO
