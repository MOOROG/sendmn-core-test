

ALTER proc [dbo].[proc_csDetail]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@csDetailId                        VARCHAR(30)		= NULL
	,@csMasterId                        BIGINT			= NULL
	,@condition                         INT				= NULL
	,@collMode                          INT				= NULL
	,@paymentMode                       INT				= NULL	
	,@tranCount                         INT				= NULL
	,@amount                            MONEY			= NULL
	,@period							INT				= NULL
	,@nextAction                        CHAR(1)			= NULL
	,@criteria							VARCHAR(MAX)	= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@profession                        INT				= NULL
	,@isRequireDocument					CHAR(1)			= NULL

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
		 @ApprovedFunctionId = 2019020
		,@logIdentifier = 'csDetailId'
		,@logParamMain = 'csDetail'
		,@logParamMod = 'csDetailHistory'
		,@module = '20'
		,@tableAlias = 'Compliance Rule Setup Detail'
	
	DECLARE @criteriaList TABLE(criteriaId INT)
	
	IF ISNULL(@isRequireDocument, 'N') = 'Y'
		SET @isRequireDocument = '1'
	ELSE
		SET @isRequireDocument = '0'

	IF @flag = 'i'
	BEGIN
		--IF @condition ='4601' AND ISNULL(@tranCount,'0')=0
		--BEGIN
		--	EXEC proc_errorHandler 0, 'Sorry, Tran count can not be 0!', @csDetailId
		--	--SELECT * FROM staticDataValue WHERE typeID=4601
		--	return;
		--END
		/*
		IF @condition  IN ('4600','4602','4603') AND ISNULL(@tranCount,'0')=0
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Tran count can not be 0!', @csDetailId
			return;
		END
		*/
		--IF @condition  IN ('4600','4602','4603') AND ISNULL(@period,'0')=0
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Sorry, Period(In days) can not be 0!', @csDetailId
		--	return;
		--END
		--IF @condition  IN ('4600','4602','4603') AND ISNULL(@amount,'0')=0
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Sorry, Amount can not be 0!', @csDetailId
		--	return;
		--END

		BEGIN TRANSACTION

			INSERT INTO csDetail (
				 csMasterId
				,condition
				,collMode
				,paymentMode
				,tranCount
				,amount
				,period
				,nextAction
				,createdBy
				,createdDate
				,isEnable
				,profession
				,documentRequired
			)
			SELECT
				 @csMasterId
				,@condition
				,@collMode
				,@paymentMode
				,@tranCount
				,@amount
				,@period
				,@nextAction
				,@user
				,GETDATE()
				,'Y'
				,@profession
				,@isRequireDocument
					
			SET @csDetailId = SCOPE_IDENTITY()
			
			SET @sql = '
				SELECT valueId FROM staticDataValue 
					WHERE valueId IN (' + @criteria + ')' 
			
			INSERT @criteriaList
			EXEC (@sql)
			
			INSERT csCriteriaHistory(csDetailId, criteriaId, modType, createdBy, createdDate)
			SELECT @csDetailId, criteriaId, 'U', @user, GETDATE() FROM @criteriaList
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @csDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csDetailHistory WITH(NOLOCK)
				WHERE csDetailId = @csDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				 mode.*
				 ,documentRequired1 = ISNULL(MODE.documentRequired, 0)
				,amount1 = CAST(mode.amount as DECIMAL(38, 2))				
				,criteria = dbo.FNAGetCsvValue(@csDetailId, 1000, @user)
			FROM csDetailHistory mode WITH(NOLOCK)
			INNER JOIN csDetail main WITH(NOLOCK) ON mode.csDetailId = main.csDetailId
			WHERE mode.csDetailId= @csDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				*
				,documentRequired1 = ISNULL(documentRequired, 0)
				,amount1 = CAST(amount AS DECIMAL(38, 2))
				,criteria = dbo.FNAGetCsvValue(@csDetailId, 1000, @user)
			FROM csDetail WITH(NOLOCK) WHERE csDetailId = @csDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csDetail WITH(NOLOCK)
			WHERE csDetailId = @csDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csDetailHistory WITH(NOLOCK)
			WHERE csDetailId  = @csDetailId AND approvedBy IS NULL AND (createdBy<> @user OR modType = 'D') 
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csDetail WHERE approvedBy IS NULL AND csDetailId  = @csDetailId)			
			BEGIN				
				UPDATE csDetail SET
				 csMasterId = @csMasterId
				,condition = @condition
				,collMode = @collMode
				,paymentMode = @paymentMode
				,tranCount = @tranCount
				,amount = @amount
				,period = @period
				,nextAction = @nextAction
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				,profession = @profession
				,documentRequired = @isRequireDocument
				WHERE csDetailId = @csDetailId	
			
				SET @sql = '
				SELECT valueId FROM staticDataValue 
					WHERE valueId IN (' + @criteria + ')' 
				
				INSERT @criteriaList
				EXEC (@sql)
				
				DELETE FROM csCriteriaHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
				INSERT csCriteriaHistory(csDetailId, criteriaId, modType, createdBy, createdDate)
				SELECT @csDetailId, criteriaId, 'U', @user, GETDATE() FROM @criteriaList		
			END
			ELSE
			BEGIN
				DELETE FROM csDetailHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
				INSERT INTO csDetailHistory(
					 csDetailId
					,condition
					,collMode
					,paymentMode
					,tranCount
					,amount
					,period
					,nextAction
					,isEnable
					,createdBy
					,createdDate
					,modType
					,profession
					,documentRequired
				)
				
				SELECT
					 @csDetailId
					,@condition
					,@collMode
					,@paymentMode
					,@tranCount
					,@amount
					,@period
					,@nextAction
					,'Y'
					,@user
					,GETDATE()
					,'U'
					,@profession
					,@isRequireDocument
				
				SET @sql = '
				SELECT valueId FROM staticDataValue 
					WHERE valueId IN (' + @criteria + ')' 
				
				INSERT @criteriaList
				EXEC (@sql)
				
				DELETE FROM csCriteriaHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL 
				INSERT csCriteriaHistory(csDetailId, criteriaId, modType, createdBy, createdDate)
				SELECT @csDetailId, criteriaId, 'U', @user, GETDATE() FROM @criteriaList	

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @csDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csDetail WITH(NOLOCK)
			WHERE csDetailId = @csDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @csDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csDetailHistory  WITH(NOLOCK)
			WHERE csDetailId = @csDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @csDetailId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM csDetail WITH(NOLOCK) WHERE csDetailId = @csDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM csDetail WHERE csDetailId = @csDetailId
			DELETE FROM csCriteriaHistory WHERE csDetailId = @csDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @csDetailId
			RETURN
		END
			INSERT INTO csDetailHistory(
					 csDetailId
					,condition
					,collMode
					,paymentMode
					,tranCount
					,amount
					,period
					,nextAction
					,createdBy
					,createdDate
					,modType
					,profession
					,documentRequired
				)
				SELECT
					 csDetailId
					,condition
					,collMode
					,paymentMode					
					,tranCount
					,amount
					,period
					,nextAction
					,@user
					,GETDATE()					
					,'D'
					,profession
					,@isRequireDocument
				FROM csDetail
				WHERE csDetailId = @csDetailId
			SET @modType = 'delete'	
			
			INSERT INTO csCriteriaHistory(
					 csCriteriaId
					,csDetailId
					,criteriaId
					,createdBy
					,createdDate
					,modType
				)
				SELECT	
					 csCriteriaId
					,csDetailId
					,criteriaId
					,@user
					,GETDATE()
					,'D'
				FROM csCriteria WHERE csDetailId = @csDetailId

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @csDetailId
	END
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'condition'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		SET @table = '(
				SELECT
					 csDetailId = ISNULL(mode.csDetailId, main.csDetailId)
					,condition = ISNULL(mode.condition, main.condition)					
					,collMode = ISNULL(mode.collMode, main.collMode)	
					,paymentMode = ISNULL(mode.paymentMode, main.paymentMode)					
					,tranCount = ISNULL(mode.tranCount, main.tranCount)
					,amount = ISNULL(mode.amount, main.amount)
					,period = ISNULL(mode.period, main.period)
					,nextAction=ISNULL(mode.nextAction, main.nextAction)
					,isDisabled=CASE WHEN ISNULL(ISNULL(mode.isEnable, main.isEnable),''n'')=''y'' then ''Enabled'' else ''Disabled'' END
					,main.createdBy
					,main.createdDate
					,profession = ISNULL(mode.profession, main.profession)
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.csDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
					,isDocumentRequired = CASE WHEN ISNULL(main.documentRequired, 0) = 1 then ''Yes'' else ''No'' END
				FROM csDetail main WITH(NOLOCK)
					LEFT JOIN csDetailHistory mode ON main.csDetailId = mode.csDetailId AND mode.approvedBy IS NULL					
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)					
					WHERE main.csMasterId = ' + CAST (@csMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) '
			
			
		SET @table = '(
				SELECT
					 csDetailId 
					,condition
					,isDocumentRequired
					,condition1 = CASE WHEN condition = ''11201'' THEN ISNULL(con.detailTitle,''All'') + ISNULL('' (''+SP.detailTitle+'')'','''') ELSE ISNULL(con.detailTitle,''All'') END
					,collMode
					,collMode1 = ISNULL(cm.detailTitle, ''All'')
					,paymentMode
					,paymentMode1 = ISNULL(pm.typeTitle, ''All'')
					,tranCount
					,amount
					,period
					,nextAction
					,nextAction1 = CASE WHEN main.nextAction = ''H'' THEN ''Hold'' WHEN main.nextAction= ''B'' THEN ''Block'' WHEN main.nextAction= ''Q'' THEN '' Questionnaire'' END 
					,isDisabled
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
					,main.modifiedDate
					,hasChanged
				FROM ' + @table + ' main
				LEFT JOIN staticDataValue con WITH(NOLOCK) ON main.condition = con.valueId
				LEFT JOIN staticDataValue cm WITH(NOLOCK) ON main.collMode = cm.valueId
				LEFT JOIN serviceTypeMaster pm WITH(NOLOCK) ON main.paymentMode = pm.serviceTypeId		
				LEFT JOIN staticDataValue SP WITH(NOLOCK) ON SP.VALUEID = MAIN.profession
				WHERE main.csDetailId NOT IN(
						SELECT 
							csDetailId 
						FROM csDetailHistory cdh WITH(NOLOCK) 
						WHERE createdBy = ''' +  @user + ''' AND modType = ''D''
					)
				) x'
			
			
		SET @sql_filter = ''

		IF @condition IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND condition = ' + CAST(@condition AS VARCHAR(50))
			
		IF @collMode IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND collMode = ' + CAST(@collMode AS VARCHAR(50))
		
		IF @paymentMode IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND paymentMode = ' + CAST(@paymentMode AS VARCHAR(50))
	
		IF @nextAction IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND nextAction = ''' + CAST(@nextAction AS VARCHAR(50))+''''
	
		PRINT (@table+@sql_filter)
		SET @select_field_list ='
			 csDetailId
			,condition
			,condition1
			,isDocumentRequired
			,collMode
			,collMode1
			,paymentMode
			,paymentMode1
			,tranCount
			,amount
			,period
			,nextAction
			,nextAction1
			,isDisabled
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
			,hasChanged
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
			SELECT 'X' FROM csDetail WITH(NOLOCK)
			WHERE csDetailId = @csDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM csDetail WITH(NOLOCK)
			WHERE csDetailId = @csDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @csDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM csDetail WHERE approvedBy IS NULL AND csDetailId = @csDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @csDetailId
					RETURN
				END
			DELETE FROM csDetail WHERE csDetailId =  @csDetailId
			DELETE FROM csCriteriaHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @csDetailId
					RETURN
				END
			DELETE FROM csDetailHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
			DELETE FROM csCriteriaHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @csDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM csDetail WITH(NOLOCK)
			WHERE csDetailId = @csDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM csDetail WITH(NOLOCK)
			WHERE csDetailId = @csDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @csDetailId
			RETURN
		END
		BEGIN TRANSACTION
			DECLARE @newCriteriaValue VARCHAR(MAX)
			IF EXISTS (SELECT 'X' FROM csDetail WHERE approvedBy IS NULL AND csDetailId = @csDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM csDetailHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE csDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE csDetailId = @csDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csDetailId, @newValue OUTPUT
				
				SELECT 
					@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
				FROM csCriteriaHistory 
				WHERE csDetailId = @csDetailId AND approvedBy IS NULL
				
				EXEC [dbo].proc_GetColumnToRow  'csCriteria', 'csDetailId', @csDetailId, @oldValue OUTPUT
				
				DELETE FROM csCriteria WHERE csDetailId = @csDetailId
				INSERT csCriteria(criteriaId, csDetailId, createdBy, createdDate)
				SELECT criteriaId, @csDetailId, @user, GETDATE() FROM csCriteriaHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
				
				SELECT @tranCount = ISNULL(tranCount, 0), @amount = ISNULL(amount, 0) FROM csDetail cd WITH(NOLOCK)
					LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
					WHERE cd.csDetailId = @csDetailId
				
				IF ISNULL(@amount, 0) <> 0 
				BEGIN
					INSERT INTO csDetailRec(
						 csMasterId
						,csDetailId
						,condition
						,collMode
						,paymentMode
						,checkType
						,parameter
						,period
						,criteria
						,nextAction
						,isEnable
						,createdBy
						,createdDate
					)
					SELECT
						 csMasterId
						,cd.csDetailId  
						,condition
						,collMode
						,paymentMode
						,'Sum'
						,amount
						,period
						,cch.criteriaId
						,cd.nextAction
						,'Y'
						,@user
						,GETDATE()	
					FROM csDetail cd WITH(NOLOCK)
					LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
					WHERE cd.csDetailId = @csDetailId
				END
				IF ISNULL(@tranCount, 0) <> 0 
				BEGIN
					INSERT INTO csDetailRec(
						 csMasterId
						,csDetailId
						,condition
						,collMode
						,paymentMode
						,checkType
						,parameter
						,period
						,criteria
						,nextAction
						,isEnable
						,createdBy
						,createdDate
					)
					SELECT
						 csMasterId
						,cd.csDetailId  
						,condition
						,collMode
						,paymentMode
						,'Count'
						,tranCount
						,period
						,cch.criteriaId
						,cd.nextAction
						,'Y'
						,@user
						,GETDATE()	
					FROM csDetail cd WITH(NOLOCK)
					LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
					WHERE cd.csDetailId = @csDetailId
				END
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance Rule Criteria', @csDetailId, @user, @oldValue, @newCriteriaValue	
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.condition = mode.condition
					,main.collMode = mode.collMode
					,main.paymentMode = mode.paymentMode
					,main.tranCount = mode.tranCount
					,main.amount = mode.amount
					,main.period = mode.period
					,main.nextAction = mode.nextAction
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,main.profession = mode.profession
					,main.documentRequired = mode.documentRequired
				FROM csDetail main
				INNER JOIN csDetailHistory mode ON mode.csDetailId = main.csDetailId
				WHERE mode.csDetailId = @csDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'csDetail', 'csDetailId', @csDetailId, @newValue OUTPUT
				
				SELECT 
					@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
				FROM csCriteriaHistory 
				WHERE csDetailId = @csDetailId AND approvedBy IS NULL
				
				EXEC [dbo].proc_GetColumnToRow  'csCriteria', 'csDetailId', @csDetailId, @oldValue OUTPUT
				
				DELETE FROM csCriteria WHERE csDetailId = @csDetailId
				INSERT csCriteria(criteriaId, csDetailId, createdBy, createdDate)
				SELECT criteriaId, @csDetailId, @user, GETDATE() FROM csCriteriaHistory WHERE csDetailId = @csDetailId AND approvedBy IS NULL
				
				SELECT @tranCount = ISNULL(tranCount, 0), @amount = ISNULL(amount, 0) FROM csDetail cd WITH(NOLOCK)
					LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
					WHERE cd.csDetailId = @csDetailId
					
				UPDATE csDetailRec SET
					 isEnable = 'N'
				WHERE csDetailId = @csDetailId
				
				/*IF ISNULL(@amount, 0) <> 0
				BEGIN
					DECLARE @csDetailRecId INT
					SELECT @csDetailRecId = csDetailRecId FROM csDetailRec WITH(NOLOCK) WHERE csDetailId = @csDetailId AND ISNULL(@amount, 0) <> 0
					
					UPDATE csDetailRec SET
						 
					WHERE csDetailRecId = @csDetailRecId
				END*/
				IF @amount <> 0
				BEGIN
					INSERT INTO csDetailRec(
						 csMasterId
						,csDetailId
						,condition
						,collMode
						,paymentMode
						,checkType
						,parameter
						,period
						,criteria
						,isEnable
						,createdBy
						,createdDate
					)
					SELECT
						 csMasterId
						,cd.csDetailId  
						,condition
						,collMode
						,paymentMode
						,'Sum'
						,amount
						,period
						,cch.criteriaId
						,'Y'
						,@user
						,GETDATE()	
					FROM csDetail cd WITH(NOLOCK)
					LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
					WHERE cd.csDetailId = @csDetailId
				END
				
				IF @tranCount <> 0
				BEGIN
					INSERT INTO csDetailRec(
						 csMasterId
						,csDetailId
						,condition
						,collMode
						,paymentMode
						,checkType
						,parameter
						,period
						,criteria
						,isEnable
						,createdBy
						,createdDate
					)
					SELECT
						 csMasterId
						,cd.csDetailId  
						,condition
						,collMode
						,paymentMode
						,'Count'
						,tranCount
						,period
						,cch.criteriaId
						,'Y'
						,@user
						,GETDATE()	
					FROM csDetail cd WITH(NOLOCK)
					LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
					WHERE cd.csDetailId = @csDetailId
				END
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance Rule Criteria', @csDetailId, @user, @oldValue, @newCriteriaValue
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csDetailId, @oldValue OUTPUT
				UPDATE csDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE csDetailId = @csDetailId
				
				DELETE FROM csCriteria WHERE csDetailId = @csDetailId
			END
			
			UPDATE csDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE csDetailId = @csDetailId AND approvedBy IS NULL
			
			UPDATE csCriteriaHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE csDetailId = @csDetailId AND approvedBy IS NULL 
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @csDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @csDetailId
	END
	
	ELSE IF @flag = 'disabled'
	BEGIN
		--UPDATE csDetail SET isDisabled=case when isDisabled='y' then 'n' else 'y' end where csDetailId=@csDetailId
		--EXEC proc_errorHandler 0, 'Record disabled successfully.', @csDetailId
		
		
		IF (SELECT isnull(isEnable,'n') FROM csDetail WHERE csDetailId = @csDetailId)='n'
		begin
			UPDATE csDetail SET isEnable='y' WHERE csDetailId = @csDetailId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csDetailId
			return;
		end
		else
		begin		
			UPDATE csDetail SET isEnable='n' WHERE csDetailId = @csDetailId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csDetailId
			return;
		end
		IF (SELECT isnull(isEnable,'n') FROM csDetailHistory WHERE csDetailId = @csDetailId)='n'
		begin
			UPDATE csDetailHistory SET isEnable='y' WHERE csDetailId = @csDetailId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csDetailId
			return;
		end
		else
		begin		
			UPDATE csDetailHistory SET isEnable='n' WHERE csDetailId = @csDetailId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csDetailId
			return;
		end
		
		
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @csDetailId
END CATCH


