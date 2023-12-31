USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_PayoutAgentAccount]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[proc_PayoutAgentAccount] (
@Flag				VARCHAR(30)  = NULL
,@TransferType		VARCHAR(100) = NULL
,@User				VARCHAR(150) = NULL
,@rowID				VARCHAR(25)  = NULL
,@sortBy			VARCHAR(50)  = NULL
,@sortOrder			VARCHAR(5)	  = NULL
,@pageSize			INT		  = NULL
,@pageNumber		INT		  = NULL
,@nameOfPartner		VARCHAR(100) = NULL
,@receiveUSDNostro	VARCHAR(50)	= NULL
,@receiveUSDCorrespondent	VARCHAR(50)= NULL
)

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
		 @sql				VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)	
		
		
IF @Flag = 'i'
BEGIN
	INSERT INTO tblPayoutAgentAccount(transferType,nameOfPartner,receiveUSDNostro,receiveUSDCorrespondent,CreatedBy,CreatedDate) 
	VALUES(@TransferType,@nameOfPartner,@receiveUSDNostro,@receiveUSDCorrespondent,@User,GETDATE())

	EXEC proc_errorHandler 0,'Record Saved Successfully', null  RETURN
END

ELSE IF @Flag = 'u'
BEGIN 
	UPDATE tblPayoutAgentAccount SET transferType = @TransferType, nameOfPartner = @nameOfPartner, receiveUSDNostro = @receiveUSDNostro
		,receiveUSDCorrespondent = @receiveUSDCorrespondent, CreatedBy = @User, CreatedDate = GETDATE()
	WHERE RowId = @rowID
	EXEC proc_errorHandler 0,'Record updated successfully.', @rowID
END

ELSE IF @Flag = 'a'
BEGIN
	SELECT p.*,NostroName = a.acct_num+' | '+ a.acct_name,CorrespondentName =c.acct_num+' | '+ c.acct_name FROM tblPayoutAgentAccount p(NOLOCK) 
	inner join ac_master a(nolock)  on a.acct_num = p.receiveUSDNostro
	left join ac_master c(nolock)  on c.acct_num = p.receiveUSDCorrespondent
	WHERE rowId = @rowID
end
ELSE IF @Flag = 's'
BEGIN
	SET @table = '(SELECT * FROM tblPayoutAgentAccount (nolock) WHERE 1=1 )x'
	
	IF @sortBy IS NULL
		SET @sortBy = 'rowId'
	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'

	SET @sql_filter = ''

    IF @nameOfPartner IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND nameOfPartner LIKE ''%' + @nameOfPartner + '%'''

	SET @select_field_list ='rowId,transferType,nameOfPartner,receiveUSDNostro,receiveUSDCorrespondent,CreatedBy,CreatedDate'
			
	EXEC dbo.proc_paging
		 @table
		,@sql_filter
		,@select_field_list
		,@extra_field_list
		,@sortBy
		,@sortOrder
		,@pageSize
		,@pageNumber
END

GO
