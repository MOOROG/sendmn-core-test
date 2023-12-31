USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reconciliationReport]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_reconciliationReport]
(		 
	 @flag					VARCHAR(50)
	,@fromDate				VARCHAR(50)		= NULL
	,@toDate				VARCHAR(50)		= NULL
	,@user					VARCHAR(100)	= NULL	
	,@agentId               INT				= NULL
	,@userName				VARCHAR(50)		= NULL
	,@pageNumber			INT				= 1
	,@pageSize				INT				= 50
	,@box					VARCHAR(30)		= NULL
	,@isDocUpload			VARCHAR(10)		= NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
	
	IF ISDATE(@fromDate) < 1
	BEGIN
		SELECT '1' [S.N.], '<font color="red"><b>Date input is not valid.</b></font>' Remarks				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		SELECT 'Reconciliation  Report' title
		RETURN
	END
	IF ISDATE(@toDate) < 1
	BEGIN
		SELECT '1' [S.N.], '<font color="red"><b>Date input is not valid.</b></font>' Remarks				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		SELECT 'Reconciliation  Report' title
		RETURN

	END
			
	DECLARE 
		@sql VARCHAR(MAX)
		,@table VARCHAR(MAX)
		--,@oldToDate VARCHAR(50) = @toDate
		,@url VARCHAR(MAX)
		,@dtFromDate DATETIME = @fromDate
		,@dtToDate DATETIME  = @toDate +' 23:59:59'
		   

	IF @flag = 'complain-wise'
	BEGIN		
		IF @isDocUpload='Y'
		BEGIN
			SELECT 
				[S.N.] = ROW_NUMBER() OVER(ORDER BY am.agentName),
				[Agent Name] = am.agentName,
				[ICN] =  dbo.fnaDecryptstring(rt.controlNo),
				[Voucher Type] = CASE 
									WHEN vou.voucherType = 'sd'  THEN 'SEND Domestic' 
									WHEN vou.voucherType = 'pi' THEN 'PAID International' 
									WHEN vou.voucherType = 'pd' THEN 'PAID Domestic' 
									ELSE 'ALL' 
								 END,
				[Amount] = rt.pAmt,
				[Paid Date] = rt.paidDate,
				[Sender Name] = sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, ''),
				[Receiver Name] = rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, ''),
				[Complain Remarks] = vou.remarks 
			FROM voucherReconcilation vou WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON vou.agentId = am.agentId
			INNER JOIN vwRemitTranArchive rt WITH(NOLOCK) ON vou.tranId = rt.id
			INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id = rec.tranId
			INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id = sen.tranId
			INNER JOIN txnDocuments td with(NOLOCK) ON td.tdId=rt.id
				WHERE vou.createdDate BETWEEN @dtFromDate AND @dtToDate
					AND vou.[status] ='Complain'
					AND vou.agentId = ISNULL(@agentId, vou.agentId)
		END
		ELSE IF @isDocUpload='N'
		BEGIN
			SELECT 
				[S.N.] = ROW_NUMBER() OVER(ORDER BY am.agentName),
				[Agent Name] = am.agentName,
				[ICN] =  dbo.fnaDecryptstring(rt.controlNo),
				[Voucher Type] = CASE 
									WHEN vou.voucherType = 'sd'  THEN 'SEND Domestic' 
									WHEN vou.voucherType = 'pi' THEN 'PAID International' 
									WHEN vou.voucherType = 'pd' THEN 'PAID Domestic' 
									ELSE 'ALL' 
								 END,
				[Amount] = rt.pAmt,
				[Paid Date] = rt.paidDate,
				[Sender Name] = sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, ''),
				[Receiver Name] = rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, ''),
				[Complain Remarks] = vou.remarks 
			FROM voucherReconcilation vou WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON vou.agentId = am.agentId
			INNER JOIN vwRemitTranArchive rt WITH(NOLOCK) ON vou.tranId = rt.id
			INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id = rec.tranId
			INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id = sen.tranId
			LEFT JOIN txnDocuments td with(NOLOCK) ON td.tdId=rt.id
				WHERE vou.createdDate BETWEEN @dtFromDate AND @dtToDate
					AND vou.[status] ='Complain'
					AND vou.agentId = ISNULL(@agentId, vou.agentId)
					AND td.tdId is NULL
		END
		ELSE
		BEGIN
			SELECT 
				[S.N.] = ROW_NUMBER() OVER(ORDER BY am.agentName),
				[Agent Name] = am.agentName,
				[ICN] =  dbo.fnaDecryptstring(rt.controlNo),
				[Voucher Type] = CASE 
									WHEN vou.voucherType = 'sd'  THEN 'SEND Domestic' 
									WHEN vou.voucherType = 'pi' THEN 'PAID International' 
									WHEN vou.voucherType = 'pd' THEN 'PAID Domestic' 
									ELSE 'ALL' 
								 END,
				[Amount] = rt.pAmt,
				[Paid Date] = rt.paidDate,
				[Sender Name] = sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, ''),
				[Receiver Name] = rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, ''),
				[Complain Remarks] = vou.remarks 
			FROM voucherReconcilation vou WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON vou.agentId = am.agentId
			INNER JOIN vwRemitTranArchive rt WITH(NOLOCK) ON vou.tranId = rt.id
			INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id = rec.tranId	
			INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id = sen.tranId		
				WHERE vou.createdDate BETWEEN @dtFromDate AND @dtToDate
					AND vou.[status] ='Complain'
					AND vou.agentId = ISNULL(@agentId, vou.agentId)					
		END

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		UNION ALL
		SELECT  'Agent ' head, CASE WHEN @agentId IS NULL THEN 'All Agents' ELSE (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId) END value 
		SELECT 'Reconciliation Report: Voucher Complain -Wise' title
		RETURN;
	END

	IF @flag = 'reconcile-wise'
	BEGIN
		SET @url ='<a href="#" onclick=OpenInNewWindow("Reports.aspx?reportName=20182200_recon&user='+@user
							
		SELECT 
			id
			,agentId
			,fromDate
			,toDate	
			,voucherType
			,boxNo
			,send_d = ISNULL(send_d, 0)
			,paid_d = ISNULL(paid_d, 0)
			,paid_i = ISNULL(paid_i, 0)
			,total_txn = ISNULL(send_d, 0) + ISNULL(paid_d, 0) + ISNULL(paid_i, 0)	
			INTO #tempTable			
		FROM voucherReceive vr WITH(NOLOCK)
			WHERE fromDate >= @fromDate 
				AND toDate <= @ToDate
				AND agentId = ISNULL(@agentId , agentId)
		
		CREATE NONCLUSTERED INDEX idx_tmp ON #tempTable(id,agentId,fromDate,toDate,voucherType)
		
		IF @isDocUpload='Y'
		BEGIN			
			SELECT 
				[S.N.]			= ROW_NUMBER() OVER(ORDER BY am.agentName),
				[AGENT NAME]	= am.agentName,
				[FROM DATE]		= CONVERT(VARCHAR, b.fromDate, 101),
				[TO DATE]		= CONVERT(VARCHAR, b.toDate, 101),
				[VOUCHER TYPE]	= CASE 
									WHEN b.voucherType = 'sd' THEN 'SEND-D' 
									WHEN b.voucherType = 'pi' THEN 'PAID-I' 
									WHEN b.voucherType = 'pd' THEN 'PAID-D' 
									ELSE 'ALL' 
								 END,
				[BOX NO.]		= boxNo,		
				[Receive Transaction_SEND-D]	= SEND_D,
				[Receive Transaction_PAID-D]	= PAID_D,
				[Receive Transaction_PAID-I]	= PAID_I,
				[Receive Transaction_TOTAL]		= TOTAL_TXN,
				[Reconciliation_SEND-D]		= RSENDDEM,
				[Reconciliation_PAID-D]		= RPAIDDOM,
				[Reconciliation_PAID-I]		= RPAIDINT,
				[Reconciliation_TOTAL]		= Rtotal,
				[Complain_SEND-D]		= CSENDDEM,
				[Complain_PAID-D]		= CPAIDDOM,
				[Complain_PAID-I]		= CPAIDINT,
				[Complain_TOTAL]		= Ctotal,
				[Remaining_SEND-D]		= @url+'&flag=txn-wise-ddl-sd&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(SEND_D - RSENDDEM - CSENDDEM AS VARCHAR) + '</a>',

				[Remaining_PAID-D]		= @url+'&flag=txn-wise-ddl-pd&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(PAID_D - RPAIDDOM - CPAIDDOM AS VARCHAR) + '</a>',



				[Remaining_PAID-I]		= @url+'&flag=txn-wise-ddl-pi&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(PAID_I - RPAIDINT - CPAIDINT AS VARCHAR) + '</a>',



				[Remaining_TOTAL]		= TOTAL_TXN - Rtotal - Ctotal
			FROM (
				SELECT  
						 x.receivedId
						,x.agentId
						,RPaidDom = SUM(RPaidDom)
						,RPaidInt = SUM(RPaidInt)
						,Rsenddem = SUM(Rsenddem)
						,CPaidDom = SUM(CPaidDom)
						,CPaidInt = SUM(CPaidInt)
						,Csenddem = SUM(Csenddem)
						,Rtotal = SUM(RPaidDom) + SUM(RPaidInt) + SUM(Rsenddem)
						,Ctotal = SUM(CPaidDom) + SUM(CPaidInt) + SUM(Csenddem)
				FROM (
					SELECT 
						 vr.receivedId
						,vr.agentId				
						,CASE WHEN vr.voucherType='pd' AND  vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
						,CASE WHEN vr.voucherType='pi' AND  vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
						,CASE WHEN vr.voucherType='sd' AND  vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
						,CASE WHEN vr.voucherType='pd' AND  vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
						,CASE WHEN vr.voucherType='pi' AND  vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
						,CASE WHEN vr.voucherType='sd' AND  vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
					 FROM voucherReconcilation vr WITH(NOLOCK)
					 INNER JOIN #tempTable b ON vr.receivedId = b.id
					 INNER JOIN txnDocuments td ON td.tdId = vr.tranId
					 GROUP BY vr.receivedId,vr.agentId,vr.voucherType,vr.[STATUS]
				 )x GROUP BY receivedId, agentId
			 )x INNER JOIN #tempTable b ON x.receivedId = b.id
			 INNER JOIN agentMaster am WITH(NOLOCK) ON b.agentId = am.agentId
			 
		END
		ELSE IF @isDocUpload='N'
		BEGIN			
			SELECT 
				[S.N.]			= ROW_NUMBER() OVER(ORDER BY am.agentName),
				[AGENT NAME]	= am.agentName,
				[FROM DATE]		= CONVERT(VARCHAR, b.fromDate, 101),
				[TO DATE]		= CONVERT(VARCHAR, b.toDate, 101),
				[VOUCHER TYPE]	= CASE 
									WHEN b.voucherType = 'sd' THEN 'SEND-D' 
									WHEN b.voucherType = 'pi' THEN 'PAID-I' 
									WHEN b.voucherType = 'pd' THEN 'PAID-D' 
									ELSE 'ALL' 
								 END,
				[BOX NO.]		= boxNo,		
				[Receive Transaction_SEND-D]	= SEND_D,
				[Receive Transaction_PAID-D]	= PAID_D,
				[Receive Transaction_PAID-I]	= PAID_I,
				[Receive Transaction_TOTAL]		= TOTAL_TXN,
				[Reconciliation_SEND-D]		= RSENDDEM,
				[Reconciliation_PAID-D]		= RPAIDDOM,
				[Reconciliation_PAID-I]		= RPAIDINT,
				[Reconciliation_TOTAL]		= Rtotal,
				[Complain_SEND-D]		= CSENDDEM,
				[Complain_PAID-D]		= CPAIDDOM,
				[Complain_PAID-I]		= CPAIDINT,
				[Complain_TOTAL]		= Ctotal,
				[Remaining_SEND-D]		= @url+'&flag=txn-wise-ddl-sd&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(SEND_D - RSENDDEM - CSENDDEM AS VARCHAR) + '</a>',



				[Remaining_PAID-D]		= @url+'&flag=txn-wise-ddl-pd&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(PAID_D - RPAIDDOM - CPAIDDOM AS VARCHAR) + '</a>',



				[Remaining_PAID-I]		= @url+'&flag=txn-wise-ddl-pi&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(PAID_I - RPAIDINT - CPAIDINT AS VARCHAR) + '</a>',



				[Remaining_TOTAL]		= TOTAL_TXN - Rtotal - Ctotal
			FROM (
				SELECT  
						 x.receivedId
						,x.agentId
						,RPaidDom = SUM(RPaidDom)
						,RPaidInt = SUM(RPaidInt)
						,Rsenddem = SUM(Rsenddem)
						,CPaidDom = SUM(CPaidDom)
						,CPaidInt = SUM(CPaidInt)
						,Csenddem = SUM(Csenddem)
						,Rtotal = SUM(RPaidDom) + SUM(RPaidInt) + SUM(Rsenddem)
						,Ctotal = SUM(CPaidDom) + SUM(CPaidInt) + SUM(Csenddem)
				FROM (
					SELECT 
						 vr.receivedId
						,vr.agentId				
						,CASE WHEN vr.voucherType='pd' AND  vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
						,CASE WHEN vr.voucherType='pi' AND  vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
						,CASE WHEN vr.voucherType='sd' AND  vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
						,CASE WHEN vr.voucherType='pd' AND  vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
						,CASE WHEN vr.voucherType='pi' AND  vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
						,CASE WHEN vr.voucherType='sd' AND  vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
					 FROM voucherReconcilation vr WITH(NOLOCK)
					 INNER JOIN #tempTable b ON vr.receivedId = b.id
					 LEFT JOIN txnDocuments td ON td.tdId = vr.tranId
					 AND td.tdId is null
					 GROUP BY vr.receivedId,vr.agentId,vr.voucherType,vr.[STATUS]					 
				 )x GROUP BY receivedId, agentId
			 )x INNER JOIN #tempTable b ON x.receivedId = b.id
			 INNER JOIN agentMaster am WITH(NOLOCK) ON b.agentId = am.agentId
			 OPTION (MAXRECURSION 0)
		END
		ELSE
		BEGIN			
			SELECT 
				[S.N.]			= ROW_NUMBER() OVER(ORDER BY am.agentName),
				[AGENT NAME]	= am.agentName,
				[FROM DATE]		= CONVERT(VARCHAR, b.fromDate, 101),
				[TO DATE]		= CONVERT(VARCHAR, b.toDate, 101),
				[VOUCHER TYPE]	= CASE 
									WHEN b.voucherType = 'sd' THEN 'SEND-D' 
									WHEN b.voucherType = 'pi' THEN 'PAID-I' 
									WHEN b.voucherType = 'pd' THEN 'PAID-D' 
									ELSE 'ALL' 
								 END,
				[BOX NO.]		= boxNo,		
				[Receive Transaction_SEND-D]	= SEND_D,
				[Receive Transaction_PAID-D]	= PAID_D,
				[Receive Transaction_PAID-I]	= PAID_I,
				[Receive Transaction_TOTAL]		= TOTAL_TXN,
				[Reconciliation_SEND-D]		= RSENDDEM,
				[Reconciliation_PAID-D]		= RPAIDDOM,
				[Reconciliation_PAID-I]		= RPAIDINT,
				[Reconciliation_TOTAL]		= Rtotal,
				[Complain_SEND-D]		= CSENDDEM,
				[Complain_PAID-D]		= CPAIDDOM,
				[Complain_PAID-I]		= CPAIDINT,
				[Complain_TOTAL]		= Ctotal,
				[Remaining_SEND-D]		= @url+'&flag=txn-wise-ddl-sd&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(SEND_D - RSENDDEM - CSENDDEM AS VARCHAR) + '</a>',



				[Remaining_PAID-D]		= @url+'&flag=txn-wise-ddl-pd&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(PAID_D - RPAIDDOM - CPAIDDOM AS VARCHAR) + '</a>',



				[Remaining_PAID-I]		= @url+'&flag=txn-wise-ddl-pi&agentId=' + CAST(x.agentId AS VARCHAR) + '&fromDate=' + CONVERT(VARCHAR, b.fromDate, 101) + '&toDate=' + CONVERT(VARCHAR, b.toDate, 101)+'")>' + CAST(PAID_I - RPAIDINT - CPAIDINT AS VARCHAR) + '</a>',



				[Remaining_TOTAL]		= TOTAL_TXN - Rtotal - Ctotal
			FROM (
				SELECT  
						 x.receivedId
						,x.agentId
						,RPaidDom = SUM(RPaidDom)
						,RPaidInt = SUM(RPaidInt)
						,Rsenddem = SUM(Rsenddem)
						,CPaidDom = SUM(CPaidDom)
						,CPaidInt = SUM(CPaidInt)
						,Csenddem = SUM(Csenddem)
						,Rtotal = SUM(RPaidDom) + SUM(RPaidInt) + SUM(Rsenddem)
						,Ctotal = SUM(CPaidDom) + SUM(CPaidInt) + SUM(Csenddem)
				FROM (
					SELECT 
						 vr.receivedId
						,vr.agentId				
						,CASE WHEN vr.voucherType='pd' AND  [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
						,CASE WHEN vr.voucherType='pi' AND  [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
						,CASE WHEN vr.voucherType='sd' AND  [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
						,CASE WHEN vr.voucherType='pd' AND  [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
						,CASE WHEN vr.voucherType='pi' AND  [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
						,CASE WHEN vr.voucherType='sd' AND  [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
					 FROM voucherReconcilation vr WITH(NOLOCK)
					 INNER JOIN #tempTable b ON vr.receivedId = b.id
					 GROUP BY vr.receivedId,vr.agentId,vr.voucherType,vr.[STATUS]
				 )x GROUP BY receivedId, agentId
			 )x INNER JOIN #tempTable b ON x.receivedId = b.id
			 INNER JOIN agentMaster am WITH(NOLOCK) ON b.agentId = am.agentId
			 OPTION (MAXRECURSION 0)
		END
		 --ORDER BY am.agentName


		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		UNION ALL
		SELECT  'Agent ' head, CASE WHEN @agentId IS NULL THEN 'All Agents' ELSE (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId) END value 
		SELECT 'Reconciliation Report: Voucher Receive -Wise' title
		RETURN;
	END

	IF @flag = 'user-wise'
	BEGIN
		SELECT 
			 [S.N.]	= ROW_NUMBER() OVER(ORDER BY createdBy)
			,[User Name] = createdBy
			,[Reconcilition_SEND-D]		= SUM(Rsenddem)
			,[Reconcilition_PAID-D]		= SUM(RPaidDom)
			,[Reconcilition_PAID-I]		= SUM(RPaidInt)	
			,[Complain_SEND-D]			= SUM(Csenddem)
			,[Complain_PAID-D]			= SUM(CPaidDom)
			,[Complain_PAID-I]			= SUM(CPaidInt)	
			,[TOTAL]					= SUM(Rsenddem) + SUM(RPaidDom) + SUM(RPaidInt)	+  SUM(Csenddem) + SUM(CPaidDom) + SUM(CPaidInt)
		FROM (
			SELECT 
				createdBy
				,CASE WHEN vr.voucherType = 'pd' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
				,CASE WHEN vr.voucherType = 'pi' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
				,CASE WHEN vr.voucherType = 'sd' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
				,CASE WHEN vr.voucherType = 'pd' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
				,CASE WHEN vr.voucherType = 'pi' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
				,CASE WHEN vr.voucherType = 'sd' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
			FROM voucherReconcilation vr WITH(NOLOCK) 
				WHERE vr.createdDate BETWEEN @dtFromDate AND @dtToDate
					AND vr.createdBy = ISNULL(@userName, vr.createdBy)
			GROUP BY vr.createdBy, vr.voucherType, vr.[status]
		)x GROUP BY createdBy

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		UNION ALL
		SELECT  'User Name ' head, @userName  value 
		SELECT 'Reconciliation Report - User Summary' title
		RETURN;
	END

	if @flag = 'user-agent'
	BEGIN
		SELECT 
			 [S.N.]	= ROW_NUMBER() OVER(ORDER BY x.createdBy)
			,[User Name] = x.createdBy
			,[Agent] = am.agentName
			,[Reconcilition_SEND-D]		= SUM(Rsenddem)
			,[Reconcilition_PAID-D]		= SUM(RPaidDom)
			,[Reconcilition_PAID-I]		= SUM(RPaidInt)	
			,[Complain_SEND-D]			= SUM(Csenddem)
			,[Complain_PAID-D]			= SUM(CPaidDom)
			,[Complain_PAID-I]			= SUM(CPaidInt)	
			,[TOTAL]					= SUM(Rsenddem) + SUM(RPaidDom) + SUM(RPaidInt)	+  SUM(Csenddem) + SUM(CPaidDom) + SUM(CPaidInt)
		FROM (
			SELECT 
				 createdBy
				,agentId
				,CASE WHEN vr.voucherType='pd' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
				,CASE WHEN vr.voucherType='pi' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
				,CASE WHEN vr.voucherType='sd' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
				,CASE WHEN vr.voucherType='pd' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
				,CASE WHEN vr.voucherType='pi' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
				,CASE WHEN vr.voucherType='sd' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
			FROM voucherReconcilation vr WITH(NOLOCK) 
				WHERE vr.createdDate BETWEEN @dtFromDate AND @dtToDate					
					AND vr.createdBy = ISNULL(@userName, vr.createdBy)
			GROUP BY vr.createdBy,vr.voucherType,vr.[status],agentId
		)x INNER JOIN agentMaster am WITH(NOLOCK) ON x.agentId = am.agentId
		GROUP BY x.createdBy, am.agentName
		--ORDER BY x.createdBy


		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		UNION ALL
		SELECT  'User Name ' head, @userName  value 
		SELECT 'Reconciliation Report - User-Agent Summary' title
		RETURN;
	END

	IF @flag = 'txn-wise'
	BEGIN	
		IF (DATEDIFF(DAY,@fromDate,@toDate) > 62)
		BEGIN
			SELECT '1' [S.N.], 'Data Rage is not valid, Max. Report days: 62 days.' Remarks				
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
			SELECT  'Agent Name ' head, CASE WHEN @agentId IS NULL THEN 'All Agent' ELSE (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId) END value 
			SELECT 'Reconciliation  Report' title
			RETURN

		END
		
		SET @url ='<a href="#" onclick=OpenInNewWindow("Reports.aspx?reportName=20182200_recon&fromDate='+@fromDate+'&toDate='+@toDate+'&user='+@user
			
		IF OBJECT_ID('tempdb..#TEMP_TABLE') IS NOT NULL
			DROP TABLE #TEMP_TABLE


			SELECT 
				SEND_D ID, TRAN_TYPE, AGENT_ID INTO #TEMP_TABLE 
			FROM 
			(
				SELECT 
					SEND_D = id,
					TRAN_TYPE = 'SD',
					AGENT_ID = sBranch
				FROM vwRemitTranArchive WITH(NOLOCK) 
				WHERE sBranch = ISNULL(@agentId ,sBranch)
					AND tranType = 'D' 
					AND approvedDate BETWEEN @dtFromDate AND @dtToDate 
				UNION ALL
				SELECT 
					PAID_D = id,
					TRAN_TYPE = CASE WHEN tranType = 'D' THEN 'PD' ELSE 'PI' END,
					AGENT_ID = pBranch
				FROM vwRemitTranArchive WITH(NOLOCK) 
				WHERE pBranch = ISNULL(@agentId, pBranch)
					AND (tranType = 'D' OR tranType = 'I')
					AND paidDate BETWEEN @dtFromDate AND @dtToDate 				
			) x

		CREATE NONCLUSTERED INDEX idx ON #TEMP_TABLE(id, TRAN_TYPE, AGENT_ID)


		IF @isDocUpload='Y'
		BEGIN			
			SELECT 
				[S.N.]	= ROW_NUMBER() OVER(ORDER BY A.agentName),
				[AGENT] = agentName,
				[TRANSACTION_SEND-D] = ISNULL(Tsenddem,0),
				[TRANSACTION_PAID-D] = ISNULL(TPaidDom,0),
				[TRANSACTION_PAID-I] = ISNULL(TPaidInt,0),
				[RECONCILED_SEND-D] = @url + '&flag=tw-rec-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Rsenddem, 0) AS VARCHAR)+ '</a>',
				[RECONCILED_PAID-D] = @url + '&flag=tw-rec-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(RPaidDom, 0) AS VARCHAR)+ '</a>',
				[RECONCILED_PAID-I] = @url + '&flag=tw-rec-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(RPaidInt, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_SEND-D] = @url + '&flag=tw-com-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Csenddem, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_PAID-D] = @url + '&flag=tw-com-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(CPaidDom, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_PAID-I] = @url + '&flag=tw-com-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(CPaidInt, 0) AS VARCHAR)+ '</a>',
				[REMAINING_SEND-D] = @url + '&flag=txn-wise-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Tsenddem, 0) - ISNULL(Rsenddem, 0) - ISNULL(Csenddem, 0) AS VARCHAR) + '</a>',
				[REMAINING_PAID-D] = @url + '&flag=txn-wise-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(TPaidDom, 0) - ISNULL(RPaidDom, 0) - ISNULL(CPaidDom, 0) AS VARCHAR) + '</a>',
				[REMAINING_PAID-I] = @url + '&flag=txn-wise-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(TPaidInt, 0) - ISNULL(RPaidInt, 0) - ISNULL(CPaidInt, 0) AS VARCHAR) + '</a>'	
			FROM (
				SELECT 
					agentName  = am.agentName,
					agentId = am.agentId,
					TPaidDom = SUM(ISNULL(TPaidDom, 0)),
					TPaidInt = SUM(ISNULL(TPaidInt, 0)),
					Tsenddem = SUM(ISNULL(Tsenddem, 0))
				FROM (
					SELECT 	 
						AGENT_ID
						,CASE WHEN TRAN_TYPE='pd' THEN COUNT('a') ELSE 0 END TPaidDom
						,CASE WHEN TRAN_TYPE='pi' THEN COUNT('a') ELSE 0 END TPaidInt
						,CASE WHEN TRAN_TYPE='sd' THEN COUNT('a') ELSE 0 END Tsenddem
					FROM #TEMP_TABLE
					GROUP BY AGENT_ID, TRAN_TYPE
				)Y
				INNER JOIN agentMaster am WITH(NOLOCK) ON y.AGENT_ID = am.agentId
				GROUP BY agentName, agentId
			)A 
			LEFT JOIN (
				SELECT 
					agentId = x.agentId,
					RPaidDom = SUM(ISNULL(RPaidDom, 0)),
					RPaidInt = SUM(ISNULL(RPaidInt, 0)),
					Rsenddem = SUM(ISNULL(Rsenddem, 0)),
					CPaidDom = SUM(ISNULL(CPaidDom, 0)),
					CPaidInt = SUM(ISNULL(CPaidInt, 0)),
					Csenddem = SUM(ISNULL(Csenddem, 0)) 
				FROM (
					SELECT	
						vr.agentId	 
						,CASE WHEN vr.voucherType = 'pd' AND TRAN_TYPE = 'PD' AND vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
						,CASE WHEN vr.voucherType = 'pi' AND TRAN_TYPE = 'PI' AND vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
						,CASE WHEN vr.voucherType = 'sd' AND TRAN_TYPE = 'SD' AND vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
						,CASE WHEN vr.voucherType = 'pd' AND TRAN_TYPE = 'PD' AND vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
						,CASE WHEN vr.voucherType = 'pi' AND TRAN_TYPE = 'PI' AND vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
						,CASE WHEN vr.voucherType = 'sd' AND TRAN_TYPE = 'SD' AND vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
					FROM voucherReconcilation vr WITH(NOLOCK) 
					INNER JOIN #TEMP_TABLE b on vr.tranid = b.id AND b.AGENT_ID = vr.agentId
					INNER JOIN txnDocuments td WITH(NOLOCK) ON td.tdId=vr.tranId
					GROUP BY vr.agentId, vr.voucherType, vr.[STATUS], TRAN_TYPE
				)x GROUP BY agentId
			)B ON A.agentId = B.agentId
		END
		ELSE IF @isDocUpload='N'
		BEGIN			
			SELECT 
				[S.N.]	= ROW_NUMBER() OVER(ORDER BY A.agentName),
				[AGENT] = agentName,
				[TRANSACTION_SEND-D] = ISNULL(Tsenddem,0),
				[TRANSACTION_PAID-D] = ISNULL(TPaidDom,0),
				[TRANSACTION_PAID-I] = ISNULL(TPaidInt,0),
				[RECONCILED_SEND-D] = @url + '&flag=tw-rec-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Rsenddem, 0) AS VARCHAR)+ '</a>',
				[RECONCILED_PAID-D] = @url + '&flag=tw-rec-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(RPaidDom, 0) AS VARCHAR)+ '</a>',
				[RECONCILED_PAID-I] = @url + '&flag=tw-rec-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(RPaidInt, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_SEND-D] = @url + '&flag=tw-com-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Csenddem, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_PAID-D] = @url + '&flag=tw-com-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(CPaidDom, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_PAID-I] = @url + '&flag=tw-com-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(CPaidInt, 0) AS VARCHAR)+ '</a>',
				[REMAINING_SEND-D] = @url + '&flag=txn-wise-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Tsenddem, 0) - ISNULL(Rsenddem, 0) - ISNULL(Csenddem, 0) AS VARCHAR) + '</a>',
				[REMAINING_PAID-D] = @url + '&flag=txn-wise-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(TPaidDom, 0) - ISNULL(RPaidDom, 0) - ISNULL(CPaidDom, 0) AS VARCHAR) + '</a>',
				[REMAINING_PAID-I] = @url + '&flag=txn-wise-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(TPaidInt, 0) - ISNULL(RPaidInt, 0) - ISNULL(CPaidInt, 0) AS VARCHAR) + '</a>'	
			FROM (
				SELECT 
					agentName  = am.agentName,
					agentId = am.agentId,
					TPaidDom = SUM(ISNULL(TPaidDom, 0)),
					TPaidInt = SUM(ISNULL(TPaidInt, 0)),
					Tsenddem = SUM(ISNULL(Tsenddem, 0))
				FROM (
					SELECT 	 
						AGENT_ID
						,CASE WHEN TRAN_TYPE='pd' THEN COUNT('a') ELSE 0 END TPaidDom
						,CASE WHEN TRAN_TYPE='pi' THEN COUNT('a') ELSE 0 END TPaidInt
						,CASE WHEN TRAN_TYPE='sd' THEN COUNT('a') ELSE 0 END Tsenddem
					FROM #TEMP_TABLE
					GROUP BY AGENT_ID, TRAN_TYPE
				)Y
				INNER JOIN agentMaster am WITH(NOLOCK) ON y.AGENT_ID = am.agentId
				GROUP BY agentName, agentId
			)A 
			LEFT JOIN (
				SELECT 
					agentId = x.agentId,
					RPaidDom = SUM(ISNULL(RPaidDom, 0)),
					RPaidInt = SUM(ISNULL(RPaidInt, 0)),
					Rsenddem = SUM(ISNULL(Rsenddem, 0)),
					CPaidDom = SUM(ISNULL(CPaidDom, 0)),
					CPaidInt = SUM(ISNULL(CPaidInt, 0)),
					Csenddem = SUM(ISNULL(Csenddem, 0)) 
				FROM (
					SELECT	
						vr.agentId	 
						,CASE WHEN vr.voucherType = 'pd' AND TRAN_TYPE = 'PD' AND vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
						,CASE WHEN vr.voucherType = 'pi' AND TRAN_TYPE = 'PI' AND vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
						,CASE WHEN vr.voucherType = 'sd' AND TRAN_TYPE = 'SD' AND vr.[STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
						,CASE WHEN vr.voucherType = 'pd' AND TRAN_TYPE = 'PD' AND vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
						,CASE WHEN vr.voucherType = 'pi' AND TRAN_TYPE = 'PI' AND vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
						,CASE WHEN vr.voucherType = 'sd' AND TRAN_TYPE = 'SD' AND vr.[STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
					FROM voucherReconcilation vr WITH(NOLOCK) 
					INNER JOIN #TEMP_TABLE b on vr.tranid = b.id AND b.AGENT_ID = vr.agentId
					LEFT JOIN txnDocuments td WITH(NOLOCK) ON td.tdId=vr.tranId
					WHERE td.tdId is NULL
					GROUP BY vr.agentId, vr.voucherType, vr.[STATUS], TRAN_TYPE
				)x GROUP BY agentId
			)B ON A.agentId = B.agentId
		END
		ELSE
		BEGIN			
			SELECT 
				[S.N.]	= ROW_NUMBER() OVER(ORDER BY A.agentName),
				[AGENT] = agentName,
				[TRANSACTION_SEND-D] = ISNULL(Tsenddem,0),
				[TRANSACTION_PAID-D] = ISNULL(TPaidDom,0),
				[TRANSACTION_PAID-I] = ISNULL(TPaidInt,0),
				[RECONCILED_SEND-D] = @url + '&flag=tw-rec-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Rsenddem, 0) AS VARCHAR)+ '</a>',
				[RECONCILED_PAID-D] = @url + '&flag=tw-rec-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(RPaidDom, 0) AS VARCHAR)+ '</a>',
				[RECONCILED_PAID-I] = @url + '&flag=tw-rec-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(RPaidInt, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_SEND-D] = @url + '&flag=tw-com-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Csenddem, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_PAID-D] = @url + '&flag=tw-com-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(CPaidDom, 0) AS VARCHAR)+ '</a>',
				[COMPLAINED_PAID-I] = @url + '&flag=tw-com-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(CPaidInt, 0) AS VARCHAR)+ '</a>',
				[REMAINING_SEND-D] = @url + '&flag=txn-wise-ddl-sd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(Tsenddem, 0) - ISNULL(Rsenddem, 0) - ISNULL(Csenddem, 0) AS VARCHAR) + '</a>',
				[REMAINING_PAID-D] = @url + '&flag=txn-wise-ddl-pd&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(TPaidDom, 0) - ISNULL(RPaidDom, 0) - ISNULL(CPaidDom, 0) AS VARCHAR) + '</a>',
				[REMAINING_PAID-I] = @url + '&flag=txn-wise-ddl-pi&agentId=' + CAST(a.agentId AS VARCHAR) + '")>' + CAST(ISNULL(TPaidInt, 0) - ISNULL(RPaidInt, 0) - ISNULL(CPaidInt, 0) AS VARCHAR) + '</a>'	
			FROM (
				SELECT 
					agentName  = am.agentName,
					agentId = am.agentId,
					TPaidDom = SUM(ISNULL(TPaidDom, 0)),
					TPaidInt = SUM(ISNULL(TPaidInt, 0)),
					Tsenddem = SUM(ISNULL(Tsenddem, 0))
				FROM (
					SELECT 	 
						AGENT_ID
						,CASE WHEN TRAN_TYPE='pd' THEN COUNT('a') ELSE 0 END TPaidDom
						,CASE WHEN TRAN_TYPE='pi' THEN COUNT('a') ELSE 0 END TPaidInt
						,CASE WHEN TRAN_TYPE='sd' THEN COUNT('a') ELSE 0 END Tsenddem
					FROM #TEMP_TABLE
					GROUP BY AGENT_ID, TRAN_TYPE
				)Y
				INNER JOIN agentMaster am WITH(NOLOCK) ON y.AGENT_ID = am.agentId
				GROUP BY agentName, agentId
			)A 
			LEFT JOIN (
				SELECT 
					agentId = x.agentId,
					RPaidDom = SUM(ISNULL(RPaidDom, 0)),
					RPaidInt = SUM(ISNULL(RPaidInt, 0)),
					Rsenddem = SUM(ISNULL(Rsenddem, 0)),
					CPaidDom = SUM(ISNULL(CPaidDom, 0)),
					CPaidInt = SUM(ISNULL(CPaidInt, 0)),
					Csenddem = SUM(ISNULL(Csenddem, 0)) 
				FROM (
					SELECT	
						vr.agentId	 
						,CASE WHEN vr.voucherType = 'pd' AND TRAN_TYPE = 'PD' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidDom
						,CASE WHEN vr.voucherType = 'pi' AND TRAN_TYPE = 'PI' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END RPaidInt
						,CASE WHEN vr.voucherType = 'sd' AND TRAN_TYPE = 'SD' AND [STATUS] = 'Reconciled' THEN COUNT('a') ELSE 0 END Rsenddem
						,CASE WHEN vr.voucherType = 'pd' AND TRAN_TYPE = 'PD' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidDom
						,CASE WHEN vr.voucherType = 'pi' AND TRAN_TYPE = 'PI' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END CPaidInt
						,CASE WHEN vr.voucherType = 'sd' AND TRAN_TYPE = 'SD' AND [STATUS] = 'Complain'   THEN COUNT('a') ELSE 0 END Csenddem
					FROM voucherReconcilation vr WITH(NOLOCK) 
					INNER JOIN #TEMP_TABLE b on vr.tranid = b.id AND b.AGENT_ID = vr.agentId
					GROUP BY vr.agentId, vr.voucherType, [STATUS], TRAN_TYPE
				)x GROUP BY agentId
			)B ON A.agentId = B.agentId
		END
		
		--ORDER BY A.agentName

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT 'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT 'Agent Name ' head, CASE WHEN @agentId IS NULL THEN 'All Agent' ELSE (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId) END value 
		SELECT 'Reconciliation  Report' title
		RETURN
					
	END

	IF @flag = 'txn-wise-ddl-sd'
	BEGIN
		
		--;WITH Temp
		--AS
		--(	SELECT 
		--		vr.id
		--	FROM vwRemitTranArchive vr WITH(NOLOCK) 
		--	LEFT JOIN (
		--		SELECT 
		--			tranId 
		--		FROM voucherReconcilation ds WITH(NOLOCK)
		--			WHERE (ds.[status] = 'Reconciled' OR ds.[status] = 'Complain') 
		--			AND ds.voucherType='sd'
		--	) x ON vr.id = x.tranId
		--	WHERE sBranch = @agentId
		--		AND tranType = 'D' 
		--		AND approvedDate BETWEEN @dtFromDate AND @dtToDate 
		--		AND x.tranid IS NULL
		--)
		
		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Send Date]		= rt.createdDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.sBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Send User]		= rt.createdBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN (	
			SELECT 
				vr.id
			FROM vwRemitTranArchive vr WITH(NOLOCK) 
			LEFT JOIN (
				SELECT 
					tranId 
				FROM voucherReconcilation ds WITH(NOLOCK)
					WHERE (ds.[status] = 'Reconciled' OR ds.[status] = 'Complain') 
					AND ds.voucherType='sd'
			) x ON vr.id = x.tranId
			WHERE sBranch = @agentId
				AND tranType = 'D' 
				AND approvedDate BETWEEN @dtFromDate AND @dtToDate 
				AND x.tranid IS NULL
		) t ON t.id = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report- Remaining Send Domestic' title
		RETURN
	END	

	IF @flag = 'txn-wise-ddl-pd'
	BEGIN
		--IF OBJECT_ID('tempdb..#TEMP1') IS NOT NULL
		--	DROP TABLE #TEMP1

		--SELECT id
		--INTO #TEMP1
		--FROM vwRemitTranArchive WITH(NOLOCK) 
		--WHERE pBranch = @agentId
		--	and tranType = 'D' 
		--	and paidDate between @fromDate and @toDate +' 23:59:59' 

		--DELETE FROM #TEMP1 						
		--FROM #TEMP1 t INNER JOIN voucherReconcilation ds WITH(NOLOCK) ON t.id = ds.tranId
		--where ds.status in ('Reconciled','Complain') and ds.voucherType='pd'

		--;WITH Temp
		--AS
		--(	SELECT 
		--		vr.id
		--	FROM vwRemitTranArchive vr WITH(NOLOCK) 
		--	LEFT JOIN (
		--		SELECT 
		--			tranId 
		--		FROM voucherReconcilation ds WITH(NOLOCK)
		--			WHERE (ds.[status] = 'Reconciled' OR ds.[status] = 'Complain') 
		--			AND ds.voucherType='pd'
		--	) x ON vr.id = x.tranId
		--	WHERE pBranch = @agentId
		--		AND tranType = 'D' 
		--		AND paidDate BETWEEN @dtFromDate AND @dtToDate 
		--		AND x.tranid IS NULL
		--)

		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Paid Date]		= rt.paidDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.pBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Paid User]		= rt.paidBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN (	
			SELECT 
				vr.id
			FROM vwRemitTranArchive vr WITH(NOLOCK) 
			LEFT JOIN (
				SELECT 
					tranId 
				FROM voucherReconcilation ds WITH(NOLOCK)
					WHERE (ds.[status] = 'Reconciled' OR ds.[status] = 'Complain') 
					AND ds.voucherType='pd'
			) x ON vr.id = x.tranId
			WHERE pBranch = @agentId
				AND tranType = 'D' 
				AND paidDate BETWEEN @dtFromDate AND @dtToDate 
				AND x.tranid IS NULL
		) t on t.id = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report -Remaining Paid Domestic' title
		RETURN
	END	

	IF @flag = 'txn-wise-ddl-pi'
	BEGIN
		--IF OBJECT_ID('tempdb..#TEMP2') IS NOT NULL
		--	DROP TABLE #TEMP2

		--SELECT id
		--INTO #TEMP2
		--FROM vwRemitTranArchive WITH(NOLOCK) 
		--WHERE pBranch = @agentId
		--	and tranType = 'I' 
		--	and paidDate between @fromDate and @toDate +' 23:59:59' 

		--DELETE FROM #TEMP2 						
		--FROM #TEMP2 t INNER JOIN voucherReconcilation ds WITH(NOLOCK) ON t.id = ds.tranId
		--where ds.status in ('Reconciled','Complain') and ds.voucherType='pi'
		
		--;WITH TEMP2
		--AS
		--(	
		--	SELECT 
		--		vr.id
		--	FROM vwRemitTranArchive vr WITH(NOLOCK) 
		--	LEFT JOIN (
		--		SELECT 
		--			tranId 
		--		FROM voucherReconcilation ds WITH(NOLOCK)
		--			WHERE (ds.[status] = 'Reconciled' OR ds.[status] = 'Complain') 
		--			AND ds.voucherType='pi'
		--	) x ON vr.id = x.tranId
		--	WHERE pBranch = @agentId
		--		AND tranType = 'I' 
		--		AND paidDate BETWEEN @dtFromDate AND @dtToDate 
		--		AND x.tranid IS NULL
		--)
		
		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Paid Date]		= rt.paidDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.pBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Paid User]		= rt.paidBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN (
			SELECT 
				vr.id
			FROM vwRemitTranArchive vr WITH(NOLOCK) 
			LEFT JOIN (
				SELECT 
					tranId 
				FROM voucherReconcilation ds WITH(NOLOCK)
					WHERE (ds.[status] = 'Reconciled' OR ds.[status] = 'Complain') 
						AND ds.voucherType='pi'
			) x ON vr.id = x.tranId
			WHERE pBranch = @agentId
				AND tranType = 'I' 
				AND paidDate BETWEEN @dtFromDate AND @dtToDate 
				AND x.tranid IS NULL
		) t ON t.id = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report -Remaining Paid International' title
		RETURN
	END

	IF @flag='box-wise'
	BEGIN
		SELECT 
			 [S.N]	= ROW_NUMBER() OVER(ORDER BY boxno ASC)
			,[Date]	= CONVERT(VARCHAR,createdDate,101)
			,[User]	= createdBy
			,Box	= boxNo 
		FROM boxNumberList WITH(NOLOCK)
				
			WHERE boxNo = ISNULL(@box, boxNo)
			AND createdBy = ISNULL(@userName, createdBy)
			AND createdDate BETWEEN @dtFromDate AND @dtToDate
			AND flag='b'
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'User Name' head, ISNULL(@userName,'All') value UNION ALL
		SELECT  'Box Number' head, ISNULL(@box,'All') value
		SELECT 'Reconcilled Box Report' title
		RETURN
	END

	-- ## Reconciled drildown
	IF @flag = 'tw-rec-ddl-sd'
	BEGIN
		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Send Date]		= rt.createdDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.sBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Send User]		= rt.createdBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
			,[Reconciled User]	= t.createdBy
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN voucherReconcilation t ON t.tranId = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId
		WHERE rt.approvedDate BETWEEN @dtFromDate and @dtToDate
			AND rt.sBranch = @agentId
			AND rt.tranType = 'D'  
			AND t.[status] = 'Reconciled'
			AND t.voucherType='sd'		

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report- Reconciled Send Domestic' title
		RETURN
	END	

	IF @flag = 'tw-rec-ddl-pd'
	BEGIN
		SELECT  
			[S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Paid Date]		= rt.paidDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.pBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Paid User]		= rt.paidBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
			,[Reconciled User]	= t.createdBy
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN voucherReconcilation t ON t.tranId = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId
		WHERE paidDate BETWEEN @dtFromDate AND @dtToDate 
			AND pBranch = @agentId
			AND tranType = 'D' 
			AND t.[status] = 'Reconciled' 
			AND t.voucherType='pd'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report -Reconciled Paid Domestic' title
		RETURN
	END	

	IF @flag = 'tw-rec-ddl-pi'
	BEGIN
		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Paid Date]		= rt.paidDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.pBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Paid User]		= rt.paidBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
			,[Reconciled User]	= t.createdBy
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN voucherReconcilation t ON t.tranId = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId
		WHERE paidDate BETWEEN @dtFromDate AND @dtToDate
			AND pBranch = @agentId
			AND tranType = 'I'
			AND t.[status] = 'Reconciled'
			AND t.voucherType='pi'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report -Reconciled Paid International' title
		RETURN
	END
	
	-- ## Complain drildown
	IF @flag = 'tw-com-ddl-sd'
	BEGIN
		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Send Date]		= rt.createdDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.sBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Send User]		= rt.createdBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
			,[Complain By]		= t.createdBy
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN voucherReconcilation t ON t.tranId = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId
		WHERE rt.approvedDate BETWEEN @dtFromDate AND @dtToDate
			AND rt.sBranch = @agentId
			AND rt.tranType = 'D'  
			AND t.[status] = 'Complain'
			AND t.voucherType='sd'		

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report- Complain Send Domestic' title
		RETURN
	END	

	IF @flag = 'tw-com-ddl-pd'
	BEGIN
		SELECT  
			 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
			,[Paid Date]		= rt.paidDateLocal 
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Payout Amount]	= rt.pAmt
			,[Agent Name]		= rt.pBranchName
			,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Paid User]		= rt.paidBy
			,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
			,[Complain By]		= t.createdBy
		FROM vwRemitTranArchive rt WITH(NOLOCK)
		INNER JOIN voucherReconcilation t on t.tranId = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId
		WHERE paidDate BETWEEN @dtFromDate AND @dtToDate
			AND pBranch = @agentId
			AND tranType = 'D' 
			AND t.[status] = 'Complain' 
			AND t.voucherType='pd'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report -Complain Paid Domestic' title
		RETURN
	END	

	IF @flag = 'tw-com-ddl-pi'
	BEGIN
		SELECT  
				 [S.N.]				= ROW_NUMBER() OVER(ORDER BY rt.id)
				,[Paid Date]		= rt.paidDateLocal 
				,[Control No]		= dbo.FNADecryptString(rt.controlNo)
				,[Payout Amount]	= rt.pAmt
				,[Agent Name]		= rt.pBranchName
 				,[Sender Name]		= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
				,[Receiver Name]	= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
				,[Paid User]		= rt.paidBy
				,[Contact]			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
				,[Complain By]		= t.createdBy
		FROM vwRemitTranArchive rt WITH(NOLOCK) 
		INNER JOIN voucherReconcilation t ON t.tranId = rt.id
		INNER JOIN vwTranSendersArchive sen WITH(NOLOCK) ON rt.id=sen.tranId
		INNER JOIN vwTranReceiversArchive rec WITH(NOLOCK) ON rt.id=rec.tranId
		WHERE paidDate BETWEEN @dtFromDate and @dtToDate
			AND pBranch = @agentId
			AND tranType = 'I' 
			AND t.[status] = 'Complain'
			AND t.voucherType='pi'

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL
		SELECT  'Agent Name ' head, (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)  value 
		SELECT 'Reconciliation  Report -Complain Paid International' title
		RETURN
	END




GO
