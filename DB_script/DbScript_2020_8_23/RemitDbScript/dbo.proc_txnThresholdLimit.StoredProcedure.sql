USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnThresholdLimit]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_txnThresholdLimit]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@ttlId                              VARCHAR(30)    = NULL
	,@controlNo                          VARCHAR(30)    = NULL
	,@pAgent                             INT            = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL
	,@chkE								VARCHAR(50)		= NULL
	,@chkT								VARCHAR(50)		= NULL


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
		,@remarks			VARCHAR(MAX)
	SELECT
		 @logIdentifier = 'ttlId'
		,@logParamMain = 'txnThresholdLimit'
		,@logParamMod = 'txnThresholdLimitMod'
		,@module = '20'
		,@tableAlias = ''

	IF @flag = 'i'
	BEGIN
		/*
		EXEC proc_txnThresholdLimit @flag = 'i', @user = 'admin', @ttlId = '0', @controlNo = '90801761047', @pAgent = '4616', @chkE = 'True', @chkT = 'False'

		*/
		IF @chkE ='True' AND @chkT = 'True'
			SET @remarks  ='More than 30 days old txn & Payout limit exceeded.'
		IF @chkE ='True' AND @chkT ='False'
			SET @remarks  ='More than 30 days old txn.'
		IF @chkE ='False' AND @chkT = 'True'
			SET @remarks  ='Payout limit exceeded.'

		BEGIN TRANSACTION	
		--alter table txnThresholdLimit add	remarks varchar(max)	
			INSERT INTO txnThresholdLimit (
				 controlNo
				,pAgent
				,createdBy
				,createdDate
				,remarks
			)
			SELECT
				 dbo.FNAEncryptString(@controlNo)
				,@pAgent
				,@user
				,GETDATE()
				,@remarks 
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @ttlId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @ttlId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @ttlId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @ttlId
	END

	IF @flag = 'a'
	BEGIN
		SELECT * FROM txnThresholdLimit WITH(NOLOCK) WHERE ttlId = @ttlId
	END

	IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE txnThresholdLimit SET
				 controlNo = @controlNo
				,pAgent = @pAgent
			WHERE ttlId = @ttlId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @ttlId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @ttlId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @ttlId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @ttlId
	END

	IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE txnThresholdLimit SET
				isDeleted = 'Y'
			WHERE ttlId = @ttlId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @ttlId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @ttlId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @ttlId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @ttlId
	END

	IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'ttlId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.ttlId
					,controlNo = ''<a href = "Manage.aspx?controlNo='' + dbo.FNADecryptString(main.controlNo) + ''">'' + dbo.FNADecryptString(main.controlNo) + ''</a>''
					,main.pAgent
					,pAgentName = am.agentName
					,main.createdBy
					,main.createdDate
					,modifiedBy = main.createdBy
					,modifiedDate = main.createdDate
					,haschanged = CASE WHEN main.approvedBy IS NULL THEN ''Y'' ELSE ''N'' END
					,main.isDeleted
					,main.remarks
				FROM txnThresholdLimit main WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.pAgent = am.agentId
					WHERE main.approvedBy IS NULL 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 ttlId
			,controlNo
			,pAgent
			,pAgentName
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
			,haschanged
			,isDeleted
			,remarks '
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
	
	IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM txnThresholdLimit WITH(NOLOCK) WHERE ttlId = @ttlId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'Illegal Operation! You are not allowed to approve this record', @ttlId
			RETURN
		END
		UPDATE txnThresholdLimit SET
			 isActive		= 'Y'
			,approvedBy		= @user
			,approvedDate	= GETDATE()
		WHERE ttlId = @ttlId
		
		EXEC proc_errorHandler 0, 'Changes Approved Successfully', @ttlId
	END
	
	IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM txnThresholdLimit WITH(NOLOCK) WHERE ttlId = @ttlId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'Illegal Operation! You are not allowed to reject this record', @ttlId
			RETURN
		END		
		DELETE FROM txnThresholdLimit WHERE ttlId = @ttlId		
		EXEC proc_errorHandler 0, 'Changes Rejected Successfully', @ttlId
	END

	IF @flag = 'check-type'
	BEGIN
		DECLARE @days INT,@pAmt MONEY
		SELECT @days = DATEDIFF(DAY,createdDateLocal,GETDATE()),
			   @pAmt = pAmt
		FROM remitTran rt WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo) 

		IF @days > 30 AND @pAmt > = 300000
			SELECT '1' chkE,'1' chkT 
		ELSE IF @days > 30 AND @pAmt < 300000
			SELECT '1' chkE,'0' chkT 
		ELSE IF @days <= 30 AND @pAmt > = 300000
			SELECT '0' chkE,'1' chkT 
		ELSE 
			SELECT '0' chkE,'0' chkT 
	END
	 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @ttlId
END CATCH



GO
