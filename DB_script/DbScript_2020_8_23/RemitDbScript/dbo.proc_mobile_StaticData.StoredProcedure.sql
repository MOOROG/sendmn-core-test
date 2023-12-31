USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_mobile_StaticData]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	proc_mobile_StaticData @flag='kycv3', @customerId = 'amritchang1'
*/

CREATE PROCEDURE [dbo].[proc_mobile_StaticData](
	@flag			VARCHAR(30)		= NULL
	,@customerId	VARCHAR(100)    = NULL
)AS
BEGIN
	DECLARE @nativeCountry VARCHAR(20)
	
	--SELECT @customerId = username FROM customerMasterTemp with (nolock) WHERE username = @customerId
	SELECT @customerId=email,@nativeCountry=x.nativeCountry FROM (SELECT username AS email ,cmt.nativeCountry AS nativeCountry FROM dbo.CustomerMastertemp (NOLOCK) cmt 
	UNION ALL 
	SELECT email,cm.nativeCountry AS nativeCountry FROM   dbo.customerMaster(NOLOCK) cm )x WHERE x.email=@customerId
	
	IF @flag = 'img-path'
	BEGIN
		DECLARE @MEMBESHIP_ID VARCHAR(50) = NULL, @REGISTERED_DATE VARCHAR(30)
		IF EXISTS(SELECT * FROM dbo.customerMaster(NOLOCK) WHERE email = @customerId)
		BEGIN
			IF EXISTS(SELECT * FROM dbo.customerMaster(NOLOCK) WHERE email = @customerId AND membershipId IS NULL)
			BEGIN
				EXEC PROC_GENERATE_MEMBERSHIP_ID @CUSTOMERID = 0, @USER = 'mobile', @loginBranchId = 0, @MEMBESHIP_ID = @MEMBESHIP_ID OUT

				UPDATE dbo.customerMaster SET MEMBERSHIPID = @MEMBESHIP_ID WHERE email = @customerId
			END
			SELECT MEMBERSHIPID
					, REGISTERED_DATE = CONVERT(VARCHAR(10), CREATEDDATE, 111)
			FROM dbo.customerMaster (NOLOCK) 
			WHERE email = @customerId
			RETURN
		END
		IF EXISTS(SELECT * FROM dbo.customerMasterTemp(NOLOCK) WHERE email = @customerId)
		BEGIN
			IF EXISTS(SELECT * FROM dbo.customerMasterTemp(NOLOCK) WHERE email = @customerId AND membershipId IS NULL)
			BEGIN
				EXEC PROC_GENERATE_MEMBERSHIP_ID @CUSTOMERID = 0, @USER = 'mobile', @loginBranchId = 0, @MEMBESHIP_ID = @MEMBESHIP_ID OUT

				UPDATE dbo.customerMasterTemp SET MEMBERSHIPID = @MEMBESHIP_ID WHERE email = @customerId
			END
			SELECT MEMBERSHIPID
					, REGISTERED_DATE = CONVERT(VARCHAR(10), CREATEDDATE, 111)
			FROM dbo.customerMasterTemp (NOLOCK) 
			WHERE email = @customerId
			RETURN
		END
		SELECT MEMBERSHIPID = '', REGISTERED_DATE = ''
		RETURN
	END
	IF @flag = 'receiver'
	BEGIN
		SELECT 
			 CONVERT(VARCHAR,CM.countryId) AS countryId
			 ,CM.countryName AS country
			 ,CM.countryCode AS Code
			 ,IsProvienceReq = CASE WHEN TSL.countryId IS NOT NULL THEN 'true' ELSE 'false' end
		FROM dbo.countryMaster(NOLOCK) AS CM
		INNER JOIN (SELECT DISTINCT COUNTRYID FROM countryReceivingMode(NOLOCK)) CR ON CR.COUNTRYID = cm.countryId
		LEFT JOIN (
			SELECT DISTINCT COUNTRYiD FROM dbo.tblServicewiseLocation(NOLOCK)
			 )AS TSL ON TSL.countryId = CM.countryId WHERE CM.isOperativeCountry='Y'
		ORDER BY country
		SELECT 
			CAST(TSL.rowId AS VARCHAR) AS id
			,TSL.location  AS [text]
			, CONVERT(VARCHAR,TSL.countryId) AS countryId
		FROM dbo.tblServicewiseLocation(NOLOCK) AS TSL 
		ORDER BY [text]
		----WHERE CONVERT(VARCHAR,TSL.countryId)='203' AND TSL.partnerLocationId='019'

		SELECT 
			CAST(rowId AS VARCHAR) AS id,TSL.subLocation AS [text], CONVERT(VARCHAR,TSL.locationId) AS provinceId
		FROM dbo.tblSubLocation(NOLOCK) AS TSL
		ORDER BY [text]

		SELECT 
			CONVERT(VARCHAR,SDV.valueId) AS id,SDV.detailTitle AS [text]
		FROM dbo.staticDataValue(NOLOCK) AS SDV 
		WHERE SDV.typeID='3800' AND isActive = 'Y'
		AND ISNULL(IS_DELETE,'N')='N'
		ORDER BY [text]

		SELECT 
			CONVERT(VARCHAR,SDV.valueId) AS id,SDV.detailTitle AS [text]
		FROM dbo.staticDataValue(NOLOCK) AS SDV 
		WHERE SDV.typeID='2100' AND isActive = 'Y'
		AND ISNULL(IS_DELETE,'N')='N'
		ORDER BY [text]

		SELECT 
			CONVERT(VARCHAR,SDV.detailTitle) AS id,SDV.detailTitle AS [text]
		FROM dbo.staticDataValue(NOLOCK) AS SDV 
		WHERE SDV.typeID='7006' AND isActive = 'Y'
		ORDER BY [text]
		RETURN
	END
	IF @flag='kyc'
	BEGIN

		SELECT CM.countryId AS [id],CM.countryName AS [text],CM.CountryCode AS Code 
		FROM dbo.countryMaster AS CM(NOLOCK) ORDER BY [text]---country

		SELECT cityName AS [id],cityName [text] 
		FROM dbo.CityMaster(NOLOCK) ORDER by cityName --city

		SELECT valueId AS [id],detailTitle AS [text] 
		FROM staticdatavalue WITH (NOLOCK) 
		WHERE typeid=2000  AND ISNULL(ISActive,'N')='Y' AND ISNULL(IS_DELETE,'N')='N'
		ORDER BY [text]--occuptttion

		SELECT rowId AS [id],bankName AS [text] FROM vwBankLists bl(nolock) ORDER BY [text]--bankName

		--SELECT valueId AS id,detailTitle AS [text],
		--	CASE	WHEN valueId = 1302		THEN 'docIssueDate,docExpiryDate' 
		--			WHEN valueId = 8008		THEN 'docIssueDate' 
		--			WHEN valueId = 10997	THEN 'docIssueDate,docExpiryDate'
		--			WHEN valueId = 11012	THEN 'docIssueDate,docExpiryDate'  
		--	ELSE '' END AS [dependent]  
		--FROM staticdatavalue(nolock)
		--where typeid = 1300 AND valueId IN (11079,8008)  
		--AND ISNULL(ISActive,'Y') = 'Y' AND ISNULL(IS_DELETE,'N')='N'				---- idType

		SELECT valueId AS id,detailTitle AS [text] FROM StaticDataValue(nolock) 
		WHERE typeID = 3900	AND ISNULL(IS_DELETE,'N')='N'
		ORDER BY [text]																--sourceOfFund

		RETURN
	END
	IF @flag='kycV3'
	BEGIN	
		--SELECT cityName AS [id],cityName [text] 
		--FROM dbo.CityMaster(NOLOCK) ORDER by cityName --city
		SELECT ROW_ID AS id, PROVINCE_NAME AS text
		FROM TBL_PROVINCE_LIST P(NOLOCK) 
		WHERE P.IS_ACTIVE = 1

		SELECT p_text = P.PROVINCE_NAME, p_id = P.ROW_ID
				,c_text = C.CITY_NAME, c_id = C.ROW_ID
		FROM TBL_PROVINCE_LIST P(NOLOCK) 
		INNER JOIN TBL_CITY_LIST C(NOLOCK) ON C.PROVINCE_ID = P.ROW_ID

		
		SELECT rowId AS [id],bankName AS [text] FROM vwBankLists bl(nolock) ORDER BY [text]--bankName

		SELECT agentid,agentName FROM dbo.agentMaster(NOLOCK)  WHERE PARENTID = 394399
		AND ACTASBRANCH = 'Y'

		IF EXISTS (SELECT 'x' FROM dbo.customerMasterTemp(NOLOCK) WHERE username=@customerId)
		BEGIN

			--SELECT TOP 1 firstName,gender=CASE WHEN gender=97 THEN 'M' 
			--							 WHEN gender=98 THEN 'F' ELSE 'O' end,
			--		CONVERT(VARCHAR(10),dob,120) AS dob,customerEmail AS email,city,address FROM dbo.CustomerMasterTemp(NOLOCK) WHERE email=@customerId

			--SELECT TOP 1 bankName,bankAccountNo AS bankAccount,idNumber AS passportNumber,CONVERT(VARCHAR(10),idIssueDate,120) AS passportIssueDate,
			--CONVERT(VARCHAR(10),idExpiryDate,120) AS passportExpiryDate,idType AS anotherIDType,idNumber AS anotherIDNumber, branchId AS branch
			--,referelCode FROM dbo.CustomerMasterTemp(NOLOCK) WHERE email=@customerId AND bankName IS NOT NUll

			--SELECT TOP 1 customerId AS userId, verifyDoc1 AS passportPicture,verifyDoc2 AS anotherIDPicture
			-- FROM dbo.CustomerMasterTemp(NOLOCK) WHERE email=@customerId  AND (verifyDoc1 IS NOT NULL OR verifyDoc2 IS NOT NULL)

			SELECT TOP 1	
					cmt.firstName,
					cmt.lastName1 lastName,
					fullName,
					gender=CASE WHEN gender=97 THEN 'M' WHEN gender=98 THEN 'F' ELSE NULL END ,
					cmt.idType,
					CONVERT(VARCHAR(10),dob,120) AS dob
					,customerEmail AS email
					,district province
					,city
					,address
					,nativeCountry=cm.countryCode
					,cmt.occupation
					,bankName
					,bankAccountNo AS bankAccount
					,idNumber AS passportNumber
					,idNumber AS nationalIDNumber
					,CONVERT(VARCHAR(10),idIssueDate,120) AS passportIssueDate
					,CONVERT(VARCHAR(10),idExpiryDate,120) AS passportExpiryDate
					,idNumber AS nationalIdNumber
					,CONVERT(VARCHAR(10),idIssueDate,120) AS nationalIdIssueDate
					,CONVERT(VARCHAR(10),idExpiryDate,120) AS nationalIdExpiryDate
					, branchId AS branch
					,referelCode
					,customerId AS userId
					,verifyDoc1 AS nationalIdFront
					,verifyDoc1 AS passportPicture
					,verifyDoc2 AS nationalIdBack
					,REGISTERED_DATE = CONVERT(VARCHAR(10), CMT.CREATEDDATE, 111)
					,MEMBESHIP_ID = membershipId
				FROM dbo.customerMasterTEMP(NOLOCK) cmt
				INNER JOIN dbo.countryMaster(NOLOCK) cm ON cm.countryId=cmt.nativeCountry WHERE email=@customerId

		END
		ELSE
		BEGIN
			--SELECT TOP 1 firstName,gender=CASE WHEN gender=97 THEN 'M' 
			--							 WHEN gender=98 THEN 'F' ELSE 'O' end,
			--		CONVERT(VARCHAR(10),dob,120) AS dob,customerEmail AS email,city,address FROM dbo.customerMaster(NOLOCK) WHERE email=@customerId

			--SELECT TOP 1 bankName,bankAccountNo AS bankAccount,idNumber AS passportNumber,CONVERT(VARCHAR(10),idIssueDate,120) AS passportIssueDate,
			--CONVERT(VARCHAR(10),idExpiryDate,120) AS passportExpiryDate,idType AS anotherIDType,idNumber AS anotherIDNumber, branchId AS branch
			--,referelCode FROM dbo.customerMaster(NOLOCK) WHERE email=@customerId AND bankName IS NOT NUll

			--SELECT TOP 1 customerId AS userId, verifyDoc1 AS passportPicture,verifyDoc2 AS anotherIDPicture
			-- FROM dbo.customerMaster(NOLOCK) WHERE email=@customerId  AND (verifyDoc1 IS NOT NULL OR verifyDoc2 IS NOT NULL)

			SELECT TOP 1	
					cmt.firstName,
					cmt.lastName1 lastName,
					fullName,
					gender=CASE WHEN gender=97 THEN 'M' WHEN gender=98 THEN 'F' ELSE NULL END ,
					cmt.idType,
					CONVERT(VARCHAR(10),dob,120) AS dob
					,customerEmail AS email
					,district province
					,city
					,address
					,nativeCountry=cm.countryCode
					,cmt.occupation
					,bankName
					,bankAccountNo AS bankAccount
					,idNumber AS passportNumber
					,CONVERT(VARCHAR(10),idIssueDate,120) AS passportIssueDate
					,CONVERT(VARCHAR(10),idExpiryDate,120) AS passportExpiryDate
					,idNumber AS nationalIdNumber
					,CONVERT(VARCHAR(10),idIssueDate,120) AS nationalIdIssueDate
					,CONVERT(VARCHAR(10),idExpiryDate,120) AS nationalIdExpiryDate
					, branchId AS branch
					,referelCode
					,customerId AS userId
					,verifyDoc1 AS nationalIdFront
					,verifyDoc1 AS passportPicture
					,verifyDoc2 AS nationalIdBack
					,REGISTERED_DATE = CONVERT(VARCHAR(10), CMT.CREATEDDATE, 111)
					,MEMBESHIP_ID = membershipId
				FROM dbo.customerMaster(NOLOCK) cmt
				INNER JOIN dbo.countryMaster(NOLOCK) cm ON cm.countryId=cmt.nativeCountry WHERE email=@customerId

		END

		SELECT valueId AS id,detailTitle AS [text] FROM StaticDataValue(nolock) 
		WHERE typeID = 2000	AND isActive='Y'
		ORDER BY [text]--Occupation
		
		RETURN
	END
END



GO
