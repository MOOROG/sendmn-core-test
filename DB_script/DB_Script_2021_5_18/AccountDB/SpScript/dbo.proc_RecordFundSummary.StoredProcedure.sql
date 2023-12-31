USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_RecordFundSummary]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_RecordFundSummary]
	@flag CHAR(1) = NULL,
	@date VARCHAR(20),
	@ExRate_user MONEY =NULL,
	@company_id VARCHAR(5),	
	@user VARCHAR(50)

as
--SELECT * FROM SendTransactionSummary

--EXEC [proc_RecordFundSummary] @date='2017-04-18',@company_id='1',@user='system'

SET NOCOUNT ON;
SET XACT_ABORT ON;
		 
	UPDATE REMIT_TRN_MASTER set EX_USD =1 WHERE TRN_DATE BETWEEN @date  AND  @date +' 23:59:59.998'  
	AND (EX_USD = 0 OR EX_USD IS NULL)

DECLARE @msg VARCHAR(MAX)
--------------------------------------------------------------------------
begin try
---------------DATA FOR VOUCHER GENERATION--------------------------------
	DECLARE @GLOBALREMIT INT = 6873	,@KUMARIAPI INT = 9267
	

	IF OBJECT_ID(N'tempdb..#TEMPTXNSEND') IS NOT NULL
        DROP TABLE #TEMPTXNSEND
		 
		 SELECT	 
				 TRN_REF_NO
				,S_AGENT
				,S_COUNTRY
				,TRN_TYPE
				,NPR_USD_RATE
				,EX_USD
				,EX_FLC
				,SETTLEMENT_RATE
			---	,EX_USD SCURRCOSTRATE
				,S_CURR
				,S_AMT
				,USD_AMT
				,SC_TOTAL
				,SC_HO
				,SC_S_AGENT
				,P_AMT
				,p_amt_act
				,agent_ex_gain
				,agent_receiverSCommission
				,TRN_DATE
	INTO #TEMPTXNSEND
	FROM REMIT_TRN_MASTER R  WITH (NOLOCK)
	WHERE TRN_DATE BETWEEN @date  AND  @date+' 23:59:59'
	AND F_INIT ='Y'
	AND S_AGENT NOT IN (@GLOBALREMIT,@KUMARIAPI)
	
	IF NOT EXISTS(SELECT TOP 1 * FROM #TEMPTXNSEND )
	BEGIN
		EXEC proc_errorHandler 1,'VOUCHER ALREADY GENERATED / NO TRANSACTION FOUND',null
		RETURN;
	END


	ALTER TABLE #TEMPTXNSEND ADD SAGENTID INT

	UPDATE #TEMPTXNSEND SET SAGENTID = AGENT_ID 
	FROM #TEMPTXNSEND T INNER JOIN AGENTTABLE S  WITH (NOLOCK)
	ON T.S_AGENT = S.map_code
	 

--------------CALCULATION FOR VOUCHER START--------------------------------------

UPDATE #TEMPTXNSEND SET SETTLEMENT_RATE = 1 WHERE isnull(SETTLEMENT_RATE,'') = ''

UPDATE #TEMPTXNSEND  SET EX_USD = 1 WHERE isnull(EX_USD,'' ) = ''

IF OBJECT_ID(N'tempdb..#SEND') IS NOT NULL
        DROP TABLE #SEND
SELECT
	IDENTITY(INT,1,1) AS SN, COUNT(*) TRAN_COUNT,S_AGENT,  S_CURR, SAGENTID
			,USD_P_AMT			= SUM(ROUND(ISNULL(USD_AMT,0),2))
			,USD_P_COMM			= SUM(ROUND(ISNULL(SC_TOTAL/EX_USD,0),2))
			,USD_FX_SHARING		= 0
			,NPR_FX_SHARING		= 0
			,NPR_P_COMM			= SUM(ROUND(ISNULL(SC_TOTAL * EX_FLC,0),2))
			,NPR_P_AMT			= SUM(ROUND(ISNULL(P_AMT,0),2))
			,SETTLEMENT_RATE	= SETTLEMENT_RATE
	INTO #SEND
	FROM #TEMPTXNSEND 
	GROUP BY  S_AGENT, S_CURR,SAGENTID,SETTLEMENT_RATE

DECLARE 
	@acct_num			VARCHAR(50)	,
	@TRAN_Amt			MONEY		, 
	@USD_Amt			MONEY		,
	@PART_TRAN_TYPE		VARCHAR(2)	,
	@current_id			INT			,
	@max_id				INT
	


BEGIN TRANSACTION
----------Update account balance starts
	SET @current_id = 1        
	
DECLARE 
		 @current_voucher_number INT
		,@ref_num                BIGINT
		,@voucher_type			 VARCHAR(2)
	SET @current_voucher_number = 0
	--Writing voucher to database starts

	
--##########################

	DECLARE @weightedRate TABLE(AGENTID INT,RATE MONEY,REMAINAMT MONEY,cummNPR DECIMAL(10,2))

	INSERT INTO @weightedRate
	SELECT S.S_AGENT,RATE = ISNULL(S.WeightedRate,S.USD_RATE),S.REMAIN_AMT,S.cummNPR
	FROM SendTransactionSummary S(NOLOCK)
	INNER JOIN(
		SELECT S_AGENT,TRAN_ID = MAX(TRAN_ID) FROM SendTransactionSummary(NOLOCK)
		GROUP BY S_AGENT
	)X ON S.S_AGENT = X.S_AGENT AND S.TRAN_ID = X.TRAN_ID


	ALTER TABLE #SEND ADD weightedRate MONEY,REMAINAMT MONEY,cummUsd DECIMAL(10,2),cummNPR DECIMAL(10,2)

	--UPDATE S SET S.weightedRate = (S.SETTLEMENT_RATE+ISNULL(W.RATE,S.SETTLEMENT_RATE))/2.00
	--			,REMAINAMT = USD_P_AMT + USD_P_COMM + ISNULL(W.REMAINAMT,0)
	--FROM #SEND S
	--LEFT JOIN @weightedRate W ON S.S_AGENT = W.AGENTID
	
	SELECT S_AGENT,S_CURR, SUM(USD_P_AMT + USD_P_COMM) USD,SUM((USD_P_AMT + USD_P_COMM)*SETTLEMENT_RATE) AS NPR
			,CAST(0 AS MONEY) AS SETTLEMENT_RATE,CAST(0 AS MONEY) REMAINAMT
			,CAST(0 AS DECIMAL(10,2)) cummNPR,CAST(0 AS MONEY) weightedRate
	INTO #CollectedAmt FROM #SEND where S_CURR <> 'NPR' 
	GROUP BY S_AGENT,S_CURR

	UPDATE #CollectedAmt SET SETTLEMENT_RATE = NPR / USD 

	UPDATE S SET REMAINAMT = USD + ISNULL(W.REMAINAMT,0)
					,cummNPR = NPR + W.cummNPR
	FROM #CollectedAmt S
	INNER JOIN @weightedRate W ON S.S_AGENT = W.AGENTID

	UPDATE #CollectedAmt SET weightedRate = cummNPR / REMAINAMT
		
	UPDATE #CollectedAmt SET 
		cummNPR = NPR
		,weightedRate = SETTLEMENT_RATE
		,REMAINAMT = USD
	FROM #CollectedAmt S
	LEFT JOIN @weightedRate W ON S.S_AGENT = W.AGENTID
	WHERE W.AGENTID IS NULL

	-------------------------------OLD LOGIC---------------------------------------------------
		--UPDATE S SET REMAINAMT = USD_P_AMT + USD_P_COMM + ISNULL(W.REMAINAMT,0)
		--			,cummNPR = (USD_P_AMT + USD_P_COMM)*SETTLEMENT_RATE+W.cummNPR
		--FROM #SEND S
		--INNER JOIN @weightedRate W ON S.S_AGENT = W.AGENTID

		--UPDATE #SEND SET weightedRate = cummNPR / REMAINAMT
		
		--UPDATE #SEND SET 
		--	cummNPR = (USD_P_AMT + USD_P_COMM)*SETTLEMENT_RATE
		--	,weightedRate = SETTLEMENT_RATE
		--	,REMAINAMT = (USD_P_AMT + USD_P_COMM)
		--FROM #SEND S
		--LEFT JOIN @weightedRate W ON S.S_AGENT = W.AGENTID
		--WHERE W.AGENTID IS NULL

--------########## CREATE SUMMARY SEND TRANSACTION 
	INSERT INTO  SendTransactionSummary(S_AGENT,S_CURR,USD_AMT,NPR_AMT,USD_RATE,P_CURR,TRAN_DATE
		,REMAIN_AMT,WeightedRate,cummNPR)
	SELECT S_AGENT,S_CURR, USD ,NPR,SETTLEMENT_RATE,'NPR',@date
		,REMAINAMT,ISNULL(weightedRate,SETTLEMENT_RATE),cummNPR
	FROM #CollectedAmt where S_CURR <> 'NPR' 
	
	
	--SELECT * FROM @weightedRate
	--SELECT * FROM #SEND
------## END OF VOUCHER ENTRY
	
IF @@TRANCOUNT > 0	
COMMIT TRANSACTION

EXEC proc_errorHandler 0,'PROCESS COMPLETED',null

RETURN

 
END TRY
BEGIN CATCH

SELECT ERROR_MESSAGE()

IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION
END CATCH


GO
