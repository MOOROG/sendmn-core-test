USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_rbaReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_rbaReport]
    @user VARCHAR(50) = NULL ,
    @reportFor VARCHAR(50) = NULL ,
    @sCountry VARCHAR(100) = NULL ,
    @sAgent INT = NULL ,
    @sBranch INT = NULL ,
    @sNativeCountry VARCHAR(100) = NULL ,
    @sIDNumber VARCHAR(100) = NULL ,
    @fDate VARCHAR(10) = NULL ,
    @tDate VARCHAR(10) = NULL ,
    @fRBA MONEY = NULL ,
    @tRBA MONEY = NULL ,
    @slabGroup MONEY = NULL ,
    @reportType VARCHAR(50) = NULL ,
    @rCountry VARCHAR(100) = NULL ,
    @nonnativetxn VARCHAR(1) = NULL ,
    @fTXNAmount MONEY = NULL ,
    @tTXNAmount MONEY = NULL ,
    @fTXNCount INT = NULL ,
    @tTXNCount INT = NULL ,
    @fBnfCountryCount INT = NULL ,
    @tBnfCountryCount INT = NULL ,
    @fBnfCount INT = NULL ,
    @tBnfCount INT = NULL ,
    @fOutletCount INT = NULL ,
    @tOutletCount INT = NULL ,
    @pagesize VARCHAR(10) = NULL ,
    @pageNumber VARCHAR(10) = NULL
AS
 DECLARE @nativecountryid INT ,
        @customerid INT ,
        @SQL VARCHAR(MAX)

    DECLARE @LOWrFrom MONEY ,
        @LOWrTo MONEY ,
        @MEDIUMrFrom MONEY ,
        @MEDIUMrTo MONEY ,
        @HIGHrFrom MONEY ,
        @HIGHrTo MONEY
    
    DECLARE @constString VARCHAR(MAX)

    SELECT  @LOWrFrom = rFrom ,
            @LOWrTo = rTo
    FROM    RBAScoreMaster
    WHERE   TYPE = 'LOW'
    SELECT  @MEDIUMrFrom = rFrom ,
            @MEDIUMrTo = rTo
    FROM    RBAScoreMaster
    WHERE   TYPE = 'MEDIUM'
    SELECT  @HIGHrFrom = rFrom ,
            @HIGHrTo = rTo
    FROM    RBAScoreMaster
    WHERE   TYPE = 'HIGH'

    SELECT  @nativecountryid = countryid
    FROM    countrymaster
    WHERE   countryname = @sNativeCountry

    SELECT  @customerid = customerid
    FROM    customeridentity
    WHERE   idnumber = @sIDNumber
 
 SET @reportFor = REPLACE(@reportFor, '_', ' ')
 SET @reportType = REPLACE(@reportType, '_', ' ')
IF @reportFor = 'TXN RBA-V2'
    BEGIN
        IF @reportType = 'Summary Report-Agent'
        BEGIN
        
            IF OBJECT_ID(N'tempdb..##TEMPRBAREPORTA1') IS NOT NULL 
                DROP TABLE ##TEMPRBAREPORTA1

            SET @SQl = '
    SELECT 
     sagentname,
     LOW = SUM(CASE WHEN ts.RBA > 0.00 AND ts.RBA <= 40.00 THEN 1 ELSE 0 END ),
     MEDIUM = SUM(CASE WHEN ts.RBA > 40.00 AND ts.RBA <= 50.00 THEN 1 ELSE 0 END ),
     HIGH = SUM(CASE WHEN ts.RBA > 50.00  AND ts.RBA <= 99.99 THEN 1 ELSE 0 END ),
     VERYHIGH = SUM(CASE WHEN ts.RBA > 99.99 THEN 1 ELSE 0 END ),
     TOTAL = SUM(1)  
    INTO  ##TEMPRBAREPORTA1
    FROM remittran r WITH (NOLOCK)  INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID=ts.TRANID
    INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId=c.CustomerId
    AND sCountry=''' + @sCountry + '''
    AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate+ ' 23:59:59:998'''
                
        END
 IF @reportType = 'Summary Report-Branch'
        BEGIN

            IF OBJECT_ID(N'tempdb..##TEMPRBAREPORTB1') IS NOT NULL
                DROP TABLE ##TEMPRBAREPORTB1

            SET @SQl = '
    SELECT 
      sagentname,
      sbranchname,
      LOW = SUM(CASE WHEN ts.RBA > 0.00 AND ts.RBA <= 40.00 THEN 1 ELSE 0 END ),
      MEDIUM = SUM(CASE WHEN ts.RBA > 40.00 AND ts.RBA <= 50.00 THEN 1 ELSE 0 END ),
      HIGH = SUM(CASE WHEN ts.RBA > 50.00  AND ts.RBA <= 99.99 THEN 1 ELSE 0 END ),
      VERYHIGH = SUM(CASE WHEN ts.RBA > 99.99 THEN 1 ELSE 0 END ),
      TOTAL = SUM(1)
    INTO  ##TEMPRBAREPORTB1
    FROM remittran r WITH (NOLOCK)  INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID=ts.TRANID
    INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId=c.CustomerId
    AND sCountry=''' + @sCountry + ''' 
    AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate+ ' 23:59:59:998'''

        END
IF @reportType = 'Summary Report-Monthly'
        BEGIN

            IF OBJECT_ID(N'tempdb..##TEMPRBAREPORTS1') IS NOT NULL
                DROP TABLE ##TEMPRBAREPORTS1

            SET @SQl = '
    SELECT  
      MONTH = CONVERT(VARCHAR(7),R.approvedDate, 102),
      LOW = SUM(CASE WHEN ts.RBA > 0.00 AND ts.RBA <= 40.00 THEN 1 ELSE 0 END ),
      MEDIUM = SUM(CASE WHEN ts.RBA > 40.00 AND ts.RBA <= 50.00 THEN 1 ELSE 0 END ),
      HIGH = SUM(CASE WHEN ts.RBA > 50.00  AND ts.RBA <= 99.99 THEN 1 ELSE 0 END ),
      VERYHIGH = SUM(CASE WHEN ts.RBA > 99.99 THEN 1 ELSE 0 END ),
      TOTAL = SUM(1) 
    INTO  ##TEMPRBAREPORTS1
    FROM remittran r WITH (NOLOCK)  INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID=ts.TRANID
    INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId=c.CustomerId
    AND sCountry=''' + @sCountry + ''' 
    AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate+ ' 23:59:59:998'''

        END
IF @sAgent IS NOT NULL
            SET @SQl = @SQl + ' AND sagent= ' + CAST(@sAgent AS VARCHAR)  

        IF @sbranch IS NOT NULL
            SET @SQl = @SQl + ' AND sbranch= ' + CAST(@sbranch AS VARCHAR)
 
        IF @sNativeCountry IS NOT NULL
            SET @SQl = @SQl + ' AND ts.NativeCountry= '''
                + CAST(@sNativeCountry AS VARCHAR) + '''' 

        IF @sIDNumber IS NOT NULL
            SET @SQl = @SQl + ' AND ts.idnumber= '''
                + CAST(@sIDNumber AS VARCHAR) + ''''  

        IF @fRBA IS NOT NULL AND @tRBA IS NOT NULL
            SET @SQl = @SQl + ' AND ts.RBA BETWEEN '
                + CAST(@fRBA AS VARCHAR) + ' AND '
                + CAST(@tRBA AS VARCHAR) + ''

        IF @rCountry IS NOT NULL
            SET @SQl = @SQl + ' AND pcountry= '''
                + CAST(@rCountry AS VARCHAR) + '''' 
 
        IF @fTXNAmount IS NOT NULL
            AND @TTXNAmount IS NOT NULL
            SET @SQl = @SQl + ' AND camt BETWEEN '
                + CAST(@fTXNAmount AS VARCHAR) + ' AND '
                + CAST(@TTXNAmount AS VARCHAR) + ''

        IF @nonnativetxn IS NOT NULL
        BEGIN 
            IF @nonnativetxn = 'Y'
            BEGIN 
                SET @SQl = @SQl
                    + ' AND R.PCOUNTRY=ISNULL(TS.NATIVECOUNTRY,R.PCOUNTRY) '
            END

            IF @nonnativetxn = 'N'
            BEGIN 
                SET @SQl = @SQl
                    + ' AND R.PCOUNTRY<>ISNULL(TS.NATIVECOUNTRY,R.PCOUNTRY) '
            END
        END
 IF @reportType = 'Summary Report-Agent'
        BEGIN

            SET @SQl = @SQl
                + 'GROUP BY  sagentname  ORDER BY  sagentname '
        END

        IF @reportType = 'Summary Report-Branch'
        BEGIN

            SET @SQl = @SQl
                + 'GROUP BY  sagentname,sbranchname  ORDER BY  sagentname,sbranchname'
        END

        IF @reportType = 'Summary Report-Monthly'
        BEGIN

            SET @SQl = @SQl
                + 'GROUP BY  CONVERT(VARCHAR(7),R.approvedDate, 102)   ORDER BY  CONVERT(VARCHAR(7),R.approvedDate, 102) '
        END
 
  PRINT ( @SQL )
  EXEC (@SQL)
  

        IF @reportType = 'Summary Report-Agent'
        BEGIN
            SELECT [SN] = ROW_NUMBER()OVER(order BY sAgentName),
    [Sending Agent] = sagentname ,
                [LOW_TXN] = LOW,
                [LOW_%] = CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 ,
                [MEDIUM_TXN] = MEDIUM,
                [MEDIUM_%] = CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100,
                [HIGH_TXN] = HIGH,
                [HIGH_%] = CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100,
    [VERY HIGH_TXN] = VERYHIGH ,
    [VERY HIGH_%] = CAST(VERYHIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100,
                [TOTAL TXN] = TOTAL
        FROM    ##TEMPRBAREPORTA1
        END
  IF @reportType = 'Summary Report-Branch'
        BEGIN
            SELECT  
    [SN] = ROW_NUMBER()OVER(order BY sAgentName, sbranchname),
    [Sending Agent] = sagentname ,
                [Sending Branch] = sbranchname ,
                [LOW_TXN] = LOW,
                [LOW_%] = CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 ,
                [MEDIUM_TXN] = MEDIUM,
                [MEDIUM_%] = CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100,
                [HIGH_TXN] = HIGH,
                [HIGH_%] = CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100,
    [VERY HIGH_TXN] = VERYHIGH ,
    [VERY HIGH_%] = CAST(VERYHIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100,
                [TOTAL TXN] = TOTAL
        FROM    ##TEMPRBAREPORTB1
        END
IF @reportType = 'Summary Report-Monthly'
        BEGIN
       SELECT  
    [SN] = ROW_NUMBER()OVER(order BY [MONTH]),
    [MONTH],
                [LOW_TXN] = LOW,
                [LOW_%] = CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 ,
                [MEDIUM_TXN] = MEDIUM,
                [MEDIUM_%] = CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100,
                [HIGH_TXN] = HIGH,
                [HIGH_%] = CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100,
    [VERY HIGH_TXN] = VERYHIGH ,
    [VERY HIGH_%] = CAST(VERYHIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100,
                [TOTAL TXN] = TOTAL
        FROM    ##TEMPRBAREPORTS1

        END
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
  SELECT  'From Date ' head ,
    CONVERT(VARCHAR(10), @fDate, 101) VALUE
  UNION ALL
  SELECT  'To Date ' head ,
    CONVERT(VARCHAR(10), @tDate, 101) value
  UNION ALL
  SELECT  'Sending Country ' head ,
    @sCountry value
  UNION ALL
  SELECT  'Sending Agent ' head ,
    ( SELECT    agentName
      FROM      agentmaster WITH ( NOLOCK )
      WHERE     agentId = @sAgent
    ) VALUE
  UNION ALL
  SELECT  'Sending Branch ' head ,
    ( SELECT    agentName
      FROM      agentmaster WITH ( NOLOCK )
      WHERE     agentId = @sBranch
    ) VALUE
  UNION ALL
  SELECT  'Report Type ' head ,
    value = @reportType
 
  SELECT  'RBA TXN Report' title

  RETURN;
    END
 IF @reportFor = 'TXN RBA'
    BEGIN
        IF @reportType = 'Detail Report'
        BEGIN
   DECLARE @txnRBALink VARCHAR(5000),@cusRBALink VARCHAR(5000)
   SET @constString = '<a href="#" onclick="OpenInNewWindow(''''/SwiftSystem/Reports/Reports.aspx?reportName=rbareport&reportFor=TXN RBA&rptType=Detail Report&fromDate=' + @fDate + '&toDate=' + @tDate  + '&sCountry=' + @sCountry
         SET @txnRBALink = '<a href="#" onclick="OpenInNewWindow(''''/Remit/RiskBaseAnalysis/txnRBACalcDetails.aspx?'
   SET @cusRBALink='<a href="#" onclick="OpenInNewWindow(''''/Remit/RiskBaseAnalysis/cusRBACalcDetails.aspx?'            
   
   SET @SQl = '
    SELECT 
      [Sending Agent]   = sagentname
     ,[Sending Branch]   = sbranchname
     ,[Confirmed Date]   = r.approveddate
     ,ICN      = dbo.decryptdb(CONTROLNO) 
     ,[Sender Name]    = SenderName
     ,[Id Number]    = ts.IDNumber
     ,[Date Of Birth]   = ts.DOB
     ,[Occupation]    = ts.Occupation
     ,[Native Country]   = ts.NativeCountry
     ,[Receiver Name]   = ReceiverName
     ,[Receiver Country]   = pCountry
     ,[Payment Type]    = paymentMethod
     ,[TXN Amount]    = cAmt
     ,[TXN RBA]     = ''' + @txnRBALink + 'tranId='' + CAST(r.id AS VARCHAR) + ''&customerId=''+ CAST(ts.customerId AS VARCHAR)+''&dt=''+ LEFT(CONVERT(VARCHAR,r.createdDate,102), 7) +'''''')">'' + CONVERT(VARCHAR, ts.RBA, 2) + ''</a>'' 
     ,[Customer RBA]    = ''' + @cusRBALink + 'tranId='' + CAST(r.id AS VARCHAR) + ''&customerId=''+ CAST(ts.customerId AS VARCHAR)+''&dt=''+ LEFT(CONVERT(VARCHAR,r.createdDate,102), 7) +'''''')">'' + CONVERT(VARCHAR, c.RBA, 2) + ''</a>''
     ,txnRBA      = ts.RBA
     ,customerRBA    = c.RBA
    FROM remittran r WITH (NOLOCK)  
    INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID = ts.TRANID
    INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId = c.CustomerId
    AND sCountry = ''' + @sCountry + ''' 
    AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate
                + ' 23:59:59:998'''
        END
 IF @reportType = 'Summary Report-Agent'
        BEGIN
        
            IF OBJECT_ID(N'tempdb..##TEMPRBAREPORTA') IS NOT NULL 
                DROP TABLE ##TEMPRBAREPORTA

            SET @SQl = '
    SELECT 
      sagentname
     ,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@LOWrFrom AS VARCHAR)
      + ' AND ' + CAST(@LOWrTo AS VARCHAR)
      + ' THEN 1 ELSE 0 END ) AS LOW
     ,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@MEDIUMrFrom AS VARCHAR)
      + ' AND  ' + CAST(@MEDIUMrTo AS VARCHAR)
      + ' THEN 1 ELSE 0 END ) AS MEDIUM
     ,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@HIGHrFrom AS VARCHAR)
      + ' AND  ' + CAST(@HIGHrTo AS VARCHAR)
      + ' THEN 1 ELSE 0 END ) AS HIGH
     ,SUM(1) TOTAL INTO  ##TEMPRBAREPORTA
    FROM remittran r WITH (NOLOCK)  INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID=ts.TRANID
    INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId=c.CustomerId
    AND sCountry=''' + @sCountry + '''
    AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate
        + ' 23:59:59:998'''
                
        END
 IF @reportType = 'Summary Report-Branch'
        BEGIN

            IF OBJECT_ID(N'tempdb..##TEMPRBAREPORTB') IS NOT NULL
                DROP TABLE ##TEMPRBAREPORTB

            SET @SQl = 'SELECT sagentname,sbranchname
,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@LOWrFrom AS VARCHAR)
                + ' AND  ' + CAST(@LOWrTo AS VARCHAR)
                + ' THEN 1 ELSE 0 END ) AS LOW
,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@MEDIUMrFrom AS VARCHAR)
                + ' AND  ' + CAST(@MEDIUMrTo AS VARCHAR)
                + ' THEN 1 ELSE 0 END ) AS MEDIUM
,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@HIGHrFrom AS VARCHAR)
                + ' AND  ' + CAST(@HIGHrTo AS VARCHAR)
                + ' THEN 1 ELSE 0 END ) AS HIGH
,SUM(1) TOTAL INTO  ##TEMPRBAREPORTB
FROM remittran r WITH (NOLOCK)  INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID=ts.TRANID
INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId=c.CustomerId
AND sCountry=''' + @sCountry + ''' 
AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate
                + ' 23:59:59:998'''

        END
  IF @reportType = 'Summary Report-Monthly'
        BEGIN

            IF OBJECT_ID(N'tempdb..##TEMPRBAREPORTS') IS NOT NULL
                DROP TABLE ##TEMPRBAREPORTS

            SET @SQl = 'SELECT  CONVERT(VARCHAR(7),R.approvedDate, 102) MONTH
,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@LOWrFrom AS VARCHAR)
                + ' AND  ' + CAST(@LOWrTo AS VARCHAR)
                + ' THEN 1 ELSE 0 END ) AS LOW
,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@MEDIUMrFrom AS VARCHAR)
                + ' AND  ' + CAST(@MEDIUMrTo AS VARCHAR)
                + ' THEN 1 ELSE 0 END ) AS MEDIUM
,SUM(CASE WHEN ts.RBA BETWEEN ' + CAST(@HIGHrFrom AS VARCHAR)
                + ' AND  ' + CAST(@HIGHrTo AS VARCHAR)
                + ' THEN 1 ELSE 0 END ) AS HIGH
,SUM(1) TOTAL INTO  ##TEMPRBAREPORTS
FROM remittran r WITH (NOLOCK)  INNER JOIN transenders ts WITH (NOLOCK) ON  r.ID=ts.TRANID
INNER JOIN customers c WITH (NOLOCK) ON ts.CustomerId=c.CustomerId
AND sCountry=''' + @sCountry + ''' 
AND r.approvedDate BETWEEN  ''' + @fDate + ''' AND ''' + @tDate
                + ' 23:59:59:998'''

        END
IF @sAgent IS NOT NULL
            SET @SQl = @SQl + ' AND sagent= ' + CAST(@sAgent AS VARCHAR)  

        IF @sbranch IS NOT NULL
            SET @SQl = @SQl + ' AND sbranch= ' + CAST(@sbranch AS VARCHAR)
 
        IF @sNativeCountry IS NOT NULL
            SET @SQl = @SQl + ' AND ts.NativeCountry= '''
                + CAST(@sNativeCountry AS VARCHAR) + '''' 

        IF @sIDNumber IS NOT NULL
            SET @SQl = @SQl + ' AND ts.idnumber= '''
                + CAST(@sIDNumber AS VARCHAR) + ''''  

        IF @fRBA IS NOT NULL
            AND @tRBA IS NOT NULL
            SET @SQl = @SQl + ' AND ts.RBA BETWEEN '
                + CAST(@fRBA AS VARCHAR) + ' AND '
                + CAST(@tRBA AS VARCHAR) + ''

        IF @rCountry IS NOT NULL
            SET @SQl = @SQl + ' AND pcountry= '''
                + CAST(@rCountry AS VARCHAR) + '''' 
 
        IF @fTXNAmount IS NOT NULL
            AND @TTXNAmount IS NOT NULL
            SET @SQl = @SQl + ' AND camt BETWEEN '
                + CAST(@fTXNAmount AS VARCHAR) + ' AND '
                + CAST(@TTXNAmount AS VARCHAR) + ''

        IF @nonnativetxn IS NOT NULL
        BEGIN 
            IF @nonnativetxn = 'Y'
            BEGIN 
                SET @SQl = @SQl
                    + ' AND R.PCOUNTRY=ISNULL(TS.NATIVECOUNTRY,R.PCOUNTRY) '
            END

            IF @nonnativetxn = 'N'
            BEGIN 
                SET @SQl = @SQl
                    + ' AND R.PCOUNTRY<>ISNULL(TS.NATIVECOUNTRY,R.PCOUNTRY) '
            END
        END

        IF @reportType = 'Summary Report-Agent'
        BEGIN

            SET @SQl = @SQl
                + 'GROUP BY  sagentname  ORDER BY  sagentname '
        END

        IF @reportType = 'Summary Report-Branch'
        BEGIN

            SET @SQl = @SQl
                + 'GROUP BY  sagentname,sbranchname  ORDER BY  sagentname,sbranchname'
        END

        IF @reportType = 'Summary Report-Monthly'
        BEGIN

            SET @SQl = @SQl
                + 'GROUP BY  CONVERT(VARCHAR(7),R.approvedDate, 102)   ORDER BY  CONVERT(VARCHAR(7),R.approvedDate, 102) '
        END
IF @reportType = 'Detail Report'
  BEGIN
   DECLARE @SQL1 VARCHAR(MAX)
   SET @SQL1='
    SELECT COUNT(''X'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @SQL +') AS tmp;

    SELECT * FROM 
    (
    SELECT ROW_NUMBER() OVER (ORDER BY txnRBA DESC) AS [S.N.],
      [Sending Agent] 
     ,[Sending Branch] 
     ,[Confirmed Date] 
     ,ICN    
     ,[Sender Name]  
     ,[Id Number]  
     ,[Date Of Birth] 
     ,[Occupation]  
     ,[Native Country] 
     ,[Receiver Name] 
     ,[Receiver Country] 
     ,[Payment Type]  
     ,[TXN Amount]  
     ,[TXN RBA]   
     ,[Customer RBA]
    FROM 
    (
     '+ @SQL +'
    ) AS aa
    ) AS tmp WHERE 1 = 1 AND  tmp.[S.N.] BETWEEN (('+@pageNumber+' - 1)  '+@pageSize+' + 1) AND '+@pageNumber+'  '+@pageSize+''
   
   PRINT (@SQL1)
   EXEC (@SQL1)
  END
  ELSE
  BEGIN
   PRINT ( @SQL )
   EXEC (@SQL)
  END

        IF @reportType = 'Summary Report-Agent'
        BEGIN
            SELECT  [Sending Agent] = sagentname ,
                    LOW ,
                    CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 [LOW %] ,
                    MEDIUM ,
                    CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100 [MEDIUM %] ,
                    HIGH ,
                    CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100 [HIGH %] ,
                    TOTAL
            FROM    ##TEMPRBAREPORTA
        END
 IF @reportType = 'Summary Report-Branch'
        BEGIN
            SELECT  [Sending Agent] = sagentname ,
                    [Sending Branch] = sbranchname ,
                    LOW ,
                    CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 [LOW %] ,
                    MEDIUM ,
                    CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100 [MEDIUM %] ,
                    HIGH ,
                    CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100 [HIGH %] ,
                    TOTAL
            FROM    ##TEMPRBAREPORTB
        END

        IF @reportType = 'Summary Report-Monthly'
        BEGIN
      SELECT  MONTH ,
                    LOW ,
                    CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 [LOW %] ,
                    MEDIUM ,
                    CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100 [MEDIUM %] ,
                    HIGH ,
                    CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100 [HIGH %] ,
                    TOTAL
            FROM    ##TEMPRBAREPORTS

        END
    END
 IF @reportFor NOT IN ('TXN RBA','TXN RBA-V2')
    BEGIN
        DECLARE @PERIODICRBA VARCHAR(20)

        IF @reportfor = 'TXN Average RBA'
            SET @PERIODICRBA = 'TXNRBA'
        IF @reportfor = 'TXN Periodic RBA'
            SET @PERIODICRBA = 'TXNRBA'
        IF @reportfor = 'Final RBA'
            SET @PERIODICRBA = 'FINALRBA'

        IF @reportType = 'Detail Report'
        BEGIN
   SET @constString = '<a href="#" onclick="OpenInNewWindow(''''/SwiftSystem/Reports/Reports.aspx?reportName=rbareport&reportFor=TXN RBA&rptType=Detail Report&fromDate=' + @fDate + '&toDate=' + @tDate  + '&sCountry=' + @sCountry
            SET @txnRBALink = '<a href="#" onclick="OpenInNewWindow(''''/Remit/RiskBaseAnalysis/txnRBACalcDetails.aspx?'
   SET @cusRBALink='<a href="#" onclick="OpenInNewWindow(''''/Remit/RiskBaseAnalysis/cusRBACalcDetails.aspx?'
            SET @SQl = '  
    SELECT  
      [Date]       = DT
     ,[Customer Name]    = fullName
     ,[Native Country]    = countryName 
     ,[Id Type]      = X.detailtitle
     ,[Id Number]     = idNumber
     ,[Date of Birth]    = CONVERT(DATE,DOB ,101)
     ,[Occupation]     = O.DETAILTITLE 
     ,[Txn Amount]     = txnamount
     ,[Txn Count]     = ''' + @constString + '&sIdNumber='' + c.idNumber + '''''')">'' + CAST(txncount AS VARCHAR) + ''</a>''
     ,[Outlets used]     = outletsused
     ,[Beneficiary Country Count] = bnfcountrycount
     ,[Beneficiary Count]   = bnfcount
     ,[Txn RBA]      = txnrba
     ,[Customer RBA]     = p.rba
     ,[Final RBA]     = ''' + @cusRBALink + 'customerId=''+ CAST(C.customerId AS VARCHAR)+''&dt=''+ P.dt +'''''')">'' + CONVERT(VARCHAR, finalrba, 2) + ''</a>''
     ,finalRBA      = finalrba
    FROM PERIODICRBA P WITH (NOLOCK) 
    INNER JOIN CUSTOMERS C WITH (NOLOCK) ON C.CUSTOMERID = P.CUSTOMERID
    INNER JOIN (
      SELECT valueid,detailtitle 
      FROM STATICDATAvalue WITH(NOLOCK) 
      WHERE typeid = 1300 and isactive = ''Y''
      ) X ON C.IDTYPE = X.VALUEID
    INNER JOIN OCCUPATIONMASTER  O WITH (NOLOCK) ON ISNULL(C.OCCUPATION,1) = O.OCCUPATIONID
    LEFT JOIN COUNTRYMASTER CM WITH (NOLOCK) ON C.NATIVECOUNTRY=CM.COUNTRYID
    WHERE REPLACE(DT,''.'',''-'') + ''-01'' BETWEEN ''' + @fDate
      + ''' AND ''' + @tDate + ' 23:59:59:998'''
 
        END
 IF @reportType = 'Summary Report-Monthly'
        BEGIN
            IF OBJECT_ID(N'tempdb..##TEMPRBAFINAL') IS NOT NULL
                DROP TABLE ##TEMPRBAFINAL

            SET @SQl = '  
    SELECT DT  
    ,SUM(CASE WHEN ' + @PERIODICRBA + ' BETWEEN '
      + CAST(@LOWrFrom AS VARCHAR) + ' AND  '
      + CAST(@LOWrTo AS VARCHAR)
      + ' THEN 1 ELSE 0 END ) AS LOW
    ,SUM(CASE WHEN ' + @PERIODICRBA + ' BETWEEN '
      + CAST(@MEDIUMrFrom AS VARCHAR) + ' AND  '
      + CAST(@MEDIUMrTo AS VARCHAR)
      + ' THEN 1 ELSE 0 END ) AS MEDIUM
    ,SUM(CASE WHEN ' + @PERIODICRBA + ' BETWEEN '
      + CAST(@HIGHrFrom AS VARCHAR) + ' AND  '
      + CAST(@HIGHrTo AS VARCHAR)
      + ' THEN 1 ELSE 0 END ) AS HIGH
    ,SUM(1) TOTAL INTO  ##TEMPRBAFINAL
    FROM PERIODICRBA P WITH (NOLOCK) INNER JOIN CUSTOMERS C WITH (NOLOCK) ON C.CUSTOMERID=P.CUSTOMERID
    WHERE REPLACE(DT,''.'',''-'')+''-01'' BETWEEN  ''' + @fDate
      + ''' AND ''' + @tDate + ' 23:59:59:998'''
        END
   
        IF @sNativeCountry IS NOT NULL
            SET @SQl = @SQl + ' AND c.NativeCountry= '''
                + CAST(@nativecountryid AS VARCHAR) + '''' 

        IF @sIDNumber IS NOT NULL
            SET @SQl = @SQl + ' AND p.customerid= '''
                + CAST(@customerid AS VARCHAR) + ''''  

        IF @fRBA IS NOT NULL
            AND @tRBA IS NOT NULL
            SET @SQl = @SQl + ' AND ' + @PERIODICRBA + ' BETWEEN '
                + CAST(@fRBA AS VARCHAR) + ' AND '
                + CAST(@tRBA AS VARCHAR) + ''
     
        IF @fTXNAmount IS NOT NULL
            AND @TTXNAmount IS NOT NULL
            SET @SQl = @SQl + ' AND TXNAMOUNT BETWEEN '
                + CAST(@fTXNAmount AS VARCHAR) + ' AND '
                + CAST(@TTXNAmount AS VARCHAR) + ''

        IF @fTXNCount IS NOT NULL
            AND @TTXNCount IS NOT NULL
            SET @SQl = @SQl + ' AND TXNCOUNT BETWEEN '
                + CAST(@fTXNCount AS VARCHAR) + ' AND '
                + CAST(@TTXNCount AS VARCHAR) + ''

 
        IF @fBnfCountryCount IS NOT NULL
            AND @TBnfCountryCount IS NOT NULL
            SET @SQl = @SQl + ' AND BNFCOUNTRYCOUNT BETWEEN '
                + CAST(@fBnfCountryCount AS VARCHAR) + ' AND '
                + CAST(@TBnfCountryCount AS VARCHAR) + ''
 
        IF @fBnfCount IS NOT NULL
            AND @tBnfCount IS NOT NULL
            SET @SQl = @SQl + ' AND BNFCOUNT BETWEEN '
                + CAST(@fBnfCount AS VARCHAR) + ' AND '
                + CAST(@tBnfCount AS VARCHAR) + ''
 
        IF @fOutletCount IS NOT NULL
            AND @tOutletCount IS NOT NULL
            SET @SQl = @SQl + ' AND OUTLETSUSED BETWEEN '
                + CAST(@fOutletCount AS VARCHAR) + ' AND '
                + CAST(@tOutletCount AS VARCHAR) + ''

        IF @nonnativetxn IS NOT NULL
        BEGIN 
            IF @nonnativetxn = 'Y'
                BEGIN 
                    SET @SQl = @SQl
                        + ' AND ISNULL(nonnativetxn,''N'')=''Y'' '
                END

            IF @nonnativetxn = 'N'
                BEGIN 
                    SET @SQl = @SQl
                        + ' AND ISNULL(nonnativetxn,''N'')=''N'' '
                END

        END


        IF @reportType = 'Summary Report-Monthly'
        BEGIN
            SET @SQL = @SQL + ' GROUP BY DT ORDER BY DT'
        END
IF @reportType = 'Detail Report'
  BEGIN
   SET @SQL1='
    SELECT COUNT(''X'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @SQL +') AS tmp;

    SELECT * FROM 
    (
    SELECT ROW_NUMBER() OVER (ORDER BY [finalRBA] DESC) AS [S.N.],
      [Date]      
     ,[Customer Name]   
     ,[Native Country]   
     ,[Id Type]     
     ,[Id Number]    
     ,[Date of Birth]   
     ,[Occupation]    
     ,[Txn Amount]    
     ,[Txn Count]    
     ,[Outlets used]    
     ,[Beneficiary Country Count]
     ,[Beneficiary Count]  
     ,[Txn RBA]     
     ,[Customer RBA]    
     ,[Final RBA]
    FROM 
    (
     '+ @SQL +'
    ) AS aa
    ) AS tmp WHERE 1 = 1 AND  tmp.[S.N.] BETWEEN (('+@pageNumber+' - 1)  '+@pageSize+' + 1) AND '+@pageNumber+'  '+@pageSize+''
   
   PRINT (@SQL1)
   EXEC (@SQL1)
  END
  ELSE
  BEGIN
   PRINT ( @SQL )
   EXEC (@SQL)
        END

        IF @reportType = 'Summary Report-Monthly'
        BEGIN
   SET @constString = '<a href="#" onclick="OpenInNewWindow(''/SwiftSystem/Reports/Reports.aspx?reportName=rbaReport&rptType=Detail Report&reportFor=' + @reportFor + '&sCountry=' + @sCountry
            SELECT  
     [Date]   = DT
                ,LOW   = @constString + '&fromDate=' + REPLACE(DT, '.', '-') + '-01' + '&toDate=' + CONVERT(VARCHAR,DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST(REPLACE(DT, '.', '-') + '-01' AS DATETIME)) + 1, 0)),120) + '&rbaRangeFrom=0&rbaRangeTo=40'')">' + CAST(LOW AS VARCHAR) + '</a>'
                ,[LOW %]  = CAST(LOW AS MONEY) / CAST(TOTAL AS MONEY) * 100 
                ,MEDIUM   = @constString + '&fromDate=' + REPLACE(DT, '.', '-') + '-01' + '&toDate=' + CONVERT(VARCHAR,DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST(REPLACE(DT, '.', '-') + '-01' AS DATETIME)) + 1, 0)),120) + '&rbaRangeFrom=40&rbaRangeTo=50'')">' + CAST(MEDIUM AS VARCHAR) + '</a>'
                ,[MEDIUM %]  = CAST(MEDIUM AS MONEY) / CAST(TOTAL AS MONEY) * 100  
                ,HIGH   = @constString + '&fromDate=' + REPLACE(DT, '.', '-') + '-01' + '&toDate=' + CONVERT(VARCHAR,DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST(REPLACE(DT, '.', '-') + '-01' AS DATETIME)) + 1, 0)),120) + '&rbaRangeFrom=50&rbaRangeTo=100'')">' + CAST(HIGH AS VARCHAR) + '</a>'
                ,[HIGH %]  = CAST(HIGH AS MONEY) / CAST(TOTAL AS MONEY) * 100 
                ,TOTAL
            FROM ##TEMPRBAFINAL
        END
    END
 EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
    SELECT  'From Date ' head ,
            CONVERT(VARCHAR(10), @fDate, 101) VALUE
    UNION ALL
    SELECT  'To Date ' head ,
            CONVERT(VARCHAR(10), @tDate, 101) value
    UNION ALL
    SELECT 'Report For ' head,
   @reportFor value
    UNION ALL
    SELECT  'Sending Country ' head ,
            @sCountry value
    UNION ALL
    SELECT  'Sending Agent ' head ,
            ( SELECT    agentName
              FROM      agentmaster WITH ( NOLOCK )
              WHERE     agentId = @sAgent
            ) VALUE
    UNION ALL
    SELECT  'Sending Branch ' head ,
            ( SELECT    agentName
              FROM      agentmaster WITH ( NOLOCK )
              WHERE     agentId = @sBranch
            ) VALUE
    UNION ALL
    SELECT  'Report Type ' head ,
            value = @reportType
 
    SELECT  'Risk Based Assessment Report' title
GO
