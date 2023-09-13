  
alter proc [dbo].[proc_UserwiseTxnDetail]  
  @flag    VARCHAR(10) = NULL  
 ,@user    VARCHAR(30) = NULL  
 ,@sBranch   VARCHAR(40) = NULL   
 ,@userName   VARCHAR(100)= NULL   
 ,@fromDate   VARCHAR(20) = NULL  
 ,@toDate   VARCHAR(20) = NULL  
 ,@rCountry   VARCHAR(50) = NULL  
 ,@pageNumber  INT   = NULL  
 ,@pageSize   INT   = NULL  
     ,@sAgent      VARCHAR(50) = NULL      
AS  
   
  
     SET NOCOUNT ON;  
 DECLARE @SQL VARCHAR(MAX)  
   
     IF (DATEDIFF(DAY, @fromDate,@toDate) > 31 )  
     BEGIN  
  
    EXEC proc_errorHandler '1', 'Invalid date Range to view this report.', NULL  
    EXEC proc_errorHandler '1', 'Invalid date Range to view this report.', NULL  
    RETURN;  
  
     END  
  
     IF @userName IS NULL  
     BEGIN  
  
    EXEC proc_errorHandler '1', 'User Cannot be blank to view this report.', NULL  
    EXEC proc_errorHandler '1', 'User Cannot be blank to view this report.', NULL  
    RETURN;  
  
     END  
  
   if @sAgent is null  
       select @sAgent = A.agentId from applicationUsers U with (nolock), agentMaster B with (nolock),   
    agentMaster A with (nolock)  
   where U.agentId = B.agentId and B.parentId = A.agentId and userName = @user  
      
 SET @SQL = ' SELECT   
   [SN] = ROW_NUMBER() over (order by rt.createdDate)  
  ,[Tran No] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST(ISNULL(rt.holdTranId,RT.ID) AS VARCHAR(50)) + '');">'' + CAST(ISNULL(rt.holdTranId,RT.ID) AS VARCHAR(50)) + ''</span>''  
  ,[ICN] = dbo.FNADecryptString(rt.ControlNo)  
  ,[Sender Details] = rt.senderName + ''<br />'' + ISNULL(ts.membershipId , '''')  
  ,[Receiver Name] = rt.receiverName  
  ,[DOT] = CONVERT(VARCHAR(20), rt.createdDate, 120)   
  ,[Coll Mode] = Case when collmode = ''Bank Deposit'' then ''JP Post'' else collmode end
  ,[Paid Date] = ISNULL(CONVERT(VARCHAR(50), rt.paidDate, 120), '''')  
  ,[Tot Collected_Amt] = rt.cAmt  
  ,[Tot Collected_Curr] = rt.collCurr  
  ,[Send_Amt] = rt.tAmt  
  ,[Send_Curr] = rt.collCurr  
  ,[Charge_Amt] = rt.serviceCharge  
  ,[Charge_Curr] = rt.collCurr  
  ,[Receive_Amt] = rt.pAmt  
  ,[Receive_Curr] = rt.payoutCurr  
  ,[User ID] = rt.createdBy   
  ,[Receive Country] = rt.pCountry  
  ,rt.tranStatus  
  ,rt.payStatus  
 FROM vwremitTran rt WITH(NOLOCK)  
 INNER JOIN vwtranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId  
 INNER JOIN vwtranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId  
 WHERE 1=1 '  
  
   
 IF @flag = 'paid'  
 BEGIN  
  IF @sBranch IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.pBranch = '''+ @sBranch+''''  
  
  --IF @userName IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.paidBy = '''+ @userName+''''  
  
  IF @rCountry IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.pCountry = '''+ @rCountry+''''  
    
  SET @SQL = @SQL +' and  RT.paidDate BETWEEN  '''+@fromDate+'''  AND  '''+@toDate+' 23:59:59'''  

  SET @SQL = @SQL +' order by rt.paidDate'  
 END  
   
 IF @flag = 'send'  
 BEGIN  
  IF @sBranch IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.sBranch = '''+ @sBranch+''''  
  
  SET @SQL = @SQL + '  AND  RT.createdBy = '''+ @userName+''''  
  
  IF @rCountry IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.pCountry = '''+ @rCountry+''''  
  SET @SQL = @SQL +' and RT.createdDate BETWEEN  '''+@fromDate+'''  AND  '''+@toDate+' 23:59:59'''  
   SET @SQL = @SQL + 'order by rt.createdDate'  
 END  
   
 IF @flag = 'Approved'  
 BEGIN  
  IF @sBranch IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.sBranch = '''+ @sBranch+''''  
  
  SET @SQL = @SQL + '  AND  RT.approvedBy = '''+ @userName+''''  
    
  IF @rCountry IS NOT NULL  
   SET @SQL = @SQL + '  AND  RT.pCountry = '''+ @rCountry+''''  
  
  SET @SQL = @SQL +' and  RT.approvedDate BETWEEN  '''+@fromDate+'''  AND  '''+@toDate+' 23:59:59'''  

 END  
  
 --print @sql  
 exec(@sql)  
   
  
 EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
   
 SELECT 'Branch' head,CASE WHEN @sBranch IS NULL THEN 'All' ELSE  
       (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sBranch) END VALUE  
 UNION ALL  
 SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
 UNION ALL  
 SELECT 'From Date' head,@FROMDATE VALUE  
 UNION ALL  
 SELECT 'To Date' head,@TODATE VALUE  
 UNION ALL  
 SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
  
 SELECT 'Userwise Txn Report '+@flag title  
   
   
   
    
   
  