USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_lockTransaction]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

EXEC proc_lockTransaction @flag = 'st', @controlNo = '91598256530'
SELECT * FROM remitTran where controlNo = '91181462426'


select * from staticDataValue where typeid in (5400, 5500)

*/

CREATE proc [dbo].[proc_lockTransaction] 	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@tranId				INT				= NULL
	,@Msg				VARCHAR(MAX)		= NULL

AS

IF @flag = 'lt'
BEGIN

     IF NOT EXISTS (SELECT 'X' FROM remitTran WITH (NOLOCK)
			  WHERE controlNo = @controlNo and tranStatus='Unpaid' and payStatus='payment')
    BEGIN
	   
			 EXEC proc_errorHandler 1, 'Transaction not found', @controlNo
			 RETURN;
    END

    UPDATE remitTran SET
		 lockedBy = @user
		,tranStatus = 'Block'
		,lockedDate = GETDATE()
		,lockedDateLocal = DBO.FNADateFormatTZ(GETDATE(), @user)
	WHERE controlNo = @controlNo 
     and tranStatus='Unpaid' and payStatus='payment'

END
ELSE IF @flag = 'ut'
BEGIN

    IF NOT EXISTS (SELECT 'X' FROM remitTran WITH (NOLOCK)
			  WHERE controlNo = @controlNo and tranStatus='Block' and payStatus='payment')
    BEGIN
	   
			 EXEC proc_errorHandler 1, 'Blocked Transaction not found', @controlNo
			 RETURN;
    END

	UPDATE remitTran SET 
		 lockedBy = @user
		,tranStatus = 'Unpaid'
		,lockedDate = GETDATE()
		,lockedDateLocal = DBO.FNADateFormatTZ(GETDATE(), @user)
	WHERE controlNo = @controlNo
	and tranStatus='Block' and payStatus='payment'


END
ELSE IF @flag = 'st'
BEGIN

    IF NOT EXISTS (SELECT 'X' FROM remitTran WITH (NOLOCK)
			  WHERE controlNo = @controlNo and tranStatus='Unpaid' and payStatus='payment')
    BEGIN
	   
			 EXEC proc_errorHandler 1, 'Transaction not found', @controlNo
			 RETURN;
    END

    SELECT * FROM remitTran WITH (NOLOCK)
    WHERE controlNo = @controlNo 
	and tranStatus='Unpaid' and payStatus='payment'


END


GO
