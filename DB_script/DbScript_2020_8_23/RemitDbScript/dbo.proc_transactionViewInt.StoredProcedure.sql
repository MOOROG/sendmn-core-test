USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionViewInt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_transactionViewInt](
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@tranId			VARCHAR(50)		= NULL
	,@message			VARCHAR(500)	= NULL
	,@messageComplaince VARCHAR(500)	= NULL
	,@messageOFAC		VARCHAR(500)	= NULL
	,@lockMode			CHAR(1)			= NULL
	,@viewType			VARCHAR(50)		= NULL
	,@viewMsg			VARCHAR(MAX)	= NULL
	,@branch			INT				= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
	,@ip				VARCHAR(100)	= NULL
	,@dcInfo			VARCHAR(100)	= NULL
)
AS
	DECLARE 
	   @select_field_list VARCHAR(MAX)
	   ,@extra_field_list  VARCHAR(MAX)
	   ,@table             VARCHAR(MAX)
	   ,@sql_filter        VARCHAR(MAX)
	
	DECLARE @controlNoEncrypted VARCHAR(100)
	   ,@code						VARCHAR(50)
	   ,@userName					VARCHAR(50)
	   ,@password					VARCHAR(50)	
	   ,@userType					VARCHAR(10)
	   ,@tranStatus					VARCHAR(50)
	   ,@tranIdType					CHAR(1)
	   ,@voucherNo					VARCHAR(50)
	   ,@holdTranId					INT
		
SET NOCOUNT ON;
SET XACT_ABORT ON;
	
SET  @tranIdType = DBO.FNAGetTranIdType(@tranId)
	
IF @controlNo IS NOT NULL
BEGIN
	SET @controlNo = UPPER(@controlNo)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	SELECT @tranId = id, @tranStatus = tranStatus,@holdTranId =holdTranId FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted	
END

ELSE IF @tranId IS NOT NULL
BEGIN
	IF @tranIdType ='H'  --- h - remitTRanTemp , c-  remitTran
		SELECT @controlNoEncrypted = controlNo, @tranStatus = tranStatus,@voucherNo = voucherNo,@holdTranId =holdTranId ,@controlNo = dbo.FNADecryptString(controlNo)
		FROM vwremitTran WITH(NOLOCK) WHERE holdTranId = @tranId
	ELSE
		SELECT @controlNoEncrypted = controlNo, @tranStatus = tranStatus,@voucherNo = voucherNo,@holdTranId =holdTranId ,@controlNo = dbo.FNADecryptString(controlNo)
		FROM remitTran WITH(NOLOCK) WHERE id = @tranId
END

IF @flag = 's'
BEGIN

	
	IF OBJECT_ID('tempdb..#countryHead') IS NOT NULL
	DROP TABLE #countryHead

	-->> IMPORT FROM OLD DB 
	IF @tranStatus IS NULL
	BEGIN				
		SELECT 
			 @tranStatus			= tranStatus
			,@tranId				= id 
			,@controlNoEncrypted	= controlNo
			,@voucherNo				= voucherNo
			,@holdTranId			= id
		FROM vwremitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		
	END	
	
	IF @tranStatus IS NULL
	BEGIN
		SELECT * FROM remitTranTemp WITH (NOLOCK) WHERE 1=2
		RETURN;
	END	
		
	CREATE TABLE #countryHead(userName VARCHAR(200),branchId VARCHAR(50))
	IF @userType IS NULL
	BEGIN
		SELECT @userType = userType FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	END	
	EXEC proc_tranViewHistoryInt 'i', @user, @tranId, @controlNoEncrypted, NULL, @viewType, @viewMsg, @ip, @dcInfo	
		
	--## Transaction Details
	SET @table='SELECT 
		 tranId				= case when trn.id = trn.holdTranId THEN NULL ELSE trn.id END 
		,holdTranId			= ISNULL(CAST(trn.holdTranId AS VARCHAR),''-'')
		,controlNo			= dbo.FNADecryptString(trn.controlNo)
		
		-->> Sender Information
		,sMemId				= sen.membershipId
		,sCustomerId		= sen.customerId
		,senderName			= sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
		,sCountryName		= sen.country
		,sCity				= sen.city
		,sAddress			= sen.address
		,sContactNo			= sen.mobile
		,sTelNo				= ISNULL(sen.homephone, sen.workphone)
		,sIdType			= sen.idType
		,sIdNo				= sen.idNumber
		,sValidDate			= sen.validDate
		,sEmail				= sen.email
		,nativeCountry		= sen.nativeCountry
			
		-->> Receiver Information
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
		,rCountryName = rec.country
		,rCity = rec.city
		,rAddress = rec.address
		,rContactNo = rec.mobile
		,rTelNo = ISNULL(rec.homephone, rec.workphone)
		,rIdType = ISNULL(rec.idType, rec.idType2)
		,rIdNo = ISNULL(rec.idNumber, rec.idNumber2)
		,rValidDate = ISNULL(rec.validDate,rec.validDate2)
		
		
		-->> Sending Agent Information
		,sAgentName = trn.sAgentName --CASE WHEN trn.sAgentName = trn.sBranchName THEN ''-'' ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,sAgentState = ''''
		,sAgentDistrict = ''''
		,sAgentLocation = ''''
		,sAgentCity = sa.agentCity
		,sAgentAddress = sa.agentAddress
		
		-->> Payout Agent Information
		,pAgentName = trn.pAgentName --CASE WHEN trn.pAgentName = trn.pBranchName THEN ''-'' ELSE trn.pAgentName END
		,pBranchName = trn.pBranchName
		,pAgentCountry = trn.pCountry
		,pAgentState = ''''
		,pAgentDistrict = ''''
		,pAgentLocation = ''''
		,pAgentCity = pa.agentCity
		,pAgentAddress = pa.agentAddress
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,sAgentComm = isnull(sAgentComm,0)
		,sAgentCommCurrency = ISNULL(sAgentCommCurrency,0)
		,pAgentComm = ISNULL(pAgentComm,0)
		,pAgentCommCurrency = ISNULL(pAgentCommCurrency,0)
		,exRate = customerRate
		,trn.cAmt
		,pAmt = FLOOR(trn.pAmt)
		,CashOrBank = CASE WHEN UPPER(trn.paymentMethod) =''BANK DEPOSIT'' THEN ''BANK'' ELSE ''CASH'' END
		,relationship = ISNULL(trn.relWithSender, ''-'')
		,purposeOfRemit = ISNULL(trn.purposeOfRemit, ''-'')
		,sourceOfFund = ISNULL(trn.sourceOfFund, ''-'')
		,collMode = trn.collMode
		,trn.collCurr
		,paymentMethod = UPPER(trn.paymentMethod)
		,trn.payoutCurr
		,BranchName = trn.pBankBranchName
		,accountNo = case WHEN trn.payStatus =''Post'' then trn.accountNo + '' <font color="red" style="font-weight: bold">[Post User: ''+trn.postedBy+'', Date: ''+CAST(trn.postedDate as VARCHAR)+'']</font>'' else trn.accountNo end
		,BankName = trn.pBankName
		,tranStatus = case when trn.id = trn.holdTranId THEN ''Payment'' ELSE trn.tranStatus END 
		,trn.payStatus
		,custRate = isnull(customerRate,0) +isnull(schemePremium,0)
		,settRate = agentCrossSettRate
		,payoutMsg = ISNULL(trn.pMessage, ''-'')
		,trn.createdBy
		,trn.createdDate
		,trn.approvedBy
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.cancelRequestBy
		,trn.cancelRequestDate
		,trn.cancelApprovedBy
		,trn.cancelApprovedDate
		,trn.lockedBy
		,trn.lockedDate
		,trn.payTokenId
		,trn.tranType
		,trn.pAgent
		,expectedPayoutAgent = ISNULL(trn.expectedPayoutAgent,''[Any Where]'')
		,sen.txnTestQuestion
		,sen.txnTestAnswer
		,trnStatusBeforeCnlReq = case when trn.trnStatusBeforeCnlReq = ''Payment'' 
										then ''Approved Transaction'' 
								when trn.trnStatusBeforeCnlReq = ''Paid''  then ''Transaction on PAID'' 
								when trn.trnStatusBeforeCnlReq = ''Post''  then ''Transaction on POST'' 
								else ''Transaction on ''+trnStatusBeforeCnlReq
								 end
	FROM vwremitTran trn WITH(NOLOCK)
	LEFT JOIN vwtranSenders  sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN vwtranReceivers  rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle'
	

	SET @table=@table+ ' WHERE trn.controlNo = '''+@controlNoEncrypted+''''

	IF @userType='CH'
	BEGIN
		INSERT #countryHead
		SELECT x.userName,x.agentId FROM dbo.FNAAgentUserListForCH(@user) x WHERE userId IS NOT NULL
		SET @table=@table+ ' AND (trn.sBranch IN (SELECT branchId FROM #countryHead) OR (trn.pBranch IN(SELECT branchId FROM #countryHead)))'
	END
	PRINT(@table)
		
	EXEC(@table)
		
	--## Lock Transaction
	IF (@lockMode = 'Y')
	BEGIN
		IF @viewType <> 'CANCEL'
		BEGIN
			IF @tranStatus LIKE '%Hold%'
			BEGIN
				UPDATE remitTranTemp SET
					 tranStatus = 'Lock'
					,lockedBy = @user
					,lockedDate = GETDATE()
					,lockedDateLocal = dbo.FNADateFormatTZ(GETDATE(), @user)
				WHERE (tranStatus = 'Payment' AND tranStatus <> 'CancelRequest') 
				  AND payStatus = 'Unpaid' AND controlNo = @controlNoEncrypted
			END
			ELSE
			BEGIN
				UPDATE remitTran SET
					 tranStatus = 'Lock'
					,lockedBy = @user
					,lockedDate = GETDATE()
					,lockedDateLocal = dbo.FNADateFormatTZ(GETDATE(), @user)
				WHERE (tranStatus = 'Payment' AND tranStatus <> 'CancelRequest') 
				  AND payStatus = 'Unpaid' AND controlNo = @controlNoEncrypted 
			END
		END
	END
	

	--## Log Details
	SELECT 
		 rowId
		,MESSAGE
		,msgType
		,trn.createdBy
		,trn.createdDate
		,ISNULL(trn.fileType,'')fileType
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.controlNo = @controlNoEncrypted OR tranId = @tranId OR tranid = @holdTranId
	ORDER BY trn.createdDate DESC

	--## COLLECTION DETAIL
	
	SELECT @tranId = ID, @voucherNo = voucherNo FROM remitTran WITH(NOLOCK) 
	WHERE (controlNo = @controlNoEncrypted OR id = @tranId)
	
	SELECT 
		 bankName = ISNULL(B.bankName, 'Cash')
		,collMode
		,amt = ISNULL(amt, 0)
		,collDate
		,voucherNo = @voucherNo
		,narration
	FROM collectionDetails C WITH (NOLOCK)
	LEFT JOIN countryBanks B WITH (NOLOCK) ON C.countryBankId = B.countryBankId 
    WHERE tranId = @holdTranId
    AND C.countryBankId = B.countryBankId

END

--## Add Complain (Trouble Ticket)
ELSE IF @flag = 'ac'	
BEGIN TRY

	IF @message IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Message can not be blank.', @tranId
		RETURN
	END
	
	IF @tranId IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction No can not be blank.', @tranId
		RETURN
	END

	INSERT INTO tranModifyLog(
		 tranId
		,controlNo
		,MESSAGE
		,createdBy
		,createdDate
		,MsgType
		,status
	)
	SELECT
		 @tranId
		,@controlNoEncrypted
		,@message
		,@user
		,GETDATE()
		,'COMPLAIN'
		,'Not Resolved'
	EXEC proc_errorHandler 0, 'Comments has been added successfully.', @tranId
	
	
END TRY
BEGIN CATCH

	 SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id

END CATCH

--## Log Details
ELSE IF @flag = 'showLog'	
BEGIN 

	SELECT 
		 rowId
		,MESSAGE
		,msgType
		,trn.createdBy
		,trn.createdDate
		,ISNULL(trn.fileType,'') fileType
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.tranId = @tranId
	ORDER BY trn.createdDate DESC
	
END 

ELSE IF @flag='OFAC'
BEGIN
/*
EXEC proc_transactionView @flag = 'OFAC', @tranId = '10000045'
select * from dbo.remitTranOfac
select * from remitTranCompliance
select * from blackList where entNum=10009
select * from blackList where rowId=12822
*/

	IF @controlNoEncrypted IS NOT NULL
		SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL 
	DROP TABLE #tempMaster
	
	IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL 
	DROP TABLE #tempDataTable
		

	CREATE TABLE #tempDataTable
	(
		DATA VARCHAR(MAX) NULL
	)
	
	DECLARE @ofacKeyIds VARCHAR(MAX)
	SELECT @ofacKeyIds=blackListId FROM dbo.remitTranOfac 
	WHERE TranId = ISNULL(@holdTranId, @tranId)

	SELECT distinct A.val ofacKeyId
	INTO #tempMaster
	FROM
	(
		SELECT * FROM dbo.SplitXML(',',@ofacKeyIds)
	)A
	INNER JOIN
	(
		SELECT ofacKey FROM blacklistHistory WITH(NOLOCK)
	)B ON A.val=B.ofacKey
	
	ALTER TABLE #tempMaster ADD ROWID INT IDENTITY(1,1)

	DECLARE @TNA_ID AS INT
			,@MAX_ROW_ID AS INT
			,@ROW_ID AS INT=1
			,@ofacKeyId VARCHAR(100)
			,@SDN VARCHAR(MAX)=''
			,@ADDRESS VARCHAR(MAX)=''
			,@REMARKS AS VARCHAR(MAX)=''
			,@ALT AS VARCHAR(MAX)=''
			,@DATA AS VARCHAR(MAX)=''
			,@DATA_SOURCE AS VARCHAR(200)=''
	
	SELECT @MAX_ROW_ID=MAX(ROWID) FROM #tempMaster	
	WHILE @MAX_ROW_ID >=  @ROW_ID
	BEGIN	
		
		SELECT @ofacKeyId=ofacKeyId FROM #tempMaster WHERE ROWID=@ROW_ID		

		SELECT @SDN='<b>'+ISNULL(entNum,'')+'</b>,  <b>Name:</b> '+ ISNULL(name,''),@DATA_SOURCE='<b>Data Source:</b> '+ISNULL(dataSource,'')
		FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'		
		
		SELECT @ADDRESS=ISNULL(address,'')+', '+ISNULL(city,'')+', '+ISNULL(STATE,'')+', '+ISNULL(zip,'')+', '+ISNULL(country,'')
		FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='add'
		
		SELECT @ALT = COALESCE(@ALT + ', ', '') +CAST(ISNULL(NAME,'') AS VARCHAR(MAX))
		FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType IN ('alt','aka')			
				
		SELECT @REMARKS=ISNULL(remarks,'')
		FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'

		SET @SDN=RTRIM(LTRIM(@SDN))
		SET @ADDRESS=RTRIM(LTRIM(@ADDRESS))
		SET @ALT=RTRIM(LTRIM(@ALT))
		SET @REMARKS=RTRIM(LTRIM(@REMARKS))	
		
		SET @SDN=REPLACE(@SDN,', ,','')
		SET @ADDRESS=REPLACE(@ADDRESS,', ,','')
		SET @ALT=REPLACE(@ALT,', ,','')
		SET @REMARKS=REPLACE(@REMARKS,', ,','')
		
		SET @SDN=REPLACE(@SDN,'-0-','')
		SET @ADDRESS=REPLACE(@ADDRESS,'-0-','')
		SET @ALT=REPLACE(@ALT,'-0-','')
		SET @REMARKS=REPLACE(@REMARKS,'-0-','')
		
		SET @SDN=REPLACE(@SDN,',,','')
		SET @ADDRESS=REPLACE(@ADDRESS,',,','')
		SET @ALT=REPLACE(@ALT,',,','')
		SET @REMARKS=REPLACE(@REMARKS,',,','')
		
		IF @DATA_SOURCE IS NOT NULL AND @DATA_SOURCE<>'' 
			SET @DATA=@DATA_SOURCE
			
		IF @SDN IS NOT NULL AND @SDN<>'' 
			SET @DATA=@DATA+'<BR>'+@SDN
			
		IF @ADDRESS IS NOT NULL AND @ADDRESS<>'' 
			SET @DATA=@DATA+'<BR><b>Address: </b>'+@ADDRESS
			
		IF @ALT IS NOT NULL AND @ALT<>'' AND @ALT<>' '
			SET @DATA=@DATA+'<BR>'+'<b>a.k.a :</b>'+@ALT+''

		IF @REMARKS IS NOT NULL AND @REMARKS<>'' 
			SET @DATA=@DATA+'<BR><b>Other Info :</b>'+@REMARKS

		IF @DATA IS NOT NULL OR @DATA <>''
		BEGIN
			INSERT INTO #tempDataTable		
			SELECT REPLACE(@DATA,'<BR><BR>','')
		END
		
		SET @ROW_ID=@ROW_ID+1
	END
		
	ALTER TABLE #tempDataTable ADD ROWID INT IDENTITY(1,1)
	SELECT ROWID [S.N.],DATA [Remarks] FROM #tempDataTable
	
END

ELSE IF @flag='Compliance'
BEGIN
	SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo)
	
	SELECT
		 rowId
		,csDetailRecId 
		,[S.N.]		= ROW_NUMBER()OVER(ORDER BY ROWID)	
		,[Remarks]	= ISNULL( RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' + 
						CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
							 WHEN checkType = 'Count' THEN 'Transaction Count' END
						+ ' exceeds ' + CAST(PARAMETER AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)   
						,reason)
		,[Matched TRAN ID] = ISNULL(rtc.matchTranId,rtc.TranId)
	FROM remitTranCompliance rtc WITH(NOLOCK)
	LEFT JOIN csDetailRec cdr WITH(NOLOCK) ON rtc.csDetailTranId = cdr.csDetailRecId 
	WHERE rtc.TranId = ISNULL(@holdTranId, @tranId)
END

ELSE IF @flag='COMPL_DETAIL'
BEGIN
/*
5000	By Sender ID
5001	By Sender Name
5002	By Sender Mobile
5003	By Beneficiary ID
5004	By Beneficiary ID(System)
5005	By Beneficiary Name
5006	By Beneficiary Mobile
5007	By Beneficiary A/C Number
*/
	DECLARE @tranIds AS VARCHAR(MAX), @criteria AS INT, @totalTran AS INT, @criteriaValue AS VARCHAR(500), @id AS INT,@reason VARCHAR(500)
	SELECT 
		@tranIds = matchTranId, 
		@id = TranId 
	FROM remitTranCompliance WITH(NOLOCK) 
	WHERE rowId = @controlNo --(ROWID) --id of remitTranCompliance

	SELECT @criteria = criteria FROM csDetailRec WITH(NOLOCK) WHERE csDetailRecId = @tranId--id of csDetailRec
	SELECT @totalTran = COUNT(*) FROM dbo.Split(',', @tranIds)
		
	IF @criteria='5000'
		SELECT @criteriaValue = B.membershipId
			 FROM tranSenders B WITH(NOLOCK) WHERE B.tranId = @id			 
			 
	IF @criteria='5001'
		SELECT @criteriaValue = ISNULL(B.firstName, '') + ISNULL(' ' + B.middleName, '') + ISNULL(' ' + B.lastName1, '') + ISNULL(' ' + B.lastName2, '')
			 FROM tranSenders B WITH(NOLOCK) WHERE B.tranId = @id	
			 
	IF @criteria='5002'
		SELECT @criteriaValue = B.mobile
			 FROM tranSenders B WITH(NOLOCK) WHERE B.tranId = @id	
			 
	IF @criteria='5003'
		SELECT @criteriaValue = B.membershipId
			 FROM tranReceivers B WITH(NOLOCK) WHERE B.tranId = @id	
			 
	IF @criteria='5004'
		SELECT @criteriaValue = B.membershipId
			 FROM tranReceivers B WITH(NOLOCK) WHERE B.tranId = @id
			 
	IF @criteria='5005'
		SELECT @criteriaValue = ISNULL(B.firstName, '') + ISNULL(' ' + B.middleName, '') + ISNULL(' ' + B.lastName1, '') + ISNULL(' ' + B.lastName2, '')
			 FROM tranReceivers B WITH(NOLOCK) WHERE B.tranId = @id
	
	IF @criteria='5006'
		SELECT @criteriaValue = B.mobile
			 FROM tranReceivers B WITH(NOLOCK) WHERE B.tranId = @id		
	
	IF @criteria='5007'
		SELECT @criteriaValue = A.accountNo
			 FROM remitTran A WITH(NOLOCK) WHERE A.id = @id	
			 
	-- @tranId=0 LOGIC IS ONLY FOR Suspected duplicate transaction  WHERE THERE IS csDetailRecId ALWAYS 0
			 
	SELECT
		 REMARKS	= CASE WHEN @tranId = 0 THEN @reason ELSE
						RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' + 
						CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
							 WHEN checkType = 'Count' THEN 'Transaction Count' END
						+ ' exceeds ' + CAST(PARAMETER AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)+': <font size=''2px''>'+ISNULL(@criteriaValue,'')+'</font>'
						END
		,totTran	= 'Total Count: <b>'+ CASE WHEN @tranId = 0 THEN '1' ELSE  CAST(@totalTran AS VARCHAR) END +'</b>'
	FROM csDetailRec WITH(NOLOCK)
	WHERE csDetailRecId= CASE WHEN @tranId=0 THEN 1 ELSE @tranId END

	SELECT 
		 [S.N.]			= ROW_NUMBER() OVER(ORDER BY @controlNo)
		,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)
		,[TRAN AMOUNT]	= dbo.ShowDecimal(trn.cAmt) 
		,[CURRENCY]		= trn.collCurr 
		,[TRAN DATE]	= CONVERT(VARCHAR,trn.createdDate,101)  		
	FROM VWremitTran trn WITH(NOLOCK) INNER JOIN 
	(
		SELECT * FROM dbo.Split(',', @tranIds)
	)B ON trn.holdTranId = B.value
	
	UNION ALL
	---- RECORD DISPLAY FROM CANCEL TRANSACTION TABLE
	SELECT 
		 [S.N.]			= ROW_NUMBER() OVER(ORDER BY @controlNo)
		,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)
		,[TRAN AMOUNT]	= dbo.ShowDecimal(trn.cAmt) 
		,[CURRENCY]		= trn.collCurr 
		,[TRAN DATE]	= CONVERT(VARCHAR,trn.createdDate,101)  		
	FROM cancelTranHistory trn WITH(NOLOCK) INNER JOIN 
	(
		SELECT * FROM dbo.Split(',', @tranIds)
	)B ON trn.tranId = B.value

END

--## Approve Complaince/OFAC 
ELSE IF @flag = 'saveComplainceRmks'
BEGIN
	IF EXISTS(SELECT 'X' FROM remitTranOfac WITH(NOLOCK) WHERE TranId = @holdTranId)
	BEGIN
		IF EXISTS(SELECT 'X' FROM remitTranCompliance WITH(NOLOCK) WHERE TranId = @holdTranId)
		BEGIN
			IF @messageOFAC IS NULL
			BEGIN		
				EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @holdTranId
				RETURN;		
			END	
			IF @messageComplaince IS NULL
			BEGIN		
				EXEC proc_errorHandler 1, 'Complaince remarks can not be blank.', @holdTranId
				RETURN;		
			END	
		END
		ELSE
		BEGIN
			IF @messageOFAC IS NULL
			BEGIN		
				EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @holdTranId
				RETURN;		
			END			
		END
	END
	
	IF EXISTS(SELECT 'X' FROM remitTranCompliance WITH(NOLOCK) WHERE TranId=@holdTranId)
	BEGIN
		IF @messageComplaince IS NULL
		BEGIN		
			EXEC proc_errorHandler 1, 'Complaince remarks can not be blank.', @holdTranId
			RETURN;		
		END	
	END
	
     BEGIN TRANSACTION
	    UPDATE remitTranOfac SET 
			approvedRemarks		= @messageOFAC
		    ,approvedBy			= @user
		    ,approvedDate		= GETDATE() 
	    WHERE TranId = ISNULL(@holdTranId, @tranId) AND approvedBy IS NULL
    	
	    UPDATE remitTranCompliance SET 
			approvedRemarks		= @messageComplaince
		    ,approvedBy			= @user
		    ,approvedDate		= GETDATE() 
	    WHERE TranId = ISNULL(@holdTranId, @tranId) AND approvedBy IS NULL
    	  
	    UPDATE remitTran SET 
			tranStatus			= 'Payment'
	    WHERE id = @tranId

	   -- UPDATE irh_ime_plus_01.dbo.moneySend
			 --SET TransStatus	= 'Payment'
	   -- WHERE refno = @controlNoEncrypted

    COMMIT TRANSACTION

	EXEC proc_errorHandler 0, 'Release remarks has been saved successfully.', @tranId	
END

--EXEC proc_transactionView @FLAG='chkFlag',@tranId='26'
ELSE IF @flag = 'chkFlagOFAC'		
BEGIN 
	SELECT CASE WHEN approvedDate IS NULL THEN 'N' ELSE 'Y'  END AS Compliance_FLAG
	FROM remitTranOfac WITH(NOLOCK) WHERE TranId = @holdTranId
END

ELSE IF @flag = 'chkFlagCOMPLAINCE'		
BEGIN 
	SELECT CASE WHEN approvedDate IS NULL THEN 'N' ELSE 'Y'  END AS Compliance_FLAG
	FROM remitTranCompliance WITH(NOLOCK) WHERE TranId = @holdTranId
END

ELSE IF @flag = 'va'			--Verify Agent For Tran Modification
BEGIN
	--Necessary paremeter: @user, @branch, @controlNo
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo) AND sBranch = @branch)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction not found', NULL
		RETURN
	END
	EXEC proc_errorHandler 0, 'Success', NULL
END
GO
