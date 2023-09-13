--EXEC proc_searchCustomerIRH @flag = 'srr', @senderId = '4', @searchValue = null
USE FastMoneyPro_Remit
GO

ALTER PROC [dbo].[proc_searchCustomerIRH]
	 --DECLARE 
	 @user			VARCHAR(20)		= null
	,@flag			VARCHAR(20)		= null
	,@searchType	VARCHAR(20)		= null
	,@searchValue	VARCHAR(80)		= null
	,@country		VARCHAR(50)		= NULL
	,@senderId		VARCHAR(20)		= NULL
	,@recId			VARCHAR(20)		= NULL
	,@agentType		CHAR(1)			= NULL		--I-Internal, E-External
	,@sCountryId	VARCHAR(50)		= NULL
	,@settlementAgent VARCHAR(50)	= NULL
	,@customerId	VARCHAR(10)		= NULL
	
AS
SET NOCOUNT ON;
--SELECT @flag ='s', @searchType = 'customerId', @searchValue = '282083105155', @sCountryId = '119', @settlementAgent = '4880'
DECLARE @SQL VARCHAR(MAX), @TranId varchar(50)
DECLARE @idType VARCHAR(30)
DECLARE @senderName VARCHAR(100)
DECLARE @membershipId VARCHAR(50),@visaStatus INT
DECLARE @txnList TABLE(id BIGINT NOT NULL,receiver VARCHAR(100), rIdNumber VARCHAR(50), rMobile VARCHAR(50))

IF @FLAG IN ('SenderH', 's')			--Direct Search By Passport/Mobile Number
BEGIN
		
		DECLARE @customers TABLE(customerId BIGINT, idNumber VARCHAR(50))
		DECLARE @SenderIDimage VARCHAR(500), @fileName VARCHAR(200)
		
		IF ISNULL(@searchValue, '') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Please enter value to search', NULL
			RETURN
		END
		
		IF @searchType = 'email'
		BEGIN
		    SET @SQL = '
						SELECT TOP 1 customerId, idNumber FROM customerMaster WITH(NOLOCK)
						WHERE ISNULL(isDeleted, ''N'') = ''N'' AND ISNULL(isBlacklisted, ''N'') = ''N''
					  '

			IF @sCountryId IS NOT NULL
				SET @SQL = @SQL + ' AND country = ''' + @sCountryId + ''''	
			IF @searchValue IS NOT NULL
				SET @SQL = @SQL + ' AND email='''+ @searchValue + ''''
			ELSE
				SET @SQL = @SQL + ' AND 1 = 2'

			PRINT @SQL
			INSERT INTO @customers
			EXEC(@SQL)
			
			IF NOT EXISTS(SELECT 'X' FROM @customers)
			BEGIN
				EXEC proc_errorHandler 1, 'Customer not found with the respected search', NULL
				RETURN
			END
		END

		SELECT TOP 1 @fileName = [fileName] FROM customerDocument WITH(NOLOCK)
		WHERE customerId = @customerId 
		ORDER BY createdDate DESC
		
		IF @fileName is null
			SET @SenderIDimage = 'Customer Id Image: <img alt = "Customer Identity" title = "Click to Add Document" onclick = "ViewImage(' + ISNULL(@customerId,'0') +');" style="height:50px;width:50px;" src="../../../Images/na.gif" />'
	    ELSE
			SET @SenderIDimage = 'Customer Id Image: <img alt = "Customer Identity" title = "Click to Add Document" onclick = "ViewImage(' + ISNULL(@customerId,'0') +');" style="height:50px;width:50px;" src="../../../doc/'+ @fileName + '" />'  
			
		DECLARE @txnSum INT,@txnCount varchar(20), @date VARCHAR(20) = CONVERT(VARCHAR, GETDATE(),111)
        
		SET @txnSum = ISNULL(@txnSum, 0)
		SET @txnCount = ISNULL(@txnCount, 0)

		DECLARE @receiverName VARCHAR(200), @rCustomerId VARCHAR(20), @receiverCountry VARCHAR(100), @receiverAddress VARCHAR(200), @receiverCity VARCHAR(100),
		@receiverEmail VARCHAR(100), @receiverPhone VARCHAR(50), @receiverMobile VARCHAR(50), @receiverIDDescription VARCHAR(50), @receiverID VARCHAR(30),
		@paymentType VARCHAR(100), @rBankAcNo VARCHAR(50), @paidCType VARCHAR(3), @receiveCType VARCHAR(3), @pBank INT, @pBankBranch INT, @pBankBranchName VARCHAR(50),
		@receiverCountryId INT

		SELECT TOP 1
			 @receiverName			= ReceiverName
			,@rCustomerId			= CustomerId
			,@receiverCountry		= UPPER(ReceiverCountry)
			,@receiverAddress		= ReceiverAddress
			,@receiverCity			= receiverCity
			,@receiverEmail			= ''
			,@receiverPhone			= ReceiverPhone	 
			,@receiverMobile		= receiver_mobile
			,@receiverIDDescription	= ReceiverIDDescription
			,@ReceiverID			= ReceiverID
			,@paymentType			= CASE paymentType WHEN 'Cash Pay' THEN 'CASH PAYMENT' 
											WHEN 'Bank Transfer' THEN 'BANK DEPOSIT'
											WHEN 'Account Deposit To Other Bank' THEN 'BANK DEPOSIT'
											ELSE UPPER(paymentType) END
			,@pBank					= pBank
			,@pBankBranch			= pBankBranch
			,@pBankBranchName		= pBankBranchName
			,@rBankAcNo				= rBankACNo
			,@paidCType				= paidCType
			,@receiveCType			= receiveCType
		FROM customerTxnHistory WITH(NOLOCK)
		WHERE senderPassport = @searchValue
		ORDER BY tranNo DESC
		
		DECLARE @rFirstName VARCHAR(100), @rMiddleName VARCHAR(100), @rLastName1 VARCHAR(100), @rLastName2 VARCHAR(100), @rFullName VARCHAR(100), @totalRows INT
		SELECT @rFirstName = firstName, @rMiddleName = middleName, @rLastName1 = lastName1, @rLastName2 = lastName2 FROM dbo.FNASplitName(@receiverName)
		
		

		SELECT TOP 1
			 0 errorCode
			,customerId				= CM.customerId
			,sMemId					= CM.membershipId
			,sfirstName				= CM.firstName
			,smiddleName			= ISNULL(CM.middleName, '')
			,slastName1				= ISNULL(CM.lastName1, '')
			,slastName2				= ISNULL(CM.lastName2, '')
			,sState					= ISNULL(CM.state, '')
			,scountry				= ISNULL(CM.nativecountry, '')
			,saddress				= ISNULL(CM.address, '') 
			,saddress2				= ISNULL(CM.address2, '')
			,szipCode				= ISNULL(CM.zipCode, '')
			,sDistrict				= CM.district
			,sCity					= CM.city
			,semail					= ISNULL( CM.email, '')
			,sgender				= CASE WHEN CM.gender = 97 THEN 'Male' WHEN CM.gender = 98 THEN 'Female' END
			,shomePhone				= ISNULL(CM.homePhone, '')
			,sworkPhone				= isnull(CM.workPhone, '') 
			,smobile				= CM.mobile
			,sdob					= convert(varchar(20), CM.dob,  111)
			,sCustomerType			= custType.detailTitle
			,sOccupation			= CM.occupation
			,idName					= sdv.detailTitle
			,sidNumber				= ISNULL(CM.idNumber, '')
			,svalidDate				= ISNULL(CONVERT(VARCHAR,CM.idExpiryDate,111), '')
			,senderName				= CM.fullName
			,companyName			= CM.companyName

			,receiverName			= @receiverName
			,rId					= @rCustomerId
			,rfirstName				= @rFirstName
			,rmiddleName			= @rMiddleName
			,rlastName1				= @rLastName1
			,rlastName2				= @rLastName2
			,rcountry				= @receiverCountry
			,raddress				= @receiverAddress
			,raddress2				= ''
			,rState					= ''
			,rzipCode				= ''
			,rDistrict				= ''
			,rCity					= @receiverCity
			,remail					= ISNULL(@receiverEmail, '')
			,rgender				= ''
			,rhomePhone				= ISNULL(@receiverPhone, '')
			,rworkPhone				= ISNULL(@receiverPhone, '')
			,rmobile				= ISNULL(@receiverMobile, '')
			,rdob					= ''
			,ridtype				= @receiverIDDescription
			,ridNumber				= @receiverID
			,rvalidDate				= ''

			,purposeOfRemit			= ''
			,sourceOfFund			= ''
			,relWithSender			= ''
			,pCountry				= @receiverCountry
			,paymentMethod			= @paymentType
			,pAgent					= ''
			,pBank					= ISNULL(@pBank, '')
			,pBankBranch			= ISNULL(@pBankBranch, '')
			,pBankBranchName		= ISNULL(@pBankBranchName, '')
			,accountNo				= ISNULL(@rBankAcNo, '')
			,collCurr				= @paidCType
			,payoutCurr				= @receiveCType
			,salaryRange			= cm.salaryRange
			,txnSum					= dbo.ShowDecimal(CAST(@txnSum AS VARCHAR(200)))
			,txnSum2				= @txnSum
			,txnPerDayCustomerLimit	= isnull(dbo.FNAGetPerDayCustomerLimit(@settlementAgent),0)
			,txnCount				= @txnCount
			,SenderIDimage			= @SenderIDimage
			INTO #sTemp
		FROM dbo.customerMaster CM WITH(NOLOCK)
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = CM.idType
		LEFT JOIN staticDataValue custType WITH (NOLOCK) ON CM.customerType = custType.valueId 
		WHERE CM.customerId IN (SELECT customerId FROM @customers) AND country = @sCountryId
		
		IF NOT EXISTS(SELECT 'x' FROM #sTemp)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer not found with the respected search', NULL
		RETURN
		END	
			
		SELECT * FROM #sTemp
		
		--DROP TABLE #sTemp
		RETURN
END

IF @FLAG IN ('s-new')			--Direct Search By Passport/Mobile Number
BEGIN
		DECLARE @IdNumber VARCHAR(30), @AVAILABLEBALANCE MONEY
		IF ISNULL(@customerId, '') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Please enter value to search', NULL
			RETURN
		END
		
		select @AVAILABLEBALANCE = availableLimit from DBO.FNAGetUserCashLimitDetails(@user,NULL)
		
		SELECT @IdNumber = idNumber 
		FROM customerMaster (NOLOCK) 
		WHERE customerId = @customerId

		DECLARE @kycStatus INT, @MSG VARCHAR(150),@visaStatusNotFound varchar(10)

		SELECT @kycStatus = kycStatus
		FROM TBL_CUSTOMER_KYC (NOLOCK) 
		WHERE CUSTOMERID = @customerId
		AND ISDELETED = 0
		--AND kycStatus='11044'
		ORDER BY KYC_DATE 
		
		IF ISNULL(@kycStatus, 0) <> 11044
		BEGIN
			IF @kycStatus IS NOT NULL
				SELECT @MSG = 'KYC for selected customer is not completed, it is in status : '  + detailTitle FROM staticDataValue (NOLOCK) WHERE valueId = @kycStatus
			ELSE 
				SELECT @MSG = 'Please complete KYC status first'

			EXEC proc_errorHandler 1, @MSG, NULL
			RETURN
		END

		SELECT @visaStatus = visaStatus FROM customermaster WHERE customerId = @customerId
		IF @visaStatus IS NULL
		BEGIN 
			set @visaStatusNotFound = 'true'
		END

		IF @IdNumber IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid customer, Please udpate Identity Type Card Number to proceed!', NULL
			RETURN
		END

		SELECT TOP 1 @fileName = [fileName] FROM customerDocument WITH(NOLOCK)
		WHERE customerId = @customerId 
		AND fileType = 'custDoc'
		ORDER BY createdDate DESC
		
		IF @fileName is null
			SET @SenderIDimage = 'Customer Id Image: <img alt = "Customer Identity" title = "Click to Add Document" onclick = "ViewImage(' + ISNULL(@customerId,'0') +');" style="height:50px;width:50px;" src="../../../Images/na.gif" />'
	    ELSE
			SET @SenderIDimage = 'Customer Id Image: <img alt = "Customer Identity" title = "Click to Add Document" onclick = "ViewImage(' + ISNULL(@customerId,'0') +');" style="height:50px;width:50px;" src="../../../doc/'+ @fileName + '" />'  
			
		SET @txnSum = ISNULL(@txnSum, 0)
		SET @txnCount = ISNULL(@txnCount, 0)

		SELECT TOP 1
			 @receiverName			= ReceiverName
			,@rCustomerId			= CustomerId
			,@receiverCountry		= UPPER(ReceiverCountry)
			,@receiverCountryId		= CM.countryId
			,@receiverAddress		= ReceiverAddress
			,@receiverCity			= receiverCity
			,@receiverEmail			= ''
			,@receiverPhone			= ReceiverPhone	 
			,@receiverMobile		= receiver_mobile
			,@receiverIDDescription	= ReceiverIDDescription
			,@ReceiverID			= ReceiverID
			,@paymentType			= CASE paymentType WHEN 'Cash Pay' THEN 'CASH PAYMENT' 
											WHEN 'Bank Transfer' THEN 'BANK DEPOSIT'
											WHEN 'Account Deposit To Other Bank' THEN 'BANK DEPOSIT'
											ELSE UPPER(paymentType) END
			,@pBank					= pBank
			,@pBankBranch			= pBankBranch
			,@pBankBranchName		= pBankBranchName
			,@rBankAcNo				= rBankACNo
			,@paidCType				= paidCType
			,@receiveCType			= receiveCType
		FROM customerTxnHistory T WITH(NOLOCK)
		INNER JOIN countryMaster CM(NOLOCK) ON CM.countryName = T.ReceiverCountry
		WHERE senderPassport = @IdNumber
		ORDER BY tranNo DESC

		IF @receiverEmail IS NULL OR @receiverEmail=''
		BEGIN
		    SELECT  @receiverEmail=email FROM dbo.receiverInformation WHERE mobile LIKE '%'+@receiverMobile+'%'
		END

		SELECT @rFirstName = firstName, @rMiddleName = middleName, @rLastName1 = lastName1, @rLastName2 = lastName2 FROM dbo.FNASplitName(@receiverName)
		
		SELECT TOP 1
			 0 errorCode
			,customerId				= CM.customerId
			,sMemId					= CM.membershipId
			,sfirstName				= CM.firstName
			,smiddleName			= ISNULL(CM.middleName, '')
			,slastName1				= ISNULL(CM.lastName1, '')
			,slastName2				= ISNULL(CM.lastName2, '')
			,sState					= ISNULL(CM.state, '')
			,scountry				= ISNULL(CM.nativecountry, '')
			,saddress				= ISNULL(CM.address, '') 
			,saddress2				= ISNULL(CM.address2, '')
			,szipCode				= ISNULL(CM.zipCode, '')
			,sDistrict				= CM.district
			,sCity					= CM.city
			,semail					= ISNULL( CM.email, '')
			,sgender				= CASE WHEN CM.gender = 97 THEN 'Male' WHEN CM.gender = 98 THEN 'Female' END
			,shomePhone				= ISNULL(CM.telNo, '')
			,sworkPhone				= isnull(CM.workPhone, '') 
			,smobile				= CM.mobile
			,sdob					= convert(varchar(20), CM.dob,  23)
			,sCustomerType			= custType.detailTitle
			,sOccupation			= CM.occupation
			,idName					= sdv.detailTitle
			,sidNumber				= ISNULL(CM.idNumber, '')
			,svalidDate				= ISNULL(CONVERT(VARCHAR,CM.idExpiryDate,23), '')
			,senderName				= CM.fullName
			,companyName			= CASE WHEN cm.companyName IS NULL AND CM.customerType='4701' THEN cm.firstName END

			,receiverName			= @receiverName
			,rId					= @rCustomerId
			,rfirstName				= @rFirstName
			,rmiddleName			= @rMiddleName
			,rlastName1				= @rLastName1
			,rlastName2				= @rLastName2
			,rcountry				= @receiverCountry
			,raddress				= @receiverAddress
			,raddress2				= ''
			,rState					= ''
			,rzipCode				= ''
			,rDistrict				= ''
			,rCity					= @receiverCity
			,remail					= ISNULL(@receiverEmail, '')
			,rgender				= ''
			,rhomePhone				= ISNULL(@receiverPhone, '')
			,rworkPhone				= ISNULL(@receiverPhone, '')
			,rmobile				= ISNULL(@receiverMobile, '')
			,rdob					= ''
			,ridtype				= @receiverIDDescription
			,ridNumber				= @receiverID
			,rvalidDate				= ''
			
			,purposeOfRemit			= ''
			,sourceOfFund			= sourceOfFund
			,relWithSender			= ''
			,pCountry				= @receiverCountry
			,pCountryId				= @receiverCountryId
			,paymentMethod			= @paymentType
			,pAgent					= ''
			,pBank					= ISNULL(@pBank, '')
			,pBankBranch			= ISNULL(@pBankBranch, '')
			,pBankBranchName		= ISNULL(@pBankBranchName, '')
			,accountNo				= ISNULL(@rBankAcNo, '')
			,collCurr				= @paidCType
			,payoutCurr				= @receiveCType
			,salaryRange			= cm.salaryRange
			,txnSum					= dbo.ShowDecimal(CAST(@txnSum AS VARCHAR(200)))
			,txnSum2				= @txnSum
			,txnPerDayCustomerLimit	= isnull(dbo.FNAGetPerDayCustomerLimit(@settlementAgent),0)
			,txnCount				= @txnCount
			,SenderIDimage			= @SenderIDimage
			,idIssueDate			= ISNULL(CONVERT(VARCHAR,CM.idIssueDate,23), '')
			,CM.street
			,CM.organizationType
			,CM.customerType
			,CM.PLACEOFISSUE
			,AVAILABLEBALANCE =  ISNULL(@AVAILABLEBALANCE, 0)
			,CM.monthlyIncome
			,visaStatusNotFound = @visaStatusNotFound
			,cm.additionalAddress
		INTO #sTempNew
		FROM dbo.customerMaster CM WITH(NOLOCK)
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = CM.idType
		LEFT JOIN staticDataValue custType WITH (NOLOCK) ON CM.customerType = custType.valueId 
		WHERE CM.customerId IN (@customerId) AND country = @sCountryId
		
		IF NOT EXISTS(SELECT 'x' FROM #sTempNew)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer not found with the respected search', NULL
		RETURN
		END	
			
		SELECT * FROM #sTempNew
		
		--DROP TABLE #sTemp
		RETURN
END

ELSE IF @flag = 'ASN'
BEGIN
	IF NOT EXISTS(SELECT * FROM dbo.customerMaster (NOLOCK) WHERE customerId = @recId)
	BEGIN
	    EXEC proc_errorHandler 1, 'No result found', NULL
		RETURN
	END

    SELECT TOP 1
			 0 errorCode
			,customerId				= CM.idNumber
			,sMemId					= CM.membershipId
			,sfirstName				= CM.firstName
			,smiddleName			= ISNULL(CM.middleName, '')
			,slastName1				= ISNULL(CM.lastName1, '')
			,slastName2				= ISNULL(CM.lastName2, '')
			,sState					= ISNULL(CM.state, '')
			,scountry				= ISNULL(CM.nativecountry, '')
			,saddress				= ISNULL(CM.address, '') 
			,saddress2				= ISNULL(CM.address2, '')
			,szipCode				= ISNULL(CM.zipCode, '')
			,sDistrict				= CM.district
			,sCity					= CM.city
			,semail					= ISNULL( CM.email, '')
			,sgender				= CASE WHEN CM.gender = 97 THEN 'Male' WHEN CM.gender = 98 THEN 'Female' END
			,shomePhone				= ISNULL(CM.homePhone, '')
			,sworkPhone				= isnull(CM.workPhone, '') 
			,smobile				= CM.mobile
			,sdob					= convert(varchar(20), CM.dob,  111)
			,sCustomerType			= custType.detailTitle
			,sOccupation			= CM.occupation
			,idName					= sdv.detailTitle
			,sidNumber				= ISNULL(CM.idNumber, '')
			,svalidDate				= ISNULL(CONVERT(VARCHAR,CM.idExpiryDate,111), '')
			,senderName				= CM.fullName
			,companyName			= CM.companyName

			,receiverName			= @receiverName
			,rId					= @rCustomerId
			,rfirstName				= @rFirstName
			,rmiddleName			= @rMiddleName
			,rlastName1				= @rLastName1
			,rlastName2				= @rLastName2
			,rcountry				= @receiverCountry
			,raddress				= @receiverAddress
			,raddress2				= ''
			,rState					= ''
			,rzipCode				= ''
			,rDistrict				= ''
			,rCity					= @receiverCity
			,remail					= ISNULL(@receiverEmail, '')
			,rgender				= ''
			,rhomePhone				= ISNULL(@receiverPhone, '')
			,rworkPhone				= ISNULL(@receiverPhone, '')
			,rmobile				= ISNULL(@receiverMobile, '')
			,rdob					= ''
			,ridtype				= @receiverIDDescription
			,ridNumber				= @receiverID
			,rvalidDate				= ''

			,purposeOfRemit			= ''
			,sourceOfFund			= ''
			,relWithSender			= ''
			,pCountry				= @receiverCountry
			,paymentMethod			= @paymentType
			,pAgent					= ''
			,pBank					= ISNULL(@pBank, '')
			,pBankBranch			= ISNULL(@pBankBranch, '')
			,pBankBranchName		= ISNULL(@pBankBranchName, '')
			,accountNo				= ISNULL(@rBankAcNo, '')
			,collCurr				= @paidCType
			,payoutCurr				= @receiveCType
			,salaryRange			= cm.salaryRange
			,txnSum					= dbo.ShowDecimal(CAST(@txnSum AS VARCHAR(200)))
			,txnSum2				= @txnSum
			,txnPerDayCustomerLimit	= isnull(dbo.FNAGetPerDayCustomerLimit(@settlementAgent),0)
			,txnCount				= @txnCount
			,SenderIDimage			= @SenderIDimage
		FROM dbo.customerMaster CM WITH(NOLOCK)
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = CM.idType
		LEFT JOIN staticDataValue custType WITH (NOLOCK) ON CM.customerType = custType.valueId 
		WHERE CM.customerId = @recId
END

ELSE IF @flag = 'srr'					--Search Recent Receiver List
BEGIN

	SELECT @membershipId = isnull(membershipId,''), @senderName = fullName FROM customers WITH(NOLOCK) WHERE idNumber = @senderId
	SET @SQL = '
			IF OBJECT_ID(''tempdb..#TEMP'') IS NOT NULL DROP TABLE #TEMP
			SELECT TOP 5 TR.customerId id,TS.fullName,COUNT(1) NO_OF_TXN 
			INTO #TEMP
			FROM dbo.tranReceivers TR(NOLOCK)
			INNER JOIN dbo.tranSenders TS(NOLOCK) ON TR.tranId = TS.tranId
			WHERE TS.customerId = '''+@senderId+'''
			GROUP BY TR.customerId,TS.fullName
			ORDER BY NO_OF_TXN DESC'
			
	SET @SQL = @SQL + '
				SELECT TOP 5 T.id ,
				membershiId=RI.membershipId,
				senderName=T.fullName,
				receiverName = RI.firstName+ISNULL('' ''+ri.middleName,'''')+ISNULL('' ''+ri.lastName1,'''') ,
				rMobile=RI.mobile,
				bank='''',
				payMode='''',
				bankBranch='''',
				acNo=ri.receiverAccountNo,
				idType=RI.idType,
				idNumber=RI.idNumber
				FROM dbo.receiverInformation RI(NOLOCK)
				INNER JOIN #TEMP T ON T.id = RI.receiverId'
	IF @searchValue IS NOT NULL
		SET @SQL = @SQL + ' AND RI.firstName+ISNULL('' ''+ri.middleName,'''')+ISNULL('' ''+ri.lastName1,'''') LIKE ''' + @searchValue + '%'''
		
	--SET @SQL = @SQL + '
	--GROUP BY receiverName ,CTH.receiver_mobile ,CTH.rBankName ,CTH.rBankBranch ,CTH.rBankACNo ,CTH.membershipId ,senderName ,CTH.Tranno
	--ORDER BY MAX(ri.receiverId)  DESC'
	PRINT 1
	PRINT(@SQL)
	EXEC (@SQL)
	RETURN
END

ELSE IF @flag = 'sth'					--Sender Txn History
BEGIN
	--******Inficare System Search******
	SELECT @senderName = fullName FROM customers WITH(NOLOCK) WHERE idNumber = @senderId
	
	SET @SQL = '
		SELECT TOP 5
			 id						= ms.Tranno
			,senderName				= ''' + @senderName + '''
			,receiverName			= ms.ReceiverName
			,tAmt					= ms.paidAmt
			,createdDate			= CONVERT(VARCHAR , ms.confirmDate, 111)
			,ICN					= dbo.FNADecryptString(ms.refno)
			,payMode				= ms.paymentType
			,bank					= CASE WHEN ms.paymentType = ''Bank Transfer'' THEN ms.rBankName
											WHEN ms.paymentType = ''Account Deposit to Other Bank'' THEN ms.ben_bank_name ELSE ms.rBankName END 
			,bankBranch				= CASE WHEN ms.paymentType = ''Bank Transfer'' THEN ms.rBankBranch
											WHEN ms.paymentType = ''Account Deposit to Other Bank'' THEN ms.rBankAcType ELSE ms.rBankBranch END
			,acNo					= ms.rBankACNo
		FROM customerTxnHistory ms WITH(NOLOCK)
		WHERE senderPassport = ''' + @senderId + '''
	'
	IF @recId IS NOT NULL
	 	SET @SQL = @SQL + ' AND ms.ReceiverName LIKE ''' + @recId + '%'''
	 	
	SET @SQL = @SQL + ' ORDER BY ms.Tranno DESC'
	
	EXEC (@SQL)
	RETURN
END

ELSE IF @flag = 'advS'					--Advance Search(Load Customer Grid)
BEGIN
	SET @searchValue = ISNULL(@searchValue, '')
	SET @SQL = '
		SELECT DISTINCT TOP 15 
			 errorCode			= ''0''
			,customerId			= C.customerId
			,membershipId		= C.membershipId
			,senderName			= C.fullName
			,countryName		= CM.countryName
			,address			= C.address
			,mobile				= C.mobile
			,nativeCountry		= C.nativeCountry
			,email				= C.email
			,idNumber			= C.idNumber
			,idType				= SV.detailTitle
			,validDate			= CONVERT(VARCHAR, C.idExpiryDate, 111)
			,cUstId				= C.idNumber
		FROM customerMaster C WITH(NOLOCK)
		INNER JOIN countryMaster CM WITH (NOLOCK) ON C.country = CM.countryId
		LEFT JOIN staticDataValue SV WITH (NOLOCK) ON SV.valueId = C.idType
		WHERE ISNULL(C.isDeleted,''N'') = ''N'' AND ISNULL(isBlackListed, ''N'') = ''N''
	'

	IF @sCountryId IS NOT NULL
		SET @SQL = @SQL + ' AND c.country = ''' + @sCountryId + ''''

	IF @searchType = 'firstName'
		SET @SQL = @SQL + ' AND C.fullName LIKE ''' + @searchValue + '%'''

	ELSE IF @searchType = 'Address'
		SET @SQL = @SQL + ' AND C.Address LIKE ''' + @searchValue + '%'''
		
	ELSE IF @searchType = 'Passport'
		SET @SQL = @SQL + ' AND C.idType = 1302 AND C.idNumber = ''' + @searchValue + ''''

	ELSE IF @searchType IS NOT NULL AND @searchType <> 'IC'
		SET @SQL = @SQL + ' AND C.' + @searchType + ' = ''' + @searchValue + ''''
		
	ELSE
		SET @SQL = @SQL + ' AND 1 = 2'
				
	--PRINT @SQL
	EXEC(@SQL)
END


ELSE IF @flag = 'advS-new'					--Advance Search(Load Customer Grid)
BEGIN
	SET @searchValue = ISNULL(@searchValue, '')
	SET @SQL = '
		SELECT DISTINCT TOP 15 
			 errorCode			= ''0''
			,customerId			= C.customerId
			,membershipId		= C.membershipId
			,senderName			= C.fullName
			,countryName		= CM.countryName
			,address			= C.address
			,mobile				= C.mobile
			,nativeCountry		= C.nativeCountry
			,email				= C.email
			,idNumber			= C.idNumber
			,idType				= SV.detailTitle
			,validDate			= CONVERT(VARCHAR, C.idExpiryDate, 111)
			,cUstId				= C.idNumber
		FROM customerMaster C WITH(NOLOCK)
		INNER JOIN countryMaster CM WITH (NOLOCK) ON C.country = CM.countryId
		LEFT JOIN staticDataValue SV WITH (NOLOCK) ON SV.valueId = C.idType
		WHERE ISNULL(C.isDeleted,''N'') = ''N'' AND ISNULL(isBlackListed, ''N'') = ''N''
	'

	IF @sCountryId IS NOT NULL
		SET @SQL = @SQL + ' AND c.country = ''' + @sCountryId + ''''

	IF @searchType = 'name'
		SET @SQL = @SQL + ' AND C.fullName LIKE ''' + @searchValue + '%'''

	ELSE IF @searchType = 'email'
		SET @SQL = @SQL + ' AND C.email LIKE ''' + @searchValue + '%'''
		
	ELSE IF @searchType = 'membershipId'
		SET @SQL = @SQL + ' AND C.membershipId LIKE ''' + @searchValue + '%'''

	ELSE IF @searchType = 'dob'
		SET @SQL = @SQL + ' AND C.dob LIKE ''' + @searchValue + '%'''
		
	ELSE
		SET @SQL = @SQL + ' AND 1 = 2'
				
	--PRINT @SQL
	EXEC(@SQL)
END

ELSE IF @searchType = 'ICN'				--Search By ICN
BEGIN
	EXEC proc_errorHandler 1, 'Search By ICN is not allowed for now', NULL
	RETURN
	
		SELECT top 1
				@SenderId=C.customerId,
				@TranId= trn.id ,
				@ReceiverID=cast(R.customerId as varchar(20))
				--,S.customerId
		  FROM customers C 
			 LEFT JOIN tranSenders S WITH(NOLOCK) ON C.customerId  = S.customerId
			 LEFT JOIN remitTran trn WITH(NOLOCK) ON S.tranId  = trn.id
			 LEFT JOIN tranReceivers R WITH(NOLOCK) ON R.tranId  = trn.id
		 WHERE trn.controlNo = dbo.FNADecryptString(@searchValue) and R.tranId is not null
		 ORDER BY trn.id DESC

		  --select @searchValue
		IF NOT EXISTS(SELECT 'A' FROM customers WHERE customerId=@SenderId)
		BEGIN
			EXEC proc_errorHandler 1, 'This Member is not found.', NULL
			RETURN;
		END	
		IF EXISTS(SELECT 'A' FROM customers WHERE customerId=@SenderId AND ISNULL(isBlackListed,'N')='Y')
		BEGIN
			EXEC proc_errorHandler 1, 'This customer is blacklisted. Cannot proceed for transaction.', NULL
			RETURN;
		END	
	  
	  
	  SELECT 0 errorCode,* FROM (
		SELECT
			 membershipId [sMemId], firstName sfirstName, isnull(middleName,'') smiddleName, 
			 isnull(lastName1,'') slastName1, isnull(lastName2,'')slastName2
			 ,country scountry, isnull([address],'')saddress, isnull([State],'') sState,
			  isnull(zipCode,'') szipCode, district [sDistrict], city [sCity], email semail
			 ,homePhone shomePhone, isnull(workPhone,'') sWorkPhone , mobile smobile, convert(varchar(20), dob,  111) sdob,
			  Typ.detailTitle sCustomerType, Ocu.detailTitle sOccupation
			 ,relativeName sRelativeName, Rel.detailTitle sRelation, Cont.countryName scountryName, ID.idType sidType,
			  ID.idNumber sidNumber, ID.validDate svalidDate
		  FROM customers  C WITH (NOLOCK)
			 LEFT JOIN customerIdentity ID WITH (NOLOCK) ON C.customerId = ID.idType
			 JOIN staticDataValue Rel WITH (NOLOCK) ON C.relationId = Rel.valueId
			 JOIN staticDataValue Ocu WITH (NOLOCK) ON C.occupation = Ocu.valueId
			 JOIN staticDataValue Typ WITH (NOLOCK) ON C.customerType = Typ.valueId
			 JOIN countryMaster Cont WITH (NOLOCK)  ON C.country = Cont.countryId
		WHERE C.customerId=@SenderId
		) AS sender
	     LEFT JOIN (
		SELECT
			 membershipId [rMemId], firstName rfirstName, isnull(middleName,'') rmiddleName, 
			 isnull(lastName1,'') rlastName1, isnull(lastName2,'')rlastName2
			 ,country [rcountry], isnull([address],'')raddress, isnull([State],'') rState,
			  isnull(zipCode,'') rzipCode, district [rDistrict], city [rCity], email remail
			 ,homePhone rhomePhone, isnull(workPhone,'') sWorkPhone , mobile rmobile, convert(varchar(20), dob,  111) rdob,
			  Typ.detailTitle rCustomerType, Ocu.detailTitle rOccupation ,relativeName rRelativeName, Rel.detailTitle rRelation,
			   Cont.countryName rcountryName, ID.idType ridType,
			  ID.idNumber ridNumber, ID.validDate rvalidDate
		  FROM customers  C WITH (NOLOCK)
			 LEFT JOIN customerIdentity ID WITH (NOLOCK) ON C.customerId = ID.idType
			 JOIN staticDataValue Rel WITH (NOLOCK) ON C.relationId = Rel.valueId
			 JOIN staticDataValue Ocu WITH (NOLOCK) ON C.occupation = Ocu.valueId
			 JOIN staticDataValue Typ WITH (NOLOCK) ON C.customerType = Typ.valueId
			 JOIN countryMaster Cont WITH (NOLOCK)  ON C.country = Cont.countryId
		WHERE C.customerId=@ReceiverID
	) as REC ON sender.sMemId=REC.rMemId
	
	

END

ELSE IF @flag = 'R'						--Load Receiver after picked
BEGIN
	DECLARE @TRANLIST TABLE(tranId BIGINT,customerId INT)
	
	--*****Inficare Search Receiver******
	--INSERT INTO @TRANLIST(tranId)
	--SELECT MAX(ms.Tranno) FROM irh_ime_plus_01.dbo.moneySend ms WITH(NOLOCK)
	--WHERE senderPassport = @senderId
	--GROUP BY ms.Tranno
	
	SELECT @rFullName = receiverName FROM customerTxnHistory WITH(NOLOCK) WHERE Tranno = @recId
	SELECT @rFirstName = firstName, @rMiddleName = middleName, @rLastName1 = lastName1, @rLastName2 = lastName2 FROM dbo.FNASplitName(@rFullName)
	
	SELECT DISTINCT  
		 ID									= ms.Tranno
		,[sid]								= ms.senderPassport
		,[senderName]						= ms.SenderName
		,sidType							= ms.senderFax
		,sidNumber							= ms.senderPassport
		,smobile							= ms.sender_mobile 
		,saddress							= ms.SenderAddress
		,tranNo								= dbo.FNADecryptString(ms.refno)
		,[receiverName]						= ms.receiverName
		,firstName							= @rFirstName
		,middleName							= @rMiddleName 
		,lastName1							= @rLastName1
		,lastName2							= @rLastName2
		,pBranchName						= ms.rBankBranch
		,paymentMethod						= CASE ms.paymentType WHEN 'Cash Pay' THEN 'CASH PAYMENT' WHEN 'Bank Transfer' THEN 'BANK DEPOSIT'
													WHEN 'Account Deposit to Other Bank' THEN 'BANK DEPOSIT' ELSE UPPER(ms.paymentType) END 
		,tAmt								= ms.paidAmt
		,createdDate						= CONVERT(VARCHAR,ms.confirmDate,111) 
		,sCountry							= ms.SenderCountry
		,idType								= ms.receiverIDDescription
		,idNumber							= ms.receiverID 
		,validDate							= ''
		,dob								= ''
		,homePhone							= ReceiverPhone
		,mobile								= receiver_mobile
		,[address]							= ReceiverAddress
		,[state]							= ReceiverCity
		,zipCode							= ''
		,country							= ReceiverCountry
		,email								= ''
		,accountNo							= ISNULL(ms.rBankACNo, '')
		,pBank								= ISNULL(pBank, 0)
		,pBankBranch						= ISNULL(pBankBranch, 0)
		,pBankBranchName					= ISNULL(pBankBranchName, '')
	FROM customerTxnHistory ms WITH(NOLOCK)
	WHERE 
	--ms.SenderName LIKE ISNULL(@searchValue + '%', '%') AND 
	ms.Tranno = @recId
END

ELSE IF @flag = 'branchByAgent'
BEGIN
		

	IF @agentType = 'I'
	BEGIN		
		SET @SQL = '
					SELECT TOP 20 
						 agentId 
						,agentName
						,agentAddress
						,agentCity				= ISNULL(agentCity,'''') 
						,agentPhone1			= ISNULL(agentPhone1 ,'''') 
					    ,agentState				= ISNULL(agentState, '''') 
					    ,extCode				= ISNULL(extCode, '''') 
					FROM agentMaster WITH(NOLOCK)
					WHERE ISNULL(isDeleted, ''N'') = ''N''
						AND agentType = ''2904''
						AND parentId = ''' + @senderId + '''
					'
						
		IF @searchValue IS NOT NULL
			SET @SQL = @SQL + ' AND ' + @searchType + ' LIKE ''%' + @searchValue + '%'''
		
		SET @SQL = @SQL + ' ORDER BY agentName ASC'
		
	END

	ELSE IF @agentType = 'E'
	BEGIN
		IF @searchType = 'agentName'
			SET @searchType = 'branchName'
		ELSE IF @searchType = 'agentAddress'
			SET @searchType = 'address'
		ELSE IF @searchType = 'agentCity'
			SET @searchType = 'city'
		ELSE IF @searchType = 'agentPhone1'
			SET @searchType = 'phone'

		ELSE IF @searchType = 'agentState'
			SET @searchType = 'State'
	    ELSE IF @searchType = 'extCode'
			SET @searchType = 'externalCode'
	
		SET @SQL = '
					SELECT TOP 10
						 agentId			= extBranchId
						,agentName			= branchName
						,agentAddress		= address
						,agentCity			= ISNULL(city, '''')
						,agentPhone1		= ISNULL(phone, '''')
					    ,agentState			= ISNULL(State, '''')
					    ,extCode			= ISNULL(externalCode, '''')
					FROM externalBankBranch WITH(NOLOCK)
					WHERE ISNULL(isDeleted, ''N'') = ''N''
					AND extBankId = ''' + @senderId + '''
					AND ISNULL(isBlocked,''N'') = ''N''
					'
					
		IF @searchValue IS NOT NULL
			SET @SQL = @SQL + ' AND ' + @searchType + ' LIKE ''' + @searchValue + '%'''
		
		SET @SQL = @SQL + ' ORDER BY agentName ASC'
		
	END
	EXEC(@SQL)
	PRINT(@SQL)
	RETURN
END

ELSE IF @flag = 'locationByAgent'
BEGIN

	SELECT	TOP 50 
			L.LocationId,
			L.Address,
			L.City,
			A.agentName
	FROM agentDoorToDoorLocation L WITH (NOLOCK)
	INNER JOIN agentMaster A WITH (NOLOCK) ON L.agentId=A.agentId
	WHERE L.agentId = @senderId 
	AND L.Address LIKE ISNULL(@searchValue+'%','%')
	ORDER BY L.Address
END



