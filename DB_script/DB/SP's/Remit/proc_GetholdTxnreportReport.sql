alter proc proc_GetholdTxnreportReport
		@user  VARCHAR(10) ,
		@fromDate varchar(10) = NULL,
		@toDate varchar(10) = NULL,
		@rptType varchar(20) = NULL,
		@pageNumber  INT    = NULL,  
		@pageSize  INT    = NULL ,
		@branchId  varchar(10) = NULL
As
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
 DECLARE @SQL VARCHAR(MAX),@dateNew varchar(20)
	SET @dateNew = @toDate + ' 23:59:59'

	IF @rptType = 'VIEW'
	BEGIN
	set @SQL = '
	SELECT [SN]  = ROW_NUMBER() over (ORDER BY createdDate ),
		rt.id TranId,
		dbo.fnadecryptstring(controlNo) [JME NO],
		senderName [Sender Name],
		receiverName [Receiver Name],
		pCountry [Payout Country],
		CONVERT(date,createdDate,105)[Transaction Date],
		cAmt [Collect Amount],
		collcurr [Collect Currency],
		case when collMode = ''Bank Deposit'' then ''JP Post'' else  collMode end [Collection Mode],
		pamt [Payout Amount],
		payoutcurr [Payout Currency],
		tranStatus [Status],
		raw.REFERRAL_NAME [Inroducer],
		createdBy [User Name]
		FROM remitTranTemp rt (NOLOCK) 
		LEFT JOIN REFERRAL_AGENT_WISE raw (NOLOCK) ON raw.REFERRAL_CODE = rt.promotionCode
		where rt.createdDate between '''+@fromDate+''' and '''+@dateNew+'''
		AND rt.createdby = '''+@user+'''
		order by rt.id
		'
	END
	ELSE
	BEGIN 
	set @SQL = '
	SELECT [SN]  = ROW_NUMBER() over (ORDER BY createdDate ),
	 dbo.fnadecryptstring(controlNo) [JME NO],
		senderName [Sender Name],
		receiverName [Receiver Name],
		pCountry [Payout Country],
		CONVERT(date,createdDate,105)[Transaction Date],
		cAmt [Collect Amount],
		collcurr [Collect Currency],
	    case when collMode = ''Bank Deposit'' then ''JP Post'' else  collMode end [Collection Mode],
		pamt [Payout Amount],
		payoutcurr [Payout Currency],
		tranStatus [Status],
		createdBy [User Name]
		FROM remitTranTemp
		where createdDate between '''+@fromDate+''' and '''+@dateNew+'''
		AND sBranch='''+@branchId+'''
		order by id
		'

	END
	 PRINT @SQL    
	 EXEC(@SQL)  
  
	 EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
	 SELECT 'fromDate' head, @fromDate value
	 UNION ALL
	 SELECT 'toDate' head, @toDate value 
	 SELECT 'Hold Transaction Report' title
END 