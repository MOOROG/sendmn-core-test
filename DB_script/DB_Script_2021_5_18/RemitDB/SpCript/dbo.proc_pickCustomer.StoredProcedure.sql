USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_pickCustomer]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROC proc_pickCustomer
--GO

/*

	proc_pickCustomer @customerType = 's', @name = 'Raj'

*/

CREATE proc [dbo].[proc_pickCustomer]
	 @customerType CHAR(1)
	,@membershipId INT = NULL
	,@name VARCHAR(50) = NULL
	,@address VARCHAR(50) = NULL
	,@mobile VARCHAR(50) = NULL
	,@email VARCHAR(50) = NULL
	,@user VARCHAR(30) = NULL
AS


DECLARE @senderList TABLE(
	 rowId INT IDENTITY(1, 1)
	,membershipId INT
	,name VARCHAR(50)
	,address VARCHAR(50)
	,mobile VARCHAR(50)
	,email VARCHAR(50)
	,customerType CHAR(1)
)


INSERT @senderList
SELECT '101', 'Bijaya Sahi', 'Kathmandu', '9876543210', 'bijay@swifttech.com.np', 's'
UNION ALL
SELECT '102', 'Binay Rai', 'Kathmandu', '1234567890', 'binay@swifttech.com.np', 's'
UNION ALL
SELECT '103', 'Dipesh Shrestha', 'Khadbari', '4563219870', 'dipesh@swifttech.com.np', 's'
UNION ALL
SELECT '104', 'Pralhad Sedai', 'Bharatpur', '9876543210', 'bijay@swifttech.com.np', 's'
UNION ALL
SELECT '105', 'Rajnikanta', 'Banglure', '3345333322', 'gmail@rajnikant.com.np', 's'
UNION ALL
SELECT '106', 'Rajesh Dai', 'Kathmandu', '77777777777', 'rajesh@swifttech.com.np', 's'

INSERT @senderList
SELECT
	 membershipId
	,name + ' - Receiver'
	,address
	,mobile
	,email
	,'r'
FROM @senderList

SELECT * INTO tCust FROM @senderList
--WHERE customerType = @customerType
--	AND membershiptId = ISNULL(@membershipId, membershipId)
--	AND name LIKE '%' +  ISNULL(@name, name) + '%'
--	AND address LIKE '%' +  ISNULL(@address, address) + '%'
--	AND mobile LIKE '%' +  ISNULL(@mobile, mobile) + '%'
--	AND email LIKE '%' +  ISNULL(@email, email) + '%'
	


GO
