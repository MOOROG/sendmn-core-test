USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_ChangePassword]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_online_ChangePassword]
     @userName			    VARCHAR(100),
     @oldPassword			VARCHAR(100),
     @newPassword			VARCHAR(100),
	 @IsForcedPwdChange		BIT
 AS 
 BEGIN

	DECLARE @oldpassDB VARCHAR(200),@customerId BIGINT
	
	SELECT 
		@oldpassDB = dbo.FNADecryptString(customerPassword)
		,@customerId= customerId 
	FROM customerMaster WITH (NOLOCK) WHERE email=@userName  or mobile = @userName
	
	IF isnull(@oldPassword,'1') = isnull(@newPassword,'')
	BEGIN
		EXEC proc_errorHandler 1, 'New Password can not be same as your old password, Please try again!', @customerId
		RETURN;
	END
	
	IF isnull(@oldpassDB,'1') <> isnull(@oldPassword,'')
	BEGIN
		EXEC proc_errorHandler 1, 'Your old password is invalid, Please try again!', @customerId
		RETURN;
	END

	IF @IsForcedPwdChange IS NOT NULL
	BEGIN
	  UPDATE customerMaster SET isForcedPwdChange = @IsForcedPwdChange
	  WHERE  email= @userName OR mobile = @userName
	END
	
     UPDATE customerMaster SET
		 customerPassword = dbo.encryptDb(@newPassword)
		,modifiedDate = GETDATE()	 
	 WHERE  email= @userName OR mobile = @userName


	 INSERT INTO passwordHistory(userName ,pwd, createdBy, createdDate)
	 SELECT @userName, dbo.encryptDb(@oldPassword), @userName, GETDATE()
	    
	 EXEC proc_errorHandler 0, 'Your password has been successfully changed. Please login to continue.', @customerId	
END

GO
