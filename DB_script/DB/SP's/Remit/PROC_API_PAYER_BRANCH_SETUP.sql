use fastmoneypro_remit
go
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Author,Anoj Kattel>
-- Create date: <Create Date,2019/5/30>
-- Description:	<Description,This Sp is Used For add and update data of payer details>
-- =============================================
ALTER PROCEDURE PROC_API_PAYER_BRANCH_SETUP 
	 @FLAG				VARCHAR(50)
	,@XML				NVARCHAR(MAX)	=	NULL
	,@PAYER_COUNTRY		VARCHAR(50) 	=	NULL 
	,@API_PARTNER_ID	INT				=	NULL
	,@COUNTRY_CURRENCY	VARCHAR(4)		=	NULL
	,@BANK_CODE			VARCHAR(50)		=	NULL
	,@BANK_NAME			VARCHAR(200)	=	NULL
	,@CITY_CODE			VARCHAR(16)		=	NULL
	,@PAYERID			BIGINT			=	NULL
	,@SQl				VARCHAR(MAX)	=	NULL
	,@CityId			BIGINT			=	NULL
	,@pMode				INT				=	NULL
	,@pCountry			INT				=	NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NEW_RECORD		INT				=	NULL,
			@MSG			VARCHAR(500)	=	NULL

	IF @FLAG = 'syncPayerIfPaymentModeCash'
	BEGIN
	    IF OBJECT_ID('tempdb..#apiPayerData') IS NOT NULL DROP TABLE #apiPayerData
		
		DECLARE @XMLPayerData  XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(PayerId)[1]','VARCHAR(200)') AS 'PayerCode'
					,p.value('(PayerName)[1]','VARCHAR(MAX)') AS 'PayerName'
					,p.value('(BranchId)[1]','VARCHAR(MAX)') AS 'BranchCode'
					,p.value('(BranchName)[1]','VARCHAR(MAX)') AS 'BranchName'
					,p.value('(BranchAddress)[1]','VARCHAR(MAX)') AS 'BranchAddress'
					,p.value('(NeedBank)[1]','VARCHAR(200)') AS 'NeedBank'
		INTO #apiCashPayerData
		FROM @XMLPayerData.nodes('/ArrayOfPayerDetailsResults/PayerDetailsResults') AS apiPayerData(p)

		UPDATE #apiCashPayerData SET PayerCode=LTRIM(RTRIM(PayerCode)),
									 BranchCode=LTRIM(RTRIM(BranchCode)),
									 BranchName=LTRIM(RTRIM(BranchName)),
									 PayerName=LTRIM(RTRIM(PayerName))

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE P
		FROM #apiCashPayerData P 
		INNER JOIN dbo.API_BANK_BRANCH_LIST (NOLOCK) B ON LTRIM(RTRIM(b.BRANCH_CODE1))=P.BranchCode AND LTRIM(RTRIM(b.BRANCH_NAME))=p.BranchName AND B.PAYMENT_TYPE_ID=1
		
		---- select only payer data
		SELECT DISTINCT PayerCode,PayerName INTO #cashPayerData
		FROM #apiCashPayerData

		IF EXISTS(SELECT (1) FROM #cashPayerData)
		BEGIN
			----- left join with API_BANK_LIST and #cashPayerData for add new API_BANK_LIST
			SELECT CPD.PayerCode,CPD.PayerName INTO #newCashPayerDataOnly FROM #cashPayerData CPD (NOLOCK)
			LEFT JOIN dbo.API_BANK_LIST APL (NOLOCK) ON LTRIM(RTRIM(APL.BANK_CODE1))=CPD.PayerCode AND LTRIM(RTRIM(apl.BANK_NAME))=CPD.PayerName WHERE APL.BANK_CODE1 IS NULL

			IF EXISTS (SELECT 'a' FROM #newCashPayerDataOnly)
			BEGIN
			    --- INSERT NEW BANK DATA (CASH PAYER DATA) INTO API_BANK_LIST
				INSERT INTO dbo.API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_CODE2,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,
											  BANK_PHONE,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
									SELECT	  @API_PARTNER_ID,LTRIM(RTRIM(PayerName)),LTRIM(RTRIM(PayerCode)),NULL,NULL,NULL,NULL,
											  NULL,NULL,LTRIM(RTRIM(@COUNTRY_CURRENCY)),LTRIM(RTRIM(@PAYER_COUNTRY)),1,1  FROM #newCashPayerDataOnly
			END

			----------- add new bank branch data on API_BANK_BRANCH_LIST with BANK_ID=PayerCode for update new added bank branch data related with bank
			IF EXISTS(SELECT (1) FROM #apiCashPayerData)
			BEGIN
				INSERT INTO dbo.API_BANK_BRANCH_LIST(BRANCH_CODE2,BRANCH_NAME,BRANCH_CODE1,BRANCH_STATE,BRANCH_DISTRICT,
													 BRANCH_ADDRESS,BRANCH_PHONE,BRANCH_EMAIL,BRANCH_COUNTRY,IS_ACTIVE,BANK_ID,PAYMENT_TYPE_ID)
											SELECT	 LTRIM(RTRIM(PayerCode)),LTRIM(RTRIM(BranchName)),LTRIM(RTRIM(BranchCode)),NULL,NULL,
													 LTRIM(RTRIM(BranchAddress)),NULL,PayerName,LTRIM(RTRIM(@PAYER_COUNTRY)),1,0,1
											FROM #apiCashPayerData
			END
			---- update bank id for new added bank branch data
			UPDATE dbo.API_BANK_BRANCH_LIST SET BANK_ID=ABL.BANK_ID,BRANCH_CODE2=NULL,BRANCH_EMAIL=NULL
			FROM dbo.API_BANK_LIST ABL(NOLOCK)
			WHERE BRANCH_CODE2=ABL.BANK_CODE1 AND BRANCH_EMAIL=ABL.BANK_NAME AND ABL.BANK_CODE1 IS NOT NULL

		END

		SELECT @NEW_RECORD = COUNT(1) 
		FROM #apiCashPayerData
		SET @MSG ='Payer Details synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'
		
		EXEC proc_errorHandler 0, @MSG, NULL
	END

	IF @FLAG = 'syncPayerIfPaymentModeBankDeposit'
	BEGIN
	    IF OBJECT_ID('tempdb..#apiBankPayerData') IS NOT NULL DROP TABLE #apiBankPayerData
		
		DECLARE @XMLBankPayerData XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) ,
				@bankId			BIGINT			=			NULL

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(PayerId)[1]','VARCHAR(200)') AS 'PayerCode'
					,p.value('(PayerName)[1]','VARCHAR(200)') AS 'PayerName'
					,p.value('(BranchId)[1]','VARCHAR(200)') AS 'BranchCode'
					,p.value('(BankId)[1]','VARCHAR(200)') AS 'BankCode'
					,p.value('(BankName)[1]','VARCHAR(200)') AS 'BankName'
					,p.value('(BranchName)[1]','VARCHAR(200)') AS 'BranchName'
					,p.value('(BranchAddress)[1]','VARCHAR(200)') AS 'BranchAddress'
					,p.value('(NeedBank)[1]','VARCHAR(200)') AS 'NeedBank'
		INTO #apiBankPayerData
		FROM @XMLBankPayerData.nodes('/ArrayOfPayerDetailsResults/PayerDetailsResults') AS apiBankPayerData(p)


		UPDATE #apiBankPayerData SET PayerCode=LTRIM(RTRIM(PayerCode)),PayerName=LTRIM(RTRIM(PayerName)),
									BranchCode=LTRIM(RTRIM(BranchCode)),BranchName=LTRIM(RTRIM(BranchName)),
									BranchAddress=LTRIM(RTRIM(BranchAddress)),NeedBank =LTRIM(RTRIM(NeedBank)),
									BankCode=LTRIM(RTRIM(BankCode)),
									BankName=LTRIM(RTRIM(BankName))
		DECLARE @TOTAL_COUNT INT 
		SELECT @TOTAL_COUNT = COUNT(0) FROM #apiBankPayerData
		--SELECT  DISTINCT BankId FROM #apiBankPayerData
		--RETURN
		--UPDATE dbo.API_BANK_LIST SET PAYMENT_TYPE_ID=0
		--WHERE LTRIM(RTRIM(BANK_CODE1))=LTRIM(RTRIM(@BANK_CODE)) AND LTRIM(RTRIM(BANK_NAME))=LTRIM(RTRIM(@BANK_NAME)) AND PAYMENT_TYPE_ID=1

		---- get cityid from API_CITY_LIST
		--SELECT @CityId=CITY_ID FROM API_CITY_LIST WHERE CITY_CODE=@CITY_CODE
		--DELETE EXISTING DATA FROM TEMP TABLE
		--DELETE P
		--FROM #apiBankPayerData P 
		--INNER JOIN dbo.API_PAYOUT_BRANCH_LOACTION (NOLOCK) B ON LTRIM(RTRIM(b.BRANCH_CODE))=P.BranchCode AND 
		--														LTRIM(RTRIM(B.BRANCH_NAME))=P.BranchName --AND B.CITY_ID=@CityId
		
		---- select only payer data

		
		SELECT DISTINCT PayerCode,PayerName,BankCode,BankId=0,BankName='',BranchCode, BranchName, BranchAddress, NeedBank INTO #payerOnlyData
		FROM #apiBankPayerData
		
		ALTER TABLE #payerOnlyData ALTER COLUMN BankName VARCHAR(250)
		ALTER TABLE #payerOnlyData ADD RowId INT

		--- check Temp Payer List Has Data Or Not continue if has data
		IF EXISTS(SELECT (1) FROM #payerOnlyData)
		BEGIN
			UPDATE pod SET pod.BankId=abl.BANK_ID,BankName=abl.BANK_NAME
			FROM dbo.API_BANK_LIST abl(NOLOCK)
			INNER JOIN #payerOnlyData pod ON pod.BankCode=abl.BANK_CODE1 AND abl.BANK_COUNTRY=@PAYER_COUNTRY

			DELETE p 
			FROM #payerOnlyData p
			INNER JOIN dbo.API_PAYOUT_LOACTION apl (NOLOCK) ON apl.PAYOUT_NAME=p.PayerName AND apl.PAYOUT_CODE=p.PayerCode AND apl.BANK_ID=p.BankId
            

			INSERT INTO dbo.API_PAYOUT_LOACTION(PAYOUT_NAME,PAYOUT_CODE,BANK_ID,BANK_NAME,NEED_BANK)
			SELECT DISTINCT LTRIM(RTRIM(PayerName)),LTRIM(RTRIM(PayerCode)),BankId,LTRIM(RTRIM(BankName)),1 FROM #payerOnlyData

				
			UPDATE pod SET pod.RowId = apl.Id
			FROM #payerOnlyData pod
			INNER JOIN dbo.API_PAYOUT_LOACTION (NOLOCK) apl ON apl.PAYOUT_NAME=pod.PayerName AND apl.PAYOUT_CODE=pod.PayerCode AND apl.BANK_ID=pod.BankId
            
			INSERT INTO dbo.API_PAYOUT_BRANCH_LOACTION(PAYOUT_ID,BRANCH_CODE,BRANCH_NAME,BRANCH_ADDRESS,CITY_ID,NEED_BANK)
			SELECT RowId,BranchCode,BranchName,BranchAddress,NULL,CASE NeedBank WHEN 'A' THEN 1 ELSE 0 END
			FROM #payerOnlyData 
		END

		SELECT @NEW_RECORD = COUNT(1) FROM #payerOnlyData
		SET @MSG ='Payer Details synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system. TOTAL :'+CAST(@TOTAL_COUNT AS VARCHAR)
		
		EXEC proc_errorHandler 0, @MSG, NULL
	END

	--IF @FLAG = 'payerForJmeNepal'
	--BEGIN
	--    IF OBJECT_ID('tempdb..#apiBankPayerForJMEData') IS NOT NULL DROP TABLE #apiBankPayerForJMEData
		
	--	DECLARE @XMLBankPayerFORJMEData XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

	--	SELECT  IDENTITY(INT, 1, 1) AS rowId
	--				,p.value('(lOCATIONIDField)[1]','VARCHAR(200)') AS 'AgentCode'
	--				,p.value('(aGENTField)[1]','VARCHAR(200)') AS 'AgentName'
	--				,p.value('(bRANCHField)[1]','VARCHAR(200)') AS 'BranchName'
	--				,p.value('(aDDRESSField)[1]','VARCHAR(200)') AS 'BranchAddress'
	--				,p.value('(cITYField)[1]','VARCHAR(200)') AS 'CityName'
	--				,p.value('(cURRENCYField)[1]','VARCHAR(200)') AS 'CurrencyCode'
	--				,p.value('(pAYMENT_OPTIONField)[1]','VARCHAR(200)') AS 'PaymentMode'
	--	INTO #apiBankPayerForJMEData
	--	FROM @XMLBankPayerFORJMEData.nodes('/ArrayOfJmeNepalResponse/JmeNepalResponse') AS apiBankPayerData(p)

	--	--DELETE EXISTING DATA FROM TEMP TABLE
	--	DELETE P
	--	FROM #apiBankPayerForJMEData P 
	--	INNER JOIN dbo.API_PAYOUT_BRANCH_LOACTION (NOLOCK) B ON b.BRANCH_CODE=P.AgentCode AND NEED_BANK = CASE @BANK_CODE WHEN 'Y' THEN 1 ELSE 0 END
		
	--	---- select only payer data
	--	SELECT DISTINCT AgentName,AgentCode INTO #payerOnlyForJMEData
	--	FROM #apiBankPayerForJMEData

	--	--- check Temp Payer List Has Data Or Not continue if has data
	--	IF EXISTS(SELECT (1) FROM #payerOnlyForJMEData)
	--	BEGIN
	--		----- left join with api_payout_location and #payerOnlyData for add new api_payout_location
	--		SELECT pOD.AgentName INTO #newPayerDataForJMEOnly FROM #payerOnlyForJMEData pOD (NOLOCK)
	--		LEFT JOIN dbo.API_PAYOUT_LOACTION APL (NOLOCK) ON APL.PAYOUT_NAME=pOD.AgentName

	--		IF EXISTS(SELECT (1) FROM #payerOnlyForJMEData)
	--		BEGIN
	--			--- get bankid from api_bank_list using bank_code

	--			INSERT INTO dbo.API_PAYOUT_LOACTION(PAYOUT_NAME,PAYOUT_CODE,BANK_NAME,NEED_BANK)
	--										 SELECT AgentName,AgentCode,AgentName,CASE @BANK_CODE WHEN 'Y' THEN 1 ELSE 0 END FROM #payerOnlyForJMEData
	--		END

	--		----------- add new payer branch data on ap_payout_branch_location with payout_ID=PayerCode for update new added payout data related with branch
	--		IF EXISTS(SELECT (1) FROM #apiBankPayerForJMEData)
	--		BEGIN
	--		     INSERT INTO dbo.API_PAYOUT_BRANCH_LOACTION(PAYOUT_ID,BRANCH_CODE,BRANCH_NAME,BRANCH_ADDRESS,NEED_BANK)
	--											SELECT AgentCode,AgentCode,AgentName,BranchAddress,CASE @BANK_CODE WHEN 'Y' THEN 1 ELSE 0 END
	--											FROM #apiBankPayerForJMEData 
	--		END

	--		---- update payer id for new added payout branch data
	--		UPDATE dbo.API_PAYOUT_BRANCH_LOACTION SET PAYOUT_ID=APLL.Id
	--		FROM dbo.API_PAYOUT_LOACTION APLL(NOLOCK)
	--		WHERE PAYOUT_ID=APLL.PAYOUT_CODE
		
	--	END

	--	SELECT @NEW_RECORD = COUNT(1) FROM #apiBankPayerForJMEData
	--	SET @MSG ='Payer Details synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'
		
	--	EXEC proc_errorHandler 0, @MSG, NULL
	--END

	IF @FLAG='getPayerDataByAgent'
	BEGIN
		IF ISNULL(@XML, '') <> ''
		BEGIN
			SET @XMLBankPayerData = CONVERT(xml, replace(@XML,'&','&amp;'), 2)

			SELECT  IDENTITY(INT, 1, 1) AS rowId
						,p.value('(PayerId)[1]','VARCHAR(200)') AS 'PayerCode'
						,p.value('(PayerName)[1]','VARCHAR(200)') AS 'PayerName'
						,p.value('(BranchId)[1]','VARCHAR(200)') AS 'BranchCode'
						,p.value('(BankId)[1]','VARCHAR(200)') AS 'BankCode'
						,p.value('(BankName)[1]','VARCHAR(200)') AS 'BankName'
						,p.value('(BranchName)[1]','VARCHAR(200)') AS 'BranchName'
						,p.value('(BranchAddress)[1]','VARCHAR(200)') AS 'BranchAddress'
						,p.value('(NeedBank)[1]','VARCHAR(200)') AS 'NeedBank'
			INTO #apiBankPayerData1
			FROM @XMLBankPayerData.nodes('/ArrayOfPayerDetailsResults/PayerDetailsResults') AS apiBankPayerData(p)
				
			UPDATE #apiBankPayerData1 SET PayerCode=LTRIM(RTRIM(PayerCode)),PayerName=LTRIM(RTRIM(PayerName)),
										BranchCode=LTRIM(RTRIM(BranchCode)),BranchName=LTRIM(RTRIM(BranchName)),
										BranchAddress=LTRIM(RTRIM(BranchAddress)),NeedBank =LTRIM(RTRIM(NeedBank)),
										BankCode=LTRIM(RTRIM(BankCode)),
										BankName=LTRIM(RTRIM(BankName))
			
			DELETE 
			FROM PAYER_BANK_DETAILS 
			WHERE BANK_ID = @BANK_CODE
			AND creaeteddate < '2020-02-06'

			DELETE A 
			FROM #apiBankPayerData1 A
			INNER JOIN PAYER_BANK_DETAILS B(NOLOCK) ON B.BANK_CODE = A.BankCode 
													AND B.PAYER_CODE = A.PayerCode 
													AND B.PAYER_BRANCH_CODE = A.BranchCode
													AND B.BANK_ID = @BANK_CODE
			
			INSERT INTO PAYER_BANK_DETAILS
			SELECT PayerName, BANK_ID, BANK_COUNTRY, PayerCode, BranchName, BranchCode, BranchAddress, NULL, NULL, 
					BANK_COUNTRY, B.PAYMENT_TYPE_ID, B.BANK_CODE1, @API_PARTNER_ID, GETDATE()
			FROM #apiBankPayerData1 A
			INNER JOIN API_BANK_LIST B (NOLOCK) ON B.BANK_ID = @BANK_CODE
		END
		
		IF @API_PARTNER_ID IS NOT NULL AND @API_PARTNER_ID ='394130'
		BEGIN
			IF EXISTS(SELECT * FROM PAYER_BANK_DETAILS (NOLOCK) WHERE BANK_ID = @BANK_CODE AND BANK_COUNTRY = 'INDIA' AND PAYER_BRANCH_CODE IN ('ID98000002', 'ID98000001'))
			BEGIN
				SELECT APL.PAYER_ID payerId, APL.PAYER_NAME + ' - ' + BRANCH_ADDRESS+' - '+CAST(BANK_ID AS VARCHAR) payerName 
				FROM dbo.PAYER_BANK_DETAILS APL (NOLOCK)
				INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYNAME = APL.BRANCH_COUNTRY
				WHERE APL.BANK_ID=@BANK_CODE
				AND PAYER_BRANCH_CODE IN ('ID98000001', 'ID98000002')
				RETURN;
			END

			SELECT payerId=NULL , payerName='SELECT'
			UNION ALL
		    SELECT APL.PAYER_ID payerId, APL.PAYER_NAME + ' - ' + BRANCH_ADDRESS+' - '+CAST(BANK_ID AS VARCHAR) payerName 
			FROM dbo.PAYER_BANK_DETAILS APL (NOLOCK)
			INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYNAME = APL.BRANCH_COUNTRY
			WHERE APL.BANK_ID=@BANK_CODE
			--UNION ALL
			--SELECT APL.PAYER_ID payerId, APL.PAYER_NAME + ' - ' + BRANCH_ADDRESS payerName 
			--FROM dbo.PAYER_BANK_DETAILS APL (NOLOCK)
			--INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYNAME = APL.BRANCH_COUNTRY
			--WHERE PARTNER_ID = @API_PARTNER_ID
			--AND CM.COUNTRYID = @pCountry
			--AND PAYMENT_MODE = @pMode  
			--ORDER BY payerName ASC
			RETURN;
		END
		
		SELECT payerId=NULL , payerName='SELECT'
		UNION ALL
		SELECT APL.Id payerId, APL.PAYOUT_NAME payerName 
		FROM dbo.API_PAYOUT_LOACTION APL (NOLOCK)
		WHERE APL.BANK_ID=@BANK_CODE
		--ORDER BY payerName ASC
	END

	IF @FLAG ='getPayoutBranchByPayoutAndCityId'
	BEGIN
		IF @API_PARTNER_ID IS NOT NULL AND @API_PARTNER_ID ='393880'
		BEGIN
			SET @SQl='
				SELECT	 payerId			=		NULL,
						 payerName			=		''SELECT'',
						 BranchAddress		=		NULL,
						 BranchCode			=		NULL
				UNION ALL
				SELECT	DISTINCT Id					payerId,
						 BRANCH_NAME				payerName,
						 BRANCH_ADDRESS				BranchAddress,
						 BRANCH_CODE				BranchCode
				FROM dbo.API_PAYOUT_BRANCH_LOACTION APBL(NOLOCK) 
				WHERE 1=1 ';
		END
		ELSE
		BEGIN
			SET @SQl='
			SELECT		 payerId							=		NULL,
						 payerName							=		''SELECT'',
						 BranchAddress						=		NULL,
						 BranchCode							=		NULL
			UNION ALL
			SELECT	 DISTINCT Id									payerId,
					 BRANCH_NAME+''(''+acl.CITY_NAME+'')''			payerName,
					 BRANCH_ADDRESS									BranchAddress,
					 BRANCH_CODE									BranchCode
			FROM dbo.API_PAYOUT_BRANCH_LOACTION APBL(NOLOCK) 
			INNER JOIN dbo.API_CITY_LIST ACL(NOLOCK) ON ACL.CITY_ID=APBL.CITY_ID
			WHERE 1=1 ';
		END

		IF @PAYERID IS NOT NULL
		BEGIN
		     SET @SQl+=' AND PAYOUT_ID='''+CONVERT(VARCHAR(15), @PAYERID)+''''
		END
		--IF @CityId IS NOT NULL
		--BEGIN
		--     SET @SQl+=' AND ACL.CITY_ID='''+CONVERT(VARCHAR(25),@CityId)+''''
		--END
		PRINT @SQl;
		EXEC(@SQl);
	END
END


