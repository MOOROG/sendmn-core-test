USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_forgotPassword]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_online_forgotPassword](
	@flag			VARCHAR(10) =	NULL
   ,@customerEmail  VARCHAR(100) =	NULL
   ,@customerDob	DATE	=	NULL
   )
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @firstName VARCHAR(30),@dob VARCHAR(30),@newPassword VARCHAR(20),@email VARCHAR(40),@customerID VARCHAR(50), @customerIdNo VARCHAR(50)
	
	IF @flag='fp'
	BEGIN	
		
		SELECT @firstName = firstName+' '+lastName1,@dob = CAST(dob AS date),@email=email, @customerIdNo = idNumber
		FROM customerMaster WITH (NOLOCK) WHERE email = @customerEmail and onlineUser='Y' 
		
		IF @email IS NULL
		BEGIN
			SELECT '1' ErrorCode, 'Your information does not match, please provide the valid information. ' Msg
		END

		if @dob is null
		begin
			SET @dob = CAST(dbo.FNAGETDOB_FROM_ALIENCARD(LEFT(@customerIdNo,6),RIGHT(LEFT(@customerIdNo,8),1)) AS DATE);
		end
		IF @dob=@customerDob 
		BEGIN	
																																
			SET @newPassword = RIGHT('0000000' + CAST(CHECKSUM(NEWID()) AS VARCHAR), 7)					
			UPDATE dbo.customerMaster SET customerPassword=dbo.FNAEncryptString(@newPassword),isForcedPwdChange=1 WHERE email=@customerEmail		
										 
			SELECT '0' ErrorCode, @firstName as fullName, @dob as DateOfBirth, @newPassword as [Password], @customerID AS customerId
		END		
		ELSE
		SELECT '1' ErrorCode, 'Your information does not match, please provide the valid information.' Msg
			
	END					
END
GO
