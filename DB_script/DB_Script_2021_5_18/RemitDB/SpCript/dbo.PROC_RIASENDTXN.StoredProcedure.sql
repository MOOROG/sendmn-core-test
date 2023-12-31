USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_RIASENDTXN]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_RIASENDTXN]
(
	@flag				VARCHAR(20)
	,@user				VARCHAR(50)	= NULL
	,@txnDate			DATETIME	= NULL
	,@cAmt				MONEY		= NULL
	,@pAmt				MONEY		= NULL
	,@exRate			FLOAT		= NULL
	,@sCharge			MONEY		= NULL
	,@senderName		VARCHAR(150)= NULL
	,@sIdNumber			VARCHAR(20)	= NULL
	,@pCurr				VARCHAR(5)	= NULL
	,@sCountry			VARCHAR(30)	= NULL
	,@sCountryId		VARCHAR(30)	= NULL
	,@controlNumber		VARCHAR(20)	= NULL
	,@receiverName		VARCHAR(150)= NULL
	,@receiverCountry	VARCHAR(30)	= NULL
	,@receiverCountryId	VARCHAR(30)	= NULL
	,@orderNumber		VARCHAR(20)	= NULL
	,@sequenceNumber	VARCHAR(20)	= NULL
	,@paymentMethod		VARCHAR(30)	= NULL
	,@branchId			INT			= NULL
	,@sIdTypeText		VARCHAR(40)	= NULL
	,@sIdType			VARCHAR(15)	= NULL
	,@sMobile			VARCHAR(20) = NULL
	,@sEmail			VARCHAR(100) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN
		IF @flag = 'pCurr'
		BEGIN
			SELECT currencyCode FROM currencyMaster CM(NOLOCK)
			WHERE ISNULL(CM.isActive, 'Y') = 'Y'
			ORDER BY CM.currencyCode ASC
		END
		ELSE IF @flag = 'exrate'
		BEGIN
			SELECT 102.12
			RETURN
		END
		ELSE IF @flag = 'i'
		BEGIN
			IF @user IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Your session expired, please re-login to continue', null;
				RETURN
			END
			IF @branchId IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'You are not authorised to make the transaction', null;
				RETURN
			END
			IF ISNULL(@senderName, '') = ''
			BEGIN
				EXEC proc_errorHandler 1, 'Sender Name can not be empty!', null;
				RETURN
			END
			IF ISNULL(@receiverName, '') = ''
			BEGIN
				EXEC proc_errorHandler 1, 'Receiver Name can not be empty!', null;
				RETURN
			END
			IF ISNULL(@sIdNumber, '') = ''
			BEGIN
				EXEC proc_errorHandler 1, 'Receiver Name can not be empty!', null;
				RETURN
			END
			IF NOT EXISTS(SELECT 1 FROM currencyMaster (NOLOCK) WHERE currencyCode = @pCurr)
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Payout Currency code!', null;
				RETURN
			END
			IF EXISTS(SELECT 1 FROM remitTran (NOLOCK) WHERE controlNo = dbo.fnaEncryptString(@controlNumber))
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction already exists with same Control Number!', null;
				RETURN
			END

			DECLARE @pSuperAgent INT, @pSuperAgentName VARCHAR(100), @pAgent INT, @pAgentName VARCHAR(100), @pBranch INT, @pBranchName VARCHAR(100)
			DECLARE @sSuperAgent INT, @sSuperAgentName VARCHAR(100), @sAgent INT, @sAgentName VARCHAR(100), @sBranch INT, @sBranchName VARCHAR(100)

			SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
				   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
			FROM dbo.FNAGetBranchFullDetails(221227)

			SELECT @sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName,
				   @sAgent = sAgent,@sAgentName = sAgentName ,@sBranch = sBranch, @sBranchName = sBranchName
			FROM dbo.FNAGetBranchFullDetails(@branchId)

			SET @txnDate = @txnDate + CONVERT(VARCHAR,GETDATE(),108)

			DECLARE @customerId VARCHAR(20)
			--------#Register Customer if not registered#---------------
			EXEC PROC_CHECK_CUSTOMER_REGISTRATION @flag = 'i', @customerName = @senderName, @customerIdNo = @sIdNumber, @customerIdType = @sIdType, 
				@nativeCountryId = @sCountryId, @customerId = @customerId OUT, @user = @user, @custMobile = @sMobile, @custEmail = @sEmail
			
			IF @customerId = '0000'
			BEGIN
				EXEC proc_errorHandler 1, 'Sender Email can not be blank.', NULL
				RETURN
			END
			
			DECLARE @cAmtUSD MONEY,@paymentMethodId int,@sCurrCostRate MONEY,@sCurrHoMargin MONEY
			
			select @paymentMethodId = serviceTypeId from serviceTypeMaster(nolock) where typeTitle = @paymentMethod
			select @receiverCountryId = countryId from CountryMaster(nolock) where countryName = @receiverCountry

			SELECT 
				@sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
			FROM dbo.FNAGetExRate(118, @sAgent, @sBranch, 'KRW', @receiverCountryId, @pAgent, @pCurr, @paymentMethodId)

			SET @cAmtUSD = @cAmt/(@sCurrCostRate+ISNULL(@sCurrHoMargin,0))

			DECLARE @message VARCHAR(1000) = NULL,@errCode TINYINT = NULL,@ruleId INT = NULL

			EXEC proc_complianceRuleDetail @flag= 'sender-limit',@user=@user,@cAmtUSD=@cAmtUSD,@customerId=@customerId
				,@pCountryId=NULL,@deliveryMethod = @paymentMethodId,@message=@message out, @errCode=@errCode out
				,@ruleId=  @ruleId out

			IF @errCode <> 0
			BEGIN
				EXEC proc_errorHandler 1,@message, null;
				RETURN
			END
			
			BEGIN TRANSACTION;
				INSERT  INTO remitTran
				( 
					controlNo ,sCurrCostRate, sCurrHoMargin ,pCurrCostRate ,pCurrHoMargin ,customerRate , serviceCharge ,pAgentComm ,pAgentCommCurrency ,
					sSuperAgent ,sSuperAgentName ,sAgent ,sAgentName ,sBranch ,sBranchName ,sCountry ,pSuperAgent ,pSuperAgentName ,
					pAgent ,pAgentName ,pBranch ,pBranchName ,pCountry ,paymentMethod ,
					collCurr ,tAmt ,cAmt ,pAmt ,payoutCurr ,relWithSender ,purposeOfRemit ,sourceOfFund ,tranStatus ,payStatus ,createdDate , 
					approvedDate, createdDateLocal ,createdBy ,tranType ,senderName ,receiverName, controlno2, ContNo
				)
				SELECT
					dbo.fnaEncryptString(@controlNumber), @exRate, 0, NULL, NULL, NULL, @sCharge, NULL, 'USD',
					@sSuperAgent, @sSuperAgentName, @sAgent, @sAgentName, @sBranch, @sBranchName, 'South Korea', @pSuperAgent, @pSuperAgentName,
					@pAgent, @pAgentName, @pBranch, @pBranchName, @receiverCountry, @paymentMethod,
					'KRW', (@cAmt - @sCharge), @cAmt, @pAmt, @pCurr, NULL, NULL, NULL, 'Payment', 'Post', @txnDate, 
					@txnDate, @txnDate, @user, 'R', @senderName, @receiverName, dbo.fnaEncryptString(@orderNumber), @sequenceNumber

				DECLARE @tempTranId BIGINT = @@IDENTITY

				INSERT INTO tranSenders
				( 
					tranId, customerId, firstName, fullName, country, idType, idNumber, nativeCountry, email, mobile
				)
				SELECT 
					@tempTranId, @customerId, @senderName, @senderName, @sCountry, @sIdTypeText, @sIdNumber, @sCountry, @sEmail, @sMobile

				INSERT  INTO tranReceivers
				( 
					tranId, firstName, fullName, country
				)
				SELECT 
					@tempTranId, @receiverName, @receiverName, @receiverCountry

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
			
			SELECT 0 ErrorCode,'Transaction has been sent successfully' Msg,NULL
			RETURN;
		END
	END;
END TRY
    BEGIN CATCH
        IF @@TRANCOUNT <> 0
            ROLLBACK TRANSACTION;
		
        DECLARE @errorMessage VARCHAR(MAX);
        SET @errorMessage = ERROR_MESSAGE();
	
        EXEC proc_errorHandler 1, @errorMessage, @user;
END CATCH;






GO
