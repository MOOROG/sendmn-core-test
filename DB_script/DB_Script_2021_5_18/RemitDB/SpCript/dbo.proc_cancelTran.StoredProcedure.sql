USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cancelTran]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_cancelTran] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
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
	,@refund			CHAR(1)			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
	,@cancelId			VARCHAR(100)	= NULL
) 
AS

DECLARE 
	@tranStatus VARCHAR(20) = NULL,
	@payStatus	VARCHAR(50)  = NULL,
	@tranType	CHAR(1)		= NULL


DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)
	,@sAgent			INT
	,@tAmt				MONEY
	,@pAmt				MONEY
	,@message			VARCHAR(200)

SET NOCOUNT ON
SET XACT_ABORT ON
SELECT @pageSize = 1000, @pageNumber = 1

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	,@lockStatus				VARCHAR(20)

DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(LTRIM(RTRIM(@controlNo))))

IF @flag = 'cancelRequest'
BEGIN
	IF @user IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Your session has expired. Cannot send cancel request', NULL
		RETURN
	END
	
	SELECT 
		@tranStatus = tranStatus,
		@payStatus	= payStatus,
		@tranId		= id,
		@lockStatus = lockStatus
	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted

	IF (@tranStatus IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction not found', @controlNoEncrypted
		RETURN
	END
	
	SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	IF @agentId <> (SELECT dbo.FNAGetHOAgentId()) 
	BEGIN
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) 
		  WHERE controlNo = @controlNoEncrypted AND sBranch <> @agentId)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
			RETURN
		END
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
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
		RETURN
	END


	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Cancel Request has already been sent', @controlNoEncrypted
		RETURN
	END
	BEGIN TRANSACTION
		UPDATE remitTran SET
			 tranStatus				= 'CancelRequest'		--Transaction  Hold
			,trnStatusBeforeCnlReq	=	tranStatus			
			,cancelRequestBy		= @user
			,cancelRequestDate		= GETDATE()
			,cancelRequestDateLocal	= GETDATE()
			,cancelReason			= ISNULL(@cancelReason,cancelReason)
			,oldSysTranNo			=	@cancelId
		WHERE controlNo = @controlNoEncrypted
	
	SELECT @message = 'Transaction requested for Cancel. Reason : ''' + @cancelReason + ''''
	
	INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,createdBy,createdDate,tranStatus)
	SELECT @tranId,@controlNoEncrypted,@cancelReason,'CancelRequest',@user,GETDATE(),@tranStatus

	EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Cancel Request'
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
	EXEC proc_errorHandler 0, 'Request for cancel done successfully', @controlNoEncrypted
	
	EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @message, @agentRefId = NULL
END

ELSE IF @flag = 'cancel'	
	BEGIN
		-- @refund ='N' TREATED AS NORMAL / FULL RETUND  --WHEN RT.Pagent IN( 221226) then (RT.cAmt-rt.serviceCharge) 
		DECLARE @sBranch INT, @pLocation INT, @pAgentComm MONEY, @cancelCharge MONEY, @returnAmt MONEY
			, @idNumber VARCHAR(25),@accountType VARCHAR(20), @cAmt MONEY, @userId INT, @collMode VARCHAR(20)
		DECLARE @referralCode VARCHAR(15),@sType CHAR(1),@isOnbehalf CHAR(1),@date1 DATETIME,@date2 DATETIME,@createDate DATETIME 

		SELECT 
			 @tranStatus		= RT.tranStatus
			,@sBranch			= RT.sBranch
			,@userId			= A.userId
			,@sAgent			= RT.sAgent
			,@pLocation			= RT.pLocation
			,@tAmt				= RT.tAmt 
			,@returnAmt			= CASE WHEN ISNULL(@refund,'')='D' OR RT.Pagent IN( 221226) then rt.tAmt  else RT.cAmt end 
			,@pAmt				= RT.pAmt
			,@tranId			= RT.id
			,@customerId		= S.customerId
			,@idNumber			= S.idNumber
			,@refund			= case when RT.Pagent IN( 221226) then 'D' else @refund end
			,@accountType		= rt.SrouteId
			,@cAmt				= rt.cAmt
			,@collMode			= RT.COLLMODE
			,@createDate		= RT.createdDate
			,@referralCode = PROMOTIONCODE
			,@isOnbehalf = (CASE WHEN ISONBEHALF = '1' THEN 'Y' ELSE 'N' END)
		FROM remitTran RT WITH(NOLOCK) 
		INNER JOIN tranSenders S WITH(NOLOCK) ON S.tranId = RT.id
		LEFT JOIN applicationUsers A(NOLOCK) ON A.USERNAME = RT.CREATEDBY
		WHERE controlNo = @controlNoEncrypted
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction', NULL
			RETURN
		END
		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Hold')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is hold. Transaction must be approved for cancellation.', NULL
			RETURN
		END
				
		SET @cancelCharge = 0

		BEGIN TRANSACTION
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
				 ,cancelReason				= @cancelReason
				 ,refund					= @refund
			WHERE controlNo = @controlNoEncrypted

			--SELECT @message = 'Cancel Request Approved'
			SELECT @message = @cancelReason
			EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Cancel Approved'

			--update balance
			EXEC proc_UpdateCustomerBalance @controlNo=@controlNoEncrypted

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		declare @ref_num varchar(20)
		select top 1  @ref_num = t.ref_num from SendMnPro_Account.dbo.tran_master t(nolock)
		WHERE field1 = @controlNo AND t.tran_type = 's' AND field2 = 'Send Voucher'
		
		IF @ref_num is NOT null
		BEGIN
			set @cancelReason ='Cancellation and refund of '+@controlNo

			declare @tempTbl table (errorcode varchar(5), msg varchar(max), id varchar(50))

			insert into @tempTbl(errorcode, msg, id)
			EXEC SendMnPro_Account.dbo.proc_CancelTranVoucher @flag = 'REVERSE',@refNum=@ref_num,@vType='s',@refund='N',@user=@user,@remarks=@cancelReason
		END
		
		set @message = 'Transaction Cancelled '

		EXEC [proc_errorHandler] 0, @message, @tranId

	END
ELSE IF @flag = 'cancelReject'
BEGIN
	BEGIN TRANSACTION
		UPDATE remitTran SET
			 tranStatus				= 'Payment'					
		WHERE controlNo = @controlNoEncrypted
	
	SELECT @tranId = id	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	SELECT @message = 'Cancel Request for this transaction rejected'
	EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Cancel Reject'
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
	EXEC proc_errorHandler 0, 'Cancel Request rejected successfully', @controlNoEncrypted
	
	EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @message, @agentRefId = NULL	
END
ELSE IF @flag = 'detailsAgent'
BEGIN
		SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

		SELECT 
			@tranStatus = tranStatus,
			@payStatus = payStatus 
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted

		IF (@tranStatus IS NOT NULL)
		BEGIN
			INSERT INTO tranViewHistory(
				 controlNumber
				,tranViewType
				,createdBy
				,createdDate
			)
			SELECT
				 @controlNoEncrypted
				,'C'
				,@user
				,GETDATE()
		END
		ELSE
		BEGIN
			EXEC proc_errorHandler 1000, 'No Transaction Found', @controlNoEncrypted
			RETURN
		END
		
		IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch = @agentId)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest' AND @payStatus = 'UnPaid')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is in Modification Status', @controlNoEncrypted
			RETURN
		END
		IF (@payStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Cancel Request has already been sent', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Lock')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked. Please contact HO', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Block')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is blocked. Please contact HO', @controlNoEncrypted
			RETURN
		END
		--IF (@payStatus = 'Post')
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Transaction is Post. Please contact Head Office.', @controlNoEncrypted
		--	RETURN
		--END
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
		SELECT 
			 trn.id
			,controlNo = dbo.FNADecryptString(trn.controlNo)
			,sMemId = sen.membershipId
			,sCustomerId = sen.customerId
			,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
			,sCountryName = sen.country
			,sStateName = sen.state
			,sDistrict = sen.district
			,sCity = sen.city
			,sAddress = sen.address
			,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
			
			,sIdType = sen.idType
			,sIdNo = sen.idNumber
			,sValidDate = sen.validDate
			,sEmail = sen.email
			
			,rMemId = rec.membershipId
			,rCustomerId = rec.customerId
			,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
			,rCountryName = rec.country
			,rStateName = rec.state
			,rDistrict = rec.district
			,rCity = rec.city
			,rAddress = rec.address
			,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
			,rIdType = rec.idType
			,rIdNo = rec.idNumber
			
			,sBranchName = trn.sBranchName
			,sAgentName = CASE WHEN trn.sAgent = trn.sBranch THEN trn.sSuperAgentName ELSE trn.sAgentName END
			,sAgentLocation = sLoc.districtName
			,sAgentDistrict = sa.agentDistrict
			,sAgentCity = sa.agentCity
			,sAgentCountry = sa.agentCountry
			
			,pAgentName = CASE WHEN trn.pAgentName = trn.pBranchName THEN trn.pSuperAgentName ELSE trn.pAgentName END
			,pBranchName = trn.pBranchName
			,pAgentCountry = trn.pCountry
			,pAgentState = trn.pState
			,pAgentDistrict = trn.pDistrict
			,pAgentLocation = pLoc.districtName
			,pAgentCity = pa.agentCity
			,pAgentAddress = pa.agentAddress
			
			,trn.tAmt
			,trn.serviceCharge
			,handlingFee = ISNULL(trn.handlingFee, 0)
			,trn.cAmt
			,trn.pAmt
			
			,relationship = ISNULL(trn.relWithSender, '-')
			,purpose = ISNULL(trn.purposeOfRemit, '-')
			,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
			,collMode = trn.collMode
			,trn.collCurr
			,paymentMethod = trn.paymentMethod
			,trn.payoutCurr
			,trn.tranStatus
			,trn.payStatus
			,payoutMsg = ISNULL(trn.pMessage, '-')
			,trn.createdBy
			,trn.createdDate
			,trn.approvedBy
			,trn.approvedDate
		FROM remitTran trn WITH(NOLOCK)
		LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
		LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
		LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
		LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
		WHERE trn.controlNo = @controlNoEncrypted
		
	END

ELSE IF @flag = 'cancelReceipt'
BEGIN
	DECLARE @AccName NVARCHAR(100),@AccNo VARCHAR(30),@BankName NVARCHAR(100)

	SELECT @controlNoEncrypted = DBO.fnaDecryptstring(Controlno) FROM remitTran(NOLOCK) WHERE holdtranid = @tranId

	SELECT top 1 @tAmt = TRAN_AMT FROM SendMnPro_Account.dbo.TRAN_MASTER(NOLOCK) WHERE acc_num='100241027580' and field1 = @controlNoEncrypted and field2='Remittance Voucher'
	and acct_type_code='Reverse'

	SELECT @AccName = accountName,@AccNo = accountNum,@BankName = bankName FROM DBO.[FNA_KFTC_CUST_DETAILBY_TXN](@tranId)
	SELECT
		 controlNo = dbo.FNADecryptString(controlNo)
		,postedBy = trn.sBranchName
		,createdDate
		,cancelDate = cancelApprovedDate
		,sender = sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
		,receiver = rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
		,rContactNo = rec.mobile
		,trn.collCurr
		,trn.cAmt
		,trn.serviceCharge
		,trn.pAmt
		,trn.cancelCharge
		--,returnAmt = trn.cAmt - ISNULL(trn.cancelCharge,0)
		,returnAmt = ISNULL(@tAmt,trn.cAmt)
		,@AccName AccName,@AccNo AccNo,@BankName BankName
	FROM remitTran trn WITH(NOLOCK)
	INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	WHERE trn.holdtranid = @tranId
	
END
ELSE IF @flag = 's'
BEGIN
	
	SET @table = '(
				SELECT 
					 trn.id
					,controlNo = dbo.FNADecryptString(trn.controlNo)
					,sCustomerId = sen.customerId
					,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,sCountryName = sen.country
					,sStateName = sen.state
					,sCity = sen.city
					,sAddress = sen.address
					,rCustomerId = rec.customerId
					,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,rCountryName = rec.country
					,rStateName = rec.state
					,rCity = rec.city
					,rAddress = rec.address
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE trn.tranStatus = ''CancelRequest'' and TranType =''D''
	'
	SET @sql_filter = ''
	
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
		
	IF @sFirstName IS NOT NULL
		SET @table = @table + ' AND sen.firstName LIKE ''' + @sFirstName + '%'''
		
	IF @sMiddleName IS NOT NULL
		SET @table = @table + ' AND sen.middleName LIKE ''' + @sMiddleName + '%'''
		
	IF @sLastName1 IS NOT NULL
		SET @table = @table + ' AND sen.lastName1 LIKE ''' + @sLastName1 + '%'''
		
	IF @sLastName2 IS NOT NULL
		SET @table = @table + ' AND sen.lastName2 LIKE ''' + @sLastName2 + '%'''
		
	IF @sMemId IS NOT NULL
		SET @table = @table + ' AND sen.membershipId = ' + CAST(@sMemId AS VARCHAR)
			
	IF @rFirstName IS NOT NULL
		SET @table = @table + ' AND rec.firstName LIKE ''' + @rFirstName + '%'''
		
	IF @rMiddleName IS NOT NULL
		SET @table = @table + ' AND rec.middleName LIKE ''' + @rMiddleName + '%'''
		
	IF @rLastName1 IS NOT NULL
		SET @table = @table + ' AND rec.lastName1 LIKE ''' + @rLastName1 + '%'''
		
	IF @rLastName2 IS NOT NULL
		SET @table = @table + ' AND rec.lastName2 LIKE ''' + @rLastName2 + '%'''		
		
	IF @rMemId IS NOT NULL
		SET @table = @table + ' AND c.membershipId = ' + CAST(@rMemId AS VARCHAR)
		
	SET @select_field_list ='
				 id
				,controlNo
				,sCustomerId
				,senderName
				,sCountryName
				,sStateName
				,sCity
				,sAddress
				,rCustomerId
				,receiverName
				,rCountryName
				,rStateName
				,rCity
				,rAddress				
			   '
	SET @table = @table + ') x'
			
	EXEC dbo.proc_paging
            @table
           ,@sql_filter
           ,@select_field_list
           ,@extra_field_list
           ,@sortBy
           ,@sortOrder
           ,@pageSize
           ,@pageNumber
END

ELSE IF @flag = 'checkCancleTxn'
BEGIN
	SELECT 
		@tranStatus = tranStatus,
		@tranType	= tranType,
		@tranId		= id
	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	IF (@tranStatus IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid transaction', @controlNo
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		  SELECT errorCode = 0, msg = 'Success', id = @controlNo, extra = @tranType, extra2 = @tranId
		  RETURN
	END
	ELSE 
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid transaction', @controlNo
	END
END



IF @flag='getallcanceltxn'
BEGIN
    SELECT	pSuperAgent					pSuperAgent,
			dbo.decryptDb(controlNo)	controlNo,
			oldSysTranNo				cancelId
	FROM dbo.remitTran (NOLOCK) WHERE tranStatus = 'CancelRequest'
END

GO
