
ALTER PROC PROC_COMPLIANCE_CHECKING_NEW
(
	@flag				VARCHAR(30)		= 'core'  
	 ,@user				VARCHAR(50)    
	 ,@pCountryId		INT  
	 ,@deliveryMethod	INT   
	 ,@amount			MONEY			= null  
	 ,@customerId		VARCHAR(20)     
	 ,@receiverName		VARCHAR(50)		= NULL  
	 ,@sIdNo			VARCHAR(50)     = NULL   
	 ,@sIdType			VARCHAR(50)		= NULL  
	 ,@receiverMobile	VARCHAR(25)		= NULL  
	 ,@message			VARCHAR(1000)	= NULL
	 ,@shortMessage		VARCHAR(100)	= NULL
	 ,@errCode			TINYINT			= NULL
	 ,@ruleId			INT				= NULL
	 ,@professionId		INT				= NULL
	 ,@accountNo		VARCHAR(30)		= NULL
	 ,@receiverId		BIGINT			= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @perTxnLimitAmt MONEY  
	DECLARE @limitAmt MONEY, @comRuleId INT, @ruleType CHAR(1), @periodInDays INT, @isDocRequired BIT
	DECLARE @limitAmtAgg MONEY, @comRuleIdAgg INT, @ruleTypeAgg CHAR(1) 
	DECLARE @limitAmtProfession MONEY, @comRuleIdProfession INT, @ruleTypeProfession CHAR(1)  
	DECLARE @csMasterId INT  
	DECLARE @YearStart DATE, @YearEnd DATE, @MonthStart DATE, @MonthEnd DATE
	 
	CREATE TABLE #TBL_COMPLIANCE(COMM_RULE_ID INT, LIMIT_AMT MONEY, RULE_TYPE CHAR(1), PERIOD_DAYS INT, R_COUNNTRY INT, PAYMENT_MODE INT, IS_CHECKED BIT, IS_DOC_REQUIRED BIT)
	CREATE TABLE #TBL_COMPLIANCE_RECEIVER(COMM_RULE_ID INT, LIMIT_AMT MONEY, RULE_TYPE CHAR(1), PERIOD_DAYS INT, R_COUNNTRY INT, PAYMENT_MODE INT, IS_CHECKED BIT, IS_DOC_REQUIRED BIT)
	CREATE TABLE #TBL_COMPLIANCE_NO_OF_TXN(CONDITION INT, COMM_RULE_ID INT, LIMIT_NO_OF_TXN INT, RULE_TYPE CHAR(1), PERIOD_DAYS INT, R_COUNNTRY INT, PAYMENT_MODE INT, IS_CHECKED BIT, IS_DOC_REQUIRED BIT)

	SELECT @YearStart = DATEADD(DAY, -365, GETDATE())  
		,@MonthStart = DATEADD(DAY, -30, GETDATE())  
	

	INSERT INTO #TBL_COMPLIANCE(COMM_RULE_ID, LIMIT_AMT, RULE_TYPE, R_COUNNTRY, PERIOD_DAYS, PAYMENT_MODE, IS_CHECKED, IS_DOC_REQUIRED)
	SELECT comRuleId = comRuleId, limitAmt = limitAmt, ruleType = nextAction  , rCountry, period, paymentMode, 0, documentRequired
	FROM (  
		SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction, CM.rCountry, CD.period, CD.paymentMode, CD.documentRequired
		FROM dbo.csDetail CD(NOLOCK)  
		INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
		WHERE ISNULL(CM.rCountry, @pCountryId) = @pCountryId  
		AND CD.condition in (4600, 11201)
		AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
		AND ISNULL(CD.isActive, 'Y') = 'Y'   
		AND ISNULL(CD.isDeleted, 'N') = 'N'  
		AND ISNULL(CD.isEnable, 'Y') = 'Y'  
		AND ISNULL(CM.isActive, 'Y') = 'Y'  
		AND ISNULL(CM.isDeleted, 'N') = 'N' 
		AND PROFESSION IS NULL

		UNION ALL

		SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction, CM.rCountry, CD.period, CD.paymentMode, CD.documentRequired
		FROM dbo.csDetail CD(NOLOCK)  
		INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
		WHERE ISNULL(CM.rCountry, @pCountryId) = @pCountryId  
		AND CD.condition in (4600, 11201)
		AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
		AND ISNULL(CD.isActive, 'Y') = 'Y'   
		AND ISNULL(CD.isDeleted, 'N') = 'N'  
		AND ISNULL(CD.isEnable, 'Y') = 'Y'  
		AND ISNULL(CM.isActive, 'Y') = 'Y'  
		AND ISNULL(CM.isDeleted, 'N') = 'N' 
		AND PROFESSION = @professionId
	)X;
	
	--DELETE RECORD HAVING SAME PERIOD(PER TXN, 1 DAY, 30 DAY) AND RULE TYPE(HOLD, BLOCK) AND CHOOSE SMALLER AMOUNT
	WITH CTE 
	AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY RULE_TYPE, PERIOD_DAYS ORDER BY LIMIT_AMT ASC) ROW_ID,* 
		FROM #TBL_COMPLIANCE
	)

	DELETE FROM CTE WHERE ROW_ID = 2

	CREATE TABLE #tempTran(id BIGINT, tAmt MONEY, sIdType VARCHAR(100),sIdNo VARCHAR(100),createdDate DATETIME  
	,tranStatus VARCHAR(50))  
  
	CREATE TABLE #tempTranR(id BIGINT, tAmt MONEY, createdDate DATETIME, tranStatus VARCHAR(50)  
	,receiverName VARCHAR(150))  

	DECLARE @sumTxnAmt MONEY, @maxDays INT

	SELECT @maxDays = MAX(PERIOD_DAYS)
	FROM #TBL_COMPLIANCE

	INSERT INTO #tempTran(id,tAmt,sIdType,sIdNo,createdDate,tranStatus)  
	SELECT r.id,r.tAmt ,s.idType,s.idNumber,r.createdDate,r.tranStatus   
	FROM vwRemitTran R(nolock)  
	INNER JOIN vwtranSenders S(nolock) ON R.ID = S.tranId  
	WHERE r.tranStatus <> 'Cancel'  
	AND S.customerId = @customerId  
	AND r.createdDate BETWEEN DATEADD(DAY, -1 * @maxDays, CAST(GETDATE() AS DATE)) AND GETDATE()
	
	CREATE TABLE #TBL_COMPLIANCE_RESULT (ERROR_CODE INT, MSG VARCHAR(500), RULE_ID INT, SHORT_MSG VARCHAR(100), [TYPE] VARCHAR(10), IS_DOC_REQUIRED BIT)
	--SELECT * FROM #TBL_COMPLIANCE --WHERE RULE_TYPE = 'B'
	WHILE EXISTS (SELECT TOP 1 1 FROM #TBL_COMPLIANCE WHERE IS_CHECKED = 0)
	BEGIN
		SELECT @limitAmt = LIMIT_AMT, @comRuleId = COMM_RULE_ID, @ruleType = RULE_TYPE, @periodInDays = PERIOD_DAYS, @isDocRequired = IS_DOC_REQUIRED
		FROM #TBL_COMPLIANCE
		WHERE IS_CHECKED = 0
		--AND RULE_TYPE = 'B'
		ORDER BY PERIOD_DAYS DESC
		IF @periodInDays <> 0
			SELECT @sumTxnAmt = SUM(ISNULL(tAmt,0)) FROM #tempTran WHERE createdDate BETWEEN DATEADD(DAY, CASE WHEN @periodInDays = 1 THEN 0 ELSE -1 * @periodInDays END, CAST(GETDATE() AS DATE)) AND GETDATE()
		ELSE 
			SET @sumTxnAmt = 0
		
		IF (ISNULL(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = CASE WHEN @periodInDays = 0 THEN 'The transaction is
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because the transaction   
			amount (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>), is exceeded as <b>per transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>).'  
			ELSE 'The transaction is   
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because previous transaction sum is  
			(<b>'+CAST(ISNULL(@sumTxnAmt, 0) AS VARCHAR)+' JPY</b>) and by doing this transaction (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>)  
			<b>'+CAST(@periodInDays AS VARCHAR) + ' Day(s) transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.'  END
			
			INSERT INTO #TBL_COMPLIANCE_RESULT
			SELECT CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message, @comRuleId
						, CASE WHEN @periodInDays = 0 THEN 'Per txn limit exceeded' ELSE CAST(@periodInDays AS VARCHAR) + ' Day(s) txn limit exceeded.'  END, 'SENDER'
						, @isDocRequired
		END    

		UPDATE #TBL_COMPLIANCE SET IS_CHECKED = 1
		WHERE COMM_RULE_ID = @comRuleId
	END
	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RESULT WHERE ERROR_CODE = 1)
	BEGIN
		SELECT * FROM #TBL_COMPLIANCE_RESULT
		RETURN
	END
	

	--Check for receiver
	IF ISNULL(@receiverName, '') = ''  
	BEGIN  
		SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
		RETURN  
	END  

	
	INSERT INTO #TBL_COMPLIANCE_RECEIVER(COMM_RULE_ID, LIMIT_AMT, RULE_TYPE, R_COUNNTRY, PERIOD_DAYS, PAYMENT_MODE, IS_CHECKED, IS_DOC_REQUIRED)
	SELECT comRuleId = comRuleId, limitAmt = limitAmt, ruleType = nextAction  , rCountry, period, paymentMode, 0, documentRequired
	FROM (  
		SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction, CM.rCountry, CD.period, CD.paymentMode, CD.documentRequired
		FROM dbo.csDetail CD(NOLOCK)  
		INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
		WHERE ISNULL(CM.rCountry, @pCountryId) = @pCountryId  
		AND CD.condition in (4603)
		AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
		AND ISNULL(CD.isActive, 'Y') = 'Y'   
		AND ISNULL(CD.isDeleted, 'N') = 'N'  
		AND ISNULL(CD.isEnable, 'Y') = 'Y'  
		AND ISNULL(CM.isActive, 'Y') = 'Y'  
		AND ISNULL(CM.isDeleted, 'N') = 'N' 
	)X;

	--DELETE RECORD HAVING SAME PERIOD(PER TXN, 1 DAY, 30 DAY) AND RULE TYPE(HOLD, BLOCK) AND CHOOSE SMALLER AMOUNT
	WITH CTE1 
	AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY RULE_TYPE, PERIOD_DAYS ORDER BY LIMIT_AMT ASC) ROW_ID,* 
		FROM #TBL_COMPLIANCE_RECEIVER
	)

	DELETE FROM CTE1 WHERE ROW_ID = 2  

	SELECT @maxDays = MAX(PERIOD_DAYS)
	FROM #TBL_COMPLIANCE_RECEIVER

	SET @receiverMobile = '%' + @receiverMobile

	--IF ISNULL(@accountNo, '') = ''
	--	SELECT @accountNo = receiverAccountNo FROM RECEIVERINFORMATION (NOLOCK) WHERE RECEIVERID = @receiverId
		
	INSERT INTO  #tempTranR(id,tAmt,receiverName,createdDate,tranStatus)  
	SELECT rt.id,tAmt,tr.firstName,createdDate,tranStatus   
	FROM vwRemitTran rt WITH(NOLOCK)   
	INNER JOIN dbo.vwTranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id   
	WHERE tr.fullName = @receiverName AND tranStatus <> 'CANCEL'  
	AND TR.mobile LIKE @receiverMobile  
	AND createdDate BETWEEN DATEADD(DAY, -1 * @maxDays,CAST(GETDATE() AS DATE)) AND GETDATE()
	--AND RT.paymentMethod <> 'BANK DEPOSIT' 

	--UNION ALL

	--SELECT rt.id,tAmt,tr.firstName,createdDate,tranStatus   
	--FROM vwRemitTran rt WITH(NOLOCK)   
	--INNER JOIN dbo.vwTranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id   
	--WHERE tranStatus <> 'CANCEL'  
	--AND rt.ACCOUNTNO = @accountNo
	--AND createdDate BETWEEN DATEADD(DAY, -1 * @maxDays, GETDATE()) AND GETDATE()
	--AND RT.paymentMethod = 'BANK DEPOSIT' 

	WHILE EXISTS (SELECT TOP 1 1 FROM #TBL_COMPLIANCE_RECEIVER WHERE IS_CHECKED = 0)
	BEGIN
		SELECT @limitAmt = LIMIT_AMT, @comRuleId = COMM_RULE_ID, @ruleType = RULE_TYPE, @periodInDays = PERIOD_DAYS, @isDocRequired = IS_DOC_REQUIRED
		FROM #TBL_COMPLIANCE_RECEIVER
		WHERE IS_CHECKED = 0
		--AND RULE_TYPE = 'B'
		ORDER BY PERIOD_DAYS DESC
		
		IF @periodInDays <> 0
			SELECT @sumTxnAmt = SUM(ISNULL(tAmt,0)) FROM #tempTranR WHERE createdDate BETWEEN DATEADD(DAY, CASE WHEN @periodInDays = 1 THEN 0 ELSE -1 * @periodInDays END, CAST(GETDATE() AS DATE)) AND GETDATE()
		ELSE 
			SET @sumTxnAmt = 0

		IF (ISNULL(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = CASE WHEN @periodInDays = 0 THEN 'The transaction is in <b style=''background-color:red; color:white;''>'+
			CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because same reciever  
			<b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.(' + CAST((@sumTxnAmt + @amount) AS VARCHAR) + ' JPY)'  
			ELSE 'The transaction is in<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because same reciever  
			<b>'+CAST(@periodInDays AS VARCHAR) + ' Day(s) transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.(' + CAST((ISNULL(@sumTxnAmt, 0) + @amount) AS VARCHAR) + ' JPY)' END

			
			INSERT INTO #TBL_COMPLIANCE_RESULT
			SELECT CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message, @comRuleId
						, CASE WHEN @periodInDays = 0 THEN 'Per txn limit exceeded' ELSE CAST(@periodInDays AS VARCHAR) + ' Day(s) txn limit exceeded.'  END, 'RECEIVER'
						, @isDocRequired
		END    

		UPDATE #TBL_COMPLIANCE_RECEIVER SET IS_CHECKED = 1
		WHERE COMM_RULE_ID = @comRuleId
	END


	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RESULT WHERE ERROR_CODE = 1)
	BEGIN
		SELECT * FROM #TBL_COMPLIANCE_RESULT
		RETURN
	END

	--COMPLIANCE NO OF TXN WISE
	INSERT INTO #TBL_COMPLIANCE_NO_OF_TXN(COMM_RULE_ID, LIMIT_NO_OF_TXN, RULE_TYPE, R_COUNNTRY, PERIOD_DAYS, PAYMENT_MODE, IS_CHECKED, CONDITION, IS_DOC_REQUIRED)
	SELECT comRuleId = comRuleId, limitAmt = limitAmt, ruleType = nextAction  , rCountry, period, paymentMode, 0, CONDITION, documentRequired
	FROM (  
		SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction, CM.rCountry, CD.period, CD.paymentMode, CD.CONDITION, CD.documentRequired
		FROM dbo.csDetail CD(NOLOCK)  
		INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
		WHERE ISNULL(CM.rCountry, @pCountryId) = @pCountryId  
		AND CD.condition in (11311, 11312)
		AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
		AND ISNULL(CD.isActive, 'Y') = 'Y'   
		AND ISNULL(CD.isDeleted, 'N') = 'N'  
		AND ISNULL(CD.isEnable, 'Y') = 'Y'  
		AND ISNULL(CM.isActive, 'Y') = 'Y'  
		AND ISNULL(CM.isDeleted, 'N') = 'N' 
	)X;

	--DELETE RECORD HAVING SAME PERIOD(PER TXN, 1 DAY, 30 DAY) AND RULE TYPE(HOLD, BLOCK) AND CHOOSE SMALLER AMOUNT
	WITH CTE2
	AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY RULE_TYPE, PERIOD_DAYS, CONDITION ORDER BY LIMIT_NO_OF_TXN ASC) ROW_ID,* 
		FROM #TBL_COMPLIANCE_NO_OF_TXN
	)

	DELETE FROM CTE2 WHERE ROW_ID = 2  

	CREATE TABLE #tempNoOfTxn(tAmt MONEY, txnType CHAR(1),createdDate DATETIME)

	SELECT @maxDays = MAX(PERIOD_DAYS)
	FROM #TBL_COMPLIANCE_NO_OF_TXN

	INSERT INTO #tempNoOfTxn(tAmt,txnType, createdDate)  
	SELECT TAMT, 'S', createdDate
	FROM vwRemitTran R(nolock)  
	INNER JOIN vwtranSenders S(nolock) ON R.ID = S.tranId  
	WHERE r.tranStatus <> 'Cancel'  
	AND S.customerId = @customerId  
	AND r.createdDate BETWEEN DATEADD(DAY, -1 * @maxDays, CAST(GETDATE() AS DATE)) AND GETDATE()

	INSERT INTO #tempNoOfTxn(tAmt,txnType, createdDate)  
	SELECT TAMT, 'R', createdDate
	FROM vwRemitTran rt WITH(NOLOCK)   
	INNER JOIN dbo.vwTranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id   
	WHERE tr.fullName = @receiverName AND tranStatus <> 'CANCEL'  
	AND TR.mobile LIKE @receiverMobile  
	AND createdDate BETWEEN DATEADD(DAY, -1 * @maxDays, CAST(GETDATE() AS DATE)) AND GETDATE()

	DECLARE @limitTxn INT, @limTxnCount INT, @type CHAR(1), @condition INT
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #TBL_COMPLIANCE_NO_OF_TXN WHERE IS_CHECKED = 0)
	BEGIN
		SELECT @limitTxn = LIMIT_NO_OF_TXN, @comRuleId = COMM_RULE_ID, @ruleType = RULE_TYPE, @periodInDays = PERIOD_DAYS, @condition = condition, @isDocRequired = IS_DOC_REQUIRED
		FROM #TBL_COMPLIANCE_NO_OF_TXN
		WHERE IS_CHECKED = 0
		--AND RULE_TYPE = 'B'
		ORDER BY PERIOD_DAYS DESC
		
		--11203 RECEIVER, 11202 SENDER
		IF @condition = 11312
		BEGIN
			IF @periodInDays <> 0
				SELECT @limTxnCount = COUNT(0), @type = 'R' FROM #tempNoOfTxn 
				WHERE createdDate BETWEEN DATEADD(DAY, CASE WHEN @periodInDays = 1 THEN 0 ELSE -1 * @periodInDays END, GETDATE()) AND GETDATE()
				AND txnType = 'R'
			ELSE 
				SET @limTxnCount = 0
		END
		ELSE IF @condition = 11311
		BEGIN
			IF @periodInDays <> 0
				SELECT @limTxnCount = COUNT(0), @type = 'S' FROM #tempNoOfTxn 
				WHERE createdDate BETWEEN DATEADD(DAY, CASE WHEN @periodInDays = 1 THEN 0 ELSE -1 * @periodInDays END, GETDATE()) AND GETDATE()
				AND txnType = 'S'
			ELSE 
				SET @limTxnCount = 0
		END
		
		IF (ISNULL(@limTxnCount,0) + 1) > @limitTxn  
		BEGIN  
			SET @message = 'The transaction is in <b style=''background-color:red; color:white;''>'+
			CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'
			</b> because '+CASE WHEN @type = 'S' THEN 'sender can send' ELSE 'receiver can receive' END +' maximum
			(<b>'+CAST(@limitTxn AS VARCHAR)+' times</b>) only, in '+CAST(@periodInDays AS VARCHAR) + 'Days.'

			
			INSERT INTO #TBL_COMPLIANCE_RESULT
			SELECT CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message, @comRuleId
						, CAST(@periodInDays AS VARCHAR) + ' days maximum number of txn exceeded', 'RECEIVER'
						, @isDocRequired
		END    

		UPDATE #TBL_COMPLIANCE_NO_OF_TXN SET IS_CHECKED = 1
		WHERE COMM_RULE_ID = @comRuleId
	END

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RESULT)
	BEGIN
		SELECT * FROM #TBL_COMPLIANCE_RESULT
		RETURN
	END
	

	--Return success message if there is no complaince matched txn  
	SELECT ERROR_CODE = 0, MSG = 'Success', RULE_ID = 0, SHORT_MSG = 'Success', '', 0
	RETURN  
END


