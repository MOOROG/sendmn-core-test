USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ValidateDuplicateCustomer]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Proc_ValidateDuplicateCustomer]
(
  @customerId int  
)
AS
begin	
	DECLARE @DOB DATE,@ID INT = 1,@CName varchar(100), @CompName varchar(100)
	SELECT @DOB = dob,@CName = fullName FROM customerMaster(NOLOCK) WHERE customerId = @customerId

	create table #TEMP(fullName varchar(100),IsOk int,customerId bigint)

	insert into #TEMP(fullName,IsOk,customerId)

	SELECT fullName,1 as IsOk,customerId 
	FROM customerMaster(NOLOCK) WHERE dob = @DOB and customerId <> @customerId

	ALTER TABLE #TEMP ADD ID INT IDENTITY(1,1)

	declare @str int 
	select @str = count(1) from #TEMP

	WHILE @str > = @ID AND EXISTS (SELECT 'A' FROM #TEMP WHERE IsOk <> 0)
	BEGIN
		SELECT @CompName = fullName FROM #TEMP WHERE ID = @ID
		
		IF(SELECT DBO.FNA_MatchCustomerName(@CName,@CompName)) = 1
			UPDATE #TEMP SET IsOk = 0 WHERE ID = @ID
		
		SET @ID = @ID + 1
	END

	select @customerId orgCust,customerId from #TEMP where IsOk = 0
	RETURN
END
GO
