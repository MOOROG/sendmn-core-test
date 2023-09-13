SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROC [dbo].[proc_RSPTXN_report]
	 @flag				VARCHAR(10) = NULL
	,@user				VARCHAR(30) = NULL
	,@pCountry			VARCHAR(100)= NULL
	,@pAgent			VARCHAR(40) = NULL
	,@pBranch			VARCHAR(40) = NULL	
	,@sBranch			VARCHAR(40) = NULL		
	,@depositType		VARCHAR(40) = NULL
	,@searchBy			VARCHAR(40) = NULL
	,@searchByValue		VARCHAR(40) = NULL
	,@orderBy			VARCHAR(40) = NULL
	,@status			VARCHAR(40) = NULL
	,@paymentType		VARCHAR(40) = NULL
	,@dateField			VARCHAR(50) = NULL
	,@dateFrom			VARCHAR(20) = NULL
	,@dateTo			VARCHAR(20) = NULL
	,@transType			VARCHAR(40) = NULL
	,@displayTranNo		CHAR(1)		= NULL
	,@pageNumber		INT			= NULL
	,@pageSize			INT			= NULL
	,@rptType			CHAR(1)		= NULL
	AS

	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#listBranch') IS NOT NULL
		DROP TABLE #listBranch
	DECLARE @SQL VARCHAR(MAX),@userType varchar(2),@regionalBranchId INT,@branchId INT,@parentId INT,@agetntType varchar(5)
	CREATE TABLE #listBranch (branchId INT,branchName VARCHAR(200))

	SELECT @userType = usertype,@regionalBranchId = @sBranch 
	FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

	IF @userType = 'RH'
	BEGIN
		SELECT @parentId = B.agentId, @agetntType = B.agentType FROM agentMaster B WITH (NOLOCK) 
		INNER JOIN applicationUsers AU WITH (NOLOCK) ON B.agentId=AU.agentId WHERE AU.userName = @user
		
		IF @agetntType = 2903
		BEGIN
			INSERT INTO #listBranch
			SELECT agentId, agentName 
			FROM agentMaster WITH(NOLOCK) 
			WHERE parentId = @parentId
			AND ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isActive, 'N') = 'Y'
			AND agentId = ISNULL(@sBranch, agentId)
			ORDER BY agentName
		END
		ELSE IF @agetntType = 2904
		BEGIN
			
			SELECT @parentId = parentId FROM agentMaster(NOLOCK) WHERE agentId = @parentId and agentType = 2904

			SELECT agentId, agentName FROM agentMaster WITH(NOLOCK) 
			WHERE parentId = @parentId
			AND ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isActive, 'N') = 'Y'
			AND agentId = ISNULL(1056, agentId)
			ORDER BY agentName
		END
	END
	ELSE IF @userType ='HO'
	BEGIN
		INSERT INTO #listBranch
		SELECT b.agentId branchId, b.agentName branchName 
		FROM agentMaster a WITH(NOLOCK)
		INNER JOIN agentMaster b WITH(NOLOCK) ON  b.parentId = a.agentId
		WHERE ISNULL(b.isDeleted, 'N') <> 'Y'
				AND b.agentType = '2904' 
				AND ISNULL(a.isActive, 'N') = 'Y'
				AND a.isInternal ='Y'
				AND b.agentId=ISNULL(@sBranch,b.agentId)
	END
	ELSE IF @userType ='AH'
	BEGIN
		SELECT @parentId = B.agentId, @agetntType = B.agentType FROM agentMaster B WITH (NOLOCK) 
		INNER JOIN applicationUsers AU WITH (NOLOCK) ON B.agentId=AU.agentId WHERE AU.userName = @user
		
		IF @agetntType = 2903
		BEGIN
			INSERT INTO #listBranch
			SELECT agentId, agentName 
			FROM agentMaster WITH(NOLOCK) 
			WHERE parentId = @parentId
			AND ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isActive, 'N') = 'Y'
			AND agentId = ISNULL(@sBranch, agentId)
			ORDER BY agentName
		END
		ELSE IF @agetntType = 2904
		BEGIN
			
			SELECT @parentId = parentId FROM agentMaster(NOLOCK) WHERE agentId = @parentId and agentType = 2904

			SELECT agentId, agentName FROM agentMaster WITH(NOLOCK) 
			WHERE parentId = @parentId
			AND ISNULL(isDeleted, 'N') = 'N'
			AND ISNULL(isActive, 'N') = 'Y'
			AND agentId = ISNULL(1056, agentId)
			ORDER BY agentName
		END
	END
	ELSE
	BEGIN
		INSERT INTO #listBranch
		SELECT agentId , agentName 
		FROM agentMaster a WITH(NOLOCK) WHERE agentId=@regionalBranchId
	END
	
	IF @sBranch IS NOT NULL
		DELETE FROM #listBranch WHERE branchId <> @sBranch

	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	IF @sBranch IS NOT NULL
	INSERT INTO @FilterList 
	SELECT 
		'Branch Name', agentName 
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	
	IF @searchByValue IS NOT NULL AND @searchBy IS NOT NULL
	BEGIN
			INSERT INTO @FilterList
			SELECT
			CASE @searchBy
				WHEN 'cid'		THEN 'Customer ID'
				WHEN 'sName'	THEN 'Sender Name'
				WHEN 'rName'	THEN 'Receiver Name'
				WHEN 'icn'		THEN 'Control No'
			END
			,@searchByValue
	END	

IF @rptType = 'p'
BEGIN

	INSERT INTO @FilterList 
	SELECT 'Date Type', 'Paid Date'

	SELECT 
			[BRN NO]		= '<a href="/AgentNew/SearchTxnReport/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+CAST(ID AS VARCHAR)+'">'+DBO.FNADECRYPTSTRING(CONTROLNO)+'</a>'
			,[DATE_SEND]	= CONVERT(VARCHAR,RT.approvedDate,111)
			,[DATE_PAID]	= CONVERT(VARCHAR,RT.paidDate,111)
			,[SENDER NAME]	= senderName
			,[RECEIVER NAME]= receiverName
			,[EX-RATE]		= customerRate
			,[PAYMENT TYPE]	= paymentMethod
			,[COLLECTED_AMT]	= cAmt
			,[COLLECTED_CURR]	= collCurr
			,[SEND_AMT]		= tAmt
			,[SEND_CURR]	= collCurr
			,[CHARGE_CURR]	= serviceCharge
			,[CHARGE_CURR]	= collCurr
			,[RECEIVED_AMT]	= pAmt
			,[RECEIVED_CURR]	= payoutCurr
			,[USER_SEND]	= approvedBy
			,[USER_RECEIVED]= paidBy
			,TRANSTATUS		= transtatus
			,PAYSTATUS		= PAYSTATUS 
	FROM REMITTRAN RT(NOLOCK) 
	INNER JOIN #listBranch T ON T.branchId = RT.pBranch
	WHERE paidDate BETWEEN @dateFrom AND @dateTo+' 23:59:59'
	AND payStatus = ISNULL(@status,payStatus)
	AND transtatus = ISNULL(@transType,transtatus)
	AND paymentMethod = ISNULL(@paymentType,paymentMethod)
END
ELSE IF @rptType = 's'
BEGIN
	
	INSERT INTO @FilterList 
	SELECT 'Date Type', 'Send Date'
	select * from 
	(
		SELECT 
			[BRN_NO]			=	'<a href="/AgentNew/SearchTxnReport/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+CAST(RT.ID AS VARCHAR)+'">'+DBO.FNADECRYPTSTRING(CONTROLNO)+'</a>'
			,[Serial No]		=	RT.id
			,'UnApproved'			[Status]
			,[DATE_SEND]		=	CONVERT(VARCHAR,RT.approvedDate,111)
			,[DATE_PAID]		=	CONVERT(VARCHAR,RT.paidDate,111)
			,[SENDER_NAME]		=	senderName
			,[SENDER_MOBILE]	=	TS.MOBILE
			,[RECEIVER_NAME]	= receiverName
			,[EX_RATE]			= customerRate
			,[COLLECTION_MODE]	= Case when collmode = 'Bank Deposit' then 'JP Post' else collmode end
			,[PAYMENT_TYPE]		= paymentMethod
			,[COLLECTED_AMT]	= cAmt
			,[COLLECTED_CURR]	= collCurr
			,[SEND_AMT]		= tAmt
			,[SEND_CURR]	= collCurr
			,[CHARGE_CURRSc]	= serviceCharge
			,[CHARGE_CURR]	= collCurr
			,[RECEIVED_AMT]	= pAmt
			,[RECEIVED_CURR]= payoutCurr
			,[USER_SEND]	= approvedBy
			,[USER_RECEIVED]= paidBy
			,TRANSTATUS		= transtatus
			,PAYSTATUS		= PAYSTATUS 
			,rt.createddate
	FROM REMITTRANTEMP RT(NOLOCK) 
	INNER JOIN #listBranch T ON T.branchId = RT.sBranch
	LEFT JOIN TRANSENDERS TS (NOLOCK) ON TS.TRANID = RT.ID
	WHERE createddate BETWEEN @dateFrom AND @dateTo+' 23:59:59'
	AND transtatus IN ('OFAC Hold','Compliance Hold','OFAC/Compliance Hold')

	union all

	SELECT 
			[BRN_NO]				=	'<a href="/AgentNew/SearchTxnReport/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+CAST(RT.ID AS VARCHAR)+'">'+DBO.FNADECRYPTSTRING(CONTROLNO)+'</a>'
			,[Serial No]			=	RT.holdtranid
			,'Approved'					[Status]
			,[DATE_SEND]			=	CONVERT(VARCHAR,RT.approvedDate,111)
			,[DATE_PAID]			=	CONVERT(VARCHAR,RT.paidDate,111)
			,[SENDER_NAME]			=	senderName
			,[SENDER_MOBILE]		=	TS.MOBILE
			,[RECEIVER_NAME]		=	receiverName
			,[EX_RATE]				=	customerRate
			,[COLLECTION_MODE]		=	CASE when collmode = 'Bank Deposit' then 'JP Post' else collmode end
			,[PAYMENT_TYPE]			=	paymentMethod
			,[COLLECTED_AMT]		=	cAmt
			,[COLLECTED_CURR]		=	collCurr
			,[SEND_AMT]				=	tAmt
			,[SEND_CURR]			=	collCurr
			,[CHARGE_CURRSc]		=	serviceCharge
			,[CHARGE_CURR]			=	collCurr
			,[RECEIVED_AMT]			=	pAmt
			,[RECEIVED_CURR]		=	payoutCurr
			,[USER_SEND]			=	approvedBy
			,[USER_RECEIVED]		=	paidBy
			,TRANSTATUS				=	transtatus
			,PAYSTATUS				=	PAYSTATUS 
			,rt.createddate
	FROM REMITTRAN RT(NOLOCK) 
	INNER JOIN #listBranch T ON T.branchId = RT.sBranch
	LEFT JOIN TRANSENDERS TS (NOLOCK) ON TS.TRANID = RT.ID
	WHERE approvedDate BETWEEN @dateFrom AND @dateTo+' 23:59:59'
	AND payStatus = ISNULL(@status,payStatus)
	AND transtatus = ISNULL(@transType,transtatus)
	AND paymentMethod = ISNULL(@paymentType,paymentMethod)
	)xyz
	order by xyz.createddate desc
						
END
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
SELECT *,NULL FROM @FilterList
	   
SELECT 'TXN Report' title

GO