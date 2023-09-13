USE 
FastMoneyPro_Remit
GO

--EXEC proc_customerReport @flag = 'registration-rpt',@startDate = '10/01/2017',@endDate = '12/31/2018',@user = 'admin',@country = null,@branch = NULL

ALTER PROC proc_customerReport
(
	@flag			VARCHAR(50)
	,@startDate		VARCHAR(30) = NULL
	,@endDate		VARCHAR(30) = NULL
	,@user			VARCHAR(30) = NULL
	,@country		VARCHAR(30) = NULL
	,@branch		VARCHAR(80)	= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @flag = 'registration-rpt'
	BEGIN
		SELECT [BRANCH NAME] = agentName, 
				[NATIVE COUNTRY] = C.countryName, 
				[TOTAL REGISTERED CUSTOMERS] = '<a href="#" onclick="OpenInNewWindow(''/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerdetailreport&startDate=' + @startDate + '&endDate='+ @endDate + 
				'&country=' + CAST(ISNULL(CM.nativeCountry, '') AS VARCHAR) + '&branch=' + CAST(ISNULL(X.agentId, '') as varchar)+'&flag=detail-customer'')">' + CAST(COUNT(1) AS VARCHAR) + '</a>'
		FROM customerMaster CM(NOLOCK) 
		LEFT JOIN (
			SELECT AU.userName, AM.agentName, AM.agentId FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		)X ON X.userName = CM.verifiedBy
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		WHERE CM.approvedBy IS NOT NULL
		AND X.agentName IS NOT NULL
		AND CM.nativeCountry = ISNULL(@country, CM.nativeCountry)
		AND CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		GROUP BY X.agentName, C.countryName, X.agentId, C.countryName, CM.nativeCountry
		ORDER BY C.countryName 

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		select 'Country' head, CASE WHEN @country IS NULL THEN 'All' ELSE (SELECT countryName FROM countryMaster (NOLOCK) WHERE countryId = @country) END UNION ALL	
		select 'Branch' head, ISNULL((SELECT agentName FROM agentMaster (NOLOCK) WHERE agentId = @branch), 'All') union all-- CASE WHEN @branch IS NULL THEN 'All' ELSE (SELECT agentName FROM agentMaster (NOLOCK) WHERE agentId = @branch) END UNION ALL
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  
		

		SELECT 'Customer Registration Report' title
	END
	ELSE IF @flag = 'detail-customer'
	BEGIN
		SELECT [CUSTOMER NAME] = firstName, 
				[EMAIL] = email, 
				[REGISTERED DATE] = CM.createdDate, 
				[APPROVED DATE] = CM.verifiedDate,
				[BANK NAME] = ABL.BANK_NAME,
				[BANK ACCOUNT NUMBER] = CM.bankAccountNo,
				[WALLET ACCOUNT NUMBER] = CM.walletAccountNo,
				[AVAILBALE BALANCE] = CM.availableBalance 
		FROM customerMaster CM(NOLOCK)
		LEFT JOIN (
			SELECT AU.userName, AM.agentName FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		)X ON X.userName = CM.verifiedBy
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		LEFT JOIN dbo.API_BANK_LIST ABL(NOLOCK) ON ABL.BANK_NAME = CM.bankName
		WHERE CM.nativeCountry = ISNULL(@country, CM.nativeCountry)
		AND X.agentName IS NOT NULL
		AND CM.approvedBy IS NOT NULL
		AND CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		ORDER BY CM.CREATEDDATE

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		select 'Country' head, CASE WHEN @country IS NULL THEN 'All' ELSE (SELECT countryName FROM countryMaster (NOLOCK) WHERE countryId = @country) END UNION ALL	
		select 'Branch' head, ISNULL((SELECT agentName FROM agentMaster (NOLOCK) WHERE agentId = @branch), 'All') union all-- CASE WHEN @branch IS NULL THEN 'All' ELSE (SELECT agentName FROM agentMaster (NOLOCK) WHERE agentId = @branch) END UNION ALL
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  
		
		SELECT 'Customer Registration Detail Report' title
	END
	ELSE IF @flag = 'transaction-rpt'
	BEGIN
		DECLARE @MAINTABLE TABLE (AgentName VARCHAR(80), Country VARCHAR(30), Transactions INT)
		DECLARE @CUSTOMERTABLE TABLE (AgentName VARCHAR(80),customerId BIGINT)
		DECLARE @CUSTOMERTXNTABLE TABLE (AgentName VARCHAR(80), Transactions INT, Country VARCHAR(30))
		DECLARE @BRANCHTABLE TABLE (AgentName VARCHAR(80), Transactions INT, Country VARCHAR(30))
		
		INSERT INTO  @CUSTOMERTABLE (AgentName, customerId) 
		SELECT ISNULL(X.agentName, 'System HO'),CM.customerId
		FROM customerMaster CM(NOLOCK) 
		LEFT JOIN (
			SELECT AU.userName, AM.agentName, AM.agentId FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		)X ON X.userName = CM.approvedBy
		WHERE CM.approvedBy IS NOT NULL
		--AND X.agentName IS NOT NULL
		AND CM.availableBalance IS NOT NULL
		--GROUP BY X.agentName, CM.customerId

		INSERT INTO @CUSTOMERTXNTABLE (AgentName, Transactions, Country)
		SELECT CT.AgentName, COUNT(1) Transactions, X.pCountry FROM @CUSTOMERTABLE CT 
		LEFT JOIN (
			SELECT TS.customerId, RT.pCountry, RT.approvedDate 
			FROM remitTran RT(NOLOCK) 
			INNER JOIN tranSenders TS(NOLOCK) ON TS.tranId = RT.id
			INNER JOIN countryMaster CM(NOLOCK) ON CM.countryName = RT.pCountry
			WHERE RT.tranType IN('O','M') and RT.tranStatus <> 'cancel'
			AND CM.countryId = ISNULL(@country, CM.countryId)
		) X ON X.customerId = CT.customerId
		WHERE X.customerId IS NOT NULL
		AND X.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		GROUP BY X.pCountry, CT.AgentName


		INSERT INTO @BRANCHTABLE (AgentName, Transactions, Country)
		SELECT AM.agentName, COUNT(1) Transactions, C.countryName 
		FROM remitTran RT(NOLOCK)
		INNER JOIN agentMaster AM(NOLOCK) ON AM.agentId = RT.SAGENT
		INNER JOIN countryMaster C(NOLOCK) ON C.countryName = RT.pCountry
		WHERE C.countryId = ISNULL(null, C.countryId)
		AND AM.agentName IS NOT NULL
		AND RT.tranType = 'I' and RT.tranStatus <> 'cancel'
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		GROUP BY  C.countryName,AM.agentName

		--INSERT INTO @BRANCHTABLE (AgentName, Transactions, Country)
		--SELECT X.agentName, COUNT(1) Transactions, C.countryName 
		--FROM remitTran RT(NOLOCK) 
		--LEFT JOIN (
		--	SELECT AU.userName, AM.agentName FROM agentMaster AM(NOLOCK) 
		--	INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
		--	WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		--)X ON X.userName = RT.createdBy
		--INNER JOIN countryMaster C(NOLOCK) ON C.countryName = RT.pCountry
		--WHERE C.countryId = ISNULL(@country, C.countryId)
		--AND X.agentName IS NOT NULL
		--AND RT.tranType = 'I' and RT.tranStatus <> 'cancel'
		--AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		--GROUP BY X.agentName, C.countryName
		
		--SELECT * FROM @CUSTOMERTXNTABLE
		--SELECT * FROM @BRANCHTABLE

		INSERT INTO @MAINTABLE (AgentName, Transactions, Country)
		SELECT DISTINCT AgentName, Transactions, Country FROM @CUSTOMERTXNTABLE UNION ALL
		SELECT DISTINCT AgentName, Transactions, Country FROM @BRANCHTABLE 
		
		SELECT [BRANCH NAME] = MT.AgentName, 
				[NATIVE COUNTRY] = MT.Country, 
				[TOTAL TRANSACTIONS] = '<a href="#" onclick="OpenInNewWindow(''/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerdetailreport&startDate=' + @startDate + '&endDate='+ @endDate + 
				'&country=' + CAST(ISNULL(Country, '') AS VARCHAR) + '&branch=' + CAST(ISNULL(AM.agentId, '') AS VARCHAR)+'&flag=detail-tran-customer'')">' + CAST(SUM(Transactions) AS VARCHAR) + '</a>'
		FROM @MAINTABLE MT
		INNER JOIN agentMaster AM(NOLOCK) ON AM.agentName = MT.AgentName
		GROUP BY MT.AgentName, MT.Country, AM.agentId

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT 'Country' head, CASE WHEN @country IS NULL THEN 'All' ELSE (SELECT countryName FROM countryMaster (NOLOCK) WHERE countryId = @country) END UNION ALL	
		SELECT 'Branch' head, ISNULL((SELECT agentName FROM agentMaster (NOLOCK) WHERE agentId = @branch), 'All') UNION ALL
		SELECT  'From Date' head, @startDate value UNION ALL
		SELECT  'To Date' head, @endDate value  

		SELECT 'Transaction Report' title
	END
	ELSE IF @flag = 'detail-tran-customer'
	BEGIN
		DECLARE @CUSTOMERTBL TABLE (customerId VARCHAR(20))

		INSERT INTO @CUSTOMERTBL (customerId)
		SELECT CM.customerId
		FROM customerMaster CM(NOLOCK)
		LEFT JOIN (
			SELECT AU.userName, AM.agentName FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		)X ON X.userName = CM.verifiedBy
		WHERE X.agentName IS NOT NULL
		AND CM.approvedBy IS NOT NULL
		AND CM.availableBalance IS NOT NULL

		SELECT [JME CONTROLNO] = DBO.decryptDb(controlNo)
				,[SENDER NAME] = senderName
				,[RECEIVER NAME] = receiverName
				,[TRANSACTION TYPE] = paymentMethod
				,[COLL AMOUNT] = RT.cAmt
				,[PAYOUT AMOUNT] = RT.pAmt
				,[PAYOUT AGENT] = RT.pAgentName
				,[PAYOUT BANK] = RT.pBankName
		FROM remitTran RT(NOLOCK)
		INNER JOIN  tranSenders TS(NOLOCK) ON TS.tranId = RT.id
		INNER JOIN @CUSTOMERTBL C ON C.customerId = TS.customerId
		WHERE RT.pCountry = ISNULL(@country, RT.pCountry)
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND RT.tranStatus <> 'Cancel'
		AND RT.tranType IN('O','M')

		UNION ALL

		SELECT [JME CONTROLNO] = DBO.decryptDb(controlNo)
				,[SENDER NAME] = senderName
				,[RECEIVER NAME] = receiverName
				,[TRANSACTION TYPE] = paymentMethod
				,[COLL AMOUNT] = RT.cAmt
				,[PAYOUT AMOUNT] = RT.pAmt
				,[PAYOUT AGENT] = RT.pAgentName
				,[PAYOUT BANK] = RT.pBankName
		FROM remitTran RT(NOLOCK)
		WHERE RT.pCountry = ISNULL(@country, RT.pCountry)
		AND RT.sAgent = ISNULL(@branch, RT.sAgent)
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND RT.tranStatus <> 'Cancel'
		AND RT.tranType = 'I'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'Country' head, ISNULL(@country, 'All')  UNION ALL	
		SELECT 'Branch' head, ISNULL((SELECT agentName FROM agentMaster (NOLOCK) WHERE agentId = @branch), 'All') UNION ALL
		SELECT  'From Date' head, @startDate value UNION ALL
		SELECT  'To Date' head, @endDate value  

		SELECT 'Transaction Detail Report' title
	END
	ELSE IF @flag = 'register-matrix'
	BEGIN
		IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL DROP TABLE #TEMP

		CREATE TABLE #TEMP (NAME VARCHAR(50), COUNTRY VARCHAR(30), QTY INT, AGENTID INT) 
		INSERT INTO #TEMP (NAME , COUNTRY , QTY, AGENTID )
		SELECT [NAME] = agentName, 
						[COUNTRY] = C.countryName, 
						[QTY] = COUNT(1),
						AGENTID = X.agentId
		FROM customerMaster CM(NOLOCK) 
		LEFT JOIN (
			SELECT AU.userName, AM.agentName, AM.agentId FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		)X ON X.userName = CM.verifiedBy
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		WHERE CM.approvedBy IS NOT NULL
		AND X.agentName IS NOT NULL
		AND CM.nativeCountry = ISNULL(@country, CM.nativeCountry)
		AND CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		GROUP BY X.agentName, C.countryName, X.agentId, C.countryName, CM.nativeCountry
		ORDER BY C.countryName

		IF NOT EXISTS(SELECT 1 FROM #TEMP)
		BEGIN
			SELECT SNO = 1, [ERROR_MESSAGE] = 'NO DATA FOUND FOR THIS FILTER'
			RETURN
		END

		DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
		SET @columns = '';
		SELECT 
			@columns += N', p.' + QUOTENAME(NAME)
		FROM (SELECT DISTINCT NAME FROM #TEMP) AS x;

		SET @columns = ', p.Country ' + @columns

		SET @sql = N'
			SELECT *
			FROM
			(
			  SELECT NAME, COUNTRY, QTY = ISNULL(QTY, 0) FROM #TEMP
			) AS j
			PIVOT
			(
			  SUM(QTY) FOR NAME IN ('
			  + STUFF(REPLACE(REPLACE(REPLACE(@columns, 'p.Country ,', ''), ', p.[', ',['), 'p.', ''), 1, 1, '')
			  + ')
			) AS p;';

		PRINT @sql;
		EXEC sp_executesql @sql;
	END
	ELSE IF @flag = 'matrix-detail'
	BEGIN
		SELECT [CUSTOMER NAME] = firstName, 
				[EMAIL] = email, 
				[REGISTERED DATE] = CM.createdDate, 
				[APPROVED DATE] = CM.verifiedDate,
				[BANK NAME] = ABL.BANK_NAME,
				[BANK ACCOUNT NUMBER] = CM.bankAccountNo,
				[WALLET ACCOUNT NUMBER] = CM.walletAccountNo,
				[AVAILBALE BALANCE] = CM.availableBalance 
		FROM customerMaster CM(NOLOCK)
		LEFT JOIN (
			SELECT AU.userName, AM.agentName FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentName = ISNULL(@branch, AM.agentName)
		)X ON X.userName = CM.verifiedBy
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		LEFT JOIN dbo.API_BANK_LIST ABL(NOLOCK) ON ABL.BANK_NAME = CM.bankName
		WHERE C.countryName = ISNULL(@country, C.countryName)
		AND X.agentName IS NOT NULL
		AND CM.approvedBy IS NOT NULL
		AND CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		select 'Country' head, @country UNION ALL	
		select 'Branch' head, @branch UNION ALL
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  
		
		SELECT 'Customer Registration Detail Report' title
	END
	ELSE IF @flag = 'trn-matrix'
	BEGIN
		SELECT RT.pCountry, COUNT(1) CNT, TS.customerId INTO #TEMPtrnmatrix
		FROM remitTran RT(NOLOCK) 
		INNER JOIN tranSenders TS(NOLOCK) ON TS.tranId = RT.id
		WHERE RT.tranType IN('O','M') and RT.tranStatus <> 'cancel'
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND RT.pCountry = ISNULL(@country, RT.pCountry)
		GROUP BY RT.pCountry,TS.customerId

		--SELECT approvedBy,* FROM customerMaster(NOLOCK) WHERE customerId=45077
		ALTER TABLE #TEMPtrnmatrix ADD BranchName VARCHAR(100)


		--SELECT ISNULL(X.agentName, 'System HO'),CM.customerId
		--FROM customerMaster CM(NOLOCK) 
		--INNER JOIN #TEMP T ON T.customerId = cm.customerId
		--LEFT JOIN (
		--	SELECT AU.userName, AM.agentName, AM.agentId FROM agentMaster AM(NOLOCK) 
		--	INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
		--	--WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		--)X ON X.userName = CM.approvedBy
		--WHERE CM.approvedBy IS NOT NULL

		UPDATE T SET T.BranchName = ISNULL(X.agentName, 'System HO') FROM customerMaster CM(NOLOCK) 
		INNER JOIN #TEMPtrnmatrix T ON T.customerId = cm.customerId
		LEFT JOIN (
			SELECT AU.userName, AM.agentName, AM.agentId FROM agentMaster AM(NOLOCK) 
			INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
			WHERE AM.agentId = ISNULL(@branch, AM.agentId)
		)X ON X.userName = CM.approvedBy
		WHERE CM.approvedBy IS NOT NULL

		UPDATE #TEMPtrnmatrix SET BRANCHNAME='Unknown Branch' WHERE BRANCHNAME IS NULL

		INSERT INTO #TEMPtrnmatrix (BRANCHNAME, CNT, pCountry)
		SELECT RT.sAgentName, COUNT(1) Transactions,RT.pCountry
		FROM remitTran RT(NOLOCK) 
		WHERE 1=1
		AND RT.pCountry= ISNULL(@country, RT.pCountry)
		AND RT.sAgent = ISNULL(@branch, RT.sAgent)
		AND RT.tranType = 'I' and RT.tranStatus <> 'cancel'
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		GROUP BY RT.sAgentName,RT.pCountry

		--INSERT INTO @MAINTABLE (AgentName, Transactions, Country)
		--SELECT BRANCHNAME,SUM(CNT) CNT,pCountry FROM #TEMP GROUP BY BRANCHNAME,pCountry 
		
		IF OBJECT_ID('tempdb..#TEMPTRN') IS NOT NULL DROP TABLE #TEMPTRN

		CREATE TABLE #TEMPTRN (NAME VARCHAR(50), COUNTRY VARCHAR(30), QTY INT) 
		
		INSERT INTO #TEMPTRN (NAME, COUNTRY, QTY)
		SELECT BRANCHNAME,pCountry,SUM(CNT) CNT FROM #TEMPtrnmatrix GROUP BY BRANCHNAME,pCountry 

		--SELECT NAME = MT.AgentName, 
		--		COUNTRY = MT.Country, 
		--		QTY = SUM(Transactions)
		--FROM @MAINTABLE MT
		--INNER JOIN agentMaster AM(NOLOCK) ON AM.agentName = MT.AgentName
		--GROUP BY MT.AgentName, MT.Country, AM.agentId

		IF NOT EXISTS(SELECT 1 FROM #TEMPTRN)
		BEGIN
			SELECT SNO = 1, [ERROR_MESSAGE] = 'NO DATA FOUND FOR THIS FILTER'
			RETURN
		END

		SET @columns = '';
		SELECT 
			@columns += N', p.' + QUOTENAME(NAME)
		FROM (SELECT DISTINCT NAME FROM #TEMPTRN) AS x;

		SET @columns = ', p.Country ' + @columns

		SET @sql = N'
			SELECT *
			FROM
			(
			  SELECT NAME, COUNTRY, QTY = ISNULL(QTY, 0) FROM #TEMPTRN
			) AS j
			PIVOT
			(
			  SUM(QTY) FOR NAME IN ('
			  + STUFF(REPLACE(REPLACE(REPLACE(@columns, 'p.Country ,', ''), ', p.[', ',['), 'p.', ''), 1, 1, '')
			  + ')
			) AS p;';

		----PRINT @sql;
		EXEC sp_executesql @sql;
	END
	ELSE IF @flag = 'matrix-trn-detail'
	BEGIN
		
		INSERT INTO @CUSTOMERTBL (customerId)
		SELECT TS.customerId
		FROM remitTran RT(NOLOCK) 
		INNER JOIN tranSenders TS(NOLOCK) ON TS.tranId = RT.id
		WHERE RT.tranType IN('O','M') and RT.tranStatus <> 'cancel'
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND RT.pCountry = ISNULL(@country, RT.pCountry)
		GROUP BY RT.pCountry,TS.customerId

		--INSERT INTO @CUSTOMERTBL (customerId)
		--SELECT CM.customerId
		--FROM customerMaster CM(NOLOCK)
		--LEFT JOIN (
		--	SELECT AU.userName, AM.agentName FROM agentMaster AM(NOLOCK) 
		--	INNER JOIN applicationUsers AU(NOLOCK) ON AU.agentId = AM.agentId
		--	WHERE AM.agentName = ISNULL(@branch, AM.agentName)
		--)X ON X.userName = CM.verifiedBy
		--WHERE X.agentName IS NOT NULL
		--AND CM.approvedBy IS NOT NULL
		--AND CM.availableBalance IS NOT NULL

		SELECT [JME CONTROLNO] = DBO.decryptDb(controlNo)
				,[SENDER NAME] = senderName
				,[RECEIVER NAME] = receiverName
				,[TRANSACTION TYPE] = paymentMethod
				,[COLL AMOUNT] = RT.cAmt
				,[PAYOUT AMOUNT] = RT.pAmt
				,[PAYOUT AGENT] = RT.pAgentName
				,[PAYOUT BANK] = RT.pBankName
		FROM remitTran RT(NOLOCK)
		INNER JOIN  tranSenders TS(NOLOCK) ON TS.tranId = RT.id
		INNER JOIN @CUSTOMERTBL C ON C.customerId = TS.customerId
		WHERE RT.pCountry = ISNULL(@country, RT.pCountry)
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND RT.tranStatus <> 'Cancel'
		AND RT.tranType IN('O','M')

		UNION ALL

		SELECT [JME CONTROLNO] = DBO.decryptDb(controlNo)
				,[SENDER NAME] = senderName
				,[RECEIVER NAME] = receiverName
				,[TRANSACTION TYPE] = paymentMethod
				,[COLL AMOUNT] = RT.cAmt
				,[PAYOUT AMOUNT] = RT.pAmt
				,[PAYOUT AGENT] = RT.pAgentName
				,[PAYOUT BANK] = RT.pBankName
		FROM remitTran RT(NOLOCK)
		WHERE RT.pCountry = ISNULL(@country, RT.pCountry)
		AND RT.sAgentName = ISNULL(@branch, RT.sAgentName)
		AND RT.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND RT.tranStatus <> 'Cancel'
		AND RT.tranType = 'I'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'Country' head, ISNULL(@country, 'All')  UNION ALL	
		SELECT 'Branch' head, ISNULL(@branch, 'All') UNION ALL
		SELECT  'From Date' head, @startDate value UNION ALL
		SELECT  'To Date' head, @endDate value  

		SELECT 'Transaction Detail Report' title
	END
END

