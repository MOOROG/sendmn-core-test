ALTER  PROC [dbo].[ProcExtractDailyTransation_nepal]
	@flag CHAR(1) = NULL,
	@date VARCHAR(20),
	@ExRate_user MONEY =NULL,
	@company_id VARCHAR(5),	
	@user VARCHAR(50)

as
--EXEC [ProcExtractDailyTransation_nepal] @date='2017-02-28',@company_id='1',@user='PRALHAD'
SET NOCOUNT ON;
SET XACT_ABORT ON;
		 
	UPDATE REMIT_TRN_MASTER set EX_USD =1 WHERE TRN_DATE BETWEEN @date  AND  @date +' 23:59:59.998'  
	AND (EX_USD = 0 OR EX_USD IS NULL)

DECLARE @msg VARCHAR(MAX)
--------------------------------------------------------------------------
begin try
---------------DATA FOR VOUCHER GENERATION--------------------------------
	DECLARE @GLOBALREMIT INT = 6873	,@KUMARIAPI INT = 9267
	--DECLARE @GLOBALREMIT INT = 1069	,@KUMARIAPI INT = 1092

	IF EXISTS(
		SELECT TOP 1 'A' FROM REMIT_TRN_MASTER R  WITH (NOLOCK)
		WHERE TRN_DATE < @date
		AND F_INIT IS NULL
		AND S_AGENT NOT IN (@GLOBALREMIT,@KUMARIAPI)
	)
	BEGIN
		SELECT @date = CONVERT(VARCHAR,MIN(TRN_DATE),101) FROM REMIT_TRN_MASTER R  WITH (NOLOCK)
		WHERE TRN_DATE < @date
		AND F_INIT IS NULL
		AND S_AGENT NOT IN (@GLOBALREMIT,@KUMARIAPI)

		SET @msg = 'BACK DATE VOUCHER GENERATION PENDING ON :'+ @date

		EXEC proc_errorHandler 1,@msg,null
		RETURN
	END
		

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
	AND F_INIT IS NULL
	AND S_AGENT NOT IN (@GLOBALREMIT,@KUMARIAPI)
	
	IF NOT EXISTS(SELECT TOP 1 * FROM #TEMPTXNSEND )
	BEGIN
		EXEC proc_errorHandler 1,'VOUCHER ALREADY GENERATED / NO TRANSACTION FOUND',null
		RETURN;
	END

	DECLARE @REMITINTL_AC VARCHAR(30) = '123654789'

	ALTER TABLE #TEMPTXNSEND ADD SAGENTID INT

	UPDATE #TEMPTXNSEND SET SAGENTID = AGENT_ID 
	FROM #TEMPTXNSEND T INNER JOIN AGENTTABLE S  WITH (NOLOCK)
	ON T.S_AGENT = S.map_code
	 

		IF EXISTS(SELECT * FROM #TEMPTXNSEND WHERE SAGENTID IS NULL )
		BEGIN
		
				DECLARE @strMissingList varchar(100)

				SELECT  @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				S_AGENT
				FROM  (SELECT DISTINCT S_AGENT FROM #TEMPTXNSEND WITH (NOLOCK) WHERE SAGENTID IS NULL) X
				
				SELECT @strMissingList = 'AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList

				EXEC proc_errorHandler 1,@strMissingList,null
				RETURN;
		END

IF OBJECT_ID(N'tempdb..#voucherList') IS NOT NULL
        DROP TABLE #voucherList
CREATE TABLE #voucherList
(
	VOUCHER_NUMBER	int,	
	GL_CODE			VARCHAR(50),
	ACC_NUM			VARCHAR(50),
	ACC_NAME		VARCHAR(150),
	PART_TRAN_TYPE	VARCHAR(50),--dr/cr
	TRAN_AMT		MONEY,	
	USD_AMT			MONEY,
	TRAN_TYPE		VARCHAR(10),
	SERIAL			INT
)

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

----------Transaction Voucher-------------------
	INSERT INTO  #voucherList
	(ACC_NUM,ACC_NAME,TRAN_AMT,USD_AMT,PART_TRAN_TYPE,SERIAL,VOUCHER_NUMBER,GL_CODE,TRAN_TYPE) 
		
		SELECT 
			ACC_NUM,dbo.FUNGetAcName(ACC_NUM) ACC_NAME,TRAN_AMT,USD_AMT,PART_TRAN_TYPE,SERIAL,VOUCHER_NUMBER,dbo.FunGetGLCode(ACC_NUM) GL_CODE,'S' TRAN_TYPE
		FROM 
			(
							
-------------RECEIVIABLE DEBIT----------------------------------------------------------------------------		

				SELECT  
						 ACC_NUM		=	ACCT_NUM  ----Max Money International A/c (NPR) -Principal Dr.
						,TRAN_AMT		=	SUM(NPR_P_AMT)
						,USD_AMT		=	SUM(USD_P_AMT)
						,PART_TRAN_TYPE	=	'Dr'
						,SERIAL			=	1
						,VOUCHER_NUMBER	=	1
				FROM #SEND S INNER JOIN AC_MASTER A ON  S.SAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '3'	
				GROUP BY ACCT_NUM,SN		
	 
			
			UNION ALL

				SELECT  
						 ACC_NUM		=	ACCT_NUM  ----Commission Receivable A/c - Dr.
						,TRAN_AMT		=	SUM(NPR_P_COMM) 
						,USD_AMT		=	SUM(USD_P_COMM)
						,PART_TRAN_TYPE	=	'Dr'
						,SERIAL			=	2
						,VOUCHER_NUMBER	=	1
				FROM #SEND S INNER JOIN AC_MASTER A ON  S.SAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '4'	
				GROUP BY ACCT_NUM,SN	
				
	 			UNION ALL	
-------------FEE EARNING CREDIT ----------------------------------------------------------------------------		
		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  ----'Remittance Commission International'
						,TRAN_AMT		=	SUM(NPR_P_COMM)  
						,USD_AMT		=	SUM(USD_P_COMM)    
						,PART_TRAN_TYPE	=	'Cr'
						,SERIAL			=	3
						,VOUCHER_NUMBER	=	1
				FROM #SEND S INNER JOIN AC_MASTER A ON  S.SAGENTID=A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '5'	
				GROUP BY ACCT_NUM			

				UNION ALL

				SELECT  
						 ACC_NUM		=	@REMITINTL_AC  ----Remittance - International A/c - Cr.
						,TRAN_AMT		=	SUM(NPR_P_AMT)  
						,USD_AMT		=	SUM(USD_P_AMT)    
						,PART_TRAN_TYPE	=	'Cr'
						,SERIAL			=	4
						,VOUCHER_NUMBER	=  1
				FROM #SEND S 	
				
			
			) AS TMP
			ORDER  BY VOUCHER_NUMBER, SERIAL ASC 
 

DELETE FROM #voucherList WHERE ISNULL(TRAN_AMT,0) = 0
	
--SELECT * FROM #voucherList
--RETURN
---------------------------------------------------TRANSACTION ENDS--------------------------------------

IF NOT EXISTS (SELECT 'X' FROM #voucherList)
BEGIN
	EXEC proc_errorHandler 1,'NO TRANSACTION FOUND',null
	RETURN
END

--##################COMMON SCRIPT TO CHECK VOUCHER BALANCE, TO UDATE ACCOUNT BALANCE AND MAKING VOUCHER ENTRY
--Checking voucher leg (must contain dr and cr leg)
IF EXISTS (
	SELECT 'X' FROM (
						SELECT VOUCHER_NUMBER, 
							SUM(CASE WHEN PART_TRAN_TYPE = 'Dr' THEN 1 ELSE 0 END) DRCnt,
							SUM(CASE WHEN PART_TRAN_TYPE = 'Cr' THEN 1 ELSE 0 END) CRCnt
						FROM #voucherList GROUP BY VOUCHER_NUMBER
					) X WHERE ISNULL(DRCnt, 0) = 0 OR ISNULL(CRCnt, 0) = 0
				
)
BEGIN
	SELECT 'Voucher must have both debit and credit leg. One or more voucher do not contain either debit or credit leg.' AS REMARKS
	--SELECT * FROM #voucherList 
	RETURN
END
--Checking voucher leg ends
 
--Checking debit and credit balance voucher balance starts	
IF OBJECT_ID(N'tempdb..#dr_cr_source') IS NOT NULL
	DROP TABLE #dr_cr_source

SELECT 
	VOUCHER_NUMBER ,
	ROUND(SUM(CASE PART_TRAN_TYPE WHEN 'Dr' THEN TRAN_AMT ELSE 0 END),2) Dr,
	ROUND(SUM(CASE PART_TRAN_TYPE WHEN 'Cr' THEN TRAN_AMT ELSE 0 END),2) Cr
INTO #dr_cr_source	
FROM #voucherList GROUP BY VOUCHER_NUMBER			

IF EXISTS (SELECT 'X' FROM #dr_cr_source WHERE  ROUND(Dr, 2) <> ROUND(Cr, 2))
BEGIN
	EXEC proc_errorHandler 1,'Voucher can not be generated: Debit Amount is not equal to Credit Amount',null	
	RETURN
END

--####Preparing to update account balance starts	

IF OBJECT_ID(N'tempdb..#account_update_source') IS NOT NULL
	DROP TABLE #account_update_source

SELECT 
	IDENTITY(INT,1,1) RowID,
	ACC_NUM [ACCT_NUM],		
	SUM(CASE PART_TRAN_TYPE WHEN 'Dr' THEN ISNULL(TRAN_AMT,0) * -1 ELSE ISNULL(TRAN_AMT,0) END)  AS TRAN_AMT,
	SUM(CASE PART_TRAN_TYPE WHEN 'Dr' THEN ISNULL(USD_AMT,0) * -1 ELSE ISNULL(USD_AMT,0) END)  AS USD_AMT	
INTO #account_update_source
FROM #voucherList
GROUP BY ACC_NUM

 --SELECT * FROM #voucherList 
 --RETURN

DECLARE 
	@acct_num			VARCHAR(50)	,
	@TRAN_Amt			MONEY		, 
	@USD_Amt			MONEY		,
	@PART_TRAN_TYPE		VARCHAR(2)	,
	@current_id			INT			,
	@max_id				INT
	
SELECT @max_id = MAX(RowID) FROM #account_update_source
--Preparing to update account balance ends


BEGIN TRANSACTION
----------Update account balance starts
	SET @current_id = 1        
	WHILE @max_id >= @current_id
	BEGIN
		SELECT 
			@acct_num			= ACCT_NUM,
			@TRAN_Amt			= ABS(TRAN_AMT),                
			@USD_Amt			= ABS(USD_AMT),
			@PART_TRAN_TYPE		= CASE WHEN TRAN_AMT < 0 THEN 'Dr' ELSE 'Cr' END --dr/cr
		FROM #account_update_source WHERE RowID = @current_id
	    
		EXEC ProcDrCrUpdateFinal @PART_TRAN_TYPE ,@acct_num, @TRAN_Amt, @USD_Amt 
	    
		SET @current_id = @current_id + 1
	END

------DROP TABLE #account_update_source
------Update account balance ends


DECLARE 
		 @current_voucher_number INT
		,@ref_num                BIGINT
		,@voucher_type			 VARCHAR(2)
	SET @current_voucher_number = 0
	--Writing voucher to database starts

	SET @strMissingList = ''

	WHILE EXISTS(SELECT 'X' FROM #voucherList WHERE voucher_number > @current_voucher_number)-- ORDER BY voucher_number ASC)
	BEGIN
		SELECT TOP 1 @voucher_type = TRAN_TYPE, @current_voucher_number = voucher_number 
		FROM #voucherList 
		WHERE voucher_number > @current_voucher_number ORDER BY voucher_number ASC
	     
		SELECT @ref_num  = ISNULL(transaction_voucher, 1) FROM billsetting 
		----WHERE v_code = @voucher_type  
		
		
			IF EXISTS (
							SELECT TOP 1 'X' FROM tran_master WITH (NOLOCK)
							WHERE ref_num  = @ref_num AND tran_type = @voucher_type
						)
			BEGIN
							
							--SELECT 'Voucher no already Exists,' 
							--		Wait for Another Process to complete and try again !' AS remarks
							SELECT @strMissingList = @strMissingList + @ref_num +' , '
			END
		          
		UPDATE billsetting SET transaction_voucher = ISNULL(transaction_voucher, 1) + 1
		---- WHERE v_code = @voucher_type
	    
		INSERT INTO tran_master (
			entry_user_id, acc_num, gl_sub_head_code, part_tran_type, 
			ref_num, tran_amt, usd_amt, usd_rate, tran_date,
			tran_type, company_id, part_tran_srl_num,created_date,rpt_code
		 )	    
			
		SELECT 
			@user, vl.acc_num, am.gl_code, vl.PART_TRAN_TYPE, 
			@ref_num, vl.TRAN_AMT, vl.USD_AMT, CASE WHEN ISNULL( vl.USD_AMT,0)<>0 THEN vl.TRAN_AMT/ISNULL(vl.USD_AMT,1) ELSE '' END  , @date, 
			vl.TRAN_TYPE, @company_id, ROW_NUMBER() OVER (ORDER BY vl.SERIAL ASC) part_tran_srl_num, GETDATE(),'s'
		FROM #voucherList vl WITH(NOLOCK) 
		INNER JOIN ac_master am WITH(NOLOCK) ON vl.acc_num = am.acct_num		
		WHERE vl.voucher_number = @current_voucher_number			
		

		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
		SELECT @ref_num, 'To record total international remittance send ', @voucher_type, @company_id, @date		
	    				       		
	END	

	--Writing voucher to database ends
	
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

	UPDATE SendMnPro_Remit.dbo.creditlimitint 
		SET  todaysSent = CASE WHEN ISNULL(todaysSent,0)>(USD_P_AMT+USD_P_COMM)  THEN ISNULL(todaysSent,0)- (USD_P_AMT+USD_P_COMM)  
						  ELSE 0 END 
	FROM 
	SendMnPro_Remit.dbo.creditlimitint L,#SEND T
	WHERE L.agentId=T.S_AGENT
			
	UPDATE REMIT_TRN_MASTER set
		F_INIT ='Y'		
	FROM REMIT_TRN_MASTER t with(nolock)  INNER JOIN #TEMPTXNSEND TT
	ON T.TRN_REF_NO = TT.TRN_REF_NO
	    
------## END OF VOUCHER ENTRY
	
IF @@TRANCOUNT > 0	
COMMIT TRANSACTION
IF LEN(@strMissingList)>0 
	SELECT @strMissingList = 'PROCESS COMPLETED WITH already Exists VOUCHER NO :' + @strMissingList
ELSE
	SET @strMissingList = 'PROCESS COMPLETED'

EXEC proc_errorHandler 0,@strMissingList,null

RETURN

 
END TRY
BEGIN CATCH
SET @strMissingList = ERROR_MESSAGE()
EXEC proc_errorHandler 0,@strMissingList,null

IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION
END CATCH



GO
