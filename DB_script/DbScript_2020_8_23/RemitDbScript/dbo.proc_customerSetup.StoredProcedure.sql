USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerSetup]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_customerSetup]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@customerId                        VARCHAR(30)		= NULL
	,@fullName							VARCHAR(200)	= NULL
	,@passportNo                        VARCHAR(30)		= NULL
	,@mobile							VARCHAR(30)		= NULL
	,@firstName							VARCHAR(100)	= NULL
	,@middleName						VARCHAR(100)	= NULL
	,@lastName1							VARCHAR(100)	= NULL
	,@lastName2							VARCHAR(100)	= NULL
	,@customerIdType					VARCHAR(30)		= NULL
	,@customerIdNo						VARCHAR(50)		= NULL
	,@custIdValidDate					VARCHAR(30)		= NULL
	,@custDOB							VARCHAR(30)		= NULL
	,@custTelNo							VARCHAR(30)		= NULL
	,@custMobile						VARCHAR(30)		= NULL
	,@custCity							VARCHAR(100)	= NULL
	,@custPostal						VARCHAR(30)		= NULL
	,@companyName						VARCHAR(100)	= NULL
	,@custAdd1							VARCHAR(100)	= NULL
	,@custAdd2							VARCHAR(100)	= NULL
	,@country							VARCHAR(30)		= NULL
	,@custNativecountry					VARCHAR(30)		= NULL
	,@custEmail							VARCHAR(50)		= NULL
	,@custGender						VARCHAR(30)		= NULL
	,@custSalary						VARCHAR(30)		= NULL
	,@memberId							VARCHAR(30)		= NULL
	,@occupation						VARCHAR(30)		= NULL
	,@state								VARCHAR(30)		= NULL
	,@zipCode							VARCHAR(30)		= NULL
	,@district							VARCHAR(30)		= NULL
	,@homePhone							VARCHAR(30)		= NULL
	,@workPhone							VARCHAR(30)		= NULL
	,@placeOfIssue						VARCHAR(30)		= NULL
	,@customerType						VARCHAR(30)		= NULL
	,@isBlackListed						VARCHAR(30)		= NULL
	,@relativeName						VARCHAR(30)		= NULL
	,@relationId						VARCHAR(30)		= NULL	
	,@lastTranId						VARCHAR(30)		= NULL
	,@receiverName						VARCHAR(100)	= NULL
	,@tranId							VARCHAR(20)		= NULL
	,@ICN								VARCHAR(50)		= NULL
	,@bank								VARCHAR(100)	= NULL
	,@mapCodeInt						VARCHAR(10)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@isMemberIssued					CHAR(1)			= NULL
	,@agent								VARCHAR(50)		= NULL
	,@branch							VARCHAR(50)		= NULL
	,@branchId							VARCHAR(50)		= NULL

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

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
		 
	IF @flag = 'idType'
	BEGIN
		SELECT [value], [text] FROM (
			SELECT NULL [value], 'Select' [text] UNION ALL
			
			SELECT 
			 [value]		= SV.valueId
			,[text]		= SV.detailTitle
		FROM countryIdType CID WITH(NOLOCK)
		INNER JOIN staticDataValue SV WITH(NOLOCK) ON CID.IdTypeId = SV.valueId
		WHERE countryId = @country AND ISNULL(isDeleted, 'N') = 'N'
		AND (spFlag IS NULL OR ISNULL(spFlag, 0) = 5200)
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END	
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF @customerIdType IS NOT NULL
			SELECT @customerIdType = value FROM dbo.Split('|', @customerIdType) WHERE id = 1
		 
		IF EXISTS(SELECT 'X' FROM customers WHERE membershipId = @memberId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Membership Id already in use', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customers WHERE mobile = @custMobile AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			SELECT @errorMsg = 'Customer with mobile number ' + @custMobile + ' already exist'
			EXEC proc_errorHandler 1, @errorMsg, @customerId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO customers (
					  membershipId
					,firstName
					,middleName
					,lastName1
					,lastName2
					,country
					,[address]
					,[state]
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
					,lastTranId
					,relationId
					,relativeName
					,gender
					,companyName
					,salaryRange
					,address2
					,fullName					
					,createdBy
					,createdDate
					,postalCode 
					,idExpiryDate
					,idType
					,idNumber
					,telNo
					,memberIDissuedDate
					,memberIDissuedByUser
					,memberIDissuedAgentId
					,memberIDissuedBranchId
					,agentId
					,branchId
					
			)
			SELECT  
				 --@memberId
				 CASE WHEN @isMemberIssued ='Y' THEN @memberId ELSE NULL END
				,@firstName
				,@middleName
				,@lastName1
				,@lastName2
				,@country
				,@custAdd1	
				,@state
				,@zipCode
				,@district
				,@custCity
				,@custEmail
				,@homePhone
				,@workPhone
				,@custMobile
				,@custNativecountry
				,@custDOB
				,@placeOfIssue
				,@customerType
				,@occupation
				,@isBlackListed
				,@lastTranId
				,@relationId
				,@relativeName
				,@custGender
				,@companyName
				,@custSalary
				,@custAdd2
				,ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')				
				,@user
				,GETDATE()
				,@custPostal
				,@custIdValidDate
				,@customerIdType
				,@customerIdNo
				,@custTelNo
				,CASE WHEN @isMemberIssued ='Y' THEN GETDATE() ELSE NULL END
				,CASE WHEN @isMemberIssued ='Y' THEN @user ELSE NULL END
				,CASE WHEN @isMemberIssued ='Y' THEN @agent  ELSE NULL END
				,CASE WHEN @isMemberIssued ='Y' THEN @branch  ELSE NULL END
				,@agent
				,@branch
				
			SET @customerId = SCOPE_IDENTITY()
			
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
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
		
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'customerId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '
				SELECT
					 main.customerId
					,main.membershipId
					,name = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName1, '''') + ISNULL( '' '' + main.lastName2, '''')
					,companyName = main.companyName
					,main.firstName
					,main.lastName1
					,main.middleName
					,country = ccm1.countryName
					,address = main.address
					,main.state
					,main.zipCode
					,main.district
					,main.city
					,main.email
					,idType = sdv.detailTitle
					,passportNo = main.idNumber
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
					,lastIdUploadDate
				FROM customers main WITH(NOLOCK)
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.idType = sdv.valueId
				LEFT JOIN countryMaster ccm WITH(NOLOCK) ON main.nativeCountry = ccm.countryId
				LEFT JOIN countryMaster ccm1 WITH(NOLOCK) ON main.country = ccm1.countryId
				LEFT JOIN (
					SELECT customerId, MAX(createdDate) as lastIdUploadDate FROM customerDocument WITH(NOLOCK) GROUP BY customerId
					)cusDoc on cusDoc.customerId = main.customerId
				WHERE ISNULL(main.isDeleted, ''N'') = ''N'' '

		IF @passportNo IS NOT NULL 
			SET @table = @table + ' AND ISNULL(main.idNumber, '''') = ''' + @passportNo + ''''
		
		IF @customerIdType IS NOT NULL AND @customerIdNo IS NOT NULL
			SET @table = @table + ' AND ISNULL(main.idType, 0) = ' + @customerIdType + ' AND ISNULL(main.idNumber, '''') = ''' + @customerIdNo + ''''
		
		IF @memberId IS NOT NULL
			SET @table = @table + ' AND ISNULL(main.membershipId, '''') = ''' + @memberId + ''''
		
		IF @country IS NOT NULL
			SET @table = @table + ' AND ISNULL(main.country, '''') = ''' + @country + ''''
		
		IF @mobile IS NOT NULL
			SET @table = @table + ' AND ISNULL(main.mobile, '''') = ''' + @mobile + ''''
					
		SET @sql_filter = ''

		SET @sql = '('+ @table+')X'
    

		IF @fullName IS NOT NULL 
			SET @sql_filter = @sql_filter + ' and name LIKE ''%' + @fullName + '%'''
		
		IF (@fullName IS NULL AND @passportNo IS NULL AND @mobile IS NULL)
		SET @sql_filter = @sql_filter + ' AND 1<>1'
		
		--PRINT @sql

		SET @select_field_list ='
			 customerId
			,membershipId
			,name
			,companyName
			,address
			,country
			,state
			,zipCode
			,district
			,city
			,email
			,idType
			,passportNo
			,mobile
			,nativeCountry
			,dob
			,placeOfIssue
			,customerType
			,occupation
			,isBlackListed
			,createdBy
			,createdDate
			,isDeleted 
			,lastIdUploadDate'
			
		EXEC dbo.proc_paging
			 @sql
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		IF @customerIdType IS NOT NULL
			SELECT @customerIdType = value FROM dbo.Split('|', @customerIdType) WHERE id = 1
		IF (YEAR(GETDATE()) - YEAR(@custDOB) < 16) 
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Not Eligible', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customers WHERE customerId <> @customerId AND membershipId = @memberId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Membership Id already in use', @customerId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customers WHERE customerId <> @customerId AND mobile = @mobile AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			SELECT @errorMsg = 'Customer with mobile number ' + @mobile + ' already exist'
			EXEC proc_errorHandler 1, @errorMsg, @customerId
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE customers SET
				    
					firstName		= @firstName
					,middleName		= @middleName
					,lastName1		= @lastName1
					,lastName2		= @lastName2
					--,country		= @country
					,[address]		= @custAdd1
					,[state]		= @state
					,zipCode		= @zipCode
					,district		= @district
					,city			= @custCity
					,email			= @custEmail
					,homePhone		= @homePhone
					,workPhone		= @workPhone
					,mobile			= @custMobile
					,nativeCountry	= @custNativecountry
					,dob			= @custDOB
					,placeOfIssue	= @placeOfIssue
					,customerType	= @customerType
					,occupation		= @occupation
					,isBlackListed	= @isBlackListed			
					,lastTranId		= @lastTranId
					,relationId		= @relationId
					,relativeName	= @relativeName
					,gender			= @custGender
					,companyName	= @companyName
					,salaryRange	= @custSalary
					,address2		= @custAdd2
					,fullName		= ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')			
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()
					,postalCode		= @custPostal
					,idExpiryDate	= @custIdValidDate
					,idType			= @customerIdType
					,idNumber		= @customerIdNo
					,telNo			= @custTelNo 
					,membershipId		=  CASE WHEN @isMemberIssued ='Y' AND membershipId IS NULL THEN @memberId ELSE membershipId END
					,memberIDissuedDate  = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedDate IS NULL THEN GETDATE() ELSE memberIDissuedDate END
					,memberIDissuedByUser = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedByUser IS NULL THEN @user ELSE memberIDissuedByUser END
					,memberIDissuedAgentId = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedAgentId IS NULL THEN @agent ELSE memberIDissuedAgentId END
					,memberIDissuedBranchId = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedBranchId IS NULL THEN @branch ELSE memberIDissuedAgentId END
					,agentId		= @agent
					,branchId		= @branch
					
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
		SELECT '0' errCode , 'Record updated successfully.' msg , @customerId id
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			 idExpiryDate = CONVERT(VARCHAR,c.idExpiryDate,101)
			,dob = CONVERT(VARCHAR,c.dob,101)
			,idType1		= CAST(SV.valueId AS VARCHAR) + '|' + ISNULL(CID.expiryType, 'E')
			,c.*
		FROM customers c WITH(NOLOCK)		
		LEFT JOIN staticDataValue SV WITH(NOLOCK) ON c.IdType = SV.valueId
		LEFT JOIN countryIdType CID WITH(NOLOCK) ON CID.IdTypeId = SV.valueId
		WHERE c.customerId = @customerId

		--SELECT 
		--	 idExpiryDate = CONVERT(VARCHAR,c.idExpiryDate,101)
		--	,dob = CONVERT(VARCHAR,c.dob,101)
		--	,Convert(VARCHAR,c.dob,101)dob
		--	,ci.idType
		--	,ci.idNumber
		--	,c.*
		--FROM customers c 
		--   LEFT JOIN (SELECT * FROM customerIdentity ci WITH(NOLOCK) where ISNULL(isPrimary,'N')='Y' AND customerId = @customerId)ci
		--   ON c.customerId =  ci.customerId
		--WHERE c.customerId = @customerId
  
	END	
	
	ELSE IF @flag = 'd'
	BEGIN
		UPDATE customers SET
			     isDeleted	= 'Y'
			WHERE customerId = @customerId
		SET @modType = 'delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @customerId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @customerId
				RETURN
			END
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @customerId
		RETURN
	END	
	
	ELSE IF @flag = 'custImage'
	BEGIN			
			SELECT TOP 1
				  customerId
				 ,fileName
			FROM customerDocument
			WHERE 
			customerId = @customerId
			AND ISNULL(isDeleted,'N')<>'Y'
			ORDER BY createdDate DESC
	END

	ELSE IF @flag = 'custHistory'
	BEGIN
	
		SET @sortBy = 'tranId'
		SET @sortOrder = 'desc'

		SET @table = '
			SELECT 
				 tranId					= ms.Tranno
				,receiverName			= ms.ReceiverName 
				,tAmt					= ms.paidAmt
				,createdDate			= CONVERT(VARCHAR , ms.confirmDate, 101)
				,ICN					= ''<a href=#><span onclick ="ViewTranDetail('' +  dbo.FNADecryptString(ms.refno) + '');">'' + dbo.FNADecryptString(ms.refno) + ''</span></a>''
				,payMode				= ms.paymentType
				,bank					= ms.rBankName 
				,bankBranch				= ms.rBankBranch 
				,acNo					= ms.rBankACNo
			FROM irh_ime_plus_01.dbo.moneySend ms WITH(NOLOCK)'

		SET @table = @table + ' WHERE ms.senderPassport = ''' + @customerIdNo + ''''
		
		IF @tranId IS NOT NULL
			SET @table = @table + ' AND cast(ms.Tranno as varchar) = ''' + @tranId + ''''
		
		IF @ICN IS NOT NULL
			SET @table = @table + ' AND ms.refno = ''' + dbo.FNAEncryptString(@ICN) + ''''

		IF @receiverName IS NOT NULL
			SET @table = @table + ' AND ms.ReceiverName LIKE ''%' + @receiverName + '%'''

		IF @bank IS NOT NULL
			SET @table = @table + ' AND ms.rBankName LIKE ''%' + @bank + '%'''

		SET @sql_filter = ''
			
		SET @sql = '('+ @table+')X'
		PRINT @sql
		SET @select_field_list ='
								 tranId
								,receiverName
								,tAmt
								,createdDate
								,ICN
								,payMode
								,bank
								,bankBranch
								,acNo'
			
		EXEC dbo.proc_paging
			 @sql
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber



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
