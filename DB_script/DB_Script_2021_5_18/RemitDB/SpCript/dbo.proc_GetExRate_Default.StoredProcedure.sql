USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetExRate_Default]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_GetExRate_Default]
@flag varchar(20),
@user varchar(150),
@pCountryId INT,
@pCurr VARCHAR(5),
@deliveryMethod VARCHAR(20),
@cAmt MONEY,
@pAmt MONEY,
@calBy CHAR(1),
@agentRefId VARCHAR(50) = null,
@pCountry VARCHAR(50),
@tpExRate FLOAT = NULL,
@tpPCurr VARCHAR(5)= NULL

AS
SET NOCOUNT ON ;

declare @payOutPartner bigint
declare @sCountryId int=118,@sAgent int=2080,@sSuperAgent int=1008 ,@sBranch int ,@collCurr varchar(5)='KRW'
DECLARE @scValue MONEY,@exRateOffer MONEY,@scDiscount MONEY ,@AmountLimitPerTran MONEY,@AmountLimitPerDay MONEY

DECLARE @place INT,@currDecimal INT,@exRate FLOAT,@serviceCharge MONEY,@tAmt MONEY

DECLARE @pSuperAgent INT,@pSuperAgentName VARCHAR(200),@pAgent BIGINT,@pAgentName VARCHAR(200),@pBranch INT,@pBranchName VARCHAR(200)

DECLARE @errorCode INT,@msg VARCHAR(MAX)

select @pCountryId = countryId from countryMaster(nolock) where countryName = @pCountry

SELECT @payOutPartner = AgentId FROM TblPartnerwiseCountry (NOLOCK)
	WHERE COUNTRYID = @pCountryId
	AND ISNULL(PaymentMethod, @deliveryMethod) = @deliveryMethod 
	AND IsActive = 1

SELECT TOP 1 @pAgent = AM.agentId
	FROM agentMaster AM(NOLOCK) 
	WHERE AM.parentId = @payOutPartner AND agentType=2903 AND AM.isSettlingAgent = 'Y' AND AM.isApiPartner = 1

SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
			@pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
	FROM dbo.FNAGetBranchFullDetails(@pAgent)

IF @flag = 'exRate'
BEGIN
			IF @payOutPartner IN (224388,2140) and @pCurr <>'USD' --## TANGLO,MTRADE
            BEGIN
				SELECT  '5' ErrorCode ,
                    'Thirdparty transaction' Msg ,
                    PayoutPartner = @payOutPartner
                RETURN;
			END;

			SELECT  @scValue = 0 ,
                    @exRateOffer = 0 ,
                    @scDiscount = 0 ,
                    @AmountLimitPerTran = 3000,
					@AmountLimitPerDay = 20000
			
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
                    customerTotalSentAmt = 0 ,
                    maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
                RETURN;
			END;
			
			SELECT  @exRate = 
				dbo.FNAGetCustomerRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent, @pCurr,@deliveryMethod);
            IF @exRate IS NULL
            BEGIN
                SELECT  '1' ErrorCode ,
                    'Exchange rate not defined yet for receiving currency ('+ @pCurr + ')' Msg ,
                    amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0 ,
                    maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
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
				ELSE IF @pCountryId = 42 AND @pCurr = 'USD' and @deliveryMethod = 2
				BEGIN
					SELECT  @serviceCharge = amount
					FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
					@pCountryId,@pSuperAgent,@pAgent,NULL,@deliveryMethod,@pAmt,'USD');
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
                        customerTotalSentAmt = 0 ,
						maxAmountLimitPerTran = @AmountLimitPerTran ,
						PerTxnMinimumAmt = @AmountLimitPerDay;
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
				ELSE IF @pCountryId = 42 AND @pCurr = 'USD' and @deliveryMethod = 2
				BEGIN
					SELECT  @serviceCharge = amount
					FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
					@pCountryId,@pSuperAgent,@pAgent,NULL,@deliveryMethod,@pAmt,'USD');
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
                        customerTotalSentAmt = 0 ,
						maxAmountLimitPerTran = @AmountLimitPerTran ,
						PerTxnMinimumAmt = @AmountLimitPerDay;
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
                    customerTotalSentAmt = 0 ,
                    maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
                RETURN;
            END;
			
			--4. Validate Country Sending Limit 
            EXEC PROC_CHECKCOUNTRYLIMIT @flag = 's-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = NULL
				,@deliveryMethod = @deliveryMethod,@sendingCustType = NULL,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
				,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
				,@msg = @msg OUT, @errorCode = @errorCode OUT

			IF @errorCode <> '0'
			BEGIN
				SELECT  @errorCode ErrorCode ,
                    @msg Msg ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0 ,
					maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
				RETURN;
			END
			--Validate Country Sending Limit END

			--5. Validate Country Receiving Limit
            EXEC PROC_CHECKCOUNTRYLIMIT @flag = 'r-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = NULL
				,@deliveryMethod = @deliveryMethod,@sendingCustType = NULL,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
				,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
				,@msg = @msg OUT, @errorCode = @errorCode OUT
			
			IF @errorCode <> '0'
			BEGIN
				SELECT  @errorCode ErrorCode ,
                    @msg Msg ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0 ,
					maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
				RETURN;
			END
			--Validate Country Receiving Limit
			--End of Limit Checking------------------------------------------------------------------------------------------------------------
			SET @msg = 'Success';
		
			---------Compliance Checking Begin--------------------------------
			
			DECLARE @complianceRuleId INT, @cAmtUSD MONEY,@sCurrCostRate MONEY,@sCurrHoMargin MONEY
  
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
                    scAction = NULL ,
                    scValue = @scValue ,
                    scDiscount = @scDiscount ,
                    amountLimitPerTran = @AmountLimitPerTran ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0 ,
                    minAmountLimitPerTran = @AmountLimitPerTran ,
                    maxAmountLimitPerTran = @AmountLimitPerDay ,
					PerTxnMinimumAmt = '',
					tpExRate = @exRate,
					tpPCurr = @pCurr, 
                    schemeAppliedMsg = '',
					schemeId = 0
        END;

ELSE IF @flag = 'exRate_TP'
 BEGIN

			SELECT  @scValue = 0 ,
                    @exRateOffer = 0 ,
                    @scDiscount = 0 ,
                    @AmountLimitPerTran = 3000,
					@AmountLimitPerDay = 20000
			
         
			SELECT  @place = place ,
                    @currDecimal = currDecimal
            FROM  currencyPayoutRound(NOLOCK)
            WHERE ISNULL(isDeleted, 'N') = 'N'
            AND currency = @pCurr AND (tranType IS NULL OR tranType = @deliveryMethod);
			
			IF @pCountryId IS NULL
				SELECT @pCountryId = countryId FROM countryMaster (NOLOCK) WHERE countryName = @pCountry

            SET @currDecimal = ISNULL(@currDecimal, 0);

            IF @pCurr IS NULL
            BEGIN
					SELECT  '1' ErrorCode ,
                            'Currency not been defined yet for receiving country' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = 0 ,
                            maxAmountLimitPerTran = @AmountLimitPerTran ,
                            PerTxnMinimumAmt = @AmountLimitPerDay;
                    RETURN;
			END;
			DECLARE @sAgentSettRate MONEY
			SELECT @sAgentSettRate = sAgentSettRate FROM DBO.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethod)

			IF ISNULL(@sAgentSettRate, 0) = 0
			BEGIN
				SELECT  '1' ErrorCode ,
                            'Exchange rate not defined yet for sending currency (' + @collCurr + ')' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                           customerTotalSentAmt = 0 ,
                            maxAmountLimitPerTran = @AmountLimitPerTran ,
                            PerTxnMinimumAmt = @AmountLimitPerDay;
				RETURN
			END

			IF ISNULL(@tpExRate, 0) = 0
			BEGIN
				SELECT  '1' ErrorCode ,
                            'Third Party Exchange rate fetching error for currency (' + @pCurr + ')' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = 0 ,
                            maxAmountLimitPerTran = @AmountLimitPerTran ,
                            PerTxnMinimumAmt = @AmountLimitPerDay;
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
                            customerTotalSentAmt = 0 ,
                            maxAmountLimitPerTran = @AmountLimitPerTran ,
                            PerTxnMinimumAmt = @AmountLimitPerDay;
                    RETURN;
            END;
			
            IF @calBy = 'C'
            BEGIN
                    SELECT  @serviceCharge = amount
                    FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
                    @pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,@cAmt,@collCurr);

					IF @pCountryId = 42 AND @pCurr = 'USD' and @deliveryMethod = 2
					BEGIN
						SELECT  @serviceCharge = amount
                    FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
                    @pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,@cAmt,'USD');
					END

                    IF @serviceCharge IS NULL
                    BEGIN
                            SELECT  '1' ErrorCode ,
                                    'Service charge not defined yet for receiving country' Msg ,
                                    amountLimitPerDay = @AmountLimitPerDay ,
                                    customerTotalSentAmt = 0 ,
                            maxAmountLimitPerTran = @AmountLimitPerTran ,
                            PerTxnMinimumAmt = @AmountLimitPerDay;
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
				
				IF @pCountryId = 42 AND @pCurr = 'USD' and @deliveryMethod = 2
				BEGIN
					SELECT  @serviceCharge = amount
					FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,
                                                    @pCountryId,@pSuperAgent,@pAgent,@pBranch,@deliveryMethod,
                                                    @tAmt, 'USD');
				END

                IF @serviceCharge IS NULL
				BEGIN
                    SELECT  '1' ErrorCode ,
                            'Service charge not defined yet for receiving country' Msg ,
                            amountLimitPerDay = @AmountLimitPerDay ,
                            customerTotalSentAmt = 0 ,
                        maxAmountLimitPerTran = @AmountLimitPerTran ,
                        PerTxnMinimumAmt = @AmountLimitPerDay;
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
                            customerTotalSentAmt = 0 ,
                            maxAmountLimitPerTran = @AmountLimitPerTran ,
                            PerTxnMinimumAmt = @AmountLimitPerDay;
                    RETURN;
            END;
			
			--4. Validate Country Sending Limit 
        EXEC PROC_CHECKCOUNTRYLIMIT @flag = 's-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = NULL
			,@deliveryMethod = @deliveryMethod,@sendingCustType = NULL,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT

		IF @errorCode <> '0'
		BEGIN
			SELECT  @errorCode ErrorCode ,
                    @msg Msg ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0 ,
					maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
				RETURN;
		END
		--Validate Country Sending Limit END

		--5. Validate Country Receiving Limit
        EXEC PROC_CHECKCOUNTRYLIMIT @flag = 'r-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = NULL
			,@deliveryMethod = @deliveryMethod,@sendingCustType = NULL,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT
			
		IF @errorCode <> '0'
		BEGIN
			SELECT  @errorCode ErrorCode ,
                    @msg Msg ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0 ,
					maxAmountLimitPerTran = @AmountLimitPerTran ,
                    PerTxnMinimumAmt = @AmountLimitPerDay;
				RETURN;
		END
		--Validate Country Receiving Limit
		SET @msg = 'Success';
		
			---------Validation Begin--------------------------------
			
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
                    scAction = NULL ,
                    scValue = @scValue ,
                    scDiscount = @scDiscount ,
                    amountLimitPerTran = @AmountLimitPerTran ,
					amountLimitPerDay = @AmountLimitPerDay ,
                    customerTotalSentAmt = 0,
					minAmountLimitPerTran = @AmountLimitPerTran ,
                    maxAmountLimitPerTran = @AmountLimitPerDay ,
					PerTxnMinimumAmt = '',
					tpExRate = @tpExRate,
					tpPCurr = @tpPCurr, 
                    schemeAppliedMsg = '',
                    schemeId = 0
END
GO
