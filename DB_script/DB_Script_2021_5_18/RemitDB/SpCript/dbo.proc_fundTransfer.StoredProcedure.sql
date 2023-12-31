USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_fundTransfer]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*



*/
CREATE proc [dbo].[proc_fundTransfer]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(50)		= NULL
     ,@fundTrxId						VARCHAR(30)		= NULL
     ,@sAgent							VARCHAR(30)		= NULL
     ,@agent							varchar(200)	= NULL
     ,@trnAmt		                    Money		    = NULL
     ,@trnType							CHAR(1)			= NULL
     ,@trnDate							DATETIME		= NULL
     ,@remarks							VARCHAR(1000)	= NULL
     ,@isApproved						CHAR(1)			= NULL
     ,@approvedDate						DATETIME		= NULL
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL


AS
SET NOCOUNT ON
	
DECLARE @glcode VARCHAR(10), @acct_num VARCHAR(20);
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
       

SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@ApprovedFunctionId INT	
		
	SELECT
		 @logIdentifier = 'fundTrxId'
		,@logParamMain = 'fundTransfer'
		,@tableAlias = 'fundTransfer'
		,@module = 20
		,@ApprovedFunctionId = 20102030
	
	
	IF @flag = 'a'
	BEGIN
		--IF EXISTS (SELECT 'X' FROM fundTransferMod WITH(NOLOCK) WHERE fundTrxId = @fundTrxId AND createdBy = @user)
		--BEGIN
		--	SELECT 
		--		 *
		--	FROM fundTransferMod WHERE fundTrxId = @fundTrxId	
		--END
		--ELSE
		BEGIN
			SELECT 
				 T.agent,
				 T.trnAmt,
				 trnDate = CONVERT(VARCHAR,T.trnDate ,101),
				 T.remarks,
				 T.createdBy,
				 T.createdDate,
				 T.trnType,
				 AM.agentName
			FROM fundTransfer T WITH (NOLOCK)
			INNER JOIN agentMaster AM WITH (NOLOCK) ON T.agent = AM.agentId
			WHERE fundTrxId = @fundTrxId		
		END
	END
	
    ELSE IF @flag = 'i'
    BEGIN
		
		BEGIN TRANSACTION
			
			INSERT INTO fundTransfer (
				 sAgent
				,Agent
				,trnAmt
				,trnType
				,trnDate
				,remarks
				,createdBy
				,createdDate
			)
			SELECT
				 @sAgent
				,@agent
				,@trnAmt
				,@trnType
				,@trnDate
				,@remarks
				,@user
				,GETDATE()
                    
		SET @fundTrxId = SCOPE_IDENTITY()
		
				DELETE FROM fundTransferMod WHERE fundTrxId = @fundTrxId

				INSERT INTO fundTransferMod (
					 sAgent
					,fundTrxId
					,Agent
					,trnAmt
					,trnType
					,trnDate
					,remarks
					,createdBy
					,createdDate
					,modType 
				)
				SELECT
					 @sAgent
					,@fundTrxId
					,@agent
					,@trnAmt
					,@trnType
					,@trnDate
					,@remarks
					,@user
					,GETDATE()
					,'I'  
					
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
        EXEC proc_errorHandler 0, 'Record has been added successfully.', @fundTrxId
    END
    
    ELSE IF @flag = 'u'
    BEGIN
		IF EXISTS(SELECT 'A' FROM fundTransfer WHERE createdBy = @user AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record.', @fundTrxId
			RETURN;
		END
			
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM fundTransfer WITH(NOLOCK) WHERE fundTrxId = @fundTrxId AND approvedDate IS NULL )
			BEGIN

				UPDATE fundTransfer SET
					 sAgent						= @sAgent
					,Agent						= @agent
					,trnAmt						= @trnAmt
					,trnType					= @trnType
					,trnDate					= @trnDate
					,remarks					= @remarks
					,modifiedDate				= GETDATE()
					,modifiedBy					= @user
				WHERE fundTrxId = @fundTrxId
			END 
			ELSE
			BEGIN
				DELETE FROM fundTransferMod WHERE fundTrxId = @fundTrxId

				INSERT INTO fundTransferMod (
					 sAgent
					,fundTrxId
					,Agent
					,trnAmt
					,trnType
					,trnDate
					,remarks
					,createdBy
					,createdDate
					,modType 
				)
				SELECT
					 @sAgent
					,@fundTrxId
					,@agent
					,@trnAmt
					,@trnType
					,@trnDate
					,@remarks
					,@user
					,GETDATE()
					,'U'  
			END
			
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @fundTrxId
     END

	ELSE IF @flag = 'd'
	BEGIN

		IF EXISTS (SELECT 'X' FROM fundTransfer WITH(NOLOCK) 
			WHERE fundTrxId = @fundTrxId  AND createdBy = @user)
		BEGIN
			UPDATE fundTransfer SET isDeleted='Y',approvedBy=@user,approvedDate=GETDATE() WHERE fundTrxId = @fundTrxId
			--DELETE FROM fundTransfer WHERE fundTrxId = @fundTrxId
			--DELETE FROM fundTransferMod WHERE fundTrxId = @fundTrxId
			EXEC proc_errorHandler 0, 'Record deleted successfully', @fundTrxId
			return;
		END
		ELSE
		BEGIN
				EXEC proc_errorHandler 1, 'You can not delete this record!', @fundTrxId
				return;
		END



	END	

    ELSE IF @flag = 's'
    BEGIN

		IF @sortBy IS NULL
		   SET @sortBy = 'fundTrxId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.fundTrxId
							,main.sAgent
							,main.Agent                    
							,main.trnAmt 
							,trnType = CASE WHEN main.trnType = ''T'' THEN ''Transfer'' WHEN main.trnType = ''R'' THEN ''Received''  END
							,main.trnDate
							,main.remarks  
							,am.agentName              
							,main.createdBy
							,main.createdDate
							,haschanged = CASE WHEN (main.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
							,modifiedby = case when main.modifiedBy is not null then main.modifiedBy else main.createdBy end
	
					
					FROM fundTransfer main WITH(NOLOCK)
					INNER JOIN agentMaster am WITH(NOLOCK) ON main.Agent = am.agentId
					
					WHERE 
						main.approvedDate is null
						AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)					
					
						
			)x '
					
		SET @sql_filter = ''		
		
		IF(@agent IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agent + '%'''
		
		SET @select_field_list ='
				fundTrxId
               ,sAgent
               ,Agent               
               ,trnAmt
               ,trnType 
               ,trnDate
               ,remarks              
               ,agentName
               ,createdBy
               ,createdDate
               ,haschanged
               ,modifiedby
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
	
	ELSE IF @flag = 's1'
    BEGIN

		IF @sortBy IS NULL
		   SET @sortBy = 'fundTrxId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.fundTrxId
							,main.sAgent
							,main.Agent                    
							,main.trnAmt 
							,trnType = CASE WHEN main.trnType = ''T'' THEN ''Transfer'' WHEN main.trnType = ''R'' THEN ''Received''  END
							,main.trnDate
							,main.remarks 							
							,am.agentName              
							,main.createdBy
							,main.createdDate
							,haschanged = CASE WHEN (main.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
							,main.modifiedby
							,main.modifiedDate
							,trnStatus=case when isApproved=''N'' then ''Rejected'' else ''Approved'' end
							,main.approvedBy 
							,main.approvedDate
						FROM fundTransfer main 
						INNER JOIN agentMaster am WITH(NOLOCK) ON main.Agent = am.agentId
						WHERE main.approvedDate is not null 
					) x'
					

		
		SET @sql_filter = ''
		
		IF(@agent IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agent + '%'''
		
		SET @select_field_list ='
				fundTrxId
               ,sAgent
               ,Agent               
               ,trnAmt
               ,trnType 
               ,trnDate
               ,remarks              
               ,agentName
               ,createdBy
               ,createdDate
               ,haschanged
               ,modifiedby
               ,modifiedDate
               ,trnStatus
               ,approvedBy
               ,approvedDate
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
		IF NOT EXISTS (SELECT 'X' FROM fundTransfer WITH(NOLOCK) WHERE fundTrxId = @fundTrxId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM fundTransferMod WITH(NOLOCK) WHERE fundTrxId = @fundTrxId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @fundTrxId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM fundTransfer WHERE fundTrxId = @fundTrxId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fundTrxId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @fundTrxId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @fundTrxId
					RETURN
				END
				UPDATE fundTransfer SET isApproved='N',approvedBy=@user,approvedDate=GETDATE() WHERE fundTrxId=@fundTrxId
				--DELETE FROM fundTransfer WHERE fundTrxId = @fundTrxId				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @fundTrxId
	END
	
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM fundTransfer WITH(NOLOCK) WHERE fundTrxId = @fundTrxId AND ISNULL(isApproved,'N') = 'N')
		AND
		NOT EXISTS(SELECT 'X' FROM fundTransferMod WITH(NOLOCK) WHERE fundTrxId = @fundTrxId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @fundTrxId
			RETURN
		END
		BEGIN TRANSACTION		
			IF EXISTS (SELECT 'X' FROM fundTransfer WHERE isApproved IS NULL AND fundTrxId = @fundTrxId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM fundTransferMod WHERE fundTrxId = @fundTrxId
				
			IF @modType IN('I','U')
			BEGIN --New record
				UPDATE fundTransfer SET
					 isApproved = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE fundTrxId = @fundTrxId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fundTrxId, @newValue OUTPUT
				
			END
			DELETE FROM fundTransferMod WHERE fundTrxId = @fundTrxId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @fundTrxId, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @fundTrxId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @fundTrxId
	END	
			
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
