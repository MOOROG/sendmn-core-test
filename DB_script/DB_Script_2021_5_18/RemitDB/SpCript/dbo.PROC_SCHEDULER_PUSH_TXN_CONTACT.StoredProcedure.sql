USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SCHEDULER_PUSH_TXN_CONTACT]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PROC_SCHEDULER_PUSH_TXN_CONTACT](
	 @flag VARCHAR(100) = NULL
	,@id		VARCHAR(100)= NULL
	,@ControlNo	VARCHAR(100)=NULL
)AS
BEGIN
	IF @flag='push-list-contact'
	BEGIN
		SELECT TOP 10
			 sIDwhom		=	'Government'
			,sIDtype		=	TS.idType
			,sCountry		=	dbo.FunCountryCode(TS.country)
			,sName			=	(SELECT FSN.lastName1 FROM dbo.FNASplitName(Ts.firstName) AS FSN)		--LastName
			,sLastName		=	(SELECT FSN.firstName FROM dbo.FNASplitName(Ts.firstName) AS FSN)	---firstName
			,sSurName		=	''		
			,sAddress		=	TS.address
			,sIDnumber		=	TS.idNumber
			,sIDdate		=	FORMAT(TS.issuedDate,'yyyyMMdd')
			,sBirthday		=	FORMAT(TS.dob,'yyyyMMdd')
			,sPhone			=	[dbo].FunContactAPI_MobileFormat(TS.mobile)
			,sZipCode		=	TS.zipCode
			,sRegion		=	TS.address
			,sCity			=	TS.city
			,sBirthPlace	=	TS.nativeCountry
			,sIDexpireDate	=	FORMAT(TS.validDate,'yyyyMMdd')
			,sResident		=	CASE WHEN TS.nativeCountry = 'South Korea' THEN 1 ELSE 0 END ------Required---0 not resident, 1  resident
			,sCountryStay	=	dbo.FunCountryCode(TS.country)
			,sCountryC		=	dbo.FunCountryCode(TS.nativeCountry)

			,bName			=	TR.lastName1
			,bLastName		=	TR.firstName
			,bSurName		=	''
			,bBirthday		=	FORMAT(TR.dob,'yyyyMMdd')
			,bCountry		=	dbo.FunCountryCode(TR.country)
			,bIDdate		=	FORMAT(tr.issuedDate,'yyyyMMdd')
			,bIDwhom		=	'Governmnet'
			,bResident		=	CASE WHEN TR.country = RT.pCountry THEN 1 ELSE 0 END
			,bBirthPlace	=	TR.country
			,bPhone			=	[dbo].FunContactAPI_MobileFormat(TR.mobile)

			,trnService		=	'2' --CASH PAYMENT
			---,trnClAmount='456.66'
			,trnPickupPoint	=	AM.agentCode
			,trnAmount		=	CONVERT(FLOAT,RT.pAmt)
			,trnDate		=	FORMAT(RT.approvedDate,'yyyyMMdd')
			,trnCurrency	=	RT.payoutCurr---USD and RUB
			,trnSendPoint	=	'TAWX'------Given by contact for GME
			,trnRate		=	RT.customerRate------to be checked
			,trnReference	=	dbo.FNADecryptString(RT.controlNo)
			,trnTerminalNumber=	'1'
			,TransactionID	=	''
		FROM dbo.remitTran AS RT(NOLOCK) 
		INNER JOIN tranSenders TS (NOLOCK) ON TS.tranId = RT.id
		INNER JOIN tranReceivers TR (NOLOCK) ON TR.tranId = RT.id
		INNER JOIN agentMaster AM (NOLOCK) ON AM.agentId = RT.pBank
		--INNER JOIN dbo.countryMaster AS CM ON TS.country = CM.countryName
		--LEFT JOIN dbo.countryMaster AS CM1 ON TR.country = CM1.countryName
		WHERE RT.approvedBy IS NOT NULL AND RT.payStatus in('Unpaid')
		AND RT.tranStatus = 'payment' and RT.pAgent = 393228
		AND RT.payoutCurr='usd' and TS.issuedDate is not null and TS.dob IS NOT NULL

		UNION ALL
		SELECT TOP 1
			 sIDwhom		=	'Government'
			,sIDtype		=	TS.idType
			,sCountry		=	dbo.FunCountryCode(TS.country)
			,sName			=	(SELECT FSN.lastName1 FROM dbo.FNASplitName(Ts.firstName) AS FSN)		--LastName
			,sLastName		=	(SELECT FSN.firstName FROM dbo.FNASplitName(Ts.firstName) AS FSN)	---firstName
			,sSurName		=	''		
			,sAddress		=	TS.address
			,sIDnumber		=	TS.idNumber
			,sIDdate		=	FORMAT(TS.issuedDate,'yyyyMMdd')
			,sBirthday		=	FORMAT(TS.dob,'yyyyMMdd')
			,sPhone			=	[dbo].FunContactAPI_MobileFormat(TS.mobile)
			,sZipCode		=	TS.zipCode
			,sRegion		=	TS.address
			,sCity			=	TS.city
			,sBirthPlace	=	TS.nativeCountry
			,sIDexpireDate	=	FORMAT(TS.validDate,'yyyyMMdd')
			,sResident		=	CASE WHEN TS.nativeCountry = 'South Korea' THEN 1 ELSE 0 END ------Required---0 not resident, 1  resident
			,sCountryStay	=	dbo.FunCountryCode(TS.country)
			,sCountryC		=	dbo.FunCountryCode(TS.nativeCountry)

			,bName			=	TR.lastName1
			,bLastName		=	TR.firstName
			,bSurName		=	''
			,bBirthday		=	FORMAT(TR.dob,'yyyyMMdd')
			,bCountry		=	dbo.FunCountryCode(TR.country)
			,bIDdate		=	FORMAT(tr.issuedDate,'yyyyMMdd')
			,bIDwhom		=	'Governmnet'
			,bResident		=	CASE WHEN TR.country = RT.pCountry THEN 1 ELSE 0 END
			,bBirthPlace	=	TR.country
			,bPhone			=	[dbo].FunContactAPI_MobileFormat(TR.mobile)

			,trnService		=	'2' --CASH PAYMENT
			---,trnClAmount='456.66'
			,trnPickupPoint	=	AM.agentCode
			,trnAmount		=	CONVERT(FLOAT,RT.pAmt)
			,trnDate		=	FORMAT(RT.approvedDate,'yyyyMMdd')
			,trnCurrency	=	RT.payoutCurr---USD and RUB
			,trnSendPoint	=	'TAWX'------Given by contact for GME
			,trnRate		=	RT.customerRate------to be checked
			,trnReference	=	dbo.FNADecryptString(RT.controlNo)
			,trnTerminalNumber=	'1'
			,TransactionID	=	RT.ContNo
		FROM dbo.remitTran AS RT(NOLOCK) 
		INNER JOIN tranSenders TS (NOLOCK) ON TS.tranId = RT.id
		INNER JOIN tranReceivers TR (NOLOCK) ON TR.tranId = RT.id
		INNER JOIN agentMaster AM (NOLOCK) ON AM.agentId = RT.pBank
		--INNER JOIN dbo.countryMaster AS CM ON TS.country = CM.countryName
		--LEFT JOIN dbo.countryMaster AS CM1 ON TR.country = CM1.countryName
		WHERE RT.approvedBy IS NOT NULL AND RT.payStatus in('Post')
		and RT.pAgent = 393228
		AND RT.payoutCurr='usd' and TS.issuedDate is not null and TS.dob IS NOT NULL
		AND RT.controlNo = dbo.FNAEncryptString('80978679590')
		and 1=2

		RETURN
	END
	ELSE IF @flag='sync-list-Contact'
	BEGIN
		SELECT RT.id AS TranId, RT.ContNo AS DocId 
		FROM dbo.remitTran AS RT(NOLOCK) 
		WHERE RT.pAgent = 393228
		AND RT.tranStatus='Payment'
		and RT.payStatus='Post'
	END
	ELSE IF @flag='mark-paid-contact'
	BEGIN
		UPDATE remitTran 
			SET payStatus	=	'Paid'
			,tranStatus		=	'Paid' 
			,paidDate		=	getdate()
			,paidDateLocal	=	GETUTCDATE()
			,paidBy			=	'Scheduler'
		WHERE id = @id AND payStatus = 'Post'
		AND tranStatus = 'payment' AND pAgent = 393228
		
		SELECT '0' ErrorCode,'Update success' Msg, NULL Id
	END
	ELSE IF @flag='mark-post-contact'
	BEGIN
		UPDATE remitTran SET 
			 payStatus		=	'Post'
			,postedBy		=	'system'
			,postedDate		=	GETDATE()
			,postedDateLocal=	GETUTCDATE()
			,controlNo2		=	controlNo
			,ContNo			=	@id
		WHERE controlNo		=	Dbo.FNAEncryptString(@ControlNo) 
		AND pAgent = 393228
		
		SELECT '0' ErrorCode,'Update success' Msg, NULL Id
	END
END
GO
