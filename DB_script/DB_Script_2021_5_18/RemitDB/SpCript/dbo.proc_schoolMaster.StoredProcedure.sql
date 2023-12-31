USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_schoolMaster]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_schoolMaster]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId								INT				= NULL
	,@schoolId							INT				= NULL
	,@name		                        VARCHAR(200)	= NULL
	,@levelId							INT				= NULL
	,@levelName							VARCHAR(200)	= NULL
	,@address							VARCHAR(max)	= NULL
	,@contactNo							VARCHAR(10)		= NULL
	,@faxNo								VARCHAR(100)	= NULL
	,@contactPerson						VARCHAR(200)	= NULL
	,@country							VARCHAR(100)	= NULL
	,@zone								VARCHAR(100)	= NULL
	,@district							VARCHAR(100)	= NULL
	,@agentId							INT				= NULL
	,@bankId							INT				= NULL
	,@bankBranchId						INT				= NULL
	,@accountNo							VARCHAR(50)		= NULL
	,@agentName							VARCHAR(200)	= NULL	
	,@feeTypeId							INT				= NULL
	,@isMaintainYrSem					VARCHAR(1)		= NULL	
	,@accountName						VARCHAR(200)	= NULL
	,@tranId							VARCHAR(50)		= NULL
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
		,@modType			VARCHAR(6)
	SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'schoolMaster'
		,@logParamMod = 'schoolMaster'
		,@module = '40'
		,@tableAlias = 'School Master'	

	IF @flag='ss'-->> Select School
	BEGIN
		SELECT rowId,name+' -'+address name FROM schoolMaster sm WITH(NOLOCK) inner join agentMaster am with(nolock) on sm.agentId = am.agentId
                WHERE isnull(sm.isDeleted,'N') = 'N' and isnull(sm.isActive,'Y') = 'Y'
				and isnull(am.isActive,'Y') = 'Y'
				Order by name 

	END
	
	IF @flag='sl'-->> Select Level/Program accroding to schoolId
	BEGIN
			SELECT rowid,name FROM schoolLevel WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND isDeleted IS NULL
	END
	IF @flag='s2'-->> Select Level/Program accroding to agentId of School
	BEGIN
			select @schoolId=rowId from schoolMaster with(nolock) where agentId=@agentId
			SELECT rowid,name FROM schoolLevel WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND isDeleted IS NULL
	END
	IF @flag='s3'-->> Select school/college agent
	BEGIN
			select agentId, agentName 
			from agentMaster with(nolock) 
			where parentId = '5576' 
			AND ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isActive, 'N') = 'Y'
			Order by agentName 
	END
	IF @flag='sf'-->> Select fee type accroding to schoolId & Level/Program 
	BEGIN
			SELECT rowid,feeType name FROM schoolFee WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND levelId=@levelId AND isDeleted IS NULL
	END
	
	IF @flag='sta'-->> Select transfer amount (fee amount)
	BEGIN
			SELECT dbo.ShowDecimalExceptComma(ISNULL(amount,0)) amount FROM schoolFee WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND levelId=@levelId 
                    AND isDeleted IS NULL and rowid=@feeTypeId
	END
	IF @flag = 'i'
	BEGIN
	
		BEGIN TRANSACTION
			
			--select * from schoolMaster
			--ALTER TABLE schoolMaster ADD isMaintainYrSem VARCHAR(1)
			INSERT INTO schoolMaster (
				 name
				,address
				,contactNo
				,faxNo
				,contactPerson
				,country
				,zone
				,district
				,agentId
				,bankId
				,bankBranchId
				,accountNo
				,createdDate
				,createdBy
				,isMaintainYrSem
				,accountName
			)
			SELECT
				 @name
				,@address
				,@contactNo
				,@faxNo
				,@contactPerson
				,@country
				,@zone
				,@district
				,@agentId
				,@bankId
				,@bankBranchId
				,@accountNo
				,GETDATE()
				,@user		
				,@isMaintainYrSem
				,@accountName	
					
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT a.*,b.agentName agentName 
		from schoolMaster a with(nolock) inner join agentMaster b with(nolock) 
		on a.agentId=b.agentId
		where rowId=@rowId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE schoolMaster SET
					 name			= @name
					,address		= @address
					,contactNo		= @contactNo
					,faxNo			= @faxNo
					,contactPerson	= @contactPerson
					,country		= @country
					,zone			= @zone
					,district		= @district
					,agentId		= @agentId
					,bankId			= @bankId
					,bankBranchId	= @bankBranchId
					,accountNo		= @accountNo
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()
					,isMaintainYrSem= @isMaintainYrSem
					,accountName	= @accountName
			WHERE rowId = @rowId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @rowId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE schoolMaster SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE rowId = @rowId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	END

	ELSE IF @flag = 's'
	BEGIN
	
		IF @sortBy IS NULL
			SET @sortBy = 'rowId'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(
							SELECT
								 main.rowId
								,agMas.agentName
								,main.name
								,main.address 
								,main.contactNo		
								,main.faxNo			   
								,main.contactPerson
								,main.country
								,main.zone
								,main.district
								,main.createdDate
								,main.createdBy
							FROM schoolMaster main WITH(NOLOCK) inner join agentMaster agMas with(nolock) on main.agentId=agMas.agentId
								WHERE ISNULL(main.isDeleted, '''')<>''Y''
					) x'

		SET @sql_filter = ''
	
		IF @name IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND name like ''%' + @name + '%'''
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName like ''%' + @agentName + '%'''
			
		SET @select_field_list ='
			 rowId
			,agentName
			,name
			,address
			,contactNo
			,faxNo
			,contactPerson
			,country
			,zone
			,district
			,createdDate
			,createdBy
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
	
	IF @FLAG='Li'
	BEGIN
		--SELECT * FROM schoolLevel		
			
			IF EXISTS(SELECT 'A' FROM schoolLevel 
				WHERE schoolId=@schoolId and name = @levelName and levelId=@levelId
					 AND isnull(isDeleted,'N')='N')
			BEGIN
				EXEC proc_errorHandler 1, 'ALREADY ADDED!', @rowId
				RETURN;
			END
			BEGIN TRANSACTION
			INSERT INTO schoolLevel (
				 name
				,levelId
				,schoolId
				,createdDate
				,createdBy
			)
			SELECT
				 @levelName
				,@levelId 
				,@schoolId
				,GETDATE()
				,@user			
					
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId

	END
	
	IF @FLAG='Ls'
	BEGIN
		SELECT * FROM schoolLevel with(nolock) WHERE schoolId=@schoolId AND isDeleted is null
	END
	
	IF @FLAG='Ld'
	BEGIN
		BEGIN TRANSACTION
			UPDATE schoolLevel SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE rowId = @rowId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	END

	IF @FLAG = 'yrSem'
	BEGIN
		SELECT ISNULL(isMaintainYrSem,'N') FROM SCHOOLMASTER WITH(NOLOCK) WHERE ROWID=@schoolId
	END

	IF @flag='msl'
	BEGIN			
			select @schoolId = stdCollegeId from tranReceivers with(nolock) where tranId = @tranId
			SELECT rowid,name FROM schoolLevel WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND isDeleted IS NULL
	END

	IF @flag='msl'
	BEGIN			
			select @schoolId = stdCollegeId from tranReceivers with(nolock) where tranId = @tranId
			SELECT rowid,name FROM schoolLevel WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND isDeleted IS NULL
	END
	IF @flag='msf'-->> Select fee type accroding to schoolId & Level/Program 
	BEGIN
			select @schoolId = stdCollegeId,@levelId = stdLevel from tranReceivers with(nolock) where tranId = @tranId
			SELECT rowid,feeType name FROM schoolFee WITH(NOLOCK) 
                    WHERE schoolId=@schoolId AND levelId=@levelId AND isDeleted IS NULL
	END
	IF @FLAG = 'mYrSem'
	BEGIN
		select @schoolId = stdCollegeId from tranReceivers with(nolock) where tranId = @tranId
		if (SELECT ISNULL(isMaintainYrSem,'N') FROM SCHOOLMASTER WITH(NOLOCK) WHERE ROWID=@schoolId) = 'Y'
			select valueId rowid,detailTitle name from staticDataValue with(nolock) where typeId=7600 and isnull(isActive,'Y')='Y' and isnull(is_delete,'N')='N'
		else
			select  valueId rowid, detailTitle name from staticDataValue with(nolock) where 1=2
		
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
