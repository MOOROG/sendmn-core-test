USE FASTMONEYPRO_REMIT
GO

ALTER PROC PROC_COMPLIANCE_CHECKING_NEW
(
	@flag				VARCHAR(30)  = 'core'  
	 ,@user				VARCHAR(50)    
	 ,@pCountryId		INT  
	 ,@deliveryMethod	INT   
	 ,@amount			MONEY   = null  
	 ,@customerId		VARCHAR(20)     
	 ,@receiverName		VARCHAR(50)  = NULL  
	 ,@sIdNo			VARCHAR(50)     = NULL   
	 ,@sIdType			VARCHAR(50)  = NULL  
	 ,@receiverMobile	VARCHAR(25)  = NULL  
	 ,@message			VARCHAR(1000) = NULL OUTPUT  
	 ,@shortMessage		VARCHAR(100) = NULL OUTPUT  
	 ,@errCode			TINYINT   = NULL OUTPUT  
	 ,@ruleId			INT    = NULL OUTPUT  
	 ,@professionId		INT = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @perTxnLimitAmt MONEY  
	DECLARE @limitAmt MONEY, @comRuleId INT, @ruleType CHAR(1), @periodInDays INT
	DECLARE @limitAmtAgg MONEY, @comRuleIdAgg INT, @ruleTypeAgg CHAR(1) 
	DECLARE @limitAmtProfession MONEY, @comRuleIdProfession INT, @ruleTypeProfession CHAR(1)  
	DECLARE @csMasterId INT  
	DECLARE @YearStart DATE, @YearEnd DATE, @MonthStart DATE, @MonthEnd DATE
	 
	CREATE TABLE #TBL_COMPLIANCE(COMM_RULE_ID INT, LIMIT_AMT MONEY, RULE_TYPE CHAR(1), PERIOD_DAYS INT, R_COUNNTRY INT, PAYMENT_MODE INT, IS_CHECKED BIT)
	CREATE TABLE #TBL_COMPLIANCE_PROFESSION(COMM_RULE_ID INT, LIMIT_AMT MONEY, RULE_TYPE CHAR(1), PERIOD_DAYS INT, R_COUNNTRY INT, PAYMENT_MODE INT)

	SELECT @YearStart = DATEADD(DAY, -365, GETDATE())  
		,@MonthStart = DATEADD(DAY, -30, GETDATE())  
	

	INSERT INTO #TBL_COMPLIANCE(COMM_RULE_ID, LIMIT_AMT, RULE_TYPE, R_COUNNTRY, PERIOD_DAYS, PAYMENT_MODE, IS_CHECKED)
	SELECT comRuleId = comRuleId, limitAmt = limitAmt, ruleType = nextAction  , rCountry, period, paymentMode, 0
	FROM (  
		SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction, CM.rCountry, CD.period, CD.paymentMode
		FROM dbo.csDetail CD(NOLOCK)  
		INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
		WHERE ISNULL(CM.rCountry, 151) = 151  
		AND CD.condition in (4600, 11201)
		AND ISNULL(CD.paymentMode, 2) = 2   
		AND ISNULL(CD.isActive, 'Y') = 'Y'   
		AND ISNULL(CD.isDeleted, 'N') = 'N'  
		AND ISNULL(CD.isEnable, 'Y') = 'Y'  
		AND ISNULL(CM.isActive, 'Y') = 'Y'  
		AND ISNULL(CM.isDeleted, 'N') = 'N' 
		AND ISNULL(PROFESSION, 8084) = 8084
	)X;

	--DELETE RECORD HAVING SAME PERIOD(PER TXN, 1 DAY, 30 DAY) AND RULE TYPE(HOLD, BLOCK) AND CHOOSE SMALLER AMOUNT
	WITH CTE 
	AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY RULE_TYPE, PERIOD_DAYS ORDER BY LIMIT_AMT ASC) ROW_ID,* 
		FROM #TBL_COMPLIANCE
	)

	DELETE FROM CTE WHERE ROW_ID = 2

	CREATE TABLE #tempTran(id BIGINT, cAmt MONEY, sIdType VARCHAR(100),sIdNo VARCHAR(100),createdDate DATETIME  
	,tranStatus VARCHAR(50))  
  
	CREATE TABLE #tempTranR(id BIGINT, cAmt MONEY, createdDate DATETIME, tranStatus VARCHAR(50)  
	,receiverName VARCHAR(150))  

	   
	DECLARE @sumTxnAmt MONEY, @maxDays INT

	SELECT @maxDays = MAX(PERIOD_DAYS)
	FROM #TBL_COMPLIANCE

	INSERT INTO #tempTran(id,cAmt,sIdType,sIdNo,createdDate,tranStatus)  
	SELECT r.id,r.cAmt ,s.idType,s.idNumber,r.createdDate,r.tranStatus   
	FROM vwRemitTran R(nolock)  
	INNER JOIN vwtranSenders S(nolock) ON R.ID = S.tranId  
	WHERE r.tranStatus <> 'Cancel'  
	AND S.customerId = @customerId  
	AND r.createdDate BETWEEN DATEADD(DAY, -1 * @maxDays, GETDATE()) AND GETDATE()

	CREATE TABLE #TBL_COMPLIANCE_RESULT (ERROR_CODE INT, MSG VARCHAR(500), RULE_ID INT, SHORT_MSG VARCHAR(100))

	WHILE EXISTS (SELECT * FROM #TBL_COMPLIANCE WHERE IS_CHECKED = 0 AND RULE_TYPE = 'B')
	BEGIN
		SELECT @limitAmt = LIMIT_AMT, @comRuleId = COMM_RULE_ID, @ruleType = RULE_TYPE, @periodInDays = PERIOD_DAYS
		FROM #TBL_COMPLIANCE
		WHERE IS_CHECKED = 0
		AND RULE_TYPE = 'B'

		IF @periodInDays <> 0
			SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)) FROM #tempTran WHERE createdDate BETWEEN DATEADD(DAY, -1 * @periodInDays, GETDATE()) AND GETDATE()
		ELSE 
			SET @sumTxnAmt = 0

		IF (ISNULL(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = CASE WHEN @periodInDays = 0 THEN 'The transaction is
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because the transaction   
			amount (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>), is exceeded as <b>per transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>).'  
			ELSE 'The transaction is   
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because previous transaction sum is  
			(<b>'+CAST(@sumTxnAmt AS VARCHAR)+' JPY</b>) and by doing this transaction (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>)  
			<b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.'  END
			
			INSERT INTO #TBL_COMPLIANCE_RESULT
			SELECT CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message, @comRuleId
						, CASE WHEN @periodInDays = 0 THEN 'Per day txn limit exceeded' ELSE CAST(@periodInDays AS VARCHAR) + ' Days txn limit exceeded.'  END
		END    

		UPDATE #TBL_COMPLIANCE SET IS_CHECKED = 1
		WHERE COMM_RULE_ID = @comRuleId
	END
	SELECT * FROM #TBL_COMPLIANCE_RESULT
	RETURN
	--per txn limit for agg rule
	INSERT INTO #TBL_COMPLIANCE
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 0, @condition = 4600, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod


	--per txn limit for profession rule
	INSERT INTO #TBL_COMPLIANCE_PROFESSION
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 0, @condition = 11201, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod,@professionId=@professionId

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE WHERE LIMIT_AMT <= @amount) OR EXISTS(SELECT * FROM #TBL_COMPLIANCE_PROFESSION WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmtAgg = LIMIT_AMT, @ruleTypeAgg = RULE_TYPE, @comRuleIdAgg = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT < @amount
		ORDER BY LIMIT_AMT

		SELECT @limitAmtProfession = LIMIT_AMT, @ruleTypeProfession = RULE_TYPE, @comRuleIdProfession = COMM_RULE_ID
		FROM #TBL_COMPLIANCE_PROFESSION
		WHERE LIMIT_AMT < @amount
		ORDER BY LIMIT_AMT

		IF ISNULL(@comRuleIdProfession, 0) <> 0 AND ISNULL(@comRuleIdAgg, 0) <> 0
		BEGIN
			IF @limitAmtProfession > @limitAmtAgg
				SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
			ELSE 
				SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession
		END
		ELSE IF ISNULL(@comRuleIdProfession, 0) = 0
			SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
		ELSE 
			SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession
		
		IF @amount > @limitAmt 
		BEGIN  
			SET @message = 'The transaction is
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because the transaction   
			amount (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>), is exceeded as <b>per transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>).'  
  
			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per txn limit exceeded.'  
			RETURN  
		END
	END
	DELETE FROM #TBL_COMPLIANCE
	DELETE FROM #TBL_COMPLIANCE_PROFESSION


	

	--per day txn limit for agg rule
	INSERT INTO #TBL_COMPLIANCE
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 1, @condition = 4600, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod

	--per day txn limit for profession rule
	INSERT INTO #TBL_COMPLIANCE_PROFESSION
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 1, @condition = 11201, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod,@professionId=@professionId

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE WHERE LIMIT_AMT <= @amount) OR EXISTS(SELECT * FROM #TBL_COMPLIANCE_PROFESSION WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmtAgg = LIMIT_AMT, @ruleTypeAgg = RULE_TYPE, @comRuleIdAgg = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		SELECT @limitAmtProfession = LIMIT_AMT, @ruleTypeProfession = RULE_TYPE, @comRuleIdProfession = COMM_RULE_ID
		FROM #TBL_COMPLIANCE_PROFESSION
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		IF ISNULL(@comRuleIdProfession, 0) <> 0 AND ISNULL(@comRuleIdAgg, 0) <> 0
		BEGIN
			IF @limitAmtProfession > @limitAmtAgg
				SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
			ELSE 
				SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession
		END
		ELSE IF ISNULL(@comRuleIdProfession, 0) = 0
			SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
		ELSE 
			SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession

		SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0))
		FROM #tempTran   
		WHERE createdDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()

		IF (isnull(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
		SET @message = 'The transaction is   
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because previous transaction sum is  
			(<b>'+CAST(@sumTxnAmt AS VARCHAR)+' JPY</b>) and by doing this transaction (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>)  
			<b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.'  
  
			--SELECT @errCode = 1, @message = 'Daily txn limit exceeded.', @ruleId = @comRuleId  
			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per day limit exceeded.'  
			RETURN  
		END  
	END
	DELETE FROM #TBL_COMPLIANCE
	DELETE FROM #TBL_COMPLIANCE_PROFESSION

	--per month txn limit for agg rule
	INSERT INTO #TBL_COMPLIANCE
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 30, @condition = 4600, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod

	--per month txn limit for profession rule
	INSERT INTO #TBL_COMPLIANCE_PROFESSION
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 30, @condition = 11201, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod,@professionId=@professionId


	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE WHERE LIMIT_AMT <= @amount) OR EXISTS(SELECT * FROM #TBL_COMPLIANCE_PROFESSION WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmtAgg = LIMIT_AMT, @ruleTypeAgg = RULE_TYPE, @comRuleIdAgg = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		SELECT @limitAmtProfession = LIMIT_AMT, @ruleTypeProfession = RULE_TYPE, @comRuleIdProfession = COMM_RULE_ID
		FROM #TBL_COMPLIANCE_PROFESSION
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		IF ISNULL(@comRuleIdProfession, 0) <> 0 AND ISNULL(@comRuleIdAgg, 0) <> 0
		BEGIN
			IF @limitAmtProfession > @limitAmtAgg
				SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
			ELSE 
				SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession
		END
		ELSE IF ISNULL(@comRuleIdProfession, 0) = 0
			SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
		ELSE 
			SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession

		SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0))
		FROM #tempTran   
		WHERE createdDate BETWEEN @MonthStart AND GETDATE()  

		IF (isnull(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = 'The transaction is   
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because previous transaction sum is  
			(<b>'+CAST(@sumTxnAmt AS VARCHAR)+' JPY</b>) and by doing this transaction (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>)  
			<b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.'  
  
			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Monthly txn limit exceeded.'  
		RETURN  
		END  
	END
	DELETE FROM #TBL_COMPLIANCE
	DELETE FROM #TBL_COMPLIANCE_PROFESSION

	--per year txn limit for agg rule
	INSERT INTO #TBL_COMPLIANCE
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 365, @condition = 4600, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod

	--per year txn limit for profession rule
	INSERT INTO #TBL_COMPLIANCE_PROFESSION
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 365, @condition = 11201, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod,@professionId=@professionId

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE WHERE LIMIT_AMT <= @amount) OR EXISTS(SELECT * FROM #TBL_COMPLIANCE_PROFESSION WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmtAgg = LIMIT_AMT, @ruleTypeAgg = RULE_TYPE, @comRuleIdAgg = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		SELECT @limitAmtProfession = LIMIT_AMT, @ruleTypeProfession = RULE_TYPE, @comRuleIdProfession = COMM_RULE_ID
		FROM #TBL_COMPLIANCE_PROFESSION
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		IF ISNULL(@comRuleIdProfession, 0) <> 0 AND ISNULL(@comRuleIdAgg, 0) <> 0
		BEGIN
			IF @limitAmtProfession > @limitAmtAgg
				SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
			ELSE 
				SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession
		END
		ELSE IF ISNULL(@comRuleIdProfession, 0) = 0
			SELECT @limitAmt = @limitAmtAgg, @comRuleId = @comRuleIdAgg, @ruleType = @ruleTypeAgg
		ELSE 
			SELECT @limitAmt = @limitAmtProfession, @comRuleId = @comRuleIdProfession, @ruleType = @ruleTypeProfession
			
		SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0))  
		FROM #tempTran 
		
		IF (isnull(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = 'The transaction is
			<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because previous transaction sum is  
			(<b>'+CAST(@sumTxnAmt AS VARCHAR)+' JPY</b>) and by doing this transaction (<b>'+CAST(@amount AS VARCHAR)+' JPY</b>)  
			<b>per year transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.'  
  
			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Yearly txn limit exceeded.'  
			RETURN  
		END
	END 
	DELETE FROM #TBL_COMPLIANCE
	DELETE FROM #TBL_COMPLIANCE_PROFESSION

	--Check for receiver
	IF ISNULL(@receiverName, '') = ''  
	BEGIN  
		SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
		RETURN  
	END  

	SET @receiverMobile = '%' + @receiverMobile  

	INSERT INTO  #tempTranR(id,cAmt,receiverName,createdDate,tranStatus)  
	SELECT rt.id,cAmt,tr.firstName,createdDate,tranStatus   
	FROM vwRemitTran rt WITH(NOLOCK)   
	INNER JOIN dbo.vwTranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id   
	WHERE tr.fullName = @receiverName AND tranStatus <> 'CANCEL'  
	AND TR.mobile LIKE @receiverMobile  
	AND createdDate BETWEEN @YearStart AND GETDATE()  

	CREATE TABLE #TBL_COMPLIANCE_RECEIVER(COMM_RULE_ID INT, LIMIT_AMT MONEY, RULE_TYPE CHAR(1))

	--per txn limit for RECEIVER
	INSERT INTO #TBL_COMPLIANCE_RECEIVER
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 1, @condition = 4603, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RECEIVER WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmt = LIMIT_AMT, @ruleType = RULE_TYPE, @comRuleId = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0)) 
		FROM #tempTranR    
		WHERE createdDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()  

		IF (ISNULL(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = 'The transaction is in <b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because same reciever  
			<b>per day transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.(' + CAST((@sumTxnAmt + @amount) AS VARCHAR) + ' JPY)'  
			
			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per day limit exceeded for same receiver.'  
			RETURN  
		END  
	END
	DELETE FROM #TBL_COMPLIANCE_RECEIVER

	--per MONTH txn limit for RECEIVER
	INSERT INTO #TBL_COMPLIANCE_RECEIVER
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 30, @condition = 4603, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RECEIVER WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmt = LIMIT_AMT, @ruleType = RULE_TYPE, @comRuleId = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0))
		FROM #tempTranR   
		WHERE createdDate BETWEEN @MonthStart AND GETDATE()

		IF (ISNULL(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = 'The transaction is in<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because same reciever  
			<b>per month transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.(' + CAST((@sumTxnAmt + @amount) AS VARCHAR) + ' JPY)'
			  
			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per month limit exceeded for same receiver.'  
			RETURN  
		END  
	END
	DELETE FROM #TBL_COMPLIANCE_RECEIVER

	--YEARLY txn limit for RECEIVER
	INSERT INTO #TBL_COMPLIANCE_RECEIVER
	EXEC PROC_GET_COMPLIANCE_DETAIL @period= 365, @condition = 4603, @pCountryId = @pCountryId, @deliveryMethod=@deliveryMethod

	IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RECEIVER WHERE LIMIT_AMT <= @amount)
	BEGIN
		SELECT @limitAmt = LIMIT_AMT, @ruleType = RULE_TYPE, @comRuleId = COMM_RULE_ID
		FROM #TBL_COMPLIANCE
		WHERE LIMIT_AMT <= @amount
		ORDER BY LIMIT_AMT

		SELECT @sumTxnAmt = SUM(ISNULL(cAmt,0))
		FROM #tempTranR 

		IF (ISNULL(@sumTxnAmt,0) + @amount) > @limitAmt  
		BEGIN  
			SET @message = 'The transaction is in<b style=''background-color:red; color:white;''>'+CASE WHEN @ruleType = 'B' THEN 'blocked' WHEN @ruleType = 'Q' THEN 'questionnaire' ELSE 'hold' END+'</b> because same reciever  
			<b>per year transaction</b> Limit (<b>'+CAST(@limitAmt AS VARCHAR)+' JPY</b>) is exceeded.(' + CAST((@sumTxnAmt + @amount) AS VARCHAR) + ' JPY)'  

			SELECT @errCode = CASE WHEN @ruleType = 'B' THEN 1 WHEN @ruleType = 'H' THEN 2 ELSE 3 END, @message = @message, @ruleId = @comRuleId, @shortMessage = 'Per year limit exceeded for same receiver.'  
			RETURN  
		END  
	END

	--Return success message if there is no complaince matched txn  
	SELECT @errCode = 0, @message = 'Success', @ruleId = 0  
	RETURN  
END