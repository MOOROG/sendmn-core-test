USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ScheduleGMENepal]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_ScheduleGMENepal](
	 @Flag VARCHAR(20)
	,@TranId BIGINT = NULL
)AS
BEGIN
	IF @Flag='list'
	BEGIN
		SELECT TOP 50
			 r.id AS TranId
			,Dbo.FNADecryptString(r.controlNo) AS ControlNo
			,r.id AS ExConfirmId
			,r.senderName AS CustomerName
			,ts.address AS CustomerAddress
			,ts.mobile AS  CustomerContact
			,ts.city AS CustomerCity
			,ts.country AS CustomerCountry
			,ts.idType AS CustomerIdType
			,ts.idNumber AS CustomerIdNumber
			,r.receiverName AS BeneName
			,tr.address AS BeneAddress
			,tr.mobile AS BeneContact
			,tr.city AS BeneCity
			,tr.country AS BeneCountry
			,ts.occupation AS Profession
			,r.sourceOfFund AS IncomeSource
			,r.relWithSender AS Relationship
			,r.purposeOfRemit AS PurposeOfRemittance
			,r.tAmt AS SendingAmount
			,r.pAmt AS ReceivingAmount
			,'C' AS PaymentMethod
			,CONVERT(VARCHAR,r.createdDate,110) AS TransactionDate
			,'C' AS CalculateBy
			,NULL AS FreeCharge
			,sCurrCostRate
			,pCurrCostRate
		FROM dbo.remitTran r (NOLOCK)
		INNER JOIN dbo.tranSenders ts (NOLOCK) ON r.id=ts.tranId
		INNER JOIN dbo.tranReceivers tr (NOLOCK) ON r.id=tr.tranId
		WHERE r.tranStatus='Payment' and r.payStatus='Unpaid' AND r.paymentMethod='Cash Payment' AND r.pAgent = 1036
		return
	END
	
	ELSE IF @flag='updateToPost'
	BEGIN
		UPDATE dbo.remitTran SET payStatus = 'Post', postedBy = 'SCHEDULAR', postedDate = GETDATE() WHERE id=@TranId and pAgent = 1036
		IF @@ROWCOUNT=1
		BEGIN
			SELECT '0' ErrorCode, 'Transaction Status updated.' Msg, NULL Id
			RETURN 0
		END 
	END

	ELSE IF @flag='updateToPaid'
	BEGIN
		UPDATE dbo.remitTran SET tranStatus='Paid', payStatus='Paid', paidBy='system', paidDate=GETDATE(),paidDateLocal=GETUTCDATE() 
		WHERE id=@TranId  and pAgent = 1036
		IF @@ROWCOUNT=1
		BEGIN
			SELECT '0' ErrorCode, 'Transaction Status updated.' Msg, NULL Id
			RETURN 0
		END 
	END

	ELSE IF @flag='list-posted'
	BEGIN
		SELECT 
			 dbo.FNADecryptString(controlNo)  AS ControlNo
			,id AS TranId 
		FROM dbo.remitTran (NOLOCK) WHERE payStatus='Post' AND paymentMethod='Cash Payment'
		and pAgent = 1036
		return
	END
END

GO
