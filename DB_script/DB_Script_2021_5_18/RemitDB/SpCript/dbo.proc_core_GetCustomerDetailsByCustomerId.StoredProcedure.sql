USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_core_GetCustomerDetailsByCustomerId]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_core_GetCustomerDetailsByCustomerId]
(
 @flag VARCHAR(5),
 @customerId INT,
 @user VARCHAR(100)
)
AS
SET NOCOUNT ON;
IF @flag='s'
Begin

SELECT email,
    firstName,
    idNumber,
    CONVERT(VARCHAR(10),cm.idExpiryDate,102) AS idExpiryDate,
    mobile,
    sdv.detailTitle AS gender,
    cm.[address],
    bl.BankName,
    cm.bankAccountNo,
    CONVERT(VARCHAR(10),cm.createdDate,101) AS createdDate
    
FROM dbo.customerMaster cm WITH(NOLOCK)
LEFT JOIN dbo.staticDataValue sdv WITH(NOLOCK) ON cm.gender=sdv.valueId
LEFT JOIN dbo.vwBankLists bl WITH(NOLOCK)
ON bl.rowId=cm.bankName
WHERE customerid=@customerId


END



GO
