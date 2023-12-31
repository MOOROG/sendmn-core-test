USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_GmeApiClientRegistration]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Client Signup/Registration 
*/
CREATE PROCEDURE [dbo].[mobile_proc_GmeApiClientRegistration]	
	@flag				VARCHAR(30)
	,@applicationName	VARCHAR(50)		= NULL	
	,@description		VARCHAR(MAX)	= NULL			
	,@aboutUrl			VARCHAR(100)	= NULL	
	,@applicationType	VARCHAR(50)		= NULL
	,@scope				VARCHAR(50)		= NULL
	,@secret			VARCHAR(50)		= NULL
	,@clientId			VARCHAR(100)	= NULL

AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;
BEGIN TRY
	
	----------------------- Local variables declaration ###STARTS------------------------

	DECLARE @_clientId		VARCHAR(100)
			,@_rowId			INT
	
	----------------------- Local variables declaration ###ENDS------------------------

	IF @flag='appRegister' --application registered for the first time.
	BEGIN
		IF ISNULL(@scope,'') NOT IN('mobile_app','social_comp')
		BEGIN
			SELECT '1' ErrorCode, 'Unable to mapped with requested scope/channel.' Msg ,NULL ID
			RETURN
		END
		SET @_clientId=CONCAT
						(
							DATEPART(SECOND,GETDATE())
							,YEAR(GETDATE())
							,LEFT( NEWID(), 5 )
							,MONTH(GETDATE())
							,DAY(GETDATE())
							,LEFT( NEWID(), 5 )
							,DATEPART(HOUR,GETDATE())
							,DATEPART(MINUTE,GETDATE())
							,DATEPART(MILLISECOND,GETDATE())
						)
		BEGIN TRANSACTION
		INSERT INTO mobile_GmeApiClientRegistration(applicationName,[description],aboutUrl,applicationType,scope,isActive)
		SELECT @applicationName,@description,@aboutUrl,@applicationType,@scope,1

		SET @_rowId=SCOPE_IDENTITY()

		UPDATE mobile_GmeApiClientRegistration SET [secret]=dbo.FNAEncryptString(@secret),clientId=@_clientId WHERE rowid=@_rowId

		 IF @@TRANCOUNT > 0  
		 COMMIT TRANSACTION  
		 SELECT '0' ErrorCode , @_clientId clientId, @secret [secret]
		 RETURN
	END
	ELSE IF @flag='chk-client' --application registered for the first time.
	BEGIN
		IF EXISTS
		(			
			SELECT 'X' FROM mobile_GmeApiClientRegistration(NOLOCK) 
			WHERE clientId=@clientId 
					AND [secret]=dbo.FNAEncryptString(@secret) 
					AND ISNULL(isActive,0)=1 
					AND ISNULL(approvedDate,'')<>''
					AND ISNULL(scope,'') IN('mobile_app','social_comp')
		)
		BEGIN
			PRINT 1
			SELECT @scope=scope FROM mobile_GmeApiClientRegistration(NOLOCK) 
			WHERE clientId=@clientId AND [secret]=dbo.FNAEncryptString(@secret) 

			SELECT '0' ErrorCode , 'Success.' Msg, @scope ID
			RETURN
		END
		ELSE IF EXISTS
		(
			SELECT 'X' FROM mobile_GmeApiClientRegistration(NOLOCK) 
			WHERE clientId=@clientId 
					AND [secret]=dbo.FNAEncryptString(@secret) 
					AND ISNULL(isActive,0)=1 
					AND ISNULL(approvedDate,'')<>''
					AND ISNULL(scope,'') NOT IN('mobile_app','social_comp')
		)
		BEGIN
			PRINT 2
			SELECT '1' ErrorCode , 'User not mapped within the scope of application.' Msg, NULL ID
			RETURN
		END
		ELSE IF EXISTS
		(
			SELECT 'X' FROM mobile_GmeApiClientRegistration(NOLOCK) 
			WHERE clientId=@clientId 
					AND [secret]=dbo.FNAEncryptString(@secret) 
					AND ISNULL(isActive,0)=0 
					AND ISNULL(approvedDate,'')<>''
					AND ISNULL(scope,'') IN('mobile_app','social_comp')
		)
		BEGIN
			PRINT 3
			SELECT '1' ErrorCode , 'Application scope is no longer exists or removed.' Msg, NULL ID
			RETURN
		END
		ELSE IF EXISTS
		(
			SELECT 'X' FROM mobile_GmeApiClientRegistration(NOLOCK) 
			WHERE clientId=@clientId 
					AND [secret]=dbo.FNAEncryptString(@secret) 
					AND ISNULL(isActive,0)=1 
					AND ISNULL(approvedDate,'')=''
					AND ISNULL(scope,'') IN('mobile_app','social_comp')
		)
		BEGIN
		PRINT 4
			SELECT '1' ErrorCode , 'Application scope is in pending for approval.' Msg, NULL ID
			RETURN
		END
		ELSE
		BEGIN
			PRINT 5
			SELECT '1' ErrorCode , 'Client Id or secret doesnot match.' Msg, NULL ID
			RETURN
		END
	END
END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE() 
	 SELECT '1' ErrorCode, @errorMessage Msg ,NULL ID
END CATCH

GO
