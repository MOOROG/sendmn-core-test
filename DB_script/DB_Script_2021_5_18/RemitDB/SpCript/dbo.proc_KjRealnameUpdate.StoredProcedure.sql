USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_KjRealnameUpdate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_KjRealnameUpdate]  
 @flag						VARCHAR(50)		= NULL   
,@user						VARCHAR(30)		= NULL  
,@customerId				VARCHAR(30)		= NULL 
,@searchCriteria			VARCHAR(30)		= NULL
,@searchValue				VARCHAR(50)		= NULL
,@fromDate					DATETIME		= NULL
,@toDate					DATETIME		= NULL
,@cusType					VARCHAR(50)		= NULL
,@accountNumber				VARCHAR(100)	= NULL
,@CustomerBankName			NVARCHAR(100)	= NULL
,@obpId						VARCHAR(50)     = NULL

AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  


IF	@flag='list'
	BEGIN
		SELECT	customerId,			idType,				REPLACE(idNumber, ' ', '') AS [idNumber],
				approvedDate,		verifiedDate,		CONVERT(VARCHAR(6), dob, 12) AS [dob],
				C.isActive,			customerStatus
				,bankCode =CASE C.bankName WHEN '13' THEN '005' WHEN '26' THEN '081' WHEN '2' THEN '006' WHEN '24' THEN '004' ELSE K.bankCode END
				,bankAccountNo,		walletAccountNo,	obpId,
				CustomerBankName,	country,			nativeCountry,
				CASE WHEN nativeCountry = '238' THEN '1' --USA
					 WHEN nativeCountry = '113' THEN '2' -- JAPAN
					 WHEN nativeCountry = '45'  THEN '3' --CHINA
					 ELSE '4' END AS [nativeCountryCode],
				gender, 
				[genderCode] = CASE WHEN gender='97' THEN '7' --MALE
					 WHEN gender='98' THEN '8' END  -- FEMALE
		FROM	customerMaster(NOLOCK)C
		INNER JOIN KoreanBankList K(NOLOCK) ON K.ROWID = C.bankName
		WHERE	approvedDate IS NOT NULL 
		AND		OBPID IS NOT NULL
		and CustomerBankName='nnull'
		AND C.customerId IN (
		SELECT DISTINCT customerId FROM TBLCUSTOMERMODIFYLOGS(NOLOCK) WHERE 
		columnName NOT IN('idExpiryDate','idIssueDate','CustomerBankName','mobile','email') AND
		--modifiedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE() AND modifiedBy <>'SYSTEM' -- REST OF THE TIME
		modifiedDate BETWEEN CAST(DATEADD(D,-3,CAST(GETDATE() AS DATE)) AS VARCHAR(10)) AND GETDATE() AND modifiedBy <>'SYSTEM' -- FOR MORNING ONLY
		)
		
		--AND		c.bankName in(13,26,2,24)
		--78423
	END	
ELSE IF @flag='update-bankname'
	BEGIN
		BEGIN TRAN
		
		INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, newValue, modifiedBy, modifiedDate)
		SELECT @customerId, 'CustomerBankName',CustomerBankName,'SYSTEM',GETDATE()
		FROM   customerMaster(NOLOCK)
		WHERE customerId = @customerId	

		UPDATE dbo.customerMaster SET CustomerBankName = @CustomerBankName
		WHERE customerId = @customerId			

		commit tran
		
		SELECT '0' ErrorCode , 'Customer bank name change successfully.' Msg , @customerId id
	END

GO
