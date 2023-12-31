USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_Online_sendTxn_Test]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_Online_sendTxn_Test]
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
	  @tpRefNo varchar(20) = null,
	  @tpTranId varchar(20) = null
    )
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

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
            @pSuperAgentName VARCHAR(100),
            @pStateId INT,
            @senderName VARCHAR(100) ,
            @id INT ,
            @customerStatus VARCHAR(20) ,
            @idExpiryDate DATETIME;
		
		DECLARE @errorCode CHAR(1)= '0' ,@agentAvlLimit MONEY;

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
            
        SET @GMTDate = dbo.FNAGMTOnline(GETDATE(), @user);
	
		SELECT @sAgent = sAgent, @sAgentName = sAgentName, @sBranch = sBranch, @sBranchName = sBranchName,
				@sSuperAgent = sSuperAgent, @sSuperAgentName = sSuperAgentName 
		FROM dbo.FNAGetBranchFullDetails(@sBranch)

			
		IF @pCountryId IS NULL
			SELECT @pCountryId = countryId FROM countryMaster (NOLOCK) WHERE countryName = @pCountry

		IF @pCountry LIKE '%?%'
			SELECT @pCountry = COUNTRYNAME FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYID = @pCountryId

        SELECT  @pBank = CASE WHEN @pCountryId = 36 THEN 221226 ELSE @pAgent END,
                @pBankName = CASE WHEN @pAgentName IS NULL THEN (SELECT agentName FROM agentMaster WHERE agentId = @pAgent) ELSE @pAgentName END,
                @pBankBranch = @pBranch ,
				@pBankBranchName = CASE WHEN @pBranchName IS NULL THEN (SELECT agentName FROM agentMaster WHERE agentId = @pBranch) ELSE @pBranchName END;
        SELECT  @pAgent = CASE WHEN @pCountryId = 36 THEN 221226 ELSE NULL END ,
                @pAgentName = NULL ,
                @pBranch = NULL ,
                @pBranchName = NULL;
          
		
		SET @sCountryId = 118
		SET @sCountry = 'South Korea'
		SET @sAgentCommCurrency = 'KRW'
        IF @flag = 'exRate'			--Get Exchange Rate, Service Charge, Scheme/Offer and amount details
        BEGIN
            SELECT TOP 1
                    @senderId = customerId ,
                    @idExpiryDate = idExpiryDate ,
                    @createdDate = createdDate,
					@sIdNo		 = idNumber,
					@sIdType	 = idType,
					@customerStatus = CASE WHEN customerStatus IS NULL THEN 'pending' ELSE 'verified' END,
					@todaysTotalSent = ISNULL(todaysSent, 0)
            FROM  customerMaster WITH ( NOLOCK ) WHERE email = @user;		
		
            select @sIdType = detailTitle from staticDataValue(nolock) where valueId = @sIdType

			SELECT  @scValue = 0 ,
                    @exRateOffer = 0 ,
                    @scDiscount = 0 ,
                    @AmountLimitPerTran = 3000,
					@AmountLimitPerDay = 20000
			
            IF ( @idExpiryDate < GETDATE() )
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
            AND currency = @pCurr AND (tranType IS NULL OR tranType = @deliveryMethod);
			
            SET @currDecimal = ISNULL(@currDecimal, 0);
		    
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
				dbo.FNAGetCustomerRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent, @pCurr,@deliveryMethod);
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
				IF @pCountryId = 36
				BEGIN
					SET @pAmt = @cAmt * @exRate
					SELECT  @serviceCharge = amount
					FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
					@pCountryId,@pSuperAgent,@pAgent,NULL,@deliveryMethod,@pAmt,@collCurr);
				END
				ELSE
				BEGIN
					SELECT  @serviceCharge = amount
					FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
					@pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,@cAmt,@collCurr);
				END
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
				
                SET @pAmt = ( @cAmt-@serviceCharge ) * @exRate
							
				SET @pAmt = ROUND(@pAmt,@currDecimal)
            END;
            ELSE
            IF @calBy = 'P'
			BEGIN
				SET @tAmt = @pAmt / @exRate

				IF @pCountryId = 36
				BEGIN
					SELECT  @serviceCharge = amount
					FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
					@pCountryId,@pSuperAgent,@pAgent,NULL,@deliveryMethod,@pAmt,@collCurr);
				END
				ELSE
				BEGIN
					
                    SELECT  @serviceCharge = amount
                    FROM    [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
										@pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,
                                                @tAmt, @collCurr);
				END

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
			SET @msg = 'Success';
		
			---------Compliance Checking Begin--------------------------------
			
			DECLARE @complianceRuleId INT, @cAmtUSD MONEY
  
			SELECT 
				@sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
			FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

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
	
--	select  flag			= 'sender-limit'
--				,user1			= @user
--				,sIdType		= @sIdType
--				,sIdNo			= @sIdNo
--				,cAmt			= @cAmt
--				,cAmtUSD		= @cAmtUSD
--				,customerId	= @senderId
--				,pCountryId	= @pCountryId
--				,deliveryMethod= @deliveryMethod
--				,message1		= @complienceMessage
--				,shortMessage  = @shortMsg   
--				,errCode		= @complienceErrorCode
--				,ruleId		= @complianceRuleId 
--return
			EXEC [proc_complianceRuleDetail]
				 @flag			= 'sender-limit'
				,@user			= @user
				,@sIdType		= @sIdType
				,@sIdNo			= @sIdNo
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

				set @complienceErrorCode = 1

				INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName
				, receiverCountry,payOutAmt,complianceId,complianceReason,complainceDetailMessage,createdBy,createdDate,logType)

				SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName
				, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),'online'
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
			if exists(select 'a' from customerMaster(nolock) where email = @user)
			begin
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

			end
			--Bank compare
			DECLARE @bankName VARCHAR(25) = 'Bank', @bankRate MONEY, @bankPayout MONEY, @bankFee MONEY
				, @bankSave MONEY, @bankTransafer MONEY

			SELECT @bankRate = customerRate, @bankFee = serviceCharge FROM bankTransferSettings(NOLOCK)

			SELECT @bankTransafer = @cAmt - @bankFee
			SELECT @bankPayout = @bankTransafer * @bankRate
			SELECT @bankSave = @pAmt - @bankPayout

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
					bankTransafer = @bankTransafer,
					bankPayout = @bankPayout,
					bankRate = @bankRate,
					bankFee = @bankFee,
					bankSave = @bankSave,
					bankName = @bankName,

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
					tpExRate = '',
					tpPCurr = '', 
                    schemeAppliedMsg = CASE WHEN @schemeId IS NOT NULL AND @couponCode IS NOT NULL
                                            THEN 'Congratulations. Voucher Code has been applied.'
              ELSE ''
 END ,
         schemeId = @schemeId;
        END;

		IF @flag = 'i'					--Send Transaction
        BEGIN	
			IF @user = 'demo.gme@gmeremit.com'
			BEGIN
				EXEC proc_errorHandler 1,'You can not send money through test GME acocunt :(', NULL;
                RETURN;
			END

			IF NOT EXISTS (SELECT 'X' FROM dbo.customerMaster(nolock) WHERE email = @user and approvedDate is not null)
			BEGIN
				EXEC proc_errorHandler 1,'You are not authorized to perform transaction :(', NULL;
                RETURN;
			END

			SELECT @agentAvlLimit = [dbo].FNAGetCustomerACBal(@user);
			SET @agentAvlLimit = ISNULL(@agentAvlLimit, 0);
			IF ISNULL(@agentAvlLimit, 0) < ISNULL(@cAmt, 0)
			BEGIN
				EXEC proc_errorHandler 1,'You donot have sufficient balance to do the transaction', NULL;
				RETURN;
			END;

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
		
            SET @controlNo = '80' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 9);
			
            SELECT  @controlNoEncrypted = dbo.FNAEncryptString(@controlNo);
		
            IF EXISTS ( SELECT 'X'FROM remitTranTempOnline WITH (NOLOCK)WHERE controlNo = @controlNoEncrypted )
            BEGIN
                EXEC proc_errorHandler 1, 'Technical error occurred. Please try again',NULL;
                RETURN;
            END;
		
            IF EXISTS ( SELECT TOP 1'X' FROM pinQueueList WITH (NOLOCK) WHERE  icn = @controlNoEncrypted )
            BEGIN
                EXEC proc_errorHandler 1, 'Technical error occurred. Please try again',NULL;
                RETURN;
            END;
				
            IF @deliveryMethod IN ( 'Cash Payment', 'Door to Door' )
            BEGIN
                IF @pBank IS NOT NULL
                BEGIN
                    SELECT  @pAgent = @pBank ,@pAgentName = @pBankName;
                    IF @pBankBranch IS NOT NULL
                        SELECT  @pBranch = @pBankBranch , @pBranchName = @pBankBranchName;
                END;
            END;
            ELSE
            IF @deliveryMethod = 'Bank Deposit'
            BEGIN                               
				IF NOT EXISTS(SELECT 'A' FROM agentMaster(nolock) where agentId = @pBank and agenttype =2903 and IsIntl = 1)
				BEGIN	
					EXEC proc_errorHandler 1, 'Invalid bank selected', NULL
					return
				END	
				SELECT @pAgent = bankpartnerId from AgentBankMapping(NOLOCK) WHERE bankId = @pBank
				SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
						@pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
				FROM dbo.FNAGetBranchFullDetails(@pAgent)
            END;
			
			--##Get Voucher Details into temp table END##--
			IF @pCountryId = '203' --@pCountry ='VIETNAM' 
			BEGIN
				SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
					   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
				FROM dbo.FNAGetBranchFullDetails(2090)

				SELECT
						@pAgentComm	= (SELECT amount FROM dbo.FNAGetPayComm
						(@sAgent,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry), 
						NULL, null, @pCountryId, null, @pAgent, 'USD'
						,@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL))
						,@pAgentCommCurrency	= 'KRW'

			END
			ELSE IF @pCountryId = 36
			BEGIN
				SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
					   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
				FROM dbo.FNAGetBranchFullDetails(@pAgent)

				SELECT
						@pAgentComm	= (SELECT amount FROM dbo.FNAGetPayComm
						(@sAgent,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry), 
						NULL, null, @pCountryId, null, @pAgent, 'USD'
						,@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL))
						,@pAgentCommCurrency	= 'USD'

			END
			
			--Get Service Charge----------------------------------------------------------------------------------------------------------------------
			IF @pCountryId = 36 ----## FOR CAMBODIA
			BEGIN
				SELECT @iServiceCharge = ISNULL(amount, -1) 
				FROM [dbo].FNAGetServiceCharge(
									@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
									@pCountryId, @pSuperAgent, @pAgent, NULL, 
									@deliveryMethodId, @pAmt, @collCurr
								) 
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
			
			SELECT  @iServiceCharge = @serviceCharge , @customerRate = @exRate;
		
			--End Service Charge-------------------------------------------------------------------------------------------------------------------------------------
		
			--4. Get Exchange Rate Details------------------------------------------------------------------------------------------------------------------
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
			FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)
		 
			IF @customerRate IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
				RETURN
			END
			DECLARE @iMsg VARCHAR(MAX)
			IF isnull(@exRate,0) <> isnull(@customerRate,1)
			BEGIN
				SET @iMsg = 'Amount detail not match. Please re-calculate the amount again' + CAST(isnull(@exRate,0) AS VARCHAR) + ' : ' + CAST(isnull(@customerRate,1) AS VARCHAR) 
				EXEC proc_errorHandler 1, @iMsg, NULL
				RETURN
			END

			SELECT TOP 1 @senderId = customerId FROM customerMaster WITH(NOLOCK) WHERE email = @user;	
			
			IF @benId IS NOT NULL
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM receiverInformation (NOLOCK) WHERE customerId = @senderId AND receiverId = @benId)
				BEGIN
					EXEC proc_errorHandler 1,'Invalid receiver Id!', NULL;
					RETURN;
				END
			END

			DECLARE @scDisc MONEY

			SELECT @iCustomerRate = @exRate, @iTAmt = @cAmt - @iServiceCharge

			SELECT @place = place, @currDecimal = currDecimal
			FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
			AND currency = @pCurr AND (tranType IS NULL OR tranType = @deliveryMethodId)
		
			SET @currDecimal = ISNULL(@currDecimal, 0)
			SET @place = ISNULL(@place, 0)
	
			SET @iPAmt = ROUND(@iTAmt * @iCustomerRate, @currDecimal)
			----## WHILE CALCULATING FROM PAYOUT AMOUNT CONSIDARING 10 VND 
			IF @pCurr = 'VND' AND ISNULL(@iPAmt,0) < ISNULL(@pAmt,1)+10
			BEGIN
				SET @pAmt = ISNULL(@iPAmt,0)
			END
			IF @pCurr = 'IDR' AND ISNULL(@iPAmt,0) > ISNULL(@pAmt,1)+10
			BEGIN
				SET @pAmt = ISNULL(@iPAmt,0)
			END
			
			IF ISNULL(@iPAmt,0) <> ISNULL(@pAmt,1)
			BEGIN
				SET @iMsg = 'Amount detail not match. Please re-calculate the amount again.' + CAST(@iPAmt AS VARCHAR) + ' - ' +  CAST(@pAmt AS VARCHAR)
				EXEC proc_errorHandler 1, @iMsg, NULL
				RETURN
			END
			

			SELECT  @SENDERS_IDENTITY_TYPE = CASE WHEN idType = '1302'THEN 'P' WHEN idType = '7316' THEN 'N' END ,
						@sIdNo = idNumber ,
						@senderName = isnull(fullName, firstname)
				FROM    customerMaster
				WHERE   customerId = @senderId; 

			--OFAC Checking
			DECLARE @receiverOfacRes VARCHAR(MAX), @ofacRes VARCHAR(MAX), @ofacReason VARCHAR(200)
			EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @ofacRes OUTPUT
			EXEC proc_ofacTracker @flag = 't', @name = @rfName, @Result = @receiverOfacRes OUTPUT
			
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
			EXEC [proc_complianceRuleDetail]
				@flag			= 'receiver-limit'
				,@user			= @user
				,@sIdType		= @sIdType
				,@sIdNo			= @sIdNo
				,@receiverName  = @rfName
				,@cAmt			= @cAmt
				,@cAmtUSD		= @cAmtUSD
				,@customerId	= @senderId
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

				set @complienceErrorCode = 1

				INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName
				, receiverCountry,payOutAmt,complianceId,complianceReason,complainceDetailMessage,createdBy,createdDate,logType)

				SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName
				, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),'online'

				DECLARE @tempCompId BIGINT = @@IDENTITY
			END	   
			
			IF @complienceErrorCode = 1
			BEGIN
				EXEC proc_errorHandler 1, @shortMsg, NULL
				RETURN;
			END;

			--Compliance checking end
		
            DECLARE @agentFxGain MONEY;
            SET @agentFxGain = ((@tAmt) * (@agentCrossSettRate- (@customerRate + ISNULL(@schemePremium,0))))/ @agentCrossSettRate;
		
			--**********Customer Per Day Limit Checking**********
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
                EXEC proc_errorHandler 1, 'Similar transaction found', NULL;
				RETURN;
            END;
			
			-- #########country and occupation  risk point
            DECLARE @countryRisk INT ,@OccupationRisk INT ,@isFirstTran CHAR(1);
			
		
            DECLARE @VNo VARCHAR(20); 

			BEGIN TRANSACTION;
				INSERT  INTO remitTranTempOnline
				( 
				controlNo ,sCurrCostRate ,sCurrHoMargin ,sCurrSuperAgentMargin ,sCurrAgentMargin ,pCurrCostRate ,pCurrHoMargin ,pCurrSuperAgentMargin ,
				pCurrAgentMargin ,agentCrossSettRate ,customerRate ,sAgentSettRate ,pDateCostRate ,treasuryTolerance ,customerPremium ,schemePremium ,sharingValue ,
				sharingType ,serviceCharge ,handlingFee ,agentFxGain ,sAgentComm ,sAgentCommCurrency ,sSuperAgentComm ,sSuperAgentCommCurrency ,pAgentComm ,pAgentCommCurrency ,
				pCommissionType ,pSuperAgentComm ,pSuperAgentCommCurrency ,promotionCode ,pMessage ,sSuperAgent ,sSuperAgentName ,sAgent ,sAgentName ,sBranch ,
				sBranchName ,sCountry ,pSuperAgent ,pSuperAgentName ,pAgent ,pAgentName ,pBranch ,pBranchName ,pCountry ,paymentMethod ,pBank ,pBankName ,pBankBranch ,pBankBranchName ,
				accountNo ,pBankType ,expectedPayoutAgent ,collMode ,collCurr ,tAmt ,cAmt ,pAmt ,payoutCurr ,relWithSender ,purposeOfRemit ,sourceOfFund ,tranStatus ,payStatus ,createdDate ,
				createdDateLocal ,createdBy ,tranType ,voucherNo ,senderName ,receiverName ,calBy ,isOnlineTxn ,schemeId ,ScOrderNo ,UnitaryBankAccountNo,pState,pDistrict
				)
				SELECT 
				@controlNoEncrypted ,@sCurrCostRate ,@sCurrHoMargin ,@sCurrSuperAgentMargin ,@sCurrAgentMargin ,@pCurrCostRate ,@pCurrHoMargin ,@pCurrSuperAgentMargin ,
				@pCurrAgentMargin ,@agentCrossSettRate ,@customerRate ,@sAgentSettRate ,@pDateCostRate ,@treasuryTolerance ,@customerPremium ,ISNULL(@schemePremium, 0) ,
				@sharingValue , @sharingType , @serviceCharge ,ISNULL(@scDiscount, 0) ,@agentFxGain ,@sAgentComm ,@sAgentCommCurrency ,@sSuperAgentComm ,@sSuperAgentCommCurrency ,@pAgentComm ,@pAgentCommCurrency ,
				@pCommissionType , @pSuperAgentComm ,@pSuperAgentCommCurrency ,@agentRefId ,@payMsg ,@sSuperAgent , @sSuperAgentName ,@sAgent ,@sAgentName ,@sBranch ,@sBranchName ,@sCountry , @pSuperAgent ,
				@pSuperAgentName , @pAgent , @pAgentName , @pBranch ,@pBranchName ,@pCountry ,@deliveryMethod ,@pBank , @pBankName ,@pBankBranch ,@pBankBranchName ,@raccountNo ,@pBankType , @pAgentName ,@collMode , @collCurr ,@tAmt , @cAmt ,
				@pAmt , @pCurr , @relationship , @purpose ,@sourceOfFund ,'Hold' ,'Unpaid' ,@GMTDate ,
				GETDATE() , @user ,'O' , @VNo , @senderName , @rfName ,@calBy , 'Y' ,@schemeId ,@ScOrderNo ,@unitaryBankAccountNo,@RLocation,@RState;
				
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
                                FROM    receiverInformation(nolock)
                                WHERE   ISNULL(firstName, '') = ISNULL(@fName, '')
                        AND ISNULL(middleName, '') = ISNULL(@mName, '')
                                        AND ISNULL(lastName1, '') = ISNULL(@lName, '')
										AND ISNULL(lastName2, '') = ISNULL(@lName2, '')
                                        AND customerId = @senderId )
                    BEGIN				 
						INSERT INTO receiverInformation
						( customerId ,firstName,middleName,lastName1,lastName2 ,country ,address ,city ,email ,homePhone 
							,workPhone ,mobile ,relationship,state,district)
						SELECT  @senderId ,firstName,middleName,lastName1,lastName2,@pCountry,@rAdd1,@rCity,@rEmail,@rTel
							,@rTel,@rMobile,@relationship,@RLocationText,@RStateText
						FROM dbo.FNASplitName(@rfName);
					
								SET @benId = @@IDENTITY;
                    END;
                    ELSE
                    BEGIN
                        SELECT TOP 1 @benId = receiverId
                        FROM    receiverInformation(nolock)
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
                            FROM dbo.receiverInformation(nolock)
					WHERE receiverId = @benId
					UPDATE dbo.receiverInformation
					SET   firstName             =ISNULL( @fName       ,@firstName) 
                            , middleName 		=ISNULL( @mName		  ,@midName)
                            , lastName1 		=ISNULL( @lName		  ,@lastName)
                            , lastName2 		=ISNULL( @lName2	  ,@lastName2)
                            , country 			=ISNULL( @pCountry	  ,@payCountry)
                            , address 			=ISNULL( @rAdd1		  ,@recAdd1)
                            , city 				=ISNULL( @rCity		  ,@reccity)
							, state				=isnull( @RLocationText,@recState)
							, district			=isnull(@RStateText   ,@recDistrict)
                            , email 			=ISNULL( @rEmail	  ,@recEmail)
							, homePhone 		=ISNULL( @rTel		  ,@recTel)
                            , workPhone 		=ISNULL( @rTel		  ,@recTel)
                            , mobile 			=ISNULL( @rMobile	  ,@recMobile)
                            , relationship		=ISNULL( @relationship,@recRelationship)
					WHERE receiverId	= @benId
				END								
                INSERT  INTO tranReceiversTempOnline( tranId ,customerId ,membershipId ,firstName ,middleName ,lastName1 ,lastName2 ,fullName ,
                            country ,[address] ,[state] ,district ,zipCode ,city ,email ,homePhone ,workPhone ,mobile ,nativeCountry ,dob ,
                            placeOfIssue ,idType ,idNumber ,idPlaceOfIssue ,issuedDate ,relationType,validDate ,gender
			            )
                SELECT  @id ,@benId ,NULL ,firstName ,middleName ,lastName1 ,lastName2 ,@rfName ,
                        @pCountry ,@rAdd1 ,@RLocationText ,@RStateText ,null ,@rCity, @rEmail ,@rTel ,@rTel ,@rMobile ,@rNaCountry ,@rdob ,
						NULL ,@rIdType ,@rIdNo ,NULL ,NULL ,@relationship,@rIdValid ,NULL
                FROM    dbo.FNASplitName(@rfName);		
			
                INSERT  INTO collectionDetailsOnline
                        ( tranId ,collMode ,countryBankId ,amt ,collDate ,narration ,branchId ,createdBy ,createdDate
                        )
                SELECT  @id ,@collMode ,0 ,@cAmt ,@GMTDate ,'online' ,NULL ,@memberShipId ,GETDATE();
		   
				EXEC proc_online_temp_to_main @id = @id OUTPUT,@voucherDetails= @VoucherXML


				EXEC proc_UpdateCustomerBalance @controlNo = @controlNoEncrypted, @type = 'deduct'
		
				--------------------------#########------------OFAC/COMPLIANCE INSERT (IF EXISTS)---------------########----------------------
				IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId)
				BEGIN
					INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
					SELECT @id, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId
					SET @compFinalRes = 'C'
				END

				IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> '')
				BEGIN
					IF @pCountryId IN (36)
					BEGIN
						SET @complienceMessage = ISNULL('Compliance: ' + @shortMsg, '') + ISNULL('Ofac: ' + @ofacRes, '') + ISNULL(' ' + @receiverOfacRes, '') 
						
						INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName
							, receiverCountry,payOutAmt,complianceId,complianceReason,complainceDetailMessage,createdBy,createdDate,logType)
						
						SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName
							, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),'reject_log'

						SET @tempCompId = @@IDENTITY

						IF ISNULL(@tempCompId, 0) = 0
							SET @msg = 'Your transaction is under Compliance/OFAC Please refer ' + CAST(@tempCompId AS VARCHAR) + ' code to HEAD OFFICE';
						
						EXEC proc_errorHandler 1, @msg, NULL;
						EXEC proc_ApproveHoldedTXN @flag = 'reject', @user = @user , @id = @id
						RETURN
					END

					IF((ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> '') AND ISNULL(@compFinalRes, '') = '')
					BEGIN
						IF ISNULL(@ofacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
						
						IF ISNULL(@receiverOfacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tranId, @receiverOfacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@receiverOfacRes)

						UPDATE remitTranTemp SET
								tranStatus	= 'OFAC Hold'
						WHERE id = @id
					END
					
					ELSE IF(@compFinalRes <> '' AND (ISNULL(@ofacRes, '') = '' OR ISNULL(@receiverOfacRes, '') = ''))
					BEGIN
						UPDATE remitTranTemp SET
								tranStatus	= 'Compliance Hold'
						WHERE id = @id
					END
			
					ELSE IF(ISNULL(@compFinalRes, '') <> '' AND (ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> ''))
					BEGIN
						IF ISNULL(@ofacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
						
						IF ISNULL(@receiverOfacRes, '') <> ''
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @tranId, @receiverOfacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@receiverOfacRes)
				
						UPDATE remitTranTemp SET
								tranStatus	= 'OFAC/Compliance Hold'
						WHERE id = @id
					END
				END
				--Compliance checking

				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
					SElect 0 errorCode, 'Transaction has been sent successfully' msg, @id id, @controlNo extra;
			
				IF @pCountryId <> 36
					exec [proc_ApproveHoldedTXN]  @flag = 'approve', @id = @id,@user = 'admin'
				RETURN                		
		END;
		
		ELSE IF @flag = 'approve-wing'
		BEGIN
			select @id = id, @deliveryMethod = paymentMethod from remitTranTemp (nolock) where controlno = dbo.FNAEncryptString(@controlNo)
			
			if @deliveryMethod <> 'BANK DEPOSIT'
				update remitTranTemp set controlno = dbo.FNAEncryptString(@tpRefNo) where id = @id

			EXEC [proc_ApproveHoldedTXN]  @flag = 'approve', @id = @id,@user = 'admin'

			SELECT @id = id FROM remitTran (NOLOCK) WHERE controlno = case when @deliveryMethod = 'BANK DEPOSIT' then dbo.FNAEncryptString(@controlNo) else dbo.FNAEncryptString(@tpRefNo) end

			UPDATE remitTran SET controlno		= case when @deliveryMethod = 'BANK DEPOSIT' then dbo.FNAEncryptString(@controlNo) else dbo.FNAEncryptString(@tpRefNo) end
								,controlNo2		= dbo.FNAEncryptString(@controlNo)
								,ContNo			= @tpTranId
								,paystatus		= 'Post'
								,postedBy		= @user
								,postedDate		= getdate()
								,postedDateLocal = getdate()
			WHERE id = @id

			SELECT 0 ErrorCode,'Transaction has been sent successfully' Msg, @id id, case when @deliveryMethod = 'BANK DEPOSIT' then @controlNo else @tpRefNo end extra

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
						rt.sourceOfFund, rt.pBankName, rt.pBankBranchName, rt.serviceCharge, rt.collCurr, rt.customerRate,
						pAgentId = rt.pAgent,pBranchId =rt.pBranch,rt.cAmt,rt.pBank,rt.pBankBranch,payoutMethod = rt.paymentMethod,
                        paymentMethod = CASE
                                WHEN rt.paymentMethod = 'BANK DEPOSIT'
                                THEN '2'
                                WHEN rt.paymentMethod = 'CASH PAYMENT'
                                THEN '1'
								WHEN rt.paymentMethod = 'HOME DELIVERY'
								THEN '12'
                                END ,
                        rt.receiverName ,tr.address , tr.[state], tr.city , tr.mobile , tr.email , phone = tr.homePhone ,
                        relationship = rt.relWithSender , cAmt = CAST(cAmt AS DECIMAL(10, 2)) , collCurr ,
                        collMode ,
                        pAgent = CAST(pBank AS VARCHAR) + ISNULL('|' + pBankType, '') ,
                        pAgentName = pBankName ,
                        pBranch = pBankBranch ,
                        pBranchName = pBankBranchName ,
                        rt.accountNo ,
                        receiverId = x.recCustId,
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
                FROM    vwRemitTran rt WITH ( NOLOCK )
                        INNER JOIN countryMaster cm WITH ( NOLOCK ) ON rt.pCountry = cm.countryName
						INNER JOIN vwTranReceivers tr WITH ( NOLOCK ) ON tr.tranId = rt.id
						LEFT JOIN (
                        SELECT RI.receiverId AS recCustId, tr.customerId FROM vwTranReceivers tr WITH ( NOLOCK ) 
						LEFT JOIN dbo.receiverInformation RI (NOLOCK) ON RI.receiverId = tr.customerId
						) X ON X.customerId = tr.customerId
                WHERE   rt.id = @tranId;
			END;

			ELSE IF @flag = 'mostRecentTxn'
            BEGIN
                    SELECT DISTINCT TOP 3
   							id ,
							holdTranId,
             				createdDate = CONVERT(VARCHAR, createdDate, 101) ,
                            receiverName ,
                           paymentMethod ,
                            cAmt = CAST(cAmt AS DECIMAL(10, 2)) ,
                            tranStatus ,
           					collCurr,pCountry
                    FROM    dbo.vwRemitTran WITH ( NOLOCK ) -- needs to be remitTran For Every Successful Transaction
					where createdby = @user AND sAgent = @sAgent 
					--needs to retrieve for the specific sending agent
                    --WHERE   tranType = 'O'
                            -- AND createdBy = @user -- for sepecific user for now commented
                    ORDER BY holdTranId DESC;
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
	
    END CATCH;
GO
