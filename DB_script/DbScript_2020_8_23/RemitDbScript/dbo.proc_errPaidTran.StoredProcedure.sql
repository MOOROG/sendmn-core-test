ALTER  PROC [dbo].[proc_errPaidTran]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(200)	= NULL
	,@controlNo							VARCHAR(100)	= NULL
	,@rowId								INT 			= NULL
	,@eptId								INT				= NULL
	,@tranId							INT				= NULL
	,@newPBranch						INT      		= NULL
	,@narration							VARCHAR(200)  	= NULL 
	,@rIdType							VARCHAR(100)   	= NULL
	,@rIdNo								VARCHAR(30)    	= NULL
	,@expiryType						CHAR(1)    		= NULL 
	,@issueDate							DATETIME    	= NULL
	,@validDate							DATETIME    	= NULL
	,@placeOfIssue						VARCHAR(100)   	= NULL
	,@mobileNo							VARCHAR(20)    	= NULL
	,@rRelativeType						VARCHAR(100)   	= NULL
	,@rRelativeName						VARCHAR(100)   	= NULL
	,@payRemarks						VARCHAR(MAX)	= NULL
	,@newDeliveryMethod					VARCHAR(100)	= NULL
	,@hasChanged						VARCHAR(1)		= NULL
	,@createdDate						VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@sortBy							VARCHAR(20)		= NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON


DECLARE @controlNoEncrypted VARCHAR(20)

	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	IF @tranId IS NULL
		SELECT @tranId=id FROM remitTran WITH(NOLOCK) WHERE controlNo=@controlNoEncrypted
	IF @rowId IS NULL
		SET @rowId=@eptId
		
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@module				VARCHAR(10)
		,@tableAlias			VARCHAR(100)
		,@logIdentifier			VARCHAR(50)
		,@logParamMod			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)		
		,@id					VARCHAR(10)
		,@modType				VARCHAR(6)
		,@ApprovedFunctionId	INT
		,@tranAmount			MONEY
		,@agentId				INT
		,@oldPBranch			INT
		,@oldPBranchName		VARCHAR(500)
		,@newPBranchName		VARCHAR(500)
		,@newPaidDate			VARCHAR(50)
		,@oldPaidDate			VARCHAR(50)
		,@MESSAGE				VARCHAR(MAX)
		,@oldSettlingAgent		INT
		,@newSettlingAgent		INT
		,@parentId				INT
	
	DECLARE 
		 @agentType					INT
		,@pBranch					INT
		,@pBranchName				VARCHAR(100)
		,@pAgent					INT
		,@pAgentName				VARCHAR(100)
		,@pSuperAgent				INT
		,@pSuperAgentName			VARCHAR(100)
		,@deliveryMethod			VARCHAR(100)
		,@deliveryMethodId			INT
		,@pLocation					INT
		,@pState					VARCHAR(50)
		,@pDistrict					VARCHAR(50)
		,@tAmt						MONEY
		,@cAmt						MONEY
		,@pAmt						MONEY
		,@payoutCurr				VARCHAR(3)
		,@serviceCharge				MONEY
		,@pCountry					VARCHAR(100)
		,@pCountryId				INT
		,@sBranch					INT
		,@sCountry					VARCHAR(100)
		,@sLocation					INT
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@pHubComm					MONEY
		,@pHubCommCurrency			VARCHAR(3)
		,@settlingAgent				INT
			
	SELECT
		 @ApprovedFunctionId = 20141130
		,@logIdentifier = 'eptId'
		,@logParamMain = 'errPaidTran'
		,@logParamMod = 'errPaidTranHistory'
		,@module = '20'
		,@tableAlias = 'Erroneously Paid Txn'
	
	SELECT @newPBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@newPBranch
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE tranId = @tranId  AND ISNULL(isDeleted,'N') = 'N')
		BEGIN
			 EXEC proc_errorHandler 1, 'Record (EP) already exists or recorded.', @tranId
			 RETURN;
		END
		SELECT @oldPBranch = pBranch, @pLocation = pLocation FROM remitTran  WITH(NOLOCK) WHERE id = @tranId
		DECLARE @districtId INT, @newAgentDistrictId INT
		
		
		SELECT @districtId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @pLocation
		
		SELECT @newAgentDistrictId = districtId FROM zoneDistrictMap WITH(NOLOCK)
		WHERE districtName = (SELECT agentDistrict FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch)
		
		IF RIGHT(@controlNo, 1) = 'D'
		BEGIN
			IF @districtId <> @newAgentDistrictId
			BEGIN
				EXEC proc_errorHandler 1, 'This agent is not allowed to pay this transaction. Transaction is not within this agent district', NULL
				RETURN
			END
		END
		--Find Old Settling Agent
		SELECT @oldSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @oldPBranch AND ISNULL(isSettlingAgent, 'N') = 'Y'
		IF @oldSettlingAgent IS NULL
		BEGIN
			SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @oldPBranch
			SELECT @oldSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
		END
		IF @oldSettlingAgent IS NULL
		BEGIN
			SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId
			SELECT @oldSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
		END
		--Find New Settling Agent
		SELECT @newSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch AND ISNULL(isSettlingAgent, 'N') = 'Y'
		IF @newSettlingAgent IS NULL
		BEGIN
			SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch
			SELECT @newSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
		END
		IF @newSettlingAgent IS NULL
		BEGIN
			SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId
			SELECT @newSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
		END
			
		IF @oldPBranch = @newPBranch
		BEGIN
			 EXEC proc_errorHandler 1, 'Sorry, You can not choose same old branch!', @tranId
			 RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS(SELECT TOP 1 'X' FROM errPaidTran WHERE tranId = @tranId AND tranStatus='Paid')
			BEGIN
				INSERT INTO errPaidTran (
					 tranId
					,oldSettlingAgent
					,oldPBranch
					,oldPBranchName
					,oldPSuperAgentComm
					,oldPSuperAgentCommCurrency
					,oldPAgentComm
					,oldPAgentCommCurrency
					,oldPaidDate 
					,newSettlingAgent
					,newPBranch
					,newPBranchName
					,payoutAmt
					,narration					
					,createdBy
					,createdDate
					,tranStatus
				)
				SELECT TOP 1 tranId,newSettlingAgent,newPBranch,newPBranchName,newPSuperAgentComm,newPSuperAgentCommCurrency,newPAgentComm,newPAgentCommCurrency,newPaidDate,
				@newSettlingAgent,@newPBranch,@newPBranchName,payoutAmt,@narration,@user,GETDATE(),'Unpaid' 
				FROM errPaidTran WHERE tranId=@tranId AND tranStatus='Paid'
				ORDER BY eptId DESC
				
				SET @rowId = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				INSERT INTO errPaidTran (
					 tranId
					,oldSettlingAgent
					,oldPBranch
					,oldPBranchName
					,oldPSuperAgentComm
					,oldPSuperAgentCommCurrency
					,oldPAgentComm
					,oldPAgentCommCurrency
					,oldPaidDate 
					,newSettlingAgent
					,newPBranch
					,newPBranchName
					,payoutAmt
					,narration					
					,createdBy
					,createdDate
					,tranStatus
				)
				SELECT id,@oldSettlingAgent,pBranch,pBranchName,pSuperAgentComm,pSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,paidDate,
				@newSettlingAgent,@newPBranch,@newPBranchName,pAmt,@narration,@user,GETDATE(),'Unpaid' 
				FROM remitTran WHERE id=@tranId
				SET @rowId = SCOPE_IDENTITY()
			END
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END	
	IF @flag = 'u'
    BEGIN
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record.', @rowId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND tranStatus	='Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify, Already paid this record', @rowId
			RETURN
		END 
		
		SELECT @tranId = tranId FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId
		SELECT @pLocation = plocation FROM remitTran WITH(NOLOCK) WHERE id = @tranId
		SELECT @districtId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @pLocation
		SELECT @newAgentDistrictId = districtId FROM zoneDistrictMap WITH(NOLOCK)
		WHERE districtName = (SELECT agentDistrict FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch)
		IF @districtId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Location not found', NULL
			RETURN
		END
		IF @newAgentDistrictId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Location not found', NULL
			RETURN
		END
		IF @districtId <> @newAgentDistrictId
		BEGIN
			EXEC proc_errorHandler 1, 'This agent is not allowed to pay this transaction. Transaction is not within this agent district', NULL
			RETURN
		END
		
		--Find New Settling Agent
		SELECT @newSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch AND ISNULL(isSettlingAgent, 'N') = 'Y'
		IF @newSettlingAgent IS NULL
		BEGIN
			SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch
			SELECT @newSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
		END
		IF @newSettlingAgent IS NULL
		BEGIN
			SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId
			SELECT @newSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
		END
        BEGIN TRANSACTION
            IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user)
            BEGIN					
				UPDATE main SET 
					 main.tranId						= trn.id
					,main.oldPBranch					= trn.pBranch
					,main.oldPBranchName				= trn.pBranchName
					,main.oldPSuperAgentComm			= trn.pSuperAgentComm
					,main.oldPSuperAgentCommCurrency	= trn.pSuperAgentCommCurrency
					,main.oldPAgentComm					= trn.pAgentComm
					,main.oldPAgentCommCurrency			= trn.pAgentCommCurrency
					,main.oldPaidDate					= trn.paidDate
					,main.newSettlingAgent				= @newSettlingAgent
					,main.newPBranch					= @newPBranch
					,main.newPBranchName				= @newPBranchName
					,main.payoutAmt						= trn.pAmt
					,main.narration						= @narration	 			
					,main.createdBy						= @user
					,main.createdDate					= GETDATE()
					,main.tranStatus					= 'Unpaid'
				FROM errPaidTran main
				INNER JOIN remitTran trn ON trn.id= main.tranId
				WHERE main.eptId= @rowId
					
			END 
			ELSE
			BEGIN	
				IF EXISTS(SELECT TOP 1 'X' FROM errPaidTran WHERE tranId = @tranId AND tranStatus = 'Paid' AND eptId <> @rowId)
				BEGIN
					INSERT INTO errPaidTranHistory (									
						 eptId
						,tranId
						,oldSettlingAgent
						,oldPBranch
						,oldPBranchName
						,oldPSuperAgentComm
						,oldPSuperAgentCommCurrency
						,oldPAgentComm
						,oldPAgentCommCurrency
						,oldPaidDate 
						,newSettlingAgent
						,newPBranch
						,newPBranchName
						,payoutAmt
						,narration					
						,createdBy
						,createdDate
						,modType
					)
					SELECT TOP 1 @rowId,tranId,newSettlingAgent,newPBranch,newPBranchName,newPSuperAgentComm,newPSuperAgentCommCurrency,newPAgentComm,
					newPAgentCommCurrency,newPaidDate,
					@newSettlingAgent,@newPBranch,@newPBranchName,payoutAmt,@narration,@user,GETDATE(),'U' 
					FROM errPaidTran WHERE tranId=@tranId AND tranStatus='Paid'
					ORDER BY eptId DESC

				END
				ELSE
				BEGIN
					SELECT @oldPBranch = pBranch FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
					SELECT @oldSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @oldPBranch AND ISNULL(isSettlingAgent, 'N') = 'Y'
					IF @oldSettlingAgent IS NULL
					BEGIN
						SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @oldPBranch
						SELECT @oldSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
					END
					IF @oldSettlingAgent IS NULL
					BEGIN
						SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId
						SELECT @oldSettlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId AND ISNULL(isSettlingAgent, 'N') = 'Y'
					END
					INSERT INTO errPaidTranHistory (
						 eptId
						,tranId
						,oldSettlingAgent
						,oldPBranch
						,oldPBranchName
						,oldPSuperAgentComm
						,oldPSuperAgentCommCurrency
						,oldPAgentComm
						,oldPAgentCommCurrency
						,oldPaidDate 
						,newSettlingAgent
						,newPBranch
						,newPBranchName
						,payoutAmt
						,narration					
						,createdBy
						,createdDate
						,modType
					)
					SELECT @rowId,id,@oldSettlingAgent,pBranch,pBranchName,pSuperAgentComm,pSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,paidDate,
					@newSettlingAgent,@newPBranch,@newPBranchName,pAmt,@narration,@user,GETDATE(),'U'
					FROM remitTran WHERE id=@tranId
				END					         
			END
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully', @rowId
     END     
	IF @flag = 'd'
    BEGIN
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record.', @rowId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND tranStatus='Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record, Already Paid!', @rowId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM errPaidTran WHERE eptId = @rowId
		END
		ELSE
		BEGIN		
			EXEC proc_errorHandler 1, 'Sorry, You can not delete this record, Already Approved!', @rowId
			RETURN
		END

		EXEC proc_errorHandler 0, 'Record deleted successfully', @rowId
     END     
	IF @flag IN ('reject','rejectAll')
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM errPaidTranHistory WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rowId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM errPaidTran WHERE eptId = @rowId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rowId
					RETURN
				END
				DELETE FROM errPaidTran WHERE eptId = @rowId				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rowId
					RETURN
				END
				DELETE FROM errPaidTranHistory WHERE eptId = @rowId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @rowId
	END	
	IF @flag IN ('approve','approveAll')
	BEGIN
		DECLARE @requestedBy VARCHAR(50)
		IF NOT EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM errPaidTranHistory WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rowId
			RETURN
		END
		BEGIN TRANSACTION	
			
			IF EXISTS (SELECT 'X' FROM errPaidTran WHERE approvedBy IS NULL AND eptId = @rowId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM errPaidTranHistory WHERE eptId = @rowId	AND approvedBy IS NULL		
							
			IF @modType = 'I'
			BEGIN --New record
				UPDATE errPaidTran SET
					 approvedBy = @user
					,approvedDate= dbo.FNAGetDateInNepalTZ()
				WHERE eptId = @rowId	
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT						
			
				SELECT 
					  @oldPaidDate		= oldPaidDate
					 ,@oldPBranchName	= oldPBranchName
					 ,@newPBranchName	= newPBranchName
					 ,@newPaidDate		= createdDate
					 ,@tranId			= tranId
					 ,@narration		= narration
					 ,@requestedBy		= createdBy
				FROM errPaidTran WHERE eptId=@rowId
				
				SET @MESSAGE='EP:Paid by '+ ISNULL(@oldPBranchName,'') +' on '+ISNULL(@oldPaidDate,'')+' has been approved For Mistakely Post to agent '+ISNULL(@newPBranchName,'')+' on '+ISNULL(@newPaidDate,'') + ' by <b>' + @user + '</b>' + ISNULL('. <br/>Remarks:' 


+ @narration, '')
				EXEC proc_transactionLogs 'i', @requestedBy, @tranId, @MESSAGE, 'M'		
						
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT				
				UPDATE main SET
					 main.newSettlingAgent			= mode.newSettlingAgent
					,main.newPBranch				= mode.newPBranch
					,main.newPBranchName			= mode.newPBranchName
					,main.narration					= mode.narration        
					,main.modifiedDate				= dbo.FNAGetDateInNepalTZ()
					,main.modifiedBy				= @user
				FROM errPaidTran main
				INNER JOIN errPaidTranHistory mode ON mode.eptId= main.eptId AND mode.approvedBy IS NULL
					WHERE mode.eptId = @rowId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
							
				SELECT 
					  @oldPaidDate		= oldPaidDate
					 ,@oldPBranchName	= oldPBranchName
					 ,@newPBranchName	= newPBranchName
					 ,@newPaidDate		= createdDate
					 ,@tranId			= tranId
					 ,@narration		= narration
					 ,@requestedBy		= createdBy
				FROM errPaidTran WHERE eptId=@rowId
				
				SET @MESSAGE='EP:Paid by '+ ISNULL(@oldPBranchName,'') +' on '+ISNULL(@oldPaidDate,'')+' has been approved updated record For Mistakely Post to agent '+ISNULL(@newPBranchName,'')+' on '+ISNULL(@newPaidDate,'') + ' by <b>' + @user + '</b>' + ISNULL('. 


<br/>Remarks: ' + @narration, '')
				EXEC proc_transactionLogs 'i', @requestedBy, @tranId, @MESSAGE, 'M'	
				
			END
			ELSE IF @modType = 'D'
			BEGIN			
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				UPDATE errPaidTran SET
					 isDeleted = 'Y'
					,modifiedDate = dbo.FNAGetDateInNepalTZ()
					,modifiedBy = @user
				WHERE eptId = @rowId				
			END
			
			SELECT 
				@controlNo = dbo.fnadecryptstring(controlNo),
				@controlNoEncrypted = controlNo,
				@pAmt = pAmt,
				@pBranch = pBranch
			FROM remitTran rt WITH(NOLOCK) WHERE id = @tranId

			IF ISNUMERIC(@controlNo) = 1 AND RIGHT(@controlNo,1) <> 'D'
			BEGIN
				INSERT INTO dbo.rs_remitTranTroubleTicket(RefNo,Comments,DatePosted,PostedBy,uploadBy,status,noteType,tranno,category)
				SELECT @controlNoEncrypted, @message, GETDATE(), @user, @user, NULL, 2, NULL, 'push'
			END

			UPDATE errPaidTranHistory SET 
				approvedBy = @user, 
				approvedDate = dbo.FNAGetDateInNepalTZ() 
			WHERE eptId = @rowId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @rowId
				RETURN
			END		
			-- ## Accounting EP
			DECLARE @a_commCodeDom VARCHAR(20), @a_commCodeIntl VARCHAR(20), @a_mapCodeDom VARCHAR(20), @a_mapCodeInt VARCHAR(20)
				, @b_commCodeDom VARCHAR(20), @b_commCodeIntl VARCHAR(20), @b_mapCodeDom VARCHAR(20), @b_mapCodeInt VARCHAR(20)	
			
			IF RIGHT(@controlNo,1) <> 'D' 
			BEGIN
				IF EXISTS(SELECT 'x' FROM SendMnPro_Account.dbo.ErroneouslyPaymentNew WITH(NOLOCK) WHERE REF_NO = @controlNo)
				BEGIN
					UPDATE SendMnPro_Account.dbo.ErroneouslyPaymentNew SET EP_invoiceNo = @rowId WHERE REF_NO = @controlNo
				END
				ELSE
				BEGIN
					INSERT INTO SendMnPro_Account.dbo.ErroneouslyPaymentNew(REF_NO,TRANNO,AMOUNT,EP_COMMISSION,EP_AGENTCODE,EP_BRANCHCODE,EP_DATE,EP_USER,EP_invoiceNo)
					SELECT 
						DBO.FNADecryptString(CONTROLNO),
						TRANID,
						FLOOR(E.payoutAmt),
						ISNULL(ISNULL(OLDPAGENTCOMM,pagentcomm),0),
						am.mapCodeInt,
						bm.mapCodeInt,
						E.APPROVEDDATE,
						E.APPROVEDBY,
						EPTID
					FROM errPaidTran E (NOLOCK) 
					INNER JOIN REMITTRAN R  (NOLOCK) ON E.TRANID = R.ID
					LEFT JOIN AGENTMASTER AM (NOLOCK) ON R.PAGENT = AM.AGENTID
					LEFT JOIN AGENTMASTER BM (NOLOCK) ON R.PBRANCH = BM.AGENTID
					WHERE eptId = @rowId
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT 'x' FROM SendMnPro_Account.dbo.ErroneouslyPaymentNew WITH(NOLOCK) WHERE REF_NO = @controlNo)
				BEGIN
					UPDATE SendMnPro_Account.dbo.ErroneouslyPaymentNew SET EP_invoiceNo = @rowId WHERE REF_NO = @controlNo
				END
				ELSE
				BEGIN
					INSERT INTO SendMnPro_Account.dbo.ErroneouslyPaymentNew(REF_NO,TRANNO,AMOUNT,EP_COMMISSION,EP_AGENTCODE,EP_BRANCHCODE,EP_DATE,EP_USER,EP_invoiceNo)
					SELECT DBO.FNADecryptString(CONTROLNO) 
						,TRANID
						,FLOOR(E.payoutAmt)
						,ISNULL(ISNULL(OLDPAGENTCOMM,pagentcomm),0)
						,CASE WHEN r.paymentMethod = 'Cash Payment' THEN am.mapCodeInt
								ELSE am.mapCodeDom END 
						,CASE WHEN r.paymentMethod = 'Cash Payment' THEN bm.mapCodeInt
								ELSE bm.mapCodeDom END 
						,E.APPROVEDDATE
						,E.APPROVEDBY
						,EPTID
					FROM errPaidTran E (NOLOCK) 
					INNER JOIN REMITTRAN R  (NOLOCK) ON E.TRANID=R.ID
					LEFT JOIN AGENTMASTER AM (NOLOCK) ON R.PAGENT=AM.AGENTID
					LEFT JOIN AGENTMASTER BM (NOLOCK) ON R.PBRANCH=BM.AGENTID
					WHERE eptId = @rowId
				END
			END	
				
			-- ## Limit Update
			EXEC Proc_AgentBalanceUpdate @flag = 'ep',@tAmt = @pAmt ,@settlingAgent = @pBranch			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @rowId
	END	
	
	IF @flag = 's'
	BEGIN
	
		SET @table = '(
					
				SELECT
					 eptId = main.eptId
					,tranId = main.tranId
					,controlNo = tranMas.controlNo
					,newPBranch = main.newPBranch
					,newPBranchName = main.newPBranchName
					,oldPBranch = main.oldPBranch
					,oldPBranchName = main.oldPBranchName
					,payoutAmount	= main.payoutAmt
					,oldPaidDate = main.oldPaidDate
					,narration	= main.narration
					,receiverName = tRec.firstName + ISNULL( '' '' + tRec.middleName, '''') + ISNULL( '' '' + tRec.lastName1, '''') + ISNULL( '' '' + tRec.lastName2, '''')
					,senderName = tSend.firstName + ISNULL( '' '' + tSend.middleName, '''') + ISNULL( '' '' + tSend.lastName1, '''') + ISNULL( '' '' + tSend.lastName2, '''')
					,tranStatus	= main.tranStatus
					,createdBy	= main.createdBy
					,createdDate	= main.createdDate
					,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.CreatedDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
					,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.CreatedBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.tranId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END		

				FROM errPaidTran main WITH(NOLOCK)
					INNER JOIN remitTran tranMas on tranMas.id=main.tranId
					INNER JOIN tranSenders tSend WITH(NOLOCK) ON tranMas.id = tSend.tranId
					INNER JOIN tranReceivers tRec WITH(NOLOCK) ON tranMas.id=  tRec.tranId	
					LEFT JOIN errPaidTranHistory mode ON main.eptId = mode.eptId AND mode.approvedBy IS NULL
					AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y'' AND main.tranStatus=''Unpaid''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						)'
						
						
		IF @sortBy IS NULL
			SET @sortBy = 'eptId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '( 
				SELECT
					 main.eptId
					,main.tranId
					,controlNo1=main.controlNo
					,controlNo = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(main.controlNo) + '''''')">'' + dbo.FNADecryptString(main.controlNo) + ''</a>''
					,main.newPBranch
					,main.newPBranchName
					,main.oldPBranch 
					,main.oldPBranchName 
					,main.payoutAmount
					,main.oldPaidDate 
					,main.narration
					,main.receiverName 
					,main.senderName 
					,main.tranStatus
					,main.createdBy
					,main.createdDate
					,main.modifiedDate		
					,main.modifiedBy		
					,main.hasChanged 					
				FROM ' + @table + ' main
				) x'	
		SET @sql_filter = ''
		
		IF @controlNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND controlNo1 = ''' + dbo.FNAEncryptString(@controlNo) + ''''
		
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
					
		IF @createdDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cast(createdDate as date) = ''' + CAST(@createdDate AS VARCHAR(11))  + ''''
			
		SET @select_field_list ='
					 eptId
					,tranId
					,controlNo1
					,controlNo
					,newPBranch
					,newPBranchName
					,oldPBranch 
					,oldPBranchName 
					,payoutAmount
					,oldPaidDate 
					,narration
					,receiverName 
					,senderName 
					,tranStatus
					,createdBy
					,createdDate
					,modifiedDate		
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

	IF @flag = 'c'			
	BEGIN

		IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND tranStatus = 'Paid')
		BEGIN

			EXEC proc_errorHandler 1, 'Paid Transaction Not Found', @controlNoEncrypted
			RETURN	
		END
		
		IF EXISTS(SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE tranId = @tranId AND tranStatus = 'Unpaid' AND ISNULL(isDeleted,'N')<>'Y')
		BEGIN

			EXEC proc_errorHandler 1, 'Transaction Already Processed For Mistakely Post!', @controlNoEncrypted
			RETURN	
		END		
	
		SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		IF @agentId = dbo.FNAGetHOAgentId()
		BEGIN
			EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
			RETURN
		END
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNo
	END

	IF @flag = 'a'
	BEGIN		
		SELECT a.*,dbo.FNADecryptString(b.controlNo) controlNo ,
		newPBranchName1 = newPBranchName+'|'+newPbranch 
			FROM errPaidTran a WITH(NOLOCK) INNER JOIN remitTran b WITH(NOLOCK) ON a.tranId=b.id
		WHERE eptId = @rowId		
	END
	
	IF @flag = 'PAY'
	BEGIN
		SELECT 
			 eptId
			,newPBranch
			,newPBranchName 
		FROM errPaidTran WITH(NOLOCK) 
		WHERE approvedDate IS NOT NULL 
			AND tranId = @tranId  
			AND tranStatus ='Unpaid'
			AND ISNULL(isDeleted,'N')<>'Y'			
	END
	
	IF @flag = 'payUpdate'
	BEGIN		
		IF NOT EXISTS(SELECT 'X'
						FROM errPaidTran WITH(NOLOCK) 
						WHERE approvedDate IS NOT NULL 
							AND eptId = @rowId  
							AND tranStatus ='Unpaid'
							AND newPaidDate IS NULL
							AND ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			SELECT '1','Transaction Not Available For Payment Order.',@rowId
			RETURN
		END
		SELECT
			 @oldPBranch	= oldPBranch
			,@newPBranch    = CASE WHEN @newPBranch IS NULL THEN newPBranch ELSE @newPBranch END
			,@tranAmount	= payoutAmt
		FROM errPaidTran WITH(NOLOCK) 
		WHERE eptId=@rowId
		
		IF @newPBranch IS NULL OR @newPBranch = ''
		BEGIN
			SELECT '1','PO agent is missing.',@rowId
			RETURN
		END
		IF @newDeliveryMethod IS NULL OR @newDeliveryMethod = ''
		BEGIN
			SELECT '1','PO agent is missing.',@rowId
			RETURN
		END
		

		SELECT @newPBranchName = agentName 
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch
					
		SET @pBranch = @newPBranch	
		
		SELECT 
			 @agentType = agentType
			,@pBranchName = agentName
			,@pAgent = parentId
			,@a_mapCodeDom = mapCodeDom
			,@a_mapCodeInt = mapCodeInt
			,@a_commCodeDom = commCodeDom
			,@a_commCodeIntl = commCodeInt
			,@b_mapCodeDom = mapCodeDom
			,@b_mapCodeInt = mapCodeInt
			,@b_commCodeDom = commCodeDom
			,@b_commCodeIntl = commCodeInt 
			,@pCountry = agentCountry
			,@pState = agentState
			,@pDistrict = agentDistrict 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch 

		SELECT 
			 @deliveryMethod	= paymentMethod
			,@pLocation			= pLocation
			,@tAmt				= tAmt
			,@cAmt				= cAmt
			,@pAmt				= pAmt
			,@payoutCurr		= payoutCurr
			,@serviceCharge		= serviceCharge 
			,@sBranch			= sBranch
			,@sCountry			= sCountry
			,@sBranch			= sBranch 
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted

		SELECT @sLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		
		IF @agentType = 2903	--Agent
		BEGIN
			SET @pAgent = @pBranch
		END
		ELSE
		BEGIN
			SELECT 
				 @a_mapCodeDom = mapCodeDom
				,@a_mapCodeInt = mapCodeInt
				,@a_commCodeDom = commCodeDom
				,@a_commCodeIntl = commCodeInt 
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		END
		SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		
		--3.Find Settlement Agent
		SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent AND isSettlingAgent = 'Y'
		
		
		SELECT @deliveryMethodId = serviceTypeId 
		FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @newDeliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		
		IF(@sCountry = 'Nepal')
		BEGIN
			IF @deliveryMethod = 'Cash Payment'
			BEGIN
				DECLARE @tranDistrictId INT, @payAgentDistrictId INT
				SELECT @payAgentDistrictId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @pLocation
				SELECT @tranDistrictId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = (SELECT pLocation FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
				IF @payAgentDistrictId IS NULL
				BEGIN
					SELECT '1', 'Payout Location not found.',@rowId 
					RETURN
				END
				IF @tranDistrictId IS NULL
				BEGIN
					SELECT '1', 'Payout Location not found.',@rowId 
					RETURN
				END
				IF(@tranDistrictId <> @payAgentDistrictId)
				BEGIN
					SELECT '1', 'You are not allowed to pay this TXN. This TRANSACTION is not within the agent district.', @rowId 
					RETURN
				END
			END
		END
		
		IF @sCountry = 'Nepal'
		BEGIN
			DECLARE @commissionCheck MONEY, @mapCode VARCHAR(20), @payOption INT
			
			IF @newDeliveryMethod = 'Cash Payment'
				SELECT @mapCode = mapCodeInt, @payOption = payOption FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch
			ELSE
				SELECT @mapCode = mapCodeIntAc, @payOption = payOption FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch
			IF @payOption IN (10,20)
			BEGIN
				SELECT
					 @pAgentComm		= ISNULL(pAgentComm, 0)
					,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
					,@commissionCheck	= pAgentComm
				FROM dbo.FNAGetDomesticPayComm(@sBranch, @pBranch, @deliveryMethodId, @tAmt)
			END
			ELSE
			BEGIN
				SELECT @pAgentComm = 0, @commissionCheck = 0
			END
			SELECT @pAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR'
		END
		ELSE
		BEGIN
			DECLARE @sCountryId INT
			IF @newDeliveryMethod = 'Cash Payment'
				SELECT @mapCode = mapCodeInt, @payOption = payOption FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch
			ELSE
				SELECT @mapCode = mapCodeIntAc, @payOption = payOption FROM agentMaster WITH(NOLOCK) WHERE agentId = @newPBranch

			SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry AND ISNULL(isDeleted, 'N') = 'N'
			SELECT @sLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
			SELECT @pSuperAgentComm =  0, @pSuperAgentCommCurrency = 'NPR'
			--IF @payOption IN (10,20)

			SELECT @pAgentComm = ISNULL(amount, 0), 
				@commissionCheck = amount, 
				@pAgentCommCurrency = commissionCurrency 
			FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, @sLocation, @pSuperAgent, 151, @pLocation, 
						@pBranch, 'NPR', @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL)
			--ELSE
			--	SELECT @pAgentComm = 0, @pAgentCommCurrency = 'NPR', @commissionCheck = 0

			SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'
		END

		UPDATE errPaidTran SET 
			 ridType					= @rIdType
			,rIdNo						= @rIdNo
			,expiryType					= @expiryType
			,issueDate					= @issueDate
			,validDate					= @validDate
			,placeOfIssue				= @placeOfIssue
			,mobileNo					= @mobileNo
			,rRelativeType				= @rRelativeType
			,rRelativeName				= @rRelativeName
			,newPBranch					= @pBranch
			,newPBranchName				= @pBranchName
			,newPSuperAgentComm			= @pSuperAgentComm
			,newPSuperAgentCommCurrency	= @pSuperAgentCommCurrency
			,newPAgentComm				= @pAgentComm
			,newPAgentCommCurrency		= @pAgentCommCurrency
			,newPSuperAgent				= @pSuperAgent
			,newPSuperAgentName			= @pSuperAgentName
			,newPAgent					= @pAgent
			,newPAgentName				= @pAgentName
			,newDeliveryMethod			= @newDeliveryMethod
			,tranStatus					= 'Paid'  
			,newPaidBy					= @user
			,newPaidDate				= GETDATE()	
			,payRemarks					= @payRemarks
			,newSettlingAgent			= @settlingAgent							
		WHERE eptId = @rowId 

		--6.Update receiver identification details
		SELECT @tranId = id, @controlNo = dbo.fnadecryptstring(controlNo) FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		UPDATE tranReceivers SET
			 idType			= @rIdType
			,idNumber		= @rIdNo
			,issuedDate		= @issueDate
			,validDate		= @validDate
			,placeOfIssue	= @placeOfIssue
			,mobile			= @mobileNo
		WHERE tranId = @tranId
		
		EXEC proc_updatePayTopUpLimit @settlingAgent, @tranAmount

		SELECT 
			 @oldPaidDate		= oldPaidDate
			,@oldPBranchName	= oldPBranchName
			,@newPBranchName	= newPBranchName
			,@newPaidDate		= createdDate
		FROM errPaidTran WHERE EPTID=@ROWID

		SET @MESSAGE='PO:Transaction has been paid by '+ ISNULL(@user,'') +' from '+ISNULL(@newPBranchName,'')+' agent on '+ CAST(GETDATE() AS VARCHAR)+' for Mistakely post record!'
		EXEC proc_transactionLogs 'i', @user, @tranId, @MESSAGE, 'M'
			
		IF ISNUMERIC(@controlNo) = 1 AND RIGHT(@controlNo,1) <> 'D'
		BEGIN
			INSERT INTO dbo.rs_remitTranTroubleTicket(RefNo,Comments,DatePosted,PostedBy,uploadBy,status,noteType,tranno,category)
			SELECT @controlNoEncrypted, @message, GETDATE(), @user, @user, NULL, 2, NULL, 'push'
		END
				
		--## Accounting PO
		UPDATE AC SET
			  PO_COMMISSION		= CASE WHEN R.sAgent = 4854 THEN 0 ELSE ISNULL(E.newPAgentComm,0) END
			 ,PO_AgentCode		= CASE WHEN R.tranType = 'D' AND E.newDeliveryMethod = 'Bank Deposit' THEN am.mapCodeDom 
									ELSE AM.mapCodeInt END 
			 ,PO_BranchCode		= CASE WHEN R.tranType = 'D' AND E.newDeliveryMethod = 'Bank Deposit' THEN bm.mapCodeDom 
									ELSE bm.mapCodeInt END 
			 ,PO_DATE			= E.newPaidDate
			 ,PO_USER			= E.newPaidBy
			 ,PO_INVOICENO		= E.eptId
		 FROM  SendMnPro_Account.dbo.ErroneouslyPaymentNew  AC, errPaidTran E (NOLOCK), REMITTRAN R  (NOLOCK) ,AGENTMASTER AM (NOLOCK),AGENTMASTER BM (NOLOCK)
		 WHERE E.EPTID = AC.EP_INVOICENO
				AND E.TRANID = R.ID
				AND E.newPBranch = bm.agentId
				AND E.newPAgent = am.agentId
				AND AC.ref_no = @controlNo

		-- ## Limit Update
		EXEC Proc_AgentBalanceUpdate @flag = 'po',@tAmt = @pAmt ,@settlingAgent = @pBranch	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Transaction has been paid successfully.', @tranId
	END
	IF @flag = 'cancel'
    BEGIN		
		IF NOT EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId)
		BEGIN
			EXEC proc_errorHandler 1, 'Record not found.', @rowId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not cancel this transaction before approval.', @rowId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @rowId AND tranStatus	='Paid')
		BEGIN
			EXEC proc_errorHandler 1, 'You can not cancel, Transaction has been already paid.', @rowId
			RETURN
		END 

        BEGIN TRANSACTION							
		UPDATE errPaidTran SET 
			 modifiedBy				= @user
			,modifiedDate			= GETDATE()
			,tranStatus				= 'Cancel'
		FROM errPaidTran main WHERE main.eptId= @rowId	
		SELECT @tranId =  tranId FROM dbo.errPaidTran ep WITH(NOLOCK) WHERE eptId= @rowId	
		SET @MESSAGE='EP Cancelled: '+ ISNULL(@narration,'')
		EXEC proc_transactionLogs 'i', @user, @tranId, @narration, 'C'		

		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Transaction has been cancelled successfully', @rowId
     END
END TRY
BEGIN CATCH

     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @tranId

END CATCH




GO
