USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendPayTable]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_sendPayTable]
     @flag						VARCHAR(20)			= NULL
    ,@user						VARCHAR(30)			= NULL
    ,@rowId						INT					= NULL
	,@country					VARCHAR(30)			= NULL
	,@agent						VARCHAR(100)		= NULL
	,@customerRegistration		CHAR(1)				= NULL
	,@newCustomer				CHAR(1)				= NULL
	,@collection				CHAR(1)				= NULL
	,@id						CHAR(1)				= NULL
	,@idIssueDate				CHAR(1)				= NULL
	,@iDValidDate				CHAR(1)				= NULL
	,@dob						CHAR(1)				= NULL
	,@address					CHAR(1)				= NULL
	,@city						CHAR(1)				= NULL
	,@contact					CHAR(1)				= NULL
	,@occupation				CHAR(1)				= NULL
	,@company					CHAR(1)				= NULL
	,@salaryRange				CHAR(1)				= NULL
	,@purposeofRemittance		CHAR(1)				= NULL
	,@sourceofFund				CHAR(1)				= NULL
	,@rId						CHAR(1)				= NULL
	,@rPlaceOfIssue				CHAR(1)				= NULL
	,@raddress					CHAR(1)				= NULL
	,@rcity						CHAR(1)				= NULL
	,@rContact					CHAR(1)				= NULL
	,@rRelationShip				CHAR(1)				= NULL
	,@rDOB						CHAR(1)				= NULL
	,@rIdValidDate				CHAR(1)				= NULL
	,@nativeCountry				CHAR(1)				= NULL
	,@tXNHistory				CHAR(1)				= NULL
	,@opeType					VARCHAR(4)			= NULL
	,@createdBy					VARCHAR(30)			= NULL
	,@createdDate				DATETIME			= NULL
	,@modifiedBy				VARCHAR(30)			= NULL
	,@modifiedDate				DATETIME			= NULL
    ,@sortBy                    VARCHAR(50)		    = NULL
    ,@sortOrder                 VARCHAR(5)			= NULL
    ,@pageSize					INT					= NULL
    ,@pageNumber				INT				    = NULL
 AS
 BEGIN TRY 
 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
   	DECLARE
		 @sql				VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX) = ''
		,@modType			VARCHAR(6)
		
		SELECT
		 @logIdentifier = 'rowId'
		,@tableAlias = ' Send Pay Table'	
		
	 IF @flag ='s'
	 BEGIN
		IF @sortBy IS NULL
		SET @sortBy ='rowId'

		SET @table = '
					( 
						SELECT 
							rowId			= rowId, 
							country			= cm.countryName ,
							agentName		= ISNULL(agentName,''All'') ,
							id				= id,
							idIssueDate		= idIssueDate,
							salaryRange		= salaryRange,
							opeType			= opeType,
							createdBy		= spt.createdBy,
							createdDate		= spt.createdDate 
						FROM sendPayTable spt WITH(NOLOCK)
						LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = spt.agent
						LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = spt.country
						WHERE ISNULL(spt.isDeleted,''N'') = ''N''

					) x' 
						
						SET @sql_filter =''
						IF @country IS NOT NULL 
							SET @sql_filter =@sql_filter + ' AND country Like ''%'+@country+'%'''
							
						IF @agent IS NOT NULL 
							SET @sql_filter =@sql_filter + ' AND agentName Like ''%'+@agent+'%'''
							
						IF @opeType IS NOT NULL 
							SET @sql_filter =@sql_filter + ' AND opeType = '''+@opeType+''''
			    
						SET @select_field_list ='
								rowId
								,country
								,agentName
								,id
								,idIssueDate
								,salaryRange
								,opeType
								,createdBy
								,createdDate'
						
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
	 
	 ELSE IF @flag = 'a'
	 BEGIN
		SELECT spt.*, am.agentId, am.agentName, cm.countryId, cm.countryName FROM sendPayTable spt WITH(NOLOCK)
		LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = spt.agent
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON cm.countryId = spt.country
		WHERE rowId = @rowId AND opeType = @opeType
		RETURN
	 END
	 
	 ELSE IF @flag ='i'
	 BEGIN
		IF EXISTS (SELECT 'X' FROM sendPayTable WHERE country = @country AND opeType = @opeType AND ISNULL(isDeleted,'N') <> 'Y' and ISNULL(agent,1) = ISNULL(@agent,1) )
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot insert duplicate data', @rowId
			RETURN
		END
		BEGIN TRANSACTION
		INSERT INTO sendPayTable(
					country, agent, customerRegistration, newCustomer, collection, id, idIssueDate, iDValidDate, dob, address, city, contact,occupation					
				   ,company, salaryRange, purposeofRemittance,sourceofFund, rId, rPlaceOfIssue, raddress, rcity, rContact, rRelationShip, nativeCountry				
				   ,tXNHistory, opeType, createdBy, createdDate, modifiedBy	,modifiedDate ,rDOB,rIdValidDate)
				   
				   SELECT @country, @agent, @customerRegistration, @newCustomer, @collection, @id, @idIssueDate, @iDValidDate, @dob, @address, @city, @contact, @occupation					
				   ,@company, @salaryRange, @purposeofRemittance, @sourceofFund, @rId, @rPlaceOfIssue, @raddress, @rcity, @rContact, @rRelationShip, @nativeCountry				
				   ,@tXNHistory, @opeType, @user, GETDATE(), @modifiedBy, @modifiedDate ,@rDOB,@rIdValidDate
				   
				   
				   		
			SET @modType = 'Insert'
			SET @rowId = @@IDENTITY
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
		RETURN 
	 END
	 
	 ELSE IF @flag = 'u'
	 BEGIN
			BEGIN TRANSACTION
			UPDATE sendPayTable SET
					 country				=		@country
					,agent					=		@agent
					,customerRegistration	=		@customerRegistration
					,newCustomer			=		@newCustomer
					,collection				=		@collection
					,id						=		@id
					,idIssueDate			=		@idIssueDate
					,iDValidDate			=		@iDValidDate
					,dob					=		@dob
					,address				=		@address
					,city					=		@city
					,contact				=		@contact
					,occupation				=		@occupation			
				   ,company					=		@company
				   ,salaryRange				=		@salaryRange
				   ,purposeofRemittance		=		@purposeofRemittance
				   ,sourceofFund			=		@sourceofFund
				   ,rId						=		@rId
				   ,rPlaceOfIssue			=		@rPlaceOfIssue
				   ,raddress				=		@raddress
				   ,rcity					=		@rcity
				   ,rContact				=		@rContact
				   ,rRelationShip			=		@rRelationShip
				   ,rDOB					=		@rDOB
				   ,rIdValidDate			=		@rIdValidDate
				   ,nativeCountry			=		@nativeCountry			
				   ,tXNHistory				=		@tXNHistory
				   ,opeType					=		@opeType
				  ,modifiedBy				=		@user
				  ,modifiedDate				=		GETDATE()
				  WHERE rowId				=		@rowId
				  
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowId
		RETURN 
	 END
	 
	 ELSE IF @flag ='copy'
	 BEGIN
		IF EXISTS (SELECT 'X' FROM sendPayTable WHERE country = @country AND opeType = @opeType AND ISNULL(isDeleted,'N') <> 'Y' and ISNULL(agent,1) = ISNULL(@agent,1) )
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot insert duplicate data', @rowId
			RETURN
		END
		BEGIN TRANSACTION
		INSERT INTO sendPayTable(
					country, agent, customerRegistration, newCustomer, collection, id, idIssueDate, iDValidDate, dob, address, city, contact,occupation					
				   ,company, salaryRange, purposeofRemittance,sourceofFund, rId, rPlaceOfIssue, raddress, rcity, rContact, rRelationShip, nativeCountry				
				   ,tXNHistory, opeType, createdBy, createdDate, modifiedBy	,modifiedDate ,rDOB,rIdValidDate)
				   
				   SELECT @country, @agent, @customerRegistration, @newCustomer, @collection, @id, @idIssueDate, @iDValidDate, @dob, @address, @city, @contact, @occupation					
				   ,@company, @salaryRange, @purposeofRemittance, @sourceofFund, @rId, @rPlaceOfIssue, @raddress, @rcity, @rContact, @rRelationShip, @nativeCountry				
				   ,@tXNHistory, @opeType, @user, GETDATE(), @modifiedBy, @modifiedDate ,@rDOB,@rIdValidDate
				   
				   
				   		
			SET @modType = 'Insert'
			SET @rowId = @@IDENTITY
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been copied successfully.', @rowId
		RETURN 
	 END
	 
	 ELSE IF @flag ='d'
	 BEGIN
		BEGIN TRANSACTION
		UPDATE sendPayTable SET
		isDeleted   =  'Y'
		,modifiedBy		=		@user
	    ,modifiedDate	=		GETDATE()
	     WHERE rowId	=		@rowId
	     
		SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been deleted successfully.', @rowId
		RETURN 
	 END
	END TRY
	
   BEGIN CATCH 
       IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId
   END CATCH 


GO
