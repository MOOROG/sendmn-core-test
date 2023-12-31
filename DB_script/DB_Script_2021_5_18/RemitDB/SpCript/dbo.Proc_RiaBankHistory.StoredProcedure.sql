USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_RiaBankHistory]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[Proc_RiaBankHistory]
(
 @flag						VARCHAR(50)
 ,@rowid					BIGINT		= NULL
,@user						VARCHAR(30)	= NULL
,@XML						VARCHAR(MAX)= NULL
,@payResponseCode			VARCHAR(20)	= NULL
,@payResponseMsg			VARCHAR(100)= NULL
,@XML2						XML			= NULL
,@tranIds					VARCHAR(500) = NULL
,@controlNo					VARCHAR(20) = NULL
,@requestMsg				VARCHAR(250) = NULL
)
AS 
BEGIN TRY 
	DECLARE
	     @sCountryId				INT	= NULL
		,@sCountry					VARCHAR(50) = NULL
		,@payoutCurr				VARCHAR(50) = NULL
		,@pCountry					VARCHAR(100)
		,@tranId					BIGINT
		,@tranIdTemp				BIGINT 
		,@pCountryId				INT
		,@pSuperAgent				INT 
		,@pSuperAgentName			VARCHAR(100)
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
		,@message					VARCHAR(255)

	DECLARE @riaAgentId VARCHAR(20)
	SELECT @riaAgentId =am.agentId 
	FROM Vw_GetAgentID vw
	LEFT JOIN agentMaster am  ON vw.agentId = am.parentId
	WHERE SearchText = 'riaAgent'

	

	IF @flag = 'download'
	BEGIN
		
		--SET @XML = '
  -- <DownloadDatail>
  --    <OrderNo>US103548816</OrderNo>
  --    <PIN>12707834169</PIN>
  --    <SendingCorrespSeqID>14999885</SendingCorrespSeqID>
  --    <PayingCorrespSeqID>1354</PayingCorrespSeqID>
  --    <SalesDate>20210516</SalesDate>
  --    <SalesTime>035319</SalesTime>
  --    <CountryFrom>US</CountryFrom>
  --    <CountryTo>MN</CountryTo>
  --    <PayingCorrespLocID>0007</PayingCorrespLocID>
  --    <SendingCorrespBranchNo>EW100</SendingCorrespBranchNo>
  --    <BeneficiaryCurrency>MNT</BeneficiaryCurrency>
  --    <BeneficiaryAmount>2775060.00</BeneficiaryAmount>
  --    <DeliveryMethod>2</DeliveryMethod>
  --    <PaymentCurrency>MNT</PaymentCurrency>
  --    <PaymentAmount>2775060.64</PaymentAmount>
  --    <CommissionCurrency>EUR</CommissionCurrency>
  --    <CommissionAmount>1.50</CommissionAmount>
  --    <CustomerChargeCurrency>USD</CustomerChargeCurrency>
  --    <CustomerChargeAmount>15.00</CustomerChargeAmount>
  --    <BeneID>827159645</BeneID>
  --    <BeneFirstName>boldbaatar</BeneFirstName>
  --    <BeneLastName>dorj</BeneLastName>
  --    <BeneCity>ulaanbaatar</BeneCity>
  --    <BeneState>UB</BeneState>
  --    <BeneCountry>MN</BeneCountry>
  --    <CustID>1829379831</CustID>
  --    <CustFirstName>boldbaatar</CustFirstName>
  --    <CustLastName>dorj</CustLastName>
  --    <CustCountry>US</CustCountry>
  --    <CustDateOfBirth>19650602</CustDateOfBirth>
  --    <BankName>KHAN BANK</BankName>
  --    <BankAccountNo>5429661061</BankAccountNo>
  --    <BankCode>394685</BankCode>
  -- </DownloadDatail>
  -- <DownloadDatail>
  --    <OrderNo>US103550916</OrderNo>
  --    <PIN>12708447181</PIN>
  --    <SendingCorrespSeqID>14999891</SendingCorrespSeqID>
  --    <PayingCorrespSeqID>1355</PayingCorrespSeqID>
  --    <SalesDate>20210516</SalesDate>
  --    <SalesTime>035439</SalesTime>
  --    <CountryFrom>US</CountryFrom>
  --    <CountryTo>MN</CountryTo>
  --    <PayingCorrespLocID>0009</PayingCorrespLocID>
  --    <SendingCorrespBranchNo>EW100</SendingCorrespBranchNo>
  --    <BeneficiaryCurrency>MNT</BeneficiaryCurrency>
  --    <BeneficiaryAmount>693765.50</BeneficiaryAmount>
  --    <DeliveryMethod>2</DeliveryMethod>
  --    <PaymentCurrency>EUR</PaymentCurrency>
  --    <PaymentAmount>693765.03</PaymentAmount>
  --    <CommissionCurrency>MNT</CommissionCurrency>
  --    <CommissionAmount>1.50</CommissionAmount>
  --    <CustomerChargeCurrency>USD</CustomerChargeCurrency>
  --    <CustomerChargeAmount>8.00</CustomerChargeAmount>
  --    <BeneID>736219145</BeneID>
  --    <BeneFirstName>boldbaatar</BeneFirstName>
  --    <BeneLastName>dorj</BeneLastName>
  --    <BeneCity>ulaanbaatar</BeneCity>
  --    <BeneState>UB</BeneState>
  --    <BeneCountry>MN</BeneCountry>
  --    <CustID>1829379831</CustID>
  --    <CustFirstName>boldbaatar</CustFirstName>
  --    <CustLastName>dorj</CustLastName>
  --    <CustCountry>US</CustCountry>
  --    <CustDateOfBirth>19650602</CustDateOfBirth>
  --    <BankName>TRADE AND DEVELOPMENT BANK </BankName>
  --    <BankAccountNo>473014289</BankAccountNo>
  --    <BankCode>394684</BankCode>
  -- </DownloadDatail>
 	--	'


		--test  start
			--SELECT 
			--		PCOrderNo = ria.OrderNo, 
			--		SCOrderNo = ria.OrderNo, 
			--		NotificationID = ABS(CHECKSUM(NEWID())), 
			--		OrderStatus = 'RECEIVED' 
			--	FROM RiaBankHistory ria WITH(NOLOCK)
		 -- return
		--test end
		 DECLARE @XML1		XML, @downloadTokenId VARCHAR(50),@rowInserted VARCHAR(50)

		 DECLARE  @tranCount VARCHAR(20), @CancelCount VARCHAR(20)  ,@sql VARCHAR(MAX),@cancelReason VARCHAR(200)

		set @XML = REPLACE(@XML,'<?xml version="1.0" encoding="utf-16"?>','')
		set @XML = REPLACE(@XML,'<ArrayOfDownloadDatail xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">','')
		set @XML = REPLACE(@XML,'</ArrayOfDownloadDatail>','')
		set @XML = REPLACE(@XML,'xmlns="http://tempuri.org/"','')


		 SET @XML1 = @XML

		 SELECT tmp.* INTO #RiaTemp FROM 
			(						
				SELECT
				OrderNo						=  p.value('(OrderNo/text())[01]', 'VARCHAR(50)')
				,PIN						=  p.value('(PIN/text())[01]', 'VARCHAR(20)')

				,SendingCorrespSeqID		=  p.value('(SendingCorrespSeqID/text())[01]', 'VARCHAR(50)')
				,PayingCorrespSeqID			=  p.value('(PayingCorrespSeqID/text())[01]', 'VARCHAR(50)')
				,SalesDate					=  p.value('(SalesDate/text())[01]', 'VARCHAR(50)')
				,SalesTime					=  p.value('(SalesTime/text())[01]', 'VARCHAR(50)')
				,CountryFrom				=  p.value('(CountryFrom/text())[01]', 'VARCHAR(50)')
				,CountryTo					=  p.value('(CountryTo/text())[01]', 'VARCHAR(50)')

				,PayingCorrespLocID			=  p.value('(PayingCorrespLocID/text())[01]', 'VARCHAR(50)')
				,SendingCorrespBranchNo		=  p.value('(SendingCorrespBranchNo/text())[01]', 'VARCHAR(50)')

				,BeneficiaryCurrency		=  p.value('(BeneficiaryCurrency/text())[01]', 'VARCHAR(50)')
				,BeneficiaryAmount			=  p.value('(BeneficiaryAmount/text())[01]', 'MONEY')

				,DeliveryMethod				=  p.value('(DeliveryMethod/text())[01]', 'VARCHAR(50)')
				,PaymentCurrency			=  p.value('(PaymentCurrency/text())[01]', 'VARCHAR(50)')
				,PaymentAmount				=  p.value('(PaymentAmount/text())[01]', 'MONEY')
				,CommissionCurrency			=  p.value('(CommissionCurrency/text())[01]', 'VARCHAR(50)')
				,CommissionAmount			=  p.value('(CommissionAmount/text())[01]', 'VARCHAR(50)')

				,CustomerChargeCurrency		=  p.value('(CustomerChargeCurrency/text())[01]', 'VARCHAR(50)')
				,CustomerChargeAmount		=  p.value('(CustomerChargeAmount/text())[01]', 'VARCHAR(50)')

				,BeneID						= p.value('(BeneID/text())[01]', 'VARCHAR(50)')
				,BeneFirstName				=  p.value('(BeneFirstName/text())[01]', 'VARCHAR(250)')
				,BeneMiddleName				=  p.value('(BeneMiddleName/text())[01]', 'VARCHAR(250)')
				,BeneLastName				=  p.value('(BeneLastName/text())[01]', 'VARCHAR(250)')
				,BeneLastName2				=  p.value('(BeneLastName2/text())[01]', 'VARCHAR(250)')
				,BeneAddress				=  p.value('(BeneAddress/text())[01]', 'VARCHAR(4000)')
				,BeneCity					=  p.value('(BeneCity/text())[01]', 'VARCHAR(250)')
				,BeneState					=  p.value('(BeneState/text())[01]', 'VARCHAR(50)')
				,BeneZipCode				=  p.value('(BeneZipCode/text())[01]', 'VARCHAR(50)')
				,BeneCountry				=  p.value('(BeneCountry/text())[01]', 'VARCHAR(50)')
				,BenePhoneNo				=  p.value('(BenePhoneNo/text())[01]', 'VARCHAR(50)')
				,BeneMessage				=  p.value('(BeneMessage/text())[01]', 'VARCHAR(4000)')

				,CustID						=  p.value('(CustID/text())[01]', 'VARCHAR(50)')
				,CustFirstName				=  p.value('(CustFirstName/text())[01]', 'VARCHAR(250)')
				,CustMiddleName				=  p.value('(CustMiddleName/text())[01]', 'VARCHAR(250)')
				,CustLastName				=  p.value('(CustLastName/text())[01]', 'VARCHAR(250)')
				,CustLastName2				=  p.value('(CustLastName2/text())[01]', 'VARCHAR(250)')
				,CustCountry				=  p.value('(CustCountry/text())[01]', 'VARCHAR(50)')
				,CustID1Type				=  p.value('(CustID1Type/text())[01]', 'VARCHAR(50)')
				,CustID1No					=  p.value('(CustID1No/text())[01]', 'VARCHAR(50)')
				,CustID1IssuedBy			=  p.value('(CustID1IssuedBy/text())[01]', 'VARCHAR(50)')
				,CustID1IssuedByCountry		=  p.value('(CustID1IssuedByCountry/text())[01]', 'VARCHAR(50)')
				,CustID1IssuedDate			=  p.value('(CustID1IssuedDate/text())[01]', 'VARCHAR(50)')
				,CustID1ExpirationDate		=  p.value('(CustID1ExpirationDate/text())[01]', 'VARCHAR(50)')

				,CustID2Type				=  p.value('(CustID2Type/text())[01]', 'VARCHAR(50)')
				,CustID2No					=  p.value('(CustID2No/text())[01]', 'VARCHAR(50)')
				,CustID2IssuedBy			=  p.value('(CustID2IssuedBy/text())[01]', 'VARCHAR(50)')
				,CustID2IssuedByState		=  p.value('(CustID2IssuedByState/text())[01]', 'VARCHAR(50)')
				,CustID2IssuedByCountry		=  p.value('(CustID2IssuedByCountry/text())[01]', 'VARCHAR(50)')
				,CustID2IssuedDate			=  p.value('(CustID2IssuedDate/text())[01]', 'VARCHAR(50)')
				,CustID2ExpirationDate		=  p.value('(CustID2ExpirationDate/text())[01]', 'VARCHAR(50)')

				,CustCountryOfBirth			=  p.value('(CustCountryOfBirth/text())[01]', 'VARCHAR(50)')
				,CustDateOfBirth			=  p.value('(CustDateOfBirth/text())[01]', 'VARCHAR(50)')
				,CustOccupation				=  p.value('(CustOccupation/text())[01]', 'VARCHAR(50)')
				,CustSourceOfFunds			=  p.value('(CustSourceOfFunds/text())[01]', 'VARCHAR(50)')
				,TransferReason				=  p.value('(TransferReason/text())[01]', 'VARCHAR(1000)')

				,BankName					=  p.value('(BankName/text())[01]', 'VARCHAR(250)')
				,BankAccountType			=  p.value('(BankAccountType/text())[01]', 'VARCHAR(50)') --N
				,BankAccountNo				=  p.value('(BankAccountNo/text())[01]', 'VARCHAR(50)')

				,BeneIDType					=  p.value('(BeneIDType/text())[01]', 'VARCHAR(50)')
				,BeneIDNo					=  p.value('(BeneIDNo/text())[01]', 'VARCHAR(50)')

				,BankCity					=  p.value('(BankCity/text())[01]', 'VARCHAR(50)')
				,BankBranchNo				=  p.value('(BankBranchNo/text())[01]', 'VARCHAR(50)')
				,BankBranchName				=  p.value('(BankBranchName/text())[01]', 'VARCHAR(250)')
				,BankBranchAddress			=  p.value('(BankBranchAddress/text())[01]', 'VARCHAR(250)')
				,BankCode					=  p.value('(BankCode/text())[01]', 'VARCHAR(50)')
				,BankRoutingCode			=  p.value('(BankRoutingCode/text())[01]', 'VARCHAR(50)')
				,MobileWalletAccountNo		=  p.value('(MobileWalletAccountNo/text())[01]', 'VARCHAR(50)')
				FROM @XML1.nodes('/DownloadDatail') n1(p)
			)tmp 
			LEFT JOIN RiaBankHistory(NOLOCK) ht ON tmp.PIN = ht.PIN 
			WHERE ht.PIN IS NULL

		BEGIN TRAN 
			INSERT INTO RiaBankHistory(
				 OrderNo,PIN
				 ,SendingCorrespSeqID,PayingCorrespSeqID
				 ,SalesDate,SalesTime
				 ,CountryFrom,CountryTo
				 ,PayingCorrespLocID,SendingCorrespBranchNo
				,BeneficiaryCurrency,BeneficiaryAmount
				,DeliveryMethod,PaymentCurrency
				,PaymentAmount,CommissionCurrency
				,CommissionAmount,CustomerChargeCurrency
				,CustomerChargeAmount,BeneID
				,BeneFirstName,BeneMiddleName
				,BeneLastName,BeneLastName2
				,BeneAddress,BeneCity
				,BeneState,BeneZipCode
				,BeneCountry,BenePhoneNo
				,BeneMessage
				,CustID,CustFirstName
				,CustMiddleName,CustLastName
				,CustLastName2,CustCountry
				,CustID1Type,CustID1No
				,CustID1IssuedBy,CustID1IssuedByCountry
				,CustID1IssuedDate,CustID1ExpirationDate
				,CustID2Type,CustID2No
				,CustID2IssuedBy,CustID2IssuedByCountry
				,CustID2IssuedDate,CustID2ExpirationDate
				,CustCountryOfBirth,CustDateOfBirth
				,CustOccupation,CustSourceOfFunds
				,TransferReason
				,BankName,BankAccountType
				,BankAccountNo,BeneIDType
				,BeneIDNo,BankCity
				,BankBranchNo,BankBranchName
				,BankBranchAddress,BankCode
				,BankRoutingCode
				,recordStatus,createdDate,createdBy)
			SELECT 	
				OrderNo,PIN
				,SendingCorrespSeqID,PayingCorrespSeqID
				,SalesDate,SalesTime
				,CountryFrom,CountryTo
				,PayingCorrespLocID,SendingCorrespBranchNo
				,BeneficiaryCurrency,BeneficiaryAmount
				,DeliveryMethod,PaymentCurrency
				,PaymentAmount,CommissionCurrency
				,CommissionAmount,CustomerChargeCurrency
				,CustomerChargeAmount,BeneID
				,BeneFirstName,BeneMiddleName
				,BeneLastName,BeneLastName2
				,BeneAddress,BeneCity
				,BeneState,BeneZipCode
				,BeneCountry,BenePhoneNo
				,BeneMessage
				,CustID,CustFirstName
				,CustMiddleName,CustLastName
				,CustLastName2,CustCountry
				,CustID1Type,CustID1No
				,CustID1IssuedBy,CustID1IssuedByCountry
				,CustID1IssuedDate,CustID1ExpirationDate
				,CustID2Type,CustID2No
				,CustID2IssuedBy,CustID2IssuedByCountry
				,CustID2IssuedDate,CustID2ExpirationDate
				,CustCountryOfBirth,CustDateOfBirth
				,CustOccupation,CustSourceOfFunds
				,TransferReason
				,BankName,BankAccountType
				,BankAccountNo,BeneIDType
				,BeneIDNo,BankCity
				,BankBranchNo,BankBranchName
				,BankBranchAddress,BankCode
				,BankRoutingCode
				,'DRAFT',GETDATE(),@user					
			FROM #RiaTemp

			SET @rowInserted = @@ROWCOUNT


			--## 2. Find Sending Agent Details
			SELECT @sAgent = sAgent,@sAgentName = sAgentName,@sBranch = sBranch,@sBranchName = sBranchName
					,@sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName
					,@pCountry = pCountry,@pCountryId = pCountryId
					,@pSuperAgent = pSuperAgent, @pSuperAgentName = pSuperAgentName
			FROM dbo.FNAGetBranchFullDetails(@riaAgentId)

			SET @sCountryId = 133
			SET @sCountry = 'Malaysia'

			SET @payoutCurr = 'MNT'
			set @pCountry = 'Mongolia'

			INSERT INTO remitTran 
				(
					[controlNo]
					,[senderName]
					,[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod] 
					,[cAmt],[pAmt],[tAmt] ,[payoutCurr]
					,[pAgent]
					,[pAgentName]
					,pBranch,pBranchName
					,[receiverName] 
					,[pCountry]
					,pBank
					,pBankName
					,pBankBranch,pBankBranchName
					,[purposeofRemit]
					,[createdDate],[createdDateLocal],[createdBy],[approvedDate],[approvedDateLocal]
					,[approvedBy],[serviceCharge]   
					,sCurrCostRate,pCurrCostRate,agentCrossSettRate,customerRate, accountNo     
						--## hardcoded parameters   
					,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName], sRouteId
					,sourceoffund	
				 )
			SELECT  dbo.FNAEncryptString(PIN)
					,ISNULL(CustFirstName,'') +ISNULL(' '+CustMiddleName,'') +ISNULL(' '+CustLastName,'') + ISNULL(' '+CustLastName2,'')
					,ISNULL(cm.countryName,@sCountry),@sSuperAgent,@sSuperAgentName,'Bank Deposit'
					,PaymentAmount,BeneficiaryAmount,(PaymentAmount-CommissionAmount),@payoutCurr
					,case when P.agentType = '2903' then P.agentId else A.agentId end
					,case when P.agentType = '2903' then P.agentName else A.agentName end
					,A.agentId, A.agentName
					,ISNULL(BeneFirstName,'') +ISNULL(' '+BeneMiddleName,'') +ISNULL(' '+BeneLastName,'') + ISNULL(' '+BeneLastName2,'')
					,@pCountry
					,case when P.agentType = '2903' then P.agentId else A.agentId end
					,case when P.agentType = '2903' then P.agentName else A.agentName end
					,A.agentId, A.agentName
					,TransferReason
					,GETDATE(),GETDATE(),@user,GETDATE(),GETDATE()
					,@user,CommissionAmount
					,1,1,BeneficiaryAmount/ISNULL(PaymentAmount,1),BeneficiaryAmount/ISNULL(PaymentAmount,1),BankAccountNo
					,'Payment', 'Unpaid',PaymentCurrency,dbo.encryptdb(pin),'I',@sAgent,@sAgentName,@sBranch,@sBranchName, 'RIA'
					,CustSourceOfFunds
			FROM #RiaTemp(NOLOCK) tm 
			INNER JOIN agentMaster A (NOLOCK) ON A.agentId = tm.BankCode
			INNER JOIN agentMaster P (nolock) on P.agentId = A.parentId
			left join countryMaster cm on tm.CountryFrom = cm.countryCode

			DECLARE @autoMappedTxns int = @@ROWCOUNT

			ALTER TABLE #RiaTemp ADD tranId BIGINT
			
			UPDATE t  SET T.tranId = R.Id
			FROM #RiaTemp T
			INNER JOIN remitTran R (NOLOCK) ON R.controlNo = dbo.FNAEncryptString(T.PIN)

			INSERT INTO tranSenders	(tranId,firstName,country,[address],idType,idNumber,mobile)
			SELECT	t.tranId
					,ISNULL(CustFirstName,'') +ISNULL(' '+CustMiddleName,'') +ISNULL(' '+CustLastName,'') + ISNULL(' '+CustLastName2,'')
					,@sCountry,'Malaysia',CustID1Type,CustID1No,''
			FROM #RiaTemp T

			INSERT INTO tranReceivers (tranId,firstName,country,city,[address],mobile,accountNo,purposeOfRemit,idType2,idNumber2
			,bankName,branchName,chequeNo)		
			SELECT t.tranId
				,ISNULL(BeneFirstName,'') +ISNULL(' '+BeneMiddleName,'') +ISNULL(' '+BeneLastName,'') + ISNULL(' '+BeneLastName2,'')
				,@pCountry,BeneCity,BeneAddress,BenePhoneNo
				,BankAccountNo,TransferReason,BeneIDType,BeneIDNo
				,BankName,BankBranchName,BankAccountNo
			FROM #RiaTemp T


			INSERT apiBankDepositDownloadLogs(downloadQty, createdBy, createdDate, providerName) 
			SELECT @rowInserted, @user, GETDATE(), 'RIA'

			SELECT @downloadTokenId = COUNT('x') FROM #RiaTemp


			IF @@TRANCOUNT > 0
			BEGIN
				COMMIT TRANSACTION
				DECLARE @msg VARCHAR(MAX)
				SET @msg = @downloadTokenId + ' Txn(s) Downloaded Successfully';

				EXEC proc_errorHandler 0,@msg,@downloadTokenId
				
				SELECT 
					PCOrderNo = ria.OrderNo, 
					SCOrderNo = ria.OrderNo, 
					NotificationID = ABS(CHECKSUM(NEWID())), 
					OrderStatus = 'RECEIVED' 
				FROM RiaBankHistory ria WITH(NOLOCK)
				INNER JOIN #RiaTemp tmp ON  ria.PIN=tmp.PIN
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SET @msg = 'Error while saving the downloaded transaction(s). please try again.'
				EXEC proc_errorHandler 1,@msg,@downloadTokenId
			END

		RETURN		
	END

	IF @flag = 'GetOrderNoByControlNo'
	BEGIN
		SELECT orderno FROM RiaBankHistory(NOLOCK) WHERE Pin = @controlNo
	END

	IF @flag = 'PAY-ERROR'
	BEGIN
		UPDATE dbo.RiaBankHistory SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
			FROM bankDepositAPIQueu API 
		WHERE  provider = 'RIA' AND controlNo = DBO.encryptDb(@controlNo)

		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END

	IF @flag = 'PAY-SUCCESS'
	BEGIN

		UPDATE API SET   API.txnStatus = 'paid',
			API.confirmedBy = @user,
			API.confirmedDate = GETDATE(),
			API.apiResponseCode = @payResponseCode,
			API.apiResponseMsg = @payResponseMsg
		FROM bankDepositAPIQueu API 
		WHERE API.provider = 'RIA' AND  API.controlNo = DBO.encryptDb(@controlNo)

		EXEC [proc_errorHandler] 0,'Process Completed', @rowId
	END

	ELSE IF @flag = 'Ria-Cancel-List'        
	BEGIN   
	  SET @sql ='SELECT         
		  [Control No]       = dbo.FNADecryptString(rt.controlNO)   
		  ,[Tran No]		= rt.id    
		  ,[Sending Country] = rt.sCountry    
		  ,[Sending Agent] = rt.sAgentName    
		  ,[Bank Name]  = rt.pBankName    
		  ,[Branch Name]  = rt.pBankBranchName   
		  ,[Bank A/C No]  = rt.accountNo    
		  ,[Confirm Date]  = rt.approvedDate    
		  ,[Payout Amount] = rt.pAmt    
		  ,[Unpaid Days]  = DATEDIFF(D,rt.approvedDate,GETDATE())      
	  FROM [dbo].remitTran rt WITH(NOLOCK)          
	  INNER JOIN RiaBankHistory ria WITH(NOLOCK) ON rt.controlNo = ria.PIN      
	  WHERE rt.payStatus=''CancelRequest'' and ria.recordStatus = ''cancel'' '       
        
	  print(@sql)        
	  EXEC(@sql)        
	RETURN        
	END    

	IF @flag = 'Sync-Cancel-List' --list of txn to be sync cancelled in ria system
	BEGIN
		 SELECT 
			[Payout Amount]	= rt.pAmt,
			[Tran Id] = id,
			[Control No] = dbo.decryptdb(controlNo),
			[RIA OrderNo] = orderNo ,
			[Sending Country]	= rt.sCountry,
			[Sending Agent]	= rt.sAgentName,
			[Bank Name]		= rt.pBankName,
			[Branch Name]		= rt.pBankBranchName
		FROM RiaBankHistory(NOLOCK) ria 
		INNER JOIN  RemitTran(NOLOCK) rt  ON dbo.encryptdb(ria.Pin) = rt.controlNO 
		WHERE ria.recordStatus = 'Cancel'
	END


	IF @flag = 'DoCancel'
	BEGIN
		SET @XML1 = @XML

		 SELECT t.* INTO #CancelFinal FROM 
		 (
			SELECT
				 PCOrderNo			= p.value('(PCOrderNo/text())[01]', 'VARCHAR(100)')
				,SCOrderNo			= p.value('(SCOrderNo/text())[01]', 'VARCHAR(100)')	
				,NotificationCode	= p.value('(NotificationCode/text())[01]', 'VARCHAR(100)')	
				,NotificationDesc	= p.value('(NotificationDesc/text())[01]', 'VARCHAR(100)')	
			FROM @XML1.nodes('/Root/Acknowledgements/OrderStatusNoticeAcknowledgement') n(p)
			)t 

		
		IF EXISTS(SELECT 'x' FROm #CancelFinal(NOLOCK))
		BEGIN
			BEGIN TRANSACTION
				
				--UPDATE rh SET FinalMessageText = 'Transaction Cancelled In Ria System SuccessFully'
				--FROM RiaHistory(NOLOCK) rh 
				--INNER JOIN #CancelFinal(NOLOCK) tmp ON rh.SCOrderNo = tmp.SCOrderNo
				--WHERE tmp.NotificationCode = '1000' 

				UPDATE  ria set recordStatus = 'cancelled'
				FROM RiaBankHistory(NOLOCK) ria 
				INNER JOIN #CancelFinal(NOLOCK) tmp ON ria.OrderNo = tmp.SCOrderNo
				WHERE ria.recordStatus = 'cancel' AND tmp.NotificationCode = '1000' 


				SET @cancelReason = 'This transaction cancelled in RIA side'

				SELECT @CancelCount =COUNT('x') 
				FROM RemitTran(NOLOCK) rt 
				INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
				INNER JOIN #CancelFinal(NOLOCK) tmp ON ria.OrderNo = tmp.SCOrderNo
				WHERE rt.tranStatus = 'CancelRequest' AND rt.payStatus = 'Unpaid' AND rt.tranType = 'I' 


				UPDATE rt SET
					 tranStatus				= 'Cancel'					--Transaction  Hold
					,cancelRequestBy		= @user
					,cancelRequestDate		= dbo.FNAGetDateInNepalTZ()
					,cancelRequestDateLocal	= dbo.FNAGetDateInNepalTZ()
					,cancelReason			= @cancelReason
				FROM RemitTran(NOLOCK) rt 
				INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
				INNER JOIN #CancelFinal(NOLOCK) tmp ON ria.OrderNo = tmp.SCOrderNo
				WHERE rt.tranStatus = 'CancelRequest' AND rt.payStatus = 'Unpaid' AND rt.tranType = 'I' 
				
				

				SELECT @message = 'Transaction requested for Cancel. Reason : ''' + @cancelReason + ''''
	
				INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				SELECT rt.Id,@cancelReason,@user,GETDATE(),'Cancel Approved'
				FROM RemitTran(NOLOCK) rt 
				INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
				INNER JOIN #CancelFinal(NOLOCK) tmp ON ria.OrderNo = tmp.SCOrderNo
				WHERE rt.tranStatus = 'CancelRequest' AND rt.payStatus = 'Unpaid' AND rt.tranType = 'I' 

				COMMIT TRANSACTION
					SET @message = @CancelCount + ' Transaction(s) cancelled successfully'
					EXEC proc_errorHandler 0, @message, NULL
				RETURN

				SET @message = 'No transactions found for cancellation process'
				EXEC proc_errorHandler 0, @message, NULL
		END
	END

	IF @flag = 'GET_Ria_Sync_List'	--GET LIST TO SYNC AS PAID WITH Ria
	BEGIN
		IF OBJECT_ID('tempdb..#tempBankDeposit') IS NOT NULL
			DROP TABLE #tempBankDeposit

		SELECT TOP 100
			 errorCode			=	0
			,msg				=	'Txn Found'
			,rowId				=	b.rowId
			,[PCOrderNo]		=	ria.OrderNo
			,[SCOrderNo]		=	ria.OrderNo
			,[NotificationID]	=	rt.id
			,[OrderStatus]		=	'PAID'
			,controlNo		=dbo.decryptDb(rt.controlNo)
		INTO #tempBankDeposit
		FROM bankDepositAPIQueu b 
		inner join remitTran(nolock) rt ON b.controlNo = rt.controlNo
		inner join RiaBankHistory(nolock) ria on rt.controlNo = dbo.encryptdb(ria.PIN)
		WHERE ISNULL(b.txnStatus, 'payError') in ('payError','readytopay')
		AND b.provider = 'RIA' 
		and rt.transtatus = 'paid'
		and rt.paystatus = 'paid'
				
		SELECT * FROM #tempBankDeposit

		UPDATE b SET b.txnStatus = 'readyToPay'
		FROM bankDepositAPIQueu b 
		INNER JOIN #tempBankDeposit t ON t.rowId = b.rowId
	END

	IF @flag = 'CancelTxnData'	--GET LIST TO Cancel In Ria
	BEGIN
		--IF NOT EXISTS(SELECT 'x' FROM RemitTran(NOLOCK) rt 
		--INNER JOIN RiaBankHistory(NOLOCK) ria on rt.controlNo = dbo.encryptdb(ria.PIN)
		--WHERE rt.controlNo = dbo.encryptdb(@controlNo))
		--BEGIN
		--	SELECT errorCode = '1', errorMsg = 'Transaction Not Found'
		--RETURN
		--END
		
		--IF NOT EXISTS(SELECT 'x' FROM RemitTran(NOLOCK) rt WHERE rt.controlNo = dbo.encryptdb(@controlNo) and transtatus = 'Payment' and payStatus ='Post')
		--BEGIN
		--	SELECT errorCode = '1', errorMsg = 'Transaction is not in authorised mode'
		--RETURN
		--END 

		SELECT 
			 errorCode			=	0
			,errorMsg			=	'Success'
			,[PCOrderNo]		=	ria.OrderNo
			,[SCOrderNo]		=	ria.OrderNo
			,[NotificationID]	=	rt.id
			,[OrderStatus]		=	'CANCELED'
			,controlNo			=  dbo.decryptDb(rt.controlNo)
		FROM remitTran(nolock) rt
		INNER JOIN RiaBankHistory(nolock) ria on rt.controlNo = dbo.encryptdb(ria.PIN)
		WHERE rt.controlNo = dbo.encryptdb(@controlNo)
	END

	IF @flag = 'cancelConfirm'
	BEGIN
		BEGIN TRANSACTION
				 
		SET @cancelReason = @payResponseMsg
		SELECT @message = 'Transaction requested for Cancel. Reason : ''' + @cancelReason + ''''
	
		INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,createdBy,createdDate,tranStatus)
		SELECT rt.Id,rt.controlNo,@cancelReason,'CancelRequest',@user,GETDATE(),lockStatus
		FROM RemitTran(NOLOCK) rt 
		INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
		WHERE rt.controlNo = dbo.encryptdb(@controlNo)

		
		UPDATE  ria set recordStatus = 'cancelled'
		FROM RemitTran(NOLOCK) rt 
		INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
		WHERE ria.recordStatus = 'cancel' AND rt.controlNo = dbo.encryptdb(@controlNo)

		SET @cancelReason = @payResponseMsg

		UPDATE rt SET
				tranStatus				= 'Cancel'					--Transaction  Hold
			,payStatus					= 'unpaid'
			,cancelRequestBy		= @user
			,cancelRequestDate		= dbo.FNAGetDateInNepalTZ()
			,cancelRequestDateLocal	= dbo.FNAGetDateInNepalTZ()
			,cancelReason			= @cancelReason
		FROM RemitTran(NOLOCK) rt 
		INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
		WHERE  rt.controlNo =  dbo.encryptdb(@controlNo)
				
		SELECT @message = 'Transaction requested for Cancel. Reason : ''' + @cancelReason + ''''
	
		INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
		SELECT rt.Id,@cancelReason,@user,GETDATE(),'Cancel Approved'
		FROM RemitTran(NOLOCK) rt 
		INNER JOIN RiaBankHistory(NOLOCK) ria ON rt.controlNo = dbo.encryptdb(ria.PIN)
		WHERE rt.controlNo =  dbo.encryptdb(@controlNo)

		COMMIT TRANSACTION
			SET @message = 'Transaction(s) cancelled successfully'
			EXEC proc_errorHandler 0, @message, NULL
		RETURN
	END
END TRY 

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN
	
	SELECT '1' ErrorCode, ERROR_MESSAGE() Msg, NULL Id
END CATCH

GO
