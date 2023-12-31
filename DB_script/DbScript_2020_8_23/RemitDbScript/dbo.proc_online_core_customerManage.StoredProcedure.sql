USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_core_customerManage]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_online_core_customerManage]  
  @flag						 VARCHAR(50)  = NULL  
 ,@user						 VARCHAR(30)  = NULL  
 ,@customerId				 VARCHAR(30)  = NULL  
 ,@fullName					 NVARCHAR(200)= NULL  
 ,@passportNo                VARCHAR(30)  = NULL  
 ,@mobile					 VARCHAR(15)  = NULL  
 ,@firstName				 VARCHAR(100) = NULL  
 ,@middleName				 VARCHAR(100) = NULL  
 ,@lastName1				 VARCHAR(100) = NULL  
 ,@lastName2				 VARCHAR(100) = NULL  
 ,@customerIdType			 VARCHAR(30)  = NULL  
 ,@customerIdNo				 VARCHAR(50)  = NULL  
 ,@custIdissueDate			 VARCHAR(30)  = NULL  
 ,@custIdValidDate			 VARCHAR(30)  = NULL  
 ,@custDOB					 VARCHAR(30)  = NULL  
 ,@custTelNo				 VARCHAR(30)  = NULL  
 ,@custMobile				 VARCHAR(30)  = NULL  
 ,@custCity					 VARCHAR(100) = NULL  
 ,@custPostal				 VARCHAR(30)  = NULL  
 ,@companyName				 VARCHAR(100) = NULL  
 ,@custAdd1					 VARCHAR(100) = NULL  
 ,@custAdd2					 VARCHAR(100) = NULL  
 ,@country					 VARCHAR(30)  = NULL  
 ,@custNativecountry		 VARCHAR(30)  = NULL  
 ,@custEmail				 VARCHAR(50)  = NULL  
 ,@custGender				 VARCHAR(30)  = NULL  
 ,@custSalary				 VARCHAR(30)  = NULL  
 ,@memberId					 VARCHAR(30)  = NULL  
 ,@occupation				 VARCHAR(30)  = NULL  
 ,@state					 VARCHAR(30)  = NULL  
 ,@zipCode					 VARCHAR(30)  = NULL  
 ,@district					 VARCHAR(30)  = NULL  
 ,@homePhone				 VARCHAR(30)  = NULL  
 ,@workPhone				 VARCHAR(30)  = NULL  
 ,@placeOfIssue				 VARCHAR(30)  = NULL  
 ,@customerType				 VARCHAR(30)  = NULL  
 ,@isBlackListed			 VARCHAR(30)  = NULL  
 ,@relativeName				 VARCHAR(30)  = NULL  
 ,@relationId				 VARCHAR(30)  = NULL   
 ,@lastTranId				 VARCHAR(30)  = NULL  
 ,@receiverName				 VARCHAR(100) = NULL  
 ,@tranId					 VARCHAR(20)  = NULL  
 ,@ICN						 VARCHAR(50)  = NULL  
 ,@bank						 VARCHAR(100) = NULL  
 ,@bankId					 VARCHAR(100) = NULL
 ,@accountNumber			 VARCHAR(100) = NULL
 ,@mapCodeInt				 VARCHAR(10)  = NULL  
 ,@sortBy					 VARCHAR(50)  = NULL  
 ,@sortOrder				 VARCHAR(5)   = NULL  
 ,@pageSize					 INT		  = NULL  
 ,@pageNumber				 INT		  = NULL  
 ,@isMemberIssued			 CHAR(1)	  = NULL  
 ,@agent					 VARCHAR(50)  = NULL  
 ,@branch					 VARCHAR(50)  = NULL  
 ,@branchId					 VARCHAR(50)  = NULL  
 ,@onlineUser				 VARCHAR(50)  = NULL  
 ,@ipAddress				 VARCHAR(30)  = NULL  
 ,@isActive					CHAR(1)      = NULL  
 ,@email					VARCHAR(150) = NULL
 ,@searchCriteria			VARCHAR(30)	  = NULL
 ,@searchValue				VARCHAR(50)	  = NULL
 ,@newPassword				VARCHAR(20)	  =	NULL
 ,@verifyDoc1				VARCHAR(255) = NULL 
 ,@verifyDoc2				VARCHAR(255) = NULL
 ,@verifyDoc3				VARCHAR(255) = NULL
 ,@verifyDoc4				VARCHAR(255) = NULL
 ,@createdDate				DATETIME	  = NULL
 ,@createdBy				VARCHAR(50)  = NULL
 ,@idNumber					varchar(50)   = null
 ,@dob						varchar(10)   = null  --new added by dhan
 ,@issueDate				varchar(10)   = null
 ,@expiryDate				varchar(10)   = null  --new added by dhan
   
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
  
SELECT @homePhone = @customerIdNo,@accountNumber = REPLACE(@accountNumber,'-','')

IF ISNUMERIC(@country) <> '1'  
	SET @country = (select top 1 countryId from countrymaster with (nolock) where countryName=@country)  
  
BEGIN TRY 
	 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)	
	 DECLARE  
	   @sql    VARCHAR(MAX)  
	  ,@oldValue   VARCHAR(MAX)  
	  ,@newValue   VARCHAR(MAX)  
	  ,@module   VARCHAR(10)  
	  ,@tableAlias  VARCHAR(100)  
	  ,@logIdentifier  VARCHAR(50)  
	  ,@logParamMod  VARCHAR(100)  
	  ,@logParamMain  VARCHAR(100)  
	  ,@table    VARCHAR(MAX)  
	  ,@select_field_list VARCHAR(MAX)  
	  ,@extra_field_list VARCHAR(MAX)  
	  ,@sql_filter  VARCHAR(MAX)  
	  ,@modType   VARCHAR(6)  
	  ,@errorMsg   VARCHAR(MAX)  
	  ,@bankName  VARCHAR(100)  

    
	 SELECT  
	   @logIdentifier = 'customerId'  
	  ,@logParamMain = 'customerMaster'    
	  ,@module = '20'  
	  ,@tableAlias = 'CustomerMaster'  
         


  /***************************************GME Online Core************************************************/
	IF @flag = 'customer-modify-list'
	BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'
		SET @table = '(
		SELECT 
			customerId as Id
			,fullName = ISNULL(firstName, '''')
			,sd.detailTitle as idType
			,ISNULL(cm.idNumber,'''') as idNumber
			,com.countryName
			,cm.city
			,ISNULL(cm.email,''N/A'') as email
			,ISNULL(cm.mobile,''N/A'') as mobile
			,cm.createdDate
			,isActive = isnull(cm.isActive, ''Y'') 
			,[status] = case when cm.approvedBy is not null then ''Approved'' when cm.approvedBy is null and cm.verifiedBy is not null then ''Approve Pending''
						when cm.verifiedBy is null and cm.approvedby is null then ''Verify Pending'' end
			,accountName =cm.bankAccountNo
			,bankName = isnull(bl.bankName, ''N/A'')
			,isEnabled = CASE WHEN ISNULL(cm.isActive, ''Y'') = ''Y'' THEN ''Enabled'' ELSE ''Disabled'' END
		FROM dbo.customerMaster cm(nolock)
		LEFT JOIN dbo.staticDataValue sd(nolock) ON sd.valueId=cm.idType
		LEFT JOIN dbo.countryMaster com(nolock) ON com.countryId = cm.nativeCountry
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE 1=1 
		'
		
		IF @createdDate IS NOT NULL
            SET @table = @table + '  AND cm.createdDate between '''+ CONVERT(VARCHAR,@createdDate,101) + ''' AND '''+ CONVERT(VARCHAR,@createdDate,101) + ' 23:59:59''';
			SET @table = @table + ')x'
			
		SET @sql_filter = ''
            
		IF @mobile IS NOT NULL
            SET @sql_filter = @sql_filter + '  AND mobile ='''+ @mobile + '''';
		
        IF @email IS NOT NULL
            SET @sql_filter += ' AND  email like ''' + @email+ '%''';

		IF @idNumber IS NOT NULL
            SET @sql_filter += ' AND  REPLACE(idNumber, ''-'', '''') like ''' + REPLACE(@idNumber, '-', '')+ '%''';
		
		SET @select_field_list ='id,fullName,isActive,isEnabled,status,idType,idNumber,countryName,city,email,mobile,createdDate,accountName,bankName'
			   
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

	IF @flag = 's-customer'
	BEGIN
		declare @isTxnMade char(1)
		if exists (select 1 from remitTran RT(nolock) 
					inner join customerMaster CM(nolock) on CM.email = RT.createdBy
					where CM.customerId = @customerId)
			set @isTxnMade = 'Y'
		else
			set @isTxnMade = 'N'


		SELECT customerId, email,firstName, bankName, isApproved = CASE WHEN cm.verifiedBy IS NOT NULL THEN 'Y' ELSE 'N' END,
			gender, country, [address], city, telNo, mobile, nativeCountry
			,dob = FORMAT(dob,'MM/dd/yyyy'),idIssueDate = FORMAT(idIssueDate,'MM/dd/yyyy'),idExpiryDate = FORMAT(idExpiryDate,'MM/dd/yyyy')
			, occupation
			, bankAccountNo,
			idType, idNumber, verifyDoc1, verifyDoc2, verifyDoc3, homePhone, isTxnMade = @isTxnMade, verifyDoc4 = SelfieDoc
		FROM customerMaster cm (NOLOCK) 
		WHERE customerId = @customerId
	END

	IF @flag = 'enable-disable'
	BEGIN
		IF @isActive = 'Y'
		BEGIN
			update customerMaster set  isActive = 'N' where customerId = @customerId

			SELECT '0' ErrorCode , 'Customer has been disabled successfully.' Msg , @customerId id	 
		END
		ELSE
		BEGIN
			update customerMaster set  isActive = 'Y' where customerId = @customerId

			SELECT '0' ErrorCode , 'Customer has been enabled successfully.' Msg , @customerId id	 
		END
	END

	IF @flag = 'customer-modify'
	BEGIN
		
		--LOG FOR CUSTOMER UPDATE
		EXEC PROC_CUSTOMERMODIFYLOG @flag = 'i', @email = @custEmail, @idNumber = @customerIdNo, @bank = @bankId, 
									@accNumber = @accountNumber, @customerId = @customerId, @mobileNumber = @custMobile,
									@user = @user,@idType = @customerIdType	,@dob = @dob, @issueDate = @issueDate,@expiryDate =@expiryDate

   
       
		UPDATE dbo.customerMaster SET
			email =  @custEmail
			,firstName = @firstName
			,fullName = @firstName
			,gender= @custGender 
			,country = @country
			,[address] = @custAdd1
			,city = @custCity
			,nativeCountry = @custNativecountry
			,mobile  = @custMobile	
			--,homePhone = @customerIdNo
			,telNo = @custTelNo
			,occupation = @occupation
			,idType = @customerIdType
			,idNumber = @customerIdNo
			,dob = @dob   --new one by dhan
			,idExpiryDate = @expiryDate
			,idIssueDate = @issueDate --new one by dhan
			,bankName = @bankId
			,modifiedBy = @user
			,modifiedDate = GETDATE()
			,bankAccountNo = @accountNumber
			,verifyDoc1= CASE WHEN @verifyDoc1 IS NOT NULL THEN @verifyDoc1 ELSE verifyDoc1 END
			,verifyDoc2 = CASE WHEN @verifyDoc2 IS NOT NULL THEN @verifyDoc2 ELSE verifyDoc2 END
			,verifyDoc3 = CASE WHEN @verifyDoc3 IS NOT NULL THEN @verifyDoc3 ELSE verifyDoc3 END
			,SelfieDoc = CASE WHEN @verifyDoc4 IS NOT NULL THEN @verifyDoc4 ELSE SelfieDoc END
		WHERE customerId = @customerId

		UPDATE KFTC_CUSTOMER_master SET userCellNo = @custMobile,accHolderInfoType=@customerIdType,accHolderInfo=@customerIdNo  where customerid = @customerId

		SELECT '0' ErrorCode , 'Customer has been updated successfully.' Msg , @customerId id	 
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
