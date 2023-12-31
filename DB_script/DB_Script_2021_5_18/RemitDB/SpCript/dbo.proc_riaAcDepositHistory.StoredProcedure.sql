USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_riaAcDepositHistory]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_riaAcDepositHistory](
	 @flag							VARCHAR(20) = NULL
	,@rowid							BIGINT		= NULL
	,@PIN							VARCHAR(50)	= NULL		
	,@xml							XML			= NULL	
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
	,@remarks						VARCHAR(200) = NULL	
)
AS 
SET XACT_ABORT ON
SET NOCOUNT ON
BEGIN TRY  

	DECLARE
		 @tranId							BIGINT
		,@beneficiaryName					VARCHAR(300)
		,@beneficiaryFirstName				VARCHAR(50)
		,@beneficiaryLastName				VARCHAR(50)
		,@beneficiaryLastName2				VARCHAR(50)
		,@beneficiaryCountry				VARCHAR(50)
		,@beneficiaryCity					VARCHAR(50)
		,@beneficiaryAddress				VARCHAR(300)
		,@beneficiaryBankAccountNumber		VARCHAR(300)
		,@beneficiaryBankBranchCode			VARCHAR(300)
		,@beneficiaryBankBranchName			VARCHAR(300)
		,@beneficiaryBankCode				VARCHAR(300)
		,@beneficiaryBankCode2				VARCHAR(300)
		,@beneficiaryBankName				VARCHAR(300)
		,@beneficiaryIdNo					VARCHAR(300)
		,@beneficiaryPhone					VARCHAR(300)
		
		,@customerName						VARCHAR(300)
		,@customerFirstName					VARCHAR(50)
		,@customerLastName					VARCHAR(50)
		,@customerLastName2					VARCHAR(50)
		,@customerNationality				VARCHAR(300)
		,@customerAddress					VARCHAR(300)
		,@customerIdType					VARCHAR(300)
		,@customerIdNo						VARCHAR(300)
		,@customerIdIssuedDate				VARCHAR(50)
		,@customerIdExpiryDate				VARCHAR(300)
		,@customerDob						VARCHAR(50)
		,@customerPhone						VARCHAR(300)
		,@customerOccupation				VARCHAR(50)
		
		,@destinationAmount					MONEY
		,@destinationCurrency				VARCHAR(300)
		,@payOutMethod						VARCHAR(300)
		,@purpose							VARCHAR(300)
		,@settlementCurrency				VARCHAR(300)
		,@transactionStatus					VARCHAR(300)
		,@recordStatus						VARCHAR(300)
		,@createdDate						VARCHAR(300)
		,@createdBy							VARCHAR(300)	
		
		,@sCountry							VARCHAR(100)
		,@sSuperAgent						INT
		,@sSuperAgentName					VARCHAR(100)
		,@sAgent							INT	 
		,@sAgentName						VARCHAR(100)
		,@sBranch							INT 
		,@sBranchName						VARCHAR(100)
 		
 		,@pCountry							VARCHAR(100)
 		,@pCountryId						INT
 		,@pSuperAgent						INT
		,@pSuperAgentName					VARCHAR(100)
		,@pAgent							INT
		,@pAgentName						VARCHAR(100)
		,@pBranchName						VARCHAR(100)
		,@pAgentComm						MONEY
		,@pAgentCommCurrency				VARCHAR(25)
		,@pSuperAgentComm					MONEY
		,@pSuperAgentCommCurrency			VARCHAR(25)			
		,@pBankName							VARCHAR(100)
		,@pBankBranchName					VARCHAR(100)
		,@sAgentSettRate					VARCHAR(100)
		,@ControlNoModified					VARCHAR(50)	
		,@tAmt								MONEY
		,@sourceOfFund						VARCHAR(50)
			
	IF @flag = 'd'
	BEGIN
		DELETE FROM RIA_AcDepositHistory WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0,'Transaction has been deleted successfully.', @rowId
		RETURN
	END
	IF @flag = 'i'
	BEGIN
		--EXEC proc_riaAcDepositHistory @flag='i' ,@xml=@xml,@user='admin'
		DECLARE @rowInserted VARCHAR(50)
		--DECLARE @xml1 XML =  REPLACE(REPLACE(@xml, '&quot;', '"'), '&quot', '"')
		SELECT t.* INTO #tempRIA
			FROM (
						
				SELECT
				OrderNo						=  p.value('(OrderNo/text())[01]', 'VARCHAR(100)')
				,PIN						=  p.value('(PIN/text())[01]', 'VARCHAR(100)')
				,SendingCorrespSeqID		=  p.value('(SendingCorrespSeqID/text())[01]', 'VARCHAR(100)')
				,PayingCorrespSeqID			=  p.value('(PayingCorrespSeqID/text())[01]', 'VARCHAR(100)')
				,SalesDate					=  p.value('(SalesDate/text())[01]', 'VARCHAR(100)')
				,SalesTime					=  p.value('(SalesTime/text())[01]', 'VARCHAR(100)')
				,CountryFrom				=  p.value('(CountryFrom/text())[01]', 'VARCHAR(100)')
				,CountryTo					=  p.value('(CountryTo/text())[01]', 'VARCHAR(100)')
				,PayingCorrespLocID			=  p.value('(PayingCorrespLocID/text())[01]', 'VARCHAR(100)')
				,SendingCorrespBranchNo		=  p.value('(SendingCorrespBranchNo/text())[01]', 'VARCHAR(100)')
				,BeneQuestion				=  p.value('(BeneQuestion/text())[01]', 'VARCHAR(100)')
				,BeneAnswer					=  p.value('(BeneAnswer/text())[01]', 'VARCHAR(100)')
				,PmtInstructions			=  p.value('(PmtInstructions//text())[01]', 'VARCHAR(100)')
				,BeneficiaryCurrency		=  p.value('(BeneficiaryCurrency/text())[01]', 'VARCHAR(100)')
				,BeneficiaryAmount			=  p.value('(BeneficiaryAmount/text())[01]', 'MONEY')
				,DeliveryMethod				=  p.value('(DeliveryMethod/text())[01]', 'VARCHAR(100)')
				,PaymentCurrency			=  p.value('(PaymentCurrency/text())[01]', 'VARCHAR(100)')
				,PaymentAmount				=  p.value('(PaymentAmount/text())[01]', 'MONEY')
				,CommissionCurrency			=  p.value('(CommissionCurrency/text())[01]', 'VARCHAR(100)')
				,CommissionAmount			=  p.value('(CommissionAmount/text())[01]', 'VARCHAR(100)')
				,CustomerChargeCurrency		=  p.value('(CustomerChargeCurrency/text())[01]', 'VARCHAR(100)')
				,CustomerChargeAmount		=  p.value('(CustomerChargeAmount/text())[01]', 'VARCHAR(100)')
				,BeneID						=  p.value('(BeneID/text())[01]', 'VARCHAR(100)')
				,BeneFirstName				=  p.value('(BeneFirstName/text())[01]', 'VARCHAR(100)')
				,BeneLastName				=  p.value('(BeneLastName/text())[01]', 'VARCHAR(100)')
				,BeneLastName2				=  p.value('(BeneLastName2/text())[01]', 'VARCHAR(100)')
				,BeneAddress				=  p.value('(BeneAddress/text())[01]', 'VARCHAR(100)')
				,BeneCity					=  p.value('(BeneCity/text())[01]', 'VARCHAR(100)')
				,BeneState					=  p.value('(BeneState/text())[01]', 'VARCHAR(100)')
				,BeneZipCode				=  p.value('(BeneZipCode/text())[01]', 'VARCHAR(100)')
				,BeneCountry				=  p.value('(BeneCountry/text())[01]', 'VARCHAR(100)')
				,BenePhoneNo				=  p.value('(BenePhoneNo/text())[01]', 'VARCHAR(100)')
				,BeneMessage				=  p.value('(BeneMessage/text())[01]', 'VARCHAR(100)')
				,CustID						=  p.value('(CustID/text())[01]', 'VARCHAR(100)')
				,CustFirstName				=  p.value('(CustFirstName/text())[01]', 'VARCHAR(100)')
				,CustLastName				=  p.value('(CustLastName/text())[01]', 'VARCHAR(100)')
				,CustLastName2				=  p.value('(CustLastName2/text())[01]', 'VARCHAR(100)')
				,CustCountry				=  p.value('(CustCountry/text())[01]', 'VARCHAR(100)')
				,CustID1Type				=  p.value('(CustID1Type/text())[01]', 'VARCHAR(100)')
				,CustID1No					=  p.value('(CustID1No/text())[01]', 'VARCHAR(100)')
				,CustID1IssuedBy			=  p.value('(CustID1IssuedBy/text())[01]', 'VARCHAR(100)')
				,CustID1IssuedByState		=  p.value('(CustID1IssuedByState/text())[01]', 'VARCHAR(100)')
				,CustID1IssuedByCountry		=  p.value('(CustID1IssuedByCountry/text())[01]', 'VARCHAR(100)')
				,CustID1IssuedDate			=  p.value('(CustID1IssuedDate/text())[01]', 'VARCHAR(100)')
				,CustID1ExpirationDate		=  p.value('(CustID1ExpirationDate/text())[01]', 'VARCHAR(100)')
				,CustID2Type				=  p.value('(CustID2Type/text())[01]', 'VARCHAR(100)')
				,CustID2No					=  p.value('(CustID2No/text())[01]', 'VARCHAR(100)')
				,CustID2IssuedBy			=  p.value('(CustID2IssuedBy/text())[01]', 'VARCHAR(100)')
				,CustID2IssuedByState		=  p.value('(CustID2IssuedByState/text())[01]', 'VARCHAR(100)')
				,CustID2IssuedByCountry		=  p.value('(CustID2IssuedByCountry/text())[01]', 'VARCHAR(100)')
				,CustID2IssuedDate			=  p.value('(CustID2IssuedDate/text())[01]', 'VARCHAR(100)')
				,CustID2ExpirationDate		=  p.value('(CustID2ExpirationDate/text())[01]', 'VARCHAR(100)')
				,CustTaxID					=  p.value('(CustTaxID/text())[01]', 'VARCHAR(100)')
				,CustTaxCountry				=  p.value('(CustTaxCountry/text())[01]', 'VARCHAR(100)')
				,CustCountryOfBirth			=  p.value('(CustCountryOfBirth/text())[01]', 'VARCHAR(100)')
				,CustNationality			=  p.value('(CustNationality/text())[01]', 'VARCHAR(100)')
				,CustDateOfBirth			=  p.value('(CustDateOfBirth/text())[01]', 'VARCHAR(100)')
				,CustOccupation				=  p.value('(CustOccupation/text())[01]', 'VARCHAR(100)')
				,CustSourceOfFunds			=  p.value('(CustSourceOfFunds/text())[01]', 'VARCHAR(100)')
				,CustPaymentMethod			=  p.value('(CustPaymentMethod/text())[01]', 'VARCHAR(100)')
				,TransferReason				=  p.value('(TransferReason/text())[01]', 'VARCHAR(100)')
				,BankName					=  p.value('(BankName/text())[01]', 'VARCHAR(100)')
				,BankAccountNo				=  p.value('(BankAccountNo/text())[01]', 'VARCHAR(100)')
				,BeneIDType					=  p.value('(BeneIDType/text())[01]', 'VARCHAR(100)')
				,BeneIDNo					=  p.value('(BeneIDNo/text())[01]', 'VARCHAR(100)')
				,BeneTaxID					=  p.value('(BeneTaxID/text())[01]', 'VARCHAR(100)')
				,BankCity					=  p.value('(BankCity/text())[01]', 'VARCHAR(100)')
				,BankBranchNo				=  p.value('(BankBranchNo/text())[01]', 'VARCHAR(100)')
				,BankBranchName				=  p.value('(BankBranchName/text())[01]', 'VARCHAR(100)')
				,BankBranchAddress			=  p.value('(BankBranchAddress/text())[01]', 'VARCHAR(100)')
				,BankCode					=  p.value('(BankCode/text())[01]', 'VARCHAR(100)')
				,BankRoutingCode			=  p.value('(BankRoutingCode/text())[01]', 'VARCHAR(100)')
				,BIC_SWIFT					=  p.value('(BIC_SWIFT/text())[01]', 'VARCHAR(100)')
				,UnitaryBankAccountNo		=  p.value('(UnitaryBankAccountNo/text())[01]', 'VARCHAR(100)')
				,Valuetype					=  p.value('(Valuetype/text())[01]', 'VARCHAR(100)')
				FROM @xml.nodes('/Root/RequestResponses/Order') n1(p)
			)t
			LEFT JOIN RIA_AcDepositHistory h WITH(NOLOCK) ON t.PIN = h.PIN AND recordStatus <> 'REJECTED'
			WHERE h.PIN IS NULL
		
		SELECT 
			 @sSuperAgent		= 64210
			,@sSuperAgentName	= 'Ria Money Transfer'
			,@sAgent			= 62202
			,@sAgentName		= 'Ria Money Transfer'
			,@sBranch			= 62204
			,@sBranchName		= 'Ria money transfer'
			,@pSuperAgent		= 1003
			,@pSuperAgentName	= 'International Agents'
				
		BEGIN TRANSACTION	
		
		INSERT RIA_AcDepositDownloadLogs(createdBy, createdDate) 
		SELECT @user, GETDATE()
		
		INSERT INTO RIA_AcDepositHistory (OrderNo,PIN,SendingCorrespSeqID,PayingCorrespSeqID,SalesDate
				,SalesTime,CountryFrom,CountryTo,PayingCorrespLocID,SendingCorrespBranchNo,BeneQuestion,BeneAnswer,PmtInstructions 
				,BeneficiaryCurrency,BeneficiaryAmount,DeliveryMethod,PaymentCurrency,PaymentAmount,CommissionCurrency
				,CommissionAmount,CustomerChargeCurrency,CustomerChargeAmount,BeneID,BeneFirstName,BeneLastName,BeneLastName2
				,BeneAddress,BeneCity,BeneState,BeneZipCode,BeneCountry,BenePhoneNo,BeneMessage,CustID,CustFirstName,CustLastName
				,CustLastName2,CustCountry,CustID1Type,CustID1No,CustID1IssuedBy,CustID1IssuedByState,CustID1IssuedByCountry
				,CustID1IssuedDate,CustID1ExpirationDate,CustID2Type,CustID2No,CustID2IssuedBy,CustID2IssuedByState,CustID2IssuedByCountry
				,CustID2IssuedDate,CustID2ExpirationDate,CustTaxID,CustTaxCountry,CustCountryOfBirth,CustNationality,CustDateOfBirth
				,CustOccupation,CustSourceOfFunds,CustPaymentMethod,TransferReason,BankName,BankAccountNo,BeneIDType,BeneIDNo,BeneTaxID,BankCity,BankBranchNo,BankBranchName
				,BankBranchAddress,BankCode,BankRoutingCode,BIC_SWIFT,UnitaryBankAccountNo,Valuetype,recordStatus,createdDate,createdBy)
				
		SELECT 
				OrderNo,PIN,SendingCorrespSeqID,PayingCorrespSeqID,SalesDate,SalesTime,CountryFrom,CountryTo,PayingCorrespLocID,
				SendingCorrespBranchNo,BeneQuestion,BeneAnswer,PmtInstructions,BeneficiaryCurrency,BeneficiaryAmount,DeliveryMethod,
				PaymentCurrency,PaymentAmount,CommissionCurrency,CommissionAmount,CustomerChargeCurrency,CustomerChargeAmount,BeneID,
				BeneFirstName,BeneLastName,BeneLastName2,BeneAddress,BeneCity,BeneState,BeneZipCode,BeneCountry,BenePhoneNo,BeneMessage,
				CustID,CustFirstName,CustLastName,CustLastName2,CustCountry,CustID1Type,CustID1No,CustID1IssuedBy,CustID1IssuedByState,
				CustID1IssuedByCountry,CustID1IssuedDate,CustID1ExpirationDate,CustID2Type,CustID2No,CustID2IssuedBy,CustID2IssuedByState,
				CustID2IssuedByCountry,CustID2IssuedDate,CustID2ExpirationDate,CustTaxID,CustTaxCountry,CustCountryOfBirth,CustNationality,
				CustDateOfBirth,CustOccupation,CustSourceOfFunds,TransferReason,CustPaymentMethod,BankName,BankAccountNo,BeneIDType,BeneIDNo,BeneTaxID,BankCity,BankBranchNo,
				BankBranchName,BankBranchAddress,BankCode,BankRoutingCode,BIC_SWIFT,UnitaryBankAccountNo,Valuetype,'DRAFT',GETDATE(),@user								
		FROM #tempRIA
		
		SET @rowInserted = @@ROWCOUNT
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		DECLARE @msg VARCHAR(MAX)
		SET @msg = @rowInserted+' transaction(s) downloaded successfully.'
		EXEC proc_errorHandler 0, @msg, @rowInserted
			
		
		SELECT PCOrderNo = ria.rowid, SCOrderNo = ria.OrderNo, NotificationID = ABS(CHECKSUM(NEWID())), OrderStatus = 'RECEIVED' 
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		INNER JOIN #tempRIA tmp ON  ria.PIN=tmp.PIN
				
		RETURN		
	END
	
	IF @flag='up-list'--unpaid list 
		BEGIN
		SELECT 
			 [Control NO] = PIN
			,[TRAN NO] =''
			,[Sending Country]= CASE ISNULL(cm.countryName,'') WHEN '' THEN ria.CountryFrom ELSE cm.countryName END
			,[Sending Agent]='RIA'
			,[Bank Name] = BankName
			,[Branch Name]	= BankBranchName
			,[Receiver Name] = BeneFirstName + ISNULL(' ' + BeneLastName, '') + ISNULL(' ' + BeneLastName2,'') 
			,[Bank A/C NO]	= BankAccountNo
			,[DOT]	= ria.createdDate
			,[Total Amount] = BeneficiaryAmount
			,[Unpaid Days] = DATEDIFF(DAY,ria.createdDate,GETDATE())
			,rowId
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		LEFT JOIN countryMaster cm WITH(NOLOCK)
		ON ria.CountryFrom=cm.countryCode	
		WHERE recordStatus NOT IN ('CANCEL','REJECTED') AND pAgent = @rbankCode
	RETURN
	END	
	
	IF @flag='all-list' -- show all downloaded txn list
	BEGIN	
		DECLARE @sql VARCHAR(MAX)
		
		--SET @sql='
		--SELECT 
		--	 [Control NO]			= dbo.FNADecryptString(rt.controlNo)			
		--	,[Sending Country]		= rt.sCountry
		--	,[Receiving Country]	= rt.pCountry
		--	,[Bank Name]			= rt.pBankName
		--	,[Branch Name]			= rt.pBankBranchName
		--	,[Receiver Name]		= rt.receiverName
		--	,[Bank A/C NO]			= rt.accountNo
		--	,[DOT]					= rt.createdDate
		--	,[Total Amount]			= rt.pAmt
		--	,[Unpaid Days]			= DATEDIFF(DAY,rt.createdDate,GETDATE())
		--	,[Record Status]		= CASE WHEN rt.pBank IS NULL THEN ''UNASSIGNED'' ELSE ''ASSIGNED'' END
		--	,rowId					= ria.rowId		
		--FROM remitTran rt WITH(NOLOCK)
		--INNER JOIN RIA_AcDepositHistory ria WITH(NOLOCK) ON rt.controlNo = ria.PINEncrypted
		--WHERE tranStatus = ''Payment'' AND payStatus = ''Unpaid''
		--'
		
		SET @sql='
		SELECT 
			 [Control NO] = PIN			
			,[Sending Country]= CASE ISNULL(cm.countryName,'''') WHEN '''' THEN ria.CountryFrom ELSE cm.countryName END
			,[Sending Agent]=''RIA''
			,[Bank Name] = BankName
			,[Branch Name]	= BankBranchName
			,[Receiver Name] = BeneFirstName+ ISNULL('' ''+BeneLastName,'''')+ISNULL('' ''+BeneLastName2,'''')
			,[Bank A/C NO]	= BankAccountNo
			,[DOT]	= ria.createdDate
			,[Total Amount] = BeneficiaryAmount
			,[Unpaid Days] = DATEDIFF(DAY,ria.createdDate,GETDATE())
			,[Record Status] = CASE WHEN pAgent IS NULL THEN ''UNASSIGNED'' ELSE ''ASSIGNED'' END
			,rowId			
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		LEFT JOIN countryMaster cm WITH(NOLOCK)
		ON ria.CountryFrom=cm.countryCode
		WHERE recordStatus NOT IN(''CANCEL'',''PAID'',''REJECTED'')		
		'
		
		IF @filterType = 'UA' -- Unassigned 
		SET @sql = @sql + 'AND pAgent IS NULL'
		
		ELSE IF @filterType = 'A' -- Assigned
		SET @sql = @sql + 'AND pAgent IS NOT NULL'
		SET @sql = @sql + ' ORDER BY ria.createdDate DESC'
		PRINT @sql				
		EXEC (@sql)
		
		SELECT TOP 1 createdBy, createdDate FROM RIA_AcDepositDownloadLogs WITH(NOLOCK) ORDER BY rowId DESC
		
		RETURN
	END	
	
	IF @flag = 'ul' -- show unpaid list
		BEGIN
		 SELECT DISTINCT
			 receiveAgentId	= am.agentId
			,[bankName] = am.agentName
		    ,[Txn] = COUNT(*)
		    ,amt = SUM(CAST(BeneficiaryAmount AS MONEY))
		    FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		    INNER JOIN agentMaster am WITH(NOLOCK) ON ria.pAgent = am.agentId
		    WHERE recordStatus NOT IN ('CANCEL','REJECTED') AND pAgent IS NOT NULL
		    GROUP BY am.agentName, am.agentId
		    		    
		SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @thirdPartyAgentId
	END	
	
	IF @flag = 'a' -- select by rowId 
		BEGIN
		SELECT 
			 rowId		
			,[rCountry] = CASE ISNULL(cm1.countryName,'') WHEN '' THEN ria.CountryTo ELSE cm1.countryName END 
			,[rAddress] = BeneAddress
			,[rBankAcNo] = BankAccountNo
			,[rBankBranchCode] = ''
			,[rBankBranchName] = BankBranchName
			,[rBankCode] = BankCode
			,[rBankName] = BankName
			,[rIdType] = BeneIDType
			,[rIdNo] = ISNULL(BeneIDNo, ABS(CHECKSUM(NEWID())))
			,[rName] = BeneFirstName + ISNULL(' ' + BeneLastName, '') + ISNULL(' ' + BeneLastName2,'')  
			,[rContactNo] = BenePhoneNo
			,[sCountry] = CASE ISNULL(cm.countryName,'') WHEN '' THEN ria.CountryFrom ELSE cm.countryName END
			,[sAddress] = ''
			,[sIdValidDate] = CustID2ExpirationDate
			,[sIdNo] = CustID1No
			,[sIdType] = CustID1Type
			,[sName] = CustFirstName + ISNULL(' ' + CustLastName, '') + ISNULL(' ' + CustLastName2,'')  
			,[sNationality] = CustNationality
			,[sContactNo] = ''
			,[rAmount] = BeneficiaryAmount
			,[rCurrency] = BeneficiaryCurrency
			,[controlNo] = PIN
			,paymentMode = 'Bank Deposit'
			,purpose = 'Family Support'
			,settlementCurrency = BeneficiaryCurrency
			,transactionStatus = recordStatus
			,[pBankId] = CAST(pBank AS VARCHAR) + '|' + pBankType
			,[pBranchId] = pBankBranch			
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		
		LEFT JOIN countryMaster cm WITH(NOLOCK)
		ON ria.CountryFrom=cm.countryCode		
		LEFT JOIN countryMaster cm1 WITH(NOLOCK)
		ON ria.CountryTo=cm1.countryCode
		
		WHERE rowId = @rowId
		RETURN
	END	
	IF @flag = 'getpayconfirm' -- select by rowId 
		BEGIN
		SELECT 
			  errorCode			=	0
		     ,msg				=	'Txn Found'
			 ,id				=	Pin
			 ,[PCOrderNo]		=	rowid
			 ,[SCOrderNo]		=	OrderNo
			 ,[NotificationID]	=	rowid
			 ,[OrderStatus]		=	'PAID'
			 ,[StatusDate]		=	CONVERT(VARCHAR(10), GETDATE(), 112)
			 ,[StatusTime]		=	REPLACE(CONVERT (VARCHAR(8),GETDATE(), 108),':','')			 
			 ,[BenIDType]		=	BeneIDType
			 ,[BenIDNo]			=	BeneIDNo
			 ,[BenIDExpDate]	=	NULL--CONVERT(VARCHAR(10), GETDATE(), 112) --'20191005'
			 ,[BenIDIssuedBy]	=	'MY'
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)		
		WHERE rowId = @rowId
		
		RETURN
	END	
	IF @flag = 'select' -- select by control no 
		BEGIN
		SELECT 
			 rowId			
			,[rCountry] = CASE ISNULL(cm1.countryName,'') WHEN '' THEN ria.CountryTo ELSE cm.countryName END 
			,[rAddress] = BeneAddress
			,[rBankAcNo] = BankAccountNo
			,[rBankBranchCode] = ''
			,[rBankBranchName] = BankBranchName
			,[rBankCode] = BankCode
			,[rBankName] = BankName
			,[rIdType] = BeneIDType
			,[rIdNo] = ISNULL(BeneIDNo, ABS(CHECKSUM(NEWID())))
			,[rName] = BeneFirstName + ISNULL(' ' + BeneLastName, '') + ISNULL(' ' + BeneLastName2,'')
			,[rContactNo] = BenePhoneNo
			,[sCountry] = CASE ISNULL(cm.countryName,'') WHEN '' THEN ria.CountryFrom ELSE cm.countryName END
			,[sAddress] = ''
			,[sIdValidDate] = CustID2ExpirationDate
			,[sIdNo] = CustID1No
			,[sIdType] = CustID1Type
			,[sName] = CustFirstName + ISNULL(' ' + CustLastName, '') + ISNULL(' ' + CustLastName2,'') 
			,[sNationality] = CustNationality
			,[sContactNo] = ''
			,[rAmount] = BeneficiaryAmount
			,[rCurrency] = BeneficiaryCurrency
			,[controlNo] = PIN
			,paymentMode = 'Bank Deposit'
			,purpose = 'Family Support'
			,settlementCurrency = BeneficiaryCurrency
			,transactionStatus = recordStatus
			,[pBankId] = CAST(pBank AS VARCHAR) + '|' + pBankType
			,[pBranchId] = pBankBranch		
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		LEFT JOIN countryMaster cm WITH(NOLOCK)
		ON ria.CountryFrom=cm.countryCode		
		LEFT JOIN countryMaster cm1 WITH(NOLOCK)
		ON ria.CountryTo=cm1.countryCode
		WHERE PIN = @PIN
		RETURN
	END
	
	IF @flag = 'payError'
		BEGIN
		UPDATE RIA_AcDepositHistory SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	IF @flag = 'getRejectTxn' -- select by rowId 
		BEGIN
		SELECT 
			  errorCode			=	0
		     ,msg				=	'Txn Found'
			 ,id				=	@rowId
			 ,[PCOrderNo]		=	rowid
			 ,[SCOrderNo]		=	OrderNo
			 ,[NotificationID]	=	rowid
			 ,[OrderStatus]		=	'REJECTED'
			 ,[StatusDate]		=	CONVERT(VARCHAR(10), GETDATE(), 112)
			 ,[StatusTime]		=	REPLACE(CONVERT (VARCHAR(8),GETDATE(), 108),':','')			 
			 ,[Reason]			=	@remarks
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)		
		WHERE rowId = @rowId
		
		RETURN
	END	
	IF @flag = 'rejectTxn'
		BEGIN
				
		UPDATE RIA_AcDepositHistory SET 
			 recordStatus = 'REJECTED'
			,Remarks = @remarks 	
			,rejectedBy = @user
			,rejectedDate = GETDATE()
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Reject txn has been recorded successfully.', @rowId
		RETURN
	END
	
	IF	@flag='updateBank' --Assign Bank
	BEGIN
		SET @pAgent = 13410
		
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
		
		UPDATE RIA_AcDepositHistory SET
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
			 @agentType							INT
	 		
			,@pState							VARCHAR(100)
			,@pDistrict							VARCHAR(100)
			,@pLocation							INT
			,@MapCodeIntBranch					VARCHAR(50)			
		
		 	SELECT 		
			 @sAgent			= 4869
			,@sAgentName		= 'RIA FINANCIAL SERVICES'
			,@sBranch			= 4870
	 		,@sBranchName		= 'RIA FINANCIAL SERVICES - HEAD OFFICE'			
			,@sSuperAgent		= 4641
	 		,@sSuperAgentName	= 'INTERNATIONAL AGENTS'			
			,@pCountry			= 'Nepal'
	 		,@pCountryId		= 151
	 		,@pSuperAgent		= 1002
	 		
			
		SELECT 
			 @sCountry							= dbo.FNAGetCountryName(ria.CountryFrom)
			,@pCountry							= dbo.FNAGetCountryName(ria.CountryTo)
			,@beneficiaryAddress				= BeneAddress
			,@beneficiaryCountry				= dbo.FNAGetCountryName(ria.BeneCountry)
			,@beneficiaryCity					= BeneCity
			,@beneficiaryBankAccountNumber		= BankAccountNo
			,@beneficiaryBankBranchCode			= ''
			,@beneficiaryBankBranchName			= BankBranchName
			,@beneficiaryBankCode				= BankCode
			,@beneficiaryBankName				= BankName
			,@beneficiaryIdNo					= BeneIDNo
			,@beneficiaryName					= BeneFirstName + ISNULL(' ' + BeneLastName, '') + ISNULL(' ' + BeneLastName2,'')
			,@beneficiaryFirstName				= BeneFirstName
			,@beneficiaryLastName				= BeneLastName
			,@beneficiaryLastName2				= BeneLastName2
			,@beneficiaryPhone					= BenePhoneNo
			,@customerAddress					= ''
			,@customerIdIssuedDate				= CustID1IssuedDate
			,@customerIdExpiryDate				= CustID1ExpirationDate
			,@customerIdNo						= CustID1No
			,@customerIdType					= CustID1Type
			,@customerDob						= CustDateOfBirth
			,@customerName						= CustFirstName + ISNULL(' ' + CustLastName,'') + ISNULL(' ' + CustLastName2,'')
			,@customerFirstName					= CustFirstName
			,@customerLastName					= CustLastName
			,@customerLastName2					= CustLastName2
			,@customerNationality				= dbo.FNAGetCountryName(CustNationality)
			,@customerPhone						= ''
			,@customerOccupation				= CustOccupation
			,@destinationAmount					= FLOOR(BeneficiaryAmount)
			,@destinationCurrency				= BeneficiaryCurrency
			,@PIN								= PIN
			,@purpose							= CustPaymentMethod
			,@settlementCurrency				= PaymentCurrency
			,@tAmt								= PaymentAmount
			,@transactionStatus					= recordStatus
			,@recordStatus						= recordStatus
			,@createdDate						= ria.createdDate
			,@createdBy							= ria.createdBy
			,@sourceOfFund						= CustSourceOfFunds
			,@pAgent							= pAgent
			,@pBranch							= pBranch
		FROM RIA_AcDepositHistory ria WITH(NOLOCK)
		WHERE rowId = @rowId
			
		SET @ControlNoModified = dbo.FNAEncryptstring(@PIN)		
		SELECT  
		     @pAgent			= am.agentId
			,@pAgentName		= am.agentName
			,@pBranch			= bm.agentId
			,@pBranchName		= bm.agentName 
			,@pState			= bm.agentState
			,@pDistrict			= bm.agentDistrict
			,@pLocation			= bm.agentLocation
		FROM agentMaster am WITH(NOLOCK)
		LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId AND bm.isHeadOffice = 'Y'
		WHERE am.agentId = @pAgent and isnull(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
			
		IF @pBranch IS NULL
		BEGIN
			SELECT TOP 1
				 @pAgent			= am.agentId
				,@pAgentName		= am.agentName
				,@pBranch			= bm.agentId
				,@pBranchName		= bm.agentName 
				,@pState			= bm.agentState
				,@pDistrict			= bm.agentDistrict
				,@pLocation			= bm.agentLocation
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId
			WHERE am.agentId = @pAgent and isnull(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
		END
                         
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
					,dbo.FNAEncryptString(@PIN)
					,'I'
					,@sAgent
					,@sAgentName
					,@sBranch
					,@sBranchName
					,@extBankId
					,@beneficiaryBankName
					,@extBankBranchId
					,@beneficiaryBankBranchName
					,@beneficiaryBankAccountNumber
					,'1'
										
					SET @tranId = SCOPE_IDENTITY()
					
			INSERT INTO tranSenders	(
				 tranId
				,firstName
				,lastName1
				,lastName2
				,fullName
				,country
				,[address]
				,nativeCountry
				,idType
				,idNumber
				,issuedDate
				,validDate
				,dob
				,homePhone
			)
			SELECT
				 @tranId			
				,@customerFirstName
				,@customerLastName
				,@customerLastName2
				,@customerName
				,@sCountry
				,@customerAddress
				,@customerNationality
				,@customerIdType
				,@customerIdNo
				,CONVERT(DATETIME,@customerIdIssuedDate,103)
				,CONVERT(DATETIME,@customerIdExpiryDate,101)
				,CONVERT(DATETIME,@customerDob,101)
				,@customerPhone					
					
			INSERT INTO tranReceivers (
				 tranId
				,firstName
				,lastName1
				,lastName2
				,fullName
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
				,@beneficiaryFirstName
				,@beneficiaryLastName
				,@beneficiaryLastName2
				,@beneficiaryName
				,@beneficiaryCountry
				,@beneficiaryCity
				,@beneficiaryAddress	
				,@beneficiaryPhone
				,NULL -- rIdType	
				,@beneficiaryIdNo
				,NULL	
				,@beneficiaryIdNo
				
			UPDATE RIA_AcDepositHistory SET recordStatus = 'PAID' WHERE rowId = @rowId
			
		--Update Accounting
			EXEC dbo.proc_payAcDepositAC
				 @flag				= 'payIntl'
				,@user				= @user
				,@tranIds			= @tranId

			--Update Inficare
			EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ControlNoModified
			EXEC proc_INFICARE_sendTxn @flag = 'SI-SA', @controlNoEncrypted = @ControlNoModified
			EXEC proc_INFICARE_payTxn @flag = 'p', @tranIds = @tranId	
			
			SET @PIN = dbo.FNADecryptString(@ControlNoModified)							
										
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			SET @msg = 
				CASE 
					WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
					ELSE 'Transaction paid successfully'
				END
			EXEC [proc_errorHandler] 0, @msg, @PIN	
			RETURN		
	END
	
	IF @flag = 'getPayConfirmBulk'
	BEGIN
		SELECT
		  errorCode			=	0
		 ,msg				=	'Txn Found'
		 ,id				=	rt.id
		 ,[PCOrderNo]		=	rt.id
		 ,[SCOrderNo]		=	rt.voucherNo
		 ,[NotificationID]	=	rt.id
		 ,[OrderStatus]		=	'PAID'
		 ,[StatusDate]		=	CONVERT(VARCHAR(10), rt.paidDate, 112)
		 ,[StatusTime]		=	REPLACE(CONVERT (VARCHAR(8),rt.paidDate, 108),':','')			 
		 ,[BenIDType]		=	tr.idType
		 ,[BenIDNo]			=	tr.idNumber
		 ,[BenIDExpDate]	=	CONVERT(VARCHAR(10), tr.validDate, 112) --NULL
		 ,[BenIDIssuedBy]	=	'MY'
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN payQueue pq WITH(NOLOCK) ON rt.controlNo = pq.controlNo
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id
	END
	IF @flag = 'payBulk'
	BEGIN		
		INSERT INTO payQueueHistory(controlNo,routeId,processId,qStatus,completedAt)
		SELECT pq.controlNo,pq.routeId,pq.processId,pq.qStatus, GETDATE() FROM payQueue pq WITH(NOLOCK)
		INNER JOIN remitTran rt WITH(NOLOCK) ON rt.controlNo = pq.controlNo
		INNER JOIN (
			SELECT
			 PCOrderNo			= p.value('(PCOrderNo/text())[01]', 'VARCHAR(100)')
			,SCOrderNo			= p.value('(SCOrderNo/text())[01]', 'VARCHAR(100)')	
			,PCNotificationID	= p.value('(PCNotificationID/text())[01]', 'VARCHAR(100)')	
			,ProcessDate		= p.value('(ProcessDate/text())[01]', 'VARCHAR(100)')	
			,ProcessTime		= p.value('(ProcessTime/text())[01]', 'VARCHAR(100)')	
			,NotificationCode	= p.value('(NotificationCode/text())[01]', 'VARCHAR(100)')	
			,NotificationDesc	= p.value('(NotificationDesc/text())[01]', 'VARCHAR(100)')			
		FROM @xml.nodes('/Root/Acknowledgements/OrderStatusNoticeAcknowledgement') n(p)
		)X ON X.SCOrderNo = rt.voucherNo
		WHERE X.NotificationCode = '1000'

		DELETE pq FROM payQueue pq
		INNER JOIN remitTran rt WITH(NOLOCK) ON rt.controlNo = pq.controlNo
		INNER JOIN (
			SELECT
			 PCOrderNo			= p.value('(PCOrderNo/text())[01]', 'VARCHAR(100)')
			,SCOrderNo			= p.value('(SCOrderNo/text())[01]', 'VARCHAR(100)')	
			,PCNotificationID	= p.value('(PCNotificationID/text())[01]', 'VARCHAR(100)')	
			,ProcessDate		= p.value('(ProcessDate/text())[01]', 'VARCHAR(100)')	
			,ProcessTime		= p.value('(ProcessTime/text())[01]', 'VARCHAR(100)')	
			,NotificationCode	= p.value('(NotificationCode/text())[01]', 'VARCHAR(100)')	
			,NotificationDesc	= p.value('(NotificationDesc/text())[01]', 'VARCHAR(100)')			
		FROM @xml.nodes('/Root/Acknowledgements/OrderStatusNoticeAcknowledgement') n(p)
		)X ON X.SCOrderNo = rt.voucherNo
		WHERE X.NotificationCode = '1000'		
		
		EXEC [proc_errorHandler] 0, 'Pay Bulk Successfully.', @rowId
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 

	SELECT 1 errorCode, ERROR_MESSAGE()  msg, NULL id
END CATCH



GO
