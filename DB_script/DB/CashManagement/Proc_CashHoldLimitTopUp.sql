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
-- Create date: <Create Date,,04/02/2019>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE Proc_CashHoldLimitTopUp 
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber						INT				= NULL
	,@hasChanged						CHAR(1)			= NULL
	,@agentCountry						VARCHAR(200)	= NULL
	,@agentName							VARCHAR(200)	= NULL
	,@hasLimit							VARCHAR(20)		= NULL
	,@riskyAgent						CHAR(1)			= NULL
	,@agentId                           INT				= NULL
	,@amount                            MONEY			= NULL
	,@btId								INT				= NULL 
	,@createdBy							VARCHAR(50)		= NULL
	,@approvedBy						VARCHAR(50)		= NULL
	,@approvedDate						VARCHAR(50)		= NULL
	,@approvedFromDate					DATETIME		= NULL
	,@approvedToDate					DATETIME		= NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE   @errorMessage VARCHAR(MAX)
			,@sql    VARCHAR(MAX)  
			,@table    VARCHAR(MAX)  
			,@select_field_list VARCHAR(MAX)  
			,@extra_field_list VARCHAR(MAX)  
			,@sql_filter  VARCHAR(MAX) 
			,@modType	CHAR(1)
			,@tableAlias		VARCHAR(100)
			,@logParamMain		VARCHAR(100)
			,@oldValue			VARCHAR(MAX)
			,@newValue			VARCHAR(MAX)
			,@logIdentifier		VARCHAR(50)
	IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '( 
					SELECT 
						 main.cashHoldLimitId
						,am.agentId
						,am.agentName
						,am.agentCountry
						,limitAmt = ISNULL(main.cashHoldLimit, 0)
						,perTopUpAmt = ISNULL(main.perTopUpLimit, 0)
						,limitToppedUp = isnull(main.topUpToday,0)				
						,topUp = ''<input id="topUp_'' + CAST(am.agentId AS VARCHAR) + ''" type="text" style="width: 75px; text-align: right;"/>''
						,main.createdBy
						,main.createdDate
						,main.modifiedBy
						,hasLimit = CASE WHEN main.agentId IS not NULL
											THEN ''Y'' ELSE ''N'' END 
					FROM agentMaster am 	
					INNER JOIN CASH_HOLD_LIMIT_BRANCH_WISE main ON am.agentId = main.agentId

					) 
		
					'
		
		SET @table = '( 
		SELECT
			 main.cashHoldLimitId
			,main.agentId
			,main.agentName
			,main.agentCountry
			,main.limitAmt
			,main.perTopUpAmt
			,main.limitToppedUp
			,main.topUp
			,main.createdBy
			,main.createdDate
			,modifiedBy	= main.createdBy
			,haschanged = ''N''
			,main.hasLimit
		FROM ' + @table + ' main
		) x '				
		SET @sql_filter = ''
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''			
		
					
		SET @select_field_list ='			 
			 cashHoldLimitId
			,agentId
			,agentName
			,agentCountry
			,limitAmt
			,perTopUpAmt
			,limitToppedUp
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
		ELSE IF @flag = 'al'		--Approval List
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentName'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT 
					 AP.btId
					,am.agentName
					,AP.amount
					,AP.createdBy
					,AP.createdDate
				FROM CASH_HOLD_LIMIT_TOP_UP_APPROVAL AP WITH(NOLOCK)
				INNER JOIN agentMaster am WITH(NOLOCK) ON AP.agentId = am.agentId
				WHERE AP.approvedBy IS NULL
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

	ELSE IF @flag = 'i'
	BEGIN
	IF EXISTS (SELECT 1 FROM dbo.CASH_HOLD_LIMIT_TOP_UP_APPROVAL WHERE agentId = @agentId AND approvedDate IS NULL)
	BEGIN
			EXEC proc_errorHandler 1, 'Previous top-up is waiting for approval', @user
			RETURN
	END 
	IF @amount IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please enter the amount', @user
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dbo.CASH_HOLD_LIMIT_TOP_UP_APPROVAL
			        ( agentId , amount ,btStatus , createdBy , createdDate ,approvedBy ,approvedDate ,modType 
			        )
			VALUES  ( @agentId , -- agentId - int
			          @amount , -- amount - int
			          NULL , -- btStatus - varchar(50)
			          @user , -- createdBy - varchar(30)
			          GETDATE() , -- createdDate - datetime
			          NULL  , -- approvedBy - varchar(30)
			          NULL  , -- approvedDate - datetime
			          NULL  -- modType - varchar(1)
			        )

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		DECLARE @msg as varchar(max)
		SET @msg='Top Up Amount '+ CAST(@amount AS VARCHAR) +' has been saved successfully and is waiting for apporval'
		EXEC proc_errorHandler 1, @msg, NULL 
		
	END
	ELSE IF @flag = 'approve'
	BEGIN
		SELECT @amount=amount,@agentId=agentId,@createdBy = createdBy FROM CASH_HOLD_LIMIT_TOP_UP_APPROVAL WHERE btId=@btId
		-->> checking approve for same user
		--IF(@createdBy = @user)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'You are not authorised to approve this record', @btId
		--	RETURN
		--END
		BEGIN TRANSACTION
			
			UPDATE dbo.CASH_HOLD_LIMIT_TOP_UP_APPROVAL SET
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
	ELSE IF @flag = 'reject'
	BEGIN
		SELECT @amount=amount,@agentId=agentId,@createdBy = createdBy FROM CASH_HOLD_LIMIT_TOP_UP_APPROVAL WHERE btId=@btId
		
		--IF(@createdBy = @user)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'You are not authorised to reject this record', @btId
		--	RETURN
		--END
		
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
				
				UPDATE dbo.CASH_HOLD_LIMIT_TOP_UP_APPROVAL SET BTSTATUS=@modType,approvedBy=@user,approvedDate=dbo.FNAGetDateInNepalTZ() WHERE btId=@btId
			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @btId
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
					from CASH_HOLD_LIMIT_TOP_UP_APPROVAL 
				where agentId=''' +  cast(@agentId as varchar) + ''' 
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

END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 

	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH

