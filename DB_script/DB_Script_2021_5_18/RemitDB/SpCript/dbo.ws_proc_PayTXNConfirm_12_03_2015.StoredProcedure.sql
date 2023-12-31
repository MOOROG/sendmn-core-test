USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_PayTXNConfirm_12_03_2015]    Script Date: 5/18/2021 5:17:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_proc_PayTXNConfirm_12_03_2015] (	 
	 @ACCESSCODE		VARCHAR(50)
	,@USERNAME			VARCHAR(50)
	,@PASSWORD			VARCHAR(50)
	,@REFNO				VARCHAR(20)
	,@AGENT_SESSION_ID	VARCHAR(150)
	,@PAY_TOKEN_ID		BIGINT
)

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	DECLARE @apiRequestId BIGINT
	INSERT INTO apiRequestLogPay(
		 ACCESSCODE
		,USERNAME
		,PASSWORD
		,REFNO
		,AGENT_SESSION_ID
		,PAY_TOKEN_ID
		,requestedDate
	)
	SELECT
		 @ACCESSCODE
		,@USERNAME
		,@PASSWORD
		,@REFNO
		,@AGENT_SESSION_ID
		,@PAY_TOKEN_ID
		,GETDATE()
	
	SET @apiRequestId = SCOPE_IDENTITY()
	
	DECLARE @errCode INT, @controlNoEnc VARCHAR(50) = dbo.FNAENcryptString(@REFNO)
	DECLARE @autMsg	VARCHAR(500), @errorCode VARCHAR(10), @errorMsg VARCHAR(MAX), @remarks VARCHAR(30) = 'Pay Update'
	EXEC ws_proc_checkAuthntication @USERNAME, @PASSWORD, @ACCESSCODE, @errCode OUT, @autMsg OUT

	IF @errCode = '1'
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = ISNULL(@autMsg,'Authentication Fail')
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = 'You are required to change your password'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	------------------VALIDATION-------------------------------
	/*
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE,'AGENT SESSION ID Field is Empty' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID	= NULL, REFNO = @REFNO
		RETURN
	END
	*/
	IF @REFNO IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'REFNO Field is Empty'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	IF ISNUMERIC(@REFNO) = 0 AND @REFNO IS NOT NULL
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'Technical Error: REFNO must be numeric'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END

	IF @PAY_TOKEN_ID IS NULL
	BEGIN
		SELECT @errorCode = '1004', @errorMsg = 'PAY TOKEN ID Field is Empty'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN;
	END

	DECLARE	
		@pCountry					VARCHAR(50),
		@pLocation					INT, 
		@pBranch					INT,
		@pBranchMapCode				VARCHAR(50),
		@pBranchName				VARCHAR(200),
		@pAgent						INT,
		@pAgentMapCode				VARCHAR(50),
		@pAgentName					VARCHAR(200),
		@pSuperAgent				INT,
		@pSuperAgentName			VARCHAR(100),
		@sBranchMapCode				VARCHAR(10),
		@sCountry					VARCHAR(100),
		@sLocation					INT,
		@tranId						BIGINT,
		@tranStatus					VARCHAR(30),
		@tokenId					VARCHAR(40),
		@pDateCostRate				MONEY,
		@userCountry				VARCHAR(50),
		@paymentMethod				VARCHAR(100),
		@expected_payoutagentid		VARCHAR(50),
		@lock_status				VARCHAR(50),
		@lock_by					VARCHAR(50),
		@status						VARCHAR(50),
		@collCurr					VARCHAR(3),
		@payoutCurr					VARCHAR(3),
		@pAmt						MONEY,
		@cAmt						MONEY,
		@payoutAmt					MONEY,
		@serviceCharge				MONEY,
		@sSettlementRate			FLOAT,
		@pSettlementRate			FLOAT,
		@pHubComm					MONEY,
		@sRouteId					CHAR(5)
	
	DECLARE @sBranch INT, @sBranchName VARCHAR(100), @sAgent INT, @sAgentName VARCHAR(100), @agentType INT, @sSuperAgent INT, @sSuperAgentName VARCHAR(100),
	@pState VARCHAR(100), @pDistrict VARCHAR(100), @pCountryId INT, @sCountryId INT
	
	-- PICK AGENTID ,COUNTRY FROM USER
	SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @USERNAME AND ISNULL(isDeleted, 'N') = 'N'
	
	SELECT @pBranchMapCode = mapCodeInt, @pBranchName = agentName, @pAgent = parentId, @pCountryId = agentCountryId, @pState = agentState
		,@pDistrict = agentDistrict,@pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
		
	SELECT @pAgentName = agentName, @pAgentMapCode = mapCodeInt, @pSuperAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
	SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent	
			
	SELECT	
		 @tranId					= rt.id
		,@tranStatus				= rt.tranStatus
		,@pCountry					= rt.pCountry
		,@sCountry					= rt.sCountry
		,@sBranch					= rt.sBranch
		,@sAgent					= rt.sAgent
		,@sSuperAgent				= rt.sSuperAgent
		,@tokenId					= rt.payTokenId
		,@paymentMethod				= rt.paymentMethod
		,@expected_payoutagentid	= rt.pAgent
		--,@pAgentName				= rt.pAgentName
		,@lock_status				= rt.lockStatus
		,@lock_by					= rt.lockedBy
		,@status					= rt.payStatus
		,@collCurr					= rt.collCurr
		,@payoutCurr				= rt.payoutCurr
		,@pAmt						= rt.pAmt
		,@cAmt						= rt.cAmt
		,@payoutAmt					= rt.pAmt
		,@serviceCharge				= rt.serviceCharge
		,@sSettlementRate			= NULL
		,@pSettlementRate			= NULL
		,@sRouteId					= rt.sRouteId
	FROM vwRemitTran rt WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	WHERE controlNo = @controlNoEnc
	
	IF @tranStatus IS NULL
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'Transaction does not exist. Please check your ICN(IME CONTROL NUMBER).'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END

	IF (@lock_by <> @USERNAME)
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'You are not authorized to pay: ' + @REFNO + ''
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END

	IF (@status = 'Paid')
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'Transaction ' + @REFNO + ' is already PAID'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END

	IF @paymentMethod <> 'Cash Payment' AND @paymentMethod <> 'ML CARES DONATION' AND @paymentMethod <> 'Cash Payment USD'
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'This transaction is not Cash Pay Transaction'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN;
	END
		
	IF @tokenId IS NULL OR ISNULL(@PAY_TOKEN_ID, 0) <> @tokenId
	BEGIN
		SELECT @errorCode = '1004', @errorMsg = 'Invalid Token ID'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN;
	END


	IF (@pAgent IS NOT NULL AND @expected_payoutagentid <> @pAgent)
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'This transaction belongs to : ' + @pAgentName
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	
	IF (@tranStatus LIKE '%Hold%')
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'The Transaction is not approved. Kindly contact support1@imeremit.com to approve the transction.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	
	IF (ISNULL(@tranStatus,'') <> 'Payment')
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'This transaction is not currently available for payment. Kindly contact support1@imeremit.com for the details.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	
	IF (ISNULL(@Status,'') <> 'Unpaid')
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'This transaction is not currently available for payment. Kindly contact support1@imeremit.com for the details.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO
		RETURN
	END
	
	--IF (@lock_status <> 'locked')
	--BEGIN
	--	SELECT '2004' CODE
	--		,'Transaction ' + @REFNO + ' is not in LOCK Stage' MESSAGE
	--		,@AGENT_SESSION_ID AGENT_SESSION_ID
	--		,Confirm_ID	= NULL, REFNO = @REFNO
	--	RETURN
	--END

	DECLARE @Confirm_ID VARCHAR(40)
	SET @Confirm_ID = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000', 7)
	
	--Check Agent Payout Limit
	
	--Start:Commission Calculation
	DECLARE @deliveryMethodId INT, @pAgentComm MONEY, @pAgentCommCurrency VARCHAR(3), @pSuperAgentComm MONEY, @pSuperAgentCommCurrency VARCHAR(3),
	@commCheck MONEY, @commissionType CHAR(1)
	SET @deliveryMethodId = CASE WHEN @paymentMethod = 'ML CARES DONATION' THEN 9 ELSE 1 END			--Cash Payment
	SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
	
	--SELECT @pAgentComm = ISNULL(amount, 0), @pAgentCommCurrency = commissionCurrency, @commCheck = amount, @commissionType = commissionType 
	--FROM dbo.FNAGetPayComm(@sCountryId, @sSuperAgent, @sAgent, @sBranch,
	--						@pCountryId, @pSuperAgent, @pAgent, @pBranch,
	--						@collCurr, @payoutCurr, @deliveryMethodId,
	--						@cAmt, @payoutAmt, @serviceCharge,
	--						NULL, NULL, @sSettlementRate, @pSettlementRate)
	
	SELECT 
			 @pAgentComm			= ISNULL(amount, 0)
			,@pAgentCommCurrency	= commissionCurrency
			,@commCheck				= amount 
		FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, @sLocation, @pSuperAgent, @pCountryId, @pLocation, @pBranch, 'NPR', 
								@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, @pSuperAgentComm)
	
	SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = @pAgentCommCurrency

	SELECT @pDateCostRate = pRate FROM defExRate WITH(NOLOCK) WHERE currency = @payoutCurr AND country = @pCountryId AND agent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
	IF @pDateCostRate IS NULL
		SELECT @pDateCostRate = pRate FROM defExRate WITH(NOLOCK) WHERE currency = @payoutCurr AND country = @pCountryId AND agent IS NULL AND ISNULL(isActive, 'N') = 'Y'
	
	--End:Commission Calculation
	
	BEGIN TRANSACTION	

	UPDATE remitTran SET
		 pAgentComm					= @pAgentComm
		,pAgentCommCurrency			= @pAgentCommCurrency
		--,pCommissionType			= @commissionType
		--,pSuperAgentComm			= @pSuperAgentComm
		--,pSuperAgentCommCurrency	= @pSuperAgentCommCurrency
		,pDateCostRate				= @pDateCostRate
		,pBranch					= @pBranch
		,pBranchName				= @pBranchName
		,pAgent						= @pAgent
		,pAgentName					= @pAgentName
		,pSuperAgent				= @pSuperAgent
		,pSuperAgentName			= @pSuperAgentName
		,lockStatus					= 'unlocked'
		,tranStatus					= 'Paid'
		,payStatus					= 'Paid'
		,paidDate					= DBO.FNADateFormatTZ(GETDATE(), @USERNAME)
		,paidDateLocal				= GETDATE()
		,paidBy						= @USERNAME
		,payTokenId					= @Confirm_ID
	WHERE controlNo = @controlNoEnc
	
	EXEC proc_INFICARE_payTxn @flag = 'p', @tranIds = @tranId
	
	-- ## Queue Table for Data Integration
	IF @sRouteId IS NOT NULL
	BEGIN
		INSERT INTO payQueue2(controlNo, pAgent, pAgentName, pBranch, pBranchName, paidBy, paidDate, paidBenIdType, paidBenIdNumber, routeId)
		SELECT @controlNoEnc, @pAgent, @pAgentName, @pBranch, @pBranchName, @USERNAME, dbo.FNAGetDateInNepalTZ(), NULL, NULL, @sRouteId
	END

    IF @@TRANCOUNT > 0
	  COMMIT TRANSACTION
	 
	SELECT
		 CODE				= '0'
		,MESSAGE			= 'Success'
		,AGENT_SESSION_ID	= @AGENT_SESSION_ID
		,Confirm_ID			= @Confirm_ID
		,REFNO				= @REFNO

	SELECT @errorCode = '0', @errorMsg = 'Pay Success'
	EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
	
END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
ROLLBACK TRAN

DECLARE @errorLogId BIGINT
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error',@errorMsg MESSAGE, 'ws_proc_PayTXNConfirm', @USERNAME, GETDATE()
SET @errorLogId = SCOPE_IDENTITY()

SELECT @errorCode = '9001', @errorMsg = 'Technical Error : ' + ERROR_MESSAGE() + ', Error Log Id : ' + CAST(@errorLogId AS VARCHAR)
EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks

SELECT @errorCode CODE, 'Technical Error occurred, Error Log Id : ' + CAST(@errorLogId AS VARCHAR) MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID, Confirm_ID = NULL, REFNO = @REFNO

END CATCH


/*

EXEC ws_proc_PayTXNConfirm @ACCESSCODE='IMEBGUBL085',
@USERNAME='apitest02',@PASSWORD='ime@9999',
@AGENT_SESSION_ID='1234567',
@REFNO='90401449117',
@PAY_TOKEN_ID='7355'

 
*/

GO
