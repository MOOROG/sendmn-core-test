USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_acDepositPaidISOReport]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_acDepositPaidISOReport]
	 @flag				VARCHAR(50)
	,@bankId			VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@dateType			VARCHAR(50)		= NULL
	,@tranType			VARCHAR(10)		= NULL
	,@chkSender			VARCHAR(10)		= NULL
	,@chkBankComm		VARCHAR(10)		= NULL
	,@chkGenerator		VARCHAR(10)		= NULL
	,@chkIMERef			VARCHAR(10)		= NULL
	,@sendingAgent		VARCHAR(50)		= NULL 
	,@beneficiaryCountry VARCHAR(50)	= NULL	
	,@fromTime			VARCHAR(20)		= NULL
	,@toTime			VARCHAR(20)		= NULL		
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@pageSize			VARCHAR(50)		= NULL
	,@pageNumber		VARCHAR(50)		= NULL
	,@user				VARCHAR(50)		= NULL
	,@logStatus			VARCHAR(10)		= NULL
	,@paidUser			VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	,@logId						INT
	

	DECLARE 
		@controlNoEncrypted VARCHAR(30), 
		@FIELDS AS VARCHAR(MAX),
		@SQL1 AS VARCHAR(MAX),
		@SQL VARCHAR(MAX),
		@fromDateOld VARCHAR(20),
		@toDateOld VARCHAR(20)


	SET @fromDateOld = @fromDate
	SET @toDateOld = @toDate
	SET @fromDate=@fromDate+' '+@fromTime
	SET @toDate= @toDate+' '+@toTime 
	
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	INSERT INTO @FilterList
	SELECT 'REPORT TYPE' ,CASE WHEN @flag ='summary' THEN 'SUMMARY' ELSE 'DETAIL' END 

	DECLARE @globalFilter VARCHAR(MAX) = '',@dateField1 varchar(100),@dateFieldColumn varchar(100)
	--SELECT * FROM acDepositQueueIso
	set @dateField1 = 'paidDate'
	set @dateFieldColumn = '[DOT/Paid Date]'
	IF @dateType ='paidDate' 
	BEGIN
		SET @globalFilter = @globalFilter+' AND q.status=''Success'' AND tm.paidDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = ''Paid'''
		INSERT @FilterList
		SELECT 'Date Type', @dateType
		UNION ALL
		SELECT 'From Date', @FROMDATE
		UNION ALL
		SELECT 'To Date', @TODATE		
	END
	IF @dateType ='postDate' 
	BEGIN
		SET @globalFilter = @globalFilter+' AND tm.postedDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = ''Post'''
		INSERT @FilterList
		SELECT 'Date Type', @dateType
		UNION ALL
		SELECT 'From Date', @FROMDATE
		UNION ALL
		SELECT 'To Date', @TODATE
		set @dateField1 = 'postedDate'
		set @dateFieldColumn = '[DOT/Post Date]'
	END
	IF @dateType ='confirmDate'	
	BEGIN 
		SET @globalFilter = @globalFilter+' AND tm.approvedDateLocal BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = ''Paid'''
		INSERT @FilterList
		SELECT 'Date Type', @dateType
		UNION ALL
		SELECT 'From Date', @FROMDATE
		UNION ALL
		SELECT 'To Date', @TODATE
	END
				
	IF @sendingAgent IS NOT NULL
	BEGIN
		SET @globalFilter = @globalFilter+' AND tm.sAgent='''+@sendingAgent+''''
		INSERT @FilterList
		SELECT 'Sending Agent', (SELECT agentName FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sendingAgent) 
	END
	IF @bankId IS NOT NULL
	BEGIN 
		SET @globalFilter = @globalFilter+' AND (tm.pBank='''+@bankId+''' OR tm.pAgent  = '''+@bankId+''')'
		INSERT @FilterList
		SELECT 'Bank Name', (SELECT agentName FROM agentMaster am WITH(NOLOCK) WHERE agentId = @bankId) 
	END
	IF @tranType IS NOT NULL
	BEGIN 
		SET @globalFilter = @globalFilter+' AND tm.tranType = '''+@tranType+''''
		INSERT @FilterList
		SELECT 'Tran Type' head,ISNULL(@tranType,'All') value
	END

	IF @paidUser IS NOT NULL
	BEGIN
		SET @globalFilter = @globalFilter+' AND tm.paidBy = '''+@paidUser+''''
		INSERT @FilterList
		SELECT 'Paid User' head,ISNULL(@paidUser,'All') value
	END
	IF @logStatus IS NOT NULL
	BEGIN 
		IF @logStatus = 'Pending'
			SET @globalFilter = @globalFilter+' AND q.status IS NULL '
		ELSE IF @logStatus = 'Paid'
			SET @globalFilter = @globalFilter+' AND q.status = ''success'''
		ELSE
			SET @globalFilter = @globalFilter+' AND q.status = '''+@logStatus+''''
		INSERT @FilterList
		SELECT 'Log Status' head,ISNULL(UPPER(@logStatus),'All') value
	END
	IF @flag='detail'
	BEGIN	
		CREATE TABLE #TEMP_TABLE
		(
			tranId BIGINT, 
			creditBank VARCHAR(500),
			receiverName VARCHAR(500),
			senderName VARCHAR(500),
			accountNo VARCHAR(100),
			imeRefNo VARCHAR(50),
			approvedDate DATETIME,
			paidDate DATETIME,
			amt MONEY,
			generatedFrom VARCHAR(200),
			logStatus VARCHAR(50),
			processDate DATETIME,
			resMsg VARCHAR(MAX),
			referenceId VARCHAR(100)
		)
		--+'' (''+ replace(replace(isnull(tm.pBankBranchName,tm.pBranchName),isnull(tm.pAgentName,tm.pBankName),''''),''-'','''') +'')''
		SET @SQL='
				SELECT 
					 [tranId]						= tm.id
					,[Credit Bank]					= ISNULL(tm.pAgentName, tm.pBankName)
					,[Receiver Name]				= tr.firstName + ISNULL( '' '' + tr.middleName, '''') + ISNULL('' '' + tr.lastName1, '''') + ISNULL('' '' + tr.lastName2, '''') 
					,[Sender Name]					= sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''') 
				
					,[Account No.]					= tm.accountNo
					,[IME Ref]						= dbo.FNADecryptString(tm.controlNo)
					,[approvedDate]					= tm.approvedDate
					,[paidDate]						= tm.'+@dateField1+' 
					,[Credit Amount]				= ISNULL(tm.pAmt,0)
					,[Generate From]				= tm.sAgentName
					,[ISO Logs_Status]				= q.status
					,[ISO Logs_Process Date]		= q.processDate
					,[ISO Logs_Response Msg]	    = q.resMsg	
					,[Refrence ID]					= q.referenceId						
				FROM remitTran tm WITH(NOLOCK) 
				INNER JOIN tranReceivers tr WITH(NOLOCK) ON tm.id = tr.tranId
				INNER JOIN tranSenders sen WITH(NOLOCK) ON tm.id = sen.tranId
				INNER JOIN acDepositQueueIso q WITH(NOLOCK) ON q.tranId = tm.id
				WHERE tm.paymentMethod = ''BANK DEPOSIT'' and tm.expectedPayoutAgent =''iso''  '+@globalFilter
		PRINT(@SQL)
		INSERT INTO #TEMP_TABLE(tranId,creditBank,receiverName,senderName,accountNo,imeRefNo,approvedDate,paidDate,amt,generatedFrom,logStatus,processDate,resMsg,referenceId)
		EXEC(@SQL)

		SET @SQL1='
			SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM (SELECT * FROM #TEMP_TABLE) AS tmp;

			SELECT * FROM 
			(
			SELECT ROW_NUMBER() OVER (ORDER BY [Credit Bank]) AS [S.N],* 
			FROM 
			(
				 SELECT 
					[Credit Bank] = creditBank,
					[Receiver Name] = receiverName,
					[Sender Name] = senderName,
					[Account No.] = accountNo,
					[IME Ref] = ''<a href="' + dbo.FNAGetURL() + 'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + imeRefNo + ''" title="View Detail">'' + imeRefNo + ''</a>'',
					'+@dateFieldColumn+' = cast(approvedDate as varchar)+''</br>''+cast(paidDate as varchar) ,
					[Credit Amount] = amt,
					[Generate From] = generatedFrom,
					[ISO Logs_Status]		= logStatus,
					[ISO Logs_Process date]		= processDate,
					[ISO Logs_Response Msg]	    = resMsg,
					[Refrence ID]				= referenceId		
				 FROM #TEMP_TABLE 
			) AS aa
			) AS tmp WHERE 1 = 1 AND  tmp.[S.N] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''

		PRINT(@SQL1)
		EXEC(@SQL1)		
	END

	IF @flag='summary'
	BEGIN
		SET @SQL='
				SELECT 
					 [S.N.]	= row_number()over(order by ISNULL(tm.pBankName,tm.pAgentName)),
					 [Credit Bank]					= ''<a href="' + dbo.FNAGetUrl() + 'SwiftSystem/Reports/Reports.aspx?reportName=aclogIso&rptType=detail&sendingAgent=' + ISNULL(@sendingAgent, '') + '&bankId='' + CAST(ISNULL(tm.pBank,tm.pAgent) AS VARCHAR) + ''&tranType=' + ISNULL(@tranType, '')
	 +  '&fromDate=' + ISNULL(@fromDateOld, '')+  '&logStatus=' + ISNULL(@logStatus, '') + '&toDate=' + ISNULL(@toDateOld, '') + '&dateType=' + ISNULL(@dateType, '') + '&fromTime=' + ISNULL(@fromTime, '') + '&toTime=' + ISNULL(@toTime, '') + '" title="View Detail">'' + ISNULL(tm.pBankName,tm.pAgentName) +
	 ''</a>'' 
					,[Txn Count]					= count(''x'')
					,[Credit Amount]				= sum(ISNULL(tm.pAmt,0))
				FROM remitTran tm WITH(NOLOCK) 
				INNER JOIN tranReceivers tr WITH(NOLOCK) ON tm.id=tr.tranId
				INNER JOIN acDepositQueueIso q WITH(NOLOCK) ON q.tranId = tm.id
				WHERE paymentMethod=''BANK DEPOSIT'' and expectedPayoutAgent =''iso'' 
			'+ @globalFilter
	

		SET @SQL = @SQL+' GROUP BY isnull(tm.pBankName,tm.pAgentName),ISNULL(tm.pBank,tm.pAgent)'	
		EXEC(@SQL)
	END
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT * FROM @FilterList
	
	SELECT 'ACCOUNT DEPOSIT PAID REPORT- ISO' title





GO
