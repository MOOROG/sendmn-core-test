USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcDeleteLedgerGroup]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec ProcDeleteLedgerGroup 'd', '36', 'admin'

CREATE proc [dbo].[ProcDeleteLedgerGroup]
	 @flag		CHAR(1)
	,@rowid		VARCHAR(20)
	,@user		VARCHAR(20)		= NULL

AS

SET NOCOUNT ON;

IF @flag='d'
BEGIN
	
	IF NOT EXISTS(SELECT * FROM ac_master WHERE gl_code=@rowid)
	AND NOT EXISTS( SELECT * FROM GL_GROUP WHERE p_id=@rowid)
	BEGIN
	
		DELETE FROM GL_GROUP WHERE gl_code=@rowid
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','SUCCESS',@rowid,@user ,'',@user
		
		
		--select 'DELETE COMPLETED!'
		--SET @rowid  = SCOPE_IDENTITY();
		SELECT 0 error_code, 'DELETE COMPLETED!' mes, @rowid id	
			
	END 
	ELSE
	BEGIN
	      IF @@TRANCOUNT >0
            ROLLBACK TRANSACTION
		--select 'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!'
		SELECT 1 error_code, ERROR_MESSAGE() mes, @rowid id
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@rowid,@user ,'',@user
	
	END
END



GO
