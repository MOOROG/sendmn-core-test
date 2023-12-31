USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_OFACManualEntry]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_OFACManualEntry]
 	  @flag                             VARCHAR(50)		= NULL
     ,@rowId							VARCHAR(10)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@entNum							VARCHAR(30)		= NULL
     ,@name								VARCHAR(30)		= NULL
     ,@vesselType						VARCHAR(100)	= NULL
     ,@address							VARCHAR(50)		= NULL
     ,@city								VARCHAR(200)	= NULL
     ,@state							VARCHAR(100)	= NULL
     ,@zip								VARCHAR(10)		= NULL
     ,@country							VARCHAR(100)	= NULL
     ,@remarks							VARCHAR(100)	= NULL
     ,@dataSource						VARCHAR(100)	= NULL
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
		,@logParamMain = 'blacklist'
		,@logParamMod = 'blacklistLog'
		,@module = '20'
		,@tableAlias = 'Black List'
		
	IF @flag = 'i'
	BEGIN
					
			INSERT INTO blacklist(
							 ofacKey
							,entNum
							,name
							,vesselType
							,address
							,city
							,state
							,zip
							,country
							,remarks
							,dataSource
							,createdDate
							,createdBy
							,isManual)
						VALUES(
							 @dataSource+''+@entNum
							,@entNum
							,@name
							,@vesselType
							,@address
							,@city
							,@state
							,@zip
							,@country
							,@remarks
							,'MANUAL'
							,GETDATE()
							,@user
							,'Y')
			SET @rowId = @@IDENTITY
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
			INSERT INTO blacklistHistory(
						     blackListId
							,ofacKey
							,entNum
							,name
							,vesselType
							,address
							,city
							,state
							,zip
							,country
							,remarks
							,dataSource
							,createdDate
							,createdBy
							,isManual)
					VALUES(
							 @rowId
							,@dataSource+''+@entNum
							,@entNum
							,@name
							,@vesselType
							,@address
							,@city
							,@state
							,@zip
							,@country
							,@remarks
							,'MANUAL'
							,GETDATE()
							,@user
							,'Y')
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END
	
	ELSE IF @flag = 's'
	BEGIN
		SELECT * FROM blacklist WITH(NOLOCK) WHERE rowId = @rowId AND isManual = 'y' AND isdeleted IS NULL
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			declare @nameOld as varchar(500)
			select @nameOld = name from blackList with(nolock) where rowid = @rowid
			UPDATE blacklist SET
				 entNum			=	@entNum
				,ofacKey		=   @dataSource+''+@entNum
				,name			=	@name
				,vesselType		=	@vesselType
				,address		=	@address
				,city			=	@city
				,state			=	@state
				,zip			=	@zip
				,country		=	@country
				,remarks		=	@remarks
				,dataSource		=	'MANUAL'
				,modifiedDate	=	GETDATE()
				,modifiedBy		=	@user	
			WHERE rowId = @rowId	

			if @nameOld <> @name
			begin
				INSERT INTO blacklistHistory(
								 blackListId
								,ofacKey
								,entNum
								,name
								,vesselType
								,address
								,city
								,state
								,zip
								,country
								,remarks
								,dataSource
								,createdDate
								,createdBy
								,isManual)
						VALUES(
								 @rowId
								,@dataSource+''+@entNum
								,@entNum
								,@name
								,@vesselType
								,@address
								,@city
								,@state
								,@zip
								,@country
								,@remarks
								,'MANUAL'
								,GETDATE()
								,@user
								,'Y')
				end
			else
			begin
				UPDATE blacklistHistory SET
					 entNum			=	@entNum
					,ofacKey		=   @dataSource+''+@entNum
					,name			=	@name
					,vesselType		=	@vesselType
					,address		=	@address
					,city			=	@city
					,state			=	@state
					,zip			=	@zip
					,country		=	@country
					,remarks		=	@remarks
					,dataSource		=	'MANUAL'
					,modifiedDate	=	GETDATE()
					,modifiedBy		=	@user	
				WHERE blackListId = @rowId	
			end
			
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue, @module
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
		
			UPDATE blacklist SET
				 isdeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE rowId = @rowId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue, @module
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
	
	ELSE IF @flag IN ('a')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'Name'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			
		SET @table = '(
				SELECT
					 main.rowId
					,main.entNum
					,main.name
					,main.vesselType
					,main.address
					,main.city
					,main.state
					,main.zip
					,main.country
					,main.remarks
					,main.dataSource
					,main.createdBy
					,CONVERT(VARCHAR,main.createdDate,101) createdDate
					,main.isDeleted
					,main.isManual
				FROM blackList main WITH(NOLOCK)
					WHERE 1 = 1 and isManual IS NOT NULL and isdeleted IS NULL
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @name IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND name  = ''%' + @name + '%'''
		
		IF @country IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND country = ''' + @country + ''''
		
		IF @dataSource IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND dataSource = ''' + @dataSource + ''''
			
		IF @entNum IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND entNum = ''' + @entNum + ''''
			
		SET @select_field_list ='
			rowId,entNum,name,vesselType,address,city,state,zip,country,remarks,dataSource,isManual
			,createdBy
			,createdDate
			,isDeleted '
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
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH




GO
