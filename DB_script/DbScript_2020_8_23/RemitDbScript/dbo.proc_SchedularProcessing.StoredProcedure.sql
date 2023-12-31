USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_SchedularProcessing]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_SchedularProcessing]
@flag			varchar(30),
@id				bigint = null,
@TxnStatus		varchar(50) = null,
@errorCode		VARCHAR(5)	= NULL,
@errorMsg		VARCHAR(250) = NULL
as
set nocount on;
if @flag = 'reprocess-GIBL'
begin
	SELECT TOP 30
		trn.id,controlNo = dbo.FNADecryptString(trn.controlNo)
	FROM remitTran trn WITH(NOLOCK)
	WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Unpaid'
	AND tranStatus = 'payment' AND pCountry='Nepal'
	--AND 1 = 2
	AND trn.pAgent = 1056 
	ORDER BY 1 
END
ELSE if @flag = 'unApprove-mTrade'
begin
	SELECT  DISTINCT TOP 30
		trn.id,[uploadLogId] = ContNo,controlNo = dbo.FNADecryptString(trn.controlNo)
	FROM remitTran trn WITH(NOLOCK)
	WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Unpaid'
	AND tranStatus = 'payment' AND trn.pAgent = 2129
	ORDER BY 1 desc
END
ELSE if @flag = 'postList-mTrade'
begin
	SELECT TOP 30
		trn.id,[uploadLogId] = ContNo,controlNo = dbo.FNADecryptString(trn.controlNo)
	FROM remitTran trn WITH(NOLOCK)
	WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Post'
	AND tranStatus = 'payment' AND trn.pAgent = 2129
	AND Approveddate < dateadd(day,-1,getdate())
	order by newid() 
END
else if @flag = 'mark-post-mTrade'
begin
	update remitTran set payStatus = 'Post', postedBy = 'SCHEDULAR', postedDate = getdate()
	where id = @id AND pAgent = 2129 
end
else if @flag = 'mark-Paid-mTrade'
begin
	
	update remitTran set payStatus = 'Paid',transtatus='Paid', paidBy='SCHEDULAR', paidDate = getdate()
	where id = @id AND pAgent = 2129 AND tranStatus <> 'Cancel'
end
else if @flag = 'reprocess-DONGA'
begin
	
		SELECT TOP 30
			errorCode = 0
			, msg = 'Success'
			, id = RT.id 
			, SumTransaction = '1'
			, SumUSD = CASE WHEN payoutCurr = 'USD' THEN RT.pAmt ELSE NULL END
			, SumAUD = NULL
			, SumCAD = NULL
			, SumEUR = NULL
			, SumVND = CASE WHEN payoutCurr = 'VND' THEN RT.pAmt ELSE NULL END
			, SumGBP = NULL
			, SumJPY = NULL

			, TransactionID = dbo.FNADecryptString(RT.controlNo)
			, Sender = RT.senderName
			, Receiver = RT.receiverName
			, Address = CASE 
							WHEN RT.paymentMethod = 'BANK DEPOSIT' THEN TR.address
							WHEN RT.paymentMethod = 'CASH PAYMENT' AND RT.pBank <> '2091' THEN RT.pBankName + ', ' + TR.address
							ELSE TR.address
						END
			, CityCode = TSL.partnerLocationId
			, DistrictCode = TSUB.partnerSubLocationId
			, Amount = RT.pAmt
			, SCurrency = RT.payoutCurr
			, RCurrency = RT.payoutCurr
			, PaymentMode = CASE 
								WHEN RT.paymentMethod =  'BANK DEPOSIT' THEN 'TA' 
								WHEN RT.paymentMethod = 'HOME DELIVERY' THEN 'HD' 
								WHEN RT.paymentMethod = 'CASH PAYMENT' AND RT.pBank <> '2091' THEN 'TA'
								WHEN RT.paymentMethod = 'CASH PAYMENT' AND RT.pBank = '2091' THEN 'CP'
							END
			, Phone = TR.mobile
			, BankAccount = CASE 
								WHEN RT.paymentMethod = 'BANK DEPOSIT' THEN RT.accountNo 
								ELSE NULL 
							END
			, BankCode = AM.BANKCODE
			, BranchState = ''
			, Note = ''
			, controlNo = RT.controlNo
		----INTO #TEMPTXNS
		FROM remitTran RT (NOLOCK) 
		INNER JOIN tranSenders TS (NOLOCK) ON TS.tranId = RT.id
		INNER JOIN tranReceivers TR (NOLOCK) ON TR.tranId = RT.id
		INNER JOIN tblSubLocation TSUB (NOLOCK) ON TSUB.rowId = RT.pDistrict
		INNER JOIN tblServicewiseLocation TSL (NOLOCK) ON TSL.rowId = RT.pState
		LEFT JOIN agentMaster AM (NOLOCK) ON AM.agentId = RT.pBank
		WHERE RT.approvedBy IS NOT NULL AND RT.payStatus ='Unpaid'
		AND RT.tranStatus = 'payment'
		AND RT.pCountry = 'VIETNAM' AND RT.pAgent = 2090
end
else if @flag = 'push-error-DONGA'
begin
	update remitTran set payStatus = 'Post', postedBy = 'SCHEDULAR', postedDate = getdate() where id = @id AND pAgent = 2090
end
ELSE IF @flag = 'sync-list-DONGA'
BEGIN
	SELECT TOP 30 controlNo = dbo.FNADecryptString(controlNo)
			,id
	FROM remitTran (NOLOCK) 
	WHERE  payStatus = 'Post' AND tranStatus = 'Payment' 
	AND pCountry = 'VIETNAM' AND pAgent = 2090
	AND Approveddate < dateadd(hour,-2,getdate())
	order by newid() 
END
else if @flag = 'mark-paid-DONGA'
begin
	update remitTran set payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'SCHEDULAR', paidDate = getdate()
	where id = @id AND pAgent = 2090 AND tranStatus <> 'Cancel'
end
else if @flag = 'Exrate-Display'
begin
	select cCurrency,cCountry,BuyRate = (cRate+cMargin+cHoMargin),pCurrency, m.countryName
		,SaleRate = pRate,customerRate,c.currencyDesc,Unit = 1 
	from exrateTreasury t(nolock)
	inner join currencyMaster c(nolock) on c.CurrencyCode = t.pCurrency
	INNER JOIN countryMaster m(nolock) on m.countryId = t.pCountry
	ORDER BY pCountry,pCurrency
END
ELSE IF @flag = 'sync-list-WING'
BEGIN
	SELECT top 30 controlNo = dbo.FNADecryptString(controlNo2)
			,id
			,paymentMethod
			,CREATEDDATE
	FROM remitTran (NOLOCK) 
	WHERE  payStatus = 'Post' AND tranStatus = 'Payment' 
	AND pCountry = 'Cambodia' AND pAgent = 221226
	AND Approveddate < dateadd(hour,-2,getdate())
	--and 1=2
	--AND approvedDate BETWEEN '2018-05-01' AND '2018-05-03'
	--and id IN (100100787, 100099609)
	order by newid() 
END
else if @flag = 'mark-paid-WING'
begin
	update remitTran set payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'SCHEDULAR', paidDate = getdate()
	where id = @id AND pAgent = 221226 AND tranStatus <> 'Cancel'
end
ELSE IF @flag = 'send-email-list'
BEGIN
	SELECT top 100 customerId, createdBy, email, 
			dbo.decryptDb(customerPassword) [password], 
			walletAccountNo, fullName ,approveddate
	INTO #temp 
	FROM customerMaster (NOLOCK) 
	WHERE approvedDate BETWEEN CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) and getdate()
	AND OBPID is not null
	DELETE T
	FROM #temp T
	INNER JOIN emailNotes EN(NOLOCK) ON EN.sendTo = T.email
	AND EN.sendStatus = 'Y'
	
	--DELETE FROM #temp
	
	--INSERT INTO #temp (createdBy, email, 
	--		[password], 
	--		walletAccountNo, fullName)
	--SELECT 'online', 'pralhad@swifttech.com.np', '123', '98756456789', 'Arjun Dhami'

	SELECT * FROM #temp order by approveddate
END
ELSE IF @flag = 'push-list-commercial'
BEGIN
	SELECT TOP 30
			errorCode = 0
			, msg = 'Success'
			, id = RT.id 
			, TRANSACTIONREF = RT.id
			, CUSPIN = dbo.FNADecryptString(RT.controlNo)
			, SENDERACCOUNTNO = CASE WHEN RT.payoutCurr = 'USD' THEN '1951784701' ELSE '1207080074' END
			, CURRENCY = RT.payoutCurr
			, REMITTENCETYPE = CASE 
									WHEN RT.paymentMethod = 'CASH PAYMENT' THEN '00' 
									WHEN RT.paymentMethod =  'BANK DEPOSIT' AND pBank = '221275' THEN '01'
									WHEN RT.paymentMethod =  'BANK DEPOSIT' AND pBank <> '221275' THEN '02'
								END
			, SENDERNAME = LEFT(RT.senderName,50)
			, BENEFICIARYNAME = LEFT(RT.receiverName,50)
			, BENEFICIARYADD = LEFT(TR.address,100)
			, BENEFICIARYPHONE = CASE WHEN TR.mobile LIKE '+94%' THEN REPLACE(TR.mobile, '+94', '0')
									WHEN TR.mobile LIKE '0%' THEN TR.mobile
									WHEN TR.mobile LIKE '94%' THEN STUFF(TR.mobile, 1, 2, '0') 
									ELSE TR.mobile
								END
			, BENEFICIARYID = ''
			, BENEFICIARYIDACCTNO = ''
			, BANKACCTNO = RT.accountNo
			, BANKNAME = AM.agentCode
			, BANKADDRESS = b.agentCode
			, SENDERPHONE = TS.mobile
			, SENDRESINFO = ''
			, SMSALERT = '3'
			, AMOUNT = RT.pAmt
			, CHARGE = '0'
		FROM remitTran RT (NOLOCK) 
		INNER JOIN tranSenders TS (NOLOCK) ON TS.tranId = RT.id
		INNER JOIN tranReceivers TR (NOLOCK) ON TR.tranId = RT.id
		LEFT JOIN agentMaster AM (NOLOCK) ON AM.agentId = RT.pBank
		LEFT JOIN agentMaster b (NOLOCK) ON b.agentId = RT.pBankBranch
		WHERE RT.approvedBy IS NOT NULL 
		AND RT.payStatus ='Unpaid'
		AND RT.tranStatus = 'payment'
		AND RT.pCountry = 'SRI LANKA' 
		AND RT.pAgent = 221271 
		ORDER BY RT.ID DESC
		--AND RT.ID = 100284172
END
ELSE IF @flag = 'push-error-commercial'
BEGIN
	update remitTran set payStatus = 'Post', postedBy = 'SCHEDULAR', postedDate = getdate() 
	where id = @id AND pAgent = 221271
END
ELSE IF @flag = 'sync-list-commercial'
BEGIN
	SELECT TOP 30 controlNo = dbo.FNADecryptString(controlNo2)
			,id
			,paymentMethod
	FROM remitTran (NOLOCK) 
	WHERE  payStatus = 'Post' AND tranStatus = 'Payment' 
	AND pCountry = 'Sri Lanka' AND pAgent = 221271
	AND Approveddate < dateadd(hour,-2,getdate())
	order by newid() 
END
ELSE IF @flag = 'mark-paid-commercial'
BEGIN
	update remitTran set payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'SCHEDULAR', paidDate = getdate()
	where id = @id AND pAgent = 221271 AND tranStatus <> 'Cancel'
END
ELSE IF @flag = 'expiry-notify'
BEGIN
	SELECT MOBILE,email,firstName,idExpiryDate = CONVERT(varchar,idExpiryDate,106) INTO #TEMP_Expiry
	FROM customerMaster (NOLOCK) WHERE DATEDIFF(DAY, GETDATE(), idExpiryDate) IN (30, 1) AND
	APPROVEDDATE IS NOT NULL
	--and email='pralhads@gmeremit.com'

	UPDATE #TEMP_Expiry SET MOBILE = REPLACE(MOBILE,'+82','0')
	UPDATE #TEMP_Expiry SET MOBILE = REPLACE(MOBILE,'+','')
	UPDATE #TEMP_Expiry SET MOBILE = REPLACE(MOBILE,'-','')
	UPDATE #TEMP_Expiry SET MOBILE = CASE WHEN LEFT(MOBILE,2)='82' THEN STUFF(MOBILE, 1, 2, '0') ELSE MOBILE END
	UPDATE #TEMP_Expiry SET MOBILE = CASE WHEN LEFT(MOBILE,2)='00' THEN STUFF(MOBILE,1,2,'0') ELSE MOBILE END

	INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
	SELECT 'globalmoney',0,'VISAEXP','Your ID is going to expire soon,Please update on time to get uninterrupted GME service.'
	,FORMAT(GETDATE(),'yyyyMMddHHmmss'),FORMAT(GETDATE(),'yyyyMMddHHmmss'),'1588-6864','GME^'+MOBILE
	FROM #TEMP_Expiry
	
	SELECT * FROM #TEMP_Expiry
	
END
GO
