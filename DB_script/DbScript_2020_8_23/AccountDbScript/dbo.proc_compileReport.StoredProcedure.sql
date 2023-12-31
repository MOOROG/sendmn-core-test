USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_compileReport]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
    exec proc_compileReport @flag='A',@DATE='2013-1-6', @reportJobId='1'
*/

create PROCEDURE [dbo].[proc_compileReport]
	@flag VARCHAR(10),
	@DATE			VARCHAR(20) = NULL,
	@SAGENT			VARCHAR(10) = NULL,
	@INCLUDEZERO	VARCHAR(1)  = NULL,
	@BANKCODE		VARCHAR(50)	= NULL,
	@DR1			VARCHAR(50) = NULL,
	@DR2			VARCHAR(50)	= NULL,
	@CR1			VARCHAR(50)	= NULL,
	@CR2			VARCHAR(50)	= NULL,
     @reportJobId   VARCHAR(20) = NULL

AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

IF @flag='A'
BEGIN

		DECLARE @DATE2 VARCHAR(10),@SQLQUERY VARCHAR (MAX)
		SELECT @DATE2=DATEADD (D,- 3,CAST(@DATE AS DATE))

		SET @SQLQUERY='
		INSERT INTO DUMP_COMPILE_REPORT (Bank_ID,Branch_Code,agent_name, BANKCODE, BANKBRANCH, BANKACCOUNTNUMBER, DR,CR, reportJobId  )  
		
		SELECT CASE WHEN ISNULL(ismainagent,''N'')=''Y'' THEN AGENT ELSE '''' END Bank_ID

		,CASE WHEN ISNULL(ismainagent,''N'')=''N'' THEN AGENT ELSE '''' END Branch_Code

		,UPPER(agent_name) agent_name

		,ISNULL(BANKCODE,'''')BANKCODE

		,ISNULL(BANKBRANCH,'''') BANKBRANCH

		,ISNULL(BANKACCOUNTNUMBER,'''') BANKACCOUNTNUMBER

		,ISNULL(CASE WHEN BALANCE<0 THEN ABS(BALANCE) ELSE 0 END,0) DR

		,ISNULL(CASE WHEN BALANCE<0 THEN 0 ELSE BALANCE END,0) CR
		,'+ @reportJobId +'
		FROM

		(

		SELECT AGENT, ISNULL(SUM(BALANCE),0) BALANCE FROM

		(

		SELECT CASE WHEN ISNULL(AT.central_sett,''N'')=''Y'' THEN ISNULL (AT.central_sett_code,map_code) ELSE MAP_CODE END AS AGENT , Z.BALANCE FROM (

		SELECT AGENT_ID, SUM(CASE WHEN PART_TRAN_TYPE=''DR'' THEN TRAN_AMT*-1 ELSE TRAN_AMT END) BALANCE FROM tran_master T WITH (NOLOCK)

		INNER JOIN (SELECT AGENT_ID,acct_num FROM ac_master WITH (NOLOCK) WHERE ACCT_RPT_CODE=''20'') X ON T.acc_num=X.acct_num

		WHERE tran_date<= ''' + @DATE+' 23:59:59''

		GROUP BY AGENT_ID

		) Z RIGHT JOIN agentTable AT WITH (NOLOCK) ON Z.agent_id=AT.agent_id

		AND ISNULL(AT.AcDepositBank,''N'')=''N''
		AND ISNULL(AT.AGENT_STATUS,''Y'')=''Y''
		AND AT.AGENT_TYPE=''Receiving''

		UNION ALL

		SELECT ISNULL (AT.central_sett_code,map_code) AGENT , ISNULL(AMT,0) AMT

		FROM (

		SELECT S_AGENT, (S_AMT)*-1 AMT

		FROM REMIT_TRN_LOCAL WITH ( NOLOCK)

		WHERE CONFIRM_DATE BETWEEN '''+@DATE2+''' AND '''+@DATE+' 23:59:59''

		AND F_SENDTRN IS NULL

		UNION ALL

		SELECT R_AGENT, (P_AMT) AMT

		FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK)

		WHERE P_DATE BETWEEN '''+@DATE2+''' AND '''+@DATE+' 23:59:59''

		AND F_STODAY_PTODAY IS NULL AND F_PTODAY_SYESTERDAY IS NULL

		UNION ALL

		SELECT S_AGENT,

		(CASE WHEN CAST(CONFIRM_DATE AS DATE)= CAST(CANCEL_DATE AS DATE) THEN ISNULL(S_AMT,0) ELSE ISNULL(P_AMT,0) + ISNULL(R_SC,0) END ) AMT

		FROM REMIT_TRN_LOCAL WITH ( NOLOCK)

		WHERE CANCEL_DATE BETWEEN '''+@DATE2+''' AND '''+@DATE+' 23:59:59''

		AND F_CODAY_SYESTERDAY IS NULL AND F_STODAY_CTODAY IS NULL

		) X

		RIGHT JOIN agentTable AT ON	X.S_AGENT=AT.AGENT_IME_CODE
		AND ISNULL(AT.AcDepositBank,''N'')=''N''
		AND ISNULL(AT.AGENT_STATUS,''Y'')=''Y''
		AND AT.AGENT_TYPE=''Receiving''

		UNION ALL

		SELECT ISNULL (AT.central_sett_code,map_code) AGENT ,ISNULL(P_AMT,0) P_AMT

		FROM REMIT_TRN_MASTER WITH (NOLOCK) RIGHT JOIN agentTable AT ON

		AT.map_code=CASE WHEN TRN_TYPE=''Bank Transfer'' THEN P_AGENT ELSE P_BRANCH END

		WHERE PAID_DATE BETWEEN '''+@DATE2+''' AND '''+@DATE+' 23:59:59''

		AND F_PAID IS NULL

		UNION ALL

		SELECT ISNULL (AT.central_sett_code,map_code) AGENT , AMOUNT*-1 AMT

		FROM ErroneouslyPaymentNew E WITH (NOLOCK), agentTable AT WITH (NOLOCK)

		WHERE CASE WHEN ISNULL(central_sett,''n'')=''y''

		THEN E.ep_agentCode ELSE E.ep_branchcode END = AT.map_code

		AND E.ep_date BETWEEN '''+@DATE2+''' AND ''' + @DATE+' 23:59:59''

		AND E.ep_vo IS NULL
		
		
		UNION ALL

		SELECT ISNULL (AT.central_sett_code,map_code) AGENT , AMOUNT AMT

		FROM ErroneouslyPaymentNew E WITH (NOLOCK), agentTable AT WITH (NOLOCK)

		WHERE CASE WHEN ISNULL(central_sett,''n'')=''y''

		THEN E.po_agentCode ELSE E.po_branchcode END = AT.map_code

		AND E.po_date BETWEEN '''+@DATE2+''' AND ''' + @DATE+' 23:59:59''

		AND E.po_vo IS NULL
		

		) XX

		GROUP BY AGENT

		) ZZ RIGHT JOIN agentTable A

		ON ZZ.AGENT=A.map_code

		WHERE AGENT<>0
	     AND ISNULL(A.AcDepositBank,''N'')=''N''
		AND ISNULL(A.AGENT_STATUS,''Y'')=''Y''

		AND A.AGENT_TYPE=''Receiving'''



		--print @SQLQUERY
		--IF @INCLUDEZERO <>'N'
		--SET @SQLQUERY= @SQLQUERY + ' AND ZZ.BALANCE<>0'

		IF @BANKCODE IS NOT NULL

		SET @SQLQUERY= @SQLQUERY + ' AND A.BANKCODE=''' +@BANKCODE + ''''

		IF @DR1 IS NOT NULL AND @DR2 IS NOT NULL AND @CR1 IS NULL AND @CR2 IS NULL

		SET @SQLQUERY= @SQLQUERY + ' AND ABS(BALANCE) BETWEEN '+@DR1+' AND '+@DR2+' '

		IF @CR1 IS NOT NULL AND @CR2 IS NOT NULL AND @DR1 IS NULL AND @DR2 IS NULL

		SET @SQLQUERY= @SQLQUERY + ' AND ABS(BALANCE) BETWEEN '+@CR1+' AND ' + @CR2+' '

		IF @CR1 IS NOT NULL AND @CR2 IS NOT NULL AND @DR1 IS NOT NULL AND @DR2 IS NOT NULL

		SET @SQLQUERY= @SQLQUERY + ' AND ((ABS(BALANCE) BETWEEN '+@CR1+' AND '+@CR2+') OR ( BALANCE <0 AND ABS(BALANCE) BETWEEN ' +@DR1 + ' AND ' + @DR2+')) '

		SET @SQLQUERY= @SQLQUERY + ' ORDER BY BANKCODE,agent_name'

	   
		EXECUTE (@SQLQUERY) 
		--PRINT @SQLQUERY

	     SELECT 'JOB CREATED FOR JOB ID:'+ @reportJobId as MSG
     
	     UPDATE ReportJobHistory
		  SET job_status = 'Y', job_desc ='Process completed, Ready for View', job_ready_date =GETDATE()
	     WHERE rowid = @reportJobId

END






GO
