USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GMERemitBankDepositPay]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_GMERemitBankDepositPay](
	 @flag							VARCHAR(50) = NULL
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
	,@XML							VARCHAR(MAX)= NULL
	
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
	,@pBankType						CHAR(1)		= NULL
	,@redownload					CHAR(1)		= NULL
	,@user							VARCHAR(30)	= NULL
	,@pBankBranchName				VARCHAR(150) = NULL 
	,@pBankBranch					INT = NULL 
	,@pBank							INT = NULL
	,@bankBranchName				VARCHAR(100)= NULL
	,@pAgent						INT = NULL		
	,@sCountry						VARCHAR(50) = NULL
	,@payConfirmationNo				VARCHAR(50) = NULL
	,@sBranchMapCOdeInt				INT			= NULL
	,@XML2							XML			= NULL
	)
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	
	DECLARE	 @tranId					BIGINT
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
			,@sAgentMapCode				INT = 1075
	 		,@sBranchMapCode			INT 

			,@sAgentSettRate			VARCHAR(100) = NULL
			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
			,@tAmt						MONEY
			,@ServiceCharge				MONEY
			,@beneIdNo					INT
			,@customerRate				MONEY
			,@payoutCurr				VARCHAR(50)
			,@collCurr					VARCHAR(50)			 		
			,@MapCodeIntBranch			VARCHAR(50) 
			,@companyId					INT = 16
			,@ControlNoModified			VARCHAR(50)
			,@controlNo					VARCHAR(50)
			,@sCountryId				INT
			,@pAgentName				VARCHAR(80)
			,@pCountryId				INT
			,@recordStatus				VARCHAR(30)
			,@agentName					VARCHAR(100)
			,@status					VARCHAR(30)
			
			,@senderIdNo				VARCHAR(15)
			,@rCurrency					VARCHAR(30)
			,@refNo						VARCHAR(30)
			,@benefName					VARCHAR(100)
			,@benefMobile				VARCHAR(30)
			,@benefAddress				VARCHAR(150)
			,@senderMobile				VARCHAR(30)
			,@pCurrency					VARCHAR(30)
			,@pCommission				MONEY
			,@pAmount					MONEY
			,@rIdType					VARCHAR(30)
			,@rIdNumber					VARCHAR(30)
			,@rValidDate				DATETIME
			,@rIssuedDate				DATETIME
			,@rDob						DATETIME
			,@rOccupation				VARCHAR(100)
			,@rNativeCountry			VARCHAR(50)
			,@rIdPlaceOfIssue			VARCHAR(100)
			,@relationType				VARCHAR(100)
			,@relativeName				VARCHAR(100)
			,@rbankBranch				VARCHAR(100)
			,@rcheque					VARCHAR(50)
			,@rAccountNo				VARCHAR(50)
			,@purpose					VARCHAR(250)
			,@relationship				VARCHAR(100)
			,@pBranchName				VARCHAR(100)
			,@remarks					VARCHAR(500)
			,@sCurrCostRate				MONEY
			,@rCurrCostRate				MONEY
			,@transferAmount			MONEY
			,@pCurrCostRate				MONEY

	IF @flag = 'download'
	BEGIN
	    DECLARE @XML1 XML, @downloadTokenId VARCHAR(50)
      
		set @XML = REPLACE(@XML,'<?xml version="1.0" encoding="utf-16"?>','')
		set @XML = REPLACE(@XML,'<ArrayOfGetBankDepositTransactionResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">','')
		set @XML = REPLACE(@XML,'<ArrayOfReturn_ACC_Deposit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">','')
		set @XML = REPLACE(@XML,'</ArrayOfGetBankDepositTransactionResult>','')
		set @XML = REPLACE(@XML,' xmlns="http://tempuri.org/"','')
		set @XML = REPLACE(@XML,'<?xml version="1.0" encoding="utf-16"?>','')
		set @XML = REPLACE(@XML,'<ArrayOfGetBankDepositTransactionResult xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">','')
		set @XML = REPLACE(@XML,'<ArrayOfReturn_ACC_Deposit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">','')
		set @XML = REPLACE(@XML,'</ArrayOfGetBankDepositTransactionResult>','')
		set @XML = REPLACE(@XML,' xmlns="http://tempuri.org/"','')
		
		SET @XML1 = @XML
		DECLARE @rowInserted VARCHAR(50)
		--@XML =  REPLACE(REPLACE(@xml, '&quot;', '"'), '&quot', '"')
		SELECT x.* INTO #tempCE
			FROM (	
				SELECT 
				p.value('(PinNo)[1]','VARCHAR(200)') AS 'controlNo'
				,p.value('(SendingAgent)[1]','VARCHAR(200)') AS 'sendAgent'
				,p.value('(CustomerName)[1]','VARCHAR(200)') AS 'senderName'
				,p.value('(CutomerAdress)[1]','VARCHAR(200)') AS 'senderAddress'
				,p.value('(CustomerContact)[1]','VARCHAR(200)') AS 'senderMobileNumber'
				,p.value('(CustomerCity)[1]','VARCHAR(200)') AS 'senderCity'
				,p.value('(CustomerCountry)[1]','VARCHAR(200)') AS 'senderCountry'
				,p.value('(BeneName)[1]','VARCHAR(200)') AS 'receiverName'
				,p.value('(BeneAddress)[1]','VARCHAR(200)') AS 'receiverAddress'
				,p.value('(BenePhone)[1]','VARCHAR(200)') AS 'receiverMobile'
				,p.value('(BeneCity)[1]','VARCHAR(200)') AS 'receiverCity'
				,p.value('(BeneCountry)[1]','VARCHAR(200)') AS 'receiverCountry'
				,p.value('(TransferAmount)[1]','VARCHAR(200)') AS 'transferAmount'
				,p.value('(ScurrCostRate)[1]','VARCHAR(200)') AS 'sCurrCostRate'
				,p.value('(RcurrCostRate)[1]','VARCHAR(200)') AS 'rCurrCostRate'
				,p.value('(ReceivingAmount)[1]','VARCHAR(200)') AS 'payoutAmount'
				,p.value('(ReceivingCurrency)[1]','VARCHAR(200)') AS 'payoutCurrency'
				,p.value('(PaymentMethod)[1]','VARCHAR(200)') AS 'paymentType'
				,p.value('(BankCode)[1]','VARCHAR(200)') AS 'benBankCode'
				,p.value('(BankName)[1]','VARCHAR(200)') AS 'benBankName'
				,p.value('(BankAccountNumber)[1]','VARCHAR(200)') AS 'receiverAccountNumber'
				,p.value('(BankBranchCode)[1]','VARCHAR(200)') AS 'benBankBranchCode'
				,p.value('(BankBranchName)[1]','VARCHAR(200)') AS 'benBankBranchName'
				,p.value('(TransactionDate)[1]','VARCHAR(200)') AS 'txnCreatedDate'
				,p.value('(DownLoadTokenId)[1]','VARCHAR(200)') AS 'downloadTokenId'
				,p.value('(SessionId)[1]','VARCHAR(200)') AS 'agentSessionId'
				
				FROM @XML1.nodes('/GetBankDepositTransactionResult') AS tmp(p)
			)x
			LEFT JOIN dbo.GMEPayHistory r WITH(NOLOCK) ON r.refNo = dbo.FNAEncryptString(x.controlNo)
			WHERE r.refNo IS NULL

			
			
			BEGIN TRANSACTION
				INSERT INTO dbo.GMEPayHistory( refNo ,senderAgent ,senderName ,senderAddress ,senderCity ,senderMobile ,senderCountry, benefName ,
					benefAddress ,benefMobile ,benefCity ,benefCountry ,pAmount ,pCurrency ,paymentType ,beneBankName ,beneBankBranchName ,
				    beneAccountNo ,beneBankCode ,beneBankBranchCode ,txnDate , tokenId, sessionId, createdBy, createdDate, recordStatus,
					transferAmount, sCurrCostRate, rCurrCostRate)
				          
				SELECT
					 dbo.FNAEncryptString(controlNo), sendAgent, senderName, senderAddress, senderMobileNumber, senderCity, senderCountry, receiverName,
					 receiverAddress, receiverMobile, receiverCity, receiverCountry, payoutAmount, payoutCurrency, paymentType, benBankName, benBankBranchName,
					 receiverAccountNumber, benBankCode, benBankBranchCode, txnCreatedDate, downloadTokenId, agentSessionId, @user, GETDATE(), 'DRAFT',
					 transferAmount, sCurrCostRate, rCurrCostRate
				FROM #tempCE
			
			SET @rowInserted = @@ROWCOUNT

			
			----------------#######--------------------------Remit Tran
			--## 2. Find Sending Agent Details
			SELECT @sAgent = sAgent,@sAgentName = sAgentName,@sBranch = sBranch,@sBranchName = sBranchName
					,@sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName
					,@pCountry = pCountry,@pCountryId = pCountryId
					,@pSuperAgent = pSuperAgent, @pSuperAgentName = pSuperAgentName
			FROM dbo.FNAGetBranchFullDetails(394432)

			SET @sCountryId = 118
			SET @sCountry = 'South Korea'
			SET @payoutCurr = 'MNT'
			set @pCountry = 'Mongolia'

			SELECT @downloadTokenId = downloadTokenId FROM #tempCE 
			DECLARE @autoMappedTxns int 
			DECLARE @autoMappedTxnswallet int 



		INSERT INTO remitTran ([controlNo],[senderName],[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod] 
			,[cAmt],[pAmt],[tAmt] ,[payoutCurr],[pAgent],[pAgentName],pBranch, pBranchName
			,[receiverName] ,[pCountry],pBank, pBankName, pBankBranch, pBankBranchName,[purposeofRemit]
			,[sAgentSettRate],[createdDate],[createdDateLocal],[createdBy],[approvedDate]    
			,[approvedDateLocal],[approvedBy]
			,[serviceCharge]   
			,sCurrCostRate,pCurrCostRate,agentCrossSettRate, accountNo     
			--## hardcoded parameters   
			,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName], sRouteId
			,customerrate,sourceoffund	
					)
		SELECT
			dbo.FNAEncryptString(controlNo),senderName,@sCountry,@sSuperAgent,@sSuperAgentName
			,case when paymentType='BANK DEPOSIT' then 'Bank Deposit' else 'Cash Payment' end 
			,transferAmount,payoutAmount,transferAmount-x.amount,@payoutCurr
			,case when P.agentType = '2903' then P.agentId else A.agentId end
			,case when P.agentType = '2903' then P.agentName else A.agentName end
			,A.agentId, A.agentName
			,receiverName, @pCountry
			,case when P.agentType = '2903' then P.agentId else A.agentId end
			,case when P.agentType = '2903' then P.agentName else A.agentName end
			,A.agentId, A.agentName , 'Family Maintainance'
			,sCurrCostRate,txnCreatedDate,txnCreatedDate,@user,GETDATE()
			,GETDATE(), @user ,x.amount
			,sCurrCostRate	,rCurrCostRate,rCurrCostRate, receiverAccountNumber 			
			--## HardCoded Parameters
			, 'Payment', 'Unpaid', 'KRW'
			, dbo.FNAEncryptString(controlNo), 'I', @sAgent, @sAgentName
			, @sBranch, @sBranchName, 'GME'
			, 1, 'Employees Salary'
		FROM #tempCE T
		INNER JOIN agentMaster A (NOLOCK) ON A.routingCode = T.benBankCode
		INNER JOIN agentMaster P (nolock) on P.agentId = A.parentId
		CROSS APPLY [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch,142,null,NULL,NULL,case when paymentType='BANK DEPOSIT' then '2' else '1' end ,t.transferAmount,'KRW')X

	
		SET @autoMappedTxns  = @@ROWCOUNT

		ALTER TABLE #tempCE ADD tranId BIGINT

		update t  SET T.tranId = R.Id 
		FROM #tempCE T
		INNER JOIN remitTran R (NOLOCK) 
		ON R.controlNo = dbo.FNAEncryptString(T.controlNo)

		update r SET r.customerrate = (r.pCurrCostRate/r.sCurrCostRate)
		FROM #tempCE T
		INNER JOIN remitTran R (NOLOCK) 
		ON T.tranId = R.Id




		INSERT INTO tranSenders	(
				tranId,firstName,country,[address],idType,idNumber,mobile)
		SELECT	t.tranId,senderName,@sCountry,senderAddress,null,null,senderMobileNumber
		FROM #tempCE T

		--## Inserting Data in tranReceivers table
		INSERT INTO tranReceivers (
				tranId,firstName,country,city,[address],mobile
				,accountNo,relWithSender,purposeOfRemit)		
		SELECT t.tranId,receiverName,@pCountry,receiverCity,receiverAddress,receiverMobile
			    ,receiverAccountNumber,'Family','Family Maintainance'
		FROM #tempCE T

		update g set g.recordStatus = 'Paid' from GMEPayHistory g
		inner join #tempCE t on dbo.FNAEncryptString(t.controlNo) = g.refNo

		INSERT apiBankDepositDownloadLogs(downloadQty, createdBy, createdDate, providerName) 
		SELECT @rowInserted, @user,  GETDATE(), 'GME'

	IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			DECLARE @msg VARCHAR(MAX)
			SET @msg = @rowInserted + ' Txns Downloaded Successfully AND ' + cast((ISNULL(@autoMappedTxns,0)  + ISNULL(@autoMappedTxnswallet,0))as varchar) + ' Txns Mapped Automatically.'
			IF @rowInserted = '0' 
			BEGIN
				EXEC proc_errorHandler 1,@msg,@downloadTokenId
				RETURN
			END
			EXEC proc_errorHandler 0,@msg,@downloadTokenId
		END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SET @msg = 'Error in operation please try again.'
				EXEC proc_errorHandler 1,@msg,@downloadTokenId
			END
		RETURN		
	END

	IF @flag='all-list' -- show all downloaded txn list
	BEGIN	
		DECLARE @sql VARCHAR(MAX)
		SET @sql='
		SELECT 
			 [Control NO] = dbo.FNADecryptString(refNo)			
			,[Sending Country]= senderCountry
			,[Sending Agent]=''GME''
			,[Bank Name] = beneBankName
			,[Branch Name]	= beneBankBranchName
			,[Receiver Name] = benefName
			,[Bank A/C NO]	= beneAccountNo
			,[DOT]	= txnDate
			,[Total Amount] = pAmount
			,[Unpaid Days] = DATEDIFF(DAY, createdDate, GETDATE())
			,[Record Status] = CASE WHEN pBank IS NULL THEN ''UNASSIGNED'' ELSE ''ASSIGNED'' END
			,rowId			
		FROM GMEPayHistory WITH(NOLOCK)
		WHERE recordStatus NOT IN(''CANCEL'',''PAID'',''Bank'') 
		AND paymentType IN (''BANK DEPOSIT'')  '
		
		IF @filterType = 'A' -- Unassigned 
			SET @sql = @sql + 'AND pBank IS NULL '
		
		ELSE IF @filterType = 'UA' -- Assigned
			SET @sql = @sql + 'AND pBank IS NOT NULL '
		
		SET @sql = @sql + 'ORDER BY createdDate DESC'
		EXEC (@sql)
		
		SELECT TOP 1 createdBy, CONVERT(VARCHAR(19), createdDate, 100), downloadQty 
		FROM apiBankDepositDownloadLogs WITH(NOLOCK) WHERE providerName = 'GME' ORDER BY rowId DESC
		RETURN
	END	
	
	IF @flag = 'a' -- select by rowid 
	BEGIN
		SELECT 
			 RR.rowId
			,[rCountry]			= 'Nepal'
			,[rAddress]			= RR.benefAddress
			,[rBankAcNo]		= RR.beneAccountNo
			,[rBankBranchCode]	= RR.pBankBranch
			,[rBankBranchName]	= RR.[beneBankBranchName]
			,[rBankCode]		= RR.[pBank]
			,[rBankName]		= RR.[beneBankName]
			,[rIdType]			= ''
			,[rIdNo]			= ''
			,[rName]			= RR.[benefName]
			,[rContactNo]		= RR.[benefMobile]
			,[sCountry]			= RR.[senderCountry]
			,[sAddress]			= RR.[senderAddress]
			,[sName]			= RR.[senderName]
			,[sNationality]		= ''
			,[sContactNo]		= RR.[senderMobile]
			,[rAmount]			= RR.[pAmount]
			,[rCurrency]		= RR.[pCurrency]
			,[controlNo]		= DBO.FNADECRYPTSTRING(RR.[refNo])
			,paymentMode		= 'B'
			,purpose			= 'Family Support'
			,settlementCurrency = RR.[pCurrency]
			,transactionStatus	= RR.recordStatus
			,[pBankId]			= RR.pBank
			,[pBranchId]		= RR.pBankBranch
			,receiverIdType		= RR.rIdType
			,receiverIdNumber	= RR.rIdNumber	
			,idType				= S.valueId
			,downloadTokenId	= RR.tokenId
		FROM dbo.GMEPayHistory RR WITH(NOLOCK)
		LEFT JOIN dbo.staticDataValue S ON S.detailTitle = RR.rIdType
		WHERE RR.rowId = @rowid
		RETURN
	END	
	
	IF @flag = 'select' -- select by control no 
	BEGIN
		SELECT 
			  RR.rowId
			,[rCountry]			= 'Nepal'
			,[rAddress]			= RR.benefAddress
			,[rBankAcNo]		= RR.beneAccountNo
			,[rBankBranchCode]	= RR.pBankBranch
			,[rBankBranchName]	= RR.[beneBankBranchName]
			,[rBankCode]		= RR.[pBank]
			,[rBankName]		= RR.[beneBankName]
			,[rIdType]			= RR.[rIdType]
			,[rIdNo]			= RR.[rIdNumber]
			,[rName]			= RR.[benefName]
			,[rContactNo]		= RR.[benefMobile]
			,[sCountry]			= RR.[senderCountry]
			,[sAddress]			= RR.[senderAddress]
			,[sName]			= RR.[senderName]
			,[sNationality]		= ''
			,[sContactNo]		= RR.[senderMobile]
			,[rAmount]			= RR.[pAmount]
			,[rCurrency]		= RR.[pCurrency]
			,[controlNo]		= DBO.FNADECRYPTSTRING(RR.[refNo])
			,paymentMode		= 'B'
			,purpose			= 'Family Support'
			,settlementCurrency = RR.[pCurrency]
			,transactionStatus	= RR.recordStatus
			,[pBankId]			= RR.pBank
			,[pBranchId]		= RR.pBankBranch
			,receiverIdType		= RR.rIdType
			,receiverIdNumber	= RR.rIdNumber	
			,idType				= S.valueId
		FROM dbo.GMEPayHistory RR WITH(NOLOCK)
		LEFT JOIN dbo.staticDataValue S ON S.detailTitle = RR.rIdType
		WHERE RR.[refNo] = @ceNumber
		RETURN
	END
	
	IF @flag = 'payError'
	BEGIN
		UPDATE dbo.GMEPayHistory SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	
	IF	@flag='updateBank' --Assign Bank
	BEGIN
		DECLARE @pBankName VARCHAR(100)
		IF EXISTS (SELECT rowid FROM dbo.GMEPayHistory WHERE rowid = @rowid AND recordStatus = 'PAID')
		BEGIN
		    EXEC proc_errorHandler 1, 'Transaction already paid', NULL 
			RETURN
		END
			
		UPDATE dbo.GMEPayHistory SET
			  pBank				= @pBank
			 ,pBankBranch		= @pBankBranch
			 ,pBranch			= @pBankBranch
			 ,recordStatus		= 'PAID'
		WHERE rowId = @rowId
		
		--Insert into remittran
		SELECT
			 @refNo						= rm.refNo
			,@benefName					= rm.benefName
			,@benefMobile				= rm.benefMobile 
			,@benefAddress				= rm.benefAddress
			,@senderName				= rm.senderName
			,@senderAddress 			= rm.senderAddress
			,@senderMobile				= rm.senderMobile 
			,@pCurrency					= rm.pCurrency
			,@pCommission				= NULL
			,@pAmount					= rm.pAmount
			,@recordStatus				= rm.recordStatus
			,@rIdType					= rm.rIdType
			,@rIdNumber					= rm.rIdNumber
			,@rValidDate				= rm.rValidDate
			,@rIssuedDate				= rm.rIssueDate
			,@rDob						= rm.rDob
			,@rOccupation				= rm.rOccupation
			,@rNativeCountry			= rm.nativeCountry
			,@pBranch					= isnull(@pBankBranchName,rm.pBranch)
			,@rIdPlaceOfIssue			= rm.rIdPlaceOfIssue
			,@relationType				= rm.relationType
			,@relativeName				= rm.relativeName
			,@rbankName					= rm.rBank
			,@rbankBranch				= rm.rBankBranch
			,@rcheque					= rm.rAccountNo
			,@rAccountNo				= rm.beneAccountNo
			,@purpose					= rm.purposeOfRemit
			,@relationship				= rm.relWithSender
			,@pBank						= rm.pBank
			,@pBankBranch				= rm.pBankBranch
			,@transferAmount			= rm.transferAmount
			,@rCurrCostRate				= rm.rCurrCostRate
			,@sCurrCostRate				= rm.sCurrCostRate
			,@txnCreatedDate			= rm.txnDate
			,@pCurrCostRate				= rm.rCurrCostRate
		FROM dbo.GMEPayHistory rm WITH(NOLOCK)
		WHERE rowId = @rowId
		
		--## 1. Get payout bank and bank branch name
		SELECT @pBank = sAgent,@pBankName = sAgentName,
				@pBankBranch = sBranch,@pBankBranchName = sBranchName
		FROM dbo.FNAGetBranchFullDetails(@pBankBranch)

		--## 2. Find Sending Agent Details
		SELECT @sAgent = sAgent,@sAgentName = sAgentName,@sBranch = sBranch,@sBranchName = sBranchName
				,@sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName
				,@pCountry = pCountry,@pCountryId = pCountryId
				,@pSuperAgent = pSuperAgent, @pSuperAgentName = pSuperAgentName
		FROM dbo.FNAGetBranchFullDetails(394432)

		--## 3. set Sending country details
		SET @sCountryId = 118
		SET @sCountry = 'South Korea'
		SET @payoutCurr = 'NPR'

		SET @ControlNoModified = @refNo

		--## Check if controlno exist in remittran. 		
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified)
		BEGIN
			SELECT  
				@agentName = sAgentName
				,@status = payStatus	
			FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified
			SET @msg = 'This transaction belongs to ' + @agentName + ' and is in status: ' + @status
			EXEC proc_errorHandler 1,@msg,NULL
			RETURN
		END

		DECLARE @deliveryMethodId INT
		
		SELECT @payoutMethod = 'Bank Deposit', @collCurr='KRW'
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'			

		--## GET SERVICE CHARGE
		SET @tAmt = @transferAmount

		SELECT @ServiceCharge = AMOUNT FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch
				,@pCountryId,null,@pBank,@pBankBranch,@deliveryMethodId,@tAmt,@collCurr)
		
		SET @cAmt = @tAmt + isnull(@ServiceCharge, 0)

		SET @customerRate = @pCurrCostRate / @sCurrCostRate

		BEGIN TRANSACTION
		BEGIN
		--## Inserting Data in remittran table 
			INSERT INTO remitTran ([controlNo],[senderName],[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod] 
			,[cAmt],[pAmt],[tAmt] ,[payoutCurr],[pAgent],[pAgentName],pBranch, pBranchName
			,[receiverName] ,[pCountry],pBank, pBankName, pBankBranch, pBankBranchName,[purposeofRemit]
			,[sAgentSettRate],[createdDate],[createdDateLocal],[createdBy],[approvedDate]    
			,[approvedDateLocal],[approvedBy],[serviceCharge]   
			,sCurrCostRate,pCurrCostRate,agentCrossSettRate, accountNo     
			--## hardcoded parameters   
			,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName], sRouteId
			,customerrate,sourceoffund					
					)
		SELECT
			@ControlNoModified,@senderName,@sCountry,@sSuperAgent,@sSuperAgentName,'Bank Deposit'
			,@cAmt,@pAmount,@tAmt,@payoutCurr,@pBank, @pBankName, @pBankBranch, @pBankBranchName
			,@receiverName, @pCountry, @pBank, @pBankName, @pBankBranch, @pBankBranchName, @purpose
			,@sCurrCostRate,@txnCreatedDate,@txnCreatedDate,@user,@txnCreatedDate
			,@txnCreatedDate, @user,@ServiceCharge
			,@sCurrCostRate	,@pCurrCostRate,@rCurrCostRate, @rAccountNo 			
			--## HardCoded Parameters
			,'Payment', 'Unpaid',@collCurr,@refNo,'I',@sAgent,@sAgentName,@sBranch,@sBranchName, 'GME'
			,@customerRate, 'Employees Salary'
					
				SET @tranId = SCOPE_IDENTITY()
				
				--## Inserting Data in tranSenders table
				INSERT INTO tranSenders	(
						tranId,firstName,country,[address],idType,idNumber,mobile)
				SELECT	@tranId,@senderName,@sCountry,@senderAddress,@senderIdType,@senderIdNo,@senderMobile
				
				--## Inserting Data in tranReceivers table
				INSERT INTO tranReceivers (
						tranId,firstName,country,city,[address],mobile,idType2,idNumber2,dob,occupation,validDate,idPlaceOfIssue
						,relationType,relativeName,bankName
						,branchName,chequeNo,accountNo,relWithSender,purposeOfRemit,issuedDate2,validDate2)		
				SELECT @tranId,@benefName,@pCountry,@benefAddress,@benefAddress,@benefMobile,@rIdType,@rIdNumber,@rDob,@rOccupation,@rValidDate,@rIdPlaceOfIssue
					,@relationType,@relativeName,@rbankName,@rbankBranch,@rcheque,@raccountNo,@relationship,@purpose,@rIssuedDate,@rValidDate
			
			--## Updating Data in reliableRemitPayHistory table by paid status
			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @Pamount ,@settlingAgent = @pBranch
		END
		IF @@TRANCOUNT > 0
		BEGIN
			DECLARE @controlNoDec VARCHAR(50) = dbo.decryptDb(@refNo)
			EXEC proc_errorHandler 0,'Bank Updated Successfully.', @controlNoDec
			COMMIT TRANSACTION
				
			RETURN
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			EXEC [proc_errorHandler] 1, 'Error in operation data', NULL 
		END
	END	

	IF @flag='getAcNumUpdate'
	BEGIN
		UPDATE dbo.GMEPayHistory  SET 
			beneAccountNo = @receiverAccountNumber
			WHERE rowid = @rowId	
					
		EXEC [proc_errorHandler] 0, 'Receiver bank account number updated successfully.', @rowId
		RETURN
	END	


	IF	@flag='updateRecName' 
	BEGIN
		DECLARE @oldReceiverName VARCHAR(100)
		SELECT @oldReceiverName = benefName, @ceNumber = refNo from dbo.GMEPayHistory  (NOLOCK) WHERE rowId = @rowId
		
		IF LTRIM(RTRIM(@oldReceiverName)) <> @receiverName
			INSERT TPTxnModifyLogs(provider, controlNo, filedName, oldValue, newValue,	createdBy, createdDate)
			SELECT 'GME', @ceNumber, 'receiverName', @oldReceiverName, @receiverName, @user, GETDATE()
				
		UPDATE GMEPayHistory SET 
			benefName = @receiverName
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Receiver Name Updated Successfully.', @rowId
		RETURN
	END	

	IF	@flag='updateBankDetails' 
	BEGIN
		DECLARE @oldNankName VARCHAR(100), @oldBankBranchName VARCHAR(100), @oldReceiverAccountNumber VARCHAR(100)
		SELECT 
			@oldNankName = ISNULL(beneBankName, ''), @oldBankBranchName = ISNULL(beneBankBranchName, ''), @oldReceiverAccountNumber = ISNULL(beneAccountNo, '')
			,  @ceNumber = refNo 
		FROM dbo.GMEPayHistory (NOLOCK)
		WHERE rowId = @rowId
		
		IF LTRIM(RTRIM(@oldNankName)) <> @bankName
			INSERT TPTxnModifyLogs(provider, controlNo, filedName, oldValue, newValue,	createdBy, createdDate)
			SELECT 'GME', @ceNumber, 'pBankName', @oldNankName, @bankName, @user, GETDATE()
	
	
		IF LTRIM(RTRIM(@oldBankBranchName)) <> @bankBranchName
			INSERT TPTxnModifyLogs(provider, controlNo, filedName, oldValue, newValue,	createdBy, createdDate)
			SELECT 'GME', @ceNumber, 'benBranchName', @oldBankBranchName, @bankBranchName, @user, GETDATE()
	
		IF LTRIM(RTRIM(@oldReceiverAccountNumber)) <> @receiverAccountNumber
			INSERT TPTxnModifyLogs(provider, controlNo, filedName, oldValue, newValue,	createdBy, createdDate)
			SELECT 'GME', @ceNumber, 'receiverAccountNumber', @oldReceiverAccountNumber, @receiverAccountNumber, @user, GETDATE()
	
		UPDATE dbo.GMEPayHistory SET
			 beneBankName			= @bankName		 
			,beneBankBranchName		= @bankBranchName					
			,beneAccountNo			= @receiverAccountNumber			
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Bank Details Updated Successfully.', @rowId
		RETURN
	END

	IF @flag = 'GET-LIST'	--GET LIST TO SYNC AS PAID WITH GME
	BEGIN
		IF OBJECT_ID('tempdb..#tempBankDeposit') IS NOT NULL
			DROP TABLE #tempBankDeposit

	    SELECT TOP 100 b.rowId, controlNo = dbo.fnadecryptstring(b.controlNo), b.paidDate INTO #tempBankDeposit
		FROM bankDepositAPIQueu b 
		inner join remitTran(nolock) rt ON b.controlNo = rt.controlNo
		-- where rt.controlNo = dbo.encryptdb('80240864349')
		WHERE ISNULL(b.txnStatus, 'payError') = 'payError' 
		AND b.provider = 'GME' 
		and rt.transtatus = 'paid'
		and rt.paystatus = 'paid'
		ORDER BY rowId DESC
				
		SELECT * FROM #tempBankDeposit

		UPDATE b SET b.txnStatus = 'readyToPay'
		FROM bankDepositAPIQueu b 
		INNER JOIN #tempBankDeposit t ON t.rowId = b.rowId
	END

	IF @flag = 'PAY-ERROR'
	BEGIN
		DECLARE @controlNoTable TABLE(controlNo VARCHAR(50),tranId BIGINT)
		INSERT INTO @controlNoTable(controlNo)
		SELECT ICN= dbo.FNAEncryptString(p.value('(text())[01]', 'VARCHAR(100)')) FROM @XML2.nodes('/root/row') n1(p)

		UPDATE API SET API.txnStatus = 'payError',
						API.confirmedBy = @user,
						API.confirmedDate = GETDATE(),
						API.apiResponseCode = @payResponseCode,
						API.apiResponseMsg = @payResponseMsg
		FROM dbo.bankDepositAPIQueu API (NOLOCK)
		INNER JOIN @controlNoTable CNT ON CNT.controlNo = API.controlNo
		
		EXEC [proc_errorHandler] 0,'Process Failed', @rowId
	END

	IF @flag = 'PAY-SUCCESS'
	BEGIN
		INSERT INTO @controlNoTable(controlNo)
		SELECT ICN= dbo.encryptdb(p.value('(text())[01]', 'VARCHAR(100)')) FROM @XML2.nodes('/root/row') n1(p)

		UPDATE API SET API.txnStatus = 'paid',
						API.confirmedBy = @user,
						API.confirmedDate = GETDATE(),
						API.apiResponseCode = @payResponseCode,
						API.apiResponseMsg = @payResponseMsg
		FROM dbo.bankDepositAPIQueu API (NOLOCK)
		INNER JOIN @controlNoTable CNT ON CNT.controlNo = API.controlNo

		EXEC [proc_errorHandler] 0,'Process Completed', @rowId
	END
END












GO
