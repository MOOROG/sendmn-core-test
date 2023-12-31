USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_getStaticForOnline]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_online_getStaticForOnline]
	 @Flag			VARCHAR(50)  = NULL
	,@user			VARCHAR(150) = NULL
	,@param			VARCHAR(100) = NULL
	,@paymentType	VARCHAR(100) = NULL
	,@bankId		VARCHAR(50)	 = NULL
	,@payLocationId	VARCHAR(50)	 = NULL
AS

SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY

	IF @flag = 'adminEmails'
	BEGIN
		SELECT email From dbo.systemEmailsetup  where ISNULL(onlineTxnAlerts,'N') = 'Y' AND ISNULL(isDeleted,'N') <> 'Y'
	END

	ELSE IF @flag = 'customerStatus'
	BEGIN
		SELECT CASE WHEN ISNULL(customerStatus,'P') = 'P' THEN 'pending' ELSE 'verified' END   
		FROM dbo.customerMaster WHERE email = @user
	END
	ELSE IF @flag = 'getCountryCode'
	BEGIN
		SELECT countryCode FROM dbo.countryMaster WITH(NOLOCK) WHERE countryId = @param
	END
	ELSE IF @flag = 'payingCorrespLocID'
	BEGIN
		
		IF(@paymentType = '1') --CASH PAYMENT
		BEGIN

			SELECT CorrespLocID,PriorityIndex, FBankID = NULL FROM Ria_PayingCorrespLocID WITH(NOLOCK) 
			WHERE countryId = @param AND ISNULL(payLocId,'') = ISNULL(@payLocationId,'')
		END
		ELSE IF(@paymentType = '2')--BANK DEPOSIT
		BEGIN
			SELECT DISTINCT CorrespLocID = fCorrespLocID, PriorityIndex = 0, FBankID FROM dbo.Ria_BankList bl WITH(NOLOCK)
			INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON bl.Country = cm.countryCode
			WHERE cm.countryId =  @param AND fBankID = ISNULL(@bankId,fBankID)
		END		
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, null
END CATCH
GO
