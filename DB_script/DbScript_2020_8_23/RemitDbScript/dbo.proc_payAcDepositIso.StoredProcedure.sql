USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payAcDepositIso]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_payAcDepositIso]
	@flag		VARCHAR(10),
	@userName	VARCHAR(50) = NULL,
	@pwd		VARCHAR(50) = NULL,
	@agentCode	VARCHAR(50)	= NULL,
	@tranId		BIGINT		= NULL,
	@rowId		BIGINT		= NULL,
	@processId	VARCHAR(30) = NULL,
	@resCode	VARCHAR(500)= NULL,
	@resMsg		VARCHAR(max)= NULL,
	@user		VARCHAR(50)	= NULL,
	@tranType	CHAR(1)		= NULL,
	@AccNo		VARCHAR(30)	= NULL,
	@bankAccName VARCHAR(255)=NULL,
	@code		VARCHAR(10)  =NULL,
	@referenceId	VARCHAR(50)	= NULL


AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @mobileNo VARCHAR(15)
DECLARE @isoUser VARCHAR(50) = 'ISOPAIDSYSTEM'
--30 minutes prior
DECLARE @cutOffDate DATETIME = DATEADD(MINUTE, -30, GETDATE())		
BEGIN TRY
	IF @flag = 'BankList'
	BEGIN
		SELECT bankCode, bankName FROM dbo.IsoBankSetup WITH(NOLOCK) 
		WHERE ISNULL(isActive,'Y') <> 'N'
		RETURN
	END
	IF @flag = 's'   
	BEGIN
		-- Removed credentials checking logic as Requested By Ramesh sir
		--IF NOT EXISTS(SELECT 'A' FROM dbo.applicationUsers WITH(NOLOCK) 
		--	WHERE CONVERT(VARBINARY,userName) = CONVERT(VARBINARY,@userName) 
		--	AND CONVERT(VARBINARY,pwd) =  CONVERT(VARBINARY,dbo.FNAEncryptString(@pwd)) 
		--	AND agentCode = @agentCode 
		--)
		--BEGIN
		--	SELECT 1 code, 'Invalid Login Details, please try with valid user.' msg
		--	RETURN
		--END	
		/*
		SELECT * FROM IsoBankSetup
		SELECT * FROM acDepositQueueIso
		*/

		UPDATE acDepositQueueIso SET 
			[status] = 'Ready',
			[processDate] = GETDATE()
		WHERE rowId = @rowId

		--SELECT referenceId = 'IME'+CAST(q.tranId AS VARCHAR(50)),
		--	0 CODE,q.*,b.*
		--FROM acDepositQueueIso q WITH(NOLOCK)
		--INNER JOIN IsoBankSetup b WITH(NOLOCK) ON q.pBank = b.bankId 
		--INNER JOIN remitTran rt (NOLOCK) ON q.tranId = rt.id
		--WHERE q.rowId = @rowId 
		--AND q.paidDate IS NULL 
		--AND rt.paidDate IS NULL
		--AND rt.payStatus = 'Post'
		--AND [status] ='Ready'
		--SELECT * FROM acDepositQueueIso


		SELECT			
			0 CODE
			,b.agentCode
			,b.userName
			,b.pwd
			,b.accountNo
			,b.bankCode
			,q.toAc
			,q.amount
			,q.remarks
			,q.ReferenceId
		FROM acDepositQueueIso q WITH(NOLOCK)
		INNER JOIN IsoBankSetup b WITH(NOLOCK) ON q.pBank = b.bankId 
		INNER JOIN remitTran rt (NOLOCK) ON q.tranId = rt.id
		WHERE q.rowId = @rowId 
		AND q.paidDate IS NULL 
		AND rt.paidDate IS NULL
		AND rt.payStatus = 'Post'
		AND [status] ='Ready'


		RETURN
	END

	IF @flag = 'list'   
	BEGIN		
		-- Removed credentials checking logic as Requested By Ramesh sir
		--IF NOT EXISTS(SELECT 'A' FROM dbo.applicationUsers WITH(NOLOCK) 
		--	WHERE CONVERT(VARBINARY,userName) = CONVERT(VARBINARY,@userName) 
		--	AND CONVERT(VARBINARY,pwd) = CONVERT(VARBINARY,dbo.FNAEncryptString(@pwd)) 
		--	AND agentCode = @agentCode 
		--)
		--BEGIN
		--	SELECT 1 code, 'Invalid Login Details, please try with valid user.' msg
		--	RETURN
		--END	
		--30 minutes prior
		--DECLARE @cutOffDate DATETIME = DATEADD(MINUTE, -30, GETDATE())		

		SELECT TOP 50
			'0' code,q.rowId
		FROM acDepositQueueIso q WITH(NOLOCK)		
		INNER JOIN IsoBankSetup b WITH(NOLOCK) ON q.pBank = b.bankId 
		INNER JOIN remitTran rt (NOLOCK) ON q.tranId = rt.id
		WHERE q.paidDate IS NULL 
			AND rt.paidDate IS NULL			
			AND q.[status] IS NULL
			AND rt.payStatus = 'Post'
			
		RETURN
	END

	IF @flag = 'pay'  
	BEGIN
		DECLARE 
			 @pAgent			BIGINT
			,@pAgentName		VARCHAR(500)
			,@pBranch			BIGINT
			,@pBranchName		VARCHAR(500)
			,@pState			VARCHAR(200)
			,@pDistrict			VARCHAR(200)
			,@pLocation			VARCHAR(50)
			,@sRouteId			VARCHAR(50)
			,@controlNo			VARCHAR(20)

		SELECT 
			@tranId = tranId, 
			@tranType = rt.tranType,
			@pAgent = rt.pAgent,
			@sRouteId = rt.sRouteId,
			@controlNo = rt.controlNo
		FROM acDepositQueueIso q WITH(NOLOCK) 
		INNER JOIN remitTran rt WITH(NOLOCK) ON q.tranId = rt.id
		WHERE q.rowid = @rowId
		
		IF @tranType = 'I'
		BEGIN			
			SELECT  
				 @pAgent			= am.agentId
				,@pAgentName		= am.agentName
				,@pBranch			= bm.agentId
				,@pBranchName		= bm.agentName 
				,@pState			= bm.agentState
				,@pDistrict			= bm.agentDistrict
				,@pLocation			= bm.agentLocation
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId AND bm.isHeadOffice = 'Y'
			WHERE am.agentId = @pAgent and isnull(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
		
			IF @pBranch IS NULL
			BEGIN
				SELECT TOP 1
					 @pAgent			= am.agentId
					,@pAgentName		= am.agentName
					,@pBranch			= bm.agentId
					,@pBranchName		= bm.agentName 
					,@pState			= bm.agentState
					,@pDistrict			= bm.agentDistrict
					,@pLocation			= bm.agentLocation
				FROM agentMaster am WITH(NOLOCK)
				LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId
				WHERE am.agentId = @pAgent AND ISNULL(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
			END
			BEGIN TRAN
			UPDATE remitTran SET
				 pBranch					= @pBranch
				,pBranchName				= @pBranchName
				,pState						= @pState
				,pDistrict					= @pDistrict
				,pAgentComm					= case when rt.paymentMethod='Relief Fund' then 0 else (
													SELECT amount FROM dbo.FNAGetPayComm(
														NULL
														,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), NULL, 1002, 151, 
														@pLocation, @pBranch, 'NPR'
														,2, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
													)
												)
												end
				,pAgentCommCurrency			= 'NPR'
				,pSuperAgentComm			= 0
				,pSuperAgentCommCurrency	= 'NPR'
				,tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,paidBy						= @isoUser
				,paidDate					= dbo.FNAGetDateInNepalTZ()
				,paidDateLocal				= GETDATE()	
			FROM remitTran rt WITH(NOLOCK) 
			WHERE rt.id = @tranId		
			
			UPDATE acDepositQueueIso SET 
				 [status] = 'Success'
				,resCode = @resCode
				,resMsg = @resMsg
				,processId = @processId
				,paidDate = dbo.FNAGetDateInNepalTZ()
				--,referenceId = @referenceId
			WHERE rowid = @rowId
			--SELECT TOP 5  * from payQueue2 (nolock) order by 1 desc
			-- ## Update Accounting
			EXEC dbo.proc_payAcDepositAC
				 @flag				= 'payIntl'
				,@user				= @isoUser
				,@tranIds			= @tranId

			-- ## sending sms
			INSERT INTO smsQueueAcDepositTxn(tranId)VALUES(@tranId)
			
			-- ## Queue Table for Data Integration
			IF @sRouteId IS NOT NULL
			BEGIN
				INSERT INTO payQueue2(controlNo, pAgent, pAgentName, pBranch, pBranchName, paidBy, paidDate, paidBenIdType, paidBenIdNumber, routeId)
				SELECT @controlNo, @pAgent, @pAgentName, @pBranch, @pBranchName, @isoUser, dbo.FNAGetDateInNepalTZ(), NULL, NULL, @sRouteId
			END
			-- ## TT Lodged
			INSERT INTO tranModifyLog(tranId,[message],createdBy,createdDate,MsgType,[status])
			SELECT @tranId,'Transaction has been paid successfully via ISO.',@isoUser,dbo.FNAGetDateInNepalTZ(),'','Resolved'

			COMMIT TRAN	
			EXEC proc_errorHandler 0, 'Transction has been paid successfully.', NULL
			RETURN
		END
		IF @tranType = 'D'
		BEGIN
			SELECT  
				 @pAgent			= am.agentId
				,@pAgentName		= am.agentName
				,@pBranch			= bm.agentId
				,@pBranchName		= bm.agentName 
				,@pState			= bm.agentState
				,@pDistrict			= bm.agentDistrict
				,@pLocation			= bm.agentLocation
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId AND bm.isHeadOffice = 'Y'
			WHERE am.agentId = @pAgent AND isnull(bm.isDeleted,'N') = 'N' AND bm.isActive = 'Y'
		
			IF @pBranch IS NULL
			BEGIN
				SELECT TOP 1
					 @pAgent			= am.agentId
					,@pAgentName		= am.agentName
					,@pBranch			= bm.agentId
					,@pBranchName		= bm.agentName 
					,@pState			= bm.agentState
					,@pDistrict			= bm.agentDistrict
					,@pLocation			= bm.agentLocation
				FROM agentMaster am WITH(NOLOCK)
				LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId
				WHERE am.agentId = @pAgent AND isnull(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
			END

			BEGIN TRAN
			UPDATE remitTran SET
				 pBranch					= @pBranch
				,pBranchName				= @pBranchName
				,pState						= @pState
				,pDistrict					= @pDistrict
				,pAgentComm					= case when rt.paymentMethod='Relief Fund' then 0 else (
													SELECT amount FROM dbo.FNAGetPayComm(
														NULL
														,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), NULL, 1002, 151, 
														@pLocation, @pBranch, 'NPR'
														,2, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
													)
												)
												end
				,pAgentCommCurrency			= 'NPR'
				,pSuperAgentComm			= 0
				,pSuperAgentCommCurrency	= 'NPR'
				,tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,paidBy						= @isoUser
				,paidDate					= dbo.FNAGetDateInNepalTZ()
				,paidDateLocal				= GETDATE()	
			FROM remitTran rt WITH(NOLOCK) 
			WHERE rt.id = @tranId

				-- ## Update Accounting
			EXEC dbo.proc_payAcDepositAC
				 @flag				= 'payDomIso'
				,@user				= @isoUser
				,@tranIds			= @tranId

			UPDATE acDepositQueueIso SET 
				 [status] = 'Success' 
				,resCode = @resCode
				,resMsg = @resMsg
				,processId = @processId
				--,referenceId = @referenceId
			WHERE rowId = @rowId
				
			-- ## TT Lodged
			INSERT INTO tranModifyLog(tranId,[message],createdBy,createdDate,MsgType,[status])
			SELECT @tranId,'Transaction has been paid successfully via ISO.',@isoUser,dbo.FNAGetDateInNepalTZ(),'','Resolved'

			COMMIT TRAN	
			EXEC proc_errorHandler 0, 'Transction has been paid successfully.', NULL
			RETURN
		END
	END

	IF @flag = 'payError'  
	BEGIN
		UPDATE acDepositQueueIso SET 
			 [status] = 'Error' 
			,resCode = @resCode
			,resMsg = @resMsg
			,processId = @processId
			--,referenceId = @referenceId
		WHERE rowId = @rowId

		INSERT INTO tranModifyLog(tranId,controlNo,[Message],createdBy,createdDate)
		SELECT i.tranId,rt.controlNo, @resMsg, 'System',GETDATE()
		FROM acDepositQueueIso i WITH(NOLOCK)
		INNER JOIN dbo.remitTran rt WITH(NOLOCK) ON i.tranId = rt.id
		WHERE rowId = @rowId

		EXEC proc_errorHandler 0, 'Error has been updated successfully.', NULL
		RETURN
	END	

	IF @flag='chkAccName'
	BEGIN
		DECLARE 
			 @recAccNameRt varchar(225)=NULL
			,@recAccNoRt varchar(30)=NULL 
			,@tranNo BIGINT

		--SELECT 
		--	@tranNo=rt.id
		--	,@controlNo=dbo.fnaDecryptString(rt.controlNo)
		--	,@recAccNoRt=rt.accountNo
		--	,@recAccNameRt=rt.receiverName from (
		--	SELECT 0 CODE,q.tranId
		--	FROM acDepositQueueIso q WITH(NOLOCK) 
		--	INNER JOIN IsoBankSetup b WITH(NOLOCK) ON q.pBank = b.bankId 
		--	WHERE q.rowId = @rowId
		--) xx inner join remitTran rt with(nolock) on xx.tranId=rt.id

		SELECT @tranNo = tranId FROM acDepositQueueIso q WITH(NOLOCK) WHERE rowId = @rowId
		-----select @tranNo,@controlNo,@recAccNoRt,@recAccNameRt

		SELECT
			 @controlNo=dbo.fnaDecryptString(rt.controlNo)
			,@recAccNoRt=rt.accountNo
			,@recAccNameRt=rt.receiverName
		FROM remitTran rt WITH(NOLOCK)
		WHERE id = @tranNo

		IF (REPLACE(REPLACE(@recAccNameRt, ' ', ''), '.', '') = REPLACE(REPLACE(@bankAccName, ' ', ''), '.', '') and @code='0')
		BEGIN
			SELECT '0' errorCode,'Account Name Matches',null
			RETURN
		END
		ELSE
		BEGIN
			DECLARE @controlNoEncrypted varchar(30)=NULL,@troubleMsg varchar(225)='Invalid Account Number.'
			SET @controlNoEncrypted=dbo.FNAEncryptString(@controlNo)


			BEGIN TRAN
				--INSERT INTO dbo.rs_remitTranTroubleTicket(RefNo,Comments,DatePosted,PostedBy,uploadBy,status,msrepl_tran_version,noteType,tranno)
				--SELECT @controlNoEncrypted, 'Account name Errror, Correct Account Name is :'+@bankAccName, GETDATE(), 'System', 'System', NULL, NEWID(), 2, @tranNo

				IF @code='0' AND (@recAccNameRt<>@bankAccName AND @bankAccName is not null)
					SET @troubleMsg='Account name Error, Correct Account Name is :'+@bankAccName
				ELSE
					SET @troubleMsg='Invalid Account Number.'


				INSERT INTO tranModifyLog(tranId,controlNo,[Message],createdBy,createdDate)
				SELECT @tranNo,@controlNoEncrypted, @troubleMsg, 'System',GETDATE()

				UPDATE acDepositQueueIso set [status]='Error',resCode ='1',resMsg= @troubleMsg where tranId=@tranNo

				--UPDATE remitTran set tranStatus='Payment',payStatus='Unpaid' where id=@tranNo
			COMMIT TRAN
			
			EXEC proc_errorHandler 1001, 'Account name did not match and trouble ticket has been added.', null
			RETURN
		END
	END

	IF @flag='AccName'
	BEGIN
		
		IF OBJECT_ID('tempdb..#temp') is not null
			drop TABLE #temp

		CREATE TABLE #temp(
			 accountName varchar(30) NULL
			,accountNo varchar(30) NULL
		)


		INSERT INTO #temp (accountName,accountNo) SELECT 'Saroj Chalise', '3308010000234'
		INSERT INTO #temp (accountName,accountNo) SELECT 'Akriti Shahi', '3308010000123'
		INSERT INTO #temp (accountName,accountNo) SELECT 'Manoj Subedi', '0207010002551'



		DECLARE @tempRecName varchar(255)=null
		SELECT top 1 @tempRecName=accountName from #temp rt with(NOLOCK) where accountNo=@AccNo
		SELECT '0' errorCode,@tempRecName msg,null
	END
END TRY

BEGIN CATCH
IF @@ERROR <>0
ROLLBACK TRANSACTION
SELECT 1 code, ERROR_MESSAGE() msg, NULL ID
END CATCH 







GO
