USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_balanceTopUp]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_balanceTopUp]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@btId                              VARCHAR(30)		= NULL
	,@agentId                           INT				= NULL
	,@amount                            MONEY			= NULL
	,@topUpExpiryDate                   DATETIME		= NULL
	,@remarks							VARCHAR(MAX)	= NULL	
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
		,@today				DATETIME = DATEADD(DAY,7,CONVERT(VARCHAR, GETDATE(), 101))
		,@lastBgId			INT
	SELECT
		 @logIdentifier = 'btId'
		,@logParamMain = 'balanceTopUp'
		,@logParamMod = 'balanceTopUpMod'
		,@module = '20'
		,@tableAlias = 'Balance Top Up'
	IF @flag = 'i'
	BEGIN
		SELECT @userId = userId FROM applicationUsers WHERE userName = @user
		IF NOT EXISTS(SELECT 'X' FROM creditLimit WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Ledger not found', @user
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM topUpLimit WHERE userId = @userId)
		BEGIN
			EXEC proc_errorHandler 1, 'Operation Unsuccessful, You do not have permission.', @user
			RETURN 
		END		
		IF @amount IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please enter the amount', @user
			RETURN
		END

		SELECT 
			@lastBgId = MAX(bgId) 
		FROM bankGuarantee WITH(NOLOCK) 
		WHERE agentId = @agentId 
		AND ISNULL(isDeleted,'N') <> 'Y'
		AND ISNULL(isActive,'Y') <>'N'

		IF EXISTS(SELECT 'x' FROM bankGuarantee WITH(NOLOCK) 
			WHERE bgId = @lastBgId AND expiryDate < @today)
		BEGIN	
			UPDATE dbo.creditLimit SET 
				limitAmt = 0, 
				topUpToday = 0, 
				modifiedBy = @user, 
				modifiedDate = GETDATE() 
			WHERE agentId = @agentId
			SELECT '1','Bank Guarantee for this agent has been expired or going to expire. Please contact agent.',NULL
			RETURN
		END

		IF @amount > 0
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM topUpLimit WHERE userId = @userId AND limitPerDay > (
					SELECT ISNULL(SUM(ISNULL(amount, 0)),0) FROM balanceTopUp 
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

		IF(ISNULL((SELECT perTopUpLimit FROM topUpLimit WHERE userId = @userId AND approvedBy IS NOT NULL), 0) < @amount)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Top-up amount exceeded the User Per Top Up Limit', @user
			RETURN
		END

		IF(ISNULL((SELECT SUM(perTopUpAmt) FROM creditLimit WHERE agentId = @agentId AND approvedBy IS NOT NULL), 0) < @amount)	--changed due to multi pule result
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Top-up amount exceeded the Agent Per Top Up Limit', @user
			RETURN
		END
		DECLARE @basicLimit MONEY, @topUpT MONEY, @topUpY MONEY, @topUpYCalc MONEY, @maxLimitAmt MONEY, @todaysAddedMaxLimit MONEY
		SELECT 
			 @basicLimit = ISNULL(cl.limitAmt, 0)
			,@topUpT = ISNULL(cl.topUpToday, 0)
			,@topUpY = ISNULL(cl.topUpTillYesterday, 0)
			,@maxLimitAmt = ISNULL(cl.maxLimitAmt, 0)
			,@todaysAddedMaxLimit = ISNULL(cl.todaysAddedMaxLimit, 0)
			,@topUpYCalc = CASE WHEN cl.topUpTillYesterday - (CASE WHEN (v.clr_bal_amt - cl.yesterdaysBalance) < 0 THEN 0 ELSE (v.clr_bal_amt - cl.yesterdaysBalance) END) - cl.todaysPaid - cl.todaysCancelled + cl.todaysEPI - cl.todaysPOI <= 0 THEN 0 
							ELSE cl.topUpTillYesterday - (CASE WHEN (v.clr_bal_amt - cl.yesterdaysBalance) < 0 THEN 0 ELSE (v.clr_bal_amt - cl.yesterdaysBalance) END) - cl.todaysPaid - cl.todaysCancelled + cl.todaysEPI - cl.todaysPOI END
		FROM creditLimit cl WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON cl.agentId = am.agentId
		INNER JOIN dbo.vWAgentClrBal v ON v.map_code = am.mapCodeInt WHERE cl.agentId = @agentId
		IF((@amount + @basicLimit + @topUpT + @topUpYCalc) > @maxLimitAmt + @todaysAddedMaxLimit)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Agent Max Limit Amount exceeded', @user
			RETURN
		END
		BEGIN TRANSACTION	
			INSERT INTO balanceTopUp (
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
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @btId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		DECLARE @message AS VARCHAR(MAX)
		SET @message='Top Up Limit Amount '+ CAST(@amount AS VARCHAR) +' has been requested successfully.'
		EXEC proc_errorHandler 0, @message, @btId
	END
	
	ELSE IF @flag = 'ld'			--Other Limit Detail
	BEGIN
		SELECT 
			 am.agentName, 
			 cl.maxLimitAmt, 
			 cl.perTopUpAmt,
			 topUpTillYesterday = CASE WHEN cl.topUpTillYesterday - (CASE WHEN (v.clr_bal_amt - cl.yesterdaysBalance) < 0 THEN 0 ELSE 
			(v.clr_bal_amt - cl.yesterdaysBalance) END) - cl.todaysPaid - cl.todaysCancelled + cl.todaysEPI - cl.todaysPOI <= 0 
			THEN 0 ELSE cl.topUpTillYesterday - (CASE WHEN (v.clr_bal_amt - cl.yesterdaysBalance) < 0 THEN 0 
			ELSE (v.clr_bal_amt - cl.yesterdaysBalance) END) - cl.todaysPaid - cl.todaysCancelled + cl.todaysCancelled - cl.todaysPOI END,

			cl.topUpToday, 
			todaysCancel = cl.todaysCancelled, 
			cl.todaysEPI, 
			cl.todaysPOI,
			todaysFundDeposit = (V.clr_bal_amt - cl.yesterdaysBalance)
		FROM creditLimit cl WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON cl.agentId = am.agentId
		INNER JOIN dbo.vWAgentClrBal v ON v.map_code = am.mapCodeInt WHERE cl.agentId = @agentId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
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
		LEFT JOIN creditLimit cr WITH(NOLOCK) ON am.agentId = cr.agentId
		WHERE am.agentType = 2903 AND am.agentId = @agentId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE balanceTopUp SET
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
		DECLARE @msg AS VARCHAR(MAX)
		SET @msg='Top Up Amount '+ CAST(@amount AS VARCHAR) +' has been updated successfully.'
		EXEC proc_errorHandler 0, @msg, @btId
		
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE balanceTopUp SET
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
					,agentName = am.agentName+'' <b>(''+bal.createdBy+'')</b>''
					,bal.amount
					,bal.createdBy
					,bal.createdDate
					,availableBal = dbo.FNAGetLimitBalWithNegValue(am.agentId)
					,currBal = V.clr_bal_amt - cl.todaysSent + cl.todaysPaid + cl.todaysCancelled - cl.todaysEPI + cl.todaysPOI
					,appAmt = ''<input id="topUp_'' + CAST(bal.btId AS VARCHAR) + ''" type="text" style="width: 75px; text-align: right;" value="'' + CAST(bal.amount AS VARCHAR) + ''"/>''
					,securityType = CASE WHEN bg.agentId IS NOT NULL THEN ''Bank :''+dbo.ShowDecimal(bg.amount)+''</br>[Exp. Date :''+convert(varchar,bg.expiryDate,101)+'']''
						WHEN cs.agentId IS NOT NULL THEN ''Cash :''+dbo.ShowDecimal(cs.cashDeposit) ELSE ''-'' END
				FROM balanceTopUp bal WITH(NOLOCK)
				inner join creditLimit cl with(nolock) on cl.agentId = bal.agentId
				INNER JOIN agentMaster am WITH(NOLOCK) ON bal.agentId = am.agentId
				INNER JOIN dbo.vWAgentClrBal V ON V.map_code = am.mapCodeInt 
				LEFT JOIN dbo.cashSecurity cs WITH(NOLOCK) ON cs.agentId = bal.agentId AND ISNULL(cs.isDeleted,''N'') <>''Y'' 
				LEFT JOIN dbo.bankGuarantee bg WITH(NOLOCK) ON bg.agentId = bal.agentId AND ISNULL(bg.isDeleted,''N'') <>''Y''
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
			,availableBal
			,currBal
			,appAmt
			,securityType
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
		IF @sortBy IS NULL
			SET @sortBy = 'agentName'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		IF @user IN ('admin', 'admin1')
		BEGIN
			SET @table = '( 
					SELECT
						 main.crLimitId
						,am.agentId
						,am.agentName
						,am.agentCountry
						,am.agentDistrict
						,loc.districtName agentLocation
						,currency = ISNULL(cm.currencyCode, ''N/A'')
						,limitAmt = ISNULL(main.limitAmt, 0)
						,maxLimitAmt = ISNULL(main.maxLimitAmt, 0)
						,perTopUpAmt = ISNULL(main.perTopUpAmt, 0)
						,currentBalance = ABS(V.clr_bal_amt - main.todaysSent + main.todaysPaid + main.todaysCancelled - main.todaysEPI + main.todaysPOI)
						,availableLimit = 
									main.limitAmt - V.clr_bal_amt - main.todaysSent + main.todaysPaid + main.todaysCancelled - main.todaysEPI + main.todaysPOI

						,expiryDate = ISNULL(CAST(main.expiryDate AS VARCHAR), ''N/A'')
						,limitToppedUp = CASE WHEN main.topUpTillYesterday - (CASE WHEN (V.clr_bal_amt - main.yesterdaysBalance) < 0 THEN 0 ELSE (V.clr_bal_amt - main.yesterdaysBalance) END) 
						- main.todaysPaid - main.todaysCancelled + main.todaysEPI - main.todaysPOI <= 0 THEN
											main.topUpToday ELSE main.topUpToday + (main.topUpTillYesterday - (CASE WHEN (V.clr_bal_amt - main.yesterdaysBalance) < 0 THEN 0 ELSE (V.clr_bal_amt - main.yesterdaysBalance) END) 
											- main.todaysPaid - main.todaysCancelled + main.todaysEPI - main.todaysPOI) END
						,topUp = ''<input id="topUp_'' + CAST(am.agentId AS VARCHAR) + ''" type="text" style="width: 75px; text-align: right;"/>''
						,todaysSent = main.todaysSent
						,todaysPaid = main.todaysPaid 
						,todaysCancelled = main.todaysCancelled
						,main.createdBy
						,main.createdDate
						,main.modifiedBy							
					FROM agentMaster am 	
					INNER JOIN dbo.vWAgentClrBal V ON V.map_code = am.mapCodeInt 			
					INNER JOIN creditLimit main ON am.agentId = main.agentId
					LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyId	
					LEFT JOIN api_districtList loc with(nolock) ON loc.districtCode=am.agentLocation	
					WHERE am.isSettlingAgent = ''Y'' 
					) 
		
					'

		END	
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#agentId') IS NOT NULL
			DROP TABLE #agentId
		
			CREATE TABLE #agentId(agentId INT)	
			INSERT INTO #agentId
			SELECT agentId FROM agentMaster WHERE ISNULL(isDeleted, 'N') = 'N'
			
			DELETE FROM #agentId 						
			FROM #agentId ag
			INNER JOIN
			agentGroupMaping agm ON agm.agentId = ag.agentId
			WHERE agm.groupCat = '6900' AND ISNULL(agm.isDeleted, 'N') = 'N'
				
			INSERT INTO #agentId			
			SELECT DISTINCT agm.agentId FROM userGroupMapping ugm 
			INNER JOIN agentGroupMaping agm ON agm.groupDetail = ugm.groupDetail AND ISNULL(agm.isDeleted, 'N') = 'N' AND ISNULL(ugm.isDeleted, 'N') = 'N'
			WHERE ugm.userName = @user
		
			SET @table = '( 
					SELECT
						 main.crLimitId
						,am.agentId
						,am.agentName
						,am.agentCountry
						,am.agentDistrict
						,loc.districtName agentLocation
						,currency = ISNULL(cm.currencyCode, ''N/A'')
						,limitAmt = ISNULL(main.limitAmt, 0)
						,maxLimitAmt = ISNULL(main.maxLimitAmt, 0)
						,perTopUpAmt = ISNULL(main.perTopUpAmt, 0)
						,currentBalance = V.clr_bal_amt - main.todaysSent + main.todaysPaid + main.todaysCancelled - main.todaysEPI + main.todaysPOI
						,availableLimit = 
									CASE WHEN 										
										main.topUpTillYesterday - (CASE WHEN (V.clr_bal_amt - main.yesterdaysBalance) < 0 THEN 0 ELSE (V.clr_bal_amt - main.yesterdaysBalance) END) 
										- main.todaysPaid - main.todaysCancelled + main.todaysEPI - main.todaysPOI <= 0 THEN 
											main.limitAmt + main.topUpToday + V.clr_bal_amt - main.todaysSent + main.todaysPaid + main.todaysCancelled - main.todaysEPI + main.todaysPOI
									ELSE 
											main.limitAmt + (main.topUpTillYesterday - (CASE WHEN (V.clr_bal_amt - main.yesterdaysBalance) < 0 
											THEN 0 ELSE (V.clr_bal_amt - main.yesterdaysBalance) END) - main.todaysPaid - main.todaysCancelled + main.todaysEPI - main.todaysPOI) + 
											main.topUpToday + V.clr_bal_amt - main.todaysSent + main.todaysPaid + main.todaysCancelled - main.todaysEPI + main.todaysPOI
									END
						,expiryDate = ISNULL(CAST(main.expiryDate AS VARCHAR), ''N/A'')
						,limitToppedUp = CASE WHEN main.topUpTillYesterday - (CASE WHEN (V.clr_bal_amt - main.yesterdaysBalance) < 0 THEN 0 ELSE (V.clr_bal_amt - main.yesterdaysBalance) END) - main.todaysPaid - main.todaysCancelled + main.todaysEPI - main.todaysPOI <= 0 THEN
											main.topUpToday ELSE main.topUpToday + (main.topUpTillYesterday - (CASE WHEN (V.clr_bal_amt - main.yesterdaysBalance) < 0 THEN 0 ELSE (V.clr_bal_amt - main.yesterdaysBalance) END) - main.todaysPaid - main.todaysCancelled + main.todaysEPI - main


.todaysPOI) END
						,topUp = ''<input id="topUp_'' + CAST(am.agentId AS VARCHAR) + ''" type="text" style="width: 75px; text-align: right;" />''
						,todaysSent = main.todaysSent
						,todaysPaid = main.todaysPaid
						,todaysCancelled = main.todaysCancelled
						,main.createdBy
						,main.createdDate
						,main.modifiedBy								
					FROM agentMaster am
					INNER JOIN 
						(
							SELECT DISTINCT agentId FROM #agentId
						)ag ON am.agentId = ag.agentId 	
					INNER JOIN dbo.vWAgentClrBal V ON V.map_code = am.mapCodeInt 	
					INNER JOIN creditLimit main ON am.agentId = main.agentId
					LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyId
					LEFT JOIN api_districtList loc WITH(NOLOCK) ON loc.districtCode=am.agentLocation					
					WHERE am.isSettlingAgent = ''Y''
					) 
		
					'
		END
		
		
		SET @table = '( 
		SELECT
			 main.crLimitId
			,main.agentId
			,main.agentName
			,main.agentCountry
			,main.agentDistrict
			,main.agentLocation
			,main.currency
			,main.limitAmt
			,main.perTopUpAmt
			,main.limitToppedUp
			,main.maxLimitAmt
			,main.currentBalance
			,main.availableLimit
			,main.expiryDate
			,main.topUp
			,main.todaysSent
			,main.todaysPaid
			,main.todaysCancelled
			,main.createdBy
			,main.createdDate
			,modifiedBy	= main.createdBy
			,haschanged = ''N''
		FROM ' + @table + ' main
		) x

		'
		SET @sql_filter = ''
		
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + @haschanged + ''''
			
		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentCountry, '''')  LIKE ''%' + @agentCountry + '%'''
		
		IF @agentDistrict IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentDistrict, '''')  LIKE ''%' + @agentDistrict + '%'''
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
			
		IF @agentLocation IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') LIKE ''%' + @agentLocation + '%'''
		
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
			,agentDistrict
			,agentLocation
			,currency
			,limitAmt
			,perTopUpAmt
			,limitToppedUp
			,maxLimitAmt
			,currentBalance
			,availableLimit
			,expiryDate
			,topUp
			,todaysSent
			,todaysPaid
			,todaysCancelled
			,createdBy
			,createdDate
			,modifiedBy
			,hasChanged
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
	
	ELSE IF @flag = 'reject'
	BEGIN
		SELECT 
			@amount=amount,
			@agentId=agentId,
			@createdBy = createdBy 
		FROM balanceTopUp WHERE btId=@btId
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
				
				UPDATE balanceTopUp SET 
					 btStatus = 'Rejected'
					,approvedBy = @user
					,approvedDate = dbo.FNAGetDateInNepalTZ()
					,remarks = @remarks 
					,reqAmt= @amount
					,amount = 0
				WHERE btId=@btId
			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @btId
	END

	ELSE IF @flag = 'approve'
	BEGIN	
		DECLARE @maxCreditLimitForAgent MONEY, 
				@availableBal MONEY,
				@currBal MONEY,
				@reqAmt MONEY

		SELECT  @reqAmt = amount,
				@agentId = agentId,
				@createdBy = createdBy 
		FROM balanceTopUp WITH(NOLOCK) WHERE btId=@btId

		SELECT 
			@lastBgId = MAX(bgId) 
		FROM bankGuarantee WITH(NOLOCK) 
		WHERE agentId = @agentId 
		AND ISNULL(isDeleted,'N') <> 'Y'
		AND ISNULL(isActive,'Y') <>'N'

		IF EXISTS(SELECT 'x' FROM bankGuarantee WITH(NOLOCK) 
			WHERE bgId = @lastBgId AND expiryDate < @today)
		BEGIN	
			UPDATE dbo.creditLimit SET 
				limitAmt = 0, 
				topUpToday = 0, 
				modifiedBy = @user, 
				modifiedDate = GETDATE() 
			WHERE agentId = @agentId
			SELECT '1','Bank Guarantee for this agent has been expired or going to expire. Please contact agent.',NULL
			RETURN
		END

		IF NOT EXISTS(SELECT 'x' FROM balanceTopUp WITH(NOLOCK) WHERE btId = @btId AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Record has been approved already. Please CHECK.', @btId
			RETURN
		END

		IF (@amount IS NULL OR @amount = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Amount should not be blank.', @btId
			RETURN
		END
		IF(@createdBy = @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorised to approve this record.', @btId
			RETURN
		END
		
		SELECT 
			 @basicLimit = ISNULL(cl.limitAmt, 0)
			,@topUpT = ISNULL(cl.topUpToday, 0)
			,@topUpY = ISNULL(cl.topUpTillYesterday, 0)
			,@maxLimitAmt = ISNULL(cl.maxLimitAmt, 0)
			,@todaysAddedMaxLimit = ISNULL(cl.todaysAddedMaxLimit, 0)
			,@topUpYCalc = CASE WHEN cl.topUpTillYesterday - (CASE WHEN (v.clr_bal_amt - cl.yesterdaysBalance) < 0 THEN 0 ELSE (v.clr_bal_amt - cl.yesterdaysBalance) END) - cl.todaysPaid - cl.todaysCancelled + cl.todaysEPI - cl.todaysPOI <= 0 THEN 0 
							ELSE cl.topUpTillYesterday - (CASE WHEN (v.clr_bal_amt - cl.yesterdaysBalance) < 0 THEN 0 ELSE (v.clr_bal_amt - cl.yesterdaysBalance) END) - cl.todaysPaid - cl.todaysCancelled + cl.todaysEPI - cl.todaysPOI END
			,@currBal = V.clr_bal_amt - cl.todaysSent + cl.todaysPaid + cl.todaysCancelled - cl.todaysEPI + cl.todaysPOI
		FROM creditLimit cl WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON cl.agentId = am.agentId
		INNER JOIN dbo.vWAgentClrBal v ON v.map_code = am.mapCodeInt WHERE cl.agentId = @agentId

		IF((@amount + @basicLimit + @topUpT + @topUpYCalc) > @maxLimitAmt + @todaysAddedMaxLimit)
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot approve record. Agent MAX Limit Amount exceeded', @user
			RETURN
		END
				
		SELECT @maxCreditLimitForAgent = maxCreditLimitForAgent 
			FROM topuplimit tl WITH(NOLOCK) INNER JOIN applicationUsers au WITH(NOLOCK) ON tl.userId = au.userId
			WHERE au.userName = @user	

		IF @maxCreditLimitForAgent IS NULL OR @maxCreditLimitForAgent = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot approve record. User wise agent max credit limit amount has not been set yet.', @user
			RETURN
		END
		SET @availableBal =  dbo.FNAGetLimitBalWithNegValue(@agentId)

		IF(@maxCreditLimitForAgent + (@currBal - @amount - @availableBal) <  0)
		BEGIN
			SET @msg = 'You can not approve this record. Your max credit limit for agent has been exceeded. Your Limit: '+ dbo.ShowDecimal(@maxCreditLimitForAgent) +'.'
			EXEC proc_errorHandler 1, @msg, @user
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE creditLimit SET
				 topUpToday = ISNULL(topUpToday, 0) + @amount
			WHERE agentId = @agentId
			

			UPDATE balanceTopUp SET
				 btStatus		= 'Approved'
				,approvedBy		= @user
				,approvedDate	= dbo.FNAGetDateInNepalTZ()
				,remarks = @remarks
				,amount = @amount
				,reqAmt = @reqAmt
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
		EXEC proc_errorHandler 0, 'Balance topup request approved successfully.', @btId
	END
	
	ELSE IF @flag='history'
	BEGIN
		SET @sortBy = 'approvedDate'
		SET @sortOrder = 'DESC'
		
		SET @table = '( 
				select 
						amount,
						isnull(btStatus,''Requested'')btStatus,
						createdBy,
						createdDate,
						approvedBy,
						approvedDate 
					from balanceTopUp 
				where agentId=''' +  CAST(@agentId AS VARCHAR) + ''' 
				) x
	
				'
					
		SET @sql_filter = ''
		
		IF @approvedBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(approvedBy, '''') LIKE ''%' + @approvedBy + '%'''		
					
		IF @createdBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(createdBy, '''') LIKE ''%' + @createdBy + '%'''

		IF @approvedFromDate IS NOT NULL AND @approvedToDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR,@approvedFromDate, 101) + ''' AND ''' + CONVERT(VARCHAR,@approvedToDate, 101) + ' 23:59:59'''
		

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

	ELSE IF @flag='aa'
	BEGIN
		SELECT
			 am.agentId
			,am.agentName
			,securityType = 
						CASE WHEN cs.cashDeposit IS NULL AND bg.amount IS NULL THEN 'Security Type'
						WHEN cs.cashDeposit IS NULL AND bg.amount IS NOT NULL THEN 'Bank Guarantee' 
						WHEN cs.cashDeposit IS NOT NULL AND bg.amount IS NULL THEN 'Cash Security' 
						ELSE 'Security Type' END
			,securityValue = 
						CASE WHEN cs.cashDeposit IS NULL AND bg.amount IS NULL THEN 0
						WHEN cs.cashDeposit IS NULL AND bg.amount IS NOT NULL THEN bg.amount
						WHEN cs.cashDeposit IS NOT NULL AND bg.amount IS NULL THEN cs.cashDeposit 
						ELSE 0 END
			,baseLimit = ISNULL(cr.limitAmt, 0)
			,maxLimit = ISNULL(cr.maxLimitAmt, 0)
			,TodaysTopup = ISNULL(cr.topUpToday,0)
			,availableBal = ISNULL(dbo.FNAGetLimitBalWithNegValue(bt.agentId), 0)
			,currBal = V.clr_bal_amt - cr.todaysSent + cr.todaysPaid + cr.todaysCancelled - cr.todaysEPI + cr.todaysPOI
			,ReqLimit = bt.amount
		FROM dbo.balanceTopUp bt WITH(NOLOCK) 		
		INNER JOIN agentMaster am ON bt.agentId = am.agentId
		LEFT JOIN creditLimit cr WITH(NOLOCK) ON am.agentId = cr.agentId
		INNER JOIN dbo.vWAgentClrBal V ON V.map_code = am.mapCodeInt
		LEFT JOIN dbo.cashSecurity cs WITH(NOLOCK) ON bt.agentId = cs.agentId 
		LEFT JOIN dbo.bankGuarantee  bg WITH(NOLOCK) ON bt.agentId = bg.agentId
		
		WHERE bt.btId = @btId
	END	

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @btId
END CATCH





GO
