USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_AGENTS_DATA]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Anoj Kattel>
-- Create date: <Create Date,2019/03/21>
-- Description:	<Description,This is used for migrate agent data to system>
-- =============================================
CREATE PROCEDURE [dbo].[PROC_MIGATE_AGENTS_DATA]
( 
   @oldSystemRowId						INT
  ,@agentName                           VARCHAR(200)	=	NULL
  ,@agentAddress                        VARCHAR(200)	=	NULL
  ,@agentCountry                        VARCHAR(100)	=	NULL
  ,@agentState                          VARCHAR(100)	=	NULL
  ,@agentDistrict                       VARCHAR(100)	=	NULL
  ,@agentPhone                          VARCHAR(50)		=	NULL
  ,@agentFax                            VARCHAR(50)		=	NULL
  ,@agentMobile                         VARCHAR(50)		=	NULL
  ,@contractExpiryDate					DATETIME		=	NULL
  ,@agentEmail                          VARCHAR(100)	=	NULL
  ,@businessLicense                     CHAR(100)		=	NULL
  ,@agentBlock							CHAR(1)			=	NULL
  ,@createdDate                         DATETIME		=	NULL
  ,@createdBy                           VARCHAR(100)	=	NULL
  ,@modifiedDate                        DATETIME		=	NULL
  ,@modifiedBy                          VARCHAR(100)	=	NULL
  ,@approvedDate                        DATETIME		=	NULL
  ,@approvedBy                          VARCHAR(100)	=	NULL
  ,@isHeadOffice                        VARCHAR(10)		=	NULL
  ,@agentSettCurr                       VARCHAR(5)		=	NULL
  ,@contactPerson                       VARCHAR(250)	=	NULL
  ,@branchCode							VARCHAR(3)		=	NULL
  ,@isIntrenalBranch					CHAR(1)			=	NULL
  ,@apiCode								VARCHAR(50)		=	NULL
  ,@apiCode1							VARCHAR(50)		=	NULL
  ,@agentPaymentType					VARCHAR(30)		=	NULL
  ,@isBranchOfAPIPartner				CHAR(1)			=   NULL
  ,@parentId                            INT				=	NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY 
	IF @branchCode  IS NOT NULL AND EXISTS ( SELECT  'X' FROM    agentMaster(nolock)
											WHERE   agentName = @agentName
											AND agentType IN(2901,2902,2903,2904)
											AND ISNULL(isDeleted, 'N') <> 'Y'
											AND ISNULL(isActive, 'N') = 'Y' )
	BEGIN
		EXEC proc_errorHandler 1, 'Agent with this name already exists', NULL
		RETURN;
	END
	IF EXISTS ( SELECT  'X' FROM    agentMaster(nolock)
            WHERE   branchCode = @branchCode)
	BEGIN
		EXEC proc_errorHandler 1, 'Branch with this branch code already exists', NULL
		RETURN;
	END
	DECLARE @agentCountryId INT,@agentId INT,@newParentId INT=NULL

	SELECT @agentCountryId = countryId FROM COUNTRYMASTER (NOLOCK) WHERE countryName = @agentCountry

	--IF  @isIntrenalBranch IN ('Y', 'N') AND @isBranchOfAPIPartner = 'N'
	--BEGIN
		
	--	IF @parentId IS NOT NULL
	--	BEGIN
	--	    SELECT @newParentId=agentId FROM dbo.agentMaster WHERE swiftCode=@parentId;
	--	END

	--	INSERT INTO agentMaster(
	--		parentId , agentName , agentAddress  , agentCountryId , agentCountry , agentState ,agentPhone1 ,agentDistrict, agentMobile1 ,agentFax1,  agentEmail1 ,
	--		businessOrgType,businessType,agentType,actAsBranch,contractExpiryDate,isSettlingAgent,agentGrp,businessLicense,agentBlock,isActive,
	--		isMigrated,createdDate,createdBy,modifiedDate,modifiedBy,approvedDate,approvedBy,
	--		isDeleted,isHeadOffice,agentSettCurr,contactPerson1,IsIntl,isApiPartner,branchCode,swiftCode
	--	)
	--	VALUES(
	--		@newParentId,@agentName,@agentAddress,@agentCountryId,@agentCountry,@agentState,@agentPhone,@agentDistrict,@agentMobile,@agentFax,@agentEmail,
	--		4503,6204,'2903',@isIntrenalBranch,@contractExpiryDate,'Y',6207,@businessLicense,@agentBlock,'Y',
	--		'N',@createdDate,@createdBy,@modifiedDate,@modifiedBy,@approvedDate,@approvedBy,
	--		'N',@isHeadOffice,@agentSettCurr,@contactPerson,CASE WHEN @isIntrenalBranch = 'N' THEN 1 ELSE 0 END,0,@branchCode,@oldSystemRowId
	--	)

	--	update agentmaster set mapCodeInt = @agentId, mapCodeDom = @agentId, 
	--							commCodeInt = '10'+cast(@agentId as varchar), 
	--							commCodeDom = '11'+cast(@agentId as varchar),
	--							mapCodeDomAc = '11'+cast(@agentId as varchar),
	--							agentCode = 'JME'+cast(@agentId as varchar),
	--							mapCodeIntAc = @agentId
	--	where agentId = @agentId
	--END

	DECLARE @parentIdNew INT,@newBankCode INT=CASE WHEN @parentId=11000041 THEN @parentId ELSE NULL END;

	SELECT @parentIdNew = AGENTID FROM agentMaster WHERE SWIFTCODE = CASE WHEN @parentId=11000041 THEN 11000040 ELSE @parentId END AND agentType = '2902'

	IF @isIntrenalBranch IN ('O') AND NOT EXISTS(SELECT 1 FROM agentMaster (NOLOCK) WHERE parentId = @parentIdNew AND SWIFTCODE = @parentId AND agentType = '2903')
	BEGIN
			INSERT INTO agentMaster (
										parentId, agentName, agentCode, agentCountry, agentCountryId, 
										agentRole, 
										isSettlingAgent, agentBlock, isActive, isDeleted, createdBy, createdDate, approvedBy, approvedDate,
										businessOrgType,businessType,agentGrp,isMigrated, IsIntl, AGENTTYPE, extCode,agentAddress,agentState,agentPhone1,
										agentEmail1,agentFax1,swiftCode
									)

								SELECT	@parentIdNew, @agentName, @apiCode, @agentCountry, @agentCountryId,
										CASE @agentPaymentType 
												WHEN 'Bank Transfer'  THEN '2'
												WHEN 'Account Deposit to Other Bank'  THEN '2'
												WHEN 'INSTANT BANK DEPOSIT'  THEN '2'
												WHEN 'THIRD BANK DEPOSIT'  THEN '2'
												WHEN 'THIRD PARTY BANK DEPOSIT'  THEN '2'
												WHEN 'Cash Pay'  THEN '1'
												WHEN 'Home Delivery' THEN '12'
												ELSE NULL END,
										'N', @agentBlock, 'Y', 'N', 'system', GETDATE(), 'system', GETDATE(), 
										4503,6204,4301,'Y', 1, 2903,@apiCode1,@agentAddress,@agentState,@agentPhone,
										@agentEmail,@agentFax,@oldSystemRowId

			EXEC dbo.proc_errorHandler 1, 'Agent Information Added.', @oldSystemRowId 
			RETURN;
		END

	ELSE IF @isIntrenalBranch IN ('O') 
	BEGIN
		IF EXISTS (SELECT TOP 1 'A' FROM agentMaster (NOLOCK) WHERE AGENTNAME = @agentName AND agentType IN ('2903', '2904'))
		BEGIN
			SET @agentName = @agentName + ISNULL(' '+@agentAddress, '')
		END	

		SELECT @parentIdNew =  AGENTID FROM agentMaster (NOLOCK) WHERE swiftCode = @parentId AND agentType = '2903'

		INSERT INTO agentMaster (	parentId, agentName, agentCode, agentCountry, agentCountryId, 
									agentRole,
									isSettlingAgent, agentBlock, isActive, isDeleted, createdBy, createdDate, approvedBy, approvedDate,
									isMigrated, IsIntl, AGENTTYPE, extCode,swiftCode,BANKCODE
								)

							SELECT	@parentIdNew, @agentName, @apiCode, @agentCountry, @agentCountryId,
									CASE @agentPaymentType 
											WHEN 'Bank Transfer'  THEN '2'
											WHEN 'Account Deposit to Other Bank'  THEN '2'
											WHEN 'INSTANT BANK DEPOSIT'  THEN '2'
											WHEN 'THIRD BANK DEPOSIT'  THEN '2'
											WHEN 'THIRD PARTY BANK DEPOSIT'  THEN '2'
											WHEN 'Cash Pay'  THEN '1'
											WHEN 'Home Delivery' THEN '12'
											ELSE NULL END,
									'N', @agentBlock, 'Y', 'N', 'system', GETDATE(), 'system', GETDATE(), 'Y', 1, 2902,@apiCode1,@oldSystemRowId,@newBankCode
			EXEC dbo.proc_errorHandler 1, 'Agent Information Added.', @oldSystemRowId 
			RETURN;
	END
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  
    DECLARE @errorMessage VARCHAR(MAX);  
    SET @errorMessage = ERROR_MESSAGE();  
    EXEC proc_errorHandler 1, @errorMessage, null;  
END CATCH
GO
