USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_approveTranAPI_v2]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_approveTranAPI_v2] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(20)		= NULL
	,@tranId			INT				= NULL	
	,@sCountry			INT				= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL	
	,@sTranId			VARCHAR(50)		= NULL	
	,@rCountry			INT				= NULL
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL
	,@pCountry			INT				= NULL
	
	,@customerId		INT				= NULL
	,@agentId			INT				= NULL
	,@senderId			INT				= NULL
	,@benId				INT				= NULL
	,@cancelReason		VARCHAR(200)	= NULL
	,@cAmt				MONEY			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON

SELECT @pageSize = 1000, @pageNumber = 1

	DECLARE
		 @code						VARCHAR(50)	= NULL
		,@userName					VARCHAR(50)	= NULL
		,@password					VARCHAR(50)	= NULL
	
	DECLARE @sBranch INT, @bankId INT, @pBankBranch INT, @branchMapCode VARCHAR(8), @bankBranchName VARCHAR(200), @pAgentComm MONEY
	
	EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT
	DECLARE @controlNoEncrypted		VARCHAR(100)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	
IF @flag = 'approve'			--Approve
BEGIN
	--Check if the approver is the same user who sent transaction
	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND createdBy = @user)
	BEGIN
		SELECT 1 Code, @agentRefId agent_refId, 'Process denied for same user' [message], @controlNo refId
		RETURN	
	END
	DECLARE @tranStatus VARCHAR(20) = NULL
	SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	SELECT @tranStatus = tranStatus, @cAmt = cAmt FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @sBranch <> dbo.FNAGetHOAgentId() --Head Office
	BEGIN
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch <> @sBranch)
		BEGIN
			EXEC proc_errorHandler 0, 'Transaction is not in authorized mode', @tranId
			RETURN
		END
	END
	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction has been requested for cancel', @tranId
		RETURN
	END
	IF (@tranStatus = 'Payment')
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction already been approved and ready for payment', @tranId
		RETURN
	END
	IF (@tranStatus = 'Paid')
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction is not in authorized mode', @tranId
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction is cancelled', @tranId
		RETURN
	END
	IF (@tranStatus = 'Lock')
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction is locked. Please Contact HO', @tranId
		RETURN
	END
	DECLARE @userId INT, @sendPerTxn MONEY, @sendPerDay MONEY, @sendTodays MONEY
	SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @sendPerDay = sendPerDay, @sendPerTxn = sendPerTxn, @sendTodays = ISNULL(sendTodays, 0) FROM userWiseTxnLimit WITH(NOLOCK) WHERE userId = @userId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
	IF(@cAmt > @sendPerTxn)
	BEGIN
		EXEC proc_errorHandler 0, 'Transfer Amount exceeds user per transaction limit.', @tranId
		RETURN
	END
	IF(@sendTodays > @sendPerDay)
	BEGIN
		EXEC proc_errorHandler 0, 'User Per Day Transaction Limit exceeded.', @tranId
		RETURN
	END
	
	SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @cAmt = cAmt FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	UPDATE remitTran SET
		  tranStatus				= 'Payment'					--Payment
		 ,approvedBy				= @user
		 ,approvedDate				= dbo.FNAGetDateInNepalTZ()
		 ,approvedDateLocal			= dbo.FNAGetDateInNepalTZ()
	WHERE controlNo = @controlNoEncrypted
	
	UPDATE userWiseTxnLimit SET
			 sendTodays = ISNULL(sendTodays, 0) + @cAmt
		WHERE userId = @userId
	
	EXEC proc_errorHandler 0, 'Transaction Approved Successfully', @tranId
	
	--SELECT @code, @userName, @password, @controlNo, @agentRefId
	--RETURN
	DECLARE 
		 @rCity				VARCHAR(50)		= NULL
		,@payoutMethod		CHAR(1)			= NULL
		,@sFullName			VARCHAR(150)	= NULL
		,@sAddress			VARCHAR(100)	= NULL
		,@sContactNo		VARCHAR(20)		= NULL
		,@sIdType			VARCHAR(50)		= NULL
		,@sIdNo				VARCHAR(20)		= NULL
		,@sEmail			VARCHAR(100)	= NULL
		,@rFullName			VARCHAR(150)	= NULL
		,@rAddress			VARCHAR(100)	= NULL
		,@rContactNo		VARCHAR(20)		= NULL
		,@rIdType			VARCHAR(50)		= NULL
		,@rIdNo				VARCHAR(20)		= NULL
		,@relationship		VARCHAR(50)		= NULL
		,@deliveryMethod	VARCHAR(100)	= NULL
		,@pLocation			INT				= NULL
		,@accountNo			VARCHAR(50)		= NULL
		,@serviceCharge		MONEY			= NULL
		,@sAgentComm		MONEY			= NULL
		,@pAmt				MONEY			= NULL
		,@mapCode			VARCHAR(10)		= NULL
		,@remarks			VARCHAR(200)	= NULL
	
	SELECT
		 @sBranch			= sBranch
		,@sFullName			= sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,@sAddress			= sen.[address]
		,@sContactNo		= sen.mobile
		,@sIdType			= sen.idType
		,@sIdNo				= sen.idNumber
		,@sEmail			= sen.email
		,@rFullName			= rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,@rAddress			= rec.[address]
		,@rContactNo		= rec.mobile
		,@rIdType			= rec.idType
		,@rIdNo				= rec.idNumber
		,@rCity				= rec.city
		,@relationship		= trn.relWithSender
		,@deliveryMethod	= trn.paymentMethod
		,@serviceCharge		= trn.serviceCharge
		,@cAmt				= trn.cAmt
		,@sAgentComm		= trn.sAgentComm
		,@pAgentComm		= trn.pAgentComm
		,@pAmt				= trn.pAmt
		,@pLocation			= trn.pLocation
		,@accountNo			= trn.accountNo
		,@pBankBranch		= trn.pBankBranch
		,@bankId			= trn.pBank
		,@user				= trn.createdBy
		,@remarks			= trn.pMessage
		,@tranId			= trn.id
	FROM remitTran trn WITH(NOLOCK)
	INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	WHERE controlNo = @controlNoEncrypted
	
	SELECT @mapCode = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	SELECT @payoutMethod = CASE WHEN @deliveryMethod = 'Cash Payment' THEN 'C' WHEN @deliveryMethod = 'Bank Deposit' THEN 'B' END
	IF @deliveryMethod = 'Bank Deposit'
	BEGIN
		SELECT @branchMapCode = mapCodeDom FROM agentMaster WITH(NOLOCK) WHERE agentId = @bankId
		SELECT @bankBranchName = agentAddress FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
	END
	
	IF @remarks IS NOT NULL
	BEGIN
		EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @remarks, @agentRefId = NULL
	END
	
END


GO
