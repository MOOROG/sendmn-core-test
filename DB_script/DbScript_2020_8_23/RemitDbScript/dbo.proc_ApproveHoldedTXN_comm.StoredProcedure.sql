USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ApproveHoldedTXN_comm]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_ApproveHoldedTXN_comm] (	 
	 @flag				VARCHAR(50)	
	,@user				VARCHAR(130)
	,@userType			VARCHAR(10)		= NULL
	,@branch			VARCHAR(50)		= NULL	
	,@id				VARCHAR(40)		= NULL
	,@country			VARCHAR(50)		= NULL
	,@sender			VARCHAR(50)		= NULL
	,@receiver			VARCHAR(50)		= NULL
	,@amt				MONEY			= NULL
	,@bank				VARCHAR(50)		= NULL
	,@voucherNo			VARCHAR(50)		= NULL	
	,@branchId			INT				= NULL
	,@pin				VARCHAR(50)		= NULL
	,@errorCode			VARCHAR(10)		= NULL	
	,@msg				VARCHAR(500)	= NULL
	,@idList			XML				= NULL
	,@txnDate			VARCHAR(20)		= NULL
	,@txncreatedBy		VARCHAR(50)		= NULL
	,@xml				VARCHAR(MAX)	= NULL
	,@remarks			VARCHAR(MAX)	= NULL
	,@settlingAgentId	INT				= NULL
    ,@ControlNo			VARCHAR(50)		= NULL
	,@txnType			VARCHAR(1)		= NULL
	,@sendCountry		VARCHAR(50)		= NULL
	,@sendAgent			VARCHAR(50)		= NULL
	,@sendBranch		VARCHAR(50)		= NULL
	,@approvedFrom		VARCHAR(10)		= NULL
	,@tpControlNo1		VARCHAR(30)		= NULL
	,@tpControlNo2		VARCHAR(30)		= NULL
) 

AS
BEGIN TRY

	DECLARE 
		 @table             VARCHAR(MAX)
		,@sql		        VARCHAR(MAX)
		,@sqlSelfTxn		VARCHAR(MAX)
		,@sRouteId VARCHAR(5)
		,@collMode VARCHAR(100)

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE 
		 @pinEncrypted VARCHAR(50) = dbo.FNAEncryptString(@pin)
		,@cAmt MONEY
		,@userId INT		
		,@createdBy	VARCHAR(50)
		,@tranStatus VARCHAR(50)
		,@message	VARCHAR(200)
		,@sBranch	BIGINT			
		,@invicePrintMethod VARCHAR(50)
		,@parentId	BIGINT
		,@tablesql AS VARCHAR(MAX)
		,@branchList VARCHAR(MAX) 
		,@denyAmt	MONEY
		,@C2CAgentID VARCHAR(30) = '1045'
		,@REAgentID VARCHAR(30) = '1100'

	IF @pin IS NULL
	BEGIN
		SELECT @pin = dbo.FNADecryptString(controlNo), @pinEncrypted = controlNo FROM remitTranTemp WITH(NOLOCK) WHERE id = @id		
	END
	ELSE
	BEGIN
		SET @pinEncrypted  = dbo.FNAEncryptString(@pin)
	END
	
	DECLARE @PinList TABLE(id VARCHAR(50), pin VARCHAR(50),hasProcess CHAR(1),isOFAC CHAR(1),errorMsg VARCHAR(MAX),tranId INT,createdBy	VARCHAR(50))
	DECLARE @TempcompTable TABLE(errorCode INT,msg VARCHAR(MAX),id VARCHAR(50))
	DECLARE @isSelfApprove VARCHAR(1)
	
	IF @flag = 'approve'
	BEGIN
		declare @pBank int,@paymentMethod varchar(50),@tranType char(1), @externalBankCode INT, @createdDate DATETIME, 
		@senderName VARCHAR(100),@sBranchName VARCHAR(150)
		DECLARE @agentFxGain MONEY

		IF @createdBy = @user
		BEGIN
			EXEC proc_errorHandler 1, 'Same user cannot approve the Transaction', @id
			RETURN
		END		
		DECLARE @customerId BIGINT, @tAmt MONEY, @pAmt MONEY, @introducer VARCHAR(50), @payoutPartner INT, @serviceCharge MONEY,@pCurrCostRate FLOAT,@pCurrHoMargin	FLOAT
		,@isFirstTran CHAR(1), @sAgent int
		
		SELECT
			 @cAmt = cAmt
			,@customerId = cm.customerId 
			,@userId = A.userId
			,@tAmt = r.tAmt
			,@pAmt = r.pAmt
			,@createdBy = r.createdBy
			,@controlNo = dbo.FNADecryptString(controlNo)
			,@sBranch	= sBranch
			,@sBranchName = sBranchName
			,@pBank		= pBank
			,@introducer = promotionCode
			,@sAgent	= sAgent
			,@paymentMethod = paymentMethod
			,@tranType	= tranType
			,@sRouteId = sRouteId
			,@collMode = COLLMODE
			,@externalBankCode = externalBankCode
			,@createdDate = r.createdDate
			,@senderName = r.senderName
			,@tranStatus = R.tranStatus
			,@payoutPartner = R.pSuperAgent
			,@serviceCharge = R.serviceCharge
			,@pCurrCostRate = R.pCurrCostRate
			,@pCurrHoMargin = R.pCurrHoMargin
			,@agentFxGain = R.agentFxGain
			,@isFirstTran = ISNULL(T.isFirstTran, 'N')
		FROM remitTran r WITH(NOLOCK)
		INNER JOIN TRANSENDERS T(NOLOCK) ON T.TRANID = R.ID
		LEFT JOIN customerMaster cm(NOLOCK) ON T.customerId = cm.customerId
		LEFT JOIN applicationUsers A(NOLOCK) ON A.USERNAME = R.CREATEDBY
		WHERE r.id = @id

		DECLARE @kycStatus INT

		--SELECT TOP 1 @kycStatus = kycStatus
		--FROM TBL_CUSTOMER_KYC (NOLOCK) 
		--WHERE CUSTOMERID = @customerId
		--AND ISDELETED = 0--AND kycStatus=11044
		--ORDER BY rowId DESC

		SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId=@sBranch
		SELECT @invicePrintMethod = invoicePrintMethod FROM agentMaster A WITH(NOLOCK) 
		INNER JOIN agentBusinessFunction B WITH(NOLOCK) ON A.agentId=B.agentId
		WHERE A.agentId=@parentId
		
		BEGIN TRANSACTION
			
			DECLARE @TRANID BIGINT = @id


			SET @txnDate = @createdDate

			EXEC PROC_CALCULATE_REFERRAL_COMM @COMMISSION_AMT = @serviceCharge, @T_AMT = @tAmt, @FX = @agentFxGain, @IS_NEW_CUSTOMER = @isFirstTran,
						@REFERRAL_CODE = @introducer, @PAYOUT_PARTNER = @payoutPartner, @CUSTOMER_ID = @customerId, @TRAN_ID = @TRANID, 
						@S_AGENT = @sAgent, @AMOUNT = @cAmt, @USER = @user, @TRAN_DATE = @txnDate, @COLL_MODE = @collMode

			

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			
		RETURN
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() msg, NULL id
END CATCH
GO
