USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_passwordFormat]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_passwordFormat]
 	@flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId                             VARCHAR(30)		= NULL
	,@loginAttemptCount					INT				= NULL
	,@minPwdLength                      INT				= NULL
	,@pwdHistoryNum                     INT				= NULL
	,@specialCharNo                     INT				= NULL
	,@numericNo                         INT				= NULL
	,@capNo                             INT				= NULL
	,@lockUserDays						FLOAT			= NULL
	,@isActive							CHAR(1)			= NULL
	,@cddCheck							MONEY			= NULL
	,@eddCheck							MONEY			= NULL
	,@txnApprove						MONEY			= NULL
	,@holdCustTxnMoreBrnch				MONEY			= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
		IF NOT EXISTS(SELECT 'X' FROM passwordFormat)
		BEGIN
			INSERT INTO passwordFormat (
				 loginAttemptCount
				,minPwdLength
				,pwdHistoryNum
				,specialCharNo
				,numericNo
				,capNo
				,chkcddOn
				,chkEddOn
				,lockUserDays
				,txnApproveAmt
				,holdCustTxnMoreBrnch
				,isActive
				,createdBy
				,createdDate
			)
			SELECT
				 @loginAttemptCount
				,@minPwdLength
				,@pwdHistoryNum
				,@specialCharNo
				,@numericNo
				,@capNo
				,@cddCheck
				,@eddCheck
				,@lockUserDays
				,@txnApprove
				,@holdCustTxnMoreBrnch
				,@isActive
				,@user
				,GETDATE()
			
			SET @rowId = SCOPE_IDENTITY()
			Exec proc_errorHandler '0','Record has been added successfully.',NULL
		END
		ELSE
		BEGIN
			UPDATE passwordFormat SET
				 loginAttemptCount	= @loginAttemptCount
				,minPwdLength		= @minPwdLength
				,pwdHistoryNum		= @pwdHistoryNum
				,specialCharNo		= @specialCharNo
				,numericNo			= @numericNo
				,capNo				= @capNo
				,chkCddOn			= @cddCheck
				,chkEddOn			= @eddCheck
				,lockUserDays		= @lockUserDays
				,txnApproveAmt		= @txnApprove
				,holdCustTxnMoreBrnch	= @holdCustTxnMoreBrnch
				,isActive			= @isActive
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE 1 = 1
			
			SET @rowId = SCOPE_IDENTITY()
			
		END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		Exec proc_errorHandler '0','Record has been updated successfully.',NULL
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS(SELECT 'A' FROM passwordFormat)
		BEGIN
			SELECT *,'0' errorCode FROM passwordFormat WITH(NOLOCK)
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' errorCode,5 minPwdLength ,0 chkCustomerInfoOn,0 chkCDDInfoOn
			RETURN
		END
		
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE passwordFormat SET
				 loginAttemptCount	= @loginAttemptCount
				,minPwdLength		= @minPwdLength
				,pwdHistoryNum		= @pwdHistoryNum
				,specialCharNo		= @specialCharNo
				,numericNo			= @numericNo
				,capNo				= @capNo
				,chkCddOn			= @cddCheck
				,chkEddOn			= @eddCheck
				,lockUserDays		= @lockUserDays
				,txnApproveAmt		= @txnApprove
				,holdCustTxnMoreBrnch	= @holdCustTxnMoreBrnch
				,isActive			= @isActive
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE rowId = @rowId
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		Exec proc_errorHandler '0','Record has been updated successfully.',NULL
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
		select 1 code, @errorMessage msg
END CATCH



GO
