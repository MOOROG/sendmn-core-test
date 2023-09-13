USE [FastMoneyPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_CASHANDVAULT]    Script Date: 3/29/2019 9:14:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <2019/25/3,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[PROC_CASHANDVAULT] 
	  @flag				 VARCHAR(50)	=	NULL 
	 ,@user				 VARCHAR(30)	=	NULL 
	 ,@agentId			 INT			=	NULL
	 ,@cashHoldLimit	 MONEY			=	NULL 
	 ,@ruleType			 CHAR(1)		=	NULL
	 ,@sortBy		   	 VARCHAR(50)	=	NULL
	 ,@sortOrder		 VARCHAR(5)		=	NULL
	 ,@pageSize			 INT			=	NULL
	 ,@pageNumber		 INT			=	NULL  
	 ,@flag1			 VARCHAR(5)		=	NULL
	 ,@cashHoldLimitId	 INT			=	NULL 
	 ,@activeStatus		 BIT			=	NULL  
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

	IF @flag = 'i'
	BEGIN
		DECLARE @totalLimitOfUsers MONEY,@ruleId INT

		SELECT @totalLimitOfUsers=SUM(cashHoldLimit) FROM dbo.CASH_HOLD_LIMIT_USER_WISE WITH(NOLOCK) WHERE agentId = @agentId AND approvedBy IS NOT NULL
		IF @cashHoldLimit < @totalLimitOfUsers 
		BEGIN
			EXEC proc_errorHandler 1, 'Cash Hold Limit of branch cannot be smaller than Cash Hold Limit of users.', NULL
			RETURN
		END

		SELECT @ruleId=cashHoldLimitId FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE agentId = @agentId
		IF @ruleId IS NOT NULL OR @ruleId != ''
		BEGIN
			UPDATE dbo.CASH_HOLD_LIMIT_BRANCH_WISE
				SET agentId = @agentId
					,cashHoldLimit = @cashHoldLimit
					,ruleType = @ruleType
					,modifiedBy = @user
					,modifiedDate = GETDATE()
				WHERE cashHoldLimitId = @ruleId
			EXEC proc_errorHandler 0, 'Cash and Vault updated successfully.', NULL
			RETURN
		END
		ELSE
		BEGIN
			--BEGIN insert
			IF EXISTS (SELECT 1 FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE (NOLOCK) WHERE agentId = @agentId AND approvedBy IS NULL)
			BEGIN
				EXEC proc_errorHandler 1, 'Your setup for same agent is waiting for approval.', NULL
				RETURN
			END
			IF EXISTS (SELECT 1 FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE (NOLOCK) WHERE agentId = @agentId)
			BEGIN
				EXEC proc_errorHandler 1, 'Your setup for same agent is already done.', NULL
				RETURN
			END

			INSERT INTO CASH_HOLD_LIMIT_BRANCH_WISE(agentId, cashHoldLimit, ruleType, isActive, createdBy, createdDate)
			VALUES(@agentId,@cashHoldLimit,@ruleType,0,@user,GETDATE())

			EXEC proc_errorHandler 0, 'Cash and Vault saved successfully.', NULL
			RETURN
		END 
				
	END 
	ELSE IF @flag = 'u'
	BEGIN
	
		SELECT @totalLimitOfUsers=SUM(cashHoldLimit) FROM dbo.CASH_HOLD_LIMIT_USER_WISE WITH(NOLOCK) WHERE agentId = @agentId AND approvedBy IS NOT NULL
		IF @cashHoldLimit < @totalLimitOfUsers 
		BEGIN
			EXEC proc_errorHandler 1, 'Cash Hold Limit of branch cannot be smaller than Cash Hold Limit of users.', NULL
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', NULL
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', NULL
			RETURN
		END 

		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM CASH_HOLD_LIMIT_BRANCH_WISE WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN
				UPDATE dbo.CASH_HOLD_LIMIT_BRANCH_WISE
				SET agentId = @agentId
					,cashHoldLimit = @cashHoldLimit
					,ruleType = @ruleType
					,modifiedBy = @user
					,modifiedDate = GETDATE()
				WHERE cashHoldLimitId = @cashHoldLimitId
			END
			ELSE
			BEGIN
			    DELETE FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD WHERE cashHoldLimitId = @cashHoldLimitId

				INSERT INTO CASH_HOLD_LIMIT_BRANCH_WISE_MOD(agentId, cashHoldLimitId, cashHoldLimit, ruleType, isActive, createdBy, createdDate, modType)
				VALUES(@agentId, @cashHoldLimitId, @cashHoldLimit,@ruleType,0,@user,GETDATE(), 'U')
			END
		COMMIT TRANSACTION     

		EXEC proc_errorHandler 0, 'Changes updated successfully.', @user
		RETURN
	END 
	ELSE IF @flag = 's'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
						SELECT agentName
						,AM.agentId
						,ISNULL(CHL.cashHoldLimit, 0) cashHoldLimit
						,CHL.cashHoldLimitId
						,IS_ACTIVE = CASE WHEN CHL.isActive = 0 THEN 
						''In-ACTIVE | <a class="btn btn-xs btn-success" title="Active" href="javascript:void(0);" onclick="ActiveInActive(''''''+CAST(ISNULL(CHL.cashHoldLimitId, 0) AS VARCHAR)+'''''',1)"><i class="fa fa-check"></i></a>''
						 WHEN CHL.isActive IS NULL THEN 
						 ''Un-Assigned'' 
						 ELSE 
						 ''ACTIVE | <a class="btn btn-xs btn-danger" title="In-Active" href="javascript:void(0);" onclick="ActiveInActive(''''''+CAST(ISNULL(CHL.cashHoldLimitId, 0) AS VARCHAR)+'''''',0)"><i class="fa fa-times"></i></a>''
						 END

						,RULE_TYPE = CASE WHEN CHL.ruleType = ''B'' THEN ''Block'' WHEN CHL.ruleType IS NULL THEN ''-'' ELSE ''Hold'' END
						,HAS_USER_LIMIT = CASE WHEN CHL.hasUserLimit = 0 THEN ''NO'' ELSE ''Yes'' END
						,hasChanged = CASE WHEN (CHL.approvedBy IS NULL AND CHL.cashHoldLimitId IS NOT NULL)
											OR	(aum.cashHoldLimitId IS NOT NULL) 
									  THEN ''Y'' ELSE ''N'' END
						,modifiedBy = CASE WHEN CHL.approvedBy IS NULL THEN CHL.createdBy ELSE aum.createdBy END
			FROM dbo.agentMaster AM (NOLOCK) 
			LEFT JOIN CASH_HOLD_LIMIT_BRANCH_WISE CHL (NOLOCK) ON  AM.agentId = CHL.agentId
			LEFT JOIN CASH_HOLD_LIMIT_BRANCH_WISE_MOD aum (NOLOCK)  ON CHL.cashHoldLimitId = aum.cashHoldLimitId 
			WHERE AM.PARENTID = 393877
			--AND (
			--		aum.createdBy = ''' +  @user + ''' 
			--	)
		)x'
		PRINT @table
		SET @sql_filter = ''
		SET @select_field_list ='agentId,agentName,IS_ACTIVE,RULE_TYPE,HAS_USER_LIMIT,cashHoldLimit,cashHoldLimitId,hasChanged,modifiedBy'
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
	ELSE IF @flag = 'CashAndVault-Details'
	BEGIN
		SELECT  am.agentId
				,cashHoldLimit
				,cashHoldLimitId
				,ruleType
				,isJMEBranch = CASE WHEN ISNULL(AM.actAsBranch, 'Y') = 'Y' THEN 'Y' ELSE 'N' END
		FROM dbo.agentMaster AM (NOLOCK)
		LEFT JOIN CASH_HOLD_LIMIT_BRANCH_WISE CHL (NOLOCK) ON  AM.agentId = CHL.agentId
		WHERE AM.AGENTID = @agentId
	END 
	ELSE IF @flag = 'approve'
	BEGIN
		DECLARE @cashHoldLimitofBranch MONEY
		SELECT @cashHoldLimitofBranch=cashHoldLimit FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE cashHoldLimitId = @cashHoldLimitId
		SELECT @totalLimitOfUsers=SUM(cashHoldLimit) FROM dbo.CASH_HOLD_LIMIT_USER_WISE WITH(NOLOCK) WHERE cashHoldLimitBranchId = @cashHoldLimitId AND approvedBy IS NOT NULL
	
		IF @cashHoldLimitofBranch  < @totalLimitOfUsers 
		BEGIN
			EXEC proc_errorHandler 1, 'Cash Hold Limit of branch cannot be smaller than Cash Hold Limit of users.', NULL
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM CASH_HOLD_LIMIT_BRANCH_WISE (NOLOCK)  WHERE approvedBy IS NULL AND cashHoldLimitId = @cashHoldLimitId)
			SET @modType = 'I'
		ELSE
			SELECT @modType = modType FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD (NOLOCK)  WHERE cashHoldLimitId = @cashHoldLimitId

		IF @modType = 'I'
		BEGIN
		    UPDATE dbo.CASH_HOLD_LIMIT_BRANCH_WISE 
			SET approvedBy = @user,
				approvedDate = GETDATE(),
				isActive = 1
			WHERE cashHoldLimitId=@cashHoldLimitId
		END
		ELSE IF @modType = 'U'
		BEGIN
			--INSERT INTO BRANCH_WISE_HISTORY TABLE\
			INSERT INTO CASH_HOLD_LIMIT_BRANCH_WISE_HISTORY
			 (cashHoldLimitId,agentId,cashHoldLimit,ruleType,isActive,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate)
			SELECT	cashHoldLimitId,agentId,cashHoldLimit,ruleType,isActive,createdBy,GETDATE(),modifiedBy, GETDATE(), approvedBy,approvedDate
			FROM CASH_HOLD_LIMIT_BRANCH_WISE (NOLOCK) 
			WHERE cashHoldLimitId = @cashHoldLimitId

		    UPDATE MAIN SET MAIN.agentId = MODE.agentId
							,MAIN.cashHoldLimit = MODE.cashHoldLimit
							,MAIN.ruleType = MODE.ruleType
			FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE MAIN(NOLOCK)
			INNER JOIN dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD MODE(NOLOCK) ON MODE.cashHoldLimitId = MAIN.cashHoldLimitId
			WHERE MAIN.cashHoldLimitId = @cashHoldLimitId
			
			DELETE FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD WHERE cashHoldLimitId = @cashHoldLimitId
		END

		EXEC proc_errorHandler 0, 'Changes approved successfully.', @user
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
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE WITH(NOLOCK) WHERE cashHoldLimitId = @cashHoldLimitId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', NULL
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM CASH_HOLD_LIMIT_BRANCH_WISE WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL)
		BEGIN
		    DELETE FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE cashHoldLimitId = @cashHoldLimitId
		END
		ELSE 
		BEGIN
		    DELETE FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE_MOD WHERE cashHoldLimitId = @cashHoldLimitId
		END

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', NULL
	END


	
END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 

	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH
