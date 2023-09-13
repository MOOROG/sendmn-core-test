

ALTER PROC [dbo].[proc_cancelTranInt] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(100)	= NULL	
	,@agentId			INT				= NULL		
	,@cancelReason		VARCHAR(200)	= NULL
	,@scRefund			VARCHAR(50)		= NULL
	,@id				BIGINT			= NULL
	,@tranId			INT				= NULL	
	,@Branch			VARCHAR(200)	= NULL
	,@branchId			INT				= NULL
	,@createdBy			VARCHAR(100)	= NULL
	,@userType			VARCHAR(10)		= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE 
		 @select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)

	DECLARE 
	     @controlNoEncrypted VARCHAR(50)
		,@tranStatus VARCHAR(50)
		,@message	VARCHAR(MAX)
		,@serviceCharge	MONEY
		,@cAmt MONEY
		,@tAmt MONEY	
		,@txnSentBy VARCHAR(50)
		,@tranIdType VARCHAR(1)
		,@cancelReason1 VARCHAR(500)
		,@tellerBalance AS MONEY	
		,@DT1 DATETIME 
		,@sAgent1 INT
		,@payStatus varchar(20)
	DECLARE @TransStatusNep VARCHAR(20), @TransPayStatusNep VARCHAR(20),@msg VARCHAR(200)	
	DECLARE @moneySendTranStatus VARCHAR(50), @moneySendPayStatus VARCHAR(50), @remitTranStatus VARCHAR(50)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(LTRIM(RTRIM(@controlNo))))

	-->> SEARCH HOLD/UNPAID TRANSACTION - AGENT PANEL
	IF @flag = 'searchAgent'
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send cancel request.', NULL
			RETURN
		END	
		
		SELECT @agentId = agentId,@userType=userType
		FROM applicationUsers WITH(NOLOCK) WHERE userName = @user		
		
		IF @tranId IS NOT NULL
		BEGIN
				IF LEN(@tranId) = 8
					SELECT 
							 @tranStatus			= tranStatus
							,@tranId				= id 
							,@txnSentBy				= createdBy
							,@controlNoEncrypted	= controlNo
							,@sAgent1				= sAgent
							,@payStatus				= payStatus
					FROM vwRemitTran WITH(NOLOCK) WHERE ISNULL(CAST(holdTranId AS VARCHAR(50)),CAST(id AS VARCHAR(50))) = CAST(@tranId AS VARCHAR(50))
				ELSE
					SELECT 
							 @tranStatus			= tranStatus
							,@tranId				= id 
							,@txnSentBy				= createdBy
							,@controlNoEncrypted	= controlNo
							,@sAgent1				= sAgent
							,@payStatus				= payStatus
					FROM vwRemitTran WITH(NOLOCK) WHERE CAST(id AS VARCHAR(50)) = CAST(@tranId AS VARCHAR(50))
		END
		
		IF @controlNo IS NOT NULL
		BEGIN
			SELECT 
						 @tranStatus			= tranStatus
						,@tranId				= id 
						,@txnSentBy				= createdBy
						,@controlNoEncrypted	= controlNo
						,@sAgent1				= sAgent
						,@payStatus				= payStatus
			FROM vwRemitTran WITH(NOLOCK) WHERE controlNo =@controlNoEncrypted 
		END		
		
		IF (@tranStatus IS NOT NULL)
		BEGIN
			INSERT INTO tranViewHistory(
				 controlNumber
				,tranViewType
				,createdBy
				,createdDate
			)
			SELECT
				 @controlNoEncrypted
				,'C'
				,@user
				,GETDATE()
		END
		ELSE
		BEGIN		
			EXEC proc_errorHandler 1000, 'No Transaction Found', @controlNoEncrypted
			RETURN
		END
		
		IF NOT EXISTS(SELECT 'X' FROM vwRemitTran WITH(NOLOCK) 
				WHERE controlNo = @controlNoEncrypted AND sAgent = @sAgent1)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
			RETURN
		END
		
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END
		IF (@payStatus = 'Post')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been POST.', @controlNoEncrypted
			RETURN
		END
		IF (@payStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been Paid.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been Cancel Processing.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for modification.', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Lock')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Block')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is blocked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for cancellation', @controlNoEncrypted
			RETURN
		END
 
		IF EXISTS(SELECT 'x' FROM trancancelrequest WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND cancelStatus <> 'Rejected')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is already requested for cancel.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Already Paid transaction cannot be requested for cancellation', @controlNoEncrypted
			RETURN
		END
		
		SET @tranStatus = @tranStatus+'|'+dbo.FNADecryptString(@controlNoEncrypted)
		EXEC proc_errorHandler 0, 'Transaction Found', @tranStatus

	END	 

    -->> MAKE A REQUEST - AGENT PANEL
	ELSE IF @flag = 'request'
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send cancel request.', NULL
			RETURN
		END	
		
		SELECT  
			 @tranStatus			= tranStatus
			,@tranId				= id 
			,@txnSentBy				= createdBy
			,@controlNoEncrypted	= controlNo
			,@sAgent1				= sAgent
		FROM vwRemitTran WITH(NOLOCK) 
		WHERE controlNo = @controlNoEncrypted 
		
		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found.', @controlNoEncrypted
			RETURN
		END
		
		SELECT @agentId = agentId,@userType=userType
		FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		-->>checking if transaction is in authorisation mode 
		IF @agentId <> (SELECT dbo.FNAGetHOAgentId()) 
		BEGIN
			IF EXISTS(SELECT 'X' FROM vwRemitTran WITH(NOLOCK) 
								WHERE controlNo = @controlNoEncrypted AND sAgent <> @sAgent1)
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction is not in authorized mode.', @controlNoEncrypted
				RETURN
			END
		END
		
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been Cancel Processing.', @controlNoEncrypted
			RETURN
		END
		
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for modification.', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Lock')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Block')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is blocked. Please contact HO', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for cancellation', @controlNoEncrypted
			RETURN
		END
		BEGIN TRANSACTION

		IF EXISTS(SELECT 'X' FROM remitTranTemp WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
		BEGIN
			UPDATE remitTranTemp SET
				 tranStatus				= 'CancelRequest'				
				,cancelRequestBy		= @user
				,cancelRequestDate		= GETDATE()
				,cancelRequestDateLocal	= dbo.FNADateFormatTZ(GETDATE(), @user)
				,trnStatusBeforeCnlReq  = @tranStatus
			WHERE controlNo = @controlNoEncrypted
		END
		ELSE
		BEGIN
			UPDATE remitTran SET
				 tranStatus				= 'CancelRequest'				
				,cancelRequestBy		= @user
				,cancelRequestDate		= GETDATE()
				,cancelRequestDateLocal	= dbo.FNADateFormatTZ(GETDATE(), @user)
				,trnStatusBeforeCnlReq  = @tranStatus
			WHERE controlNo = @controlNoEncrypted
			DECLARE @DT DATETIME = GETDATE()
		END	
		INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,createdBy,createdDate,tranStatus)
		SELECT @tranId,@controlNoEncrypted,@cancelReason,'CancelRequest',@user,GETDATE(),@tranStatus
			
		--########### TO UPDATE THE STATUS IN INFICARE AND AC DB 

		
		SELECT @message = 'Transaction requested for Cancel. Reason : ''' + @cancelReason + ''''
		EXEC proc_transactionLogs @flag = 'i',@user = @user,@tranId = @tranId, 
				@message = @message, @msgType = 'Cancel Request', @controlNo = @controlNoEncrypted
			
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			
		EXEC proc_errorHandler 0, 'Transaction has been requested for cancel successfully', @controlNoEncrypted
	END
	
	-->> HOLD/UNPAID CANCEL REQUEST LIST
	ELSE IF @flag = 's1'
	BEGIN
		SET @sortBy     = 'createdDate'
		SET @sortOrder	= 'DESC'       
		SET @table = '(
					SELECT 
						 id = ISNULL(trn.holdTranId,trn.Id)
						,controlNo = dbo.FNADecryptString(trn.controlNo)
						,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')				
						,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,Branch = trn.sBranchName
						,cAmt 
						,pAmt
						,ServiceCharge
						,A.createdBy
						,requestedDate = convert(VARCHAR(20),A.createdDate,100)
						,A.scRefund
						,trnStatusBeforeCnlReq =  CASE WHEN trn.trnStatusBeforeCnlReq = ''Payment'' THEN ''Unpaid'' ELSE trn.trnStatusBeforeCnlReq END
						,trn.pCountry	
						,createdDate = A.createdDate				
					FROM vwRemitTran trn WITH(NOLOCK)
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.controlNo=trn.controlNo
					LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE trn.tranStatus = ''CancelRequest''
					and A.cancelStatus =''CancelRequest''
		'

		SET @sql_filter = ''				

		--SET @table  = @table + '  AND  A.tranStatus IN (''Hold'',''Payment'',''Compliance Hold'',''OFAC Hold'',''Compliance'',''OFAC'')'
		
		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 

		IF @id IS NOT NULL
			SET @table = @table + ' AND ISNULL(trn.holdTranId,trn.Id) = ''' + CAST(@id AS VARCHAR) + '''' 
				
		IF @Branch IS NOT NULL
			SET @table = @table + ' AND trn.sBranchName LIKE ''' + @Branch + '%'''
			
		IF @createdBy IS NOT NULL
			SET @table = @table + ' AND A.createdBy LIKE ''' + @createdBy + '%'''
		

		SET @select_field_list ='
					 id
					,controlNo
					,senderName
					,receiverName
					,Branch
					,cAmt
					,pAmt
					,ServiceCharge
					,createdBy
					,createdDate
					,scRefund
					,trnStatusBeforeCnlReq	
					,pCountry		
					,requestedDate
			   '
		SET @table = @table + ') x'
				
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
	
	-->> PAID/POST CANCEL REQUEST LIST
	ELSE IF @flag = 's2'
	BEGIN
		SET @sortBy     = 'createdDate'
		SET @sortOrder	= 'DESC'       
		SET @table = '(
					SELECT 
						 id = ISNULL(trn.holdTranId,trn.Id)
						,controlNo = dbo.FNADecryptString(trn.controlNo)
						,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')				
						,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,Branch = trn.sBranchName
						,cAmt 
						,pAmt
						,ServiceCharge
						,A.createdBy
						,requestedDate = convert(VARCHAR(20),A.createdDate,100)
						,A.scRefund
						,trnStatusBeforeCnlReq = CASE WHEN trn.trnStatusBeforeCnlReq = ''Payment'' THEN ''Unpaid'' ELSE trn.trnStatusBeforeCnlReq END						
						,A.createdDate	
						,trn.pCountry		
						,trn.pAgentName	
					FROM vwRemitTran trn WITH(NOLOCK)
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.controlNo=trn.controlNo
					LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE trn.tranStatus = ''CancelRequest'' 
					AND trn.payStatus in (''Post'',''Paid'')
					and A.cancelStatus =''CancelRequest''
		'

		SET @sql_filter = ''
	
		SET @table  = @table + '  AND  A.tranStatus IN (''POST'',''PAID'')'
		
		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 

		IF @id IS NOT NULL
			SET @table = @table + ' AND ISNULL(trn.holdTranId,trn.Id) = ''' + CAST(@id AS VARCHAR) + '''' 
				
		IF @Branch IS NOT NULL
			SET @table = @table + ' AND trn.sBranchName LIKE ''' + @Branch + '%'''
			
		IF @createdBy IS NOT NULL
			SET @table = @table + ' AND A.createdBy LIKE ''' + @createdBy + '%'''
			
		SET @select_field_list ='
					 id
					,controlNo
					,senderName
					,receiverName
					,Branch
					,cAmt
					,pAmt
					,ServiceCharge
					,createdBy
					,createdDate
					,scRefund
					,trnStatusBeforeCnlReq	
					,pCountry	
					,requestedDate	
					,pAgentName
			   '
		SET @table = @table + ') x'
				
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

	-->> HOLD/UNPAID CANCEL REQUEST LIST FOR REGIONAL
	ELSE IF @flag = 's3'
	BEGIN
			DECLARE @branchList AS VARCHAR(MAX)
			SET @branchList = '
			INNER JOIN ( 
				SELECT ' + CAST(@branchId AS VARCHAR) + ' agentId '
				
			IF @userType = 'RH'
			BEGIN
				SET @branchList = @branchList + '
								UNION ALL 	
								SELECT 
									 am.agentId 			
								FROM agentMaster am WITH(NOLOCK)
								INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
								WHERE rba.agentId = ' + CAST(@branchId AS VARCHAR) + '
								AND ISNULL(rba.isDeleted, ''N'') = ''N''
								AND ISNULL(rba.isActive, ''N'') = ''Y''
								AND memberAgentId <> ' + CAST(@branchId AS VARCHAR) + ''
			END
			IF @userType = 'AH'
			BEGIN
				SET @branchList = @branchList + '
								UNION ALL 	
								select agentId from agentMaster with(nolock) where parentId = 
								(select parentId from agentmaster with(nolock) where agentId=' + CAST(@branchId AS VARCHAR) + ')
								and agentId <> ' + CAST(@branchId AS VARCHAR) + ''
			END

			SET @branchList = @branchList + '			
				) bl ON trn.sBranch = bl.agentId			
				'

		SET @sortBy     = 'createdDate'
		SET @sortOrder	= 'DESC'       
		SET @table = '(
					SELECT 
						 id = ISNULL(trn.holdTranId,trn.Id)
						,controlNo = dbo.FNADecryptString(trn.controlNo)
						,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')				
						,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,Branch = trn.sBranchName
						,cAmt 
						,pAmt
						,ServiceCharge
						,A.createdBy
						,requestedDate = convert(VARCHAR(20),A.createdDate,100)
						,A.scRefund
						,trnStatusBeforeCnlReq = trn.trnStatusBeforeCnlReq 
						,trn.pCountry	
						,createdDate = A.createdDate				
					FROM vwRemitTran trn WITH(NOLOCK)
					' + @branchList + '	
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.controlNo=trn.controlNo
					LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE trn.tranStatus = ''CancelRequest'' AND trn.payStatus not in (''Post'',''Paid'')
					and A.cancelStatus =''CancelRequest''
		'

		SET @sql_filter = ''				

		SET @table  = @table + '  AND  A.tranStatus IN (''Hold'',''Compliance Hold'',''OFAC Hold'')'
		
		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 

		IF @id IS NOT NULL
			SET @table = @table + ' AND ISNULL(trn.holdTranId,trn.Id) = ''' + CAST(@id AS VARCHAR) + '''' 
				
		IF @Branch IS NOT NULL
			SET @table = @table + ' AND trn.sBranchName LIKE ''' + @Branch + '%'''
			
		IF @createdBy IS NOT NULL
			SET @table = @table + ' AND A.createdBy LIKE ''' + @createdBy + '%'''
			
		SET @select_field_list ='
					 id
					,controlNo
					,senderName
					,receiverName
					,Branch
					,cAmt
					,pAmt
					,ServiceCharge
					,createdBy
					,createdDate
					,scRefund
					,trnStatusBeforeCnlReq	
					,pCountry		
					,requestedDate
			   '
		SET @table = @table + ') x'
				
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
	
	-->> APPROVE CANCEL REQUEST TRANSACTION
	ELSE IF @flag='approve'
	BEGIN	
		DECLARE @pCountry VARCHAR(100), @isPaidTxn CHAR(1), @sCountryId INT, @sAgent INT, @sBranch INT, 
		@pCountryId INT, @pAgent INT, @bonusPoint INT,@canceledAmt money,@holdTranId bigint,@collMode varchar(15)
		SELECT 
			 @tranId			= a.id
			,@serviceCharge		= a.serviceCharge
			,@tAmt				= a.tAmt
			,@cAmt				= a.cAmt
			,@createdBy			= a.createdBy
			,@tranStatus		= b.tranStatus
			,@remitTranStatus	= a.tranStatus
			,@cancelReason1		= b.cancelReason
			,@pCountry			= a.pCountry
			,@isPaidTxn			= CASE WHEN (paidBy IS NOT NULL OR paidDate IS NOT NULL) THEN 'Y' ELSE 'N' END
			,@sCountryId		= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry)
			,@sAgent			= sAgent
			,@sBranch			= sBranch
			,@pCountryId		= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = pCountry)
			,@pAgent			= pAgent
			,@bonusPoint		= ISNULL(a.bonusPoint, 0)
			,@canceledAmt		= (a.cAmt - ISNULL(a.sAgentComm,0) - ISNULL(a.agentFxGain,0)) / (a.sCurrCostRate + ISNULL(a.sCurrHoMargin,0))
			,@agentId			= a.sAgent
			,@holdTranId		= a.holdTranId
			,@collMode			= a.collMode
		FROM vwRemitTran a WITH(NOLOCK)
		INNER JOIN tranCancelrequest b WITH(NOLOCK) ON a.controlNo = b.controlNo
		WHERE a.controlNo = @controlNoEncrypted AND b.approvedDate IS NULL AND b.cancelStatus='CancelRequest'
		
		DECLARE @customerId BIGINT
		SELECT @customerId = customerId FROM vwTranSenders WITH(NOLOCK) WHERE tranId = @tranId
		
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction', NULL
			RETURN
		END
		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for modification.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'Already Paid transaction cannot be requested for cancellation.', @controlNoEncrypted
			RETURN
		END


		IF (@tranStatus = 'Lock')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Block')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is blocked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF @cAmt IS NULL
			SET @cAmt=0

		BEGIN TRANSACTION
		
		-->> UPDATE CANCEL HISTORY TABLE
		UPDATE 
			 tranCancelrequest SET 
			 cancelStatus = 'Approved'
			,scRefund = CASE WHEN @scRefund ='Y' THEN ISNULL(@cAmt,0) ELSE ISNULL(@tAmt,0) END
			,approvedBy = @user
			,approvedDate = GETDATE()
			,approvedRemarks = @cancelReason
			,isScRefund	= @scRefund
		WHERE controlNo = @controlNoEncrypted AND cancelStatus='CancelRequest'

		-->> FOR API 
		IF @tranStatus NOT LIKE '%Hold%'
		BEGIN
			-->> UPDATE REMITTRAN				
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
			WHERE controlNo = @controlNoEncrypted

			--UPDATE FastMoneyPro_account.dbo.remit_trn_master SET
			--	 trn_status	= 'Cancel'
			--	,cancel_date	= GETDATE()
			--WHERE trn_ref_no = @controlNoEncrypted
			
			--UPDATE BRANCH/AGENT CREDIT LIMIT
			EXEC Proc_AgentBalanceUpdate_INT @flag = 'c',@tAmt = @cAmt ,@settlingAgent = @sAgent
		END
				
		IF @tranStatus LIKE '%HOLD%'
		BEGIN	
			-->> UPDATE REMITTRAN				
			UPDATE remitTranTemp SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
			WHERE controlNo = @controlNoEncrypted
			
			INSERT INTO cancelTranHistory(
				tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue
				--,sharingType
				,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate,cancelApprovedDateLocal
				,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,senderName,receiverName
			)
			SELECT 
				id,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue
				--,sharingType
				,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@cancelReason1,refund,cancelCharge,dbo.FNADateFormatTZ(GETDATE(), @user),GETDATE()
				,@user,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,senderName,receiverName
			 FROM remitTranTemp WHERE controlNo =  @controlNoEncrypted
			
			INSERT INTO cancelTranSendersHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer 
			FROM transenderstemp WITH(NOLOCK) WHERE tranId = @tranId
			
			INSERT INTO cancelTranReceiversHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress
			FROM tranReceiversTemp WITH(NOLOCK)	WHERE tranId = @tranId

			DELETE FROM remitTranTemp WHERE controlNo = @controlNoEncrypted
			DELETE FROM tranSendersTemp WHERE tranId = @tranId
			DELETE FROM tranReceiversTemp WHERE tranId = @tranId

				
			UPDATE creditLimitInt SET todaysSent = ISNULL(todaysSent,0) - @canceledAmt
			WHERE agentId=@sAgent
		END		

		SELECT @message = 'Transaction cancel has been done successfully.'
		--UPDATE balance
		DECLARE @referralCode VARCHAR(15),@sType CHAR(1),@isOnbehalf CHAR(1),@userId INT,@date1 DATETIME,@date2 DATETIME,@createDate DATETIME 
		
		SELECT	@createDate = RT.createdDate
				,@userId= AU.USERID
			    ,@referralCode = PROMOTIONCODE
				,@isOnbehalf = (CASE WHEN ISONBEHALF = '1' THEN 'Y' ELSE 'N' END)
	    FROM REMITTRAN RT (NOLOCK)
		INNER JOIN APPLICATIONUSERS AU (NOLOCK) ON AU.USERNAME = RT.CREATEDBY
		WHERE controlNo = @controlNoEncrypted

		--select @sAgent,@userId,@referralCode,@cAmt,@isOnbehalf

		select @date1 = convert(VARCHAR(10),getdate(),120)
		select @date2 = @date1 + '23:59:59'
		IF @createDate BETWEEN @date1 AND  @date2 AND @collMode = 'Cash Collect'
		BEGIN
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='CANCEL',@S_AGENT = @sAgent,@S_USER = @userId,@REFERRAL_CODE = @referralCode,@C_AMT = @cAmt,@ONBEHALF =@isOnbehalf
		END
		IF @collMode = 'Bank Deposit'
		BEGIN
			EXEC proc_UpdateCustomerBalance @controlNo=@controlNoEncrypted
		END

		EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Transaction Cancel Approved'	
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		EXEC [proc_errorHandler] 0, 'Transaction cancel has been done successfully', @tranId

		DECLARE @ref_num varchar(20)
		SELECT TOP 1  @ref_num = t.ref_num FROM FastMoneyPro_Account.dbo.tran_master t(NOLOCK)
		WHERE field1 = @controlNo AND t.tran_type = 'j' AND field2 = 'Remittance Voucher'

		-- Reverse Voucher Entry
		EXEC FastMoneyPro_Account.dbo.proc_CancelTranVoucher @flag = 'REVERSE',@refNum=@ref_num,@vType='J',@refund='N',@user=@user,@remarks=@cancelReason
	END
		
	-->> REJECT CANCEL REQUEST TRANSACTION
	ELSE IF @flag='reject'
	BEGIN		
		SELECT 
			  @tranStatus		= CASE WHEN tranStatus ='Post' THEN 'Payment' ELSE transtatus END
			 ,@tranId			= id	
			 		
		FROM tranCancelrequest WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction', NULL
			RETURN
		END

		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END
	    
		BEGIN TRANSACTION

		IF @tranStatus LIKE '%HOLD%'
		BEGIN
			UPDATE remitTranTemp SET
				  tranStatus				= @tranStatus
				 ,cancelRequestBy			= NULL
				 ,cancelRequestDate			= NULL
				 ,cancelRequestDateLocal	= NULL
			WHERE controlNo = @controlNoEncrypted
		END
		ELSE
		BEGIN
			UPDATE remitTran SET
				  tranStatus				= @tranStatus
				 ,cancelRequestBy			= NULL
				 ,cancelRequestDate			= NULL
				 ,cancelRequestDateLocal	= NULL
			WHERE controlNo = @controlNoEncrypted
		END
		
		UPDATE tranCancelrequest SET
			 cancelStatus			= 'Rejected'
			,approvedBy				= @user
			,approvedDate			= GETDATE()
			,approvedRemarks		= @cancelReason
		WHERE controlNo = @controlNoEncrypted

		SELECT @message = 'Transaction Cancel Request Rejected'
		
		EXEC proc_transactionLogs @flag = 'i',@user = @user,@tranId = @tranId, 
				@message = @message, @msgType = 'Transaction Cancel Rejected', @controlNo = @controlNoEncrypted
	
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	
		EXEC [proc_errorHandler] 0, 'Transaction Cancel Request Rejected Successfully', @tranId
	END
	
	-->> CANCEL RECEIPT 
	ELSE IF @flag = 'cancelReceipt'
	BEGIN
		SELECT @tranStatus = tranStatus FROM tranCancelrequest WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		
		IF @tranStatus LIKE  '%Hold%'
		BEGIN
			SELECT
				 controlNo = dbo.FNADecryptString(trn.controlNo)
				,sBranch = trn.sBranchName
				,sBranchId = trn.sBranch
				,createdBy	= trn.createdBy
				,sendDate = trn.createdDate
				,cancelAppDate = req.approvedDate
				,cancelReqDate = req.createdDate
				,cancelReqBy = req.createdBy
				,cancelReason = req.cancelReason
				,sender = sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
				,receiver = rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
				,rContactNo = rec.mobile
				,trn.collCurr
				,trn.cAmt
				,trn.serviceCharge
				,trn.pAmt
				,pCurr = trn.payoutCurr 
				,cancelCharge = ISNULL(trn.cancelCharge ,0)
				,returnAmt = req.scRefund
			FROM cancelTranHistory trn WITH(NOLOCK)
			INNER JOIN tranCancelrequest req WITH(NOLOCK) ON trn.tranId=req.tranId
			INNER JOIN cancelTranSendersHistory sen WITH(NOLOCK) ON trn.tranId = sen.tranId
			INNER JOIN cancelTranReceiversHistory rec WITH(NOLOCK) ON trn.tranId = rec.tranId
			WHERE trn.controlNo = @controlNoEncrypted
		
		END
		ELSE
		BEGIN
			SELECT
				 controlNo = dbo.FNADecryptString(trn.controlNo)
				,sBranch = trn.sBranchName
				,sBranchId = trn.sBranch
				,createdBy	= trn.createdBy
				,sendDate = trn.createdDate
				,cancelAppDate = req.approvedDate
				,cancelReqDate = req.createdDate
				,cancelReqBy = req.createdBy
				,cancelReason = req.cancelReason
				,sender = sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
				,receiver = rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
				,rContactNo = rec.mobile
				,trn.collCurr
				,trn.cAmt
				,trn.serviceCharge
				,trn.pAmt
				,pCurr = trn.payoutCurr 
				,cancelCharge = ISNULL(trn.cancelCharge ,0)
				,returnAmt = req.scRefund
			FROM remitTran trn WITH(NOLOCK)
			INNER JOIN tranCancelrequest req WITH(NOLOCK) ON trn.id=req.tranId
			INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
			INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
			WHERE trn.controlNo = @controlNoEncrypted			
		END
		
	END
	
	-->> CHECKING STATUS OF REQUEST
	ELSE IF(@flag='displayRequest')
	BEGIN
		SELECT  cancelReason
		FROM tranCancelrequest T WITH(NOLOCK) 
			 WHERE controlNo=@controlNoEncrypted AND approvedDate IS NULL
			 AND cancelStatus='CancelRequest'
	END
	
	-->> CANCEL REQUEST LIST - AGENT PANEL
	ELSE IF @flag = 'sAgentpending'
	BEGIN

		SELECT @userType = USERTYPE FROM applicationUsers WHERE userName =@user
		
		SET @table = '(
					SELECT						 
						 RT.sAgentName
						,RT.sBranchName
						,A.createdBy
						,controlNo = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'AgentPanel/Reports/SearchTransaction/TransactionDetail.aspx?searchBy=controlNo&searchValue='' + dbo.FNADecryptString(RT.controlNo)  + '''''')">'' + dbo.FNADecryptString(RT.co


ntrolNo) + ''</a>''
						,RT.cAmt							
						,CONVERT(VARCHAR,A.createdDate,101) createdDate
						,RT.sBranch
						,filterControlNo = dbo.FNADecryptString(RT.controlNo)
						FROM vwRemitTran RT WITH(NOLOCK)
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.controlNo=RT.controlNo
					WHERE RT.tranStatus = ''CancelRequest'' 
						) x'
		
		SET @sql_filter = ''
		IF @controlNo IS NOT NULL
			SET @sql_filter = @sql_filter+ ' AND  filterControlNo ='''+@controlNo+''''
			
		IF @branchId IS NOT NULL
			SET @sql_filter = @sql_filter+ ' AND  sBranch ='''+CAST(@branchId AS VARCHAR)+''''
			
		IF @createdBy IS  NOT NULL
			SET @sql_filter= @sql_filter + ' AND createdBy='''+@createdBy+''''
		 
		SET @select_field_list ='
			 sAgentName
			,sBranchName
			,createdBy
			,controlNo
			,cAmt
			,createdDate
			,filterControlNo
			'
					   
		EXEC dbo.proc_paging
			@table
		   ,@sql_filter
		   ,@select_field_list
		   ,''
		   ,@sortBy
		   ,@sortOrder
		   ,@pageSize
			
	END

	-->> MAKE CANCEL TRANSACTION - ADMIN PANEL
	ELSE IF @flag = 'cancelTxnAdmin'
	BEGIN		
		SELECT 
			 @tranId			= a.id
			,@serviceCharge		= a.serviceCharge
			,@tAmt				= a.tAmt
			,@cAmt				= a.cAmt
			,@createdBy			= a.createdBy
			,@tranStatus		= a.tranStatus
			,@pCountry			= a.pCountry
			,@branchId			= a.sBranch
			,@isPaidTxn			= CASE WHEN (paidBy IS NOT NULL OR paidDate IS NOT NULL) THEN 'Y' ELSE 'N' END
			,@sCountryId		= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry)
			,@sAgent			= sAgent
			,@sBranch			= sBranch
			,@pCountryId		= (SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = pCountry)
			,@pAgent			= pAgent
			,@bonusPoint		= ISNULL(a.bonusPoint, 0)
			,@canceledAmt		= (a.cAmt - ISNULL(a.sAgentComm,0) - ISNULL(a.agentFxGain,0)) / (a.sCurrCostRate + ISNULL(a.sCurrHoMargin,0))
		FROM vwRemitTran a WITH(NOLOCK) 
		WHERE a.controlNo = @controlNoEncrypted 
			
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction.', NULL
			RETURN
		END
		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found.', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for modification.', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Lock')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Block')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is blocked. Please contact HO', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has already been requested for cancellation', @controlNoEncrypted
			RETURN
		END

		IF EXISTS(SELECT 'x' FROM trancancelrequest WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND cancelStatus <> 'Rejected')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is already requested for cancel.', @controlNoEncrypted
			RETURN
		END
		BEGIN TRANSACTION
		
		INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,
				createdBy,createdDate,tranStatus,approvedBy,approvedDate,scRefund,isScRefund)
		SELECT @tranId,@controlNoEncrypted,@cancelReason,'Approved',@user,GETDATE(),@tranStatus,@user,GETDATE(),
		CASE WHEN @scRefund ='Y' THEN @cAmt ELSE @tAmt END,@scRefund
		
		IF @tranStatus NOT LIKE '%HOLD%'
		BEGIN			
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'
				 ,cancelRequestBy			= @user
				 ,cancelRequestDate			= GETDATE()
				 ,cancelRequestDateLocal	= dbo.FNADateFormatTZ(GETDATE(), @user)
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
				 ,trnStatusBeforeCnlReq		= @tranStatus
			WHERE controlNo = @controlNoEncrypted
			IF EXISTS (SELECT 'X' FROM remitTran WITH(NOLOCK) 
					WHERE controlNo = @controlNoEncrypted 
						AND createdDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101) + ' 23:59:59')
			BEGIN
				UPDATE creditLimitInt SET 
					todaysCancelled = ISNULL(todaysCancelled,0) + @canceledAmt
				WHERE agentId = @sAgent
			END
		END
				
		IF @tranStatus LIKE '%HOLD%'
		BEGIN	
			-->> UPDATE REMITTRAN				
			UPDATE remitTranTemp SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
				 ,cancelRequestBy			= @user
				 ,cancelRequestDate			= GETDATE()
				 ,cancelRequestDateLocal	= dbo.FNADateFormatTZ(GETDATE(), @user)
				 ,trnStatusBeforeCnlReq		= @tranStatus
			WHERE controlNo = @controlNoEncrypted
			
			INSERT INTO cancelTranHistory(
				tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate,cancelApprovedDateLocal
				,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,trnStatusBeforeCnlReq,senderName,receiverName
			)
			SELECT 
				id,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@cancelReason1,refund,cancelCharge,GETDATE(),dbo.FNADateFormatTZ(GETDATE(), @user)
				,@user,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,trnStatusBeforeCnlReq,senderName,receiverName
			 FROM remitTranTemp WHERE controlNo =  @controlNoEncrypted
			
			INSERT INTO cancelTranSendersHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer 
			FROM transenderstemp WITH(NOLOCK) WHERE tranId = @tranId
			
			INSERT INTO cancelTranReceiversHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress
			FROM tranReceiversTemp WITH(NOLOCK)	WHERE tranId = @tranId

			IF EXISTS (SELECT 'X' FROM remitTranTemp WITH(NOLOCK) 
					WHERE id = @tranId 
						AND createdDate BETWEEN CONVERT(VARCHAR,GETDATE(),101) AND CONVERT(VARCHAR,GETDATE(),101) + ' 23:59:59')
			BEGIN
				UPDATE creditLimitInt SET todaysSent = ISNULL(todaysSent,0) - @canceledAmt
				WHERE agentId=@sAgent
			END

			DELETE FROM remitTranTemp WHERE controlNo = @controlNoEncrypted
			DELETE FROM tranSendersTemp WHERE tranId = @tranId
			DELETE FROM tranReceiversTemp WHERE tranId = @tranId			
			SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName=@createdBy			
		END
		
		IF @isPaidTxn = 'N'
		BEGIN
			UPDATE customers SET
				 bonusPointPending = ISNULL(bonusPointPending, 0) - @bonusPoint
				,bonusTxnCount		= ISNULL(bonusTxnCount, 0) - 1
				,bonusTxnAmount		= ISNULL(bonusTxnAmount, 0) - @cAmt
			WHERE customerId = @customerId
		END
		ELSE IF @isPaidTxn = 'Y'
		BEGIN
			UPDATE customers SET
				 bonusPoint			= ISNULL(bonusPoint, 0) - @bonusPoint
				,bonusTxnCount		= ISNULL(bonusTxnCount, 0) - 1
				,bonusTxnAmount		= ISNULL(bonusTxnAmount, 0) - @cAmt
			WHERE customerId = @customerId
		END
		
		SELECT @message = 'Transaction cancel has been done successfully.'
		EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Transaction Cancel Approved'	
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	
		EXEC [proc_errorHandler] 0, 'Transaction cancel has been done successfully', @tranId
	END

