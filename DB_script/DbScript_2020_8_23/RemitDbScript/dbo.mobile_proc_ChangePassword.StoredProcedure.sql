USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_ChangePassword]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[mobile_proc_ChangePassword]
     @userName			    VARCHAR(100),
     @oldPassword			VARCHAR(100),
     @newPassword			VARCHAR(100)
 AS 
 BEGIN

	DECLARE @oldpassDB VARCHAR(200),@customerId BIGINT
	
	IF EXISTS(SELECT 'A' FROM customermastertemp(NOLOCK) WHERE username = @userName AND ISACTIVE='Y')
	BEGIN
		SELECT 
			@oldpassDB		= customerPassword
			,@customerId	= customerId 
		FROM customermastertemp WITH (NOLOCK) 
		WHERE username = @userName
		
		IF DBO.FNAencryptstring(@oldPassword) = DBO.FNAencryptstring(@newPassword)
		BEGIN
			EXEC proc_errorHandler 1, 'New Password can not be same as your old password, Please try again!', @customerId
			RETURN;
		END
	
		IF isnull(@oldpassDB,'1') <> DBO.FNAencryptstring(@oldPassword)
		BEGIN
			EXEC proc_errorHandler 1, 'Your old password is invalid, Please try again!', @customerId
			RETURN;
		END

		UPDATE customermastertemp SET
			 customerPassword = dbo.FNAencryptstring(@newPassword)
			,modifiedDate = GETDATE()	 
		 WHERE  username = @userName

		 INSERT INTO passwordHistory(userName ,pwd, createdBy, createdDate)
		 SELECT @userName, dbo.FNAencryptstring(@oldPassword), @userName, GETDATE()
	    
		 EXEC proc_errorHandler 0, 'Your password has been successfully changed.', @customerId

		RETURN
	END

	SELECT 
		@oldpassDB = customerPassword
		,@customerId= customerId 
	FROM customerMaster WITH (NOLOCK) 
	WHERE email = @userName
	
	IF DBO.FNAencryptstring(@oldPassword) = DBO.FNAencryptstring(@newPassword)
	BEGIN
		EXEC proc_errorHandler 1, 'New Password can not be same as your old password, Please try again!', @customerId
		RETURN;
	END
	
	IF isnull(@oldpassDB,'1') <> DBO.FNAencryptstring(@oldPassword)
	BEGIN
		EXEC proc_errorHandler 1, 'Your old password is invalid, Please try again!', @customerId
		RETURN;
	END
	
     UPDATE customerMaster SET
		 customerPassword = dbo.FNAencryptstring(@newPassword)
		,modifiedDate = GETDATE()	 
	 WHERE  email = @userName


	 INSERT INTO passwordHistory(userName ,pwd, createdBy, createdDate)
	 SELECT @userName, dbo.FNAencryptstring(@oldPassword), @userName, GETDATE()
	    
	 EXEC proc_errorHandler 0, 'Your password has been successfully changed.', @customerId	
END

GO
