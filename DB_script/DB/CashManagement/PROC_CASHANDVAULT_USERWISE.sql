SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <03/27/2019,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE PROC_CASHANDVAULT_USERWISE 
	  @flag							VARCHAR(50)		=	NULL 
	 ,@user							VARCHAR(30)		=	NULL 
	 ,@agentId						INT				=	NULL
	 ,@cashHoldLimit				MONEY			=	NULL 
	 ,@ruleType						CHAR(1)			=	NULL
	 ,@sortBy		   				VARCHAR(50)		=	NULL
	 ,@sortOrder					VARCHAR(5)		=	NULL
	 ,@pageSize						INT				=	NULL
	 ,@pageNumber					INT				=	NULL  
	 ,@flag1						VARCHAR(5)		=	NULL
	 ,@cashHoldLimitId			    INT			    =	NULL 
	 ,@cashHoldLimitBranchId		INT				=	NULL		
	 ,@userId						INT				=	NULL		
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
		DECLARE   @errorMessage VARCHAR(MAX)
			,@sql    VARCHAR(MAX)  
			,@table    VARCHAR(MAX)  
			,@select_field_list VARCHAR(MAX)  
			,@extra_field_list VARCHAR(MAX)  
			,@sql_filter  VARCHAR(MAX) 
			,@modType	CHAR(1)
			,@totalCashHoldLimitOfBranch MONEY
			,@totalCashHoldLimitOfUsers MONEY
	
	IF @flag = 'getBranchUser'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
			PRINT 1;
		SET @table = '(SELECT   UserName
				,cashHoldLimit = ISNULL(CHLU.cashHoldLimit , 0)
				,cashHoldLimitId = ISNULL(CHLU.cashHoldLimitId, 0)
				,RULE_TYPE = CASE WHEN CHLU.ruleType = ''B'' THEN ''Block'' WHEN CHLU.ruleType IS NULL THEN ''-'' ELSE ''Hold'' END
				,IS_ACTIVE = CASE WHEN CHLU.isActive = 0 THEN
				''In-ACTIVE | <a class="btn btn-xs btn-success" title="Active" href="javascript:void(0);" onclick="ActiveInActive(''''''+CAST(ISNULL(CHLU.cashHoldLimitId, 0) AS VARCHAR)+'''''',1)"><i class="fa fa-check"></i></a>''
					 WHEN CHLU.isActive IS NULL THEN
					''Not-Configured''
					ELSE 
					''ACTIVE | <a class="btn btn-xs btn-danger" title="In-Active" href="javascript:void(0);" onclick="ActiveInActive(''''''+CAST(ISNULL(CHLU.cashHoldLimitId, 0) AS VARCHAR)+'''''',0)"><i class="fa fa-times"></i></a>''
					END
				,hasChanged = CASE WHEN (CHLU.approvedBy IS NULL AND CHLU.cashHoldLimitId IS NOT NULL)
									OR	(aum.cashHoldLimitId IS NOT NULL) 
									  THEN ''Y'' ELSE ''N'' END
				,modifiedBy = CASE WHEN CHLU.approvedBy IS NULL THEN CHLU.createdBy ELSE aum.createdBy END
				,userId = AU.userId
		FROM dbo.applicationUsers AU (NOLOCK) 
		LEFT JOIN  CASH_HOLD_LIMIT_USER_WISE  CHLU (NOLOCK) ON AU.userId = CHLU.userId
		LEFT JOIN CASH_HOLD_LIMIT_USER_WISE_MOD aum (NOLOCK)  ON CHLU.cashHoldLimitId = aum.cashHoldLimitId 
		WHERE AU.agentId = '''+ CAST (@agentId AS VARCHAR) + '''
		)x'
		PRINT @table
		SET @sql_filter = ''
		SET @select_field_list ='UserName,cashHoldLimit,userId,cashHoldLimitId,IS_ACTIVE,hasChanged,modifiedBy,RULE_TYPE'
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
	ELSE IF @flag = 'UserDetails'
	BEGIN
	    SELECT AU.userName
				,cashHoldLimit = ISNULL(CH.cashHoldLimit, 0)
				,cashHoldLimitId = ISNULL(CH.cashHoldLimitId, 0)
				,CH.ruleType
		FROM dbo.applicationUsers AU(NOLOCK)
		INNER JOIN dbo.CASH_HOLD_LIMIT_BRANCH_WISE CHB(NOLOCK) ON CHB.agentId = AU.agentId
		LEFT JOIN dbo.CASH_HOLD_LIMIT_USER_WISE CH(NOLOCK) ON CH.userId = AU.userId
		WHERE CHB.cashHoldLimitId = @cashHoldLimitBranchId
		AND ISNULL(CH.cashHoldLimitId, @cashHoldLimitId) = @cashHoldLimitId
		AND AU.userId = @userid
	END

	IF @flag = 'i'
	BEGIN
	
		SELECT @totalCashHoldLimitOfBranch=cashHoldLimit FROM  dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE agentid = @agentId AND approvedBy IS NOT NULL
		SELECT @totalCashHoldLimitOfUsers=SUM(cashHoldLimit) FROM dbo.CASH_HOLD_LIMIT_USER_WISE WHERE agentId = @agentId AND approvedBy IS NOT NULL
		IF @totalCashHoldLimitOfBranch > 0
		BEGIN
			IF (ISNULL(@totalCashHoldLimitOfUsers,0) + @cashHoldLimit >@totalCashHoldLimitOfBranch)
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry total cash hold limit of users cannot exceed cash hold limit of branch', NULL
				RETURN
			END 
		END 

		IF EXISTS (SELECT 1 FROM dbo.CASH_HOLD_LIMIT_USER_WISE (NOLOCK) WHERE userId = @userId AND agentId = @agentId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Your setup for same user is waiting for approval.', NULL
			RETURN
		END
		IF EXISTS (SELECT 1 FROM dbo.CASH_HOLD_LIMIT_USER_WISE (NOLOCK) WHERE userId = @userId AND agentId = @agentId)
		BEGIN
			EXEC proc_errorHandler 1, 'Your setup for same user is already done.', NULL
			RETURN
		END

		INSERT INTO dbo.CASH_HOLD_LIMIT_USER_WISE
		        ( cashHoldLimitBranchId ,
		          agentId ,
		          userId ,
		          cashHoldLimit ,
		          ruleType ,
		          isActive ,
		          createdBy ,
		          createdDate ,
		          modifiedBy ,
		          modifiedDate ,
		          approvedBy ,
		          approvedDate
		        )
		VALUES  ( @cashHoldLimitBranchId , -- cashHoldLimitBranchId - int
		          @agentId , -- agentId - int
		          @userId , -- userId - int
		          @cashHoldLimit , -- cashHoldLimit - money
		          @ruleType , -- ruleType - char(1)
		          0 , -- isActive - bit
		          @user , -- createdBy - varchar(50)
		          GETDATE() , -- createdDate - datetime
		          NULL , -- modifiedBy - varchar(50)
		          NULL , -- modifiedDate - varchar(50)
		          NULL , -- approvedBy - varchar(50)
		          NULL  -- approvedDate - datetime
		        )

		EXEC proc_errorHandler 0, 'Cash and Vault saved successfully.', NULL
		RETURN
	END 
	ELSE IF @flag = 'u'
	BEGIN
		SELECT @totalCashHoldLimitOfBranch=cashHoldLimit FROM  dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE agentid = @agentId

		SELECT @totalCashHoldLimitOfUsers=SUM(cashHoldLimit)+ISNULL(@cashHoldLimit, 0) FROM dbo.CASH_HOLD_LIMIT_USER_WISE WHERE agentId = @agentId AND approvedBy IS NOT NULL
		AND cashHoldLimitId <> @cashHoldLimitId
		
		
		IF ISNULL(@totalCashHoldLimitOfBranch, 0) > 0
		BEGIN
			IF (ISNULL(@totalCashHoldLimitOfUsers,0) > @totalCashHoldLimitOfBranch)
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry total cash hold limit of users cannot exceed cash hold limit of branch', NULL
				RETURN
			END 
		END 

		IF EXISTS (SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', NULL
			RETURN
		END

		IF EXISTS (SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', NULL
			RETURN
		END 

		BEGIN TRANSACTION
			    DELETE FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD WHERE cashHoldLimitId = @cashHoldLimitId

				INSERT INTO CASH_HOLD_LIMIT_USER_WISE_MOD(agentId,userId,cashHoldLimitBranchId,cashHoldLimitId, cashHoldLimit, ruleType, isActive, createdBy, createdDate, modType)
				VALUES(@agentId,@userId,@cashHoldLimitBranchId, @cashHoldLimitId, @cashHoldLimit,@ruleType,0,@user,GETDATE(), 'U')
		COMMIT TRANSACTION     

		EXEC proc_errorHandler 0, 'Changes updated successfully.', @user
		RETURN
	END 

	ELSE IF @flag = 'approve'
	BEGIN
		DECLARE @selectedAgentId INT,@requestedCashHoldLimit MONEY
		SELECT @selectedAgentId = agentId,@requestedCashHoldLimit=cashHoldLimit FROM CASH_HOLD_LIMIT_USER_WISE WHERE cashHoldLimitId = @cashHoldLimitId
	
		SELECT @totalCashHoldLimitOfBranch=cashHoldLimit FROM  dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE agentid = @selectedAgentId AND approvedBy IS NOT NULL 
		SELECT @totalCashHoldLimitOfUsers=SUM(cashHoldLimit) FROM dbo.CASH_HOLD_LIMIT_USER_WISE WHERE agentId = @selectedAgentId AND approvedBy IS NOT NULL 
		AND cashHoldLimitId <> @cashHoldLimitId
		
		IF @totalCashHoldLimitOfBranch > 1
		BEGIN
			IF (ISNULL(@totalCashHoldLimitOfUsers,0) + @requestedCashHoldLimit >@totalCashHoldLimitOfBranch)
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry total cash hold limit of users cannot exceed cash hold limit of branch', NULL
				RETURN
			END 
		END 

		IF EXISTS (SELECT 'X' FROM CASH_HOLD_LIMIT_USER_WISE (NOLOCK)  WHERE approvedBy IS NULL AND cashHoldLimitId = @cashHoldLimitId)
			SET @modType = 'I'
		ELSE
			SELECT @modType = modType FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD (NOLOCK)  WHERE cashHoldLimitId = @cashHoldLimitId

		IF @modType = 'I'
		BEGIN
		    UPDATE dbo.CASH_HOLD_LIMIT_USER_WISE 
			SET approvedBy = @user,
				approvedDate = GETDATE(),
				isActive = 1
			WHERE cashHoldLimitId=@cashHoldLimitId
		END
		ELSE IF @modType = 'U'
		BEGIN
			--INSERT INTO BRANCH_WISE_HISTORY TABLE\
			INSERT INTO CASH_HOLD_LIMIT_USER_WISE_HISTORY
			 (cashHoldLimitId,userId,cashHoldLimitBranchId,agentId,cashHoldLimit,ruleType,isActive,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate)
			SELECT	cashHoldLimitId,userId,cashHoldLimitBranchId,agentId,cashHoldLimit,ruleType,isActive,createdBy,GETDATE(),modifiedBy, GETDATE(), approvedBy,approvedDate
			FROM CASH_HOLD_LIMIT_USER_WISE (NOLOCK) 
			WHERE cashHoldLimitId = @cashHoldLimitId

		    UPDATE MAIN SET MAIN.agentId = MODE.agentId
							,MAIN.cashHoldLimit = MODE.cashHoldLimit
							,MAIN.ruleType = MODE.ruleType
			FROM dbo.CASH_HOLD_LIMIT_USER_WISE MAIN(NOLOCK)
			INNER JOIN dbo.CASH_HOLD_LIMIT_USER_WISE_MOD MODE(NOLOCK) ON MODE.cashHoldLimitId = MAIN.cashHoldLimitId
			WHERE MAIN.cashHoldLimitId = @cashHoldLimitId
			
			DELETE FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD WHERE cashHoldLimitId = @cashHoldLimitId
		END

		EXEC proc_errorHandler 0, 'Changes approved successfully.', @user
	END
	IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_USER_WISE WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', NULL
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM CASH_HOLD_LIMIT_USER_WISE WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL)
		BEGIN
		    DELETE FROM dbo.CASH_HOLD_LIMIT_USER_WISE WHERE cashHoldLimitId = @cashHoldLimitId
		END
		ELSE 
		BEGIN
		    DELETE FROM dbo.CASH_HOLD_LIMIT_USER_WISE_MOD WHERE cashHoldLimitId = @cashHoldLimitId
		END

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', NULL
	END
	ELSE IF @flag = 'ddl'
	BEGIN
	    SELECT agentName, agentId 
		FROM dbo.agentMaster (NOLOCK) WHERE parentId=393877
		AND ISNULL(actAsBranch, 'N') = @flag1
	END
	ELSE IF @flag = 'getBranchUser'
	BEGIN 
		SELECT   UserName
				,ISNULL(CHLU.cashHoldLimit,'')  cashHoldLimit
				,IS_ACTIVE = CASE WHEN ISNULL(CHLU.isActive,0) = 0 THEN 'In-ACTIVE' ELSE 'Active' END
		FROM dbo.applicationUsers AU (NOLOCK) 
		LEFT JOIN  CASH_HOLD_LIMIT_USER_WISE  CHLU (NOLOCK) 
		ON AU.agentId = CHLU.agentId
		WHERE AU.agentId = @agentId
	END 
END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 

	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH


GO

