USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_complianceRuleDetail]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_complianceRuleDetail]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].proc_complianceRuleDetail
GO
*/	
/*
DECLARE @result1 VARCHAR(MAX)
EXEC proc_complianceRuleDetail 'rajiv', '297493', 1200, 45, 22, NULL, 2, @result = @result1 OUTPUT
PRINT @result1

*/

CREATE proc [dbo].[ws_int_proc_complianceRuleDetail]
		 @user				VARCHAR(50)		= NULL
		,@tranId			BIGINT			= NULL
		,@tAmt				MONEY			= NULL
		,@senId				INT				= NULL
		,@benId				INT				= NULL
		,@beneficiaryName	VARCHAR(200)	= NULL
		,@beneficiaryMobile VARCHAR(50)		= NULL
		,@benAccountNo		VARCHAR(50)		= NULL
		,@masterId			INT				= NULL
		,@paymentMethod		INT				= NULL
		,@checkingFor		CHAR(1)			= NULL
		,@agentRefId		VARCHAR(20)		= NULL
		,@result			VARCHAR(MAX)	= NULL OUTPUT
		,@senderId			VARCHAR(30)		= NULL
		,@senderMemId		VARCHAR(20)		= NULL
		,@senderName		VARCHAR(100)	= NULL
		,@senderMobile		VARCHAR(30)		= NULL

AS
SET NOCOUNT ON
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
	
	SET @result = ''
	IF ISNULL(@masterId, 0) = 0
		RETURN
	
	CREATE TABLE #tempTran(id BIGINT, sBranch INT, tAmt MONEY, sIdNumber VARCHAR(50), senderName VARCHAR(200), sMobile VARCHAR(50),
						rIdNumber VARCHAR(50), receiverName VARCHAR(100), rMobile VARCHAR(50), rMembershipId VARCHAR(50), accountNo VARCHAR(100),
						approvedDate DATETIME, createdDate DATETIME, tranStatus VARCHAR(20))
	
	IF @senId IS NOT NULL
		SELECT @sCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @senId
	
	IF @benId IS NOT NULL
		SELECT @rCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @benId
	
	DECLARE 
		 @beneficiaryId		VARCHAR(30)
		,@beneficiaryMemId	VARCHAR(20)
		,@beneficiaryAcNo	VARCHAR(50)
		
		,@amount			MONEY
		,@tranCount			INT
		,@period			INT
	
	-->>Get Sender and Receiver Detail
	IF @senId IS NOT NULL
	BEGIN
		SELECT 
			 @senderId		= cust.idNumber
			,@senderMemId	= membershipId
			,@senderName	= cust.fullName
			,@senderMobile	= mobile 
		FROM customers cust WITH(NOLOCK) 
		WHERE cust.customerId = @senId
	END
	
	IF @tranId IS NOT NULL
	BEGIN
		SELECT 
			 @beneficiaryId			= TR.idNumber
			,@beneficiaryMemId		= membershipId
			,@beneficiaryName		= trn.receiverName
			,@beneficiaryMobile		= mobile
			,@beneficiaryAcNo		= trn.accountNo
		FROM remitTran trn WITH(NOLOCK) 
		INNER JOIN tranReceivers TR WITH(NOLOCK) ON trn.id = TR.tranId
		WHERE trn.id = @tranId
	END
	
	SELECT @beneficiaryAcNo = @benAccountNo
	
	DECLARE 
		 @sql		VARCHAR(MAX)
		,@sqlSen	VARCHAR(MAX) = ''
		,@sqlRec	VARCHAR(MAX) = ''
		,@sqlTrn	VARCHAR(MAX) = ''

	CREATE TABLE #tempCriteria(rowId INT IDENTITY(1,1), criteria INT)
	INSERT #tempCriteria(criteria)
	SELECT DISTINCT criteria FROM csDetailRec cdr WHERE cdr.csMasterId = @masterId AND (paymentMode = @paymentMethod OR paymentMode IS NULL)
	
	--3. Construct String Query
	DECLARE @totalRows INT, @count INT, @criteria INT
	SET @count = 1
	SELECT @totalRows = COUNT(*) FROM #tempCriteria
	SET @sqlSen = ' AND ('
	SET @sqlRec = ' AND ('
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT @criteria = criteria FROM #tempCriteria WHERE rowId = @count
		IF((@criteria = 5000) AND ISNULL(@senderId, '') <> '')
			SET @sqlSen = @sqlSen + ' idNumber = ''' + @senderId + ''' OR'
		ELSE IF((@criteria = 5001) AND ISNULL(@senderName, '') <> '')
			SET @sqlTrn = @sqlTrn + ' OR trn.senderName = ''' + ISNULL(@senderName, '') + ''''
		ELSE IF((@criteria = 5002) AND ISNULL(@senderMobile, '') <> '')
			SET @sqlSen = @sqlSen + ' mobile = ''' + ISNULL(@senderMobile, '') + ''' OR'
		ELSE IF((@criteria = 5005) AND ISNULL(@beneficiaryName, '') <> '')
			SET @sqlTrn = @sqlTrn + ' OR trn.receiverName = ''' + ISNULL(@beneficiaryName, '') + ''''
		ELSE IF((@criteria = 5006) AND ISNULL(@beneficiaryMobile, '') <> '')
			SET @sqlRec = @sqlRec + ' mobile = ''' + ISNULL(@beneficiaryMobile, '') + ''' OR'
		ELSE IF((@criteria = 5007) AND ISNULL(@beneficiaryAcNo, '') <> '')
			SET @sqlTrn = @sqlTrn + ' OR trn.accountNo = ''' + ISNULL(@beneficiaryAcNo, '') + ''''

			SET @sqlRec = @sqlRec + ' 1 = 1 OR'
		SET @count = @count + 1
	END

	SET @sqlSen = LEFT(@sqlSen, LEN(@sqlSen) - 2) + ')'
	SET @sqlRec = LEFT(@sqlRec, LEN(@sqlRec) - 2) + ')'

	IF OBJECT_ID(N'tempdb..##tempTran') IS NOT NULL
	BEGIN
		DROP TABLE ##tempTran
	END
	
	SET @sql = '
				SELECT 
					 trn.id
					,trn.sBranch
					,trn.tAmt
					,T.sIdNumber
					,trn.senderName
					,T.sMobile
					,T.rIdNumber
					,trn.receiverName
					,T.rMobile
					,T.rMembershipId
					,trn.accountNo
					,trn.approvedDate 
					,trn.createdDate
					,trn.tranStatus
				FROM vwRemitTran trn WITH(NOLOCK)
				INNER JOIN
				(
					SELECT tranId = ISNULL(sen.tranId, rec.tranId), sen.sIdNumber, sen.sMobile, rec.rIdNumber, rec.rMobile, rec.rMembershipId FROM
					(
						SELECT 
							 tranId
							,sIdNumber	= idNumber 
							,sMobile	= mobile
						FROM vwTranSenders WITH(NOLOCK)
						WHERE 1=1 ' 
							+ @sqlSen + 
						'
					)sen
					JOIN
					(
						SELECT 
							 tranId
							,rIdNumber	= idNumber
							,rMobile	= mobile
							,rMembershipId = membershipId 
						FROM vwTranReceivers WITH(NOLOCK)
						WHERE 1=1 '
							+ @sqlRec +
						'
					)rec ON sen.tranId = rec.tranId
				)T ON trn.id = T.tranId
				WHERE 1=1 ' + @sqlTrn + '
				'
	PRINT @sql
	INSERT INTO #tempTran
	EXEC (@sql)
	SET @sql = ''

	IF @checkingFor = 'v'
	BEGIN
		DECLARE @sBranch INT
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		INSERT INTO #tempTran(id, sBranch, tAmt, sIdNumber, senderName, sMobile, rIdNumber, receiverName, rMobile, rMembershipId, accountNo, createdDate, tranStatus)
		SELECT NULL, @sBranch, @tAmt, @senderId, @senderName, @senderMobile, @beneficiaryId, @beneficiaryName, @beneficiaryMobile, @beneficiaryMemId, @beneficiaryAcNo, dbo.FNADateFormatTZ(GETDATE(), @user), 'Payment'
	END
	
	CREATE TABLE #tempQuery(rowId INT IDENTITY(1,1), csDetailRecId INT, query VARCHAR(MAX))
	INSERT #tempQuery(csDetailRecId, query)	
	SELECT 
		 csDetailRecId
		,query = 'SELECT ' + CAST(csDetailRecId AS VARCHAR)+ ', '+
		CASE
			WHEN checkType = 'SUM' THEN '(ISNULL(SUM(tAmt), 0) + ' + CAST(@tAmt AS VARCHAR) + ') '
			WHEN checkType = 'COUNT' THEN
			CASE
				WHEN condition = 4600 THEN ' COUNT(trn.id)'					--4600 - Aggregate Rule
				WHEN condition = 4601 THEN ' COUNT(DISTINCT trn.sBranch)'	--4601 - Multiple POS
				WHEN condition = 4602 THEN ' COUNT(DISTINCT trn.sIdNumber)'	--4602 - Multiple Beneficiary(Same Sender)
				WHEN condition = 4603 THEN ' COUNT(DISTINCT trn.rIdNumber)'	--4603 - Multiple Sender(Same Beneficiary)
			END
		END
		+
		' FROM #tempTran trn WITH(NOLOCK)
		WHERE tranStatus NOT LIKE ''%Cancel%'' AND ISNULL(approvedDate, createdDate) BETWEEN
		'''
		+ 
		CASE WHEN period = 0 THEN '1900-01-01' ELSE CONVERT(VARCHAR,DATEADD(D,-PERIOD,GETDATE()),101) END
		+ ''' AND '''
		+ CASE WHEN period = 0 THEN '2100-12-31' ELSE CONVERT(VARCHAR,GETDATE(),101) + ' 23:59:59' END
		+ ''''
		+
		CASE
			WHEN criteria = 5000 THEN ' AND trn.sIdNumber = ''' + ISNULL(@senderId, '') + ''' GROUP BY trn.sIdNumber'
			WHEN criteria = 5001 THEN ' AND trn.senderName = ''' + ISNULL(@senderName, '') + ''' GROUP BY trn.senderName'
			WHEN criteria = 5002 THEN ' AND trn.sMobile = ''' + ISNULL(@senderMobile, '') + ''' GROUP BY trn.sMobile'
			WHEN criteria = 5003 THEN ' AND trn.rIdNumber = ''' + ISNULL(@beneficiaryId, '') + ''' GROUP BY trn.rIdNumber'
			WHEN criteria = 5004 THEN ' AND trn.rMembershipId = ''' + ISNULL(@beneficiaryMemId, '') + ''' GROUP BY trn.rMembershipId'
			WHEN criteria = 5005 THEN ' AND trn.receiverName = ''' + ISNULL(@beneficiaryName, '') + ''' GROUP BY trn.receiverName'
			WHEN criteria = 5006 THEN ' AND trn.rMobile = ''' + ISNULL(@beneficiaryMobile, '') + ''' GROUP BY trn.rMobile'
			WHEN criteria = 5007 THEN ' AND trn.accountNo = ''' + ISNULL(@beneficiaryAcNo, '') + ''' GROUP BY trn.accountNo'
		END
		+
		' HAVING '
		+
		CASE
			WHEN checkType = 'SUM' THEN
			'(ISNULL(SUM(tAmt), 0)) '
			WHEN checkType = 'COUNT' THEN
			CASE
				WHEN condition = 4600 THEN ' COUNT(trn.id)'
				WHEN condition = 4601 THEN ' COUNT(DISTINCT trn.sBranch)'
				WHEN condition = 4602 THEN ' COUNT(DISTINCT trn.sIdNumber)'
				WHEN condition = 4603 THEN ' COUNT(DISTINCT trn.rIdNumber)'
			END
		END
		+
		'>='
		+ 
		CAST(PARAMETER AS VARCHAR)
		+
		' UNION ALL'
	FROM
	(
		SELECT
			 csDetailRecId
			,csMasterId
			,condition
			,collMode
			,paymentMode
			,checkType
			,PARAMETER
			,period
			,criteria
		FROM csDetailRec 
		WHERE csMasterId = @masterId 
		AND (paymentMode = @paymentMethod OR paymentMode IS NULL)
	) X

	SELECT @totalRows = COUNT(*) FROM #tempQuery 
	UPDATE #tempQuery
		SET query = LEFT(query, LEN(query) - 9)
	WHERE rowId = @totalRows
	
	SELECT @sql = COALESCE(@sql + ' ', '') + query FROM #tempQuery
	--SELECT @sql 
	--RETURN
	--End of Contruct string Query--------------------------------------------------------------------------------------------------
	
	--4. String Query Execution-----------------------------------------------------------------------------------------------------
	CREATE TABLE #tempResult(rowId INT IDENTITY(1,1), csDetailRecId INT, PARAMETER INT, matchTranId VARCHAR(MAX))
	INSERT #tempResult(csDetailRecId, PARAMETER)
	EXEC (@sql)
	--------------------------------------------------------------------------------------------------------------------------------
	
	--5. Select compliance Detail ID and Matched TXN Id and insert into remitTranCompliance Table------------------------------------
	DELETE FROM remitTranComplianceTemp WHERE agentRefId = @agentRefId
	DELETE FROM #tempTran WHERE id IS NULL
	--SELECT * FROM ##tempTran
	IF EXISTS(SELECT 'X' FROM #tempResult)
	BEGIN
		DECLARE @csDetailRecId INT, @tranIds VARCHAR(MAX)
		
		SELECT @totalRows = COUNT(*) FROM #tempResult
		/*
		UPDATE #tempResult SET
			 matchTranId = (SELECT COALESCE(ISNULL(matchTranId + ', ', ''), '') + CAST(id AS VARCHAR) FROM ##tempTran tt WHERE tt.createdDate BETWEEN DATEADD(D, -c.period, GETDATE()) AND GETDATE() + '23:59:59')
		FROM #tempResult t
		INNER JOIN csDetailRec c ON t.csDetailRecId = c.csDetailRecId
		
		IF @checkingFor = 'i'
		BEGIN
			INSERT remitTranCompliance(TranId, csDetailTranId, matchTranId)
			SELECT @tranId, csDetailRecId, matchTranId FROM #tempResult
		END
		ELSE IF @checkingFor = 'v'
		BEGIN
			INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
			SELECT csDetailRecId, matchTranId, @agentRefId FROM #tempResult
		END
		*/
		
		SET @count = 1
		WHILE(@count <= @totalRows)
		BEGIN
			SELECT @csDetailRecId = csDetailRecId FROM #tempResult WHERE rowId = @count
			SELECT @period = period FROM csDetailRec WITH(NOLOCK) WHERE csDetailRecId = @csDetailRecId
			SELECT @tranIds = COALESCE(ISNULL(@tranIds + ',', ''), '') + CAST(id AS VARCHAR) FROM #tempTran WHERE createdDate BETWEEN DATEADD(D,-@period,GETDATE()) AND GETDATE() + '23:59:59'
			
			IF @checkingFor = 'i'
			BEGIN
				INSERT remitTranCompliance(TranId, csDetailTranId, matchTranId)
				SELECT @tranId, @csDetailRecId, @tranIds
			END
			ELSE IF @checkingFor = 'v'
			BEGIN
				INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
				SELECT @csDetailRecId, @tranIds, @agentRefId
			END
			
			SET @tranIds = NULL
			SET @count = @count + 1
		END
		
		SET @result = 'C'
	END
END

--ALTER TABLE remitTranComplianceTemp ALTER COLUMN matchTranId VARCHAR(MAX)

GO
