USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcExtractDailyPaidTransation_nepal]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[ProcExtractDailyPaidTransation_nepal] 
 
 ----DECLARE
	@flag		CHAR(1),
	@date		VARCHAR(20),
	@company_id VARCHAR(5),	
	@user		VARCHAR(50) 
AS	

/*

exec [ProcExtractDailyPaidTransation_nepal] @flag='i',@date='2017-03-14',@company_id='1',@user='system'

SELECT * FROM #voucherList   ORDER BY VOUCHER_NUMBER,SERIAL
SELECT VOUCHER_NUMBER,SERIAL,SUM(TRAN_AMT) FROM   #voucherList   GROUP BY VOUCHER_NUMBER,SERIAL ORDER BY VOUCHER_NUMBER,SERIAL

SELECT * FROM #TEMPTXNPAID   WHERE S_AGENT=21295 IN ('10100000','33300082','33300191','12500000')
SELECT * FROM #SEND WHERE S_AGENT=21295 

*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @GLOBALREMIT INT = 6873
	,@KUMARIAPI INT = 9267

 DECLARE @RemitIntl VARCHAR(20),@COMMEXPINTL VARCHAR(30),@msg VARCHAR(MAX)

--------------------------------------------------------------------------
begin try
---------------DATA FOR VOUCHER GENERATION--------------------------------
	
	IF EXISTS(
		SELECT TOP 1 'A' FROM REMIT_TRN_MASTER R  WITH (NOLOCK)
		WHERE PAID_DATE < @date
		AND PAY_STATUS = 'Paid' AND F_PAID IS NULL
	)
	BEGIN
		SELECT @date = CONVERT(VARCHAR,MIN(PAID_DATE),101) FROM REMIT_TRN_MASTER R  WITH (NOLOCK)
		WHERE PAID_DATE < @date
		AND PAY_STATUS = 'Paid' AND F_PAID IS NULL

		SET @msg = 'BACK DATE VOUCHER GENERATION PENDING ON :'+ @date

		EXEC proc_errorHandler 1,@msg,null
		RETURN
	END

	IF OBJECT_ID(N'tempdb..#TEMPTXNPAID') IS NOT NULL
        DROP TABLE #TEMPTXNPAID
		
		 SELECT	 
				 TRN_REF_NO
				,S_AGENT
				,SC_S_AGENT
				,S_COUNTRY
				,TRN_TYPE
				,USD_AMT
				,SETTLEMENT_RATE
				,P_AMT
				,P_AGENT
				,P_BRANCH
				,SC_P_AGENT
				,agent_receiverSCommission
				,TRN_DATE
	INTO #TEMPTXNPAID
	FROM REMIT_TRN_MASTER R  WITH (NOLOCK)
	WHERE PAID_DATE BETWEEN @date  AND  @date+' 23:59:59'
	AND PAY_STATUS = 'Paid' AND F_PAID IS NULL
	
	IF NOT EXISTS(SELECT TOP 1 * FROM #TEMPTXNPAID)
	BEGIN
		EXEC proc_errorHandler 1,'VOUCHER ALREADY GENERATED / NO TRANSACTION FOUND',null
		RETURN;
	END
		
-----------------------VALIDATION PROCESS BEGINS--------------------
	DECLARE @strMissingList varchar(100) = ''
		
		  IF EXISTS(SELECT TOP 1 'X' FROM agentTable WITH (NOLOCK)
			 WHERE central_sett='N' 
			 --AND ISNULL(central_sett_code,'') = ''  AND ISNULL(IsMainAgent,'N')='N'
		  )
		  BEGIN

				  SELECT TOP 1 @strMissingList = COALESCE(@strMissingList + ', ', '') + 
					CAST(map_code AS varchar)+'-'+ (agent_name)
				  FROM agentTable WITH (NOLOCK)
				  WHERE central_sett='N' 
				  --AND ISNULL(central_sett_code,'') = ''  AND ISNULL(IsMainAgent,'N')='N'

				  SELECT @strMissingList = 'Wrong Headoffice Defined For: '+ @strMissingList

				  EXEC proc_errorHandler 1,@strMissingList,null

				  RETURN;
		  END

		 IF EXISTS(SELECT TOP 1 'X' FROM agentTable WITH (NOLOCK)
			 WHERE central_sett='Y' 
			 AND ISNULL(central_sett_code,'') NOT IN  (SELECT map_code FROM agentTable  WITH (NOLOCK))
			 --AND ISNULL(IsMainAgent,'N')='N'
		  )
		  BEGIN

				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
					CAST(map_code AS varchar)+'-'+ (agent_name)
				FROM agentTable WITH (NOLOCK)
				WHERE central_sett='Y' 
				AND ISNULL(central_sett_code,'') NOT IN  (SELECT map_code FROM agentTable  WITH (NOLOCK))
				--AND ISNULL(IsMainAgent,'N')='N'

			      --SELECT @strMissingList = 'Wrong Headoffice Defined For: '+ @strMissingList
			      EXEC proc_errorHandler 1,@strMissingList,null
				  RETURN;
		  END


		IF EXISTS(SELECT TOP 1 'X' FROM  #TEMPTXNPAID WHERE TRN_TYPE='Cash Pay'
		AND P_AGENT NOT IN (SELECT ISNULL(map_code,0) FROM agentTable)
		)
		BEGIN
		
				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(CAST(P_AGENT AS INT)AS VARCHAR)+'-'+ dbo.decryptDb(TRN_REF_NO)
				FROM #TEMPTXNPAID
				WHERE TRN_TYPE='Cash Pay'
					AND P_AGENT NOT IN (SELECT ISNULL(map_code,0) FROM agentTable)
				GROUP BY P_AGENT, TRN_REF_NO

				  --SELECT  @strMissingList='CASH PAY-AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList as REMARKS
				  EXEC proc_errorHandler 1,@strMissingList,null
				  RETURN;
		  END
		
		
		---- IF EXISTS(SELECT TOP 1 'X' FROM  #TEMPTXNPAID WHERE TRN_TYPE IN 
		---- ('Bank Transfer','Foreign Emp. Bond','RELIEF FUND') AND P_AGENT  NOT IN (SELECT ISNULL(map_code,0) FROM agentTable))
		----BEGIN
		----		SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
		----		   CAST(P_AGENT AS varchar(20))+'-'+ dbo.decryptDb(TRN_REF_NO)
		----		   FROM  #TEMPTXNPAID 
		----			 WHERE TRN_TYPE in ('Bank Transfer','Foreign Emp. Bond','RELIEF FUND')
		----			 AND P_AGENT  NOT IN (SELECT ISNULL(map_code,0) FROM agentTable)
		----			 GROUP BY P_AGENT,TRN_REF_NO

		----		--SELECT @strMissingList='Bank Deposit-AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList as REMARKS
		----		 EXEC proc_errorHandler 1,@strMissingList,null
		----		 RETURN;
		---- END

		
		IF EXISTS(SELECT TOP 1 'X' FROM  #TEMPTXNPAID 
		  WHERE TRN_TYPE NOT IN ('Bank Transfer','Cash Pay','Foreign Emp. Bond','RELIEF FUND')
		 
		)
		BEGIN
				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(TRN_TYPE AS varchar(20))+'-'+ dbo.decryptDb(TRN_REF_NO)
				FROM #TEMPTXNPAID 
				WHERE TRN_TYPE NOT IN ('Bank Transfer','Cash Pay','Foreign Emp. Bond','RELIEF FUND')
		 		GROUP BY TRN_TYPE,TRN_REF_NO

				--SELECT  @strMissingList ='Undefined transaction type '+ @strMissingList as REMARKS
				EXEC proc_errorHandler 1,@strMissingList,null
				 RETURN;
		 END
	
	
	ALTER TABLE #TEMPTXNPAID ADD SAGENTID INT


-----------------------VALIDATION PROCESS END---------------------------


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
			
    UPDATE #TEMPTXNPAID 
	    SET P_BRANCH = ISNULL(A.central_sett_code,T.P_BRANCH)  
    FROM #TEMPTXNPAID T
    INNER JOIN  agentTable A WITH(NOLOCK) ON A.map_code= T.P_BRANCH
    WHERE  TRN_TYPE='Cash Pay'

	UPDATE #TEMPTXNPAID 
	    SET P_AGENT = ISNULL(A.central_sett_code,T.P_AGENT)  
    FROM #TEMPTXNPAID T
    INNER JOIN  agentTable A WITH(NOLOCK) ON A.map_code= T.P_AGENT
    WHERE  TRN_TYPE IN   ('Bank Transfer','Foreign Emp. Bond','RELIEF FUND')
	 
 	UPDATE #TEMPTXNPAID SET SAGENTID = S.agent_id 
	FROM #TEMPTXNPAID T INNER JOIN AGENTTABLE S  WITH (NOLOCK)
	ON T.P_AGENT = S.map_code


	IF EXISTS(
		SELECT * FROM #TEMPTXNPAID WHERE SAGENTID IS NULL  
			)
	BEGIN
			SELECT  @strMissingList = COALESCE(@strMissingList + ', ', '') + 
			S_AGENT
			FROM  (SELECT DISTINCT S_AGENT FROM #TEMPTXNPAID WITH (NOLOCK) WHERE SAGENTID IS NULL) X
				
			--SELECT  @strMissingList ='AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList as REMARKS
			EXEC proc_errorHandler 1,@strMissingList ,null
			RETURN;
	END		


	SELECT * INTO #TEMPTHIRDPARTY FROM #TEMPTXNPAID 
	WHERE S_AGENT IN (@GLOBALREMIT,@KUMARIAPI)

	DELETE  FROM #TEMPTXNPAID WHERE S_AGENT IN (@GLOBALREMIT,@KUMARIAPI)

	---- FOR GLOBAL REMIT
	UPDATE T SET T.SC_S_AGENT = CO.sAgentComm  from #TEMPTHIRDPARTY t
	--INNER JOIN SendMnPro_Remit.dbo.countryMaster c (NOLOCK) ON T.S_COUNTRY = C.countryName
	CROSS APPLY SendMnPro_Remit.dbo.[FNAGetGIBLCommission](T.S_AGENT,t.TRN_REF_NO,1,'GIBL') CO
	WHERE S_AGENT = @GLOBALREMIT

	---- FOR REST OF THE AGENT
	
	UPDATE T SET T.SC_S_AGENT = CO.sAgentComm  from #TEMPTHIRDPARTY t
	--INNER JOIN SendMnPro_Remit.dbo.countryMaster c (NOLOCK) ON T.S_COUNTRY = C.countryName
	CROSS APPLY SendMnPro_Remit.dbo.[FNAGetGIBLCommission](T.S_AGENT,t.TRN_REF_NO,1,'KUMARI') CO
	WHERE S_AGENT = @KUMARIAPI

	--select T.S_AGENT,T.S_COUNTRY,1,T.P_AMT,* from #TEMPTHIRDPARTY t
	--INNER JOIN SendMnPro_Remit.dbo.countryMaster c (NOLOCK) ON T.S_COUNTRY = C.countryName
	--CROSS APPLY SendMnPro_Remit.dbo.[FNAGetGIBLCommission](T.S_AGENT,C.countryId,1,T.P_AMT,'KUMARI')
	--WHERE S_AGENT = @KUMARIAPI

	ALTER TABLE #TEMPTHIRDPARTY ADD PAGENTID INT

	UPDATE #TEMPTHIRDPARTY SET PAGENTID = S.agent_id 
	FROM #TEMPTHIRDPARTY T INNER JOIN AGENTTABLE S  WITH (NOLOCK)
	ON T.P_AGENT = S.map_code

	UPDATE #TEMPTHIRDPARTY SET SAGENTID = S.agent_id 
	FROM #TEMPTHIRDPARTY T INNER JOIN AGENTTABLE S  WITH (NOLOCK)
	ON T.S_AGENT = S.map_code

 SELECT @RemitIntl = '123654789'  --##Remitance Account - International
 SELECT @COMMEXPINTL = '291000173'  --##Commission Expenses - International Paid


----------Transaction Voucher-------------------
	INSERT INTO  #voucherList
	(ACC_NUM,ACC_NAME,TRAN_AMT,USD_AMT,PART_TRAN_TYPE,SERIAL,VOUCHER_NUMBER,GL_CODE,TRAN_TYPE) 
		SELECT 
			ACC_NUM,dbo.FUNGetAcName(ACC_NUM) ACC_NAME,TRAN_AMT,USD_AMT,PART_TRAN_TYPE,SERIAL,VOUCHER_NUMBER,dbo.FunGetGLCode(ACC_NUM) GL_CODE,'S' TRAN_TYPE
		FROM 
			(
-------------CASH PAY----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	@RemitIntl
						,TRAN_AMT		=	SUM(P_AMT)   
						,USD_AMT		=	SUM(USD_AMT) 
						,PART_TRAN_TYPE	=	'Dr'
						,SERIAL			=	1
						,VOUCHER_NUMBER	=	1
				FROM #TEMPTXNPAID P 
				----WHERE TRN_TYPE = 'Cash Pay'
	
				UNION ALL	

				SELECT  
						 ACC_NUM		=	@COMMEXPINTL
						,TRAN_AMT		=	SUM(SC_P_AGENT)   
						,USD_AMT		=	SUM(SC_P_AGENT/SETTLEMENT_RATE) 
						,PART_TRAN_TYPE	=	'Dr'
						,SERIAL			=	2
						,VOUCHER_NUMBER	=	1
				FROM #TEMPTXNPAID P 
				----WHERE TRN_TYPE = 'Cash Pay'

				UNION ALL	
				
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(P_AMT)   
						,USD_AMT		=	SUM(p.USD_AMT)  
						,PART_TRAN_TYPE	=	'CR'
						,SERIAL			=	3
						,VOUCHER_NUMBER	=	1
				FROM #TEMPTXNPAID P INNER JOIN AC_MASTER A ON P.SAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '20'	 ----'PRINCIPLE'
				----AND  TRN_TYPE='Cash Pay'
				GROUP BY ACCT_NUM	
	 
				UNION ALL	
				
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(SC_P_AGENT)   
						,USD_AMT		=	SUM(SC_P_AGENT/SETTLEMENT_RATE) 
						,PART_TRAN_TYPE	=	'CR'
						,SERIAL			=	4
						,VOUCHER_NUMBER	=	1
				FROM #TEMPTXNPAID P INNER JOIN AC_MASTER A ON P.SAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '21'	 ----'INTL COMMISSION'
				----AND  TRN_TYPE='Cash Pay'
				GROUP BY ACCT_NUM
			
			) AS TMP
			ORDER  BY VOUCHER_NUMBER, SERIAL ASC 

---- ## THIRDPARTY TXN VOUCHER
INSERT INTO  #voucherList
	(ACC_NUM,ACC_NAME,TRAN_AMT,USD_AMT,PART_TRAN_TYPE,SERIAL,VOUCHER_NUMBER,GL_CODE,TRAN_TYPE) 
		SELECT 
			ACC_NUM,dbo.FUNGetAcName(ACC_NUM) ACC_NAME,TRAN_AMT,USD_AMT,PART_TRAN_TYPE,SERIAL,VOUCHER_NUMBER,dbo.FunGetGLCode(ACC_NUM) GL_CODE,'S' TRAN_TYPE
		FROM 
			(
-------------CASH PAY----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(P_AMT)   
						,USD_AMT		=	0 
						,PART_TRAN_TYPE	=	'Dr'
						,SERIAL			=	1
						,VOUCHER_NUMBER	=	2
				FROM #TEMPTHIRDPARTY P INNER JOIN AC_MASTER A ON P.SAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = 'TP'	 ----'PRINCIPLE'
				AND  TRN_TYPE='Cash Pay'
				GROUP BY ACCT_NUM	
		UNION ALL
		-------------– Commission Receivable----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(SC_S_AGENT)   
						,USD_AMT		=	0 
						,PART_TRAN_TYPE	=	'Dr'
						,SERIAL			=	2
						,VOUCHER_NUMBER	=	2
				FROM #TEMPTHIRDPARTY P INNER JOIN AC_MASTER A ON P.SAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = 'TCR'	 ----'PRINCIPLE'
				AND  TRN_TYPE='Cash Pay'
				GROUP BY ACCT_NUM	
		UNION ALL
		-------------– PAY OUT AGENT PRINCIPLE----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(P_AMT)   
						,USD_AMT		=	0 
						,PART_TRAN_TYPE	=	'CR'
						,SERIAL			=	3
						,VOUCHER_NUMBER	=	2
				FROM #TEMPTHIRDPARTY P INNER JOIN AC_MASTER A ON P.PAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '20'	 ----'PRINCIPLE'
				AND  TRN_TYPE='Cash Pay'
				GROUP BY ACCT_NUM	
		UNION ALL
		-------------–  COMMINCOME_GIBLREMIT----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(SC_S_AGENT)   
						,USD_AMT		=	0 
						,PART_TRAN_TYPE	=	'CR'
						,SERIAL			=	4
						,VOUCHER_NUMBER	=	2
				FROM #TEMPTHIRDPARTY P 
				INNER JOIN AC_MASTER A ON P.SAGENTID = A.AGENT_ID
				WHERE TRN_TYPE='Cash Pay' 
				AND A.ACCT_RPT_CODE = 'TCI'
				--AND P.S_AGENT = @GLOBALREMIT  ---- GLOBAL REMIT AGENT ID
				GROUP BY ACCT_NUM	
		
		UNION ALL
		-------------– PAY OUT AGENT COMMISSION----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(SC_P_AGENT)   
						,USD_AMT		=	0 
						,PART_TRAN_TYPE	=	'CR'
						,SERIAL			=	5
						,VOUCHER_NUMBER	=	2
				FROM #TEMPTHIRDPARTY P INNER JOIN AC_MASTER A ON P.PAGENTID = A.AGENT_ID
				WHERE A.ACCT_RPT_CODE = '21'	 ----'PRINCIPLE'
				AND  TRN_TYPE = 'Cash Pay'
				GROUP BY ACCT_NUM	
		UNION ALL
		-------------–  COMMEXPENSE_ GIBLREMIT----------------------------------------------------------------------------		
				SELECT  
						 ACC_NUM		=	ACCT_NUM  
						,TRAN_AMT		=	SUM(SC_P_AGENT)   
						,USD_AMT		=	0 
						,PART_TRAN_TYPE	=	'DR'
						,SERIAL			=	6
						,VOUCHER_NUMBER	=	2
				FROM #TEMPTHIRDPARTY P 
				INNER JOIN AC_MASTER A ON P.SAGENTID = A.AGENT_ID
				WHERE TRN_TYPE = 'Cash Pay' 
				AND A.ACCT_RPT_CODE = 'TCE'
				GROUP BY ACCT_NUM	
		
	) AS TMP
	ORDER  BY VOUCHER_NUMBER, SERIAL ASC 

DELETE FROM #voucherList WHERE ISNULL(TRAN_AMT,0) = 0

----SELECT * FROM #voucherList 
----return
---------------------------------------------------TRANSACTION ENDS--------------------------------------

IF NOT EXISTS (SELECT 'X' FROM #voucherList)
BEGIN
	--SELECT 'NO TRANSACTION FOUND' remarks
	EXEC proc_errorHandler 1,'NO TRANSACTION FOUND',null
	RETURN
END

--##########################
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
	--SELECT 'Voucher must have both debit and credit leg. One or more voucher do not contain either debit or credit leg.' AS REMARKS
	EXEC proc_errorHandler 1,'Voucher must have both debit and credit leg. One or more voucher do not contain either debit or credit leg.',null
	--SELECT * FROM #voucherList 
	RETURN
END
--Checking voucher leg ends
 
 ----SELECT * FROM #voucherList
 ----RETURN

--Checking debit and credit balance voucher balance starts	
DECLARE @DR MONEY , @CR MONEY

SELECT @DR = SUM(TRAN_AMT) FROM #voucherList WHERE PART_TRAN_TYPE ='DR'
SELECT @CR = SUM(TRAN_AMT) FROM #voucherList WHERE PART_TRAN_TYPE ='CR'

IF ISNULL(@DR,0) <> ISNULL(@CR,0)
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
	
	set @strMissingList = ''

	WHILE EXISTS(SELECT 'X' FROM #voucherList WHERE voucher_number > @current_voucher_number)-- ORDER BY voucher_number ASC)
	BEGIN
		SELECT TOP 1 @voucher_type = TRAN_TYPE, @current_voucher_number = voucher_number FROM #voucherList WHERE voucher_number > @current_voucher_number ORDER BY voucher_number ASC
	     
		SELECT @ref_num  = ISNULL(transaction_voucher, 1) FROM billsetting 
		----WHERE v_code = @voucher_type            
		
		
			IF EXISTS (
							SELECT TOP 1 'X' FROM tran_master WITH (NOLOCK)
							WHERE ref_num =@ref_num AND tran_type= @voucher_type
						)
			BEGIN

							--SELECT 'Voucher no already Exists,	Wait for Another Process to complete and try again !' AS remarks
							SELECT @strMissingList = @strMissingList + @ref_num +' , '
							
			END
		
		
		UPDATE billsetting SET transaction_voucher = ISNULL(transaction_voucher, 1) + 1 
		----WHERE v_code = @voucher_type
	    
		INSERT INTO tran_master (
			entry_user_id, acc_num, gl_sub_head_code, part_tran_type, 
			ref_num, tran_amt, usd_amt, usd_rate, tran_date,
			tran_type, company_id, part_tran_srl_num,created_date,rpt_code
		 )	    
			
		SELECT 
			@user, vl.acc_num, am.gl_code, vl.PART_TRAN_TYPE, 
			@ref_num, vl.TRAN_AMT, vl.USD_AMT, CASE WHEN ISNULL( vl.USD_AMT,0)<>0 THEN vl.TRAN_AMT/vl.USD_AMT ELSE '' END  , @date, 
			vl.TRAN_TYPE, @company_id, ROW_NUMBER() OVER (ORDER BY vl.SERIAL ASC) part_tran_srl_num, GETDATE(),'s'
		FROM #voucherList vl WITH(NOLOCK) 
		INNER JOIN ac_master am WITH(NOLOCK) ON vl.acc_num = am.acct_num		
		WHERE vl.voucher_number = @current_voucher_number			
			
		
		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
		SELECT @ref_num, 'To record international remittance paid - ' + CASE WHEN  @current_voucher_number ='1' THEN 'through thirdparty' ELSE 'through agents' END , @voucher_type, @company_id, @date		
	END	

	--Writing voucher to database ends
	
--##########################
		UPDATE C 
			SET  todaysPaid = todaysPaid - Y.P_AMT
		FROM SendMnPro_Remit.dbo.creditlimit  C
		INNER JOIN (
			SELECT P_AMT = SUM(P_AMT),P_AGENT FROM (
				SELECT SUM(P_AMT) P_AMT,P_AGENT FROM #TEMPTXNPAID GROUP BY P_AGENT
				UNION ALL
				SELECT SUM(P_AMT),P_AGENT FROM #TEMPTHIRDPARTY GROUP BY P_AGENT
			)X GROUP BY P_AGENT
		)Y ON C.agentId = Y.P_AGENT

		
		UPDATE REMIT_TRN_MASTER set
		F_PAID = 'Y'		
		FROM REMIT_TRN_MASTER t with(nolock)   
		INNER JOIN #TEMPTXNPAID TT ON T.TRN_REF_NO = TT.TRN_REF_NO
	
		UPDATE REMIT_TRN_MASTER set
		F_PAID = 'Y'		
		FROM REMIT_TRN_MASTER t with(nolock)   
		INNER JOIN #TEMPTHIRDPARTY TT ON T.TRN_REF_NO = TT.TRN_REF_NO

	----- ############## Record history
		Exec JobHistoryRecord 'i','VOUCHER GENERATED','To record international remittance paid','',@user ,'',@user
		 
	
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
