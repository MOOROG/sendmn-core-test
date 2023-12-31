USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcDeleteAccount]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec [ProcDeleteAccount] 'd', '101596','admin'

CREATE proc [dbo].[ProcDeleteAccount]
		 @flag		CHAR(1)
		,@rowid		VARCHAR(20)
		,@user		VARCHAR(20) = NULL

AS

SET NOCOUNT ON;
--BEGIN TRY
IF @flag='d'
BEGIN

	IF NOT EXISTS( SELECT * FROM tran_master WITH(NOLOCK)
	WHERE acc_num =(SELECT acct_num FROM ac_master WHERE acct_id = @rowid)) 
	AND (SELECT clr_bal_amt FROM ac_master WITH(NOLOCK) WHERE acct_id = @rowid)= 0
	BEGIN
	
		DELETE FROM ac_master WHERE acct_id = @rowid
		EXEC JobHistoryRecord 'i','ACCOUNT DELETED','SUCCESS',@rowid,@user ,'',@user
		--select 'DELETE COMPLETED!'
		
		--SET @rowid  = SCOPE_IDENTITY();
		SELECT 0 error_code, 'DELETE COMPLETED!' mes, @rowid id	
		
	END 
	ELSE
	BEGIN
	
	   IF @@TRANCOUNT >0
       ROLLBACK TRANSACTION 
       SELECT 1 error_code, ERROR_MESSAGE() mes, @rowid id
		--select 'SORRY, ACCOUNT ALREADY EXISTS IN VOUCHER!'
		Exec JobHistoryRecord 'i','ACCOUNT DELETED','FAIL',@rowid,@user ,'',@user
	
	END
	
END
--END TRY

--BEGIN CATCH
--    IF @@TRANCOUNT >0
--       ROLLBACK TRANSACTION
     
--     SELECT 1 error_code, ERROR_MESSAGE() mes, @rowid id

--END CATCH


GO
