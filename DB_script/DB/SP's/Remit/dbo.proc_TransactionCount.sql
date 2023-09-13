
ALTER proc proc_TransactionCount 
(@User varchar(50) = null)
 as
 DECLARE @date VARCHAR(10) =CONVERT(VARCHAR, GETDATE() ,111);

 declare @intPaid int , @iSend int , @iCancel int 
	
	IF (SELECT dbo.FNAHasRight(@User,'90100020') )='N'
		RETURN

	SELECT @intPaid = COUNT(tranStatus) 
	FROM dbo.remitTran WITH(NOLOCK)
	WHERE paidDate BETWEEN @date AND @date + ' 23:59:59'

	SELECT @iSend = COUNT('A') 
	FROM dbo.remitTran  WITH(NOLOCK)
	WHERE payStatus<>'Paid' AND approvedDate BETWEEN @date AND @date + ' 23:59:59'

	SELECT @iCancel = COUNT('A') 
	FROM dbo.remitTran  WITH(NOLOCK)
	WHERE cancelApprovedDate BETWEEN @date AND @date + ' 23:59:59'

 SELECT @iCancel iCancel,@iSend iSend, @intPaid intPaidCount

 --SELECT [TxnNo] = count(1) ,tranStatus
 --FROM remitTran(nolock) 
 --where createdDate BETWEEN @date AND @date + ' 23:59:59'
 --group by tranStatus
 --UNION ALL

--SELECT [TxnNo] = count(1),'Pending GIBL Reprocessing' tranStatus
--FROM remitTran trn WITH(NOLOCK)
--WHERE trn.approvedBy IS NOT NULL AND trn.payStatus = 'Unpaid'
--AND tranStatus = 'payment' AND pCountry = 'Nepal'
--AND trn.pAgent = 1056

	SELECT [TxnNo] = COUNT(1),'Unpaid Transactions' tranStatus
	FROM remitTran rt WITH(NOLOCK)  
    WHERE rt.approvedBy IS NOT NULL 
	and payStatus <> 'Paid'  
	AND PAIDDATE IS NOT NULL
	AND tranType IN ('I','O')  
	--and rt.createddate >= '2019-01-01'


