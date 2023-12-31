USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryHolidayList]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*/
CREATE proc [dbo].[proc_countryHolidayList]
	@flag                       VARCHAR(50)	= NULL
	,@user                      VARCHAR(30)	= NULL
    ,@rowid						INT			= NULL
    ,@countryId					VARCHAR(50) = NULL
	,@eventDate					DATE		= NULL
    ,@rsCountryId				VARCHAR(50) = NULL
    ,@eventName					VARCHAR(100)= NULL
    ,@eventDesc					VARCHAR(MAX)= NULL
    ,@isDeleted                 CHAR(1)		= NULL     
    ,@sortBy                    VARCHAR(50)	= NULL
    ,@sortOrder                 VARCHAR(5)	= NULL
    ,@pageSize                  INT			= NULL
    ,@pageNumber                INT			= NULL


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
		,@errorMsg			VARCHAR(MAX)

	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)

IF @flag = 'a'
BEGIN 
    
    SELECT rowId,CONVERT(VARCHAR,eventDate,101) [eventDate],eventDesc,eventName From countryHolidayList with (nolock)
    where rowid= @rowid

END


ELSE IF @flag = 'd'
BEGIN 
    BEGIN TRANSACTION
    
		UPDATE countryHolidayList 
		 set isDeleted ='Y', ModifiedBy=@user, ModifiedDate=GETDATE()
		where rowid= @rowid

	INSERT INTO #msg(errorCode, msg, id)
	EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
	
	IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
	BEGIN
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		EXEC proc_errorHandler 1, 'Failed to delete record.', @rowid
		RETURN
	END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Record has been deleted successfully.', @rowid
END

ELSE IF @flag = 'i'
BEGIN 
	
	
	BEGIN TRANSACTION
	     INSERT INTO 
		 countryHolidayList (
			countryId
			,eventDate
			,eventName
			,eventDesc
			,createdBy
			,createdDate
		)
		SELECT
			@countryId
			,@eventDate
			,@eventName
			,@eventDesc
			,@user
			,GETDATE()

		SET @rowid = SCOPE_IDENTITY()
		
	    INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowid
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowid

END

ELSE IF @flag = 'u'
BEGIN 
	
	
	BEGIN TRANSACTION
	     UPDATE  countryHolidayList SET 
			countryId = @countryId
			,eventDate = @eventDate
			,eventName = @eventName
			,eventDesc = @eventDesc
			,modifiedBy = @user
			,modifiedDate = GETDATE()
		WHERE rowId = @rowid
		
	    INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'u', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowid
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowid

END

ELSE IF @flag = 's'
BEGIN 
	
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
							rowId 
							,countryId
							,eventDate
							,eventName
							,eventDesc
							,createdBy
							,createdDate
						FROM countryHolidayList  WITH (NOLOCK)
					    WHERE ISNULL(isDeleted,''N'') <> ''Y''
					    AND CountryId = '''+ @countryId +'''
			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,countryId
						  ,eventDate
						  ,eventName 
						  ,eventDesc 
						  ,createdBy
						  ,createdDate
						'
		
		  SET @table =  @table +') x '

		IF @eventName IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND eventName  =  ''' + @eventName + ''''		


		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
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
     EXEC proc_errorHandler 1, @errorMessage, @rowid
END CATCH


GO
