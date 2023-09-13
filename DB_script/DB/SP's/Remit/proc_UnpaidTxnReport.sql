  
  
alter PROC [dbo].[proc_UnpaidTxnReport]  
(    
  @flag    VARCHAR(50)  
 ,@user    VARCHAR(100) = NULL  
 ,@tranType   char(1)   = NULl  
 ,@agentId   VARCHAR(100) = NULL  
 ,@agentName   VARCHAR(100) = NULL  
 ,@pageNumber  INT    = 1  
 ,@pageSize   INT    = 50   
 ,@country   varchar(5)  = NULL  
 ,@asOnDate varchar(10) = null
)   
AS  
 SET NOCOUNT ON  
 SET XACT_ABORT ON  
 /*  
  proc_UnpaidTxnReport @flag = 's' ,@tranType = 'I'  
  EXEC proc_MultipleTxnAnalysisReport @flag = 's',@user='admin',@fromDate = '2014-01-01',@toDate = '2014-04-09',@tranType = 'I',@reportBy = 'ssmr',@customer = null,@pageNumber = '1',@pageSize = '100'  
 */  
  
SET @tranType = 'I'  
   
BEGIN  
   
 DECLARE @reportName varchar(50) = '20167500'  
   
 IF @flag = 's'  
 BEGIN   
  SELECT  
  [SNO] = ROW_NUMBER() over (ORDER BY pcountry ASC)  
  ,[Pay Country] = pcountry  
  ,[Total Amount] = SUM(pAmt)  
  ,[Total TXN] = COUNT(1)  
  FROM remitTran RT WITH(NOLOCK)  
  INNER JOIN countryMaster CM(NOLOCK) ON CM.countryName = RT.pCountry  
  WHERE tranStatus='Payment'   
  AND CM.countryId = ISNULL(@country, CM.countryId)  
  AND payStatus in('Post','Unpaid')  
  GROUP BY pcountry  
  
     EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
     
  SELECT  'Trn Type ' head, 'International' value   
    
  SELECT 'Unpaid Transacton Report' title  
 END  
   
 ELSE IF @flag = 'detail'   
 BEGIN  
  SELECT  
  controlNo = '<a href="../../Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+cast(rt.id as varchar)+'">'+dbo.FNADecryptString(controlNo) +'</a>',  
  [Pay Country] = pCountry,  
  [Pay Method] = paymentMethod,  
  [S.Curr] = collCurr,  
  [S.Amount ] = cAmt,  
  [p.Curr] = payoutCurr,   
  [P.Amount] = pAmt,  
  [TxnDate] = rt.approvedDate,  
  [Sender] = rt.senderName,  
  [Sender Mobile] = ts.mobile,  
  [Receiver] = rt.receiverName,  
  [Rec. Mobile] = tr.mobile  
  FROM remitTran rt WITH(NOLOCK)  
  INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId  
  INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId  
  WHERE tranStatus = 'Payment' AND payStatus in('Post','Unpaid')    
  AND rt.sAgent = @agentId  
  order by rt.id  
  EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
     
  SELECT  'Agent' head, @agentName value  
  SELECT 'Unpaid Transacton Report - Detail' title  
 END  
 ELSE IF @flag = 'detail1'   
 BEGIN  
	declare @date varchar(30) = @asOnDate
	select  controlNo = '<a href="../../Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+cast(id as varchar)+'">'+dbo.FNADecryptString(controlNo) +'</a>',  
		[Pay Country] = pCountry,  
		[Pay Method] = paymentMethod,  
		[S.Curr] = collCurr,  
		[S.Amount ] = cAmt,
		[T.Amount ] = tAmt,   
		[p.Curr] = payoutCurr,   
		[P.Amount] = pAmt,  
		[TxnDate] = convert(varchar,approvedDate,121),  
		[Sender] = senderName,  
		[Sender Mobile] = smobile,  
		[Receiver] = receiverName,  
		[Rec. Mobile] = rmobile  
	from(
	SELECT rt.id,CONTROLNO,pCountry,paymentMethod,collCurr,cAmt,tAmt,payoutCurr,pAmt,rt.approvedDate,rt.senderName,ts.mobile [smobile],rt.receiverName,tr.mobile [rmobile]
	FROM REMITTRAN (NOLOCK) rt
	INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId  
    INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId  
    INNER JOIN countryMaster CM(NOLOCK) ON CM.countryName = RT.pCountry  
	WHERE CAST(rt.CREATEDDATE AS DATE) <= @date
	AND CAST(rt.PAIDDATE AS DATE) > @date
	AND CM.COUNTRYID = ISNULL(@country,CM.COUNTRYID)
	--ORDER BY CREATEDDATE
	UNION ALL
	
	SELECT rt.id,CONTROLNO,pCountry,paymentMethod,collCurr,cAmt,tAmt,payoutCurr,pAmt,rt.approvedDate,rt.senderName,ts.mobile [smobile],rt.receiverName,tr.mobile [rmobile]
	FROM REMITTRAN (NOLOCK) rt
	INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId  
    INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId  
    INNER JOIN countryMaster CM(NOLOCK) ON CM.countryName = RT.pCountry  
	WHERE CAST(rt.CREATEDDATE AS DATE) <= @date
	AND CAST(rt.CANCELAPPROVEDDATE AS DATE) > @date
	AND CM.COUNTRYID = ISNULL(@country,CM.COUNTRYID)
	--ORDER BY CREATEDDATE
	
	UNION ALL
	
	SELECT rt.id,CONTROLNO,pCountry,paymentMethod,collCurr,cAmt,tAmt,payoutCurr,pAmt,rt.approvedDate,rt.senderName,ts.mobile [smobile],rt.receiverName,tr.mobile [rmobile]
	FROM REMITTRAN (NOLOCK) rt
	INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId  
    INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId  
    INNER JOIN countryMaster CM(NOLOCK) ON CM.countryName = RT.pCountry  
	WHERE CAST(rt.CREATEDDATE AS DATE) <= @date
	AND rt.CANCELAPPROVEDDATE IS NULL
	AND rt.PAIDDATE IS NULL
	AND CM.COUNTRYID = ISNULL(@country,CM.COUNTRYID)
	--ORDER BY CREATEDDATE
	)x order by approvedDate
  
  EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
     
  SELECT  'Trn Type ' head, CASE WHEN @tranType='I' THEN 'International' WHEN @tranType ='D' THEN 'Domestic' END value  
  UNION ALL    
  SELECT  'Agent' head, @agentName value  
  SELECT 'Unpaid Transacton Report - Detail' title  
 END  
END  
  
  
  
  
  