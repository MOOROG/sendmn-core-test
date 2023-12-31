USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sscCopyDetail]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_sscCopyDetail]
	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@sscDetailId                        VARCHAR(30)    = NULL
	,@sscMasterId                        INT            = NULL
	,@fromAmt                            MONEY          = NULL
	,@toAmt                              MONEY          = NULL
	,@pcnt                               FLOAT          = NULL
	,@minAmt                             MONEY          = NULL
	,@maxAmt                             MONEY          = NULL
	,@sessionId							 VARCHAR(50)    = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL


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
		 @ApprovedFunctionId = 20141130
		,@logIdentifier = 'sscDetailId'
		,@logParamMain = 'sscDetailTemp'
		,@logParamMod = 'sscDetailHistory'
		,@module = '20'
		,@tableAlias = 'Special Service Charge Detail'
			
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM sscDetailTemp
				WHERE sscDetailId <> ' + CAST(ISNULL(@sscDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @sscDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @sscDetailId
			RETURN	
		END
	END	
	
	IF @flag = 'i'
	BEGIN
		
		BEGIN TRANSACTION
			INSERT INTO sscDetailTemp (				 
				 sscMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
				,sessionId
			)
			SELECT	
				 @sscMasterId			 
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				,@sessionId
				
				
			SET @sscDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @sscDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		
		SELECT * FROM sscDetailTemp WITH(NOLOCK) WHERE sscDetailId=@sscDetailId 
		
	END

	ELSE IF @flag = 'u'
	BEGIN

		BEGIN TRANSACTION

				UPDATE sscDetailTemp SET
				 fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE sscDetailId = @sscDetailId			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @sscDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN

			DELETE FROM sscDetailTemp WHERE sscDetailId = @sscDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @sscDetailId
			RETURN
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'sscDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 sscMasterId
					,sscDetailId = main.sscDetailId
					,fromAmt = main.fromAmt 
					,toAmt = main.toAmt 
					,pcnt = main.pcnt
					,minAmt =  main.minAmt
					,maxAmt =  main.maxAmt
					,main.createdBy
					,main.createdDate
					,main.modifiedBy 
			

				FROM sscDetailTemp main WITH(NOLOCK) WHERE sscMasterId='+cast(@sscMasterId as varchar)+' and SESSIONID='''+@sessionId+''') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 sscMasterId
			,sscDetailId
			,fromAmt
			,toAmt
			,pcnt
			,minAmt
			,maxAmt
			,createdBy
			,createdDate
			,modifiedBy

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

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sscDetailId
END CATCH



GO
