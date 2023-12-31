USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ws_globalBank]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_ws_globalBank]
(
	 @flag			VARCHAR(50)  
	,@user			VARCHAR(30) 
	,@controlNo		VARCHAR(100)	= NULL
	,@id			BIGINT			= NULL
	,@msg			VARCHAR(MAX)	= NULL
	,@xml			VARCHAR(MAX)	= NULL
	,@xmlAPI		XML				= NULL
	,@syncDate		VARCHAR(20)		= NULL
	,@status		VARCHAR(20)		= NULL
	,@controlNo2	VARCHAR(20)		= NULL
	,@remarks		VARCHAR(500)	= NULL
	,@errorCode		VARCHAR(50)		= NULL
	,@errorMsg		VARCHAR(100)	= NULL
	,@tpErrorCode	VARCHAR(50)		= NULL
	,@rNameIME		VARCHAR(200)	= NULL
	,@rNameGbl		VARCHAR(200)	= NULL
)		
AS 
SET NOCOUNT ON
SET XACT_ABORT ON 
BEGIN TRY
	DECLARE @gblPayAgentId INT = 37402
	DECLARE @controlNoEncrypted VARCHAR(50)

	declare @rCountry varchar(50)
		,@pBranch int
		,@psAgent int
		,@pCountryId int
		,@pAgentName	varchar(100)

	IF @flag = 'ss' --Sync Status
	BEGIN
		SELECT
			 @errorCode = '1'
			,@errorMsg = 'Could not Synchronize the Transaction. Unknown Transaction status in API'

		IF @status = 'Paid'
		BEGIN
			SELECT @errorCode = '0', @errorMsg = 'Paid Transaction Synchronized Successfully'
			UPDATE remitTran SET
				  tranStatus	= 'Paid'	
				 ,payStatus		= 'Paid'
				 ,lockStatus	= 'unlocked'			 
				 ,paidBy		= @user
				 ,paidDate		= ISNULL(paidDate, GETDATE())
				 ,paidDateLocal	= ISNULL(paidDateLocal, DBO.FNADateFormatTZ(GETDATE(), @user))
			WHERE controlNo = dbo.FNAEncryptString(@controlNo)

			UPDATE dbo.tpTxnList SET status = 'Paid' WHERE controlNo = dbo.FNAEncryptString(@controlNo)
		END
		ELSE IF @status = 'CANCELLED'
		BEGIN
			SET @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
			SELECT @errorCode = '0', @errorMsg = 'Cancelled Transaction Synchronized Successfully'
			
			EXEC proc_cancelTran @flag = 'cancelTpTxn', @controlNo = @controlNo, @user = @user
			
			UPDATE dbo.tpTxnList SET status = 'Cancel' WHERE controlNo = @controlNoEncrypted
		END		
		ELSE IF @status = 'UNPAID'
		BEGIN
		
			SELECT @errorCode = '0', @errorMsg = 'Post Transaction Synchronized Successfully'
			UPDATE remitTran SET			
				  payStatus			= 'Post'						 
				 ,approvedBy		= ISNULL(approvedBy, @user)
				 ,approvedDate		= ISNULL(approvedDate, DBO.FNADateFormatTZ(GETDATE(), @user))
				 ,approvedDateLocal	= ISNULL(approvedDateLocal, GETDATE())
			WHERE controlNo = dbo.FNAEncryptString(@controlNo)

			INSERT INTO tpTxnList(tranId, controlNo, transferredDate, pAgent, status)
            SELECT id, controlNo, @syncDate, @gblPayAgentId, 'Unpaid' FROM dbo.remitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo)
		END
		
		EXEC proc_errorHandler @errorCode, @errorMsg, @controlNo
		RETURN
		
	END
	
	IF @flag = 'listForSync'
	BEGIN
		
		----sync with global ime bank
		SELECT top 60 id,Controlno = dbo.fnaDecryptstring(Controlno) ,convert(varchar,createddate ,101) createddate
		FROM remittran(NOLOCK) 
		WHERE paystatus='post' and pAgent = 1056 
			and approveddate < dateadd(Hour,-3,getdate())
		order by newid()
		RETURN
	END
	
		--accountNo
	IF @flag = 'txnDetail'
	BEGIN
		SELECT
			 controlNo = dbo.FNADecryptString(controlNo)													--M-20
			,benefName = rt.receiverName																	--M-50
			,benefAdddress = CAST( ISNULL(tr.ADDRESS,ISNULL(tr.city,'Kathmandu')) AS VARCHAR (95))																		--M-100
			,benefTel = tr.homePhone																		--O-50
			,benefMobile = tr.mobile																		--O-30
			,benefIdType = tr.idType 		
			,benefAccIdNo = CASE 
								WHEN rt.paymentMethod = 'CASH PAYMENT' THEN ISNULL(tr.idType, 'ReceiverID') + ':' + ISNULL(tr.idNumber , '0')
								ELSE rt.accountNo 
							END --M-30	
			,senderName = rt.senderName																		--M-50
			,senderAddress = CAST(ts.address AS VARCHAR(90))												--M-100
			,senderTel = COALESCE(ts.homePhone,ts.mobile)--,'01231231123')									--O-30
			,senderMobile = COALESCE(ts.mobile,ts.homePhone)--,'9876767676')								--O-30
			,senderIdType = ISNULL(ts.idType,'Passport')													--M-25
			,senderIdNo = ts.idNumber																		--M-25
			,purpose = rt.purposeOfRemit																	--O-25
			,remitType = CASE WHEN rt.paymentMethod = 'CASH PAYMENT' THEN 'ID' ELSE 'BANK' END				--M-4		
			,payingBankCd = ''	
			,payingBranchCd = ''																			--M-6
			,PayingBankBranchCd = rt.externalBankCode
			,rCurrency =rt.collCurr																		--M-4
			,localAmount = ROUND(rt.pAmt/rt.pCurrCostRate, 4)																		--M-Decimal(10, 2)
			,amount		= rt.pAmt																			--M-Decimal(10, 2)
			,serviceCharge	= ''														--M-Decimal(10, 2)
			,rCommission	= ''
			,exchangeRate = rt.pCurrCostRate																--M-Decimal(10, 2)
			,refNo = ts.idNumber --rt.id																					--O-20
			,remarks = CASE 
							WHEN rt.paymentMethod = 'CASH PAYMENT' THEN rt.pMessage	
							ELSE ISNULL(rt.pBankName, '') + ISNULL(', ' + rt.pBankBranchName, '')
						END																					--O-100
			,[source]  = rt.sourceOfFund																	--M-25
			,HitApi = CASE WHEN rt.tranStatus = 'Hold' AND rt.paymentMethod = 'BANK DEPOSIT' THEN dbo.FNAGetAPIStatus(1023) ELSE 0 END
			,newAccount = ISNULL(tr.isNewAc, 'N')
			,customerDOB= CASE WHEN tr.isNewAc='Y' THEN ISNULL(CONVERT(char(10), ts.dob,126),'1980-01-01') ELSE ISNULL(CONVERT(char(10), ts.dob,126),'') END
		FROM remitTranTemp rt WITH(NOLOCK)
		INNER JOIN tranSendersTemp ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceiversTemp tr WITH(NOLOCK) ON rt.id = tr.tranId
		WHERE rt.id = @id
		and rt.pagent= 1056
		RETURN
	END

	IF @flag = 'txnDetail-rp'
	BEGIN
		IF EXISTS(
			SELECT 'A'  
			FROM remitTran rt WITH(NOLOCK)
			WHERE (rt.id = @id OR rt.holdTranId = @id)
			AND tranStatus = 'Payment' AND payStatus = 'Unpaid'
			AND rt.externalBankCode IS NULL and paymentMethod='BANK DEPOSIT'
		)
		BEGIN
			UPDATE rt set rt.externalBankCode = a.ExtCode 
			FROM remitTran rt
			INNER JOIN AGENTMASTER A (NOLOCK) ON a.agentId = rt.pAgent
			WHERE (rt.id = @id OR rt.holdTranId = @id)
			AND tranStatus = 'Payment' AND payStatus = 'Unpaid'
			AND rt.externalBankCode IS NULL and paymentMethod='BANK DEPOSIT'
			
		END

		SELECT  
			 controlNo = dbo.FNADecryptString(controlNo)													--M-20
			,benefName = rt.receiverName																	--M-50
			,benefAdddress = CAST( ISNULL(tr.ADDRESS,ISNULL(tr.city,'Kathmandu')) AS VARCHAR (95))																			--M-100
			,benefTel = tr.homePhone																		--O-50
			,benefMobile = tr.mobile																		--O-30
			,benefIdType = CASE 
								WHEN tr.idType = 'National ID'	THEN 'Citizenship No' 
								WHEN tr.idType = 'Passport'	THEN 'Passport No' 
								WHEN tr.idType = 'Driving License' THEN 'Driving Licence No' 
								ELSE 'Others'
							END 		
			,benefAccIdNo = CASE 
								WHEN rt.paymentMethod = 'CASH PAYMENT' THEN ISNULL(tr.idType, 'ReceiverID') + ':' + ISNULL(tr.idNumber , '0')
								ELSE rt.accountNo 
							END --M-30	
			,senderName = rt.senderName																		--M-50
			,senderAddress = ISNULL(CAST(ts.ADDRESS AS varchar(90)), 'Seoul')								--M-100
			,senderTel = COALESCE(ts.homePhone,ts.mobile)--,'01231231123')									--O-30
			,senderMobile = COALESCE(ts.mobile,ts.homePhone)--,'9876767676')								--O-30
			,senderIdType = CASE 
								WHEN ts.idType = 'Alien Registration Card'	THEN 'Work Permit' 
								WHEN ts.idType IN ('National ID', 'Passport', 'Driving License') THEN ts.idType 
								WHEN ts.idType IS NULL THEN 'Passport'
								ELSE 'Others'
							END
			,senderIdNo = ts.idNumber																		--M-25
			,purpose = CASE 
							WHEN rt.purposeOfRemit = 'Family maintenance'	THEN 'Family maintenance' 
							WHEN rt.purposeOfRemit = 'Educational expenses'	THEN 'Education' 
							WHEN rt.purposeOfRemit = 'Medical Expenses'	THEN 'Medical' 
							WHEN rt.purposeOfRemit = 'Purchase of land / property' THEN 'Purchase of Fixed Assets' 
							ELSE 'Others'
						END																	--O-25
			,remitType = CASE WHEN rt.paymentMethod = 'CASH PAYMENT' THEN 'ID' ELSE 'BANK' END				--M-4
			,payingBankCd = ''	
			,payingBranchCd = ''																			--M-6
			,PayingBankBranchCd = CASE WHEN paymentMethod ='CASH PAYMENT' then '0' else isnull(rt.externalBankCode,'14') end
			,rCurrency = 'USD'	--rt.collCurr																		--M-4
			,localAmount = ROUND(rt.pAmt/rt.pCurrCostRate, 4)	--rt.tAmt																			--M-Decimal(10, 2)
			--,localAmount = ROUND(rt.pAmt/104.21, 4)	--rt.tAmt																			--M-Decimal(10, 2)
			,amount	= ROUND(rt.pAmt, 0)																				--M-Decimal(10, 2)
			,serviceCharge	= ''	--rt.serviceCharge																--M-Decimal(10, 2)
			,rCommission	= ''	--rt.pAgentComm
			--,exchangeRate = 104.21	--rt.customerRate																	--M-Decimal(10, 2)
			,exchangeRate = ROUND(rt.pCurrCostRate, 4)	--rt.customerRate																	--M-Decimal(10, 2)
			,refNo = ts.idNumber--rt.id																					--O-20
			,remarks = rt.pMessage																			--O-100
			,[source]  = CASE 
							WHEN rt.sourceOfFund = 'Lottery' THEN 'Lottery' 
							WHEN rt.sourceOfFund = 'Loan from bank'	THEN 'Loan' 
							WHEN rt.sourceOfFund = 'Salary / Wages'	THEN 'Salary savings' 
							ELSE 'Others'
						END																		--M-25
			,HitApi = CASE WHEN rt.tranStatus = 'Payment' AND rt.paymentMethod = 'BANK DEPOSIT' THEN 1 ELSE 0 END
			--,newAccount = ISNULL(tr.isNewAc, 'N')
			,newAccount = 'N'
			,customerDOB= CASE WHEN tr.isNewAc='Y' THEN ISNULL(CONVERT(char(10), ts.dob,126),'1980-01-01') ELSE ISNULL(CONVERT(char(10), ts.dob,126),'') END
			,checkAccount = CASE WHEN rt.holdTranId IS NULL THEN 'Y' ELSE 'N' END
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		WHERE (rt.id = @id OR rt.holdTranId = @id)
		AND tranStatus = 'Payment' AND payStatus = 'Unpaid'
		and pAgent = 1056 
		RETURN
	END

	IF @flag = 'approve'
	BEGIN
		DECLARE		 
			 @cAmt MONEY
			,@userId INT		
			,@createdBy	VARCHAR(50)
			,@sBranch INT
			,@pAgent INT
			,@invicePrintMethod VARCHAR(50)
			,@parentId INT
			,@tranStatus VARCHAR(50)

		SELECT
			 @cAmt = cAmt
			,@userId = au.userId 
			,@createdBy = r.createdBy
			,@controlNo = dbo.FNADecryptString(controlNo)
			,@controlNoEncrypted = controlNo
			,@sBranch	= sBranch
			,@tranStatus = r.transtatus
			,@rCountry = r.pCountry
			,@pAgent = case when r.pCountry='Nepal' and r.paymentMethod='CASH PAYMENT' then isnull(r.pAgent,1056) else r.pAgent end
		FROM remitTranTemp r WITH(NOLOCK)
		INNER JOIN applicationUsers au ON r.createdBy = au.userName 
		WHERE r.id = @id
		
		SELECT @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
			
		SELECT 
			@invicePrintMethod = invoicePrintMethod 
		FROM agentMaster A WITH(NOLOCK) 
		INNER JOIN agentBusinessFunction B WITH(NOLOCK) ON A.agentId = B.agentId
		WHERE A.agentId = @parentId
		
		SELECT top 1 @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @rCountry

		SELECT @pBranch=sBranch,@pAgent = sAgent,@pAgentName = sAgentName,@psAgent=sSuperAgent 
		FROM DBO.FNAGetBranchFullDetails(@pAgent)

		BEGIN TRANSACTION
		
			UPDATE remitTranTemp SET 
				 transtatus =	CASE @tranStatus
									WHEN 'Hold' THEN 'Payment'
									WHEN 'Compliance Hold' THEN 'Compliance'
									WHEN 'OFAC Hold' THEN 'OFAC'
									WHEN 'OFAC/Compliance Hold' THEN 'OFAC/Compliance'
									ELSE 'Payment'
								END
				,payStatus			= CASE WHEN @tranStatus = 'Hold' AND dbo.FNAGetAPIStatus(1023) = 1 THEN 'Post' ELSE payStatus END							
				,approvedBy			= @user
				,approvedDate		= dbo.FNADateFormatTZ(GETDATE(), @user)
				,approvedDateLocal	= GETDATE()
				,pAgentComm		= (SELECT amount FROM dbo.FNAGetPayComm
											(sBranch,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
												NULL, @psAgent, @pCountryId, null, @pBranch, sAgentCommCurrency
												,(select top 1 serviceTypeId from servicetypemaster(nolock) where typeTitle = paymentMethod)
												, cAmt, pAmt, serviceCharge, NULL, NULL
											))
				,pAgentCommCurrency	= sAgentCommCurrency
				,pAgent				= @pAgent
				,pAgentName			= @pAgentName
				
			WHERE id = @id
			
			INSERT INTO PinQueueList(ICN)
			SELECT @controlNoEncrypted
			
			DECLARE @tranIdNew BIGINT
			EXEC proc_remitTranTempToRemitMain @id 
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		IF @invicePrintMethod = 'aa'
			EXEC proc_errorHandler 11, 'Transaction Approved Successfully', @controlNo
		ELSE
			EXEC proc_errorHandler 0, 'Transaction Approved Successfully', @controlNo		
		RETURN
	
		RETURN		
	END

	IF @flag = 'rp-re'
	BEGIN
		
		SELECT @controlNo = dbo.FNADecryptString(controlNo), @controlNoEncrypted = controlNo ,@rCountry = pCountry
				,@pAgent = pAgent
		FROM dbo.remitTran WITH(NOLOCK) WHERE id = @id OR holdTranId = @id

		SELECT top 1 @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @rCountry

		SELECT @pBranch=sBranch,@pAgent = sAgent,@pAgentName = sAgentName,@psAgent=sSuperAgent 
		FROM DBO.FNAGetBranchFullDetails(@pAgent)

		BEGIN TRANSACTION

		IF @errorCode = '0' OR @tpErrorCode = 'R900'						
		BEGIN
			INSERT INTO tpTxnList(tranId, controlNo, transferredDate, pAgent, status)
            SELECT @id, @controlNoEncrypted, GETDATE(), @gblPayAgentId, 'Unpaid'

			UPDATE remitTran SET				  
				 payStatus			= 'Post'
				 ,pAgentComm		= (SELECT amount FROM dbo.FNAGetPayComm
											(sBranch,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
												NULL, @psAgent, @pCountryId, null, @pBranch, sAgentCommCurrency
												,(select top 1 serviceTypeId from servicetypemaster(nolock) where typeTitle = paymentMethod)
												, cAmt, pAmt, serviceCharge, NULL, NULL
											))
				,pAgentCommCurrency	= sAgentCommCurrency
				,pAgent				= @pAgent
				,pAgentName			= @pAgentName
				,postedBy			= @user
				,postedDate			= GETDATE()
			WHERE id = @id OR holdTranId = @id			
		END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		IF @errorCode = '0'		
			SELECT 0 errorCode, 'Transaction ' + @controlNo + ' Re-processed Successfully' msg, @id id		
		ELSE IF @msg = 'Remit Already Exists' OR @tpErrorCode = 'R900'
			SELECT 0 errorCode, 'Transaction ' + @controlNo + ' already existed in Global IME Bank Remit. Marked as post in our system.' msg, @id id		
		ELSE
			EXEC proc_errorHandler @errorCode, @msg, @id		
		RETURN

	END

	IF @flag = 'c'
	BEGIN
		INSERT INTO thirdPartyTxnLogS(provider,msg,createdBy,createdDate,transferNumber)
		SELECT @gblPayAgentId,'cancel',@user,GETDATE(),dbo.FNAEncryptString(@controlNo)		
		EXEC proc_errorHandler 0, 'Transaction has been cancelled Successfully', null
		RETURN
	END

	IF @flag = 'sps'
	BEGIN
		DECLARE @PinList TABLE(pin VARCHAR(50), pinStatus VARCHAR(50))
		
		INSERT @PinList
		SELECT
			 dbo.FNAEncryptString(p.value('@pin','VARCHAR(50)')) as cn	
			,p.value('@status','VARCHAR(50)')	
		FROM @xmlAPI.nodes('/root/row') as tmp(p)
		WHERE ISNUMERIC(p.value('@pin','VARCHAR(50)')) = 1

		UPDATE r SET
			  tranStatus				= 'Paid'
			 ,payStatus 				= 'Paid'
			 ,lockStatus				= 'unlocked'
			 ,paidBy					= @user
			 ,paidDate					= ISNULL(paidDate, GETDATE())
			 ,paidDateLocal				= ISNULL(paidDateLocal, DBO.FNADateFormatTZ(GETDATE(), @user))
		FROM remitTran r WITH(NOLOCK)
		INNER JOIN @PinList p ON r.controlNo = p.pin 
			AND r.pAgent = @gblPayAgentId
			AND r.payStatus <> 'Paid'
			AND p.pinStatus = 'Paid'
		
		UPDATE dbo.tpTxnList 
			 SET status = 'Paid'
		FROM dbo.tpTxnList tp
		INNER JOIN @PinList p ON tp.controlNo = p.pin
		WHERE p.pinStatus = 'Paid'

		EXEC proc_errorHandler 0, 'Paid Transaction(s) Synchronized Successfully', null
		RETURN
	END

	IF @flag = 's'
	BEGIN
		SELECT 
			id							= r.id
			,senderName					= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,receiverName				= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')			
			,controlNo					= dbo.FNADecryptString(r.controlNo)
			,pin					    = dbo.FNADecryptString(r.controlNo)
			,pAmt						= r.pAmt		
			,createdDate				= CONVERT(VARCHAR, r.createdDate, 101)
			,r.tranStatus				
			,r.payStatus 
		FROM remitTran r  WITH(NOLOCK) 
		LEFT JOIN tranSenders sen  WITH(NOLOCK) ON r.id = sen.tranId
		LEFT JOIN tranReceivers rec  WITH(NOLOCK) ON r.id = rec.tranId 
		WHERE r.approvedDate BETWEEN @syncDate AND @syncDate + ' 23:59:59'
		AND r.pAgent = @gblPayAgentId
		RETURN
	END
	
	IF @flag = 'get-detail'
	BEGIN
		SELECT RT.receiverName, dbo.decryptDb(RT.controlNo) controlNo, RT.accountNo
		FROM dbo.remitTran RT (NOLOCK)
		WHERE id = @id
		RETURN
	END

	IF @flag = 'updateTT'
	BEGIN
		SET @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		BEGIN TRAN
			IF NOT EXISTS(SELECT 'X' FROM dbo.tranModifyLog WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND message = 'NAME AND ACCOUNT NUMBER DIFFERS')
			BEGIN
				INSERT INTO dbo.tranModifyLog(controlNo, message, createdBy, createdDate)
				SELECT @controlNoEncrypted, 'NAME AND ACCOUNT NUMBER DIFFERS', 'system', GETDATE()
			END
			
		COMMIT TRAN
		
		EXEC dbo.proc_errorHandler 0, 'NAME AND ACCOUNT NUMBER DIFFERS', NULL
	END
	
	IF @flag = 'uaf'
	BEGIN
		DECLARE @tranId BIGINT
		SET @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		SELECT @tranId = id FROM dbo.remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		
		UPDATE dbo.tranReceivers SET isNewAc = 'Y' WHERE tranId = @tranId
		
		EXEC dbo.proc_errorHandler 0, 'Is New Account flag Updated to Y', NULL
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT 1 error_code, ERROR_MESSAGE() mes, ERROR_LINE() id

	INSERT INTO dbErrorLog(spName, flag, errorMsg, errorLine, createdBy, createdDate)
	SELECT ERROR_PROCEDURE(), @flag, ERROR_MESSAGE(), ERROR_LINE(), @user, GETDATE()
END CATCH
GO
