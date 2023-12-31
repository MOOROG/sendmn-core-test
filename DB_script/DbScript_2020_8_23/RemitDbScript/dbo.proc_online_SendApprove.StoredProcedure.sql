USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_SendApprove]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_online_SendApprove] (	 
	 @flag				VARCHAR(50)	
	,@user				VARCHAR(30)	= NULL
    ,@controlNo			VARCHAR(50) = NULL
    --,@mrn				VARCHAR(50) = NULL
	,@id				VARCHAR(50) = NULL
	,@detailVal			VARCHAR(max) = NULL
	,@strPaymentType	VARCHAR(50) = NULL
	,@fltAmount			VARCHAR(50) = NULL
	,@intStatus			VARCHAR(200) = NULL
	,@rfName VARCHAR(100) = NULL 
	,@sIdType VARCHAR(100) =NULL
	,@sIdNo   VARCHAR(100) =NULL
	,@sMobile VARCHAR(50) = NULL 
    ,@sCountry VARCHAR(100) = NULL 
	--,@statusSofort	VARCHAR(200) = NULL
	--,@statusReason	VARCHAR(200) = NULL
	--,@merchantSig		VARCHAR(200) = NULL
	--,@SofoTxnId		VARCHAR(50) = NULL
	,@BankName			VARCHAR(200) = NULL
	,@tranId			varchar(50) = NULL
	,@senderRealName	VARCHAR(200) = NULL
	,@agentRefId		VARCHAR(50)	= NULL
	,@postCodeResponse	VARCHAR(50)	= NULL
	,@addressResponse	VARCHAR(50)	= NULL
	,@voucherDetails	xml = null
	
) 

AS
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE 
		 @pinEncrypted VARCHAR(50) = dbo.FNAEncryptString(@controlNo)
		,@createdBy VARCHAR(50)
		,@customerStatus VARCHAR(20)
	DECLARE @pCountry varchar(50),@deliveryMethod VARCHAR(30), @cAmt MONEY, @pBank INT, @pBankName varchar(100), @pAgent INT, @pAgentName varchar(100)
	DECLARE @txnUser VARCHAR(50) = 'onlineuser'
	DECLARE @controlNoEncrypted VARCHAR(20)
	declare @tranStatus varchar(20)
	DECLARE @receiverOfacRes VARCHAR(MAX),@ofacRes VARCHAR(MAX),@ofacReason VARCHAR(MAX), @senderName VARCHAR(200), @receiverName VARCHAR(200),
		@senderId BIGINT, @receiverId BIGINT, @sBranch INT, @pBranch INT, @sCountryId INT, @pCountryId INT, @deliveryMethodId INT, @tAmt MONEY,
		@accountNo VARCHAR(100), @rMobile VARCHAR(50), @agentSessionId VARCHAR(100)
	DECLARE @result VARCHAR(MAX),@sAgent int
	DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20)
	DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)

	
	IF @flag = 'updateOnlineTxn'
	BEGIN
			SELECT 
					 @customerStatus = CASE WHEN ISNULL(customerStatus, 'P') = 'P' THEN 'PendingUser' ELSE 'VerifiedUser' END 
					,@pCountry = r.pCountry
					,@deliveryMethod = paymentMethod, @pBank = pBank, @pBankName = pBankName
					,@cAmt = r.cAmt
					,@senderId = c.customerId
			FROM dbo.customerMaster c WITH(NOLOCK)
			INNER JOIN remitTranTempOnline r ON r.createdBy = c.email AND ISNULL(c.onlineUser,'N')='Y'
			WHERE r.id = @id
			
			IF @intStatus = '1'
			BEGIN
				-->>Start:OFAC/Compliance Checking
				SELECT
					 @controlNoEncrypted	= controlNo
					,@controlNo				= dbo.FNADecryptString(controlNo) 
					,@senderName = senderName, @receiverName = receiverName, @sBranch = sBranch, @pBranch = pBranch
					,@sCountryId			= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry)
					,@pCountryId			= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = pCountry)
					,@deliveryMethodId		= (SELECT serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = paymentMethod)
					,@tAmt					= tAmt
					,@accountNo				= accountNo
					,@sAgent				= sAgent
					,@agentRefId			= promotionCode
				FROM remitTranTempOnline WITH(NOLOCK)
				WHERE id = @id
				
				SELECT @senderId = customerId FROM tranSendersTempOnline WITH(NOLOCK) WHERE tranId = @id
				SELECT @receiverId = customerId, @rMobile = mobile FROM tranReceiversTempOnline WITH(NOLOCK) WHERE tranId = @id
				
				SET @agentSessionId = NEWID()
				
				EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @ofacRes OUTPUT
				EXEC proc_ofacTracker @flag = 't', @name = @receiverName, @Result = @receiverOfacRes OUTPUT
				
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
				
				SELECT @sCountry = countryName FROM dbo.countryMaster WHERE countryId = @sCountryId
				
				

				BEGIN TRANSACTION
					DECLARE 
						@msg VARCHAR(MAX)
						,@complienceMessage varchar(1000)   = NULL 
						,@shortMsg          varchar(100)    = NULL 
						,@complienceErrorCode TINYINT		= NULL
						,@complianceRuleId	INT				= NULL
					EXEC [proc_complianceRuleDetail] 
						@user    = @user
						,@sIdType   = @sIdType
						,@sIdNo    = @sIdNo
						,@receiverName  = @rfName
						,@cAmt    = @cAmt
						,@country   = @sCountry
						,@message   = @complienceMessage OUTPUT
						,@shortMessage  = @shortMsg    OUTPUT
						,@errCode   = @complienceErrorCode OUTPUT
						,@ruleId   = @complianceRuleId  OUTPUT
    
					IF(@complienceErrorCode <> 0)
					BEGIN  
						IF @@TRANCOUNT > 0
						COMMIT TRANSACTION
						IF(@complienceErrorCode = 2)
						BEGIN
							INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
							SELECT @complianceRuleId, NULL, @agentRefId
						END 
						
						--IF(@complienceErrorCode = 1)
						--BEGIN
						--	SELECT 101 errorCode,@complienceMessage msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
						--END 
						--ELSE 
						--BEGIN
						--	INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
						--	SELECT @complianceRuleId, NULL, @agentRefId

						--	--SELECT 102 errorCode,@complienceMessage msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
						--END
   
						INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName, receiverCountry, payOutAmt,
							complianceId, complianceReason, complainceDetailMessage, createdBy, createdDate)
						SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName, @pCountry, @cAmt, 
							@complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE()

						--DECLARE @tempRowId INT = @@IDENTITY

						--SELECT
						--	id
						--	,csDetailRecId = ''
						--	,[S.N.]  = ROW_NUMBER()OVER(ORDER BY id) 
						--	,[Remarks] = complianceReason
						--	,[Action] = CASE WHEN @complienceErrorCode=102 THEN 'HOLD' ELSE 'Blocked' END
						--	--,[Matched Tran ID] = ''
						--FROM ComplianceLog 
						--WHERE id = @tempRowId
					END
				
					--<<End:OFAC/Compliance Checking
				
					UPDATE creditLimit SET 
						todaysSent = ISNULL(todaysSent, 0) + @tAmt
					WHERE agentId = @sAgent
   
   					/*
					Move from tempOnline to Main Temp table
					*/
					--EXEC proc_online_temp_to_main @id = @id, @voucherDetails = @voucherDetails
					EXEC proc_online_temp_to_main @id = @id
			
					-- UPDATE Limit
					UPDATE dbo.customerMaster SET lastTranId = @tranId
						,todaysSent		= ISNULL(todaysSent,0) + @cAmt
						,totalSent		= ISNULL(totalSent,0)+ @cAmt
					WHERE customerId = @senderId
					
						
					
					-->>Start:OFAC/Compliance Verification
					IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId)
					BEGIN
						INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
						SELECT @tranId, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId
						SET @compFinalRes = 'C'
						
						DELETE FROM dbo.remitTranComplianceTemp WHERE agentRefId = @agentRefId
					END
					
					IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '')
					BEGIN
						IF(@ofacRes <> '' AND ISNULL(@compFinalRes, '') = '')
						BEGIN
							INSERT remitTranOfac(TranId, blackListId, reason, flag)
							SELECT @id, @ofacRes, @ofacReason, NULL
							
							UPDATE remitTranTemp SET
								 tranStatus	= CASE WHEN @customerStatus = 'PendingUser' THEN 'OFAC Hold' ELSE 'OFAC' END
							WHERE controlNo = @controlNoEncrypted
						END
						
						ELSE IF(@compFinalRes <> '' AND ISNULL(@ofacRes, '') = '')
						BEGIN
							UPDATE remitTranTemp SET
								 tranStatus	= CASE WHEN @customerStatus = 'PendingUser' THEN 'Compliance Hold' ELSE 'Compliance' END
							WHERE controlNo = @controlNoEncrypted
						END
						
						ELSE IF(ISNULL(@compFinalRes, '') <> '' AND ISNULL(@ofacRes, '') <> '')
						BEGIN
							INSERT remitTranOfac(TranId, blackListId, reason)
							SELECT @id, @ofacRes, @ofacReason
							
							UPDATE remitTranTemp SET
								 tranStatus	= CASE WHEN @customerStatus = 'PendingUser' THEN 'OFAC/Compliance Hold' ELSE 'OFAC/Compliance' END
							WHERE controlNo = @controlNoEncrypted
						END
					END
					
					SELECT @tranStatus=r.tranStatus FROM remittranTemp r where id=@tranId					
					IF @tranStatus = 'Payment'
					BEGIN
						-->>Shift to main table
						EXEC proc_remitTranTempToMain @tranId
					END
					
				IF @@TRANCOUNT > 0
					COMMIT TRANSACTION				
				SELECT 0 ErrorCode , 'Transaction Approved Successfully' Msg, @tranId Id, @customerStatus Extra
			END
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH


GO
