USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customersUpload]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_customersUpload]
 	 @flag                          VARCHAR(50)		= NULL
	,@user                          VARCHAR(50)		= NULL
	,@xml							XML				= NULL
	,@sortBy                        VARCHAR(50)		= NULL
	,@sortOrder                     VARCHAR(5)		= NULL
	,@gender	                    VARCHAR(10)		= NULL
	,@pageSize                      INT				= NULL
	,@pageNumber                    INT				= NULL
	,@searchValue					VARCHAR(200)	= NULL
	,@searchBy						VARCHAR(50)		= NULL
	,@country						INT				= NULL
	,@isBlackList					CHAR(1)			= NULL

	,@customerId                        VARCHAR(30)		= NULL
	,@agentId	                        VARCHAR(30)		= NULL
	,@branchId	                        VARCHAR(30)		= NULL
	,@senderId							VARCHAR(30)		= NULL
	,@membershipId                      VARCHAR(20)		= NULL
	,@placeOfIssue						VARCHAR(50)		= NULL
	,@fullName							VARCHAR(200)	= NULL
	,@firstName                         VARCHAR(50)		= NULL
	,@middleName						VARCHAR(50)		= NULL
	,@lastName1							VARCHAR(50)		= NULL
	,@lastName2							VARCHAR(50)		= NULL
	,@customerIdType					VARCHAR(30)		= NULL
	,@customerIdNo						VARCHAR(50)		= NULL
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
	,@relationId						INT				= NULL
	,@relativeName						VARCHAR(100)	= NULL
	,@companyName						VARCHAR(100)	= NULL
	,@idType							INT				= NULL
	,@idNumber							VARCHAR(200)	= NULL				
	
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
		,@errorMsg			VARCHAR(MAX)
		
	SELECT
		 @logIdentifier = 'customerId'
		,@logParamMain = 'customers'		
		,@module = '20'
		,@tableAlias = 'Customers'
		--ALTER TABLE customers ADD isUploaded CHAR(1)
	IF @flag = 'i'
	BEGIN
		--ALTER TABLE customers ADD isUploaded CHAR(1)
		DECLARE @temp_table 
		table(
			FirstName VARCHAR(200),MiddleName VARCHAR(200),LastName VARCHAR(200),
			Gender VARCHAR(50),PassportNo VARCHAR(100),Country VARCHAR(100),District VARCHAR(100), CompanyName VARCHAR(200),Email VARCHAR(100)
			)
		INSERT @temp_table(FirstName,MiddleName,LastName,Gender,PassportNo,Country,District,CompanyName,Email)
		SELECT
			p.value('@FirstName','VARCHAR(200)'),
			p.value('@MiddleName','VARCHAR(200)'),
			p.value('@LastName','VARCHAR(200)'),
			p.value('@Gender','VARCHAR(50)'),
			p.value('@PassportNo','VARCHAR(100)'),
			p.value('@Country','VARCHAR(100)'),
			p.value('@District','VARCHAR(200)'),
			p.value('@CompanyName','VARCHAR(200)'),
			p.value('@Email','VARCHAR(200)')
		FROM @xml.nodes('/root/row') as tmp(p)
		BEGIN TRANSACTION
			INSERT INTO dbo.customers(firstName,middleName,lastName1,country,address,idType,idNumber,gender,companyName,email,isUploaded,customerType,fullName)
			SELECT FirstName,MiddleName,LastName,CASE WHEN country ='Nepal' THEN 151 ELSE NULL END,District, '1302',PassportNo,
				CASE WHEN Gender ='Male' THEN 1801 ELSE '1802' END,CompanyName,Email,'Y','4700',
				ISNULL(firstName, '') + ISNULL( ' ' + middleName, '')+ ISNULL( ' ' + LastName, '') 
			FROM @temp_table 
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @user
	END
	IF @flag = 's'
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
					,main.lastName1
					,main.middleName
					,country = ccm1.countryName
					,main.address
					,main.state
					,main.zipCode
					,main.district
					,main.city
					,main.email
					,main.companyName
					,idType = sdv.detailTitle
					,main.idNumber
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
					,isBlackListed1 = main.isBlackListed
					,countryId = main.country
				FROM customers main WITH(NOLOCK)
				LEFT JOIN countryMaster ccm ON main.nativeCountry = ccm.countryId
				LEFT JOIN countryMaster ccm1 ON main.country = ccm1.countryId
				LEFT JOIN staticDataValue sdv with(nolock) on sdv.valueId = main.idType 
				WHERE 1 = 1 AND ISNULL(main.isDeleted, '''') <> ''Y'' AND isUploaded = ''Y'' 
				) x'
					
		SET @sql_filter = ''
		
		if @searchBy is not null and @searchValue is null
			SET @sql_filter = @sql_filter + ' and 1=2'

		if @country is not null
			SET @sql_filter = @sql_filter + ' and countryId = ''' + cast(@country as varchar) + ''''

		IF @searchBy = 'name' and @searchValue IS NOT NULL 
			SET @sql_filter = @sql_filter + ' and name LIKE ''%' + @searchValue + '%'''

			
		IF @searchBy = 'mobile' and @searchValue IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(mobile, '''') = ''' + @searchValue + ''''
		
		IF @searchBy IN ('membershipId','PassportNo','NRIC') AND @searchValue IS NOT NULL 
			SET @sql_filter = @sql_filter + ' AND (membershipId = ''' + CAST(@searchValue AS VARCHAR) + ''' or idNumber = ''' + CAST(@searchValue AS VARCHAR) + ''')'

		
		SET @select_field_list ='
		
			 customerId
			,membershipId
			,name
			,address
			,country
			,idType
			,idNumber
			,district
			,city
			,email
			,companyName
			,homePhone
			,workPhone
			,mobile'
			
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
	IF @flag = 'u'		
	BEGIN
		IF @mobile IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Mobile Number', NULL
			RETURN
		END
		IF (YEAR(GETDATE()) - YEAR(@dob) < 16) 
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Not Eligible', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customers WHERE customerId <> @customerId AND membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Membership Id already in use', @customerId
			RETURN
		END
		BEGIN TRANSACTION

			UPDATE customers SET
				firstName				= @firstName
				,middleName				= @middleName
				,lastName1				= @lastName1
				,lastName2				= @lastName2
				,fullName				= @firstName + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')
				,country				= @country
				,[address]				= @address
				,[STATE]				= @state
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
				,isBlackListed			= @isBlackList
				,relationId				= @relationId
				,relativeName			= @relativeName
				,modifiedBy				= @user
				,modifiedDate			= GETDATE()
				,gender					= @gender
				,companyName			= @companyName
				,agentId				= @agentId
				,branchId				= @branchId
				,idType					= @idType
				,idNumber				= @idNumber
			WHERE customerId = @customerId
			
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
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH



GO
