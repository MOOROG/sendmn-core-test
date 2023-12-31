USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payTxnValidation]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_payTxnValidation](
		 @flag				VARCHAR(1)			
		,@user			    VARCHAR(50) 			
	    ,@rowId				BIGINT			    = NULL
		,@controlNo			VARCHAR(50)		    = NULL
		,@partnerId         VARCHAR(30)			= NULL
		,@pBranchId			VARCHAR(50)			= NULL
)
AS

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
	,@paymentMethod VARCHAR(50)
	,@sBranchId VARCHAR(50)
	,@branchName VARCHAR(200)
	,@mapCodeInt VARCHAR(50)
	,@lockStatus VARCHAR(50)
	,@userAgentId INT
	,@complianceHoldPay CHAR(1)
	,@sSuperAgent		VARCHAR(20)
	   
	SET @controlNo = UPPER(@controlNo)
	SET @controlNoEncrypted = DBO.FNAEncryptString(@controlNo)
IF @flag = 'S'
BEGIN
	IF (@partnerId='IME-I')  
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
			, @complianceHoldPay =  CASE WHEN ISNULL(tc.controlNo ,'')='' THEN 'N' 
										ELSE 'Y' 
									END
			,@sSuperAgent = rt.sSuperAgent
		FROM remitTran rt WITH(NOLOCK) 
		LEFT JOIN tranPayCompliance tc WITH(NOLOCK)
		ON rt.controlNo = tc.controlNo
		WHERE rt.controlNo = @controlNoEncrypted

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

		IF (@tranStatus = 'Compliance')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is in Compliance !!!', @controlNoEncrypted
			RETURN
		END	

		IF (@tranStatus = 'Hold')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is hold', @controlNoEncrypted
			RETURN
		END
		IF @tranStatus IN ('Hold','OFAC Hold','Compliance Hold','OFAC/Compliance Hold','Compliance Hold Pay')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is hold', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus <> 'Payment')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
			RETURN
		END
		--IF (@sSuperAgent = dbo.FNAGetIntlAgentId())
		--BEGIN
		--	EXEC proc_errorHandler 1, 'You can not pay transaction of same country!!', NULL
		--	RETURN
		--END
		IF @complianceHoldPay = 'Y'
		BEGIN
			EXEC proc_errorHandler 101, 'Transaction Verification Successful', @tranId
		END
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @tranId
	END
END






GO
