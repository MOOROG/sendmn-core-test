USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_kyc]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[proc_kyc]
	 @flag					VARCHAR(50)
	,@user					VARCHAR(30)			
	,@rowId					BIGINT 			= NULL
	,@kycId					BIGINT 			= NULL
	,@remitCardNo			VARCHAR(20) 	= NULL
	,@branch				VARCHAR(100) 	= NULL
	,@clientCode			VARCHAR(100) 	= NULL
	,@accountNo				VARCHAR(100) 	= NULL
	,@amlRefNo				VARCHAR(100) 	= NULL
	,@currOfAccount			VARCHAR(5)		= NULL
	,@typeOfAccount			VARCHAR(10)		= NULL
	,@accountTypeOther		VARCHAR(100) 	= NULL
	,@salutation			VARCHAR(50)		= NULL
	,@firstName				VARCHAR(150) 	= NULL
	,@middleName			VARCHAR(150) 	= NULL
	,@lastName				VARCHAR(150) 	= NULL
	,@pAddress				VARCHAR(150) 	= NULL
	,@tAddress				VARCHAR(150) 	= NULL
	,@hNoP					VARCHAR(15) 	= NULL
	,@hNoT					VARCHAR(15) 	= NULL
	,@wardNoP				VARCHAR(2) 		= NULL
	,@wardNoT				VARCHAR(2) 		= NULL
	,@streetP				VARCHAR(100) 	= NULL
	,@streetT				VARCHAR(100) 	= NULL
	,@vdcMP					VARCHAR(100) 	= NULL
	,@vdcMT					VARCHAR(100) 	= NULL
	,@districtP				VARCHAR(100) 	= NULL
	,@districtT				VARCHAR(100) 	= NULL
	,@zoneP					VARCHAR(100) 	= NULL
	,@zoneT					VARCHAR(100) 	= NULL
	,@countryP				VARCHAR(50) 	= NULL
	,@countryT				VARCHAR(50) 	= NULL
	,@phoneNoP				VARCHAR(20) 	= NULL
	,@phoneNoT				VARCHAR(20) 	= NULL
	,@mobileP				VARCHAR(20)  	= NULL
	,@mobileT				VARCHAR(20)  	= NULL
	,@emailP				VARCHAR(150) 	= NULL
	,@emailT				VARCHAR(150) 	= NULL
	,@maritalStatus			VARCHAR(50)  	= NULL
	,@maritalStatusOther	VARCHAR(50)  	= NULL
	,@nationality			VARCHAR(100) 	= NULL
	,@dobAd					DATETIME     	= NULL
	,@dboBs					VARCHAR(10)  	= NULL
	,@citizenshipNo			VARCHAR(50)  	= NULL
	,@placeOfIssue			VARCHAR(100) 	= NULL
	,@dateOfIssue			VARCHAR(10)    	= NULL
	,@passportNo			VARCHAR(50)  	= NULL
	,@pasportIssuePlace		VARCHAR(100) 	= NULL
	,@pasportIssueDate		DATETIME     	= NULL
	,@visaIssueDate			DATETIME     	= NULL
	,@visValidity			DATETIME     	= NULL
	,@idCardType			VARCHAR(50)  	= NULL
	,@idCardNo				VARCHAR(50)  	= NULL
	,@issuanceOffice		VARCHAR(150) 	= NULL
	,@idCarcharIssueDate	DATETIME 	 	= NULL
	,@mDateOfBirth			DATETIME 	 	= NULL
	,@attMojorityDate		DATETIME 	 	= NULL
	,@nameOfGrudian			VARCHAR(150) 	= NULL
	,@relWithMinor			VARCHAR(150) 	= NULL
	,@occupation			VARCHAR(100) 	= NULL
	,@oocupationOther		VARCHAR(100) 	= NULL
	,@natureOfBusiness		VARCHAR(100) 	= NULL
	,@natureOfBusinessOther	VARCHAR(100) 	= NULL
	,@isTaxassessed			CHAR(1)		 	= NULL
	,@panVatNo				VARCHAR(50)	 	= NULL
	,@purposeOfAccount		VARCHAR(100) 	= NULL
	,@purposeAcOther		VARCHAR(100) 	= NULL
	,@sourceOfFunds			VARCHAR(100) 	= NULL
	,@sourceOther			VARCHAR(100) 	= NULL
	,@spousesName			VARCHAR(150) 	= NULL
	,@fathersName			VARCHAR(150) 	= NULL
	,@mothersName			VARCHAR(150) 	= NULL
	,@grandFathersName		VARCHAR(150) 	= NULL
	,@grandMothersName		VARCHAR(150) 	= NULL
	,@sonsName				VARCHAR(300) 	= NULL
	,@daughtersName			VARCHAR(300) 	= NULL
	,@daughterInLawsName	VARCHAR(300) 	= NULL
	,@fatherInLaw			VARCHAR(150) 	= NULL
	,@motherInLaw			VARCHAR(150) 	= NULL
	,@nomineesName			VARCHAR(150) 	= NULL
	,@nomineesRel			VARCHAR(150) 	= NULL
	,@nomineesAge			INT			 	= NULL
	,@nomineesFMName		VARCHAR(200) 	= NULL
	,@nomineesFullAddress	VARCHAR(200) 	= NULL
	,@nomineesPhoneNo		VARCHAR(20)  	= NULL
	,@guardiansName			VARCHAR(200) 	= NULL
	,@relWithGuardian		VARCHAR(150) 	= NULL
	,@guardianAddress		VARCHAR(150) 	= NULL
	,@isPolitician			CHAR(1)      	= NULL
	,@beneficiaryOwner		CHAR(1)		 	= NULL
	,@benificiaryDetail		VARCHAR(150) 	= NULL
	,@isNrn					CHAR(1)      	= NULL
	,@aapy					VARCHAR(150) 	= NULL
	,@anotpy				VARCHAR(150) 	= NULL
	,@isAssociatedWithUsa	CHAR(1)      	= NULL
	,@usAssociateType		VARCHAR(150) 	= NULL
	,@bankBranch			VARCHAR(150) 	= NULL
	,@accountType			VARCHAR(50)  	= NULL
	,@remarks				VARCHAR(150) 	= NULL
	,@institute				VARCHAR(100) 	= NULL
	,@address				VARCHAR(150) 	= NULL
	,@designation			VARCHAR(50)  	= NULL
	,@anualIncome			MONEY		 	= NULL
	,@createdBy				VARCHAR(30)  	= NULL
	,@createdDate			DATETIME	 	= NULL
	,@modifiedBy			VARCHAR(30)	 	= NULL
	,@modifiedDate			DATETIME	 	= NULL
	,@sessionId				VARCHAR(60)		= NULL
	,@valueType				CHAR(1)			= NULL
	,@sortBy                VARCHAR(50)		= NULL
	,@sortOrder             VARCHAR(5)		= NULL
	,@pageSize              INT				= NULL
	,@pageNumber            INT				= NULL
	,@fileType				VARCHAR(20)		= NULL
	,@fileDescription		VARCHAR(200)	= NULL
	,@agentId	            VARCHAR(50)		= NULL
	,@branchId		        VARCHAR(50)		= NULL
	,@hasChanged			CHAR(1)			= NULL
	,@isActive				CHAR(1)			= NULL
	,@isApprove				CHAR(1)			= NULL
	,@fullName				VARCHAR(200)	= NULL
	,@fromDate				VARCHAR(20)		= NULL
	,@toDate				VARCHAR(20)		= NULL
	,@status				VARCHAR(50)		= NULL
AS 
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY

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
		,@doiCitizen		DATETIME
		
BEGIN
	DECLARE  @tempTbl TABLE(doi DATETIME)
	
	IF @flag = 'i'
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot register the customer.', NULL
			RETURN
		END

		IF @branch IS NULL
			SELECT @branch = agentId FROM dbo.applicationUsers WITH(NOLOCK) WHERE userName = @user

		SET @remitCardNo = REPLACE(@remitCardNo,'-','')
		IF LEN(@remitCardNo) <> '16'
		BEGIN
			EXEC proc_errorHandler 1, 'IME Remit Card Number should be 16 digits.', @remitCardNo
			RETURN;
		END

		IF NOT EXISTS(SELECT 'X' FROM imeRemitCardMaster WITH(NOLOCK) 
			WHERE remitCardNo = @remitCardNo AND cardStatus ='Available')
		BEGIN
			EXEC proc_errorHandler 1, 'Remit Card Number does not exists.', @remitCardNo
			RETURN;
		END

		IF EXISTS(SELECT 'X' FROM kycMaster WITH(NOLOCK) 
		WHERE remitCardNo = @remitCardNo AND ISNULL(isDeleted,'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Already Exists Customer With Same Remit Card Number.', @remitCardNo
			RETURN;
		END
		IF (LEN(LTRIM(RTRIM(@mobileP))) <> '10')
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number Should Be 10 Digits.', NULL
			RETURN
		END		
		IF @dobAd > = GETDATE()
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Date Of Birth.', NULL
			RETURN
		END
		
		INSERT INTO @tempTbl
		EXEC proc_convertDate @flag='A',@nepDate = @dateOfIssue
		SELECT @doiCitizen = doi FROM @tempTbl

		IF @doiCitizen IS NOT NULL
		BEGIN
			IF @doiCitizen > = GETDATE()
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Date Of Issue - Citizenship.', NULL
				RETURN
			END
			IF @dobAd > = @doiCitizen
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Date Of Issue (Citizenship), Can not be greater than DOB.', NULL
				RETURN
			END
		END

		IF @pasportIssueDate IS NOT NULL
		BEGIN
			IF @pasportIssueDate > = GETDATE()
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Date Of Issue - Passport.', NULL
				RETURN
			END
			IF @dobAd > = @pasportIssueDate
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Date Of Issue (Passport), Can not be greater than DOB.', NULL
				RETURN
			END
		END

		INSERT INTO kycMaster(		
			 remitCardNo
			,agentId
			,salutation
			,firstName
			,middleName
			,lastName
			,hNoP
			,hNoT
			,wardNoP
			,wardNoT
			,streetP
			,streetT
			,vdcMP
			,vdcMT
			,districtP
			,districtT
			,zoneP
			,zoneT
			,countryP
			,countryT
			,phoneNoP
			,phoneNoT
			,mobileP
			,mobileT
			,emailP
			,emailT
			,maritalStatus
			,maritalStatusOther
			,nationality
			,dobAd
			,dboBs
			,citizenshipNo
			,placeOfIssue
			,dateOfIssue
			,passportNo
			,pasportIssuePlace
			,pasportIssueDate
			,visaIssueDate
			,visValidity
			,idCardType
			,idCardNo
			,issuanceOffice
			,idCarcharIssueDate
			,mDateOfBirth
			,attMojorityDate
			,nameOfGrudian
			,relWithMinor
			,occupation
			,oocupationOther
			,natureOfBusiness
			,natureOfBusinessOther
			,isTaxassessed
			,panVatNo
			,purposeOfAccount
			,purposeAcOther
			,sourceOfFunds
			,sourceOther
			,spousesName
			,fathersName
			,mothersName
			,grandFathersName
			,grandMothersName
			,sonsName
			,daughtersName
			,daughterInLawsName
			,fatherInLaw
			,motherInLaw
			,nomineesName
			,nomineesRel
			,nomineesAge
			,nomineesFMName
			,nomineesFullAddress
			,nomineesPhoneNo
			,guardiansName
			,relWithGuardian
			,guardianAddress
			,isPolitician
			,beneficiaryOwner
			,benificiaryDetail
			,isNrn
			,aapy
			,anotpy
			,isAssociatedWithUsa
			,usAssociateType
			,createdBy
			,createdDate
			,isActive
			,cardStatus
		)
		SELECT 
			 @remitCardNo
			,@branch
			,@salutation
			,@firstName
			,@middleName
			,@lastName
			,@hNoP
			,@hNoT
			,@wardNoP
			,@wardNoT
			,@streetP
			,@streetT
			,@vdcMP
			,@vdcMT
			,@districtP
			,@districtT
			,@zoneP
			,@zoneT
			,@countryP
			,@countryT
			,@phoneNoP
			,@phoneNoT
			,@mobileP
			,@mobileT
			,@emailP
			,@emailT
			,@maritalStatus
			,@maritalStatusOther
			,@nationality
			,@dobAd
			,@dboBs
			,@citizenshipNo
			,@placeOfIssue
			,@dateOfIssue
			,@passportNo
			,@pasportIssuePlace
			,@pasportIssueDate
			,@visaIssueDate
			,@visValidity
			,@idCardType
			,@idCardNo
			,@issuanceOffice
			,@idCarcharIssueDate
			,@mDateOfBirth
			,@attMojorityDate
			,@nameOfGrudian
			,@relWithMinor
			,@occupation
			,@oocupationOther
			,@natureOfBusiness
			,@natureOfBusinessOther
			,@isTaxassessed
			,@panVatNo
			,@purposeOfAccount
			,@purposeAcOther
			,@sourceOfFunds
			,@sourceOther
			,@spousesName
			,@fathersName
			,@mothersName
			,@grandFathersName
			,@grandMothersName
			,@sonsName
			,@daughtersName
			,@daughterInLawsName
			,@fatherInLaw
			,@motherInLaw
			,@nomineesName
			,@nomineesRel
			,@nomineesAge
			,@nomineesFMName
			,@nomineesFullAddress
			,@nomineesPhoneNo
			,@guardiansName
			,@relWithGuardian
			,@guardianAddress
			,@isPolitician
			,@beneficiaryOwner
			,@benificiaryDetail
			,@isNrn
			,@aapy
			,@anotpy
			,@isAssociatedWithUsa
			,@usAssociateType
			,@user
			,GETDATE()
			,@isActive
			,'Pending'
					
		SET @kycId = SCOPE_IDENTITY()

		UPDATE	imeRemitCardMaster SET cardStatus = 'Reserved' WHERE remitCardNo = @remitCardNo
		
		INSERT INTO kycBusinessNature(kycId,institute,address,designation,anualIncome)
		SELECT @kycId, institute,address,designation,anualIncome FROM temp_kycNormalise WITH(NOLOCK)
		WHERE valueType='N' AND userName = @user AND sessionId =@sessionId		 

		-- ## Send SMS
		
		IF @mobileP <> '' OR @mobileP IS NOT NULL
        BEGIN
			INSERT INTO smsqueue(mobileNo,msg,createdDate,createdBy,country,agentId,branchId)
			SELECT @mobileP,'Thank You for enrolling into IME Remit Card. For more Information Contact: 01-4430600',GETDATE(),@user,'Nepal',@agentId,@agentId 
		END
		
		DELETE FROM temp_kycNormalise WHERE userName = @user AND sessionId =@sessionId	
		EXEC proc_errorHandler 0, 'KYC Customer has been saved successfully, Now please upload the customer documents.', @kycId	
	END
	
	ELSE IF @flag = 'u'
    BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot register the customer.', NULL
			RETURN
		END
		SET @remitCardNo = REPLACE(@remitCardNo,'-','')
		IF LEN(@remitCardNo) <> '16'
		BEGIN
			EXEC proc_errorHandler 1, 'IME Remit Card Number should be 16 digits.', @remitCardNo
			RETURN;
		END
		IF NOT EXISTS(SELECT 'X' FROM imeRemitCardMaster WITH(NOLOCK) 
			WHERE remitCardNo = @remitCardNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Remit Card Number does not exists.', @remitCardNo
			RETURN;
		END

		IF EXISTS(SELECT 'X' FROM kycMaster WITH(NOLOCK) 
		WHERE remitCardNo = @remitCardNo AND ISNULL(isDeleted,'N') = 'N' AND rowId <> @rowId)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Exists Customer With Same Remit Card Number.', @remitCardNo
			RETURN;
		END
		IF (LEN(LTRIM(RTRIM(@mobileP))) <> '10')
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number Should Be 10 Digits.', NULL
			RETURN
		END
		IF @dobAd > = GETDATE()
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Date Of Birth.', NULL
			RETURN
		END
		
		INSERT INTO @tempTbl
		EXEC proc_convertDate @flag='A',@nepDate=@dateOfIssue
		SELECT @doiCitizen = doi FROM @tempTbl

		IF @doiCitizen IS NOT NULL
		BEGIN
			IF @doiCitizen > = GETDATE()
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Date Of Issue - Citizenship.', NULL
				RETURN
			END
		END

		IF @pasportIssueDate IS NOT NULL
		BEGIN
			IF @pasportIssueDate > = GETDATE()
			BEGIN
				EXEC proc_errorHandler 1, 'Invalid Date Of Issue - Passport.', NULL
				RETURN
			END
		END
		UPDATE kycMaster SET		
		 remitCardNo			=	@remitCardNo
		--,agentId				=	@branch		
		,salutation				=	@salutation
		,firstName				=	@firstName
		,middleName				=   @middleName
		,lastName				=   @lastName
		,hNoP					=	@hNoP
		,hNoT					=	@hNoT
		,wardNoP				=	@wardNoP
		,wardNoT				=	@wardNoT
		,streetP				=	@streetP
		,streetT				=	@streetT
		,vdcMP					=	@vdcMP
		,vdcMT					=	@vdcMT
		,districtP				=	@districtP
		,districtT				=	@districtT
		,zoneP					=	@zoneP
		,zoneT					=	@zoneT
		,countryP				=	@countryP
		,countryT				=	@countryT
		,phoneNoP				=	@phoneNoP
		,phoneNoT				=	@phoneNoT
		,mobileP				=	@mobileP
		,mobileT				=	@mobileT
		,emailP					=	@emailP
		,emailT					=	@emailT
		,maritalStatus			=	@maritalStatus
		,maritalStatusOther		=	@maritalStatusOther
		,nationality			=	@nationality
		,dobAd					=	@dobAd
		,dboBs					=	@dboBs
		,citizenshipNo			=	@citizenshipNo
		,placeOfIssue			=	@placeOfIssue
		,dateOfIssue			=	@dateOfIssue
		,passportNo				=	@passportNo
		,pasportIssuePlace		=	@pasportIssuePlace
		,pasportIssueDate		=	@pasportIssueDate
		,visaIssueDate			=	@visaIssueDate
		,visValidity			=	@visValidity
		,idCardType				=	@idCardType
		,idCardNo				=	@idCardNo
		,issuanceOffice			=	@issuanceOffice
		,idCarcharIssueDate		=	@idCarcharIssueDate
		,mDateOfBirth			=	@mDateOfBirth
		,attMojorityDate		=	@attMojorityDate
		,nameOfGrudian			=	@nameOfGrudian
		,relWithMinor			=	@relWithMinor
		,occupation				=	@occupation
		,oocupationOther		=	@oocupationOther
		,natureOfBusiness		=	@natureOfBusiness
		,natureOfBusinessOther	=	@natureOfBusinessOther
		,isTaxassessed			=	@isTaxassessed
		,panVatNo				=	@panVatNo
		,purposeOfAccount		=	@purposeOfAccount
		,purposeAcOther			=	@purposeAcOther
		,sourceOfFunds			=	@sourceOfFunds
		,sourceOther			=	@sourceOther
		,spousesName			=	@spousesName
		,fathersName			=	@fathersName
		,mothersName			=	@mothersName
		,grandFathersName		=	@grandFathersName
		,grandMothersName		=	@grandMothersName
		,sonsName				=	@sonsName
		,daughtersName			=	@daughtersName
		,daughterInLawsName		=	@daughterInLawsName
		,fatherInLaw			=	@fatherInLaw
		,motherInLaw			=	@motherInLaw
		,nomineesName			=	@nomineesName
		,nomineesRel			=	@nomineesRel
		,nomineesAge			=	@nomineesAge
		,nomineesFMName			=	@nomineesFMName
		,nomineesFullAddress	=	@nomineesFullAddress
		,nomineesPhoneNo		=	@nomineesPhoneNo
		,guardiansName			=	@guardiansName
		,relWithGuardian		=	@relWithGuardian
		,guardianAddress		=	@guardianAddress
		,isPolitician			=	@isPolitician
		,beneficiaryOwner		=	@beneficiaryOwner
		,benificiaryDetail		=	@benificiaryDetail
		,isNrn					=	@isNrn
		,aapy					=	@aapy
		,anotpy					=	@anotpy
		,isAssociatedWithUsa	=	@isAssociatedWithUsa
		,usAssociateType		=	@usAssociateType		
		,modifiedBy				=	@user
		,modifiedDate			=	GETDATE()
		WHERE rowId = @rowId
		EXEC proc_errorHandler 0, 'Record updated successfully', @rowId	
    END
	
	ELSE IF @flag='d'
	BEGIN
		IF EXISTS(SELECT 'x' FROM kycMaster WITH(NOLOCK) WHERE approvedDate IS NOT NULL AND rowId = @rowId)
		BEGIN
			SELECT '1' errorCode,'Sorry, You can not delete. Already approved KYC customer.' msg,@rowId
			RETURN;
		END
		UPDATE kycMaster SET isDeleted='Y',modifiedBy = @user,modifiedDate = GETDATE() WHERE rowId = @rowId
		EXEC proc_errorHandler 0, 'Record deleted successfully', @rowId	
		RETURN;
	END

	ELSE IF @flag = 's_admin'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'customerId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '
					SELECT
						 main.rowId
						,main.remitCardNo
						,fullName = isnull('' ''+main.salutation,'''')+'' ''+ isnull('' ''+main.firstName,'''')+ isnull('' ''+main.middleName,'''')+ isnull('' ''+main.lastName,'''')
						,main.accountNo						
						,main.createdBy
						,main.createdDate
						,haschanged = CASE WHEN (main.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
						,isApprove = CASE WHEN (main.approvedBy IS NULL) THEN ''N'' ELSE ''Y'' END
						,isActive = CASE WHEN (main.isActive IS NULL OR main.isActive = ''Y'') THEN ''Y'' ELSE ''N'' END
						,modifiedBy = main.createdBy
						,agentName = case when main.agentId is null then ''Head Office'' else am.agentName END
						,mobile = main.mobileP
					FROM kycMaster main WITH(NOLOCK) 
					LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
					WHERE ISNULL(main.isDeleted,''N'')<>''Y'' 
					 '
					 
		SET @sql_filter = ''
		
		IF @remitCardNo IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND remitCardNo = '''+@remitCardNo+''''
			
		IF @accountNo IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND accountNo = '''+@accountNo+''''	
		
		IF @fullName IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND fullName like ''%'+@fullName+'%'''	

		IF @isApprove IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND isApprove = '''+@isApprove+''''	

		IF @isActive IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND isActive = '''+@isActive+''''

		SET @sql = '('+ @table+')X'

		SET @select_field_list ='
								rowId
								,remitCardNo
								,fullName
								,accountNo								
								,createdBy
								,createdDate
								,haschanged
								,isActive
								,modifiedBy
								,agentName
								,isApprove
								,mobile'
			
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
		
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'customerId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = 'SELECT
						 rowId
						,agentId
						,remitCardNo
						,fullName = isnull('' ''+main.salutation,'''')+'' ''+ isnull('' ''+main.firstName,'''')+ isnull('' ''+main.middleName,'''')+ isnull('' ''+main.lastName,'''')
						,accountNo						
						,main.createdBy
						,main.createdDate
						,mobile = mobileP
						,cardStatus
						,complain = ''<font color="red"><i>''+kc.description+''</i></font>''
					FROM kycMaster main with(nolock)
					LEFT JOIN kycComplain kc WITH(NOLOCK) ON kc.customerId = main.rowId and kc.setPrimary = ''Y''
					WHERE ISNULL(main.isDeleted,''N'')<>''Y'' AND main.cardStatus <> ''Approved''
					 '
					 
		SET @sql_filter = ''
		IF @agentId IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND agentId = '''+@agentId+''''

		IF @remitCardNo IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND remitCardNo = '''+@remitCardNo+''''
					
		IF @fullName IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND fullName like ''%'+@fullName+'%'''

		SET @sql = '('+ @table+')X'

		SET @select_field_list ='
								 rowId
								,agentId
								,remitCardNo
								,fullName
								,accountNo								
								,createdBy
								,createdDate
								,mobile
								,cardStatus
								,complain'
			
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
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			 km.*
			,pCountryName=cmp.countryName
			,tCountryName=cmt.countryName
			,pZone=sp.stateName
			,tZone=st.stateName 
		FROM kycMaster km WITH(NOLOCK) 
		LEFT JOIN countryMaster cmp  WITH(NOLOCK) ON km.countryP=cmp.countryId 
		LEFT JOIN countryMaster cmt  WITH(NOLOCK) ON km.countryT=cmt.countryId 
		LEFT JOIN countryStateMaster sp  WITH(NOLOCK) ON sp.stateId=zoneP
		LEFT JOIN countryStateMaster st  WITH(NOLOCK) ON st.stateId=zoneT 
		WHERE rowId = @rowId
	END
	
	ELSE IF @flag = 'confirm-page'
	BEGIN
		SELECT 
			 km.*
			,pCountryName=cmp.countryName
			,tCountryName=cmt.countryName
			,pZone=sp.stateName
			,tZone=st.stateName 
			,CNT = ISNULL(cd.CNT,0)
			,fullName = ISNULL(' '+km.salutation,'')+' '+ ISNULL(' '+km.firstName,'')+ ISNULL(' '+km.middleName,'')+ ISNULL(' '+km.lastName,'')
		FROM kycMaster km WITH(NOLOCK) 
		LEFT JOIN countryMaster cmp  WITH(NOLOCK) ON km.countryP=cmp.countryId 
		LEFT JOIN countryMaster cmt  WITH(NOLOCK) ON km.countryT=cmt.countryId 
		LEFT JOIN countryStateMaster sp  WITH(NOLOCK) ON sp.stateId=zoneP
		LEFT JOIN countryStateMaster st  WITH(NOLOCK) ON st.stateId=zoneT
		LEFT JOIN
		( 
			SELECT customerId,CNT = COUNT('X') FROM customerDocument cd WITH(NOLOCK) WHERE customerId = @rowId AND ISNULL(isDeleted,'N') = 'N'
			GROUP BY customerId
		)cd ON km.rowId = cd.customerId
		WHERE km.rowId = @rowId
	END
	
	ELSE IF @flag = 'insertInTemp'
	BEGIN
		INSERT INTO temp_kycNormalise (
			 institute
			,address
			,designation
			,anualIncome
			,accountType
			,remarks
			,userName
			,sessionId
			,valueType
		)
		SELECT 
			 @institute
			,@address
			,@designation
			,@anualIncome
			,@accountType
			,@remarks
			,@user
			,@sessionId
			,@valueType
		SET @rowId = SCOPE_IDENTITY()
		EXEC proc_errorHandler 0, 'Record added successfully', @rowId	
	END

	ELSE IF @flag='dTemp'
	BEGIN
		SELECT @valueType = valueType FROM temp_kycNormalise WHERE rowId = @rowId 
		DELETE FROM temp_kycNormalise WHERE rowId = @rowId AND userName = @user AND sessionId = @sessionId	
		EXEC proc_errorHandler 0, 'Record deleted successfully', @valueType	
	END

	ELSE IF @flag = 'aTemp'
	BEGIN
		SELECT rowId,institute,address,designation,anualIncome = dbo.ShowDecimal(anualIncome) FROM temp_kycNormalise WITH(NOLOCK) 
			WHERE userName=@user AND sessionId = @sessionId AND valueType = @valueType
	END
	
	ELSE IF @flag ='saveBusinessNature'
	BEGIN
		INSERT INTO kycBusinessNature(kycId,institute,address,designation,anualIncome,createdBy,createdDate)
		SELECT	@kycId, @institute,@address,@designation,@anualIncome,@user,GETDATE()
		EXEC proc_errorHandler 0, 'Record added successfully.', @valueType	
	END
	
	ELSE IF @flag = 'deleteBuzNature'
	BEGIN	
		DELETE FROM kycBusinessNature WHERE rowId = @rowId
		EXEC proc_errorHandler 0, 'Record deleted successfully', @valueType	
	END			
	
	ELSE IF @flag = 'showOrg'
	BEGIN
		SELECT 
			rowId,
			institute,
			address,
			designation,
			anualIncome = dbo.ShowDecimal(anualIncome) 
		FROM kycBusinessNature WITH(NOLOCK) WHERE kycId = @kycId
	END
	
	ELSE IF @flag='approveCustomer'
	BEGIN

		SELECT @remitCardNo = remitCardNo,
				@createdBy = createdBy,
				@mobileP = mobileP,
				@agentId = agentId
			FROM kycMaster WITH(NOLOCK) WHERE rowId = @rowId

		IF @createdBy = @user
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, You have created this record so you can not approve.', @valueType	
			RETURN;
		END
		IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @remitCardNo AND ISNULL(isDeleted,'N') ='Y')
		BEGIN
			EXEC proc_errorHandler 1, 'KYC customer has already been made with same Remit Card Number.', @valueType	
			RETURN;
		END

		DECLARE @docCount INT
		SELECT @docCount = COUNT('X') FROM customerDocument cd WITH(NOLOCK) 
			WHERE customerId = @rowId AND ISNULL(isDeleted,'N') = 'N'

		IF @docCount < 6 
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Incomplete documents: Please upload complete document & Approve KYC.', @valueType	
			RETURN;
		END
		SELECT @accountNo =	accountNo FROM imeRemitCardMaster WHERE remitCardNo = @remitCardNo

		UPDATE kycMaster SET 
			 approvedBy=@user
			,approvedDate=GETDATE()
			,accountNo = @accountNo
			,cardStatus = 'Approved'
		WHERE rowId=@rowId
		/*
		-- ## Send SMS
		IF @mobileP <> '' OR @mobileP IS NOT NULL
        BEGIN
			INSERT INTO smsqueue(mobileNo,msg,createdDate,createdBy,country,agentId,branchId)
			SELECT @mobileP,'Thank You for enrolling into IME Remit Card. For more Information Contact: 01-4430600',GETDATE(),@user,'Nepal',@agentId,@agentId 
		END
		*/
		-- ## Create IME Customer
		IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @remitCardNo AND ISNULL(isDeleted,'N') ='N')
		BEGIN
			INSERT INTO customerMaster (membershipId,firstName,middleName,lastName,maritalStatus,dobEng,dobNep,citizenshipNo,placeOfIssue,
					pTole,pHouseNo,pMunicipality,pWardNo,pCountry,pZone,pDistrict,
					tTole,tHouseNo,tMunicipality,tWardNo,tCountry,tZone,tDistrict,
					fatherName,motherName,grandFatherName,occupation,email,phone,mobile,
					createdBy,createdDate,approvedBy,approvedDate,isActive,agentId,customerStatus,isKyc,gender)
			SELECT remitCardNo,firstName,middleName,lastName,maritalStatus,dbo.FNANepDateConversion(dboBs),dboBs,citizenshipNo,placeOfIssue,
					streetP,hNoP,vdcMP,wardNoP,cm.countryName, sm.stateName, districtP,
					streetT,hNoT,vdcMT,wardNoT,cm1.countryName, sm1.stateName,districtT,
					fathersName,mothersName,grandFathersName,occupation,emailP,phoneNoP,
					mobileP,kyc.createdBy,kyc.createdDate,@user,GETDATE(),'Y',agentId,'Approved','Y',
					case when salutation = 'Mr.' then '1801' else '1802' end
			FROM  kycMaster kyc WITH(NOLOCK) 
			LEFT JOIN countryMaster cm WITH(NOLOCK) ON kyc.countryP = cm.countryId
			LEFT JOIN countryMaster cm1 WITH(NOLOCK) ON kyc.countryT = cm1.countryId
			LEFT JOIN countryStateMaster sm WITH(NOLOCK) ON sm.stateId = kyc.zoneP
			LEFT JOIN countryStateMaster sm1 WITH(NOLOCK) ON sm1.stateId = kyc.zoneT
			WHERE kyc.rowId=@rowId
		END
		SELECT '0' errorCode,'KYC Customer has been approved successfully.' msg, NULL	
		
	END
	
	ELSE IF @flag='uploadDoc'
	BEGIN
			DECLARE @fileName VARCHAR(250)
			SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType
			INSERT INTO customerDocument (
				 customerId
				,agentId
				,branchId
				,[fileName]
				,fileDescription
				,fileType
				,createdBy
				,createdDate
				,isKycDoc
			)
			SELECT
				 @kycId
				,@agentId
				,@branchId
				,@fileName
				,@fileDescription
				,@fileType
				,@user
				,GETDATE()
				,'Y'
			SELECT '0' errorCode,'Document Upload Successfully' msg,@fileName	
	END
	
	ELSE IF @flag = 'displayDoc'
	BEGIN
		SELECT 
			cdId,	
			fileName = fileDescription,
			createdBy,
			createdDate 
		FROM customerDocument WITH(NOLOCK) 
		WHERE customerId = @kycId AND ISNULL(isKycDoc,'N') = 'Y' AND ISNULL(isDeleted,'N')<>'Y'
	END
	
	ELSE IF @flag = 'deleteDoc'
	BEGIN
		SELECT @kycId = customerId FROM customerDocument WITH(NOLOCK) WHERE cdId = @rowId
		--IF EXISTS(SELECT 'x' FROM kycMaster WITH(NOLOCK) 
		--WHERE approvedDate IS NOT NULL AND rowId = @kycId)
		--BEGIN
		--	SELECT '1' errorCode,'Sorry, You can not delete document. Already approved KYC customer.' msg,@rowId
		--	RETURN;
		--END
		UPDATE customerDocument SET isDeleted='Y' WHERE cdId = @rowId
		SELECT '0' errorCode,'Document Delete Successfully' msg,@rowId	
		RETURN;
	END

	ELSE IF @flag = 'file-type'
	BEGIN		
		SELECT VALUE,TEXTVALUE FROM 
		(
			SELECT 'FORM-1' value,'FORM-1' TEXTVALUE UNION ALL
			SELECT 'FORM-2' value,'FORM-2' TEXTVALUE UNION ALL
			SELECT 'FORM-3' value,'FORM-3' TEXTVALUE UNION ALL
			SELECT 'APPLICATION FORM-1' value,'APPLICATION FORM-1' TEXTVALUE UNION ALL
			SELECT 'APPLICATION FORM-2' value,'APPLICATION FORM-2' TEXTVALUE UNION ALL
			SELECT 'ID CARD' value,'ID CARD' textVaue 
		)X  WHERE VALUE NOT IN (SELECT ISNULL(fileDescription,'') FROM customerDocument 
		WITH(NOLOCK) WHERE customerId = @rowId AND ISNULL(isDeleted,'N') = 'N')
		
	END		

	ELSE IF @flag = 'pending-list'
	BEGIN
		SET @table ='
			SELECT
				 main.rowId
				,[IME Remit Card Number] = main.remitCardNo +'' ''+ CASE WHEN gh.tranStatus = ''Unpaid''	 THEN ''&nbsp;&nbsp;<b><font color="red"><i><span onclick="PayTransaction(''+main.remitCardNo+'');"><a href="#">View Txn</a></span> Already Sent Transaction</i></
b></font>'' ELSE '''' END
				,[Customer Name] = isnull('' ''+main.salutation,'''')+'' ''+ isnull('' ''+main.firstName,'''')+ isnull('' ''+main.middleName,'''')+ isnull('' ''+main.lastName,'''')				
				,[Agent Name] = case when main.agentId is null then ''Head Office'' else am.agentName END
				,[Created By] = main.createdBy
				,[Created Date] = main.createdDate	
				,[Status] = main.cardStatus
				,[Complain Detail] = ''<font color="red"><i>''+kc.description+''</i></font>''
			FROM kycMaster main WITH(NOLOCK) 
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			LEFT JOIN globalCardServiceHistory gh WITH(NOLOCK) ON  main.remitCardNo = gh.remitCardNo
			LEFT JOIN kycComplain kc WITH(NOLOCK) ON kc.customerId = main.rowId and kc.setPrimary = ''Y''
			WHERE ISNULL(main.isDeleted,''N'')<>''Y'' 
			AND (main.approvedDate IS NULL or gh.tranStatus =''Unpaid'')
			AND ISNULL(main.isDeleted,''N'') = ''N'' 
			AND main.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''					 
				
		IF @remitCardNo IS NOT NULL  
			SET @table=@table + ' AND main.remitCardNo = '''+@remitCardNo+''''
			
		
		IF @agentId IS NOT NULL  
			SET @table=@table + ' AND main.agentId = '''+@agentId+''''	

		SET @table=@table + ' order by gh.tranStatus desc'	
		EXEC(@table)
		PRINT(@table)
		RETURN;		
	END

	ELSE IF @flag = 'unpaid-txn'
	BEGIN
		SELECT 
			rt.id,
			[S.N.] = ROW_NUMBER()OVER(ORDER BY rt.approvedDate),
			[Control No] = dbo.fnadecryptstring(rt.controlNo),
			[Sending Agent] = rt.sBranchName,
			[Sender Name] = rt.senderName,
			[Receiver Name] = rt.receiverName,
			[Amount] = dbo.ShowDecimal(rt.pAmt),
			[TXN Date] = rt.approvedDate			
		FROM dbo.remitTran rt WITH(NOLOCK) 
		INNER JOIN dbo.tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE 
			rt.paymentMethod ='IME Remit Card'
		AND rt.payStatus = 'Unpaid' 
		AND rec.membershipId = @remitCardNo
	END
END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errCode, ERROR_MESSAGE() + ERROR_LINE() mes, NULL id
END CATCH



GO
