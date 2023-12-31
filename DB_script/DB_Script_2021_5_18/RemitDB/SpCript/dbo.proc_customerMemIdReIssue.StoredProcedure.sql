USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerMemIdReIssue]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_customerMemIdReIssue]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(50)		= NULL
	,@id								INT				= NULL
	,@customerId						INT				= NULL
	,@membershipId						VARCHAR(50)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

	,@name								VARCHAR(200)	= NULL
	,@hasChanged						CHAR(1)			= NULL
	,@isApproved						CHAR(1)			= NULL
	,@searchBy							VARCHAR(50)		= NULL
	,@searchValue						VARCHAR(200)	= NULL
	,@customerCardNo					VARCHAR(100)	= NULL
	,@newMemId							VARCHAR(50)		= NULL
	,@reqMsg							VARCHAR(MAX)	= NULL
            
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), membershipId INT)
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
		
	SELECT
		 @logIdentifier = 'customerId'
		,@logParamMain = 'Customer Membership Id Reissue'		
		,@module = '20'
		,@tableAlias = 'customerMemIdReIssue'
			
    IF @flag = 'approve'
	BEGIN		
		IF NOT EXISTS(SELECT 'X' FROM customerMemIdReIssue WITH(NOLOCK) WHERE id = @id AND approvedDate IS NULL AND rejectedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Request not found.', NULL
			RETURN
		END
		SELECT @newMemId = newMemId,@customerId = customerId 
			FROM customerMemIdReIssue WITH(NOLOCK) WHERE id = @id AND approvedDate IS NULL AND rejectedDate IS NULL

		IF NOT EXISTS(SELECT 'X' FROM dbo.customerMaster WITH(NOLOCK) 
			WHERE customerId = @customerId)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer not found.', @customerId
			RETURN
		END

		IF EXISTS(SELECT 'X' FROM dbo.customerMaster WITH(NOLOCK) 
			WHERE membershipId = @newMemId 
			AND ISNULL(isDeleted,'N') <> 'Y' 
			AND rejectedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Already in use new Membership ID.', @newMemId
			RETURN
		END
		BEGIN TRANSACTION
		UPDATE customerMaster SET membershipId = @newMemId WHERE customerId = @customerId
		UPDATE customerMemIdReIssue SET approvedBy = @user, approvedDate = GETDATE() WHERE id = @id

		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @customerId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, membershipId)

		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @customerId, @user, @oldValue, @newValue
		
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to approve record.', @customerId
			RETURN
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record approved successfully.', @customerId
	END
	
	IF @flag = 'reject'
	BEGIN
		BEGIN TRANSACTION
		UPDATE customerMemIdReIssue SET
			 rejectedDate  = GETDATE()
			,rejectedBy = @user
		WHERE id = @id

		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @customerId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, membershipId)

		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @customerId, @user, @oldValue, @newValue
		
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to reject record.', @customerId
			RETURN
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record rejected successfully.', @customerId
	END

	IF @flag = 'select'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'membershipId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 mr.id
					,cm.customerId
					,membershipId = mr.oldMemId
					,mr.newMemId
					,name = ISNULL(cm.firstName, '''') + ISNULL( '' '' + cm.middleName, '''')+ ISNULL( '' '' + cm.lastName, '''')
					,cm.pZone
					,cm.pDistrict
					,cm.mobile
					,mr.createdBy
					,mr.createdDate
					,haschanged = CASE WHEN (mr.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
					,mr.modifiedBy
				FROM customerMaster cm WITH(NOLOCK)
				INNER JOIN customerMemIdReIssue mr with(nolock) on cm.customerId = mr.customerId
				WHERE ISNULL(cm.isDeleted, '''') <> ''Y'' and mr.rejectedDate is null
					) x'
					
		SET @sql_filter = ''
		
		IF @searchBy = 'name' and @searchValue is not null
			SET @sql_filter = @sql_filter + ' AND name LIKE ''%' + @searchValue + '%'''
		
		IF @searchBy = 'membershipId' and @searchValue is not null
			SET @sql_filter = @sql_filter + ' AND membershipId = ''' + @searchValue + ''''
		
		IF @searchBy = 'mobile' and @searchValue is not null
			SET @sql_filter = @sql_filter + ' AND ISNULL(mobile, '''') LIKE ''%' + @searchValue + '%'''
		
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + @hasChanged + ''''

		SET @select_field_list ='			 
			 id
			,customerId
			,membershipId
			,newMemId
			,name
			,pZone
			,pDistrict
			,mobile			
			,createdBy
			,createdDate
			,hasChanged
			,modifiedBy'

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

	IF @flag = 'i'
	BEGIN		
		SELECT @customerId= customerId FROM customerMaster WITH(NOLOCK) WHERE membershipId = @membershipId 

		IF @customerId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Membership Id not valid.', @membershipId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM customerMemIdReIssue WITH(NOLOCK) 
			WHERE customerId = @customerId AND approvedDate IS NULL AND rejectedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Request already in pending.', @membershipId
			RETURN
		END

		IF (len(ltrim(rtrim(@newMemId))) <> '8')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number/Membership Id Should Be 8 Digits.', @membershipId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM dbo.customerMaster WITH(NOLOCK) 
			WHERE membershipId = @newMemId 
			AND ISNULL(isDeleted,'N') <> 'Y' 
			AND rejectedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Already in use new Membership ID.', @newMemId
			RETURN
		END


		INSERT INTO customerMemIdReIssue
		(
			customerId,
			oldMemId,
			newMemId,
			remarks,
			createdBy,
			createdDate		
		)
		SELECT 
			@customerId,
			@membershipId,
			@newMemId,
			@reqMsg,
			@user,
			GETDATE() 
		EXEC proc_errorHandler 0, 'Record has been requested successfully.', @customerId
		RETURN
	END

	IF @flag = 'u'
	BEGIN				
		IF (len(ltrim(rtrim(@newMemId))) <> '8')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number/Membership Id Should Be 8 Digits.', NULL
			RETURN
		END
		UPDATE customerMemIdReIssue SET
			newMemId = @newMemId,
			remarks = @reqMsg,
			modifiedBy = @user,
			modifiedDate = GETDATE()
		WHERE id = @id
		
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @customerId
		RETURN
	END

	IF @flag = 'i-agent'
	BEGIN		
		IF EXISTS(SELECT 'X' FROM customerMemIdReIssue WITH(NOLOCK) 
			WHERE customerId = @customerId AND approvedDate IS NULL AND createdBy <> @user and rejectedDate is null)
		BEGIN
			EXEC proc_errorHandler 1, '	Request already in pending, please contact headoffice.', NULL
			RETURN
		END
		IF (len(ltrim(rtrim(@newMemId))) <> '8')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number/Membership Id Should Be 8 Digits.', NULL
			RETURN
		END
		INSERT INTO customerMemIdReIssue
		(
			customerId,
			oldMemId,
			newMemId,
			remarks,
			createdBy,
			createdDate		
		)
		SELECT 
			@customerId,
			@membershipId,
			@newMemId,
			@reqMsg,
			@user,
			GETDATE()
		EXEC proc_errorHandler 0, 'Record has been requested successfully.', @customerId
		RETURN
	END

	IF @flag = 'u-agent'
	BEGIN				
		IF (len(ltrim(rtrim(@newMemId))) <> '8')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer Card Number/Membership Id Should Be 8 Digits.', NULL
			RETURN
		END
		UPDATE customerMemIdReIssue SET
			newMemId = @newMemId,
			remarks = @reqMsg,
			modifiedBy = @user,
			modifiedDate = GETDATE()
		WHERE id = @id
		
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @customerId
		RETURN
	END

	IF @flag = 'a'
	BEGIN
		SELECT id,customerId,oldMemId,newMemId,remarks,createdBy,createdDate
		FROM customerMemIdReIssue WITH(NOLOCK) 
			WHERE customerId = @customerId AND approvedDate IS NULL and rejectedDate is null
	END

	IF @flag = 'a1'
	BEGIN		
		SELECT id,customerId,oldMemId,newMemId,remarks,createdBy,createdDate,approvedBy, approvedDate
		FROM customerMemIdReIssue WITH(NOLOCK) 
			WHERE id = @id and rejectedDate is null
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @customerId
END CATCH



GO
