USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cePayHistory_v2]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[proc_cePayHistory_v2]
	 @flag							VARCHAR(50)
	,@user							VARCHAR(50)
	,@rowId							BIGINT		 = NULL	
	,@ceNumber                      VARCHAR(256) = NULL
	,@originatingAgentRefNum        VARCHAR(256) = NULL
	,@senderName                    VARCHAR(256) = NULL
	,@senderCountry                 VARCHAR(256) = NULL
	,@senderAgentCode               VARCHAR(256) = NULL
	,@senderAgentName               VARCHAR(256) = NULL
	,@senderMobileNumber            VARCHAR(256) = NULL
	,@senderMessageToBeneficiary	VARCHAR(256) = NULL
	,@txnCreatedDate                VARCHAR(256) = NULL
	,@receiverName                  VARCHAR(256) = NULL
	,@receiverMobile                VARCHAR(256) = NULL
	,@payoutCurrencyCode            VARCHAR(256) = NULL
	,@payoutCurrencyName            VARCHAR(256) = NULL
	,@sentAmount                    VARCHAR(256) = NULL
	,@charges                       VARCHAR(256) = NULL
	,@finalPayoutAmount             VARCHAR(256) = NULL
	,@receiverAccountNumber         VARCHAR(256) = NULL
	,@receiverIbanNumber            VARCHAR(256) = NULL
	,@senderAddress                 VARCHAR(256) = NULL
	,@receiverAddress               VARCHAR(256) = NULL
	,@senderIdType                  VARCHAR(256) = NULL
	,@senderIdNumber                VARCHAR(256) = NULL
	,@senderIdDateType              VARCHAR(256) = NULL
	,@senderIdDate                  VARCHAR(256) = NULL
	,@districtId                    VARCHAR(256) = NULL
	,@districtName                  VARCHAR(256) = NULL
	,@serviceId                     VARCHAR(256) = NULL
	,@benBankCode                   VARCHAR(256) = NULL
	,@benBankName                	VARCHAR(256) = NULL
	,@benBranchCode              	VARCHAR(256) = NULL
	,@benBranchName              	VARCHAR(256) = NULL
	,@benAccountType             	VARCHAR(256) = NULL
	,@benEftCode                 	VARCHAR(256) = NULL
	,@agentCode                  	VARCHAR(256) = NULL
	,@responseCode               	VARCHAR(256) = NULL
	,@responseDesc               	VARCHAR(256) = NULL
	,@userId                        VARCHAR(256) = NULL
	,@pBranch						INT			 = NULL
	,@pBranchName					VARCHAR(50)	 = NULL
	,@rIdType						VARCHAR(30)	 = NULL
	,@rIdNumber						VARCHAR(30)	 = NULL
	,@rIdPlaceOfIssue				VARCHAR(50)	 = NULL
	,@rIssuedDate					DATETIME	 = NULL
	,@rValidDate					DATETIME	 = NULL
	,@rDob							DATETIME	 = NULL
	,@rAddress						VARCHAR(100) = NULL
	,@rCity							VARCHAR(100) = NULL
	,@rOccupation					VARCHAR(100) = NULL
	,@rContactNo					VARCHAR(50)	 = NULL
	,@rNativeCountry				VARCHAR(100) = NULL
	,@relationType					VARCHAR(50)	 = NULL
	,@relativeName					VARCHAR(100) = NULL
	,@remarks						VARCHAR(500) = NULL
	,@payResponseCode				VARCHAR(20)	 = NULL
	,@payResponseMsg				VARCHAR(100) = NULL
	,@pAgent						INT			 = NULL
	,@pAgentName					VARCHAR(100) = NULL
	,@agentName						VARCHAR(200) = NULL

	,@sortBy						VARCHAR(50)	 = NULL
	,@sortOrder						VARCHAR(5)	 = NULL
	,@pageSize						INT			 = NULL
	,@pageNumber					INT			 = NULL	
	,@provider						VARCHAR(50)	 = NULL
	,@customerId					VARCHAR(50)	 = NULL
	,@membershipId					VARCHAR(50)	 = NULL

	,@rbankName						VARCHAR(50)	 = NULL
	,@rbankBranch					VARCHAR(100) = NULL
	,@rcheque						VARCHAR(50)	 = NULL
	,@rAccountNo					VARCHAR(50)	 = NULL
	,@topupMobileNo					varchar(50)	 = null
	,@relationship					VARCHAR(100) = NULL
	,@purpose						VARCHAR(100) = NULL

AS
SET XACT_ABORT ON

BEGIN TRY
	DECLARE
		 @ceNumberEnc	VARCHAR(50) = dbo.FNAencryptString(@ceNumber)
		 
	IF ISNULL(@purpose,'')=''
		SET @purpose = 'Family support'
			 	
	IF @flag = 's'
	BEGIN	
		DECLARE @table				VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
		SET @table = '
			(
				SELECT
					rowId=rowId
					,''Cash Express'' AS provider
					,am.agentName
					,dbo.FNADecryptString(ceNumber) AS xpin
					,customer				= ISNULL(ce.sendername, '''')
					,beneficiary			= ISNULL(ce.receiverName, '''')
					,customerAddress		= ISNULL(ce.senderAddress, '''')
					,beneficiaryAddress		= ISNULL(ce.receiverAddress, '''')
					,payoutAmount			= ce.finalPayoutAmount
					,payoutDate				=ce.paidDate
				FROM cePayHistory_v2  ce WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = ce.pBranch
				WHERE recordStatus NOT IN(''DRAFT'', ''EXPIRED'')		
			'
			IF @ceNumber IS NOT NULL
			BEGIN
				SET @table = @table + ' AND ceNumber = ''' + @ceNumberEnc + ''''	
				select @pBranch = pBranch,@user = createdBy from cePayHistory_v2 with(nolock)
				where ceNumber = @ceNumberEnc
				if @pBranch is null and @user is not null
				begin
					select @pBranch = agentId  from applicationUsers with(nolock)  
					where userName = @user
					update cePayHistory_v2 set pBranch = @pBranch 
					where ceNumber = @ceNumberEnc 
				end		
			END
			ELSE
			BEGIN
				SET @table = @table + ' AND tranPayProcess IS NULL'
			END
			
			IF @pAgentName IS NOT NULL
				SET @table = @table + ' AND am.agentName LIKE ''' + @pAgentName + '%'''
			SET @table = @table + ' 
			) x '
			
			SET @sql_filter = ''	
		
			IF @provider IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND provider LIKE ''' + @provider + '%'''
			

			SET @select_field_list ='
				 rowId
				,provider		
				,agentName 
				,xpin
				,customer
				,beneficiary
				,customerAddress
				,beneficiaryAddress
				,payoutAmount
				,payoutDate			
				'
			EXEC dbo.proc_paging
				 @table
				,@sql_filter
				,@select_field_list
				,@extra_field_list
				,@sortBy
				,@sortOrder
				,@pageSize
				,@pageNumber

		RETURN
	END		
		 
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 
				'x' 
			FROM cePayHistory_v2 
			WHERE ceNumber = @ceNumberEnc
		)
		
		BEGIN
			UPDATE cePayHistory_v2 SET 
				recordStatus = 'EXPIRED'
			WHERE ceNumber = @ceNumberEnc AND recordStatus <> 'READYTOPAY'
		END
		
		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		IF @pBranch = '1001'
		BEGIN
			EXEC [proc_errorHandler] 1, 'Payout branch is missing.', @rowId
			RETURN;
		END	
		
		INSERT INTO cePayHistory_v2(
			 ceNumber
			,originatingAgentRefNum
			,senderName
			,senderCountry
			,senderAgentCode
			,senderAgentName
			,senderMobileNumber
			,senderMessageToBeneficiary
			,txnCreatedDate
			,receiverName
			,receiverMobile
			,payoutCurrencyCode
			,payoutCurrencyName
			,sentAmount
			,charges
			,finalPayoutAmount
			,receiverAccountNumber
			,receiverIbanNumber
			,senderAddress
			,receiverAddress
			,senderIdType
			,senderIdNumber
			,senderIdDateType
			,senderIdDate
			,districtId
			,districtName
			,serviceId
			,benBankCode
			,benBankName
			,benBranchCode
			,benBranchName
			,benAccountType
			,benEftCode
			,agentCode
			,responseCode
			,responseDesc
			,userId
			,recordStatus
			,createdDate
			,createdBy
			,pBranch
		)
		SELECT
		 @ceNumberEnc
		,@originatingAgentRefNum
		,@senderName
		,@senderCountry
		,@senderAgentCode
		,@senderAgentName
		,@senderMobileNumber
		,@senderMessageToBeneficiary
		,@txnCreatedDate
		,@receiverName
		,@receiverMobile
		,@payoutCurrencyCode
		,@payoutCurrencyName
		,@sentAmount
		,@charges
		,@finalPayoutAmount
		,@receiverAccountNumber
		,@receiverIbanNumber
		,@senderAddress
		,@receiverAddress
		,@senderIdType
		,@senderIdNumber
		,@senderIdDateType
		,@senderIdDate
		,@districtId
		,@districtName
		,@serviceId
		,@benBankCode
		,@benBankName
		,@benBranchCode
		,@benBranchName
		,@benAccountType
		,@benEftCode
		,@agentCode
		,@responseCode
		,@responseDesc
		,@userId
		,'DRAFT'
		,GETDATE()		
		,@user				
		,@pBranch	
						
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END
	
	IF @flag = 'readyToPay'
	BEGIN
		--alter table cePayHistory_v2 ADD topupMobileNo VARCHAR(20),
		--alter table cePayHistory_v2 ADD customerId bigint,membershipId varchar(50)
		UPDATE cePayHistory_v2 SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = isnull(@pBranch ,pBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks	 	 = @remarks 
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,topupMobileNo	 = @topupMobileNo
			,customerId		 = @customerId
			,membershipId	 = @membershipId
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose	
			,rIssueDate		 = @rIssuedDate
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.','Nepal'
		RETURN
	END	
	
	IF @flag = 'payError'
	BEGIN
		UPDATE cePayHistory_v2 SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	
	
	IF @flag IN ('pay', 'restore')
	BEGIN
		IF NOT EXISTS(
			SELECT 'x' FROM cePayHistory_v2 WITH(NOLOCK) 
			WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
				AND rowid = @rowid
		)
		
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END
		
		DECLARE
			 @tranId					BIGINT
			,@tranIdTemp				BIGINT  
			,@pSuperAgent				INT 
			,@pSuperAgentName			VARCHAR(100)
			,@pCountry					VARCHAR(100)
			,@pState					VARCHAR(100)
			,@pDistrict					VARCHAR(100)
			,@pLocation					INT
			,@pAgentComm				MONEY
			,@pAgentCommCurrency		VARCHAR(3)
			,@pSuperAgentComm			MONEY
			,@pSuperAgentCommCurrency	VARCHAR(3)
						
			,@sAgent					INT	 
			,@sAgentName				VARCHAR(100)
			,@sBranch					INT 
			,@sBranchName				VARCHAR(100)
			,@sSuperAgent				INT
			,@sSuperAgentName			VARCHAR(100) 
			,@sAgentMapCode				INT = 33300350
	 		,@sBranchMapCode			INT = 33422529
	 		,@sCountry					VARCHAR(100)


			,@bankName					VARCHAR(100) = NULL
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL

			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
			,@customerRate				MONEY
			,@payoutCurr				VARCHAR(50)
			,@collCurr					VARCHAR(50)		
	 		
			,@MapCodeIntBranch			VARCHAR(50) 
			,@MapCodeIntAgent			VARCHAR(50) 
			,@MapAgentName				VARCHAR(50) 
			,@companyId					INT = 16
			,@ControlNoModified			VARCHAR(50)	
			,@controlNo					VARCHAR(50)
			
		SELECT 
			@ceNumber						= ce.ceNumber
			,@originatingAgentRefNum		= ce.originatingAgentRefNum
			,@senderName					= ce.senderName
			,@senderCountry					= ce.senderCountry
			,@senderAgentCode				= ce.senderAgentCode
			,@senderAgentName				= ce.senderAgentName
			,@senderMobileNumber			= ce.senderMobileNumber
			,@senderMessageToBeneficiary	= ce.senderMessageToBeneficiary
			,@txnCreatedDate				= ce.txnCreatedDate
			,@receiverName					= ce.receiverName
			,@receiverMobile				= ce.receiverMobile
			,@payoutCurrencyCode			= ce.payoutCurrencyCode
			,@payoutCurrencyName			= ce.payoutCurrencyName
			,@sentAmount					= ce.sentAmount
			,@charges						= ce.charges
			,@finalPayoutAmount				= ce.finalPayoutAmount
			,@receiverAccountNumber			= ce.receiverAccountNumber
			,@receiverIbanNumber			= ce.receiverIbanNumber
			,@senderAddress					= ce.senderAddress
			,@receiverAddress				= ce.receiverAddress
			,@senderIdType					= ce.senderIdType
			,@senderIdNumber				= ce.senderIdNumber
			,@senderIdDateType				= ce.senderIdDateType
			,@senderIdDate					= ce.senderIdDate
			,@districtId					= ce.districtId
			,@districtName					= ce.districtName
			,@serviceId						= ce.serviceId
			,@benBankCode					= ce.benBankCode
			,@benBankName					= ce.benBankName
			,@benBranchCode					= ce.benBranchCode
			,@benBranchName					= ce.benBranchName
			,@benAccountType				= ce.benAccountType
			,@benEftCode					= ce.benEftCode
			,@agentCode						= ce.agentCode
			,@responseCode					= ce.responseCode
			,@responseDesc					= ce.responseDesc
			,@userId						= ce.userId
			
			,@pBranch						= ce.pBranch
			,@rIdType						= ce.rIdType
			,@rIdNumber						= ce.rIdNumber
			,@rIdPlaceOfIssue				= ce.rIdPlaceOfIssue
			,@rValidDate					= ce.rValidDate
			,@rDob							= ce.rDob
			,@rAddress						= ce.rAddress
			,@rCity							= ce.rCity
			,@rOccupation					= ce.rOccupation
			,@rContactNo					= ce.rContactNo
			--,@nativeCountry = ce.nativeCountry
			,@relationType					= ce.relationType
			,@relativeName					= ce.relativeName
			,@remarks						= ce.remarks
			,@payResponseCode				= ce.payResponseCode
			,@payResponseMsg				= ce.payResponseMsg
			,@rbankName						= rBank
			,@rbankBranch					= rBankBranch
			,@rcheque						= rAccountNo
			,@rAccountNo					= rChequeNo
			,@topupMobileNo					= topupMobileNo
			,@customerId					= customerId
			,@membershipId					= membershipId
			,@purpose						= purposeOfRemit
			,@relationship					= relWithSender
			,@rIssuedDate					= rIssueDate
		FROM cePayHistory_v2 ce WITH(NOLOCK)
		WHERE rowId = @rowId		
		
		SET @ControlNoModified = dbo.FNAEncryptstring(dbo.FNADecryptstring(@ceNumber)+'A')
		SELECT 
			 @pAgent = parentId, 
			 @pBranchName = agentName, 
			 @agentType = agentType,
			 @pCountry = agentCountry,
			 @pState = agentState,
			 @pDistrict = agentDistrict,
			 @pLocation = agentLocation,
			 @MapCodeIntBranch=mapCodeInt  
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch	

--## Check if controlno exist in remittran. 		
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified)
		BEGIN
			DECLARE @status VARCHAR(100),@msg VARCHAR(100)
			SELECT  
				 @agentName = sAgentName
				,@status = payStatus	
			FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified
			SET @msg = 'This transaction belongs to ' + @agentName + ' and is in status: ' + @status
			EXEC proc_errorHandler 1,@msg,NULL
			RETURN
		END
--## Set paying agent details.
		SELECT 
			@pAgent = parentId, 
			@pBranchName = agentName, 
			@agentType = agentType,
			@pCountry = agentCountry,
			@pState = agentState,
			@pDistrict = agentDistrict,
			@pLocation = agentLocation,
			@MapCodeIntBranch=mapCodeInt  
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
		
		IF @agentType = 2903
			SET @pAgent = @pBranch
		
		--## Check if txn exist in remitTran but not in Inficare system.
		DECLARE	
			 @remitTrandate DATETIME
			,@remitTrandateNepal DATETIME
		
		SELECT 
			 @tranId = id
			,@remitTrandate = paidDate
			,@remitTrandateNepal = paidDateLocal
			,@pAgentComm = pAgentComm 
			,@remitTrandate = GETDATE()
			,@remitTrandateNepal = dbo.FNAGetDateInNepalTZ()
		FROM remitTran  WITH(NOLOCK) WHERE controlNo = @ControlNoModified

		
		--##1. Find Sending Agent Details
		SELECT  @sBranch = agentId, 
				@sAgent = parentId, 
				@sBranchName = agentName, 
				@agentType = agentType 
		FROM agentMaster WITH(NOLOCK) 
		WHERE mapCodeInt = @sBranchMapCode AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @agentType = 2903
		BEGIN
			SET @sAgent = @sBranch
		END
		
		SELECT  @sSuperAgent = parentId, 
				@sAgentName = agentName,
				@sCountry = agentCountry
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent

		SELECT @sSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent

--##2. Find Payout Agent Details
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent

--##3. Find Commission 
		DECLARE @sCountryId INT, @deliveryMethodId INT, @pCommCheck MONEY
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
		
		SET @payoutMethod = 'Cash Payment'
		DECLARE @pCountryId INT = NULL
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'
				
		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'
		SELECT  @pAgentComm = ISNULL(amount, 0), 
				@pCommCheck = amount, 
				@pAgentCommCurrency = commissionCurrency, 
				@pCommCheck = amount 
		FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, NULL, @pSuperAgent, 151, 
		@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @finalPayoutAmount, NULL, NULL, NULL)

		IF @pCommCheck IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Payout Commission not defined', NULL
				RETURN
			END		
		
		
		-------Compliance Check Begin----------

		-- Thirdparty txn doesn't have tranid. Hence, temp tranid is created for compliance checking process. Later on this will replace by actual tranId.
		SELECT @tranIdTemp = ABS(CAST(CRYPT_GEN_RANDOM(8) AS BIGINT)) 

		IF NOT EXISTS(SELECT 'X' FROM remitTranCompliancePay WITH(NOLOCK) WHERE tranId = @tranIdTemp AND approvedDate IS NOT NULL)
		BEGIN

		DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20), @result VARCHAR(MAX),@complianceAction CHAR(1),
		@compApproveRemark	VARCHAR(200)

		DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
		
		INSERT @csMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetComplianceRuleMaster_Pay(@pBranch, @pCountryId, NULL, @pBranch, NULL, NULL, @customerId)
		SELECT @totalRows = COUNT(*) FROM @csMasterRec
		
		DECLARE @denyTxn CHAR(1) = 'N'
		IF EXISTS(SELECT 'X' FROM @csMasterRec)
		BEGIN
			DELETE FROM remitTranCompliancePayTemp WHERE tranId = @tranIdTemp
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
				
				EXEC proc_complianceRuleDetail_Pay 
				 @user				= @user
				,@tranId			= @tranIdTemp
				,@tAmt				= @finalPayoutAmount
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @receiverName 
				,@receiverMobile	= @rContactNo
				,@receiverAcNo		= @rAccountNo
				,@masterId			= @csMasterId
				,@paymentMethod		= @deliveryMethodId
				,@checkingFor		= 'v'				
				,@result			= @complianceRes OUTPUT
								
				
				SET @compFinalRes = ISNULL(@compFinalRes, '') + ISNULL(@complianceRes, '')
				
				IF @complianceRes = 'M' AND ISNULL(@complianceAction, '') <> 'C'
					SET @complianceAction = 'M'
				IF @complianceRes = 'C' 
					SET @complianceAction = 'C'
				
				SET @count = @count + 1
			END
		END
		
		IF(ISNULL(@compFinalRes, '') <> '')
		BEGIN			
			IF(@compFinalRes <> '')
			BEGIN				
				IF EXISTS(SELECT 'X' FROM remitTranCompliancePayTemp WITH(NOLOCK) WHERE tranId = @tranIdTemp)
				BEGIN
					INSERT INTO remitTranCompliancePay(tranId, csDetailTranId, matchTranId)
					SELECT @tranIdTemp, csDetailTranId, matchTranId FROM remitTranCompliancePayTemp WITH(NOLOCK) WHERE tranId = @tranIdTemp
					
					
					--INSERT tranPayCompliance(tranId,provider,controlNo,pBranch,receiverName,rMemId,dob,
					--rIdType,rIdNumber,rPlaceOfIssue,rContactNo,rRelationType,rRelativeName,relWithSender,purposeOfRemit,createdBy,createdDate)					
					--SELECT @tranIdTemp, '4670' , @ControlNoModified,@pBranch,@receiverName,@membershipId,@rDob,
					--@rIdType,@rIdNumber,@rIdPlaceOfIssue,@rContactNo,@relationType,@relativeName,@relationship,@purpose,@user,GETDATE()
					
					DELETE FROM dbo.remitTranCompliancePayTemp WHERE tranId = @tranIdTemp			
				END

				IF ISNULL(@complianceAction, '') <> ''
					BEGIN
												
						--UPDATE remitTran SET
						--	 tranStatus	= 'Hold'
						--WHERE id = @tranId
					
						UPDATE remitTranCompliancePay SET
							 approvedRemarks	= 'Marked for Compliance'
							,approvedBy			= 'system'
							,approvedDate		= GETDATE()
						WHERE tranId = @tranIdTemp

						--UPDATE tranPayCompliance SET
						--	 approvedRemarks	= 'Marked for Compliance'
						--	,approvedBy			= 'system'
						--	,approvedDate		= GETDATE()
						--WHERE tranId = @tranIdTemp
					END				

			END

		END 

		END		
		
		-------Compliance Check End----------
			
		BEGIN TRANSACTION
		BEGIN
		
		--## Inserting Data in remittran table 				
		INSERT INTO remitTran (	 
					  [controlNo]						
					 ,[senderName]					
					 ,[sCountry]					
					 ,[sSuperAgent]					
					 ,[sSuperAgentName]				
					 ,[paymentMethod]				
					 ,[cAmt]						
					 ,[pAmt]						
					 ,[tAmt]						
					 ,[pAgentComm]					
					 ,[payoutCurr]					
					 ,[pAgent]						
					 ,[pAgentName]					
					 ,[pSuperAgent]					
					 ,[pSuperAgentName]				
					 ,[receiverName]				
					 ,[pCountry]					
					 ,[pBranch]						
					 ,[pBranchName]					
					 ,[pState]						
					 ,[pDistrict]					
					 ,[pLocation]					
					 ,[purposeofRemit]				
					 ,[pMessage]					
					 ,[pBankBranch]					
					 ,[sAgentSettRate]				
					 ,[createdDate]					
					 ,[createdDateLocal]			
					 ,[createdBy]					
					 ,[approvedDate]				
					 ,[approvedDateLocal]			
					 ,[approvedBy]					
					 ,[paidBy]						
					 ,[paidDate]					
					 ,[paidDateLocal]
													
					 --## hardcoded parameters			
					 ,[tranStatus]					
					 ,[payStatus]					
					 ,[collCurr]					
					 ,[controlNo2]					
					 ,[tranType]					
					 ,[sAgent]						
					 ,[sAgentName]					
					 ,[sBranch]						
					 ,[sBranchName]	
				 )
		SELECT 
					 @ControlNoModified
					,@senderName
					,@sCountry
					,@sSuperAgent
					,@sSuperAgentName
					,'Cash Payment'
					,@finalPayoutAmount
					,@finalPayoutAmount
					,@finalPayoutAmount
					,@pAgentComm
					,@payoutCurrencyCode
					,@pAgent
					,@pAgentName
					,@pSuperAgent
					,@pSuperAgentName 
					,@receiverName	 
					,@pCountry
					,@pBranch
					,@pBranchName
					,@pState
					,@pDistrict
					,@pLocation
					,@purpose
					,@remarks	
					,@pBankBranch
					,@SagentsettRate
					,GETDATE() 
					,GETDATE()
					,'SWIFT:API'
					,GETDATE()	 
					,GETDATE()
					,'SWIFT:API'
					,@user
					,dbo.FNAGetDateInNepalTZ()
					,dbo.FNAGetDateInNepalTZ()

					--## hardCoded Parameters
					,'Paid'
					,'Paid'
					,@payoutCurrencyCode
					,@ceNumber
					,'I'
					,@sAgent
					,@sAgentName
					,@sBranch
					,@sBranchName
										
			SET @tranId = SCOPE_IDENTITY()

			--## Inserting Data in tranSenders table
			INSERT INTO tranSenders	(
					 tranId
					,firstName
					,country
					,[address]
					,idType
					,idNumber
					,validDate
					,mobile				
				)
				SELECT
					 @tranId			
					,@senderName
					,@sCountry	
					,@senderAddress
					,@senderIdType	
					,@senderIdNumber
					,@senderIdDate
					,@senderMobileNumber					
					
			--## Inserting Data in tranReceivers table
			INSERT INTO tranReceivers (
					 tranId
					,firstName
					,country
					,city
					,[address]
					,homePhone
					,idType
					,idNumber
					,idType2
					,idNumber2
					,dob
					,occupation
					,validDate
					,idPlaceOfIssue
					,relationType
					,relativeName
					,bankName
					,branchName
					,chequeNo
					,accountNo
					,workPhone
					,customerId
					,membershipId
					,mobile
					,relWithSender
					,purposeOfRemit
					,issuedDate2
					,validDate2
					)		
				SELECT 
					 @tranId			
					,@receiverName
					,@pCountry
					,@receiverAddress
					,@receiverAddress	
					,@rContactNo--@receiverMobile
					,@rIdType	
					,@rIdNumber
					,@rIdType	
					,@rIdNumber
					,@rDob
					,@rOccupation
					,@rValidDate
					,@rIdPlaceOfIssue
					,@relationType
					,@relativeName
					,@rbankName
					,@rbankBranch
					,@rcheque
					,@raccountNo
					,@topupMobileNo 
					,@customerId
					,@membershipId
					,@rContactNo
					,@relationship
					,@purpose
					,@rIssuedDate
					,@rValidDate

			UPDATE remitTranCompliancePay SET
					tranId	= @tranId							
			WHERE tranId = @tranIdTemp

			--UPDATE tranPayCompliance SET
			--tranId	= @tranId
			--WHERE tranId = @tranIdTemp

			IF @membershipId IS NOT NULL
			BEGIN
				UPDATE dbo.customerMaster SET 
					paidTxn = ISNULL(paidTxn,0)+1,
					firstTxnDate = ISNULL(firstTxnDate,GETDATE()) 
				WHERE membershipId = @membershipId 
			END
			--## Updating Data in cePayHistory_v2 table by paid status
			UPDATE cePayHistory_v2 SET 
				 recordStatus = 'PAID'
				,tranPayProcess = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg = @payResponseMsg
				,paidDate    = GETDATE()
				,paidBy		 = @user				
			WHERE rowId = @rowId
			/*Topup Information Send SMS*/
			IF @membershipId IS NOT NULL
			BEGIN
				EXEC proc_topupQueue 
					 @flag			= 'a'
					,@user			= @user
					,@tranId		= @tranId
					,@tranType		= 'I'
			END
		END
		EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @finalPayoutAmount ,@settlingAgent = @pBranch
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = 
			CASE 
				WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
				ELSE 'Transaction paid successfully'
			END
		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ControlNoModified
		SET @controlNo = dbo.fnadecryptstring(@ControlNoModified)
		EXEC [proc_errorHandler] 0, @msg, @controlNo	
		RETURN	
	END
	
	
	IF @flag = 'a'
	BEGIN
		SELECT TOP 1
			 rowId
			,[controlNo]		= dbo.FNADecryptString(ce.ceNumber)
			,[sCountry]			= ce.senderCountry
			,[sName]			= ce.senderName
			,[sAddress]			= ISNULL(ce.senderAddress,'')
			,sCity				=null
			,sMobile			=isnull(ce.senderMobileNumber,'')
			,sAgentName			='Cash Express'
			,sAgent				= 4670
			,[sIdType]			= ce.senderIdType
			,[sIdNumber]		= ce.senderIdNumber
			,[rCountry]			= 'Nepal'--ce.Destination_Country
			,[rName]			= ce.receiverName
			,[rAddress]			= ce.receiverAddress
			,[rCity]			= ''--ce.rCity
			,[rPhone]			= ISNULL(ce.receiverMobile,'')
			,[rIdType]			= ce.rIdType
			,[rIdNumber]		= ce.rIdNumber
			,[pAmt]				= ce.finalPayoutAmount
			,[pCurr]			= ce.payoutCurrencyCode
			,[pBranch]			= am.agentName
			,branchId			= ce.pBranch 
			,[pUser]			= ce.createdBy
			,transactionMode	= 'Cash Payment' --case paymentMode when 1 then 'Cash Payment' ELSE 'Bank Deposit' END
			,PlaceOfIssue		= rIdPlaceOfIssue
		    ,rRelativeName		= relativeName
		    ,RelationType		= relationType
		    ,rContactNo			= rContactNo
		FROM cePayHistory_v2 ce WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON ce.pBranch = am.agentId
		WHERE recordStatus <> ('DRAFT') AND rowId = @rowId
		ORDER BY rowId DESC
		RETURN
	END
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
	--SELECT ERROR_LINE()
	--select @senderIdDate
END CATCH



GO
