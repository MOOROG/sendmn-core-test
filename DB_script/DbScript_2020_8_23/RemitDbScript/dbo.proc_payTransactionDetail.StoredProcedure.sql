USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payTransactionDetail]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[proc_payTransactionDetail](
		 @flag				VARCHAR(1)			
		,@user			    VARCHAR(50) 			
	    ,@rowId				BIGINT			    = NULL
		,@securityNo		VARCHAR(50)		    = NULL
		,@transactionDate   DATETIME            = NULL
		,@sendingCountry    VARCHAR(50)		    = NULL
		,@senderName        VARCHAR(50)		    = NULL
		,@senderAddress		VARCHAR(50)		    = NULL
		,@senderContactNo	VARCHAR(50)		    = NULL
		,@senderCountry     VARCHAR(50)		    = NULL
		,@senderIdNo		VARCHAR(50)			= NULl
		,@senderIdType		VARCHAR(50)			= NULl
		,@recName			VARCHAR(50)			= NULl
		,@recAddress		VARCHAR(50)			= NULl
		,@recContactNo		VARCHAR(50)			= NULl
		,@recIdType			VARCHAR(50)			= NULl
		,@recIdNo			VARCHAR(50)			= NULl
		,@pAmount			VARCHAR(50)			= NULl
		,@relationType		VARCHAR(50)			= NULl
		,@relativeName		VARCHAR(50)			= NULl
		,@rIdPlaceOfIssue	VARCHAR(50)			= NULl
		,@partnerId         VARCHAR(30)			= NULL
		,@pBranchId			VARCHAR(50)			= NULL
		,@branchName		VARCHAR(200)		= NULL
)
AS

IF @Flag='s'
BEGIN
	DECLARE @agentGrp INT,@cotrolNo VARCHAR(50),@subPartnerId int
	IF @pBranchId IS NOT NULL
		SELECT @branchName = agentName, @agentGrp = agentGrp FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranchId
	
	DECLARE 
		@mapCodeDom VARCHAR(50)
	   ,@tranStatus VARCHAR(50)
	   ,@tranId INT
	   ,@payStatus VARCHAR(50)
	   ,@controlNoEncrypted VARCHAR(50)
	   ,@agentType VARCHAR(50)
	   ,@pTxnLocation VARCHAR(50)
	   ,@pAgentLocation VARCHAR(50)
	   ,@pAgent VARCHAR(50)
	   ,@controlNo VARCHAR(50)
	   ,@paymentMethod VARCHAR(50)
	   ,@sBranchId VARCHAR(50)	  
	   ,@mapCodeInt VARCHAR(50)
	   ,@lockStatus VARCHAR(50)	 
	   ,@payTokenId VARCHAR(50)  
IF (@partnerId='IME-I')    /***** Mongolia INTERNATIONAL *****/
BEGIN 
		
IF @pBranchId IS NULL
BEGIN
	EXEC proc_errorHandler 1, 'Please Choose Agent', NULL
	RETURN
END

SELECT 
		@mapCodeInt = mapCodeInt
	,@agentType = agentType
	,@pAgentLocation = agentLocation 
FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranchId

IF (@mapCodeInt IS NULL OR @mapCodeInt = '' OR @mapCodeInt = 0)
BEGIN
	EXEC proc_errorHandler 1, 'Invalid Map Code', NULL
	RETURN
END
	
SELECT 
		@tranStatus = tranStatus
	, @tranId = id 
	, @lockStatus = lockStatus
	, @payStatus = payStatus
	, @sBranchId = sBranch
	, @paymentMethod = paymentMethod
	, @controlNoEncrypted = controlNo
FROM remitTran WITH(NOLOCK) WHERE id = @rowId
	
IF @tranStatus IS NULL
BEGIN
	EXEC proc_errorHandler 1000, 'Transaction not found', NULL
	RETURN
END

IF @agentType = 2903	
BEGIN
	SET @pAgent = @pBranchId
END

INSERT INTO tranViewHistory(
		controlNumber
	,tranViewType
	,agentId
	,createdBy
	,createdDate
	,tranId
)
SELECT
		@controlNoEncrypted
	,'PAY'
	,@pBranchId
	,@user
	,GETDATE()
	,@tranId
		
IF @paymentMethod = 'Bank Deposit'
BEGIN
	EXEC proc_errorHandler 1, 'Cannot process payment for Payment Type Bank Deposit', NULL
	RETURN	
END
--IF @sBranchId = @pBranchId
--BEGIN
--	EXEC proc_errorHandler 1, 'Cannot process payment for same POS', @tranId
--	RETURN
--END
		
IF (@tranStatus = 'CancelRequest')
BEGIN
	EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
	RETURN
END
IF (@lockStatus = 'Lock' )
BEGIN
	EXEC proc_errorHandler 1, 'Transaction is locked', @controlNoEncrypted
	RETURN
END
IF (@tranStatus = 'Lock' )
BEGIN
	EXEC proc_errorHandler 1, 'Transaction is locked', @controlNoEncrypted
	RETURN
END
IF (@tranStatus = 'Block')
BEGIN
	EXEC proc_errorHandler 1, 'Transaction is blocked. Please Contact HO', @controlNoEncrypted
	RETURN
END
IF (@tranStatus = 'Paid')
BEGIN
	EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
	RETURN
END
IF (@payStatus = 'Paid')
BEGIN
	EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
	RETURN
END
IF (@tranStatus = 'Hold')
BEGIN
	EXEC proc_errorHandler 1, 'Transaction is hold', @controlNoEncrypted
	RETURN
END
IF (@tranStatus = 'Cancel')
BEGIN
	EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNoEncrypted
	RETURN
END
EXEC proc_errorHandler 0, 'Transaction Verification Successful', @tranId	
SET @payTokenId = SCOPE_IDENTITY()	
SELECT TOP 1
			rowId						=trn.id
		,securityNo					=dbo.FNADecryptString(trn.controlNo)	
		,transactionDate		    =trn.createdDateLocal
		,senderName					=sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,senderAddress				=sen.address
		,senderCity					=sen.city
		,senderMobile				=sen.mobile
		,senderTel					=sen.homephone
		,senderIdType				=sen.idType
		,senderIdNo					=sen.idNumber
		,recName					=rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,recAddress					=rec.address
		,recMobile					=rec.mobile
		,recTelePhone				=rec.homephone
		,recIdType					=rec.idType
		,recIdNo					=rec.idNumber
		,recCity					=rec.city
		,recCountry					=rec.country
		,pAmount					=isnull(trn.pAmt,0)
		,rCurrency					=trn.collCurr
		,pCurrency					=trn.payoutCurr
		,remarks					=pMessage
		,paymentMethod				=trn.paymentMethod
		,tokenId					=trn.payTokenId
		,amt						=trn.pAmt
		,pBranch				    =trn.pBranch
		,sendingCountry				=trn.sCountry
		,sendingAgent				=trn.sAgentName
		,branchName					=dbo.GetAgentNameFromId(@pBranchId)
		,providerName				='BRN International'
		,orderNo					= ''	
		,agentGrp					= @agentGrp
		,subPartnerId				= 0
FROM remitTran trn WITH(NOLOCK)
INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
WHERE trn.id = @rowId
		
-- ## Lock Transaction
UPDATE remitTran SET
		payTokenId			= @payTokenId
	,lockStatus			= 'locked'
	,lockedBy			= @user
	,lockedDate			= GETDATE()
	,lockedDateLocal	= GETDATE()
WHERE id = @rowId

-- ## Log Details
SELECT 
		[message]
	,trn.createdBy
	,trn.createdDate
FROM tranModifyLog trn WITH(NOLOCK)
WHERE trn.tranId = @tranId OR ISNULL(trn.controlNo,'') = @controlNoEncrypted
ORDER BY trn.createdDate DESC

-- ## Compliance pay details Details
SELECT tranId
		,controlNo
		,pBranch
		,receiverName
		,rMemId
		,dob = CONVERT(VARCHAR(10),dob,101)
		,rIdType
		,rIdNumber
		,rPlaceOfIssue
		,rContactNo
		,rRelationType
		,rRelativeName
		,relWithSender
		,purposeOfRemit = ISNULL(sd.detailTitle,purposeOfRemit)
		,purposeOfRemitId = purposeOfRemit	
		,reason
		,bankName
		,branchName
		,chequeNo
		,accountNo
		,alternateMobileNo FROM tranPayCompliance tc WITH(NOLOCK)
		LEFT JOIN staticDataValue sd WITH(NOLOCK) ON tc.purposeOfRemit=sd.valueId
		WHERE tc.tranId = @tranId OR ISNULL(tc.controlNo,'') = ISNULL(@controlNoEncrypted, '')
END

IF(@partnerId='394432')  /***** GME Korea (Dhansingh) *****/
BEGIN
EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId
SELECT TOP 1 
	rowId				= tbl.rowId
	,securityNo		    = dbo.FNADecryptString(tbl.refNo)
	,transactionDate	= tbl.createdDate		
	,senderName		    = tbl.senderName	
	,senderAddress	    = tbl.senderAddress
	,senderMobile		= tbl.senderMobile	
	,senderIdNo		    = ''	
	,senderIdType		= ''
	,senderCity			= tbl.senderCity
	,recName		    = tbl.benefName
	,recAddress		    = tbl.benefAddress
	,recMobile			= tbl.benefMobile
	,recIdType		    = ''
	,recIdNo		    = ''
	,recCity			= tbl.benefCity
	,recCountry			= tbl.benefCountry
	,pAmount		    = isnull(tbl.pAmount,0)
	,rCurrency			= ''
	,pCurrency			= tbl.pCurrency
	,remarks			= tbl.remarks	
	,paymentMethod		= 'Cash Payment'
	,tokenId			= tbl.tokenId
	,amt				= isnull(tbl.pAmount,0)
	,pBranch			= tbl.pBranch	
	,sendingCountry		= tbl.senderCountry
	,sendingAgent		= 'GME Korea Remit'	
	,branchName			= @branchName
	,providerName       = 'GME Korea Remit'
	,orderNo			= ''		  
	,agentGrp			= @agentGrp
	,subPartnerId		= ''
FROM dbo.GMEPayHistory tbl WITH(NOLOCK)	
WHERE  rowId = @rowId ORDER BY rowId DESC

-- ## Log Details
SELECT TOP 1
		[message]
	,trn.createdBy
	,trn.createdDate
FROM tranModifyLog trn WITH(NOLOCK)
WHERE 1=2

RETURN
END
END







GO
