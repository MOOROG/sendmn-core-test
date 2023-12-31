USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procAPI_checkAuthentication]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* 
	exec [proc_applicationUsers] 'i', NULL, NULL, 'admin', 'admin', @isActive = 'Y',@pwdChangeDays = 20,@pwdChangeWarningDays = 10
*/

CREATE proc [dbo].[procAPI_checkAuthentication]
	  @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@userName                         VARCHAR(30)		= NULL
     ,@pwd								VARCHAR(50)		= NULL
     ,@agentCode						VARCHAR(10)		= NULL
     ,@userCode							INT				= NULL
AS
/*
	@flag
	s	= select all (with dynamic filters)
	i	= insert
	u	= update
	a	= select by role id
	d	= delete by role id
	l	= login
	r	= reset password --@custodian_id, @user, @pwd
	cp  = change password --@user, @pwd, @oldPwd
	loc	= Lock
	cu	= check user
	lo	= Log Out
	[custodian]

*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	IF @flag = 'l'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1001, 'Invalid Username/Password/AgentCode/User Code', NULL
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1002, 'Invalid Username/Password/AgentCode/User Code', NULL
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND userId = @userCode AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1003, 'Invalid Username/Password/AgentCode/User Code', NULL
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND userId = @userCode AND agentCode = @agentCode AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1004, 'Invalid Username/Password/AgentCode/User Code', NULL
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName AND CAST(GETDATE() AS TIME) BETWEEN loginTime AND logoutTime)
		BEGIN
			EXEC proc_errorHandler 1005, 'Not permitted for logon at this time', NULL
			RETURN
		END 
		IF EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName AND ISNULL(isLocked, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1006, 'User is locked', NULL
			RETURN
		END
		EXEC proc_errorHandler 0, 'User Authentication Valid', NULL
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errorCode, ERROR_MESSAGE() mes, null id
END CATCH

GO
