USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ceAcDepositHistory]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_ceAcDepositHistory]
(
	 @flag				VARCHAR(50)
	,@rowId				INT				= NULL
	,@user				VARCHAR(30)		= NULL
	,@gitNo				VARCHAR(50)		= NULL 
	,@mapCodeInt		INT				= NULL
	,@bankId			INT				= NULL
	,@bankName			VARCHAR(200)	= NULL
	,@pBranch			VARCHAR(100)	= NULL
	,@rBankCode			VARCHAR(50)		= NULL
	,@rBankName			VARCHAR(200)	= NULL
	,@thirdPartyAgentId	INT				= NULL
	,@payResponseCode	VARCHAR(20)		= NULL
	,@payResponseMsg	VARCHAR(100)	= NULL
	,@xml				XML				= NULL
	,@filterType		VARCHAR(20)		= NULL	
	,@extBankId			INT				= NULL
	,@extBankBranchId	INT				= NULL
	,@extBankBranchName VARCHAR(100)	= NULL
	,@pBankType			CHAR(1)			= NULL
	,@redownload		CHAR(1)			= NULL
)
AS
SET NOCOUNT ON 
SET XACT_ABORT ON

BEGIN TRY
	IF @flag = 'd'
	BEGIN
		DELETE FROM ceAcDepositHistory WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0,'Transaction has been deleted successfully.', @rowId
		RETURN
	END
	IF @flag ='i' 
		BEGIN
			DECLARE @rowInserted VARCHAR(50)
			SELECT t.* INTO #temp
			FROM (
				SELECT 
					 beneficiaryAddress = NULLIF(p.value('@beneficiaryAddress','VARCHAR(200)'), '')
					,beneficiaryBankAccountNumber = NULLIF(p.value('@beneficiaryBankAccountNumber','VARCHAR(100)'), '')
					,beneficiaryBankBranchCode = NULLIF(p.value('@beneficiaryBankBranchCode','VARCHAR(100)'), '')
					,beneficiaryBankBranchName = NULLIF(p.value('@beneficiaryBankBranchName','VARCHAR(100)'), '')
					,beneficiaryBankCode = NULLIF(p.value('@beneficiaryBankCode','VARCHAR(100)'), '')
					,beneficiaryBankName = NULLIF(p.value('@beneficiaryBankName','VARCHAR(200)'), '')
					,beneficiaryIdNo = NULLIF(p.value('@beneficiaryIdNo','VARCHAR(50)'), '')
					,beneficiaryName = NULLIF(p.value('@beneficiaryName','VARCHAR(100)'), '')
					,beneficiaryPhone = NULLIF(p.value('@beneficiaryPhone','VARCHAR(50)'), '')
					,customerAddress = NULLIF(p.value('@customerAddress','VARCHAR(100)'), '')
					,customerIdDate = NULLIF(p.value('@customerIdDate','VARCHAR(20)'), '')
					,customerIdNo = NULLIF(p.value('@customerIdNo','VARCHAR(20)'), '')
					,customerIdType = NULLIF(p.value('@customerIdType','VARCHAR(20)'), '')
					,customerName = NULLIF(p.value('@customerName','VARCHAR(100)'), '')
					,customerNationality = NULLIF(p.value('@customerNationality','VARCHAR(100)'), '')
					,customerPhone = NULLIF(p.value('@customerPhone','VARCHAR(100)'), '')
					,destinationAmount = NULLIF(p.value('@destinationAmount','VARCHAR(100)'), '')
					,destinationCurrency = NULLIF(p.value('@destinationCurrency','VARCHAR(100)'), '')
					,gitNo = NULLIF(p.value('@gitNo','VARCHAR(100)'), '')
					,paymentMode = NULLIF(p.value('@paymentMode','VARCHAR(100)'), '')
					,purpose = NULLIF(p.value('@purpose','VARCHAR(20)'), '')
					,settlementCurrency = NULLIF(p.value('@settlementCurrency','VARCHAR(20)'), '')
					,transactionStatus = NULLIF(p.value('@transactionStatus','VARCHAR(100)'), '')				
				FROM @xml.nodes('/root/row') AS tmp(p)
			) t
			LEFT JOIN ceAcDepositHistory h WITH(NOLOCK) ON t.gitNo = h.gitNo
			WHERE h.gitNo IS NULL
			
			BEGIN TRANSACTION	
				INSERT ceAcDepositDownloadLogs(createdBy, createdDate) SELECT @user,  GETDATE()
				INSERT INTO ceAcDepositHistory (
						 beneficiaryAddress, beneficiaryBankAccountNumber, beneficiaryBankBranchCode
						,beneficiaryBankBranchName, beneficiaryBankCode, beneficiaryBankName, beneficiaryIdNo				
						,beneficiaryName, beneficiaryPhone, customerAddress, customerIdDate, customerIdNo					
						,customerIdType, customerName, customerNationality, customerPhone, destinationAmount				
						,destinationCurrency, gitNo, paymentMode, purpose, settlementCurrency				
						,transactionStatus, recordStatus, createdDate, createdBy
					)
				SELECT
						beneficiaryAddress, beneficiaryBankAccountNumber, beneficiaryBankBranchCode
						,beneficiaryBankBranchName, beneficiaryBankCode, beneficiaryBankName, ISNULL(beneficiaryIdNo, ABS(CHECKSUM(NEWID())))		
						,beneficiaryName, beneficiaryPhone, customerAddress, customerIdDate, customerIdNo					
						,customerIdType, customerName, customerNationality, customerPhone, destinationAmount				
						,destinationCurrency, gitNo, paymentMode, purpose, settlementCurrency			
						,transactionStatus,'DRAFT', GETDATE(),@user		
				FROM #temp
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
			 [Control NO] = gitNo
			,[TRAN NO] =''
			,[Sending Country]=''
			,[Sending Agent]=''
			,[Bank Name] = beneficiaryBankName
			,[Branch Name]	= beneficiaryBankBranchName
			,[Receiver Name] = beneficiaryName
			,[Bank A/C NO]	= beneficiaryBankAccountNumber
			,[DOT]	= createdDate
			,[Total Amount] = destinationAmount
			,[Unpaid Days] = DATEDIFF(DAY,createdDate,GETDATE())			
			,rowId
		FROM ceAcDepositHistory WITH(NOLOCK)
		WHERE recordStatus <> 'CANCEL' AND pAgent = @rbankCode
	RETURN
	END	
	
	IF @flag='all-list' -- show all downloaded txn list
		BEGIN	
		DECLARE @sql VARCHAR(MAX)
	SET @sql='
		SELECT 
			 [Control NO] = gitNo			
			,[Sending Country]=''CASH EXPRESS API''
			,[Sending Agent]=''CASH EXPRESS''
			,[Bank Name] = beneficiaryBankName
			,[Branch Name]	= beneficiaryBankBranchName
			,[Receiver Name] = beneficiaryName
			,[Bank A/C NO]	= beneficiaryBankAccountNumber
			,[DOT]	= createdDate
			,[Total Amount] = destinationAmount
			,[Unpaid Days] = DATEDIFF(DAY,createdDate,GETDATE())
			,[Record Status] = CASE WHEN pAgent IS NULL THEN ''UNASSIGNED'' ELSE ''ASSIGNED'' END
			,rowId			
		FROM ceAcDepositHistory WITH(NOLOCK)
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
		    ,amt = SUM(CAST(destinationAmount AS MONEY))
		    FROM ceAcDepositHistory ce WITH(NOLOCK)
		    INNER JOIN agentMaster am WITH(NOLOCK) ON ce.pAgent = am.agentId
		    WHERE recordStatus <> 'CANCEL' AND pAgent IS NOT NULL
		    GROUP BY am.agentName, am.agentId
		    		    
		SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @thirdPartyAgentId
	END	
	
	IF @flag = 'a' -- select by control no 
		BEGIN
		SELECT 
			 rowId
			,[rCountry] = 'Nepal'
			,[rAddress] = beneficiaryAddress
			,[rBankAcNo] = beneficiaryBankAccountNumber
			,[rBankBranchCode] = beneficiaryBankBranchCode
			,[rBankBranchName] = beneficiaryBankBranchName
			,[rBankCode] = beneficiaryBankCode
			,[rBankName] = beneficiaryBankName
			,[rIdType] = 'ID'
			,[rIdNo] = ISNULL(beneficiaryIdNo, ABS(CHECKSUM(NEWID())))
			,[rName] = beneficiaryName
			,[rContactNo] = beneficiaryPhone
			,[sCountry] = 'United Arab Emirates'
			,[sAddress] = customerAddress
			,[sIdValidDate] = customerIdDate
			,[sIdNo] = customerIdNo
			,[sIdType] = customerIdType
			,[sName] = customerName
			,[sNationality] = customerNationality
			,[sContactNo] = customerPhone
			,[rAmount] = destinationAmount
			,[rCurrency] = destinationCurrency
			,[controlNo] = gitNo
			,paymentMode
			,purpose
			,settlementCurrency
			,transactionStatus
			,[pBankId] = CAST(pBank AS VARCHAR) + '|' + pBankType
			,[pBranchId] = pBankBranch			
		FROM ceAcDepositHistory ce WITH(NOLOCK)
		WHERE rowId = @rowId
		RETURN
	END	
	
	IF @flag = 'payError'
		BEGIN
		UPDATE ceAcDepositHistory SET 
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
		UPDATE ceAcDepositHistory SET
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
			,@pAgentCommCurrency				VARCHAR(3)
			,@pSuperAgentComm					MONEY
			,@pSuperAgentCommCurrency			VARCHAR(3)			
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
			 @beneficiaryAddress				=	beneficiaryAddress
			,@beneficiaryBankAccountNumber		=	beneficiaryBankAccountNumber
			,@beneficiaryBankBranchCode			=	beneficiaryBankBranchCode
			,@beneficiaryBankBranchName			=	beneficiaryBankBranchName
			,@beneficiaryBankCode				=	beneficiaryBankCode
			,@beneficiaryBankName				=	beneficiaryBankName
			,@beneficiaryIdNo					=	beneficiaryIdNo
			,@beneficiaryName					=	beneficiaryName
			,@beneficiaryPhone					=	beneficiaryPhone
			,@customerAddress					=	customerAddress
			,@customerIdDate					=	customerIdDate
			,@customerIdNo						=	customerIdNo
			,@customerIdType					=	customerIdType
			,@customerName						=	customerName
			,@customerNationality				=	customerNationality
			,@customerPhone						=	customerPhone
			,@destinationAmount					=	destinationAmount
			,@destinationCurrency				=	destinationCurrency
			,@gitNo								=	gitNo
			,@purpose							=	purpose
			,@settlementCurrency				=	settlementCurrency
			,@transactionStatus					=	transactionStatus
			,@recordStatus						=	recordStatus
			,@createdDate						=	createdDate
			,@createdBy							=	createdBy
			,@pBranch							=	pBranch
			,@extBankId							=   pBank
			,@extBankBranchId					=	pBankBranch
			,@pBankBranchName					=	pBankBranchName
		FROM ceAcDepositHistory ce WITH(NOLOCK) 
		WHERE rowId = @rowId
			
		SET @ControlNoModified = dbo.FNAEncryptstring(@gitNo+'A')

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
					,dbo.FNAEncryptString(@gitNo)
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
				
			UPDATE ceAcDepositHistory SET recordStatus = 'PAID' WHERE gitNo = @gitNo	

			--Update Inficare
			EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ControlNoModified
			SET @gitNo = dbo.FNADecryptString(@ControlNoModified)					
										
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			SET @msg = 
				CASE 
					WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
					ELSE 'Transaction paid successfully'
				END
			EXEC [proc_errorHandler] 0, @msg, @gitNo	
			RETURN	
		
	END
	
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
	SELECT ERROR_LINE()
END CATCH


GO
