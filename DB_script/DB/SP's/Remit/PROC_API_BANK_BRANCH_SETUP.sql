USE FastMoneyPro_Remit
GO


ALTER PROC PROC_API_BANK_BRANCH_SETUP
(
	@FLAG				VARCHAR(40)
	--grid parameters
	,@user				VARCHAR(80)		=	NULL
	,@pageSize			VARCHAR(50)		=	NULL
	,@pageNumber		VARCHAR(50)		=	NULL
	,@sortBy			VARCHAR(50)		=	NULL
	,@sortOrder			VARCHAR(50)		=	NULL
	,@API_PARTNER		INT				=	NULL
	,@PAYMENT_TYPE		INT				=	NULL
	,@bankId			VARCHAR(30)		=	NULL 
	,@BRANCH_NAME		VARCHAR(30)		=	NULL
	,@isActive			VARCHAR(5)		=	NULL
	,@rowId				VARCHAR(10)		=	NULL
	,@XML				NVARCHAR(MAX)	=	NULL
	,@BANK_COUNTRY		VARCHAR(50) 	=	NULL
	,@BANK_CURRENCY		VARCHAR(5)		=	NULL
	,@API_PARTNER_ID	INT				=	NULL
	,@CityId			BIGINT			=	NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE  @table						VARCHAR(MAX)
			,@select_field_list			VARCHAR(MAX)
			,@extra_field_list			VARCHAR(MAX)
			,@sql_filter				VARCHAR(MAX)
			,@NEW_RECORD				INT				=0
			,@NEW_BRANCH_RECORD			INT				=0
			,@MSG						VARCHAR(200)
	IF @FLAG = 'S'
	BEGIN
		SET @sortBy = 'BANK_ID'
		SET @sortOrder = 'desc'

		SET @table = '( SELECT BANK_ID,
								API_PARTNER = AM.AGENTNAME,
								API_PARTNER_ID,
								BANK_NAME,
								BANK_CODE1,
								BANK_CODE2,
								BANK_COUNTRY,
								IS_ACTIVE = CASE WHEN IS_ACTIVE = 1 THEN ''YES'' ELSE ''NO'' END,
								PAYMENT_TYPE = typeTitle,
								PAYMENT_TYPE_ID
						FROM API_BANK_LIST AB(NOLOCK)
						INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = AB.API_PARTNER_ID AND AM.PARENTID = 0
						INNER JOIN SERVICETYPEMASTER SM(NOLOCK) ON SM.serviceTypeId = AB.PAYMENT_TYPE_ID '

		SET @sql_filter = ''
		SET @table = @table + ')x'
		
		IF @API_PARTNER <> 0
			SET @sql_filter = @sql_filter+' AND API_PARTNER_ID =  '''+CAST(@API_PARTNER AS VARCHAR)+''''

		IF @PAYMENT_TYPE <> 0
			SET @sql_filter = @sql_filter+' AND PAYMENT_TYPE_ID =  '''+CAST(@PAYMENT_TYPE AS VARCHAR)+''''

		SET @select_field_list  = '
				 BANK_ID,API_PARTNER_ID,API_PARTNER,BANK_NAME,BANK_CODE1,BANK_CODE2,BANK_COUNTRY,IS_ACTIVE,PAYMENT_TYPE'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	IF @FLAG = 'API-PARTNER'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'SELECT' [text]	UNION ALL
		
		SELECT AGENTID [value], AGENTNAME [text]
		FROM agentMaster (NOLOCK)
		WHERE PARENTID = 0
		AND AGENTID NOT IN (1001, 393877)	
		) X 
		ORDER BY X.[value] ASC
	END
	IF @FLAG = 'PAYOUT-METHOD'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'SELECT' [text]	UNION ALL

		SELECT serviceTypeId [value], typeTitle [text]
		FROM SERVICETYPEMASTER (NOLOCK)
		WHERE ISNULL(ISACTIVE, 'Y') = 'Y'
		) X 
		ORDER BY X.[value] ASC
	END
	IF @FLAG = 'S-BankBranch'
	BEGIN
		SET @sortBy = 'BRANCH_ID'
		SET @sortOrder = 'desc'

		SET @table = '( SELECT BRANCH_ID,
								cm.countryName countryName,
								BRANCH_NAME,
								BRANCH_CODE1,
								BRANCH_STATE,
								BRANCH_ADDRESS,
								BRANCH_PHONE,
								BRANCH_COUNTRY,
								IS_ACTIVE = CASE WHEN AB.IS_ACTIVE = 1 THEN ''YES'' ELSE ''NO'' END
					FROM API_BANK_BRANCH_LIST AB(NOLOCK)
					INNER JOIN dbo.API_BANK_LIST ABL(NOLOCK) ON ABL.BANK_ID=AB.BANK_ID
					INNER JOIN dbo.countryMaster CM(NOLOCK) ON ABL.BANK_COUNTRY=CM.countryName
					WHERE AB.BANK_ID = '''+@bankId+''' '
		SET @sql_filter = ''
		SET @table = @table + ')x'
		
		IF @BRANCH_NAME <> ''
			SET @sql_filter = @sql_filter+' AND BRANCH_NAME LIKE  ''%'+CAST(@BRANCH_NAME AS VARCHAR)+'%'''
		--IF @PAYMENT_TYPE <> 0
		--	SET @sql_filter = @sql_filter+' AND PAYMENT_TYPE_ID =  '''+CAST(@PAYMENT_TYPE AS VARCHAR)+''''
		SET @select_field_list  = '
				 countryName,BRANCH_ID,BRANCH_NAME,BRANCH_CODE1,BRANCH_STATE,BRANCH_ADDRESS,BRANCH_PHONE,BRANCH_COUNTRY,IS_ACTIVE'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	IF @FLAG='getBranchByAgentIdForDDL'
	BEGIN
		DECLARE @COUNTRY_ID INT, @COLL_MODE INT

		SELECT @COUNTRY_ID = CM.COUNTRYID, @COLL_MODE = PAYMENT_TYPE_ID
		FROM API_BANK_LIST ABL(NOLOCK)
		INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = ABL.BANK_COUNTRY
		WHERE BANK_ID = @bankId 

		IF @COUNTRY_ID = 151
		BEGIN
			SELECT NULL agentId,agentName = 'Any Branch'
			RETURN
		END

		SELECT BRANCH_ID agentId, BRANCH_NAME agentName
		FROM dbo.API_BANK_BRANCH_LIST
		WHERE BANK_ID=@bankId AND IS_ACTIVE=1 --AND PAYMENT_TYPE_ID=@PAYMENT_TYPE;
	END

	IF @FLAG = 'enable-disable-bank'
	BEGIN
		IF @isActive = 'YES'
		BEGIN
			update API_BANK_LIST set  IS_ACTIVE = 0 where BANK_ID = @rowId

			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @rowId id	 
		END
		ELSE
		BEGIN
			update API_BANK_LIST set  IS_ACTIVE = 1 where BANK_ID = @rowId

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @rowId id	 
		END
	END
	IF @FLAG = 'enable-disable-bankBranch'
	BEGIN
		IF @isActive = 'YES'
		BEGIN
			update dbo.API_BANK_BRANCH_LIST set  IS_ACTIVE = 0 where BRANCH_ID = @rowId
			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @rowId id	 
		END
		ELSE
		BEGIN
			update dbo.API_BANK_BRANCH_LIST set  IS_ACTIVE = 1 where BRANCH_ID = @rowId

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @rowId id	 
		END
	END
	IF @FLAG = 'countryList'
	BEGIN
		SELECT countryCode value,countryName text FROM dbo.countryMaster
	END
	
	IF @FLAG = 'syncBank'
	BEGIN
		IF OBJECT_ID('tempdb..#apiBanks') IS NOT NULL DROP TABLE #apiBanks
		
		DECLARE @XMLDATA XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(Id)[1]','VARCHAR(20)') AS 'Id'
					,p.value('(Name)[1]','VARCHAR(150)') AS 'Name'
		INTO #apiBanks
		FROM @XMLDATA.nodes('/ArrayOfBankResponse/BankResponse') AS apiBanks(p)

		---- Check If Bank Details Already Exist for cash payment or not as a payer data
		UPDATE #apiBanks SET Name=LTRIM(RTRIM(Name)),Id=LTRIM(RTRIM(Id))

		UPDATE dbo.API_BANK_LIST SET PAYMENT_TYPE_ID=0
		FROM #apiBanks ab WHERE LTRIM(RTRIM(ab.Id))=LTRIM(RTRIM(BANK_CODE1)) AND LTRIM(RTRIM(ab.Name))=LTRIM(RTRIM(BANK_NAME)) AND PAYMENT_TYPE_ID=1
		--DELETE EXISTING DATA FROM TEMP TABLEf
		DELETE TMP 
		FROM #apiBanks TMP
		INNER JOIN API_BANK_LIST ABL(NOLOCK) ON LTRIM(RTRIM(ABL.BANK_CODE1)) =LTRIM(RTRIM(TMP.Id))  AND  LTRIM(RTRIM(ABL.BANK_NAME))=LTRIM((TMP.Name))
		WHERE LTRIM(RTRIM(BANK_COUNTRY)) =LTRIM(RTRIM(@BANK_COUNTRY))
		AND API_PARTNER_ID = @API_PARTNER_ID

		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_BANK_LIST (API_PARTNER_ID, BANK_NAME, BANK_CODE1, SUPPORT_CURRENCY, BANK_COUNTRY, PAYMENT_TYPE_ID, IS_ACTIVE)
		SELECT @API_PARTNER_ID,Name,Id, LTRIM(RTRIM(@BANK_CURRENCY)),LTRIM(RTRIM(@BANK_COUNTRY)), 2, 1
		FROM #apiBanks

		SELECT @NEW_RECORD = COUNT(1) FROM #apiBanks
		SET @MSG ='Bank synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END

	IF @FLAG = 'syncBankBranch'
	BEGIN
	    IF OBJECT_ID('tempdb..#apiBanksBranch') IS NOT NULL DROP TABLE #apiBanksBranch
		
		DECLARE @XMLBranchData XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) ,
				@banksId		BIGINT	=	NULL,
				@City_Id		BIGINT	=	NULL
		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(BankBranchID)[1]','VARCHAR(200)') AS 'BranchCode'
					,p.value('(BankID)[1]','VARCHAR(200)') AS 'BankCode'
					,p.value('(BankBranchName)[1]','VARCHAR(200)') AS 'BranchName'
		INTO #apiBanksBranch
		FROM @XMLBranchData.nodes('/ArrayOfBankBranchResponse/BankBranchResponse') AS apiBanksBranch(p)

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiBanksBranch TMP
		INNER JOIN dbo.API_BANK_BRANCH_LIST ABL(NOLOCK) ON LTRIM(RTRIM(ABL.BRANCH_CODE1)) =LTRIM(RTRIM(TMP.BranchCode)) AND 
					LTRIM(RTRIM(abl.BRANCH_NAME))=LTRIM(RTRIM(TMP.BranchName)) AND ABL.PAYMENT_TYPE_ID=2


		SELECT @banksId=BANK_ID FROM dbo.API_BANK_LIST WHERE BANK_CODE1=@bankId
		SELECT @City_Id=CITY_ID FROM dbo.API_CITY_LIST WHERE CITY_CODE=@CityId
		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_BANK_BRANCH_LIST (BRANCH_NAME,BANK_ID, BRANCH_CODE1,BRANCH_DISTRICT, BRANCH_COUNTRY, IS_ACTIVE,PAYMENT_TYPE_ID)
										SELECT LTRIM(RTRIM(BranchName)),@banksId, LTRIM(RTRIM(BranchCode)),@City_Id, LTRIM(RTRIM(@BANK_COUNTRY)), 1,2
		FROM #apiBanksBranch
		
		SELECT @NEW_RECORD = COUNT(1) FROM #apiBanksBranch
		SET @MSG ='Bank Branch synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END
	IF @FLAG = 'payerForJmeNepal'
	BEGIN
	    IF OBJECT_ID('tempdb..#apiBankBranchForJMEData') IS NOT NULL DROP TABLE #apiBankBranchForJMEData
		IF OBJECT_ID('tempdb..#jmeTempBankList') IS NOT NULL DROP TABLE #jmeTempBankList
		
		DECLARE @XMLBankPayerFORJMEData XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(aGENTField)[1]','VARCHAR(200)') AS 'BankName'
					,p.value('(lOCATIONIDField)[1]','VARCHAR(200)') AS 'BranchCode'
					,p.value('(bRANCHField)[1]','VARCHAR(200)') AS 'BranchName'
					,p.value('(aDDRESSField)[1]','VARCHAR(200)') AS 'BranchAddress'
					,p.value('(cITYField)[1]','VARCHAR(200)') AS 'CityName'
					,p.value('(cURRENCYField)[1]','VARCHAR(200)') AS 'CurrencyCode'
		INTO #apiBankBranchForJMEData
		FROM @XMLBankPayerFORJMEData.nodes('/ArrayOfJmeNepalResponse/JmeNepalResponse') AS apiBankPayerData(p)

		UPDATE #apiBankBranchForJMEData SET BankName=REPLACE(LTRIM(RTRIM(BankName)),'&amp','&'),
										BranchCode=LTRIM(RTRIM(BranchCode)),
										BranchName=LTRIM(RTRIM(BranchName)),
										CityName=LTRIM(RTRIM(CityName)),
										CurrencyCode=LTRIM(RTRIM(CurrencyCode))

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE P
		FROM #apiBankBranchForJMEData P 
		INNER JOIN dbo.API_BANK_BRANCH_LIST (NOLOCK) B ON LTRIM(RTRIM(b.BRANCH_CODE1))=BranchCode AND
											LTRIM(RTRIM(b.BRANCH_NAME))=BranchName AND B.PAYMENT_TYPE_ID=2 AND B.BRANCH_COUNTRY=@BANK_COUNTRY
		INNER JOIN dbo.API_BANK_LIST abl (NOLOCK) ON abl.BANK_ID = B.BANK_ID AND abl.API_PARTNER_ID=@API_PARTNER_ID
		
		--INSERT NEW DATA INTO BANK AND BANK BRANCH TABLE
		IF EXISTS(SELECT 1 FROM #apiBankBranchForJMEData)
		BEGIN
			
			SELECT p.BankName,p.CurrencyCode INTO #jmeTempBankList
			FROM #apiBankBranchForJMEData p GROUP BY p.BankName,p.CurrencyCode
			--SELECT 'jmeBankTempCode'+CONVERT(VARCHAR(150),ROW_NUMBER() OVER (ORDER BY jb.BankName)) AS rowNo,jb.BankName,jb.CurrencyCode FROM #jmeTempBankList jb
			--RETURN

			DELETE j
			FROM #jmeTempBankList j
			INNER JOIN dbo.API_BANK_LIST (NOLOCK) abl ON LTRIM(RTRIM(abl.BANK_NAME))=j.BankName AND abl.API_PARTNER_ID=@API_PARTNER_ID
			
			INSERT INTO dbo.API_BANK_LIST( 
												API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_CODE2,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE,BANK_EMAIL,
												SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE,JME_BANK_CODE
										 )

								SELECT		
										@API_PARTNER_ID,BankName,'','','','','','','',
										CurrencyCode,'Nepal','0',1,''--'jmeBankTempCode'+CONVERT(VARCHAR(50),ROW_NUMBER() OVER (ORDER BY jb.BankName)) AS rowNo
								FROM #jmeTempBankList

			INSERT INTO API_BANK_BRANCH_LIST (BRANCH_NAME,BANK_ID, BRANCH_CODE1,BRANCH_DISTRICT, BRANCH_COUNTRY, IS_ACTIVE,PAYMENT_TYPE_ID)
											SELECT abjd.BranchName,ABL.BANK_ID, abjd.BranchCode,abjd.CityName, LTRIM(RTRIM(@BANK_COUNTRY)), 1,2
			FROM #apiBankBranchForJMEData abjd
		    INNER JOIN dbo.API_BANK_LIST ABL (NOLOCK) ON LTRIM(RTRIM(ABL.BANK_NAME))=abjd.BankName AND ABL.API_PARTNER_ID=@API_PARTNER_ID
		SELECT @NEW_RECORD = COUNT(1) FROM #apiBankBranchForJMEData
		SELECT @NEW_BRANCH_RECORD= COUNT(1) FROM #jmeTempBankList
		END
		SET @MSG ='Jme Nepal . Total Bank '+CAST(@NEW_BRANCH_RECORD AS VARCHAR)+' And Bank Branch ' + CAST(@NEW_RECORD AS VARCHAR) + ' new records add successfully.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END

	IF @FLAG = 'syncGMEBank'
	BEGIN
		IF OBJECT_ID('tempdb..#apiGMEBanks') IS NOT NULL DROP TABLE #apiGMEBanks
		
		DECLARE @XMLGMEDATA XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(bankCodeField)[1]','VARCHAR(25)') AS 'bankCode'
					,p.value('(bankNameField)[1]','VARCHAR(150)') AS 'Name'
					,p.value('(addressField)[1]','VARCHAR(250)') AS 'Address'
					,p.value('(cityField)[1]','VARCHAR(100)') AS 'City'
		INTO #apiGMEBanks
		FROM @XMLGMEDATA.nodes('/ArrayOfGMEBANKRESPONSE/GMEBANKRESPONSE') AS apiGMEBanks(p)

		---- Check If Bank Details Already Exist for cash payment or not as a payer data
		UPDATE #apiGMEBanks 
				SET Name=LTRIM(RTRIM(Name)),
				bankCode=LTRIM(RTRIM(bankCode)),
				Address=LTRIM(RTRIM(Address)),
				City=LTRIM(RTRIM(City))

		--UPDATE dbo.API_BANK_LIST SET PAYMENT_TYPE_ID=0
		--FROM #apiBanks ab WHERE LTRIM(RTRIM(ab.Id))=LTRIM(RTRIM(BANK_CODE1)) AND LTRIM(RTRIM(ab.Name))=LTRIM(RTRIM(BANK_NAME)) AND PAYMENT_TYPE_ID=1
		--DELETE EXISTING DATA FROM TEMP TABLEf
		DELETE TMP 
		FROM #apiGMEBanks TMP
		INNER JOIN API_BANK_LIST ABL(NOLOCK) ON LTRIM(RTRIM(ABL.BANK_CODE1)) = TMP.bankCode  AND  LTRIM(RTRIM(ABL.BANK_NAME))= TMP.Name AND
		LTRIM(RTRIM(BANK_COUNTRY)) = LTRIM(RTRIM(@BANK_COUNTRY)) AND API_PARTNER_ID = @API_PARTNER_ID

		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_BANK_LIST (API_PARTNER_ID, BANK_NAME, BANK_CODE1, SUPPORT_CURRENCY, BANK_COUNTRY, PAYMENT_TYPE_ID, IS_ACTIVE,BANK_ADDRESS,BANK_DISTRICT)
		SELECT @API_PARTNER_ID,Name,bankCode, LTRIM(RTRIM(@BANK_CURRENCY)),LTRIM(RTRIM(@BANK_COUNTRY)), 2, 1,Address,City
		FROM #apiGMEBanks

		SELECT @NEW_RECORD = COUNT(1) FROM #apiGMEBanks
		SET @MSG ='Bank synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END

	IF @FLAG = 'syncGMEBankBranch'
	BEGIN
	    IF OBJECT_ID('tempdb..#apiGMEBanksBranch') IS NOT NULL DROP TABLE #apiGMEBanksBranch
		
		DECLARE @XMLGMEBranchData XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) ,
				@gmebanksId		BIGINT	=	NULL

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(bankBranchCodeField)[1]','VARCHAR(100)')		AS			'BranchCode'
					,p.value('(bankBranchField)[1]','VARCHAR(250)')			AS			'BranchName'
					,p.value('(branchAddressField)[1]','VARCHAR(100)')		AS			'BranchAddress'
					,p.value('(branchCityField)[1]','VARCHAR(100)')			AS			'BranchCityName'
					,p.value('(locationIdField)[1]','VARCHAR(200)')			AS			'BranchLocation'
		INTO #apiGMEBanksBranch
		FROM @XMLGMEBranchData.nodes('/ArrayOfGMEBBRANCH/GMEBBRANCH') AS apiGMEBanksBranch(p)

		UPDATE #apiGMEBanksBranch 
				SET BranchCode		=	LTRIM(RTRIM(BranchCode)),
					BranchName		=	LTRIM(RTRIM(BranchName)),
					BranchAddress	=	LTRIM(RTRIM(BranchAddress)),
					BranchCityName	=	LTRIM(RTRIM(BranchCityName)),
					BranchLocation	=	LTRIM(RTRIM(BranchLocation))

		
		SELECT @gmebanksId=BANK_ID FROM dbo.API_BANK_LIST WHERE BANK_CODE1=@bankId
		
		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiGMEBanksBranch TMP
		INNER JOIN dbo.API_BANK_BRANCH_LIST ABL(NOLOCK) ON LTRIM(RTRIM(ABL.BRANCH_CODE1)) =TMP.BranchCode AND 
					LTRIM(RTRIM(abl.BRANCH_NAME))=TMP.BranchName AND ABL.PAYMENT_TYPE_ID=2 AND LTRIM(RTRIM(ABL.BANK_ID))=@gmebanksId

		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_BANK_BRANCH_LIST (BRANCH_NAME,BANK_ID, BRANCH_CODE1,BRANCH_ADDRESS,BRANCH_DISTRICT, BRANCH_COUNTRY, IS_ACTIVE,PAYMENT_TYPE_ID)
										SELECT BranchName,@gmebanksId, BranchCode,BranchAddress,BranchCityName, LTRIM(RTRIM(@BANK_COUNTRY)), 1,2
		FROM #apiGMEBanksBranch
		
		SELECT @NEW_RECORD = COUNT(1) FROM #apiGMEBanksBranch
		SET @MSG ='Bank Branch synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END
	IF @FLAG = 'BANKLIST'
	BEGIN
		DECLARE @COUNTRY_NAME VARCHAR(30) = 'Philippines', @PROVIDER_ID INT = 394130 --TF

		SELECT DISTINCT CM.countryId, 
				 CM.countryCode,
				 CM.countryName,
				 CCM.currencyCode,
				 agentId = @PROVIDER_ID,
				 agentName = ''
		FROM COUNTRYMASTER CM(NOLOCK)
		INNER JOIN COUNTRYCURRENCY CC(NOLOCK) ON CC.COUNTRYID = CM.COUNTRYID
		INNER JOIN CURRENCYMASTER CCM(NOLOCK) ON CCM.currencyId = CC.currencyId
		WHERE COUNTRYNAME = @COUNTRY_NAME
		AND CURRENCYCODE <> 'JPY'

		SELECT BANK_CODE = BANK_CODE1,
				PROVIDER_ID = @PROVIDER_ID,
				BANK_NAME
		FROM API_BANK_LIST ABL(NOLOCK)
		WHERE BANK_COUNTRY = @COUNTRY_NAME
		AND API_PARTNER_ID = @PROVIDER_ID
		ORDER BY BANK_NAME
	END
END

--EXEC PROC_API_BANK_BRANCH_SETUP @flag='BANKLIST'
