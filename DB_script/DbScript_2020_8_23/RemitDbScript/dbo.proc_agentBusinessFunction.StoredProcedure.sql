USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentBusinessFunction]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_agentBusinessFunction]
	 @flag									VARCHAR(50)		= NULL
	,@user									VARCHAR(30)		= NULL
    ,@rowId									INT				= NULL
    ,@agentId								VARCHAR(50)		= NULL
    ,@rsagentId								CHAR(2)			= NULL
    ,@agentType								CHAR(2)			= NULL
	,@defaultDepositMode					CHAR(2)			= NULL
	,@invoicePrintMode						CHAR(2)			= NULL
	,@invoicePrintMethod					CHAR(2)			= NULL
	,@globalTRNAllowed						CHAR(1)			= NULL
	,@agentOperationType					CHAR(1)			= NULL
	,@applyCoverFund						CHAR(1)			= NULL
	,@sendSMSToReceiver						CHAR(1)			= NULL
	,@sendEmailToReceiver					CHAR(1)			= NULL
	,@sendSMSToSender						CHAR(1)			= NULL
	,@sendEmailToSender						CHAR(1)			= NULL
	,@trnMinAmountForTestQuestion			MONEY			= NULL
	,@birthdayAndOtherWish					CHAR(1)			= NULL
	,@agentLimitDispSendTxn					CHAR(1)			= NULL
	,@enableCashCollection					CHAR(1)			= NULL
    ,@dateFormat							VARCHAR(10)		= NULL
    ,@settlementType						INT				= NULL
    ,@fromSendTrnTime						TIME			= NULL
    ,@toSendTrnTime							TIME			= NULL
    ,@fromPayTrnTime						TIME			= NULL
    ,@toPayTrnTime							TIME			= NULL
    ,@fromRptViewTime						TIME			= NULL
    ,@toRptViewTime							TIME			= NULL
    ,@isActive								CHAR(1)			= NULL
    ,@tAmt									MONEY			= NULL
    ,@agentAutoApprovalLimit				MONEY			= NULL
    ,@isRT									VARCHAR(1)		= NULL
    ,@sortBy								VARCHAR(50)		= NULL
    ,@sortOrder								VARCHAR(5)		= NULL
    ,@pageSize								INT				= NULL
    ,@pageNumber							INT				= NULL
	,@isSelfTxnApprove						VARCHAR(10)		= NULL
    ,@routingEnable							CHAR(1)			= NULL
    ,@hasUSDNostroAc						CHAR(1)			= NULL
    ,@flcNostroAcCurr						VARCHAR(100)	= NULL
	,@fxGain								CHAR(1)			= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(error_code INT, msg VARCHAR(100), id INT)
     DECLARE
           @sql           VARCHAR(MAX)
          ,@oldValue      VARCHAR(MAX)
          ,@newValue      VARCHAR(MAX)
          ,@tableName     VARCHAR(50)
     DECLARE
           @select_field_list VARCHAR(MAX)
          ,@extra_field_list  VARCHAR(MAX)
          ,@table             VARCHAR(MAX)
          ,@sql_filter        VARCHAR(MAX)
     DECLARE
           @gridName              VARCHAR(50)
          ,@modType               VARCHAR(6)
     SELECT
           @gridName          = 'grid_agentBusinessFunction'
           
     IF @flag='a'
     BEGIN
			SELECT * FROM agentBusinessFunction WHERE agentId=@agentId
     END
           
     IF @flag = 'i'
     BEGIN
		IF NOT EXISTS(SELECT 'X' from agentBusinessFunction WHERE agentId=@agentId)
		BEGIN
          BEGIN TRANSACTION
               INSERT INTO agentBusinessFunction (
                     agentId
					,defaultDepositMode
					,invoicePrintMode
					,invoicePrintMethod
					,globalTRNAllowed
					,agentOperationType
					,applyCoverFund
					,sendSMSToReceiver
					,sendEmailToReceiver
					,sendSMSToSender
					,sendEmailToSender
					,trnMinAmountForTestQuestion
					,birthdayAndOtherWish
					,enableCashCollection
					,agentLimitDispSendTxn
                    ,[dateFormat]
                    ,settlementType
                    ,fromSendTrnTime
                    ,toSendTrnTime
                    ,fromPayTrnTime
                    ,toPayTrnTime
                    ,fromRptViewTime
                    ,toRptViewTime
                    ,isActive
                    ,isRT
                    ,agentAutoApprovalLimit
                    ,createdBy
                    ,createdDate
                    ,routingEnable
					,isSelfTxnApprove
					,hasUSDNostroAc
					,flcNostroAcCurr
					,fxGain
               )
               SELECT
                     @agentId
					,@defaultDepositMode
					,@invoicePrintMode
					,@invoicePrintMethod
					,@globalTRNAllowed
					,@agentOperationType
					,@applyCoverFund
					,@sendSMSToReceiver
					,@sendEmailToReceiver
					,@sendSMSToSender
					,@sendEmailToSender
					,@trnMinAmountForTestQuestion
					,@birthdayAndOtherWish
					,@enableCashCollection
					,@agentLimitDispSendTxn
                    ,@dateFormat
                    ,@settlementType
                    ,@fromSendTrnTime
                    ,@toSendTrnTime
                    ,@fromPayTrnTime
                    ,@toPayTrnTime
                    ,@fromRptViewTime
                    ,@toRptViewTime
                    ,@isActive
                    ,@isRT
                    ,@agentAutoApprovalLimit
                    ,@user
                    ,GETDATE()
                    ,@routingEnable
					,@isSelfTxnApprove
					,@hasUSDNostroAc
					,@flcNostroAcCurr
					,@fxGain
                    
               SET @rowId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'agentBusinessFunction', 'agentBusinessFunctionId', @rowId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'agentBusinessFunction', @rowId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @rowId id
                    RETURN
               END
              /*
			   IF EXISTS(SELECT 'x' FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId AND agentType = 2903)
               BEGIN
					EXEC proc_agentMaster_sub1 @flag = 'account', @agentId = @agentId, @user  = @user				
			   END
              */ 
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been saved successfully' mes, @rowId id
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'agentBusinessFunction', 'agentBusinessFunctionId', @rowId, @oldValue OUTPUT
               UPDATE agentBusinessFunction SET
						 defaultDepositMode					= @defaultDepositMode
						,invoicePrintMode					= @invoicePrintMode
						,invoicePrintMethod					= @invoicePrintMethod
						,globalTRNAllowed					= @globalTRNAllowed
						,agentOperationType					= @agentOperationType
						,applyCoverFund						= @applyCoverFund
						,sendSMSToReceiver					= @sendSMSToReceiver
						,sendEmailToReceiver				= @sendEmailToReceiver
						,sendSMSToSender					= @sendSMSToSender
						,sendEmailToSender					= @sendEmailToSender
						,trnMinAmountForTestQuestion		= @trnMinAmountForTestQuestion
						,birthdayAndOtherWish				= @birthdayAndOtherWish
						,enableCashCollection				= @enableCashCollection
						,agentLimitDispSendTxn				= @agentLimitDispSendTxn
						,[dateFormat]						= @dateFormat
						,settlementType						= @settlementType
						,fromSendTrnTime					= @fromSendTrnTime
						,toSendTrnTime						= @toSendTrnTime
						,fromPayTrnTime						= @fromPayTrnTime
						,toPayTrnTime						= @toPayTrnTime
						,fromRptViewTime					= @fromRptViewTime
						,toRptViewTime						= @toRptViewTime
						,isActive							= @isActive
						,isRT								= @isRT
						,agentAutoApprovalLimit				= @agentAutoApprovalLimit
						,modifiedBy							= @user
						,modifiedDate						= GETDATE()
						,routingEnable						= @routingEnable
						,isSelfTxnApprove					= @isSelfTxnApprove
						,hasUSDNostroAc						= @hasUSDNostroAc
						,flcNostroAcCurr					= @flcNostroAcCurr
						,fxGain								= @fxGain
                    WHERE agentId = @agentId
                    EXEC [dbo].proc_GetColumnToRow  'agentBusinessFunction', 'agentBusinessFunctionId', @rowId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'agentBusinessFunction', @rowId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @rowId id
                         RETURN
                    END
                    /*   
					IF EXISTS(SELECT 'x' FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId AND agentType = 2903)
					BEGIN
						EXEC proc_agentMaster_sub1 @flag = 'account', @agentId = @agentId, @user  = @user				
					END
   					*/
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record has been updated successfully.' mes, @rowId id 
          END
     END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'agentBusinessFunction', 'agentBusinessFunctionId', @rowId, @oldValue OUTPUT
               UPDATE agentBusinessFunction SET
						 defaultDepositMode					= @defaultDepositMode
						,invoicePrintMode					= @invoicePrintMode
						,invoicePrintMethod					= @invoicePrintMethod
						,globalTRNAllowed					= @globalTRNAllowed
						,agentOperationType					= @agentOperationType
						,applyCoverFund						= @applyCoverFund
						,sendSMSToReceiver					= @sendSMSToReceiver
						,sendEmailToReceiver				= @sendEmailToReceiver
						,sendSMSToSender					= @sendSMSToSender
						,sendEmailToSender					= @sendEmailToSender
						,trnMinAmountForTestQuestion		= @trnMinAmountForTestQuestion
						,birthdayAndOtherWish				= @birthdayAndOtherWish
						,enableCashCollection				= @enableCashCollection
						,agentLimitDispSendTxn				= @agentLimitDispSendTxn
						,[dateFormat]						= @dateFormat
						,settlementType						= @settlementType
						,fromSendTrnTime					= @fromSendTrnTime
						,toSendTrnTime						= @toSendTrnTime
						,fromPayTrnTime						= @fromPayTrnTime
						,toPayTrnTime						= @toPayTrnTime
						,fromRptViewTime					= @fromRptViewTime
						,toRptViewTime						= @toRptViewTime
						,isActive							= @isActive
						,isRT								= @isRT
						,agentAutoApprovalLimit				= @agentAutoApprovalLimit
						,modifiedBy							= @user
						,modifiedDate						= GETDATE()
						,isSelfTxnApprove					= @isSelfTxnApprove
						,hasUSDNostroAc						= @hasUSDNostroAc
						,flcNostroAcCurr					= @flcNostroAcCurr
						,fxGain								= @fxGain
                    WHERE agentBusinessFunctionId = @rowId
                    EXEC [dbo].proc_GetColumnToRow  'agentBusinessFunction', 'agentBusinessFunctionId', @rowId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'agentBusinessFunction', @rowId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @rowId id
                         RETURN
                    END
                    IF @agentId IS NULL
                    BEGIN
						SELECT
							@agentId = agentId
						FROM agentBusinessFunction WITH(NOLOCK)
						WHERE agentBusinessFunctionId = @rowId
                    END
                    /*
                    IF EXISTS(SELECT 'x' FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId AND agentType = 2903)
					BEGIN
						EXEC proc_agentMaster_sub1 @flag = 'account', @agentId = @agentId, @user  = @user				
					END
                    */
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @rowId id 
     END

	ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE agentBusinessFunction SET
                     isDeleted		= 'Y'
                    ,modifiedBy		= @user
                    ,modifiedDate	=GETDATE()
               WHERE agentBusinessFunctionId = @rowId
               EXEC [dbo].proc_GetColumnToRow  'agentBusinessFunction', 'agentBusinessFunctionId', @rowId, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'agentBusinessFunction', @rowId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @rowId id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @rowId id
     END

--- AGENT INVOICE PRINT MODE
	ELSE IF @flag = 'inv'
	BEGIN
		   
		 declare @mode varchar(20)=null
	    
	    IF @agentId IS NOT NULL AND (ISNUMERIC(@agentId) = 1)
	    BEGIN
			SELECT @mode = CASE WHEN invoicePrintMode='S' then 'Single' ELSE 'Multiple' END  from agentBusinessFunction WITH (NOLOCK)
			WHERE agentId = @agentId
	    END
	    ELSE
	    BEGIN
			SELECT @mode = CASE WHEN invoicePrintMode='S' then 'Single' ELSE 'Multiple' END  from agentBusinessFunction WITH (NOLOCK)
			WHERE agentId = (SELECT am.parentId FROM applicationUsers au WITH (NOLOCK) 
							INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
							WHERE userName =@user)
		END
		----SELECT @mode = detailTitle  FROM staticDataValue sdv WITH (NOLOCK)
		----INNER JOIN agentBusinessFunction abf WITH (NOLOCK) ON abf.invoicePrintMode = sdv.valueId
		----WHERE abf.agentId = (SELECT agentId FROM applicationUsers WITH (NOLOCK) WHERE userName =@user)


		SELECT isnull(@mode, 'Multiple') as [mode]
	    
	END

	ELSE IF @flag = 'invMethod'
	BEGIN
		DECLARE 
			 @method		VARCHAR(20) = NULL
			,@userId		INT
			,@sendLimit		MONEY
		
		SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		SELECT @sendLimit = sendLimit FROM userLimit WITH(NOLOCK) 
			WHERE userId = @userId 
				AND ISNULL(isDeleted, 'N') <> 'Y' 
				AND ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isEnable, 'N') = 'Y'  
		SELECT
			 @method = invoicePrintMethod
		FROM agentBusinessFunction WITH(NOLOCK)
		WHERE agentId = (SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)
		
		IF(@sendLimit > @tAmt)
			SELECT 'Y'
		ELSE IF(@method = 'ba')
			SELECT 'Y'
		ELSE
			SELECT 'N'
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
