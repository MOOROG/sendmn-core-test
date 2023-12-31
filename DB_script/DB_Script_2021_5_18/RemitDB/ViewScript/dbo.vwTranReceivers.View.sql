USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwTranReceivers]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwTranReceivers]
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
		,[idType],[idNumber],[idPlaceOfIssue]
		,[issuedDate],[validDate]
		,[idType2],[idNumber2],[idPlaceOfIssue2],[issuedDate2],[validDate2]
		,[relationType],[relativeName]
		,[gender],[address2]
		,[dcInfo],[ipAddress] 
		,bankName,branchName,accountNo,chequeNo
    FROM tranReceivers WITH(NOLOCK)

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
		,[idType],[idNumber],[idPlaceOfIssue]
		,[issuedDate],[validDate]
		,[idType2],[idNumber2],[idPlaceOfIssue2],[issuedDate2],[validDate2]
		,[relationType],[relativeName]
		,[gender],[address2]
		,[dcInfo],[ipAddress],bankName,branchName,accountNo,chequeNo
	FROM tranReceiversTemp WITH(NOLOCK)
	
	
	


GO
