USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_bonusOperationSetup]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_bonusOperationSetup]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].proc_bonusOperationSetup

GO
*/
/*
		EXEC proc_bonusOperationSetup @flag = 'scheme-list'
*/
CREATE proc [dbo].[proc_bonusOperationSetup]
	 @flag                  VARCHAR(50)		= NULL 
	 ,@schemePrizeId		INT				= NULL	 	
	 ,@bonusSchemeId		INT				= NULL 
	 ,@schemeName			VARCHAR(50)		= NULL 
	 ,@sendingCountry		VARCHAR(50)		= NULL 
	 ,@sendingAgent			VARCHAR(500)	= NULL 
	 ,@sendingBranch		VARCHAR(50)		= NULL 
	 ,@receivingCountry		VARCHAR(50)		= NULL 
	 ,@receivingAgent		VARCHAR(50)		= NULL 
	 ,@schemeStartDate		DATETIME		= NULL 
	 ,@schemeEndDate		DATETIME		= NULL 
	 ,@basis				VARCHAR(100)	= NULL 
	 ,@unit					INT				= NULL 
	 ,@points				INT				= NULL 
	 ,@user					VARCHAR(50)		= NULL			
	 ,@isActive				VARCHAR(2)		= NULL 
	 ,@giftItem				INT				= NULL 
	 ,@pageSize				VARCHAR(50)		= NULL
	 ,@pageNumber			VARCHAR(50)		= NULL
	 ,@sortBy				VARCHAR(50)		= NULL
	 ,@sortOrder			VARCHAR(50)		= NULL
	 ,@maxPointsPerTxn		INT				= NULL
	 ,@minTxnForRedeem		INT				= NULL
	
AS
/*
		flag		Purpose
		----------------------------
		i				insert 
		u				update
		d				delete
		a				selectById
		s				select prizeList
		i-scheme		insert scheme
		d-scheme		delete scheme
		u-scheme		update scheme
		a-scheme		selectById scheme
		scheme-list		list of scheme prize
*/

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
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@filterFlag        VARCHAR(MAX)
		,@id		          VARCHAR(50)
		,@modeType			VARCHAR(10)
		,@msg				VARCHAR(MAX)
		

IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 'X' FROM bonusPrizeSetup WHERE bonusSchemeId = @bonusSchemeId AND giftItem = @giftItem)
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot Insert  Duplicate  GiftItems For Same Scheme', NULL
		RETURN
	END
	BEGIN TRANSACTION
			INSERT INTO bonusPrizeSetup (
						 bonusSchemeId		
						,points				
						,giftItem				
						,createdBy			
						,createdDate	
				)
				SELECT
					 @bonusSchemeId
					,@points
					,@giftItem
					,@user
					,GETDATE()
			SET @id = SCOPE_IDENTITY()
			SET @modeType = 'insert'
			
		EXEC [dbo].proc_GetColumnToRow  'bonusPrizeSetup', 'schemePrizeId', @id, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)

		EXEC proc_applicationLogs 'i', NULL, @modeType, 'Bonus Operation Setup', @id, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Insert.', @id
			RETURN
		END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

	EXEC proc_errorHandler 0, 'Record has been Inserted successfully.', @id

END	

IF @flag = 'u'
BEGIN

	IF EXISTS (SELECT 'X' FROM bonusPrizeSetup 
		  WHERE bonusSchemeId = @bonusSchemeId AND giftItem = @giftItem AND schemePrizeId <> @schemePrizeId)
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot Update  Duplicate  GiftItems For Same Scheme', NULL
		RETURN
	END

	BEGIN TRANSACTION;
	
	    UPDATE bonusPrizeSetup SET
					 bonusSchemeId	= @bonusSchemeId	
					,points			= @points	
					,giftItem		= @giftItem		
					,modifiedBy		= @user	
					,modifiedDate	= GETDATE()
		WHERE schemePrizeId = @schemePrizeId
		SET @modeType = 'update'

		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @schemePrizeId
		
		EXEC [dbo].proc_GetColumnToRow  'bonusPrizeSetup', 'schemePrizeId', @schemePrizeId, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modeType, 'Bonus Prize Setup', @schemePrizeId, @user, @oldValue, @newValue

		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Update.', @schemePrizeId
			RETURN
		END

	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

	EXEC proc_errorHandler 0, 'Record has been Updated successfully.', @schemePrizeId
		
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRANSACTION

		DELETE FROM bonusPrizeSetup 
		WHERE schemePrizeId = @schemePrizeId
		
		SET @modeType = 'delete'
		EXEC proc_errorHandler 0, 'Record has been Deleted successfully.', @schemePrizeId
		
		EXEC [dbo].proc_GetColumnToRow  'bonusPrizeSetup', 'schemePrizeId', @schemePrizeId, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modeType, 'Bonus Prize Setup', @schemePrizeId, @user, @oldValue, @newValue

		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Delete.', @schemePrizeId
			RETURN
		END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

	EXEC proc_errorHandler 0, 'Record has been Deleted successfully.', @schemePrizeId
		
END

ELSE IF @flag = 'a'
BEGIN
	SELECT
		 bs.schemeName 
		,bp.points
		,bp.giftItem	
	FROM  bonusPrizeSetup bp WITH(NOLOCK)
		LEFT JOIN bonusOperationSetup bs WITH (NOLOCK)
		ON bp.bonusSchemeId = bs.bonusSchemeId
	WHERE bp.schemePrizeId = @schemePrizeId
END

ELSE IF @flag = 's'
BEGIN
	SELECT 1 totalRow, 1  pageNumber, 1 totalPage, 0 pageSize
	SELECT
		 sn = ROW_NUMBER() OVER (ORDER BY bp.schemePrizeId ASC)
		,bp.schemePrizeId
		,bs.schemeName 
		,bp.points
		--,bp.giftItem
		,sd.detailTitle [giftItem]	
	FROM  bonusPrizeSetup bp WITH(NOLOCK)
		INNER JOIN bonusOperationSetup bs WITH (NOLOCK)
		ON bp.bonusSchemeId = bs.bonusSchemeId
		INNER JOIN staticDataValue sd WITH (NOLOCK)
		ON  sd.valueId= bp.giftItem
	WHERE bp.bonusSchemeId = @bonusSchemeId
		ORDER BY bs.schemeName ASC
	RETURN
END

ELSE IF @flag = 'scheme-list'
BEGIN
	
	IF @sortBy IS NULL
			SET @sortBy = 'bonusSchemeId'
	IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
	SET @table = '(
					SELECT	bs.bonusSchemeId
							,bs.schemeName
							,ISNULL(cms.countryName,''ALL'') [sendingCountry]
							,ISNULL(cmr.countryName,''ALL'') [receivingCountry]
							,ISNULL(ams.agentName,''ALL'') [sendingAgent]
							,ISNULL(amr.agentName,''ALL'') [receivingAgent]
							,CONVERT(VARCHAR,bs.schemeStartDate,101) [schemeStartDate]
							,CONVERT(VARCHAR,bs.schemeEndDate,101) [schemeEndDate]
							,bs.basis
							,bs.unit
							,bs.points
					 FROM    bonusOperationSetup bs WITH(NOLOCK)
							LEFT JOIN countryMaster cms WITH(NOLOCK) ON bs.sendingCountry = cms.countryId
							LEFT JOIN countryMaster cmr WITH(NOLOCK) ON bs.receivingCountry = cmr.countryId
							LEFT JOIN agentMaster ams WITH(NOLOCK) ON bs.sendingAgent = ams.agentId
							LEFT JOIN  agentMaster amr WITH(NOLOCK) ON bs.receivingAgent = amr.agentId 
					 --WHERE  ISNULL(bs.isActive,''N'') <> ''N''
					 )x '
	SET @sql_filter = ''
		
	IF @schemeName IS NOT NULL
		SET @sql_filter = @sql_filter + 'AND x.schemeName LIKE '''+ @schemeName +'%'''	
		
	IF @sendingCountry IS NOT NULL
		SET @sql_filter = @sql_filter + 'AND x.sendingCountry LIKE '''+ @sendingCountry +'%'''	
	
		IF @receivingCountry IS NOT NULL
	SET @sql_filter = @sql_filter + 'AND x.receivingCountry LIKE '''+ @receivingCountry +'%'''	
			
	SET @select_field_list ='
				 bonusSchemeId
				,schemeName
				,sendingCountry
				,sendingAgent
				,receivingCountry
				,receivingAgent
				,schemeStartDate
				,schemeEndDate
				,basis
				,unit
				,points
			'		
		PRINT @TABLE
		EXEC dbo.proc_paging
			@table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
			
			RETURN
END
ELSE IF @flag = 'a-scheme'
BEGIN
	SELECT	 bs.schemeName
		,cms.countryName [sendingCountry]
		,bs.sendingCountry [sendingCountryVal]
		,cmr.countryName [receivingCountry]
		,bs.receivingCountry [receivingCountryVal]
		,amb.agentName	[sendingBranch]
		,bs.sendingBranch	[sendingBranchVal]
		,ams.agentName [sendingAgent]
		,bs.sendingAgent [sendingAgentVal]
		,amr.agentName [receivingAgent]
		,bs.receivingAgent [receivingAgentVal]
		,CONVERT( VARCHAR ,bs.schemeStartDate,101)schemeStartDate
		,CONVERT( VARCHAR ,bs.schemeEndDate,101)schemeEndDate 
		,bs.basis
		,bs.unit
		,bs.points
		,bs.isActive
		,bs.maxPointsPerTxn
		,bs.minTxnForRedeem
	FROM    bonusOperationSetup bs WITH(NOLOCK)
			LEFT JOIN countryMaster cms WITH(NOLOCK) ON bs.sendingCountry = cms.countryId
			LEFT JOIN countryMaster cmr  WITH(NOLOCK) ON bs.receivingCountry = cmr.countryId
			LEFT JOIN agentMaster ams WITH(NOLOCK) ON bs.sendingAgent = ams.agentId
			LEFT JOIN  agentMaster amr WITH(NOLOCK) ON bs.receivingAgent = amr.agentId
			LEFT JOIN  agentMaster amb WITH(NOLOCK)  ON bs.sendingBranch = amb.agentId 
	WHERE  --ISNULL(bs.isActive,'N') <> 'N'AND 
	bonusSchemeId = @bonusSchemeId
END
ELSE IF @flag = 'd-scheme'
BEGIN
	BEGIN TRANSACTION
		DELETE FROM bonusOperationSetup 
		WHERE bonusSchemeId = @bonusSchemeId
		
		EXEC [dbo].proc_GetColumnToRow  'bonusOperationSetup', 'bonusSchemeId', @bonusSchemeId, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'd', 'Bonus Operation Setup', @bonusSchemeId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Delete.', @bonusSchemeId
			RETURN
		END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

	EXEC proc_errorHandler 0, 'Record has been Deleted successfully.', @bonusSchemeId
END

ELSE IF @flag = 'u-scheme'
BEGIN

	IF EXISTS (SELECT 'X' FROM bonusOperationSetup WHERE schemeName = @schemeName AND bonusSchemeId <> @bonusSchemeId)
	BEGIN
		SET @msg = 'Cannot Update  Duplicate  Value ' + @schemeName
		EXEC proc_errorHandler 1, @msg, NULL
		RETURN
	END
	IF EXISTS (SELECT 'X' WHERE @sendingCountry = @receivingCountry)
	BEGIN
		EXEC proc_errorHandler 1, 'Sending And Receiving Country Cannot Be Same', NULL
		RETURN
	END

	IF EXISTS (SELECT 'X' FROM bonusOperationSetup 
	WHERE 
		  sendingCountry = @sendingCountry 
		  and receivingCountry = @receivingCountry 
		  AND @schemeStartDate BETWEEN schemeStartDate AND schemeEndDate
		  AND bonusSchemeId <> @bonusSchemeId)
	BEGIN
		EXEC proc_errorHandler 1, 'Already Exists Scheme Date', NULL
		RETURN
	END

	BEGIN TRANSACTION
		UPDATE bonusOperationSetup SET
			 schemeName		=		@schemeName 
			,sendingCountry	=		@sendingCountry 
			,sendingAgent	=		@sendingAgent 
			,sendingBranch	=		@sendingBranch 
			,receivingCountry=		@receivingCountry 
			,receivingAgent	=		@receivingAgent
			,schemeStartDate=		@schemeStartDate 
			,schemeEndDate	=		@schemeEndDate 
			,basis			=		@basis
			,unit			=		@unit 
			,points			=		@points 
			,isActive		=		@isActive
			,modifiedBy		=		@user
			,modifiedDate	=		GETDATE()
			,maxPointsPerTxn =		@maxPointsPerTxn
			,minTxnForRedeem =		@minTxnForRedeem
		WHERE bonusSchemeId = @bonusSchemeId
		
		EXEC [dbo].proc_GetColumnToRow  'bonusOperationSetup', 'bonusSchemeId', @bonusSchemeId, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'u', 'Bonus Operation Setup', @bonusSchemeId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Update.', @bonusSchemeId
			RETURN
		END

	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

	EXEC proc_errorHandler 0, 'Record has been Updated successfully.', @bonusSchemeId
END

ELSE IF @flag = 'i-scheme'
BEGIN
	IF EXISTS (SELECT 'X' FROM bonusOperationSetup WHERE schemeName = @schemeName)
	BEGIN
		SET @msg = 'Cannot Insert  Duplicate  Value ' + @schemeName
		EXEC proc_errorHandler 1, @msg, NULL
		RETURN
	END
	IF EXISTS (SELECT 'X' WHERE @sendingCountry = @receivingCountry)
	BEGIN
		EXEC proc_errorHandler 1, 'Sending And Receiving Country Cannot Be Same', NULL
		RETURN
	END
	IF EXISTS (SELECT 'X' FROM bonusOperationSetup WHERE sendingCountry = @sendingCountry 
		  and receivingCountry = @receivingCountry 
		  and @schemeStartDate BETWEEN schemeStartDate AND schemeEndDate)
	BEGIN
		EXEC proc_errorHandler 1, 'Already Exists Scheme Date', NULL
		RETURN
	END
	INSERT INTO bonusOperationSetup(
					 schemeName 
					,sendingCountry 
					,sendingAgent 
					,sendingBranch 
					,receivingCountry 
					,receivingAgent
					,schemeStartDate 
					,schemeEndDate 
					,basis
					,unit 
					,points 
					,isActive
					,createdBy
					,createdDate
					,maxPointsPerTxn
					,minTxnForRedeem
				)
		SELECT 
			@schemeName 
			,@sendingCountry 
			,@sendingAgent 
			,@sendingBranch 
			,@receivingCountry 
			,@receivingAgent
			,@schemeStartDate 
			,@schemeEndDate 
			,@basis
			,@unit 
			,@points 
			,@isActive
			,@user
			,GETDATE()
			,@maxPointsPerTxn
			,@minTxnForRedeem
			
		SET @id = SCOPE_IDENTITY()
		
		EXEC [dbo].proc_GetColumnToRow  'bonusOperationSetup', 'bonusSchemeId', @id, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'i', 'Bonus Operation Setup', @id, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Insert.', @id
			RETURN
		END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Record has been Added successfully.', @id
END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, NULL 
END CATCH



GO
