USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_mgReceipt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC proc_mgReceipt @flag = 'receipt' , @user = 'admin' , @controlNo = 'MG71372868'

CREATE procEDURE [dbo].[proc_mgReceipt] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@tranId			INT				= NULL

) 
AS
SET NOCOUNT ON;

IF @flag = 'receipt' 
BEGIN
	SELECT 
		 referenceNumber		 = dbo.FNADecryptString(controlNo) 
		,receiverName		     = tr.firstName + ISNULL( ' ' + tr.middleName, '') + ISNULL( ' ' + tr.lastName1, '') + ISNULL( ' ' + tr.lastName2, '')
		,recDOB					 = convert(varchar,tr.dob,101) 		
		,recAddress				 = tr.[address]
		,recContactNumber        = isnull(tr.homePhone,tr.mobile)
		,receivingCountry        = rt.pCountry 
		,senderName				 = ts.firstName + ISNULL( ' ' + ts.middleName, '') + ISNULL( ' ' + ts.lastName1, '') + ISNULL( ' ' + ts.lastName2, '')
		,sendAmount              = rt.pAmt
		,expectedReceiveAmt		 = rt.pAmt
		,sendingCountry          = rt.sCountry
		,authorisationCode       = ts.txnTestAnswer 
		,officeName				 = ts.companyName
		,aDate					 = convert(varchar,rt.createdDatelocal,101) 	
		,mgOperationIdNo		 = rt.controlNo2 
		,amountPaid				 = rt.pAmt
		,currency                = rt.payoutCurr
		,totalRoundAmount		 = rt.pAmt
		,receiverIdType          = tr.idType2
		,receiverIdNumber		 = tr.idNumber2
		,receiverCountryOfBirth  = tr.nativeCountry
		,issuingStateCountry	 = tr.idPlaceOfIssue
		,receiverOccupation		 = tr.occupation
		,recSignatureDate		 = convert(varchar,rt.paidDate,101) 
	    FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranReceivers tr  WITH(NOLOCK) ON rt.id = tr.tranId
		INNER JOIN  tranSenders  ts  WITH(NOLOCK) ON rt.id = ts.tranId
		WHERE controlNo = dbo.FNAEncryptString(@controlNo)
END




GO
