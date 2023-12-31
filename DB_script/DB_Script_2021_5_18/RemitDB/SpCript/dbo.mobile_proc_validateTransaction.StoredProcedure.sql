USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_validateTransaction]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[mobile_proc_validateTransaction]
    (
      @flag VARCHAR(50) ,
      @user VARCHAR(100) ,
      @senderId VARCHAR(50) = NULL ,
      @sIpAddress VARCHAR(50) = NULL ,
      @benId VARCHAR(50) = NULL ,
      @rfName VARCHAR(100) = NULL ,
	  @sIdType VARCHAR(100) =NULL,
	  @sIdNo   VARCHAR(100) =NULL,
	  @sMobile VARCHAR(50) = NULL ,
      @rIdType VARCHAR(100) = NULL ,
      @rIdNo VARCHAR(50) = NULL ,
      @rIdValid DATETIME = NULL ,
      @rdob DATETIME = NULL ,
      @rTel VARCHAR(20) = NULL ,
      @rMobile VARCHAR(20) = NULL ,
      @rNaCountry VARCHAR(50) = NULL ,
      @rcity VARCHAR(100) = NULL ,
      @rAdd1 VARCHAR(150) = NULL ,
      @rEmail VARCHAR(100) = NULL ,
      @raccountNo VARCHAR(50) = NULL ,
      @pCountry VARCHAR(50) = NULL -- pay country
      ,@pCountryId INT = NULL -- PAY COUNTRY ID
      ,@deliveryMethod VARCHAR(50) = NULL -- payment mode
      ,@deliveryMethodId INT = NULL -- payment mode ID
      ,@pBank INT = NULL ,
      @pBankName VARCHAR(100) = NULL ,
      @pBankBranch INT = NULL ,
      @pBankBranchName VARCHAR(100) = NULL ,
      @pAgent INT = NULL ,
      @pAgentName VARCHAR(100) = NULL ,
      @pBranch INT = NULL ,
      @pBranchName VARCHAR(100) = NULL ,
      @pBankType CHAR(1) = NULL ,
      @pSuperAgent INT = NULL ,
      @pCurr VARCHAR(3) = NULL ,
      @collCurr VARCHAR(3) = NULL ,
      @cAmt MONEY = NULL ,
      @pAmt MONEY = NULL ,
      @tAmt MONEY = NULL ,
      @serviceCharge MONEY = NULL ,
      @discount MONEY = NULL ,
      @exRate FLOAT = NULL ,
      @purpose VARCHAR(150) = NULL ,
      @sourceOfFund VARCHAR(150) = NULL ,
      @relationship VARCHAR(100) = NULL ,
      @occupation VARCHAR(100) = NULL ,
      @payMsg VARCHAR(1000) = NULL ,
      @controlNo VARCHAR(20) = NULL ,
      @sCountryId INT = NULL ,
      @sCountry VARCHAR(100) = NULL ,
      @sBranch INT = NULL ,
      @sBranchName VARCHAR(100) = NULL ,
      @sAgent INT = NULL ,
      @sAgentName VARCHAR(100) = NULL ,
      @sSuperAgent INT = NULL ,
      @sSuperAgentName VARCHAR(100) = NULL ,
      @settlingAgent INT = NULL ,
      @branchMapCode VARCHAR(10) = NULL ,
      @agentMapCode VARCHAR(10) = NULL ,
      @collMode VARCHAR(50) = NULL ,
      @depositMode VARCHAR(50) = NULL  -- DEPOSIT MODE  CASH OR BANK 
      ,
      @calBy CHAR(1) = NULL ,
      @scDiscount MONEY = NULL ,
      @cardOnline VARCHAR(50) = NULL ,
      @memberShipId VARCHAR(50) = NULL ,
      @agentRefId VARCHAR(50) = NULL ,
      @couponCode VARCHAR(20) = NULL ,
      @schemeId INT = NULL ,
      @tranId VARCHAR(50) = NULL ,
      @ScOrderNo BIGINT = NULL ,
      @unitaryBankAccountNo VARCHAR(50) = NULL ,
      @RState VARCHAR(10) = NULL,
      @RStateText VARCHAR(150) = NULL,
      @RLocation VARCHAR(20) = NULL,
      @RLocationText VARCHAR(150) = NULL,
	  @VoucherXML XML=null,
	  @tpExRate money = null,
	  @tpPCurr varchar(10) = null,
	  @tpRefNo varchar(20) = null,
	  @tpTranId varchar(20) = null,
	  @tpAgentId int = null,
	  @payOutPartner BIGINT = NULL,
	  @FOREX_SESSION_ID		VARCHAR(40) = NULL,
	  @kftcLogId			BIGINT = NULL,
	  @paymentType			VARCHAR(20) = NULL,
	  @receiverId			VARCHAR(20) = NULL
    )
AS
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	SET @receiverId = @benId

	DECLARE @complianceRuleId INT, @cAmtUSD MONEY
		,@receiverName			VARCHAR(50)		= NULL
		,@complienceMessage		VARCHAR(1000)   =NULL 
		,@shortMsg				VARCHAR(100)    =NULL 
		,@complienceErrorCode	TINYINT			= NULL
		,@compErrorCode			INT 

	IF @paymentType IS NULL
		SET @paymentType = 'wallet'
    BEGIN TRY
        BEGIN
            DECLARE @sCurrCostRate FLOAT ,
                @sCurrHoMargin FLOAT ,
                @pCurrCostRate FLOAT ,
                @pCurrHoMargin FLOAT ,
                @sCurrAgentMargin FLOAT ,
                @pCurrAgentMargin FLOAT ,
                @sCurrSuperAgentMargin FLOAT ,
                @pCurrSuperAgentMargin FLOAT ,
				@customerRate FLOAT ,
                @sAgentSettRate FLOAT ,
                @pDateCostRate FLOAT ,
                @agentCrossSettRate FLOAT ,
                @treasuryTolerance FLOAT ,
                @customerPremium FLOAT ,
                @schemePremium FLOAT ,
                @sharingValue MONEY ,
                @sharingType CHAR(1) ,
                @sAgentComm MONEY ,
                @sAgentCommCurrency VARCHAR(3) ,
                @sSuperAgentComm MONEY ,
				@sSuperAgentCommCurrency VARCHAR(3) ,
                @pAgentComm MONEY ,
				@pAgentCommCurrency VARCHAR(3) ,
                @pCommissionType CHAR(1) ,
                @pSuperAgentComm MONEY ,
                @pSuperAgentCommCurrency VARCHAR(3) ,
                @pSuperAgentName VARCHAR(100)
		--,@pCountryId				INT
                ,
                @pStateId INT
		--,@deliveryMethodId		INT
                ,
                @senderName VARCHAR(100) ,
                @id INT ,
                @customerStatus VARCHAR(20) ,
                @idExpiryDate DATETIME,
				@limitBal MONEY
		
		
            DECLARE @rowId INT;
            DECLARE @scValue MONEY ,
                @exRateOffer MONEY ,
                @scAction VARCHAR(5) ,
                @AmountLimitPerTran MONEY ,
                @AmountLimitPerDay MONEY ,
                @todaysTotalSent MONEY ,
                @tranMinimum MONEY ,
                @tranMaximum MONEY 
		
            DECLARE @ad FLOAT;

            DECLARE @xAmt MONEY ,
                @sendingCustType INT ,
                @msg VARCHAR(MAX);
            DECLARE @iServiceCharge MONEY ,
                @iTAmt MONEY ,
                @iPAmt MONEY ,
                @iCAmt MONEY ,
                @iCustomerRate FLOAT 
            DECLARE @place INT ,
                @currDecimal INT;
	
            DECLARE @controlNoEncrypted VARCHAR(20);
            DECLARE @csMasterId INT ,
                @count INT ,
                @compFinalRes VARCHAR(20);
            DECLARE @GMTDate VARCHAR(50);
            DECLARE @createdDate DATETIME;
			DECLARE @SENDERS_IDENTITY_TYPE VARCHAR(50);
			DECLARE @errorCode CHAR(1)= 0 ,@agentAvlLimit MONEY;
            
            SET @GMTDate = GETDATE()
	
			SELECT @sAgent = sAgent, @sAgentName = sAgentName, @sBranch = sBranch, @sBranchName = sBranchName,
					@sSuperAgent = sSuperAgent, @sSuperAgentName = sSuperAgentName 
			FROM dbo.FNAGetBranchFullDetails(@sBranch)

			IF @pCountryId IS NULL
				SELECT @pCountryId = countryId FROM countryMaster (NOLOCK) WHERE countryName = @pCountry

			IF @pCountry LIKE '%?%'
				SELECT @pCountry = COUNTRYNAME FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYID = @pCountryId
	
		SELECT @sCountryId = 118,@sCountry = 'South Korea',@sAgentCommCurrency = 'KRW'

		SET @pBank = @pAgent
        SET @pAgent = null 

		IF @pCountryId in(151)
		BEGIN
			SET @pAgent = @payOutPartner
		END
		ELSE
		BEGIN
			SELECT TOP 1 @pAgent = AM.agentId
			FROM agentMaster AM(NOLOCK) 
			WHERE AM.parentId = @payOutPartner AND agentType=2903 AND AM.isSettlingAgent = 'Y' AND AM.isApiPartner = 1
		END

		IF @pBank = '2093' ----## IF VCBR AGENT
		SET @pAgent = 393229
		
		SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
				@pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
		FROM dbo.FNAGetBranchFullDetails(@pAgent)
		
		IF @receiverId IS NOT NULL
		BEGIN
			SELECT 
				@receiverName = ISNULL(RI.firstName,'')+ISNULL(' '+RI.middleName,'')+ISNULL(' '+RI.lastName1,'') +ISNULL(' '+RI.lastName2,'') 
			FROM dbo.receiverInformation(NOLOCK) AS RI 
			WHERE RI.receiverId=@receiverId
		END

		IF @rfName IS NULL AND @receiverId IS NULL
		BEGIN
			EXEC proc_errorHandler 1,'Receiver name cannot be empty', NULL;
            RETURN;
		END

		
		IF NOT EXISTS (SELECT '' FROM TblPartnerwiseCountry(NOLOCK) 
				WHERE AgentId = @payOutPartner AND CountryId = @pCountryId 
				AND ISNULL(PaymentMethod,@deliveryMethodId) = @deliveryMethodId and IsActive = 1
				)
		BEGIN
			PRINT 1
			EXEC proc_errorHandler  1,'Oops, something went wrong.Please perform the transaction again' ,null
			RETURN;
		END

		IF ISNULL(@tpExRate,0) = 0
		BEGIN		
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed.Partner Exchange Rate not defined', NULL
			RETURN
		END
		
		IF @pAgent IS NULL
		BEGIN
			EXEC proc_errorHandler  1,'Oops, something went wrong.Please perform the transaction again' ,null
			RETURN;
		END

		IF NOT EXISTS (SELECT 'X' FROM dbo.customerMaster(nolock) WHERE email = @user AND approvedDate IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1,'You are not authorized to perform transaction :(', NULL;
            RETURN;
		END

		IF ISNULL(@paymentType,'') NOT IN ('wallet', 'autodebit')
		BEGIN
			EXEC proc_errorHandler 1,'Invalid payment method.Please perform the transaction again!', NULL;
            RETURN;
		END

		SELECT  @SENDERS_IDENTITY_TYPE = CASE WHEN idType = '1302'THEN 'P' WHEN idType = '7316' THEN 'N' END ,
				@sIdNo = idNumber ,
				@senderName = isnull(fullName, firstname),
				@agentAvlLimit = dbo.FNAGetCustomerACBal(email)
		FROM    customerMaster	(NOLOCK)
		WHERE   customerId = @senderId; 

		IF @paymentType = 'wallet'
		BEGIN
			IF ISNULL(@agentAvlLimit, 1) < ISNULL(@cAmt, 0)
			BEGIN
				EXEC proc_errorHandler 1,'You donot have sufficient balance to do the transaction!', NULL;
				RETURN;
			END;
		END
		ELSE IF @paymentType = 'autodebit'
		BEGIN
			DECLARE @tranAmt MONEY = NULL
				
			SELECT @tranAmt = tranAmt 
			FROM KFTC_CUSTOMER_TRANSFER (NOLOCK) 
			WHERE rowId = @kftcLogId
				
			IF @tranAmt IS NULL
			BEGIN
				EXEC proc_errorHandler 1,'Invalid auto debit request.Please perform the transaction again!', NULL;
				RETURN;
			END

			IF @tranAmt <> @cAmt
			BEGIN
				EXEC proc_errorHandler 1,'Invalid transaction amount. Please contact GME Support!', NULL;
				RETURN;
			END
		END
		ELSE 
		BEGIN
			EXEC proc_errorHandler 1,'Invalid payment method.Please perform the transaction again!', NULL;
            RETURN;
		END

		IF @rfName IS NULL
        BEGIN
            EXEC proc_errorHandler 1,'Receiver full Name missing', NULL;
            RETURN;
        END;
		IF (select COUNT(1) from  dbo.Split(' ',@rfName))<2 AND @payOutPartner <> 224388
		BEGIN
			EXEC proc_errorHandler 1, 'Receiver full Name is missing', NULL
			RETURN
		END
		IF isnull(@rMobile, '')=''
		BEGIN
			EXEC proc_errorHandler 1, 'Receiver mobile number is required!', NULL
			RETURN
		END
		IF @rAdd1 IS NULL
        BEGIN
            EXEC proc_errorHandler 1,'Receiver Address missing', NULL;
            RETURN;
        END;
		IF ISNULL(@deliveryMethod, '') = ''
        BEGIN
            EXEC proc_errorHandler 1,'Please choose payment mode', NULL;
            RETURN;
        END;
		
        IF @serviceCharge IS NULL
        BEGIN
            EXEC proc_errorHandler 1, 'Service Charge missing',NULL;
            RETURN;
        END;
		IF ISNULL(@tAmt, 0) = 0
        BEGIN
            EXEC proc_errorHandler 1,'Transfer Amount missing', NULL;
            RETURN;
		END;
		IF ISNULL(@exRate, 0) = 0
        BEGIN
            EXEC proc_errorHandler 1, 'Exchange Rate missing',NULL;
            RETURN;
        END;
		if isnull(@purpose,'') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Purpose of Remittance is required!', NULL
			RETURN
		END
		if isnull(@sourceOfFund,'') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Source of Fund is required!', NULL
			RETURN
		END
        IF ISNULL(@cAmt, 0) = 0
        BEGIN
           EXEC proc_errorHandler 1,'Collection Amount is missing. Cannot send transaction',NULL;
            RETURN;	
        END; 
  
        IF @deliveryMethod = 'Bank Deposit'
        BEGIN   
			IF EXISTS(SELECT 'A' FROM AgentBankMapping(NOLOCK) WHERE bankId = @pBank AND @pcountryId = 151)
			BEGIN	
				SELECT @pAgent = bankpartnerId from AgentBankMapping(NOLOCK) WHERE bankId = @pBank
				SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
					@pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
				FROM dbo.FNAGetBranchFullDetails(@pAgent)
			END     
			                       
			IF NOT EXISTS(SELECT 'A' FROM agentMaster(nolock) where agentId = @pBank and agenttype = 2903 and IsIntl = 1)
			BEGIN	
				EXEC proc_errorHandler 1, 'Invalid bank selected', NULL
				return
			END	

				
			IF @pBank IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Please select bank', NULL
				RETURN
			END
			IF @pAgent IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Please select bank', NULL
				RETURN
			END
			IF @raccountNo IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Account number cannot be blank', NULL
				RETURN
			END
        END;
		
		IF @pCountryId = 36 ----## FOR CAMBODIA
		BEGIN
			SELECT @iServiceCharge = ISNULL(amount, -1) 
			FROM [dbo].FNAGetServiceCharge(
								@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
								@pCountryId, @pSuperAgent, @pAgent, NULL, 
								@deliveryMethodId, @pAmt, @collCurr
							) 
		END
		ELSE IF @pCountryId = 42 AND @pCurr = 'USD' and @deliveryMethodId = 2
		BEGIN
			SELECT  @iServiceCharge = amount
			FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
			@pCountryId,@pSuperAgent,@pAgent,NULL,@deliveryMethodId,@pAmt,'USD');
		END
		
		ELSE 
		BEGIN
			SELECT @iServiceCharge = ISNULL(amount, -1) 
			FROM [dbo].FNAGetServiceCharge(
								@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
								@pCountryId, @pSuperAgent, @pAgent, @pBranch, 
								@deliveryMethodId, @cAmt, @collCurr
							) 
		END
				
		IF @iServiceCharge = -1
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Service Charge is not defined', NULL
			RETURN
		END		
		IF isnull(@iServiceCharge,0) <> isnull(@serviceCharge,1)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Amount detail not match', NULL
			RETURN
		END 

		IF ISNULL(@serviceCharge,0) > @cAmt
        BEGIN
            SELECT  '1' ErrorCode ,'COLLECTION AMOUNT SHOULD BE MORE THAN SERVICE CHARGE' Msg ,NULL
            RETURN;
        END;


		SELECT  @iServiceCharge = @serviceCharge , @customerRate = @exRate;

		SELECT 
				--@customerRate			= round(@tpExRate/sAgentSettRate, 8)
				@customerRate			= customerRate
				,@sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
				,@sCurrAgentMargin		= sCurrAgentMargin
				,@pCurrCostRate			= @tpExRate
				,@pCurrHoMargin			= 0
				,@pCurrAgentMargin		= 0
				,@agentCrossSettRate	= round(@tpExRate/sAgentSettRate, 8)
				,@treasuryTolerance		= 0
				,@customerPremium		= 0
				,@sharingValue			= 0
				,@sharingType			= 0
			FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)
				
			--select @sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId
			
		IF @customerRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
			RETURN
		END
			
		SELECT 
			@customerRate			= customerRate
			,@sCurrCostRate			= sCurrCostRate
			,@sCurrHoMargin			= sCurrHoMargin
			,@sCurrAgentMargin		= sCurrAgentMargin
			,@pCurrCostRate			= pCurrCostRate
			,@pCurrHoMargin			= pCurrHoMargin
			,@pCurrAgentMargin		= pCurrAgentMargin
			,@agentCrossSettRate	= agentCrossSettRate
			,@treasuryTolerance		= treasuryTolerance
			,@customerPremium		= customerPremium
			,@sharingValue			= sharingValue
			,@sharingType			= sharingType
		FROM exRateCalcHistory(NOLOCK) 
		WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID AND USER_ID = @user

		IF @customerRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined.', NULL
			RETURN
		END

		IF ISNULL(@exRate,0) <> ISNULL(@customerRate,1)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again', NULL
			RETURN
		END
		
		DECLARE @scDisc MONEY

		SELECT @iCustomerRate = @exRate, @iTAmt = @cAmt - @iServiceCharge

		SELECT @place = place, @currDecimal = currDecimal
		FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
		AND currency = @pCurr AND (tranType IS NULL OR tranType = @deliveryMethodId)
		
		SET @currDecimal = ISNULL(@currDecimal, 0)
		SET @place = ISNULL(@place, 0)
			
		SET @iPAmt = ROUND(@iTAmt * @iCustomerRate, @currDecimal)

		IF @pCurr = 'USD'
				SET @iPAmt = ROUND(@iPAmt, @currDecimal)
		ELSE 
			SET @iPAmt = ROUND(@iPAmt, 0)

		IF @pCurr IN ('VND','IDR') AND ISNULL(@iPAmt,0) < ISNULL(@pAmt,1)+10
		BEGIN
			SET @iPAmt = @pAmt
		END

		IF ISNULL(@iPAmt,0) <> ISNULL(@pAmt,1)
		BEGIN
			declare @iMsg VARCHAR(500) = 'Amount detail not match. Please re-calculate the amount again.' + CAST(@iPAmt AS VARCHAR) + ' - ' +  CAST(@pAmt AS VARCHAR)
			EXEC proc_errorHandler 1, @iMsg, NULL
			RETURN
		END

		--OFAC Checking
		DECLARE @receiverOfacRes VARCHAR(MAX), @ofacRes VARCHAR(MAX), @ofacReason VARCHAR(200)
		EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @ofacRes OUTPUT
		EXEC proc_ofacTracker @flag = 't', @name = @receiverName, @Result = @receiverOfacRes OUTPUT
		
		DECLARE @result VARCHAR(MAX)
		IF ISNULL(@ofacRes, '') <> ''
		BEGIN
			SET @ofacReason = 'Matched by sender name'
		END
		IF ISNULL(@receiverOfacRes, '') <> ''
		BEGIN
			SET @ofacRes = ISNULL(@ofacRes + ',' + @receiverOfacRes, '' + @receiverOfacRes)
			SET @ofacReason = 'Matched by receiver name'
		END
		IF ISNULL(@ofacRes, '') <> '' AND ISNULL(@receiverOfacRes, '') <> ''
		BEGIN
			SET @ofacReason = 'Matched by both sender name and receiver name'
		END
		--Ofac Checking End
		SET @cAmtUSD = @cAmt / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))
		--Compliance Checking

		EXEC [proc_complianceRuleDetail]
			@flag			= 'receiver-limit'
			,@user			= @user
			,@sIdType		= @sIdType
			,@sIdNo			= @sIdNo
			,@receiverName  = @rfName
			,@cAmt			= @cAmt
			,@cAmtUSD		= @cAmtUSD
			,@customerId	= @senderId
			,@receiverMobile= @rMobile
			,@pCountryId	= @pCountryId
			,@deliveryMethod= @deliveryMethodId
			,@message		= @complienceMessage OUTPUT
			,@shortMessage  = @shortMsg    OUTPUT
			,@errCode		= @complienceErrorCode OUTPUT
			,@ruleId		= @complianceRuleId  OUTPUT
   
		IF(@complienceErrorCode <> 0)
		BEGIN  
			IF(@complienceErrorCode = 1)
			BEGIN
				SET @compErrorCode=101
				--SELECT 101 errorCode,@msg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
			END 
			ELSE 
			BEGIN
				SET @compErrorCode=102
				INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
				SELECT @complianceRuleId, NULL, @agentRefId

				--SELECT 102 errorCode,@msg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
			END
				
			INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName
			, receiverCountry,payOutAmt,complianceId,complianceReason,complainceDetailMessage,createdBy,createdDate,logType)

			SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName
			, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),'online'
		END	   
			
		IF @complienceErrorCode = 1
		BEGIN
			EXEC proc_errorHandler 1, @complienceMessage, NULL
			RETURN;
		END;

		--Compliance checking end

		select @pAgentCommCurrency = 'USD'
		select 
			@pAgentComm = (SELECT amount FROM dbo.[FNAGetPayComm](
				@sAgent,@sCountryId,NULL, NULL, @pCountryId
			, null, @pAgent, @pAgentCommCurrency,@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL)
			)

		DECLARE @agentFxGain MONEY;

		DECLARE @remitTranTemp TABLE (
						tranId BIGINT,controlNo VARCHAR(20),cAmt MONEY,receiverName VARCHAR(200) ,
						receiverIdType VARCHAR(100),receiverIdNumber VARCHAR(50),dot DATETIME
					);
		DECLARE @moneySendTemp TABLE(
						tranNo BIGINT ,refno VARCHAR(20) ,paidAmt MONEY ,receiverName VARCHAR(200) ,
						receiverIdDescription VARCHAR(100) ,receiverIdDetail VARCHAR(50)
					);

		INSERT INTO @remitTranTemp( tranId ,controlNo ,cAmt ,receiverName ,receiverIdType ,receiverIdNumber ,dot )
		SELECT  rt.id ,rt.controlNo ,rt.cAmt ,rt.receiverName ,rec.idType ,rec.idNumber ,rt.createdDateLocal
		FROM vwRemitTran rt WITH ( NOLOCK )
		INNER JOIN vwTranSenders sen WITH ( NOLOCK ) ON rt.id = sen.tranId
		INNER JOIN vwTranReceivers rec WITH ( NOLOCK ) ON rt.id = rec.tranId
		WHERE sen.customerId = @senderId
		AND ( rt.approvedDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101)+ ' 23:59:59'
				OR ( approvedBy IS NULL AND cancelApprovedBy IS NULL )
			);
		
		IF EXISTS ( SELECT  'X' FROM @remitTranTemp
					WHERE   cAmt = @cAmt
					AND ( receiverName = @rfName ) AND DATEDIFF(MI, dot, GETDATE()) <= 2 
					)
		BEGIN
			EXEC proc_errorHandler 1,'Similar transaction found', NULL;
			RETURN;
		END;
		
		IF @user = 'demo.gme@gmeremit.com'
		BEGIN
			EXEC proc_errorHandler 1,'You can not send money through test GME acocunt :(', NULL;
			RETURN;
		END

		SELECT 0 ErrorCode,'Transaction is valid' Msg, @id id, null extra;

		RETURN 
		
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
