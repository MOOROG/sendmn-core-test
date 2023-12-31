USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_accountDetails]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_accountDetails]
	 @flag						VARCHAR(10)
	,@acct_name					VARCHAR(20)			= NULL
	,@acct_num					VARCHAR(20)			= NULL
	,@sortBy					VARCHAR(50)			= NULL
	,@sortOrder					VARCHAR(5)			= NULL
	,@pageSize					INT					= NULL
	,@pageNumber				INT					= NULL
AS

/*
	@flag
	s	= select all (with dynamic filters)
	i	= insert
	u	= update
	a	= select by role id
	d	= delete by role id
	l	= drop down list
		
	[applicationMessage]
	
*/
SET NOCOUNT ON
BEGIN TRY
	
 IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
			
		IF @sortBy IS NULL  
			SET @sortBy = 'created_date'
		IF @sortOrder IS NULL
			SET @sortOrder = 'Desc'
		
	--	SET @msgTo = @admin
	
		--SET @table = '[custodian]'	
		
		SET @table = 'ac_master'	
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
								acct_id
								,acct_num
								,acct_name
								,dr_bal_lim
								,clr_bal_amt
								,ac_currency
								,usd_amt
								,flc
								,flc_amt 
								,convert(varchar,created_date,107) created_date
								,convert(varchar,modified_date,107) modified_date
								,isnull(acct_cls_flg ,''o'') AS acct_cls_flg 
							'
					
		IF @acct_name IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND acct_name  LIKE ''%' + @acct_name  + '%'''
		IF @acct_num  IS NOT NULL
			SET  @sqlFilter = @sqlFilter + ' AND acct_num  LIKE ''%' + @acct_num  + '%'''		
		
		
		
		SET @extraFieldList = ',''<a href ="/CreateLedger/account_modifyglcode.aspx?ID='' + CAST(acct_id AS VARCHAR(50)) + ''&flag=a">Edit</a>'''
		+
		 ' [edit]' 
		
		
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
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT 1 errorCode, ERROR_MESSAGE() mes, NULL id
END CATCH
		
		


GO
