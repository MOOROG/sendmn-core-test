USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_JME_AGENT_SYSTEM_ACCOUNT]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PROC_JME_AGENT_SYSTEM_ACCOUNT] 
	-- Add the parameters for the stored procedure here
	@flag					VARCHAR(200)						,
	@user					VARCHAR(100)			=		NULL,
	@referralCode			VARCHAR(100)			=		NULL,
	@password				VARCHAR(100)			=		NULL,
	@IpAddress				VARCHAR(100)			=		NULL,
	@userDetails			VARCHAR(MAX)			=		NULL,
	@newPassword			VARCHAR(100)			=		NULL,
	@isForceChangePwd		CHAR(1)					=		NULL
        
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE				
			@_IsExist					BIT				=		0,
			@_IsActive					BIT				=		0,
			@_IsError					BIT				=		0,
			@_IsLocked					BIT				=		0,
			@_IsDelete					BIT				=		0,
			@_isforceChangePwd			BIT				=		0,
			@_pwdChangeDays				INT				=		NULL,
			@_pwdChangeWarningDays		INT				=		NULL,
			@_lastLoginDate				DATETIME		=		NULL,
			@_userData					VARCHAR(200)	=		NULL,
			@_Reasion					VARCHAR(2000)	=		NULL,
			@_referralId				BIGINT			=		NULL,
			@_username					VARCHAR(100)	=		NULL,
			@_address					VARCHAR(200)	=		NULL,
			@_mobile					VARCHAR(50)		=		NULL,
			@_email						VARCHAR(150)	=		NULL,
			@_referralType				VARCHAR(150)	=		NULL,
			@_errorMessage				VARCHAR(MAX)	=		NULL,
			@_invalidPwdCount			TINYINT			=		NULL

	CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))
	
	IF @flag='l'
	BEGIN
		SELECT	
				@_IsExist						=			1,
				@_referralId					=			RAU.rowId,
				@_IsLocked						=			RAU.isLocked,
				@_IsActive						=			RAU.IsActive,
				@_IsDelete						=			RAU.IsDeleted,
				@_isforceChangePwd				=			RAU.isforceChangePwd,		
				@_pwdChangeDays					=			RAU.pwdChangeDays,			
				@_pwdChangeWarningDays			=			RAU.pwdChangeWarningDays,	
				@_lastLoginDate					=			RAU.lastLoginDate,
				@_invalidPwdCount				=			ISNULL(RAU.wrongPwdCount, 0)
		FROM dbo.REFERRAL_APPLICATION_USER (NOLOCK) RAU 
		WHERE RAU.referalCode=@referralCode 
		AND RAU.pwd = dbo.fnaencryptstring(@password)
		
		SET @_UserData ='User:' + ISNULL(@user,'') + ', ReferralCode:' + CAST(@referralCode AS VARCHAR(20)) + ', Ip Address:' + CAST(@IpAddress AS VARCHAR(20))

		IF EXISTS(SELECT 1 FROM REFERRAL_APPLICATION_USER (NOLOCK) WHERE referalCode = @referralCode AND (wrongPwdCount >= 4 OR isLocked = 1))
		BEGIN
			SET @_Reasion='User locked: Due to invalid login Attempts'
			SET @userDetails = 'Reason = User Locked due to Invalid login attempts.-:::-' + @userDetails

			EXEC proc_errorHandler 1, 'Sorry you are locked at this time, due to invalid login attempts. Contact JME for more information.', @referralCode

			EXEC PROC_APPLICATION_LOGS_REFERRAL @agentId=@_referralId,@logType='Login',@IP=@IpAddress,@Reason=@_Reasion,@fieldValue=@userDetails,@user=@user,@UserData=@_userData
			RETURN
		END
		
		IF @_IsExist = 0 AND EXISTS (SELECT 1 FROM REFERRAL_APPLICATION_USER (NOLOCK) WHERE referalCode = @referralCode)
		BEGIN
			SELECT @_invalidPwdCount = ISNULL(wrongPwdCount, 0)
			FROM REFERRAL_APPLICATION_USER(NOLOCK)  
			WHERE referalCode = @referralCode

			IF @_invalidPwdCount >= 4
			BEGIN
				SET @_Reasion='User locked: Invalid username or password'
				SET @userDetails = 'Reason = User Locked due to Invalid login attempts.-:::-' + @userDetails

				EXEC proc_errorHandler 1, 'Sorry you are locked at this time, due to invalid login attempts. Contact JME for more information.', @referralCode

				EXEC PROC_APPLICATION_LOGS_REFERRAL @agentId=@_referralId,@logType='Login',@IP=@IpAddress,@Reason=@_Reasion,@fieldValue=@userDetails,@user=@user,@UserData=@_userData
				
				UPDATE REFERRAL_APPLICATION_USER
				SET isLocked = 1, lockedDate = GETDATE()
				WHERE referalCode = @referralCode
				RETURN
			END

			SET @_Reasion='User Name Or Password Not Match, you have ' + CAST((4 - ISNULL(@_invalidPwdCount, 1)) AS VARCHAR) + ' attempts left!'
			SET @userDetails = 'Reason = Login fails, Incorrect user name or password.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, @_Reasion, @referralCode
			
			UPDATE REFERRAL_APPLICATION_USER SET wrongPwdCount = ISNULL(wrongPwdCount, 0) + 1
			WHERE referalCode = @referralCode 
		END

		ELSE IF @_IsExist = 0 AND NOT EXISTS (SELECT 1 FROM REFERRAL_APPLICATION_USER (NOLOCK) WHERE referalCode = @referralCode)
		BEGIN
			SET @_Reasion='User Name Or Password Not Match !'
			SET @userDetails = 'Reason = Login fails, Incorrect user name or password.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'User Name Or Password Not Match !', @referralCode
			
			UPDATE REFERRAL_APPLICATION_USER SET wrongPwdCount = ISNULL(wrongPwdCount, 0) + 1
			WHERE referalCode = @referralCode 
		END

		ELSE IF @_IsLocked=1
		BEGIN
			SET @_Reasion='user data is locked by system'
			SET @userDetails = 'Reason = User data is locked by system.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'You Are Locked By The Jme System. Please Contact JME Office !', @referralCode
		END

		ELSE IF @_IsActive=0
		BEGIN
			SET @_Reasion='User Data Not Active '
			SET @userDetails = 'Reason = User Data Not Active.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'You Are Not A Active User. Please Contact JME Office !', @referralCode
		END

		ELSE IF @_IsDelete=1
		BEGIN
			SET @_Reasion='User Data Is Deleted By System'
			SET @userDetails = 'Reason = User Data Is Deleted By System.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'Your Data Is Blocked By System. Please Contact JME Office !', @referralCode
		END
		ELSE
		BEGIN
		    SET @_Reasion='Login Successful'
			SET @userDetails = 'Reason = Login Successful.-:::-' + @userDetails

			INSERT INTO #TEMP_ERROR_CODE 
			EXEC proc_errorHandler 0, 'Login Success', @referralCode
		END
		
		EXEC PROC_APPLICATION_LOGS_REFERRAL @agentId=@_referralId,@logType='Login',@IP=@IpAddress,@Reason=@_Reasion,@fieldValue=@userDetails,@user=@user,@UserData=@_userData

		IF NOT EXISTS(SELECT * FROM #TEMP_ERROR_CODE WHERE ERROR_CODE = 1)
		BEGIN
			SELECT * FROM #TEMP_ERROR_CODE

			SELECT ROW_ID, REFERRAL_CODE, REFERRAL_NAME, ISNULL(REFERRAL_ADDRESS,'N/A') REFERRAL_ADDRESS, REFERRAL_MOBILE, REFERRAL_EMAIL
					, AM.AGENTNAME, REFERRAL_TYPE_CODE, REFERRAL_LIMIT, @_isforceChangePwd FORCE_CHANGE_PWD
			FROM REFERRAL_AGENT_WISE R(NOLOCK)
			LEFT JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = R.BRANCH_ID
			WHERE REFERRAL_CODE = @referralCode
			
			UPDATE REFERRAL_APPLICATION_USER SET wrongPwdCount = 0
			WHERE referalCode = @referralCode 
			RETURN
		END
		SELECT * FROM #TEMP_ERROR_CODE
	END

	IF @flag='changepassword'
	BEGIN
	    SELECT	
				@_IsExist						=			1,
				@_IsLocked						=			RAU.isLocked,
				@_IsActive						=			RAU.IsActive,
				@_IsDelete						=			RAU.IsDeleted
		FROM dbo.REFERRAL_APPLICATION_USER (NOLOCK) RAU 
		INNER JOIN REFERRAL_AGENT_WISE (NOLOCK) RA ON RA.REFERRAL_CODE=RAU.referalCode
		WHERE RAU.referalCode=@referralCode 
		AND RAU.pwd=dbo.fnaencryptstring(@password)
		
		IF ISNULL(@_IsExist, 0) = 0
		BEGIN
			SET @_Reasion='User Name Or Password Not Match !'
			SET @userDetails = 'Reason = Login fails, Incorrect user name or password.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'Old password did not match !', @referralCode
		END

		ELSE IF ISNULL(@_IsLocked, 0) = 1
		BEGIN
			SET @_Reasion='user data is locked by system'
			SET @userDetails = 'Reason = User data is locked by system.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'You Are Locked By The Jme System. Please Contact JME Office !', @referralCode
		END

		ELSE IF ISNULL(@_IsActive, 1) = 0
		BEGIN
			SET @_Reasion='User Data Not Active '
			SET @userDetails = 'Reason = User Data Not Active.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'You Are Not A Active User. Please Contact JME Office !', @referralCode
		END

		IF ISNULL(@_IsDelete, 0) = 1
		BEGIN
			SET @_Reasion='User Data Is Deleted By System'
			SET @userDetails = 'Reason = User Data Is Deleted By System.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
		    EXEC proc_errorHandler 1, 'Your Data Is Blocked By System. Please Contact JME Office !', @referralCode
		END
	

		IF NOT EXISTS(SELECT 1 FROM #TEMP_ERROR_CODE WHERE ERROR_CODE=1)
		BEGIN
			UPDATE REFERRAL_APPLICATION_USER SET pwd=dbo.encryptDb(@newPassword), LastPwdChangedDate = GETDATE(), isforceChangePwd = 0
			WHERE referalCode=@referralCode AND pwd=dbo.encryptDb(@password)
			SET @_Reasion='Change Password Successful'
			SET @userDetails = 'Reason = Change Password Successful.-:::-' + @userDetails
			INSERT INTO #TEMP_ERROR_CODE 
			EXEC proc_errorHandler 0, 'Password Change Successful', @referralCode			
		END
	
		EXEC PROC_APPLICATION_LOGS_REFERRAL @agentId=@_referralId,@logType='Change Password',@IP=@IpAddress,@Reason=@_Reasion,@fieldValue=@userDetails,@user=@user,@UserData=@_userData
		SELECT * FROM #TEMP_ERROR_CODE
	END
END

GO
