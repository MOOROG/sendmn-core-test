USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_extCredentials]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
proc_extCredentials 's'

*/

CREATE proc [dbo].[proc_extCredentials](
	 @flag					VARCHAR(10)	= NULL
	,@providerCode			VARCHAR(50) = NULL
	,@agentAuthCode			VARCHAR(50)	= NULL
	,@agentCode				VARCHAR(50) = NULL
	,@userId				VARCHAR(50) = NULL
	,@pwd					VARCHAR(50) = NULL
	,@pin					VARCHAR(50) = NULL
	,@createdBy				VARCHAR(30)	= NULL
	,@createdDate			DATETIME	= NULL
	,@modifiedBy			VARCHAR(30)	= NULL
	,@modifiedDate			DATETIME	= NULL
	,@user					VARCHAR(30) = NULL
	,@pageNumber     		INT			= NULL
	,@select_field_list		VARCHAR(MAX) = NULL
	,@extra_field_list		VARCHAR(MAX) = NULL
	,@table					VARCHAR(MAX) = NULL
	,@sql_filter			VARCHAR(MAX) = NULL
	,@ApprovedFunctionId	VARCHAR(8)	 = NULL
	,@msg					VARCHAR(200) = NULL
	,@sortBy				VARCHAR(50)  = NULL 
	,@sortOrder				VARCHAR(5)	 = NULL     
	,@pageSize				INT			 = NULL       
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
/*
select * FROM extCredentials
EXEC proc_extCredentials @flag = 'cp',@providerCode='xPress',@pwd='system123',@pin='444444',@user='admin'
*/
BEGIN TRY
	IF @flag = 'cp'
		BEGIN
			UPDATE extCredentials SET
				 pwd = @pwd
				,pin = @pin
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE providerCode = @providerCode			
			SELECT 0 error_Code, 'Password has been changed successfully' mes, @providerCode
			RETURN	
		END
	
	ELSE IF @flag = 'a'
		BEGIN
			SELECT * FROM extCredentials WITH(NOLOCK) WHERE providerCode = @providerCode
			RETURN
		END
	
	ELSE IF @flag = 'i'
		BEGIN
			INSERT INTO extCredentials(agentAuthCode, agentCode, userId, pwd, pin, providerCode, createdBy, createdDate, modifiedBy, modifiedDate)
			SELECT @agentAuthCode, @agentCode, @userId, @pwd, @pin, @providerCode, @user, GETDATE(), @modifiedBy, @modifiedDate
			   SELECT 0 error_Code, 'Record has been added successfully' mes, @providerCode
		END
		
	ELSE IF @flag = 'u'
		BEGIN
			UPDATE extCredentials SET agentAuthCode = @agentAuthCode , agentCode = @agentCode, userId = @userId, pwd = @pwd, pin = @pin,
			modifiedBy = @user, modifiedDate = GETDATE() WHERE providerCode = @providerCode
			  SELECT 0 error_Code, 'Record has been updated successfully' mes, @providerCode
		END
		
	ELSE IF @flag = 'd'
		BEGIN
			DELETE FROM extCredentials WHERE providerCode = @providerCode
			  SELECT 0 error_Code, 'Record has been deleted successfully' mes,@providerCode
		END
		
	ELSE IF @flag = 's'
	 BEGIN
		IF @sortOrder IS NULL SET @sortOrder = 'ASC'
		IF @sortBy IS NULL SET @sortBy = 'agentAuthCode'
			
		SET @table = '(
				SELECT 
					agentAuthCode,
					agentCode, 
					userId,
					''xxxxxxxxxxxxxxx'' pwd,
					''xxxxxxxxxxx'' pin,
					providerCode,
					createdBy,
					createdDate,
					modifiedBy,
					modifiedDate
				FROM extCredentials
			)x'
		
		SET @sql_filter = ''
		
		SET @select_field_list ='agentAuthCode,
								agentCode, 
								userId,
								pwd,
								pin,
								providerCode,
								createdBy,
								createdDate,
								modifiedBy,
								modifiedDate'
								
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
	END
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errorCode, ERROR_MESSAGE() mes, null id
END CATCH


GO
