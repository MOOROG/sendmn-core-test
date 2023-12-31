USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_modifyTran]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_modifyTran]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@tranId							BIGINT			= NULL
	,@senderId							INT				= NULL
	,@receiverId						INT				= NULL
	,@customerId                        BIGINT			= NULL
	,@srFlag							CHAR(1)			= NULL
	,@oldCustomerId						BIGINT			= NULL
	,@agentId							INT				= NULL
	,@oldAgentId						INT				= NULL
	,@membershipId                      VARCHAR(20)		= NULL
	,@placeOfIssue						VARCHAR(50)		= NULL
	,@firstName                         VARCHAR(50)		= NULL
	,@middleName						VARCHAR(50)		= NULL
	,@lastName1							VARCHAR(50)		= NULL
	,@lastName2							VARCHAR(50)		= NULL
	,@country							INT				= NULL
	,@address                           VARCHAR(100)	= NULL
	,@state                             VARCHAR(50)		= NULL
	,@zipCode                           VARCHAR(50)		= NULL
	,@district							INT				= NULL
	,@city                              VARCHAR(50)		= NULL
	,@email                             VARCHAR(150)	= NULL
	,@homePhone                         VARCHAR(15)		= NULL
	,@workPhone                         VARCHAR(15)		= NULL
	,@mobile                            VARCHAR(15)		= NULL
	,@nativeCountry                     INT				= NULL
	,@dob                               DATETIME		= NULL
	,@customerType                      INT				= NULL
	,@occupation						INT				= NULL
	,@isBlackListed						CHAR(1)			= NULL
	
	,@pSuperAgent						INT				= NULL
	,@pCountry							INT				= NULL
	,@pState							INT				= NULL
	,@pDistrict							INT				= NULL
	
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
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
		
	SELECT
		 @logIdentifier = 'customerId'
		,@logParamMain = 'customers'		
		,@module = '20'
		,@tableAlias = 'Customers'
	
	IF @flag = 'a'
	BEGIN
		SELECT c.*
				,Convert(VARCHAR,c.dob,101)dob1
				,ci.idType
				,ci.idNumber
				,CONVERT(VARCHAR,ci.validDate,101)validDate1
				,CONVERT(VARCHAR,ci.issuedDate,101)issueDate1
			FROM customers c 
			LEFT JOIN customerIdentity ci WITH(NOLOCK)
			ON c.customerId =  ci.customerId
		WHERE c.customerId = @customerId
	END	
	ELSE IF @flag = 'u'
	BEGIN
		DECLARE 
			 @oFirstName                        VARCHAR(50)	
			,@oMiddleName						VARCHAR(50)		
			,@oLastName1						VARCHAR(50)	
			,@oLastName2						VARCHAR(50)	
			,@oCountry							INT				
			,@oAddress                          VARCHAR(100)	
			,@oState                            VARCHAR(50)	
			,@oZipCode                          VARCHAR(50)	
			,@oDistrict							INT				
			,@oCity                             VARCHAR(50)	
			,@oEmail                            VARCHAR(150)	
			,@oHomePhone                        VARCHAR(15)	
			,@oWorkPhone                        VARCHAR(15)	
			,@oMobile                           VARCHAR(15)	
			,@oNativeCountry                    INT			
			,@oDob                              DATETIME		
			,@oCustomerType                     INT			
			,@oOccupation						INT	
			,@srType							VARCHAR(20)	
			
			,@oCountryText						VARCHAR(50)
			,@oStateText						VARCHAR(50)
			,@oDistrictText						VARCHAR(50)	
			,@oNativeCountryText				VARCHAR(50)
			,@oCustomerTypeText					VARCHAR(50)
			,@oOccupationText					VARCHAR(50)
			
			,@nCountryText						VARCHAR(50)
			,@nStateText						VARCHAR(50)
			,@nDistrictText						VARCHAR(50)	
			,@nNativeCountryText				VARCHAR(50)
			,@nCustomerTypeText					VARCHAR(50)
			,@nOccupationText					VARCHAR(50) 
		
		BEGIN TRANSACTION
			SELECT 
				 @oFirstName = firstName
				,@oMiddleName = middleName
				,@oLastName1 = lastName1
				,@oLastName2 = lastName2
				,@oCountry = country
				,@oAddress = address
				,@oState = state
				,@oZipCode = zipCode
				,@oDistrict = district
				,@oCity = city
				,@oEmail = email
				,@oHomePhone = homePhone
				,@oWorkPhone = workPhone
				,@oNativeCountry = nativeCountry
				,@oDob = dob
				,@oCustomerType = customerType
				,@oOccupation = occupation  
			FROM customers WHERE customerId = @customerId
			
			SELECT @oCountryText = countryName FROM countryMaster WHERE countryId = @oCountry
			SELECT @oStateText = stateName FROM countryStateMaster WHERE stateId = @oState
			SELECT @oDistrictText = detailTitle FROM staticDataValue WHERE valueId = @oDistrict
			SELECT @oNativeCountryText = countryName FROM countryMaster WHERE countryId = @oNativeCountry
			SELECT @oCustomerTypeText = detailTitle FROM staticDataValue WHERE valueId = @oCustomerType
			SELECT @oOccupationText = detailTitle FROM staticDataValue WHERE valueId = @oOccupation
			
			SELECT @nCountryText = countryName FROM countryMaster WHERE countryId = @country
			SELECT @nStateText = stateName FROM countryStateMaster WHERE stateId = @state
			SELECT @nDistrictText = detailTitle FROM staticDataValue WHERE valueId = @district
			SELECT @nNativeCountryText = countryName FROM countryMaster WHERE countryId = @nativeCountry
			SELECT @nCustomerTypeText = detailTitle FROM staticDataValue WHERE valueId = @customerType
			SELECT @nOccupationText = detailTitle FROM staticDataValue WHERE valueId = @occupation
			
			SELECT @srType = CASE WHEN @srFlag = 'S' THEN 'Sender' 
									WHEN @srFlag = 'R' THEN 'Receiver' END
			
			IF(ISNULL(@oFirstName, 0) <> ISNULL(@firstName, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' First Name changed from ' + ISNULL(@oFirstName, 'NULL') + ' to ' + ISNULL(@firstName, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET firstName = @firstName WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET firstName = @firstName WHERE customerId = @customerId AND tranId = @tranId
			END	
			
			IF(ISNULL(@oMiddleName, 0) <> ISNULL(@middleName, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Middle Name changed from ' + ISNULL(@oMiddleName, 'NULL') + ' to ' + ISNULL(@middleName, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET middleName = @middleName WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET middleName = @middleName WHERE customerId = @customerId AND tranId = @tranId
			END	
			
			IF(ISNULL(@oLastName1, 0) <> ISNULL(@lastName1, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' First Last Name changed from ' + ISNULL(@oLastName1, 'NULL') + ' to ' + ISNULL(@lastName1, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET lastName1 = @lastName1 WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET lastName1 = @lastName2 WHERE customerId = @customerId AND tranId = @tranId
			END
			
			IF(ISNULL(@oLastName2, 0) <> ISNULL(@lastName2, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Second Last Name changed from ' + ISNULL(@oLastName2, 'NULL') + ' to ' + ISNULL(@lastName2, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET lastName2 = @lastName2 WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET lastName2 = @lastName2 WHERE customerId = @customerId AND tranId = @tranId
			END
			
			IF(ISNULL(@oCountry, 0) <> ISNULL(@country, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Country changed from ' + ISNULL(@oCountry, 'NULL') + ' to ' + ISNULL(@country, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET country = @nCountryText WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET country = @nCountryText WHERE customerId = @customerId AND tranId = @tranId
			END
			
			IF(ISNULL(@oAddress, 0) <> ISNULL(@address, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Address changed from ' + ISNULL(@oAddress, 'NULL') + ' to ' + ISNULL(@address, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET address = @address WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET address = @address WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oState, 0) <> ISNULL(@state, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' State changed from ' + ISNULL(@oStateText, 'NULL') + ' to ' + ISNULL(@nStateText, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET state = @nStateText WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET state = @nStateText WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oZipCode, 0) <> ISNULL(@zipCode, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Zip Code changed from ' + ISNULL(@oZipCode, 'NULL') + ' to ' + ISNULL(@zipCode, 'NULL'), @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET zipCode = @zipCode WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET zipCode = @zipCode WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oDistrict, 0) <> ISNULL(@district, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' District changed from ' + @oDistrictText + ' to ' + @nDistrictText, @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET district = @nDistrictText WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET district = @nDistrictText WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oCity, 0) <> ISNULL(@city, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' City', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET city = @city WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET city = @city WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oEmail, 0) <> ISNULL(@email, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Email', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET email = @email WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET email = @email WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oHomePhone, 0) <> ISNULL(@homePhone, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Home Phone', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET homePhone = @homePhone WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET homePhone = @homePhone WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oWorkPhone, 0) <> ISNULL(@workPhone, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Work Phone', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET workPhone = @workPhone WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET workPhone = @workPhone WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oNativeCountry, 0) <> ISNULL(@nativeCountry, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' First Name', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET nativeCountry = @nativeCountry WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET nativeCountry = @nativeCountry WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oDob, 0) <> ISNULL(@dob, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Date of Birth', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET dob = @dob WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET dob = @dob WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oCustomerType, 0) <> ISNULL(@customerType, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Customer Type', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET customerType = @nCustomerTypeText WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET customerType = @nCustomerTypeText WHERE customerId = @customerId AND tranId = @tranId
			END
			IF(ISNULL(@oOccupation, 0) <> ISNULL(@occupation, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, @srType + ' Occupation', @user, GETDATE(),'M'
				
				IF(@srFlag = 'S')
					UPDATE tranSenders SET occupation = @nOccupationText WHERE customerId = @customerId AND tranId = @tranId
				ELSE IF(@srFlag = 'R')
					UPDATE tranReceivers SET occupation = @nOccupationText WHERE customerId = @customerId AND tranId = @tranId
			END

			UPDATE customers SET
				 membershipId			= @membershipId
				,firstName				= @firstName
				,middleName				= @middleName
				,lastName1				= @lastName1
				,lastName2				= @lastName2
				,country				= @country
				,[address]				= @address
				,[state]				= @state
				,zipCode				= @zipCode
				,district				= @district
				,city					= @city
				,email					= @email
				,homePhone				= @homePhone
				,workPhone				= @workPhone
				,mobile					= @mobile
				,nativeCountry			= @nativeCountry
				,dob					= @dob
				,placeOfIssue			= @placeOfIssue
				,customerType			= @customerType
				,occupation				= @occupation
				,isBlackListed			= @isBlackListed
				,modifiedBy				= @user
				,modifiedDate			= GETDATE()
			WHERE customerId = @customerId
			
			UPDATE remitTran SET
				 modifiedBy				= @user
				,modifiedDate			= GETDATE()
				,modifiedDateLocal		= DBO.FNADateFormatTZ(GETDATE(), @user)
			WHERE id = @tranId

			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
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
	END
	ELSE IF @flag = 'log'
	BEGIN
		SELECT * FROM tranModifyLog WHERE tranId = @tranId
	END
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'customerId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					main.customerId
					,main.membershipId
					,name = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName1, '''') + ISNULL( '' '' + main.lastName2, '''')
					,main.firstName
					,main.lastName2
					,country = ccm1.countryName
					,main.address
					,main.state
					,main.zipCode
					,main.district
					,main.city
					,main.email
					,main.homePhone
					,main.workPhone
					,main.mobile
					,nativeCountry = ccm.countryName
					,main.dob
					,main.placeOfIssue
					,main.customerType
					,main.occupation
					,isBlackListed = CASE WHEN main.isBlackListed = ''Y'' THEN ''Yes'' ELSE ''-'' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM customers main WITH(NOLOCK)
				LEFT JOIN countryMaster ccm ON main.nativeCountry = ccm.countryId
				LEFT JOIN countryMaster ccm1 ON main.country = ccm1.countryId
					WHERE 1 = 1 
					) x'
					
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF(@firstName IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND ISNULL(firstName, '''') LIKE ''%' + @firstName + '%'''
		
		IF(@lastName2 IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND ISNULL(lastName1, '''') LIKE ''%' + @lastName1 + '%'''
		
		IF(@membershipId IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND membershipId = ' + CAST(@membershipId AS VARCHAR)
		
		IF(@mobile IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND ISNULL(mobile, '''') LIKE ''%' + @mobile + '%'''
		
		SET @select_field_list ='
			 customerId
			,membershipId
			,name
			,address
			,country
			,state
			,zipCode
			,district
			,city
			,email
			,homePhone
			,workPhone
			,mobile
			,nativeCountry
			,dob
			,placeOfIssue
			,customerType
			,occupation
			,isBlackListed
			,createdBy
			,createdDate
			,isDeleted '
			
		EXEC dbo.proc_paging
			@table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
	END
	ELSE IF @flag = 'cc'		--Change Customer
	BEGIN
		DECLARE 
			 @oldName VARCHAR(100)
			,@newName VARCHAR(100)
		BEGIN TRANSACTION
			
			SELECT @srType = CASE WHEN @srFlag = 'S' THEN 'Sender' 
									WHEN @srFlag = 'R' THEN 'Receiver' END
			SELECT 
				@oldName = firstName + ISNULL(' ' + middleName,'') + ISNULL(' ' + lastName1,'') + ISNULL(' ' + lastName2,'') + '|' + membershipId
			FROM customers WHERE customerId = @oldCustomerId
			
			SELECT
				@newName = firstName + ISNULL(' ' + middleName,'') + ISNULL(' ' + lastName1,'') + ISNULL(' ' + lastName2,'') + '|' + membershipId
			FROM customers WHERE customerId = @customerId						
			
			INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
			SELECT @tranId, @srType + ' changed from ' + @oldName + ' to ' + @newName, @user, GETDATE(),'M'
			
			IF @srFlag = 'S'
			BEGIN
				UPDATE tranSenders SET
					 customerId			= new.customerId
					,firstName			= new.firstName
					,middleName			= new.middleName
					,lastName1			= new.lastName1
					,lastName2			= new.lastName2
					,country			= cm.countryName
					,state				= csm.stateName
					,district			= dist.detailTitle
					,zipCode			= new.zipCode
					,city				= new.city
					,address			= new.address
					,homePhone			= new.homePhone
					,workPhone			= new.workPhone
					,dob				= new.dob
					,membershipId		= new.membershipId
					,placeOfIssue		= new.placeOfIssue
					,nativeCountry		= nc.countryName
					,mobile				= new.mobile
					,email				= new.email
					,customerType		= ct.detailTitle
					,occupation			= occ.detailTitle
					,idType			= cid.detailTitle
					,idNumber			= ci.idNumber
					,idPlaceOfIssue	= ci.placeOfIssue
					,issuedDate		= ci.issuedDate
					,validDate			= ci.validDate
				FROM customers new 
				LEFT JOIN customerIdentity ci ON new.customerId = ci.customerId AND ci.isPrimary = 'Y'
				LEFT JOIN countryMaster cm ON new.country = cm.countryId
				LEFT JOIN countryMaster nc ON new.nativeCountry = nc.countryId
				LEFT JOIN countryStateMaster csm ON new.state = csm.stateId
				LEFT JOIN staticDataValue dist ON new.district = dist.valueId
				LEFT JOIN staticDataValue ct ON new.customerType = ct.valueId
				LEFT JOIN staticDataValue occ ON new.occupation = occ.valueId
				LEFT JOIN staticDataValue cid ON ci.idType = cid.valueId
					WHERE new.customerId = @customerId AND tranId = @tranId
			END
			ELSE IF @srFlag = 'R'
			BEGIN
				UPDATE tranReceivers SET
					 customerId			= new.customerId
					,firstName			= new.firstName
					,middleName			= new.middleName
					,lastName1			= new.lastName1
					,lastName2			= new.lastName2
					,country			= cm.countryName
					,state				= csm.stateName
					,district			= dist.detailTitle
					,zipCode			= new.zipCode
					,city				= new.city
					,address			= new.address
					,homePhone			= new.homePhone
					,workPhone			= new.workPhone
					,dob				= new.dob
					,membershipId		= new.membershipId
					,placeOfIssue		= new.placeOfIssue
					,nativeCountry		= nc.countryName
					,mobile				= new.mobile
					,email				= new.email
					,customerType		= ct.detailTitle
					,occupation			= occ.detailTitle
					,idType			= cid.detailTitle
					,idNumber			= ci.idNumber
					,idPlaceOfIssue	= ci.placeOfIssue
					,issuedDate		= ci.issuedDate
					,validDate			= ci.validDate
				FROM customers new 
				LEFT JOIN customerIdentity ci ON new.customerId = ci.customerId AND ci.isPrimary = 'Y'
				LEFT JOIN countryMaster cm ON new.country = cm.countryId
				LEFT JOIN countryMaster nc ON new.nativeCountry = nc.countryId
				LEFT JOIN countryStateMaster csm ON new.state = csm.stateId
				LEFT JOIN staticDataValue dist ON new.district = dist.valueId
				LEFT JOIN staticDataValue ct ON new.customerType = ct.valueId
				LEFT JOIN staticDataValue occ ON new.occupation = occ.valueId
				LEFT JOIN staticDataValue cid ON ci.idType = cid.valueId
					WHERE new.customerId = @customerId AND tranId = @tranId
			END
			
			UPDATE remitTran SET
				 modifiedBy				= @user
				,modifiedDate			= GETDATE()
				,modifiedDateLocal		= DBO.FNADateFormatTZ(GETDATE(), @user)
			WHERE id = @tranId
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record updated successfully.', @customerId
	END 
	ELSE IF @flag = 'ca'		--Change Payout Location
	BEGIN
		DECLARE
			 @oPSuperAgentText	VARCHAR(50) = NULL
			,@oPCountryText		VARCHAR(50)	= NULL
			,@oPStateText		VARCHAR(50)	= NULL
			,@oPDistrictText	VARCHAR(50) = NULL
			
			,@nPSuperAgentText	VARCHAR(50) = NULL
			,@nPCountryText		VARCHAR(50)	= NULL
			,@nPStateText		VARCHAR(50)	= NULL
			,@nPDistrictText	VARCHAR(50) = NULL
			
			,@oServiceCharge	MONEY		= NULL
			,@nServiceCharge	MONEY		= NULL
			,@sBranch			INT			= NULL
			,@deliveryMethod	INT			= NULL
			,@amount			MONEY		= NULL
		
		SELECT
			 @sBranch = trn.sBranch
			,@oServiceCharge = trn.serviceCharge
			,@deliveryMethod = trn.paymentMethod
			,@amount = trn.tAmt
			,@oPSuperAgentText = psa.agentName
			,@oPCountryText = pc.countryName
			,@oPStateText = ps.stateName
			,@oPDistrictText = pdist.districtName
		FROM remitTran trn WITH(NOLOCK)
		LEFT JOIN agentMaster psa WITH(NOLOCK) ON trn.pSuperAgent = psa.agentId
		LEFT JOIN countryMaster pc WITH(NOLOCK) ON trn.pCountry = pc.countryId
		LEFT JOIN countryStateMaster ps WITH(NOLOCK) ON trn.pState = ps.stateId
		LEFT JOIN zoneDistrictMap pdist WITH(NOLOCK) ON trn.pDistrict = pdist.districtId
		WHERE trn.id = @tranId
		
		SELECT @nPSuperAgentText = agentName FROM agentMaster WHERE agentId = @pSuperAgent
		SELECT @nPCountryText = countryName FROM countryMaster WHERE countryId = @pCountry
		SELECT @nPStateText = stateName FROM countryStateMaster WHERE stateId = @pState
		SELECT @nPDistrictText = districtName FROM zoneDistrictMap WHERE districtId = @pDistrict
		
		SELECT 
			 @nServiceCharge = amount
		FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountry, @pDistrict, NULL , @deliveryMethod, @amount, NULL)	
		
		IF @oServiceCharge <> @nServiceCharge
		BEGIN
			EXEC proc_errorHandler 1, 'Operation failed! Service Charge is different for this location', @tranId
			RETURN
		END
		BEGIN TRANSACTION
			
			IF(ISNULL(@oPSuperAgentText, 0) <> ISNULL(@nPSuperAgentText, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, 'Payout Super Agent changed from ' + ISNULL(@oPSuperAgentText, 'NULL') + ' to ' + ISNULL(@nPSuperAgentText, 'NULL'), @user, GETDATE(),'M'
				
				UPDATE remitTran SET pSuperAgent = @pSuperAgent WHERE id = @tranId
			END
			IF(ISNULL(@oPCountryText, 0) <> ISNULL(@nPCountryText, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, 'Payout Country changed from ' + ISNULL(@oPCountryText, 'NULL') + ' to ' + ISNULL(@nPCountryText, 'NULL'), @user, GETDATE(),'M'
				
				UPDATE remitTran SET pCountry = @pCountry WHERE id = @tranId
			END
			IF(ISNULL(@oPStateText, 0) <> ISNULL(@nPStateText, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, 'Payout State changed from ' + ISNULL(@oPStateText, 'NULL') + ' to ' + ISNULL(@nPStateText, 'NULL'), @user, GETDATE(),'M'	
				
				UPDATE remitTran SET pState = @pState WHERE id = @tranId
			END
			IF(ISNULL(@oPDistrictText, 0) <> ISNULL(@nPDistrictText, 0))
			BEGIN
				INSERT INTO tranModifyLog(tranId, message, createdBy, createdDate,MsgType)
				SELECT @tranId, 'Payout District changed from ' + ISNULL(@oPDistrictText, 'NULL') + ' to ' + ISNULL(@nPDistrictText, 'NULL'), @user, GETDATE(),'M'
				
				UPDATE remitTran SET pDistrict = @pDistrict WHERE id = @tranId
			END
			
			UPDATE remitTran SET
				 modifiedBy				= @user
				,modifiedDate			= GETDATE()
				,modifiedDateLocal		= DBO.FNADateFormatTZ(GETDATE(), @user)
			WHERE id = @tranId	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Payout Location Updated Successfully.', @customerId
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
