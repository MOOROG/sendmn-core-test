USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_paidEODRemit]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec proc_paidEODRemit @user='admin',@TRANID='501'
-- PAID TRANSACTION EOD process

CREATE PROC [dbo].[proc_paidEODRemit]
	 @USER		VARCHAR(200)			,
     --@DATE		VARCHAR(20)	 = null,
     @TRANID	VARCHAR(50)			
AS

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#TEMPEODTABLE]') AND type in (N'U'))
	DROP TABLE [dbo].[#TEMPEODTABLE]
	--go
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#tempTRNEOD]') AND type in (N'U'))
	DROP TABLE [dbo].[#tempTRNEOD]
	--go

--DECLARE @USER	VARCHAR(100),@DATE	VARCHAR(20)
--SET @USER='SYSTEM'
--SET @DATE  = '2012-03-11'

BEGIN

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE		
		 @ref_num			INT
		,@intPartId			INT
		,@intTotalRows		INT
		,@strAccountNum		VARCHAR(20)
		,@strTranType		VARCHAR(20)
		,@TRN_AMT			MONEY
		,@IMEHO_PRINCIPAL	VARCHAR(30)
		,@IMEHO_REC			VARCHAR(30)
		,@COMMISSION_INCOME	VARCHAR(30)
		
		SET @IMEHO_PRINCIPAL = '301000251'
		SET @IMEHO_REC		 = '501000455'	
		SET @COMMISSION_INCOME = '801000511'


	SELECT PHub,PSuperAgent,PAgent,SUM(ISNULL(PAmt,0)) [PAmt],SUM(ISNULL(PSuperAgentComm,0)) [PSuperAgentComm]
	,SUM(isnull(pHubComm,0)) [PHubComm],SUM(isnull(PAgentComm,0)) [PAgentComm]
	INTO #TEMPEODTABLE  
	FROM remitTran WITH (NOLOCK)
	WHERE payEOD IS NULL AND pAmt IS NOT NULL 
	AND id = @TRANID AND paidDate IS NOT NULL
	--AND paidDate BETWEEN @DATE AND @DATE + ' 23:59:59' 
	GROUP BY pHub,pSuperAgent,pAgent

IF NOT EXISTS(SELECT TOP 1 * FROM #TEMPEODTABLE)
	BEGIN

		EXEC proc_errorHandler 1, '<FONT COLOR="RED">NO TRN FOUND</FONT>',NULL
		RETURN;
		
	END


	
SELECT
	IDENTITY(INT,1,1) AS SN,* 
			INTO #tempTRNEOD
			FROM (
				
				--- SENDING AGENT PRINCIPAL AC
				SELECT a.acct_num AS ACCT_NUM,'CR' AS TRN_TYPE
				,SUM(ISNULL(PAmt,0))AS amt,a.acct_rpt_code
				FROM #TEMPEODTABLE p JOIN ac_master a ON a.agent_id=p.pAgent
				WHERE a.acct_rpt_code=22
				GROUP BY acct_num,a.acct_rpt_code
				
				UNION ALL
				--- IME HO PRINCIPAL AC
				SELECT @IMEHO_PRINCIPAL AS ACCT_NUM,'DR' AS TRN_TYPE 
				,SUM(ISNULL(PAmt,0))AS amt,null
				FROM #TEMPEODTABLE 
				
				UNION ALL
				-- IME HO COMMISSION AC
				SELECT @IMEHO_REC AS ACCT_NUM,'DR' AS TRN_TYPE
				,SUM(ISNULL(pHubComm,0))AS amt,NULL
				FROM #TEMPEODTABLE 
				
				UNION ALL
				--- SENDING AGENT COMMISSION AC
				
				SELECT a.acct_num AS ACCT_NUM,'CR' AS TRN_TYPE
				,SUM(ISNULL(PAgentComm,0))AS amt,a.acct_rpt_code
				FROM #TEMPEODTABLE p JOIN ac_master a ON a.agent_id=p.PAgent
				WHERE a.acct_rpt_code=2
				GROUP BY acct_num,a.acct_rpt_code
				
				UNION ALL
				
				--- SUPER AGENT COMMISSION AC
				SELECT a.acct_num AS ACCT_NUM,'CR' AS TRN_TYPE
				, SUM(ISNULL(P.PSuperAgentComm,0))AS amt,a.acct_rpt_code
				FROM #TEMPEODTABLE p JOIN ac_master a ON a.agent_id=p.PSuperAgent
				GROUP BY acct_num,a.acct_rpt_code
				
				UNION ALL
				--- COMMISSION INCOME COMMISSION AC
				SELECT @COMMISSION_INCOME AS ACCT_NUM,'CR' AS TRN_TYPE
				,SUM(ISNULL(pHubComm,0)-(ISNULL(PAgentComm,0)+ISNULL(PSuperAgentComm,0)))AS amt,NULL
				FROM #TEMPEODTABLE 
			
		)a
		-- WHERE amt<>0
		
		--select * from #tempTRNEOD
		--select * from #TEMPEODTABLE
		--RETURN
		
		DECLARE @totalDR MONEY,@totalCR MONEY
		
		SELECT @totalDR=isnull(sum(amt),0) from #tempTRNEOD WITH (NOLOCK) 
		WHERE TRN_TYPE='DR' GROUP BY TRN_TYPE
			
		SELECT @totalCR=isnull(sum(amt),0) from #tempTRNEOD WITH (NOLOCK)  
		WHERE TRN_TYPE='CR' group by TRN_TYPE
			
		 
 
			-- conditions 1 for Total DR CR equal 

			IF ISNULL(@totalDR,0)<>ISNULL(@totalCR,0)
				BEGIN	
					EXEC proc_errorHandler 1, '<FONT COLOR="RED">DR and CR amount not Equal</font>' ,NULL
					RETURN
				END
		

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION

	SELECT @ref_num=ISNULL(TRAN_VOUCHER,1) FROM billSetting 
	
	UPDATE billSetting SET TRAN_VOUCHER = ISNULL(TRAN_VOUCHER,1)+1
	

	-------#####################  UPPDATE REMITTRAN TABLE SENDEOD FLAG
	UPDATE remitTran SET payEOD='Y'
	FROM remitTran WITH (NOLOCK)
	WHERE payEOD IS NULL AND ID = @TRANID
	--AND approvedDate BETWEEN @DATE AND @DATE + ' 23:59:59'
	
	--### UPDATE CLR BAL AMT 
	UPDATE ac_master SET 
						CLR_BAL_AMT=CASE 
						WHEN t.TRN_TYPE='DR' THEN ISNULL(CLR_BAL_AMT,0) - ISNULL(t.amt,0)
						ELSE ISNULL(CLR_BAL_AMT,0) -  ISNULL(-t.amt,0) 
						END
	FROM ac_master AS a
	INNER JOIN #tempTRNEOD AS t ON a.acct_num = t.acct_num
	
----------------------------------------------
SELECT @intPartId=max(SN) FROM #tempTRNEOD	
SET @intTotalRows=1
WHILE @intPartId >=  @intTotalRows
BEGIN

			SELECT @strAccountNum=ACCT_NUM,@strTranType=TRN_TYPE ,@TRN_AMT = amt
			FROM #tempTRNEOD WHERE SN=@intTotalRows

			Exec ProcDrCrUpdateFinal @strTranType,@strAccountNum,@TRN_AMT

SET @intTotalRows=@intTotalRows+1
END	
---------------------------------------------	
	
	INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,rpt_code,part_tran_type
	,ref_num,tran_amt,tran_date,tran_type,company_id,part_tran_srl_num,created_date,acct_type_code)
	SELECT @USER,c.acct_num,dbo.FNAGetGLCode(c.acct_num),'PAID' ,TRN_TYPE
	,@ref_num,amt,GETDATE(),'t','1',ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),acct_rpt_code
	from #tempTRNEOD c


	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type)
	SELECT TOP 1 @ref_num,'EOD of paid transaction: '+ CONVERT(VARCHAR(20),	GETDATE(),102) ,'1',GETDATE(),'t'

--SELECT * FROM tran_master WHERE rpt_code='PAID'
--SELECT * FROM tran_masterDetail

COMMIT TRANSACTION
--ROLLBACK TRANSACTION

--EXEC proc_errorHandler 0, '<font color="green">EOD Update successsfully for paid transaction please check daily reports</font>',NULL
		
		
END


GO
