USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_thrasholdTransIntlReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_thrasholdTransIntlReport]
		@flag			CHAR(1),
        @user			VARCHAR(50),
        @fromDate		VARCHAR(50), 
        @toDate			VARCHAR(50),
		@rptNature		VARCHAR(1),
	    @txnAmt			VARCHAR(50) = NULL
AS
SET NOCOUNT ON  
SET @toDate = @toDate +' 23:59:59'

DECLARE @sql VARCHAR(MAX)

IF @rptNature ='t'
BEGIN
	IF @flag = 's'
	BEGIN
		DECLARE @tblTemp TABLE (txnDate VARCHAR(20),senderName VARCHAR(200),idType VARCHAR(50),idNumber VARCHAR(100)) 
		INSERT INTO @tblTemp(txnDate,senderName,idType,idNumber)
		SELECT 
			txnDate = CONVERT(VARCHAR,rt.createdDate,101),
			senderName = rt.senderName,
			idType = ts.idType,
			idNumber = ts.idNumber
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		WHERE rt.createdDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		AND rt.tranStatus <> 'Cancel'
		GROUP BY rt.senderName,CONVERT(VARCHAR,rt.createdDate,101),ts.idType,ts.idNumber
		HAVING SUM(pAmt) >= @txnAmt
		ORDER BY rt.senderName,CONVERT(VARCHAR,rt.createdDate,101)

		SELECT 
			[S.N.] = ROW_NUMBER()OVER(PARTITION BY CONVERT(VARCHAR,rt.createdDate,101),rt.senderName ORDER BY CONVERT(VARCHAR,rt.createdDate,101),rt.senderName),
			[Txn Date] = CONVERT(VARCHAR,rt.createdDate,101),
			[ICN] = '<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId='+ CAST(rt.id AS VARCHAR) +''')">'+dbo.FNADecryptString(rt.controlNo)+'</a>',
			[Sender Information] = '<b>Name: '+UPPER(rt.senderName)+
						'<br>Address: '+UPPER(ISNULL(sen.address,''))+
						'<br>'+UPPER(ISNULL(sen.idType,''))+': '+UPPER(ISNULL(sen.idNumber,''))+'</b>',
			[Receiver Information] = '<b>Name: '+UPPER(rt.receiverName)+
			 CASE WHEN rt.paymentMethod = 'Bank Deposit' THEN '<br>A/C No.: '+ISNULL(rt.accountNo,'') ELSE '<br>Address: '+ISNULL(rec.address,'')+
				'<br>'+CASE WHEN rec.idNumber2 IS NULL THEN ISNULL(rec.idType,'') ELSE ISNULL(rec.idType2,'') END+
				': '+CASE WHEN rec.idNumber2 IS NULL THEN ISNULL(rec.idNumber,'') ELSE ISNULL(rec.idNumber2,'') END END+'</b>',

			[Sender- Agent Name <br> & Place] = ISNULL(rt.sAgentName,'') + '<br><i>'+ ISNULL(rt.sCountry,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = ISNULL(rt.pBranchName,'') + '<br><i>'+ ISNULL(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = rt.sourceOfFund,
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = rt.paymentMethod
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		INNER JOIN @tblTemp t ON t.senderName = rt.senderName 
				AND t.txnDate = CONVERT(VARCHAR,rt.createdDate,101) 
				AND ISNULL(t.idNumber,'') = isnull(sen.idNumber,'')
				AND ISNULL(t.idType,'') = isnull(sen.idType,'')
		INNER JOIN agentMaster sb WITH(NOLOCK) ON rt.sBranch = sb.agentId
		LEFT JOIN agentMaster pb WITH(NOLOCK) ON rt.pBranch = pb.agentId
		WHERE rt.createdDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		AND rt.tranStatus <>'Cancel'
		ORDER BY CONVERT(VARCHAR,rt.createdDate,101),rt.senderName		
	END
	IF @flag = 'r'
	BEGIN
		DECLARE @tblTemp1 TABLE (txnDate VARCHAR(20),receiverName VARCHAR(200),idType VARCHAR(50),idNumber VARCHAR(100))
		INSERT INTO @tblTemp1(txnDate,receiverName,idType,idNumber)

		SELECT CONVERT(VARCHAR,rt.paidDate,101),rt.receiverName,rec.idType2,rec.idNumber2
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE rt.paidDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		GROUP BY rt.receiverName,CONVERT(VARCHAR,rt.paidDate,101),rec.idType2,rec.idNumber2
		HAVING SUM(pAmt) >= @txnAmt
		ORDER BY rt.receiverName,CONVERT(VARCHAR,rt.paidDate,101)

		SELECT 
			[S.N.] = ROW_NUMBER()OVER(PARTITION BY CONVERT(VARCHAR,rt.paidDate,101),rt.receiverName ORDER BY CONVERT(VARCHAR,rt.paidDate,101),rt.receiverName),
			[Paid Date] = CONVERT(VARCHAR,rt.paidDate,101),
			[ICN] = '<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId='+ CAST(rt.id AS VARCHAR) +''')">'+dbo.FNADecryptString(rt.controlNo)+'</a>',

			[Receiver Information] = '<b>Name: '+UPPER(rt.receiverName)+
			 CASE WHEN rt.paymentMethod = 'Bank Deposit' THEN '<br>A/C No.: '+ISNULL(rt.accountNo,'') ELSE '<br>Address: '+UPPER(ISNULL(rec.address,''))+
				'<br>'+CASE WHEN rec.idNumber2 IS NULL THEN UPPER(ISNULL(rec.idType,'')) ELSE UPPER(ISNULL(rec.idType2,'')) END+
				': '+CASE WHEN rec.idNumber2 IS NULL THEN ISNULL(rec.idNumber,'') ELSE ISNULL(rec.idNumber2,'') END END+'</b>',

			[Sender Information] = '<b>Name: '+UPPER(rt.senderName)+'<br>Address: '+ISNULL(sen.address,'')+'<br>'+ISNULL(sen.idType,'')+': '+ISNULL(sen.idNumber,'')+'</b>',
			[Sender- Agent Name <br> & Place] = ISNULL(rt.sAgentName,'') + '<br><i>'+ ISNULL(rt.sCountry,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = ISNULL(rt.pBranchName,'') + '<br><i>'+ ISNULL(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = rt.sourceOfFund,
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = rt.paymentMethod
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		INNER JOIN @tblTemp1 t ON t.receiverName = rt.receiverName 
			AND t.txnDate = CONVERT(VARCHAR,rt.paidDate,101)
			AND t.idNumber = rec.idNumber2 
			AND t.idType = rec.idType2
		INNER JOIN agentMaster sb WITH(NOLOCK) ON rt.sBranch = sb.agentId
		INNER JOIN agentMaster pb WITH(NOLOCK) ON rt.pBranch = pb.agentId
		WHERE rt.paidDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		AND rt.tranStatus <> 'Cancel'
		ORDER BY CONVERT(VARCHAR,rt.paidDate,101),rt.receiverName
	END
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		  
	SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION ALL
	SELECT 'Txn Amount' head, 'Above '+dbo.ShowDecimal(@txnAmt) value UNION ALL
	SELECT 'Report Nature' head, CASE WHEN @rptNature ='s' THEN 'Suspicious Transaciton' WHEN @rptNature ='t' THEN 'Threshold Transaciton' END value UNION ALL
	SELECT 'Report Type' head, CASE WHEN @flag ='s' THEN 'Sender Wise' WHEN @flag ='r' THEN 'Receiver Wise' END 
		
	SELECT 'Threshold Transaction Report (International)' title	
	RETURN;
END

IF @rptNature ='s'
BEGIN
	IF @flag = 's'
	BEGIN
		DECLARE @s_tblTemp TABLE(senderName VARCHAR(200),idType VARCHAR(50),idNumber VARCHAR(100)) 
		INSERT INTO @s_tblTemp(senderName,idType,idNumber)
		SELECT rt.senderName,sen.idType,sen.idNumber
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE rt.createdDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		AND rt.tranStatus <> 'Cancel'
		GROUP BY rt.senderName,sen.idType,sen.idNumber
		HAVING SUM(pAmt) >= @txnAmt
		ORDER BY rt.senderName

		SELECT 
			[S.N.] = ROW_NUMBER()OVER(PARTITION BY rt.senderName ORDER BY rt.senderName),
			[Txn Date] = CONVERT(VARCHAR,rt.createdDate,101),
			[ICN] = '<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId='+ CAST(rt.id AS VARCHAR) +''')">'+dbo.FNADecryptString(rt.controlNo)+'</a>',
			[Sender Information] = '<b>Name: '+UPPER(rt.senderName)+'<br>Address: '+UPPER(ISNULL(sen.address,''))+'<br>'+UPPER(ISNULL(sen.idType,''))+': '+UPPER(ISNULL(sen.idNumber,''))+'</b>',
			[Receiver Information] = '<b>Name: '+UPPER(rt.receiverName)+
				CASE WHEN rt.paymentMethod = 'Bank Deposit' THEN '<br>A/C No.: '+ISNULL(rt.accountNo,'') ELSE '<br>Address: '+ISNULL(rec.address,'')+
				'<br>'+CASE WHEN rec.idNumber2 IS NULL THEN UPPER(ISNULL(rec.idType,'')) ELSE UPPER(ISNULL(rec.idType2,'')) END+
				': '+CASE WHEN rec.idNumber2 IS NULL THEN ISNULL(rec.idNumber,'') ELSE ISNULL(rec.idNumber2,'') END END+'</b>',

			[Sender- Agent Name <br> & Place] = ISNULL(rt.sAgentName,'') + '<br><i>'+ ISNULL(rt.sCountry,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = ISNULL(rt.pBranchName,'') + '<br><i>'+ ISNULL(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = rt.sourceOfFund,
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = rt.paymentMethod
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		INNER JOIN @s_tblTemp t ON t.senderName = rt.senderName 
			AND ISNULL(t.idNumber,'') = ISNULL(sen.idNumber,'') 
			AND ISNULL(t.idType,'')  = ISNULL(sen.idType,'') 
		INNER JOIN agentMaster sb WITH(NOLOCK) ON rt.sBranch = sb.agentId
		LEFT JOIN agentMaster pb WITH(NOLOCK) ON rt.pBranch = pb.agentId
		WHERE rt.createdDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		AND rt.tranStatus <>'Cancel'
		ORDER BY rt.senderName,CONVERT(VARCHAR,rt.createdDate,101)

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		  
		SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION ALL
		SELECT 'Txn Amount' head, 'Above '+dbo.ShowDecimal(@txnAmt) value UNION ALL
		SELECT 'Report Type' head, CASE WHEN @flag ='s' THEN 'Sender Wise' WHEN @flag ='r' THEN 'Receiver Wise' END 
		SELECT 'Suspicious Transaction Report (International)' title	
		RETURN;
	END
	IF @flag = 'r'
	BEGIN
		DECLARE @r_tblTemp TABLE(receiverName VARCHAR(200),idType VARCHAR(50),idNumber VARCHAR(100))
		INSERT INTO @r_tblTemp(receiverName,idType,idNumber)
		SELECT rt.receiverName,rec.idType2,rec.idNumber2
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE rt.paidDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		GROUP BY rt.receiverName,rec.idType2,rec.idNumber2
		HAVING SUM(pAmt) >= @txnAmt
		ORDER BY rt.receiverName

		SELECT 
			[S.N.] = ROW_NUMBER()OVER(PARTITION BY rt.receiverName ORDER BY rt.receiverName),
			[Paid Date] = CONVERT(VARCHAR,rt.paidDate,101),
			[ICN] = '<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId='+ CAST(rt.id AS VARCHAR) +''')">'+dbo.FNADecryptString(rt.controlNo)+'</a>',
			[Receiver Information] = '<b>Name: '+UPPER(rt.receiverName)+
			 CASE WHEN rt.paymentMethod = 'Bank Deposit' THEN '<br>A/C No.: '+ISNULL(rt.accountNo,'') ELSE '<br>Address: '+UPPER(ISNULL(rec.address,''))+
				'<br>'+CASE WHEN rec.idNumber2 IS NULL THEN ISNULL(rec.idType,'') ELSE ISNULL(rec.idType2,'') END+
				': '+CASE WHEN rec.idNumber2 IS NULL THEN ISNULL(rec.idNumber,'') ELSE ISNULL(rec.idNumber2,'') END END+'</b>',
			[Sender Information] = '<b>Name: '+UPPER(rt.senderName)+'<br>Address: '+ISNULL(sen.address,'')+'<br>'+ISNULL(sen.idType,'')+': '+ISNULL(sen.idNumber,'')+'</b>',

			[Sender- Agent Name <br> & Place] = ISNULL(rt.sAgentName,'') + '<br><i>'+ ISNULL(rt.sCountry,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = ISNULL(rt.pBranchName,'') + '<br><i>'+ ISNULL(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = rt.sourceOfFund,
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = rt.paymentMethod
		FROM remitTran rt WITH(NOLOCK) 
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		INNER JOIN @r_tblTemp t ON t.receiverName = rt.receiverName
			AND isnull(t.idType,'') = isnull(rec.idType2,'')
			AND isnull(t.idNumber,'') = isnull(rec.idNumber2,'')
		INNER JOIN agentMaster sb WITH(NOLOCK) ON rt.sBranch = sb.agentId
		INNER JOIN agentMaster pb WITH(NOLOCK) ON rt.pBranch = pb.agentId
		WHERE rt.paidDate BETWEEN @fromDate AND @toDate
		AND rt.tranType ='I'
		AND rt.tranStatus <>'Cancel'
		ORDER BY rt.receiverName,CONVERT(VARCHAR,rt.paidDate,101)
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		  
	SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION ALL
	SELECT 'Txn Amount' head, 'Above '+dbo.ShowDecimal(@txnAmt) value UNION ALL
	SELECT 'Report Nature' head, CASE WHEN @rptNature ='s' THEN 'Suspicious Transaciton' WHEN @rptNature ='t' THEN 'Threshold Transaciton' END value UNION ALL
	SELECT 'Report Type' head, CASE WHEN @flag ='s' THEN 'Sender Wise' WHEN @flag ='r' THEN 'Receiver Wise' END 
	SELECT 'Suspicious Transaction Report (International)' title	
	RETURN;
END


GO
