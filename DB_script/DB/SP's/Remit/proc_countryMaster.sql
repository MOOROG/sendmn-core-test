USE [FastMoneyPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryMaster]    Script Date: 2/5/2019 2:26:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_countryMaster]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_countryMaster

GO

proc_countryMaster 's'

*/
ALTER PROC [dbo].[proc_countryMaster]
 	 @flag								VARCHAR(150)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@countryId                         VARCHAR(30)		= NULL
	,@countryCode                       VARCHAR(10)		= NULL
	,@countryName                       VARCHAR(50)		= NULL
	,@isOperativeCountry				VARCHAR(1)		= NULL
    ,@isoAlpha3							VARCHAR(50)		= NULL
    ,@iocOlympic						VARCHAR(50)		= NULL
    ,@isoNumeric						VARCHAR(50)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@operationType						VARCHAR(2)		= NULL
	,@fatfRating						VARCHAR(20)		= NULL
	,@timeZoneId						INT				= NULL
	,@agentOperationControlType			VARCHAR(5)		= NULL
	,@defaultRoutingAgent				INT				= NULL
	,@countryMobCode					VARCHAR(10)		= NULL
	,@CountryMobLength					INT				= NULL
	,@countryType						varchar(20)		= Null 
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
		 @logIdentifier = 'countryId'
		,@logParamMain = 'countryMaster'
		,@logParamMod = 'countryMasterMod'
		,@module = '20'
		,@tableAlias = 'Country Master'
		
	IF @flag = 'cl' -- country List
	BEGIN
		SELECT [0], [1] FROM (
			SELECT NULL [0], 'All' [1] UNION ALL
			
			SELECT
				 ccm.countryId [0]
				,ccm.countryName [1]
			FROM countryMaster ccm WITH (NOLOCK) 
			WHERE ISNULL(ccm.isDeleted, 'N')  <> 'Y'  
		) x ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END	
		RETURN	
	END
	
    ELSE IF @flag = 'cl2' -- country List with Name as Value
	BEGIN

		SELECT [value], [text] FROM (
			SELECT NULL [value], 'All' [text] UNION ALL
			
			SELECT
				 ccm.countryName [value]
				,ccm.countryName [text]
			FROM countryMaster ccm WITH (NOLOCK) 
			WHERE ISNULL(ccm.isOperativeCountry, 'N') = 'Y' 
			AND ISNULL(ccm.isDeleted, 'N')  <> 'Y'  
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END	
		
	RETURN	
	END
	
	ELSE IF @flag = 'l'
	BEGIN
		SELECT 
			 countryId 
			,countryName 
		FROM countryMaster WITH (NOLOCK) 
		WHERE ISNULL(isDeleted, 'N')  <> 'Y' 
		ORDER BY countryName
		
		RETURN	
	END

     --Country List by ID
    ELSE IF @flag = 'lid'
	BEGIN

		  select distinct C.countryId, C.countryName 
		  from rsList1 R, countryMaster C , countryMaster M
		  where R.rsCountryId = C.countryId and R.countryId = M.countryId
		  AND M.countryName = @countryName
		  AND ISNULL(C.isDeleted, 'N')  <> 'Y' 
		  ORDER BY C.countryName
		
		RETURN	
	END
	 --type By Name
    ELSE IF @flag = 'typeByName'
	BEGIN

		  SELECT distinct
				S.serviceTypeId, S.typeTitle 
		  from rsList1 R, countryMaster C , countryMaster M, serviceTypeMaster S
		  where R.rsCountryId = C.countryId and R.countryId = M.countryId 
				and R.tranType = S.serviceTypeId 
		  AND M.countryName = @countryName
		  AND C.countryId = @countryId
		  AND ISNULL(C.isDeleted, 'N')  <> 'Y' 
		  ORDER BY S.typeTitle
		
		RETURN	
	END
	
	ELSE IF @flag = 'l2'
	BEGIN
		--SELECT
		--	 cm.countryId 
		--	,cm.countryName 
		--FROM countryMaster cm WITH (NOLOCK)
		--INNER JOIN applicationUsers au WITH(NOLOCK) ON cm.countryId = au.countryId
		--WHERE au.userName = @user AND ISNULL(cm.isDeleted, 'N')  <> 'Y' 
		--ORDER BY countryName
		
		SELECT
			 countryId 
			,countryName 
		FROM countryMaster WITH (NOLOCK) 
		WHERE ISNULL(isDeleted, 'N') <> 'Y' 
		ORDER BY countryName
		
		RETURN	
	END
	
	ELSE IF @flag = 'ocl'	--Operative Country List(sending or receiving)
	BEGIN
		IF @countryType = 'sCountry'
			SELECT
				 countryId
				,countryName
			FROM countryMaster WITH(NOLOCK)
			WHERE ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isOperativeCountry, 'N') = 'Y'
			AND ISNULL( operationType,'S') = 'S'
			ORDER BY countryName

		ELSE IF @countryType = 'rCountry'
			SELECT
				 countryId
				,countryName
			FROM countryMaster WITH(NOLOCK)
			WHERE ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isOperativeCountry, 'N') = 'Y'
			AND ISNULL( operationType,'R') = 'R'
			ORDER BY countryName
		ELSE 
			SELECT
				 countryId
				,countryName
			FROM countryMaster WITH(NOLOCK)
			WHERE ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isOperativeCountry, 'N') = 'Y'
			AND  operationType IS NOT NULL
			ORDER BY countryName

	END
	
	ELSE IF @flag = 'ocl1'	--Operative Country List (international)
	BEGIN
		--SELECT
		--	 countryId
		--	,countryName
		--FROM countryMaster WITH(NOLOCK)
		--WHERE ISNULL(isDeleted, 'N') = 'N'
		--AND ISNULL(isOperativeCountry, 'N') = 'Y'
		--AND countryName<>'Nepal'
		--ORDER BY countryName
		SELECT * FROM (
		SELECT countryId,countryName FROM countryMaster WHERE countryName ='NEPAL'
		UNION ALL
		SELECT
			countryId,
			countryName
		FROM countryMaster 
		WHERE ISNULL(isOperativeCountry,'') = 'Y'
		AND ISNULL(operationType,'B') IN ('B','S') 
		) X ORDER BY countryName
		--ORDER BY countryName ASC	
	RETURN
	
	END
	
	ELSE IF @flag = 'scl'
	BEGIN
		SELECT 
			 countryId
			,countryName
		FROM countryMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(isOperativeCountry, 'N') = 'Y'
		AND operationType IN ('B', 'S')
		ORDER BY countryName
	END
	
	ELSE IF @flag = 'rcl'
	BEGIN
		SELECT 
			 countryId
			,countryName
		FROM countryMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(isOperativeCountry, 'N') = 'Y'
		AND operationType IN ('B', 'R')
		ORDER BY countryName
	END
	--EXEC proc_countryMaster @flag = 'rclNepalOnly'
	ELSE IF @flag = 'rclNepalOnly'
	BEGIN
		SELECT 
			 countryId
			,countryName
		FROM countryMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(isOperativeCountry, 'N') = 'Y'
		AND operationType IN ('B', 'R')
	--	AND countryName = 'Nepal'
		ORDER BY countryName
	END

	ELSE IF @flag = 'rclForRouting'
	BEGIN
		SELECT
			 cm.countryId
			,countryName
		FROM countryReceivingMode crm WITH(NOLOCK)
		INNER JOIN countryMaster cm WITH (NOLOCK)
		ON crm.countryId = cm.countryId
		WHERE crm.receivingMode = 3
		--AND cm.countryId <> 133
		ORDER BY countryName
	END
	
	ELSE IF @flag = 'ot'	--Get Operation Type
	BEGIN
	--	SELECT operationType = ISNULL(operationType, '''') FROM countryMaster WITH(NOLOCK) WHERE countryId = @countryId
		SELECT operationType = 'B' FROM countryMaster WITH(NOLOCK) WHERE countryId = @countryId

		RETURN
	END
	
	ELSE IF @flag = 'i'
	BEGIN

		IF EXISTS(SELECT 'X' FROM countryMaster WITH(NOLOCK) WHERE countryCode = @countryCode AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Country code already exists', NULL
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM countryMaster WITH(NOLOCK) WHERE countryName = @countryName AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Country Name already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			
			INSERT INTO countryMaster (
				 countryCode
				,countryName
				,isOperativeCountry
				,isoAlpha3
				,iocOlympic
				,isoNumeric
				,createdBy
				,createdDate
				,operationType
				,fatfRating
				,timeZoneId
				,agentOperationControlType
				,defaultRoutingAgent
				,countryMobCode
				,countryMobLength
			)
			SELECT
				 @countryCode
				,@countryName
				,@isOperativeCountry
				,@isoAlpha3
				,@iocOlympic
				,@isoNumeric
				,@user
				,GETDATE()
				,@operationType
				,@fatfRating
				,@timeZoneId
				,@agentOperationControlType
				,@defaultRoutingAgent
				,@countryMobCode
				,@countryMobLength
				
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @countryId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @countryId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM countryMaster WITH(NOLOCK) WHERE countryId = @countryId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE countryMaster SET
				 countryCode = @countryCode
				,countryName = @countryName
				,isOperativeCountry = @isOperativeCountry
				,isoAlpha3 = @isoAlpha3
				,iocOlympic = @iocOlympic
				,isoNumeric = @isoNumeric
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				,operationType = @operationType
				,fatfRating = @fatfRating
				,timeZoneId = @timeZoneId
				,agentOperationControlType = @agentOperationControlType
				,defaultRoutingAgent = @defaultRoutingAgent
				,countryMobCode	= @countryMobCode
				,countryMobLength = @countryMobLength
			WHERE countryId = @countryId
			
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @countryId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @countryId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE countryMaster SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE countryId = @countryId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @countryId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @countryId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @countryId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @countryId
	END

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'countryId'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(
				SELECT  
					 main.countryId
					,main.countryCode
					,main.countryName

					,main.isoAlpha3
					,main.iocOlympic
					,main.isoNumeric
				   
					,main.createdBy
					,main.createdDate
					,main.isDeleted
					,main.isOperativeCountry
					,[isOperativeCountryFlag] = CASE WHEN main.isOperativeCountry =''Y'' THEN ''YES'' ELSE ''NO'' END
					,opType = main.operationType
					,operationType = CASE WHEN main.operationType = ''B'' THEN ''Both'' WHEN main.operationType = ''S'' THEN ''Send'' WHEN main.operationType = ''R'' THEN ''Receive''
										ELSE ''Not Configured'' END
				FROM countryMaster MAIN  WITH(NOLOCK)
				WHERE ISNULL(isDeleted, ''N'') = ''N''
					) x'

		SET @sql_filter = ''
		
		IF @countryCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryCode = ''' + @countryCode + ''''

		IF @isoAlpha3 IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isoAlpha3 = ''' + @isoAlpha3 + ''''
		
		IF @iocOlympic IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND iocOlympic = ''' + @iocOlympic + ''''
		
		IF @isoNumeric IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isoNumeric = ''' + @isoNumeric + ''''
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
		
		IF @isOperativeCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isOperativeCountry, ''N'') = ''' + @isOperativeCountry + ''''
			
		SET @select_field_list ='
			 countryId
			,countryCode
			,countryName
			,isoAlpha3
			,iocOlympic
			,isoNumeric
			,createdBy
			,createdDate
			,isDeleted 
			,isOperativeCountryFlag
			,opType
			,operationType'

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
	
	ELSE IF @flag IN ('s2')					--Load Operative Country List Only
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'countryId'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
--<a href = \"SendingLimit/List.aspx?countryId=@countryName\">Collection Limit</a>&nbsp;|&nbsp;<a href = \"ReceivingLimit/List.aspx?countryId=@countryName\">Payment Limit</a>
		SET @table = '(
				SELECT  
					 main.countryId
					,main.countryCode
					,main.countryName

					,main.isoAlpha3
					,main.iocOlympic
					,main.isoNumeric
				   
					,main.createdBy
					,main.createdDate
					,main.isDeleted
					,main.isOperativeCountry
					,[isOperativeCountryFlag] = CASE WHEN main.isOperativeCountry =''Y'' THEN ''YES'' ELSE ''NO'' END
					,link = CASE 
							WHEN main.operationType = ''B'' THEN ''<a href="SendingLimit/List.aspx?countryId='' + CAST(main.countryId AS VARCHAR) + ''&countryName='' + main.countryName + ''">Collection Limit</a> | <a href="ReceivingLimit/List.aspx?countryId='' + CAST(main.countryId AS VARCHAR) + ''&countryName='' + main.countryName + ''">Receiving Limit</a>''
							WHEN main.operationType = ''S'' THEN ''<a href="SendingLimit/List.aspx?countryId='' + CAST(main.countryId AS VARCHAR) + ''&countryName='' + main.countryName + ''">Collection Limit</a>''
							WHEN main.operationType = ''R'' THEN ''<a href="ReceivingLimit/List.aspx?countryId='' + CAST(main.countryId AS VARCHAR) + ''&countryName='' + main.countryName + ''">Receiving Limit</a>''
							ELSE ''Please define operation type'' END
				FROM countryMaster MAIN  WITH(NOLOCK)
				WHERE isOperativeCountry = ''Y'' AND main.operationType IS NOT NULL AND ISNULL(isDeleted, ''N'') = ''N''
					) x'

		SET @sql_filter = ''
		
		IF @countryCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryCode = ''' + @countryCode + ''''

		IF @isoAlpha3 IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isoAlpha3 = ''' + @isoAlpha3 + ''''
		
		IF @iocOlympic IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND iocOlympic = ''' + @iocOlympic + ''''
		
		IF @isoNumeric IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isoNumeric = ''' + @isoNumeric + ''''
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
		
		IF @isOperativeCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isOperativeCountry, ''N'') = ''' + @isOperativeCountry + ''''
			
		SET @select_field_list ='
			 countryId
			,countryCode
			,countryName
			,isoAlpha3
			,iocOlympic
			,isoNumeric
			,createdBy
			,createdDate
			,isDeleted 
			,isOperativeCountryFlag
			,link'

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
	
	ELSE IF @flag = 'l23'--agent country list
	BEGIN
		
		
		SELECT agentCountryId countryId ,agentCountry countryName 
		FROM agentMaster WHERE agentId =(SELECT agentId FROM applicationUsers WHERE userName='bharat')

	END
	
	ELSE IF @flag = '321' --customer relation
	BEGIN
				
		SELECT valueId,detailTitle FROM staticDataValue WHERE typeID=2100
	END
	
	
	ELSE IF @flag = 'countryCode2Name'
	BEGIN
		SELECT countryName from countryMaster with(nolock) where countryCode = @countryCode
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @countryId
END CATCH


