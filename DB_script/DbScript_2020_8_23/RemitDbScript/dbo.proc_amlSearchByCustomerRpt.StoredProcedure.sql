USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_amlSearchByCustomerRpt]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_amlSearchByCustomerRpt]  
  @flag     VARCHAR(10)  
 ,@user     VARCHAR(30)  
 -------------------------------------------  
 ,@sCountry    VARCHAR(50) = NULL  
 ,@rCountry    VARCHAR(50) = NULL  
 ,@sAgent    VARCHAR(50) = NULL  
 ,@rAgent    VARCHAR(50) = NULL  
 ,@sCurr     VARCHAR(50) = NULL  
 ,@rCurr     VARCHAR(50) = NULL  
 ,@rMode     VARCHAR(50) = NULL  
 ,@dateType    VARCHAR(50) = NULL  
 ,@frmDate    VARCHAR(50) = NULL  
 ,@toDate    VARCHAR(50) = NULL  
 -------------------------------------------  
 ,@searchBy    VARCHAR(50) = NULL  
 ,@saerchType   VARCHAR(50) = NULL  
 ,@searchValue  VARCHAR(50) = NULL     
  
 -------------------------------------------  
 ,@pageNumber   INT   = 1  
 ,@pageSize    INT   = 50  
 ,@isExportFull   VARCHAR(1) = NULL  
AS  
  
SET NOCOUNT ON  
BEGIN TRY   
	DECLARE @table VARCHAR(MAX),  
		  @sql VARCHAR(MAX)  ,
		  @globalFilter VARCHAR(MAX) = ''  ,
		  @URL VARCHAR(MAX) = ''  ,
		  @reportHead  VARCHAR(100) = '' , 
		  @customerId BIGINT  
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))    
	SET @pageNumber = ISNULL(@pageNumber, 1)  
	SET @pageSize = ISNULL(@pageSize, 100)    
	SET @globalFilter = ' AND rt.tranStatus <> ''Cancel''' 
   
	IF @sCountry is not null 
	BEGIN  
		INSERT @FilterList  
		SELECT 'Sender Country', @sCountry  
		SET @globalFilter = @globalFilter + ' AND rt.sCountry = ''' + @sCountry + ''''  
	END  
	IF @rCountry is not null 
	BEGIN  
		INSERT @FilterList  
		SELECT 'Receiver Country', @rCountry  
		SET @globalFilter = @globalFilter + ' AND rt.pCountry = ''' + @rCountry + ''''  
	END   
	IF @sAgent IS NOT NULL  
	BEGIN  
		INSERT @FilterList  
		SELECT 'Sender Agent', am.agentName   
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sAgent  
		SET @globalFilter = @globalFilter + ' AND rt.sAgent = ''' + @sAgent + ''''  
	END  
	IF @rAgent IS NOT NULL  
	BEGIN  
		INSERT @FilterList  
		SELECT 'Receiver Agent', am.agentName   
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @rAgent  
		SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @rAgent + ''''  
	END   
	IF @rMode IS NOT NULL  
	BEGIN  
		INSERT @FilterList  
		SELECT 'Receiving Mode', @rMode  
		SET @globalFilter = @globalFilter + ' AND rt.paymentMethod = ''' + @rMode + ''''  
	END   
	INSERT @FilterList  
	SELECT 'Date Type',    
	case when @dateType = 'txnDate' then 'TXN Date'  
	when @dateType = 'confirmDate' then 'Confirm Date'  
	when @dateType = 'paidDate' then 'Paid Date' end     
  
	IF @dateType = 'txnDate'  
	BEGIN  
		INSERT @FilterList  
		SELECT 'From Date', @frmDate  
		SET @globalFilter = @globalFilter + ' AND rt.createdDate >= ''' + @frmDate + ''''  
		INSERT @FilterList  
		SELECT 'To Date', @toDate  
		SET @globalFilter = @globalFilter + ' AND rt.createdDate <= ''' + @toDate + ' 23:59:59'''  
	END   
	IF @dateType = 'confirmDate'  
	BEGIN  
		INSERT @FilterList  
		SELECT 'From Date', @frmDate  
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate >= ''' + @frmDate + ''''  
		INSERT @FilterList  
		SELECT 'To Date', @toDate  
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate <= ''' + @toDate + ' 23:59:59'''  
	END   
	IF @dateType = 'paidDate'  
	BEGIN  
		INSERT @FilterList  
		SELECT 'From Date', @frmDate  
		SET @globalFilter = @globalFilter + ' AND rt.paidDate >= ''' + @frmDate + ''''  
		INSERT @FilterList  
		SELECT 'To Date', @toDate  
		SET @globalFilter = @globalFilter + ' AND rt.paidDate <= ''' + @toDate + ' 23:59:59'''  
	END   
	
	IF @flag = 'sbc'   
	BEGIN  
		SET @reportHead ='Search By Customer'

		IF @searchBy = 'sender'  
		BEGIN  
			--GET THE CUSTOMER ID FROM ID NUMBER, TO GET TRANSAACTIONS BY ID NUMBER
			SELECT @customerId = customerId 
			FROM customerMaster (NOLOCK) 
			WHERE idNumber = @searchValue 
		END    

		SET @URL='"Reports.aspx?saerchType='+@saerchType+'&searchValue='+ @searchValue+'&dateType='+@dateType+'&frmDate='+@frmDate
			+'&toDate='+@toDate+'&sCountry='+ISNULL(replace(@sCountry,' ','__'),'')
			+'&sAgent='+ISNULL(@sAgent,'')+
			CASE WHEN @searchBy = 'receiver'  THEN +'&recName=''+REPLACE(RT.receiverName,'' '',''__'')+'''
				+'&recMobile=''+REPLACE(TR.mobile,'' '',''__'')+''' ELSE '' 
			END
			+'&rMode='+ISNULL(REPLACE(@rMode,' ','__'),'')+'&rCountry='+ISNULL(replace(@rCountry,' ','__'),'')
			+'&rAgent='+ISNULL(@rAgent,'')
			+'&date=''+RIGHT(CONVERT(VARCHAR, rt.createdDate, 103), 7)+'''
			+'&senderName='+ CASE WHEN @searchBy = 'sender' THEN '''+REPLACE(rt.senderName,'' '',''__'')+''' ELSE '''+REPLACE(rt.receiverName,'' '',''__'')+''' END 
			+'&reportName=amlddlreport&flag=sbc_ddl&searchBy='+@searchBy+'&customerId='+CAST(ISNULL(@customerId, 0) AS VARCHAR)+'"'

		SET @table = '  
		SELECT [TXN Month/Year] =''<span class = "link" onclick =ViewAMLDDLReport('+@URL+');>'' +  RIGHT(CONVERT(VARCHAR, rt.createdDate, 103), 7) + ''</span>''  
		'  
		
		IF @searchBy = 'sender'  
		BEGIN  
			SET @table = @table +'    
			,[Sender ID Number (Name)] = ISNULL(ts.idType, '''') + ''-'' + ISNULL(ts.idNumber, '''')  + ISNULL('' ''+rt.senderName,'''')' 
		END    
		ELSE  
		BEGIN  
			SET @table = @table+'  
			,[Receiver Mobile Number (Name)] = ISNULL(tr.mobile, '''')  + ISNULL('' ''+rt.receiverName,'''')'  
		END  

		SET @table = @table + '	
			,[Txn Count]	= COUNT(''x'')  
			,[Total Amount] = CAST(SUM(rt.tAmt) AS DECIMAL(18, 2))    
		FROM remitTran rt WITH(NOLOCK)   
		LEFT JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId  
		LEFT JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId  
		WHERE 1 = 1 and rt.tranStatus <>''cancel''
		'  

		IF @searchBy = 'receiver' 
		BEGIN
			INSERT @FilterList  
			SELECT 'Id', CASE WHEN @saerchType = 'rname' THEN 'RECEIVER NAME' WHEN @saerchType = 'rmobile' THEN 'RECEIVER MOBILE' END
  
			INSERT @FilterList  
			SELECT 'ID Number', @searchValue  

			IF @saerchType = 'rname'
				SET @table = @table + ' AND tr.fullName = ISNULL('''+ @searchValue  +''',tr.fullName)' 

			IF @saerchType = 'rmobile'
				SET @table = @table + ' AND tr.mobile LIKE ISNULL(''%'+ @searchValue  +''',tr.mobile)' 
		END
		IF @searchBy = 'sender' 
		BEGIN
			INSERT @FilterList  
			SELECT 'Id','Sender Id'  
  
			INSERT @FilterList  
			SELECT 'ID Number', @searchValue  
			SET @table = @table + ' AND ts.customerId = ISNULL('''+ CAST(ISNULL(@customerId, 0) AS VARCHAR) +''',ts.customerId)' 
		END	

		INSERT @FilterList  
		SELECT 'Search by', @searchBy  
     
		SET @table = @table + @globalFilter + '   
		GROUP BY RIGHT(CONVERT(VARCHAR, rt.createdDate, 103), 7)'    

		IF @searchBy = 'sender'  
		BEGIN  
			SET @table = @table +'   
			,ts.idType 
			,ts.idNumber  
			,rt.senderName  
			'  
		END  
		IF @searchBy = 'receiver'  
		BEGIN  
			SET @table = @table +'   
			,rt.receiverName  
			,tr.mobile
			' 
		END   

		IF @isExportFull = 'Y'  
		BEGIN  
			SET @sql = '  
			SELECT [TXN Month/Year]'  
  
			IF @searchBy = 'sender'
				SET @sql =@sql +',[Sender ID Number (Name)]'  
     
			IF @searchBy = 'receiver'
				SET @sql =@sql +',Receiver Mobile Number (Name)]' 
				 
			SET @SQL= @sql + ',[Txn Count],[Total Amount]  
			FROM (    
				SELECT   
				ROW_NUMBER() OVER (ORDER BY [TXN Month/Year]) AS [S.N],*   
				FROM (' + @table + ') x    
			) AS tmp '  
  
			PRINT @sql  
			EXEC (@sql)  
		END  
		ELSE  
		BEGIN  
			SET @sql = 'SELECT   
				COUNT(*) AS TXNCOUNT  
				,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE  
				,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER       
				FROM (' + @table + ') x'  
			PRINT @sql  
			EXEC (@sql)  
    
			SET @sql = '  
			SELECT [TXN Month/Year]'  

			IF @searchBy = 'sender'
				SET @sql =@sql +',[Sender ID Number (Name)]'  
     
			IF @searchBy = 'receiver' 
				SET @sql =@sql +',[Receiver Mobile Number (Name)]' 
				 
			SET @SQL= @sql + ',[Txn Count],[Total Amount]  
			FROM (    
				SELECT   
				ROW_NUMBER() OVER (ORDER BY [TXN Month/Year]) AS [S.N],*   
				FROM (' + @table + ') x    
			) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)  
  
			PRINT @sql  
			EXEC (@sql)  
		END   
 END  
  
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL      
SELECT * FROM @FilterList       
SELECT 'AML Reports : '+@reportHead title  
  
END TRY  
  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE()  
     EXEC proc_errorHandler 1, @errorMessage ,NULL   
END CATCH  




GO
