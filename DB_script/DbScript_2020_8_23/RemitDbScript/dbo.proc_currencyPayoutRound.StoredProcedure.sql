USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_currencyPayoutRound]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_currencyPayoutRound]') AND TYPE IN (N'P', N'PC'))
      DROP PROCEDURE [dbo].proc_currencyPayoutRound
GO
*/

/*
    Exec [proc_currencyPayoutRound] @flag = 'l', @rowid = '1'
*/
CREATE proc [dbo].[proc_currencyPayoutRound]
	 @flag                          VARCHAR(50)	= NULL
	,@user                          VARCHAR(30)	= NULL
    ,@rowid							INT			= NULL
    ,@currency						VARCHAR(3)	= NULL
	,@place							INT			= NULL
    ,@currDecimal					INT			= NULL
    ,@tranType						INT			= NULL
    ,@isDeleted						CHAR(1)		= NULL     
    ,@sortBy						VARCHAR(50)	= NULL
    ,@sortOrder						VARCHAR(5)	= NULL
    ,@pageSize						INT			= NULL
    ,@pageNumber					INT			= NULL


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

IF @flag = 'p'
BEGIN
	SELECT @rowId = rowId FROM currencyPayoutRound WHERE ISNULL(isDeleted, 'N') = 'N' AND currency = @currency AND tranType = @tranType 
	IF @rowid IS NULL
		SELECT @rowId = rowId FROM currencyPayoutRound WHERE ISNULL(isDeleted, 'N') = 'N' AND currency = @currency AND tranType IS NULL
	
	SELECT place = ISNULL(place, 0), currDecimal = ISNULL(currDecimal, 0) FROM currencyPayoutRound WHERE rowId = @rowid
END
ELSE IF @flag = 'a'
BEGIN 
    
    SELECT * From currencyPayoutRound with (nolock)
    where rowid= @rowid

END

ELSE IF @flag = 'd'
BEGIN 
    BEGIN TRANSACTION
		UPDATE currencyPayoutRound SET 
			 isDeleted		= 'Y'
			,modifiedBy		= @user
			,modifiedDate	= GETDATE()
		WHERE rowid = @rowid

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


ELSE IF @flag = 'u'
BEGIN 
	IF(SELECT TOP 1 ISNULL(tranType,0) FROM currencyPayoutRound WHERE 
			currency = @currency 
			AND tranType IS NULL 
			AND ISNULL(isDeleted,'N')<> 'Y' 
			AND rowId <> @rowid) <> ISNULL(@tranType,0)
	BEGIN
		EXEC proc_errorHandler 1, 'All Trantype already setup.', @rowid
		RETURN
	END
	
	IF EXISTS(SELECT TOP 1 ISNULL(tranType,0) FROM currencyPayoutRound WHERE 
				currency = @currency 
				AND tranType IS NOT NULL 
				AND ISNULL(isDeleted,'N') <> 'Y' AND rowId <> @rowid
			)
	BEGIN
		IF @tranType IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot setup all Trantype.', @rowid
			RETURN;
		END
	END
	
	IF EXISTS(SELECT TOP 1 'X' FROM currencyPayoutRound WHERE 
				currency = @currency 
				AND tranType = @tranType 
				AND ISNULL(isDeleted,'N')<> 'Y' AND rowId <> @rowid
			)
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN;
	END
    	
BEGIN TRANSACTION
    UPDATE currencyPayoutRound SET 
		 currency		=	@currency
		,place			=	@place
		,currDecimal	=	@currDecimal
		,tranType		=	@tranType	
		,modifiedBy		=	@user
		,modifiedDate	=	GETDATE()
    WHERE rowid = @rowid

    INSERT INTO #msg(errorCode, msg, id)
	EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
	
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

ELSE IF @flag = 'i'
BEGIN 
		
	
	--select * from staticDataValue where valueId=7100
	IF (SELECT TOP 1 ISNULL(tranType,0) FROM currencyPayoutRound WHERE currency = @currency AND tranType IS NULL AND ISNULL(isDeleted,'N')<> 'Y')<> ISNULL(@tranType,0)
	BEGIN
		EXEC proc_errorHandler 1, 'All Trantype already setup.', @rowid
		RETURN;
	END
	
	IF EXISTS (SELECT TOP 1 ISNULL(tranType,0) FROM currencyPayoutRound WHERE currency = @currency AND tranType IS NOT NULL AND ISNULL(isDeleted,'N')<> 'Y')
	BEGIN
		IF @tranType IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot setup all Trantype.', @rowid
			RETURN;
		END
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM currencyPayoutRound WHERE currency = @currency AND tranType = @tranType AND ISNULL(isDeleted,'N')<> 'Y' )
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added.', @rowid
		RETURN;
	END
	BEGIN TRANSACTION
	     INSERT INTO currencyPayoutRound (
			 currency
			,place
			,currDecimal
			,tranType
			,createdBy
			,createdDate
		)
		SELECT
			 @currency
			,@place
			,@currDecimal
			,@tranType
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



ELSE IF @flag = 's'
BEGIN 
	IF @sortBy IS NULL
		SET @sortBy = 'createdDate'
	IF @sortOrder IS NULL
		SET @sortOrder = 'DESC'
		
	SET @table = '(		
					SELECT 
					   rowID
					  ,typeTitle = ISNULL(typeTitle,''All'') 
					  ,G.currency
					  ,place = ISNULL(SV.detailTitle,''0'')
					  ,G.currDecimal
					  ,G.createdBy
					  ,G.createdDate
				   FROM currencyPayoutRound G
				   LEFT JOIN serviceTypeMaster sT on G.tranType =sT.serviceTypeId
				   LEFT JOIN staticDataValue SV WITH (NOLOCK) ON SV.valueId = G.place
				   WHERE isnull(G.isDeleted,''N'') <> ''Y''
				   AND G.currency = ''' + @currency + '''
			 '	
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,typeTitle
						  ,currency
						  ,place 
						  ,currDecimal
						  ,createdBy
						  ,createdDate
						'
			
		------IF @currencyId IS NOT NULL
		------	SET @sqlFilter = @sqlFilter + ' AND currencyId = ''' + @currencyId + ''''		

	    
		  SET @table =  @table +') x '

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
