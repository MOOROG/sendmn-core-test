USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_Online_sendTxnTP]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_Online_sendTxnTP]
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
	  @paymentType			VARCHAR(20) = NULL
    )
AS
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	IF @paymentType IS NULL
		set @paymentType ='wallet'

	IF @paymentType='autodebit'
	BEGIN
		DECLARE @DATE DATETIME, @NextDate datetime
		select @DATE = CAST(GETDATE() AS DATE)
		SELECT @NextDate = DATEADD(DAY,1,@DATE)

		SELECT @DATE = @DATE+' 23:20:00',@NextDate = @NextDate+' 00:40:00'

		IF GETDATE() BETWEEN @DATE AND @NextDate
		BEGIN
			SELECT  '1' ErrorCode ,'KFTC service is not available between 11:30 PM to 12:30 AM' Msg ,NULL ID
			RETURN
		END
	END

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
            
            SET @GMTDate = dbo.FNAGMTOnline(GETDATE(), @user);
	
			SELECT @sAgent = sAgent, @sAgentName = sAgentName, @sBranch = sBranch, @sBranchName = sBranchName,
					@sSuperAgent = sSuperAgent, @sSuperAgentName = sSuperAgentName 
			FROM dbo.FNAGetBranchFullDetails(@sBranch)

			IF @pCountryId IS NULL
				SELECT @pCountryId = countryId FROM countryMaster (NOLOCK) WHERE countryName = @pCountry

			IF @pCountry LIKE '%?%'
				SELECT @pCountry = COUNTRYNAME FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYID = @pCountryId
	
		SET @sCountryId = 118
		SET @sCountry = 'South Korea'
		SET @sAgentCommCurrency = 'KRW'
		
		SELECT  @pBank = @pAgent,
			    @pBankName = @pAgentName,
			    @pBankBranch = @pBranch ,
				@pBankBranchName = CASE WHEN @pBranchName IS NULL THEN (SELECT agentName FROM agentMaster(NOLOCK) WHERE agentId = @pBranch) ELSE @pBranchName END;
        SELECT  @pAgent = null ,@pAgentName = NULL ,@pBranch = NULL ,@pBranchName = NULL;

		SELECT TOP 1 @pAgent = AM.agentId
			FROM agentMaster AM(NOLOCK) 
			WHERE AM.parentId = @payOutPartner AND agentType=2903 AND AM.isSettlingAgent = 'Y' AND AM.isApiPartner = 1
		
		SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
				   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
			FROM dbo.FNAGetBranchFullDetails(@pAgent)

        IF @flag = 'exRate'			--Get Exchange Rate, Service Charge, Scheme/Offer and amount details
        BEGIN
            SELECT TOP 1
                    @senderId = customerId ,
                    @idExpiryDate = idExpiryDate ,
					@createdDate = createdDate,
					@sIdNo		 = idNumber,
					@sIdType	 = idType,
					@agentAvlLimit = dbo.FNAGetCustomerACBal(@user),
					@customerStatus = CASE WHEN customerStatus IS NULL THEN 'pending' ELSE 'verified' END,
					@todaysTotalSent = ISNULL(todaysSent, 0)
            FROM customerMaster WITH ( NOLOCK ) WHERE email = @user;		
			
			

            SELECT @sIdType = detailTitle FROM staticDataValue(NOLOCK) WHERE valueId = @sIdType

			SELECT  @scValue = 0 ,
                    @exRateOffer = 0 ,
                    @scDiscount = 0 ,
                    @AmountLimitPerTran = 3000,
					@AmountLimitPerDay = 20000
			
            IF ( @idExpiryDate < GETDATE()  AND @sIdType <> 'National ID')
            BEGIN
                SELECT  '1' ErrorCode ,
                        'Your provided photo id has been expired. Please contact GME Support Team by writing email to support@gmeremit.com or call on +44 (0) 20 8861 2264.' Msg ,
                        amountLimitPerDay = @AmountLimitPerDay ,
                        customerTotalSentAmt = @todaysTotalSent ,
                        maxAmountLimitPerTran = @tranMaximum ,
                        PerTxnMinimumAmt = @tranMinimum;             
               RETURN;
            END;					
			
			SELECT  @place = place ,
				@currDecimal = currDecimal
			FROM  currencyPayoutRound(NOLOCK)
			WHERE ISNULL(isDeleted, 'N') = 'N'
			AND currency = @pCurr AND tranType IS NULL;

			SET @currDecimal = ISNULL(@currDecimal,0)

            IF @pCurr IS NULL
            BEGIN
					SELECT  '1' ErrorCode ,
                            'Currency not been defined yet for receiving country' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = @todaysTotalSent ,
                            maxAmountLimitPerTran = @tranMaximum ,
                            PerTxnMinimumAmt = @tranMinimum;
                    RETURN;
			END;
			
			SELECT 
				@sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
				,@sAgentSettRate = sAgentSettRate 
			FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

			IF ISNULL(@sAgentSettRate, 0) = 0
			BEGIN
				SELECT  '1' ErrorCode ,
                            'Exchange rate not defined yet for sending currency (' + @collCurr + ')' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = @todaysTotalSent ,
                            maxAmountLimitPerTran = @tranMaximum ,
                            PerTxnMinimumAmt = @tranMinimum;
				RETURN
			END

			IF ISNULL(@tpExRate, 0) = 0
			BEGIN
				SELECT  '1' ErrorCode ,
                            'Third Party Exchange rate fetching error for currency (' + @pCurr + ')' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = @todaysTotalSent ,
                            maxAmountLimitPerTran = @tranMaximum ,
                            PerTxnMinimumAmt = @tranMinimum;
				RETURN
			END

			SELECT @exRate = round(@tpExRate/@sAgentSettRate, 8)

			--SELECT  @exRate = 
			--	dbo.FNAGetCustomerRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent, @pCurr,@deliveryMethod);
            IF @exRate IS NULL
            BEGIN
                    SELECT  '1' ErrorCode ,
                            'Exchange rate not defined yet for receiving currency ('+ @pCurr + ')' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = @todaysTotalSent ,
                            maxAmountLimitPerTran = @tranMaximum ,
                            PerTxnMinimumAmt = @tranMinimum;
                    RETURN;
            END;
			
            IF @calBy = 'C'
            BEGIN
                    SELECT  @serviceCharge = amount
                    FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
                    @pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,@cAmt,@collCurr);

                    IF @serviceCharge IS NULL
                    BEGIN
                            SELECT  '1' ErrorCode ,
                                    'Service charge not defined yet for receiving country' Msg ,
									amountLimitPerDay = @AmountLimitPerDay ,
                                    customerTotalSentAmt = @todaysTotalSent ,
                                    maxAmountLimitPerTran = @tranMaximum ,
                                    PerTxnMinimumAmt = @tranMinimum;
                            RETURN;
                    END;
		
                    SET @tAmt = @cAmt - @serviceCharge+ @scDiscount;
				
                   SET @pAmt = ( @cAmt - @serviceCharge+ @scDiscount ) * ( @exRate+ @exRateOffer );
							
					SET @pAmt = ROUND(@pAmt,0)
            END;
            ELSE
            IF @calBy = 'P'
			BEGIN
				SET @tAmt = @pAmt / ( @exRate+ @exRateOffer );
				SELECT  @serviceCharge = amount
				FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
											@pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,
											@tAmt, @collCurr);

				IF @serviceCharge IS NULL
				BEGIN
					SELECT  '1' ErrorCode ,
							'Service charge not defined yet for receiving country' Msg ,
							amountLimitPerDay = @AmountLimitPerDay ,
							customerTotalSentAmt = @todaysTotalSent ,
							maxAmountLimitPerTran = @tranMaximum ,
							PerTxnMinimumAmt = @tranMinimum;
					RETURN;
				END;
			
				SET @tAmt = ROUND(@tAmt, 2);
				SET @cAmt = ( @tAmt + @serviceCharge - @scDiscount );
								
				SET @cAmt = ROUND(@cAmt, 0);	
										
			END;
			
            IF @serviceCharge > @cAmt
            BEGIN
                SELECT  '1' ErrorCode ,
                        'COLLECTION AMOUNT SHOULD BE MORE THAN SERVICE CHARGE' Msg ,
                        amountLimitPerDay = @AmountLimitPerDay ,
                        customerTotalSentAmt = @todaysTotalSent ,
                        maxAmountLimitPerTran = @tranMaximum ,
                        PerTxnMinimumAmt = @tranMinimum;
                RETURN;
            END;
			
			--4. Validate Country Sending Limit 
			EXEC PROC_CHECKCOUNTRYLIMIT @flag = 's-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
				,@deliveryMethod = @deliveryMethod,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
				,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
				,@msg = @msg OUT, @errorCode = @errorCode OUT

			IF @errorCode <> '0'
			BEGIN
				SELECT @errorCode ErrorCode, @msg Msg,null Id,null vtype
				RETURN;
			END
			--Validate Country Sending Limit END

			--5. Validate Country Receiving Limit
			EXEC PROC_CHECKCOUNTRYLIMIT @flag = 'r-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
				,@deliveryMethod = @deliveryMethod,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
				,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
				,@msg = @msg OUT, @errorCode = @errorCode OUT
			
			IF @errorCode <> '0'
			BEGIN
				SELECT @errorCode ErrorCode, @msg Msg,null Id,null vtype
				RETURN;
			END
			--Validate Country Receiving Limit
			SET @msg = 'Success';
			IF ISNULL(@paymentType,'wallet') = 'wallet'
			BEGIN
				IF ISNULL(@agentAvlLimit, 1) < ISNULL(@cAmt, 0)
				BEGIN
					SELECT  '1' ErrorCode
						,'You donot have sufficient balance to do the transaction' Msg ,
						amountLimitPerDay = @AmountLimitPerDay ,
						customerTotalSentAmt = @todaysTotalSent ,
						maxAmountLimitPerTran = @tranMaximum ,
						PerTxnMinimumAmt = @tranMinimum;
					RETURN;
				END;
			END
			---------Validation Begin--------------------------------
			
				--SELECT * FROM @csMasterRec RETURN
			DECLARE @complianceRuleId INT, @cAmtUSD MONEY
  
			--SELECT 
			--	@sCurrCostRate			= sCurrCostRate
			--	,@sCurrHoMargin			= sCurrHoMargin
			--FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

			IF @sCurrCostRate IS NULL
			BEGIN
				SELECT @errorCode = '1', @msg = 'Transaction cannot be proceed. Exchange Rate not defined!'
				RETURN
			END
			
			SET @cAmtUSD = @cAmt / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))
  
			DECLARE 
				@receiverName		VARCHAR(50)		= NULL
				,@complienceMessage varchar(1000)    =NULL 
				,@shortMsg          varchar(100)     =NULL 
				,@complienceErrorCode TINYINT		 = NULL
	
			EXEC [proc_complianceRuleDetail]
				 @flag			= 'sender-limit'
				,@user			= @user
				,@sIdType		= @sIdType
				,@sIdNo			= @sIdNo
				,@receiverName  = @rfName
				,@cAmt			= @cAmt
				,@cAmtUSD		= @cAmtUSD
				,@customerId	= @senderId
				,@pCountryId	= @pCountryId
				,@deliveryMethod= @deliveryMethod
				,@message		= @complienceMessage OUTPUT
				,@shortMessage  = @shortMsg    OUTPUT
				,@errCode		= @complienceErrorCode OUTPUT
				,@ruleId		= @complianceRuleId  OUTPUT
   
			DECLARE @compErrorCode INT 
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
			
			----------Validation End---------------------------------	
			IF @complienceErrorCode = '1'
			BEGIN
				SELECT  @compErrorCode ErrorCode ,
					@complienceErrorCode Id ,
					@shortMsg Msg ,
					'' vtype ,
					amountLimitPerDay = @AmountLimitPerDay ,
					customerTotalSentAmt = @todaysTotalSent ,
					maxAmountLimitPerTran = @tranMaximum ,
					PerTxnMinimumAmt = @tranMinimum;
				RETURN;
			END;
			IF ISNULL(@paymentType,'wallet') = 'wallet'
			BEGIN
				IF EXISTS (SELECT 'X' FROM dbo.customerMaster(nolock) WHERE email=@user)
				BEGIN
					SELECT @agentAvlLimit = [dbo].FNAGetCustomerACBal(@user);
                    
					SET @agentAvlLimit = ISNULL(@agentAvlLimit, 0);
			
					IF ISNULL(@agentAvlLimit, 0) < ISNULL(@cAmt, 0)
					BEGIN
			
							SELECT  '1' ErrorCode
									,'You donot have sufficient balance to do the transaction' Msg ,
									amountLimitPerDay = @AmountLimitPerDay ,
									customerTotalSentAmt = @todaysTotalSent ,
									maxAmountLimitPerTran = @tranMaximum ,
									PerTxnMinimumAmt = @tranMinimum;
							RETURN;
					END;
				END
			END
			SET @FOREX_SESSION_ID = NEWID()

			----## lock ex rate for individual txn
			INSERT INTO exRateCalcHistory (
				CUSTOMER_ID,[USER_ID],FOREX_SESSION_ID,serviceCharge,pAmt,customerRate,sCurrCostRate,sCurrHoMargin		
				,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,agentCrossSettRate,createdDate,isExpired,tAmt
			)
			SELECT	@senderId,@user,@FOREX_SESSION_ID,@serviceCharge,@pAmt,@exRate,@sCurrCostRate,@sCurrHoMargin		
				,@sCurrAgentMargin,@tpExRate,0,0,@exRate,GETDATE(),0,@tAmt

			--SELECT
			--@senderId,@user,@FOREX_SESSION_ID,@serviceCharge,@pAmt,@exRate,@sCurrCostRate,@sCurrHoMargin		
			--,@sCurrAgentMargin,@pCurrCostRate,@pCurrHoMargin,@pCurrAgentMargin	,@agentCrossSettRate,@treasuryTolerance	,@customerPremium	
			--,@sharingValue,@sharingType,GETDATE(),0
			
			--Bank compare
			--DECLARE @bankName VARCHAR(25) = 'Bank', @bankRate MONEY, @bankPayout MONEY, @bankFee MONEY
			--, @bankSave MONEY, @bankTransafer MONEY

			--SELECT @bankRate = customerRate, @bankFee = serviceCharge FROM bankTransferSettings(NOLOCK)

			--SELECT @bankTransafer = @cAmt - @bankFee
			--SELECT @bankPayout = @bankTransafer * @bankRate
			--SELECT @bankSave = @pAmt - @bankPayout

            SELECT  ErrorCode = @errorCode ,
                    Msg = @msg ,
					Id = NULL,
                    scCharge = @serviceCharge ,
                    exRateDisplay = ROUND(@exRate , 4, -1),
					exRate = @exRate,
                    place = @place ,
                    pCurr = @pCurr ,
                    currDecimal = @currDecimal ,
					pAmt = @pAmt ,
                    sAmt = ROUND(@tAmt, 0) ,
                    disc = 0.00 ,
					--bank data
					bankTransafer = 0.00,
					bankPayout = 0.00,
					bankRate = 0.00,
					bankFee = 0.00,
					bankSave = 0.00,
					bankName = 0.00,

                    collAmt = @cAmt ,
					collCurr = @collCurr,
                    exRateOffer = @exRateOffer ,
                    scOffer = @scDiscount ,
                    scAction = @scAction ,
                    scValue = @scValue ,
                    scDiscount = @scDiscount ,
                    amountLimitPerTran = @AmountLimitPerTran ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = ISNULL(@todaysTotalSent,0) ,
					minAmountLimitPerTran = @tranMinimum ,
                    maxAmountLimitPerTran = @tranMaximum ,
					PerTxnMinimumAmt = '',
					tpExRate = @tpExRate,
					tpPCurr = @tpPCurr, 
                    schemeAppliedMsg = '',
                    schemeId = @schemeId,
					EXRATEID = @FOREX_SESSION_ID
		
			
        END
		ELSE IF @flag = 'i'
		BEGIN		
			IF @user = 'demo.gme@gmeremit.com'
			BEGIN
				EXEC proc_errorHandler 1,'You can not send money through test GME acocunt :(', NULL;
                RETURN;
			END

			IF NOT EXISTS (SELECT '' FROM TblPartnerwiseCountry(NOLOCK) 
					WHERE AgentId = @payOutPartner AND CountryId = @pCountryId 
					AND ISNULL(PaymentMethod,@deliveryMethodId) = @deliveryMethodId and IsActive = 1
					)
			BEGIN
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
					@agentAvlLimit = dbo.FNAGetCustomerACBal(@user)
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
            
			SET @controlNo = '80' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 9);
            SELECT  @controlNoEncrypted = dbo.FNAEncryptString(@controlNo);
			
            IF EXISTS (SELECT 'X' FROM pinQueueList WITH(NOLOCK) WHERE icn = @controlNoEncrypted) 
            BEGIN
				SET @controlNo = '80' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 9);
				SELECT  @controlNoEncrypted = dbo.FNAEncryptString(@controlNo);

				IF EXISTS(SELECT 'X' FROM pinQueueList WITH(NOLOCK) WHERE icn = @controlNoEncrypted) 
				BEGIN
					EXEC proc_errorHandler 1, 'Technical error occurred. Please try again',NULL;
					RETURN;
				END
            END;

            IF @deliveryMethod = 'Bank Deposit'
            BEGIN                               
				IF NOT EXISTS(SELECT 'A' FROM agentMaster(nolock) where agentId = @pBank and agenttype =2903 and IsIntl = 1)
				BEGIN	
					EXEC proc_errorHandler 1, 'Invalid bank selected', NULL
					return
				END	
				
				IF @pBank IS NULL
				BEGIN
					EXEC proc_errorHandler 1, 'Please select bank', NULL
					RETURN
				END
				IF @pBankBranch IS NULL
				BEGIN
					EXEC proc_errorHandler 1, 'Please select bank Branch', NULL
					RETURN
				END
				IF @raccountNo IS NULL
				BEGIN
					EXEC proc_errorHandler 1, 'Account number cannot be blank', NULL
					RETURN
				END
				--if @pCountryId = 169 and len(@raccountNo) = 24
				--begin
				--	exec proc_errorHandler  1,'Please enter valid IBAN Number' ,null
				--	RETURN;
				--end	
            END;

			SELECT 
				@iServiceCharge = ISNULL(amount, -1) 
			FROM [dbo].FNAGetServiceCharge(
								@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
								@pCountryId, @pSuperAgent, @pAgent, @pBranch, 
								@deliveryMethodId, @cAmt, @collCurr
							) 
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
			AND currency = @pCurr AND tranType IS NULL
		
			SET @currDecimal = ISNULL(@currDecimal, 0)
			SET @place = ISNULL(@place, 0)
		
			SET @iPAmt = ROUND(@iTAmt * @iCustomerRate, 0)

			IF @pCurr = 'USD'
				SET @iPAmt = ROUND(@iPAmt, @currDecimal)
			ELSE 
				SET @iPAmt = ROUND(@iPAmt, 0)

			IF @pCurr = 'IDR' AND ISNULL(@iPAmt,0) < ISNULL(@pAmt,1)+10
			BEGIN
				SET @pAmt = ISNULL(@iPAmt,0)
			END
			IF @pCurr = 'MMK' AND ISNULL(@iPAmt,0) < ISNULL(@pAmt,1)+5
			BEGIN
				SET @pAmt = ISNULL(@iPAmt,0)
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
				@pAgentComm = (SELECT amount FROM [FNAGetPayComm](
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
		
		-- #########country and occupation  risk point
			DECLARE @countryRisk INT ,@OccupationRisk INT ,@isFirstTran CHAR(1);
		
			BEGIN TRANSACTION;
				
				IF EXISTS ( SELECT sno FROM dbo.customerTxnLimit WITH ( NOLOCK )
									WHERE customer_passport = @sIdNo AND customer_id_type = @SENDERS_IDENTITY_TYPE )
				BEGIN
					UPDATE  dbo.customerTxnLimit
					SET     paidAmt = ISNULL(paidAmt, 0) + @cAmt ,
							nos_of_txn = ISNULL(nos_of_txn, 0) + 1 ,
							update_ts = GETDATE()
					WHERE   customer_passport = @sIdNo AND customer_id_type = @SENDERS_IDENTITY_TYPE;
				END;
				ELSE
				BEGIN
					INSERT customerTxnLimit(customer_passport,paidAmt,trans_date,agent_id,update_ts,nos_of_txn,customer_name,customer_id_type )
							SELECT  ISNULL(@sIdNo, '-') , @cAmt ,
									CONVERT(VARCHAR, GETDATE(), 101) ,'10100000' ,GETDATE(),1,@senderName ,@SENDERS_IDENTITY_TYPE;   
				END;
				INSERT  INTO remitTranTempOnline
				( 
					controlNo ,sCurrCostRate ,sCurrHoMargin ,sCurrSuperAgentMargin ,sCurrAgentMargin ,pCurrCostRate ,pCurrHoMargin ,pCurrSuperAgentMargin ,
					pCurrAgentMargin ,agentCrossSettRate ,customerRate ,sAgentSettRate ,pDateCostRate ,treasuryTolerance ,customerPremium ,schemePremium ,sharingValue ,
					sharingType ,serviceCharge ,handlingFee ,agentFxGain ,sAgentComm ,sAgentCommCurrency ,sSuperAgentComm ,sSuperAgentCommCurrency ,pAgentComm ,pAgentCommCurrency ,
					pCommissionType ,pSuperAgentComm ,pSuperAgentCommCurrency ,promotionCode ,pMessage ,sSuperAgent ,sSuperAgentName ,sAgent ,sAgentName ,sBranch ,
					sBranchName ,sCountry ,pSuperAgent ,pSuperAgentName ,pAgent ,pAgentName ,pBranch ,pBranchName ,pCountry ,paymentMethod ,pBank ,pBankName ,pBankBranch ,pBankBranchName ,
					accountNo ,pBankType ,expectedPayoutAgent ,collMode ,collCurr ,tAmt ,cAmt ,pAmt ,payoutCurr ,relWithSender ,purposeOfRemit ,sourceOfFund ,tranStatus ,payStatus ,createdDate ,
					createdDateLocal ,createdBy ,tranType ,senderName ,receiverName ,calBy ,isOnlineTxn ,schemeId ,ScOrderNo ,UnitaryBankAccountNo,pState,pDistrict,
					sRouteId
				)
				SELECT 
					@controlNoEncrypted ,@sCurrCostRate ,@sCurrHoMargin ,@sCurrSuperAgentMargin ,@sCurrAgentMargin ,@pCurrCostRate ,@pCurrHoMargin ,@pCurrSuperAgentMargin ,
					@pCurrAgentMargin ,@agentCrossSettRate ,@customerRate ,@sAgentSettRate ,@pDateCostRate ,@treasuryTolerance ,@customerPremium ,ISNULL(@schemePremium, 0) ,
					@sharingValue , @sharingType , @serviceCharge ,ISNULL(@scDiscount, 0) ,@agentFxGain ,@sAgentComm ,@sAgentCommCurrency ,@sSuperAgentComm ,@sSuperAgentCommCurrency ,@pAgentComm ,@pAgentCommCurrency ,
					@pCommissionType , @pSuperAgentComm ,@pSuperAgentCommCurrency ,@agentRefId ,@payMsg ,@sSuperAgent , @sSuperAgentName ,@sAgent ,@sAgentName ,@sBranch ,@sBranchName ,@sCountry , @pSuperAgent ,
					@pSuperAgentName , @pAgent , @pAgentName , @pBranch ,@pBranchName ,@pCountry ,@deliveryMethod ,@pBank , @pBankName ,@pBankBranch ,@pBankBranchName ,@raccountNo ,@pBankType , @pAgentName ,@collMode , @collCurr ,@tAmt , @cAmt ,
					@pAmt , @pCurr , @relationship , @purpose ,@sourceOfFund ,'Hold' ,'Unpaid' ,@GMTDate ,
					GETDATE() , @user ,ISNULL(@pBankType,'O') , @senderName , @rfName ,@calBy , 'Y' ,@schemeId ,@ScOrderNo ,@unitaryBankAccountNo,@RLocation,@RState,
					CASE WHEN @paymentType = 'wallet' THEN 'w' WHEN @paymentType = 'autodebit' THEN 'a' END
				
				SET @id = SCOPE_IDENTITY();	

				INSERT  INTO tranSendersTempOnline
						( tranId , customerId ,membershipId ,firstName , middleName ,lastName1 ,lastName2 ,
							fullName ,country ,[address] ,address2 ,[state] ,zipCode ,city ,email ,homePhone ,
							workPhone ,mobile ,nativeCountry ,dob ,placeOfIssue ,idType ,idNumber ,idPlaceOfIssue ,
							issuedDate ,validDate ,occupation ,countryRiskPoint ,customerRiskPoint ,isFirstTran ,
							ipAddress
						)
				SELECT TOP 1
						@id ,@senderId ,membershipId ,firstName ,middleName ,lastName1 ,lastName2 ,
						@senderName ,sc.countryName ,[address] ,address2 ,ss.stateName ,zipCode ,city ,email ,homePhone ,
						workPhone ,LEFT(mobile, 15) ,nativeCountry = nc.countryName ,dob ,c.placeOfIssue ,sdv.detailTitle ,c.idNumber ,c.placeOfIssue ,
						c.idIssueDate ,c.idExpiryDate ,om.detailTitle ,@countryRisk ,( @countryRisk + @OccupationRisk ) ,@isFirstTran ,
						@sIpAddress
				FROM    dbo.customerMaster c WITH ( NOLOCK ) 
						LEFT JOIN countryMaster sc WITH ( NOLOCK ) ON c.country = sc.countryId
						LEFT JOIN countryMaster nc WITH ( NOLOCK ) ON c.nativeCountry = nc.countryId
						LEFT JOIN countryStateMaster ss WITH ( NOLOCK ) ON c.state = ss.stateId
						LEFT JOIN staticDataValue sdv WITH ( NOLOCK ) ON c.idType = sdv.valueId
						LEFT JOIN occupationMaster om WITH ( NOLOCK ) ON c.occupation = om.occupationId
				WHERE   c.customerId = @senderId;

				DECLARE @fName VARCHAR(100) ,
						@mName VARCHAR(100) ,
						@lName VARCHAR(100) ,
						@lName2 VARCHAR(100);
			
				SELECT  @fName =firstName,
						@mName =middleName,
						@lName =lastName1,
						@lName2 =lastName2
				FROM    dbo.FNASplitName(@rfName);

				DECLARE @firstName        VARCHAR(100)  
				DECLARE @midName		  VARCHAR(100)
				DECLARE @lastName		  VARCHAR(100)
				DECLARE @lastName2	  	  VARCHAR(100)
				DECLARE @payCountry	      VARCHAR(100)
				DECLARE @recAdd1		  VARCHAR(100)
				DECLARE @reccity		  VARCHAR(100)
				DECLARE @recEmail	  	  VARCHAR(100)
				DECLARE @recTel		      VARCHAR(100)
				DECLARE @recMobile		  VARCHAR(100)
				DECLARE @recRelationship  VARCHAR(100)
				DECLARE @recState	  	  VARCHAR(100)
				declare @recDistrict	  VARCHAR(100)

				IF @benId IS NULL
				BEGIN
					IF NOT EXISTS ( SELECT  'X'
									FROM    receiverInformation
									WHERE   ISNULL(firstName, '') = ISNULL(@fName, '')
											AND ISNULL(middleName, '') = ISNULL(@mName, '')
											AND ISNULL(lastName1, '') = ISNULL(@lName, '')
											AND ISNULL(lastName2, '') = ISNULL(@lName2, '')
											AND customerId = @senderId )
					BEGIN				 
						INSERT  INTO receiverInformation
							( customerId ,firstName ,middleName ,lastName1 ,lastName2 ,country ,address ,city ,email ,
								homePhone ,workPhone ,mobile ,relationship,state,district
							)
						SELECT  
								@senderId ,firstName ,middleName ,lastName1 ,lastName2 ,@pCountry ,@rAdd1 ,@rCity ,@rEmail ,
								@rTel ,@rTel ,@rMobile ,@relationship,@RLocationText,@RStateText
						FROM    dbo.FNASplitName(@rfName);
					
						SET @benId = @@IDENTITY;
					END;
					ELSE
						BEGIN
							SELECT TOP 1
									@benId = receiverId
							FROM    receiverInformation
							WHERE   ISNULL(firstName, '') = @fName
									AND ISNULL(middleName, '') = @mName
									AND ISNULL(lastName1, '') = @lName
									AND ISNULL(lastName2, '') = @lName2
									AND customerId = @senderId; 
					END;
				END;
				IF @benId IS NOT NULL
				BEGIN
					SELECT   @firstName			=firstName 
							,@midName			=middleName
							,@lastName			=lastName1
							,@lastName2			=lastName2
							,@payCountry		=country
							,@recAdd1			=address
							,@reccity			=city
							,@recEmail			=email
							,@recTel			=homePhone
							,@recMobile			=mobile
							,@recRelationship	=relationship
							,@recState			=state
							,@recDistrict		=district
							FROM dbo.receiverInformation
					WHERE receiverId	= @benId
					UPDATE dbo.receiverInformation
					SET   firstName             =ISNULL( @fName, @firstName) 
							, middleName 		=ISNULL( @mName, @midName)
							, lastName1 		=ISNULL( @lName, @lastName)
							, lastName2 		=ISNULL( @lName2, @lastName2)
							, country 			=ISNULL( @pCountry, @payCountry)
							, address 			=ISNULL( @rAdd1, @recAdd1)
							, city 				=ISNULL( @rCity, @reccity)
							, state				=ISNULL( @RLocationText, @recState)
							, district			=ISNULL(@RStateText, @recDistrict)
							, email 			=ISNULL( @rEmail, @recEmail)
							, homePhone 		=ISNULL( @rTel, @recTel)
							, workPhone 		=ISNULL( @rTel, @recTel)
							, mobile 			=ISNULL( @rMobile, @recMobile)
							, relationship		=ISNULL( @relationship, @recRelationship)
					WHERE receiverId	= @benId
				END		
				INSERT INTO tranReceiversTempOnline( tranId ,customerId ,membershipId ,firstName ,middleName ,lastName1 ,lastName2 ,fullName ,
					country ,[address] ,[state] ,district ,zipCode ,city ,email ,homePhone ,workPhone ,mobile ,nativeCountry ,dob ,
					placeOfIssue ,idType ,idNumber ,idPlaceOfIssue ,issuedDate ,relationType,validDate ,gender
				)
				SELECT  @id ,@benId ,NULL ,firstName ,middleName ,lastName1 ,lastName2 ,@rfName ,
						@pCountry ,@rAdd1 ,@RLocationText ,@RStateText ,null ,@rCity, @rEmail ,@rTel ,@rTel ,@rMobile ,@rNaCountry ,@rdob ,
						NULL ,@rIdType ,@rIdNo ,NULL ,NULL ,@relationship,@rIdValid ,NULL
				FROM    dbo.FNASplitName(@rfName);		

				--**********DATA EXIST in TEMP COLLECTION**********
				INSERT  INTO collectionDetailsOnline
						( tranId ,collMode ,countryBankId ,amt ,collDate ,narration ,branchId ,createdBy ,createdDate
						)
				SELECT  @id ,@collMode ,0 ,@cAmt ,@GMTDate ,'online' ,NULL ,@senderId ,GETDATE();
					
				EXEC proc_online_temp_to_main @id = @id OUTPUT,@voucherDetails= @VoucherXML

				IF @paymentType = 'wallet' 
					EXEC proc_UpdateCustomerBalance @controlNo = @controlNoEncrypted, @type = 'deduct'
				
				ELSE IF @paymentType = 'autodebit'
					UPDATE KFTC_CUSTOMER_TRANSFER SET tranId = @id WHERE rowId = @kftcLogId

				----## map locked ex rate with transaction for history
				UPDATE exRateCalcHistory SET controlNo = @controlNoEncrypted,AGENT_TXN_REF_ID=@id WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID

				--------------------------#########------------OFAC/COMPLIANCE INSERT (IF EXISTS)---------------########----------------------
				IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId)
				BEGIN
					INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
					SELECT @id, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId
					SET @compFinalRes = 'C'
				END

				IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '')
				BEGIN
					IF(@ofacRes <> '' AND ISNULL(@compFinalRes, '') = '')
					BEGIN
						INSERT remitTranOfac(TranId, blackListId, reason, flag)
						SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
						UPDATE remitTranTemp SET
								tranStatus	= 'OFAC Hold'
						WHERE id = @id
					END
			
					ELSE IF(@compFinalRes <> '' AND ISNULL(@ofacRes, '') = '')
					BEGIN
						UPDATE remitTranTemp SET
								tranStatus	= 'Compliance Hold'
						WHERE id = @id
					END
			
					ELSE IF(ISNULL(@compFinalRes, '') <> '' AND ISNULL(@ofacRes, '') <> '')
					BEGIN
						INSERT remitTranOfac(TranId, blackListId, reason, flag)
						SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
						UPDATE remitTranTemp SET
								tranStatus	= 'OFAC/Compliance Hold'
						WHERE id = @id
					END
				END
				--Compliance checking
			
				IF @payOutPartner = '2140'  --## MTRADE
				BEGIN
					DECLARE @sederNationalityCode VARCHAR(3), @receiverNationalityCode varchar(3), @rBankCode varchar(20), @rBankBranchCode varchar(20), @pBankCode varchar(20), @pBankBranchCode varchar(20),
					@pAgentCode varchar(10)
					--****Data For TP(MTRADE)****----
					SELECT @sederNationalityCode = countryCode ,@rdob = CM.dob
					FROM countryMaster C(NOLOCK) 
					INNER JOIN customerMaster CM(NOLOCK) ON CM.nativeCountry = C.countryId
					WHERE CM.customerId = @senderId

					SELECT @receiverNationalityCode = countryCode FROM countryMaster (NOLOCK) WHERE countryId = @pCountryId
					SELECT @rBankBranchCode = agentCode FROM agentmaster (NOLOCK) WHERE agentId = @pBankBranch
					SELECT @rBankCode = agentCode, @pAgentCode = routingCode FROM agentmaster (NOLOCK) WHERE agentId = @pBank	

					SELECT sederNationalityCode = @sederNationalityCode
						, sIdTypeCode = case @sIdType when 'Alien Registration Card' then '21' 
													  when 'National ID' then '9' when 'Passport' then '2' end
						,rIdTypeCode = ''--case @rIdType when 'National ID' then '1' else '3' end 
						,receiverNationalityCode = @receiverNationalityCode
						,rBankCode = @rBankCode
						,rBankBranchCode = @rBankBranchCode
						,sourceOfFund = '12'					--Others, so we can send our source of fund text.
						,reasonOfRemittance = '17'
						,senderOccoupation = '11'
						,remitType = 'P2P'
						,pAgentCode = @pAgentCode
						,senderDob = FORMAT(@rdob,'yyyy-MM-dd')
						,payoutMethod = CASE WHEN @deliveryMethodId = '2' THEN '1'
											WHEN @deliveryMethodId = '1' THEN '2'
											WHEN @pBank = '2135' AND @deliveryMethodId = '2' AND @pCountryId = '45' THEN '21'
										END

				END
				ELSE IF @payOutPartner = '224388' --## TANGLO
				BEGIN
					SELECT @pBankCode = agentCode FROM agentMaster (NOLOCK) WHERE agentId = @pBank
					SELECT @pBankBranchCode = agentCode FROM agentMaster (NOLOCK) WHERE agentId = @pBankBranch

					SELECT BankBranchName = @sederNationalityCode
						, BankBranchCode = @pBankBranchCode
						,bIdType = '1'
						,sFundSource = '11'
						,bIdNum = '000000'
						,bIssuerCode = @pBankCode
						,bPurposeCode = '10010'
						,bCountry = (SELECT countryCode FROM countryMaster (NOLOCK) WHERE countryId = @pCountryId)
						,bProvinceCode =  @RLocation
						,bRegencyCode = @RState
						,Relationship = case when @relationship in ('Brother','Daughter','Father','Grand Father','Grand Mother','Mother','Sister','Son','Spouse') then '4'
											 when @relationship in ('Cousin','Aunt','Uncle') then '5' else '8' 
										end
						,deliverMethod = case when @deliveryMethodId = '1' then '5' 
											  when @deliveryMethodId = '2' then '1' 
											  when @deliveryMethodId = '12' then '9'
											  when @deliveryMethodId = '13' then '2'
											  when @pCountry = 'China' then '8'
										else '0' end
						,sIdTypeCode = case @sIdType when 'Alien Registration Card' then '1' 
													  when 'National ID' then '3' when 'Passport' then '2' end
				END

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
				SElect 0 ErrorCode,'Transaction has been sent successfully' Msg, @id id, @controlNo extra;

			RETURN 
		END
		ELSE IF @flag = 'success'
		BEGIN
			declare @tpEncryptKey varchar(30)
			IF @tpRefNo = 'C'
				SET @tpRefNo = @tranId

			select @controlNoEncrypted = dbo.FNAEncryptString(@controlNo),@tpEncryptKey = dbo.FNAEncryptString(@tpRefNo)

			select @id = id,@payOutPartner = pAgent from remitTranTemp (nolock) where controlno = @controlNoEncrypted
			
			update remitTranTemp set controlno = @tpEncryptKey where id = @id

			exec [proc_ApproveHoldedTXN]  @flag = 'approve', @id = @id,@user = 'admin'

			select @id = id from remitTran (nolock) where controlno = @tpEncryptKey

			IF @payOutPartner = '2129' --##Merchantrade-Malaysia
			BEGIN
				update remitTran set controlno = @tpEncryptKey
							,controlNo2 = @controlNoEncrypted
							,ContNo = @tpTranId
							,sharingValue = pcurrCostRate
							,pcurrCostRate = case when @tpExRate is not null then @tpExRate else pcurrCostRate end
							,payStatus = 'Post'
							,postedBy = 'system'
							,postedDate = getdate()
				where id = @id
			END
			ELSE
			BEGIN
				update remitTran set controlno = @tpEncryptKey
						,controlNo2 = @controlNoEncrypted
						,ContNo = @tpTranId
						,sharingValue = pcurrCostRate
						,pcurrCostRate = case when @tpExRate is not null then @tpExRate else pcurrCostRate end
				where id = @id
			END
			----## map locked ex rate with transaction for history
			update exRateCalcHistory set controlNo = @tpEncryptKey where controlNo = @controlNoEncrypted

			SELECT 0 ErrorCode,'Transaction has been sent successfully' Msg, @id id, @tpRefNo extra
		END
		ELSE IF @flag = 'revertTxn'
		BEGIN
			select @id = id from remitTranTemp(nolock) where controlno = dbo.FNAEncryptString(@controlNo)
			EXEC proc_ApproveHoldedTXN @flag = 'reject', @user =@user , @id =@id
		END
		IF @flag = 'pagentMtrade'
		BEGIN
			IF @tpAgentId IS NULL AND @pCountry IS NOT NULL
			BEGIN
				--IF NOT EXISTS (select 'A' from countryReceivingMode cm
				--inner join countryMaster c (nolock) on c.countryId = cm.countryId
				--where c.countryName = @pCountry and receivingMode = @deliveryMethodId)
				--BEGIN
				--	select @deliveryMethodId = CM.receivingMode from countryReceivingMode cm
				--	inner join countryMaster c (nolock) on c.countryId = cm.countryId
				--	where c.countryName = @pCountry
				--END
				SELECT TOP 1 routingCode FROM agentMaster (NOLOCK) WHERE agentCountry = @pCountry AND agentRole = @deliveryMethodId and parentId = 2140
			END
			ELSE
			BEGIN
				SELECT routingCode FROM agentMaster (nolock) where agentId = @tpAgentId
			END
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
