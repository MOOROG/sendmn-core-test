USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_sendPageLoadData]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[proc_online_sendPageLoadData] 
	 @flag			VARCHAR(200)
    ,@param			VARCHAR(200)		= NULL
    ,@customerId	VARCHAR(20)			= NULL	
    ,@recId			VARCHAR(20)			= NULL
    ,@param1		VARCHAR(200)		= NULL
    ,@user			VARCHAR(150)		= NULL
    ,@country		VARCHAR(50)			= NULL
    ,@countryId		VARCHAR(10)			= NULL
    ,@countryName   VARCHAR(100)		= NULL
    ,@agentId		VARCHAR(50)			= NULL
    ,@pCountryId	VARCHAR(10)			= NULL
    ,@pCountryName  VARCHAR(100)		= NULL
    ,@sAgent		VARCHAR(100)		= NULL
    ,@sBranch		VARCHAR(100)		= NULL
    ,@rAgent		VARCHAR(100)		= NULL
    ,@sCustomerId	VARCHAR(10)			= NULL
    ,@blackListIds	VARCHAR(MAX)		= NULL
    ,@agentRefId	VARCHAR(20)			= NULL
    ,@deliveryMethodId INT				= NULL
    ,@pBankType			CHAR(1)			= NULL
    ,@complianceTempId	INT				= NULL
	,@csDetailRecId		INT				= NULL
	,@searchType						VARCHAR(50)		= NULL
	,@searchValue						VARCHAR(50)		= NULL
	,@senderId							VARCHAR(50)		= NULL
	,@agentType							VARCHAR(50)		= NULL
	,@locationId						BIGINT			= NULL
	,@pMode								VARCHAR(20)		= NULL
	,@payoutPartner						BIGINT			= NULL
	,@bankId							VARCHAR(30)		= NULL 
	,@partnerId							varchar(20)		= NULL
	,@pLocation							varchar(20)		= NULL

AS

--EXEC proc_Online_sendPageLoadData @flag ='substate', @user = 'pandey.atit@gmail.com', @locationId = null, @country = '151'
SET NOCOUNT ON;
DECLARE @Pcurr VARCHAR(5)
DECLARE @SQL VARCHAR(MAX)

IF @flag = 'state'
BEGIN
	IF @country = '151'
	BEGIN
		SELECT [Key] =Replace(stateName,char(9),''), [Value] = Replace(stateName,CHAR(9),'')  
		FROM dbo.countriesStates rcs WITH(NOLOCK)
		INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode  
		WHERE countryId = @country
		ORDER BY stateName ASC
	END
	ELSE
	BEGIN
	
		IF NOT EXISTS(SELECT 'A' FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @country AND partnerId = @payoutPartner)
		BEGIN
			SELECT [Value] = 'Any State', [Key] = '0' 
			RETURN
		END
		SELECT [Value] = location
				,[Key] = rowId 
		FROM tblServicewiseLocation (NOLOCK) 
		WHERE countryId = @country
		AND partnerId = @payoutPartner
		--AND ISNULL(serviceTypeId, @pMode) = @pMode 
		AND isActive = 1
	END
	
END
ELSE IF @flag = 'bankBranchCountryWise'
BEGIN
	SELECT [Key] = agentId, [Value] = agentName 
	FROM agentMaster A (NOLOCK) 
	WHERE A.agentCountry = @pCountryName
	AND AGENTTYPE = '2904'
	AND parentId = @senderId and isActive = 'Y'
	ORDER BY agentName ASC
END
ELSE IF @flag = 'payoutMethods'
BEGIN
	DECLARE @payoutMethods TABLE ([Key] INT,[Value] VARCHAR(50),DISORDER INT)
	INSERT INTO @payoutMethods([Key],[Value])
	SELECT 
			[Key] = serviceTypeId
		,[Value] = UPPER(typetitle)
	FROM serviceTypeMaster stm WITH (NOLOCK)
	INNER JOIN(
				SELECT 
					receivingMode, maxLimitAmt 
				FROM countryReceivingMode crm WITH(NOLOCK) 
				INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry
				INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYID = SL.COUNTRYID 
				WHERE CM.COUNTRYNAME = @country
				AND SL.agentId IS NULL AND SL.tranType IS NULL AND receivingAgent IS NULL

				UNION ALL
					   
				SELECT 
					receivingMode, maxLimitAmt 
				FROM countryReceivingMode crm WITH(NOLOCK) 
				INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
				INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYID = SL.receivingCountry 
				--WHERE CM.COUNTRYNAME = @country
				WHERE SL.tranType IS  NULL
				AND CM.COUNTRYNAME = @country 
				AND receivingAgent IS NULL
				AND ISNULL(SL.isActive,'N')='Y'
				AND ISNULL(SL.isDeleted,'N')='N'
					  
				UNION ALL
					  
				SELECT tranType, MAX(maxLimitAmt) maxLimitAmt
				FROM sendTranLimit SL WITH (NOLOCK) 
				INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYID = SL.receivingCountry 
				WHERE CM.COUNTRYNAME = @country 
				AND ISNULL(SL.isActive,'N')='Y'
				AND ISNULL(SL.isDeleted,'N')='N'
				AND SL.agentId IS NULL
				AND SL.tranType IS NOT NULL
				AND SL.receivingAgent IS NULL
				GROUP BY tranType
					  
				UNION ALL
					  
				SELECT tranType, MAX(maxLimitAmt) maxLimitAmt
				FROM sendTranLimit SL WITH (NOLOCK)
				INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYID = SL.receivingCountry 
				WHERE CM.COUNTRYNAME = @country 
				AND ISNULL(SL.isActive,'N')='Y'
				AND ISNULL(SL.isDeleted,'N')='N'
				AND receivingAgent IS NULL
				AND SL.tranType IS NOT NULL
				AND SL.receivingAgent IS NULL
				GROUP BY tranType )X ON  X.receivingMode = stm.serviceTypeId
		WHERE ISNULL(STM.isActive,'N') = 'Y' AND ISNULL(STM.isDeleted,'N') = 'N'
		AND (STM.serviceTypeId NOT IN (5))
		--AND (STM.serviceTypeId NOT IN (3,5))
		GROUP BY serviceTypeId,typetitle
		HAVING MIN(X.maxLimitAmt)>0
		--ORDER BY serviceTypeId ASC
		UPDATE @payoutMethods SET DISORDER = CASE WHEN @country in('Bangladesh','MONGOLIA','THAILAND','INDIA','PAKISTAN') AND [Key]=2 THEN 0 ELSE [Key] END
		
		DELETE FROM @payoutMethods WHERE @country IN ('CAMBODIA') AND [Key] = '2'
		--DELETE FROM @payoutMethods WHERE @country='thailand' AND [Key] = '1'

		SELECT [Key],[Value] FROM @payoutMethods ORDER BY DISORDER
END
IF @flag = 'substate'
BEGIN
	IF @country = '151'
	BEGIN
		SELECT [Key] = rcs.rowId, [Value] = Replace(stateName,CHAR(9),'')  
		FROM dbo.countriesStates rcs WITH(NOLOCK)
		INNER JOIN  countryMaster CM (NOLOCK) ON CM.countryName = rcs.countryName
		WHERE CM.countryId = @country

		RETURN
	END	
	ELSE
	BEGIN
		SELECT @payoutPartner = partnerId FROM tblServicewiseLocation (NOLOCK) WHERE ROWID = @locationId
		--TRANGLO SDN. BHD. and country Indonesia have direct sub location defined
		IF @payoutPartner = '224388' AND @country = '105'
		BEGIN
			SELECT [Key] = rowId, [Value] = subLocation 
			FROM tblSubLocation (NOLOCK) 
			WHERE locationId = 0
			AND isActive = 1
			AND partnerId = @payoutPartner
			ORDER BY subLocation ASC			
		
			RETURN
		END

		IF NOT EXISTS(SELECT 'A' FROM tblSubLocation (NOLOCK) WHERE locationId = @locationId)
		BEGIN
			SELECT [Value] = 'Any location',[Key] = '0' 
			RETURN
		END

		SELECT [Key] = rowId, [Value] = subLocation 
		FROM tblSubLocation (NOLOCK) 
		WHERE locationId = @locationId
		AND isActive = 1
		ORDER BY subLocation ASC
		RETURN
	END
	RETURN
END
ELSE IF @flag = 'bankCountryWise'
BEGIN
	IF @country IN ('151')
	BEGIN
		SELECT [Key] = '',[Value] = '[SELECT BANK]' 
		UNION ALL
		SELECT [Key] = CAST(agentId AS VARCHAR), 
				[Value] = agentName
		FROM agentMaster (NOLOCK)
		WHERE AGENTTYPE = '2903' and IsIntl = 1
		AND agentCountryId = @country 
		--AND agentRole = @deliveryMethodId
		AND ISNULL(isActive, 'Y') = 'Y'
		ORDER BY [Value]
	END
	ELSE 
	BEGIN
		SELECT * INTO #TEMPBANKLIST
		FROM (
			SELECT [Key] = '',[Value] = '[SELECT BANK]' 
			UNION ALL
			SELECT distinct [Key] = CAST(agentId AS VARCHAR)
				,[Value] = AGENTNAME + CASE WHEN parentId in (224388,2140,392226) THEN ISNULL(' | ' +AGENTCODE, '') WHEN agentCountryId = 142 THEN ISNULL(' | ' +agentState, '') ELSE '' END
			FROM  AgentMaster(NOLOCK) 
			WHERE AGENTTYPE = '2903' and ISNULL(isSettlingAgent,'') <> 'Y'
			AND agentCountryId = @country AND ISNULL(isActive, 'Y') = 'Y'
			AND ISNULL(agentRole,@deliveryMethodId) = @deliveryMethodId
			AND parentId IN (SELECT AgentId FROM TblPartnerwiseCountry (NOLOCK) WHERE COUNTRYID = @country AND ISNULL(PaymentMethod, @deliveryMethodId) = @deliveryMethodId  AND IsActive = 1)
			
		)X
		IF @country IN ('203') AND @deliveryMethodId NOT IN ('12') ----## ADDING VCBR FOR VIETNAM
		BEGIN
			INSERT INTO #TEMPBANKLIST
			SELECT agentId,agentName FROM agentMaster(NOLOCK) 
			WHERE parentId = 392224 AND
			AGENTTYPE = '2903' and ISNULL(isSettlingAgent,'') <> 'Y'

		END
		ELSE IF @country IN ('16') AND @deliveryMethodId IN ('1','2') ----## ADDING AGRANI BANK LTD/DUTCH BANGLA BANK FOR BANGLADESHF
		BEGIN
			IF @deliveryMethodId IN ('1')
			BEGIN
				INSERT INTO #TEMPBANKLIST
				SELECT agentId,agentName FROM agentMaster(NOLOCK) 
				WHERE agentId in(404527,393940) AND
				AGENTTYPE = '2903' and ISNULL(isSettlingAgent,'') <> 'Y'
			END
			ELSE IF @deliveryMethodId IN ('2') ----## ADDING AGRANI BANK LTD FOR BANGLADESHF
			BEGIN
				INSERT INTO #TEMPBANKLIST
				SELECT agentId,agentName FROM agentMaster(NOLOCK) 
				WHERE agentId = 404527 AND
				AGENTTYPE = '2903' and ISNULL(isSettlingAgent,'') <> 'Y'
			END
		END

		IF @deliveryMethodId NOT IN ('2')
		BEGIN
			DELETE FROM #TEMPBANKLIST WHERE [Value] = '[SELECT BANK]'

			SELECT * FROM #TEMPBANKLIST 
			ORDER BY [Value]

			RETURN
		END

		SELECT * FROM #TEMPBANKLIST
		ORDER BY [Value]

		RETURN
	END	
END
ELSE IF @flag = 'recAgentByRecModeAjaxagent'
	BEGIN	
		if @deliveryMethodId = '1'
              set  @param = 'CASH PAYMENT'
        else if @deliveryMethodId = 2
             set   @param = 'BANK DEPOSIT'
        else
             set   @param = 'DOOR TO DOOR'
		DECLARE @maxPayoutLimit DECIMAL(10,2)

		--SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster(nolock) where typeTitle = @param
		
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
		AND sendingCountry = '131'

		IF @param IN ('CASH PAYMENT', 'DOOR TO DOOR')
		BEGIN
			--IF @PAYOUTPARTNER='394133'
			--BEGIN
			--	SELECT bankId=NULL,AGENTNAME='Select'
			--	UNION ALL
			--	SELECT bankId=Id,AGENTNAME=PAYOUT_NAME FROM dbo.API_PAYOUT_LOACTION (NOLOCK)
			--    RETURN;
			--END

			IF EXISTS(SELECT TOP 1 'A' FROM API_BANK_LIST AP(NOLOCK) 
			INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AP.BANK_COUNTRY
			WHERE CM.COUNTRYID = @pCountryId AND API_PARTNER_ID = @PAYOUTPARTNER AND PAYMENT_TYPE_ID IN (1, 12, 0))
			BEGIN
				SELECT [Key]  = '', 0 NS,FLAG = 'E',[Value] = '[SELECT CASH OUT LOCATION]' ,maxPayoutLimit = 0
				
				UNION ALL

				SELECT [Key]=AL.BANK_ID, 0 NS,FLAG = 'E',[Value] = AL.BANK_NAME,maxPayoutLimit = @maxPayoutLimit
				FROM API_BANK_LIST AL(NOLOCK)
				INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY
				WHERE CM.COUNTRYID = @pCountryId
				AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)
				AND AL.IS_ACTIVE = 1
				AND AL.API_PARTNER_ID = @PAYOUTPARTNER
				--ORDER BY AL.BANK_NAME
			END
			ELSE
			BEGIN
				SELECT [Key] = '', 0 NS,FLAG = 'E',[Value] = '[ANY WHERE]',maxPayoutLimit = @maxPayoutLimit
			END
		END	
		ELSE IF @param = 'BANK DEPOSIT'
		BEGIN
			SELECT * FROM 
			(
				SELECT [Key] = '', 0 NS,FLAG = 'E',[Value] = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit
				UNION ALL
				SELECT [Key]=AL.BANK_ID, 0 NS,FLAG = 'E',[Value] = AL.BANK_NAME,maxPayoutLimit = @maxPayoutLimit
				FROM API_BANK_LIST AL(NOLOCK)
				INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY
				WHERE CM.COUNTRYID = @pCountryId
				AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)
				AND AL.IS_ACTIVE = 1
				AND AL.API_PARTNER_ID = @PAYOUTPARTNER
			)X
			ORDER BY X.Value
			RETURN
		END	
		ELSE
		BEGIN
			SELECT [key]=AL.BANK_ID, 
					0 NS,
					FLAG = 'E',
					[Value] = AL.BANK_NAME,
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
ELSE IF @flag = 'countryCurrency'
BEGIN
	IF @country = '203'
	BEGIN
		IF @deliveryMethodId = '1' AND @agentId IN('2091','2093','2121')
		BEGIN
			SELECT [Key] = 1 , [Value] = 'VND' UNION ALL
			SELECT [Key] = 0 , [Value] = 'USD'
		END
		ELSE IF @deliveryMethodId = '12'
		BEGIN
			SELECT [Key] = 1 , [Value] = 'VND' UNION ALL
			SELECT [Key] = 0 , [Value] = 'USD'
		END
		ELSE
		BEGIN
			SELECT [Key] = 1 , [Value] = 'VND'
		END
		RETURN
	END
	ELSE IF @country = '42'
	BEGIN
		IF @agentId IN (221297,221281)
		BEGIN
			SELECT [Key] = 1 , [Value] = 'LKR'
			RETURN
		END
		IF @deliveryMethodId = '2'

		BEGIN
			SELECT [Key] = 1 , [Value] = 'LKR' UNION ALL
			SELECT [Key] = 0 , [Value] = 'USD'
		END
		ELSE
		BEGIN
			SELECT [Key] = 1 , [Value] = 'LKR'
		END
		RETURN
	END
	ELSE IF @country = '142' AND @deliveryMethodId = '1'
	BEGIN
		SELECT [Key] = 1 , [Value] = 'USD'
		RETURN
	END
	SELECT [Key] = case when isnull(isDefault, 'Y') = 'Y' then 1 else 0 end , [Value] = CM.currencyCode
	FROM countryCurrency a(NOLOCK) 
	inner join currencyMaster cm(nolock) on cm.currencyId = a.currencyId
	where ISNULL(a.isActive, 'Y')  = 'Y' AND ISNULL(a.isDeleted, 'N') = 'N'
	and a.countryId = @COUNTRY
	RETURN
END
ELSE IF @flag = 'receiverList'
BEGIN
	SELECT [Key] = receiverId , [Value] = firstName +ISNULL(' '+middleName, '') + ISNULL(' '+lastName1, '') +ISNULL(' '+lastName2, '')
	FROM receiverInformation (NOLOCK) 
	WHERE customerId = @customerId 
	AND country = @country
	RETURN
END
ELSE IF @flag = 'receiverCountryAll'
BEGIN
	----SELECT 
	----	countryId,
	----	countryName	INTO #TEMPCOUNTRYLIST
	----FROM countryMaster CM WITH (NOLOCK)
	----INNER JOIN 
	----(
	----	SELECT  receivingCountry,min(maxLimitAmt) maxLimitAmt
	----	FROM(
	----			SELECT   receivingCountry,max (maxLimitAmt) maxLimitAmt
	----			FROM sendTranLimit SL WITH (NOLOCK) 
	----			WHERE ISNULL(isActive,'N')='Y'
	----			AND ISNULL(isDeleted,'N')='N'
	----			GROUP BY receivingCountry
				
	----			UNION ALL
				
	----			SELECT    receivingCountry,max (maxLimitAmt) maxLimitAmt
	----			FROM sendTranLimit SL WITH (NOLOCK) 
	----			WHERE ISNULL(isActive,'N')='Y'
	----			AND ISNULL(isDeleted,'N')='N'
	----			GROUP BY receivingCountry  
                 
	----	) x GROUP  BY receivingCountry
	----) Y ON  Y.receivingCountry=CM.countryId
	----WHERE ISNULL(isOperativeCountry,'') ='Y'
	----AND Y.maxLimitAmt>0

	SELECT distinct
		cm.countryId,
		concat(cm.countryName,'(',cm.countryCode,')') as countryName	INTO #TEMPCOUNTRYLIST 
	FROM countryMaster CM WITH (NOLOCK)
	INNER JOIN  tblPartnerwiseCountry(nolock) c on c.countryid = cm.countryId
	WHERE c.IsActive = 1

	ALTER TABLE #TEMPCOUNTRYLIST ADD isNativeCountry CHAR(1)
	
	UPDATE #TEMPCOUNTRYLIST SET isNativeCountry = 'N'

	UPDATE T SET T.isNativeCountry = 'Y'
	FROM #TEMPCOUNTRYLIST T
	INNER JOIN customerMaster CM(NOLOCK) ON CM.nativeCountry = T.countryId
	WHERE CM.email = @user

	SELECT * FROM #TEMPCOUNTRYLIST ORDER BY countryName
	RETURN
END
ELSE IF @flag = 'receiverCountry'						-- CountryName List
BEGIN
	SET @SQL = 
		'SELECT [Key] = CAST(countryId AS VARCHAR), [Value] = countryName FROM COUNTRYMASTER (NOLOCK) WHERE countryName = '''+@country+'''
		UNION ALL
		SELECT [Key] = CAST(countryCode AS VARCHAR), [Value] = ''countryCode'' FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYNAME = '''+@country+''''

	--SET @SQL +=  
	--	CASE WHEN @country IN ('Indonesia', 'Pakistan', 'China', 'Cambodia') AND @payoutPartner = 221233
	--			THEN	' UNION ALL 
	--					SELECT [Key] = CAST(1 AS VARCHAR), [Value] = ''isAccValidate'''
	--			ELSE	' UNION ALL 
	--					SELECT [Key] = CAST(0 AS VARCHAR), [Value] = ''isAccValidate'''
	--		END

	--PRINT(@SQL)
	EXEC(@SQL)
	
	RETURN	
END
ELSE IF @flag='loadReceiverByCusId'
BEGIN
	SELECT  rec.firstName + ISNULL(' ' + rec.middleName,'')+ ISNULL(' ' + rec.LastName1,rec.lastName2)  AS fullName
			,COALESCE(mobile,homePhone,workPhone) AS mobileNumber, rec.country , rec.relationship,receiverId, CM.COUNTRYID
	FROM receiverInformation rec WITH(NOLOCK) 
	INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = REC.country
	WHERE customerId = @customerId
END
ELSE IF @flag='receiverDetailById'
BEGIN
	 SELECT firstName+isnull(' '+ middleName,' ')+isnull(' '+lastName1,'') [receiverName]
		  ,firstName
		  ,receiverId
		  ,isnull(' '+ middleName,' ') [middleName]
		  ,isnull(' '+lastName1,'')  [lastName1]
		  ,isnull(' '+lastName2,'')  [lastName2]
		,address
		,city	
		,country = CM.countryId
		,COALESCE(homePhone,workPhone) [phone]
		,mobile 
		,email 
		,relationship
		,[state]
		,StateId = CASE WHEN RI.COUNTRY = 'NEPAL' THEN cs.rowId ELSE TL.rowId END
		,district
	FROM receiverInformation ri WITH(NOLOCK)  
	LEFT JOIN countriesStates cs (NOLOCK) ON cs.stateName = ri.state 
	LEFT JOIN tblServicewiseLocation TL (NOLOCK) ON TL.location = ri.state
	LEFT JOIN tblSubLocation TS(NOLOCK) ON TS.subLocation = ri.district
	INNER JOIN countryMaster CM (NOLOCK) ON CM.countryName = RI.country
	WHERE receiverId = @param
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
				receivingMode, maxLimitAmt 
			FROM countryReceivingMode crm WITH(NOLOCK) 
			INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
			WHERE SL.countryId = @countryId AND SL.receivingCountry = ISNULL(@pcountryId, SL.receivingCountry)
			AND SL.agentId IS NULL AND SL.tranType IS NULL AND receivingAgent IS NULL
			
			UNION ALL
					   
			SELECT 
				receivingMode, maxLimitAmt 
			FROM countryReceivingMode crm WITH(NOLOCK) 
			INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
			AND SL.receivingCountry = ISNULL(@pcountryId, SL.receivingCountry) AND SL.countryId = @countryId 
			WHERE agentId = @agentId
			AND SL.tranType IS  NULL
			AND receivingAgent IS NULL
			AND ISNULL(isActive,'N')='Y'
			AND ISNULL(isDeleted,'N')='N'			 
					  
			UNION ALL
			  
			SELECT tranType, MAX(maxLimitAmt) maxLimitAmt
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
			  
			SELECT tranType, MAX(maxLimitAmt) maxLimitAmt
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
		) pt
	   ON  pt.receivingMode = stm.serviceTypeId
	   WHERE ISNULL(STM.isActive,'N')='Y' AND ISNULL(STM.isDeleted,'N')='N'
	   GROUP BY serviceTypeId,typetitle
	   HAVING MIN(pt.maxLimitAmt)>0
	   ORDER BY typeTitle ASC

END

IF @flag = 'recModeByCountry'			
BEGIN
	SELECT @Pcurr = currencyCode FROM currencyMaster CM(nolock)
	INNER JOIN countryCurrency CC ON CM.currencyId = CC.currencyId
	WHERE CC.countryId = @pCountryId
        	
		SELECT 
			 serviceTypeId
			,UPPER(typetitle) typeTitle
			,MIN(maxLimitAmt) maxLimitAmt
			,pCurr			= @Pcurr
	   FROM serviceTypeMaster stm WITH (NOLOCK)
	   INNER JOIN (
					SELECT 
						receivingMode, maxLimitAmt 
					FROM countryReceivingMode crm WITH(NOLOCK) 
					INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
					WHERE SL.countryId = @countryId AND SL.receivingCountry = @pcountryId
					AND SL.agentId IS NULL AND SL.tranType IS NULL AND receivingAgent IS NULL AND ISNULL(applicableForSA, 'A') = 'A'

					UNION ALL
					   
					SELECT 
						receivingMode, maxLimitAmt 
					FROM countryReceivingMode crm WITH(NOLOCK) 
					INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
					AND SL.receivingCountry = @pcountryId AND SL.countryId = @countryId 
					WHERE agentId IS NULL
					AND SL.tranType IS  NULL
					AND receivingAgent IS NULL AND ISNULL(applicableForSA, 'A') = 'S'
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
					AND SL.agentId IS NULL
					AND ISNULL(isActive,'N')='Y'
					AND ISNULL(isDeleted,'N')='N'
					AND receivingAgent IS NULL
					AND SL.tranType IS NOT NULL
					AND SL.receivingAgent IS NULL
					GROUP BY tranType 
			   ) X
	   ON  X.receivingMode = stm.serviceTypeId
	   WHERE ISNULL(STM.isActive,'N') = 'Y' AND ISNULL(STM.isDeleted,'N') = 'N'
	   AND (STM.serviceTypeId NOT IN (3,5))
	   GROUP BY serviceTypeId,typetitle
	   HAVING MIN(X.maxLimitAmt)>0
	   ORDER BY serviceTypeId ASC
END

ELSE IF @flag = 'sCountry'						-- CountryName List
BEGIN
	SELECT 
		countryId,
		countryName
	FROM countryMaster(nolock) Where isnull(isOperativeCountry,'') ='Y'
	AND countryName <>'Worldwide Others'
	ORDER BY countryName ASC
	RETURN
END

ELSE IF @flag = 'loadState1'						-- CountryName List
BEGIN
	SELECT StateName, rowId AS StateId
	FROM dbo.countriesStates CS (NOLOCK)
	INNER JOIN dbo.countryMaster CM (NOLOCK) ON CM.countryName = CS.countryName
	WHERE CM.countryId = @countryId
END

ELSE IF @flag = 'pCountry'						-- CountryName List
BEGIN
	/*

	 EXEC proc_Online_sendPageLoadData @flag='pCountry',@countryId='233',@agentid='1040'

	*/
	

	 SELECT 
	    countryId,
	    countryName
		   FROM countryMaster CM WITH (NOLOCK)
	    INNER JOIN (
	SELECT  receivingCountry,min(maxLimitAmt) maxLimitAmt
	FROM( 
			  SELECT    
				receivingCountry,max (maxLimitAmt)maxLimitAmt
			  FROM sendTranLimit SL WITH (NOLOCK) 
			  WHERE countryId=@countryId
			  AND ISNULL(isActive,'N')='Y'
			  AND ISNULL(isDeleted,'N')='N'
			  GROUP BY receivingCountry  
                 
	) x GROUP  BY receivingCountry
	    ) Y
		   ON  Y.receivingCountry=CM.countryId
		   WHERE ISNULL(isOperativeCountry,'') ='Y'
		   AND Y.maxLimitAmt>0
		   ORDER BY countryName ASC


	RETURN
END

---------------ONLY FOR AJAX DDL
--ELSE IF @flag = 'recAgentByRecModeAjaxagent'
--BEGIN

--	CREATE TABLE #tempAgentList(sn INT, flag CHAR(1), agentId VARCHAR(50), agentName VARCHAR(100), maxPayoutLimit VARCHAR(30))
--	INSERT INTO #tempAgentList(sn, flag, agentId, agentName, maxPayoutLimit)
--	EXEC dbo.proc_sendPageLoadData @flag = 'recAgentByRecModeAjaxagent', @countryId = @countryId, @agentId = @agentId, @pCountryId = @pCountryId
--	, @param = @param, @user = @user
		
--	UPDATE #tempAgentList SET
--			agentId = agentId + '|' + flag --+ '|' + maxPayoutLimit
		
--	SELECT * FROM #tempAgentList
		
--	RETURN
--END
--Load Bank
	ELSE IF @flag = 'recAgentByRecModeAjaxagent'
	BEGIN		
		DECLARE @serviceTypeId int
		SELECT @serviceTypeId = serviceTypeId FROM serviceTypeMaster WITH (NOLOCK) WHERE typeTitle = @param

		DECLARE @maxPayoutLimitAmt VARCHAR(20), @payoutLimCurr VARCHAR(3)
		SELECT @maxPayoutLimitAmt = dbo.ShowDecimal(maxLimitAmt) + ISNULL(' ' + currency, ''), @payoutLimCurr = currency 
		FROM dbo.FNAGetPayoutLimit(@countryId, @pCountryId, @agentId, @serviceTypeId)
		IF @param = 'CASH PAYMENT'
		BEGIN
		    SELECT DISTINCT TOP 1  SN = 0,
						 FLAG			= 'I'
						,AGENTID		= NULL
						,AGENTNAME		= '[Any Where]' 
						,maxPayoutLimit	= dbo.ShowDecimal(RTL.maxLimitAmt) +' '+ @payoutLimCurr
					FROM receiveTranLimit RTL WITH(NOLOCK)  
					INNER JOIN countryReceivingMode CRM WITH(NOLOCK) ON RTL.COUNTRYID = CRM.COUNTRYID
					WHERE RTL.countryId = CAST(@pcountryId AS VARCHAR)
					AND RTL.sendingCountry = ISNULL(@countryId, RTL.sendingCountry)
					AND ISNULL(RTL.isActive, 'N') = 'Y'
					AND ISNULL(RTL.isDeleted, 'N') = 'N'
					AND CRM.countryId = CAST(@pcountryId AS VARCHAR)
					AND RTL.agentId IS NULL

			RETURN
		END
		ELSE 
		BEGIN
		    

			SELECT 0 NS,FLAG = 'I',AGENTID,AGENTNAME
				,maxPayoutLimit = @maxPayoutLimitAmt
			FROM agentMaster a(NOLOCK) 
			where IsIntl  = 1 AND AGENTTYPE='2903'
			AND  A.AGENTCOUNTRYID = CAST(@pcountryId AS VARCHAR)
			and isActive='Y'
			ORDER BY AGENTNAME 
			
			RETURN
		END
		
	END


ELSE IF @flag = 'agentsetting'
BEGIN
	--SELECT * FROM receiveTranLimit WITH(NOLOCK)
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
			,relationshipReq		= ''
			,benificiaryContactReq
			,acLengthFrom
			,acLengthTo
			,acNumberType
		FROM receiveTranLimit WITH(NOLOCK)
		WHERE rtlId = @rtlId
	END
	ELSE IF @pBankType = 'E'
	BEGIN
		--SELECT * FROM externalBank
		SELECT
			 maxLimitAmt			= ''
			,agMaxLimitAmt			= ''
			,branchSelection		= IsBranchSelectionRequired
			,benificiaryIdReq		= ''
			,relationshipReq		= ''
			,benificiaryContactReq	= ''
			,acLengthFrom			= ''
			,acLengthTo				= ''
			,acNumberType			= ''
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
			,relationshipReq		= ''
			,benificiaryContactReq
			,acLengthFrom
			,acLengthTo
			,acNumberType
		FROM receiveTranLimit WITH(NOLOCK)
		WHERE rtlId = @rtlId
	END
END

ELSE IF @flag = 'branchAjax'
BEGIN
	--SELECT * FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NOT NULL
	DECLARE @branchSelection VARCHAR(50)
	SELECT @branchSelection = ISNULL(branchSelection,'A')  FROM receiveTranLimit WITH (NOLOCK) WHERE agentId = @agentId
	
	SELECT @branchSelection [branchSelection]
	RETURN
	
	----SELECT
	----	agentId [serviceTypeId],
	----	agentName [typeTitle],@branchSelection [branchSelection]
	----FROM agentMaster am WITH(NOLOCK)
	----WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	----AND am.agentType = '2904'
	----AND am.parentId = @agentId
	----ORDER BY agentName ASC
	----RETURN	
END
ELSE IF @flag = 'ReceiverByTranNo'
BEGIN
	SELECT TOP 1
			 receiverName			= ReceiverName
			,rCustomerId			= CustomerId
			,receiverCountry		= UPPER(ReceiverCountry)
			,receiverAddress		= ReceiverAddress
			,receiverCity			= receiverCity
			,receiverEmail			= ''
			,receiverPhone			= ReceiverPhone	 
			,receiverMobile		= receiver_mobile
			,receiverIDDescription	= ReceiverIDDescription
			,ReceiverID			= ReceiverID
		FROM customerTxnHistory WITH(NOLOCK)
		WHERE tranNo = @param
END
ELSE IF @flag = 'lastReceiver'   -- select all receiver and display last receiver at first
BEGIN
	
	SELECT @param = mobile, @param1 = fullName ,@sCustomerId = idNumber  FROM customers WITH(NOLOCK) WHERE customerId = @sCustomerId
	
	DECLARE @receiverName VARCHAR(200), @rCustomerId VARCHAR(20), @receiverCountry VARCHAR(100), @receiverAddress VARCHAR(200), @receiverCity VARCHAR(100),
		@receiverEmail VARCHAR(100), @receiverPhone VARCHAR(50), @receiverMobile VARCHAR(50), @receiverIDDescription VARCHAR(50), @receiverID VARCHAR(30)

		SELECT TOP 1
			 @receiverName			= ReceiverName
			,@rCustomerId			= CustomerId
			,@receiverCountry		= UPPER(ReceiverCountry)
			,@receiverAddress		= ReceiverAddress
			,@receiverCity			= receiverCity
			,@receiverEmail			= ''
			,@receiverPhone			= ReceiverPhone	 
			,@receiverMobile		= receiver_mobile
			,@receiverIDDescription	= ReceiverIDDescription
			,@ReceiverID			= ReceiverID
		FROM customerTxnHistory WITH(NOLOCK)
		WHERE 1=1 and (sender_mobile = @param OR senderPassport = @sCustomerId)
		AND SenderName = @param1
		ORDER BY tranNo DESC
	
	
		SELECT 
			 id						= ms.tranNo
			,receiverName			= ms.ReceiverName 
			,rCustomerId			= @rCustomerId			
			,receiverCountry		= @receiverCountry		
			,receiverAddress		= @receiverAddress		
			,receiverCity			= @receiverCity			
			,receiverEmail			= @receiverEmail			
			,receiverPhone			= @receiverPhone			
			,receiverMobile			= @receiverMobile		
			,receiverIDDescription	= @receiverIDDescription	
			,ReceiverID				= @ReceiverID			
		FROM customerTxnHistory ms WITH(NOLOCK)
		WHERE 1=1 and (sender_mobile = @param OR senderPassport = @sCustomerId)
		AND SenderName = @param1
	
	
END
ELSE IF @flag = 'senderDetailById'
BEGIN
	SELECT 
		membershipId
		,email
		,fullName
		,city
		,C.country
		,CM.countryName
		,CN.countryName AS nativCountry
		,idType
		,idNumber
		,idExpiryDate
		,homePhone
		,mobile	 
		,HouseNo = null
		,StreetName = null
	FROM customers C(nolock)
	INNER JOIN countryMaster CM(nolock) ON C.country = CM.countryId
	LEFT JOIN countryMaster CN(nolock) ON C.nativeCountry = CN.countryId
	WHERE customerId = 21
END
ELSE IF @flag = 'loadOccupation'
BEGIN
	SELECT occupationId,detailTitle
	FROM occupationMaster WITH (NOLOCK) 
	WHERE ISNULL(isActive,'Y')='Y' AND ISNULL(isDeleted,'N')<>'Y'
END
ELSE IF @flag = 'loadRelation'
BEGIN
	SELECT valueId,detailTitle 
	FROM staticdatavalue(nolock) where typeid='2100' order by detailTitle
END

ELSE IF @flag = 'loadState'
BEGIN
	SELECT valueId,detailTitle 
	FROM staticdatavalue(nolock) where typeid='3' order by detailTitle
END

ELSE IF @flag = 'idTypeBySCountry' -- 
BEGIN
	--SELECT countryId FROM applicationUsers WITH (NOLOCK) WHERE userName = 'Medan1'
	SELECT 
		 valueId		= CAST(SV.valueId AS VARCHAR) + '|' + ISNULL(CID.expiryType, 'E')
		,detailTitle	= SV.detailTitle
		,expiryType	= CID.expiryType
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

ELSE IF @flag = 'agentByExtAgent'				--Get Principle Agent By External Agent
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
	
	/*
	SELECT
		 am.agentId
		,am.agentName
	FROM agentMaster am WITH(NOLOCK)
	INNER JOIN ExternalBankCode ebc WITH(NOLOCK) ON am.agentId = ebc.agentId
	WHERE extBranchId = @param 
	AND ISNULL(am.isActive, 'N') = 'Y' 
	AND ISNULL(ebc.isDeleted, 'N') = 'N'
	*/
END

ELSE IF @flag = 'payoutLimitInfo'
BEGIN
	--EXEC proc_sendPageLoadData @flag = 'payoutLimitInfo', @user = 'alorstar', @countryId = '133', @pCountryId = '151', @rAgent = '0', @deliveryMethodId = 1
	--SELECT * FROM receiveTranLimit
	--6. Payout Per Txn Limit------------------------------------------------------------------------------------------------------
	--SELECT * FROM receiveTranLimit
	
	--SELECT * FROM countryCurrency
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
	SELECT maxLimitAmt FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId
END

ELSE IF @flag = 'ofac'
BEGIN
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
			,@ROW_ID AS INT=1
			,@ofacKeyId VARCHAR(100)
			,@SDN VARCHAR(MAX)=''
			,@ADDRESS VARCHAR(MAX)=''
			,@REMARKS AS VARCHAR(MAX)=''
			,@ALT AS VARCHAR(MAX)=''
			,@DATA AS VARCHAR(MAX)=''
			,@DATA_SOURCE AS VARCHAR(200)=''
	
	SELECT @MAX_ROW_ID=MAX(ROWID) FROM #tempMaster	
	WHILE @MAX_ROW_ID >=  @ROW_ID
	BEGIN	
		
		SELECT @ofacKeyId=ofacKeyId FROM #tempMaster WHERE ROWID=@ROW_ID		

		SELECT @SDN='<b>'+ISNULL(entNum,'')+'</b>,  <b>Name:</b> '+ ISNULL(name,''),@DATA_SOURCE='<b>Data Source:</b> '+ISNULL(dataSource,'')
		FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType IN ('Entity','FKA','AKA','Individual')	
		
		SELECT @ADDRESS=ISNULL(name,'')+', '+ISNULL(address,'')+', '+ISNULL(city,'')+', '+ISNULL(STATE,'')+', '+ISNULL(zip,'')+', '+ISNULL(country,'')
		FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='add'
		
		SELECT @ALT = COALESCE(@ALT + ', ', '') +CAST(ISNULL(NAME,'') AS VARCHAR(MAX))
		FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType IN ('alt')			
				
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
		,[S.N.]		= ROW_NUMBER()OVER(ORDER BY id)	
		,[Remarks]	= RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' + 
						CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
							 WHEN checkType = 'Count' THEN 'Transaction Count' END
						+ ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)   
		,[Matched Tran ID] = rtc.matchTranId
	FROM remitTranComplianceTemp rtc (nolock)
	INNER JOIN csDetailRec cdr(nolock) ON rtc.csDetailTranId = cdr.csDetailRecId 
	WHERE rtc.agentRefId = @agentRefId
END

ELSE IF @flag='COMPL_DETAIL'
BEGIN
/*
5000	By Sender ID
5001	By Sender Name
5002	By Sender Mobile
5003	By Beneficiary ID
5004	By Beneficiary ID(System)
5005	By Beneficiary Name
5006	By Beneficiary Mobile
5007	By Beneficiary A/C Number
*/
	--SELECT * FROM remitTranComplianceTemp
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
		 REMARKS	= CASE WHEN @csDetailRecId = 0 THEN @reason ELSE
						RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' + 
						CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
							 WHEN checkType = 'Count' THEN 'Transaction Count' END
						+ ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' day(s) ' + dbo.FNAGetDataValue(criteria)+': <font size=''2px''>'+ISNULL(@criteriaValue,'')+'</font>'
						END
		,totTran	= 'Total Count: <b>'+ CASE WHEN @csDetailRecId = 0 THEN '1' ELSE  CAST(@totalTran AS VARCHAR) END +'</b>'
	FROM csDetailRec with(nolock)
	WHERE csDetailRecId= CASE WHEN @csDetailRecId = 0 THEN 1 ELSE @csDetailRecId END

	SELECT 
		 [S.N.]			= ROW_NUMBER() OVER(ORDER BY @complianceTempId)
		,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)
		,[TRAN AMOUNT]	= dbo.ShowDecimal(trn.cAmt) 
		,[CURRENCY]		= trn.collCurr 
		,[TRAN DATE]	= CONVERT(VARCHAR,trn.createdDate,101)  		
	FROM VWremitTran trn with(nolock) 
	INNER JOIN @tranIdTemp t ON trn.id = t.tranId
	
	UNION ALL
	---- RECORD DISPLAY FROM CANCEL TRANSACTION TABLE
	SELECT 
		 [S.N.]			= ROW_NUMBER() OVER(ORDER BY @complianceTempId)
		,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)
		,[TRAN AMOUNT]	= dbo.ShowDecimal(trn.cAmt) 
		,[CURRENCY]		= trn.collCurr 
		,[TRAN DATE]	= CONVERT(VARCHAR,trn.createdDate,101)  		
	FROM cancelTranHistory trn with(nolock)
	INNER JOIN @tranIdTemp t ON trn.id = t.tranId
END

ELSE IF @flag = 'collMode'
BEGIN
	DECLARE @collMode VARCHAR(50)
	
	SELECT @collMode = SV.detailTitle FROM agentbusinessfunction ABF WITH(NOLOCK)
	LEFT JOIN staticDataValue SV WITH (NOLOCK) ON ABF.defaultDepositMode = SV.valueId
	WHERE ISNULL(isDeleted,'N') <> 'Y' AND ABF.agentId = @agentId
	
	IF @collMode IS NULL
	BEGIN
		SELECT detailTitle VAL,detailDesc TXT FROM staticDataValue WITH(NOLOCK) WHERE typeID=2200
	END
	ELSE
	BEGIN
		SELECT @collMode val,@collMode txt
	END
	
END


ELSE IF @flag = 'branchByBank'
BEGIN
	IF NOT EXISTS(SELECT 1 FROM agentMaster (NOLOCK) WHERE parentId = @senderId)
	BEGIN
		SELECT  
			AgentId = '0'
			,AgentName	= 'Any Branch'
			,AgentAddress	= ''
			,AgentCity	= ''
			,AgentPhone1	= ''
			,AgentState	= ''
			,ExtCode = ''
	END
	
	IF @agentType = 'I'
	BEGIN
		SET @SQL = '
					SELECT top 50
						 AgentId 
						,AgentName = CASE WHEN '''+@pCountryName+''' <> ''Nepal'' THEN AgentName + '' - '' + CAST(agentCode AS VARCHAR) ELSE AgentName END
						,AgentAddress
						,AgentCity				= ISNULL(agentCity,'''') 
						,AgentPhone1			= ISNULL(agentPhone1 ,'''') 
					    ,AgentState				= ISNULL(agentState, '''') 
					    ,ExtCode				= ISNULL(extCode, '''') 
					FROM agentMaster WITH(NOLOCK)
					WHERE ISNULL(isDeleted, ''N'') = ''N''
						AND agentType = ''2904''
						AND parentId = ''' + @senderId + '''
					'
						
		IF @searchValue IS NOT NULL
			SET @SQL = @SQL + ' AND (AgentName LIKE ''' + @searchValue + '%'' OR agentCode LIKE ''' + @searchValue + '%'')'
		
		SET @SQL = @SQL + ' ORDER BY agentName ASC'
		
	END
	
	--print @SQL
	EXEC(@SQL)

END

ELSE IF @flag = 'rState'
BEGIN
	SELECT value =Replace(stateName,char(9),''), [text] = Replace(stateName,CHAR(9),'')  FROM dbo.countriesStates rcs WITH(NOLOCK)
	INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode  WHERE countryId = @countryId
END

ELSE IF @flag = 'receiveCountry'
BEGIN
	select countryId from countrymaster(nolock)
	where countryId=@country

	
	return;
END

ELSE IF @flag = 'banklist'
BEGIN
	SELECT value=rowId, text=bankName,bankCode FROM vwBankLists bl(nolock)
END

ELSE IF @flag ='getAddress'
BEGIN
	SELECT postalCode, address FROM dbo.customerMaster(nolock) WHERE ISNULL(onlineUser,'N') = 'Y' 
END

ELSE IF @flag='loadReceiverById'
BEGIN
	SELECT firstName,ISNULL(middleName,'') AS middleName,
		   COALESCE(lastName1,lastName2,'') AS lastName,state,
		   city,address,country,cm.countryId,relationship,sdv.valueId AS relationshipId,recInfo.idtype,recInfo.IdNumber,
		   COALESCE(mobile,homePhone,workPhone) AS mobileNumber, ISNULL(email,'') AS email
	FROM receiverInformation  recInfo (NOLOCK)  
	LEFT JOIN staticDataValue sdV (NOLOCK) ON recInfo.relationship =  sdV.detailTitle 
	LEFT JOIN countryMaster cm (NOLOCK) ON recInfo.country = cm.countryName
	WHERE receiverId = @recId
	
END
ELSE IF @flag='ReceiverDataStateCityById'
BEGIN
	
	SELECT firstName,ISNULL(middleName,'') AS middleName,
		   COALESCE(lastName1,lastName2,'') AS lastName,state,
		   city,address,country,cm.countryId,relationship,sdv.valueId AS relationshipId,recInfo.idtype,recInfo.IdNumber,
		   COALESCE(mobile,homePhone,workPhone) AS mobileNumber, ISNULL(email,'') AS email
	FROM receiverInformation  recInfo (NOLOCK)  
	LEFT JOIN staticDataValue sdV (NOLOCK) ON recInfo.relationship =  sdV.detailTitle 
	LEFT JOIN countryMaster cm (NOLOCK) ON recInfo.country = cm.countryName
	WHERE receiverId = @recId

	declare @rcountryName varchar(20),@stateId int
	select @rcountryName = country,@stateId = state from receiverInformation where receiverId = @recId

	IF NOT EXISTS(select 'A' from API_STATE_LIST  where STATE_COUNTRY = @rcountryName)
		BEGIN
			SELECT 'Any State' LOCATIONNAME,'0' LOCATIONID 
		END
	ELSE
		BEGIN
			select STATE_ID LOCATIONID,STATE_NAME LOCATIONNAME from API_STATE_LIST  where STATE_COUNTRY = @rcountryName 
		END
	select CITY_ID,CITY_NAME from API_CITY_LIST where STATE_ID = @stateId  
END

ELSE IF @flag='getPayoutPartner'
BEGIN
	--FOR NOW ONLY, LATER WE NEED TO GET PAYOUT PARTNER FROM AGENTMASTER TABLE IF EXISTS
	DECLARE @isAccalidate VARCHAR(20)
		SELECT @agentId= agentId,@isAccalidate =isRealTime 
		FROM TblPartnerwiseCountry (NOLOCK) 
		WHERE countryId = @Country 
		AND ISNULL(PaymentMethod, @deliveryMethodId) = @deliveryMethodId
		AND IsActive = 1
	SELECT @agentId + '|' + ISNULL(@isAccalidate,0)
END

ELSE If @flag ='pcurr'--load currency by pcountry
begin
	SELECT distinct CM.currencyCode,cc.isDefault
	FROM currencyMaster CM WITH (NOLOCK)
	INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId=CC.currencyId
	WHERE CC.countryId = @countryId AND ISNULL(CC.isDeleted,'')<>'Y'
	AND CC.spFlag IN ('R', 'B')
end
ELSE IF @flag='pickBranchById'
BEGIN
	IF EXISTS(SELECT 'A' FROM API_BANK_LIST BL(NOLOCK) 
	WHERE BL.BANK_ID = @agentId AND BANK_COUNTRY IN ('NEPAL') AND IS_ACTIVE = 1)
	BEGIN
		SELECT NULL AgentId,AgentName = 'Any Branch'
		RETURN
	END
	SELECT AgentId = BRANCH_ID
		,AgentName = BRANCH_NAME
	FROM API_BANK_BRANCH_LIST am WITH (NOLOCK) 
	WHERE BANK_ID = @agentId 
	AND IS_ACTIVE = 1
END
IF @FLAG='getBranchByAgentIdForDDL'
BEGIN
	SELECT BRANCH_ID AgentId, BRANCH_NAME AgentName
	FROM dbo.API_BANK_BRANCH_LIST
	WHERE BANK_ID=@bankId AND IS_ACTIVE=1;
END

ELSE IF @flag = 'stateAcToPcountry'
	BEGIN
		IF NOT EXISTS(SELECT 'A' FROM dbo.API_STATE_LIST (NOLOCK) WHERE  STATE_COUNTRY= @pCountryName)
		BEGIN
			SELECT 'Any State' LOCATIONNAME,'0' LOCATIONID 
			RETURN
		END
		SELECT * FROM (
		SELECT 'Select State' LOCATIONNAME,'' LOCATIONID, 0 [ROW]  UNION ALL

		SELECT [STATE_NAME] LOCATIONNAME
				,STATE_ID LOCATIONID 
				,1 [ROW]
		FROM API_STATE_LIST (NOLOCK) 
		WHERE STATE_COUNTRY = @pCountryName
		AND IS_ACTIVE = 1
		)X ORDER BY [ROW], X.LOCATIONNAME
		RETURN
	END
IF @flag = 'city'
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


GO
