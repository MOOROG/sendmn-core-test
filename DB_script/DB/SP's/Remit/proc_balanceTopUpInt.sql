

ALTER PROC [dbo].[proc_balanceTopUpInt]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@btId                              VARCHAR(30)		= NULL
	,@agentId                           INT				= NULL
	,@amount                            MONEY			= NULL
	,@topUpExpiryDate                   DATETIME		= NULL
	,@hasChanged						CHAR(1)			= NULL
	,@agentCountry						VARCHAR(200)	= NULL
	,@agentDistrict						VARCHAR(200)	= NULL
	,@agentLocation						VARCHAR(200)	= NULL
	,@agentName							VARCHAR(200)	= NULL
	,@createdBy							VARCHAR(50)		= NULL
	,@approvedBy						VARCHAR(50)		= NULL
	,@approvedDate						VARCHAR(50)		= NULL
	,@createdDate						VARCHAR(50)		= NULL
	,@approvedFromDate					DATETIME		= NULL
	,@approvedToDate					DATETIME		= NULL
	,@riskyAgent						CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber						INT				= NULL
	,@hasLimit							VARCHAR(20)		= NULL


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
		,@userId			INT
	SELECT
		 @logIdentifier = 'btId'
		,@logParamMain = 'balanceTopUpInt'
		,@logParamMod = 'balanceTopUpIntMod'
		,@module = '20'
		,@tableAlias = 'Balance Top Up'
	IF @flag = 'i'
	BEGIN
		SELECT @userId = userId FROM applicationUsers WHERE userName = @user
		IF NOT EXISTS(SELECT 'X' FROM creditLimitInt WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Ledger not found', @user
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM topUpLimitInt WHERE userId = @userId)
		BEGIN
			EXEC proc_errorHandler 1, 'Operation Unsuccessful, You do not have permission.', @user
			RETURN 
		END
		
		IF @amount IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please enter the amount', @user
			RETURN
		END
		
		IF @amount > 0
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM topUpLimitInt WHERE userId = @userId AND limitPerDay > (
					SELECT ISNULL(SUM(ISNULL(amount, 0)),0) FROM balanceTopUpInt 
					WHERE createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
					AND agentId = @agentId
					AND createdBy = @user
					))
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, Your top up limit authority for today for this agent has exceeded.', @user
				RETURN
			END
		END
		
		IF(@amount > ISNULL((SELECT balance FROM applicationUsers WITH(NOLOCK) WHERE userName = @user), 0))
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, You do not have sufficient balance for the operation', @user
			RETURN
		END

		IF(ISNULL((SELECT perTopUpLimit FROM topUpLimitInt WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NOT NULL), 0) < @amount)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Top-up amount exceeded the User Per Top Up Limit', @user
			RETURN
		END

		IF(ISNULL((SELECT perTopUpAmt FROM creditLimitInt WITH(NOLOCK) WHERE agentId = @agentId AND approvedBy IS NOT NULL), 0) < @amount)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Top-up amount exceeded the Agent Per Top Up Limit', @user
			RETURN
		END
		DECLARE @basicLimit MONEY, @topUpT MONEY, @topUpY MONEY, @topUpYCalc MONEY, @maxLimitAmt MONEY, @todaysAddedMaxLimit MONEY
		--SELECT @basicLimit = limitAmt, @topUpT = ISNULL(topUpToday, 0), @topUpY = ISNULL(topUpTillYesterday, 0), @maxLimitAmt = maxLimitAmt FROM creditLimitInt WITH(NOLOCK) WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y'
		SELECT 
			 @basicLimit = ISNULL(cl.limitAmt, 0)
			,@topUpT = ISNULL(cl.topUpToday, 0)
			,@topUpY = ISNULL(cl.topUpTillYesterday, 0)
			,@maxLimitAmt = ISNULL(cl.maxLimitAmt, 0)
			,@todaysAddedMaxLimit = ISNULL(cl.todaysAddedMaxLimit, 0)
			,@topUpYCalc = ISNULL(CASE WHEN cl.topUpTillYesterday - (0 - cl.yesterdaysBalance) - cl.todaysPaid - cl.todaysCancelled + 0 - 0 <= 0 THEN 0 ELSE  cl.topUpTillYesterday - (0 - cl.yesterdaysBalance) - cl.todaysPaid - cl.todaysCancelled + 0 - 0 END,0)
		FROM creditLimitInt cl WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON cl.agentId = am.agentId
		WHERE cl.agentId = @agentId

		IF((@amount + @basicLimit + @topUpT + @topUpYCalc) > @maxLimitAmt + @todaysAddedMaxLimit)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Agent Max Limit Amount exceeded', @user
			RETURN
		END
		/*
		IF exists(SELECT 'X' FROM balanceTopUpInt WHERE agentId=@agentId AND btStatus is null AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Previous Top Up Request is still pending for approval!', @user
			RETURN
		END
		*/
		BEGIN TRANSACTION
		
			--AC Master
			/*
			UPDATE ac_master SET
				 top_up_today = ISNULL(top_up_today, 0) + @amount
			WHERE agent_id = @agentId AND gl_code = 1
			*/	
					
			INSERT INTO balanceTopUpInt (
				 agentId
				,amount
				,topUpExpiryDate
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@amount
				,@topUpExpiryDate
				,@user
				,dbo.FNAGetDateInNepalTZ()
				
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @btId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @btId, @user, @oldValue, @newValue
			
			--Update User Balance
			--UPDATE applicationUsers SET
			--	 balance = balance - @amount
			--WHERE userName = @user
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @btId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		declare @message as varchar(max)
		set @message='Top Up Limit Amount '+ CAST(@amount AS VARCHAR) +' has been requested successfully.'
		EXEC proc_errorHandler 0, @message, @btId
	END
	
	ELSE IF @flag = 'ld'			--Other Limit Detail
	BEGIN
		SELECT 
			 am.agentName, cl.maxLimitAmt, cl.perTopUpAmt
			--,cl.topUpTillYesterday
			,topUpTillYesterday = CASE WHEN cl.topUpTillYesterday - (0 - cl.yesterdaysBalance) - cl.todaysPaid - cl.todaysCancelled + 0 - 0 <= 0 THEN 0 ELSE cl.topUpTillYesterday - (0 - cl.yesterdaysBalance) - cl.todaysPaid - cl.todaysCancelled + 0 - 0 END
			,cl.topUpToday, todaysCancel = cl.todaysCancelled, todaysEPI = 0, todaysPOI = 0 
			,todaysFundDeposit = (0 - cl.yesterdaysBalance)
		FROM creditLimitInt cl WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON cl.agentId = am.agentId
		WHERE cl.agentId = @agentId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		--SELECT * FROM balanceTopUpInt WITH(NOLOCK) WHERE btId = @btId
		SELECT
			 am.agentId
			,am.agentName
			,availableAmt = ISNULL(dbo.FNAGetLimitBal(@agentId), 0)
			,limit = ISNULL(main.dr_bal_lim, 0)
			,maxLimitAmt = ISNULL(cr.maxLimitAmt, 0)
			,currency = ISNULL(cm.currencyCode, 'N/A')
		FROM agentMaster am 
		LEFT JOIN ac_master main ON am.agentId = main.agent_id
		LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.ac_currency = cm.currencyId
		LEFT JOIN creditLimitInt cr WITH(NOLOCK) ON am.agentId = cr.agentId
		WHERE am.agentType = 2903 AND am.agentId = @agentId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE balanceTopUpInt SET
				 agentId = @agentId
				,amount = @amount
				,topUpExpiryDate = @topUpExpiryDate
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE btId = @btId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @btId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @btId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @btId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		DECLARE @msg as varchar(max)
		SET @msg='Top Up Amount '+ CAST(@amount AS VARCHAR) +' has been updated successfully.'
		EXEC proc_errorHandler 0, @msg, @btId
		
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE balanceTopUpInt SET
				 btStatus='Deleted'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE btId = @btId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @btId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @btId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @btId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @btId
	END
	
	ELSE IF @flag = 'al'		--Approval List
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentName'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT 
					 bal.btId
					,am.agentName
					,bal.amount
					,bal.createdBy
					,bal.createdDate
				FROM balanceTopUpInt bal WITH(NOLOCK)
				INNER JOIN agentMaster am WITH(NOLOCK) ON bal.agentId = am.agentId
				WHERE bal.approvedBy IS NULL
				) x
		'
		
		SET @sql_filter = ''
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
				
		SET @select_field_list ='			 
			 btId
			,agentName
			,amount
			,createdBy
			,createdDate
			'
		
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
	
	ELSE IF @flag = 's'
	BEGIN
		SET @pageSize = '1000'
		SET @PAGENUMBER ='1'

		SET @sortBy = 'agentCountry'
		SET @sortOrder = 'ASC'

		SET @table = '( 
					SELECT 
						 main.crLimitId
						,am.agentId
						,am.agentName
						,am.agentCountry
						,currency = ISNULL(cm.currencyCode, ''N/A'')
						,limitAmt = ISNULL(main.limitAmt, 0)
						,maxLimitAmt = ISNULL(main.maxLimitAmt, 0)
						,perTopUpAmt = ISNULL(main.perTopUpAmt, 0)
						,acBal = CASE WHEN main.CURRENCY=''NPR'' THEN AM1.CLR_BAL_AMT ELSE AM1.USD_AMT END
						,todayTxnAmt = (isnull(main.todaysSent,0) - isnull(main.todaysPaid,0) - isnull(main.todaysCancelled,0))											 
						,expiryDate = ISNULL(CAST(main.expiryDate AS VARCHAR), ''N/A'')

						,limitToppedUp = isnull(main.topUpToday,0)				
								
						,topUp = ''<input id="topUp_'' + CAST(am.agentId AS VARCHAR) + ''" type="text" style="width: 75px; text-align: right;"/>''
						,main.createdBy
						,main.createdDate
						,main.modifiedBy
						,countryId = cCurr.countryId
						,collCurr = currMas.currencyCode
						,hasLimit = CASE WHEN main.agentId IS not NULL
											THEN ''Y'' ELSE ''N'' END 
					FROM agentMaster am 	
					--INNER JOIN FastMoneyPro_account.DBO.AGENTTABLE AT ON am.mapCodeInt = AT.MAP_CODE
					INNER JOIN FastMoneyPro_account.DBO.AC_MASTER AM1 ON am.agentid = AM1.agent_id	
					INNER JOIN countryCurrency cCurr WITH(NOLOCK) ON cCurr.countryId = am.agentCountryId
					INNER JOIN currencyMaster currMas WITH(NOLOCK) ON currMas.currencyId = cCurr.currencyId
					LEFT JOIN creditLimitInt main ON am.agentId = main.agentId
					LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyCode						
					WHERE am.isSettlingAgent = ''Y''
					AND ISNULL(am.agentrole,''B'') IN (''B'',''S'') 
					AND AM1.ACCT_RPT_CODE IN (''APR'', ''BR'')
					AND ISNULL(cCurr.isActive,''Y'') =''Y''
					AND ISNULL(cCurr.isDeleted,''N'') = ''N''
					AND ISNULL(cCurr.ISDEFAULT, ''N'') = ''Y''
					) 
		
					'
		
		SET @table = '( 
		SELECT
			 main.crLimitId
			,main.agentId
			,main.agentName
			,main.agentCountry
			,main.currency
			,main.limitAmt
			,main.perTopUpAmt
			,main.limitToppedUp
			,main.maxLimitAmt
			,currentBalance = (ISNULL(main.acBal,0) - isnull(todayTxnAmt,0))*-1
			,availableLimit = ISNULL(main.limitAmt,0)+ isnull(main.limitToppedUp,0) + ISNULL(main.acBal,0) - isnull(todayTxnAmt,0)
			,main.expiryDate
			,main.topUp
			,main.createdBy
			,main.createdDate
			,modifiedBy	= main.createdBy
			,haschanged = ''N''
			,main.hasLimit
		FROM ' + @table + ' main
		) x '				
		SET @sql_filter = ''
		
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + @haschanged + ''''
			
		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentCountry, '''')  LIKE ''%' + @agentCountry + '%'''		
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''			
		
		IF @hasLimit IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasLimit = ''' + CAST(@hasLimit AS VARCHAR) + ''''

		IF @riskyAgent IS NOT NULL
		BEGIN
			IF @riskyAgent = 'Y'
			BEGIN
				SET @sql_filter = @sql_filter + ' AND ((limitToppedUp >= (maxLimitAmt - limitAmt - (0.10 * maxLimitAmt)) AND maxLimitAmt <> limitAmt) OR availableLimit < 0)'
			END
		END
			
		SET @select_field_list ='			 
			 crLimitId
			,agentId
			,agentName
			,agentCountry
			,currency
			,limitAmt
			,perTopUpAmt
			,limitToppedUp
			,maxLimitAmt
			,currentBalance
			,availableLimit
			,expiryDate
			,topUp
			,createdBy
			,createdDate
			,modifiedBy
			,hasChanged
			,hasLimit
			'
		
		PRINT @table
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
	
	ELSE IF @flag = 'reject'
	BEGIN
		SELECT @amount=amount,@agentId=agentId,@createdBy = createdBy FROM balanceTopUpInt WHERE btId=@btId
		/*
		IF(@createdBy = @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorised to reject this record', @btId
			RETURN
		END
		*/
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @btId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @btId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @btId
					RETURN
				END
				
				UPDATE balanceTopUpInt SET BTSTATUS=@modType,approvedBy=@user,approvedDate=dbo.FNAGetDateInNepalTZ() WHERE btId=@btId
			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @btId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		SELECT @amount=amount,@agentId=agentId,@createdBy = createdBy FROM balanceTopUpInt WHERE btId=@btId
		-->> checking approve for same user
		--IF(@createdBy = @user)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'You are not authorised to approve this record', @btId
		--	RETURN
		--END
		BEGIN TRANSACTION
			--AC Master
			UPDATE creditLimitInt SET
				 topUpToday = ISNULL(topUpToday, 0) + @amount
			WHERE agentId = @agentId
			
			UPDATE balanceTopUpInt SET
				 btStatus		= 'Approved'
				,approvedBy		= @user
				,approvedDate	= dbo.FNAGetDateInNepalTZ()
			WHERE btId = @btId 
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @btId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @btId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @btId
	END
	
	ELSE IF @flag='history'
	BEGIN
		--IF @sortBy IS NULL
		SET @sortBy = 'approvedDate'
		--IF @sortOrder IS NULL
		SET @sortOrder = 'DESC'
		
		SET @table = '( 
				select 
						amount,
						isnull(btStatus,''Requested'')btStatus,
						createdBy,
						createdDate,
						approvedBy,
						approvedDate 
					from balanceTopUpInt 
				where agentId=''' +  cast(@agentId as varchar) + ''' 
				) x
	
				'
					
		SET @sql_filter = ''
		
		IF @approvedBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(approvedBy, '''') LIKE ''%' + @approvedBy + '%'''		
					
		IF @createdBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(createdBy, '''') LIKE ''%' + @createdBy + '%'''
			/*
		IF @createdDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cast(createdDate as date) = ''' + cast(@createdDate as varchar(11)) + ''''
		
		IF @approvedDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cast(approvedDate as date) = ''' + cast(@approvedDate as varchar(11)) + ''''
		*/	
		IF @approvedFromDate IS NOT NULL AND @approvedToDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR,@approvedFromDate, 101) + ''' AND ''' + CONVERT(VARCHAR,@approvedToDate, 101) + ' 23:59:59'''
		
		/*	
		IF @approvedDate IS NULL AND @createdDate IS NULL
			SET @sql_filter = @sql_filter + ' AND cast(createdDate as date) = ''' + cast(CONVERT(VARCHAR,GETDATE(),101) as varchar(11)) + ''''
		*/
			
			
		SET @select_field_list ='
			 amount
			,btStatus
			,createdBy
			,createdDate
			,approvedBy
			,approvedDate
			'
			
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
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @btId
END CATCH


