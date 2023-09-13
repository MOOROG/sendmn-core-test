
--EXEC PROC_DAILYPAID_AND_SENDING @flag = 'SEND',@user = 'admin',@startDate = '2020-01-07',@endDate = '2020-01-07',@sAgentId = null,@payoutPartnerId = null,@payoutPartnerName = 'All'

--EXEC PROC_DAILYPAID_AND_SENDING @flag = 'PAID',@user = 'admin',@startDate = '2020-01-09',@endDate = '2020-01-09',@sAgentId = null,@payoutPartnerId = null


USE FastMoneyPro_Remit
Go
ALTER PROC PROC_DAILYPAID_AND_SENDING
	 @flag					VARCHAR(10)
	,@user					VARCHAR(30)		= NULL
	,@startDate				VARCHAR(10)		= NULL
	,@endDate				VARCHAR(10)		= NULL
	,@sAgentId				BIGINT			= NULL
	,@payoutPartnerId		BIGINT			= NULL
	,@payoutPartnerName     VARCHAR(100)    = NULL
	,@sortBy				VARCHAR(50)		= NULL        
	,@sortOrder				VARCHAR(5)		= NULL        
	,@pageSize				INT				= NULL        
	,@pageNumber			INT				= NULL        
AS
BEGIN TRY
	DECLARE     
   @select_field_list VARCHAR(MAX)    
  ,@extra_field_list  VARCHAR(MAX)    
  ,@table             VARCHAR(MAX)    
  ,@sql_filter        VARCHAR(MAX)    
  ,@sAgentName   VARCHAR(150)
  ,@pAgentName   VARCHAR(150)
  ,@endDateNew		VARCHAR(20)
  
   SELECT @sAgentName = agentName FROM dbo.agentMaster WHERE agentid = @sAgentId
   SELECT @pAgentName = agentName FROM dbo.agentMaster WHERE agentid = @payoutPartnerId
   SET @endDateNew = @endDate + ' 23:59:59'
IF @flag = 'PAID'
BEGIN

	SELECT ROW_NUMBER() OVER (ORDER BY rt.id) SN
	,rt.id [Receipt No]
	,convert(varchar,rt.createdDate,121) [Creation Date]
	,rt.paidDate [Payment Date]
	,rt.createdBy [User Name]
	,rt.pSuperAgentName [Payment Office]
	,rt.sCountry [Country Of Origin]
	,rt.receiverName [Beneficiary]
	,tr.mobile [Receiver Mobile]
	,rt.tAmt [Amount To Send]
	,rt.collCurr [Currency]
	,rt.pAmt [Amount to Receive]
	,rt.payoutCurr [Currency]
	,rt.pCountry [Receiver country]
	,CASE rt.paymentMethod WHEN 'BANK DEPOSIT' THEN 'BT' 
						   WHEN 'CASH PAYMENT' THEN 'CPU' END [Payment Type]
	,dbo.FNADecryptString(rt.controlNo) [Control Number]
	FROM remittran rt (NOLOCK)
	INNER JOIN dbo.tranReceivers tr (NOLOCK) ON tr.tranId = rt.id
	WHERE pSuperAgent = ISNULL(@payoutPartnerId, pSuperAgent) 
	AND sAgent = ISNULL(@sAgentId, sAgent) 
	AND paidDate BETWEEN @startDate AND @endDateNew 
	AND (PAYSTATUS = 'PAID')
	ORDER BY rt.createdDate

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  

	SELECT  'Paying Agent' head, ISNULL(@pAgentName, 'All') value  UNION all   
	SELECT  'From Date' head, @startDate value UNION all   
	SELECT  'To Date' head, @endDate value    
    
	SELECT 'Daily Paid Report Agent' title  

END
IF @flag = 'SEND'
BEGIN
	SELECT ROW_NUMBER() OVER (ORDER BY id) SN
		   ,id [Transaction No]
		   ,dbo.FNADecryptString(controlNo) [Control Number]
		   ,collMode [Deposit Type]
		   ,'Sent' [Tran Status]
		   ,CASE paymentMethod WHEN 'BANK DEPOSIT' THEN 'BT' 
							   WHEN 'CASH PAYMENT' THEN 'CPU' END [Payment Type]
		   ,createdDate [Date]
		   ,pSuperAgentName [Corresponding]
		   ,senderName [Sender]
		   ,createdBy [Cashier]
		   ,tAmt [Money Send]
		   ,collCurr [Currency]
		   ,serviceCharge [Commision]
		   ,cAmt [Total Amount]
		   ,pAmt [Money Received]
		   ,payoutCurr [PayCCY]
		   ,pCurrCostRate [Settlement Rate]
		   ,customerRate [CustRate]
		   ,payoutCurr [Currency Type] 
		   ,pCountry [Receiver Country]
	FROM remittran WHERE pSuperAgent = ISNULL(@payoutPartnerId, pSuperAgent) 
	AND sAgent = ISNULL(@sAgentId, sAgent) 
	AND createdDate BETWEEN @startDate AND @endDateNew 

	UNION ALL

	SELECT ROW_NUMBER() OVER (ORDER BY id) SN
		   ,id [Transaction No]
		   ,dbo.FNADecryptString(controlNo) [Control Number]
		   ,collMode [Deposit Type]
		   ,'Cancel' [Tran Status]
		   ,CASE paymentMethod WHEN 'BANK DEPOSIT' THEN 'BT' 
							   WHEN 'CASH PAYMENT' THEN 'CPU' END [Payment Type]
		   ,createdDate [Date]
		   ,pSuperAgentName [Corresponding]
		   ,senderName [Sender]
		   ,createdBy [Cashier]
		   ,-1 * tAmt [Money Send]
		   ,collCurr [Currency]
		   ,-1 * serviceCharge [Commision]
		   ,-1 * cAmt [Total Amount]
		   ,-1 * pAmt [Money Received]
		   ,payoutCurr [PayCCY]
		   ,pCurrCostRate [Settlement Rate]
		   ,customerRate [CustRate]
		   ,payoutCurr [Currency Type] 
		   ,pCountry [Receiver Country]
	FROM remittran WHERE pSuperAgent = ISNULL(@payoutPartnerId, pSuperAgent) 
	AND sAgent = ISNULL(@sAgentId, sAgent) 
	AND cancelApprovedDate BETWEEN @startDate AND @endDateNew 
	AND tranStatus IN ('Cancel')
        
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
     
	SELECT  'Sending Agent' head, @sAgentName value  UNION all   
	SELECT  'From Date' head, @startDate value UNION all   
	SELECT  'To Date' head, @endDate value 

	SELECT 'Daily Send Report Agent' title  

END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT 1 ERRORCODE,ERROR_MESSAGE() MSG,NULL ID
END CATCH

