USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cancelTranRsp]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_cancelTranRsp] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(100)	= NULL	
	,@agentId			INT				= NULL		
	,@cancelReason		VARCHAR(200)	= NULL
	,@scRefund			VARCHAR(50)		= NULL
	,@tranId			INT				= NULL	
	,@Branch			VARCHAR(200)	= NULL
	,@branchId			INT				= NULL
	,@createdBy			VARCHAR(100)	= NULL
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
	SELECT @pageSize = 1000, @pageNumber = 1
	DECLARE 
	     @controlNoEncrypted VARCHAR(50)
		,@tranStatus VARCHAR(50)
		,@message	VARCHAR(MAX)
		,@serviceCharge	MONEY
		,@cAmt MONEY
		,@tAmt MONEY
		,@userType VARCHAR(2)	
		,@txnSentBy VARCHAR(50)
		,@tranIdType VARCHAR(1)
		,@cancelReason1 VARCHAR(500)
		,@tellerBalance AS MONEY	
		,@DT1 DATETIME 
		,@irhRefund MONEY
	
	DECLARE @TransStatusNep VARCHAR(20), @TransPayStatusNep VARCHAR(20),@msg VARCHAR(200)
	DECLARE @moneySendTranStatus VARCHAR(50), @moneySendPayStatus VARCHAR(50), @remitTranStatus VARCHAR(50)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(LTRIM(RTRIM(@controlNo))))
	
	DECLARE @DT DATETIME = GETDATE()
	
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
					FROM vwRemitTran WITH(NOLOCK) WHERE ISNULL(CAST(holdTranId AS VARCHAR(50)),CAST(id AS VARCHAR(50))) = CAST(@tranId AS VARCHAR(50))
				ELSE
					SELECT 
							 @tranStatus			= tranStatus
							,@tranId				= id 
							,@txnSentBy				= createdBy
							,@controlNoEncrypted	= controlNo
					FROM vwRemitTran WITH(NOLOCK) WHERE CAST(id AS VARCHAR(50)) = CAST(@tranId AS VARCHAR(50))
		END
		
		IF @controlNo IS NOT NULL
		BEGIN
			SELECT 
						 @tranStatus			= tranStatus
						,@tranId				= id 
						,@txnSentBy				= createdBy
						,@controlNoEncrypted	= controlNo
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
				WHERE controlNo = @controlNoEncrypted AND sBranch = @agentId)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
			RETURN
		END
		
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been Cancel Processing.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been requested for modification.', @controlNoEncrypted
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
		
		IF EXISTS(SELECT 'X' FROM trancancelrequest WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND cancelStatus <> 'Rejected')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is already requested for cancel.', @controlNoEncrypted
			RETURN
		END
		
		SET @tranStatus = @tranStatus+'|'+dbo.FNADecryptString(@controlNoEncrypted)
		EXEC proc_errorHandler 0, 'Transaction Found', @tranStatus

	END	

	ELSE IF @flag = 'request'
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send cancel request.', NULL
			RETURN
		END	
		
		SELECT  
			 @tranStatus			= CASE WHEN payStatus='Post' THEN 'Post' WHEN paystatus ='Paid' THEN 'Paid' ELSE tranStatus END
			,@tranId				= id 
			,@txnSentBy				= createdBy
			,@controlNoEncrypted	= controlNo
		FROM vwRemitTran WITH(NOLOCK) 
		WHERE controlNo = @controlNoEncrypted 
		
		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found.', @controlNoEncrypted
			RETURN
		END
		
		SELECT @agentId = agentId,@userType=userType
		FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		IF @agentId <> (SELECT dbo.FNAGetHOAgentId()) 
		BEGIN
			IF EXISTS(SELECT 'X' FROM vwRemitTran WITH(NOLOCK) 
								WHERE controlNo = @controlNoEncrypted AND sBranch <> @agentId)
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction is not in authorized mode.', @controlNoEncrypted
				RETURN
			END
		END
		
		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been Cancel Processing.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been requested for modification.', @controlNoEncrypted
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

	ELSE IF @flag = 's'-->> List Payament Transaction Cancel Request
	BEGIN
	
		SET @table = '(
					SELECT 
						 id				= ISNULL(trn.holdTranId,trn.Id)
						,controlNo		= dbo.FNADecryptString(trn.controlNo)
						,senderName		= sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')				
						,receiverName	= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,Branch			= trn.sBranchName
						,cAmt 
						,pAmt
						,ServiceCharge
						,A.createdBy
						,A.createdDate
						,A.scRefund
					FROM vwRemitTran trn WITH(NOLOCK)
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.tranId=trn.id
					LEFT JOIN vwtranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN vwtranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE trn.tranStatus = ''CancelRequest'' AND ISNULL(A.tranStatus,'''')<>''Hold''
		'
		SET @sql_filter = ''
		
		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
			
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
	
	ELSE IF @flag = 's1'-->> List Unapproved Transaction Cancel Request
	BEGIN
		SELECT @userType = USERTYPE FROM applicationUsers WITH(NOLOCK) WHERE userName =@user
		
		SET @table = '(
					SELECT 
						 id				= ISNULL(trn.holdTranId,trn.Id)
						,controlNo		= dbo.FNADecryptString(trn.controlNo)
						,senderName		= sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')				
						,receiverName	= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,Branch			= trn.sBranchName
						,cAmt 
						,pAmt
						,ServiceCharge
						,A.createdBy
						,A.createdDate
						,A.scRefund
						,trn.trnStatusBeforeCnlReq
					FROM vwRemitTran trn WITH(NOLOCK)
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.controlNo=trn.controlNo
					LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE trn.tranStatus = ''CancelRequest'' 
		'
		
		SET @sql_filter = ''
		IF @userType IS NULL
			SET @table  = @table + '  AND  1 = 2'
				
		IF @userType <>'HO'
			SET @table  = @table + '  AND  A.tranStatus=''Hold'''
		
		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 

		IF @tranId IS NOT NULL
			SET @table = @table + ' AND trn.id = ''' + CAST(@tranId AS VARCHAR) + '''' 
				
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
	
	ELSE IF @flag = 's1Agent'-->> List Unapproved Transaction Cancel Request FOR AGENT PANEL
	BEGIN
		SELECT @userType = USERTYPE FROM applicationUsers WITH(NOLOCK) WHERE userName =@user
		
		SET @table = '(
					SELECT 
						 id				= ISNULL(trn.holdTranId,trn.Id)
						,controlNo		= dbo.FNADecryptString(trn.controlNo)
						,senderName		= sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')				
						,receiverName	= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
						,Branch			= trn.sBranchName
						,cAmt 
						,pAmt
						,ServiceCharge
						,A.createdBy
						,A.createdDate
						,A.scRefund
					FROM remitTran trn WITH(NOLOCK)
					INNER JOIN tranCancelrequest A WITH(NOLOCK) ON A.tranId=trn.id
					LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
					LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
					WHERE trn.tranStatus = ''CancelRequest''  AND  A.tranStatus=''Hold''
		'

		SET @sql_filter = ''
		IF @userType NOT IN ('HO','RH')
			SET @table  = @table + '  AND  1 = 2'
		
		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
			
		IF @Branch IS NOT NULL
			SET @table = @table + ' AND trn.sBranchName LIKE ''' + @Branch + '%'''
			
		IF @createdBy IS NOT NULL
			SET @table = @table + ' AND A.createdBy LIKE ''' + @createdBy + '%'''
		
		IF @userType = 'RH'
		BEGIN
		SET @table  = @table +' AND A.createdBy IN( SELECT userName 
							FROM applicationUsers WHERE agentId IN (
								SELECT am.agentId 
										 FROM agentMaster am WITH(NOLOCK)
										 LEFT JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
										 WHERE (rba.agentId = '''+CAST(@agentid AS VARCHAR)+''' AND 
										 ISNULL(rba.isDeleted, ''N'') = ''N''
										 AND ISNULL(rba.isActive, ''N'') = ''Y'')
									OR  am.agentId = '''+CAST(@agentid AS VARCHAR)+'''	
								) AND userName <>  '''+@user+'''
							)'
		END
			
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
	
	ELSE IF @flag = 'approve'
	BEGIN	
		DECLARE @holdTranId BIGINT
		DECLARE @pCountry VARCHAR(100)
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction', NULL
			RETURN
		END

		SELECT 
			 @tranId		= a.id,
			 @serviceCharge	= a.serviceCharge,
			 @tAmt			= a.tAmt,
			 @cAmt			= a.cAmt,
			 @createdBy		= a.createdBy,
			 @tranStatus	= b.tranStatus,
			 @remitTranStatus = a.tranStatus,
			 @cancelReason1	= b.cancelReason,
			 @agentId		= a.sAgent,
			 @holdTranId	= a.holdTranId,
			 @irhRefund		= ISNULL(a.cAmt,0) - ISNULL(a.sAgentComm,0) - ISNULL(agentFxGain,0),
			 @pCountry		= a.pCountry
		FROM vwRemitTran a WITH(NOLOCK) 
		INNER JOIN tranCancelrequest b WITH(NOLOCK) ON a.controlNo=b.controlNo
		WHERE a.controlNo = @controlNoEncrypted AND b.approvedDate IS NULL
			

		IF (@tranStatus IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction not found', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'Cancel')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled', @controlNoEncrypted
			RETURN
		END

		IF (@tranStatus = 'CANCELLED')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Cancel Processing')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'ModificationRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been requested for modification.', @controlNoEncrypted
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
				
		BEGIN TRANSACTION
		
		-->> UPDATE CANCEL HISTORY TABLE
		UPDATE 
			 tranCancelrequest SET 
			 cancelStatus		= 'Approved'
			,scRefund			= @irhRefund
			,approvedBy			= @user
			,approvedDate		= GETDATE()
			,approvedRemarks	= @cancelReason
			,isScRefund			= @scRefund
		WHERE controlNo	= @controlNoEncrypted
		
		-->> FOR API 
		IF @tranStatus NOT LIKE '%HOLD%' OR @holdTranId IS NULL
		BEGIN
			-->> UPDATE REMITTRAN				
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
			WHERE controlNo = @controlNoEncrypted
		

			UPDATE creditLimit SET todaysCancelled = ISNULL(todaysCancelled,0) + @irhRefund
			WHERE agentId=@agentId
		END
				
		IF @tranStatus LIKE '%HOLD%' AND @holdTranId IS NOT NULL
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
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@cancelReason1,refund,cancelCharge,GETDATE(),GETDATE()
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

			DELETE FROM remitTranTemp WHERE controlNo = @controlNoEncrypted
			DELETE FROM tranSendersTemp WHERE tranId = @tranId
			DELETE FROM tranReceiversTemp WHERE tranId = @tranId	   
			
			UPDATE creditLimit SET todaysSent = ISNULL(todaysSent,0) - @irhRefund
			WHERE agentId=@agentId
		END
		
		SELECT @message = 'Transaction Cancel Request Approved'
		EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Transaction Cancel Approved'	
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	
		EXEC [proc_errorHandler] 0, 'Transaction Cancel Request Approved successfully', @tranId
		
	END
		
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
			EXEC proc_errorHandler 1, 'Transaction already been cancelled', @controlNoEncrypted
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
	
	ELSE IF(@flag='displayRequest')
	BEGIN
		SELECT  cancelReason
		FROM tranCancelrequest T WITH(NOLOCK) 
			 WHERE controlNo=@controlNoEncrypted AND approvedDate IS NULL
			 AND cancelStatus='CancelRequest'
	END
	
	ELSE IF @flag = 'sAgentpending'-->> List Unapproved Transaction Cancel Request (Agent Panel)
	BEGIN

		SELECT @userType = USERTYPE FROM applicationUsers WHERE userName =@user
		
		SET @table = '(
					SELECT						 
						 RT.sAgentName
						,RT.sBranchName
						,A.createdBy
						,controlNo = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'AgentPanel/Reports/SearchTransaction/TransactionDetail.aspx?searchBy=controlNo&searchValue='' + dbo.FNADecryptString(RT.controlNo)  + '''''')">'' + dbo.FNADecryptString(RT.controlNo) + ''</a>''
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
	
	IF @flag = 'radioButton' 
	BEGIN
			SELECT 'hold' VALUE,'HOLD' textValue
			UNION ALL
			SELECT 'paid' VALUE, 'PAID' textValue
			UNION ALL
			SELECT 'confirm' VALUE, 'CONFIRM' textValue
	END	
	
	ELSE IF @flag = 'cancelTxnAdmin'
	BEGIN		
		SELECT 
			 @tranId		= ISNULL(a.holdTranId,a.id),
			 @serviceCharge	= a.serviceCharge,
			 @tAmt			= a.tAmt,
			 @cAmt			= a.cAmt,
			 @createdBy		= a.createdBy,
			 @tranStatus	= a.tranStatus,
			 @irhRefund		= ISNULL(a.cAmt,0) - ISNULL(a.sAgentComm,0) - ISNULL(agentFxGain,0),
			 @agentId		= a.sAgent,
			 @pCountry		= a.pCountry
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
			EXEC proc_errorHandler 1, 'Transaction already been cancelled.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction already been cancel request.', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Block')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is blocked.', @controlNoEncrypted
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
		
		IF @tranStatus IN ('Payment','Paid')
		BEGIN			
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'
				 ,cancelRequestBy			= @user
				 ,cancelRequestDate			= GETDATE()
				 ,cancelRequestDateLocal	= GETDATE()
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
				 ,trnStatusBeforeCnlReq		= @tranStatus
			WHERE controlNo = @controlNoEncrypted
			
			SET @DT1 = GETDATE()
						
			UPDATE creditLimit SET todaysCancelled = ISNULL(todaysCancelled,0)+ @irhRefund
			WHERE agentId=@agentId

		END
				
		IF @tranStatus LIKE '%HOLD%'
		BEGIN				
			UPDATE remitTranTemp SET
				  tranStatus				= 'Cancel'
				 ,cancelApprovedBy			= @user
				 ,cancelApprovedDate		= GETDATE()
				 ,cancelApprovedDateLocal	= GETDATE()
				 ,cancelRequestBy			= @user
				 ,cancelRequestDate			= GETDATE()
				 ,cancelRequestDateLocal	= GETDATE()
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
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@cancelReason1,refund,cancelCharge,GETDATE(),GETDATE()
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

			DELETE FROM remitTranTemp WHERE controlNo = @controlNoEncrypted
			DELETE FROM tranSendersTemp WHERE tranId = @tranId
			DELETE FROM tranReceiversTemp WHERE tranId = @tranId	 
			
			UPDATE creditLimit SET todaysSent = ISNULL(todaysSent,0) - @irhRefund
			WHERE agentId=@agentId
			  
			
		END
		
		SELECT @message = 'Transaction cancel has been done successfully.'
		EXEC proc_transactionLogs 'i', @user, @tranId, @message, 'Transaction Cancel Approved'	
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
	
		EXEC [proc_errorHandler] 0, 'Transaction cancel has been done successfully', @tranId
		
	END
		



GO
