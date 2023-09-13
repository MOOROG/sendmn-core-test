alter proc PROC_TRANSACTION_REPORT
	@flag				VARCHAR(10) = NULL
	,@user				VARCHAR(30) = NULL
	,@pCountry			VARCHAR(100)= NULL
	,@pAgent			VARCHAR(40) = NULL
	,@pBranch			VARCHAR(40) = NULL	
	,@sBranch			VARCHAR(40) = NULL		
	,@depositType		VARCHAR(40) = NULL
	,@searchBy			VARCHAR(40) = NULL
	,@searchByValue		VARCHAR(40) = NULL
	,@orderBy			VARCHAR(40) = NULL
	,@status			VARCHAR(40) = NULL
	,@paymentType		VARCHAR(40) = NULL
	,@dateField			VARCHAR(50) = NULL
	,@dateFrom			VARCHAR(20) = NULL
	,@dateTo			VARCHAR(20) = NULL
	,@transType			VARCHAR(40) = NULL
	,@displayTranNo		CHAR(1)		= NULL
	,@pageNumber		INT			= NULL
	,@pageSize			INT			= NULL
	,@rptType			CHAR(1)		= NULL
AS 
SET NOCOUNT ON;
SET CONCAT_NULL_YIELDS_NULL OFF;  
BEGIN
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	DECLARE @SQL VARCHAR(MAX),@usertype VARCHAR(5)
	IF @sBranch IS NOT NULL
	INSERT INTO @FilterList 
	SELECT 
		'Branch Name', agentName 
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch

	IF @searchByValue IS NOT NULL AND @searchBy IS NOT NULL
	BEGIN
			INSERT INTO @FilterList
			SELECT
			CASE @searchBy
				WHEN 'cid'		THEN 'Customer ID'
				WHEN 'sName'	THEN 'Sender Name'
				WHEN 'rName'	THEN 'Receiver Name'
				WHEN 'icn'		THEN 'Control No'
			END
			,@searchByValue
	END	
	Set @status = ISNULL(@status,'')
	SET @transType = ISNULL(@transType,'')
	SET @paymentType = CASE WHEN @paymentType = '1' THEN 'CASH PAYMENT' 
							WHEN @paymentType = '2' THEN 'BANK DEPOSIT'
							WHEN @paymentType IS NULL THEN '' ELSE @paymentType END
						 --ISNULL(@paymentType,'')
	set @sBranch = ISNULL(@sBranch,'')

	select @usertype = usertype from applicationusers where username = @user

IF @rptType = 's'
BEGIN 
	SET @SQL = '	select 
			 [BRN_NO]		
			,[Serial No]
			,[Status]
			,[DATE_SEND]	
			,[DATE_PAID]	
			,CUSTOMER_ID
			,[SENDER_NAME]	
			,[SENDER_MOBILE]
			,[RECEIVER_NAME]
			,[EX_RATE]		
			,[COLLECTION_MODE]
			,[PAYMENT_TYPE]	
			,[COLLECTED_AMT]
			,[COLLECTED_CURR]
			,[SEND_AMT]		
			,[SEND_CURR]	
			,[CHARGE_CURRSc]
			,[CHARGE_CURR]	
			,[RECEIVED_AMT]	
			,[RECEIVED_CURR]
			,[USER_SEND]	
			,[USER_RECEIVED]
			,TRANSTATUS		
			,PAYSTATUS			
			,createddate 
			,[CONTROL_NO]
	 from 
	(SELECT 
			[BRN_NO]		= CASE WHEN '''+ISNULL(@usertype,'')+'''=''A'' THEN ''<a href="../SearchTxnReport/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(RT.ID AS VARCHAR)+''">''+DBO.FNADECRYPTSTRING(CONTROLNO)+''</a>''
															  ELSE ''<a href="/Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(RT.ID AS VARCHAR)+''">''+DBO.FNADECRYPTSTRING(CONTROLNO)+''</a>'' END
			,[Serial No]  = RT.id
			,''UnApproved'' [Status]
			,[DATE_SEND]	=CONVERT(VARCHAR,RT.createdDate,111)
			,[DATE_PAID]	= CONVERT(VARCHAR,RT.paidDate,111)
			,[CUSTOMER_ID] = TS.CUSTOMERID
			,[SENDER_NAME]	= senderName
			,[SENDER_MOBILE] = TS.MOBILE
			,[RECEIVER_NAME]= receiverName
			,[EX_RATE]		= customerRate
			,[COLLECTION_MODE]	= Case when collmode = ''Bank Deposit'' then ''JP Post'' else collmode end
			,[PAYMENT_TYPE]	= paymentMethod
			,[COLLECTED_AMT]	= cAmt
			,[COLLECTED_CURR]	= collCurr
			,[SEND_AMT]		= tAmt
			,[SEND_CURR]	= collCurr
			,[CHARGE_CURRSc]	= serviceCharge
			,[CHARGE_CURR]	= collCurr
			,[RECEIVED_AMT]	= pAmt
			,[RECEIVED_CURR]= payoutCurr
			,[USER_SEND]	= approvedBy
			,[USER_RECEIVED]= paidBy
			,TRANSTATUS		= transtatus
			,PAYSTATUS		= PAYSTATUS 
			,rt.createddate
			,RT.sBranch
			,[CONTROL_NO] =  DBO.FNADECRYPTSTRING(RT.CONTROLNO)
	FROM REMITTRANTEMP RT(NOLOCK) 
	LEFT JOIN TRANSENDERSTEMP TS (NOLOCK) ON TS.TRANID = RT.ID
	WHERE createddate BETWEEN '''+@dateFrom+''' AND '''+@dateTo+'''+'' 23:59:59''
	AND transtatus IN (''OFAC Hold'',''Compliance Hold'',''OFAC/Compliance Hold'')
	AND paymentMethod =CASE WHEN '''+@paymentType+''' = '''' THEN paymentMethod ELSE '''+@paymentType+''' END

	union all

	SELECT 
			[BRN_NO]		= CASE WHEN '''+ISNULL(@usertype,'')+''' = ''A'' THEN ''<a href="../SearchTxnReport/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(RT.ID AS VARCHAR)+''">''+DBO.FNADECRYPTSTRING(CONTROLNO)+''</a>''
															  ELSE ''<a href="/Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(RT.ID AS VARCHAR)+''">''+DBO.FNADECRYPTSTRING(CONTROLNO)+''</a>'' END
			,[Serial No]  = RT.holdtranid
			,''Approved'' [Status]
			,[DATE_SEND]	=CONVERT(VARCHAR,RT.approvedDate,111)
			,[DATE_PAID]	= CONVERT(VARCHAR,RT.paidDate,111)
			,[CUSTOMER_ID] = TS.CUSTOMERID
			,[SENDER_NAME]	= senderName
			,[SENDER_MOBILE] = TS.MOBILE
			,[RECEIVER_NAME]= receiverName
			,[EX_RATE]		= customerRate
			,[COLLECTION_MODE]	= Case when collmode = ''Bank Deposit'' then ''JP Post'' else collmode end
			,[PAYMENT_TYPE]	= paymentMethod
			,[COLLECTED_AMT]	= cAmt
			,[COLLECTED_CURR]	= collCurr
			,[SEND_AMT]		= tAmt
			,[SEND_CURR]	= collCurr
			,[CHARGE_CURRSc]	= serviceCharge
			,[CHARGE_CURR]	= collCurr
			,[RECEIVED_AMT]	= pAmt
			,[RECEIVED_CURR]= payoutCurr
			,[USER_SEND]	= approvedBy
			,[USER_RECEIVED]= paidBy
			,TRANSTATUS		= transtatus
			,PAYSTATUS		= PAYSTATUS 
			,rt.createddate
			,RT.sBranch
			,[CONTROL_NO] = DBO.FNADECRYPTSTRING(RT.CONTROLNO)
	FROM REMITTRAN RT(NOLOCK) 
	LEFT JOIN TRANSENDERS TS (NOLOCK) ON TS.TRANID = RT.ID
	WHERE approvedDate BETWEEN '''+@dateFrom+''' AND '''+@dateTo+'''+'' 23:59:59''
	AND payStatus = CASE WHEN '''+@status+'''  = '''' THEN payStatus ELSE '''+@status+''' END
	AND transtatus = CASE WHEN '''+@transType+''' = '''' THEN transtatus ELSE '''+@transType+'''  END
	AND paymentMethod =CASE WHEN '''+@paymentType+''' = '''' THEN paymentMethod ELSE '''+@paymentType+''' END
	)xyz
	where sBranch = CASE WHEN '''+@sBranch+''' = '''' THEN sBranch ELSE '''+@sBranch+''' END '

	IF @searchByValue IS NOT NULL AND @searchBy IS NOT NULL
	BEGIN
		IF @searchBy = 'sName'
			SET @SQL = @SQL + 'AND SENDER_NAME like ''%'+@searchByValue+'%'''
		IF @searchBy = 'rName'
			SET @SQL = @SQL + 'AND RECEIVER_NAME like ''%'+@searchByValue+'%'''
		IF @searchBy = 'cid'
			SET @SQL = @SQL + 'AND CUSTOMER_ID = '''+@searchByValue+''''
		IF @searchBy = 'cAmt'
			SET @SQL = @SQL + 'AND COLLECTED_AMT = '''+@searchByValue+''''
		IF @searchBy = 'icn'
			SET @SQL = @SQL + 'AND CONTROL_NO = '''+@searchByValue+''''
	END

	SET @SQL = @SQL + 'order by xyz.createddate desc'
	PRINT @SQL
	EXEC (@SQL)
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
	SELECT *,NULL FROM @FilterList
	   
	SELECT 'TXN Report' title

END



END


	