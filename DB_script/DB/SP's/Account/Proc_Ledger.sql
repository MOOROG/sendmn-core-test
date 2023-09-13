
ALTER PROC Proc_Ledger  
 @Flag			 VARCHAR(20)  
,@Type			 VARCHAR(20) = NULL  
,@PId			 VARCHAR(20) = NULL  
,@accountPrefix  VARCHAR(20) = NULL  
  
AS   
BEGIN  
 IF @Flag='header'  
  BEGIN  
   SELECT lable,reportid FROM report_format WITH (NOLOCK) WHERE TYPE= @type ORDER BY CAST(reportid AS INT)  
  END  

 IF @Flag='subheader'  
  BEGIN    
   SELECT gl_code,gl_name AS gl_desec, tree_sape FROM GL_GROUP WITH (NOLOCK) WHERE p_id=@PId ORDER BY gl_code     
  END  
 IF @Flag='subGL'  
  BEGIN    
	   SELECT acct_id,acct_num, acct_name = acct_name + ' / <label style="color:red">'+ISNULL(ac_currency,'KRW')+' </label>',clr_bal_amt 
	   FROM ac_master WITH (NOLOCK) WHERE gl_code=@PId 
	   AND ISNULL(ACCT_RPT_CODE, '') <> 'CA'
	   ORDER BY acct_name    
  END   
    
 IF @Flag='GetGL'  
  BEGIN  
   SELECT gl_code, gl_name AS gl_desec, p_id ,acc_Prefix FROM GL_GROUP WHERE gl_code = @PId  
  END  
 IF @Flag='u'  
  BEGIN 
	  IF EXISTS(SELECT * FROM dbo.GL_GROUP WITH (NOLOCK) WHERE gl_name = @Type  AND gl_code <> @PId )
	  BEGIN
	      SELECT '1' ERRORCODE , 'OPERTAION FAILED' AS MSG , NULL ID 
	  END
	  ELSE
	  BEGIN
			UPDATE GL_GROUP SET gl_name = @type , acc_Prefix = @accountPrefix WHERE gl_code = @PId  

			SELECT '0' ERRORCODE , 'SUCCESSFULLY UPDATED' AS MSG , NULL ID 
	  END 
  END  
 IF @Flag='d'  
  BEGIN  

	IF EXISTS(SELECT * FROM tran_master WHERE gl_sub_head_code=@PId)  
	BEGIN
		SELECT '1' ERRORCODE,'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!' AS MSG, NULL ID          
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@PId,'' ,'','' 
		RETURN;
	END

	IF EXISTS(SELECT * FROM ac_master WHERE gl_code=@PId)  
	BEGIN
		SELECT '1' ERRORCODE,'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!' AS MSG, NULL ID          
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@PId,'' ,'','' 
		RETURN;
	END
	
	IF EXISTS(SELECT * FROM GL_GROUP WHERE p_id=@PId)  
	BEGIN
		SELECT '1' ERRORCODE,'SORRY, SUB GROUP OR ACCOUNT ALREADY EXISTS!' AS MSG, NULL ID          
		EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','FAIL',@PId,'' ,'','' 
		RETURN;
	END
	
	DELETE FROM GL_GROUP WHERE gl_code=@PId    

	EXEC JobHistoryRecord 'i','LEDGER GROUP DELETED','SUCCESS',@PId,'' ,'',''    

  
   SELECT '0' ERRORCODE , 'SUCCESSFULLY DELETED' AS MSG , NULL ID  
  END  
    
 IF @Flag='getLedgerDet'  
  BEGIN  
   SELECT acct_num,acct_name FROM ac_master where gl_code = @PId 
   AND ISNULL(ACCT_RPT_CODE, '') <> 'CA'
   order by acct_name  
  END  
    
END


