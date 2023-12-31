USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cisDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[proc_cisDetail]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@cisDetailId                       VARCHAR(30)		= NULL
	,@cisMasterId                       BIGINT			= NULL
	,@condition                         INT				= NULL
	,@collMode                          INT				= NULL
	,@paymentMode                       INT				= NULL
	,@tranCount                         INT				= NULL
	,@amount                            MONEY			= NULL
	,@period							INT				= NULL
	,@isEnable							CHAR(1)			= NULL
	,@criteria							VARCHAR(MAX)	= NULL
	,@criteriaValue						VARCHAR(MAX)	= NULL
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
		 @ApprovedFunctionId = 20601130
		,@logIdentifier = 'cisDetailId'
		,@logParamMain = 'cisDetail'
		,@logParamMod = 'cisDetailHistory'
		,@module = '20'
		,@tableAlias = 'Compliance ID Setup Detail'
	
	DECLARE @criteriaList TABLE(criteriaId INT, valueId VARCHAR(50))
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO cisDetail (
				 cisMasterId
				,condition
				,collMode
				,paymentMode
				,tranCount
				,amount
				,period
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @cisMasterId
				,@condition
				,@collMode
				,@paymentMode
				,@tranCount
				,@amount
				,@period
				,'Y'
				,@user
				,GETDATE()
					
			SET @cisDetailId = SCOPE_IDENTITY()
			
					
			INSERT @criteriaList(criteriaId, valueId)
			SELECT 
				 criteriaId = CASE WHEN ISNUMERIC(a.value) = 0 THEN NULL ELSE CAST(a.value AS INT) END
				,valueId = CASE WHEN ISNUMERIC(b.value) = 0 THEN NULL ELSE CAST(b.value AS INT) END
			FROM dbo.Split(',',@criteria) a
			INNER JOIN  dbo.Split(',', @criteriaValue) b ON a.id = b.id
			
			
			
			INSERT cisCriteriaHistory(cisDetailId, criteriaId, idTypeId, modType, createdBy, createdDate)
			SELECT @cisDetailId, criteriaId, valueId, 'U', @user, GETDATE() FROM @criteriaList
			WHERE criteriaId IS NOT NULL 
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @cisDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cisDetailHistory WITH(NOLOCK)
				WHERE cisDetailId = @cisDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				 mode.*
				,amount1 = CAST(mode.amount as DECIMAL(38, 2)) 
				,criteria = dbo.FNAGetCsvValue(@cisDetailId, 1001, @user)
				,criteriaValue = dbo.FNAGetCsvValue(@cisDetailId, 1002, @user)
			FROM cisDetailHistory mode WITH(NOLOCK)
			INNER JOIN cisDetail main WITH(NOLOCK) ON mode.cisDetailId = main.cisDetailId
			WHERE mode.cisDetailId= @cisDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				*
				,amount1 = CAST(amount as DECIMAL(38, 2))
				,criteria = dbo.FNAGetCsvValue(@cisDetailId, 1001, @user)
				,criteriaValue = dbo.FNAGetCsvValue(@cisDetailId, 1002, @user)
			FROM cisDetail WITH(NOLOCK) WHERE cisDetailId = @cisDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cisDetail WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @cisDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM cisDetailHistory WITH(NOLOCK)
			WHERE cisDetailId  = @cisDetailId AND approvedBy IS NULL AND (createdBy<> @user OR modType = 'D')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @cisDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM cisDetail WHERE approvedBy IS NULL AND cisDetailId  = @cisDetailId)			
			BEGIN				
				UPDATE cisDetail SET
				 cisMasterId = @cisMasterId
				,condition = @condition
				,collMode = @collMode
				,paymentMode = @paymentMode
				,tranCount = @tranCount
				,amount = @amount
				,period = @period
				,isEnable = @isEnable
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				WHERE cisDetailId = @cisDetailId	
							
				DELETE FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId 
				INSERT @criteriaList(criteriaId, valueId)
				SELECT 
					 criteriaId = CASE WHEN ISNUMERIC(a.value) = 0 THEN NULL ELSE CAST(a.value AS INT) END
					,valueId = CASE WHEN ISNUMERIC(b.value) = 0 THEN NULL ELSE CAST(b.value AS INT) END
				FROM dbo.Split(',',@criteria) a
				INNER JOIN  dbo.Split(',', @criteriaValue) b ON a.id = b.id
			
				INSERT cisCriteriaHistory(cisDetailId, criteriaId, idTypeId, modType, createdBy, createdDate)
				SELECT @cisDetailId, criteriaId, valueId, 'U', @user, GETDATE() FROM @criteriaList
				WHERE criteriaId IS NOT NULL	
			END
			ELSE
			BEGIN
				DELETE FROM cisDetailHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
				INSERT INTO cisDetailHistory(
					 cisDetailId
					,condition
					,collMode
					,paymentMode
					,tranCount
					,amount
					,period
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				
				SELECT
					 @cisDetailId
					,@condition
					,@collMode
					,@paymentMode
					,@tranCount
					,@amount
					,@period
					,@isEnable
					,@user
					,GETDATE()
					,'U'
	
				DELETE FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId 
				INSERT @criteriaList(criteriaId, valueId)
				SELECT 
					 criteriaId = CASE WHEN ISNUMERIC(a.value) = 0 THEN NULL ELSE CAST(a.value AS INT) END
					,valueId = CASE WHEN ISNUMERIC(b.value) = 0 THEN NULL ELSE CAST(b.value AS INT) END
				FROM dbo.Split(',',@criteria) a
				INNER JOIN  dbo.Split(',', @criteriaValue) b ON a.id = b.id
			
				INSERT cisCriteriaHistory(cisDetailId, criteriaId, idTypeId, modType, createdBy, createdDate)
				SELECT @cisDetailId, criteriaId, valueId, 'U', @user, GETDATE() FROM @criteriaList	
				WHERE criteriaId IS NOT NULL
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @cisDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cisDetail WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @cisDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM cisDetailHistory  WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @cisDetailId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM cisDetail WITH(NOLOCK) WHERE cisDetailId = @cisDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM cisDetail WHERE cisDetailId = @cisDetailId
			DELETE FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @cisDetailId
			RETURN
		END
		
			INSERT INTO cisDetailHistory(
					 cisDetailId
					,condition
					,collMode
					,paymentMode
					,tranCount
					,amount
					,period
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 cisDetailId
					,condition
					,collMode
					,paymentMode
					,tranCount
					,amount
					,period
					,isEnable
					,@user
					,GETDATE()					
					,'D'
				FROM cisDetail
				WHERE cisDetailId = @cisDetailId
			SET @modType = 'delete'	
			
			INSERT INTO cisCriteriaHistory(
					 cisCriteriaId
					,cisDetailId
					,criteriaId
					,idTypeId
					,createdBy
					,createdDate
					,modType
				)
				SELECT	
					 cisCriteriaId
					,cisDetailId
					,criteriaId
					,idTypeId
					,@user
					,GETDATE()
					,'D'
				FROM cisCriteria WHERE cisDetailId = @cisDetailId

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @cisDetailId
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
					 cisDetailId = ISNULL(mode.cisDetailId, main.cisDetailId)
					,condition = ISNULL(mode.condition, main.condition)					
					,collMode = ISNULL(mode.collMode, main.collMode)	
					,paymentMode = ISNULL(mode.paymentMode, main.paymentMode)					
					,tranCount = ISNULL(mode.tranCount, main.tranCount)
					,amount = ISNULL(mode.amount, main.amount)
					,period = ISNULL(mode.period, main.period)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.cisDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM cisDetail main WITH(NOLOCK)
					LEFT JOIN cisDetailHistory mode ON main.cisDetailId = mode.cisDetailId AND mode.approvedBy IS NULL					
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)					
					WHERE main.cisMasterId = ' + CAST (@cisMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) '
			
			
		SET @table = '(
				SELECT
					 cisDetailId 
					,condition
					,condition1 = ISNULL(con.detailTitle,''All'')
					,collMode
					,collMode1 = ISNULL(cm.detailTitle, ''All'')
					,paymentMode
					,paymentMode1 = ISNULL(pm.typeTitle, ''All'')
					,tranCount
					,amount
					,period
					,isEnable					
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
					,hasChanged
				FROM ' + @table + ' main
				LEFT JOIN staticDataValue con WITH(NOLOCK) ON main.condition = con.valueId
				LEFT JOIN staticDataValue cm WITH(NOLOCK) ON main.collMode = cm.valueId
				LEFT JOIN serviceTypeMaster pm WITH(NOLOCK) ON main.paymentMode = pm.serviceTypeId			
				WHERE main.cisDetailId NOT IN(
						SELECT 
							cisDetailId 
						FROM cisDetailHistory cdh WITH(NOLOCK) 
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
		
		IF @isEnable IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND isEnable = ''' + CAST(@isEnable AS VARCHAR(50)) + ''''



		SET @select_field_list ='
			 cisDetailId
			,condition
			,condition1
			,collMode
			,collMode1
			,paymentMode
			,paymentMode1
			,tranCount
			,amount
			,period
			,isEnable			
			,createdBy
			,createdDate
			,modifiedBy
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
			SELECT 'X' FROM cisDetail WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM cisDetail WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @cisDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM cisDetail WHERE approvedBy IS NULL AND cisDetailId = @cisDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cisDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @cisDetailId
					RETURN
				END
			DELETE FROM cisDetail WHERE cisDetailId =  @cisDetailId
			DELETE FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cisDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @cisDetailId
					RETURN
				END
			DELETE FROM cisDetailHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
			DELETE FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @cisDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM cisDetail WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM cisDetail WITH(NOLOCK)
			WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @cisDetailId
			RETURN
		END
		BEGIN TRANSACTION
			DECLARE @newCriteriaValue VARCHAR(MAX)
			IF EXISTS (SELECT 'X' FROM cisDetail WHERE approvedBy IS NULL AND cisDetailId = @cisDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM cisDetailHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE cisDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE cisDetailId = @cisDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisDetailId, @newValue OUTPUT
				
				SELECT 
					@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
				FROM cisCriteriaHistory 
				WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
				
				EXEC [dbo].proc_GetColumnToRow  'cisCriteria', 'cisDetailId', @cisDetailId, @oldValue OUTPUT
				
				DELETE FROM cisCriteria WHERE cisDetailId = @cisDetailId
				INSERT cisCriteria(criteriaId, idTypeId, cisDetailId, createdBy, createdDate)
				SELECT criteriaId, idTypeId, @cisDetailId, @user, GETDATE() FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance ID Criteria', @cisDetailId, @user, @oldValue, @newCriteriaValue	
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.condition = mode.condition
					,main.collMode = mode.collMode
					,main.paymentMode = mode.paymentMode
					,main.tranCount = mode.tranCount
					,main.amount = mode.amount
					,main.period = mode.period
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM cisDetail main
				INNER JOIN cisDetailHistory mode ON mode.cisDetailId = main.cisDetailId
				WHERE mode.cisDetailId = @cisDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'cisDetail', 'cisDetailId', @cisDetailId, @newValue OUTPUT
				
				SELECT 
					@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
				FROM cisCriteriaHistory 
				WHERE cisDetailId = @cisDetailId
				
				EXEC [dbo].proc_GetColumnToRow  'cisCriteria', 'cisDetailId', @cisDetailId, @oldValue OUTPUT
				
				DELETE FROM cisCriteria WHERE cisDetailId = @cisDetailId
				INSERT cisCriteria(criteriaId, idTypeId, cisDetailId, createdBy, createdDate)
				SELECT criteriaId, idTypeId, @cisDetailId, @user, GETDATE() FROM cisCriteriaHistory WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance ID Criteria', @cisDetailId, @user, @oldValue, @newCriteriaValue
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisDetailId, @oldValue OUTPUT
				UPDATE cisDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE cisDetailId = @cisDetailId
				
				DELETE FROM cisCriteria WHERE cisDetailId = @cisDetailId
			END
			
			UPDATE cisDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL
			
			UPDATE cisCriteriaHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE cisDetailId = @cisDetailId AND approvedBy IS NULL 
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cisDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @cisDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @cisDetailId
	END
	ELSE IF @flag = 'disabled'
	BEGIN
		--UPDATE csDetail SET isDisabled=case when isDisabled='y' then 'n' else 'y' end where csDetailId=@csDetailId
		--EXEC proc_errorHandler 0, 'Record disabled successfully.', @csDetailId
		
		
		IF (SELECT ISNULL(isEnable,'N') FROM cisDetail WHERE cisDetailId = @cisDetailId) = 'N'
		BEGIN
			UPDATE cisDetail SET isEnable='Y' WHERE cisDetailId = @cisDetailId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @cisDetailId
			RETURN;
		END
		ELSE
		BEGIN		
			UPDATE cisDetail SET isEnable='N' WHERE cisDetailId = @cisDetailId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @cisDetailId
			RETURN;
		END
		IF (SELECT ISNULL(isEnable,'N') FROM cisDetailHistory WHERE cisDetailId = @cisDetailId)='N'
		BEGIN
			UPDATE cisDetailHistory SET isEnable='Y' WHERE cisDetailId = @cisDetailId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @cisDetailId
			RETURN;
		END
		ELSE
		BEGIN		
			UPDATE cisDetailHistory SET isEnable='N' WHERE cisDetailId = @cisDetailId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @cisDetailId
			RETURN;
		END	
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @cisDetailId
END CATCH


GO
