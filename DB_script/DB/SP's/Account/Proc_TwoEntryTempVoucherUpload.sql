
ALTER PROC Proc_TwoEntryTempVoucherUpload
    @xml		NVARCHAR(MAX) = NULL ,
    @user		NVARCHAR(35) = NULL,
    @flag		VARCHAR(10) = NULL,
	@sessionId	varchar(60) = NULL,
	@fileName	varchar(50) = null
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @NARRATION VARCHAR(250), @txnDate VARCHAR(20)
	IF @flag = 'i'
	BEGIN
		DELETE FROM TEMP_TRAN_UPLOAD WHERE SESSION_ID=@sessionId
		
		DECLARE @XMLDATA XML = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 
		
		INSERT INTO TEMP_TRAN_UPLOAD(SESSION_ID, [USER], ACC_NUM, AMOUNT, TRAN_DATE, TRAN_TYPE, NARRATION, CREATED_DATE, field2)
		SELECT  @sessionId,@user,
				ACCT_NUM = p.value('@AC_NUM', 'VARCHAR(35)') ,
				AMOUNT = p.value('@AMOUNT', 'VARCHAR(35)') ,
				[DATE] = p.value('@DATE', 'VARCHAR(35)') ,
				[TYPE] = p.value('@TYPE', 'CHAR(2)') ,
				NARRATION = p.value('@NARRATION', 'NVARCHAR(250)'),
				GETDATE(),
				@fileName
		FROM    @XMLDATA.nodes('/root/row') AS tmp ( p );

		EXEC proc_errorHandler 0,'Record Inserted successfully!',null
		RETURN
	END
	ELSE IF @flag = 'S'
	BEGIN
		SELECT A.ACCT_NAME, A.ACCT_NUM, T.* FROM TEMP_TRAN_UPLOAD T(NOLOCK)
		INNER JOIN AC_MASTER A(NOLOCK) ON A.ACCT_NUM = T.ACC_NUM
		WHERE SESSION_ID = @sessionId
		--and narration = 'Incentive rusha'
		ORDER BY ROW_ID
	END   
	ELSE IF @flag = 'SAVE'
	BEGIN
		CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))
		WHILE EXISTS (SELECT * FROM TEMP_TRAN_UPLOAD (NOLOCK) WHERE SESSION_ID = @sessionId)
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_VOUCHER') IS NOT NULL DROP TABLE #TEMP_VOUCHER

			SELECT TOP 2 *
			INTO #TEMP_VOUCHER
			FROM TEMP_TRAN_UPLOAD (NOLOCK)
			WHERE SESSION_ID = @sessionId
			ORDER BY ROW_ID

			IF(SELECT COUNT(1) FROM(
				SELECT COUNT(1)cl FROM #TEMP_VOUCHER
				GROUP BY AMOUNT, TRAN_DATE, NARRATION
				)tb)>1
			BEGIN 
				INSERT INTO #TEMP_ERROR_CODE
				SELECT TOP 1 '1', 'NO DATA SAVED FOR NARRATION '+ NARRATION, NULL
				FROM #TEMP_VOUCHER 
			END
			ELSE
			BEGIN
				DELETE FROM temp_tran WHERE sessionId = @sessionId

				INSERT INTO temp_tran(sessionId, entry_user_id, acct_num, part_tran_type, tran_amt, trn_currency, usd_amt, ex_rate, tran_date, rpt_code, field2, field1)
				SELECT SESSION_ID, @user, ACC_NUM, TRAN_TYPE, AMOUNT, 'JPY', AMOUNT, 1, TRAN_DATE, 'USDVOUCHER', field2, 'Temp Batch Upload' FROM #TEMP_VOUCHER 


				SELECT @sessionId = SESSION_ID, @NARRATION = NARRATION, @txnDate = TRAN_DATE
				FROM #TEMP_VOUCHER

				INSERT INTO #TEMP_ERROR_CODE
				EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@sessionId,@date=@txnDate,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@user
			
				DELETE U
				FROM #TEMP_VOUCHER T
				INNER JOIN TEMP_TRAN_UPLOAD U(NOLOCK) ON U.ROW_ID = T.ROW_ID 
				WHERE T.SESSION_ID = @sessionId
			END
		END

		SELECT D.tran_particular, T.ERROR_CODE, T.MSG FROM #TEMP_ERROR_CODE T
		LEFT JOIN tran_masterDetail D(NOLOCK) ON D.ref_num = T.ID
	END
	ELSE IF @flag = 'CLEAR'
	BEGIN
		DELETE FROM TEMP_TRAN_UPLOAD WHERE SESSION_ID = @sessionId
	END
END


