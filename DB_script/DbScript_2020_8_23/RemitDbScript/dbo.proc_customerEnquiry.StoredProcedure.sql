USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerEnquiry]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[proc_customerEnquiry]
(
 @flag			VARCHAR(30)
,@fullName		VARCHAR(255) = NULL 
,@User		 VARCHAR(150) = NULL
,@mobile		VARCHAR(20)	 = NULL 
,@email			VARCHAR(255) = NULL 
,@message	    VARCHAR(255) = NULL 
,@controlNo		VARCHAR(15)	 = NULL 
,@enquiryType	VARCHAR(30)	 = NULL 
,@createdDate	DATETIME	 = NULL 
,@responseBy	VARCHAR(255) = NULL 
,@responseDate	DATETIME	 = NULL 
,@sortBy		VARCHAR(50)  = NULL
,@sortOrder		VARCHAR(5)	  = NULL
,@pageSize		INT		  = NULL
,@pageNumber	INT		  = NULL
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
		

IF @flag = 'saveCustomerEnquiry'
BEGIN
	INSERT INTO CustomerEnquiry(firstName,mobile,email,message,controlNo,enquiryType,createdDate)
	SELECT @fullName,@mobile,@email,@message,@controlNo,CASE WHEN @enquiryType ='general' THEN 'e'
	WHEN @enquiryType ='transaction' THEN 't' WHEN @enquiryType ='feedback' THEN 'f' END,GETDATE()

	SET @enquiryType = CASE WHEN @enquiryType ='general' THEN 'General Enquiry'WHEN @enquiryType ='transaction' 
		THEN 'Transaction Amendment ' WHEN @enquiryType ='feedback' THEN 'Sugession/FeedBack' END

	SELECT 1 errorCode, 'Your	' +@enquiryType+ ' - Request has been successfully submitted.' msg,SCOPE_IDENTITY()  id
END	   

ELSE IF @flag = 's'
BEGIN
    DECLARE @enqueryTemp VARCHAR(30) = @enquiryType
	SET @enqueryTemp= CASE WHEN  @enquiryType  ='e' THEN 'General Enquiry Request' WHEN @enquiryType='t'
	THEN 'Transaction Amendment Request' WHEN @enquiryType ='f' THEN 'Sugession/FeedBack Request' END
	
	SET @table = '(SELECT enquiryTypeNew='''+ @enqueryTemp+''', * from 
						( select enquiryId,firstName,
							mobile,email,message,
							controlNo,createdDate,enquiryType
							 FROM CustomerEnquiry (nolock))x)y '

	IF @sortBy IS NULL
		SET @sortBy = 'enquiryId'
	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'

	SET @sql_filter = ''
    IF @enquiryType IS NOT NULL
		SET @sql_filter += ' AND y.enquiryType = ''' + @enquiryType  + ''''

	SET @select_field_list ='enquiryId,firstName,mobile,email,message,controlNo,enquiryType,createdDate,enquiryTypeNew'
	
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
