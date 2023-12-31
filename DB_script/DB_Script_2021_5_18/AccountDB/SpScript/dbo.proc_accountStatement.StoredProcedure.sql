USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_accountStatement]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_accountStatement]
	 @flag				CHAR(20)	
	,@acct_num			VARCHAR(30)	= NULL
	,@acct_name			VARCHAR(30)	= NULL		
	,@acct_id			INT			= NULL
	,@ac_currency		VARCHAR(50) = NULL
	,@gl_code			VARCHAR(50) = NULL	
	,@acct_type			VARCHAR(50) = NULL	
	,@createdBy			VARCHAR(50) = NULL
	,@modifiedBy		VARCHAR(50) = NULL
	,@haschanged		CHAR(1)		= NULL	
	,@agentID			VARCHAR(10) = NULL
	
	,@user				VARCHAR(50) = NULL
	,@sortBy			VARCHAR(50)	= NULL
	,@sortOrder			VARCHAR(5)	= NULL
	,@pageSize			INT			= NULL
	,@pageNumber		INT			= NULL  
AS
/*
	@flag
	s	= select all (with dynamic filters)
	
*/

SET NOCOUNT ON

BEGIN TRY
	DECLARE
	        @sql VARCHAR(MAX)
	
	IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)
			,@TREE_sape			VARCHAR(20)
		
		
			
		--IF @sortBy IS NULL  
			SET @sortBy = 'acct_id'			
	
		SET @table = '(		
						select acct_id
						,acct_num
						,acct_name
						,dr_bal_lim
						,clr_bal_amt
						,ac_currency
						,usd_amt
						,flc
						,flc_amt
						,created_date
						,modified_date
						,gl_code
						,acct_ownership
						,ISNULL(acct_cls_flg ,''o'') AS acct_cls_flg 
						,agent_id
						FROM ac_master WITH (NOLOCK) where 1=1
					  ) x'	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
							 acct_id
							,acct_num
							,acct_name
							,dr_bal_lim
							,clr_bal_amt
							,ac_currency
							,usd_amt, flc
							,flc_amt
							,created_date
							,modified_date
							,acct_cls_flg
							,gl_code
							,acct_ownership
						'
		
					
		IF @agentID IS NOT NULL
		BEGIN
			SELECT @agentID = AGENT_ID FROM agentTable WHERE map_code = @agentID
			SET @sqlFilter = @sqlFilter + ' AND agent_id = ''' + @agentID + ''''
		END
		IF @acct_num IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND acct_num LIKE ''' + @acct_num + '%'''
			
		IF @acct_name IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND acct_name LIKE ''' + @acct_name + '%'''
			
		IF @gl_code IS NOT NULL
		BEGIN
			SELECT @TREE_sape = tree_sape FROM GL_Group (nolock) where gl_code = @gl_code
			SET @sqlFilter = @sqlFilter + ' AND gl_code IN (select gl_code from GL_Group(NOLOCK) where left(tree_sape,len('''+@TREE_sape+''')) = '''+@TREE_sape+''')'
		END
		IF @acct_type IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND acct_ownership = ''' + @acct_type + ''''

		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber
			
	END		
	IF @flag = 'D'
		BEGIN
			
			SELECT @acct_num = acct_num,@acct_name = acct_name FROM ac_master WHERE acct_id = @acct_id;

			IF EXISTS(SELECT 'A' FROM tran_master WHERE ACC_NUM = @acct_num)
			BEGIN
				exec proc_errorHandler 1,'Voucher entered account can not deleted',@acct_id
				RETURN
			END

			insert into job_history(job_name,job_time,job_user,job_value,job_remarks,update_row,old_value) 
			values ('ACCOUNT DELETED',getdate(),@user,@acct_num,@acct_num+'|'+@acct_name,@acct_id,'')

			DELETE FROM ac_master WHERE acct_id = @acct_id;
			exec proc_errorHandler 0,'Record deleted successfuly',@acct_id
			RETURN	
		END	
END TRY
BEGIN CATCH
END CATCH


GO
