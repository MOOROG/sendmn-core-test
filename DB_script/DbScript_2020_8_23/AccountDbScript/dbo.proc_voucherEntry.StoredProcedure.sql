USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_voucherEntry]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_voucherEntry]
(
	@flag			CHAR(1),
	@sessionID		VARCHAR(50) = null,
	@entry_user_id VARCHAR(50) = null,
	@acct_num		VARCHAR(20) = null,
	@part_tran_type VARCHAR(5) = null,
	@tran_amt		MONEY = null,
	@tran_date		DATE = null,
	@tran_id		int = null
)
AS
Set nocount on
IF @flag = 'i'
BEGIN 
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,part_tran_type,tran_amt,tran_date)
	SELECT @sessionID,@entry_user_id,@acct_num,@part_tran_type,@tran_amt,GETDATE() 
	
	exec proc_errorHandler 0,'Record Inserted successfully!',null
	return
END

else IF @flag = 's'
BEGIN
	SELECT t.tran_id,t.part_tran_type, t.tran_amt,t.acct_num+' | '+a.acct_name as acct_num 
	FROM temp_tran t(nolock)
	INNER JOIN ac_master a(nolock) on t.acct_num= a.acct_num
	WHERE sessionID=@sessionID
	return
END
else if @flag='d'
BEGIN
	Delete from temp_tran where tran_id = @tran_id
	exec proc_errorHandler 0,'Record Deleted successfully!',null
	return
END


--truncate table temp_tran


GO
