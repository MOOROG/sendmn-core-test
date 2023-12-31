USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwTranSendersAll]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwTranSendersAll]
AS
    SELECT 
		 [id]
		,[tranId]
		,[holdTranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue],[issuedDate],[validDate]
		,[extCustomerId],[cwPwd],[ttName]
		,[isFirstTran],[customerRiskPoint],[countryRiskPoint]
		,[gender],[salary],[companyName],[address2]
		,[dcInfo],[ipAddress],[notifySms],[txnTestQuestion],[txnTestAnswer] 
    FROM tranSenders with (nolock)
    UNION ALL
    SELECT 
		 [id]
		,[tranId]
		,[tranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue],[issuedDate],[validDate]
		,[extCustomerId],[cwPwd],[ttName]
		,[isFirstTran],[customerRiskPoint],[countryRiskPoint]
		,[gender],[salary],[companyName],[address2]
		,[dcInfo],[ipAddress],[notifySms],[txnTestQuestion],[txnTestAnswer]
	FROM tranSendersTemp WITH(NOLOCK)
	UNION ALL
    SELECT 
		 [id]
		,[tranId]
		,[tranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue],[issuedDate],[validDate]
		,[extCustomerId],[cwPwd],[ttName]
		,[isFirstTran],[customerRiskPoint],[countryRiskPoint]
		,[gender],[salary],[companyName],[address2]
		,[dcInfo],[ipAddress],[notifySms],[txnTestQuestion],[txnTestAnswer]
	FROM canceltranSendersHistory WITH(NOLOCK)


GO
