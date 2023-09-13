-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <3/28/22019,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE PROC_VAULTTRANSFER 
		@flag			VARCHAR(30)
		,@user			VARCHAR(50)
		,@sortBy		VARCHAR(50)		=	NULL
		,@sortOrder		VARCHAR(5)		=	NULL
		,@pageSize		INT				=	NULL
		,@pageNumber	INT				=	NULL  
		,@rowId			INT				=	NULL
		,@userId		INT				=	NULL 
		,@branchId		INT				=	NULL
		,@agentId		INT				=	NULL
		,@transferAmt	MONEY			=	NULL
		,@activeStatus		 BIT		=	NULL  
		,@cashHoldLimitId	 INT		=	NULL 
		,@updateBranchOrUser	CHAR(1) =   NULL 
		,@param1		CHAR(10)			=   NULL
	
AS
SET NOCOUNT ON;
SET XACT_ABORT ON ;
BEGIN TRY
	DECLARE		@errorMessage VARCHAR(MAX)
				,@sql    VARCHAR(MAX)  
				,@table    VARCHAR(MAX)  
				,@select_field_list VARCHAR(MAX)  
				,@extra_field_list VARCHAR(MAX)  
				,@sql_filter  VARCHAR(MAX) 
				,@modType	CHAR(1)
	IF @flag = 's'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
						SELECT   AU.userId
								,BC.rowId
								,AU.username
								,BC.outAmount TransferredAmount
								,BC.tranDate TransferredDate
								,hasChanged = CASE WHEN (BC.approvedBy IS NULL)
													THEN ''Y'' ELSE ''N'' END
								,modifiedBy = CASE WHEN BC.approvedBy IS NULL THEN BC.createdBy END
								,isApproved = CASE WHEN (BC.approvedBy IS NULL) THEN ''Pending'' ELSE ''Approved'' END
								,mode = CASE WHEN MODE = ''B'' THEN ''Bank'' ELSE ''CASH'' END
								,toAcc = A.ACCT_NAME
						FROM dbo.BRANCH_CASH_IN_OUT BC (NOLOCK)
						INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = BC.userId
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER A(NOLOCK) ON A.ACCT_NUM = BC.TOACC
						WHERE HEAD = ''Transfer To Vault''
						AND branchId = '''+CAST(@branchId AS VARCHAR)+'''
		)x '
		PRINT @table
		SET @sql_filter = ''
		
		SET @select_field_list ='userId,username,toAcc,mode,TransferredAmount,TransferredDate,rowId,isApproved,hasChanged,modifiedBy'
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
	IF @flag = 's-from-vault'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
						SELECT BC.rowId
								,BC.outAmount TransferredAmount
								,BC.tranDate TransferredDate
								,hasChanged = CASE WHEN (BC.approvedBy IS NULL)
													THEN ''Y'' ELSE ''N'' END
								,modifiedBy = CASE WHEN BC.approvedBy IS NULL THEN BC.createdBy END
								,isApproved = CASE WHEN (BC.approvedBy IS NULL) THEN ''Pending'' ELSE ''Approved'' END
								,mode = CASE WHEN MODE = ''B'' THEN ''Bank'' ELSE ''CASH'' END
								,toAcc = A.ACCT_NAME
								,fromAcc = AC.ACCT_NAME
								,BC.createdDate
						FROM dbo.BRANCH_CASH_IN_OUT BC (NOLOCK)
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER A(NOLOCK) ON A.ACCT_NUM = BC.TOACC
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AC.ACCT_NUM = BC.FROMACC
						WHERE HEAD = ''Transfer From Vault''
						AND BC.MODE = ''CV''
						AND AC.ACCT_RPT_CODE = ''BVA''
						AND A.AGENT_ID = '''+CAST(@branchId AS VARCHAR)+'''
		)x '
		PRINT @table
		SET @sql_filter = ''
		
		SET @select_field_list ='fromAcc,mode,toAcc,TransferredAmount,TransferredDate,rowId,isApproved,hasChanged,modifiedBy'
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
	IF @flag = 'sRequestedVaultTransfer'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
						SELECT  AU.userId
								,BC.rowId
								,AU.username
								,BC.outAmount TransferredAmount
								,BC.tranDate TransferredDate
								,hasChanged = CASE WHEN (BC.approvedBy IS NULL)
													THEN ''Y'' ELSE ''N'' END
								,modifiedBy = CASE WHEN BC.approvedBy IS NULL THEN BC.createdBy END
								,isApproved = CASE WHEN (BC.approvedBy IS NULL) THEN ''Pending'' ELSE ''Approved'' END
								,mode = CASE WHEN MODE = ''B'' THEN ''Bank'' ELSE ''CASH'' END
								,toAcc = A.ACCT_NAME
						FROM dbo.BRANCH_CASH_IN_OUT BC (NOLOCK)
						INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = BC.userId
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER A(NOLOCK) ON A.ACCT_NUM = BC.TOACC
						WHERE HEAD = ''Transfer To Vault''
						AND AU.USERNAME = '''+@user+'''
		)x '
		PRINT @table
		SET @sql_filter = ''
		 
		SET @select_field_list ='userId,username,mode,toAcc,TransferredAmount,TransferredDate,rowId,isApproved,hasChanged,modifiedBy'
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
	IF @flag = 'sRequestedVaultT'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
						SELECT  BC.rowId
								,BC.outAmount TransferredAmount
								,BC.tranDate TransferredDate
								,hasChanged = CASE WHEN (BC.approvedBy IS NULL)
													THEN ''Y'' ELSE ''N'' END
								,modifiedBy = CASE WHEN BC.approvedBy IS NULL THEN BC.createdBy END
								,isApproved = CASE WHEN (BC.approvedBy IS NULL) THEN ''Pending'' ELSE ''Approved'' END
								,mode = CASE WHEN MODE = ''B'' THEN ''Bank'' ELSE ''CASH'' END
								,toAcc = A.ACCT_NAME
								,fromAcc = AC.ACCT_NAME
								,BC.createdDate
						FROM dbo.BRANCH_CASH_IN_OUT BC (NOLOCK)
						--INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = BC.userId
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER A(NOLOCK) ON A.ACCT_NUM = BC.TOACC
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AC.ACCT_NUM = BC.FROMACC
						WHERE HEAD = ''Transfer From Vault''
						AND BC.USERID = ''0''
						AND BC.branchId = '''+cast(@branchId as varchar)+'''
		)x '
		PRINT @table
		SET @sql_filter = ''
		 
		SET @select_field_list ='fromAcc,mode,toAcc,TransferredAmount,TransferredDate,rowId,isApproved,hasChanged,modifiedBy'
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
	ELSE IF @flag = 'approve'
	BEGIN
		UPDATE dbo.BRANCH_CASH_IN_OUT 
		SET approvedBy = @user,
			approvedDate = GETDATE()
		WHERE rowId=@rowId
		
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @user
		
		DECLARE @BRANCH_ID INT,@USER_ID INT,@AMOUNT MONEY,@transferMode char(2),@accNUmber BIGINT,@destinationBranchId INT
		SELECT @BRANCH_ID = BRANCHID, @USER_ID = USERID, @AMOUNT = OUTAMOUNT,@transferMode=mode,@accNUmber = toAcc
		FROM BRANCH_CASH_IN_OUT (NOLOCK)
		WHERE ROWID = @rowId

		IF @transferMode = 'cv'
		BEGIN
			SELECT @destinationBranchId = agent_id FROM FastMoneyPro_Account.DBO.ac_master WHERE acct_num = @accNUmber
			--UPDATE BALANCE
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG = 'TRANSFER_TO_OTHER_BRANCH_VAULT',@S_AGENT = @BRANCH_ID,@S_USER = @destinationBranchId,@C_AMT=@AMOUNT
		END
		ELSE
		BEGIN
			--UPDATE balance
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='TRANSFER_TO_VAULT_APPROVE',@S_AGENT = @BRANCH_ID,@S_USER = @USER_ID,@REFERRAL_CODE = '',@C_AMT = @AMOUNT ,@ONBEHALF =''
		END
		
		EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_VAULT_TRANSFER_ACC @USER = @user, @ROW_ID = @rowId
	END
	ELSE IF @flag = 'reject'
	BEGIN
		INSERT INTO BRANCH_CASH_IN_OUT_REJECT(inAmount ,outAmount ,branchId ,userId ,referenceId ,tranDate ,head ,remarks 
				,createdBy ,createdDate ,approvedBy ,approvedDate, mode, fromAcc, toAcc)
		SELECT inAmount ,outAmount ,branchId ,userId ,referenceId ,tranDate ,head ,remarks 
				,createdBy ,createdDate ,approvedBy ,approvedDate, mode, fromAcc, toAcc
		FROM BRANCH_CASH_IN_OUT (NOLOCK)
		WHERE rowId=@rowId

		DELETE FROM BRANCH_CASH_IN_OUT WHERE rowId=@rowId 

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @user
	END
	ELSE IF @flag = 'getUserIdAndBranchId'
	BEGIN
		IF @transferAmt = 0
		BEGIN
			SELECT 1 errorCode, 'Transfer amount can''t be 0' msg
			RETURN
		END
		IF EXISTS(SELECT 1 
				FROM BRANCH_CASH_IN_OUT B(NOLOCK) 
				INNER JOIN APPLICATIONUSERS A(NOLOCK) ON A.USERID = B.USERID
				WHERE A.USERNAME = @USER
				AND B.APPROVEDDATE IS NULL)
		BEGIN
			SELECT 1 errorCode, 'Previous request is pending, you can''t make a new request!' msg
			RETURN
		END	
		DECLARE @cashAtCounter VARCHAR(30)

		IF @PARAM1 = 'COUNTER'
		BEGIN
			select @userId = userId from applicationUsers where userName = @user
			SELECT @cashAtCounter = availableCash 
			FROM DBO.FNAGetBranchCashLimitDetails(@userId,'U')
		END
		ELSE
		BEGIN
			SELECT @agentId = AGENTID FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @user
			SELECT  @cashAtCounter = availableCash 
			FROM DBO.FNAGetBranchCashLimitDetails(@agentId,'B')
		END
		IF(@cashAtCounter < @transferAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Transfer amount can''t be greater than cash at counter', @user
		END 
		SELECT 0 errorCode, 'Success!' msg
				, agentId, userId 
		FROM applicationUsers 
		WHERE username = @user
	END 
	ELSE IF @flag = 'getUserIdAndBranchId-list'
	BEGIN
		SELECT 0 errorCode, 'Success!' msg
				, agentId, userId 
		FROM applicationUsers 
		WHERE username = @user
	END 
	ELSE IF @flag = 'limit-detail'
	BEGIN
		select @userId = userId from applicationUsers where userName = @user
		SELECT totalLimit, availableLimit, availableCash [cashAtCounterUser]
		FROM DBO.FNAGetBranchCashLimitDetails(@userId,'U')
	END
	ELSE IF @flag = 'limit-detail-a'
	BEGIN
		--SELECT  cashAtBranch = DBO.FNAGetVaultAvailableBalance(@agentId)
		SELECT cashAtBranch = availableCash  FROM DBO.FNAGetBranchCashLimitDetails(@agentId,'B')
	END
	ELSE IF @flag='InsertBranchRuleId'
	BEGIN 
		DECLARE @CashHoldLimitIdOfBranch INT
		SELECT @CashHoldLimitIdOfBranch=cashHoldLimitId FROM dbo.CASH_HOLD_LIMIT_BRANCH_WISE WHERE agentId=@agentId 
		IF @CashHoldLimitIdOfBranch IS NOT NULL OR  @CashHoldLimitIdOfBranch != ''
		BEGIN
			EXEC proc_errorHandler 0, 'BranchRuleId already exist.', @CashHoldLimitIdOfBranch
			RETURN
		END
		ELSE
			BEGIN
				INSERT INTO dbo.CASH_HOLD_LIMIT_BRANCH_WISE
				    ( agentId ,
				      cashHoldLimit ,
				      ruleType ,
				      hasUserLimit ,
				      isActive ,
				      createdBy ,
				      createdDate ,
				      modifiedBy ,
				      modifiedDate ,
				      approvedBy ,
				      approvedDate 
				    )
			VALUES  ( @agentId , -- agentId - int
			          '0' , -- cashHoldLimit - money
			          'B' , -- ruleType - char(1)
			          0 , -- hasUserLimit - bit
			          0 , -- isActive - bit
			          @USER , -- createdBy - varchar(50)
			          GETDATE() , -- createdDate - datetime
			          NULL , -- modifiedBy - varchar(50)
			          NULL , -- modifiedDate - varchar(50)
			          NULL , -- approvedBy - varchar(50)
			          NULL  -- approvedDate - datetime
			        )
	
			SELECT @CashHoldLimitIdOfBranch=cashHoldLimitId FROM CASH_HOLD_LIMIT_BRANCH_WISE
			EXEC proc_errorHandler 0, 'BranchRuleId inserted successfully.', @CashHoldLimitIdOfBranch
			RETURN
		END 
	END 
	ELSE IF @flag = 'updateActiveStatus'
	BEGIN
		IF @updateBranchOrUser = 'B'
		BEGIN
			IF EXISTS(SELECT 1 FROM CASH_HOLD_LIMIT_BRANCH_WISE WHERE cashHoldLimitId = @CashHoldLimitId AND approvedBy IS NULL AND approvedDate IS NULL )
			BEGIN
				EXEC proc_errorHandler 1, 'You cannot change active status because this branch has not been approved yet', @CashHoldLimitId
				RETURN
			END 
			UPDATE dbo.CASH_HOLD_LIMIT_BRANCH_WISE SET isActive = @activeStatus WHERE cashHoldLimitId = @cashHoldLimitId
			EXEC proc_errorHandler 0, 'Active status of branch updated successfully.', NULL
		END
		ELSE IF @updateBranchOrUser = 'U'
		BEGIN
			IF EXISTS(SELECT 1 FROM CASH_HOLD_LIMIT_USER_WISE WHERE cashHoldLimitId = @cashHoldLimitId AND approvedBy IS NULL AND approvedDate IS NULL )
			BEGIN
				EXEC proc_errorHandler 1, 'You cannot change active status because this user has not been approved yet', @CashHoldLimitId
				RETURN
			END 
			UPDATE dbo.CASH_HOLD_LIMIT_USER_WISE SET isActive = @activeStatus WHERE cashHoldLimitId = @cashHoldLimitId
			EXEC proc_errorHandler 0, 'Active status of user updated successfully.', NULL
		END
	END
	ELSE IF @flag = 'bankOrBranch'
	BEGIN
		IF @param1 = 'c'
		BEGIN
			SELECT bankId = AGENTID, bankName = AGENTNAME
			FROM AGENTMASTER (NOLOCK) 
			WHERE PARENTID=393877
			AND ISNULL(ISACTIVE, 'Y') = 'Y'
			AND AGENTID = 394392

			RETURN;
		END	
		ELSE 
		BEGIN
			SELECT bankId = VALUEID, bankName = DETAILTITLE
			FROM STATICDATAVALUE (NOLOCK)
			WHERE TYPEID = '7010'
			RETURN;
		END
	END
	ELSE IF @flag = 'VAULT-ADMIN'
	BEGIN
		IF @param1 = 'ct'
		BEGIN
			SELECT ACCT_NUM, ACCT_NAME
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AM(NOLOCK) 
			INNER JOIN APPLICATIONUSERS AU(NOLOCK) ON AU.USERID = AM.AGENT_ID
			INNER JOIN APPLICATIONUSERS AU1(NOLOCK) ON AU1.AGENTID = AU.AGENTID
			WHERE AU1.USERNAME = @USER
			RETURN;
		END	
		ELSE IF @param1 = 'cv'
		BEGIN
			SELECT ACCT_NUM, ACCT_NAME
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK) 
			WHERE acct_rpt_code = 'BVA'
			AND AGENT_ID <> @AGENTID
			RETURN;
		END	
		ELSE 
		BEGIN
			SELECT ACCT_NUM, ACCT_NAME
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK) 
			WHERE acct_rpt_code = 'TB'
			RETURN;
		END
	END
	ELSE IF @flag = 'VAULT-TRANSIT'
	BEGIN
		IF @param1 = 'ct'
		BEGIN
			SELECT ACCT_NUM, ACCT_NAME
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AM(NOLOCK) 
			INNER JOIN APPLICATIONUSERS AU(NOLOCK) ON AU.USERID = AM.AGENT_ID
			INNER JOIN APPLICATIONUSERS AU1(NOLOCK) ON AU1.AGENTID = AU.AGENTID
			WHERE AU1.USERNAME = @USER
			RETURN;
		END	
		ELSE IF @param1 = 'cv'
		BEGIN
			SELECT ACCT_NUM, ACCT_NAME		--ONLY SHOW TOKYO MAIN BRANCH VAULT
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK) 
			WHERE acct_rpt_code = 'BVA'
			--AND ACCT_ID = 100109
			RETURN;
		END	
		ELSE 
		BEGIN
			SELECT ACCT_NUM, ACCT_NAME
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK) 
			WHERE acct_rpt_code = 'TB'
			RETURN;
		END
	END
	ELSE IF @flag = 'VAULT-ACC-AGENT'
	BEGIN
		SELECT ACCT_NUM, ACCT_NAME
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK)
		WHERE AGENT_ID = @agentId
		AND ACCT_RPT_CODE = 'BVA'
	END
	ELSE IF @flag = 'DDL-AGENT'
	BEGIN
		SELECT ACCT_NUM, ACCT_NAME
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER A(NOLOCK)
		WHERE acct_rpt_code = 'BVA'
		AND A.AGENT_ID = @agentId
	END
	ELSE IF @flag = 'ACC-USER'
	BEGIN
		SELECT ACCT_NUM, ACCT_NAME
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AM(NOLOCK)
		INNER JOIN APPLICATIONUSERS AU(NOLOCK) ON AU.USERID = AM.AGENT_ID
		WHERE AU.USERNAME = @user
		AND ACCT_RPT_CODE = 'TCA'
	END
	ELSE IF @FLAG = 'anyPendingTransactions'
	BEGIN
		IF EXISTS(SELECT 1 FROM remitTranTemp RT (NOLOCK)
								INNER JOIN applicationUsers AU (NOLOCK) ON AU.userName = RT.createdBy
								WHERE RT.sAgent = AU.agentId
								and RT.createdBy = @user)
		BEGIN
			EXEC proc_errorHandler 1, 'Unapproved Transaction Found', NULL
		END
		ELSE
		BEGIN
			EXEC proc_errorHandler 0, 'Unapproved Transaction Not Found', NULL
		END

	END
	IF @flag = 's-forAdmin'
	BEGIN	
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
						SELECT   AU.userId
								,BC.rowId
								,AU.username
								,BC.outAmount TransferredAmount
								,BC.tranDate TransferredDate
								,hasChanged = CASE WHEN (BC.approvedBy IS NULL)
													THEN ''Y'' ELSE ''N'' END
								,modifiedBy = CASE WHEN BC.approvedBy IS NULL THEN BC.createdBy END
								,isApproved = CASE WHEN (BC.approvedBy IS NULL) THEN ''Pending'' ELSE ''Approved'' END
								,mode = CASE WHEN MODE = ''B'' THEN ''Bank'' ELSE ''CASH'' END
								,toAcc = A.ACCT_NAME
						FROM dbo.BRANCH_CASH_IN_OUT BC (NOLOCK)
						INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = BC.userId
						LEFT JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER A(NOLOCK) ON A.ACCT_NUM = BC.TOACC
						WHERE HEAD = ''Transfer To Vault''
		)x '
		PRINT @table
		SET @sql_filter = ''
		
		SET @select_field_list ='userId,username,toAcc,mode,TransferredAmount,TransferredDate,rowId,isApproved,hasChanged,modifiedBy'
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
END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 

	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH




