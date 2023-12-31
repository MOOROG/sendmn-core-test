USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_fcyvoucherEntry]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_fcyvoucherEntry]
(
	@flag			CHAR(1),
	@tran_id		INT = null,
	@sessionID		VARCHAR(50) = null,
	@acct_num VARCHAR(50) = null,
	@fcyamt		MONEY = null,
	@apprate VARCHAR(5) = null,
	@lcyamt		MONEY = null,
	@tran_date		DATE = null,
	@tran_type		VARCHAR(5) = null,
	@currency VARCHAR(10) = null,
	@createdBy VARCHAR(50) = null
)
AS
Set nocount on
IF @flag = 'i'
BEGIN 
	INSERT INTO temp_transaction(sessionID,acct_num,fcyamt,apprate,lcyamt,tran_date,tran_type,currency,createdBy)
	SELECT @sessionID,@acct_num,@fcyamt,@apprate,@lcyamt,GETDATE(),@tran_type,@currency,@createdBy
	
	exec proc_errorHandler 0,'Record Inserted successfully!',null
	return
END

else IF @flag = 's'
BEGIN
	SELECT t.tran_id,t.fcyamt,t.apprate,t.lcyamt,t.tran_type,t.currency,t.acct_num+' | '+a.acct_name as acct_num 
	FROM temp_transaction t(nolock)
	INNER JOIN ac_master a(nolock) on t.acct_num = a.acct_num
	WHERE sessionID = @sessionID
	return
END
else if @flag='d'
BEGIN
	Delete from temp_transaction where tran_id = @tran_id
	exec proc_errorHandler 0,'Record Deleted successfully!',null
	return
END
GO
