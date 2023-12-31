USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_idRuleDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_idRuleDetail]
		 @user				VARCHAR(50)		= NULL
		,@tranId			BIGINT			= NULL
		,@tAmt				MONEY			= NULL
		,@senId				INT				= NULL		
		,@masterId			INT				= NULL
		,@paymentMethod		INT				= NULL
		,@checkingFor		CHAR(1)			= NULL
		,@agentRefId		VARCHAR(50)		= NULL	
		,@senderId			VARCHAR(50)		= NULL
		,@senderMemId		VARCHAR(30)		= NULL
		,@senderName		VARCHAR(200)	= NULL
		,@senderMobile		VARCHAR(50)		= NULL
		,@isOnlineTxn		CHAR(1)			= NULL
		,@collMode			VARCHAR(50)		= NULL
		,@result			VARCHAR(MAX)	= NULL OUTPUT

AS
SET NOCOUNT ON



BEGIN TRY
	DECLARE
		 @sHub		INT 
		,@sCountry	INT
		,@sAgent	INT
		,@sZip		INT
		,@sCustType INT
		,@sState	INT
		,@sGroup	INT

		,@rHub		INT
		,@rAgent	INT
		,@rZip		INT
		,@rCustType INT
		,@rGroup	INT
	
	IF @senderId IS NULL AND @senderMobile IS NULL
	BEGIN
		RETURN
	END

	IF ISNULL(@masterId, 0) = 0
		RETURN
	
	CREATE TABLE #tempcisTran(id BIGINT, sBranch INT, tAmt MONEY, sIdNumber VARCHAR(50), senderName VARCHAR(200), sMobile VARCHAR(50),						
						approvedDate DATETIME, createdDate DATETIME, tranStatus VARCHAR(20), collMode VARCHAR(50))
	
	--IF @senId IS NOT NULL
	--	SELECT @sCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @senId
	
		
	DECLARE		
		 @amount			MONEY
		,@tranCount			INT
		,@period			INT
		,@nextAction		CHAR(1)
		,@txnAction			CHAR(1)
		,@denyTxn			CHAR(1)
	
	-->>Get Sender and Receiver Detail
	IF @senId IS NOT NULL
	BEGIN
		SELECT 
			 @senderId		= cust.citizenshipNo
			,@senderMemId	= membershipId
			,@senderName	= firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + LastName, '')
			,@senderMobile	= mobile 
		FROM customerMaster cust WITH(NOLOCK) 
		WHERE cust.customerId = @senId
	END
		
	DECLARE 
		 @sql			VARCHAR(MAX)
		,@sqlSen		VARCHAR(MAX) = ''
		,@sqlSenTran	VARCHAR(MAX) = ''
		,@sqlTrn		VARCHAR(MAX) = ''
	
	

	CREATE TABLE #tempcisCriteria(rowId INT IDENTITY(1,1), criteria INT)
	INSERT #tempcisCriteria(criteria)
	SELECT '5000' UNION
	SELECT '5001' UNION
	SELECT '5002'	
	--SELECT DISTINCT criteria FROM cisDetailRec cdr WHERE cdr.cisMasterId = @masterId AND (paymentMode = @paymentMethod OR paymentMode IS NULL) AND ISNULL(isEnable, 'N') = 'Y'
	
	--3. Construct String Query
	DECLARE @totalRows INT, @count INT, @criteria INT
	SET @count = 1
	SELECT @totalRows = COUNT(*) FROM #tempcisCriteria
	SET @sqlSen = ' AND ('
	SET @sqlSenTran = ' AND ('
	
	WHILE(@count <= @totalRows)
	BEGIN
	
		SELECT @criteria = criteria FROM #tempcisCriteria WHERE rowId = @count

		IF((@criteria = 5000) AND ISNULL(@senderId,'') <> '')
		BEGIN
			SET @sqlSen = @sqlSen + ' idNumber = ''' + ISNULL(@senderId, '-') + ''' OR'
			SET @sqlSenTran = @sqlSenTran + ' sIdNumber = ''' + ISNULL(@senderId, '-') + ''' OR'
			
		END
		--ELSE IF((@criteria = 5001) AND ISNULL(@senderName, '') <> '')
		--	SET @sqlTrn = @sqlTrn + ' AND trn.senderName = ''' + ISNULL(@senderName, '') + ''''

		ELSE IF((@criteria = 5002) AND ISNULL(@senderMobile, '') <> '')
		BEGIN
			SET @sqlSen = @sqlSen + ' mobile = ''' + ISNULL(@senderMobile, '') + ''' OR'
			SET @sqlSenTran = @sqlSenTran + ' sMobile = ''' + ISNULL(@senderMobile, '') + ''' OR'
		END
		SET @count = @count + 1

	END
	
	SET @sqlSen = LEFT(@sqlSen, LEN(@sqlSen) - 2) + ')'
	SET @sqlSenTran = LEFT(@sqlSenTran, LEN(@sqlSenTran) - 2) + ')'


	DECLARE @cutOffDate VARCHAR(10) = CONVERT(VARCHAR, DATEADD(Day,-45, GETDATE()), 101)
	SET @sql = '
				SELECT 
					 trn.id
					,trn.sBranch
					,trn.tAmt
					,T.sIdNumber
					,trn.senderName
					,T.sMobile									
					,trn.approvedDate 
					,trn.createdDate
					,trn.tranStatus
					,trn.collMode
				FROM vwRemitTran trn WITH(NOLOCK)
				INNER JOIN
				(					
					SELECT 
						 tranId		
						,sIdNumber	= idNumber 
						,sMobile	= mobile
					FROM vwTranSenders WITH(NOLOCK)
					WHERE 1=1 ' 
						+ @sqlSen + 
					'					
				)T ON trn.id = T.tranId
				WHERE tranStatus NOT LIKE ''Cancel%'' 
					AND ControlNo Not Like ''OIII%'' ' + @sqlTrn + ' '+ @sqlSenTran +' 				
					AND ISNULL(approvedDate, createdDate) > '' ' + @cutOffDate + ''''
	--PRINT @SQL	
	INSERT INTO #tempcisTran
	EXEC (@sql)
	SET @sql = ''
		
	IF @checkingFor = 'v'
	BEGIN
		DECLARE @sBranch INT		
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user		
		
		INSERT INTO #tempcisTran(id, sBranch, tAmt, sIdNumber, senderName, sMobile,  createdDate, tranStatus, collMode)
		SELECT 0, @sBranch, @tAmt, @senderId, @senderName, @senderMobile, dbo.FNADateFormatTZ(GETDATE(), @user), 'Payment', @collMode
	END
	
	DECLARE @today DATETIME = CAST(CONVERT(VARCHAR,GETDATE(),101) AS DATETIME)

	CREATE TABLE #tempcisQuery(rowId INT IDENTITY(1,1), cisDetailId INT, query VARCHAR(MAX))
	INSERT #tempcisQuery(cisDetailId, query)
	SELECT 
		 cisDetailId
		,query = 'SELECT ' + CAST(cisDetailId AS VARCHAR)+ ', SUM(ISNULL(tAmt,0)) ' +		
			
			CASE
				WHEN ISNULL(condition,4600) = 4600 THEN ' ,COUNT(trn.id)'					--4600 - Aggregate Rule				
				WHEN condition = 4602 THEN ' ,COUNT(DISTINCT trn.sIdNumber)'	--4602 - Multiple Beneficiary(Same Sender)
				
				
			END
		
		+','+ CAST(criteria AS VARCHAR) +'AS criteria'+

		' FROM #tempcisTran trn WITH(NOLOCK)
		WHERE tranStatus NOT LIKE ''%Cancel%'' AND ISNULL(approvedDate, createdDate) BETWEEN
		'''
		+ 
		CASE WHEN ISNULL(period,0) = 0 THEN '1900-01-01' ELSE CONVERT(VARCHAR, DATEADD(D, -(period-1), @today), 101)  END
		+ ''' AND '''
		+ CASE WHEN ISNULL(period,0) = 0 THEN '2100-12-31' ELSE CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59:998' END
		+ ''''
		+
		CASE WHEN collModeDesc IS NOT NULL THEN ' AND trn.collMode = ''' + collModeDesc + '''' ELSE '' END
		+
		CASE
			WHEN criteria = 5000 THEN ' AND trn.sIdNumber = ''' + ISNULL(@senderId, '') + ''' GROUP BY trn.sIdNumber'
			WHEN criteria = 5001 THEN ' AND trn.senderName = ''' + ISNULL(@senderName, '') + ''' GROUP BY trn.senderName'
			WHEN criteria = 5002 THEN ' AND trn.sMobile = ''' + ISNULL(@senderMobile, '') + ''' GROUP BY trn.sMobile'			
		END
		+
		' HAVING (ISNULL(SUM(tAmt), 0)) >='+CAST(ISNULL(amount,0) AS VARCHAR) 
		+
		
		CASE
				WHEN ISNULL(condition,4600) = 4600 THEN ' AND COUNT(trn.id) >= ' + CAST(tranCount AS VARCHAR)				
				WHEN condition = 4602 THEN ' AND COUNT(DISTINCT trn.sIdNumber) >= ' + CAST(tranCount AS VARCHAR)
				
				ELSE ' '
		END		
				
		+
		' UNION ALL'
	FROM
	(
		SELECT
			 cisDetailId
			,cisMasterId
			,condition
			,collMode
			,collModeDesc = sdv.detailTitle
			,paymentMode
			,ISNULL(tranCount,0) tranCount
			,amount
			,period
			,criteria				
		FROM cisDetail cdr WITH(NOLOCK)
		LEFT JOIN dbo.staticDataValue sdv WITH(NOLOCK) ON cdr.collMode = sdv.valueId
		,#tempcisCriteria		
		WHERE cisMasterId = @masterId 
		AND (paymentMode = @paymentMethod OR paymentMode IS NULL)
		AND ISNULL(isEnable, 'N') = 'Y'
	) X

	SELECT @totalRows = COUNT(*) FROM #tempcisQuery 
	UPDATE #tempcisQuery
		SET query = LEFT(query, LEN(query) - 9)
	WHERE rowId = @totalRows
	
	SELECT @sql = COALESCE(@sql + ' ', '') + query FROM #tempcisQuery
	
			
	--4. String Query Execution-----------------------------------------------------------------------------------------------------
	CREATE TABLE #tempcisResult(rowId INT IDENTITY(1,1), cisDetailId INT, Amount MONEY,TxnCount INT,criteria VARCHAR(25))
	
	INSERT #tempcisResult(cisDetailId, Amount,TxnCount,criteria)
	EXEC (@sql)
	--------------------------------------------------------------------------------------------------------------------------------		
	--SELECT * FROM #tempcisResult
	SELECT  @result = ISNULL(@result+',','') + CAST(cisDetailId AS VARCHAR(20)) FROM #tempcisResult

END TRY
BEGIN CATCH     
     SELECT @result = ERROR_MESSAGE() 
END CATCH


GO
