SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[mobile_proc_GetCalculation] (
	@flag					VARCHAR(25),	 
	@accessCode				VARCHAR(MAX) = NULL,
	@sCurrCode				VARCHAR(50) = NULL,		--@sCurrCode='KRW'
	@pCurrCode				VARCHAR(50)=NULL,		--@pCurrCode='NPR'
	@agentTxnRefId			VARCHAR(50)	= NULL,
	
	@currentRate			FLOAT	    = NULL,
	@serviceCharge			MONEY	    = NULL,
	@pAmt					MONEY		= NULL,
	@cAmt					MONEY		= NULL,
	@tAmt					MONEY		= NULL,
	@pCountryId             VARCHAR(50) = NULL,
	@sendMoney              BIT	        = NULL
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	DECLARE @sAgent INT = 394403
	DECLARE @sCountryId		INT,
			@sSuperAgent	INT,
			@sBranch		INT,
			@userId			VARCHAR(100),
			@agentCode		VARCHAR(50),
			@customerId		INT,
			@rewardPoint    MONEY
		   

	
	IF NOT EXISTS(SELECT 'x' FROM agentMaster(NOLOCK) WHERE agentid=@sAgent)
	BEGIN
		SELECT '1' errorCode, 'Sending agent not found' Msg, NULL ID
		RETURN
	END
	
	SELECT @sCountryId		= agentCountryId
			,@sSuperAgent	= parentId
			,@sBranch		= agentid
			,@agentCode		= agentCode
	FROM agentMaster (NOLOCK) where agentid = @sAgent

	IF @flag='getSAgentDetais'
	BEGIN
		
		IF @sendMoney=1
		BEGIN	
			SELECT @userId=ur.username FROM dbo.mobile_userRegistration (NOLOCK) ur
			WHERE ur.accessCode=@accessCode
		END 
		
		SELECT	errorCode		= '0'
				,sAgent			= @sAgent
				,sBranch		= @sBranch
				,sCountryId		= @sCountryId
                ,sSuperAgent	= @sSuperAgent
				,userId         = @userId
		RETURN;
	END
	IF @flag='exRate'
		BEGIN

		DECLARE @exchangeRateId VARCHAR(40) = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7) 

		SELECT @userId=username,@customerId=customerId FROM mobile_userRegistration where accessCode=@accessCode

		IF ISNULL(@customerId,'')=''
		BEGIN
			SELECT '1' errorCode, 'Invalid access code!' Msg, NULL ID
			RETURN
		END

		SELECT @rewardPoint = dbo.FNACalcBonusPoint(@tAmt,@serviceCharge)
		

		INSERT INTO exRateCalcHistory (
			 AGENT_CODE	
			,[USER_ID]
			,AGENT_TXN_REF_ID
			,FOREX_SESSION_ID
			,serviceCharge
			,pAmt
			,customerRate
			,sCurrCostRate		
			,sCurrHoMargin		
			,sCurrAgentMargin	
			,pCurrCostRate		
			,pCurrHoMargin		
			,pCurrAgentMargin	
			,agentCrossSettRate
			,treasuryTolerance	
			,customerPremium	
			,sharingValue		
			,sharingType
			,createdDate				
			,isExpired
		)
		SELECT
			 @agentCode	
			,@userId	
			,@agentTxnRefId
			,@exchangeRateId		
			,@serviceCharge
			,@pAmt
			,@currentRate			
			,''		
			,''		
			,''	
			,''		
			,''		
			,''	
			,''
			,''	
			,''	
			,''		
			,''				
			,GETDATE()			
			,'N'
		
		SELECT	
			errorCode								= '0' 
			,[from]									= @sCurrCode 
			,[to]									= @pCurrCode
			,currentRate							= @currentRate
			,transferFee							= CAST(@serviceCharge AS DECIMAL)
			,exchangeRateRefId						= @exchangeRateId
			,transferLimit							= '2000000'
			,transactionLimit						= '3'
			,rewardPoint							= CAST(ROUND(@rewardPoint,0) AS DECIMAL)
			,maximumTransferAmountPerTransaction	= '20000'
			,minimumTransferAmountPerTransaction	= '10000'
			,pAmt									= ROUND(@pAmt,2)
			,cAmt									= CAST(@cAmt AS DECIMAL)
			,tAmt									= ROUND(@tAmt,0)
		FROM customerMaster cm(NOLOCK) WHERE cm.customerId=@customerId
		END

		IF @flag='get-exRate'
		BEGIN
			DECLARE @exRate FLOAT,@pCurr VARCHAR(50);
			SELECT TOP 1 @pCurr=cm.currencyCode FROM dbo.countryCurrency cc(NOLOCK)
			INNER JOIN dbo.currencyMaster cm(NOLOCK) ON cm.currencyId = cc.currencyId
			WHERE countryId = @pCountryId
			
			SELECT  @exRate = 
				dbo.FNAGetCustomerRate('113',@sAgent,@sBranch,'JPY',@pCountryId,'', @pCurr,'');
			IF @exRate IS NULL
            BEGIN
                SELECT  '1' ErrorCode ,'Exchange rate not defined yet for receiving currency ('+ @pCurr + ')' Msg 
                RETURN;
            END;
			SELECT @exRate;
		END

		IF @flag='get-exRateDetails'
		BEGIN
			SELECT cm.countryId,cm.countryName,countryCode 
			FROM dbo.countryMaster cm(NOLOCK)
			WHERE cm.isOperativeCountry='Y' AND cm.countryName <> 'Mongolia'
			ORDER BY cm.countryName

			SELECT cc.countryId,cm.currencyCode AS currencyCode,cmas.countryName AS countryName, cmas.countryCode AS countryCode 
			FROM countrycurrency cc(NOLOCK)
			INNER JOIN currencyMaster cm(NOLOCK) ON cm.currencyId = cc.currencyId
			INNER JOIN dbo.countryMaster cmas(NOLOCK) ON cmas.countryId=cc.countryId
			WHERE cmas.isOperativeCountry = 'Y' AND ISNULL(cc.isDefault,'N') <>'N' AND ISNULL(cc.isDeleted,'N')='N' AND cmas.countryName <> 'JAPAN'
			ORDER BY countryName

			select c.countryId,c.receivingMode AS payoutmethodId,m.typeTitle AS payoutName,'' AS bussinessDescription 
			from countryReceivingMode c(nolock)
			INNER join serviceTypeMaster m(nolock) on m.serviceTypeId = c.receivingMode
			order by payoutmethodId

			SELECT '0' errorCode, 'Success' Msg ,NULL ID
		END
END TRY
	
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN
	DECLARE @errorLogId BIGINT
	INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
	SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'mobile_proc_GetCalculation',@accessCode, GETDATE()
	SET @errorLogId = SCOPE_IDENTITY()

	SELECT '1' errorCode, 'Technical Error : ' + ERROR_MESSAGE() Msg, @errorLogId ID

END CATCH

GO

