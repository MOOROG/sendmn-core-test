USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_saveTempTrnUSD_Multiple]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_saveTempTrnUSD_Multiple]
(
	@flag			CHAR(1),
	@sessionID		VARCHAR(50),
	@date			VARCHAR(20),
	@narration		NVARCHAR(500),
	@company_id		VARCHAR(20) = 1,
	@v_type			VARCHAR(20),
	@user			VARCHAR(50),
	@voucherPath	varchar(100) = null
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @flag = 'I'
	BEGIN
		DECLARE @TRAN_DATE VARCHAR(30), @ROW_ID INT = 1
		CREATE TABLE #TEMP_ERROR_CODE (ROW_ID INT IDENTITY(1, 1), ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))

		SELECT * 
		INTO #temp_tran
		FROM temp_tran 
		WHERE sessionID = @sessionID

		DELETE FROM temp_tran WHERE sessionID = @sessionID
		WHILE EXISTS (SELECT TOP 1 1 FROM #temp_tran (NOLOCK) WHERE sessionID = @sessionID)
		BEGIN
			IF OBJECT_ID('tempdb..#TEMP_VOUCHER') IS NOT NULL DROP TABLE #TEMP_VOUCHER

			SELECT @TRAN_DATE = tran_date
			FROM #temp_tran (NOLOCK)
			WHERE sessionID = @sessionID

			SELECT *
			INTO #TEMP_VOUCHER
			FROM #temp_tran 
			WHERE sessionID = @sessionID
			AND tran_date = @TRAN_DATE

			DELETE FROM temp_tran WHERE sessionId = @sessionId

			INSERT INTO temp_tran(sessionId, entry_user_id, acct_num, part_tran_type, tran_amt, trn_currency, usd_amt, ex_rate, tran_date, rpt_code, field2, field1)
			SELECT sessionID, @user, acct_num, part_tran_type, tran_amt, trn_currency, usd_amt, ex_rate, tran_date, rpt_code, field2, field1 
			FROM #TEMP_VOUCHER 


			INSERT INTO #TEMP_ERROR_CODE
			EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@sessionID,@date=@TRAN_DATE,@narration=@narration,@company_id=1,@v_type='j',@user=@user, @voucherPath=@voucherPath
			
			UPDATE #TEMP_ERROR_CODE SET MSG = ISNULL(MSG, '') + '('+@TRAN_DATE+')' WHERE ROW_ID = @ROW_ID

			DELETE U
			FROM #TEMP_VOUCHER T
			INNER JOIN #temp_tran U(NOLOCK) ON U.TRAN_ID = T.TRAN_ID
			WHERE T.sessionID = @sessionId

			SET @ROW_ID = @ROW_ID + 1
		END

		SELECT D.tran_particular, T.ERROR_CODE, T.MSG FROM #TEMP_ERROR_CODE T
		LEFT JOIN tran_masterDetail D(NOLOCK) ON D.ref_num = T.ID
	END
END

GO
