SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
  
ALTER PROCEDURE [dbo].[proc_sendPageLoadData]  
  @flag   VARCHAR(50)  
    ,@param   VARCHAR(200)  = NULL  
    ,@param1  VARCHAR(200)  = NULL  
    ,@user   VARCHAR(30)   = NULL  
    ,@country  VARCHAR(50)   = NULL  
    ,@countryId  VARCHAR(10)   = NULL  
    ,@countryName   VARCHAR(100)  = NULL  
    ,@agentId  VARCHAR(50)   = NULL  
    ,@pCountryId VARCHAR(10)   = NULL  
    ,@pCountryName  VARCHAR(100)  = NULL  
    ,@sAgent  VARCHAR(100)  = NULL  
    ,@sBranch  VARCHAR(100)  = NULL  
    ,@rAgent  VARCHAR(100)  = NULL  
    ,@sCustomerId VARCHAR(10)   = NULL  
    ,@blackListIds VARCHAR(MAX)  = NULL  
    ,@agentRefId VARCHAR(20)   = NULL  
    ,@deliveryMethodId INT    = NULL  
    ,@pBankType   CHAR(1)   = NULL  
 ,@complianceTempId INT    = NULL  
 ,@csDetailRecId  INT    = NULL  
 ,@pMode   VARCHAR(5)   = NULL  
 ,@pLocation  BIGINT    = NULL  
 ,@subLocation BIGINT    = NULL  
 ,@partnerId  BIGINT    = NULL  
 ,@pAgent  INT     = NULL  
 ,@RECEIVERID INT     = NULL  
AS  
  
 SET NOCOUNT ON;  
 IF @flag = 'additional-cddi'  
 BEGIN  
	DECLARE @HOLDTRANID BIGINT = NULL

	SELECT R.HOLDTRANID
	INTO #HOLDTRANID
	FROM VWREMITTRAN R(NOLOCK)
	INNER JOIN VWTRANSENDERS S(NOLOCK) ON S.TRANID = R.ID
	WHERE S.CUSTOMERID = @sCustomerId

	SELECT @HOLDTRANID = C.TRAN_ID
	FROM #HOLDTRANID H
	INNER JOIN TBL_TXN_COMPLIANCE_CDDI C(NOLOCK) ON C.TRAN_ID = H.holdTranId
	ORDER BY C.TRAN_ID ASC
	
	IF @HOLDTRANID IS NOT NULL
	BEGIN
		SELECT Q.*, C.ANSWER_TEXT 
		FROM VIEW_COMPLIANCE_QUESTION_SET Q (NOLOCK)
		INNER JOIN TBL_TXN_COMPLIANCE_CDDI C (NOLOCK) ON C.QUES_ID = Q.ID
		WHERE C.TRAN_ID = @HOLDTRANID
		AND Q.IS_ACTIVE = 1 
	END
	ELSE
	BEGIN
		SELECT *, ANSWER_TEXT = ''  
		FROM VIEW_COMPLIANCE_QUESTION_SET (NOLOCK)  
		WHERE IS_ACTIVE = 1
	END
 END  
 ELSE IF @flag = 'S-AGENT-BEHALF'  
 BEGIN  
  --SELECT * FROM   
  --(  
  -- SELECT CONVERT(VARCHAR,AM.AGENTID) + '|' + am.actasbranch AGENTID, AM.AGENTNAME, [ORDER] = CASE WHEN AM.AGENTID = @sAgent THEN 0 ELSE 1 END  
  -- FROM AGENTMASTER AM(NOLOCK)   
  -- WHERE ISNULL(am.isActive, 'Y') = 'Y'  
  -- AND ISNULL(am.isDeleted, 'N') = 'N'  
  -- AND am.parentId = 393877  
  --)X ORDER BY [ORDER], AGENTNAME  
 SELECT agentId, agentName FROM agentMaster (NOLOCK) WHERE parentId = 0 AND agentId NOT IN (1001, 393877)   
 END  
 ELSE IF @flag = 'S-AGENT'  
 BEGIN  
  SELECT * FROM   
  (  
   SELECT CONVERT(VARCHAR,AM.AGENTID) + '|' + am.actasbranch AGENTID, AM.AGENTNAME, [ORDER] = CASE WHEN AU.AGENTID IS NOT NULL THEN 0 ELSE 1 END  
   FROM AGENTMASTER AM(NOLOCK)  
   LEFT JOIN (SELECT AGENTID FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @user) AU ON AU.AGENTID = AM.AGENTID  
   WHERE ISNULL(am.isActive, 'Y') = 'Y'  
   AND ISNULL(am.isDeleted, 'N') = 'N'  
   AND am.parentId = 393877  
   AND am.actAsBranch = 'Y'  
  )X ORDER BY [ORDER], AGENTNAME  
          
 END  
 ELSE IF @flag = 'recModeByCountry'--@author:bijay; Receiving Mode By CountryId  
 BEGIN      
  SELECT   
     serviceTypeId  
    ,UPPER(typetitle) typeTitle  
    ,MIN(maxLimitAmt) maxLimitAmt  
     FROM serviceTypeMaster stm WITH (NOLOCK)  
     INNER JOIN (  
      SELECT   
       receivingMode, maxLimitAmt   
      FROM countryReceivingMode crm WITH(NOLOCK)   
      INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry   
      WHERE SL.countryId = @countryId AND SL.receivingCountry = @pcountryId  
      AND SL.agentId IS NULL AND SL.tranType IS NULL AND receivingAgent IS NULL  
  
      UNION ALL  
          
      SELECT   
       receivingMode, maxLimitAmt   
      FROM countryReceivingMode crm WITH(NOLOCK)   
      INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry   
      AND SL.receivingCountry = @pcountryId AND SL.countryId = @countryId   
      WHERE agentId = @agentId  
      AND SL.tranType IS  NULL  
      AND receivingAgent IS NULL  
      AND ISNULL(isActive,'N')='Y'  
      AND ISNULL(isDeleted,'N')='N'  
         
      UNION ALL  
         
      SELECT tranType, MAX(maxLimitAmt) maxLimitAmt  
      FROM sendTranLimit SL WITH (NOLOCK)   
      WHERE countryId = @countryId   
      AND SL.receivingCountry=@pcountryId  
      AND ISNULL(isActive,'N')='Y'  
      AND ISNULL(isDeleted,'N')='N'  
      AND SL.agentId IS NULL  
      AND SL.tranType IS NOT NULL  
      AND SL.receivingAgent IS NULL  
      GROUP BY tranType  
         
      UNION ALL  
         
      SELECT tranType, MAX(maxLimitAmt) maxLimitAmt  
      FROM sendTranLimit SL WITH (NOLOCK)  
      WHERE countryId = @countryId   
      AND SL.receivingCountry=@pcountryId  
      AND SL.agentId=@agentid  
      AND ISNULL(isActive,'N')='Y'  
      AND ISNULL(isDeleted,'N')='N'  
      AND receivingAgent IS NULL  
      AND SL.tranType IS NOT NULL  
      AND SL.receivingAgent IS NULL  
      GROUP BY tranType   
       ) X ON  X.receivingMode = stm.serviceTypeId  
     WHERE ISNULL(STM.isActive,'N') = 'Y' AND ISNULL(STM.isDeleted,'N') = 'N'  
     AND (STM.serviceTypeId NOT IN (5))  
     --AND (STM.serviceTypeId NOT IN (3,5))  
     GROUP BY serviceTypeId,typetitle  
     HAVING MIN(X.maxLimitAmt)>0  
     ORDER BY serviceTypeId ASC  
 END  
  
 ELSE IF @flag = 'recModeByCountry-txnReport'  
 BEGIN  
  SELECT   
    serviceTypeId  
   ,UPPER(typetitle) typeTitle  
   ,MIN(maxLimitAmt) maxLimitAmt  
    FROM serviceTypeMaster stm WITH (NOLOCK)  
    INNER JOIN (  
    SELECT   
     receivingMode,   
     maxLimitAmt   
    FROM countryReceivingMode crm WITH(NOLOCK)   
    INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry   
    WHERE SL.countryId = @countryId AND SL.receivingCountry = ISNULL(@pcountryId, SL.receivingCountry)  
    AND SL.agentId IS NULL AND SL.tranType IS NULL AND receivingAgent IS NULL  
     
    UNION ALL  
          
    SELECT   
     receivingMode,   
     maxLimitAmt   
    FROM countryReceivingMode crm WITH(NOLOCK)   
    INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry   
    AND SL.receivingCountry = ISNULL(@pcountryId, SL.receivingCountry) AND SL.countryId = @countryId   
    WHERE agentId = @agentId  
    AND SL.tranType IS  NULL  
    AND receivingAgent IS NULL  
    AND ISNULL(isActive,'N')='Y'  
    AND ISNULL(isDeleted,'N')='N'      
         
    UNION ALL  
       
    SELECT   
     tranType,   
     MAX(maxLimitAmt) maxLimitAmt  
    FROM sendTranLimit SL WITH (NOLOCK)   
    WHERE countryId = @countryId   
     AND SL.receivingCountry=ISNULL(@pcountryId, SL.receivingCountry)  
     AND ISNULL(isActive,'N')='Y'  
     AND ISNULL(isDeleted,'N')='N'  
     AND SL.agentId IS NULL       
     AND SL.tranType IS NOT NULL  
     AND SL.receivingAgent IS NULL     
    GROUP BY tranType  
         
    UNION ALL  
       
    SELECT   
     tranType,   
     MAX(maxLimitAmt) maxLimitAmt  
    FROM sendTranLimit SL WITH (NOLOCK)  
    WHERE countryId = @countryId   
    AND SL.receivingCountry=ISNULL(@pcountryId, SL.receivingCountry)  
    AND SL.agentId=@agentid  
    AND ISNULL(isActive,'N')='Y'  
    AND ISNULL(isDeleted,'N')='N'  
    AND receivingAgent IS NULL       
    AND SL.tranType IS NOT NULL  
    AND SL.receivingAgent IS NULL     
    GROUP BY tranType   
   ) pt ON  pt.receivingMode = stm.serviceTypeId  
     WHERE ISNULL(STM.isActive,'N')='Y' AND ISNULL(STM.isDeleted,'N')='N'  
     GROUP BY serviceTypeId,typetitle  
     HAVING MIN(pt.maxLimitAmt)>0  
     ORDER BY typeTitle ASC  
  
 END  
  
 ELSE IF @flag = 'sCountry'--CountryName List  
 BEGIN  
  SELECT   
   countryId,  
   countryName  
  FROM countryMaster Where isnull(isOperativeCountry,'') ='Y'  
  AND countryName <>'Worldwide Others'  
  ORDER BY countryName ASC  
  RETURN  
 END  
  
 ELSE IF @flag = 'state'  
 BEGIN  
  IF NOT EXISTS(SELECT 'A' FROM dbo.API_STATE_LIST (NOLOCK) WHERE  STATE_COUNTRY= @pCountryName AND API_PARTNER_ID=@partnerId)  
  BEGIN  
   SELECT 'Any State' LOCATIONNAME,'0' LOCATIONID   
   RETURN  
  END  
  SELECT * FROM (  
  SELECT 'Select State' LOCATIONNAME,NULL LOCATIONID, 0 [ROW]  UNION ALL  
  
  SELECT [STATE_NAME] LOCATIONNAME  
    ,STATE_ID LOCATIONID   
    ,1 [ROW]  
  FROM API_STATE_LIST (NOLOCK)   
  WHERE STATE_COUNTRY = @pCountryName  
  AND API_PARTNER_ID=@partnerId  
  AND (ISNULL(PAYMENT_TYPE_ID, 1) = 1 OR PAYMENT_TYPE_ID=0)  
  AND IS_ACTIVE = 1  
  )X ORDER BY [ROW], X.LOCATIONNAME  
  RETURN  
 END  
  
 ELSE IF @flag = 'city'  
 BEGIN  
  IF NOT EXISTS(SELECT 'A' FROM dbo.API_CITY_LIST (NOLOCK) WHERE STATE_ID = @pLocation)  
  BEGIN  
   SELECT 'Any City' LOCATIONNAME,'0' LOCATIONID   
   RETURN  
  END  
  SELECT CITY_NAME LOCATIONNAME  
    ,CITY_ID LOCATIONID   
  FROM API_CITY_LIST (NOLOCK)   
  WHERE STATE_ID = @pLocation  
  AND IS_ACTIVE = 1  
  ORDER BY LOCATIONNAME  
  RETURN  
 END  
 ELSE IF @flag = 'town'  
 BEGIN  
  IF NOT EXISTS(SELECT 'A' FROM dbo.API_TOWN_LIST (NOLOCK) WHERE CITY_ID = @subLocation)  
  BEGIN  
   SELECT 'Any Town' LOCATIONNAME,'0' LOCATIONID   
   RETURN  
  END  
  SELECT TOWN_NAME LOCATIONNAME  
    ,TOWN_ID LOCATIONID   
  FROM API_TOWN_LIST (NOLOCK)   
  WHERE CITY_ID = @subLocation  
  AND IS_ACTIVE = 1  
  ORDER BY LOCATIONNAME  
  RETURN  
 END  
 ELSE IF @flag = 'pCountry'-- CountryName List  
 BEGIN  
   SELECT   
   countryId,  
   UPPER(countryName) countryName  
  FROM countryMaster CM WITH (NOLOCK)  
  INNER JOIN   
  (  
   SELECT  receivingCountry,min(maxLimitAmt) maxLimitAmt  
   FROM(  
     SELECT   receivingCountry,max (maxLimitAmt) maxLimitAmt  
     FROM sendTranLimit SL WITH (NOLOCK)   
     WHERE --countryId = @countryId  
     --AND  
      ISNULL(isActive,'N')='Y'  
     AND ISNULL(isDeleted,'N')='N'  
     AND ISNULL(agentId,ISNULL(@agentid,0))=ISNULL(@agentid,0)  
     GROUP BY receivingCountry  
                
     UNION ALL  
                 
     SELECT    receivingCountry,max (maxLimitAmt)maxLimitAmt  
     FROM sendTranLimit SL WITH (NOLOCK)   
     WHERE agentId=@agentid  
     AND ISNULL(isActive,'N')='Y'  
     AND ISNULL(isDeleted,'N')='N'  
     GROUP BY receivingCountry    
                   
   ) x GROUP  BY receivingCountry  
  ) Y ON  Y.receivingCountry=CM.countryId  
  WHERE ISNULL(isOperativeCountry,'') ='Y'  
  AND Y.maxLimitAmt>0  
  ORDER BY countryName ASC  
  RETURN  
 END  
  
 ELSE IF @flag = 'pCountryForConsoleWithSenderCountry'-- CountryName List  
 BEGIN  
  --SELECT  113    countryId,  
  --   'Japan'   countryName,  
  --   'JP'   countryCode,  
  --   '394133'  agentId,  
  --   ''    agentName  
  --UNION ALL       ------- add japan country  
          
   SELECT   
   CM.countryId,  
   UPPER(countryName)  countryName,  
   CM.countryCode   countryCode,  
   tpc.AgentId    agentId,  
   am.agentName   agentName  
  FROM countryMaster CM WITH (NOLOCK)  
  INNER JOIN   
  (  
   SELECT  receivingCountry,min(maxLimitAmt) maxLimitAmt  
   FROM(  
     SELECT   receivingCountry,max (maxLimitAmt) maxLimitAmt  
     FROM sendTranLimit SL WITH (NOLOCK)   
     WHERE --countryId = @countryId  
     --AND  
      ISNULL(isActive,'N')='Y'  
     AND ISNULL(isDeleted,'N')='N'  
     AND ISNULL(agentId,ISNULL(@agentid,0))=ISNULL(@agentid,0)  
     GROUP BY receivingCountry  
                
     UNION ALL  
                 
     SELECT    receivingCountry,max (maxLimitAmt)maxLimitAmt  
     FROM sendTranLimit SL WITH (NOLOCK)   
     WHERE agentId=@agentid  
     AND ISNULL(isActive,'N')='Y'  
     AND ISNULL(isDeleted,'N')='N'  
     GROUP BY receivingCountry    
                   
   ) x GROUP  BY receivingCountry  
  ) Y ON  Y.receivingCountry=CM.countryId  
  INNER JOIN TblPartnerwiseCountry tpc (NOLOCK)ON tpc.CountryId = CM.countryId AND CM.countryId='174'  
  AND ISNULL(tpc.IsActive,0)=1  
  INNER JOIN dbo.agentMaster am (NOLOCK) ON am.agentId=tpc.AgentId  
  WHERE ISNULL(isOperativeCountry,'') ='Y'  
  AND Y.maxLimitAmt>0 AND tpc.AgentId='394130' --AND CM.countryId=174  
  ORDER BY countryName ASC  
  RETURN  
 END  
  
 ELSE IF @flag = 'pCountryForConsoleWithOutSenderCountry'-- CountryName List  
 BEGIN  
     
  SELECT   
    CM.countryId     countryId,  
    UPPER(CM.COUNTRYNAME)   countryName,  
    CM.countryCode     countryCode,  
    '394130'      agentId,  
    'TransFast'      agentName,  
    CC.currencyCode     currencyCode,  
  CC.CURRENCYNAME, CC.CURRENCYCODE FROM COUNTRYCURRENCY C  
  INNER JOIN COUNTRYMASTER CM ON CM.COUNTRYID = C.COUNTRYID  
  INNER JOIN CURRENCYMASTER CC ON CC.CURRENCYID = C.CURRENCYID  
  --WHERE  CM.countryId not IN(203,151,113 ) AND ISDEFAULT = 'Y'   
  where cm.countryId in (174, 105)
  and currencyCode = 'JPY'
  RETURN  
  -- SELECT   
  -- CM.countryId,  
  -- UPPER(countryName)  countryName,  
  -- CM.countryCode   countryCode,  
  -- '394130'    agentId,  
  -- 'TransFast'    agentName,  
  -- CCM.currencyCode  currencyCode  
  --FROM countryMaster CM WITH (NOLOCK)   
  --INNER JOIN dbo.countryCurrency CC (NOLOCK) ON CC.countryId=CM.countryId  
  --INNER JOIN dbo.currencyMaster cCM (NOLOCK) ON CCM.currencyId=CC.countryCurrencyId   
  --where cm.isoperativecountry = 'y' AND CC.isDefault='y'  
  --and CM.countryid not in (151, 203, 113)  
  --and countryname <> 'india'  
  --RETURN  
 END  
   
 ELSE If @flag ='pcurr'--load currency by pcountry  
 begin  
  SELECT distinct CM.currencyCode,cc.isDefault  
  FROM currencyMaster CM WITH (NOLOCK)  
  INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId=CC.currencyId  
  WHERE CC.countryId = @countryId AND ISNULL(CC.isDeleted,'')<>'Y'  
  AND CC.spFlag IN ('R', 'B')  
 end  
  
 ELSE IF @flag = 'recAgentByRecModeAjaxagent'  
 BEGIN   
  DECLARE @maxPayoutLimit MONEY, @PAYOUTPARTNER INT  
  
  SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster(nolock) where typeTitle = @param  
  SELECT @PAYOUTPARTNER = TP.AGENTID  
  FROM TblPartnerwiseCountry TP(NOLOCK)  
  INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = TP.AGENTID  
  WHERE TP.CountryId = @pCountryId  
  AND ISNULL(TP.PaymentMethod, @deliveryMethodId) = @deliveryMethodId  
  AND ISNULL(TP.IsActive, 1) = 1  
  AND ISNULL(AM.ISACTIVE, 'Y') = 'Y'  
  AND ISNULL(AM.ISDELETED, 'N') = 'N'  
  
    
    
  select @maxPayoutLimit = maxLimitAmt from receiveTranLimit(NOLOCK)   
  WHERE countryId = @pCountryId AND tranType = @deliveryMethodId  
  AND sendingCountry = @countryId  
  
  IF @param IN ('CASH PAYMENT', 'DOOR TO DOOR')  
  BEGIN  
   DECLARE @SQL VARCHAR(MAX) = ''  
   IF EXISTS(SELECT TOP 1 'A' FROM API_BANK_LIST AP(NOLOCK)   
      INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AP.BANK_COUNTRY  
      WHERE CM.COUNTRYID = @pCountryId AND API_PARTNER_ID = @PAYOUTPARTNER AND PAYMENT_TYPE_ID IN (1, 12, 0))  
   BEGIN  
    IF @pCountryId = '151'  
    BEGIN  
     SET @SQL = 'SELECT bankId = '''', 0 NS,FLAG = ''E'',AGENTNAME = ''[ANY WHERE]'',maxPayoutLimit = '''+CAST(ISNULL(@maxPayoutLimit, 0) AS VARCHAR)+''' '  
	 EXEC(@SQL) 
	 RETURN
    END  
    IF @pCountryId = '203'  
    BEGIN  
    --FOR VIETNAM ONLY  
      SET @SQL += 'SELECT bankId=AL.BANK_ID, 0 NS,FLAG = ''E'',AGENTNAME =LTRIM(RTRIM(AL.BANK_NAME)) ,maxPayoutLimit = '''+CAST(ISNULL(@maxPayoutLimit, 0) AS VARCHAR)+'''  
      FROM API_BANK_LIST AL(NOLOCK)  
      INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
      WHERE CM.COUNTRYID = '''+CAST(@pCountryId AS VARCHAR)+'''  
      AND AL.PAYMENT_TYPE_ID IN (0, '''+CAST(@deliveryMethodId AS VARCHAR)+''')  
      AND AL.IS_ACTIVE = 1  
      AND AL.API_PARTNER_ID = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+''''  
    END
	IF @pCountryId='142'
	BEGIN
	    SET @SQL +='SELECT * FROM dbo.KoreanBankList WHERE ISNULL(IsActive,0)=1'
	END 
    ELSE  
    BEGIN  
      SET @SQL += 'SELECT bankId=AL.BANK_ID, 0 NS,FLAG = ''E'',AGENTNAME =LTRIM(RTRIM(AL.BANK_NAME)) ,maxPayoutLimit = '''+CAST(ISNULL(@maxPayoutLimit, 0) AS VARCHAR)+'''  
      FROM API_BANK_LIST AL(NOLOCK)  
      INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
      WHERE CM.COUNTRYID = '''+CAST(@pCountryId AS VARCHAR)+'''  
      AND AL.PAYMENT_TYPE_ID IN (0, '''+CAST(@deliveryMethodId AS VARCHAR)+''')  
      AND AL.IS_ACTIVE = 1  
      AND AL.API_PARTNER_ID = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+''''  
    END  
    
    PRINT(@SQL)  
    EXEC(@SQL)  
   END  
   ELSE  
   BEGIN  
    SELECT bankId = '', 0 NS,FLAG = 'E',AGENTNAME = '[ANY WHERE]',maxPayoutLimit = @maxPayoutLimit  
   END  
   RETURN  
  END   
  ELSE IF @param = 'BANK DEPOSIT'  
  BEGIN  
    IF @pCountryId = '203'  
    BEGIN  
	     SELECT * FROM   (  
		 SELECT bankId = null, 0 NS,FLAG = 'E',AGENTNAME = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit  
		 UNION ALL  
		 SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME =LTRIM(RTRIM(AL.BANK_NAME))+'||'+AL.BANK_CODE1 ,maxPayoutLimit = @maxPayoutLimit  
		 FROM API_BANK_LIST AL(NOLOCK)  
		 INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
		 WHERE CM.COUNTRYID = @pCountryId  
		 AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
		 AND AL.IS_ACTIVE = 1  
		 AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
		)X  
		ORDER BY X.AGENTNAME  
		RETURN 
	END
	ELSE
	BEGIN 
	   SELECT * FROM   (  
	   SELECT bankId = null, 0 NS,FLAG = 'E',AGENTNAME = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit  
	   UNION ALL  
	   SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME =LTRIM(RTRIM(AL.BANK_NAME))+'||'+AL.BANK_CODE1 ,maxPayoutLimit = @maxPayoutLimit  
	   FROM API_BANK_LIST AL(NOLOCK)  
	   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
	   WHERE CM.COUNTRYID = @pCountryId  
	   AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
	   AND AL.IS_ACTIVE = 1  
	   AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
	   )X  
	   ORDER BY X.AGENTNAME  
	   RETURN 
	END
  END   
  ELSE  
  BEGIN  
    IF @pCountryId = '203'  
    BEGIN 
		SELECT bankId=AL.BANK_ID,   
			   0 NS,  
			   FLAG = 'E',  
			   AGENTNAME = AL.BANK_CODE2,  
			   maxPayoutLimit = @maxPayoutLimit   
			   FROM API_BANK_LIST AL(NOLOCK)  
			   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
			   WHERE CM.COUNTRYID = @pCountryId  
			   AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
			   AND AL.IS_ACTIVE = 1  
			   AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
			   ORDER BY AL.BANK_NAME  
	END
	ELSE
	BEGIN
		SELECT bankId=AL.BANK_ID,   
		   0 NS,  
		   FLAG = 'E',  
		   AGENTNAME = AL.BANK_NAME,  
		   maxPayoutLimit = @maxPayoutLimit   
		   FROM API_BANK_LIST AL(NOLOCK)  
		   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
		   WHERE CM.COUNTRYID = @pCountryId  
		   AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
		   AND AL.IS_ACTIVE = 1  
		   AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
		   ORDER BY AL.BANK_NAME  
	END
     
   RETURN  
  END  
 END  
  
 ELSE IF @flag = 'recAgentByRecModeAjaxagentAndCountry'  
 BEGIN   
  
  SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster(nolock) where typeTitle = @param  
  SELECT @PAYOUTPARTNER = TP.AGENTID  
  FROM TblPartnerwiseCountry TP(NOLOCK)  
  INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = TP.AGENTID  
  WHERE TP.CountryId = @pCountryId  
  AND ISNULL(TP.PaymentMethod, @deliveryMethodId) = @deliveryMethodId  
  AND ISNULL(TP.IsActive, 1) = 1  
  AND ISNULL(AM.ISACTIVE, 'Y') = 'Y'  
  AND ISNULL(AM.ISDELETED, 'N') = 'N'  
  
    
    
  select @maxPayoutLimit = maxLimitAmt from receiveTranLimit(NOLOCK)   
  WHERE countryId = @pCountryId AND tranType = @deliveryMethodId  
  AND sendingCountry = @countryId  
  
  IF @param IN ('CASH PAYMENT', 'DOOR TO DOOR')  
  BEGIN  
   DECLARE @SQL1 VARCHAR(MAX) = ''  
   IF EXISTS(SELECT TOP 1 'A' FROM API_BANK_LIST AP(NOLOCK)   
      INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AP.BANK_COUNTRY  
      WHERE CM.COUNTRYID = @pCountryId AND API_PARTNER_ID = @PAYOUTPARTNER AND PAYMENT_TYPE_ID IN (1, 12, 0))  
   BEGIN  
    IF @pCountryId = '151'  
    BEGIN  
       SET @SQL = 'SELECT bankId = '''', 0 NS,FLAG = ''E'',AGENTNAME = ''[ANY WHERE]'',maxPayoutLimit = '''+CAST(ISNULL(@maxPayoutLimit, 0) AS VARCHAR)+''' '  
	   EXEC(@SQL) 
	   RETURN
    END  
    IF @pCountryId = '203'  
    BEGIN  
    --FOR VIETNAM ONLY  
      SET @SQL1 += 'SELECT bankId=AL.BANK_ID, 0 NS,FLAG = ''E'',AGENTNAME =LTRIM(RTRIM(BANK_NAME)) + '' - '' +LTRIM(RTRIM(AL.BANK_CODE2)) ,maxPayoutLimit = '''+CAST(ISNULL(@maxPayoutLimit, 0) AS VARCHAR)+'''  
      FROM API_BANK_LIST AL(NOLOCK)  
      INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
      WHERE CM.COUNTRYID = '''+CAST(@pCountryId AS VARCHAR)+'''  
      AND AL.PAYMENT_TYPE_ID IN (0, '''+CAST(@deliveryMethodId AS VARCHAR)+''')  
      AND AL.IS_ACTIVE = 1  
      AND AL.API_PARTNER_ID = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+''''  
    END
	 
    ELSE  
    BEGIN  
      SET @SQL1 += 'SELECT bankId=AL.BANK_ID, 0 NS,FLAG = ''E'',AGENTNAME =LTRIM(RTRIM(AL.BANK_NAME)) ,maxPayoutLimit = '''+CAST(ISNULL(@maxPayoutLimit, 0) AS VARCHAR)+'''  
      FROM API_BANK_LIST AL(NOLOCK)  
      INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
      WHERE CM.COUNTRYID = '''+CAST(@pCountryId AS VARCHAR)+'''  
      AND AL.PAYMENT_TYPE_ID IN (0, '''+CAST(@deliveryMethodId AS VARCHAR)+''')  
      AND AL.IS_ACTIVE = 1  
      AND AL.API_PARTNER_ID = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+''''  
    END  
    
    PRINT(@SQL1)  
    EXEC(@SQL1)  
   END  
   ELSE  
   BEGIN  
    SELECT bankId = '', 0 NS,FLAG = 'E',AGENTNAME = '[ANY WHERE]',maxPayoutLimit = @maxPayoutLimit  
   END  
   RETURN  
  END   
  ELSE IF @param = 'BANK DEPOSIT'  
  BEGIN 
  
  IF @pCountryId='142'
  BEGIN
	   SELECT bankId = null, 0 NS,FLAG = 'E',AGENTNAME = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit  
	   UNION ALL
       SELECT bankId=rowId, 0 NS , FLAG='E',AGENTNAME=LTRIM(RTRIM(BankName)),maxPayoutLimit = @maxPayoutLimit   
	   FROM dbo.KoreanBankList (NOLOCK) WHERE ISNULL(IsActive,0)=1
  END
  ELSE
  BEGIN
   SELECT * FROM   
   (  
    SELECT bankId = null, 0 NS,FLAG = 'E',AGENTNAME = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit  
    UNION ALL  
    SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME =LTRIM(RTRIM(AL.BANK_NAME)) ,maxPayoutLimit = @maxPayoutLimit  
    FROM API_BANK_LIST AL(NOLOCK)  
    INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
    WHERE CM.COUNTRYID = @pCountryId  
    AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
    AND AL.IS_ACTIVE = 1  
    AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
   )X  
   ORDER BY X.AGENTNAME  
   RETURN  
  END
  END   
  ELSE  
  BEGIN  
   SELECT bankId=AL.BANK_ID,   
     0 NS,  
     FLAG = 'E',  
     AGENTNAME = AL.BANK_NAME,  
     maxPayoutLimit = @maxPayoutLimit   
   FROM API_BANK_LIST AL(NOLOCK)  
   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
   WHERE CM.COUNTRYID = @pCountryId  
   AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
   AND AL.IS_ACTIVE = 1  
   AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
   ORDER BY AL.BANK_NAME  
     
   RETURN  
  END  
 END  
 --BEGIN   
 -- SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster(nolock) where typeTitle = @param  
    
 -- SELECT @PAYOUTPARTNER = TP.AGENTID  
 -- FROM TblPartnerwiseCountry TP(NOLOCK)  
 -- INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = TP.AGENTID  
 -- WHERE TP.CountryId = @pCountryId  
 -- AND ISNULL(TP.PaymentMethod, @deliveryMethodId) = @deliveryMethodId  
 -- AND ISNULL(TP.IsActive, 1) = 1  
 -- AND ISNULL(AM.ISACTIVE, 'Y') = 'Y'  
 -- AND ISNULL(AM.ISDELETED, 'N') = 'N'  
  
    
 -- select @maxPayoutLimit = maxLimitAmt from receiveTranLimit(NOLOCK)   
 -- WHERE countryId = @pCountryId AND tranType = @deliveryMethodId  
 -- and sendingCountry = @countryId  
  
 -- IF @param IN ('CASH PAYMENT', 'DOOR TO DOOR')  
 -- BEGIN  
 --  IF EXISTS(SELECT TOP 1 'A' FROM API_BANK_LIST AP(NOLOCK)   
 --  INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AP.BANK_COUNTRY  
 --  WHERE CM.COUNTRYID = @pCountryId AND API_PARTNER_ID = @PAYOUTPARTNER AND PAYMENT_TYPE_ID IN (1, 12, 0))  
 --  BEGIN  
  
 --   SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME = AL.BANK_NAME,maxPayoutLimit = @maxPayoutLimit  
 --   FROM API_BANK_LIST AL(NOLOCK)  
 --   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
 --   WHERE CM.COUNTRYID = @pCountryId  
 --   AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
 --   AND AL.IS_ACTIVE = 1  
 --   AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
 --   ORDER BY AL.BANK_NAME 
 --  END  
 --  ELSE  
 --  BEGIN  
 --   SELECT bankId = '', 0 NS,FLAG = 'E',AGENTNAME = '[ANY WHERE]',maxPayoutLimit = @maxPayoutLimit  
 --  END  
 -- END   
 -- ELSE IF @param = 'BANK DEPOSIT'  
 -- BEGIN  
 --  SELECT * FROM   
 --  (  
 --   SELECT bankId = '', 0 NS,FLAG = 'E',AGENTNAME = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit  
 --   UNION ALL  
 --   SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME = AL.BANK_NAME,maxPayoutLimit = @maxPayoutLimit  
 --   FROM API_BANK_LIST AL(NOLOCK)  
 --   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
 --   WHERE CM.COUNTRYID = @pCountryId  
 --   AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
 --   AND AL.IS_ACTIVE = 1  
 --   AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
 --  )X  
 --  ORDER BY X.AGENTNAME  
 --  RETURN  
 -- END   
 -- ELSE  
 -- BEGIN  
 --  SELECT bankId=AL.BANK_ID,   
 --    0 NS,  
 --    FLAG = 'E',  
 --    AGENTNAME = AL.BANK_NAME,  
 --    maxPayoutLimit = @maxPayoutLimit   
 --  FROM API_BANK_LIST AL(NOLOCK)  
 --  INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
 --  WHERE CM.COUNTRYID = @pCountryId  
 --  AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)  
 --  AND AL.IS_ACTIVE = 1  
 --  AND AL.API_PARTNER_ID = @PAYOUTPARTNER  
 --  ORDER BY AL.BANK_NAME  
     
 --  RETURN  
 -- END  
 --END  
  
 ELSE IF @flag = 'agentsetting'  
 BEGIN  
	DECLARE @PROMOTIONAL_CODE VARCHAR(20), @ROW_ID INT, @PROMOTIONAL_MSG VARCHAR(250), @PROMOTION_TYPE VARCHAR(150), @PROMOTION_VALUE MONEY
	--PROMOTIONAL CAMPAIGN
	 SELECT @ROW_ID = ROW_ID
			,@PROMOTIONAL_CODE = PROMOTIONAL_CODE
			,@PROMOTIONAL_MSG = PROMOTIONAL_MSG
			,@PROMOTION_VALUE = PROMOTION_VALUE
			,@PROMOTION_TYPE = detailTitle
	 FROM TBL_PROMOTIONAL_CAMAPAIGN P(NOLOCK)
	 INNER JOIN STATICDATAVALUE S(NOLOCK) ON S.VALUEID = P.PROMOTION_TYPE
	 WHERE 1 = 1
	 AND COUNTRY_ID = @countryId 
	 AND ISNULL(PAYMENT_METHOD, @deliveryMethodId) = @deliveryMethodId
	 AND CAST(GETDATE() AS DATE) BETWEEN START_DT AND END_DT
	 AND APPROVEDDATE IS NOT NULL
	 AND IS_ACTIVE = 1

  IF @pBankType = 'I'  
  BEGIN  
   DECLARE @rtlId INT  
   SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId = @agentId AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
   IF @rtlId IS NULL  
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId = @agentId AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
   IF @rtlId IS NULL  
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @countryId AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
   IF @rtlId IS NULL  
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @countryId AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
     
   SELECT  
     maxLimitAmt  
    ,agMaxLimitAmt  
    ,branchSelection  
    ,benificiaryIdReq  
    ,relationshipReq  = ''  
    ,benificiaryContactReq  
    ,acLengthFrom  
    ,acLengthTo  
    ,acNumberType 
	,ROW_ID = @ROW_ID
	,PROMOTIONAL_CODE = @PROMOTIONAL_CODE
	,PROMOTIONAL_MSG = @PROMOTIONAL_MSG
	,PROMOTION_VALUE = @PROMOTION_VALUE
	,PROMOTION_TYPE = @PROMOTION_TYPE
   FROM receiveTranLimit WITH(NOLOCK)  
   WHERE rtlId = @rtlId  
  END  
  ELSE IF @pBankType = 'E'  
  BEGIN  
   SELECT  
     maxLimitAmt   = ''  
    ,agMaxLimitAmt   = ''  
    ,branchSelection  = IsBranchSelectionRequired  
    ,benificiaryIdReq  = ''  
    ,relationshipReq  = ''  
    ,benificiaryContactReq = ''  
    ,acLengthFrom   = ''  
    ,acLengthTo    = ''  
    ,acNumberType   = ''
	,ROW_ID = @ROW_ID
	,PROMOTIONAL_CODE = @PROMOTIONAL_CODE
	,PROMOTIONAL_MSG = @PROMOTIONAL_MSG
	,PROMOTION_VALUE = @PROMOTION_VALUE
	,PROMOTION_TYPE = @PROMOTION_TYPE  
   FROM externalBank WITH(NOLOCK)  
   WHERE extBankId = @agentId  
  END  
  ELSE  
  BEGIN  
   SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @countryId AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
   IF @rtlId IS NULL  
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @countryId AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
     
   SELECT  
     maxLimitAmt  
    ,agMaxLimitAmt  
    ,branchSelection  
    ,benificiaryIdReq  
    ,relationshipReq  = ''  
    ,benificiaryContactReq  
    ,acLengthFrom  
    ,acLengthTo  
    ,acNumberType  
	,ROW_ID = @ROW_ID
	,PROMOTIONAL_CODE = @PROMOTIONAL_CODE
	,PROMOTIONAL_MSG = @PROMOTIONAL_MSG
	,PROMOTION_VALUE = @PROMOTION_VALUE
	,PROMOTION_TYPE = @PROMOTION_TYPE
   FROM receiveTranLimit WITH(NOLOCK)  
   WHERE rtlId = @rtlId  
  END  
 END  
  
ELSE IF @flag = 'branchAjax'-- Select branchName List According to AgentName By pralhad  
BEGIN  
 --SELECT * FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NOT NULL  
 DECLARE @branchSelection VARCHAR(50)  
 SELECT @branchSelection = ISNULL(branchSelection,'A')  FROM receiveTranLimit WITH (NOLOCK) WHERE agentId = @agentId  
   
 SELECT @branchSelection [branchSelection]  
 RETURN  
END  
  
ELSE IF @flag = 'schemeBySCountry'  
BEGIN  
  
 SELECT rowId as schemeCode ,schemeName   
 FROM schemeSetup WITH (NOLOCK)   
 WHERE sCountry=@countryName   
   
  
END  
  
ELSE IF @flag = 'schemeBySCountryRCountry'  
BEGIN  
 DECLARE @customerTypeId INT  
 SET @customerTypeId = 4700  
   
 DECLARE @schemeTable TABLE(schemeCode VARCHAR(50), schemeName VARCHAR(100), sCountry VARCHAR(10), sAgent VARCHAR(10), sBranch VARCHAR(10), rCountry VARCHAR(10), rAgent VARCHAR(10), customerType VARCHAR(10))  
 INSERT INTO @schemeTable  
 SELECT  
   schemeCode = rowId  
  ,schemeName  
  ,sCountry,sAgent,sBranch  
  ,rCountry,rAgent  
  ,customerType  
 FROM schemeSetup WITH (NOLOCK)   
 WHERE sCountry = @country  
 AND rCountry = @pCountryId  
 AND GETDATE() BETWEEN ISNULL(schemeStartDate, '1900-01-01') AND ISNULL(schemeEndDate, '2100-01-01')  
   
 IF EXISTS(SELECT 'X' FROM @schemeTable)  
 BEGIN  
  IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sBranch = @sBranch)  
  BEGIN  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch = @sBranch AND rAgent = @rAgent AND customerType = @customerTypeId)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch = @sBranch AND rAgent = @rAgent AND customerType = @customerTypeId   
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch = @sBranch AND rAgent = @rAgent AND customerType IS NULL)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch = @sBranch AND rAgent = @rAgent AND customerType IS NULL  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch = @sBranch AND rAgent IS NULL AND customerType = @customerTypeId)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch = @sBranch AND rAgent IS NULL AND customerType IS NULL)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL  
    RETURN  
   END  
  END  
  IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL)  
  BEGIN  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent = @rAgent AND customerType = @customerTypeId)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent = @rAgent AND customerType = @customerTypeId  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent = @rAgent AND customerType IS NULL)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent = @rAgent AND customerType IS NULL  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL)  
   BEGIN  
    SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL  
    RETURN  
   END  
  END  
  IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId)  
  BEGIN  
   SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId  
   RETURN  
  END  
  IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL)  
  BEGIN  
   SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent = @sAgent AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL  
   RETURN  
  END   
  IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent IS NULL AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId)  
  BEGIN  
   SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent IS NULL AND sBranch IS NULL AND rAgent IS NULL AND customerType = @customerTypeId  
   RETURN  
  END  
  IF EXISTS(SELECT 'X' FROM @schemeTable WHERE sAgent IS NULL AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL)  
  BEGIN  
   SELECT schemeCode, schemeName FROM @schemeTable WHERE sAgent IS NULL AND sBranch IS NULL AND rAgent IS NULL AND customerType IS NULL  
   RETURN  
  END   
 END  
END  
  
ELSE IF @flag = 'loadRulesCountry'  
BEGIN  
   
 SELECT D.paymentMode,D.tranCount,D.amount FROM csMaster M WITH (NOLOCK)  
 INNER JOIN csDetail D WITH(NOLOCK) ON M.csMasterId=D.csDetailId  
 WHERE sCountry=@countryId  
 AND ISNULL(M.isActive,'Y')='Y' AND ISNULL(D.isActive,'Y')='Y'   
  
END  
  
ELSE IF @flag = 'loadOccupation'  
BEGIN  
 SELECT occupationId,detailTitle  
 FROM occupationMaster WITH (NOLOCK)   
 WHERE ISNULL(isActive,'Y')='Y' AND ISNULL(isDeleted,'N')<>'Y'  
END  
  
ELSE IF @flag = 'idTypeBySCountry' --   
BEGIN  
 SELECT   
   valueId  = CAST(SV.valueId AS VARCHAR) + '|' + ISNULL(CID.expiryType, 'E')  
  ,detailTitle = SV.detailTitle  
  ,expiryType = CID.expiryType  
 FROM countryIdType CID WITH(NOLOCK)  
 INNER JOIN staticDataValue SV WITH(NOLOCK) ON CID.IdTypeId = SV.valueId  
 WHERE countryId = @countryId AND ISNULL(isDeleted,'N') <> 'Y'  
    AND (spFlag IS NULL OR ISNULL(spFlag, 0) = 5200)  
END  
  
ELSE IF @flag = 'idTypeByPCountry'  
BEGIN  
 SELECT  
   valueId  
  ,detailTitle  
 FROM staticDataValue sdv WITH(NOLOCK)  
 WHERE typeID = 1300  
 AND ISNULL(IS_DELETE, 'N') = 'N'  
END  
  
ELSE IF @FLAG = 'pageField' ---FIELD SELECTED FOR SEND TXN  
BEGIN  
 DECLARE @rowId INT = NULL  
 SELECT @rowId = rowId FROM sendPayTable WITH(NOLOCK) WHERE agent = @agentId AND ISNULL(isDeleted, 'N') = 'N'  
 IF @rowId IS NULL  
  SELECT @rowId = rowId FROM sendPayTable WITH(NOLOCK) WHERE country = @countryId AND agent IS NULL AND ISNULL(isDeleted, 'N') = 'N'  
    
  SELECT   
   customerRegistration   
  ,newCustomer  
  ,collection  
  ,id  
  ,idIssueDate  
  ,iDValidDate  
  ,dob  
  ,address  
  ,city  
  ,nativeCountry  
  ,contact  
  ,occupation  
  ,company  
  ,salaryRange  
  ,purposeofRemittance  
  ,sourceofFund  
  ,rId  
  ,rPlaceOfIssue  
  ,raddress  
  ,rcity  
  ,rContact  
  ,rRelationShip  
  ,rIdValidDate  
  ,rDOB  
  FROM sendPayTable WITH (NOLOCK)  
  WHERE rowId = @rowId  
  
 SELECT SD.detailTitle,SD.detailDesc, CC.COLLMODE, ISDEFAULT = 0 INTO #TEMP  
 FROM countryCollectionMode CC(NOLOCK)   
 INNER JOIN staticDataValue SD(NOLOCK) ON SD.VALUEID = CC.COLLMODE  
 WHERE ISNULL(SD.isActive, 'Y') = 'Y'  
 AND ISNULL(SD.IS_DELETE, 'N') = 'N'  
 AND CC.countryId = @countryId  
  
 UPDATE #TEMP SET ISDEFAULT = 1 WHERE collMode = 11062  
  
 SELECT * FROM #TEMP  
END  
  
ELSE IF @FLAG = 'COLLMODE-AG'  
BEGIN  
 SELECT SD.detailTitle, CC.COLLMODE, ISDEFAULT = 0 INTO #TEMP1  
 FROM countryCollectionMode CC(NOLOCK)   
 INNER JOIN staticDataValue SD(NOLOCK) ON SD.VALUEID = CC.COLLMODE  
 WHERE ISNULL(SD.isActive, 'Y') = 'Y'  
 AND ISNULL(SD.IS_DELETE, 'N') = 'N'  
 AND CC.countryId = @countryId  
  
 UPDATE #TEMP1 SET ISDEFAULT = 1 WHERE collMode = 11062  
  
 SELECT * FROM #TEMP1  
END  
  
ELSE IF @flag = 'agentByExtAgent' --Get Principle Agent By External Agent  
BEGIN  
 SELECT DISTINCT  
   am.agentId  
  ,am.agentName  
 FROM agentMaster am WITH(NOLOCK)  
 INNER JOIN ExternalBankCode ebc WITH(NOLOCK) ON am.agentId = ebc.agentId  
 WHERE bankId = @param  
 AND ISNULL(am.isActive, 'N') = 'Y'   
 AND ISNULL(ebc.isDeleted, 'N') = 'N'  
END  
  
ELSE IF @flag = 'agentByExtBranch'  
BEGIN  
 --SELECT * FROM externalBankCode ORDER BY bankId  
 SELECT @param = extBankId FROM externalBankBranch WITH(NOLOCK) WHERE extBranchId = @param  
 SELECT DISTINCT  
   am.agentId  
  ,am.agentName  
 FROM agentMaster am WITH(NOLOCK)  
 INNER JOIN ExternalBankCode ebc WITH(NOLOCK) ON am.agentId = ebc.agentId  
 WHERE bankId = @param  
 AND ISNULL(am.isActive, 'N') = 'Y'   
 AND ISNULL(ebc.isDeleted, 'N') = 'N'  
END  
  
ELSE IF @flag = 'payoutLimitInfo'  
BEGIN  
 --6. Payout Per Txn Limit  
 DECLARE @pCurr VARCHAR(3)  
 SELECT @pCurr = cm.currencyCode   
 FROM countryCurrency cc INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId  
 WHERE cc.countryId = @pCountryId  
   
 IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE sendingCountry = @countryId  
    AND countryId = @pCountryId AND (agentId = @rAgent OR agentId IS NULL) AND currency = @pCurr  
    AND ISNULL(tranType, ISNULL(@deliveryMethodId, 0)) = ISNULL(@deliveryMethodId, 0)  
    AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
    )  
 BEGIN  
  SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
  WHERE sendingCountry = @countryId AND countryId = @pCountryId AND agentId = @rAgent AND currency = @pCurr   
  AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
    
  IF @rtlId IS NULL     
   SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
   WHERE sendingCountry = @countryId AND countryId = @pCountryId AND agentId = @rAgent AND currency = @pCurr   
   AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
    
  IF @rtlId IS NULL  
   SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
   WHERE sendingCountry = @countryId AND countryId = @pCountryId AND agentId IS NULL AND currency = @pCurr   
   AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
    
  IF @rtlId IS NULL  
   SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
   WHERE sendingCountry = @countryId AND countryId = @pCountryId AND agentId IS NULL AND currency = @pCurr   
   AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'   
 END  
 IF @rtlId IS NULL  
 BEGIN  
  IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE sendingCountry IS NULL  
     AND countryId = @pCountryId AND (agentId = @rAgent OR agentId IS NULL) AND currency = @pCurr  
     AND ISNULL(tranType, ISNULL(@deliveryMethodId, 0)) = ISNULL(@deliveryMethodId, 0)  
     AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
     )  
  BEGIN  
   SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
   WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId = @rAgent AND currency = @pCurr   
   AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
     
   IF @rtlId IS NULL     
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
    WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId = @rAgent AND currency = @pCurr   
    AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
     
   IF @rtlId IS NULL  
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
    WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId IS NULL AND currency = @pCurr   
    AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'  
     
   IF @rtlId IS NULL  
    SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)  
    WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId IS NULL AND currency = @pCurr   
    AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'   
  END  
 END  
 SELECT maxLimitAmt FROM receiveTranLimit   
 WITH(NOLOCK) WHERE rtlId = @rtlId  
END  
  
ELSE IF @flag = 'ofac'  
BEGIN  
  
 --EXEC proc_sendPageLoadData @flag = 'ofac', @user = 'admin', @blackListIds = 'OFAC10,UNSCR111952'  
 --EXEC proc_sendPageLoadData @flag = 'ofac', @user = 'admin', @blackListIds = 'OFAC10,UNSCR111952'  
 IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL   
 DROP TABLE #tempMaster  
   
 IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL   
 DROP TABLE #tempDataTable  
    
  
 CREATE TABLE #tempDataTable(DATA VARCHAR(MAX) NULL)  
   
 SELECT A.val ofacKeyId  
 INTO #tempMaster  
 FROM  
 (  
  SELECT * FROM dbo.SplitXML(',', @blackListIds)  
 )A  
 INNER JOIN  
 (  
  SELECT distinct ofacKey FROM blacklist with(nolock)  
 )B ON A.val = B.ofacKey  
   
 ALTER TABLE #tempMaster ADD ROWID INT IDENTITY(1,1)  
  
 DECLARE @TNA_ID AS INT  
   ,@MAX_ROW_ID AS INT 
   ,@ofacKeyId VARCHAR(100)  
   ,@SDN VARCHAR(MAX)=''  
   ,@ADDRESS VARCHAR(MAX)=''  
   ,@REMARKS AS VARCHAR(MAX)=''  
   ,@ALT AS VARCHAR(MAX)=''  
   ,@DATA AS VARCHAR(MAX)=''  
   ,@DATA_SOURCE AS VARCHAR(200)=''  

	SET @ROW_ID = 1
   
 SELECT @MAX_ROW_ID=MAX(ROWID) FROM #tempMaster   
 WHILE @MAX_ROW_ID >=  @ROW_ID  
 BEGIN   
    
  SELECT @ofacKeyId=ofacKeyId FROM #tempMaster WHERE ROWID=@ROW_ID    
  
  SELECT @SDN='<b>'+ISNULL(entNum,'')+'</b>,  <b>Name:</b> '+ ISNULL(name,''),@DATA_SOURCE='<b>Data Source:</b> '+ISNULL(dataSource,'')  
  FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'    
    
  SELECT @ADDRESS=ISNULL(name,'')+', '+ISNULL(address,'')+', '+ISNULL(city,'')+', '+ISNULL(STATE,'')+', '+ISNULL(zip,'')+', '+ISNULL(country,'')  
  FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='add'  
    
  SELECT @ALT = COALESCE(@ALT + ', ', '') +CAST(ISNULL(NAME,'') AS VARCHAR(MAX))  
  FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType IN ('alt','aka')     
      
  SELECT @REMARKS=ISNULL(remarks,'')  
  FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'  
  
  SET @SDN=RTRIM(LTRIM(@SDN))  
  SET @ADDRESS=RTRIM(LTRIM(@ADDRESS))  
  SET @ALT=RTRIM(LTRIM(@ALT))  
  SET @REMARKS=RTRIM(LTRIM(@REMARKS))   
    
  SET @SDN=REPLACE(@SDN,', ,','')  
  SET @ADDRESS=REPLACE(@ADDRESS,', ,','')  
  SET @ALT=REPLACE(@ALT,', ,','')  
  SET @REMARKS=REPLACE(@REMARKS,', ,','')  
    
  SET @SDN=REPLACE(@SDN,'-0-','')  
  SET @ADDRESS=REPLACE(@ADDRESS,'-0-','')  
  SET @ALT=REPLACE(@ALT,'-0-','')  
  SET @REMARKS=REPLACE(@REMARKS,'-0-','')  
    
  SET @SDN=REPLACE(@SDN,',,','')  
  SET @ADDRESS=REPLACE(@ADDRESS,',,','')  
  SET @ALT=REPLACE(@ALT,',,','')  
  SET @REMARKS=REPLACE(@REMARKS,',,','')  
    
  IF @DATA_SOURCE IS NOT NULL AND @DATA_SOURCE<>''   
   SET @DATA=@DATA_SOURCE  
     
  IF @SDN IS NOT NULL AND @SDN<>''   
   SET @DATA=@DATA+'<BR>'+@SDN  
     
  IF @ADDRESS IS NOT NULL AND @ADDRESS<>''   
   SET @DATA=@DATA+'<BR><b>Address: </b>'+@ADDRESS  
     
  IF @ALT IS NOT NULL AND @ALT<>'' AND @ALT<>' '  
   SET @DATA=@DATA+'<BR>'+'<b>a.k.a :</b>'+@ALT+''  
  
  IF @REMARKS IS NOT NULL AND @REMARKS<>''   
   SET @DATA=@DATA+'<BR><b>Other Info :</b>'+@REMARKS  
  
  IF @DATA IS NOT NULL OR @DATA <>''  
  BEGIN  
   INSERT INTO #tempDataTable    
   SELECT REPLACE(@DATA,'<BR><BR>','')  
  END  
    
  SET @ROW_ID=@ROW_ID+1  
 END  
    
 ALTER TABLE #tempDataTable ADD ROWID INT IDENTITY(1,1)  
 SELECT ROWID [S.N.],DATA [Remarks] FROM #tempDataTable  
END  
  
ELSE IF @flag = 'Compliance'  
BEGIN  
 SELECT  
   id  
  ,csDetailRecId   
  ,[S.N.]  = ROW_NUMBER()OVER(ORDER BY id)   
  ,[Remarks] = RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' +   
      CASE WHEN checkType = 'Sum' THEN 'Transaction Amount'   
        WHEN checkType = 'Count' THEN 'Transaction Count' END  
      + ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' day(s) ' + dbo.FNAGetDataValue(criteria)     
  ,[Matched Tran ID] = rtc.matchTranId  
 FROM remitTranComplianceTemp rtc   
 INNER JOIN csDetailRec cdr ON rtc.csDetailTranId = cdr.csDetailRecId   
 WHERE rtc.agentRefId = @agentRefId  
END  
  
ELSE IF @flag='COMPL_DETAIL'  
BEGIN  
/*  
5000 By Sender ID  
5001 By Sender Name  
5002 By Sender Mobile  
5003 By Beneficiary ID  
5004 By Beneficiary ID(System)  
5005 By Beneficiary Name  
5006 By Beneficiary Mobile  
5007 By Beneficiary A/C Number  
*/  
 DECLARE @tranIds AS VARCHAR(MAX), @criteria AS INT, @totalTran AS INT, @criteriaValue AS VARCHAR(500), @id AS INT,@reason VARCHAR(500)  
 SELECT   
  @tranIds = matchTranId  
 FROM remitTranComplianceTemp with(nolock)   
 WHERE id = @complianceTempId --(ROWID) --id of remitTranCompliance  
  
 SELECT @criteria = criteria FROM csDetailRec with(nolock) WHERE csDetailRecId = @csDetailRecId--id of csDetailRec  
   
 DECLARE @tranIdTemp TABLE(tranId BIGINT)  
 INSERT INTO @tranIdTemp  
 SELECT value FROM dbo.Split(',', @tranIds)  
   
 SELECT @totalTran = COUNT(*) FROM @tranIdTemp  
      
 SELECT  
   REMARKS = CASE WHEN @csDetailRecId = 0 THEN @reason ELSE  
      RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' +   
      CASE WHEN checkType = 'Sum' THEN 'Transaction Amount'   
        WHEN checkType = 'Count' THEN 'Transaction Count' END  
      + ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' day(s) ' + dbo.FNAGetDataValue(criteria)+': <font size=''2px''>'+ISNULL(@criteriaValue,'')+'</font>'  
      END  
  ,totTran = 'Total Count: <b>'+ CASE WHEN @csDetailRecId = 0 THEN '1' ELSE  CAST(@totalTran AS VARCHAR) END +'</b>'  
 FROM csDetailRec with(nolock)  
 WHERE csDetailRecId= CASE WHEN @csDetailRecId = 0 THEN 1 ELSE @csDetailRecId END  
  
 SELECT   
   [S.N.]   = ROW_NUMBER() OVER(ORDER BY @complianceTempId)  
  ,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)  
  ,[TRAN AMOUNT] = dbo.ShowDecimal(trn.cAmt)   
  ,[CURRENCY]  = trn.collCurr   
  ,[TRAN DATE] = CONVERT(VARCHAR,trn.createdDate,101)      
 FROM VWremitTran trn with(nolock)   
 INNER JOIN @tranIdTemp t ON trn.id = t.tranId  
   
 UNION ALL  
 ---- RECORD DISPLAY FROM CANCEL TRANSACTION TABLE  
 SELECT   
   [S.N.]   = ROW_NUMBER() OVER(ORDER BY @complianceTempId)  
  ,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)  
  ,[TRAN AMOUNT] = dbo.ShowDecimal(trn.cAmt)   
  ,[CURRENCY]  = trn.collCurr   
  ,[TRAN DATE] = CONVERT(VARCHAR,trn.createdDate,101)      
 FROM cancelTranHistory trn with(nolock)  
 INNER JOIN @tranIdTemp t ON trn.id = t.tranId  
END  
  
ELSE IF @FLAG = 'search-cust-by'  
BEGIN  
 SELECT [VALUE] = 'name', [TEXT] = 'Name' UNION ALL  
 SELECT [VALUE] = 'membershipId', [TEXT] = 'Membership ID' UNION ALL  
 --SELECT [VALUE] = 'customerId', [TEXT] = 'Old Customer ID' UNION ALL  
 SELECT [VALUE] = 'mobile', [TEXT] = 'Mobile No' UNION ALL  
 SELECT [VALUE] = 'email', [TEXT] = 'Email ID' UNION ALL  
 SELECT [VALUE] = 'dob', [TEXT] = 'DOB' UNION ALL  
 SELECT [VALUE] = 'idNumber', [TEXT] = 'ID Number'   
END 
ELSE IF @FLAG = 'addReceiver'  
BEGIN  
 SELECT [VALUE] = 'receiverName', [TEXT] = 'Receiver Name'   
END  
  
ELSE IF @FLAG = 'idIssuedCountry'  
BEGIN  
 SELECT countryId, countryName   
 FROM countryMaster (NOLOCK)    
 WHERE ISNULL(isActive, 'Y') = 'Y'  
 ORDER BY countryName ASC  
END  
  
ELSE IF @FLAG = 'receiverDataBySender'  
BEGIN  
	DECLARE @BRANCHDETAILS VARCHAR(100), @PAYERDETAILS VARCHAR(250), @MANUALTYPE CHAR(1), @pState INT, @pDistrict INT
	SELECT @BRANCHDETAILS = CASE WHEN R.PCOUNTRY IN ('Nepal', 'Vietnam') THEN pBankBranchName
									ELSE CAST(A.BRANCH_ID AS VARCHAR) + '|' + A.BRANCH_NAME + ' - ' + A.BRANCH_CODE1 END
			, @MANUALTYPE = CASE WHEN R.PCOUNTRY IN ('Nepal', 'Vietnam') THEN 'Y' ELSE 'N' END
			, @PAYERDETAILS = CAST(R.PayerId AS VARCHAR) + '|' + AP.PAYER_NAME + ' - ' + AP.BRANCH_ADDRESS
			, @pState = R.pstate
			, @pDistrict = R.pdistrict
	FROM REMITTRAN R(NOLOCK)
	INNER JOIN TRANRECEIVERS REC(NOLOCK) ON REC.TRANID = R.ID
	LEFT JOIN API_BANK_BRANCH_LIST A(NOLOCK) ON A.BRANCH_ID = R.PBANKBRANCH
	LEFT JOIN PAYER_BANK_DETAILS AP(NOLOCK) ON AP.PAYER_ID = R.PayerId
	WHERE 1=1
	--AND R.PCOUNTRY = 'INDIA'
	AND REC.CUSTOMERID = @RECEIVERID
	ORDER BY R.ID ASC

 SELECT  receiverId,  
   firstName,   
   middleName,   
   lastName1,   
   idType,   
   idNumber,   
   gender = '',   
   [address],   
   city,   
   mobile,   
   homePhone,   
   email,  
   country,  
   paymentMode,  
   ABL.BANK_NAME bankName,  
   ABL.BANK_ID bankId,   
   abbl.BRANCH_ID branchId,   
   errorCode = 0,   
   msg = 'Success',  
   AM.AGENTID,  
   AM.AGENTNAME,  
   paymentMethod = SM.typeTitle,  
   RI.country,  
   RI.customerId,  
   RI.receiverAccountNo,  
   CM.COUNTRYID,  
   RI.purposeOfRemit,  
   RI.relationship,
   branchDetails = ISNULL(@BRANCHDETAILS, 'N/A'),
   payerDetailsHistory = ISNULL(@PAYERDETAILS, 'N/A'),
   manualType = @MANUALTYPE,
   @pState AS pState,
   @pDistrict AS pDistrict
 FROM RECEIVERINFORMATION RI(NOLOCK)   
 LEFT JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = RI.PAYOUTPARTNER  
 LEFT JOIN SERVICETYPEMASTER SM(NOLOCK) ON SM.SERVICETYPEID = RI.PAYMENTMODE  
 LEFT JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = RI.country  
 LEFT JOIN dbo.API_BANK_LIST ABL (NOLOCK) ON ABL.BANK_ID=ri.payOutPartner  
 LEFT JOIN dbo.API_BANK_BRANCH_LIST abbl ON abbl.BRANCH_ID =CASE ISNUMERIC(ri.bankLocation) WHEN 1 THEN ISNULL(CAST(ri.bankLocation AS BIGINT),0) ELSE 0 END  
 WHERE RECEIVERID = @RECEIVERID  
 AND ISNULL(RI.ISDELETED,0) <> 1
END  
ELSE IF @flag = 'branchByBank'  
BEGIN  
 IF @countryId IN (105, 174, 151)
 BEGIN  
  SELECT 0 agentId,agentName = 'Any Branch'  
  RETURN  
 END  
 --ELSE IF @countryId IN (105, 174) AND @deliveryMethodId = 2  
 --BEGIN  
 -- SET @SQL = '  
 --    SELECT top 50  
	--		agentId = PAYER_ID   
	--		,agentName = PAYER_NAME + '' - '' + BRANCH_ADDRESS--PAYER_BRANCH_NAME
	--FROM PAYER_BANK_DETAILS PD
	--INNER JOIN COUNTRYMASTER CM ON PD.BRANCH_COUNTRY = CM.COUNTRYNAME
 --    WHERE CM.COUNTRYID= ''' + CAST(@countryId AS VARCHAR) + '''  
	-- AND PD.PARTNER_ID = ''' + CAST(@partnerId AS VARCHAR) + '''
	-- AND PD.PAYMENT_MODE = ''' + CAST(@deliveryMethodId AS VARCHAR) + '''
 --    '  
        
 -- IF @param IS NOT NULL  
 --  SET @SQL = @SQL + ' AND (PAYER_BRANCH_NAME LIKE ''%' + @param + '%'' OR BRANCH_ADDRESS LIKE ''%' + @param + '%'')'  
    
 -- SET @SQL = @SQL + ' ORDER BY PAYER_NAME ASC'  
 --END  
 ELSE  
 BEGIN  
  SET @SQL = '  
     SELECT top 50  
       agentId = BRANCH_ID   
      ,agentName = CASE WHEN '''+@countryId+''' <> ''151'' THEN BRANCH_NAME + '' - '' + CAST(BRANCH_CODE1 AS VARCHAR) ELSE BRANCH_NAME END  
     FROM API_BANK_BRANCH_LIST WITH(NOLOCK)  
     WHERE IS_ACTIVE = 1  
     AND BANK_ID = ''' + @agentId + '''  
     '  
        
  IF @param IS NOT NULL  
   SET @SQL = @SQL + ' AND (BRANCH_NAME LIKE ''' + @param + '%'' OR BRANCH_CODE1 LIKE ''' + @param + '%'')'  
    
  SET @SQL = @SQL + ' ORDER BY BRANCH_NAME ASC'  
    
 END  
  
 --print @SQL  
 EXEC(@SQL)  
  
END  
ELSE IF @FLAG = 'LOGIN-BRANCH'
BEGIN
	SELECT agentId, agentName 
	FROM AGENTMASTER 
	WHERE PARENTID = 393877 
	AND ACTASBRANCH = 'Y'
END
ELSE IF @FLAG = 'paymentBy'
BEGIN
	select acct_num [VALUE],acct_name [TEXT] from fastmoneypro_account.dbo.ac_master where acct_num = '100241011536'
	
END
IF @FLAG = 'getBankByCountry'
BEGIN
   SELECT  bankId=AL.BANK_ID ,   
     0 NS,  
     FLAG = 'E',  
     AGENTNAME = AL.BANK_NAME + ' || ' +  AL.BANK_CODE1
   FROM API_BANK_LIST AL(NOLOCK)  
   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
   WHERE CM.COUNTRYID = @pCountryId  
   AND AL.IS_ACTIVE = 1  
   ORDER BY AL.BANK_NAME  
END

GO