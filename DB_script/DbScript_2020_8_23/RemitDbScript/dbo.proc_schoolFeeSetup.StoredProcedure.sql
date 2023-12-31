USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_schoolFeeSetup]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC proc_schoolFeeSetup @flag='a',@rowid= '1'
*/

CREATE proc [dbo].[proc_schoolFeeSetup]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId								VARCHAR(50)		= null
	,@schoolId							VARCHAR(50)		= NULL
	,@levelId							VARCHAR(50)		= NULL
	,@feeTypeId							VARCHAR(50)		= NULL
	,@feeType							VARCHAR(50)		= NULL
	,@amt								VARCHAR(50)		= NULL
	,@remarks							VARCHAR(50)		= NULL
	
AS
/*
		flag		Purpose
		----------------------------
		i			insert
		u			update
		d			delete
		a			selectById
		s			select schoolFee
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
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
	SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'schoolFee'
		,@logParamMod = 'schoolFee'
		,@module = '40'
		,@tableAlias = 'School Fee'	
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'A' FROM schoolFee 
				WHERE schoolId=@schoolId and levelId=@levelId
				AND feeTypeId=@feeTypeId
					 AND isnull(isDeleted,'N')='N')
		BEGIN
				EXEC proc_errorHandler 1, 'Already Added!', @rowId
				RETURN;
		END
		BEGIN TRANSACTION
			INSERT INTO schoolFee (
				  schoolId
				 ,levelId
				 ,feeTypeId
				 ,feeType
				 ,amount
				 ,remarks
				 ,createdDate
				 ,createdBy
			)
			SELECT
				  @schoolId
				 ,@levelId
				 ,@feeTypeId
				 ,@feeType
				 ,@amt
				 ,@remarks
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
	
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE schoolFee SET
					  schoolId	= @schoolId
					 ,levelId	= @levelId
					 ,feeTypeId	= @feeTypeId
					 ,feeType	= @feeType
					 ,amount	= @amt
					 ,remarks	= @remarks
					 ,modifiedDate = GETDATE()
					 ,modifiedBy   = @user
			WHERE rowId = @rowId
			SET @modType = 'Update'
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
			UPDATE schoolFee SET
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
	
	ELSE IF @flag = 'a'
	BEGIN
			SELECT 
				  CASE WHEN ISNUMERIC(schoolId)= 1 THEN (SELECT name FROM schoolMaster WHERE rowId = x.schoolId) END [school]
				 ,x.levelId
				 ,x.feeTypeId
				 ,x.feeType
				 ,dbo.ShowDecimalExceptComma(x.amount) amount
				 ,x.remarks
			 FROM schoolFee x WHERE rowId = @rowId
		END
		
	ELSE IF @flag = 's'
	BEGIN
			SELECT
				  x.rowId 
				 ,z.name [school]
				 ,y.name [level]
				 ,x.feeType
				 ,x.amount
				 ,x.createdBy
				 ,createdDate=convert(varchar,x.createdDate,101)
			 FROM schoolFee x with(nolock) inner join schoolLevel y with(nolock) on x.levelId=y.rowId
			 inner join schoolMaster z with(nolock) on z.rowId=x.schoolId
			 WHERE ISNULL(x.isDeleted , '') <> 'Y' and x.schoolId=@schoolId
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
