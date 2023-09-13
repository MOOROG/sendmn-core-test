SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC Proc_RiaCashHistory
(
 @flag						VARCHAR(50)
,@user						VARCHAR(50) = NULL		
,@rowId						BIGINT		= NULL
,@pBranch					VARCHAR(20) = NULL
,@pAgent					VARCHAR(100)= NULL
,@pAgentName				VARCHAR(100)= NULL
,@pBranchName				VARCHAR(255)= NULL
,@agentName					VARCHAR(255)= NULL
,@status					VARCHAR(50)	= NULL
,@payTokenId				VARCHAR(100)= NULL
,@refNo						VARCHAR(100)	= NULL
,@senderName				VARCHAR(100)	= NULL
,@benefName					VARCHAR(100)	= NULL
,@pAmount					MONEY = NULL
,@benefMobile				VARCHAR(30)= NULL
,@pCurrency					VARCHAR(10)= NULL
,@senderAddress				VARCHAR(100)= NULL
,@benefAddress				VARCHAR(100)= NULL
,@senderMobile				VARCHAR(30)= NULL


,@transRefID			VARCHAR(100)	= NULL -- Pay Transaction Check
,@orderFound			VARCHAR(20)		= NULL
,@pIN					VARCHAR(20)		= NULL
,@orderNo				VARCHAR(20)		= NULL
,@seqIDRA				VARCHAR(100)	= NULL	
,@orderDate				DATETIME		= NULL	

,@custNameFirst			VARCHAR(100)	= NULL
,@custNameMiddle		VARCHAR(100)	= NULL
,@custNameLast1			VARCHAR(100)	= NULL
,@custNameLast2			VARCHAR(100)	= NULL
,@custAddress			VARCHAR(100)	= NULL
,@custCity				VARCHAR(100)	= NULL
,@custState				VARCHAR(100)	= NULL
,@custCountry			VARCHAR(100)	= NULL
,@custZip				VARCHAR(100)	= NULL
,@custTelNo				VARCHAR(100)	= NULL

,@CustAmount			MONEY 			= NULL
,@Rate					MONEY			= NULL
,@CustCurrency			VARCHAR(10)		= NULL 
,@PCRate				MONEY			= NULL

,@beneNameFirst			VARCHAR(100)	= NULL
,@beneNameMiddle		VARCHAR(100)	= NULL
,@beneNameLast1			VARCHAR(100)	= NULL
,@beneNameLast2			VARCHAR(100)	= NULL
,@beneAddress			VARCHAR(100)	= NULL
,@beneCity				VARCHAR(100)	= NULL
,@beneState				VARCHAR(100)	= NULL
,@beneCountry			VARCHAR(100)	= NULL
,@beneZip				VARCHAR(100)	= NULL
,@beneTelNo				VARCHAR(100)	= NULL
,@beneAmount			MONEY			= NULL
,@beneCurrency			VARCHAR(50)     = NULL

,@responseDateTimeUTC	VARCHAR(50)		= NULL	
,@CountryFrom			VARCHAR(20)		= NULL  --Pay Transaction Check

,@rIdType					VARCHAR(30)	= NULL-- readyToPay Start
,@rIdNumber					VARCHAR(30)	= NULL 
,@rIdPlaceOfIssue			VARCHAR(50)	= NULL 
,@rIssuedDate				DATETIME	= NULL 
,@rValidDate				DATETIME	= NULL 
,@rDob						DATETIME	= NULL 
,@rContactNo				VARCHAR(50)	= NULL 
,@rbankName					VARCHAR(50)	= NULL 
,@rbankBranch				VARCHAR(100)= NULL 
,@rcheque					VARCHAR(50)	= NULL 
,@rAccountNo				VARCHAR(50)	= NULL 
,@relationType				VARCHAR(50)	= NULL 
,@relationship				VARCHAR(100)= NULL 
,@relativeName				VARCHAR(100)= NULL 
,@topupMobileNo				varchar(50)	= NULL 
,@purpose					VARCHAR(100)= NULL

,@rOccupation				VARCHAR(100)	= NULL
,@customerId				VARCHAR(30)		= NULL
,@sessionId					VARCHAR(100)	= NULL
,@sendAgent					VARCHAR(100)	= NULL
,@RequestFrom				VARCHAR(20)		= NULL
,@password					VARCHAR(100)	= NULL
,@complianceQuestion		NVARCHAR(MAX)	= NULL 
,@rNativeCountry			VARCHAR(100)	= NULL
,@rAddress					VARCHAR(100)	= NULL
,@rCity						VARCHAR(100)	= NULL
,@remarks					VARCHAR(500)	= NULL
-- readyToPay End

,@sCountry					varchar(20)	= NULL-- system ma chahi rakheko xaina
,@payConfirmationNo			varchar(20)	= NULL

,@ConfirmationId			varchar(50) = NULL-- PayConfirmtion 
,@payResponseCode			varchar(50)	= NULL
,@payResponseMsg			varchar(255)= NULL
,@serviceCharge				VARCHAR(50)	= NULL
,@PCCommissionAmount		MONEY		= NULL
,@sBranchMapCOdeInt			varchar(20)	= NULL-- PayConfirmtion 

,@provider					VARCHAR(100)= NULL	--Inernal Purpose start
,@sortBy					VARCHAR(50)	= NULL
,@sortOrder					VARCHAR(5)	= NULL
,@pageSize					INT			= NULL
,@pageNumber				INT			= NULL	-- Inernal Purpose END

,@pCurrCostRate				MONEY			= NULL
,@sCurrCostRate				MONEY			= NULL
,@agentCrossSettRate		MONEY			= NULL
)
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	DECLARE @refNoEnc VARCHAR(100) = dbo.FNAEncryptString(@pIN) 


	IF @flag = 'i' 
	BEGIN
		IF @beneCurrency<>'MNT'
		BEGIN
		    SELECT ErrorCode=1, Mdg='Receiving Currency Can not be '+@beneCurrency + '. It must be in MNT',Id= @rowId
			RETURN
		END
		IF @RequestFrom = 'mobile'
			SET @pBranch =(SELECT agentId FROM Vw_GetAgentID WHERE SearchText = 'PayTxnFromMobile')-- '394420'  --clearly this is pay from wallet user which is recorded under this payoutBranch..

		IF EXISTS ( SELECT 'x' FROM RiaCashHistory (NOLOCK) WHERE  pin= @refNoEnc)
		BEGIN
			UPDATE RiaCashHistory SET recordStatus = 'EXPIRED'  WHERE pin = @refNoEnc AND recordStatus <> 'READYTOPAY'
		END

		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
			INSERT INTO RiaCashHistory (
			 transRefID
			,orderFound  
			,pin
			,orderNo  
			,seqIDRA  
			,orderDate  

			,custNameFirst  
			,custNameMiddle
			,custNameLast1  
			,custNameLast2  
			,custAddress  
			,custCity  
			,custState  
			,custCountry  
			,custZip  
			,custTelNo  

			,CustAmount		
			,Rate					
			,CustCurrency		
			,PCRate				

			,beneNameFirst  
			,beneNameMiddle
			,beneNameLast1  
			,beneNameLast2  
			,beneAddress  
			,beneCity  
			,beneState  
			,beneCountry  
			,beneZip  
			,beneTelNo  
			,beneAmount  
		    ,beneCurrency

			,responseDateTimeUTC 
			,CountryFrom
			
			,recordStatus	
			,createdDate	
			,createdBy	
			,sendingAgent
			,RequestFrom
			
			)
		SELECT
			 @transRefID
			,@orderFound  
			,@refNoEnc
			,@orderNo  
			,@seqIDRA  
			,CONVERT(datetime, @orderDate, 102)  

			,@custNameFirst  
			,@custNameMiddle
			,@custNameLast1  
			,@custNameLast2  
			,@custAddress  
			,@custCity  
			,@custState  
			,@custCountry  
			,@custZip  
			,@custTelNo  

			,@CustAmount		
			,@Rate					
			,@CustCurrency		
			,@PCRate				

			,@beneNameFirst  
			,@beneNameMiddle
			,@beneNameLast1  
			,@beneNameLast2  
			,@beneAddress  
			,@beneCity  
			,@beneState  
			,@beneCountry  
			,@beneZip  
			,@beneTelNo  
			,@beneAmount  
			,@beneCurrency

			,@responseDateTimeUTC  		
			,@CountryFrom

			,'DRAFT'	
			,GETDATE()
			,@user
			,@sendAgent
			,@RequestFrom

		SET @rowId = SCOPE_IDENTITY()
		SELECT 	@benefName = ISNULL(@beneNameFirst,'') +ISNULL(' '+@beneNameMiddle,'') +ISNULL(' '+@beneNameLast1,'') + ISNULL(' '+@beneNameLast2,'')	
		SELECT ErrorCode=0, Mdg='Transaction Has Been Saved Successfully',Id= @rowId,Extra='',Extra2=@benefName
		RETURN
	END

	ELSE IF @Flag = 'readyToPay'
	BEGIN
		
		IF @RequestFrom = 'mobile'
			SET @pBranch = (SELECT agentId FROM Vw_GetAgentID WHERE SearchText = 'PayTxnFromMobile')

		IF @RequestFrom = 'mobile'
		BEGIN
			IF NOT EXISTS(SELECT * FROM CUSTOMERMASTER (NOLOCK) WHERE USERNAME = @user AND CUSTOMERPASSWORD = DBO.FNAENCRYPTSTRING(@password))
			BEGIN 
				SELECT '1' errorCode, 'Provided Credentials Wrong' msg, @sendAgent id
				RETURN;
		   END 
		END
		ELSE
		BEGIN
		   IF NOT EXISTS( SELECT 'x' From applicationusers where userName = @user)
		   BEGIN 
				SELECT '1' errorCode, 'Provided Credentials Wrong' msg, @sendAgent id
				RETURN;
		   END 
		END

		IF (@sessionId IS NULL OR @sessionId = '')
		BEGIN
			SELECT '1' Code,'SessionId Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF (@pIN IS NULL OR @pIN = '')
		BEGIN
			SELECT '1' Code,'ControlNo Number Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF @rIdType = '' OR @rIdType IS NULL 
		BEGIN
			SELECT '1' Code,'rIdType Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF @rIdNumber = '' OR @rIdNumber IS NULL 
		BEGIN
			SELECT '1' Code,'rIdNumber Is Mandatory' Message , NULL Id
			RETURN;
		END
		
		IF @rContactNo = '' OR @rContactNo IS NULL
		BEGIN
			SELECT '1' Code,'rContactNo Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF ISDATE(@rIssuedDate) = 0 AND @rIssuedDate IS NOT NULL
		BEGIN
			SELECT '1' Code,'rIssued Date   Formate Is Wrong!' Message , NULL Id
			RETURN;
		END

		IF @rIdPlaceOfIssue = '' AND @rIdPlaceOfIssue IS NOT NULL
		BEGIN
			SELECT '1' Code,'rIdPlaceOfIssue Is Mandatory!' Message , NULL Id
			RETURN;
		END

		IF @rOccupation = '' AND @rOccupation IS NOT NULL
		BEGIN
			SELECT '1' Code,'occupation Is Mandatory!' Message , NULL Id
			RETURN;
		END

		IF @payTokenId  = '' AND @payTokenId  IS NOT NULL
		BEGIN
			SELECT '1' Code,'ReceivingTokenId Is Mandatory!' Message , NULL Id
			RETURN;
		END
		
	   SELECT TOP 1 @rowId = rowId,@sendAgent = sendingAgent from RiaCashHistory WHERE Pin = @refNoEnc ORDER by rowId desc
		
		UPDATE dbo.RiaCashHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = isnull(@pBranch, pBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber 
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,benefMobile	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose
			,rIssueDate		 = @rIssuedDate				
		WHERE rowId = @rowId
		
		SELECT  '0' errorCode, 'Ready to pay has been recorded successfully.' msg, @sendAgent id 
		RETURN
	END

	ELSE IF @flag = 'payError'
	BEGIN
		UPDATE RiaCashHistory SET 
		payResponseCode = @payResponseCode
		,payResponseMsg	= @payResponseMsg	
		,recordStatus 	= 'PAYERROR'	
		WHERE rowId = @rowId

		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END

	ELSE IF @flag IN ('pay','restore')
	BEGIN
		IF NOT EXISTS (SELECT 'x' FROM RiaCashHistory WITH(NOLOCK) WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') AND rowid = @rowid)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END

		IF @RequestFrom = 'mobile'
			SET @pBranch = (SELECT agentId FROM Vw_GetAgentID WHERE SearchText = 'PayTxnFromMobile')


		IF @RequestFrom = 'mobile' and @customerId IS NULL
			SELECT @customerId = customerId FROM customerMaster (NOLOCK) WHERE username = @user

		IF @customerId IS NULL AND @RequestFrom = 'mobile'
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid customer!', @rowid
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
			,@sAgentMapCode				INT = 1075
	 		,@sBranchMapCode			INT = @sBranchMapCOdeInt
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL
			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
			,@tAmt						MONEY
			,@beneIdNo					INT
			,@customerRate				MONEY
			,@payoutCurr				VARCHAR(50)
			,@collCurr					VARCHAR(50)			 		
			,@MapCodeIntBranch			VARCHAR(50) 
			,@companyId					INT = 16
			,@ControlNoModified			VARCHAR(50)
			,@controlNo					VARCHAR(50)
			,@sCountryId				INT
			,@pCountryId				INT
			,@recordStatus				VARCHAR(30)
			,@senderIdType				VARCHAR(30)
			,@bankName					VARCHAR(100)
			,@senderIdNo				VARCHAR(15)
			,@rCurrency					VARCHAR(30)

			SELECT
			 @refNo						= pin

			,@benefName					= ISNULL(rm.beneNameFirst,'') +ISNULL(' '+rm.beneNameMiddle,'') +ISNULL(' '+rm.beneNameLast1,'') + ISNULL(' '+rm.beneNameLast2,'')	
			,@benefMobile				= rm.rContactNo 
			,@benefAddress				= rm.rAddress

			,@senderName				= ISNULL(rm.custNameFirst,'') +ISNULL(' '+rm.custNameMiddle,'') +ISNULL(' '+rm.custNameLast1,'') + ISNULL(' '+rm.custNameLast2,'')
			,@senderAddress 			= rm.custAddress
			,@senderMobile				= rm.custTelNo 
		
			,@pCurrency					= 'MNT'
			,@pAmount					= rm.beneAmount
			,@tAmt						= rm.CustAmount

			,@recordStatus				= rm.recordStatus

			,@rIdType					= rm.rIdType
			,@rIdNumber					= rm.rIdNumber
			,@rValidDate				= rm.rValidDate
			,@rIssuedDate				= rm.rIssueDate
			,@rDob						= rm.rDob
			,@rOccupation				= rm.rOccupation
			,@rNativeCountry			= rm.nativeCountry

			,@pBranch					= isnull(@pBranch,rm.pBranch)
			,@rIdPlaceOfIssue			= rm.rIdPlaceOfIssue
			,@relationType				= rm.relationType
			,@relativeName				= rm.relativeName
			,@rbankName					= rm.rBank
			,@rbankBranch				= rm.rBankBranch
			,@rcheque					= rm.rChequeNo
			,@rAccountNo				= rm.rAccountNo
			,@purpose					= rm.purposeOfRemit

			,@relationship				= rm.relWithSender
			,@pCurrCostRate				= rm.PCRate
			,@sCurrCostRate				= rm.sCurrCostRate
			,@collCurr					= ISNULL(rm.CustCurrency,'MYR')
			,@customerRate				= ISNULL(rm.Rate,1)
			,@rCity						= rm.rCity
		FROM RiaCashHistory (NOLOCK) rm
		LEFT JOIN staticDataValue sv WITH(NOLOCK) ON rm.purpose = sv.valueId	
		LEFT JOIN countryMaster(NOLOCK) cm ON rm.custCountry = cm.countryCode
		WHERE  rm.rowId = @rowId

		SET @ControlNoModified = @refNo
		
		SET  @sCountryId = '133'
		SET  @sCountry = 'Malaysia'

	--## Check if controlno exist in remittran. 		
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified)
		BEGIN
			DECLARE @msg VARCHAR(100)
			SELECT  @agentName = sAgentName ,@status = payStatus	
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
		
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent

	
		--## 1. Find Sending Agent Details

		SELECT @sendAgent = agentId from agentMaster where parentId = @sendAgent

		SELECT @sAgent = sAgent,@sAgentName = sAgentName,@sBranch = sBranch,@sBranchName = sBranchName
				,@sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName
				,@pCountry = pCountry,@pCountryId = pCountryId
		FROM dbo.FNAGetBranchFullDetails(@sendAgent)  --NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
		

		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 

		DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		--Get collection currency
		--SELECT @collCurr = cm.currencyCode FROM dbo.countryCurrency cc (NOLOCK)
		--INNER JOIN dbo.CurrencyMaster cm (NOLOCK) ON cm.currencyId = cc.currencyId
		--WHERE cc.countryId = @sCountryId

		SET @payoutMethod = 'Cash Payment'
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'MNT'

		SET @ServiceCharge = (ISNULL(@PCCommissionAmount,0))

		SET @cAmt = @tAmt + @ServiceCharge
		
		SET @ServiceCharge = (ISNULL(@ServiceCharge,0) * @customerRate)  --Converting Charge in MNT

		DECLARE @tranType CHAR(1) = 'I'
		IF @RequestFrom = 'mobile'
			SET @tranType = 'M'

		BEGIN TRANSACTION
		BEGIN
			INSERT INTO remitTran (	 
			[controlNo],[senderName],[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod]	,[cAmt],[pAmt]				
			,[tAmt],[customerRate],[pAgentComm]	,[payoutCurr],[pAgent],[pAgentName]	,[pSuperAgent],[pSuperAgentName]
			,[receiverName]	,[pCountry],[pBranch],[pBranchName]	,[pState],[pDistrict],[pLocation],[pbankName],[purposeofRemit]
			,[pMessage]	,[pBankBranch],[sAgentSettRate]	,[createdDate],[createdDateLocal],[createdBy],[approvedDate]				
			,[approvedDateLocal],[approvedBy],[paidBy],[paidDate]	,[paidDateLocal],[serviceCharge]			
			,sCurrCostRate,pCurrCostRate,agentCrossSettRate,sCurrHoMargin,sCurrAgentMargin							
			--## hardcoded parameters			
			,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName], sRouteId				
					)
			SELECT
			@ControlNoModified,@senderName,@sCountry,@sSuperAgent,@sSuperAgentName,'Cash Payment',@cAmt,@Pamount
			,@tAmt,@customerRate,@pAgentComm,@pCurrency,@pAgent,@pAgentName,@pSuperAgent,@pSuperAgentName 
			,@benefName	,@pCountry,@pBranch,@pBranchName,@pState,@pDistrict,@pLocation,@bankName,@purpose
			,@remarks,@pBankBranch,@SagentsettRate,dbo.FNAGetDateInNepalTZ() ,GETDATE(),@user,dbo.FNAGetDateInNepalTZ()
			,GETDATE(),@user,@user,dbo.FNAGetDateInNepalTZ(),GETDATE(),@ServiceCharge
			,@sCurrCostRate,@pCurrCostRate,@agentCrossSettRate,0,0
			--## HardCoded Parameters
			,'Paid','Paid',@collCurr,@refNo,@tranType,@sAgent,@sAgentName,@sBranch,@sBranchName, 'RIA'
					
				SET @tranId = SCOPE_IDENTITY()

				--## Inserting Data in tranSenders table
				INSERT INTO tranSenders	(
					 tranId
					,firstName
					,country
					,[address]
					,idType
					,idNumber
					,mobile
					,customerId
					)
				SELECT
					 @tranId		
					,@senderName
					,@sCountry	
					,@senderAddress
					,@senderIdType	
					,@senderIdNo
					,@senderMobile
					,@customerId
				
				--## Inserting Data in tranReceivers table
				INSERT INTO tranReceivers (
						tranId
						,customerId
					,firstName
					,country
					,city
					,[address]
					,mobile
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
					,relWithSender
					,purposeOfRemit
					,issuedDate2
					,validDate2
					)		
				SELECT 
					@tranId	
					,@customerId		
					,@benefName
					,@pCountry
					,@benefAddress
					,@benefAddress	
					,@benefMobile
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
					,@relationship
					,@purpose
					,@rIssuedDate
					,@rValidDate

			--## Updating Data in globalBankPayHistory table by paid status
			UPDATE RiaCashHistory SET 
				 recordStatus		= 'PAID'
				,tranPayProcess		= CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode	= @payResponseCode
				,payResponseMsg		= @payResponseMsg
				,ConfirmationId		= @payConfirmationNo
				,PCCommissionAmount	= ISNULL(@PCCommissionAmount,0)
				,paidDate			= GETDATE()
				,paidBy				= @user			
			WHERE rowId = @rowId

			IF ISNULL(@complianceQuestion, '') <> ''
			BEGIN
				DECLARE @XMLDATA XML;

				SET @XMLDATA = CONVERT(XML, REPLACE(@complianceQuestion,'&','&amp;'), 2) 

				SELECT  answer = p.value('@answer', 'varchar(150)') ,
						qType = p.value('@qType', 'varchar(500)'),
						qId = p.value('@qId', 'varchar(500)')
				INTO #TRANSACTION_COMPLIANCE_QUESTION
				FROM @XMLDATA.nodes('/root/row') AS tmp ( p );
		
				INSERT INTO TBL_TXN_COMPLIANCE_CDDI
				SELECT @tranId, qId, answer
				FROM #TRANSACTION_COMPLIANCE_QUESTION
			END
			

		 	IF @RequestFrom = 'mobile'	
				UPDATE customerMaster set availableBalance =ISNULL(availableBalance,0) + @pAmount WHERE customerId =  @customerId
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = CASE WHEN @flag = 'restore' THEN 'Transaction has been restored successfully' ELSE 'Transaction paid successfully' END

		 SET @refNo = dbo.decryptdb(@ControlNoModified)
		 EXEC  SendMnPro_Account.dbo.Proc_CashDepositVoucher @controlNo = @refNo ,@refNum= NULL 

		SELECT 0 errorCode, @msg msg, @refNo id,extra= @pAgentComm,extra2=@benefName
		RETURN
	END

	ELSE IF @flag = 'getRiaConfirmDetail'
	BEGIN
		SELECT TransRefID=TransRefID ,OrderNo=OrderNo,PIN=dbo.decryptDb(PIN),
			 BeneCurrency=BeneCurrency,BeneAmount=BeneAmount,
			 CorrespLocCountry=CountryFrom,CorrespLocID='FSOS1',
			 BeneCountry=ISNULL(BeneCountry,'') ,BeneCity = ISNULL(BeneCity,'Ulaanbaatar'),
			 BeneTelNo = BeneTelNo,
			 BeneAddress = BeneAddress
		FROM  RiaCashHistory ria WHERE PIN = dbo.encryptDb(@refNo)
		ORDER BY RowId Desc
	RETURN
	END
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 
		ROLLBACK TRAN

	SELECT '1' ErrorCode, ERROR_MESSAGE() Msg, NULL Id
END CATCH
GO
