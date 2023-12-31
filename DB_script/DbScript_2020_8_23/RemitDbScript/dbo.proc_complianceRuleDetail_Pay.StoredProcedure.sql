USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_complianceRuleDetail_Pay]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE proc [dbo].[proc_complianceRuleDetail_Pay]
		 @user						VARCHAR(50)		= NULL
		,@tranId					BIGINT			= NULL
		,@tAmt						MONEY			= NULL
		,@customerId				INT				= NULL
		,@receiverId				VARCHAR(50)		= NULL
		,@receiverMemId				VARCHAR(30)		= NULL
		,@receiverName				VARCHAR(200)	= NULL
		,@receiverMobile			VARCHAR(50)		= NULL
		,@receiverAcNo				VARCHAR(50)		= NULL
		,@masterId					INT				= NULL
		,@paymentMethod				INT				= NULL
		,@checkingFor				CHAR(1)			= NULL		
		,@result					VARCHAR(MAX)	= NULL OUTPUT		
		,@collMode					VARCHAR(50)		= NULL
		

AS
SET NOCOUNT ON
SET XACT_ABORT ON
/*

    1> Get the data in temp table 
    2> Create the temp for condition 
    3> Dynamic query create for checking TRN TEMP Vs Condition Temp (Loop may required)
    4> Data need to shift into main table so that each tran compain histry will be maintain
    5> 
    6> Compose the message with matched criteria
    7> 

*/
BEGIN
	DECLARE		
		 @rHub		INT
		,@rAgent	INT
		,@rZip		INT
		,@rCustType INT
		,@rGroup	INT
	
	SET @result = ''
	
	
	IF ISNULL(@masterId, 0) = 0 or ISNULL(@receiverId,'') = '' AND ISNULL(@receiverMobile,'') = ''	
		RETURN
	

	CREATE TABLE #tempTran(id BIGINT PRIMARY KEY, rBranch INT, tAmt MONEY, rIdNumber VARCHAR(50),rMembershipId VARCHAR(50), receiverName VARCHAR(200), rMobile VARCHAR(50),
						approvedDate DATETIME, createdDate DATETIME, tranStatus VARCHAR(20), collMode VARCHAR(50),rAccountNo VARCHAR(50))
		
	
	DECLARE 
		 @amount			MONEY
		,@tranCount			INT
		,@period			INT
		,@nextAction		CHAR(1)
		,@txnAction			CHAR(1)
		,@denyTxn			CHAR(1)
	
		
	--IF @tranId IS NOT NULL
	--BEGIN
	--	SELECT 
	--		 @receiverId			= tr.idNumber
	--		,@receiverMemId			= membershipId
	--		,@receiverName			= trn.receiverName
	--		,@receiverMobile		= mobile
	--		,@receiverAcNo			= trn.accountNo
	--	FROM remitTran trn WITH(NOLOCK) 
	--	INNER JOIN tranReceivers tr WITH(NOLOCK) ON trn.id = tr.tranId
	--	WHERE trn.id = @tranId
	--END
	
	
	DECLARE 
		 @sql		VARCHAR(MAX)		
		,@sqlRec	VARCHAR(MAX) = ''
		,@sqlTrn	VARCHAR(MAX) = ''

	CREATE TABLE #tempCriteria(rowId INT IDENTITY(1,1), criteria INT)
	
	INSERT #tempCriteria(criteria)
	SELECT DISTINCT criteria 
	FROM csDetailRec cdr (NOLOCK)
	INNER JOIN csDetail cd (NOLOCK) ON cdr.csDetailId = cd.csDetailId
	WHERE cdr.csMasterId = @masterId 
	AND (cdr.paymentMode = @paymentMethod OR cdr.paymentMode IS NULL) 
	AND ISNULL(cdr.isEnable, 'N') = 'Y'
	AND ISNULL(cd.isEnable, 'N') = 'Y'
	
	--3. Construct String Query
	DECLARE @totalRows INT, @count INT, @criteria INT
	SET @count = 1
	SELECT @totalRows = COUNT(*) FROM #tempCriteria	
	SET @sqlRec = ' AND ('
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT @criteria = criteria FROM #tempCriteria WHERE rowId = @count

		IF((@criteria = 5003))
			SET @sqlRec = @sqlRec + ' idNumber2 = ''' + ISNULL(@receiverId, '-') + ''' OR'					
		ELSE IF((@criteria = 5004) AND ISNULL(@receiverMemId, '') <> '')
			SET @sqlRec = @sqlRec + ' membershipId = ''' + ISNULL(@receiverMemId, '') + ''' OR'		
		ELSE IF((@criteria = 5005) AND ISNULL(@receiverName, '') <> '')
			SET @sqlTrn = @sqlTrn + ' OR trn.receiverName = ''' + ISNULL(@receiverName, '') + ''''		
		ELSE IF((@criteria = 5006) AND ISNULL(@receiverMobile, '') <> '')
			SET @sqlRec = @sqlRec + ' mobile = ''' + ISNULL(@receiverMobile, '') + ''' OR'				
		ELSE IF((@criteria = 5007) AND ISNULL(@receiverAcNo, '') <> '')
			SET @sqlTrn = @sqlTrn + ' OR trn.accountNo = ''' + ISNULL(@receiverAcNo, '') + ''''

		--SET @sqlRec = @sqlRec + ' 1 = 1 OR'
		SET @count = @count + 1
	END

	--DECLARE @complianceHoldCriteria VARCHAR(MAX)	
	--SET @complianceHoldCriteria=' AND (t.rMobile = ''' + ISNULL(@receiverMobile, '') + ''' OR t.rIdNumber =''' + ISNULL(@receiverId, '') + ''')'
		
	SET @sqlRec = LEFT(@sqlRec, LEN(@sqlRec) - 2) + ')'
	DECLARE @cutOffDate VARCHAR(10) = CONVERT(VARCHAR, DATEADD(Day,-45, GETDATE()), 101)
	


	SET @sql = '
				SELECT 
					 trn.id
					,trn.pBranch
					,trn.tAmt
					,T.rIdNumber
					,T.rMembershipId
					,trn.receiverName
					,T.rMobile					
					,trn.approvedDate 
					,trn.createdDate
					,trn.tranStatus
					,trn.collMode
					,trn.accountNo
				FROM vwRemitTran trn WITH(NOLOCK)
				INNER JOIN
				(					
					SELECT 
							 tranId
							,rIdNumber	= idNumber2
							,rMobile	= mobile
							,rMembershipId = membershipId 
						FROM vwTranReceivers WITH(NOLOCK)
						WHERE 1=1 '
							+ @sqlRec +
						'
				)T ON trn.id = T.tranId
				WHERE tranStatus NOT LIKE ''%Cancel%'' 
					AND  ControlNo Not Like ''OIII%''
					AND ISNULL(approvedDate, createdDate) > ''' + @cutOffDate + ''' ' + 
					@sqlTrn + '
				'
	PRINT @sql
	INSERT INTO #tempTran
	EXEC (@sql)
	SET @sql = ''

	IF @checkingFor = 'v'
	BEGIN
		DECLARE @rBranch INT		
		SELECT @rBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user		
		
		INSERT INTO #tempTran(id, rBranch, tAmt, rIdNumber, receiverName, rMobile, createdDate, tranStatus, collMode,rAccountNo)
		SELECT 0, @rBranch, @tAmt, @receiverId, @receiverName, @receiverMobile,  dbo.FNADateFormatTZ(GETDATE(), @user), 'Payment', @collMode,@receiverAcNo
	END
	--SELECT * FROM #tempTran

	DECLARE @today DATETIME = CAST(CONVERT(VARCHAR,GETDATE(),101) AS DATETIME)
	
	CREATE TABLE #tempQuery(rowId INT IDENTITY(1,1), csDetailRecId INT, query VARCHAR(MAX))
	INSERT #tempQuery(csDetailRecId, query)	
	SELECT 
		 csDetailRecId
		,query = 'SELECT ' + CAST(csDetailRecId AS VARCHAR)+ ', '+
		CASE
			WHEN checkType = 'SUM' THEN '(ISNULL(SUM(tAmt), 0) + ' + CAST(@tAmt AS VARCHAR) + ') '
			WHEN checkType = 'COUNT' THEN
			CASE
				WHEN ISNULL(condition,4600) = 4600 THEN ' COUNT(trn.id)'	--4600 - Aggregate Rule
				WHEN condition = 4601 THEN ' COUNT(DISTINCT trn.rBranch)'	--4601 - Multiple POS
				--WHEN condition = 4602 THEN ' COUNT(DISTINCT trn.sIdNumber)'	--4602 - Multiple Beneficiary(Same Sender)
				WHEN condition = 4603 THEN ' COUNT(DISTINCT trn.rIdNumber)'	--4603 - Multiple Sender(Same Beneficiary)
			END
		END
		+
		' FROM #tempTran trn WITH(NOLOCK)
		WHERE ISNULL(approvedDate, createdDate) BETWEEN
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
			WHEN criteria = 5003 THEN ' AND trn.rIdNumber = ''' + ISNULL(@receiverId, '') + ''' GROUP BY trn.rIdNumber'
			WHEN criteria = 5004 THEN ' AND trn.rMembershipId = ''' + ISNULL(@receiverMemId, '') + ''' GROUP BY trn.rMembershipId'
			WHEN criteria = 5005 THEN ' AND trn.receiverName = ''' + ISNULL(@receiverName, '') + ''' GROUP BY trn.receiverName'
			WHEN criteria = 5006 THEN ' AND trn.rMobile = ''' + ISNULL(@receiverMobile, '') + ''' GROUP BY trn.rMobile'
			WHEN criteria = 5007 THEN ' AND trn.rAccountNo = ''' + ISNULL(@receiverAcNo, '') + ''' GROUP BY trn.rAccountNo'
		END
		+
	CASE WHEN ISNULL(parameter,0) > 0 THEN 	
		+
		' HAVING '
		+
		CASE
			WHEN checkType = 'SUM' THEN
			'(ISNULL(SUM(tAmt), 0)) '
			WHEN checkType = 'COUNT' THEN
			CASE
				WHEN ISNULL(condition,4600) = 4600 THEN ' COUNT(trn.id)'
				WHEN condition = 4601 THEN ' COUNT(DISTINCT trn.rBranch)'
				--WHEN condition = 4602 THEN ' COUNT(DISTINCT trn.sIdNumber)'
				WHEN condition = 4603 THEN ' COUNT(DISTINCT trn.rIdNumber)'
			END
		END
		+
		'>='
		+ 
		CAST(parameter AS VARCHAR)		

	ELSE ''
	END	
		+
		' UNION ALL'
		
	FROM
	(
		SELECT
			 csDetailRecId
			,cdr.csMasterId
			,cdr.condition
			,cdr.collMode
			,collModeDesc = sdv.detailTitle
			,cdr.paymentMode
			,checkType
			,parameter
			,cdr.period
			,criteria
		FROM csDetailRec cdr WITH(NOLOCK)
		INNER JOIN csDetail cd (NOLOCK) ON cdr.csDetailId = cd.csDetailId
		LEFT JOIN dbo.staticDataValue sdv WITH(NOLOCK) ON cdr.collMode = sdv.valueId
		WHERE cdr.csMasterId = @masterId 
		AND (cdr.paymentMode = @paymentMethod OR cdr.paymentMode IS NULL)
		AND ISNULL(cdr.isEnable, 'N') = 'Y'
		AND ISNULL(cd.isEnable, 'N') = 'Y'
	) X

	
	SELECT @totalRows = COUNT(*) FROM #tempQuery 
	UPDATE #tempQuery
		SET query = LEFT(query, LEN(query) - 9)
	WHERE rowId = @totalRows
	
	SELECT @sql = COALESCE(@sql + ' ', '') + query FROM #tempQuery
	
	PRINT @sql	
	
	--End of Contruct string Query--------------------------------------------------------------------------------------------------
	
	--4. String Query Execution-----------------------------------------------------------------------------------------------------
	CREATE TABLE #tempResult(rowId INT IDENTITY(1,1), csDetailRecId INT, parameter INT, matchTranId VARCHAR(MAX))
	INSERT #tempResult(csDetailRecId, parameter)
	EXEC (@sql)
	--------------------------------------------------------------------------------------------------------------------------------
	
	--5. Select compliance Detail ID and Matched TXN Id and insert into remitTranCompliance Table------------------------------------	
	DELETE FROM #tempTran WHERE ISNULL(id, 0) = 0
	
	IF EXISTS(SELECT 'X' FROM #tempResult)
	BEGIN
		DECLARE @csDetailRecId INT, @tranIds VARCHAR(MAX)
		
		SELECT @totalRows = COUNT(*) FROM #tempResult
		--SELECT * from #tempResult -- test query
		--select * from #tempTran --test query
		SET @count = 1
		WHILE(@count <= @totalRows)
		BEGIN
			
			SELECT @csDetailRecId = csDetailRecId FROM #tempResult WHERE rowId = @count
			SELECT @period = period, @nextAction = nextAction FROM csDetailRec WITH(NOLOCK) WHERE csDetailRecId = @csDetailRecId
			SELECT @tranIds = COALESCE(ISNULL(@tranIds + ',', ''), '') + CAST(id AS VARCHAR) FROM #tempTran WHERE 
								ISNULL(approvedDate, createdDate) BETWEEN CONVERT(VARCHAR, DATEADD(D, -(@period-1), @today), 101)
								AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59:998'
								
			
			IF ISNULL(@nextAction, 'H') = 'M' AND ISNULL(@txnAction, '') <> 'B' AND ISNULL(@txnAction, '') <> 'C'
				SET @txnAction = 'M'
			
			IF ISNULL(@nextAction, 'H') = 'H' AND ISNULL(@txnAction, '') <> 'B' 
				SET @txnAction = 'C'
				
			IF ISNULL(@nextAction, 'H') = 'B' 
				SET @txnAction = 'C'--'B' -- No need to block txn in pay side
			
			IF @checkingFor = 'i'
			BEGIN
				INSERT remitTranCompliancePay(tranId, csDetailTranId, matchTranId)
				SELECT @tranId, @csDetailRecId, @tranIds
			END
			ELSE IF @checkingFor = 'v'
			BEGIN
				INSERT remitTranCompliancePayTemp(csDetailTranId, matchTranId, tranId)
				SELECT @csDetailRecId, @tranIds, @tranId
			END
			
			SET @tranIds = NULL
			SET @count = @count + 1
		END
		
		SET @result = @txnAction
				
	END
END



GO
