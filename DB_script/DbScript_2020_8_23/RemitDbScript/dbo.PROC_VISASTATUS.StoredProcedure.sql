USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_VISASTATUS]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC PROC_VISASTATUS @flag = 'update', @user = 'shikshya', @visaStatusId = '11021', @customerId = '47610'

create PROC [dbo].[PROC_VISASTATUS]

	@flag				VARCHAR(20)
	,@user				VARCHAR(20)	=	NULL
	,@visaStatusId		INT			= NULL
	,@customerId	    INT			= NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
IF @flag = 'update'
BEGIN
	IF EXISTS(SELECT 'X' FROM CUSTOMERMASTER WHERE CUSTOMERID = @customerId)
	BEGIN
		update customermaster set visastatus = @visaStatusId where customerid = @customerId

		SELECT '0' ErrorCode,'VisaStatus updated successfully', @customerId
	END
END
END
GO
