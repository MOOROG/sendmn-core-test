USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_CUSTOMER_DEPOSIT_VOUCHER]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_CUSTOMER_DEPOSIT_VOUCHER]
(
	@USER VARCHAR(50)
	,@FLAG VARCHAR(20)
	,@XML NVARCHAR(MAX)
	,@SESSION_ID VARCHAR(50) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @FLAG = 'UPLOAD'
	BEGIN
		CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))

		DECLARE @XMLDATA XML = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2), @MSG VARCHAR(250)

		SELECT  DT = p.value('@DT', 'varchar(30)'),
				AMT = p.value('@AMT', 'varchar(30)'), 
				NARRATION = p.value('@NARRATION', 'NVARCHAR(200)') 
		INTO #TEMP_DATA
		FROM @XMLDATA.nodes('/root/row') AS tmp ( p );

		DELETE FROM #TEMP_DATA WHERE NARRATION = 'NARRATION' AND AMT = 'Amount'
		DELETE FROM #TEMP_DATA WHERE NARRATION = '' AND AMT = ''

		INSERT INTO TEMP_TRAN_UPLOAD
		SELECT @SESSION_ID, @USER,'100241011536', AMT, DT, 'DR', NARRATION, GETDATE(), 'Customer Deposit(Untransacted)', NULL 
		FROM(
			SELECT * FROM #TEMP_DATA
		)X

		WHILE EXISTS (SELECT TOP 1 1 FROM TEMP_TRAN_UPLOAD (NOLOCK))
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_VOUCHER') IS NOT NULL DROP TABLE #TEMP_VOUCHER
	
			SELECT TOP 1 *
			INTO #TEMP_VOUCHER
			FROM TEMP_TRAN_UPLOAD (NOLOCK)
			--WHERE SESSION_ID = @sessionId
			ORDER BY ROW_ID

			DELETE U
			FROM #TEMP_VOUCHER T
			INNER JOIN TEMP_TRAN_UPLOAD U(NOLOCK) ON U.ROW_ID = T.ROW_ID 
	

			INSERT INTO #TEMP_VOUCHER(SESSION_ID, [USER], ACC_NUM, AMOUNT, TRAN_DATE, TRAN_TYPE, NARRATION, CREATED_DATE, field2)
			SELECT @SESSION_ID, @USER, '101139273793', AMOUNT, TRAN_DATE, 'CR', NARRATION, GETDATE(), field2
			FROM #TEMP_VOUCHER
			
			DELETE FROM temp_tran WHERE sessionId = @SESSION_ID

			INSERT INTO temp_tran(sessionId, entry_user_id, acct_num, part_tran_type, tran_amt, trn_currency, usd_amt, ex_rate, tran_date, rpt_code, field2, field1)
			SELECT SESSION_ID, @USER, ACC_NUM, TRAN_TYPE, AMOUNT, 'JPY', AMOUNT, 1, TRAN_DATE, 'USDVOUCHER', field2, 'Manual Uplaod' FROM #TEMP_VOUCHER 

			DECLARE @NARRATION NVARCHAR(500), @txnDate VARCHAR(20)

			SELECT @NARRATION = NARRATION, @txnDate = TRAN_DATE
			FROM #TEMP_VOUCHER

			INSERT INTO #TEMP_ERROR_CODE
			EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@txnDate,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@USER
		END

		SELECT * FROM #TEMP_ERROR_CODE
	END
	ELSE IF @FLAG = 'CHECK'
	BEGIN
		SET @XMLDATA = CONVERT(XML, REPLACE(@XML,'&','&amp;'), 2) 

		SELECT  DT = p.value('@DT', 'varchar(30)'),
				AMT = p.value('@AMT', 'varchar(30)'), 
				NARRATION = p.value('@NARRATION', 'NVARCHAR(200)') 
		INTO #TEMP_DATA_CHECK
		FROM @XMLDATA.nodes('/root/row') AS tmp ( p );

		DELETE FROM #TEMP_DATA_CHECK WHERE NARRATION = 'NARRATION' AND AMT = 'Amount'
		DELETE FROM #TEMP_DATA_CHECK WHERE NARRATION = '' AND AMT = ''

		DECLARE @MIN_DATE VARCHAR(20), @MAX_DATE VARCHAR(20), @AMT_UPLOAD MONEY, @AMT_TRAN MONEY
		SELECT @MIN_DATE = MIN(CAST(DT AS DATE)), @MAX_DATE = MAX(CAST(DT AS DATE)), @AMT_UPLOAD = SUM(CAST(AMT AS MONEY))
		FROM #TEMP_DATA_CHECK

		SELECT @AMT_TRAN = SUM(TRAN_AMT)
		FROM TRAN_MASTER WHERE TRAN_DATE BETWEEN @MIN_DATE AND @MAX_DATE + ' 23:59:59'
		AND ACC_NUM = '100241011536'
		AND part_tran_type = 'DR'
		AND FIELD2 = 'Customer Deposit(Untransacted)'

		IF ISNULL(@AMT_TRAN, 0) = 0
		BEGIN
			EXEC PROC_ERRORHANDLER 0, 'No file uploaded for this date range, you can continue with upload!', null
			RETURN
		END
		IF ISNULL(@AMT_UPLOAD, 0) = 0
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'No data in file for upload!', null
			RETURN
		END
		ELSE IF ISNULL(@AMT_TRAN, 0) = ISNULL(@AMT_UPLOAD, 1)
		BEGIN
			SET @MSG = 'File with same transaction amount is already uploaded with this date range Amount in system: '+CAST(ISNULL(@AMT_TRAN, 0) AS VARCHAR)+' And Amount in file: '+CAST(ISNULL(@AMT_UPLOAD, 0) AS VARCHAR)+
						', you can not uplaod this file.'
			EXEC PROC_ERRORHANDLER 1, @MSG, null
			RETURN
		END
		ELSE IF ISNULL(@AMT_TRAN, 0) <> ISNULL(@AMT_UPLOAD, 1)
		BEGIN
			SET @MSG = 'File with different transaction amount is already uploaded with this date range, Amount in system: '+CAST(ISNULL(@AMT_TRAN, 0) AS VARCHAR)+' And Amount in file: '+CAST(ISNULL(@AMT_UPLOAD, 0) AS VARCHAR)+
							', however you can uplaod this file.'
			EXEC PROC_ERRORHANDLER 0, @MSG, null
			RETURN
		END
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT 1 errorCode,'Error in Fund Transfer' msg ,NULL id
		END
END CATCH
RETURN



GO
