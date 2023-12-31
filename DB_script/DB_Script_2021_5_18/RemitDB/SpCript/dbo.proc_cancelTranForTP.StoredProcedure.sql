USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cancelTranForTP]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE proc [dbo].[proc_cancelTranForTP]
(
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL	
	,@cancelReason		VARCHAR(200)	= NULL
	,@dt				VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL		
) 

AS
DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(LTRIM(RTRIM(@controlNo))))

IF (@flag = 'cancel')
BEGIN
	DECLARE @tranStatus VARCHAR(50), @payStatus VARCHAR(50)
	SET @dt = ISNULL(@dt, GETDATE())
	SELECT @tranStatus = tranStatus, @payStatus = payStatus FROM dbo.remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	UPDATE remitTran SET
		  tranStatus				= 'Cancel'
		 --,cancelApprovedBy			= @user
		 --,cancelApprovedDate		= @dt
		 --,cancelApprovedDateLocal	= @dt
	WHERE controlNo = @controlNoEncrypted
			
	SELECT 'success' res
END

GO
