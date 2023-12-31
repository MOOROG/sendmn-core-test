USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentProfileUpdate]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_agentProfileUpdate]
		 @flag					varchar(50)			=	NULL
		,@user					varchar(50)			=	NULL
		,@agentId				VARCHAR(30)			=	NULL
		,@authorizePerson 	    VARCHAR(100)    	=	NULL
		,@contactPerson			VARCHAR(100)		=   NULL
		,@agentPhone1			VARCHAR(50)			=	NULL
		,@agentPhone2			VARCHAR(50)			=	NULL
		,@agentMobile1			VARCHAR(50)			=	NULL
		,@agentMobile2			VARCHAR(50)			=	NULL
		,@agentFax1				VARCHAR(50)			=	NULL
		,@agentFax2				VARCHAR(50)			=	NULL
		,@address1				VARCHAR(50)			=	NULL
		,@address2				VARCHAR(50)			=	NULL
		,@agentEmail1			VARCHAR(100)		=	NULL
		,@agentEmail2			VARCHAR(100)		=	NULL
		,@latitude				VARCHAR(100)		=	NULL
		,@longitude				VARCHAR(100)		=	NULL
		,@sortBy                VARCHAR(50)			=	NULL
		,@sortOrder             VARCHAR(5)			=	NULL
		,@pageSize              INT					=	NULL
		,@pageNumber			INT					=	NULL
		,@agentName				VARCHAR(200)		=	NULL
		,@id					INT					=	NULL
		,@rptType				CHAR(2)				=	NULL
		,@fromDate				VARCHAR(20)			=	NULL
		,@toDate				VARCHAR(20)			=	NULL
	
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
	IF @flag = 'i'
	BEGIN
		
		IF EXISTS(SELECT 'x' FROM agentProfileUpdate WITH(NOLOCK) WHERE agentid = @agentId AND approvedDate IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Your profile has been already approved.', NULL
			RETURN	
		END
		
		IF NOT EXISTS(SELECT 'x' FROM agentProfileUpdate WITH(NOLOCK) WHERE agentid = @agentId)
		BEGIN
			INSERT INTO agentProfileUpdate(
				 agentid
				,authorizePerson
				,contactPerson
				,Phone1
				,Phone2
				,Mobile1
				,Mobile2
				,Fax1
				,Fax2
				,address1
				,address2
				,Email1
				,Email2
				,latitude
				,longitude
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@authorizePerson 
				,@contactPerson
				,@agentPhone1
				,@agentPhone2
				,@agentMobile1
				,@agentMobile2
				,@agentFax1
				,@agentFax2
				,@address1
				,@address2
				,@agentEmail1
				,@agentEmail2
				,@latitude
				,@longitude
				,@user
				,GETDATE()	
			EXEC proc_errorHandler 0, 'Thank you very much, Your profile has been updated successfully.', NULL
			RETURN	
		END
		ELSE
		BEGIN
			UPDATE agentProfileUpdate SET
				 authorizePerson = @authorizePerson
				,contactPerson = @contactPerson
				,phone1 = @agentPhone1
				,phone2 = @agentPhone2
				,mobile1 = @agentMobile1
				,mobile2 = @agentMobile2
				,fax1 = @agentFax1
				,fax2 = @agentFax2
				,email1 = @agentEmail1
				,email2 = @agentEmail2
				,address1 = @address1
				,address2 = @address2
				,latitude = @latitude
				,longitude = @longitude
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE agentid = @agentId
			EXEC proc_errorHandler 0, 'Profile has been updated successfully.', NULL
			RETURN	
		END
	END
	
	IF @flag ='a'
	BEGIN
		select * from agentProfileUpdate where agentid = @agentId
	END
		
	IF @flag ='s'
	BEGIN
		
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
		SELECT 
			id,
			p.agentId,
			am.agentName,
			p.authorizePerson,
			p.phone1,
			p.mobile1,
			p.email1,
			p.address1,
			p.createdBy,
			p.createdDate	
		FROM agentProfileUpdate p WITH(NOLOCK) INNER JOIN agentMaster am with(nolock) on p.agentid = am.agentId
		WHERE p.approvedDate IS NULL
					) x'
					
		SET @sql_filter = ''		
		IF @agentName is not null
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''

		SET @select_field_list ='			 
			 id,
			agentId,
			agentName,
			authorizePerson,
			phone1,
			mobile1,
			email1,
			address1,
			createdBy,
			createdDate	'

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
	
	IF @flag ='approve'
	BEGIN
		if not exists(select 'x' 
			from agentProfileUpdate with(nolock) where id = @id and approvedDate is null)
		BEGIN
			EXEC proc_errorHandler 1, 'Record not found.', NULL
			RETURN
		END
		--alter table agentMaster add latitude VARCHAR(100),longitude VARCHAR(100),agentAddress2 VARCHAR(MAX)
		update main set 
			contactPerson1 = mode.authorizePerson,
			contactPerson2 = mode.contactperson,
			agentPhone1 = mode.phone1,
			agentPhone2 = mode.phone2,
			agentMobile1 = mode.mobile1,
			agentMobile2 = mode.mobile2,
			agentFax1 = mode.fax1,
			agentFax2 = mode.fax2,
			agentEmail1 = mode.email1,
			agentEmail2 = mode.email2,
			agentAddress = mode.address1,
			agentAddress2 = mode.address2,
			latitude = mode.latitude,
			longitude = mode.longitude,
			modifiedby = mode.createdby,
			modifiedDate = mode.createdDate,
			approvedBy = @user,
			approvedDate = GETDATE()
		FROM agentMaster main			
		INNER JOIN agentProfileUpdate mode ON main.agentId = mode.agentId
		WHERE mode.id = @id
		
		UPDATE agentProfileUpdate SET approvedBy = @user, approvedDate = GETDATE() WHERE id = @id
		
		EXEC proc_errorHandler 0, 'Record has been approved successfully.', @id
	END

	IF @flag = 'check-update'
	BEGIN
		
		DECLARE @hasRight CHAR(1)
		SET @hasRight = DBO.FNAHasRight(@user,'40133800')
		IF @hasRight ='Y'
		BEGIN
			IF EXISTS(SELECT 'x' FROM agentProfileUpdate WITH(NOLOCK) WHERE agentId = @agentId)
			BEGIN
				SELECT 	@agentId agentId
				RETURN;
			END
			ELSE
			BEGIN
				DECLARE @date DATETIME
				SELECT @date = approvedDate FROM agentMaster am WITH(NOLOCK) WHERE agentId = @agentId
				IF @date > '2015-07-01'
				BEGIN
					SELECT 	@agentId agentId
					RETURN;
				END
				SELECT 	'NULL' agentId
				RETURN;
			END
		END
		ELSE
		BEGIN
			SELECT 	'1001' agentId
			RETURN;
		END
	END	
	
	
	IF @flag = 'rpt'
	BEGIN	
		if @rptType <> 'nu'	
		BEGIN
			SET @sql='SELECT
				[Agent Id] = p.agentId,
				[Agent Name] = am.agentName,
				[Authorized Person] = p.authorizePerson,
				[Phone1] = p.phone1,
				[Mobile1] = p.mobile1,
				[Email1] = p.email1,
				[Address] = p.address1,
				[Created By] = p.createdBy,
				[Created Date] = p.createdDate,
				[Approved By] = p.approvedBy,
				[Approved Date] = p.approvedDate	
			FROM agentProfileUpdate p WITH(NOLOCK) INNER JOIN agentMaster am with(nolock) on p.agentid = am.agentId
			WHERE P.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		
			IF @agentId IS NOT NULL
				SET @sql = @sql+ ' AND p.agentId = '''+@agentId+''''		
			IF @rptType = 'up'
				SET @sql = @sql+ ' AND p.approvedDate is null'
			IF @rptType = 'ua'
				SET @sql = @sql+ ' AND p.approvedDate is not null'
				
			EXEC(@SQL)
		END		
		ELSE
		BEGIN
			SELECT agentId INTO #TEMP
			FROM agentMaster a WITH(NOLOCK) 
			WHERE agentCountry = 'Nepal'
			AND ((actAsBranch = 'Y' and agentType = 2903) OR agentType = 2904)
			AND ISNULL(a.isDeleted, 'N') = 'N'
			AND ISNULL(a.isActive, 'N') = 'Y'
			
			DELETE FROM #TEMP 
			FROM #TEMP T
			INNER JOIN agentProfileUpdate L WITH(NOLOCK) ON T.agentId = L.agentId		

			SELECT 
				 [Agent Id]		= am.agentId
			    ,[Agent Name]	= am.agentName 			
				,[Zone]			= agentState
				,[District]		= agentDistrict
				,[Address]		= agentAddress
				,[Phone]		= ISNULL(agentPhone1,agentMobile1)
			FROM #TEMP A INNER JOIN agentMaster am with(nolock) on A.agentId = am.agentId
			order by am.agentName	
		END
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
		SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value UNION ALL				
		SELECT 'Agent',case when @agentId is null then 'All' else (select agentName from agentMaster with(nolock) where agentId =@agentId) end UNION ALL
		SELECT 'Report Type',case when @rptType='nu' then 'Not Updated' 
			when @rptType='up' then 'Updated but pending'
			when @rptType='ua' then 'Updated but approved' end  
	   
		SELECT 'Agent Profile Update Report' title 
	END	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentId
END CATCH



GO
