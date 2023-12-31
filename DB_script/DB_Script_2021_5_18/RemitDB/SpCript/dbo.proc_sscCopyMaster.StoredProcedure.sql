USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sscCopyMaster]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	proc_sscMaster @flag = 'm', @user = 'admin'
*/

CREATE PROC [dbo].[proc_sscCopyMaster]   
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@sscMasterId                       VARCHAR(30)		= NULL
	,@code                              VARCHAR(10)		= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sHub								INT				= NULL
	,@sCountry                          INT				= NULL
	,@ssAgent							INT				= NULL
	,@sAgent							INT				= NULL
	,@sBranch                           INT				= NULL
	,@rHub								INT				= NULL
	,@rCountry                          INT				= NULL
	,@rsAgent							INT				= NULL
	,@rAgent							INT				= NULL
	,@rBranch                           INT				= NULL
	,@state                             INT				= NULL
	,@zip                               VARCHAR(20)		= NULL
	,@agentGroup                        INT				= NULL
	,@rState							INT				= NULL
	,@rZip								VARCHAR(20)		= NULL
	,@rAgentGroup						INT				= NULL
	,@baseCurrency                      INT				= NULL
	,@tranType                          INT				= NULL
	,@veType							INT				= NULL
	,@ve                                MONEY			= NULL
	,@neType							INT				= NULL
	,@ne                                MONEY			= NULL	
	,@effectiveFrom                     DATETIME		= NULL
	,@effectiveTo						DATETIME		= NULL
	,@isEnable							CHAR(1)			= NULL
	,@copySscMasterId					INT				= NULL
	,@sessionId							VARCHAR(50)		= NULL
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
		,@functionId		INT
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
		
	SELECT
		 @ApprovedFunctionId = 20131130
		,@logIdentifier = 'sscMasterId'
		,@logParamMain = 'sscMaster'
		,@logParamMod = 'sscMasterHistory'
		,@module = '20'
		,@tableAlias = 'Special Service Charge'
		
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
	
	IF @flag = 'scl'
	BEGIN
		SELECT 
             ccm.countryId
            ,ccm.countryName
            ,cnt = COUNT(rCountry)
        FROM countryCurrencyMaster ccm WITH(NOLOCK)
        LEFT JOIN dscMaster dscm WITH(NOLOCK) ON ccm.countryId = dscm.sCountry
        WHERE ISNULL(ccm.isDeleted, 'N') <> 'Y'
        GROUP BY ccm.countryId, ccm.countryName
        RETURN
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM sscMaster WHERE 
			sHub = ISNULL(@sHub, sHub) AND 
			rHub = ISNULL(@rHub, rHub) AND 
			ssAgent = ISNULL(@ssAgent, ssAgent) AND
			rsAgent = ISNULL(@rsAgent, rsAgent) AND
			sCountry = ISNULL(@sCountry, sCountry) AND
			rCountry = ISNULL(@rCountry, rCountry) AND
			sAgent = ISNULL(@sAgent, sAgent) AND
			rAgent = ISNULL(@rAgent, rAgent) AND 
			sBranch = ISNULL(@sBranch, sBranch) AND 
			rBranch = ISNULL(@rBranch, rBranch) AND 
			tranType = ISNULL(@tranType, tranType) AND 
			ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @sscMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO sscMaster (
				 code
				,[description]
				,sHub
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rHub
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,rState 
				,rZip
				,rAgentGroup
				,baseCurrency
				,tranType
				,veType
				,ve                                 
				,neType
				,ne
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @code
				,@description
				,@sHub
				,@sCountry
				,@ssAgent
				,@sAgent
				,@sBranch
				,@rHub
				,@rCountry
				,@rsAgent
				,@rAgent
				,@rBranch
				,@state
				,@zip
				,@agentGroup
				,@rState
				,@rZip
				,@rAgentGroup
				,@baseCurrency
				,@tranType
				,@veType
				,@ve                                 
				,@neType
				,@ne
				,@effectiveFrom
				,@effectiveTo 
				,@isEnable
				,@user
				,GETDATE()				
				
			SET @sscMasterId = SCOPE_IDENTITY()
			
			insert into sscDetail(sscMasterId,fromAmt,toAmt,pcnt,minAmt,maxAmt,isActive,isDeleted,
									approvedBy,approvedDate,createdBy,createdDate,modifiedBy,modifiedDate)
			select @sscMasterId,fromAmt,toAmt,pcnt,minAmt,maxAmt,isActive,isDeleted,
									approvedBy,approvedDate,createdBy,createdDate,modifiedBy,modifiedDate
			from sscDetailTemp where sessionId=@sessionId
			
			delete from sscDetailTemp where sessionId=@sessionId and sscMasterId=@sscMasterId
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @sscMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
			SELECT 
				 * 
				,CONVERT(VARCHAR, effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, effectiveTo, 101) effTo 
			FROM sscMaster WITH(NOLOCK) WHERE sAgent=@sAgent
			
			select @copySscMasterId=sscMasterId from sscMaster where sAgent=@sAgent
			
			if exists(select * from sscDetailTemp where sscMasterId=@copySscMasterId and sessionId=@sessionId)
			begin
					delete from sscDetailTemp where sscMasterId=@copySscMasterId and sessionId=@sessionId
			end
			
			insert into sscDetailTemp(sscMasterId,fromAmt,toAmt,pcnt,minAmt,maxAmt,
				isActive,isDeleted,approvedBy,approvedDate,createdBy,createdDate,modifiedBy,modifiedDate,sessionId)	
				
			select sscMasterId,fromAmt,toAmt,pcnt,minAmt,maxAmt,
				isActive,isDeleted,approvedBy,approvedDate,createdBy,createdDate,modifiedBy,modifiedDate,@sessionId from sscDetail
			where sscMasterId=@copySscMasterId
					
			--ALTER TABLE sscDetailTemp ADD sessionId varchar(50)
	END



END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sscMasterId
END CATCH

GO
