USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ceAcDepositHistory_V2]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_ceAcDepositHistory_V2](
	 @flag							VARCHAR(20) = NULL
	,@rowid							BIGINT		= NULL
	,@ceNumber						VARCHAR(20) = NULL
	,@originatingAgentRefNum		VARCHAR(20) = NULL
	,@senderName					VARCHAR(50) = NULL
	,@senderCountry					VARCHAR(50) = NULL
	,@senderAgentCode				VARCHAR(50) = NULL
	,@senderAgentName				VARCHAR(50) = NULL
	,@senderMobileNumber			VARCHAR(50) = NULL
	,@senderMessageToBeneficiary	VARCHAR(50) = NULL
	,@txnCreatedDate				VARCHAR(50) = NULL
	,@receiverName					VARCHAR(50) = NULL
	,@receiverMobile				VARCHAR(50) = NULL
	,@payoutCurrencyCode			VARCHAR(50) = NULL
	,@payoutCurrencyName			VARCHAR(50) = NULL
	,@sentAmount					VARCHAR(50) = NULL
	,@charges						VARCHAR(50) = NULL
	,@finalPayoutAmount				VARCHAR(50) = NULL
	,@receiverAccountNumber			VARCHAR(50) = NULL
	,@receiverIbanNumber			VARCHAR(50) = NULL
	,@senderAddress					VARCHAR(50) = NULL
	,@receiverAddress				VARCHAR(50) = NULL
	,@senderIdType					VARCHAR(50) = NULL
	,@senderIdNumber				VARCHAR(50) = NULL
	,@senderIdDateType				VARCHAR(50) = NULL
	,@senderIdDate					VARCHAR(50) = NULL
	,@districtId					VARCHAR(50) = NULL
	,@districtName					VARCHAR(50) = NULL
	,@serviceId						VARCHAR(50) = NULL
	,@benBankCode					VARCHAR(50) = NULL
	,@benBankName					VARCHAR(50) = NULL
	,@benBranchCode					VARCHAR(50) = NULL
	,@benBranchName					VARCHAR(50) = NULL
	,@benAccountType				VARCHAR(50) = NULL
	,@benEftCode					VARCHAR(50) = NULL
	,@xml							VARCHAR(MAX)= NULL
	
	,@mapCodeInt					INT			= NULL
	,@bankId						INT			= NULL
	,@bankName						VARCHAR(200)= NULL
	,@pBranch						VARCHAR(100)= NULL
	,@rBankCode						VARCHAR(50)	= NULL
	,@rBankName						VARCHAR(200)= NULL
	,@thirdPartyAgentId				INT			= NULL
	,@payResponseCode				VARCHAR(20)	= NULL
	,@payResponseMsg				VARCHAR(100)= NULL
	,@filterType					VARCHAR(20)	= NULL	
	,@extBankId						INT			= NULL
	,@extBankBranchId				INT			= NULL
	,@extBankBranchName				VARCHAR(100)= NULL
	,@pBankType						CHAR(1)		= NULL
	,@redownload					CHAR(1)		= NULL
	,@user							VARCHAR(30)	= NULL

)
AS 
BEGIN
	IF @flag = 'd'
	BEGIN
		DELETE FROM ceAcDepositHistory_V2 WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0,'Transaction has been deleted successfully.', @rowId
		RETURN
	END
	IF @flag = 'i'
	BEGIN
		
		DECLARE @rowInserted VARCHAR(50)
		DECLARE @xml1 XML =  REPLACE(REPLACE(@xml, '&quot;', '"'), '&quot', '"')
		SELECT t.* INTO #tempCE
			FROM (	
				SELECT 
				 ceNumber = NULLIF(p.value('@ceNumber','VARCHAR(200)'),'')
				,originatingAgentRefNum = NULLIF(p.value('@originatingAgentRefNum','VARCHAR(200)'),'')
				,senderName = NULLIF(p.value('@senderName','VARCHAR(200)'),'')
				,senderCountry = NULLIF(p.value('@senderCountry','VARCHAR(200)'),'')
				,senderAgentCode = NULLIF(p.value('@senderAgentCode','VARCHAR(200)'),'')
				,senderAgentName = NULLIF(p.value('@senderAgentName','VARCHAR(200)'),'')
				,senderMobileNumber = NULLIF(p.value('@senderMobileNumber','VARCHAR(200)'),'')
				,senderMessageToBeneficiary = NULLIF(p.value('@senderMessageToBeneficiary','VARCHAR(200)'),'')
				,txnCreatedDate = NULLIF(p.value('@txnCreatedDate','VARCHAR(200)'),'')
				,receiverName = NULLIF(p.value('@receiverName','VARCHAR(200)'),'')
				,receiverMobile = NULLIF(p.value('@receiverMobile','VARCHAR(200)'),'')
				,payoutCurrencyCode = NULLIF(p.value('@payoutCurrencyCode','VARCHAR(200)'),'')
				,payoutCurrencyName = NULLIF(p.value('@payoutCurrencyName','VARCHAR(200)'),'')
				,sentAmount = NULLIF(p.value('@sentAmount','VARCHAR(200)'),'')
				,charges = NULLIF(p.value('@charges','VARCHAR(200)'),'')
				,finalPayoutAmount = NULLIF(p.value('@finalPayoutAmount','VARCHAR(200)'),'')
				,receiverAccountNumber = NULLIF(p.value('@receiverAccountNumber','VARCHAR(200)'),'')
				,receiverIbanNumber = NULLIF(p.value('@receiverIbanNumber','VARCHAR(200)'),'')
				,senderAddress = NULLIF(p.value('@senderAddress','VARCHAR(200)'),'')
				,receiverAddress = NULLIF(p.value('@receiverAddress','VARCHAR(200)'),'')
				,senderIdType = NULLIF(p.value('@senderIdType','VARCHAR(200)'),'')
				,senderIdNumber = NULLIF(p.value('@senderIdNumber','VARCHAR(200)'),'')
				,senderIdDateType = NULLIF(p.value('@senderIdDateType','VARCHAR(200)'),'')
				,senderIdDate = NULLIF(p.value('@senderIdDate','VARCHAR(200)'),'')
				,districtId = NULLIF(p.value('@districtId','VARCHAR(200)'),'')
				,districtName = NULLIF(p.value('@districtName','VARCHAR(200)'),'')
				,serviceId = NULLIF(p.value('@serviceId','VARCHAR(200)'),'')
				,benBankCode = NULLIF(p.value('@benBankCode','VARCHAR(200)'),'')
				,benBankName = NULLIF(p.value('@benBankName','VARCHAR(200)'),'')
				,benBranchCode = NULLIF(p.value('@benBranchCode','VARCHAR(200)'),'')
				,benBranchName = NULLIF(p.value('@benBranchName','VARCHAR(200)'),'')
				,benAccountType = NULLIF(p.value('@benAccountType','VARCHAR(200)'),'')
				,benEftCode = NULLIF(p.value('@benEftCode','VARCHAR(200)'),'')
				FROM @xml1.nodes('/root/row') AS tmp(p)
			)t
			LEFT JOIN ceAcDepositHistory_V2 h WITH(NOLOCK) ON t.ceNumber = h.ceNumber
			WHERE h.ceNumber IS NULL
			
		BEGIN TRANSACTION	
		
		INSERT ceAcDepositDownloadLogs(createdBy, createdDate) SELECT @user,  GETDATE()
		
		INSERT INTO ceAcDepositHistory_V2 (
						 ceNumber,originatingAgentRefNum,senderName,senderCountry,senderAgentCode,senderAgentName,senderMobileNumber
						,senderMessageToBeneficiary,txnCreatedDate,receiverName,receiverMobile,payoutCurrencyCode,payoutCurrencyName
						,sentAmount,charges,finalPayoutAmount,receiverAccountNumber,receiverIbanNumber,senderAddress,receiverAddress
						,senderIdType,senderIdNumber,senderIdDateType,senderIdDate,districtId,districtName,serviceId,benBankCode,benBankName
						,benBranchCode,benBranchName,benAccountType,benEftCode,recordStatus,createdDate,createdBy
					)
				SELECT						
						ceNumber,originatingAgentRefNum,senderName,senderCountry,senderAgentCode,senderAgentName,senderMobileNumber
						,senderMessageToBeneficiary,txnCreatedDate,receiverName,receiverMobile,payoutCurrencyCode,payoutCurrencyName
						,sentAmount,charges,finalPayoutAmount,receiverAccountNumber,receiverIbanNumber,senderAddress,receiverAddress
						,senderIdType,senderIdNumber,senderIdDateType,senderIdDate,districtId,districtName,serviceId,benBankCode,benBankName
						,benBranchCode,benBranchName,benAccountType,benEftCode,'DRAFT',GETDATE(),@user								
				FROM #tempCE
				
				SET @rowInserted = @@ROWCOUNT

				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
				DECLARE @msg VARCHAR(MAX)
				SET @msg=@rowInserted+' Transactions Downloaded Successfully.'
				EXEC proc_errorHandler 0,@msg,NULL
			RETURN		
	END
	
	IF @flag='up-list'--unpaid list 
		BEGIN
		SELECT 
			 [Control NO] = ceNumber
			,[TRAN NO] =''
			,[Sending Country]=''
			,[Sending Agent]=''
			,[Bank Name] = benBankName
			,[Branch Name]	= benBranchName
			,[Receiver Name] = receiverName
			,[Bank A/C NO]	= receiverAccountNumber
			,[DOT]	= createdDate
			,[Total Amount] = finalPayoutAmount
			,[Unpaid Days] = DATEDIFF(DAY,createdDate,GETDATE())			
			,rowId
		FROM ceAcDepositHistory_V2 WITH(NOLOCK)
		WHERE recordStatus <> 'CANCEL' AND pAgent = @rbankCode
	RETURN
	END	
	
	IF @flag='all-list' -- show all downloaded txn list
		BEGIN	
		DECLARE @sql VARCHAR(MAX)
	SET @sql='
		SELECT 
			 [Control NO] = ceNumber			
			,[Sending Country]=''CASH EXPRESS API''
			,[Sending Agent]=''CASH EXPRESS''
			,[Bank Name] = benBankName
			,[Branch Name]	= benBranchName
			,[Receiver Name] = receiverName
			,[Bank A/C NO]	= receiverAccountNumber
			,[DOT]	= createdDate
			,[Total Amount] = finalPayoutAmount
			,[Unpaid Days] = DATEDIFF(DAY,createdDate,GETDATE())
			,[Record Status] = CASE WHEN pAgent IS NULL THEN ''UNASSIGNED'' ELSE ''ASSIGNED'' END
			,rowId			
		FROM ceAcDepositHistory_V2 WITH(NOLOCK)
		WHERE recordStatus NOT IN(''CANCEL'',''PAID'')'
		
		IF @filterType = 'UA' -- Unassigned 
		SET @sql = @sql + 'AND pAgent IS NULL'
		
		ELSE IF @filterType = 'A' -- Assigned
		SET @sql = @sql + 'AND pAgent IS NOT NULL'
		SET @sql = @sql + ' ORDER BY createdDate DESC'
		PRINT @sql				
		EXEC (@sql)
		
		SELECT TOP 1 createdBy, createdDate FROM ceAcDepositDownloadLogs WITH(NOLOCK) ORDER BY rowId DESC
		
	RETURN
	END	
	
	IF @flag = 'ul' -- show unpaid list
		BEGIN
		 SELECT DISTINCT
			 receiveAgentId	= am.agentId
			,[bankName] = am.agentName
		    ,[Txn] = COUNT(*)
		    ,amt = SUM(CAST(finalPayoutAmount AS MONEY))
		    FROM ceAcDepositHistory_V2 ce WITH(NOLOCK)
		    INNER JOIN agentMaster am WITH(NOLOCK) ON ce.pAgent = am.agentId
		    WHERE recordStatus <> 'CANCEL' AND pAgent IS NOT NULL
		    GROUP BY am.agentName, am.agentId
		    		    
		SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @thirdPartyAgentId
	END	
	
	IF @flag = 'a' -- select by rowid 
		BEGIN
		SELECT 
			 rowId
			,[rCountry] = 'Nepal'
			,[rAddress] = receiverAddress
			,[rBankAcNo] = receiverAccountNumber
			,[rBankBranchCode] = benBranchCode
			,[rBankBranchName] = benBranchName
			,[rBankCode] = benBankCode
			,[rBankName] = benBankName
			,[rIdType] = 'ID'
			,[rIdNo] = ISNULL(NULL, ABS(CHECKSUM(NEWID())))
			,[rName] = receiverName
			,[rContactNo] = receiverMobile
			,[sCountry] = 'United Arab Emirates'
			,[sAddress] = senderAddress
			,[sIdValidDate] = senderIdDate
			,[sIdNo] = senderIdNumber
			,[sIdType] = senderIdType
			,[sName] = senderName
			,[sNationality] = senderCountry
			,[sContactNo] = senderMobileNumber
			,[rAmount] = finalPayoutAmount
			,[rCurrency] = payoutCurrencyName
			,[controlNo] = ceNumber
			,paymentMode = 'A'
			,purpose = 'Family Support'
			,settlementCurrency = payoutCurrencyName
			,transactionStatus = recordStatus
			,[pBankId] = CAST(pBank AS VARCHAR) + '|' + pBankType
			,[pBranchId] = pBankBranch			
		FROM ceAcDepositHistory_V2 ce WITH(NOLOCK)
		WHERE rowId = @rowId
		RETURN
	END	
	
	IF @flag = 'select' -- select by control no 
		BEGIN
		SELECT 
			 rowId
			,[rCountry] = 'Nepal'
			,[rAddress] = receiverAddress
			,[rBankAcNo] = receiverAccountNumber
			,[rBankBranchCode] = benBranchCode
			,[rBankBranchName] = benBranchName
			,[rBankCode] = benBankCode
			,[rBankName] = benBankName
			,[rIdType] = 'ID'
			,[rIdNo] = ISNULL(NULL, ABS(CHECKSUM(NEWID())))
			,[rName] = receiverName
			,[rContactNo] = receiverMobile
			,[sCountry] = 'United Arab Emirates'
			,[sAddress] = senderAddress
			,[sIdValidDate] = senderIdDate
			,[sIdNo] = senderIdNumber
			,[sIdType] = senderIdType
			,[sName] = senderName
			,[sNationality] = senderCountry
			,[sContactNo] = senderMobileNumber
			,[rAmount] = finalPayoutAmount
			,[rCurrency] = payoutCurrencyName
			,[controlNo] = ceNumber
			,paymentMode = 'A'
			,purpose = 'Family Support'
			,settlementCurrency = payoutCurrencyName
			,transactionStatus = recordStatus
			,[pBankId] = CAST(pBank AS VARCHAR) + '|' + pBankType
			,[pBranchId] = pBankBranch			
		FROM ceAcDepositHistory_V2 ce WITH(NOLOCK)
		WHERE ceNumber = @ceNumber
		RETURN
	END
	
	IF @flag = 'payError'
		BEGIN
		UPDATE ceAcDepositHistory_V2 SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	
	IF	@flag='updateBank' --Assign Bank
		BEGIN
		DECLARE @pAgent INT
		IF @pBankType = 'I'
		BEGIN
			SET @pAgent = @extBankId
		END
		ELSE
		BEGIN
			SELECT @pAgent = internalCode FROM externalBank WITH(NOLOCK) WHERE extBankId = @extBankId
		END
		
		IF @pBranch IS NULL
			SELECT TOP 1 @pBranch = agentId FROM agentMaster WITH(NOLOCK) WHERE parentId = @pAgent AND isHeadOffice = 'Y'	
		UPDATE ceAcDepositHistory_V2 SET
			  pAgent			= @pAgent
			 ,pBranch			= @pBranch
			 ,pBank				= @extBankId
			 ,pBankBranch		= @extBankBranchId
			 ,pBankBranchName	= @extBankBranchName
			 ,pBankType			= @pBankType			
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Bank Updated Successfully.', @rowId
	END	

	IF @flag = 'bl'		--Bank List
	BEGIN
		SELECT extBankId,bankName FROM
		(
			SELECT extBankId = CAST(agentId AS VARCHAR) + '|I', bankName = agentName 
				FROM agentMaster WITH(NOLOCK) WHERE agentId = 2054 UNION ALL			
			SELECT extBankId = CAST(extBankId AS VARCHAR) + '|E', bankName 
				FROM externalBank WITH(NOLOCK)
		)X 
		ORDER BY bankName
	END

	IF @flag = 'bb'  --Bank Branch List
	BEGIN			
		SET @sql = CASE 
			WHEN @extBankId='2054' THEN 'SELECT  branchId = agentId,branchName = agentName FROM agentMaster WITH(NOLOCK) WHERE parentId = ' + CAST(@extBankId AS VARCHAR)+' ORDER BY agentName'
			ELSE 'SELECT branchId = extBranchId,branchName = BranchName FROM externalBankBranch WITH(NOLOCK) WHERE extBankId = ' + CAST(@extBankId AS VARCHAR)+' ORDER BY BranchName' END
		--PRINT(@sql)
		EXEC(@sql)
		RETURN
	END		
	
	IF @flag IN ('pay', 'restore')
	BEGIN	
		DECLARE
			 @tranId								BIGINT 
			,@beneficiaryAddress				VARCHAR(300)
			,@beneficiaryBankAccountNumber		VARCHAR(300)
			,@beneficiaryBankBranchCode			VARCHAR(300)
			,@beneficiaryBankBranchName			VARCHAR(300)
			,@beneficiaryBankCode				VARCHAR(300)
			,@beneficiaryBankCode2				VARCHAR(300)
			,@beneficiaryBankName				VARCHAR(300)
			,@beneficiaryIdNo					VARCHAR(300)
			,@beneficiaryName					VARCHAR(300)
			,@beneficiaryPhone					VARCHAR(300)
			,@customerAddress					VARCHAR(300)
			,@customerIdDate					VARCHAR(300)
			,@customerIdNo						VARCHAR(300)
			,@customerIdType					VARCHAR(300)
			,@customerName						VARCHAR(300)
			,@customerNationality				VARCHAR(300)
			,@customerPhone						VARCHAR(300)
			,@destinationAmount					VARCHAR(300)
			,@destinationCurrency				VARCHAR(300)
			,@payOutMethod						VARCHAR(300)
			,@purpose							VARCHAR(300)
			,@settlementCurrency				VARCHAR(300)
			,@transactionStatus					VARCHAR(300)
			,@recordStatus						VARCHAR(300)
			,@createdDate						VARCHAR(300)
			,@createdBy							VARCHAR(300)	
					
			,@sAgent							INT	 
			,@sAgentName						VARCHAR(100)
			,@sBranch							INT 
			,@sBranchName						VARCHAR(100)
			,@sSuperAgent						INT
			,@sSuperAgentName					VARCHAR(100) 
			,@sAgentMapCode						INT
	 		,@sBranchMapCode					INT
	 		,@sCountry							VARCHAR(100)
	 		
	 		,@agentType							INT
	 		,@pSuperAgent						INT 
	 		
			,@pSuperAgentName					VARCHAR(100)
			,@pCountry							VARCHAR(100)
			,@pState							VARCHAR(100)
			,@pDistrict							VARCHAR(100)
			,@pLocation							INT
			,@pAgentComm						MONEY
			,@pAgentCommCurrency				VARCHAR(25)
			,@pSuperAgentComm					MONEY
			,@pSuperAgentCommCurrency			VARCHAR(25)			
			,@MapCodeIntBranch					VARCHAR(50)
			,@pBankName							VARCHAR(100)
			,@pBankBranchName					VARCHAR(100)
			,@pBranchName						VARCHAR(100)
			,@sAgentSettRate					VARCHAR(100)
			,@pAgentName						VARCHAR(100)
			,@pCountryId						INT
			,@ControlNoModified			VARCHAR(50)	
	 		
	 		SELECT 
	 			 @sAgent = 4670
	 			,@sAgentName = 'AL ANSARI EXCHANGE'
	 			,@sBranch = 4671
	 			,@sBranchName = 'AL ANSARI EXCHANGE - HEAD OFFICE'
	 			,@sCountry = 'United Arab Emirates'
	 			,@sSuperAgent = 4641
	 			,@sSuperAgentName = 'INTERNATIONAL AGENTS'
	 			,@pCountry = 'Nepal'
	 			,@pCountryId = 151
	 			,@pSuperAgent = 1002
	 			,@pSuperAgentName = 'INTERNATIONAL MONEY EXPRESS (IME) PVT. LTD'	 				 			 		
			
			SELECT 
			 @beneficiaryAddress				=	receiverAddress
			,@beneficiaryBankAccountNumber		=	receiverAccountNumber
			,@beneficiaryBankBranchCode			=	benBranchCode
			,@beneficiaryBankBranchName			=	benBranchName
			,@beneficiaryBankCode				=	benBankCode
			,@beneficiaryBankName				=	benBankName
			,@beneficiaryIdNo					=	''
			,@beneficiaryName					=	receiverName
			,@beneficiaryPhone					=	receiverMobile
			,@customerAddress					=	senderAddress
			,@customerIdDate					=	senderIdDate
			,@customerIdNo						=	senderIdNumber
			,@customerIdType					=	senderIdType
			,@customerName						=	senderName
			,@customerNationality				=	''
			,@customerPhone						=	senderMobileNumber
			,@destinationAmount					=	finalPayoutAmount
			,@destinationCurrency				=	'NPR'
			,@ceNumber							=	ceNumber
			,@purpose							=	'Family Support'
			,@settlementCurrency				=	'NPR'
			,@transactionStatus					=	recordStatus
			,@recordStatus						=	recordStatus
			,@createdDate						=	createdDate
			,@createdBy							=	createdBy
			,@pBranch							=	pBranch
			,@extBankId							=   pBank
			,@extBankBranchId					=	pBankBranch
			,@pBankBranchName					=	pBankBranchName
		FROM ceAcDepositHistory_V2 ce WITH(NOLOCK) 
		WHERE rowId = @rowId
			
		SET @ControlNoModified = dbo.FNAEncryptstring(@ceNumber+'A')

		SELECT 
			@pAgent				= parentId, 
			@pBranchName		= agentName, 
			@agentType			= agentType,
			@pCountry			= agentCountry,
			@pState				= agentState,
			@pDistrict			= agentDistrict,
			@pLocation			= agentLocation,
			@MapCodeIntBranch	= mapCodeInt					 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			
		SELECT @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
	
		--## 3. Find Commission 
		DECLARE @sCountryId INT, @deliveryMethodId INT, @pCommCheck MONEY
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry

		SET @payoutMethod = 'Bank Deposit'
		SET @deliveryMethodId = 2
				
		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'
		
		SELECT @pAgentComm = amount FROM dbo.FNAGetPayComm(
				NULL
				,@sCountryId, NULL, 1002, 151, @pLocation, @pBranch, 'NPR'
				,2, @destinationAmount, @destinationAmount, 0, NULL, NULL
			)		
	
		SELECT 
			 @pBankName = bankName
			,@pAgent = am.agentId
			,@pAgentName = a.bankName
		FROM externalBank a with(nolock) inner join agentMaster am with(nolock) 
		on a.internalCode = am.agentId
		WHERE a.extBankId = @extBankId

		SELECT  top 1
			 @pBranch			= am.agentId
			,@pBranchName		= am.agentName 
		FROM agentMaster am WITH(NOLOCK)
		WHERE am.parentId = @pAgent and am.isHeadOffice = 'Y'
		
		IF @pBranch IS NULL
		BEGIN
			SELECT  top 1
				 @pBranch			= am.agentId
				,@pBranchName		= am.agentName 
			FROM agentMaster am WITH(NOLOCK)
			WHERE am.parentId = @pAgent 
		END

		BEGIN TRANSACTION
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
					 ,[pBank]
					 ,[pBankName]
					 ,[pBankBranch]
					 ,[pBankBranchName]		
					 ,[accountNo]	
					 ,[sCurrCostRate]	
					)
					
					SELECT 
					 @ControlNoModified
					,@customerName
					,@sCountry
					,@sSuperAgent
					,@sSuperAgentName
					,@payoutMethod
					,@destinationAmount--cAmt					
					,@destinationAmount --tAmt
					,@destinationAmount 
					,@pAgentComm
					,@destinationCurrency
					,@pAgent --[pAgent]
					,@pAgentName --[pAgentName]
					,@pSuperAgent --[pSuperAgent]
					,@pSuperAgentName  --[pSuperAgentName]	
					,@beneficiaryName
					,'Nepal'					
					,@pBranch
					,@pBranchName
					,@pState
					,@pDistrict
					,@pLocation
					,@purpose
					,NULL --@remarks	
					,@sAgentSettRate
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
					,@destinationCurrency
					,dbo.FNAEncryptString(@ceNumber)
					,'I'
					,@sAgent
					,@sAgentName
					,@sBranch
					,@sBranchName
					,@extBankId
					,@pBankName
					,@extBankBranchId
					,@pBankBranchName
					,@beneficiaryBankAccountNumber
					,'1'
										
					SET @tranId = SCOPE_IDENTITY()
					
					INSERT INTO tranSenders	(
					 tranId
					,firstName
					,country
					,[address]
					,idType
					,idNumber
					,validDate
					,homePhone
				)
				SELECT
					 @tranId			
					,@customerName
					,@sCountry	
					,@customerAddress
					,@customerIdType	
					,@customerIdNo
					,CONVERT(DATETIME,@customerIdDate,103)
					,@customerPhone					
					
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
					
					)		
				SELECT 
					 @tranId			
					,@beneficiaryName
					,@pCountry
					,@beneficiaryAddress
					,@beneficiaryAddress	
					,@beneficiaryPhone
					,NULL -- rIdType	
					,@beneficiaryIdNo
					,NULL	
					,@beneficiaryIdNo
				
			UPDATE ceAcDepositHistory_V2 SET recordStatus = 'PAID' WHERE ceNumber = @ceNumber	
			--Update Accounting
			EXEC dbo.proc_payAcDepositAC
				 @flag				= 'payIntl'
				,@user				= @user
				,@tranIds			= @tranId

			--Update Inficare
			EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ControlNoModified
			EXEC proc_INFICARE_sendTxn @flag = 'SI-SA', @controlNoEncrypted = @ControlNoModified
			EXEC proc_INFICARE_payTxn @flag = 'p', @tranIds = @tranId	
			
			SET @ceNumber = dbo.FNADecryptString(@ControlNoModified)					
										
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			SET @msg = 
				CASE 
					WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
					ELSE 'Transaction paid successfully'
				END
			EXEC [proc_errorHandler] 0, @msg, @ceNumber	
			RETURN	
		
	END
END


GO
