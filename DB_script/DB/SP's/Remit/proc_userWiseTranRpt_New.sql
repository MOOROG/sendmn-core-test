CREATE procEDURE [dbo].[proc_userWiseTranRpt_New]  
 @flag   VARCHAR(20),   
 @countryName  VARCHAR(50) = NULL,  
 @agentId   INT   = NULL,  
 @branchId   INT   = NULL,  
 @userName   VARCHAR(50) = NULL,  
 @fromDate   VARCHAR(20) = NULL,  
 @toDate   VARCHAR(30) = NULL,  
 @user   VARCHAR(50) = NULL,  
 @userType   VARCHAR(2) = NULL,  
 @rCountry   VARCHAR(50) = NULL  
  
AS   
SET NOCOUNT ON;  
SET ANSI_NULLS ON;  
  
  DECLARE @TABLE TABLE   
  (  
   BRANCHID INT,  
   BRANCHNAME VARCHAR(200) ,  
   USERNAME VARCHAR(50),  
   TXNSEND INT,  
   AMOUNTSEND MONEY,  
   TXNPAID INT,   
   AMOUNTPAID MONEY,  
   TXNAPPROVED INT,  
   AMOUNTAPPROVED MONEY,  
   TXNMODIFICATION INT  
  )  
  IF (DATEDIFF(DAY, @fromDate,GETDATE()) > 90 )  
  BEGIN   
    IF @FLAG ='detail'  
    BEGIN  
     SELECT DISTINCT USERNAME [HEAD] FROM @TABLE     
     SELECT      
      [HEAD]     = USERNAME  
     ,[Branch]    = BRANCHNAME  
     ,[#Send Trans]   = SUM(ISNULL(TXNSEND,0))   
     ,[Send Amount]   = SUM(ISNULL(AMOUNTSEND,0))   
     ,[#Paid Trans]   = SUM(ISNULL(TXNPAID,0))   
     ,[Paid Amount]   = SUM(ISNULL(AMOUNTPAID,0))   
     ,[#Approved Trans]  = SUM(ISNULL(TXNAPPROVED,0))   
     ,[Approved Amount]  = SUM(ISNULL(AMOUNTAPPROVED,0))   
     ,[#Amendment Count]  = SUM(ISNULL(TXNMODIFICATION,0))  
     ,agentId = BRANCHID    
     FROM @TABLE   
     GROUP BY BRANCHNAME,USERNAME,BRANCHID  
     
     EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
     SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
         (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
     UNION ALL  
     SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
     UNION ALL  
     SELECT 'From Date' head,@FROMDATE VALUE  
     UNION ALL  
     SELECT 'To Date' head,@TODATE VALUE  
     UNION ALL  
     SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
     SELECT 'USER WISE DETAIL REPORT <br><font color="red">Date Range is not valid, You can only view transaction upto 90 days.</font>' title  
     return;  
    END  
    ELSE  
    BEGIN  
     SELECT      
      [HEAD]     = USERNAME  
     ,[#SEND Trans]   = SUM(ISNULL(TXNSEND,0))   
     ,[SEND Amount]   = SUM(ISNULL(AMOUNTSEND,0))   
     ,[#Paid Trans]   = SUM(ISNULL(TXNPAID,0))   
     ,[Paid Amount]   = SUM(ISNULL(AMOUNTPAID,0))   
     ,[Approved Trans]  = SUM(ISNULL(TXNAPPROVED,0))   
     ,[Approved Amount]  = SUM(ISNULL(AMOUNTAPPROVED,0))   
     ,[#Amendment Count]  = SUM(ISNULL(TXNMODIFICATION,0))  
     FROM @TABLE GROUP BY USERNAME  
     
     EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
     SELECT 'Country' head,@countryName VALUE  
     UNION ALL  
     SELECT 'Agent' head,CASE WHEN @agentId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId) END VALUE  
     UNION ALL  
     SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
     UNION ALL  
     SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
     UNION ALL  
     SELECT 'From Date' head,@FROMDATE VALUE  
     UNION ALL  
     SELECT 'To Date' head,@TODATE VALUE  
     UNION ALL  
     SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
  
     SELECT 'USER WISE SUMMARY REPORT<br> <font color="red">Date Range is not valid, You can only view transaction upto 90 days.</font>' title  
     return;  
    END  
  END  
  
  IF (DATEDIFF(DAY, @fromDate,@toDate) > 32 )  
  BEGIN   
    IF @FLAG ='detail'  
    BEGIN  
     SELECT DISTINCT USERNAME [HEAD] FROM @TABLE  
     
     SELECT      
      [HEAD]     = USERNAME  
     ,[Branch]    = BRANCHNAME  
     ,[#Send Trans]   = SUM(ISNULL(TXNSEND,0))   
     ,[Send Amount]   = SUM(ISNULL(AMOUNTSEND,0))   
     ,[#Paid Trans]   = SUM(ISNULL(TXNPAID,0))   
     ,[Paid Amount]   = SUM(ISNULL(AMOUNTPAID,0))   
     ,[#Approved Trans]  = SUM(ISNULL(TXNAPPROVED,0))   
     ,[Approved Amount]  = SUM(ISNULL(AMOUNTAPPROVED,0))   
     ,[#Amendment Count]  = SUM(ISNULL(TXNMODIFICATION,0))  
     ,agentId = BRANCHID    
     FROM @TABLE   
     GROUP BY BRANCHNAME,USERNAME,BRANCHID  
  
     
     EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
     SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
         (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
     UNION ALL  
     SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
     UNION ALL  
     SELECT 'From Date' head,@FROMDATE VALUE  
     UNION ALL  
     SELECT 'To Date' head,@TODATE VALUE  
     UNION ALL  
     SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
     SELECT 'USER WISE DETAIL REPORT-<font color="red">Date Range is not valid, Please select date range of 32 days.</font>' title  
     return;  
    END  
    ELSE  
    BEGIN  
     SELECT      
      [HEAD]     = USERNAME  
     ,[#SEND Trans]   = SUM(ISNULL(TXNSEND,0))   
     ,[SEND Amount]   = SUM(ISNULL(AMOUNTSEND,0))   
     ,[#Paid Trans]   = SUM(ISNULL(TXNPAID,0))   
     ,[Paid Amount]   = SUM(ISNULL(AMOUNTPAID,0))   
     ,[Approved Trans]  = SUM(ISNULL(TXNAPPROVED,0))   
     ,[Approved Amount]  = SUM(ISNULL(AMOUNTAPPROVED,0))   
     ,[#Amendment Count]  = SUM(ISNULL(TXNMODIFICATION,0))  
     FROM @TABLE GROUP BY USERNAME  
     
     EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
     SELECT 'Country' head,@countryName VALUE  
     UNION ALL  
     SELECT 'Agent' head,CASE WHEN @agentId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId) END VALUE  
     UNION ALL  
     SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
     UNION ALL  
     SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
     UNION ALL  
     SELECT 'From Date' head,@FROMDATE VALUE  
     UNION ALL  
     SELECT 'To Date' head,@TODATE VALUE  
     UNION ALL  
     SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
  
     SELECT 'USER WISE SUMMARY REPORT- <font color="red">Date Range is not valid, Please select date range of 32 days.</font>' title  
     return;  
    END  
   END  
  
  SET @TODATE  = @TODATE + ' 23:59:59'  
  IF @FLAG='detail'  
  BEGIN  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNSEND,AMOUNTSEND)  
    SELECT    
      sBranch,  
      sBranchName,  
      createdBy,  
      COUNT('x'),  
      SUM(cAmt)   
    FROM vwRemitTran WITH(NOLOCK) WHERE createdDate BETWEEN @fromDate AND @toDate  
    AND sAgent = @agentId  
    AND sBranch = isnull(@branchId,sBranch)  
    AND createdby = isnull(@userName,createdBy)  
    AND isnull(pCountry,'') =  isnull(@rCountry,isnull(pCountry,''))  
    GROUP BY createdBy,sBranchName,sBranch  
  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNPAID,AMOUNTPAID)  
    SELECT    
       pBranch,  
       pBranchName,  
       paidBy,  
       COUNT('x'),  
       SUM(pAmt)   
    FROM vwRemitTran WITH(NOLOCK) WHERE paidDate BETWEEN @fromDate AND @toDate  
    AND pAgent = @agentId  
    AND pBranch = isnull(@branchId,pBranch)  
    AND paidBy = isnull(@userName,paidBy)  
    AND isnull(pCountry,'') =  isnull(@rCountry,isnull(pCountry,''))  
    GROUP BY paidBy,pBranchName,pBranch  
  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNAPPROVED,AMOUNTAPPROVED)  
    SELECT    
      sBranch,   
      sBranchName,  
       approvedBy,  
       COUNT('x'),  
       SUM(cAmt)   
    FROM vwRemitTran WITH(NOLOCK) WHERE approvedDate BETWEEN @fromDate AND @toDate  
    AND sAgent = @agentId  
    AND sBranch = isnull(@branchId,sBranch)  
    AND createdby = isnull(@userName,createdBy)  
    AND isnull(pCountry,'') =  isnull(@rCountry,isnull(pCountry,''))  
    GROUP BY approvedBy,sBranchName,sBranch  
  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNMODIFICATION)  
    select c.agentId, c.agentName ,a.createdBy,count('x')   
    from tranModifyLog a WITH(NOLOCK)   
    inner join applicationUsers b on a.createdBy=b.userName  
    inner join agentMaster c with(nolock) on b.agentId=c.agentId  
    inner join agentMaster d with(nolock) on c.parentId = d.agentId  
    inner join vwRemitTran e with(nolock) on a.controlNo = e.controlNo  
    where MsgType='MODIFY' and a.controlNo is not null  
    AND d.agentId = @agentId  
    and c.agentId = isnull(@branchId,c.agentId)  
    and a.createdby = isnull(@userName,a.createdBy)  
    and a.createdDate BETWEEN @fromDate AND @toDate  
    AND isnull(e.pCountry,'') =  isnull(@rCountry,isnull(e.pCountry,''))  
    group by a.createdBy,c.agentId,c.agentName  
  
    
    SELECT DISTINCT USERNAME [HEAD] FROM @TABLE  
     
    SELECT      
     [HEAD]     = USERNAME  
    ,[Branch]    = BRANCHNAME  
    ,[#Send Trans]   = SUM(ISNULL(TXNSEND,0))   
    ,[Send Amount]   = SUM(ISNULL(AMOUNTSEND,0))   
    ,[#Paid Trans]   = SUM(ISNULL(TXNPAID,0))   
    ,[Paid Amount]   = SUM(ISNULL(AMOUNTPAID,0))   
    ,[#Approved Trans]  = SUM(ISNULL(TXNAPPROVED,0))   
    ,[Approved Amount]  = SUM(ISNULL(AMOUNTAPPROVED,0))   
    ,[#Amendment Count]  = SUM(ISNULL(TXNMODIFICATION,0))  
    ,agentId = BRANCHID    
    FROM @TABLE   
    GROUP BY BRANCHNAME,USERNAME,BRANCHID  
  
     
    EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
    SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
    UNION ALL  
    SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
    UNION ALL  
    SELECT 'From Date' head,@FROMDATE VALUE  
    UNION ALL  
    SELECT 'To Date' head,@TODATE VALUE  
    UNION ALL  
    SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
    SELECT 'USER WISE DETAIL REPORT' title  
    
  END   
   
  IF @FLAG='summary'  
  BEGIN  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNSEND,AMOUNTSEND)  
    SELECT    
      sBranch,  
      sBranchName,  
      createdBy,  
      COUNT('x'),  
      SUM(cAmt)   
     FROM vwRemitTran WITH(NOLOCK) WHERE createdDate BETWEEN @fromDate AND @toDate  
      AND sAgent = @agentId  
      and sBranch = isnull(@branchId,sBranch)  
      and createdby = isnull(@userName,createdBy)  
      AND isnull(pCountry,'') =  isnull(@rCountry,isnull(pCountry,''))  
     GROUP BY createdBy,sBranchName,sBranch  
  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNPAID,AMOUNTPAID)  
    SELECT    
       pBranch,  
       pBranchName,  
       paidBy,  
       COUNT('x'),  
       SUM(pAmt)   
    FROM vwRemitTran WITH(NOLOCK) WHERE paidDate BETWEEN @fromDate AND @toDate  
    AND pAgent = @agentId  
    and pBranch = isnull(@branchId,pBranch)  
    and paidBy = isnull(@userName,paidBy)  
    AND isnull(pCountry,'') =  isnull(@rCountry,isnull(pCountry,''))  
     GROUP BY paidBy,pBranchName,pBranch  
  
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNAPPROVED,AMOUNTAPPROVED)  
    SELECT    
      sBranch,   
      sBranchName,  
       approvedBy,  
       COUNT('x'),  
       SUM(cAmt)   
    FROM vwRemitTran WITH(NOLOCK) WHERE approvedDate BETWEEN @fromDate AND @toDate  
    AND sAgent = @agentId  
    and sBranch = isnull(@branchId,sBranch)  
    and createdby = isnull(@userName,createdBy)  
    AND isnull(pCountry,'') =  isnull(@rCountry,isnull(pCountry,''))  
    GROUP BY approvedBy,sBranchName,sBranch  
      
    INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNMODIFICATION)  
    select c.agentId, c.agentName ,a.createdBy,count('x')   
    from tranModifyLog a WITH(NOLOCK)   
    inner join applicationUsers b on a.createdBy=b.userName  
    inner join agentMaster c with(nolock) on b.agentId=c.agentId  
    inner join agentMaster d with(nolock) on c.parentId = d.agentId  
    inner join vwRemitTran e with(nolock) on a.controlNo = e.controlNo  
    where MsgType='MODIFY' and a.controlNo is not null  
    AND d.agentId = @agentId  
    and c.agentId = isnull(@branchId,c.agentId)  
    and a.createdby = isnull(@userName,a.createdBy)  
    and a.createdDate BETWEEN @fromDate AND @toDate  
    AND isnull(e.pCountry,'') =  isnull(@rCountry,isnull(e.pCountry,''))  
    group by a.createdBy,c.agentId,c.agentName  
  
  
    SELECT      
     [HEAD]     = USERNAME  
    ,[#SEND Trans]   = SUM(ISNULL(TXNSEND,0))   
    ,[SEND Amount]   = SUM(ISNULL(AMOUNTSEND,0))   
    ,[#Paid Trans]   = SUM(ISNULL(TXNPAID,0))   
    ,[Paid Amount]   = SUM(ISNULL(AMOUNTPAID,0))   
    ,[Approved Trans]  = SUM(ISNULL(TXNAPPROVED,0))   
    ,[Approved Amount]  = SUM(ISNULL(AMOUNTAPPROVED,0))   
    ,[#Amendment Count]  = SUM(ISNULL(TXNMODIFICATION,0))  
    FROM @TABLE GROUP BY USERNAME  
     
    EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
    SELECT 'Country' head,@countryName VALUE  
    UNION ALL  
    SELECT 'Agent' head,CASE WHEN @agentId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId) END VALUE  
    UNION ALL  
    SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
    UNION ALL  
    SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
    UNION ALL  
    SELECT 'From Date' head,@FROMDATE VALUE  
    UNION ALL  
    SELECT 'To Date' head,@TODATE VALUE  
    UNION ALL  
    SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
  
    SELECT 'USER WISE SUMMARY REPORT' title  
  END  
   
  IF @FLAG='MODIFYHISTORY'  
  BEGIN  
    select [Branch]    = c.agentName   
      ,[User]    = a.createdBy  
      ,[Date]    = a.createdDate  
      ,[TranId]   = '<span class = "link" onclick ="ViewTranDetail(' + CAST(tranId AS VARCHAR(50)) + ');">' + CAST(tranId AS VARCHAR(50)) + '</span>'  
      ,[ControlNo]  = dbo.FNADecryptString(a.controlNo)  
      ,[Message]   = message  
      ,[Status]   = status  
      ,[Approved By]  = resolvedBy  
      ,[Approved Date] = resolvedDate  
    from tranModifyLog a WITH(NOLOCK)   
    inner join applicationUsers b on a.createdBy=b.userName  
    inner join agentMaster c with(nolock) on b.agentId=c.agentId  
    inner join vwRemitTran d with(nolock) on a.controlNo = d.controlNo  
    where MsgType='MODIFY'   
    and c.agentId = isnull(@branchId,c.agentId)  
    and a.createdby = isnull(@userName,a.createdBy)  
    and a.createdDate BETWEEN @fromDate AND @toDate  
    and a.controlNo is not null  
    AND isnull(d.pCountry,'') =  isnull(@rCountry,isnull(d.pCountry,''))  
    order by c.agentName,a.createdBY  
    EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
  
    SELECT 'Branch' head,CASE WHEN @branchId IS NULL THEN 'All' ELSE  
        (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@branchId) END VALUE  
    UNION ALL  
    SELECT 'User Name' head,ISNULL(@USERNAME,'All') VALUE  
    UNION ALL  
    SELECT 'From Date' head,@FROMDATE VALUE  
    UNION ALL  
    SELECT 'To Date' head,@TODATE VALUE  
    UNION ALL  
    SELECT 'Rec. Country' head, isnull(@rCountry,'All') VALUE  
  
    SELECT 'USER WISE MODIFY HISTORY' title  
  END  
  
  