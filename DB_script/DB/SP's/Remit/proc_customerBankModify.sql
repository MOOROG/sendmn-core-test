

ALTER PROC proc_customerBankModify 
(
	@flag			VARCHAR(20)
	,@user			VARCHAR(50)		= NULL
	,@searchKey		VARCHAR(30)		= NULL
	,@searchValue	VARCHAR(100)	= NULL
	,@bankId		VARCHAR(10)		= NULL
	,@accNumber		VARCHAR(30)		= NULL
	,@customerId	VARCHAR(10)		= NULL
	,@acNameInBank	NVARCHAR(50)	= NULL
	,@verifyDoc3	VARCHAR(100)	= NULL
	,@rowId			INT				= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @flag = 'customerZip'
	BEGIN
		IF @searchKey IS NULL
			SELECT @searchKey = ZIP_CODE FROM TBL_JAPAN_ADDRESS_DETAIL(NOLOCK) WHERE ROW_ID = @rowId

		IF NOT EXISTS(SELECT 1 FROM TBL_JAPAN_ADDRESS_DETAIL D(NOLOCK) WHERE ZIP_CODE = @searchKey)
		BEGIN
			EXEC proc_errorHandler '1', 'Invalid Attempt!', NULL
			RETURN
		END

		SELECT errorCode = 0, msg = 'Success', ROW_ID, STATE_ID,
				 ZIP_CODE, CITY_NAME = CITY_NAME + ISNULL(' - '+CITY_JAPANESE, ''),
				 STREET_NAME = STREET_NAME + ISNULL(' - '+STREET_JAPANESE, '')
		FROM TBL_JAPAN_ADDRESS_DETAIL D(NOLOCK)
		WHERE ZIP_CODE = @searchKey
	END
	ELSE IF @flag = 'S'
	BEGIN
		IF @searchKey IS NULL OR @searchValue IS NULL
		BEGIN
			EXEC proc_errorHandler '1', 'Invalid Attempt!', NULL
			RETURN
		END

		--@Max - 2018.09
		DECLARE @sql VARCHAR(MAX) = 'SELECT TOP 1 0 errorCode, CM.customerId, CM.fullName, 
			CM.bankAccountNo, CM.idNumber, KB.BankName, KB.bankCode, CM.homePhone, CM.verifyDoc3,
			idType,	
			CONVERT(VARCHAR(6), CM.dob, 12) AS [dob],
			CASE WHEN CM.nativeCountry = 238 THEN 1
				 WHEN CM.nativeCountry = 113 THEN 2
				 WHEN CM.nativeCountry = 45  THEN 3
				 ELSE 4 END AS [nativeCountryCode],
 			CASE WHEN CM.gender = 97 THEN 7
				 WHEN CM.gender = 98 THEN 8 END AS [genderCode]
		FROM customerMaster CM(NOLOCK) 
		INNER JOIN KoreanBankList KB(NOLOCK) ON KB.rowId = CM.bankName 
		WHERE REPLACE('+@searchKey+', ''-'', '''') = REPLACE('''+@searchValue+''', ''-'', '''')'
		
		EXEC(@sql)
	END
	ELSE IF @flag = 'customervf'	-- customer verification details
	BEGIN
		DECLARE @sqls VARCHAR(800) ='
		SELECT	''0'' As Code, 
			cm.fullName  AS name,
			ISNULL(cm.mobile,cm.homePhone) AS mobile,
			cm.gender AS gender,
			cm.idType As idType,
			cm.idNumber As idNumber,
			FORMAT(cm.dob,''MM/dd/yyyy'')AS dob,
			cm.bankName AS bankName,
			k.bankCode As bankCode,
			cm.bankAccountNo AS accountNo,
			cm.nativeCountry AS country,
			obpId AS obpId,
			walletAccountNo AS wallletNo
		FROM customerMaster cm  (NOLOCK) 
		INNER JOIN KoreanBankList k (nolock) on k.rowId = cm.bankName
		WHERE ' + @searchKey + ' =  '''+ @searchValue +''' '
		print @sqls
		EXEC(@sqls)
	END
	ELSE IF @flag = 'DDL'
	BEGIN
		SELECT BankName, bankCode FROM KoreanBankList (NOLOCK) ORDER BY BankName ASC
	END
	ELSE IF @flag = 'U'
	BEGIN
		IF @user IS NULL 
		BEGIN
			EXEC proc_errorHandler '1', 'Please login first to modify customer!', NULL
			RETURN
		END
		IF NOT EXISTS (SELECT 1 FROM customerMaster (NOLOCK) WHERE customerId = @customerId)
		BEGIN
			EXEC proc_errorHandler '1', 'Some thing went wrong this time, please try again later!', NULL
			RETURN
		END

		--LOG FOR CUSTOMER UPDATE
		EXEC PROC_CUSTOMERMODIFYLOG @flag = 'i', @email = NULL, @idNumber = NULL, @bank = @bankId, 
									@accNumber = @accNumber, @customerId = @customerId, @mobileNumber = NULL,
									@user = @user	

		UPDATE CM SET CM.bankName = KB.rowId, CM.bankAccountNo = @accNumber, CM.CustomerBankName = @acNameInBank, CM.verifyDoc3 = ISNULL(@verifyDoc3, CM.verifyDoc3)
		FROM customerMaster CM(NOLOCK)
		INNER JOIN KoreanBankList KB(NOLOCK) ON KB.bankCode = @bankId
		WHERE CM.customerId = @customerId

		EXEC proc_errorHandler '0', 'Details updated successfully!', NULL

	END	
	ELSE IF @flag = 'Audit'
	BEGIN
		UPDATE customerMaster SET AuditBy = @user,AuditDate = GETDATE() WHERE customerId = @customerId
		EXEC proc_errorHandler '0', 'Document marked as Audited', NULL
		RETURN
	END
END


--select * from TBLCUSTOMERMODIFYLOGS
--select bankName, bankAccountNo,* from customerMaster where customerId =3