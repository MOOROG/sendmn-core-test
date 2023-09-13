SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
/*
EXEC PROC_MOBILE_DYNAMIC_RECEIVERDETAILS  @countryId = '113', @serviceType = 2
EXEC PROC_MOBILE_DYNAMIC_RECEIVERDETAILS  @countryId = null, @serviceType = 5
EXEC PROC_MOBILE_DYNAMIC_RECEIVERDETAILS  @countryId = null, @serviceType = NULL
EXEC PROC_MOBILE_DYNAMIC_RECEIVERDETAILS  @countryId = 12, @serviceType = 2
*/


--SELECT * FROM  dbo.receiverFieldSetup WHERE paymentMethodId = 1


--DELETE FROM dbo.receiverFieldSetup WHERE paymentMethodId = 0




ALTER PROCEDURE [dbo].[PROC_MOBILE_DYNAMIC_RECEIVERDETAILS]
	@customerId			VARCHAR(20)		= NULL
	,@countryId			VARCHAR(10)		= NULl
	,@serviceType		VARCHAR(10)		= NULL 
 AS 
 SET NOCOUNT ON
 BEGIN
 IF @countryId IS NULL
	RETURN 
 IF @serviceType IS NULL
	RETURN 
IF OBJECT_ID('tempdb..#payoutMode') IS NOT NULL
			DROP TABLE #payoutMode

		IF OBJECT_ID('tempdb..#tempBankList') IS NOT NULL
			DROP TABLE #tempBankList
		

		DECLARE @dyCountryId VARCHAR(10), @dyServciceType VARCHAR(10)


		SET @dyCountryId = @countryId
		SET @dyServciceType = @serviceType

		IF NOT EXISTS(SELECT 'x' FROM dbo.receiverFieldSetup(nolock) WHERE pCountry = @dyCountryId AND paymentMethodId = @dyServciceType)
		BEGIN
			SET @dyCountryId = '0'
		END
		
		--SELECT @countryId = CM.countryId 
		--FROM dbo.countryMaster(NOLOCK) AS CM 
		--WHERE CM.countryCode = 'VN'

		SELECT DISTINCT * INTO #payoutMode FROM (
		SELECT 
			CRM.countryId
			,Id = crm.receivingMode
			,Mode = STM.typeDesc
			,PayoutPartner = TPC.AgentId
			,BankRequired = CASE WHEN crm.agentSelection ='N' THEN 'False' ELSE 'True' END 
		--INTO #payoutMode
		FROM dbo.countryReceivingMode(NOLOCK) AS CRM
		INNER JOIN dbo.serviceTypeMaster(NOLOCK) AS STM ON CRM.receivingMode = STM.serviceTypeId
		INNER JOIN dbo.TblPartnerwiseCountry(NOLOCK) AS TPC ON TPC.CountryId = CRM.countryId 
		AND CRM.receivingMode = ISNULL(TPC.PaymentMethod,CRM.receivingMode)
		WHERE CRM.countryId = @countryId AND TPC.IsActive = 1
		AND STM.isActive = 'Y'
		)x

		/*Receiver Field setup*/


		DECLARE @tempp TABLE(field VARCHAR(100),fieldRequired VARCHAR(5),minfieldLength INT,maxfieldLength INT,KeyWord VARCHAR(100))

		IF EXISTS(SELECT 'x' FROM receiverFieldSetup(nolock) WHERE pCountry=@dyCountryId AND paymentMethodId=@dyServciceType	
		AND field = 'Local Name' AND fieldRequired IN('M','O'))
		BEGIN
			 INSERT INTO @tempp(field,fieldRequired,minfieldLength,maxfieldLength,KeyWord)
			 SELECT field,fieldRequired,minfieldLength,maxfieldLength,KeyWord 
			 FROM receiverFieldSetup(NOLOCK) 
			 WHERE pCountry=@dyCountryId AND paymentMethodId=@dyServciceType	
			 AND field IN ('First Name in Local','Middle Name in Local','Last Name in Local')
		END

		INSERT INTO @tempp(field,fieldRequired,minfieldLength,maxfieldLength,KeyWord)
		SELECT field,fieldRequired,minfieldLength,maxfieldLength,KeyWord 
		FROM receiverFieldSetup(NOLOCK) 
		WHERE pCountry=@dyCountryId AND paymentMethodId=@dyServciceType	AND 
		field NOT IN ('Local Name','First Name in Local','Middle Name in Local','Last Name in Local')
		
		--#1
		SELECT * FROM @tempp

		--#2
		/*Reason*/
		SELECT  detailTitle AS id, detailTitle AS text FROM dbo.staticDataValue (NOLOCK) WHERE typeID=3800 AND ISNULL(isActive,'N') <> 'N'

		--#3
		/*Relation*/
		SELECT  detailTitle AS id,detailTitle AS text FROM dbo.staticDataValue (NOLOCK) WHERE typeID=2100 AND ISNULL(isActive,'N') <> 'N'

		--#4
		/*IdType*/
		SELECT detailTitle AS id,detailTitle AS text  FROM dbo.staticDataValue (NOLOCK) WHERE typeID=1300 AND ISNULL(isActive,'N') <> 'N'
				
		--#5
		/*Province*/
		SELECT id,[text],countryId FROM (		
			SELECT 
				 CAST(TSL.rowId AS VARCHAR) AS id
				,TSL.location  AS [text]
				, CONVERT(VARCHAR,TSL.countryId) AS countryId
			FROM dbo.tblServicewiseLocation(NOLOCK) AS TSL WHERE TSL.countryId=@countryId
			UNION ALL
			SELECT '0' AS id,'Any State' AS [text],@countryId AS countryId
		)x WHERE ISNULL(x.countryId,@countryId) = @countryId ORDER BY [text] ASC
		----WHERE CONVERT(VARCHAR,TSL.countryId)='203' AND TSL.partnerLocationId='019'

		/*District*/
		--#6
		SELECT 
			CAST(rowId AS VARCHAR) AS id,RTRIM(LTRIM(TSL.subLocation)) AS [text], CONVERT(VARCHAR,TSL.locationId) AS provinceId
		FROM dbo.tblSubLocation(NOLOCK) AS TSL
		UNION ALL
		SELECT '0' AS id,'Any District' AS [text],'0' AS provinceId
		ORDER BY [text]
		
		DECLARE @PAYOUTPARTNER INT, @agentCurrency VARCHAR(5), @isAccountValidation VARCHAR(20)

		SELECT DISTINCT @agentCurrency = CM.currencyCode
		FROM currencyMaster CM WITH (NOLOCK)  
		INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId=CC.currencyId  
		WHERE CC.countryId = @countryId 
		AND ISNULL(CC.isDeleted,'')<>'Y'  
		AND CC.spFlag IN ('R', 'B')  
		AND ISNULL(cc.isDefault, 'N') = 'Y'
		
		SELECT @PAYOUTPARTNER = TP.AGENTID, @isAccountValidation = CASE WHEN ISNULL(isACValidateSupport, 0) = 0 THEN 'False' ELSE 'True' END
		FROM TblPartnerwiseCountry TP(NOLOCK)  
		INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = TP.AGENTID  
		WHERE TP.CountryId = @countryId  
		AND ISNULL(TP.PaymentMethod, @serviceType) = @serviceType  
		AND ISNULL(TP.IsActive, 1) = 1  
		AND ISNULL(AM.ISACTIVE, 'Y') = 'Y'  
		AND ISNULL(AM.ISDELETED, 'N') = 'N'  
		
		--##7
		----## GET COUNTRY INFO
		SELECT CM.countryId AS Id,CM.countryName AS Name, CM.countryCode AS Code 
		FROM dbo.countryMaster(NOLOCK) AS CM 
		WHERE CM.countryId = @countryId

		--##8
		SELECT 
			 PM.countryId AS CountryId
			,PM.Id AS ModeId
			,PM.Mode,PM.PayoutPartner
			,PayCurrency = dbo.GetAllowCurrency(PM.countryId,PM.Id,null)
			,BankRequired
		FROM #payoutMode AS PM 
		WHERE PM.PayoutPartner IS NOT NULL 
		ORDER BY PM.Mode ASC

		DECLARE @SQL VARCHAR(MAX) = ''
		DECLARE @AGENTLIST TABLE(payoutPartner BIGINT,countryId INT,id BIGINT,Name VARCHAR(250),Code VARCHAR(50),AgentRole INT
				,BranchRequired VARCHAR(5),IsAccountRequired VARCHAR(5),IsAccountValidation VARCHAR(5),agentCurrency VARCHAR(50)
				)
				
		IF @countryId IN ('118') AND @serviceType = 1
		BEGIN
			SET @SQL = 'SELECT payoutPartner = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+'''
						,countryId = '''+CAST(@countryId AS VARCHAR)+'''
						,id = 0
						,Name = ''[ANY WHERE]''
						,Code = ''''
						,AgentRole = 1
						,BranchRequired = ''False''
						,IsAccountRequired = ''False''
						,IsAccountValidation = '''+@isAccountValidation+'''
						,agentCurrency = '''+CAST(@agentCurrency AS VARCHAR)+'''' 
		END
		ELSE IF @countryId = '203'
		BEGIN
			SET @SQL = 'SELECT payoutPartner = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+'''
						,countryId = CountryId
						,id = AL.BANK_ID
						,Name = LTRIM(RTRIM(AL.BANK_NAME))
						,Code = LTRIM(RTRIM(AL.BANK_CODE1))
						,AgentRole = '''+CAST(@serviceType AS VARCHAR)+'''
						,BranchRequired = ''False''
						,IsAccountRequired = CASE WHEN '''+CAST(@serviceType AS VARCHAR)+''' = 2 THEN ''True'' ELSE ''False'' END
						,IsAccountValidation = '''+@isAccountValidation+'''
						,agentCurrency = '''+CAST(@agentCurrency AS VARCHAR)+'''
				FROM API_BANK_LIST  AL(NOLOCK)  
				INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
				WHERE CM.CountryId = '''+CAST(@countryId AS VARCHAR)+'''
				AND AL.PAYMENT_TYPE_ID IN (0, '''+CAST(@serviceType AS VARCHAR)+''')
				AND AL.IS_ACTIVE = 1  
				AND AL.API_PARTNER_ID = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+''''  
		END
		ELSE
		BEGIN
			SET @SQL = 'SELECT payoutPartner = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+'''
						,countryId = CountryId
						,id = AL.BANK_ID
						,Name = LTRIM(RTRIM(AL.BANK_NAME))
						,Code = LTRIM(RTRIM(AL.BANK_CODE1))
						,AgentRole = '''+CAST(@serviceType AS VARCHAR)+'''
						,BranchRequired = CASE WHEN '''+CAST(@countryId AS VARCHAR)+''' = 151 THEN ''False'' ELSE ''True'' END
						,IsAccountRequired = CASE WHEN '''+CAST(@serviceType AS VARCHAR)+''' IN (2, 13) THEN ''True'' ELSE ''False'' END
						,IsAccountValidation = CASE WHEN AL.BANK_COUNTRY = ''CHINA'' AND AL.BANK_CODE1 = ''8600067'' THEN ''True'' ELSE '''+@isAccountValidation+''' END
						,agentCurrency = '''+CAST(@agentCurrency AS VARCHAR)+'''
				FROM API_BANK_LIST  AL(NOLOCK)  
				INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
				WHERE CM.CountryId = '''+CAST(@countryId AS VARCHAR)+'''
				AND AL.PAYMENT_TYPE_ID IN (0, '''+CAST(@serviceType AS VARCHAR)+''')
				AND AL.IS_ACTIVE = 1  
				AND AL.API_PARTNER_ID = '''+CAST(@PAYOUTPARTNER AS VARCHAR)+''''  
		END

		PRINT(@SQL)  
		INSERT INTO @AGENTLIST
		EXEC(@SQL)

		SELECT * FROM @AGENTLIST ORDER BY Name
		--EXEC PROC_MOBILE_DYNAMIC_RECEIVERDETAILS  @countryId = '104', @serviceType = 2
		--SELECT * FROM COUNTRYMASTER WHERE COUNTRYNAME = 'INDIA'
		--##10
		SELECT TOP 30
				A.Id AS BankId
				,ABL.BRANCH_ID AS Id
				,ABL.BRANCH_NAME AS [NAME]
		FROM @AGENTLIST A
		INNER JOIN API_BANK_BRANCH_LIST ABL (NOLOCK) ON ABL.BANK_ID = A.id
		ORDER BY [Name]
		
		--##11
		SELECT DISTINCT
			 Currency = X.value
			 ,T.Id
			 ,X.[Key]
		FROM @AGENTLIST t 
		INNER JOIN #payoutMode AS PM ON PM.BankRequired = 'True' AND pm.PayoutPartner = t.payoutPartner 
		CROSS APPLY DBO.GetCountryCurrency(@countryId,PM.Id,T.Id)X
		WHERE PM.Id = ISNULL(t.AgentRole,PM.ID) AND t.AgentRole = @serviceType
		ORDER BY X.[Key] DESC



		--PRINT @countryId
		--PRINT @serviceType 

		--##12
		SELECT  payoutpartner = @PAYOUTPARTNER--dbo.GetActivePayoutPartner(@countryId,@serviceType,'')
		
		RETURN
END
GO