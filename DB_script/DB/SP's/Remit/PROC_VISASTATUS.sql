--EXEC PROC_VISASTATUS @flag = 'update', @user = 'shikshya', @visaStatusId = '11021', @customerId = '47610'

alter PROC PROC_VISASTATUS

	@flag					VARCHAR(30)
	,@user					VARCHAR(20)	=	NULL
	,@visaStatusId			INT			=	NULL
	,@customerId			INT			=	NULL
	,@additionalAddress	    VARCHAR(50)	=	NULL
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
ELSE IF @flag = 'update-additionalAddress'
BEGIN
	IF EXISTS(SELECT 'X' FROM CUSTOMERMASTER WHERE CUSTOMERID = @customerId)
	BEGIN
		update customermaster set additionalAddress = @additionalAddress where customerid = @customerId

		SELECT '0' ErrorCode,'Additional Address updated successfully', @customerId
	END
END
END