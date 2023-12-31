USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_mortgage]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_mortgage]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@mortgageId						VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@regOffice							VARCHAR(200)	= NULL
	,@mortgageRegNo						VARCHAR(20)		= NULL
	,@valuationAmount					MONEY			= NULL
	,@currency                          INT				= NULL
	,@valuator							VARCHAR(50)		= NULL
	,@valuationDate						DATETIME		= NULL
	,@propertyType						VARCHAR(200)	= NULL
	,@plotNo							VARCHAR(100)	= NULL
	,@owner                             VARCHAR(50)		= NULL
	,@country                           INT				= NULL
	,@state                             INT				= NULL
	,@city                              VARCHAR(50)		= NULL
	,@zip                               VARCHAR(10)		= NULL
	,@address                           VARCHAR(100)	= NULL
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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20181230
		,@logIdentifier = 'mortgageId'
		,@logParamMain = 'mortgage'
		,@logParamMod = 'mortgageHistory'
		,@module = '20'
		,@tableAlias = 'Mortgage'
	
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 mortgageId = ISNULL(mode.mortgageId, main.mortgageId)
					,agentId = ISNULL(mode.agentId, main.agentId)
					,mortgageRegNo = ISNULL(mode.mortgageRegNo, main.mortgageRegNo)
					,regOffice = ISNULL(mode.regOffice, main.regOffice)
					,valuationAmount = ISNULL(mode.valuationAmount, main.valuationAmount)
					,currency = ISNULL(mode.currency, main.currency)
					,valuator = ISNULL(mode.valuator, main.valuator)
					,valuationDate = ISNULL(mode.valuationDate, main.valuationDate)
					,propertyType = ISNULL(mode.propertyType, main.propertyType)
					,plotNo = ISNULL(mode.plotNo, main.plotNo)
					,owner = ISNULL(mode.owner, main.owner)
					,country = ISNULL(mode.country, main.country)
					,state = ISNULL(mode.state, main.state)
					,city = ISNULL(mode.city, main.city)
					,zip = ISNULL(mode.zip, main.zip)
					,address = ISNULL(mode.address, main.address)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.mortgageId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM mortgage main WITH(NOLOCK)
					LEFT JOIN mortgageHistory mode ON main.mortgageId = mode.mortgageId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) '
			PRINT (@table)
	
	END	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO mortgage (
				 agentId
				,mortgageRegNo
				,regOffice
				,valuationAmount
				,currency
				,valuator							
				,valuationDate						
				,propertyType	
				,plotNo			
				,owner             
				,country                  
				,state                      
				,city                          
				,zip                         
				,address
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId				
				,@mortgageRegNo
				,@regOffice
				,@valuationAmount
				,@currency
				,@valuator							
				,@valuationDate						
				,@propertyType	
				,@plotNo			
				,@owner             
				,@country                  
				,@state                      
				,@city                          
				,@zip                         
				,@address                      
				,@user
				,GETDATE()
				
				
			SET @mortgageId = SCOPE_IDENTITY()			
			UPDATE securityDocument SET securityTypeId = @mortgageId,sessionId = null WHERE sessionId = @sessionId AND securityType='M'
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @mortgageId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM mortgageHistory WITH(NOLOCK)
				WHERE mortgageId = @mortgageId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*,
				valuationDate1 = CONVERT(VARCHAR,mode.valuationDate,101)
			FROM mortgageHistory mode WITH(NOLOCK)
			INNER JOIN mortgage main WITH(NOLOCK) ON mode.mortgageId = main.mortgageId
			WHERE mode.mortgageId= @mortgageId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT *,valuationDate1 = CONVERT(VARCHAR,valuationDate,101) FROM mortgage WITH(NOLOCK) WHERE mortgageId = @mortgageId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM mortgage WITH(NOLOCK)
			WHERE mortgageId = @mortgageId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @mortgageId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM mortgageHistory WITH(NOLOCK)
			WHERE mortgageId  = @mortgageId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @mortgageId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM mortgage WHERE approvedBy IS NULL AND mortgageId  = @mortgageId)			
			BEGIN				
				UPDATE mortgage SET
					 agentId			= @agentId
					,mortgageRegNo		= @mortgageRegNo
					,regOffice			= @regOffice
					,valuationAmount	= @valuationAmount
					,currency			= @currency
					,valuator			= @valuator						
					,valuationDate		= @valuationDate						
					,propertyType		= @propertyType	
					,plotNo				= @plotNo		
					,owner				= @owner             
					,country			= @country                  
					,state				= @state                      
					,city				= @city                          
					,zip				= @zip                         
					,address			= @address
					,modifiedBy			= @user
					,modifiedDate		= GETDATE()
			WHERE mortgageId = @mortgageId			
			END
			ELSE
			BEGIN
				DELETE FROM mortgageHistory WHERE mortgageId = @mortgageId AND approvedBy IS NULL
				INSERT INTO mortgageHistory(
					 mortgageId
					,agentId
					,mortgageRegNo
					,regOffice
					,valuationAmount
					,currency
					,valuator							
					,valuationDate						
					,propertyType	
					,plotNo			
					,owner             
					,country                  
					,state                      
					,city                          
					,zip                         
					,address
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @mortgageId
					,@agentId
					,@mortgageRegNo
					,@regOffice
					,@valuationAmount
					,@currency
					,@valuator							
					,@valuationDate						
					,@propertyType	
					,@plotNo			
					,@owner             
					,@country                  
					,@state                      
					,@city                          
					,@zip                         
					,@address
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @mortgageId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM mortgage WITH(NOLOCK)
			WHERE mortgageId = @mortgageId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @mortgageId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM mortgageHistory  WITH(NOLOCK)
			WHERE mortgageId = @mortgageId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @mortgageId
			RETURN
		END
		SELECT @agentId = agentId FROM mortgage WHERE mortgageId = @mortgageId
		IF EXISTS(SELECT 'X' FROM mortgage WITH(NOLOCK) WHERE mortgageId = @mortgageId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM mortgage WHERE mortgageId = @mortgageId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
			INSERT INTO mortgageHistory(
					 mortgageId
					,agentId
					,mortgageRegNo
					,regOffice
					,valuationAmount
					,currency
					,valuator							
					,valuationDate						
					,propertyType	
					,plotNo			
					,owner             
					,country                  
					,state                      
					,city                          
					,zip                         
					,address
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 mortgageId
					,agentId
					,mortgageRegNo
					,regOffice
					,valuationAmount
					,currency
					,valuator							
					,valuationDate						
					,propertyType	
					,plotNo			
					,owner             
					,country                  
					,state                      
					,city                          
					,zip                         
					,address
					,user
					,GETDATE()					
					,'D'
				FROM mortgage
				WHERE mortgageId = @mortgageId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END


	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'mortgageId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '( 
				SELECT
					 main.mortgageId
					,main.agentId
					,main.regOffice
					,main.mortgageRegNo
					,main.valuationAmount
					,currency = cm.currencyCode
					,main.valuator
					,main.valuationDate
					,main.propertyType
					,main.plotNo
					,main.owner
					,main.country
					,main.state
					,main.city
					,main.zip
					,main.address
					,main.modifiedBy							
					,haschanged
				FROM ' + @table + ' main
				LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyId
				WHERE main.agentId = ' + CAST(@agentId AS VARCHAR) + '
				) x
	
				'
					
		SET @sql_filter = ''

		SET @select_field_list ='
			 mortgageId
			,agentId
			,regOffice
			,mortgageRegNo
			,valuationAmount
			,currency
			,valuator
			,valuationDate
			,propertyType
			,plotNo
			,owner
			,country
			,state
			,city
			,zip
			,address
			,modifiedBy
			,haschanged 
			'
			
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
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM mortgage WITH(NOLOCK)
			WHERE mortgageId = @mortgageId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM mortgage WITH(NOLOCK)
			WHERE mortgageId = @mortgageId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @mortgageId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM mortgage WHERE approvedBy IS NULL AND mortgageId = @mortgageId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mortgageId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mortgageId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @mortgageId
					RETURN
				END
			DELETE FROM mortgage WHERE mortgageId =  @mortgageId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mortgageId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mortgageId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @mortgageId
					RETURN
				END
				DELETE FROM mortgageHistory WHERE mortgageId = @mortgageId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @mortgageId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM mortgage WITH(NOLOCK)
			WHERE mortgageId = @mortgageId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM mortgage WITH(NOLOCK)
			WHERE mortgageId = @mortgageId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @mortgageId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM mortgage WHERE approvedBy IS NULL AND mortgageId = @mortgageId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM mortgageHistory WHERE mortgageId = @mortgageId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE mortgage SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE mortgageId = @mortgageId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mortgageId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mortgageId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId			= mode.agentId
					,main.mortgageRegNo		= mode.mortgageRegNo
					,main.regOffice			= mode.regOffice
					,main.currency			= mode.currency
					,main.valuator			= mode.valuator
					,main.valuationDate		= mode.valuationDate
					,main.propertyType		= mode.propertyType
					,main.plotNo			= mode.plotNo
					,main.owner				= mode.owner
					,main.country			= mode.country
					,main.state				= mode.state
					,main.city				= mode.city
					,main.zip				= mode.zip
					,main.address			= mode.address
					,main.modifiedDate		= GETDATE()
					,main.modifiedBy		= @user
				FROM mortgage main
				INNER JOIN mortgageHistory mode ON mode.mortgageId = main.mortgageId
				WHERE mode.mortgageId = @mortgageId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'mortgage', 'mortgageId', @mortgageId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mortgageId, @oldValue OUTPUT
				UPDATE mortgage SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE mortgageId = @mortgageId
			END
			
			UPDATE mortgageHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE mortgageId = @mortgageId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mortgageId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @mortgageId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @mortgageId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @mortgageId
END CATCH


GO
