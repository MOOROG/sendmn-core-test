
ALTER PROC proc_remitTransaction
	@USER VARCHAR(50)=NUll,
	@FLAG VARCHAR(20),
	@customerName VARCHAR(50) = NULL,
	@pageSize INT= NULL,
	@pageNumber	INT	= NULL,
	@sortBy VARCHAR(50) = NULL,
	@sortOrder	VARCHAR(5)  = NULL,  
	@rowId varchar(20) = NULL,
	@fromDate VARCHAR(25) = NULL,
	@toDate VARCHAR(25) = NULL,
	@CustomerID VARCHAR(20) = NULL,
	@controlNumber	VARCHAR(1000) = NULL,
	@searchType VARCHAR(20) = NULL
AS
BEGIN
SET NOCOUNT ON;  
SET XACT_ABORT ON;
BEGIN TRY 
	DECLARE @errorMessage VARCHAR(MAX),
			@sql    VARCHAR(MAX)  
			,@table    VARCHAR(MAX)  
			,@select_field_list VARCHAR(MAX)  
			,@extra_field_list VARCHAR(MAX)  
			,@sql_filter  VARCHAR(MAX)  
	IF @flag = 's'
		BEGIN	
			IF @sortBy IS NULL
			  SET @sortBy = 'createdDate'
			IF @sortOrder IS NULL
			   SET @sortOrder = 'DESC'
			SET @table = '(
							SELECT rt.id, 
									controlNo = dbo.decryptDb(rt.controlNo),
									senderName,
									receiverName,
									approvedDate,
									paidDate,
									createdDate,
									ts.customerId,
									tr.customerId receiverId
							FROM dbo.remitTran rt(NOLOCK)
							INNER JOIN dbo.tranSenders ts(NOLOCK) ON rt.id = ts.tranId
							INNER JOIN dbo.tranReceivers tr(NOLOCK) ON rt.id = tr.tranId
							and rt.transtatus <> ''cancel''
						)x '
			
			SET @sql_filter = ''

			IF @CustomerID IS NOT NULL
				IF @searchType = 'receiverName'
					SET @sql_filter += ' AND receiverId =''' + @CustomerID  + ''''
				ELSE
					SET @sql_filter += ' AND customerId =''' + @CustomerID  + ''''
		
			IF ISNULL(@fromDate, '') <> '' AND ISNULL(@toDate, '') <> ''
				SET @sql_filter +=  ' AND approvedDate BETWEEN ''' +@fromDate+''' AND ''' +@toDate +' 23:59:59'''

			IF @controlNumber IS NOT NULL
				SET @sql_filter +=  ' AND controlNo IN (SELECT value FROM dbo.Split('','', '''+@controlNumber+'''))'

			SET @select_field_list ='ID,controlNo,senderName,receiverName,approvedDate,paidDate,createdDate'
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
END TRY 
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 
	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH

END

