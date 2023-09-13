
ALTER PROC [dbo].[proc_creditLimitInt]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@crLimitId							VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@parentAgentId						INT				= NULL
	,@currency                          VARCHAR(3)		= NULL
	,@limitAmt                          MONEY			= NULL
	,@perTopUpAmt                       MONEY			= NULL
	,@maxLimitAmt                       MONEY			= NULL
	,@expiryDate                        DATETIME        = NULL	
	,@todaysAddedMaxLimit				MONEY			= NULL
	,@agentName							VARCHAR(100)	= NULL
	,@agentCountry						VARCHAR(100)	= NULL
	,@agentDistrict						VARCHAR(100)	= NULL
	,@agentLocation						VARCHAR(100)	= NULL
	,@createdBy							VARCHAR(50)		= NULL
	,@approvedBy						VARCHAR(50)		= NULL
	,@currencyCode						VARCHAR(50)		= NULL
	
	,@haschanged						CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT	

	SELECT
		 @ApprovedFunctionId =30011020 
		,@logIdentifier = 'crLimitId'
		,@logParamMain = 'creditLimitInt'
		,@logParamMod = 'creditLimitIntHistory'
		,@module = '20'
		,@tableAlias = 'Credit Limit'
	
	DECLARE 
		 @gl_code INT = 1
		,@acctNum				VARCHAR(30)
		,@acBalCurrId			INT
		,@acBalCurr				VARCHAR(3)
		,@todaysSentCount		INT
		,@todaysSentAmount		MONEY
		,@todaysPaidCount		INT
		,@todaysPaidAmount		MONEY
		,@todaysCancelledCount	INT
		,@todaysCancelledAmount	MONEY

	CREATE TABLE #agentId(agentId INT)
	IF @flag = 'detail'
	BEGIN
		DECLARE @todaysDate VARCHAR(50)
		SET @todaysDate = CONVERT(VARCHAR, GETDATE(), 101)
		--SELECT @acctNum = acct_num, @acBalCurrId = ac_currency FROM ac_master WHERE gl_code = @gl_code AND agent_id = @agentId
		SELECT @acBalCurr = currencyCode FROM currencyMaster WITH(NOLOCK) WHERE currencyId = @acBalCurrId
		SELECT @todaysSentCount = COUNT(id), @todaysSentAmount = SUM(tAmt) FROM remitTran WITH(NOLOCK) WHERE (sBranch = @agentId OR sAgent = @agentId) AND approvedDate BETWEEN @todaysDate AND @todaysDate + ' 23:59:59'
		SELECT @todaysPaidCount = COUNT(id), @todaysPaidAmount = SUM(pAmt) FROM remitTran WITH(NOLOCK) WHERE (pBranch = @agentId OR pAgent = @agentId) AND paidDate BETWEEN @todaysDate AND @todaysDate + ' 23:59:59'
		SELECT @todaysCancelledCount = COUNT(id), @todaysCancelledAmount = SUM(tAmt) FROM remitTran WITH(NOLOCK) WHERE (sBranch = @agentId OR sAgent = @agentId) AND cancelApprovedDate BETWEEN @todaysDate AND @todaysDate + ' 23:59:59'
		SELECT 
			 currentBalance			= ISNULL(dbo.FNAGetACBal(@acctNum), 0)
			,currentAvailable		= ISNULL(dbo.FNAGetLimitBal(@agentId), 0)
			,acBalCurr				= @acBalCurr 
			,todaysSentCount		= ISNULL(@todaysSentCount, 0)
			,todaysSentAmount		= ISNULL(@todaysSentAmount, 0)
			,sentAmountCurr			= 'NPR'
			,todaysPaidCount		= ISNULL(@todaysPaidCount, 0) 
			,todaysPaidAmount		= ISNULL(@todaysPaidAmount, 0)
			,paidAmountCurr			= 'NPR'
			,todaysCancelledCount	= ISNULL(@todaysCancelledCount, 0)
			,todaysCancelledAmount	= ISNULL(@todaysCancelledAmount, 0)
			,cancelledAmountCurr	= 'NPR'
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF (@limitAmt > @maxLimitAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Limit Amount defined greater than Max Limit Amt', @crLimitId
			RETURN
		END
		IF NOT EXISTS(SELECT 'X' FROM agentMaster WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Agent is not active', @agentId
			RETURN
		END
       IF EXISTS(SELECT 'A' FROM dbo.creditLimitInt (NOLOCK ) WHERE agentId  = @agentId)
		BEGIN
			SELECT '1','Limit has already been setup for this agent',NULL
			RETURN
		END
		BEGIN TRANSACTION
		
			INSERT INTO creditLimitInt (
				 agentId
				,currency
				,limitAmt
				,perTopUpAmt
				,maxLimitAmt
				,expiryDate
				,todaysAddedMaxLimit
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@currency
				,@limitAmt
				,@perTopUpAmt
				,@maxLimitAmt
				,@expiryDate
				,@todaysAddedMaxLimit
				,@user
				,GETDATE()
								
			SET @crLimitId = SCOPE_IDENTITY()	

			INSERT INTO creditLimitIntHistory(
					 crLimitId
					,agentId
					,currency
					,limitAmt
					,perTopUpAmt
					,maxLimitAmt
					,expiryDate
					,createdBy
					,createdDate
					,modType
					,status
				)
				SELECT
					 @crLimitId
					,@agentId
					,@currency
					,@limitAmt
					,@perTopUpAmt
					,@maxLimitAmt
					,@expiryDate
					,@user
					,GETDATE()
					,'I'
					,'Requested'
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @crLimitId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM creditLimitIntHistory WITH(NOLOCK)
				WHERE crLimitId = @crLimitId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				 mode.*
				,CONVERT(VARCHAR,mode.expiryDate,101) expiryDate1
			FROM creditLimitIntHistory mode WITH(NOLOCK)
			INNER JOIN creditLimitInt main WITH(NOLOCK) ON mode.crLimitId = main.crLimitId
			WHERE mode.crLimitId= @crLimitId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				 *
				,CONVERT(VARCHAR,expiryDate,101) expiryDate1
			FROM creditLimitInt WITH(NOLOCK) WHERE crLimitId = @crLimitId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM creditLimitInt WITH(NOLOCK)
			WHERE crLimitId = @crLimitId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet1.', @crLimitId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM creditLimitIntHistory WITH(NOLOCK)
			WHERE crLimitId  = @crLimitId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet2.', @crLimitId
			RETURN
		END
		IF (@limitAmt > @maxLimitAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Limit Amount defined greater than Max Limit Amt', @crLimitId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM creditLimitInt WHERE approvedBy IS NULL AND crLimitId  = @crLimitId)			
			BEGIN				
				UPDATE 
					creditLimitInt SET
					 agentId = @agentId
					,currency = @currency
					,limitAmt = @limitAmt
					,perTopUpAmt = @perTopUpAmt
					,maxLimitAmt = @maxLimitAmt
					,expiryDate = @expiryDate
					,todaysAddedMaxLimit = @todaysAddedMaxLimit
					,modifiedBy = @user
					,modifiedDate = GETDATE()
				WHERE crLimitId = @crLimitId					
				
				UPDATE creditLimitIntHistory SET
					 agentId = @agentId
					,currency = @currency
					,limitAmt = @limitAmt
					,perTopUpAmt = @perTopUpAmt
					,maxLimitAmt = @maxLimitAmt					
					,expiryDate = @expiryDate
				WHERE crLimitId = @crLimitId	
						
			END
			ELSE
			BEGIN
				DELETE FROM creditLimitIntHistory WHERE crLimitId = @crLimitId AND approvedBy IS NULL
				INSERT INTO creditLimitIntHistory(
					 crLimitId
					,agentId
					,currency
					,limitAmt
					,perTopUpAmt
					,maxLimitAmt
					,expiryDate
					,createdBy
					,createdDate
					,modType
					,status
				)
				SELECT
					 @crLimitId
					,@agentId
					,@currency
					,@limitAmt
					,@perTopUpAmt
					,@maxLimitAmt
					,@expiryDate
					,@user
					,GETDATE()
					,'U'
					,'Requested'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @crLimitId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM creditLimitInt WITH(NOLOCK)
			WHERE crLimitId = @crLimitId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @crLimitId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM creditLimitIntHistory  WITH(NOLOCK)
			WHERE crLimitId = @crLimitId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @crLimitId
			RETURN
		END
		SELECT @agentId = agentId FROM creditLimitInt WHERE crLimitId = @crLimitId
		IF EXISTS(SELECT 'X' FROM creditLimitInt WITH(NOLOCK) WHERE crLimitId = @crLimitId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM creditLimitInt WHERE crLimitId = @crLimitId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
			INSERT INTO creditLimitIntHistory(
					 crLimitId
					,agentId
					,currency
					,limitAmt
					,perTopUpAmt
					,maxLimitAmt
					,expiryDate
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 crLimitId
					,agentId
					,currency
					,limitAmt
					,perTopUpAmt
					,maxLimitAmt
					,expiryDate
					,@user
					,GETDATE()					
					,'D'
				FROM creditLimitInt
				WHERE crLimitId = @crLimitId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END


	ELSE IF @flag = 's'
	BEGIN
		DECLARE @hasRight CHAR(1)
		SET @hasRight = 'Y'
			IF @sortBy IS NULL
				SET @sortBy = 'agentName'
			IF @sortOrder IS NULL
				SET @sortOrder = 'ASC'

			SET @table = '(
					SELECT
						 crLimitId = ISNULL(mode.crLimitId, main.crLimitId)
						,agentId = ISNULL(mode.agentId, main.agentId)
						,currency = ISNULL(mode.currency, main.currency)
						,limitAmt = ISNULL(mode.limitAmt, main.limitAmt)
						,perTopUpAmt = ISNULL(mode.perTopUpAmt, main.perTopUpAmt)
						,maxLimitAmt = ISNULL(mode.maxLimitAmt, main.maxLimitAmt)
						,expiryDate = ISNULL(mode.expiryDate, main.expiryDate)
						,main.topUpTillYesterday
						,main.topUpToday
						,main.todaysSent
						,main.todaysPaid
						,main.todaysCancelled
						,main.lienAmt
						,main.createdBy
						,main.createdDate
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.crLimitId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END

					FROM creditLimitInt main WITH(NOLOCK)
					LEFT JOIN creditLimitIntHistory mode ON main.crLimitId = mode.crLimitId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
					
				) '				

			SET @table = '( 
						SELECT
							 main.crLimitId
							,am.agentId
							,am.agentName
							,am.agentCountry
							,am.agentCountryId
							,main.currency
							,limitAmt = ISNULL(CAST(main.limitAmt AS VARCHAR), ''N/A'')
							,maxLimitAmt = ISNULL(CAST(main.maxLimitAmt AS VARCHAR), ''N/A'')
							,perTopUpAmt = ISNULL(CAST(main.perTopUpAmt AS VARCHAR), ''N/A'')					
							,expiryDate = ISNULL(CAST(main.expiryDate AS VARCHAR), ''N/A'')				
							,main.createdBy
							,main.createdDate
							,main.modifiedBy							
							,haschanged
						FROM agentMaster am WITH(NOLOCK)
						LEFT JOIN ' + @table + ' main ON am.agentId = main.agentId
						WHERE am.isSettlingAgent = ''Y'' and am.parentId = '+cast(@parentAgentId as varchar)+' 
						--WHERE am.isSettlingAgent = ''N'' and am.parentId = '+cast(@parentAgentId as varchar)+'
						) x
			'
			
			SET @sql_filter = ''
			
			IF @haschanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
				
			IF @agentCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentCountry, '''') = ''' + @agentCountry + ''''
			
			IF @agentDistrict IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentDistrict, '''') = ''' + @agentDistrict + ''''
			
			IF @agentName IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
				
			IF @agentLocation IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') =''' + @agentLocation + ''''
			
		SET @select_field_list ='
			 crLimitId
			,agentId
			,agentName
			,agentCountry
			,agentCountryId
			,currency
			,limitAmt
			,perTopUpAmt
			,maxLimitAmt
			,expiryDate
			,createdBy
			,createdDate
			,modifiedBy
			,haschanged 
			'
		print @sql

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
	
	ELSE IF @flag = 'simpleGrid'
	BEGIN
	
	
			IF @sortBy IS NULL
				SET @sortBy = 'agentName'
			IF @sortOrder IS NULL
				SET @sortOrder = 'ASC'
		
			SET @table = '(
					SELECT
						 crLimitId = ISNULL(mode.crLimitId, main.crLimitId)
						,agentId = ISNULL(mode.agentId, main.agentId)
						,currency = ISNULL(mode.currency, main.currency)
						,limitAmt = ISNULL(mode.limitAmt, main.limitAmt)
						,perTopUpAmt = ISNULL(mode.perTopUpAmt, main.perTopUpAmt)
						,maxLimitAmt = ISNULL(mode.maxLimitAmt, main.maxLimitAmt)
						,expiryDate = ISNULL(mode.expiryDate, main.expiryDate)
						,main.topUpTillYesterday
						,main.topUpToday
						,main.todaysSent
						,main.todaysPaid
						,main.todaysCancelled
						,main.lienAmt
						,main.createdBy
						,main.createdDate
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.crLimitId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END

					FROM creditLimitInt main WITH(NOLOCK)
						LEFT JOIN creditLimitIntHistory mode ON main.crLimitId = mode.crLimitId AND mode.approvedBy IS NULL
							AND (
									mode.createdBy = ''' +  @user + ''' 
									OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
								)
						WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
							AND (
									main.approvedBy IS NOT NULL 
									OR main.createdBy = ''' +  @user + ''' 
									OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
								)
					
				) '				


			IF @user IN ('admin', 'imeadmin')
			BEGIN
				SET @table = '( 
						SELECT
							 main.crLimitId
							,am.agentId
							,am.agentName
							,am.agentCountry
							,am.agentDistrict
							,am.agentLocation
							,currency = ISNULL(cm.currencyCode, ''N/A'')
							,limitAmt = ISNULL(CAST(main.limitAmt AS VARCHAR), ''N/A'')
							,maxLimitAmt = ISNULL(CAST(main.maxLimitAmt AS VARCHAR), ''N/A'')
							,perTopUpAmt = ISNULL(CAST(main.perTopUpAmt AS VARCHAR), ''N/A'')
							--,currentBalance = v.clr_bal_amt
							--,availableLimit = dbo.FNAGetLimitBal(am.agentId)
							--,availableLimit = main.limitamt + main.topUpTillYesterday + main.topUpToday - V.todaysSend + V.todaysPaid + V.todaysCancel + v.clr_bal_amt - main.lienAmt
							,expiryDate = ISNULL(CAST(main.expiryDate AS VARCHAR), ''N/A'')
							--,limitToppedUp = ISNULL(main.topUpTillYesterday, 0) + ISNULL(main.topUpToday, 0)
							--,todaysSent = V.todaysSend
							--,todaysPaid = V.todaysPaid
							--,todaysCancelled = V.todaysCancel
							,main.createdBy
							,main.createdDate
							,main.modifiedBy							
							,haschanged
						FROM agentMaster am
						--INNER JOIN [192.168.0.83].FastMoneyPro_account.dbo.vWAgentClrBal V ON V.map_code = am.mapCodeInt
						LEFT JOIN ' + @table + ' main ON am.agentId = main.agentId
						LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyCode
						
						WHERE am.isSettlingAgent = ''Y''
						) x
			
						'
			END	
			ELSE
			BEGIN
			/*
				IF OBJECT_ID('tempdb..#agentId') IS NOT NULL
				DROP TABLE #agentId*/
			
				--CREATE TABLE #agentId(agentId INT)	
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
							,am.agentLocation
							,currency = ISNULL(cm.currencyCode, ''N/A'')
							,limitAmt = ISNULL(CAST(main.limitAmt AS VARCHAR), ''N/A'')
							,maxLimitAmt = ISNULL(CAST(main.maxLimitAmt AS VARCHAR), ''N/A'')
							,perTopUpAmt = ISNULL(CAST(main.perTopUpAmt AS VARCHAR), ''N/A'')					
							,expiryDate = ISNULL(CAST(main.expiryDate AS VARCHAR), ''N/A'')				
							,main.createdBy
							,main.createdDate
							,main.modifiedBy							
							,haschanged
						FROM agentMaster am
						INNER JOIN 
							(
								SELECT DISTINCT agentId FROM #agentId
							)ag ON am.agentId = ag.agentId 	
						--INNER JOIN [192.168.0.83].FastMoneyPro_account.dbo.vWAgentClrBal V ON V.map_code = am.mapCodeInt	
						LEFT JOIN ' + @table + ' main ON am.agentId = main.agentId
						LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyCode
						WHERE am.isSettlingAgent = ''Y''
						) x
			
						'
			END
			
			SET @sql_filter = ''
			
			IF @haschanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
				
			IF @agentCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentCountry, '''') = ''' + @agentCountry + ''''
			
			IF @agentDistrict IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentDistrict, '''') = ''' + @agentDistrict + ''''
			
			IF @agentName IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
				
			IF @agentLocation IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') =''' + @agentLocation + ''''

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
			,maxLimitAmt
			,expiryDate
			,createdBy
			,createdDate
			,modifiedBy
			,haschanged 
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
	
	ELSE IF @flag='history'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'approvedDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'Desc'
		
		SET @table = '( 
				select 
					 ROW_NUMBER()OVER(ORDER BY a.rowid desc) sn
					,b.currencyCode
					,limitAmt
					,perTopUpAmt
					,maxLimitAmt
					,expiryDate
					,a.createdBy
					,a.approvedBy
					,a.approvedDate
					,haschanged=''Y''
					,modifiedBy=''''
				from creditLimitIntHistory a with(nolock)  inner join currencyMaster b with(nolock) 
					on a.currency=b.currencyId
				where agentId=''' +  cast(@agentId as varchar) + ''' 
				) x
	
				'
					
		SET @sql_filter = ''
			
		IF @createdBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(createdBy, '''') LIKE ''%' + @currencyCode + '%'''
		
		IF @approvedBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(approvedBy, '''') LIKE ''%' + @currencyCode + '%'''
		
		IF @currencyCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(currencyCode, '''') LIKE ''%' + @currencyCode + '%'''
			
		SET @select_field_list ='
			 sn
			,currencyCode
			,limitAmt
			,perTopUpAmt
			,maxLimitAmt
			,expiryDate
			,createdBy
			,approvedBy
			,approvedDate
			,haschanged
			,modifiedBy
		
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
		IF NOT EXISTS (
			SELECT 'X' FROM creditLimitInt WITH(NOLOCK)
			WHERE crLimitId = @crLimitId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM creditLimitInt WITH(NOLOCK)
			WHERE crLimitId = @crLimitId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @crLimitId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM creditLimitInt WHERE approvedBy IS NULL AND crLimitId = @crLimitId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crLimitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crLimitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @crLimitId
					RETURN
				END
			DELETE FROM creditLimitInt WHERE crLimitId =  @crLimitId
			UPDATE creditLimitIntHistory SET status='Rejected',approvedBy=@user,approvedDate=GETDATE() where crLimitId =  @crLimitId
			--update FROM creditLimitInt WHERE crLimitId =  @crLimitId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crLimitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crLimitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @crLimitId
					RETURN
				END
				--DELETE FROM creditLimitIntHistory WHERE crLimitId = @crLimitId AND approvedBy IS NULL
				
				UPDATE creditLimitIntHistory SET status='Rejected',approvedBy=@user,approvedDate=GETDATE() where crLimitId =  @crLimitId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @crLimitId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM creditLimitInt WITH(NOLOCK)
			WHERE crLimitId = @crLimitId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM creditLimitInt WITH(NOLOCK)
			WHERE crLimitId = @crLimitId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @crLimitId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM creditLimitInt WHERE approvedBy IS NULL AND crLimitId = @crLimitId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM creditLimitIntHistory WHERE crLimitId = @crLimitId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
			
				UPDATE creditLimitInt SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE crLimitId = @crLimitId
				
				
				UPDATE creditLimitIntHistory SET					 
					 approvedBy = @user
					,approvedDate= GETDATE()
					,status='Approved'
				WHERE crLimitId = @crLimitId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crLimitId, @newValue OUTPUT

			--END
			
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crLimitId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId = mode.agentId
					,main.currency = mode.currency
					,main.limitAmt =  mode.limitAmt
					,main.perTopUpAmt =  mode.perTopUpAmt
					,main.maxLimitAmt =  mode.maxLimitAmt
					,main.expiryDate =  mode.expiryDate
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM creditLimitInt main
				INNER JOIN creditLimitIntHistory mode ON mode.crLimitId = main.crLimitId
				WHERE mode.crLimitId = @crLimitId AND mode.approvedBy IS NULL
				
				UPDATE creditLimitIntHistory SET					 
					 approvedBy = @user
					,approvedDate= GETDATE()
					,status='Approved'
				WHERE crLimitId = @crLimitId

				EXEC [dbo].proc_GetColumnToRow  'creditLimitInt', 'crLimitId', @crLimitId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crLimitId, @oldValue OUTPUT
				UPDATE creditLimitInt SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE crLimitId = @crLimitId
			END
			
			UPDATE creditLimitIntHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE crLimitId = @crLimitId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crLimitId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @crLimitId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @crLimitId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @crLimitId
END CATCH
