USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerMaster]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_customerMaster]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(50)		= NULL
	,@id								INT				= NULL
	,@customerId						INT				= NULL
	,@membershipId						VARCHAR(100)	= NULL
	,@firstName                         VARCHAR(200)	= NULL
	,@middleName						VARCHAR(200)	= NULL
	,@lastName							VARCHAR(200)	= NULL
	,@maritalStatus						VARCHAR(50)		= NULL
	,@dobEng                            VARCHAR(50)		= NULL
	,@dobNep                            VARCHAR(20)		= NULL

	,@idType							VARCHAR(100)	= NULL
	,@idNo								VARCHAR(100)	= NULL
	,@placeOfIssue						VARCHAR(200)	= NULL
	,@issueDate							VARCHAR(50)		= NULL
	,@expiryDate						VARCHAR(50)		= NULL

	,@pTole								VARCHAR(200)	= NULL
	,@pHouseNo							VARCHAR(200)	= NULL
	,@pMunicipality						VARCHAR(200)	= NULL
	,@pWardNo							VARCHAR(200)	= NULL
	,@pCountry							VARCHAR(200)	= NULL
	,@pZone								VARCHAR(200)	= NULL
	,@pDistrict							VARCHAR(200)	= NULL

	,@tTole								VARCHAR(200)	= NULL
	,@tHouseNo							VARCHAR(200)	= NULL
	,@tMunicipality						VARCHAR(200)	= NULL
	,@tWardNo							VARCHAR(200)	= NULL
	,@tCountry							VARCHAR(200)	= NULL
	,@tZone								VARCHAR(200)	= NULL
	,@tDistrict							VARCHAR(200)	= NULL

	,@fatherName						VARCHAR(200)	= NULL
	,@motherName						VARCHAR(200)	= NULL
	,@grandFatherName					VARCHAR(200)	= NULL

	,@occupation                        VARCHAR(200)	= NULL
	,@email                             VARCHAR(50)		= NULL
	,@phone								VARCHAR(50)		= NULL
	,@mobile							VARCHAR(50)		= NULL
	,@isActive							CHAR(1)			= NULL
	,@agentId							VARCHAR(20)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

	--filter param
	,@name								VARCHAR(200)	= NULL
	,@hasChanged						CHAR(1)			= NULL
	,@isApproved						CHAR(1)			= NULL
	,@searchBy							VARCHAR(50)		= NULL
	,@searchValue						VARCHAR(200)	= NULL
	,@customerCardNo					VARCHAR(100)	= NULL
	,@createdDate						DATETIME		= NULL
	,@isUploadedFilter					char(1)			= NULL
	,@agentName							VARCHAR(200)	= NULL

	-- RECEIVER HISTORY
	,@sMembershipId						VARCHAR(16)		= null
	,@sFirstName						VARCHAR(200)	= NULL
	,@sMiddleName						VARCHAR(200)	= NULL
	,@sLastName							VARCHAR(200)	= NULL
	,@sContactNo						VARCHAR(50)		= NULL
	,@rFullName							VARCHAR(50)		= NULL
	,@rMobile							VARCHAR(50)		= NULL
	,@rMembershipId						VARCHAR(50)		= NULL
	,@rReceiverId						BIGINT			= NULL
	,@gender							VARCHAR(10)		= NULL
	,@issueDateNp						VARCHAR(20)		= NULL
	,@expiryDateNp						VARCHAR(MAX)	= NULL
            
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), membershipId INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@errorMsg			VARCHAR(MAX)
		
	SELECT
		 @logIdentifier = 'membershipId'
		,@logParamMain = 'Customer Master'		
		,@module = '20'
		,@tableAlias = 'customerMaster'
		
	DECLARE @TranId INT, 
			@ReceiverID AS VARCHAR(100) 
			
	IF @flag = 'sn'
	BEGIN
		SELECT 
			REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ') customerName 
		FROM customerMaster WITH(NOLOCK) WHERE customerId = @customerId AND ISNULL(isDeleted, 'N') <> 'Y' 
	END
	
	ELSE IF @flag='membershipIdType'
	BEGIN
		SELECT valueId membershipIdType,detailTitle membershipIdName
			FROM staticDataValue WITH(NOLOCK) WHERE typeID=1300 AND valueId IN (1301,1304,1302)
			ORDER BY detailTitle
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF (len(ltrim(rtrim(@membershipId))) <> '8')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number Should Be 8 Digits.', NULL
			RETURN
		END

		IF (len(ltrim(rtrim(@mobile))) <> '10')
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number Should Be 10 Digits.', NULL
			RETURN
		END
		IF (YEAR(GETDATE()) - YEAR(@dobEng) < 16) 
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Not Eligible! Age should be greater than 16.', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock) 
			WHERE membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' and rejectedDate is null)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number already in use', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock) 
			WHERE mobile = @mobile 
			AND ISNULL(isDeleted, 'N') <> 'Y' 
			and rejectedDate is null
			AND isKyc is null)
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number already in use', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock) 
			WHERE citizenshipNo = @idNo 
			AND idType = @idType  
			AND placeOfIssue = @placeOfIssue
			and ISNULL(isDeleted, 'N') <> 'Y' 
			and rejectedDate is null)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer ID Card number already in use', @customerId
			RETURN
		END
		IF @expiryDate IS NOT NULL AND @idType <> 'Citizenship'
		BEGIN
			IF @expiryDate < DATEADD(DAY,180,GETDATE())	
			BEGIN
				EXEC proc_errorHandler 1, 'Customer is not eligible to enroll, Going to expire soon.', @customerId
				RETURN;
			END  
		END 
		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock)
			WHERE mobile = @mobile 
				AND ISNULL(isDeleted, 'N') <> 'Y'
				and rejectedDate is null
				AND CONVERT(VARCHAR,CAST(dobEng AS DATE),102)= CONVERT(VARCHAR,CAST(@dobEng AS DATE),102)
				AND UPPER(REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ')) =
					UPPER(REPLACE(ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName, ''), '  ', ' ')))
		BEGIN
			SELECT @errorMsg = 'Similar Customer Found With Same Mobile, Name & Date Of Birth!';
			EXEC proc_errorHandler 1, @errorMsg, @customerId
			RETURN
		END

		BEGIN TRANSACTION	
			INSERT INTO customerMaster (
				 membershipId
				,firstName
				,middleName
				,lastName
				,maritalStatus
				,dobEng
				,dobNep

				,idType
				,citizenshipNo
				,placeOfIssue
				,issueDate
				,expiryDate

				,pTole
				,pHouseNo
				,pMunicipality
				,pWardNo
				,pCountry
				,pZone
				,pDistrict

				,tTole
				,tHouseNo
				,tMunicipality
				,tWardNo
				,tCountry
				,tZone
				,tDistrict
				
				,fatherName
				,motherName
				,grandFatherName

				,occupation
				,email
				,phone
				,mobile

				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
				,agentId
				,isActive
				,gender
				,issueDateNp
				,expiryDateNp
			)
			SELECT
				 @membershipId
				,@firstName
				,@middleName
				,@lastName
				,@maritalStatus
				,@dobEng
				,@dobNep

				,@idType
				,@idNo
				,@placeOfIssue
				,@issueDate
				,@expiryDate

				,@pTole
				,@pHouseNo
				,@pMunicipality
				,@pWardNo
				,@pCountry
				,@pZone
				,@pDistrict

				,@tTole
				,@tHouseNo
				,@tMunicipality
				,@tWardNo
				,@tCountry
				,@tZone
				,@tDistrict
				
				,@fatherName
				,@motherName
				,@grandFatherName

				,@occupation
				,@email
				,@phone
				,@mobile

				,@user
				,getdate()
				,@user
				,getdate()
				,isnull(@agentId,'1001')
				,@isActive
				,@gender
				,@issueDateNp
				,@expiryDateNp
				
			DECLARE @rowId INT
			SET @customerId = SCOPE_IDENTITY()
			----UPDATE imeRemitCardMaster SET cardStatus = 'Enrolled' WHERE remitCardNo = @membershipId
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, membershipId)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @customerId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @customerId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @customerId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT   
				 customerId
				,membershipId
				,firstName
				,middleName
				,lastName
				,maritalStatus
				,CONVERT(VARCHAR,CAST(dobEng AS DATE),101) dobEng
				,dobNep
				,idType
				,idType1 = dbo.FNAGetIDType(c.idType,'151')+ '|' + ISNULL(cit.expiryType, 'E')
				,citizenshipNo
				,placeOfIssue
				,expiryDate = CONVERT(VARCHAR,expiryDate,101)
				,issueDate = CONVERT(VARCHAR,issueDate,101)
				,pTole
				,pHouseNo
				,pMunicipality
				,pWardNo
				,pCountry
				,pZone
				,pDistrict

				,tTole
				,tHouseNo
				,tMunicipality
				,tWardNo
				,tCountry
				,tZone
				,tDistrict
				
				,fatherName
				,motherName
				,grandFatherName

				,occupation
				,email
				,phone
				,mobile

				,c.createdBy			
				,c.createdDate		
				,c.approvedBy			
				,c.approvedDate		
				,c.modifiedBy			
				,c.modifiedDate		
				,c.isActive			
				,c.isDeleted		
				,agentId	
				,gender = CASE gender WHEN '1801' THEN 'Male' 
									  WHEN '1802' THEN 'Female' 
									  ELSE gender 
						 END	
				,issueDateNp
				,expiryDateNp
		FROM customerMaster c WITH(NOLOCK)
		LEFT JOIN countryIdType cit WITH(NOLOCK) ON dbo.FNAGetIDType(c.idType,'151') = CAST(cit.IdTypeId AS VARCHAR) AND countryId='151'
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) on dbo.FNAGetIDType(c.idType,'151') = CAST(sdv.valueId AS VARCHAR)			
		WHERE c.customerId = @customerId
	END	

	ELSE IF @flag = 'a1'
	BEGIN
		SELECT   
				 customerId
				,membershipId
				,fullName = REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ')
				,firstName
				,middleName
				,lastName
				,maritalStatus
				,CONVERT(VARCHAR,CAST(dobEng AS DATE),101) dobEng
				,dobNep
				,idType=sdv.detailTitle
				,idType1 = dbo.FNAGetIDType(c.idType,'151')+ '|' + ISNULL(cit.expiryType, 'E')
				,citizenshipNo
				,placeOfIssue
				,expiryDate = CONVERT(VARCHAR,expiryDate,101)
				,issueDate = CONVERT(VARCHAR,issueDate,101)

				,pTole
				,pHouseNo
				,pMunicipality
				,pWardNo
				,pCountry
				,pZone
				,pDistrict

				,tTole
				,tHouseNo
				,tMunicipality
				,tWardNo
				,tCountry
				,tZone
				,tDistrict
				
				,fatherName
				,motherName
				,grandFatherName

				,occupation
				,email
				,phone
				,mobile

				,c.createdBy			
				,c.createdDate		
				,c.approvedBy			
				,c.approvedDate		
				,c.modifiedBy			
				,c.modifiedDate		
				,c.isActive			
				,c.isDeleted		
				,agentId
				,gender = CASE gender WHEN '1801' THEN 'Male' 
									  WHEN '1802' THEN 'Female' 
									  ELSE gender 
						 END
				,issueDateNp
				,expiryDateNp				
		FROM customerMaster c WITH(NOLOCK)
		LEFT JOIN countryIdType cit WITH(NOLOCK) ON dbo.FNAGetIDType(c.idType,'151') = CAST(cit.IdTypeId AS VARCHAR) AND countryId='151'
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) on dbo.FNAGetIDType(c.idType,'151') = CAST(sdv.valueId AS VARCHAR)
		WHERE c.membershipId = @membershipId
		AND ISNULL(c.isDeleted,'N')<>'Y'
		RETURN
	END	
	ELSE IF @flag = 'a11'
	BEGIN
		SELECT   
				 customerId
				,membershipId
				,fullName = REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ')
				,firstName
				,middleName
				,lastName
				,maritalStatus
				,CONVERT(VARCHAR,CAST(dobEng AS DATE),101) dobEng
				,dobNep
				,idType
				,idType1 = dbo.FNAGetIDType(c.idType,'151')+ '|' + ISNULL(cit.expiryType, 'E')
				,citizenshipNo
				,placeOfIssue
				,expiryDate = CONVERT(VARCHAR,expiryDate,101)
				,issueDate = CONVERT(VARCHAR,issueDate,101)

				,pTole
				,pHouseNo
				,pMunicipality
				,pWardNo
				,pCountry
				,pZone
				,pDistrict

				,tTole
				,tHouseNo
				,tMunicipality
				,tWardNo
				,tCountry
				,tZone
				,tDistrict
				
				,fatherName
				,motherName
				,grandFatherName

				,occupation
				,email
				,phone
				,mobile

				,c.createdBy			
				,c.createdDate		
				,c.approvedBy			
				,c.approvedDate		
				,c.modifiedBy			
				,c.modifiedDate		
				,c.isActive			
				,c.isDeleted		
				,agentId
				,gender = CASE gender WHEN '1801' THEN 'Male' 
									  WHEN '1802' THEN 'Female' 
									  ELSE gender 
						 END
		FROM customerMaster c WITH(NOLOCK)
		LEFT JOIN countryIdType cit WITH(NOLOCK) ON dbo.FNAGetIDType(c.idType,'151') = CAST(cit.IdTypeId AS VARCHAR) AND countryId='151'
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) on dbo.FNAGetIDType(c.idType,'151') = CAST(sdv.valueId AS VARCHAR)			
		WHERE c.membershipId = @membershipId
		AND ISNULL(c.isDeleted,'N')<>'Y'
		RETURN
	END	
	
	ELSE IF @flag = 'u'
	BEGIN
		DECLARE 
			@OLD_MEMBERSHIPID VARCHAR(10),
			@IsKyc CHAR(1)
		SELECT 
			@OLD_MEMBERSHIPID = MEMBERSHIPID,
			@IsKyc = ISNULL(isKyc,'N')
		FROM customerMaster CM WITH(NOLOCK) WHERE customerId = @customerId	

		IF (len(ltrim(rtrim(@membershipId))) <> '8') and @IsKyc = 'N'
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number Should Be 8 Digits.', NULL
			RETURN
		END	
		IF (len(ltrim(rtrim(@membershipId))) <> '16') and @IsKyc = 'Y'
		BEGIN
			EXEC proc_errorHandler 1, 'Remit Card Number Should Be 16 Digits.', NULL
			RETURN
		END	
		IF (len(ltrim(rtrim(@mobile))) <> '10')
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number Should Be 10 Digits.', NULL
			RETURN
		END
		IF (YEAR(GETDATE()) - YEAR(@dobEng) < 16) 
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Not Eligible', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock) WHERE customerId <> @customerId AND membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number already in use', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock) 
			WHERE customerId <> @customerId 
				AND mobile = @mobile 
				AND ISNULL(isDeleted, 'N') <> 'Y'
				AND isKyc is NULL
				AND rejectedDate is null)
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number already in use', @customerId
			RETURN
		END

		IF EXISTS(SELECT 'X' FROM customerMaster with(nolock)
			WHERE mobile = @mobile 
				AND customerId <> @customerId 
				AND ISNULL(isDeleted, 'N') <> 'Y'
				AND isKyc IS NULL
				AND CONVERT(VARCHAR,CAST(dobEng AS DATE),102)= CONVERT(VARCHAR,CAST(@dobEng AS DATE),102)
				AND UPPER(REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ')) =
					UPPER(REPLACE(ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName, ''), '  ', ' ')))
		BEGIN
			SELECT @errorMsg = 'Similar Customer Found With Same Mobile, Name & Date Of Birth!';
			EXEC proc_errorHandler 1, @errorMsg, @customerId
			RETURN
		END
		IF @expiryDate IS NOT NULL AND @idType <> 'Citizenship'
		BEGIN
			IF @expiryDate < DATEADD(DAY,180,GETDATE())	
			BEGIN
				EXEC proc_errorHandler 1, 'Customer is not eligible to enroll, Going to expire soon.', @customerId
				RETURN;
			END  
		END 

		BEGIN TRANSACTION

			UPDATE customerMaster SET
				 membershipId			= @membershipId
				,firstName				= @firstName
				,middleName				= @middleName
				,lastName				= @lastName
				,maritalStatus			= @maritalStatus
				,dobEng					= @dobEng
				,dobNep					= @dobNep

				,idType					= @idType
				,citizenshipNo			= @idNo
				,placeOfIssue			= @placeOfIssue
				,issueDate				= @issueDate
				,expiryDate				= @expiryDate

				,pTole					= @pTole
				,pHouseNo				= @pHouseNo
				,pMunicipality			= @pMunicipality
				,pWardNo				= @pWardNo
				,pCountry				= @pCountry
				,pZone					= @pZone
				,pDistrict				= @pDistrict

				,tTole					= @tTole
				,tHouseNo				= @tHouseNo
				,tMunicipality			= @tMunicipality
				,tWardNo				= @tWardNo
				,tCountry				= @tCountry
				,tZone					= @tZone
				,tDistrict				= @tDistrict

				,fatherName				= @fatherName
				,motherName				= @motherName
				,grandFatherName        = @grandFatherName
				,occupation				= @occupation
				,email					= @email
				,phone					= @phone
				,mobile					= @mobile
				,modifiedBy				= @user
				,modifiedDate			= GETDATE()
				,isActive				= @isActive
				,gender					= @gender
				,issueDateNp			= @issueDateNp
				,expiryDateNp			= @expiryDateNp
			WHERE customerId = @customerId
			----IF @OLD_MEMBERSHIPID <> @membershipId
			----BEGIN
			----	UPDATE imeRemitCardMaster SET cardStatus = 'Enrolled' WHERE remitCardNo = @membershipId
			----	UPDATE imeRemitCardMaster SET cardStatus = 'Transfered' WHERE remitCardNo = @OLD_MEMBERSHIPID
			----END
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, membershipId)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @customerId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @customerId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @customerId
		RETURN
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF NOT EXISTS (SELECT 'x' FROM customerMaster with(nolock) WHERE customerId = @customerId 
				 and approvedBy is null)
		BEGIN
				EXEC proc_errorHandler 1, 'Approved Record Can not Delete!', @customerId
				RETURN
		END    
		BEGIN TRANSACTION
			SELECT @membershipId = membershipId 
				FROM customerMaster cm WITH(NOLOCK) WHERE customerId =@customerId
				
			UPDATE customerMaster SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE customerId = @customerId 
				 and approvedBy is null

			----UPDATE imeRemitCardMaster SET cardStatus = 'Transfered' WHERE remitCardNo = @membershipId
			
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @customerId, @oldValue OUTPUT
			
			INSERT INTO #msg(errorCode, msg, membershipId)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @customerId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @customerId
				RETURN
			END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @customerId
		RETURN
	END
	
    ELSE IF @flag = 'approve'
	BEGIN
		BEGIN TRANSACTION
		UPDATE customerMaster SET
			 approvedDate  = GETDATE()
			,approvedBy = @user
			,customerStatus = 'Approved'
		WHERE customerId = @customerId

		UPDATE customerInfo SET setPrimary = 'N' WHERE customerId = @customerId

		-- ## SMS 
		DECLARE @mobileNo VARCHAR(50)
		SELECT @mobileNo = mobile FROM customerMaster WITH(NOLOCK) WHERE customerId  = @customerId
		IF @mobileNo IS NOT NULL OR @mobileNo <> ''
		BEGIN
			INSERT INTO SMSQUEUE(mobileNo,msg,createdDate,createdBy)
			SELECT @mobileNo,'IME Customer Card linu bhaekoma dhanyabad. Aba bonus point prapta gari bivinna aakarshak puraskar jitna kunai pani IME agent marphat paisa pathaunuhos. -IME',GETDATE(),@user
		END

		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @customerId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, membershipId)

		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @customerId, @user, @oldValue, @newValue
		
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to approve record.', @customerId
			RETURN
		END

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION		
		
		EXEC proc_errorHandler 0, 'Record approved successfully.', @customerId
		RETURN
	END
	
	ELSE IF @flag = 'reject'
	BEGIN
		BEGIN TRANSACTION
		SELECT @membershipId = membershipId 
				FROM customerMaster cm WITH(NOLOCK) WHERE customerId = @customerId
				
		UPDATE customerMaster SET
			rejectedDate  = GETDATE()
			,rejectedBy = @user
			,customerStatus = 'Rejected'
		WHERE customerId = @customerId
		
		----UPDATE imeRemitCardMaster SET cardStatus = 'Transfered' WHERE remitCardNo = @membershipId
		
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @customerId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, membershipId)

		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @customerId, @user, @oldValue, @newValue
		
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to reject record.', @customerId
			RETURN
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record rejected successfully.', @customerId
		RETURN
	END

	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'membershipId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					distinct
					 main.customerId
					,main.membershipId
					,name = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName, '''')
					,main.pCountry 
					,main.pZone
					,main.pDistrict
					,main.pMunicipality
					,main.email
					,main.phone
					,main.mobile
					,main.dobEng
					,main.occupation
					,main.createdBy
					,main.createdDate
					,main.isDeleted
					,haschanged = CASE WHEN (main.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
					,main.modifiedBy
					,main.agentId
					,isActive = isnull(main.isActive,''Y'')
					,isUploaded = case when cd.customerId is null then ''No'' else ''Yes'' end
					,isUploadedFilter = case when cd.customerId is null then ''N'' else ''Y'' end
					,agentName = am.agentName
					,main.approvedBy
				FROM customerMaster main WITH(NOLOCK)
				LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
				LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
					WHERE isnull(customerStatus,'''') <> ''rejected'' 
					) x'
					
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @searchBy = 'name' and @searchValue is not null
			SET @sql_filter = @sql_filter + ' AND name LIKE ''%' + @searchValue + '%'''
		
		IF @agentName is not null
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''

		IF @searchBy = 'membershipId' and @searchValue is not null
			SET @sql_filter = @sql_filter + ' AND membershipId = ''' + @searchValue + ''''
		
		IF @searchBy = 'mobile' and @searchValue is not null
			SET @sql_filter = @sql_filter + ' AND ISNULL(mobile, '''') LIKE ''%' + @searchValue + '%'''
		
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + @hasChanged + ''''

		IF @isActive IS NOT NULL 
			SET @sql_filter = @sql_filter + ' AND isActive = ''' + @isActive + ''''

		IF @isUploadedFilter IS NOT NULL 
			SET @sql_filter = @sql_filter + ' AND isUploadedFilter = ''' + @isUploadedFilter + ''''

		IF @createdDate IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND createdDate BETWEEN ''' + CONVERT(VARCHAR,@createdDate,101) + ''' AND ''' + CONVERT(VARCHAR,@createdDate,101) + ' 23:59:59'''

		SET @select_field_list ='			 
			 customerId
			,membershipId
			,name
			,pCountry
			,pZone
			,pDistrict
			,pMunicipality
			,email
			,phone
			,mobile
			,dobEng
			,occupation
			,createdBy
			,createdDate
			,isDeleted
			,hasChanged
			,modifiedBy
			,agentId
			,isActive
			,isUploaded
			,isUploadedFilter
			,agentName
			,approvedBy '

		EXEC dbo.proc_paging
				 @table
				,@sql_filter
				,@select_field_list
				,@extra_field_list
				,@sortBy
				,@sortOrder
				,@pageSize
				,@pageNumber
		RETURN
	END	

	IF @flag='image-display'
	BEGIN
		
		IF @membershipId IS NULL
			SELECT @membershipId = membershipId 
			FROM customerMaster with(nolock) WHERE customerId = @customerId
		IF LEN(@membershipId) = '16'
		BEGIN
			SELECT 
				[fileName] = fileName ,
				CASE 
					WHEN fileDescription='FORM-1' 
						THEN 'Enrollment Form'
					WHEN fileDescription='ID CARD'  
						THEN 'Primary Id Card'
					ELSE fileDescription 
				END fileDescription
			FROM customerDocument a WITH(NOLOCK) 
			INNER JOIN kycMaster KC WITH(NOLOCK) ON A.customerId = KC.rowId AND isKycDoc = 'Y'
			INNER JOIN customerMaster b WITH(NOLOCK) ON a.customerId=b.customerId 	
			WHERE KC.remitCardNo = @membershipId  --AND isKycDoc = 'Y'
			AND fileDescription IN ('FORM-1','ID CARD')		
			ORDER BY isProfilePic DESC
		END
		
		SELECT fileName [fileName],
			CASE 
				WHEN fileDescription='Enrollform' THEN 'Enrollment Form'
				WHEN fileDescription='IdCard' THEN 'ID Card -1'
				WHEN fileDescription='IdCard_2' THEN 'ID Card -2'
				WHEN fileDescription='photo' THEN 'Photo'
				ELSE fileDescription 
			END fileDescription
		FROM customerDocument a WITH(NOLOCK) 
		INNER JOIN customerMaster b WITH(NOLOCK) ON a.customerId=b.customerId		
		WHERE b.membershipId = @membershipId  
		AND A.isKycDoc IS NULL 
		and ISNULL(b.isDeleted,'N')<> 'Y'
		ORDER BY isProfilePic DESC
		RETURN
	END	

	ELSE IF @flag = 'viewHistory'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '
		(
		SELECT TOP 20  
			id = rt.id,
			rMembershipId = rec.membershipId,
			rFullName = ISNULL(rec.firstName, '''') + ISNULL( '' '' + rec.middleName, '''')+ ISNULL( '' '' + rec.lastName1, '''')+ ISNULL( '' '' + rec.lastName2, ''''),
			rMobile = rec.mobile,
			rIdType = rec.idType,
			rIdNumber = rec.idNumber,
			rAddress = rec.address
		FROM dbo.remitTran rt WITH(NOLOCK) 
		INNER JOIN dbo.tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN dbo.tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId '

		IF @sMembershipId IS NULL 
			SET @table = @table+' WHERE 1=2'
		IF @sMembershipId IS NOT NULL  
			SET @table = @table+' WHERE sen.membershipId = '''+@sMembershipId+''''		
		SET @sql_filter = ''

		SET @table = @table+')x'

		SET @select_field_list ='			 
			 id
			,rMembershipId
			,rFullName
			,rMobile
			,rIdType
			,rIdNumber
			,rAddress '

		EXEC dbo.proc_paging
				 @table
				,@sql_filter
				,@select_field_list
				,@extra_field_list
				,@sortBy
				,@sortOrder
				,@pageSize
				,@pageNumber
			RETURN
	END
	IF @flag='image-display-mId'
	BEGIN
		
		IF @membershipId IS NULL
			SELECT @membershipId = membershipId 
			FROM customerMaster with(nolock) WHERE customerId = @customerId  
		IF LEN(@membershipId) = '16'
		BEGIN
			SELECT  TOP 1
				[fileName] = fileName ,
				CASE 
					WHEN fileDescription='FORM-1' 
						THEN 'Enrollment Form'
					WHEN fileDescription='ID CARD'  
						THEN 'Primary Id Card'
					ELSE fileDescription 
				END fileDescription
			FROM customerDocument a WITH(NOLOCK) 
			INNER JOIN kycMaster KC WITH(NOLOCK) ON A.customerId = KC.rowId AND isKycDoc = 'Y'
			INNER JOIN customerMaster b WITH(NOLOCK) ON a.customerId=b.customerId 	
			WHERE KC.remitCardNo = @membershipId  --AND isKycDoc = 'Y'
			AND fileDescription IN ('FORM-1','ID CARD')	
			AND	
			(
				b.idType = 'Citizenship' 
				OR b.idType = 'Driving License' 
				OR b.idType = 'Passport' 
			)
			ORDER BY cdId DESC
		END
		
		SELECT TOP 1 fileName [fileName],
			CASE 
				WHEN fileDescription='Enrollform' 
					THEN 'Enrollment Form'
				WHEN fileDescription='IdCard'  
					THEN 'ID Card -1'
					WHEN fileDescription='IdCard_2'  
					THEN 'ID Card -2'
				ELSE fileDescription 
			END fileDescription
		FROM customerDocument a WITH(NOLOCK) 
		INNER JOIN customerMaster b WITH(NOLOCK) ON a.customerId=b.customerId		
		WHERE b.membershipId = @membershipId  
		AND A.isKycDoc IS NULL 
		and ISNULL(b.isDeleted,'N')<> 'Y'
		AND	
			(
				b.idType = 'Citizenship' 
				OR b.idType = 'Driving License' 
				OR b.idType = 'Passport' 
			)
		AND fileDescription = 'IdCard'
		ORDER BY cdId DESC

		RETURN
	END	

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @customerId
END CATCH









GO
