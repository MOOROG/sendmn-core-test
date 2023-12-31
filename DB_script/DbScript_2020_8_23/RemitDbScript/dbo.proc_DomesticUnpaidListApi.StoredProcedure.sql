USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_DomesticUnpaidListApi]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_DomesticUnpaidListApi]
			 @flag				VARCHAR(50)
			,@mapCodeInt		VARCHAR(100)	= NULL
			,@agentId			INT				= NULL
			,@tranNos			VARCHAR(MAX)	= NULL
			,@controlNo			VARCHAR(50)		= NULL
			,@bankId			INT				= NULL
			,@fromDate			VARCHAR(50)		= NULL
			,@toDate			VARCHAR(50)		= NULL
			,@dateType			VARCHAR(50)		= NULL
			,@sortBy			VARCHAR(50)		= NULL
			,@sortOrder			VARCHAR(50)		= NULL
			,@pageSize			INT				= NULL
			,@pageNumber		INT				= NULL
			,@user				VARCHAR(50)		= NULL
		    ,@rBankName			VARCHAR(200)	= NULL
AS
SET NOCOUNT ON;

/*
33300379
select * from agentMaster where mapCodeInt=33300379
 EXEC [proc_DomesticUnpaidListApi] @flag = 's',@mapCodeInt='-1'
 EXEC [proc_DomesticUnpaidListApi] @flag = 's1',@agentId='2054'
 proc_DomesticUnpaidListApi
 EXEC proc_DomesticUnpaidListApi @flag='s', @user = 'admin', @mapCodeInt = '33300379'
 EXEC [proc_DomesticUnpaidListApi]  @flag='report',@bankId='3259'


EXEC proc_DomesticUnpaidListApi @flag = 'payDom', @user = 'admin', @tranNos = '7458553'
EXEC proc_DomesticUnpaidListApi @flag='ulAgent', @user = 'shinehead123', @mapCodeInt = '33300048'
EXEC proc_DomesticUnpaidListApi @flag='intlList', @user = 'dipesh', @mapCodeInt = '10600000', 
@rBankName = 'NEPAL INDISTRIAL AND COMMERCE BANK(NIC)- AC DEPOSI'
 */
 
DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	
	EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT			
     DECLARE @controlNoEncrypted VARCHAR(30)

IF @flag = 'l'						--Unpaid List in Dropdown List
BEGIN
    SELECT
		 receiveAgentId		= pAgent
		,rBankName			= pAgentName
		,Txn				= COUNT(*)
		,AMT				= SUM(pAmt)
	FROM remitTran WITH(NOLOCK)
	WHERE paymentMethod = 'Bank Deposit' AND tranStatus = 'Payment' AND payStatus = 'Unpaid' AND tranType = 'I'
	GROUP BY pAgent, pAgentName
	ORDER BY pAgentName
END

ELSE IF @flag = 'ul'					--All Unpaid Txn List(International and Domestic Txn)
BEGIN
	--EXEC [proc_DomesticUnpaidListApi] @flag = 'ul'
	-->> International Unpaid List
	SELECT
		 receiveAgentId		= pAgent
		,rBankName			= pAgentName
		,Txn				= COUNT(*)
		,AMT				= SUM(pAmt)
	FROM remitTran WITH(NOLOCK)
	WHERE paymentMethod = 'Bank Deposit' AND tranStatus = 'Payment' AND payStatus = 'Unpaid' AND tranType = 'I'
	GROUP BY pAgent, pAgentName
	ORDER BY pAgentName
	
	-->> Domestic Unpaid List
	SELECT
		 receiveAgentId		= pBank
		,rBankName			= pBankName
		,Txn				= COUNT(*)
		,AMT				= SUM(pAmt)
	FROM remitTran WITH(NOLOCK)
	WHERE paymentMethod = 'Bank Deposit' AND tranStatus = 'Payment' AND payStatus = 'Unpaid' AND tranType = 'D'
	GROUP BY pBank, pBankName
	ORDER BY pBankName
END

ELSE IF @flag = 'intlList'				--International Unpaid A/C Deposit List
BEGIN
	SELECT
		 [Control No]		= dbo.FNADecryptString(rt.controlNo)
		,[Tran No]			= rt.id
		,[Sending Country]	= rt.sCountry
		,[Sending Agent]	= rt.sAgentName
		,[Bank Name]		= rt.pBankName
		,[Branch Name]		= rt.pBankBranchName								
		,[Receiver Name]	= rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,[Bank A/C No]		= rt.accountNo
		,[DOT]				= rt.approvedDate
		,[Total Amount]		= rt.pAmt
		,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
	FROM [dbo].remitTran rt WITH(NOLOCK)
	inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
	WHERE pAgent = @mapCodeInt
	AND tranStatus = 'Payment'
	AND paymentMethod = 'Bank Deposit'
	AND payStatus = 'Unpaid' 
	AND rt.sCountry <> 'Nepal'
	AND rt.tranType = 'I'
	ORDER BY [Unpaid Days] DESC
	RETURN

END

ELSE IF @flag = 'domList'			--Domestic Unpaid A/C Deposit List
BEGIN
	SELECT
		 [Control No]		= dbo.FNADecryptString(rt.controlNo)
		,[Tran No]			= rt.id
		,[Sending Agent]	= rt.sAgentName
		,[Bank Name]		= rt.pBankName
		,[Branch Name]		= rt.pBankBranchName								
		,[Receiver Name]	= rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,[Bank A/C No]		= rt.accountNo
		,[DOT]				= rt.approvedDate
		,[Total Amount]		= rt.pAmt
		,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
	FROM [dbo].remitTran rt WITH(NOLOCK)
	inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
	WHERE pBank = @mapCodeInt
	AND tranStatus = 'Payment'
	AND paymentMethod = 'Bank Deposit'
	AND payStatus = 'Unpaid' 
	AND rt.sCountry = 'Nepal'
	AND tranType = 'D'
	ORDER BY [Unpaid Days] DESC
	RETURN
END

ELSE IF @flag = 'ulAgent'
BEGIN
	SELECT
		 [Control No]		= dbo.FNADecryptString(rt.controlNo)
		,[Tran No]			= rt.id
		,[Sending Country]	= rt.sCountry
		,[Sending Agent]	= rt.sAgentName
		,[Bank Name]		= rt.pBankName
		,[Branch Name]		= rt.pBankBranchName								
		,[Receiver Name]	= rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,[Bank A/C No]		= rt.accountNo
		,[DOT]				= rt.approvedDate
		,[Total Amount]		= rt.pAmt
		,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
	FROM [dbo].remitTran rt WITH(NOLOCK)
	inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
	WHERE pAgent = @mapCodeInt
	AND tranStatus = 'Payment'
	AND paymentMethod = 'Bank Deposit'
	AND payStatus = 'Unpaid' 
	AND rt.sCountry <> 'Nepal'
	AND rt.tranType = 'I'
	ORDER BY [Unpaid Days] DESC
	
	SELECT
		 [Control No]		= dbo.FNADecryptString(controlNo)
		,[Tran No]			= trn.id
		,[Sending Agent]	= trn.sAgentName
		,[Bank Name]		= trn.pBankName
		,[Branch Name]		= trn.pBankBranchName
		,[Receiver Name]	= ISNULL(rec.firstName, '') + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
		,[Bank A/C No]		= trn.accountNo
		,[DOT]				= trn.createdDate
		,[Total Amount]		= trn.pAmt
		,[Unpaid Days]		= DATEDIFF(D,trn.createdDate,GETDATE())
	FROM remitTran trn WITH(NOLOCK)
	INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	WHERE payStatus = 'Unpaid' 
	AND paymentMethod = 'Bank Deposit' 
	AND tranStatus = 'Payment' AND trn.pBank = @bankId
	RETURN
END

ELSE IF @flag = 'payIntl'
BEGIN	
	DECLARE @rBankId VARCHAR(10), @parentId INT
	IF @agentId = -1
	BEGIN
		SELECT TOP 1 @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE mapCodeIntAc = @rBankId
		IF @parentId IS NULL
			SELECT TOP 1 @parentId = parentId FROM agentMaster WITH(NOLOCK) WHERE mapCodeInt = @rBankId
		SELECT TOP 1 @agentId = mapCodeIntAc FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId
		IF @agentId IS NULL
			SELECT TOP 1 @agentId = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @parentId
	END
END

ELSE IF @flag = 'payDom'
BEGIN
	CREATE TABLE #res(errorCode VARCHAR(10),errorId VARCHAR(50), msg VARCHAR(100), ext VARCHAR(100))
	CREATE TABLE #txn (id INT IDENTITY(1,1), tranNo INT, controlNo varchar(200))
	DECLARE @tranNo INT, @iUser VARCHAR(50)

	INSERT #txn(tranNo)
	SELECT value FROM dbo.Split(',', @tranNos)

    UPDATE #txn SET controlNo = dbo.FNAEncryptString(dbo.decryptDbLocal(controlNo))
     --select * from #txn
     --truncate table #txn
			
	UPDATE remitTran SET
		 tranStatus					= 'Paid'
		,payStatus					= 'Paid'
		,pSuperAgent				= 0
		,pSuperAgentCommCurrency	= 'NPR'
		,pAgentComm					= 0
		,pAgentCommCurrency			= 'NPR'
		,paidBy						= @user
		,paidDate					= dbo.FNAGetDateInNepalTZ()
		,paidDateLocal				= dbo.FNAGetDateInNepalTZ()
	FROM remitTran M
	INNER JOIN #txn T ON M.controlNo = t.controlNo	
	
	SELECT 0, 'Transaction(s) posted successfully', 'Transaction(s) posted successfully', NULL
	RETURN
END

ELSE IF @flag = 'report'
BEGIN
	SELECT   
		 [RECEIVER NAME]	= B.firstName + ISNULL( ' ' + B.middleName, '') + ISNULL( ' ' + B.lastName1, '') + ISNULL( ' ' + B.lastName2, '') 
		,[ACCOUNT NUMBER]	= A.accountNo
		,[BRANCH NAME]		= pBankBranchName 
		,[SEND AMOUNT]	= pAmt 
	FROM remitTran A WITH(NOLOCK) 
	INNER JOIN tranReceivers B WITH(NOLOCK) ON A.id=B.tranId 
	WHERE paymentMethod = 'Bank Deposit' 
	AND pBank = @bankId
	AND paidDate BETWEEN @fromDate AND @toDate + ' 23:59:59'		
END


GO
