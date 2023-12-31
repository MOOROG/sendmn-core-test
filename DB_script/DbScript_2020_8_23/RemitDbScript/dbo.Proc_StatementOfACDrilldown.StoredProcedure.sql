USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_StatementOfACDrilldown]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC Proc_StatementOfACDrilldown @REPORTTYPE = 's', @FROMDATE = '05/27/2012', @TODATE = '05/27/2012', @agentId = '9', @VOUCHERTYPE = 's'

CREATE procEDURE [dbo].[Proc_StatementOfACDrilldown]
	@REPORTTYPE		CHAR(10),
	@FROMDATE		VARCHAR(20),
	@TODATE			VARCHAR(30),
	@AGENTID		INT = NULL,
	@VOUCHERTYPE	VARCHAR(10),
	@pageSize		INT	= NULL,
	@pageNumber		INT	= NULL
	
AS
SET NOCOUNT ON;
SET ANSI_NULLS ON;


	DECLARE @NUM			INT
			,@ROWNUM		INT
			,@CLOSEAMT		MONEY
			,@REPORTHEAD	VARCHAR(40)
			,@SQL			VARCHAR(1000)
			,@EXESQL		VARCHAR(MAX)
			,@AGENTNAME		VARCHAR(200)
			,@COMM_RATE		MONEY

	SET @pageSize = ISNULL(@pageSize,500)
	SET @pageNumber = ISNULL(@pageNumber,1)
	SELECT @COMM_RATE=commRate FROM enrollCommSetup WHERE agentId is null

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#TEMPSOADETAIL]') AND type in (N'U'))
DROP TABLE [dbo].[#TEMPSOADETAIL]

CREATE TABLE #TEMPSOADETAIL (
ROWID int identity(1,1),	TRAN_TYPE CHAR(2),id INT,TXNID VARCHAR(30), txndate DATETIME,remarks VARCHAR(200)
,dr_principal MONEY,dr_comm MONEY,cr_principal MONEY,cr_comm MONEY
,TOTAL money, CLOSING money , [DR/CR] CHAR(3)
)

--# SEND TRANSACTION
IF @VOUCHERTYPE ='S'
BEGIN
	SET @SQL = '
				SELECT 
					 [TRAN_TYPE]	= NULL
					,id
					,dbo.FNADecryptString(controlNo) controlNo 
					,CAST(approvedDate  AS DATE) approvedDate
					,[remarks]		= ''SEND''
					,[dr_principal]	= ISNULL(tAmt,0) 
					,[dr_comm]		= ISNULL(CAMT,0) - ISNULL(tAmt,0)
					,[cr_principal]	= 0
					,[cr_comm]		= 0
				FROM remitTran T WITH(NOLOCK)
				WHERE CAST(approvedDate AS DATE) BETWEEN ''' + @FROMDATE + ''' AND ''' + @TODATE + ''' 
					AND ISNULL(sAgent,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(sAgent,0))'
					
	SET @REPORTHEAD = 'Sending Detail Report'

END
--# CANCEL TRANSACTION
IF @VOUCHERTYPE ='C'
BEGIN
	SET @SQL = 'SELECT 
				NULL [TRAN_TYPE]
				,id
			   ,dbo.FNADecryptString(controlNo) controlNo
			   ,CAST(cancelApprovedDate AS DATE) cancelApprovedDate
			   ,''CANCEL'' [Particulars]
			   ,0 [dr_principal],0 [dr_comm]
			   ,ISNULL(tAmt,0) [cr_principal]
			   ,CASE WHEN CAST(approvedDate AS DATE)= CAST(cancelApprovedDate AS DATE) THEN ISNULL(CAMT,0)-ISNULL(tAmt,0)  ELSE 0 END[cr_comm]
	FROM remitTran T WITH(NOLOCK)
	WHERE CAST(cancelApprovedDate AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' 
	AND ISNULL(sAgent,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(sAgent,0))'

	SET @REPORTHEAD = 'Cancel Detail Report'

END
--# DOMESTIC PAID TRANSACTION
IF @VOUCHERTYPE ='DP'
BEGIN
	SET @SQL = 'SELECT 
					NULL [TRAN_TYPE]
					,id,dbo.FNADecryptString(controlNo) controlNo 
					,CAST(paidDate AS DATE) paidDate
					,''DOMESTIC PAID'' [Particulars]
					,0 [dr_principal]
					,0 [dr_comm]
					,ISNULL(pAmt,0)[cr_principal]
					,ISNULL(pAgentComm,0) [cr_comm]
				FROM remitTran T  WITH(NOLOCK)
				WHERE CAST(paidDate AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND ISNULL(pAgent,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(sAgent,0))
				AND sCountry = ''NEPAL'''

		SET @REPORTHEAD = 'Domestic Paid Detail Report'

END
--# INTERNATIONAL PAID TRANSACTION
IF @VOUCHERTYPE ='IP'
BEGIN
	SET @SQL = 'SELECT 
					NULL [TRAN_TYPE]
					,id
					,dbo.FNADecryptString(controlNo) controlNo 
					,CAST(paidDate AS DATE) paidDate
					,''INTERNATIONAL PAID'' [Particulars]
					,0 [dr_principal]
					,0 [dr_comm]
					,ISNULL(pAmt,0)[cr_principal]
					,ISNULL(pAgentComm,0) [cr_comm]
				FROM remitTran T  WITH(NOLOCK)
				WHERE CAST(paidDate AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND ISNULL(pAgent,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(sAgent,0))
				AND sCountry <> ''NEPAL'''

	SET @REPORTHEAD = 'International Paid Detail Report'

END

--# PAID ORDER TRANSACTION
IF @VOUCHERTYPE ='PO'
BEGIN
	SET @SQL = '
				SELECT 
					NULL [TRAN_TYPE]
					,RT.id
					,dbo.FNADecryptString(RT.controlNo) controlNo 
					,CAST(T.createdDate AS DATE) createdDate
					,''PAY ORDER'' [Particulars]
					,0 [dr_principal]
					,0 [dr_comm]
					,ISNULL(T.tranAmount,0) [cr_principal]
					,ISNULL(T.pAgentComm,0) [cr_comm]
				FROM errPaidTran T  WITH(NOLOCK)
				INNER JOIN remitTran RT WITH (NOLOCK) ON T.controlNo = RT.controlNo
				WHERE CAST(T.createdDate AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND ISNULL(T.newPAgentId,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(T.newPAgentId,0))'

	SET @REPORTHEAD = 'Pay Order Detail Report'

END

--# ERRONEOUSLY PAID TRANSACTION
IF @VOUCHERTYPE ='EP'
BEGIN
	SET @SQL = '
				SELECT 
					NULL [TRAN_TYPE]
					,RT.id
					,dbo.FNADecryptString(RT.controlNo) controlNo 
					,CAST(T.createdDate AS DATE) createdDate
					,''ERRONEOUSLY PAID'' [Particulars]
					,ISNULL(T.tranAmount,0) [dr_principal]
					,ISNULL(T.pAgentComm,0) [dr_comm]
					,0 [cr_principal]
					,0 [cr_comm]
				FROM errPaidTran T  WITH(NOLOCK)
				INNER JOIN remitTran RT WITH (NOLOCK) ON T.controlNo = RT.controlNo
				WHERE CAST(T.createdDate AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND ISNULL(T.oldPAgentId,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(T.oldPAgentId,0))'

	SET @REPORTHEAD = 'Erroneously Paid Detail Report'

END

IF @VOUCHERTYPE ='CR'
BEGIN
	SET @SQL = 'SELECT 
					T.tran_type
					,T.ref_num [ID]
					,T.ref_num  
					,CAST(T.tran_date AS DATE) tran_date
					,TD.tran_particular [REMARKS]
					,0 [dr_principal]
					,0 [dr_comm]
					,T.tran_amt  [cr_principal]
					,0 [cr_comm]
			FROM ac_master A WITH(NOLOCK)
			INNER JOIN tran_master T WITH(NOLOCK) ON T.acc_num=A.acct_num 
			INNER JOIN tran_masterDetail TD WITH(NOLOCK) ON T.ref_num =TD.ref_num
			WHERE CAST(tran_date AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND A.agent_id=ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(A.agent_id,0)) and A.acct_rpt_code=''22''
			AND (T.RPT_CODE IS NULL OR T.RPT_CODE=''FUND DEPOSIT'') AND T.part_tran_type=''CR'''

END	

IF @VOUCHERTYPE ='DR'
BEGIN
	SET @SQL = 'SELECT 
					T.tran_type
					,T.ref_num [ID]
					,T.ref_num
					,CAST(T.tran_date AS DATE) tran_date
					,TD.tran_particular [REMARKS]
					,0 [dr_principal]
					,0 [dr_comm]
					,T.tran_amt  [cr_principal]
					,0 [cr_comm]
				FROM ac_master A WITH(NOLOCK)
				INNER JOIN tran_master T WITH(NOLOCK) ON T.acc_num=A.acct_num 
				INNER JOIN tran_masterDetail TD WITH(NOLOCK) ON T.ref_num =TD.ref_num
				WHERE CAST(tran_date AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND A.agent_id=ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(A.agent_id,0)) and A.acct_rpt_code=''22''
				AND T.RPT_CODE IS NULL AND T.part_tran_type=''DR'''

END		

--IF @VOUCHERTYPE = 'ME'
--BEGIN
--	SET @SQL =' SELECT 
--				[TRAN_TYPE]	= NULL
--				,[ID]	= A.customerId
--				, A.customerId
--				,CAST(A.createdDate AS DATE) [TRANDATE]
--				,[Particulars]	= ''MEMBERSHIP ENROLLMENT'' 
--				,[dr_principal]	= 0 
--				,[dr_comm]		= 0 
--				,[cr_principal]	= SUM(ISNULL(D.commRate,ISNULL(@COMM_RATE,0)))
--				,[cr_comm]		= 0
--			FROM customers A WITH(NOLOCK) 
--			INNER JOIN applicationUsers b WITH(NOLOCK) ON a.createdBy=b.userName
--			INNER JOIN agentMaster c WITH(NOLOCK) ON c.agentId=b.agentId 
--			LEFT JOIN enrollCommSetup d WITH(NOLOCK) ON d.agentId=c.agentId
--			WHERE A.createdDate BETWEEN @fromDate AND @toDate AND ISNULL(C.agentId,0) = ISNULL(@agentId,ISNULL(C.agentId,0)) 
--			AND ISNULL(C.isDeleted,'''')<>''Y'' '
		
--END

--# PAID TRANSACTION
IF @VOUCHERTYPE ='P'
BEGIN
	SET @SQL = 'SELECT 
					NULL [TRAN_TYPE]
					,id,dbo.FNADecryptString(controlNo) controlNo 
					,CAST(paidDate AS DATE) paidDate
					,''PAID'' [Particulars]
					,0 [dr_principal]
					,0 [dr_comm]
					,ISNULL(pAmt,0)[cr_principal]
					,ISNULL(pAgentComm,0) [cr_comm]
				FROM remitTran T  WITH(NOLOCK)
				WHERE CAST(paidDate AS DATE) BETWEEN '''+@FROMDATE+''' AND '''+@TODATE+''' AND ISNULL(pAgent,0) =ISNULL('''+CAST(@AGENTID AS VARCHAR)+''' ,ISNULL(sAgent,0))
				'

		SET @REPORTHEAD = 'Paid Detail Report'

END

	
BEGIN
 SET @EXESQL = 'SELECT 
					Y.*
					,ISNULL(Y.dr_principal,0)+ISNULL(Y.dr_comm,0)-ISNULL(Y.cr_principal,0)-ISNULL(Y.cr_comm,0)[TOTAL],0 [CLOSING] 
					, NULL[DR/CR]
			FROM ( 

				'+@SQL+'
				
				) Y'


--PRINT @EXESQL
INSERT INTO #TEMPSOADETAIL
EXEC(@EXESQL)
	
	SET @NUM =1
	
	--ALTER TABLE #TEMPSOADETAIL
	--ADD ROWID INT IDENTITY(1,1)
	
	SELECT @ROWNUM=COUNT(*) FROM #TEMPSOADETAIL
	
	WHILE @NUM<=@ROWNUM
	BEGIN
		SELECT @CLOSEAMT = CLOSING FROM #TEMPSOADETAIL WHERE ROWID =@NUM-1
		IF @NUM = 1
		BEGIN
			SELECT @CLOSEAMT = TOTAL FROM #TEMPSOADETAIL WHERE ROWID =@NUM
			UPDATE #TEMPSOADETAIL SET CLOSING = @CLOSEAMT,
			[DR/CR] =CASE WHEN  @CLOSEAMT>0  THEN 0  ELSE 1 END 
			WHERE ROWID = 1
			SET @NUM = @NUM +1
		END
		
		UPDATE #TEMPSOADETAIL SET CLOSING = @CLOSEAMT+TOTAL
		,[DR/CR] = CASE WHEN CAST(@CLOSEAMT+TOTAL AS MONEY)>0 THEN 0 ELSE 1 END
		 WHERE ROWID = @NUM
		
		SET @NUM = @NUM +1
	END
	
	--SELECT * FROM #TEMPSOADETAIL
	SELECT 	TXNCOUNT = COUNT('A'),
			PAGESIZE = @pageSize,
			PAGENUMBER = @pageNumber 
	 FROM #TEMPSOADETAIL
	
	
	SELECT 
		 [Txn Date]	= CONVERT(VARCHAR, txnDate, 101)
		,[Txn No]		= '<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=Y&tranId='+CAST(id AS VARCHAR)+''')">'+ (TXNID) +'</a>'
		,[Particulars]	= remarks
		, DR_Principal
		,[DR_Commission]= DR_Comm 
		,CR_Principal
		,[CR_Commission]= CR_Comm 
		,[Closing]		= CASE WHEN Closing >0 THEN Closing ELSE Closing *-1 END 
		,CASE WHEN [DR/CR] =0 THEN 'DR' ELSE 'CR' END as ' '
	 FROM #TEMPSOADETAIL
	WHERE ROWID BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND @pageSize * @pageNumber
	
	--SET @REPORTHEAD = 'Sending Detail Report'
	
	DROP TABLE #TEMPSOADETAIL
END

SELECT @AGENTNAME=agentName FROM agentMaster WHERE agentId = @AGENTID

print @SQL
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', @agentId

SELECT 'Agent Name' head, @AGENTNAME value
UNION ALL
SELECT 'From Date' head, CONVERT(VARCHAR, CAST(@fromDate AS DATE), 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR, CAST(@toDate AS DATE), 101) value

SELECT 'Statement Of Account '+@REPORTHEAD title


GO
