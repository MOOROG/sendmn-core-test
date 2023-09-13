SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[proc_commissionPackageAdd]
      @flag								VARCHAR(50)    = NULL
     ,@user								VARCHAR(30)    = NULL
     ,@id								INT			   = NULL
     ,@groupId							INT			   = NULL
     ,@packageId                        VARCHAR(150)   = NULL
     ,@type								CHAR(1)		   = NULL
     ,@code								VARCHAR(100)   = NULL
     ,@sortBy                           VARCHAR(50)    = NULL
	 ,@sortOrder                        VARCHAR(5)     = NULL
	 ,@pageSize                         INT            = NULL
	 ,@pageNumber                       INT            = NULL


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
		,@rulesId			VARCHAR(MAX)

	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionRuleNew TABLE(ruleId INT)
	DECLARE @found INT = 0
	DECLARE @ssAgent INT, @rsAgent INT,@sCountry INT, @rCountry INT, 
			@sAgent INT, @sBranch INT, @sState INT,	@sGroup INT, @rAgent INT, @rBranch INT, 
			@rState INT, @rGroup INT, @tranType INT
	
     IF @flag = 'i'
     BEGIN		
		BEGIN TRANSACTION	
			INSERT INTO commissionGroup
				(groupId,packageId,isActive,createdBy,createdDate)
			SELECT @groupId,value,'Y',@user,GETDATE() FROM dbo.Split(',',@packageId)
            INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @groupId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @groupId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
     END
	
	------------SHOW GRID DATA FOR DOMESTIC AND INTERNATIONAL COMMISSION PACKAGE 
	IF @flag = 'grid'
	BEGIN 
		IF @sortBy IS NULL  
			SET @sortBy = 'valueId'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'ASC'					
		
	SET @table = '(		
						SELECT
							 valueId
							,detailTitle
							,detailDesc
						FROM staticDataValue WITH (NOLOCK)
						WHERE typeId = CASE WHEN '''+@type+''' =''D'' THEN ''6400'' WHEN '''+@type+''' =''I'' THEN ''6500'' END
						AND ISNULL(IS_DELETE, ''N'') <> ''Y''
						AND ISNULL(isActive, ''Y'') = ''Y''
						AND valueId NOT IN 
						(
							SELECT packageId FROM commissionGroup
							WHERE ISNULL(isDeleted,''N'')<>''Y'' 
							AND ISNULL(isActive,''N'') = ''Y'' 
							AND groupId = '''+ CAST(@groupId AS VARCHAR) +'''
						)
			 '	
					
		SET @sqlFilter = ''	
		
		IF @code IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND detailTitle LIKE ''' + @code + '%'''	
		
		SET @selectFieldList = '
						   valueId
						  ,detailTitle
						  ,detailDesc 
						'
			
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
   
	----------PRINT @table
   
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH





GO

