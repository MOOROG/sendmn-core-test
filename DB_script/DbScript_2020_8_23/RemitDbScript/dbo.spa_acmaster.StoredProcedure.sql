USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[spa_acmaster]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec spa_acmaster @flag='s',@agent_id=2

CREATE  proc [dbo].[spa_acmaster]
	 @flag						CHAR(1)
	,@acct_id					VARCHAR(50)		= NULL
	,@acct_num					VARCHAR(16)		= NULL 
	,@acct_name					VARCHAR(100)	= NULL 
	,@gl_code					VARCHAR(10)		= NULL 
	,@agent_id					VARCHAR(50)		= NULL 
	,@branch_id					VARCHAR(50)		= NULL 
	,@acct_ownership			VARCHAR(1)		= NULL 
	,@dr_bal_lim				VARCHAR(50)		= NULL 
	,@lim_expiry				VARCHAR(50)		= NULL
	,@acct_rpt_code				VARCHAR(10)		= NULL
	,@acct_type_code			VARCHAR(10)		= NULL
	,@frez_ref_code				VARCHAR(5)		= NULL
	,@acct_cls_flg				VARCHAR(1)		= NULL
	,@clr_bal_amt				VARCHAR(50)		= NULL
	,@system_reserved_amt		VARCHAR(50)		= NULL 
	,@system_reserver_remarks	VARCHAR(80)		= NULL 
	,@lien_amt					VARCHAR(50)		= NULL
	,@lien_remarks				VARCHAR(80)		= NULL
	,@utilised_amt				VARCHAR(50)		= NULL
	,@available_amt				VARCHAR(50)		= NULL
	,@ac_currency				VARCHAR(10)		= NULL
	,@ac_group					VARCHAR(100)	= NULL
	,@ac_sub_group				VARCHAR(100)	= NULL
	,@user						VARCHAR(10)		= NULL
	,@company_id				VARCHAR(10)		= NULL
	,@bill_bybill				VARCHAR(5)		= NULL
AS

SET NOCOUNT ON;
BEGIN TRY
IF @flag='a'
BEGIN
	SELECT * FROM ac_master WITH(NOLOCK)
END

IF @flag='t'
BEGIN
	SELECT * FROM ac_master WITH(NOLOCK)  WHERE acct_id=@acct_id
END 

IF @flag='s'
BEGIN
	SELECT *,
	CASE 
		 WHEN dr_bal_lim=0 THEN 0
		 WHEN dr_bal_lim >0 AND clr_bal_amt<= 0 THEN system_reserved_amt + lien_amt - clr_bal_amt
		 WHEN dr_bal_lim >0 AND clr_bal_amt>0 AND (clr_bal_amt-(system_reserved_amt+ lien_amt))>0 THEN 0
		 WHEN dr_bal_lim >0 AND clr_bal_amt>0 AND (clr_bal_amt-(system_reserved_amt+ lien_amt))< 0 THEN system_reserved_amt + lien_amt - clr_bal_amt
		 ELSE 0 
		 END AS 'UtlAmt'
	FROM ac_master WITH(NOLOCK) WHERE acct_id=@acct_id



END


IF @flag='i'
BEGIN
	    INSERT INTO ac_master (
			 acct_num
			,acct_name
			,gl_code
			,agent_id
			,branch_id
			,acct_ownership
			,dr_bal_lim
			,lim_expiry
			,acct_rpt_code
			,acct_type_code
			,frez_ref_code
			,acct_opn_date
			,clr_bal_amt
			,system_reserved_amt
			,system_reserver_remarks
			,lien_amt
			,lien_remarks
			,utilised_amt
			,available_amt
			,created_date
			,created_by
			,ac_currency
			,ac_group
			,ac_sub_group
			,company_id
			,usd_amt
			,flc_amt
			,bill_by_bill
			)
		VALUES( 
			 @acct_num
			,@acct_name
			,@gl_code
			,@agent_id
			,@branch_id
			,@acct_ownership
			,ISNULL(@dr_bal_lim,0)
			,@lim_expiry
			,@acct_rpt_code
			,@acct_type_code
			,@frez_ref_code
			,GETDATE()
			,0
			,ISNULL(@system_reserved_amt,0)
			,@system_reserver_remarks
			,ISNULL(@lien_amt,0)
			,@lien_remarks
			,0
			,0
			,GETDATE()
			,@user
			,@ac_currency
			,@ac_group
			,@ac_sub_group
			,1
			,0
			,0
			,@bill_bybill
			)

		SET @acct_id=@@IDENTITY
         
		UPDATE ac_master SET 
			AVAILABLE_AMT = ISNULL(DR_BAL_LIM,0) + ISNULL(CLR_BAL_AMT,0) - ISNULL(SYSTEM_RESERVED_AMT,0) - ISNULL(LIEN_AMT,0)
		WHERE acct_id=@acct_id
		
		SELECT 0 error_code, 'INSERT COMPLETED!' mes, @acct_id id		
		--###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'
		EXEC JobHistoryRecord 'i','ACCOUNT ADDED',@acct_name,@gl_code,@acct_ownership ,@acct_id,@user
END

IF @flag='u'
BEGIN

	UPDATE ac_master SET
		 acct_name					= @acct_name
		,agent_id					= @agent_id
		,branch_id					= @branch_id
		,acct_ownership				= @acct_ownership
		,acct_rpt_code				= @acct_rpt_code
		,acct_type_code				= @acct_type_code
		,system_reserver_remarks	= @system_reserver_remarks
		,modified_by				= @user
		,ac_currency				= @ac_currency
		,ac_group					= @ac_group
		,ac_sub_group				= @ac_sub_group
		,modified_date				= getdate()
		,bill_by_bill				= @bill_bybill
	WHERE acct_id = @acct_id
	
	--###### EXEC JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'
	EXEC JobHistoryRecord 'i','ACCOUNT MODIFIED',@acct_name,@gl_code,@acct_ownership ,@acct_id,@user
		
	 SET @acct_id = @@identity
     SELECT 0 error_code, 'UPDATE COMPLETED!' mes, @acct_id id		

END
END TRY

BEGIN CATCH

   IF @@TRANCOUNT >0
       ROLLBACK TRANSACTION 
       SELECT 1 error_code, ERROR_MESSAGE() mes, @acct_id id
       
END CATCH

GO
