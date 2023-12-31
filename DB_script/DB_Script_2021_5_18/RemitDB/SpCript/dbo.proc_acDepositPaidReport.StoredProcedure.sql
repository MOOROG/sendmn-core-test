USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_acDepositPaidReport]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_acDepositPaidReport]
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
	,@redownload		VARCHAR(10)		= NULL
	,@paidUser			VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	,@logId						INT
	

DECLARE @controlNoEncrypted VARCHAR(30), @FIELDS AS VARCHAR(MAX),@SQL1 AS VARCHAR(MAX),@SQL VARCHAR(MAX)
,@fromDateOld VARCHAR(20),@toDateOld VARCHAR(20)
	
IF @flag='report'
BEGIN
	SET @fromDateOld = @fromDate
	SET @toDateOld = @toDate

	IF @fromTime IS NOT NULL
		SET @fromDate=@fromDate+' '+@fromTime
	ELSE 
		SET @fromDate=@fromDate+' 23:59:59'
	IF @toDate IS NOT NULL
		SET @toDate= @toDate+' '+@toTime 
	ELSE
		SET @toDate= @toDate+' 23:59:59'

	SET @FIELDS='[RECEIVER NAME],[ACCOUNT NUMBER],[BRANCH NAME],[PAYOUT AMOUNT]'
	
    IF @chkSender='true'
		SET @FIELDS=@FIELDS+',[SENDER NAME]'
		
	IF @chkBankComm='true'
		SET @FIELDS=@FIELDS+',[BANK COMM]' 
		
	IF @chkGenerator='true'
		SET @FIELDS=@FIELDS+',[PAID BY]' 	
		
	IF @chkIMERef='true'
		SET @FIELDS=@FIELDS+',[IME REF. NO.]' 	
		
	declare @dateField as varchar(100),@payStatus varchar(50)
	IF @dateType ='paidDate'
	begin
		set @dateField = 'paidDate'	
		set @payStatus = 'Paid'
	end
	IF @dateType ='postedDate'
	begin
		set @dateField = 'postedDate'	
		set @payStatus = 'Post'
	end
            
	SET @SQL='
		(SELECT   
			 [RECEIVER NAME]	= case when b.accountName is not null then b.accountName else B.firstName + ISNULL( '' '' + B.middleName, '''') + ISNULL( '' '' + B.lastName1, '''') + ISNULL( '' '' + B.lastName2, '''') end
			,[ACCOUNT NUMBER]	= ''A/C NO:'' + A.accountNo
			,[BRANCH NAME]		= isnull(pBankBranchName,pBranchName) 
			,[PAYOUT AMOUNT]	= dbo.ShowDecimalExceptComma(ISNULL(pAmt,0)) 	
			,[SENDER NAME]		= c.firstName + ISNULL( '' '' + c.middleName, '''') + ISNULL( '' '' + c.lastName1, '''') + ISNULL( '' '' + c.lastName2, '''') 
			,[BANK COMM]		= isnull(A.pAgentComm,0)
			,[PAID BY]			= A.paidBy
			,[IME REF. NO.]		= dbo.FNADecryptString(A.controlNo)
		FROM remitTran A WITH(NOLOCK) 
		INNER JOIN tranReceivers B WITH(NOLOCK) ON A.id=B.tranId 
		INNER JOIN tranSenders C with(nolock) on a.id=c.tranId
		WHERE paymentMethod = ''Bank Deposit'' 
		AND (pBank = '''+@bankId+''' OR isnull(pAgent,'''')  = '''+@bankId+''')
		AND '+@dateField+' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = '''+@payStatus+''''
		
		IF @tranType IS NOT NULL
			SET @SQL = @SQL + ' AND tranType = ''' + @tranType + ''''
		
		SET @SQL = @SQL + ')x'
		
		SET @SQL1=
				'SELECT '+@FIELDS+' FROM '+@SQL+''

		--SELECT @SQL1
		--RETURN;
		EXEC(@SQL1)
END
/*
UPDATE dbo.remitTran SET downloadedBy = NULL,downloadedDate=NULL,downloadLogId=NULL WHERE downloadedBy IS NOT null
SELECT * FROM acDepositdownloadLog
*/
	IF OBJECT_ID('tempdb..##temp_table') IS NOT NULL
		DROP TABLE ##temp_table

	SET @fromDateOld = @fromDate
	SET @toDateOld = @toDate
	SET @fromDate=@fromDate+' '+@fromTime
	SET @toDate= @toDate+' '+@toTime 
	
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	INSERT INTO @FilterList
	SELECT 'REPORT TYPE' ,CASE WHEN @flag ='summary' THEN 'SUMMARY' ELSE 'DETAIL' END 
	UNION ALL
	SELECT 'DOWNLOAD NATURE', CASE WHEN @redownload ='true' THEN 'RE-DOWNLOAD' ELSE 'DOWNLOAD' END 

	DECLARE @globalFilter VARCHAR(MAX) = '',@dateField1 varchar(100),@dateFieldColumn varchar(100)
	IF @redownload ='false'
		SET @globalFilter = @globalFilter+' AND tm.downloadedDate is NULL'
	
	set @dateField1 = 'paidDate'
	set @dateFieldColumn = '[DOT/Paid Date]'
	IF @dateType ='paidDate' AND @redownload ='true'
	BEGIN
		SET @globalFilter = @globalFilter+' AND paidDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = ''Paid'''
		INSERT @FilterList
		SELECT 'Date Type', @dateType
		UNION ALL
		SELECT 'From Date', @FROMDATE
		UNION ALL
		SELECT 'To Date', @TODATE		
	END
	IF @dateType ='postDate' AND @redownload ='true'
	BEGIN
		SET @globalFilter = @globalFilter+' AND postedDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = ''Post'''
		INSERT @FilterList
		SELECT 'Date Type', @dateType
		UNION ALL
		SELECT 'From Date', @FROMDATE
		UNION ALL
		SELECT 'To Date', @TODATE
		set @dateField1 = 'postedDate'
		set @dateFieldColumn = '[DOT/Post Date]'
	END
	IF @dateType ='confirmDate'	AND @redownload ='true'
	BEGIN 
		SET @globalFilter = @globalFilter+' AND approvedDateLocal BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' and payStatus = ''Paid'''
		INSERT @FilterList
		SELECT 'Date Type', @dateType
		UNION ALL
		SELECT 'From Date', @FROMDATE
		UNION ALL
		SELECT 'To Date', @TODATE
	END
				
	IF @sendingAgent IS NOT NULL
	BEGIN
		SET @globalFilter = @globalFilter+' AND sAgent='''+@sendingAgent+''''
		INSERT @FilterList
		SELECT 'Sending Agent', (SELECT agentName FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sendingAgent) 
	END
	IF @bankId IS NOT NULL
	BEGIN 
		SET @globalFilter = @globalFilter+' AND (pBank='''+@bankId+''' OR pAgent  = '''+@bankId+''')'
		INSERT @FilterList
		SELECT 'Bank Name', (SELECT agentName FROM agentMaster am WITH(NOLOCK) WHERE agentId = @bankId) 
	END
	IF @tranType IS NOT NULL
	BEGIN 
		SET @globalFilter = @globalFilter+' AND tranType = '''+@tranType+''''
		INSERT @FilterList
		SELECT 'Tran Type' head,ISNULL(@tranType,'All') value
	END

	IF @paidUser IS NOT NULL AND @dateType = 'confirmDate'
	BEGIN
		SET @globalFilter = @globalFilter+' AND tm.ApprovedBy = '''+@paidUser+''''
		INSERT @FilterList
		SELECT 'Paid User' head,ISNULL(@paidUser,'All') value
	END
	IF @paidUser IS NOT NULL AND @dateType = 'postDate'
	BEGIN
		SET @globalFilter = @globalFilter+' AND tm.postedBy = '''+@paidUser+''''
		INSERT @FilterList
		SELECT 'Paid User' head,ISNULL(@paidUser,'All') value
	END
	IF @paidUser IS NOT NULL AND @dateType = 'paidDate'
	BEGIN
		SET @globalFilter = @globalFilter+' AND tm.paidBy = '''+@paidUser+''''
		INSERT @FilterList
		SELECT 'Paid User' head,ISNULL(@paidUser,'All') value
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
			generatedFrom VARCHAR(200)
		)
		SET @SQL='
				SELECT 
					 [tranId]						= tm.id
					,[Credit Bank]					= isnull(pAgentName,pBankName)+'' (''+ replace(replace(isnull(pBankBranchName,pBranchName),isnull(pAgentName,pBankName),''''),''-'','''') +'')''
					,[Receiver Name]				= tr.firstName + ISNULL( '' '' + tr.middleName, '''') + ISNULL('' '' + tr.lastName1, '''') + ISNULL('' '' + tr.lastName2, '''') 
					,[Sender Name]					= sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''') 
				
					,[Account No.]					= tm.accountNo
					,[IME Ref]						= dbo.FNADecryptString(controlNo)
					,[approvedDate]					= tm.approvedDate
					,[paidDate]						= tm.'+@dateField1+' 
					,[Credit Amount]				= ISNULL(tm.pAmt,0)
					,[Generate From]				= tm.sAgentName				
				FROM remitTran tm WITH(NOLOCK) 
				INNER JOIN tranReceivers tr WITH(NOLOCK) ON tm.id = tr.tranId
				INNER JOIN tranSenders sen WITH(NOLOCK) ON tm.id = sen.tranId
				WHERE paymentMethod = ''BANK DEPOSIT'' '+@globalFilter
		--PRINT(@SQL)
		INSERT INTO #TEMP_TABLE(tranId,creditBank,receiverName,senderName,accountNo,imeRefNo,approvedDate,paidDate,amt,generatedFrom)
		EXEC(@SQL)

		IF @redownload ='false' 
		BEGIN
			IF EXISTS(SELECT 'X' FROM #TEMP_TABLE)
			BEGIN
				INSERT INTO acDepositdownloadLog(createdDate,createdBy)
				SELECT dbo.FNAGetDateInNepalTZ(),@user
				SET @logId = SCOPE_IDENTITY()
				UPDATE remitTran SET downloadedBy = @user,downloadedDate=dbo.FNAGetDateInNepalTZ(),downloadLogId = @logId
				FROM remitTran a,
				(
					SELECT tranId FROM #TEMP_TABLE
				)b WHERE a.id = b.tranId
			END
		END 


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
					[Generate From] = generatedFrom
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
					 [S.N.]	= row_number()over(order by ISNULL(pBankName,pAgentName)),
					 [Credit Bank]					= ''<a href="' + dbo.FNAGetUrl() + 'SwiftSystem/Reports/Reports.aspx?reportName=acdepositdetail&sendingAgent=' + ISNULL(@sendingAgent, '') + '&bankId='' + CAST(ISNULL(pBank,pAgent) AS VARCHAR) + ''&tranType=' + ISNULL(@tranType, '')
	 +  '&fromDate=' + ISNULL(@fromDateOld, '')+  '&redownload=' + ISNULL(@redownload, '') + '&toDate=' + ISNULL(@toDateOld, '') + '&dateType=' + ISNULL(@dateType, '') + '&fromTime=' + ISNULL(@fromTime, '') + '&toTime=' + ISNULL(@toTime, '') + '&paidUser='+ISNULL(@paidUser,'')+'" title="View Detail">'' + ISNULL(pBankName,pAgentName) +
	 ''</a>'' 
					,[Txn Count]					= count(*)
					,[Credit Amount]				= sum(ISNULL(tm.pAmt,0))
				FROM remitTran tm WITH(NOLOCK) 
				INNER JOIN tranReceivers tr WITH(NOLOCK) ON tm.id=tr.tranId
				WHERE paymentMethod=''BANK DEPOSIT'' 
			'+ @globalFilter
	

		SET @SQL = @SQL+' GROUP BY isnull(pBankName,pAgentName),ISNULL(pBank,pAgent)'	
		EXEC(@SQL)
	END
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT * FROM @FilterList
	
	SELECT 'ACCOUNT DEPOSIT PAID REPORT' title





GO
