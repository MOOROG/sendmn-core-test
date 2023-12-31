USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_customerValidation]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_online_customerValidation]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(100)
	,@senderId			VARCHAR(50)		= NULL	
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN
	DECLARE  @idExpiryDate		DATETIME
			,@createdDate		DATETIME

	IF @flag='checkUser'
		BEGIN	
            SELECT TOP 1
                    @senderId = customerId ,
                    @idExpiryDate = idExpiryDate ,
                    @createdDate = createdDate
            FROM    customerMaster WITH ( NOLOCK )
            WHERE   email = @user;
		
		
            IF ( @idExpiryDate < GETDATE() )
                BEGIN
					DECLARE @msg VARCHAR(250)= 'Your provided photo id has been expired. Please contact GME Support Team by writing email to support@gmeremit.com or call on +44 (0) 20 8861 2264.'

					EXEC proc_errorHandler '0', @msg, @senderId	
                    RETURN;		
                END;
			EXEC proc_errorHandler '0', 'User is valid to do transaction.', @senderId	
		END					
	END
END TRY
	BEGIN CATCH
		IF @@TRANCOUNT<>0
			ROLLBACK TRANSACTION
		
		DECLARE @errorMessage VARCHAR(MAX)
		SET @errorMessage = ERROR_MESSAGE()
	
		EXEC proc_errorHandler 1, @errorMessage, @user
	
END CATCH			
GO
