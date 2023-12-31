USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcDeleteLedgerGroup]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec ProcDeleteLedgerGroup 'd', '114'    
    
CREATE PROC [dbo].[ProcDeleteLedgerGroup]    
@flag CHAR(1),    
@rowid VARCHAR(20),    
@user VARCHAR(20)=null    
    
AS    
    
SET NOCOUNT ON;    
    
IF @flag='d'    
BEGIN  

	IF EXISTS(SELECT * FROM tran_master WHERE gl_sub_head_code=@rowid)  
	BEGIN
		SELECT '1' ERRORCODE,'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!' AS MSG, NULL ID          
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@rowid,@user ,'',@user 
		RETURN;
	END

	IF EXISTS(SELECT * FROM ac_master WHERE gl_code=@rowid)  
	BEGIN
		SELECT '1' ERRORCODE,'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!' AS MSG, NULL ID          
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@rowid,@user ,'',@user 
		RETURN;
	END
	
	IF EXISTS(SELECT * FROM GL_GROUP WHERE p_id=@rowid)  
	BEGIN
		SELECT '1' ERRORCODE,'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!' AS MSG, NULL ID          
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@rowid,@user ,'',@user 
		RETURN;
	END
	
	DELETE FROM GL_GROUP WHERE gl_code=@rowid    

	EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','SUCCESS',@rowid,@user ,'',@user    

	SELECT '0' ERRORCODE,'DELETE COMPLETED!' AS MSG , NULL ID  
            
END 


GO
