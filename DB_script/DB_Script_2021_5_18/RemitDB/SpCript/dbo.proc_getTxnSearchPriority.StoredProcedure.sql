USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_getTxnSearchPriority]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_getTxnSearchPriority]
	 @controlNo VARCHAR(50) 
	,@user VARCHAR(50) = NULL
	
AS

DECLARE @list TABLE(rowId INT IDENTITY(1, 1), ID VARCHAR(50), Name VARCHAR(50))

declare @sCountry varchar(200),@ICNlastCar  char(1)

SELECT @ICNlastCar = SendMnPro_Account.dbo.FNALastCharInDomTxn()

select @sCountry = sCountry 
	from remitTran rt with(nolock) where controlNo = dbo.fnaencryptstring(@controlNo)

IF (LEN(@controlNo) = 12 AND RIGHT(@controlNo, 1) = @ICNlastCar AND @controlNo LIKE '7%') 
BEGIN	
	SELECT 'IME-D' ID, 'IME-D' Name
	RETURN
END

ELSE IF (LEFT(@controlNo, 2) = '77' AND LEN(@controlNo) = 11 AND RIGHT(@controlNo, 1) <> @ICNlastCar and @sCountry IS NULL) 
	OR (LEFT(@controlNo, 3) = '777' AND LEN(@controlNo) = 12 AND RIGHT(@controlNo, 1) <> @ICNlastCar) 
	OR (LEFT(@controlNo, 3) = '777' AND LEN(@controlNo) = 13 AND RIGHT(@controlNo, 1) <> @ICNlastCar) 
	OR (LEFT(@controlNo, 3) = '777' AND LEN(@controlNo) = 14 AND RIGHT(@controlNo, 1) <> @ICNlastCar)
	OR (LEFT(@controlNo, 4) = '777A' AND LEN(@controlNo) = 12 AND RIGHT(@controlNo, 1) <> @ICNlastCar)
	OR (LEFT(@controlNo, 4) = '33TF')
BEGIN
	SELECT '6873' ID, 'GBL' Name
	RETURN
END

ELSE IF (LEFT(@controlNo, 2) = 'KD' AND LEN(@controlNo) = 14 AND RIGHT(@controlNo, 1) <> @ICNlastCar) 
	OR (LEFT(@controlNo, 1) = 'K' AND LEN(@controlNo) = 13 AND RIGHT(@controlNo, 1) <> @ICNlastCar) 
	OR (LEFT(@controlNo, 3) = '888' AND LEN(@controlNo) = 12 AND RIGHT(@controlNo, 1) <> @ICNlastCar) 
BEGIN
	SELECT '9267' ID, 'Kumari Bank' Name
	RETURN
END



GO
