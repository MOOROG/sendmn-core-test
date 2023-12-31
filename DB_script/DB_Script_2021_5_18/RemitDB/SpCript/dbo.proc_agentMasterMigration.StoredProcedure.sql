USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentMasterMigration]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentMasterMigration]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@agentId							VARCHAR(30)		= NULL
     ,@parentId							VARCHAR(30)		= NULL
     ,@agentName						VARCHAR(100)	= NULL
     ,@agentCode	                    VARCHAR(50)		= NULL
     ,@agentAddress	                    VARCHAR(200)	= NULL
     ,@agentCity						VARCHAR(100)	= NULL
     ,@agentCountryId					INT				= NULL
     ,@agentCountry						VARCHAR(100)	= NULL
     ,@agentState						VARCHAR(100)	= NULL
     ,@agentDistrict					VARCHAR(100)	= NULL
     ,@agentZip							VARCHAR(20)		= NULL
     ,@agentLocation					INT				= NULL
     ,@agentPhone1						VARCHAR(50)		= NULL
     ,@agentPhone2						VARCHAR(50)		= NULL
     ,@agentFax1						VARCHAR(50)		= NULL
     ,@agentFax2						VARCHAR(50)		= NULL
     ,@agentMobile1						VARCHAR(50)		= NULL
     ,@agentMobile2						VARCHAR(50)		= NULL
     ,@agentEmail1						VARCHAR(100)	= NULL
     ,@agentEmail2						VARCHAR(100)	= NULL
     ,@businessOrgType					INT				= NULL
     ,@businessType						INT				= NULL
     ,@agentRole						CHAR(1)			= NULL
     ,@agentType						INT				= NULL
     ,@allowAccountDeposit				CHAR(1)			= NULL
     ,@actAsBranch						CHAR(1)			= NULL
     ,@contractExpiryDate				DATETIME		= NULL
     ,@renewalFollowupDate				DATETIME		= NULL
     ,@isSettlingAgent					CHAR(1)			= NULL
     ,@isHeadOffice						CHAR(1)			= NULL
     ,@agentGroup						INT				= NULL
     ,@businessLicense					VARCHAR(100)	= NULL
     ,@agentBlock						CHAR(1)			= NULL
     ,@agentcompanyName					VARCHAR(200)	= NULL
     ,@companyAddress					VARCHAR(200)	= NULL
     ,@companyCity						VARCHAR(100)	= NULL	
     ,@companyCountry					VARCHAR(100)	= NULL
     ,@companyState						VARCHAR(100)	= NULL
     ,@companyDistrict					VARCHAR(100)	= NULL
     ,@companyZip						VARCHAR(50)		= NULL
     ,@companyPhone1					VARCHAR(50)		= NULL
     ,@companyPhone2					VARCHAR(50)		= NULL
     ,@companyFax1						VARCHAR(50)		= NULL
     ,@companyFax2						VARCHAR(50)		= NULL
     ,@companyEmail1					VARCHAR(100)	= NULL
     ,@companyEmail2					VARCHAR(100)	= NULL
     ,@localTime						INT				= NULL
     ,@localCurrency					INT				= NULL
     ,@agentDetails						VARCHAR(MAX)	= NULL
     ,@contactPerson					VARCHAR(200)	= NULL
     ,@cpPost							VARCHAR(50)		= NULL
     ,@cpEmail							VARCHAR(100)	= NULL
     ,@parentName						VARCHAR(100)	= NULL
     ,@haschanged						CHAR(1)			= NULL
     ,@isActive							CHAR(1)			= NULL
     ,@isDeleted                        CHAR(1)			= NULL     
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL
     ,@populateBranch					CHAR(1)			= NULL
     ,@headMessage						VARCHAR(MAX)	= NULL
     ,@mapCodeInt						VARCHAR(20)		= NULL
     ,@mapCodeDom						VARCHAR(20)		= NULL
     ,@commCodeInt						VARCHAR(20)		= NULL
     ,@commCodeDom						VARCHAR(20)		= NULL
     ,@urlRoot							VARCHAR(200)	= NULL
     ,@joinedDate						DATETIME		= NULL
     ,@createdBy						VARCHAR(50)		= NULL
     ,@createdDate						DATETIME		= NULL
     ,@approvedBy						VARCHAR(50)		= NULL
     ,@approvedDate						DATETIME		= NULL


AS
SET NOCOUNT ON
	
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
       

SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@ApprovedFunctionId INT	
		,@msg				VARCHAR(MAX)
		
	SELECT
		 @logIdentifier = 'agentId'
		,@logParamMain = 'agentMaster'
		,@tableAlias = 'Agent Setup'
		,@module = 20
		,@ApprovedFunctionId = 20101030
	
	
    IF @flag = 'i'
    BEGIN
		IF @agentName IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Name cannot be empty', NULL
			RETURN
		END
		/*
		IF EXISTS(SELECT 'X' FROM agentMaster WHERE agentName = @agentName AND agentType = @agentType AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			SET @msg = 'Agent with name ' + @agentName + ' already exists'
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		*/
		IF EXISTS(SELECT 'X' FROM agentMaster WITH(NOLOCK) WHERE mapCodeInt = @mapCodeInt)
		BEGIN
			SET @msg = 'Map Code ' + @mapCodeInt + ' already exists'
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		BEGIN TRANSACTION
			
			INSERT INTO agentMaster (
				 parentId
				,agentName
				,agentCode
				,agentAddress
				,agentCity
				,agentCountryId
				,agentCountry
				,agentState
				,agentDistrict
				,agentZip
				,agentLocation
				,agentPhone1
				,agentPhone2
				,agentFax1
				,agentFax2
				,agentMobile1
				,agentMobile2
				,agentEmail1
				,agentEmail2
				,businessOrgType
				,businessType
				,agentRole
				,agentType
				,allowAccountDeposit
				,actAsBranch
				,contractExpiryDate
				,renewalFollowupDate
				,isSettlingAgent
				,isHeadOffice
				,agentGrp
				,businessLicense
				,agentBlock
				,agentcompanyName
				,companyAddress
				,companyCity 
				,companyCountry
				,companyState
				,companyDistrict
				,companyZip
				,companyPhone1
				,companyPhone2
				,companyFax1
				,companyFax2
				,companyEmail1
				,companyEmail2
				,localTime
				,localCurrency
				,agentDetails
				--,contactPerson	
				--,cpPost
				,cpEmail			                 
				,createdDate
				,createdBy 
				,headMessage  
				,mapCodeInt
				,mapCodeDom
				,commCodeInt
				,commCodeDom  
				,joinedDate
				,approvedBy
				,approvedDate 
				,isActive              
			)
			SELECT
				 @parentId
				,@agentName
				,@agentCode
				,@agentAddress
				,@agentCity
				,@agentCountryId
				,@agentCountry
				,@agentState
				,@agentDistrict
				,@agentZip
				,@agentLocation
				,@agentPhone1
				,@agentPhone2
				,@agentFax1
				,@agentFax2
				,@agentMobile1
				,@agentMobile2
				,@agentEmail1
				,@agentEmail2
				,@businessOrgType
				,@businessType
				,@agentRole
				,@agentType
				,@allowAccountDeposit
				,@actAsBranch
				,@contractExpiryDate
				,@renewalFollowupDate
				,@isSettlingAgent
				,@isHeadOffice
				,@agentGroup
				,@businessLicense
				,@agentBlock
				,@agentcompanyName
				,@companyAddress
				,@companyCity 
				,@companyCountry
				,@companyState
				,@companyDistrict
				,@companyZip
				,@companyPhone1
				,@companyPhone2
				,@companyFax1
				,@companyFax2
				,@companyEmail1
				,@companyEmail2
				,@localTime
				,@localCurrency
				,@agentDetails	
				--,@contactPerson	
				--,@cpPost
				,@cpEmail			           
				,ISNULL(@createdDate,GETDATE())
				,ISNULL(@createdBy,@user)
				,@headMessage
				,@mapCodeInt
				,@mapCodeDom
				,@commCodeInt
				,@commCodeDom
				,@joinedDate
				,ISNULL(@approvedBy, @user)
				,ISNULL(@approvedDate, GETDATE())
				,@isActive
                    
			SET @agentId = SCOPE_IDENTITY()
			
			IF @agentCode IS NULL
				UPDATE agentMaster set agentCode = dbo.FNAGetAgentCode(@agentId) where agentId=@agentId
        COMMIT TRANSACTION
        
        EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentId
    END
	
	ELSE IF @flag = 'approve'
	BEGIN
		SELECT @agentCountry = agentCountry, @contractExpiryDate = contractExpiryDate, @approvedBy = approvedBy, @approvedDate = approvedDate FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
		
		UPDATE agentMaster SET
			 isActive = 'Y'
			,approvedBy	= ISNULL(@approvedBy, @user)
			,approvedDate = ISNULL(@approvedDate, GETDATE())
			
		WHERE agentId = @agentId
		
		/*
		INSERT INTO creditLimit(
				 agentId,currency
				,limitAmt,perTopUpAmt,maxLimitAmt
				,expiryDate,isActive
				,createdBy,createdDate,approvedBy,approvedDate
				,topUpTillYesterday,topUpToday,todaysSent,todaysPaid,todaysCancelled,lienAmt
			)
			SELECT
				 @agentId,2
				,0,0,0
				,@contractExpiryDate,'Y'
				,@user,GETDATE(),@user,GETDATE()
				,0,0,0,0,0,0
		*/
		/*
		--Account Creation
		IF EXISTS(SELECT 'X' FROM agentMaster WHERE agentId = @agentId AND ISNULL(isSettlingAgent, 'N') = 'Y')
		BEGIN
			DECLARE @currency INT
			SELECT @agentCountry = agentCountry, @contractExpiryDate = contractExpiryDate FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
			SELECT @currency = CASE WHEN @agentCountry = 'Nepal' THEN 1 ELSE 2 END
			INSERT INTO creditLimit(
				 agentId,currency
				,limitAmt,perTopUpAmt,maxLimitAmt
				,expiryDate,isActive
				,createdBy,createdDate,approvedBy,approvedDate
				,topUpTillYesterday,topUpToday,todaysSent,todaysPaid,todaysCancelled,lienAmt
			)
			SELECT
				 @agentId,@currency
				,0,0,0
				,@contractExpiryDate,'Y'
				,@user,GETDATE(),@user,GETDATE()
				,0,0,0,0,0,0
		END	
		---------------INSERTING AGENT ON IME SYSTEM--------------------

			---------------INSERTING AGENT ON IME SYSTEM--------------------
			DECLARE @ismainAgent1 CHAR(1),@CENTRAL_SETT_CODE1 VARCHAR(30)
			DECLARE @agentRole1 VARCHAR(20)
			SELECT 
				@isSettlingAgent= isSettlingAgent 
				,@agentName		= agentName
				,@agentAddress	= agentAddress
				,@agentCity		= agentCity
				,@agentPhone1	= agentPhone1
				,@agentFax1		= agentFax1
				,@agentEmail1	= agentEmail1
				,@isActive		= isActive
				,@agentState	= agentState
				,@agentDistrict = agentDistrict
				,@agentRole1	= CASE WHEN agentRole ='S' THEN 'Sending' ELSE 'Receiving' END
				,@mapCodeInt	= mapCodeInt
				,@mapCodeDom	= mapCodeDom
				,@commCodeInt	= commCodeInt
				,@commCodeDom	= commCodeDom
			FROM agentMaster WHERE agentId = @agentId
			
			IF @isSettlingAgent ='Y'
			BEGIN
				SET @ismainAgent1 =  'y'
				SET @CENTRAL_SETT_CODE1 =  @mapCodeInt
			END
			
			IF ISNULL(@isSettlingAgent,'N') = 'N' 
			BEGIN
				SET @ismainAgent1 =  'n'
				SET @CENTRAL_SETT_CODE1 = (SELECT mapCodeInt FROM agentMaster WHERE AGENTID = (SELECT parentId FROM agentMaster WHERE agentId = @agentId))
			END
					
					EXEC [192.168.1.234].IME_TEST.[dbo].[spa_agentdetail]
						@flag='i',
						@agent_id =@agentId,
						@agent_name =@agentName,
						@agent_short_name = NULL,
						@agent_address =@agentAddress,
						@agent_city  = @agentCity,
						@agent_address2  = NULL,
						@agent_phone = @agentPhone1,
						@agent_fax  = @agentFax1,
						@agent_email  = @agentEmail1,
						@agent_contact_person =null,
						@agent_contact_person_mobile = null,
						@agent_status  = @isActive,
						@MAP_code = @mapCodeInt,
						@MAP_code2 =@commCodeInt,
						@agenttype =  @agentRole1 ,
						@agent_imecode  = @mapCodeDom,
						@TDS_PCNT  = null,
						@tid = @commCodeDom,
						@agentzone  = @agentState,
						@agentdistrict  = @agentDistrict,
						@agent_panno  = null,
						@central_sett = 'y',
						@ismainAgent  = @ismainAgent1,
						@CENTRAL_SETT_CODE = @CENTRAL_SETT_CODE1,
						@username  = @user,
						@company_id ='1'
				
			---------------ending AGENT ON IME SYSTEM--------------------
			*/
	END	
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
