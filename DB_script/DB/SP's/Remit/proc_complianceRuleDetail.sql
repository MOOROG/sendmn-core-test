  
/*  
declare @complienceMessage varchar(1000)  
 EXEC [proc_complianceRuleDetail]  
@flag= 'sender-limit',@user= 'rajendragurung243@gmail.com',@sIdType= 'Alien Registration Card',@sIdNo= '920412-5280049'  
,@cAmt= '2100000.00',@cAmtUSD= '1961.7001',@customerId= 433,@pCountryId= 151,@deliveryMethod= 1,@message= @complienceMessage OUTPUT  
select @complienceMessage  
  
*/  
ALTER PROC proc_complianceRuleDetail  
  
 @flag    VARCHAR(30)  = 'core'  
 ,@user    VARCHAR(50)    
 ,@pCountryId  INT  
 ,@deliveryMethod INT   
 ,@cAmt    MONEY   = null  
 ,@cAmtUSD   MONEY   
 ,@customerId  VARCHAR(20)     
 ,@receiverName  VARCHAR(50)  = NULL  
 ,@sIdNo    VARCHAR(50)     = NULL   
 ,@sIdType   VARCHAR(50)  = NULL  
 ,@receiverMobile VARCHAR(25)  = NULL  
 ,@message   VARCHAR(1000) = NULL OUTPUT  
 ,@shortMessage  VARCHAR(100) = NULL OUTPUT  
 ,@errCode   TINYINT   = NULL OUTPUT  
 ,@ruleId   INT    = NULL OUTPUT  
AS  
SET NOCOUNT ON  
/*  
 1> Get the data for per txn, monthly txn and yearly txn limit amount  
 2> Check for per txn limit, and return with proper error message if limit amount exceeded  
    3> Check for monthly txn limit, and return with proper error message if limit amount exceeded  
    4> Check for yearly txn limit, and return with proper error message if limit amount exceeded  
    5> Return success message and code if no issue with compliance rule  
*/     
BEGIN  
    DECLARE @perTxnLimitAmt MONEY  
 DECLARE @limitAmt MONEY  
 DECLARE @comRuleId INT  
 DECLARE @csMasterId INT  
 DECLARE @YearStart DATE, @YearEnd DATE, @MonthStart DATE, @MonthEnd DATE, @ruleType CHAR(1)  
  
 SELECT @YearStart = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)  
     ,@YearEnd = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)  
     ,@MonthStart = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)  
     ,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0))  
   
 IF @flag = 'core'  
 BEGIN  
  --Checking for per txn limit (if country wise rule is defined the pick country wise)  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 0 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 0  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 0  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
    
  IF @cAmtUSD > @limitAmt--@cAmt > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because the transaction   
     amount (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>), is exceeded as <b>per transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>).'  
  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per txn limit exceeded.'  
   RETURN  
  END  
   
  CREATE TABLE #tempTran(id BIGINT, cAmt MONEY, cAmtUSD MONEY, sIdType VARCHAR(50),sIdNo VARCHAR(50),approvedDate DATETIME  
   ,createdDate DATETIME,tranStatus VARCHAR(20))  
  
  CREATE TABLE #tempTranR(id BIGINT, cAmt MONEY, cAmtUSD MONEY, approvedDate DATETIME, createdDate DATETIME, tranStatus VARCHAR(20)  
   ,receiverName VARCHAR(50))  
   
  DECLARE   
     @sql      VARCHAR(MAX)  
    ,@cutOffDate VARCHAR(10) = CONVERT(VARCHAR, DATEADD(Day,-365, GETDATE()), 101)  
    ,@sumTxnAmt MONEY  
    ,@sumTxnAmtUSD MONEY  
  
  -- Get the record of 365 days into temp table  
  INSERT INTO #tempTran(id,cAmt,cAmtUSD,sIdType,sIdNo,approvedDate,createdDate,tranStatus)  
  SELECT r.id,r.cAmt, r.cAmt--/(isnull(r.sCurrCostRate, 0) + ISNULL(r.sCurrHoMargin, 0)) 
  ,s.idType,s.idNumber,r.approvedDate,r.createdDate,r.tranStatus   
  FROM vwRemitTran R(nolock)  
  INNER JOIN vwtranSenders S(nolock) ON R.ID = S.tranId  
  WHERE r.tranStatus <> 'Cancel'  
  AND S.customerId = @customerId  
  AND r.approvedDate BETWEEN @YearStart AND CONVERT(VARCHAR,@YearEnd,101)+' 23:59:59'  
  --AND S.idNumber=@sIdNo --AND S.idType = @sIdType   
  --and s.country= @country  
    
   
  --##START#####--Check for DAILY txn limit exceeded or not  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 1 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))  
  FROM #tempTran   
  WHERE approvedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()  
  
  IF (isnull(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because previous transaction sum is  
     (<b>'+CAST(@sumTxnAmtUSD AS VARCHAR)+' USD</b>) and by doing this transaction (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>)  
     <b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.'  
  
   --SELECT @errCode = 1, @message = 'Daily txn limit exceeded.', @ruleId = @comRuleId  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per day limit exceeded.'  
   RETURN  
  END  
  --##END#####--Check for DAILY txn limit exceeded or not  
  
  --##START#####--Check for MONTHLY txn limit exceeded or not  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 30 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
   
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),   
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))  
  FROM #tempTran   
  WHERE approvedDate BETWEEN @MonthStart AND CONVERT(VARCHAR,@MonthEnd,101)+' 23:59:59'  
   
  IF (isnull(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because previous transaction sum is  
     (<b>'+CAST(@sumTxnAmtUSD AS VARCHAR)+' USD</b>) and by doing this transaction (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>)  
     <b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.'  
  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Monthly txn limit exceeded.'  
   RETURN  
  END  
  --##END#####--Check for MONTHLY txn limit exceeded or not  
  
  
  --##START#####----Check for YEARLY txn limit exceeded or not  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 365 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
   
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))   
  FROM #tempTran    
   
  IF (isnull(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because previous transaction sum is  
     (<b>'+CAST(@sumTxnAmtUSD AS VARCHAR)+' USD</b>) and by doing this transaction (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>)  
     <b>per year transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.'  
  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Yearly txn limit exceeded.'  
   RETURN  
  END  
  --##END#####----Check for YEARLY txn limit exceeded or not  
  
  IF ISNULL(@receiverName, '') = ''  
  BEGIN  
   SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
   RETURN  
  END  
  
  SET @receiverMobile = '%' + @receiverMobile  
  -- ## Start of multiple sender same Reciever txn limit  
  INSERT INTO  #tempTranR(id,cAmt, cAmtUSD,receiverName,approvedDate,createdDate,tranStatus)  
  SELECT rt.id,cAmt, cAmt/(sCurrCostRate + ISNULL(sCurrHoMargin, 0)),tr.firstName,approvedDate,createdDate,tranStatus   
  FROM vwRemitTran rt WITH(NOLOCK)   
  INNER JOIN dbo.vwTranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id   
  WHERE tr.fullName = @receiverName AND tranStatus <> 'CANCEL'  
  AND TR.mobile LIKE @receiverMobile  
  AND approvedDate BETWEEN @YearStart AND CONVERT(VARCHAR,@YearEnd,101)+' 23:59:59'  
    
  
  -- Per Day Txn limit check  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 1 AND condition = 4603)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
   
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))    
  FROM #tempTranR    
  WHERE approvedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()  
  
  IF (ISNULL(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is in <b style=''background-color:red; color:white;''>hold</b> because same reciever  
      <b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.(' + CAST((@sumTxnAmtUSD + @cAmtUSD) AS VARCHAR) + ' USD)'  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per day limit exceeded for same receiver.'  
   RETURN  
  END  
  
  -- per month Txn Limit check    
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 30 AND condition = 4603)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))    
  FROM #tempTranR   
  WHERE approvedDate BETWEEN @MonthStart AND CONVERT(VARCHAR,@MonthEnd,101)+' 23:59:59'  
  
  IF (ISNULL(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is in<b style=''background-color:red; color:white;''>hold</b> because same reciever  
       <b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.(' + CAST((@sumTxnAmtUSD + @cAmtUSD) AS VARCHAR) + ' USD)'  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per month limit exceeded for same receiver.'  
   RETURN  
  END  
  
   --- per year Txn Limit check   
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 365 AND condition = 4603)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))    
  FROM #tempTranR   
  IF (ISNULL(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is in<b style=''background-color:red; color:white;''>hold</b> because same reciever  
      <b>per year transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.(' + CAST((@sumTxnAmtUSD + @cAmtUSD) AS VARCHAR) + ' USD)'  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per year limit exceeded for same receiver.'  
   RETURN  
  END  
  
  --Return success message if there is no complaince matched txn  
  SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
  RETURN  
 END  
 ELSE IF @flag = 'sender-limit'  
 BEGIN  
  --Checking for per txn limit (if country wise rule is defined the pick country wise)  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 0 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 0  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 0  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
   
  IF @cAmtUSD > @limitAmt--@cAmt > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because the transaction   
     amount (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>), is exceeded as <b>per transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>).'  
  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per txn limit exceeded.'  
   RETURN  
  END  
   
  CREATE TABLE #tempTransaction(id BIGINT, cAmt MONEY, cAmtUSD MONEY, sIdType VARCHAR(50),sIdNo VARCHAR(50),approvedDate DATETIME  
   ,createdDate DATETIME,tranStatus VARCHAR(20))  
  
  -- Get the record of 365 days into temp table  
  INSERT INTO #tempTransaction(id,cAmt,cAmtUSD,sIdType,sIdNo,approvedDate,createdDate,tranStatus)  
  SELECT r.id,r.cAmt, r.cAmt/(r.sCurrCostRate + ISNULL(r.sCurrHoMargin, 0)) ,s.idType,s.idNumber,r.approvedDate,r.createdDate,r.tranStatus   
  FROM vwRemitTran R(nolock)  
  INNER JOIN vwtranSenders S(nolock) ON R.ID = S.tranId  
  WHERE r.tranStatus <> 'Cancel'  
  AND S.customerId = @customerId  
  AND r.approvedDate BETWEEN @YearStart AND CONVERT(VARCHAR,@YearEnd,101)+' 23:59:59'  
  --AND S.idNumber=@sIdNo --AND S.idType = @sIdType   
  --and s.country= @country  
    
   
  --##START#####--Check for DAILY txn limit exceeded or not  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 1 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))  
  FROM #tempTransaction   
  WHERE approvedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()  
    
  IF (isnull(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because previous transaction sum is  
     (<b>'+CAST(@sumTxnAmtUSD AS VARCHAR)+' USD</b>) and by doing this transaction (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>)  
     <b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.'  
  
   --SELECT @errCode = 1, @message = 'Daily txn limit exceeded.', @ruleId = @comRuleId  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per day limit exceeded.'  
   RETURN  
  END  
  --##END#####--Check for DAILY txn limit exceeded or not  
  
  --##START#####--Check for MONTHLY txn limit exceeded or not  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 30 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
   
   
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),   
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))  
  FROM #tempTransaction   
  WHERE approvedDate BETWEEN @MonthStart AND CONVERT(VARCHAR,@MonthEnd,101)+' 23:59:59'  
   
  IF (isnull(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because previous transaction sum is  
     (<b>'+CAST(@sumTxnAmtUSD AS VARCHAR)+' USD</b>) and by doing this transaction (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>)  
     <b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.'  
  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Monthly txn limit exceeded.'  
   RETURN  
  END  
  --##END#####--Check for MONTHLY txn limit exceeded or not  
  
  
  --##START#####----Check for YEARLY txn limit exceeded or not  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 365 AND condition = 4600)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4600  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))   
  FROM #tempTransaction    
  --SELECT @sumTxnAmtUSD,@cAmtUSD,@limitAmt  
  IF (isnull(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is   
     <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' ELSE 'hold' END+'</b> because previous transaction sum is  
     (<b>'+CAST(@sumTxnAmtUSD AS VARCHAR)+' USD</b>) and by doing this transaction (<b>'+CAST(@cAmtUSD AS VARCHAR)+' USD</b>)  
     <b>per year transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.'  
  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Yearly txn limit exceeded.'  
   RETURN  
  END  
  --##END#####----Check for YEARLY txn limit exceeded or not  
  
  IF ISNULL(@receiverName, '') = ''  
  BEGIN  
   SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
   RETURN  
  END  
 END  
 ELSE IF @flag = 'receiver-limit'  
 BEGIN  
  CREATE TABLE #tempTransactionR(id BIGINT, cAmt MONEY, cAmtUSD MONEY, approvedDate DATETIME, createdDate DATETIME, tranStatus VARCHAR(20)  
   ,receiverName VARCHAR(50))  
  
  SET @receiverMobile = '%' + @receiverMobile  
  
  -- ## Start of multiple sender same Reciever txn limit  
  INSERT INTO  #tempTransactionR(id,cAmt, cAmtUSD,receiverName,approvedDate,createdDate,tranStatus)  
  SELECT rt.id,cAmt, cAmt/(sCurrCostRate + ISNULL(sCurrHoMargin, 0)),tr.firstName,approvedDate,createdDate,tranStatus   
  FROM vwRemitTran rt WITH(NOLOCK)   
  INNER JOIN dbo.vwTranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id   
  WHERE tr.fullName = @receiverName AND rt.tranStatus <> 'CANCEL'   
  AND tr.mobile LIKE @receiverMobile  
  AND approvedDate BETWEEN @YearStart AND CONVERT(VARCHAR,@YearEnd,101)+' 23:59:59'  
  
  
  -- Per Day Txn limit check  
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 1 AND condition = 4603)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 1  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
   
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))    
  FROM #tempTransactionR    
  WHERE approvedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()  
  
  IF (ISNULL(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is in <b style=''background-color:red; color:white;''>hold</b> because same reciever  
      <b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.(' + CAST((@sumTxnAmtUSD + @cAmtUSD) AS VARCHAR) + ' USD)'  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per day limit exceeded for same receiver.'  
   RETURN  
  END  
  
  -- per month Txn Limit check    
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 30 AND condition = 4603)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 30  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))    
  FROM #tempTransactionR   
  WHERE approvedDate BETWEEN @MonthStart AND CONVERT(VARCHAR,@MonthEnd,101)+' 23:59:59'  
  
  IF (ISNULL(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is in<b style=''background-color:red; color:white;''>hold</b> because same reciever  
       <b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.(' + CAST((@sumTxnAmtUSD + @cAmtUSD) AS VARCHAR) + ' USD)'  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per month limit exceeded for same receiver.'  
   RETURN  
  END  
  
   --- per year Txn Limit check   
  IF EXISTS(SELECT 1   
     FROM csMaster CM(NOLOCK)   
     INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
     WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
     AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = 365 AND condition = 4603)  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
        hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry = @pCountryId  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  ELSE   --if not countrywise then then the rule defined for all countries  
  BEGIN  
   SELECT TOP 1 @comRuleId = comRuleId, @limitAmt = limitAmt, @ruleType = nextAction  
   FROM (  
    SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
       hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
    FROM dbo.csDetail CD(NOLOCK)  
    INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
    WHERE CD.period = 365  
    AND CM.rCountry IS NULL  
    AND CD.condition = 4603  
    AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
    AND ISNULL(CD.isActive, 'Y') = 'Y'   
    AND ISNULL(CD.isDeleted, 'N') = 'N'  
    AND ISNULL(CD.isEnable, 'Y') = 'Y'  
    AND ISNULL(CM.isActive, 'Y') = 'Y'  
    AND ISNULL(CM.isDeleted, 'N') = 'N' )X   
   ORDER BY X.hasDeliveryMethod DESC  
  END  
  
  SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)),  
    @sumTxnAmtUSD = SUM(ISNULL(cAmtUSD, 0))    
  FROM #tempTransactionR   
  IF (ISNULL(@sumTxnAmtUSD,0) + @cAmtUSD) > @limitAmt  
  BEGIN  
   SET @message = 'The transaction is in<b style=''background-color:red; color:white;''>hold</b> because same reciever  
      <b>per year transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' USD</b>) is exceeded.(' + CAST((@sumTxnAmtUSD + @cAmtUSD) AS VARCHAR) + ' USD)'  
   SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 ELSE 2 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per year limit exceeded for same receiver.'  
   RETURN  
  END  
  
  --Return success message if there is no complaince matched txn  
  SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
  RETURN  
 END  
END  
  