USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_Online_sendTxn]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_Online_sendTxn]
    (
      @flag					VARCHAR(50),
      @user					VARCHAR(100),
      @senderId				BIGINT				=	NULL,
	  @pwd					VARCHAR(150)		=	NULL,
      @sIpAddress			VARCHAR(50)			=	NULL,
	  @sIdType				VARCHAR(100)		=	NULL,
	  @sIdNo				VARCHAR(100)		=	NULL,
	  @sMobile				VARCHAR(50)			=	NULL,
      @receiverId			BIGINT				=	NULL,
      @rfName				VARCHAR(100)		=	NULL,
      @rmName				VARCHAR(100)		=	NULL,
      @rlName				VARCHAR(100)		=	NULL,
      @rlName2				VARCHAR(100)		=	NULL,
	  @zipCode				VARCHAR(15)			=	NULL,
	  @rStateId				INT					=	NULL,
	  @rStreet				VARCHAR(150)		=	NULL,
      @rIdType				VARCHAR(100)		=	NULL,
      @rIdNo				VARCHAR(50)			=	NULL,
      @rIdIssuedDate		DATETIME			=	NULL,
      @rIdValid				DATETIME			=	NULL,
      @rdob					DATETIME			=	NULL,
      @rTel					VARCHAR(20)			=	NULL,
      @rMobile				VARCHAR(20)			=	NULL,
      @rNaCountry			VARCHAR(50)			=	NULL,
      @rcity				VARCHAR(100)		=	NULL,
      @rAdd1				VARCHAR(150)		=	NULL,
      @rEmail				VARCHAR(100)		=	NULL,
      @raccountNo			VARCHAR(50)			=	NULL,
      @pCountry				VARCHAR(50)			=	NULL,-- pay country
      @pCountryId			INT					=	NULL,-- PAY COUNTRY ID
      @deliveryMethod		VARCHAR(50)			=	NULL,-- payment mode
      @deliveryMethodId		INT					=	NULL,-- payment mode ID
      @pBank				INT					=	NULL,
      @pBankName			VARCHAR(100)		=	NULL,
      @pBankBranch			INT					=	NULL,
      @pBankBranchName		VARCHAR(100)		=	NULL,
      @pAgent				INT					=	NULL,
      @pAgentName			VARCHAR(100)		=	NULL,
      @pBranch				INT					=	NULL,
      @pBranchName			VARCHAR(100)		=	NULL,
      @pBankType			CHAR(1)				=	NULL,
      @pSuperAgent			INT					=	NULL,
      @pCurr				VARCHAR(3)			=	NULL,
      @collCurr				VARCHAR(3)			=	NULL,
      @cAmt					MONEY				=	NULL,
      @pAmt					MONEY				=	NULL,
      @tAmt					MONEY				=	NULL,
      @serviceCharge		MONEY				=	NULL,
      @discount				MONEY				=	NULL,
      @exRate				FLOAT				=	NULL,
      @purpose				VARCHAR(150)		=	NULL,
      @sourceOfFund			VARCHAR(150)		=	NULL,
      @relationship			VARCHAR(100)		=	NULL,
      @occupation			VARCHAR(100)		=	NULL,
      @payMsg				VARCHAR(1000)		=	NULL,
      @controlNo			VARCHAR(20)			=	NULL,
      @sCountryId			INT					=	NULL,
      @sCountry				VARCHAR(100)		=	NULL,
      @sBranch				INT					=	NULL,
      @sBranchName			VARCHAR(100)		=	NULL,
      @sAgent				INT					=	NULL,
      @sAgentName			VARCHAR(100)		=	NULL,
      @sSuperAgent			INT					=	NULL,
      @sSuperAgentName		VARCHAR(100)		=	NULL,
      @settlingAgent		INT					=	NULL,
      @branchMapCode		VARCHAR(10)			=	NULL,
      @agentMapCode			VARCHAR(10)			=	NULL,
      @collMode				VARCHAR(50)			=	NULL,
      @depositMode			VARCHAR(50)			=	NULL,  -- DEPOSIT MODE  CASH OR BANK 
      @calBy				CHAR(1)				=	NULL,
      @scDiscount			MONEY				=	NULL,
      @cardOnline			VARCHAR(50)			=	NULL,
      @agentRefId			VARCHAR(50)			=	NULL,
      @couponCode			VARCHAR(20)			=	NULL,
      @schemeId				INT					=	NULL,
      @tranId				VARCHAR(50)			=	NULL,
      @ScOrderNo			BIGINT				=	NULL,
      @unitaryBankAccountNo VARCHAR(50)			=	NULL,
      @RState				VARCHAR(10)			=	NULL,
      @RStateText			VARCHAR(150)		=	NULL,
	  @RDistrict			VARCHAR(100)		=	NULL,
      @pLocation			VARCHAR(20)			=	NULL,
	  @pLocationText		VARCHAR(30)			=	NULL,
      @pSubLocation			VARCHAR(150)		=	NULL,
	  @VoucherXML			XML					=	NULL,
	  @tpRefNo				VARCHAR(20)			=	NULL,
	  @tpTranId				VARCHAR(20)			=	NULL,
	  @payOutPartner		BIGINT				=	NULL,
	  @FOREX_SESSION_ID		VARCHAR(40)			=	NULL,
	  @kftcLogId			BIGINT				=	NULL,
	  @paymentType			VARCHAR(20)			=	NULL,
	  @introducer			VARCHAR(100)		=	NULL,
	  @rgender				VARCHAR(10)			=	NULL,
	  @isRealTime			BIT					=   NULL
    )
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	IF @paymentType IS NULL
		set @paymentType = 'wallet'

    BEGIN TRY
        BEGIN
        DECLARE			@sCurrCostRate						FLOAT ,
						@sCurrHoMargin						FLOAT ,
						@pCurrCostRate						FLOAT ,
						@pCurrHoMargin						FLOAT ,
						@sCurrAgentMargin					FLOAT ,
						@pCurrAgentMargin					FLOAT ,
						@sCurrSuperAgentMargin				FLOAT ,
						@pCurrSuperAgentMargin				FLOAT ,
						@customerRate						FLOAT ,
						@sAgentSettRate						FLOAT ,
						@pDateCostRate						FLOAT ,
						@agentCrossSettRate					FLOAT ,
						@treasuryTolerance					FLOAT ,
						@customerPremium					FLOAT ,
						@schemePremium						FLOAT ,
						@sharingValue						MONEY ,
						@sharingType						CHAR(1) ,
						@sAgentComm							MONEY ,
						@sAgentCommCurrency					VARCHAR(3) ,
						@sSuperAgentComm					MONEY ,
						@sSuperAgentCommCurrency			VARCHAR(3) ,
						@pAgentComm							MONEY ,
						@pAgentCommCurrency					VARCHAR(3) ,
						@pCommissionType					CHAR(1) ,
						@pSuperAgentComm					MONEY ,
						@pSuperAgentCommCurrency			VARCHAR(3) ,
						@pSuperAgentName					VARCHAR(100),
						@senderName							VARCHAR(100) ,
						@tempTranId							INT ,
						@customerStatus						VARCHAR(20) ,
						@idExpiryDate						DATETIME,
						@errorCode							CHAR(1)= '0',
						@agentAvlLimit						MONEY,
						@rowId								INT,
						@scValue							MONEY ,
						@exRateOffer						MONEY ,
						@scAction							VARCHAR(5) ,
						@AmountLimitPerTran					MONEY ,
						@AmountLimitPerDay					MONEY ,
						@todaysTotalSent					MONEY ,
						@tranMinimum						MONEY ,
						@tranMaximum						MONEY,
						@memberShipId						VARCHAR(50)			=	NULL,
						@ad									FLOAT,
						@xAmt								MONEY ,
						@sendingCustType					INT ,
						@msg								VARCHAR(MAX),
						@iServiceCharge						MONEY ,
						@iTAmt								MONEY ,
						@iPAmt								MONEY ,
						@iCAmt								MONEY ,
						@iCustomerRate						FLOAT, 
						@place								INT ,
						@currDecimal						INT,
						@controlNoEncrypted					VARCHAR(20),
						@csMasterId							INT ,
						@count								INT ,
						@compFinalRes						VARCHAR(20),
						@createdDate						DATETIME,
						@promotionType						INT,
						@sfName								VARCHAR(100)		=	NULL,
						@smName								VARCHAR(100)		=	NULL,
						@slName								VARCHAR(100)		=	NULL,
						@slName2							VARCHAR(100)		=	NULL,
						@sAdd1								VARCHAR(100)		=	NULL,
						@sAdd2								VARCHAR(100)		=	NULL,
						@sPostCode							VARCHAR(50)			=	NULL,
						@scity								VARCHAR(200)		=	NULL,
						@sEmail								VARCHAR(150)		=	NULL,
						@sTel								VARCHAR(20)			=	NULL,
						@idPlaceOfIssued					VARCHAR(50)			=	NULL,
						@sNaCountry							INT					=	NULL,
						@sdob								DATETIME			=	NULL,
						@sIdValidDate						DATETIME			=	NULL,
						@RBAScoreCustomer					FLOAT				=	NULL,
						@isFirstTran						CHAR(1)				=	NULL,
						@salaryRange						VARCHAR(50)			=	NULL,
						@company							VARCHAR(200)		=	NULL,
						@ttName								VARCHAR(200)		=	NULL,
						@sDcInfo							VARCHAR(100)		=	NULL,
						@RBAScoreTxn						MONEY				=	NULL,
						@sState								VARCHAR(50)			=	NULL,
						@sCustStreet						VARCHAR(50)			=	NULL,
						@sCustomerType						VARCHAR(50)			=	NULL,
						@receiverName						VARCHAR(50)			=	NULL,
						@complienceMessage					VARCHAR(1000)		=	NULL, 
						@shortMsg							VARCHAR(100)		=	NULL,
						@complienceErrorCode				TINYINT				=	NULL
	
		SELECT @sAgent = sAgent, @sAgentName = sAgentName, @sBranch = sBranch, @sBranchName = sBranchName,
				@sSuperAgent = sSuperAgent, @sSuperAgentName = sSuperAgentName 
		FROM dbo.FNAGetBranchFullDetails(@sBranch)

		IF @pCountryId IS NULL
			SELECT @pCountryId = countryId FROM countryMaster (NOLOCK) WHERE countryName = @pCountry

		SELECT  @pBank = @pAgent,
			    @pBankName = @pAgentName,
			    @pBankBranch = @pBranch ,
				@pBankBranchName = @pBranchName;
        SELECT  @pAgent = null ,
                @pAgentName = NULL ,
                @pBranch = NULL ,
                @pBranchName = NULL;
		
		SET @sCountryId = 113
		SET @sCountry = 'Japan'
		SET @sAgentCommCurrency = 'JPY'

		IF @flag IN ('I', 'exRate')
		BEGIN
		--added by gagan because while calculating exrate from home page only country name is sent
			IF @pCountryId IS NULL AND @pCountry IS NULL
			BEGIN
				SELECT '1' ErrorCode, 'Please select receiving country!' Msg,NULL id
				RETURN
			END
			IF @pCountryId = 0 and @pCountry <> ''
			BEGIN
				select @pCountryId =countryId from countryMaster where countryName =@pCountry
			END
			IF @payoutPartner IS NULL AND @flag = 'I'
			BEGIN
				SELECT '1' ErrorCode, 'Payout partner not defined yet for receiving country!' Msg,NULL id
				RETURN
			END
			ELSE 
			BEGIN
				SELECT @payoutPartner = AgentId
				FROM TblPartnerwiseCountry (NOLOCK) WHERE CountryId = @pCountryId 
				AND ISNULL(PaymentMethod,@deliveryMethodId) = @deliveryMethodId 
				AND IsActive = 1
			END
			IF NOT EXISTS(SELECT 1 
						FROM TblPartnerwiseCountry (NOLOCK) WHERE AgentId = @payoutPartner 
						AND CountryId = @pCountryId 
						AND ISNULL(PaymentMethod,@deliveryMethodId) = @deliveryMethodId 
						AND IsActive = 1)
			BEGIN
				SELECT '1' ErrCode, 'Payout partner is not active this time please try after some time!' Msg,NULL id
				RETURN
			END
			
			SELECT TOP 1 @pAgent = AM.agentId
			FROM agentMaster AM(NOLOCK) 
			WHERE AM.parentId = @payOutPartner AND agentType=2903 AND AM.isSettlingAgent = 'Y' AND AM.isApiPartner = 1

			IF @pAgent IS NULL
			BEGIN
				EXEC proc_errorHandler  1,'Oops, something went wrong.Please perform the transaction again!' ,null
				RETURN;
			END

			SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
					@pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
			FROM dbo.FNAGetBranchFullDetails(@pAgent)
			
			IF ISNULL(@senderId, 0) <> 0
			BEGIN
				DECLARE @kycStatus INT

				SELECT @kycStatus = kycStatus
				FROM TBL_CUSTOMER_KYC (NOLOCK) 
				WHERE CUSTOMERID = @senderId
				AND ISDELETED = 0
				ORDER BY rowId DESC
		
				IF ISNULL(@kycStatus, 0) <> 11044
				BEGIN
					IF @kycStatus IS NOT NULL
						SELECT @MSG = 'KYC for selected customer is not completed, it is in status:' + detailTitle FROM staticDataValue (NOLOCK) WHERE valueId = @kycStatus
					ELSE 
						SELECT @MSG = 'Please complete KYC status first'

					SELECT '1' ErrorCode, @MSG Msg,NULL id
					RETURN
				END
			END
		END
		
        IF @flag = 'exRate'			--Get Exchange Rate, Service Charge, Scheme/Offer and amount details
        BEGIN
            SELECT TOP 1
                    @senderId = customerId ,
                    @idExpiryDate = idExpiryDate ,
                    @createdDate = createdDate,
					@sIdNo		 = idNumber,
					@sIdType	 = idType,
					@agentAvlLimit = dbo.FNAGetCustomerAvailableBalance(customerId),
					@customerStatus = CASE WHEN customerStatus IS NULL THEN 'pending' ELSE 'verified' END,
					@todaysTotalSent = ISNULL(todaysSent, 0)
            FROM  customerMaster WITH(NOLOCK) 
			WHERE customerId = @senderId;		
			
            SELECT @sIdType = detailTitle FROM staticDataValue(NOLOCK) WHERE valueId = @sIdType

			SELECT  @scValue = 0 ,
                    @exRateOffer = 0 ,
                    @scDiscount = 0 ,
                    @AmountLimitPerTran = 3000,
					@AmountLimitPerDay = 20000
			
			--2. Find payout currency if null
			IF @pCurr IS NULL
				SELECT @pCurr = pCurrency FROM dbo.exRateTreasury WITH(NOLOCK) WHERE pCountry = @pCountryId AND pAgent = @pAgent 
			IF @pCurr IS NULL
				SELECT @pCurr = pCurrency FROM dbo.exRateTreasury WITH(NOLOCK) WHERE pCountry = @pCountryId AND pAgent IS NULL
				
			SELECT  @place = place ,
                    @currDecimal = currDecimal
            FROM  currencyPayoutRound(NOLOCK)
            WHERE ISNULL(isDeleted, 'N') = 'N'
            AND currency = @pCurr AND (tranType IS NULL OR tranType = @deliveryMethodId);
			
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
			SELECT  @exRate = 
				dbo.FNAGetCustomerRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent, @pCurr,@deliveryMethodId);
            
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
								@pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethodId,@cAmt,@collCurr);

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
		
                SET @tAmt = @cAmt - @serviceCharge;
				
                SET @pAmt = (@cAmt - @serviceCharge) * @exRate
							
				SET @pAmt = ROUND(@pAmt, @currDecimal)
            END;
            ELSE
            IF @calBy = 'P'
			BEGIN
				SET @tAmt = @pAmt / @exRate
				SELECT  @serviceCharge = amount
                FROM    [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
									@pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethodId,
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
                SET @cAmt = ( @tAmt + @serviceCharge);
								
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
				SELECT  @errorCode ErrorCode ,
                    @msg Msg ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = @todaysTotalSent ,
					maxAmountLimitPerTran = @tranMaximum ,
                    PerTxnMinimumAmt = @tranMinimum;
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
				SELECT  @errorCode ErrorCode ,
                    @msg Msg ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = @todaysTotalSent ,
					maxAmountLimitPerTran = @tranMaximum ,
                    PerTxnMinimumAmt = @tranMinimum;
				RETURN;
			END
		
			--Validate Country Receiving Limit
			--End of Limit Checking------------------------------------------------------------------------------------------------------------
			--SET @msg = 'Success';
			IF ISNULL(@senderId, 0) <> 0
			BEGIN
				IF ISNULL(@paymentType,'wallet') = 'wallet'
				BEGIN
					IF ISNULL(@agentAvlLimit, 1) < ISNULL(@cAmt, 0)
					BEGIN
						SELECT  '1' ErrorCode
							,@MSG Msg ,
							amountLimitPerDay = @AmountLimitPerDay ,
							customerTotalSentAmt = @todaysTotalSent ,
							maxAmountLimitPerTran = @tranMaximum ,
							PerTxnMinimumAmt = @tranMinimum;
						RETURN;
					END;
				END
			END
			SELECT 
				 @sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
				,@pCurrCostRate			= pCurrCostRate
				,@pCurrHoMargin			= pCurrHoMargin
				,@pCurrAgentMargin		= pCurrAgentMargin
				,@agentCrossSettRate	= agentCrossSettRate
				,@treasuryTolerance		= treasuryTolerance
				,@customerPremium		= customerPremium
				,@sharingValue			= sharingValue
				,@sharingType			= sharingType
			FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethodId)

			IF @sCurrCostRate IS NULL
			BEGIN
				SELECT @errorCode = '1', @msg = 'Transaction cannot be proceed. Exchange Rate not defined!'
				RETURN
			END
			
			---------Compliance Checking Begin--------------------------------
			DECLARE @complianceRuleId INT, @cAmtUSD MONEY
  
			--SET @cAmtUSD = @cAmt / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))
			--EXEC [proc_complianceRuleDetail]
			--	 @flag			= 'sender-limit'
			--	,@user			= @user
			--	,@sIdType		= @sIdType
			--	,@sIdNo			= @sIdNo
			--	,@cAmt			= @cAmt
			--	,@cAmtUSD		= @cAmtUSD
			--	,@customerId	= @senderId
			--	,@pCountryId	= @pCountryId
			--	,@deliveryMethod= @deliveryMethodId
			--	,@message		= @complienceMessage OUTPUT
			--	,@shortMessage  = @shortMsg    OUTPUT
			--	,@errCode		= @complienceErrorCode OUTPUT
			--	,@ruleId		= @complianceRuleId  OUTPUT
   
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
				, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),'sender-limit'
			END	   
			
	
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
			----------Compliance Validation End---------------------------------	
			
			IF ISNULL(@senderId, 0) <> 0
			BEGIN	
				SET @FOREX_SESSION_ID = NEWID()

				----## lock ex rate for individual txn
				INSERT INTO exRateCalcHistory (
					CUSTOMER_ID,[USER_ID],FOREX_SESSION_ID,serviceCharge,pAmt,customerRate,sCurrCostRate,sCurrHoMargin		
					,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,agentCrossSettRate,treasuryTolerance,customerPremium	
					,sharingValue,sharingType,createdDate,isExpired,tAmt
				)
				SELECT
				@senderId,@user,@FOREX_SESSION_ID,@serviceCharge,@pAmt,@exRate,@sCurrCostRate,@sCurrHoMargin		
				,@sCurrAgentMargin,@pCurrCostRate,@pCurrHoMargin,@pCurrAgentMargin	,@agentCrossSettRate,@treasuryTolerance	,@customerPremium	
				,@sharingValue,@sharingType,GETDATE(),0,@tAmt
			END
			
			
            SELECT  ErrorCode = @errorCode ,
                    Msg = @msg ,
					Id = NULL,
                    scCharge = @serviceCharge,
                    exRateDisplay =@exRate, --ROUND(@exRate , 4, -1),
					exRate = @exRate,
                    place = @place ,
                    pCurr = @pCurr ,
                    currDecimal = @currDecimal ,
					pAmt = @pAmt ,
                    sAmt =ISNULL(ROUND(@tAmt, 0),0) ,
                    disc = 0.00 ,
					--bank data
					bankTransafer = 0.00,
					bankPayout = 0.00,
					bankRate = 0.00,
					bankFee = 0.00,
					bankSave = 0.00,
					bankName = '',

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
					tpExRate = @exRate,
					tpPCurr = @pCurr, 
                    schemeAppliedMsg = '',
					schemeId = @schemeId,
					EXRATEID = @FOREX_SESSION_ID
        END;

		IF @flag = 'i'--Send Transaction
        BEGIN
			DECLARE @AVAILABLEBALANCE MONEY
			--1. Field Validation
			IF @user IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
				RETURN
			END

			IF NOT EXISTS (SELECT 'X' FROM dbo.customerMaster(nolock) WHERE customerId = @senderId AND customerPassword = dbo.fnaencryptstring(@pwd) AND approvedDate IS NOT NULL)
			BEGIN
				EXEC proc_errorHandler 1,'User name or password not match', NULL;
                RETURN;
			END

			IF ISNULL(@paymentType, '') NOT IN ('wallet', 'autodebit')
			BEGIN
				EXEC proc_errorHandler 1,'Invalid payment method. Please perform the transaction again!', NULL;
                RETURN;
			END

            IF @rfName IS NULL
            BEGIN
                EXEC proc_errorHandler 1,'Receiver First Name missing', NULL;
                RETURN;
            END;

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
		
            IF ISNULL(@cAmt, 0) = 0
            BEGIN
                EXEC proc_errorHandler 1, 'Collection Amount is missing. Cannot send transaction',NULL;
                RETURN;	
            END; 
			
			IF @serviceCharge > @cAmt
			BEGIN
				EXEC proc_errorHandler 1, 'Collection Amount is less than service charge.', NULL
				RETURN	
			END 

			SELECT @AVAILABLEBALANCE = DBO.FNAGetCustomerAvailableBalance(@senderId)

			IF (ISNULL(@AVAILABLEBALANCE, 0) < @cAmt) 
			BEGIN
				EXEC proc_errorHandler 1, 'Collect Amount can not be greater then Available Balance!', NULL
				RETURN
			END
			
            SET @controlNo = '21' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
			
			IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
			BEGIN
				SET @controlNo = '21' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
				IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
				BEGIN
					EXEC proc_errorHandler 1, 'Technical error occurred. Please try again', NULL
					RETURN
				END
			END

            SELECT  @controlNoEncrypted = dbo.FNAEncryptString(@controlNo);
			
			IF @deliveryMethod = 'Bank Deposit'
            BEGIN                               
				IF NOT EXISTS(SELECT 'A' FROM API_BANK_LIST(nolock) where BANK_ID = @pBank AND IS_ACTIVE = 1)
				BEGIN
					EXEC proc_errorHandler 1, 'Invalid bank selected', NULL
					RETURN
				END
            END;

			----3.Get Exchange Rate Details-----------------------------------------------------------
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
				,@iPAmt					= pAmt
			FROM exRateCalcHistory(NOLOCK) 
			WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID AND USER_ID = @user
			
			IF @sCurrCostRate IS NULL
			BEGIN
				SELECT @errorCode = '1', @msg = 'Transaction cannot be proceed. Exchange Rate not defined!'
				RETURN
			END

			IF @customerRate IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
				RETURN
			END

			IF ISNULL(@exRate,0) <> ISNULL(@customerRate,1)
			BEGIN
				EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again', NULL
				RETURN
			END
	
			SELECT  @iServiceCharge = amount
			FROM    [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
								@pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethodId,
										@cAmt, @collCurr);

			SELECT @iCustomerRate = @customerRate, @iTAmt = @cAmt - @iServiceCharge
			
			SELECT @place = place, @currDecimal = currDecimal
			FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
			AND currency = @pCurr AND ISNULL(tranType, @deliveryMethodId) = @deliveryMethodId
		
			SET @currDecimal = ISNULL(@currDecimal, 0)
			SET @place = ISNULL(@place, 0)
			SET @iPAmt = ROUND(@iTAmt * @iCustomerRate, @currDecimal)
					
			IF @pAmt - @iPAmt = 1
				SET @iPAmt = @pAmt
			IF @iPAmt <> @pAmt
			BEGIN
				EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again.', NULL
				RETURN
			END
			--------#Register Receiver if not registered#---------------
			IF ISNULL(@receiverId, 0) = 0
			BEGIN
				DECLARE @rBankId INT = ISNULL(@pBank, @pAgent)
				EXEC PROC_CHECK_RECEIVER_REGISTRATION @flag = 'i', @user=@user, @rfName=@rfName, @rmName=@rmName, @rlName=@rlName, @receiverIdNo=@rIdNo,
					@receiverIdType=@rIdType, @receiverCountry=@pCountry, @receiverAdd=@rAdd1, @receiverCity=@rcity, @receiverMobile=@rMobile,
					@receiverPhone = @rTel, @receiverEmail = @rEmail, @receiverId = @receiverId OUT, @customerId = @senderId, @paymentMethodId=@deliveryMethodId,
					@rBankId= @rBankId, @rAccountNo=@raccountNo

			END

			--**********Customer Per Day Limit Checking**********
            DECLARE @remitTranTemp TABLE (
                    tranId BIGINT,controlNo VARCHAR(20),cAmt MONEY,receiverName VARCHAR(200) ,
                    receiverIdType VARCHAR(100),receiverIdNumber VARCHAR(50),dot DATETIME
                );
            
            INSERT INTO @remitTranTemp( tranId ,controlNo ,cAmt ,receiverName ,receiverIdType ,receiverIdNumber ,dot )
            SELECT  rt.id ,rt.controlNo ,rt.cAmt ,rt.receiverName ,rec.idType ,rec.idNumber ,rt.createdDateLocal
			FROM vwRemitTran rt WITH(NOLOCK)
			INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
			INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
			WHERE sen.customerId = @senderId
			AND ( rt.approvedDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101)+ ' 23:59:59'
					OR ( approvedBy IS NULL AND cancelApprovedBy IS NULL )
				);
			SET @receiverName=@rfName+ISNULL(' '+@rmName,'')+ISNULL(' '+@rlName,'')+ISNULL(' '+@rlName2,'')
            IF EXISTS ( SELECT  'X' FROM @remitTranTemp
                        WHERE   cAmt = @cAmt
                        AND ( receiverName = @receiverName ) AND DATEDIFF(MI, dot, GETDATE()) <= 2 
						)
			BEGIN
				EXEC proc_errorHandler 1, 'Similar transaction found. Please perform the transaction after 2 minutes.', NULL;
				RETURN;
			END;

			--##Get Voucher Details into temp table END##--	
			
			SELECT @pAgentCommCurrency = DBO.FNAGetPayCommCurrency(@sSuperAgent,@sAgent,@sBranch,@SCOUNTRYID,@pSuperAgent,@pBranch,@pCountryId)

			SELECT @pAgentComm = amount FROM dbo.FNAGetPayComm(@sAgent,@sCountryId, 
									NULL, null, @pCountryId, null, @pAgent, @pAgentCommCurrency
									,@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL)

			SELECT @sAgentComm = 0, @sSuperAgentComm = 0, @sSuperAgentCommCurrency = @sAgentCommCurrency

			DECLARE @agentFxGain MONEY
			SET @agentFxGain = @tAmt - (@pAmt / @pCurrCostRate)

			--get sender info

			IF @receiverId IS NOT NULL
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM receiverInformation (NOLOCK) WHERE customerId = @senderId AND receiverId = @receiverId)
				BEGIN
					EXEC proc_errorHandler 1,'Invalid receiver Id!', NULL;
					RETURN;
				END
			END
			IF NOT EXISTS(SELECT 'Z' FROM tranSenders WITH(NOLOCK) WHERE customerId = @senderId)
				SET @isFirstTran = 'Y'
			
			SET @receiverName=@rfName+ISNULL(' '+@rmName,'')+ISNULL(' '+@rlName,'')+ISNULL(' '+@rlName2,'')

			
			SELECT		@memberShipId		=	membershipId,
					@sfName				=	firstName,
					@smName				=	middleName,
					@slName				=	lastName1,
					@slName2			=	lastName2,
					@senderName			=	fullName,
					@sCountryId			=	country,
					@sAdd1				=	address,
					@sAdd2				=	address2,
					@sPostCode			=	zipCode,
					@scity				=	city,
					@sEmail				=	email,
					@sTel				=	telNo,
					@sNaCountry			=	nativeCountry,
					@sdob				=	dob,
					@sIdValidDate		=	idExpiryDate,
					@salaryRange		=	salaryRange,
					@company			=	companyName,		
					@sState				=	state,		
					@sCustStreet		=	street,		
					@sCustomerType		=	customerType	
			FROM dbo.customerMaster WHERE customerId=@senderId;

			--OFAC Checking
			DECLARE @receiverOfacRes VARCHAR(MAX), @ofacRes VARCHAR(MAX), @ofacReason VARCHAR(200)
			IF(ISNULL(@senderId, '') = '')
				SELECT @senderName = @sfName + ISNULL(' ' + @smName, '') + ISNULL(' ' + @slName, '') + ISNULL(' ' + @slName2, '')
			ELSE
				SELECT @senderName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName1, '') + ISNULL(' ' + lastName2, '') 
				FROM dbo.customerMaster WITH(NOLOCK) WHERE customerId = @senderId
			
			SELECT @receiverName = @rfName + ISNULL(' ' + @rmName, '') + ISNULL(' ' + @rlName, '') + ISNULL(' ' + @rlName2, '')

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

			--Compliance Checking				
			SET @cAmtUSD = @cAmt / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))
			
			IF @sCountry IS NULL
				SELECT @sCountry = countryName FROM dbo.countryMaster(nolock) WHERE countryId = @sCountryId

			--EXEC [proc_complianceRuleDetail]
			--	@flag				= 'receiver-limit'
			--	,@user				= @user
			--	,@sIdType			= @sIdType
			--	,@sIdNo				= @sIdNo
			--	,@receiverName		= @rfName
			--	,@cAmt				= @cAmt
			--	,@cAmtUSD			= @cAmtUSD
			--	,@customerId		= @senderId
			--	,@pCountryId		= @pCountryId
			--	,@receiverMobile	= @rMobile
			--	,@deliveryMethod	= @deliveryMethodId
			--	,@message			= @complienceMessage OUTPUT
			--	,@shortMessage		= @shortMsg    OUTPUT
			--	,@errCode			= @complienceErrorCode OUTPUT
			--	,@ruleId			= @complianceRuleId  OUTPUT
   
		IF(@complienceErrorCode <> 0)
		BEGIN  
			IF(@complienceErrorCode = 1) --BLOCK TXN
			BEGIN
				SET @compErrorCode = 101
				--SELECT 101 errorCode,@msg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
			END 
			ELSE 
			BEGIN
				--IN CASE OF HOLD TXN
				SET @compErrorCode = 102
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

		BEGIN TRANSACTION
				------- add data on remittrantemp
				INSERT INTO dbo.remitTranTemp
						(  controlNo
					,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin
					,pCurrCostRate,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin
					,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate
					,treasuryTolerance,customerPremium,schemePremium,sharingValue
					--,sharingType
					,serviceCharge,handlingFee, agentFxGain
					,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency
					,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency
					,promotionCode,promotionType
					,pMessage
					,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,sCountry
					,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName,pCountry
					,paymentMethod
					,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,pBankType
					,expectedPayoutAgent
					,collMode,collCurr,tAmt,cAmt,pAmt,payoutCurr
					,relWithSender,purposeOfRemit,sourceOfFund
					,tranStatus,payStatus
					,createdDate,createdDateLocal,createdBy	
					,tranType,voucherNo	
					,senderName
					,receiverName	
					,pState
					,pDistrict
					,pLocation
					--NEW
					,isScMaunal
					,originalSC
					,isOnlineTxn
					--,externalBankCode
					--,isOnBehalf
						)
				VALUES  (  @controlNoEncrypted
					,@sCurrCostRate,@sCurrHoMargin,@sCurrSuperAgentMargin,@sCurrAgentMargin
					,@pCurrCostRate,@pCurrHoMargin,@pCurrSuperAgentMargin,@pCurrAgentMargin
					,@agentCrossSettRate,@customerRate,@sAgentSettRate,@pDateCostRate
					,@treasuryTolerance,@customerPremium,ISNULL(@schemePremium,0),@sharingValue
					--,@sharingType
					,@serviceCharge,ISNULL(@scDiscount,0), @agentFxGain
					,@sAgentComm,@sAgentCommCurrency,@sSuperAgentComm,@sSuperAgentCommCurrency
					,@pAgentComm,@pAgentCommCurrency,@pSuperAgentComm,@pSuperAgentCommCurrency
					,@introducer,@promotionType													--@promotionCode REPLACED BY ARJUN
					,@payMsg
					,@sSuperAgent,@sSuperAgentName,@sAgent,@sAgentName,@sBranch,@sBranchName,@sCountry
					,@pSuperAgent,@pSuperAgentName,@pAgent,@pAgentName,@pBranch,@pBranchName,@pCountry
					,@deliveryMethod
					,@pBank,@pBankName,@pBankBranch,@pBankBranchName,@raccountNo,@pBankType
					,@pAgentName
					,'Bank Deposit',@collCurr,@tAmt,@cAmt,@pAmt,@pCurr
					,@relationship,@purpose,@sourceOfFund
					,'Hold','Unpaid'
					,DBO.FNADateFormatTZ(GETDATE(), @user),GETDATE(),@user
					,'O',''
					,@senderName
					,@receiverName
					,@RState
					,@RDistrict
					,@pLocationText
					,0 
					,@iServiceCharge
					,'Y'
					--,@customerDepositedBank
					--,@isOnbehalf
						)

				SET @tempTranId=SCOPE_IDENTITY()

				INSERT INTO controlNoList(controlNo)
				SELECT @controlNo

				INSERT INTO tranSendersTemp(
						tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2
					,fullName,country,[address],address2,zipCode,city,email,homePhone,mobile,nativeCountry,dob
					,placeOfIssue,idType,idNumber,validDate,occupation,customerRiskPoint
					,isFirstTran,salary,companyName,ttName,dcInfo,ipAddress,RBA,STATE,district,customerType
				)
				SELECT 
							@tempTranId,@senderId,@memberShipId,@sfName,@smName,@slName,@slName2
						,@senderName,@sCountry,@sAdd1,@sAdd2,@sPostCode,@scity,@sEmail,@sTel,@sMobile,@sNaCountry,@sdob
						,@idPlaceOfIssued,@sIdType,@sIdNo,@sIdValidDate,@occupation,@RBAScoreCustomer
						,@isFirstTran,@salaryRange,@company,@ttName,@sDcInfo,@sIpAddress, @RBAScoreTxn,@sState,@sCustStreet,@sCustomerType

				INSERT INTO tranReceiversTemp(
						tranId,customerId,membershipId
					,firstName,middleName,lastName1,lastName2
					,fullName
					,country,[address],zipCode,city,email
					,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue
					,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,gender
					,STATE,district,accountNo,relationType
				)
				SELECT
						@tempTranId,@receiverId,''
					,@rfName,@rmName,@rlName,@rlName2
					,@receiverName
					,@pCountry,@rAdd1,@zipCode,@rcity,@rEmail
					,@rTel,@rTel,@rMobile,@rNaCountry,@rdob,NULL
					,@rIdType,@rIdNo,NULL,@rIdIssuedDate,@rIdValid,@rgender
					,@RStateText,@RDistrict,@raccountNo,@relationship

				EXEC proc_customerTxnHistory @controlNo = @controlNoEncrypted

				----## map locked ex rate with transaction for history
				UPDATE exRateCalcHistory set controlNo = @controlNoEncrypted,AGENT_TXN_REF_ID=@tempTranId where FOREX_SESSION_ID = @FOREX_SESSION_ID

				--------------------------#########------------OFAC/COMPLIANCE INSERT (IF EXISTS)---------------########----------------------
				IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId)
				BEGIN
					INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
					SELECT @tempTranId, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId
					SET @compFinalRes = 'C'
				END

				IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> '')
				BEGIN
					DECLARE @tempCompId BIGINT = @@IDENTITY
					--if txn need to be rejected
					IF @pCountryId IN (0)
					BEGIN
						SET @complienceMessage = ISNULL('Compliance: ' + @shortMsg, '') + ISNULL('Ofac: ' + @ofacRes, '') + ISNULL(' ' + @receiverOfacRes, '') 
						
						INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName
							, receiverCountry,payOutAmt,complianceId,complianceReason,complainceDetailMessage,createdBy,createdDate,logType)
						
						SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName
							, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),'reject_log'

						SET @tempCompId = @@IDENTITY

						SET @msg = 'Your transaction is under Compliance/OFAC Please refer ' + CAST(ISNULL(@tempCompId, 0) AS VARCHAR) + ' code to HEAD OFFICE';
						
						EXEC proc_errorHandler 1, @msg, NULL;
						EXEC proc_ApproveHoldedTXN @flag = 'reject', @user = @user , @id = @tempTranId
						
						COMMIT TRANSACTION 
						RETURN
					END

					IF((ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> '') AND ISNULL(@compFinalRes, '') = '')
					BEGIN
						IF ISNULL(@ofacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tempTranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
						
						IF ISNULL(@receiverOfacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tempTranId, @receiverOfacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@receiverOfacRes)

						UPDATE remitTranTemp SET
								tranStatus	= 'OFAC Hold'
						WHERE id = @tempTranId
					END
					
					ELSE IF(@compFinalRes <> '' AND (ISNULL(@ofacRes, '') = '' OR ISNULL(@receiverOfacRes, '') = ''))
					BEGIN
						UPDATE remitTranTemp SET
								tranStatus	= 'Compliance Hold'
						WHERE id = @tempTranId
					END
			
					ELSE IF(ISNULL(@compFinalRes, '') <> '' AND (ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> ''))
					BEGIN
						IF ISNULL(@ofacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tempTranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
						
						IF ISNULL(@receiverOfacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tempTranId, @receiverOfacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@receiverOfacRes)
				
						UPDATE remitTranTemp SET
								tranStatus	= 'OFAC/Compliance Hold'
						WHERE id = @tempTranId
					END
				END
				--Compliance checking

				IF @@TRANCOUNT > 0
					COMMIT TRANSACTION
				
				SELECT 0 errorCode, 'Transaction has been sent successfully' msg, @controlNo id, @tempTranId extra;
				
				EXEC proc_UpdateCustomerBalance @controlNo = @controlNoEncrypted, @type = 'deduct'

				RETURN    
		END;

		ELSE IF @flag = 'approve-wing'
		BEGIN
			select @tempTranId = id, @deliveryMethod = paymentMethod from remitTranTemp (nolock) where controlno = dbo.FNAEncryptString(@controlNo)
			
			if @deliveryMethod <> 'Mobile Wallet'
				update remitTranTemp set controlno = dbo.FNAEncryptString(@tpRefNo),controlNo2	= dbo.FNAEncryptString(@controlNo) where id = @tempTranId
			IF EXISTS(
				select 'A' from remittran(nolock) where controlno = dbo.FNAEncryptString(@tpRefNo) AND pCountry = 'Cambodia' AND pAgent = 221226 -- AND DATEDIFF(DAY,createddate,GETDATE()) > 30 
			)
			BEGIN
				UPDATE remittran SET controlno = dbo.FNAEncryptString(@tpRefNo+'A') where controlno = dbo.FNAEncryptString(@tpRefNo)
				UPDATE PINQUEUELIST SET ICN = dbo.FNAEncryptString(@tpRefNo+'A') WHERE ICN = dbo.FNAEncryptString(@tpRefNo)
				UPDATE SendMnPro_Account.dbo.tran_master set field1 = @tpRefNo+'A' where field1 = @tpRefNo and field2 = 'remittance Voucher'
			END

			EXEC [proc_ApproveHoldedTXN]  @flag = 'approve', @id = @tempTranId,@user = 'admin'

			SELECT @tempTranId = id FROM remitTran (NOLOCK) 
			WHERE controlno = case when @deliveryMethod = 'Mobile Wallet' then dbo.FNAEncryptString(@controlNo) else dbo.FNAEncryptString(@tpRefNo) end
			AND paystatus = 'UNPAID' 
			IF @tempTranId IS NOT NULL
			BEGIN
				UPDATE remitTran SET controlno		= case when @deliveryMethod = 'Mobile Wallet' then dbo.FNAEncryptString(@controlNo) else dbo.FNAEncryptString(@tpRefNo) end
									,controlNo2		= dbo.FNAEncryptString(@controlNo)
									,ContNo			= @tpTranId
									,paystatus		= 'Post'
									,postedBy		= @user
									,postedDate		= getdate()
									,postedDateLocal = getdate()
				WHERE id = @tempTranId AND paystatus = 'UNPAID'
			END
			SELECT 0 ErrorCode,'Transaction has been sent successfully' Msg, @tempTranId id, case when @deliveryMethod = 'Mobile Wallet' then @controlNo else @tpRefNo end extra

		END;

		ELSE IF @flag = 'showLimit'
		BEGIN
			SELECT  [paymentType] = sdv.detailTitle ,
					limit.id ,
					currency ,
					sendingLimit = CAST(CAST(maximum AS DECIMAL(10,2)) AS VARCHAR) ,
					cm.countryName ,
					limitType = CASE WHEN ISNULL(limitType,'T') = 'T' THEN 'Per Transactioin' ELSE 'Per Day' END
				FROM    onlineCustomerLimitSetup limit WITH ( NOLOCK )
				INNER JOIN staticDataValue sdv WITH ( NOLOCK ) ON sdv.valueId = limit.payBy
				INNER JOIN countryMaster cm WITH ( NOLOCK ) ON cm.countryId = limit.receivingCountry
				WHERE   customerVerification = @customerStatus
				AND limitType = 'T' AND limit.receivingCountry = '151'; 
		END;


		ELSE IF @flag ='lastTxnsOfBank'
		BEGIN	
	 	 	 
			select top 3 value= 'rFullName='+isnull(receiverName,'')+'=v-::-cmbAgent='+isnull(CAST(pBank AS VARCHAR),'')+
				'=d-::-cmbAgentName='+isnull(pBankName,'')+'=v-::-hddBranch='+cast(isnull(pBankBranch,'') as varchar)+
				'=v-::-hddBranchName='+isnull(pBankBranchName,'')+'=v-::-txtAccountNo='+isnull(rt.accountNo,'')+
				'=v-::-receiverrelation='+isnull(rt.relWithSender,'')+'=d-::-RAddress='+isnull(address,'')+'=v-::-rState='+isnull([STATE],'')+
				'=v-::-rCity='+isnull(city,'')+'=v-::-receiverMobile='+ isnull(mobile,'')+'=v-::-receiverEmail='+isnull(email,'')+
				'=v-::-rTelephone='+isnull(homePhone,'')+'=v-::-ddllstReceiver='+isnull(cast(ts.customerId as varchar),'')+'=d'
				,[text]= isnull(receiverName,'')+' | '+isnull(pBankName,'')+' | '+isnull(rt.accountNo,'')
					from dbo.vwRemitTran rt WITH(NOLOCK) 
				LEFT JOIN dbo.vwTranReceivers ts WITH(NOLOCK) ON ts.tranId = rt.id
				WHERE tranType='O' AND rt.createdBy = @user 
				AND isnull(paymentMethod,'CASH PAYMENT') = 'BANK DEPOSIT'
				AND rt.pCountry = @pCountry
				ORDER BY rt.holdTranId desc

				RETURN
		END

		ELSE IF @flag = 'isProVoucherUsed'
        BEGIN
            IF NOT EXISTS ( SELECT 'x' FROM  remitTran(nolock) WHERE promotionCode IS NOT NULL AND createdBy = @user )
           BEGIN
                SELECT  '1' errorCode , 'Promotional Code already used.' , NULL;
            END;	
		ELSE
        BEGIN
			SELECT  '0' errorCode , 'Promotional Code not used.' , NULL;
            END;	
		END;
				
		ELSE IF @flag = 'getTtranDetail'
        BEGIN
                SELECT  cm.countryId , rt.pCountry, rt.tAmt, rt.pAmt, rt.payoutCurr, rt.pAgentName, rt.purposeOfRemit,
						rt.sourceOfFund, rt.pBankName, rt.pBankBranchName, rt.serviceCharge, rt.collCurr,
						customerRate =CASE WHEN rt.pAgent IN (224389,2129) THEN 0 ELSE rt.customerRate END,
						pAgentId = rt.pAgent,pBranchId =rt.pBranch,rt.cAmt,rt.pBank,rt.pBankBranch,payoutMethod = rt.paymentMethod,
                        paymentMethod = s.serviceTypeId,
                        rt.receiverName ,tr.address , tr.[state], tr.city , tr.mobile , tr.email , phone = tr.homePhone ,
                        relationship = rt.relWithSender , cAmt = CAST(cAmt AS DECIMAL(10, 2)) , collCurr ,
                        collMode ,
                        pAgent = CAST(pBank AS VARCHAR) + ISNULL('|' + pBankType, '') ,
                        pAgentName = pBankName ,
                        pBranch = pBankBranch ,
                        pBranchName = pBankBranchName ,
                        rt.accountNo ,
                        RI.receiverId,
						tr.firstName,
						tr.middleName,
						tr.lastName1,
						tr.state,
						tr.city,
						tr.address,
						tr.country,
						tr.relationType,
						tr.mobile,
						tr.email
                FROM    RemitTran rt WITH ( NOLOCK )
                INNER JOIN countryMaster cm WITH ( NOLOCK ) ON rt.pCountry = cm.countryName
				INNER JOIN TranReceivers tr WITH ( NOLOCK ) ON tr.tranId = rt.id
				INNER JOIN serviceTypeMaster s(nolock) on s.typeTitle = rt.paymentMethod
				LEFT JOIN dbo.receiverInformation RI (NOLOCK) ON RI.receiverId = tr.customerId
                WHERE  rt.id = @tranId;
			END;

			ELSE IF @flag = 'mostRecentTxn'
            BEGIN
                   DECLARE @totalSend MONEY, @totalSendText VARCHAR(200), @YearStart DATE, @YearEnd DATETIME,@vYearlyLimit MONEY

					SELECT @YearStart	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
						,@YearEnd	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)+' 23:59:59'
					
					SELECT @totalSend = SUM(ROUND(R.cAmt/(R.sCurrCostRate + ISNULL(R.sCurrHoMargin, 0)), 2, 0))
					FROM REMITTRAN R(NOLOCK) 
					INNER JOIN TRANSENDERS T(NOLOCK) ON T.TRANID = R.ID
					WHERE T.CUSTOMERID = @senderId 
					AND R.TRANSTATUS <> 'Cancel'
					AND R.approvedDate BETWEEN @YearStart AND @YearEnd

					
					SELECT @vYearlyLimit = amount
					FROM dbo.csDetail CD(NOLOCK)
					INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId 
					WHERE CD.period = 365
					AND CD.condition = 4600
					AND ISNULL(CD.isActive, 'Y') = 'Y' 
					AND ISNULL(CD.isDeleted, 'N') = 'N'
					AND ISNULL(CD.isEnable, 'Y') = 'Y'
					AND ISNULL(CM.isActive, 'Y') = 'Y'
					AND ISNULL(CM.isDeleted, 'N') = 'N'


					SET @totalSendText = 'Remaining sending limit for the year '+FORMAT(GETDATE(),'yyyy')+' = USD '+FORMAT((@vYearlyLimit - ISNULL(@totalSend, 0)),'0,00');
					
                    SELECT DISTINCT TOP 3
   							R.id ,
             				createdDate = CONVERT(VARCHAR, createdDate, 101) ,
                            receiverName ,
							paymentMethod ,
                            cAmt = CAST(cAmt AS DECIMAL(10, 2)) ,
                            tranStatus ,
           					collCurr,pCountry
                    FROM    REMITTRAN R ( NOLOCK ) -- needs to be remitTran For Every Successful Transaction
					INNER JOIN TRANSENDERS T(NOLOCK) ON T.TRANID = R.ID
					WHERE T.CUSTOMERID = @senderId 
					AND R.TRANSTATUS <> 'Cancel'
                    ORDER BY R.ID DESC;

					SELECT totalSendText = @totalSendText
            END

			ELSE IF @flag = 'txnSummary'
            BEGIN
				SELECT DISTINCT
                            id ,
							holdTranId,
          createdDate = CONVERT(VARCHAR, createdDate, 101) ,
                            receiverName ,
                            paymentMethod ,
                            cAmt = CAST(cAmt AS DECIMAL(10, 2)) ,
                            tranStatus ,
                            collCurr
               FROM    dbo.vwRemitTran WITH ( NOLOCK ) -- needs to be remitTran For Every Successful Transaction
					where createdby = @user AND sAgent=@sAgent --needs to retrieve for the specific sending agent
                    --WHERE   tranType = 'O'
     -- AND createdBy = @user -- for sepecific user for now commented
              ORDER BY holdTranId DESC;
            END;

			ELSE IF @flag = 'hasScheme'
			BEGIN
					DECLARE @todayDate DATETIME;
					SET @todayDate = GETDATE();
	
					IF EXISTS ( SELECT 'X' FROM dbo.schemeSetup WITH ( NOLOCK )
								WHERE sCountry = @sCountryId
								AND sAgent = @sAgent
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N' )
					BEGIN
					IF @schemeId IS NULL
								SELECT @schemeId = rowId
								FROM dbo.schemeSetup WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent = @sAgent
								AND sBranch = NULL
								AND rCountry = @pCountryId
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N'
								AND ISNULL(couponCode, 'x') = @couponCode;
					IF @schemeId IS NULL
								SELECT @schemeId = rowId
								FROM dbo.schemeSetup WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent = @sAgent
								AND sBranch = @sBranch
								AND rCountry = @pCountryId
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
					IF @schemeId IS NULL
								SELECT @schemeId = rowId
								FROM dbo.schemeSetup WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent = @sAgent
								AND sBranch = @sBranch
								AND rCountry IS NULL
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
					IF @schemeId IS NULL
								SELECT
								@schemeId = rowId
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent = @sAgent
								AND sBranch IS NULL
								AND rCountry = @pCountryId
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
					IF @schemeId IS NULL
								SELECT
								@schemeId = rowId
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent = @sAgent
								AND sBranch IS NULL
								AND rCountry IS NULL
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
				END;	
	
				IF EXISTS ( SELECT 'X'
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent IS NULL
								AND sBranch IS NULL
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N' )
				BEGIN
				IF @schemeId IS NULL
								SELECT
								@schemeId = rowId
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent IS NULL
								AND sBranch IS NULL
								AND rCountry = @pCountryId
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
				IF @schemeId IS NULL
								SELECT
								@schemeId = rowId
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry = @sCountryId
								AND sAgent IS NULL
								AND sBranch IS NULL
								AND rCountry IS NULL
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
				END;
	
					IF EXISTS ( SELECT
								'X'
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry IS NULL
								AND sAgent IS NULL
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N' )
						BEGIN
							IF @schemeId IS NULL
								SELECT
								@schemeId = rowId
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry IS NULL
								AND sAgent IS NULL
								AND sBranch IS NULL
								AND rCountry = @pCountryId
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
							IF @schemeId IS NULL
							SELECT
								@schemeId = rowId
								FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
								WHERE
								sCountry IS NULL
								AND sAgent IS NULL
								AND sBranch IS NULL
								AND rCountry IS NULL
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N';
						END;
	
					IF @schemeId IS NOT NULL
						BEGIN
							DECLARE @multipleSchemeId INT;
							SELECT
								@multipleSchemeId = rowId
							FROM
								dbo.schemeSetup
								WITH ( NOLOCK )
							WHERE
								sCountry = @sCountryId
								AND sAgent = @sAgent
								AND sBranch IS NULL
								AND rCountry = @pCountryId
								AND @todayDate BETWEEN schemeStartDate AND schemeEndDate
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N'
								AND couponCode = @couponCode;
		
							IF @multipleSchemeId IS NOT NULL
								SELECT '0' errorCode , 'Scheme is Available.' msg , @multipleSchemeId id;
							ELSE
								SELECT '0' errorCode , 'Scheme is Available.' msg , @schemeId id;
						END;
					ELSE
						BEGIN
							SELECT '1' errorCode , 'Scheme is NOT Available.' msg , @schemeId id;
						END;
				END;

				ELSE IF @flag = 'checkSingleTxn'
                BEGIN		 
                    IF ( SELECT approvedDate FROM customerMaster WITH ( NOLOCK )  WHERE customerId = @user AND ISNULL(onlineUser, 'N') = 'Y' ) IS NULL
                    BEGIN                       
                        SELECT  '1' ErrorCode ,
                                'Sorry! Your customer verification is in pending.
								 Kindly visit to our nearest agent/branch to verify your document.' Msg,
                                @user Id;
       RETURN;
                    END;

					ELSE IF (SELECT availableBalance FROM dbo.customerMaster WITH (NOLOCK) WHERE customerId=@user AND ISNULL(onlineUser,'N')='Y') IS NULL
					BEGIN
						SELECT '1' ErrorCode, 'Sorry! You have no balance in your GME Wallet' Msg, @user Id;
						RETURN;
					END

                    ELSE
     BEGIN
                        SELECT  '0' ErrorCode ,'You are authorised to send transaction.' Msg ,  @user Id;
                        RETURN;
    END;
                   
                END;
  
	END;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT <> 0
            ROLLBACK TRANSACTION;
		
        DECLARE @errorMessage VARCHAR(MAX);
        SET @errorMessage = ERROR_MESSAGE();
	
        EXEC proc_errorHandler 1, @errorMessage, @user;
	
END CATCH

GO
