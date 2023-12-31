USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_CUSTOMER_APPROVE_USER_WISE]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_CUSTOMER_APPROVE_USER_WISE]
(
	@flag			VARCHAR(20)	= NULL
	,@startDate		VARCHAR(30) = NULL
	,@endDate		VARCHAR(30) = NULL
	,@user			VARCHAR(30) = NULL
	,@country		VARCHAR(30) = NULL
	,@approvedBy	VARCHAR(80)	= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @flag = 'rpt'
	BEGIN
		--SELECT ALL CUSTOMER'S IN THAT RANGE
		SELECT CM.approvedBy APPROVED_BY, C.countryName NATIVE_COUNTRY, COUNT(1) QTY INTO #CUSTOMER_TEMP
		FROM customerMaster CM(NOLOCK)
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		WHERE CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND CM.approvedBy = ISNULL(@approvedBy, CM.approvedBy)
		AND CM.nativeCountry = ISNULL(@country, CM.nativeCountry)
		AND CM.approvedBy IS NOT NULL
		GROUP BY CM.approvedBy, C.countryName

		ALTER TABLE #CUSTOMER_TEMP ADD APPROVED_BY_FULL_NAME VARCHAR(150)

		UPDATE T SET T.APPROVED_BY_FULL_NAME = A.firstName + ISNULL(' ' + A.middleName, '') + ISNULL(' ' + A.lastName, '') 
		FROM #CUSTOMER_TEMP T
		LEFT JOIN applicationUsers A(NOLOCK) ON A.userName = T.APPROVED_BY


		IF NOT EXISTS(SELECT TOP 1 * FROM #CUSTOMER_TEMP)
		BEGIN
			SELECT SNO = 1, [ERROR_MESSAGE] = 'NO DATA FOUND FOR THIS FILTER'
			RETURN
		END

		DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
		SET @columns = '';
		SELECT 
			@columns += N', p.' + QUOTENAME(NATIVE_COUNTRY)
		FROM (SELECT DISTINCT NATIVE_COUNTRY FROM #CUSTOMER_TEMP) AS x;

		SET @columns = ', p.Country ' + @columns

		SET @sql = N'
			SELECT *
			FROM
			(
			  SELECT APPROVED_BY_FULL_NAME, APPROVED_BY, NATIVE_COUNTRY, QTY = ISNULL(QTY, 0) FROM #CUSTOMER_TEMP
			) AS j
			PIVOT
			(
			  SUM(QTY) FOR NATIVE_COUNTRY IN ('
			  + STUFF(REPLACE(REPLACE(REPLACE(@columns, 'p.Country ,', ''), ', p.[', ',['), 'p.', ''), 1, 1, '')
			  + ')
			) AS p;';

		
		EXEC sp_executesql @sql;

	END
	ELSE IF @flag = 'summary'
	BEGIN
		SELECT CM.approvedBy APPROVER_USER_NAME, COUNT(1) [NUMBER_OF_CUSTOMERS] INTO #TEMP
		FROM customerMaster CM(NOLOCK) 
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		WHERE CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND CM.approvedBy = ISNULL(@approvedBy, CM.approvedBy)
		AND CM.nativeCountry = ISNULL(@country, CM.nativeCountry)
		AND CM.approvedBy IS NOT NULL
		GROUP BY CM.approvedBy

		ALTER TABLE #TEMP ADD APPROVER_NAME VARCHAR(100)

		UPDATE T SET T.APPROVER_NAME = A.firstName + ISNULL(' ' + A.middleName, '') + ISNULL(' ' + A.lastName, '')
		FROM #TEMP T
		LEFT JOIN applicationUsers A(NOLOCK) ON  A.userName = T.APPROVER_USER_NAME

		SELECT APPROVER_NAME, APPROVER_USER_NAME, [NUMBER_OF_CUSTOMERS] FROM #TEMP
		ORDER BY [NUMBER_OF_CUSTOMERS] DESC

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		select 'Country' head, CASE WHEN @country IS NULL THEN 'All' ELSE (SELECT countryName FROM countryMaster (NOLOCK) WHERE countryId = @country) END UNION ALL	
		select 'Approved By' head, ISNULL(@approvedBy, 'All') UNION ALL
		SELECT  'From Date' head, @startDate value UNION ALL
		SELECT  'To Date' head, @endDate value  
		
		SELECT 'Customer Registration Summary' title
	END
	ELSE IF @flag = 'detail'
	BEGIN
		SELECT firstName [CUSTOMER_NAME], email [CUSTOMER_EMAIL], mobile [CUSTOMER_MOBILE], C.countryName [NATIVE_COUNTRY]
		FROM customerMaster CM(NOLOCK)
		INNER JOIN countryMaster C(NOLOCK) ON C.countryId = CM.nativeCountry
		WHERE CM.approvedDate BETWEEN @startDate AND @endDate + ' 23:59:59'
		AND CM.approvedBy = @approvedBy
		AND C.countryName = @country
		AND CM.approvedBy IS NOT NULL

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		select 'Country' head, ISNULL(@country, 'All') UNION ALL
		select 'Approved By' head, ISNULL(@approvedBy, 'All') UNION ALL
		SELECT  'From Date' head, @startDate value UNION ALL
		SELECT  'To Date' head, @endDate value  
		
		SELECT 'Customer Registration Detail Report' title
	END
END


--PROC_CUSTOMER_APPROVE_USER_WISE @flag = 'rpt',@startDate= '2018-01-01',@endDate	= '2018-01-28',@user= 'ADMIN',@country= NULL,@approvedBy= NULL
--proc_customerReport @flag = 'register-matrix',@startDate= '2018-01-01',@endDate	= '2018-01-28',@user= 'ADMIN',@country= NULL,@branch= NULL


--EXEC PROC_CUSTOMER_APPROVE_USER_WISE @flag = 'rpt',@user = 'admin',@startDate = '12/01/2017',@endDate = '7/10/2018',@country = null,@approvedBy = null

--EXEC PROC_CUSTOMER_APPROVE_USER_WISE @flag = 'detail',@user = 'admin',@startDate = '04/01/2018',@endDate = '7/10/2018',@country = 'Cambodia',@approvedBy = 'anisham'

GO
