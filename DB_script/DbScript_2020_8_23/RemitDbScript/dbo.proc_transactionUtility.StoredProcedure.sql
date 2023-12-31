USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionUtility]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_transactionUtility] (
	 @flag					VARCHAR(50)
	,@user					VARCHAR(50) 	= NULL		
	,@controlNo				VARCHAR(100)	= NULL
	,@agentId				VARCHAR(100)	= NULL
	,@requestXML			VARCHAR(MAX)	= NULL
	,@responseXML			VARCHAR(MAX)	= NULL
	,@id					VARCHAR(50)		= NULL
	,@msg					VARCHAR(200)	= NULL
	,@holdTranId			VARCHAR(50)		= NULL
	,@createdDate			VARCHAR(50)		= NULL
	,@count					INT				= NULL
	,@pass					VARCHAR(50)		= NULL
	,@ragent				VARCHAR(100)	= NULL
	,@agentCode				VARCHAR(50)		= NULL
	,@sortBy				VARCHAR(50)		= NULL
    ,@sortOrder				VARCHAR(5)		= NULL
    ,@pageSize				INT				= NULL
    ,@pageNumber			INT				= NULL
	,@bankType				CHAR(1)			= NULL
	,@fromDate				VARCHAR(50)		= NULL
	,@toDate				VARCHAR(50)		= NULL
	,@rCountry				VARCHAR(50)		= NULL
	,@bankCode				VARCHAR(max)    = NULL
	,@accountNo				VARCHAR(100)	= NULL
	,@accountName			VARCHAR(100)	= NULL 	
	,@responseCode			VARCHAR(100)    = NULL 
	,@bankName				VARCHAR(100)	= NULL
	,@superAgentId			VARCHAR(50)		= NULL
	,@targetCountries		VARCHAR(MAX)	= NULL
)
AS
/*

*/
SET XACT_ABORT ON 
SET NOCOUNT ON 
BEGIN TRY
	--Get list of agent and date for Sync Status in Bulk (Called by Schedular)
	DECLARE 
		@table             VARCHAR(MAX)
		,@sql		        VARCHAR(MAX)
		,@select_field_list VARCHAR(MAX)
		,@riaAgentId INT = 56778

	--Reprocess List
	IF @flag = 'rp'	
	BEGIN
		 
		IF @sortBy IS NULL
		   SET @sortBy = 'id'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   
		SET @table = '(
						SELECT DISTINCT
							 trn.id
							,ISNULL(trn.holdTranId,trn.id) holdTranId
							,controlNo = dbo.FNADecryptString(trn.controlNo)
							,sAgent = ams.agentName	
							,sBranchName						
							,sCountry = trn.sCountry	
							,rAgent = amr.agentName	
							,rCountry = trn.pCountry								
							,sender = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')							
							,receiver = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
							,accountNo = trn.accountNo
							,amt = CAST(trn.cAmt AS DECIMAL(18, 2))				
							,createdDate = CONVERT(VARCHAR, trn.createdDate, 101)
							,createdBy = trn.createdBy
							,collMode = trn.collMode
							,ScOrderNo = ''''
						FROM remitTran trn WITH(NOLOCK)
						LEFT JOIN agentMaster ams WITH(NOLOCK) ON trn.sAgent = ams.agentId	
						LEFT JOIN agentMaster amr WITH(NOLOCK) ON trn.pAgent = amr.agentId	
						INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
						INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId												
						WHERE trn.approvedBy IS NOT NULL AND trn.payStatus =''Unpaid'' 
						AND tranStatus = ''payment'' AND trn.pAgent = 1056 AND pCountry=''Nepal''
					'
			
			IF @id IS NOT NULL			
				SET @table = @table + ' AND trn.id = ''' + @id + '''' 
			IF @createdDate IS NOT NULL
				SET @table = @table + '  AND TRN.createdDate between '''+@createdDate+''' and  '''+@createdDate+' 23:59:59'''
			IF @holdTranId IS NOT NULL
				SET @table = @table  + '  AND TRN.holdTranId = '''+@holdTranId+''''
			IF @controlNo IS NOT NULL
				SET @table = @table  + '  AND TRN.controlNo = dbo.FNAEncryptString('''+@controlNo+''')'
			IF @ragent IS NOT NULL
				SET @table = @table  + '  AND amr.agentName = '''+@ragent+''''
			if @rCountry IS NOT NULL
				SET @table = @table  + '  AND trn.pCountry = '''+@rCountry+''''
			if @superAgentId IS NOT NULL
				SET @table = @table  + '  AND trn.pSuperAgent = '''+@superAgentId+''''
				
			IF @fromDate IS NOT NULL and @toDate IS NOT NULL
				SET @table = @table + ' AND trn.createdDate BETWEEN ''' + @fromDate +''' AND '''+ @toDate +' 23:59:59'''
			SET @table = @table + ' ) x '
			SET @select_field_list ='
					 id
					,holdTranId
					,controlNo
					,sAgent			
					,sBranchName			
					,sCountry
					,rAgent		
					,collMode				
					,rCountry			
					,ScOrderNo		
					,sender					
					,receiver
					,accountNo
					,amt
					,createdDate
					,createdBy
			   '

		PRINT @table				
		EXEC dbo.proc_paging
                @table
               ,null
               ,@select_field_list
               ,null
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber			
	
		RETURN
	END
	
	DECLARE @controlNoEnc VARCHAR(100)  = dbo.FNAencryptString(@controlNo)
	IF @flag IN ('a')
	BEGIN
		SELECT  
			 controlNo = dbo.FnaDecryptString(controlNo)
			,benefName = tr.firstName + ISNULL(' ' + tr.middleName,'') + ISNULL(' ' + tr.lastName1,'')
			,benefAdddress = tr.address
			,benefTel = tr.homePhone
			,benefMobile = tr.mobile
			,benefIdType = tr.idType
			,benefAccIdNo = tr.idNumber
			,senderName = ts.firstName + ISNULL(' ' + ts.middleName,'') + ISNULL(' ' + ts.lastName1,'')
			,senderAddress = ts.address
			,senderTel = ts.homePhone
			,senderMobile = ts.mobile
			,senderIdType = ts.idType
			,senderIdNo = ts.idNumber
			,purpose = rt.purposeOfRemit
			,remitType = rt.paymentMethod
			,rCurrency =rt.payoutCurr
			,localAmount = rt.tAmt
			,amount		= rt.pAmt
			,serviceCharge	= rt.serviceCharge
			,rCommission	= rt.pAgentComm
			,exchangeRate = rt.customerRate
			,refNo = rt.id
			,remarks = rt.pMessage
			,[source]  = rt.sourceOfFund
			,tranStatus = rt.tranStatus
			,payStatus = rt.payStatus
			,paidBy = rt.paidBy
			,paidDate = rt.paidDate
			,approvedDate = CONVERT(VARCHAR, rt.approvedDate, 101)
		FROM remitTran rt 
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		WHERE rt.controlNo = @controlNoEnc
	END

	IF @flag IN ('gbl-a')
	BEGIN
		SELECT  
			 controlNo = dbo.FnaDecryptString(controlNo)
			,benefName = tr.firstName + ISNULL(' ' + tr.middleName,'') + ISNULL(' ' + tr.lastName1,'')
			--,benefAdddress = tr.address
			--,benefTel = tr.homePhone
			--,benefMobile = tr.mobile
			--,benefIdType = tr.idType
			--,benefAccIdNo = tr.idNumber
			,senderName = ts.firstName + ISNULL(' ' + ts.middleName,'') + ISNULL(' ' + ts.lastName1,'')
			--,senderAddress = ts.address
			--,senderTel = ts.homePhone
			--,senderMobile = ts.mobile
			--,senderIdType = ts.idType
			--,senderIdNo = ts.idNumber
			--,purpose = rt.purposeOfRemit
			,remitType = rt.paymentMethod
			--,rCurrency =rt.payoutCurr
			,localAmount = rt.tAmt
			,amount		= rt.pAmt
			,serviceCharge	= rt.serviceCharge
			--,rCommission	= rt.pAgentComm
			,exchangeRate = rt.customerRate
			--,refNo = rt.id
			--,remarks = rt.pMessage
			--,[source]  = rt.sourceOfFund
			,tranStatus = rt.tranStatus
			,payStatus = rt.payStatus
			--,paidBy = rt.paidBy
			--,paidDate = rt.paidDate
			,approvedDate = CONVERT(VARCHAR, rt.approvedDate, 101)
		FROM remitTran rt 
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		WHERE rt.controlNo = @controlNoEnc
	END

	IF @flag = 'rpid'
	BEGIN
		--Check for authentication
		IF dbo.FNACheckWsAuthentication(@user, @pass, @agentCode) <> 0
		BEGIN
			SELECT id, holdTranId FROM remitTran WITH(NOLOCK) WHERE 1 = 2
			RETURN
		END

		UPDATE dbo.jobRunLog SET lastExecutionDate = GETDATE() WHERE jobName = 'Reprocess transaction'

		IF ISNULL(@count, 0) < 1 SET @count = 1

		--Get the list of transaction ids to process
		IF OBJECT_ID('tempdb..#tempTran') IS NOT NULL
			DROP TABLE #tempTran

		CREATE TABLE #tempTran(id BIGINT)

		INSERT INTO #tempTran(id)
		SELECT DISTINCT id FROM (
			SELECT TOP (50)
						 trn.id
					FROM remitTran trn WITH(READPAST)
					INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
					WHERE trn.approvedBy IS NOT NULL 
						AND trn.payStatus ='Unpaid' 
						AND trn.tranStatus = 'Payment'
						AND ISNULL(trn.lockStatus, 'unlocked') <> 'locked'
					ORDER BY trn.id ASC
				) x

		--Lock the transactions to make it unavailable for another process call
		UPDATE remitTran SET
			 lockStatus				= 'locked'
			,lockedBy				= 'system'
			,lockedDate				= GETDATE()
		FROM remitTran rt
		INNER JOIN #tempTran t ON rt.id = t.id

		DECLARE @currentDate DATETIME = GETDATE()
		
		DECLARE @txnCount INT = 0
		SELECT @txnCount = COUNT('X') FROM #tempTran
		IF @txnCount > 0
		BEGIN
			--Log with the number of transactions processed in a single batch run
			INSERT INTO reprocessScheduleRunLog(createdDate, txnCount, processName)
			SELECT @currentDate, txnCount = COUNT('X'), 'Process third party transaction' FROM #tempTran
		END

		--Return the list of transaction ids to be processed
		SELECT *, processId = SCOPE_IDENTITY() FROM #tempTran

		--dispose temp table
		IF OBJECT_ID('tempdb..#tempTran') IS NOT NULL
			DROP TABLE #tempTran
		RETURN
	END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
	SELECT ERROR_LINE()
END CATCH


GO
