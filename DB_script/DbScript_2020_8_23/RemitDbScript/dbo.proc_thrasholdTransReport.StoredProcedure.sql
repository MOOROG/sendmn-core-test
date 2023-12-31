USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_thrasholdTransReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_thrasholdTransReport]
		@flag			CHAR(1),
        @user			VARCHAR(50),
        @fromDate		VARCHAR(50), 
        @toDate			VARCHAR(50),
		@rptNature		VARCHAR(1),
	    @txnAmt			VARCHAR(50) = NULL
AS
SET NOCOUNT ON  
SET @toDate = @toDate +' 23:59:59'

DECLARE @sql varchar(MAX)

IF @rptNature ='t'
BEGIN
	IF @flag = 'o' 
	BEGIN
		SELECT 
			 [Name & Address of Customer] = isnull(s.firstName,'') +  isnull(s.middleName,'') + isnull(s.lastName1,'') + '('+ isnull(s.address ,'')+')'
			,[Branch/Agent] = r.sBranchName
			,[Date of Transaction] = r.createdDate
			,[Nature Of Transaction]=CASE WHEN r.paymentMethod = 'Bank Deposit' THEN 'Cash Deposit' ELSE r.paymentMethod END
			,[IME Control Number]=dbo.FNADecryptString(r.controlNo) 
			,[Amount Involved] = r.pAmt
			,[Source of Fund] = r.sourceOfFund
		from remitTran r with (nolock) 
		inner join tranSenders s with (nolock) on r.id=s.tranId 
		where r.createdDate between @fromDate AND @toDate 
		AND r.tranType ='D' AND r.pAmt>= 1000000
		AND r.tranStatus <>'Cancel'
	END
	IF @flag = 's'
	BEGIN
		declare @tblTemp table (txnDate varchar(20),senderName varchar(200)) 
		insert into @tblTemp(txnDate,senderName)
		select convert(varchar,rt.approvedDate,101),rt.senderName
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		where rt.approvedDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		group by rt.senderName,convert(varchar,rt.approvedDate,101)
		having sum(pAmt) >= @txnAmt
		order by rt.senderName,convert(varchar,rt.approvedDate,101)

		select 
			[S.N.] = ROW_NUMBER()over(partition by convert(varchar,rt.approvedDate,101),rt.senderName order by convert(varchar,rt.approvedDate,101),rt.senderName),
			[Txn Date] = convert(varchar,rt.approvedDate,101),
			[Sender Information_Name] = '<b>'+upper(rt.senderName)+'</b>',
			[Sender Information_Address] = sen.address,
			[Sender Information_Id Number] = sen.idType+'<br><i>'+ sen.idNumber+ '</i>',
			[Receiver Information_Name] = '<b>'+upper(isnull(rt.receiverName,''))+ '</b>',
			[Receiver Information_Address] = rec.address,
			[Receiver Information_Id Number] = CASE WHEN rec.idNumber2 IS NULL THEN '' ELSE rec.idType2+'<br><i>'+ rec.idNumber2+ '</i>' END,
			[Sender- Agent Name <br> & Place] = isnull(rt.sBranchName,'') + '<br><i>'+ isnull(sb.agentAddress,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = isnull(rt.pBranchName,'') + '<br><i>'+ isnull(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = '',
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = ''--rt.pMessage
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		inner join @tblTemp t on t.senderName = rt.senderName and t.txnDate = convert(varchar,rt.approvedDate,101)
		inner join agentMaster sb with(nolock) on rt.sBranch = sb.agentId
		left join agentMaster pb with(nolock) on rt.pBranch = pb.agentId
		where rt.approvedDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		AND rt.tranStatus <>'Cancel'
		order by convert(varchar,rt.approvedDate,101),rt.senderName		
	END
	IF @flag = 'r'
	BEGIN

		declare @tblTemp1 table (txnDate varchar(20),receiverName varchar(200)) 
		insert into @tblTemp1(txnDate,receiverName)

		select convert(varchar,rt.paidDate,101),rt.receiverName
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		where rt.paidDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		group by rt.receiverName,convert(varchar,rt.paidDate,101)
		having sum(pAmt) >= @txnAmt
		order by rt.receiverName,convert(varchar,rt.paidDate,101)


		select 
			[S.N.] = ROW_NUMBER()over(partition by convert(varchar,rt.paidDate,101),rt.receiverName order by convert(varchar,rt.paidDate,101),rt.receiverName),
			[Paid Date] = convert(varchar,rt.paidDate,101),
			[Sender Information_Name] = '<b>'+upper(rt.senderName)+'</b>',
			[Sender Information_Address] = sen.address,
			[Sender Information_Id Number] =  sen.idType+'<br><i>'+ sen.idNumber+ '</i>',
			[Receiver Information_Name] = '<b>'+upper(isnull(rt.receiverName,''))+ '</b>',
			[Receiver Information_Address] = rec.address,
			[Receiver Information_Id Number] = CASE WHEN rec.idNumber2 IS NULL THEN '' ELSE rec.idType2+'<br><i>'+ rec.idNumber2+ '</i>' END,
			[Sender- Agent Name <br> & Place] = isnull(rt.sBranchName,'') + '<br><i>'+ isnull(sb.agentAddress,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = isnull(rt.pBranchName,'') + '<br><i>'+ isnull(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = '',
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = ''--rt.pMessage
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		inner join @tblTemp1 t on t.receiverName = rt.receiverName and t.txnDate = convert(varchar,rt.paidDate,101)
		inner join agentMaster sb with(nolock) on rt.sBranch = sb.agentId
		inner join agentMaster pb with(nolock) on rt.pBranch = pb.agentId
		where rt.paidDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		AND rt.tranStatus <>'Cancel'
		order by convert(varchar,rt.paidDate,101),rt.receiverName
	END
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		  
	SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION ALL
	SELECT 'Txn Amount' head, 'Above '+dbo.ShowDecimal(@txnAmt) value UNION ALL
	SELECT 'Report Nature' head, case when @rptNature ='s' then 'Suspicious Transaciton' when @rptNature ='t' then 'Threshold Transaciton' end value UNION ALL
	SELECT 'Report Type' head, case when @flag ='s' then 'Sender Wise' when @flag ='r' then 'Receiver Wise' end 
		
	SELECT 'Schedule - 2<br>Threshold Transaction Report (TTR) form <br> for Money Remitter/Money Transferor<br>Name of Reporting Institution: GLOBAL IME BANK Limited' title	
	RETURN;
END

IF @rptNature ='s'
BEGIN
	IF @flag = 's'
	BEGIN
		declare @s_tblTemp table(senderName varchar(200)) 
		insert into @s_tblTemp(senderName)
		select rt.senderName
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		where rt.approvedDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		group by rt.senderName
		having sum(pAmt) >= @txnAmt
		order by rt.senderName

		select 
			[S.N.] = ROW_NUMBER()over(partition by rt.senderName,convert(varchar,rt.approvedDate,101) order by rt.senderName,convert(varchar,rt.approvedDate,101)),
			[Txn Date] = convert(varchar,rt.approvedDate,101),
			[Sender Information_Name] = '<b>'+upper(rt.senderName)+'</b>',
			[Sender Information_Address] = sen.address,
			[Sender Information_Id Number] =  sen.idType+'<br><i>'+ sen.idNumber+ '</i>',
			[Receiver Information_Name] = '<b>'+upper(isnull(rt.receiverName,''))+ '</b>',
			[Receiver Information_Address] = rec.address,
			[Receiver Information_Id Number] = CASE WHEN rec.idNumber2 IS NULL THEN '' ELSE rec.idType2+'<br><i>'+ rec.idNumber2+ '</i>' END,
			[Sender- Agent Name <br> & Place] = isnull(rt.sBranchName,'') + '<br><i>'+ isnull(sb.agentAddress,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = isnull(rt.pBranchName,'') + '<br><i>'+ isnull(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = '',
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = ''--rt.pMessage
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		inner join @s_tblTemp t on t.senderName = rt.senderName 
		inner join agentMaster sb with(nolock) on rt.sBranch = sb.agentId
		left join agentMaster pb with(nolock) on rt.pBranch = pb.agentId
		where rt.approvedDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		AND rt.tranStatus <>'Cancel'
		order by rt.senderName,convert(varchar,rt.approvedDate,101)

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		  
		SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION ALL
		SELECT 'Txn Amount' head, 'Above '+dbo.ShowDecimal(@txnAmt) value UNION ALL
		SELECT 'Report Type' head, case when @flag ='s' then 'Sender Wise' when @flag ='r' then 'Receiver Wise' end 
		SELECT 'Schedule - 2<br>Threshold Transaction Report (TTR) form <br> for Money Remitter/Money Transferor<br>Name of Reporting Institution: GLOBAL IME BANK Limited' title	
		RETURN;
	END
	IF @flag = 'r'
	BEGIN
		declare @r_tblTemp table(receiverName varchar(200))
		insert into @r_tblTemp(receiverName)
		select rt.receiverName
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		where rt.paidDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		group by rt.receiverName
		having sum(pAmt) >= @txnAmt
		order by rt.receiverName

		select 
			[S.N.] = ROW_NUMBER()over(partition by rt.receiverName,convert(varchar,rt.paidDate,101) order by rt.receiverName,convert(varchar,rt.paidDate,101)),
			[Paid Date] = convert(varchar,rt.paidDate,101),
			[Sender Information_Name] = '<b>'+upper(rt.senderName)+'</b>',
			[Sender Information_Address] = sen.address,
			[Sender Information_Id Number] =  sen.idType+'<br><i>'+ sen.idNumber+ '</i>',
			[Receiver Information_Name] = '<b>'+upper(isnull(rt.receiverName,''))+ '</b>',
			[Receiver Information_Address] = rec.address,
			[Receiver Information_Id Number] = CASE WHEN rec.idNumber2 IS NULL THEN '' ELSE rec.idType2+'<br><i>'+ rec.idNumber2+ '</i>' END,
			[Sender- Agent Name <br> & Place] = isnull(rt.sBranchName,'') + '<br><i>'+ isnull(sb.agentAddress,'')+'</i>', 
			[Receiver- Agent Name <br> & Place] = isnull(rt.pBranchName,'') + '<br><i>'+ isnull(pb.agentAddress,'')+'</i>',
			[Relationship <br>With Sender] = rt.relWithSender,
			[Source Of Fund] = '',
			[Amount Involved<br> NPR] = rt.pAmt,		
			[Remarks] = ''--rt.pMessage
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		inner join @r_tblTemp t on t.receiverName = rt.receiverName
		inner join agentMaster sb with(nolock) on rt.sBranch = sb.agentId
		inner join agentMaster pb with(nolock) on rt.pBranch = pb.agentId
		where rt.paidDate between @fromDate and @toDate
		and rt.tranType ='D'
		and rt.receiverName <> 'CM Trading Enterprises Pvt. Ltd'
		AND rt.tranStatus <>'Cancel'
		order by rt.receiverName,convert(varchar,rt.paidDate,101)
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL		  
	SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION ALL
	SELECT 'Txn Amount' head, 'Above '+dbo.ShowDecimal(@txnAmt) value UNION ALL
	SELECT 'Report Nature' head, case when @rptNature ='s' then 'Suspicious Transaciton' when @rptNature ='t' then 'Threshold Transaciton' end value UNION ALL
	SELECT 'Report Type' head, case when @flag ='s' then 'Sender Wise' when @flag ='r' then 'Receiver Wise' end 
	SELECT 'Suspicious Transaction Report' title	
	RETURN;
END


GO
