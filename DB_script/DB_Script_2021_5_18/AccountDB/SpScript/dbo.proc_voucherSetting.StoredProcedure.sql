USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_voucherSetting]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[proc_voucherSetting]
(
	@flag			CHAR(1)
	,@user			VARCHAR(100)	= NULL
	,@Approval_mode	CHAR(1)			= NULL
	,@id			INT				= NULL
	,@sortBy		VARCHAR(50)	= NULL
	,@sortOrder		VARCHAR(5)	= NULL
	,@pageSize		INT			= NULL
	,@pageNumber	INT			= NULL  
)
AS 
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY

	DECLARE 
		 @selectFieldList	VARCHAR(MAX)
		,@extraFieldList	VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@sqlFilter			VARCHAR(MAX)
		
		SET @sortBy = 'created_date'
		set @sortOrder = 'DESC'	
		set @sqlFilter =''
		set @extraFieldList = ''
			
	if @flag='s'
	BEGIN
		set @table = '(SELECT id,V_TYPE
						,case Approval_mode when ''y'' then ''yes'' 
											when ''n'' then ''No'' 
											End as Approval_mode
						,created_by
						,created_date
						,modified_by
						,modified_date 
						FROM VOUCHER_SETTING WITH(NOLOCK) WHERE 1=1 )x '
		
		set @selectFieldList = 'id,V_TYPE,Approval_mode,created_by,created_date,modified_by,modified_date'
		
		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber
			
			
			return
	END
	
	if @flag ='y'
	BEGIN
		SELECT * FROM VOUCHER_SETTING with(nolock) WHERE id = @id
		return
	END
	
	if @flag='u'
	BEGIN
		UPDATE VOUCHER_SETTING 
		SET	Approval_mode  = @Approval_mode
			,modified_by   = @user
			,modified_date = GETDATE()
		WHERE id = @id
		
		EXEC proc_errorHandler 0,'Approval mode changed!',null

		RETURN
		
	END
END TRY
BEGIN CATCH
END CATCH
GO
