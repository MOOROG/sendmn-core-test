--EXEC proc_DailyTxnRpt @flag = 'dailyTxnRptCash', @user = 'nagoya', @fromDate = '2020-02-27', @toDate = '2020-02-27'

ALTER proc [dbo].[proc_DailyTxnRpt]
(
	 @flag				VARCHAR(30)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@todayDate			VARCHAR(20)		= NULL
	,@fromDate			varchar(10)		= NULL
	,@toDate			varchar(10)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
    ,@sortOrder			VARCHAR(5)		= NULL
    ,@pageSize			INT				= NULL
    ,@pageNumber		INT				= NULL
	,@customerId		BIGINT			= NULL		
	,@particulars		nvarchar(100)	= NULL
	,@trandate			varchar(10)		= NULL
	,@referralCode		VARCHAR(50) = NULL
	,@depositAmount		money			= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
			DECLARE @table VARCHAR(MAX) ,
            @select_field_list VARCHAR(MAX) ,
            @extra_field_list VARCHAR(MAX) ,
            @sql_filter VARCHAR(MAX);

BEGIN TRY
IF @flag = 'dailyTxnRptCash'
BEGIN
	--IF @todayDate IS NULL
	--	SET @todayDate = (SELECT CONVERT(VARCHAR(10),GETDATE(),111));
	
	IF @referralCode IS NULL
	BEGIN
		SELECT CONVERT(VARCHAR(12),R.createdDate,111)	[DATE],
				'<a onclick ="ViewTranDetail('+CONVERT(VARCHAR(25),id)+')">'+dbo.decryptDb(controlNo)+'</a>' [PIN_NO],
				senderName	[SENDER_NAME],
				cAmt [COLLECT_AMOUNT],
				PSUPERAGENTNAME,
				R.CREATEDDATE
		INTO #REPORT_CASH_COLLECT
		FROM dbo.remitTran r(NOLOCK)
		INNER JOIN AGENTMASTER M(NOLOCK) ON M.AGENTID = R.SAGENT
		LEFT JOIN REFERRAL_AGENT_WISE RR(NOLOCK) ON RR.REFERRAL_CODE = R.PROMOTIONCODE
		WHERE COLLMODE = 'CASH COLLECT'
		AND M.ACTASBRANCH = 'Y'
		AND RR.REFERRAL_TYPE_CODE NOT IN ('RR', 'RC')
		AND R.CREATEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' 
		AND R.CREATEDBY = @user
		AND R.TRANSTATUS <> 'Cancel'
		order by R.CREATEDDATE desc

		SELECT * FROM #REPORT_CASH_COLLECT order by createddate desc

		SELECT DISTINCT PSUPERAGENTNAME, SHOW_NAME = 'Txn Send To: '+PSUPERAGENTNAME
		FROM #REPORT_CASH_COLLECT
	END
	ELSE
	BEGIN
		SELECT CONVERT(VARCHAR(12),R.createdDate,111)	[DATE],
				'<a onclick ="ViewTranDetail('+CONVERT(VARCHAR(25),id)+')">'+dbo.decryptDb(controlNo)+'</a>' [PIN_NO],
				senderName	[SENDER_NAME],
				cAmt [COLLECT_AMOUNT],
				PSUPERAGENTNAME,
				R.CREATEDDATE
		INTO #REPORT_CASH_COLLECT1
		FROM dbo.remitTran r(NOLOCK)
		INNER JOIN AGENTMASTER M(NOLOCK) ON M.AGENTID = R.SAGENT
		WHERE COLLMODE = 'CASH COLLECT'
		AND M.ACTASBRANCH = 'Y'
		AND R.PROMOTIONCODE = @referralCode
		AND R.CREATEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' 
		AND R.TRANSTATUS <> 'Cancel'
		order by R.CREATEDDATE desc

		SELECT * FROM #REPORT_CASH_COLLECT1 order by createddate desc

		SELECT DISTINCT PSUPERAGENTNAME, SHOW_NAME = 'Txn Send To: '+PSUPERAGENTNAME
		FROM #REPORT_CASH_COLLECT1
	END
END
IF @flag = 'unPostTransaction'
BEGIN

   SELECT @table = '
			 (

			SELECT  id
			,CONTROLNO = DBO.DECRYPTDB(CONTROLNO)
			,''UnPost'' Status
			,CAST(DATEDIFF(MINUTE,APPROVEDDATE, GETDATE()) AS VARCHAR) + '' minutes'' CREATEDDATE
			,PAYMENTMETHOD
			,PCOUNTRY
			,pbankname
			FROM REMITTRAN (NOLOCK)
			WHERE 1=1
			AND payStatus = ''unpaid''
			AND tranStatus = ''Payment''
			AND CREATEDDATE >= ''2020-02-15''
			--AND PCOUNTRY IN (''VIETNAM'', ''NEPAL'')
			'
           SET @sql_filter = ''; 
           SET @table = @table + ' )x';
           PRINT @table;
           SET @select_field_list = 'id,CONTROLNO,CREATEDDATE,PAYMENTMETHOD,PCOUNTRY,pbankname';
      
           EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber;

END
ELSE IF @flag = 'customerHistroy'
BEGIN
	SELECT top 20 ROW_NUMBER() OVER (ORDER BY rt.createddate desc) SN
			,dbo.fnadecryptstring(rt.controlno) [Control No]
			,convert(varchar(10),rt.createdDate,121) TranDate
			,ts.fullName Sender
			,tr.fullName Receiver
			,rt.tAmt [Transfer Amount]
			,rt.serviceCharge [Service Charge]
			,rt.collmode [Collection Mode]
			,rt.pbankname [Bank Name]
			,RI.receiverAccountNo [Receiver Account Number]
	FROM VWREMITTRAN rt (nolock)
	INNER JOIN VWTRANSENDERS ts (nolock) on ts.tranid = rt.id
	INNER JOIN VWTRANRECEIVERS tr (nolock) on tr.tranid = rt.id
	LEFT JOIN RECEIVERINFORMATION RI (NOLOCK) ON RI.RECEIVERID = TR.CUSTOMERID
	where ts.customerid = @customerId
	ORDER BY rt.createddate desc

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'CustomerId' head,@customerId VALUE

	SELECT 'Customer recent 20 Transaction History' title
END
IF @flag = 'depositList'
BEGIN

   SELECT @table = '
			 (
			SELECT tranid
				,trandate
				,depositAmount
				,paymentAmount
				,particulars
				,closingBalance
				,''JPPOST'' bank
				,downloadDate
			FROM customer_deposit_logs
			'
			   
           SET @sql_filter = ''; 

		   IF @particulars IS NOT NULL
				SET	@sql_filter = @sql_filter + 'AND particulars like ''%'+@particulars+'%'''
		   IF @trandate IS NOT NULL
				SET	@sql_filter = @sql_filter + 'AND convert(varchar(10),tranDate,121) = '''+@trandate+''''
		   IF @depositAmount IS NOT NULL
				SET	@sql_filter = @sql_filter + 'AND depositAmount ='''+cast(@depositAmount as varchar)+''' '
		    SET @table = @table + ' )x';
       
           PRINT @table;
           SET @select_field_list = 'tranid,trandate,depositAmount,paymentAmount,particulars,closingBalance,bank,downloadDate';

           EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber;

END
IF @flag = 'depositListNew'
BEGIN
	IF @particulars = 'Nnull'
		SET @particulars = NULL
	DECLARE @sql nvarchar(max)
	set @sql = 'Select  ROW_NUMBER() OVER (ORDER BY tranid )  SN
						,convert(varchar(10), trandate,121) [Transaction Date]
						,depositAmount [Deposit Amount]
						,paymentAmount [Payment Amount]
						,particulars [Particulars]
						,closingBalance [Closing Balance]
						,''JPPOST'' Bank
						,CONVERT(VARCHAR(19),DownloadDate,121) [Download Date]
				FROM customer_deposit_logs
				where 1=1
			'
		   IF @particulars IS NOT NULL
				SET	@sql = @sql + ' AND particulars like N''%'+@particulars+'%'''
		   IF @trandate IS NOT NULL
				SET	@sql = @sql + ' AND convert(varchar(10),tranDate,121) = '''+@trandate+''''
		   IF @depositAmount IS NOT NULL
				SET	@sql = @sql + ' AND depositAmount ='''+cast(@depositAmount as varchar)+''' '
			PRINT(@sql)
			EXEC(@sql)

			
		EXEC proc_errorHandler '0', 'List has been prepared successfully.', NULL

		SELECT  'particulars' head, @particulars value UNION ALL
		SELECT  'Transction Date' head, @trandate value UNION ALL
		SELECT  'Amount' head, cast(@depositAmount as varchar) value 

		SELECT  'JP Deposit List' title
END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	SELECT ERROR_MESSAGE() MSG

END CATCH




