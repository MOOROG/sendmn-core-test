USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_voucherSettings]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  exec [proc_voucherSettings] @flag ='s'
  exec [proc_voucherSettings] @flag = 's'  ,@pageNumber='1', @pageSize='10', @sortBy=null, @sortOrder=null
*/

CREATE proc [dbo].[proc_voucherSettings]
	 @flag					VARCHAR(10)			= NULL
	,@vtype					VARCHAR(20)			= NULL
	,@approvalmode			VARCHAR(20)			= NULL
	,@sortBy				VARCHAR(50)			= NULL
	,@sortOrder				VARCHAR(5)			= NULL
	,@pageSize				INT					= NULL
	,@pageNumber			INT					= NULL
	,@user					VARCHAR(50)			= NULL
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
		-- select id,v_type,approval_mode,v_code from VOUCHER_SETTING
		SET @table = 'VOUCHER_SETTING'	
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList =	' 
		                         ID
								,v_type
							    ,approval_mode
							    ,v_code								
								'
					
		--IF @acct_name IS NOT NULL
		--	SET @sqlFilter = @sqlFilter + ' AND acct_name  LIKE ''%' + @acct_name  + '%'''
		--IF @acct_num  IS NOT NULL
		--	SET  @sqlFilter = @sqlFilter + ' AND acct_num  LIKE ''%' + @acct_num  + '%'''		
		
		
		
		--SET @extraFieldList = ',''<a href ="/VoucherSetting/EditVoucherSetting.aspx?ID='' + CAST(ID AS VARCHAR(50)) + ''&flag=a"><img src="../../../Images/edit.gif"></img></a>'''
		--+
		-- ' [edit]' 
		
		
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
	
if @flag='u'
begin
		Update VOUCHER_SETTING set approval_mode = @approvalmode
		where  v_type = @vtype
		
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
end	

GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 

EndSave: 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT 1 errorCode, ERROR_MESSAGE() mes, NULL id
END CATCH
		
		


GO
