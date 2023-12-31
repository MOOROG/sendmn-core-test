USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnMessageSetup]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_txnMessageSetup]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								INT				= NULL
	,@country                           NVARCHAR(MAX)	= NULL
	,@service                           NVARCHAR(MAX)	= NULL
	,@codeDescription                   NVARCHAR(MAX)	= NULL
	,@paymentMethodDesc					NVARCHAR(MAX)	= NULL
	,@msgFlag							VARCHAR(200)    = NULL
	,@isActive							VARCHAR(200)	= NULL
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
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@module				VARCHAR(10)
		,@tableAlias			VARCHAR(100)
		,@logIdentifier			VARCHAR(50)
		,@logParamMod			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@functionId			INT
		,@modType				VARCHAR(6)
		,@ApprovedFunctionId	INT
	SELECT
		 --@functionId = 20231200
		 @logIdentifier = 'id'
		,@logParamMain = 'txnMessageSetup'
		,@module = '20'
		,@tableAlias = 'Transaction Message Setup'

		IF @country ='Nnull'	
			SET @country=NULL
		IF @service ='Nnull'	
			SET @service=NULL
		IF @codeDescription ='Nnull'	
			SET @codeDescription=NULL
		IF @paymentMethodDesc ='Nnull'	
			SET @paymentMethodDesc=NULL
	
	IF @flag = 's'
	BEGIN
		SET @table = '(
					SELECT   id
							,country
							,service
							,codeDescription
							,paymentMethodDesc
							,flag
							,isActive
							,createdBy
							,createdDate 
					FROM txnMessageSetup WHERE ISNULL(isDeleted,''N'')<>''Y'' 				
				) '
	
	END	
	
	IF @flag = 'i'
	BEGIN

		IF EXISTS(SELECT 'X' FROM txnMessageSetup WHERE id = @id AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			
			INSERT INTO txnMessageSetup(				 
				 country
				,service
				,codeDescription
				,paymentMethodDesc
				,flag
				,isActive
				,createdBy
				,createdDate
			)
			SELECT				 
				 @country
				,@service
				,@codeDescription
				,@paymentMethodDesc
				,@msgFlag
				,@isActive
				,@user
				,GETDATE()
				
			SET @id = SCOPE_IDENTITY()
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM txnMessageSetup WITH(NOLOCK) WHERE id = @id
	END

	ELSE IF @flag = 'u'
	BEGIN
	
		BEGIN TRANSACTION
		
				UPDATE txnMessageSetup SET
						 country						= @country
						,service						= @service
						,codeDescription				= @codeDescription
						,paymentMethodDesc				= @paymentMethodDesc
						,flag							= @msgFlag
						,isActive						= @isActive
						,modifiedBy						= @user
						,modifiedDate					= GETDATE()
				WHERE id = @id

			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @id
	END
	
	ELSE IF @flag = 'd'
	BEGIN

		UPDATE txnMessageSetup SET isDeleted='Y',modifiedBy=@user,modifiedDate=GETDATE() WHERE id=@id

		EXEC proc_errorHandler 0, 'Record deleted successfully', @id
	END

	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			

		SET @table = '(
					SELECT   id
							,country
							,service
							,codeDescription
							,paymentMethodDesc
							,flag
							,isActive
							,createdBy
							,createdDate 
							,modifiedBy
							,'''' hasChanged
					FROM txnMessageSetup WHERE ISNULL(isDeleted,''N'')<>''Y'' 				
				)X '
		SET @sql_filter = ''		
		PRINT (@table)
		
		IF @country IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND  country LIKE ''%' + @country + '%'''
			
		IF @service IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND  service LIKE ''%' + @service + '%'''
			
		IF @codeDescription IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND  codeDescription LIKE ''%' + @codeDescription + '%'''
					
		SET @select_field_list ='
				 id              
				,country
				,service
				,codeDescription
				,paymentMethodDesc
				,flag
				,isActive
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
	
	ELSE IF @flag='display'
	BEGIN
		SELECT country [COUNTRY NAME]
			,service [SERVICE]
			,codeDescription [IME CODE DESCRIPTION]
			,paymentMethodDesc [PAYMENT METHOD]
		 FROM txnMessageSetup WHERE flag=@msgFlag
		 order by id desc
	END


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH

GO
