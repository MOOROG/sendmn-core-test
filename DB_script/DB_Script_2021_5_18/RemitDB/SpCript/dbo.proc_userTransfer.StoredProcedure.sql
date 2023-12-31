USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userTransfer]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_userTransfer]
	 @flag							VARCHAR(20) = NULL
	,@user							VARCHAR(30)	= NULL
	,@fromCountry					VARCHAR(30)	= NULL
	,@fromAgent						VARCHAR(50) = NULL
	,@fromBranch					VARCHAR(20)	= NULL
	,@fromUser						VARCHAR(50)	= NULL
	,@toCountry						VARCHAR(20)	= NULL
    ,@toAgent						VARCHAR(20) = NULL
    ,@toBranch						VARCHAR(20) = NULL
	,@userName						VARCHAR(50) = NULL
	,@newBranchId					INT			= NULL
	,@newBranchCode					VARCHAR(200)= NULL
	,@branchId						INT			= NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
DECLARE
	 @sql					VARCHAR(MAX)
	,@oldValue				VARCHAR(MAX)
	,@newValue				VARCHAR(MAX)

	IF @flag = 'tBranch'					   
	BEGIN
		SELECT
			agentId,
			agentName = agentCode+'|'+agentName 
		FROM agentMaster am WITH(NOLOCK)
		WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
		AND isActive = 'Y'
		AND am.parentId = @fromAgent
		AND am.agentId <> @fromBranch
		ORDER BY agentName ASC
		RETURN	
	END

	IF @flag = 'u'
	BEGIN		
			if @fromBranch = @toBranch
			begin
				SELECT 1 error_code, 'Branch should be different.' mes, @fromUser id 
				return;
			end

			SELECT 
				 @oldValue = 'Branch = ' + am.agentName
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN applicationUsers au WITH(NOLOCK) ON am.agentId = au.agentId AND au.userName = @fromUser
	
			SELECT 
				@newValue = 'Branch = ' + am.agentName
			FROM agentMaster am WITH(NOLOCK)
			WHERE am.agentId = @toBranch	

			BEGIN TRANSACTION
		
			UPDATE applicationUsers SET 
				 newBranchId = @toBranch
				,branchTransferRequested = 'Y'
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE userName = @fromUser
		
		
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, 'update', 'Branch Transfer', @fromUser, @user, @oldValue, @newValue	
	
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	
			EXEC proc_errorHandler 0, 'User Transfer Requested Successfully.', @fromUser		
			RETURN

		
	END

	IF @flag='currentBranch'
	BEGIN
		SELECT am.agentId, am.agentName, au.agentCode FROM agentMaster am WITH(NOLOCK)
		INNER JOIN applicationUsers au WITH(NOLOCK) ON am.agentId = au.agentId
		WHERE au.userName = @userName
	END

	IF @flag ='accept'
	BEGIN
		BEGIN TRANSACTION
		UPDATE applicationUsers SET 
			  agentId		= @newBranchId
			 ,newBranchId	= NULL
			 ,agentCode		= @newBranchCode
		WHERE userName = @user
	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'update', 'Branch Transfer', @fromUser, @user, 'User Transfer accepted', @newBranchId		

		EXEC proc_errorHandler 0, 'Branch transfer request accepted successfully.', @user	
		RETURN
	END

	IF @flag ='reject'
	BEGIN
			BEGIN TRANSACTION
			UPDATE applicationUsers SET 
				 newBranchId = NULL
				 WHERE userName = @user
	
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, 'update', 'Branch Transfer', @fromUser, @user, 'User Transfer rejected', @newBranchId
			EXEC proc_errorHandler 0, 'branch transfer request rejected successfully.', @user	
			RETURN
	END

	IF @flag = 't-branch'
	BEGIN
				
		SELECT au.modifiedBy, au.modifiedDate, am.agentName, am.agentCode FROM applicationUsers au WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = au.newBranchId 
		 WHERE newBranchId = @newBranchId AND userName = @userName 
		 	
		RETURN
	END

	IF @flag = 'a'
	BEGIN
		SELECT 
			fCountryId = au.countryId,
			fCountryName = cm.countryName,
			fBranchId = au.agentId,
			fBranchName = bm.agentName,
			fAgentId = bm.parentId,
			fAgentName = am.agentName
		FROM applicationUsers au WITH(NOLOCK)
		INNER JOIN countryMaster cm WITH(NOLOCK) ON au.countryId = cm.countryId
		INNER JOIN agentMaster bm WITH(NOLOCK) ON au.agentId = bm.agentId
		INNER JOIN agentMaster am WITH(NOLOCK) ON bm.parentId = am.agentId
		WHERE userName = @userName
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH





GO
