USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_SendTransaction]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_SendTransaction]
@User						VARCHAR(100)	= NULL,
@SenderId					INT				= NULL,
@sIpAddress					VARCHAR(20)		= NULL,
@ReceiverId					INT				= NULL,
@rFirstName					VARCHAR(50)		= NULL,
@rMiddleName				VARCHAR(50)		= NULL,
@rLastName					VARCHAR(50)		= NULL,
@rIdType					VARCHAR(50)		= NULL,
@rIdNo						VARCHAR(30)		= NULL,
@rIdIssue					VARCHAR(10)		= NULL,
@rIdExpiry					VARCHAR(10)		= NULL,
@rDob						VARCHAR(10)		= NULL,
@rMobileNo					VARCHAR(20)		= NULL,
@rNativeCountry				VARCHAR(50)		= NULL,
@rStateId					INT				= NULL,
@rDistrictId				INT				= NULL,
@rAddress					VARCHAR(100)	= NULL,
@rCity						VARCHAR(50)		= NULL,
@rEmail						VARCHAR(50)		= NULL,
@rAccountNo					VARCHAR(50)		= NULL,
@sCountryId					INT				= NULL,
@pCountryId					INT				= NULL,
@deliveryMethodId			INT				= NULL,
@pBankId					BIGINT			= NULL,
@pBranchId					BIGINT			= NULL,
@collCurr					VARCHAR(3)		= NULL,
@payoutCurr					VARCHAR(3)		= NULL,
@collAmt					MONEY			= NULL,
@payoutAmt					MONEY			= NULL,
@transferAmt				MONEY			= NULL,
@exRate						MONEY			= NULL,
@calBy						CHAR(1)			= NULL,
@tpExRate					DECIMAL(30,12)	= NULL,
@payOutPartnerId			BIGINT			= NULL,
@forexSessionId				VARCHAR(40)		= NULL,
@kftcLogId					BIGINT			= NULL,
@paymentType				VARCHAR(20)		= NULL,
@scDiscount					MONEY			= NULL,
@PurposeOfRemittance		VARCHAR(100)	= NULL,
@SourceOfFund				VARCHAR(100)	= NULL,
@RelWithSender				VARCHAR(100)	= NULL,
@SourceType					CHAR(1)			= NULL,
@schemeId					BIGINT			= NULL,
@processId					VARCHAR(40)		= NULL,
@flag						VARCHAR(100),
@controlNo					VARCHAR(20)		= NULL,
@PartnerPin					VARCHAR(20)		= NULL,
@PartnerId					VARCHAR(20)		= NULL,
@tranId						BIGINT			= NULL,
@errorCode					INT				= NULL,
@Message					NVARCHAR(500)	= NULL,
@complianceQuestion		NVARCHAR(MAX)	= NULL

AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
BEGIN TRY	
	DECLARE @complianceRuleId	INT
	,@cAmtUSD					MONEY
	,@complienceMessage			VARCHAR(1000)		=	NULL 
	,@shortMsg					VARCHAR(100)		=	NULL 
	,@complienceErrorCode		TINYINT				=	NULL
	,@compErrorCode				INT 
	,@discountType				VARCHAR(2)			=	NULL
	,@discountvalue				MONEY				=	NULL
	,@couponType				VARCHAR(3)			=	NULL
	,@discountPercent			MONEY				=	NULL
	,@couponName				VARCHAR(20)			=	NULL
	,@ServiceCharge_Temp		MONEY				=	NULL
	,@schemePremium				MONEY				=	NULL
	,@customerType 				INT
	
IF @flag = 'SEND'
BEGIN
	IF @paymentType IS NULL
		SET @paymentType = 'WALLET'
        
        DECLARE 
				@sCurrCostRate					FLOAT ,
				@sCurrHoMargin					FLOAT ,
				@pCurrCostRate					FLOAT ,
				@customerRate					MONEY ,
				@agentCrossSettRate				FLOAT,
				@iServiceCharge					MONEY,
				@iTAmt							MONEY,
				@iPAmt							MONEY,
				@place							INT ,
				@currDecimal					INT,
				@agentAvlLimit					MONEY,
				@serviceCharge					MONEY,
				@sCountry						VARCHAR(50)	=	'Mongolia',
				@sAgent							BIGINT,
				@sAgentName						VARCHAR(100),
				@sBranch						INT,
				@sBranchName					VARCHAR(100),
				@sSuperAgent					INT,
				@sSuperAgentName				VARCHAR(100),
				@senderName						VARCHAR(100),
				@sIdNo							VARCHAR(50),
				@sIdType						VARCHAR(50),
				@sMobile						VARCHAR(15),
				@pAgent							BIGINT,
				@pSuperAgent					BIGINT,
				@pSuperAgentName				VARCHAR(100),
				@pAgentName						VARCHAR(100),
				@receiverName					VARCHAR(100),
				@controlNoEncrypted				VARCHAR(30),
				@tempCompId						BIGINT,
				@msg							VARCHAR(MAX),
				@pBranch						INT,
				@pBranchName					VARCHAR(100)

		SELECT @sCountryId = 142,@sBranch = 394420

		SELECT	@sAgent				=	sAgent, 
				@sAgentName			=	sAgentName, 
				@sBranch			=	sBranch, 
				@sBranchName		=	sBranchName,
				@sSuperAgent		=	sSuperAgent, 
				@sSuperAgentName	=	sSuperAgentName 
		FROM dbo.FNAGetBranchFullDetails(@sBranch)

		----SELECT @pCountry = COUNTRYNAME FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYID = @pCountryId
		SELECT @payOutPartnerId = AGENTID FROM TblPartnerwiseCountry(NOLOCK) 
			WHERE CountryId = @pCountryId AND IsActive = 1 
			AND ISNULL(PaymentMethod, @deliveryMethodId) = @deliveryMethodId

		SELECT TOP 1	@pAgent			=	AM.agentId
						--,@pCountryId		=	AM.agentCountryId
		FROM agentMaster AM(NOLOCK) 
		WHERE AM.parentId = @payOutPartnerId AND agentType = 2903 
		AND AM.isSettlingAgent = 'Y' AND AM.isApiPartner = 1
		
		SELECT 
			@pSuperAgentName			=	sSuperAgentName,
			@pSuperAgent				=	sSuperAgent,
			@pAgent						=	sAgent,
			@pAgentName					=	sAgentName 
		FROM dbo.FNAGetBranchFullDetails(@pAgent)

		SELECT @pBranch=@pAgent,@pBranchName=@pAgentName
		 
		IF @receiverId IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT '1' FROM dbo.receiverInformation(NOLOCK) WHERE receiverId=@ReceiverId)
			BEGIN
			   EXEC proc_errorHandler 1,'Receiver Data Not Match !', NULL;
				RETURN; 
			END
			SELECT TOP 1   @receiverName = ISNULL(firstName,'')+ISNULL(' '+middleName,'')+ISNULL(' '+lastName1,'') +ISNULL(' '+lastName2,'') 
			FROM dbo.receiverInformation(NOLOCK)
			WHERE receiverId = @receiverId
		END
		ELSE
			SET @receiverName = ISNULL(@rFirstName,'')+ISNULL(' '+@rMiddleName,'')+ISNULL(' '+@rLastName,'')

		IF @rFirstName IS NULL AND @receiverId IS NULL
		BEGIN
			EXEC proc_errorHandler 1,'Receiver name cannot be empty', NULL;
            RETURN;
		END

		

		IF @payOutPartnerId IS NULL
		BEGIN
		    EXEC proc_errorHandler  1,'Oops, something went wrong.Please perform the transaction again' ,null
			RETURN;
		END
		--IF NOT EXISTS (SELECT TOP 1   '' FROM TblPartnerwiseCountry(NOLOCK) 
		--		WHERE AgentId = @payOutPartnerId AND CountryId = @pCountryId 
		--		AND ISNULL(PaymentMethod,@deliveryMethodId) = @deliveryMethodId and IsActive = 1
		--		)
		--BEGIN
		--	EXEC proc_errorHandler  1,'Oops, something went wrong.Please perform the transaction again' ,null
		--	RETURN;
		--END
		
		IF ISNULL(@exRate,0) = 0
		BEGIN		
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed.Exchange Rate not defined', NULL
			RETURN
		END

		IF @pAgent IS NULL
		BEGIN
			EXEC proc_errorHandler  1,'Oops, something went wrong.Please perform the transaction again' ,null
			RETURN;
		END

		SELECT TOP 1   	
				@agentAvlLimit 	=	dbo.FNAGetCustomerAvailableBalance(@SenderId),
				@senderName 	=	firstName,
				@sIdNo			=	idNumber,
				@sIdType		=	idType,
				@sMobile		=	mobile,
				@customerType 	=	customerType
		FROM 	customerMaster(NOLOCK) 
		WHERE 	email = @User AND customerId = @SenderId
		
		IF NOT EXISTS (SELECT TOP 1  'X' FROM dbo.customerMaster(nolock) WHERE email = @user AND approvedDate IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1,'You are not authorized to perform transaction :(', NULL;
            RETURN;
		END

		IF ISNULL(@paymentType,'') NOT IN ('wallet')
		BEGIN
			EXEC proc_errorHandler 1,'Invalid payment method.Please perform the transaction again!', NULL;
            RETURN;
		END
		
	
		IF @user in('demo.gme@gmeremit.com')
		BEGIN
			EXEC proc_errorHandler 1,'You can not send money through test GME acocunt :(', NULL;
            RETURN;
		END
		
        IF ISNULL(@collAmt, 0) = 0
        BEGIN
            EXEC proc_errorHandler 1, 'Collection Amount is missing. Cannot send transaction',NULL;
            RETURN;	
        END; 
		
        SET @controlNo = '21' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
        SELECT  @controlNoEncrypted = dbo.FNAEncryptString(@controlNo);
			
        IF EXISTS (SELECT TOP 1   'X' FROM pinQueueList WITH(NOLOCK) WHERE icn = @controlNoEncrypted) 
        BEGIN
			SET @controlNo = '21' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
			SELECT  @controlNoEncrypted = dbo.FNAEncryptString(@controlNo);

			IF EXISTS(SELECT TOP 1   'X' FROM pinQueueList WITH(NOLOCK) WHERE icn = @controlNoEncrypted) 
			BEGIN
				EXEC proc_errorHandler 1, 'Technical error occurred. Please try again',NULL;
				RETURN;
			END
        END;
		
        IF @deliveryMethodId = 2 AND @pCountryId<>'151'
        BEGIN                               
			IF NOT EXISTS(SELECT TOP 1   'A' FROM api_bank_list(nolock) where bank_ID = @pBankId and PAYMENT_TYPE_ID in(0,2) and IS_ACTIVE = 1)
			BEGIN	
				EXEC proc_errorHandler 1, 'Invalid bank selected', NULL
				return
			END
			IF @raccountNo IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Account number cannot be blank', NULL
				RETURN
			END
        END;

		DECLARE @pAgentCommCurrency VARCHAR(3),@pAgentComm MONEY

		SELECT @pAgentCommCurrency = DBO.FNAGetPayCommCurrency(@sSuperAgent,@sAgent,@sBranch,@SCOUNTRYID,@pSuperAgent,@pBranch,@pCountryId)

		SELECT @pAgentComm = amount FROM dbo.FNAGetPayComm(@sAgent,@sCountryId, 
								NULL, null, @pCountryId, null, @pAgent, @pAgentCommCurrency
								,@deliveryMethodId, @collAmt, @payoutAmt, @serviceCharge, @transferAmt, NULL)
		
		--4. Get Exchange Rate Details------------------------------------------------------------------------------------------------------------------

			SELECT 
				 @customerRate			= customerRate
				,@sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
				,@pCurrCostRate			= pCurrCostRate
				,@agentCrossSettRate	= agentCrossSettRate
				,@serviceCharge			= serviceCharge
				,@iPAmt					= pAmt
				,@schemeId				= schemeId
			FROM exRateCalcHistory(NOLOCK) 
			WHERE FOREX_SESSION_ID = @forexSessionId AND [USER_ID] = @user

			IF @customerRate IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
				RETURN
			END

		IF @paymentType = 'WALLET'
		BEGIN
			IF ISNULL(@agentAvlLimit, 1) < ISNULL(@collAmt, 0)
			BEGIN
				EXEC proc_errorHandler 1,'You donot have sufficient balance to do the transaction!', NULL;
				RETURN;
			END;
		END
		--ELSE 
		--BEGIN
		--	EXEC proc_errorHandler 1,'Invalid payment method.Please perform the transaction again!', NULL;
  --          RETURN;
		--END
			--Get Service Charge----------------------------------------------------------------------------------------------------------------------
			
			SELECT @iServiceCharge = ISNULL(amount, -1) 
			FROM [dbo].FNAGetServiceCharge(
								@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
								@pCountryId, @pSuperAgent, @pAgent, @pBranch, 
								@deliveryMethodId, @collAmt, @collCurr
							) 
			IF @iServiceCharge = -1
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Service Charge is not defined', NULL
				RETURN
			END
			
			IF ISNULL(@iServiceCharge,0) <> ISNULL(@serviceCharge,1)
			BEGIN
			--declare @mnb varchar(500)='iservice' + cast(@iServiceCharge as varchar) + ', service: '+cast(@serviceCharge as varchar)
			--	EXEC proc_errorHandler 1, @mnb, NULL
				EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Amount detail not match', NULL
				RETURN
			END 

			--End Service Charge-------------------------------------------------------------------------------------------------------------------------------------
			--DECLARE @iMsg VARCHAR(MAX)
			IF ISNULL(@exRate,0) <> ISNULL(@customerRate,1)
			BEGIN
				--SET @iMsg = 'Amount detail not match. Please re-calculate the amount again' + CAST(isnull(@exRate,0) AS VARCHAR) + ' : ' + CAST(isnull(@customerRate,1) AS VARCHAR) 
				EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again', NULL
				RETURN
			END
			
			SELECT @iTAmt = @collAmt - @iServiceCharge

			SELECT TOP 1   @place = place ,@currDecimal = currDecimal
			FROM  currencyPayoutRound(NOLOCK)
			WHERE ISNULL(isDeleted, 'N') = 'N'
			AND currency = @payoutCurr AND tranType IS NULL;

			SET @currDecimal = ISNULL(@currDecimal, 0)
			SET @place = ISNULL(@place, 0)
			
			SET @iPAmt = @iTAmt * @CustomerRate
			
			IF @payoutAmt - @iPAmt <= 1
				SET @iPAmt = @payoutAmt

			----## WHILE CALCULATING FROM PAYOUT AMOUNT CONSIDARING 10 VND 
			IF ISNULL(@iPAmt,0) <> ISNULL(@payoutAmt,1)
			BEGIN
				--SET @Msg = 'Amount detail not match. Please re-calculate the amount again.' + CAST(@iPAmt AS VARCHAR) + ' - ' +  CAST(@payoutAmt AS VARCHAR)
				EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again.', NULL
				RETURN
			END
			
			----OFAC Checking
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
			
			--SET @cAmtUSD = @collAmt / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))
			
			----Compliance Checking
			--EXEC [proc_complianceRuleDetail]
			--	@flag				= 'receiver-limit'
			--	,@user				= @user
			--	,@sIdType			= @sIdType
			--	,@sIdNo				= @sIdNo
			--	,@receiverName		= @receiverName
			--	,@cAmt				= @collAmt
			--	,@cAmtUSD			= @cAmtUSD
			--	,@customerId		= @senderId
			--	,@pCountryId		= @pCountryId
			--	,@receiverMobile	= @rMobileNo
			--	,@deliveryMethod	= @deliveryMethodId
			--	,@message			= @complienceMessage OUTPUT
			--	,@shortMessage		= @shortMsg    OUTPUT
			--	,@errCode			= @complienceErrorCode OUTPUT
			--	,@ruleId			= @complianceRuleId  OUTPUT
   
		
			--**********Customer Per Day Limit Checking**********
            DECLARE @remitTranTemp TABLE (
                    tranId BIGINT,controlNo VARCHAR(20),cAmt MONEY,receiverName VARCHAR(200) ,
                    receiverIdType VARCHAR(100),receiverIdNumber VARCHAR(50),dot DATETIME
                );
            
            INSERT INTO @remitTranTemp( tranId ,controlNo ,cAmt ,receiverName ,receiverIdType ,receiverIdNumber ,dot )
            SELECT TOP 1    rt.id ,rt.controlNo ,rt.cAmt ,rt.receiverName ,rec.idType ,rec.idNumber ,rt.createdDateLocal
			FROM vwRemitTran rt WITH(NOLOCK)
			INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
			INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
			WHERE sen.customerId = @senderId
			AND ( rt.approvedDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101)+ ' 23:59:59'
					OR ( approvedBy IS NULL AND cancelApprovedBy IS NULL )
				);
		
            IF EXISTS ( SELECT TOP 1    'X' FROM @remitTranTemp
                        WHERE   cAmt = @collAmt
                        AND ( receiverName = @receiverName ) AND DATEDIFF(MI, dot, GETDATE()) <= 2 
						)
			BEGIN
				EXEC proc_errorHandler 1, 'Similar transaction found. Please perform the transaction after 2 minutes.', NULL;
				RETURN;
			END;
			
			DECLARE @countryRisk INT,@OccupationRisk INT,@compFinalRes VARCHAR(5)
			
			-- #########country and occupation  risk point
            DECLARE @pCountry VARCHAR(50),@deliveryMethod VARCHAR(30),@pBankName VARCHAR(100),@pBankBranchName VARCHAR(100)
			
			SELECT TOP 1   @pCountry = COUNTRYNAME FROM countryMaster(NOLOCK) WHERE countryId = @pCountryId
			SELECT TOP 1   @deliveryMethod = typeTitle FROM serviceTypeMaster(NOLOCK) WHERE serviceTypeId = @deliveryMethodId
			SELECT TOP 1   @pBankName = agentName FROM agentMaster(NOLOCK) WHERE agentId = @pBankId AND agentType = '2903' AND isActive = 'Y'
			SELECT TOP 1   @pBankBranchName = agentName FROM agentMaster(NOLOCK) WHERE agentId = @pBranchId AND agentType = '2904' AND isActive = 'Y'
		
			DECLARE @VNo VARCHAR(20); 
			
			BEGIN TRANSACTION;
				INSERT  INTO remitTranTemp
				( 
				controlNo ,sCurrCostRate ,sCurrHoMargin ,pCurrCostRate ,agentCrossSettRate ,customerRate ,
				serviceCharge ,handlingFee ,pAgentComm ,pAgentCommCurrency ,
				promotionCode ,sSuperAgent ,sSuperAgentName ,sAgent ,sAgentName ,sBranch ,sBranchName ,sCountry ,
				pSuperAgent ,pSuperAgentName ,pAgent ,pAgentName ,pCountry ,paymentMethod ,pBank ,pBankName ,pBankBranch ,pBankBranchName ,accountNo ,
				collCurr ,tAmt ,cAmt ,pAmt ,payoutCurr ,relWithSender ,purposeOfRemit ,sourceOfFund ,tranStatus ,payStatus ,createdDate ,
				createdDateLocal ,createdBy ,tranType ,senderName ,receiverName ,isOnlineTxn ,schemeId,pState,pDistrict,
				sRouteId,schemePremium,collMode
				)
				SELECT TOP 1   
				@controlNoEncrypted ,@sCurrCostRate ,@sCurrHoMargin ,@pCurrCostRate ,@agentCrossSettRate ,@customerRate,
				@serviceCharge ,ISNULL(@scDiscount, 0) ,@pAgentComm ,@pAgentCommCurrency ,
				@processId ,@sSuperAgent , @sSuperAgentName ,@sAgent ,@sAgentName ,@sBranch ,@sBranchName ,@sCountry , 
				@pSuperAgent ,@pSuperAgentName , @pAgent , @pAgentName ,@pCountry ,@deliveryMethod ,@pBankId , @pBankName ,@pBranchId ,@pBankBranchName ,@raccountNo ,
				@collCurr ,@iTAmt , @collAmt ,@payoutAmt , @payoutCurr , @RelWithSender , @PurposeOfRemittance ,@sourceOfFund ,'Hold' ,'Unpaid' ,GETDATE() ,
				GETUTCDATE() , @user ,ISNULL(@SourceType,'O')  , @senderName , @receiverName, 'Y' ,@schemeId,@rDistrictId,@rStateId,
				CASE WHEN @paymentType = 'wallet' THEN 'w' WHEN @paymentType = 'autodebit' THEN 'a' END,ISNULL(@schemePremium, 0),'Bank Deposit'
				
				SET @tranId = SCOPE_IDENTITY();	

				IF ISNULL(@complianceQuestion, '') <> ''
				BEGIN
					DECLARE @XMLDATA XML;

					SET @XMLDATA = CONVERT(XML, REPLACE(@complianceQuestion,'&','&amp;'), 2) 

					SELECT  answer = p.value('@answer', 'varchar(150)') ,
							qType = p.value('@qType', 'varchar(500)'),
							qId = p.value('@qId', 'varchar(500)')
					INTO #TRANSACTION_COMPLIANCE_QUESTION
					FROM @XMLDATA.nodes('/root/row') AS tmp ( p );
		
					INSERT INTO TBL_TXN_COMPLIANCE_CDDI
					SELECT @tranId, qId, answer
					FROM #TRANSACTION_COMPLIANCE_QUESTION
				END

				INSERT  INTO tranSendersTemp
						( tranId , customerId ,membershipId ,firstName , middleName ,lastName1 ,lastName2 ,
							fullName ,country ,[address] ,address2 ,zipCode ,city ,email ,homePhone ,
							workPhone ,mobile ,nativeCountry ,dob ,placeOfIssue ,idType ,idNumber ,idPlaceOfIssue ,
							issuedDate ,validDate ,occupation ,countryRiskPoint ,customerRiskPoint ,ipAddress
						)
				SELECT TOP 1
						@tranId ,@senderId ,membershipId ,firstName ,middleName ,lastName1 ,lastName2 ,
						@senderName ,sc.countryName ,[address] ,address2 ,zipCode ,city ,email ,homePhone ,
						workPhone ,LEFT(mobile, 15) ,nativeCountry = nc.countryName ,dob ,c.placeOfIssue ,sdv.detailTitle ,c.idNumber ,c.placeOfIssue ,
						c.idIssueDate ,c.idExpiryDate ,om.detailTitle ,@countryRisk ,( @countryRisk + @OccupationRisk ) ,@sIpAddress
				FROM   (SELECT TOP 1 * FROM dbo.customerMaster c WITH ( NOLOCK ) WHERE c.customerId = @senderId) C
				LEFT JOIN countryMaster sc WITH ( NOLOCK ) ON c.country = sc.countryId
				LEFT JOIN countryMaster nc WITH ( NOLOCK ) ON c.nativeCountry = nc.countryId
				LEFT JOIN staticDataValue sdv WITH ( NOLOCK ) ON c.idType = sdv.valueId
				LEFT JOIN occupationMaster om WITH ( NOLOCK ) ON c.occupation = om.occupationId
				--WHERE   c.customerId = @senderId;
				
                IF @ReceiverId IS NULL
                BEGIN
					IF NOT EXISTS ( SELECT TOP 1    'X'
                                FROM    receiverInformation(nolock)
                                WHERE   fullName = @receiverName AND customerId = @senderId )
                    BEGIN				 
						INSERT INTO receiverInformation
						( customerId ,firstName,middleName,lastName1 ,country ,address ,city ,email  
							,homePhone ,mobile ,relationship,state,district,fullName,nativeCountry)
						SELECT  @senderId ,@rFirstName,@rMiddleName,@rLastName,@pCountry,@rAddress,@rCity,@rEmail
							,@rMobileNo,@rMobileNo,@RelWithSender,@rStateId,@rDistrictId,@receiverName,@rNativeCountry
						
						SET @ReceiverId = SCOPE_IDENTITY()
                    END;
					--ELSE
     --               BEGIN
     --                   SELECT TOP 1 @ReceiverId = receiverId
     --                   FROM    receiverInformation(nolock)
     --                   WHERE   fullName = @receiverName AND customerId = @senderId; 
					--END;
                END;
											
				INSERT  INTO tranReceiversTemp( tranId ,customerId  ,firstName ,middleName ,lastName1 ,lastName2 ,fullName ,
					country ,[address] ,[state] ,district ,zipCode ,city ,email ,homePhone ,workPhone ,mobile ,nativeCountry ,dob ,
					placeOfIssue ,idType ,idNumber ,idPlaceOfIssue ,issuedDate ,relationType,validDate ,gender
								)
				SELECT TOP 1   @tranId,@ReceiverId,firstName,middleName ,lastName1 ,lastName2 ,fullName ,
					@pCountry ,[address] ,[state] ,district ,zipCode ,city ,email ,homePhone ,workPhone ,mobile ,country ,@rDob ,
					null ,ISNULL(@rIdType,idType) ,ISNULL(@rIdNo,idNumber) ,null ,@rIdIssue ,@RelWithSender,@rIdExpiry ,null
				FROM receiverInformation(NOLOCK) WHERE receiverId = @ReceiverId
			
				----IF @paymentType = 'WALLET' 
				EXEC proc_UpdateCustomerBalance @controlNo = @controlNoEncrypted, @type = 'DEDUCT'
				
				----## map locked ex rate with transaction for history
				UPDATE exRateCalcHistory set controlNo = @controlNoEncrypted,AGENT_TXN_REF_ID = @tranId,isExpired = 1 where FOREX_SESSION_ID = @forexSessionId
				--------------------------#########------------OFAC/COMPLIANCE INSERT (IF EXISTS)---------------########----------------------
				IF EXISTS(SELECT TOP 1   'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @processId)
				BEGIN
					INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
					SELECT TOP 1   @tranId, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @processId
					SET @compFinalRes = 'C'
				END

				IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '' OR ISNULL(@receiverOfacRes, '') <> '')
				BEGIN
					IF @pCountryId =36 AND @deliveryMethod <>'BANK DEPOSIT'
					BEGIN
						SET @complienceMessage = ISNULL('Compliance: ' + @shortMsg, '') + ISNULL('Ofac: ' + @ofacRes, '') + ISNULL(' ' + @receiverOfacRes, '') 
						
						SET @msg = 'Your transaction is under Compliance/OFAC Please refer ' + CAST(ISNULL(@tempCompId, 0) AS VARCHAR) + ' code to HEAD OFFICE';
						
						EXEC proc_errorHandler 1, @msg, NULL;
						EXEC proc_ApproveHoldedTXN @flag = 'reject', @user = @user , @id = @tranId
						
						COMMIT TRANSACTION 
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
						WHERE id = @tranId
					END
					
					ELSE IF(@compFinalRes <> '' AND (ISNULL(@ofacRes, '') = '' OR ISNULL(@receiverOfacRes, '') = ''))
					BEGIN
						UPDATE remitTranTemp SET
								tranStatus	= 'Compliance Hold'
						WHERE id = @tranId
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
						WHERE id = @tranId
					END
				END
				--Compliance checking
				--IF EXISTS(SELECT TOP 1   'A' FROM remitTrantemp(NOLOCK) WHERE id = @tranId AND pAgentComm IS NULL)
				--BEGIN
				--	SELECT 
				--			@pAgentComm = (SELECT amount FROM FNAGetPayComm
				--			(sBranch,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
				--				NULL, sAgent, (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = pCountry),
				--				null, pAgent,pAgentCommCurrency
				--				,(select serviceTypeId from servicetypemaster(nolock) where typeTitle = paymentMethod)
				--				, cAmt, pAmt, serviceCharge, NULL, NULL
				--			))
				--	FROM remitTrantemp(NOLOCK)
				--	WHERE id = @tranId

				--	UPDATE remitTrantemp SET pAgentComm = @pAgentComm WHERE id = @tranId AND pAgentComm IS NULL
				--END
		
		
				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
					SElect 0 errorCode, 'Transaction has been sent successfully' msg, @tranId id,@controlNo extra
			
				RETURN   
END 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
		
    DECLARE @errorMessage VARCHAR(MAX);
    SET @errorMessage = ERROR_MESSAGE();
	
    EXEC proc_errorHandler 1, @errorMessage, @user;
	
END CATCH





GO
