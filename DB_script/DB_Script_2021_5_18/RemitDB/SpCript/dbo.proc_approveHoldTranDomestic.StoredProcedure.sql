USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_approveHoldTranDomestic]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_approveHoldTranDomestic] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@sAgent			varchar(50)		= null
	,@controlNo			varchar(50)		= null
	,@sender			varchar(200)	= null
	,@receiver			varchar(200)	= null
	,@amt				varchar(100)	= null
	,@txnDate			varchar(20)		= null
	,@txnUser			varchar(50)		= null
	,@tranId			varchar(50)		= null

) 
AS

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)
	,@cAmt				MONEY

SET NOCOUNT ON
SET XACT_ABORT ON

/*
exec proc_approveHoldTranDomestic @flag='summary'
*/
IF @flag = 'summary'	
BEGIN
	SELECT 		
		 trn.sAgent
		,[S.N.] = row_number() over(order by trn.sAgent)
		,[Agent] = trn.sAgentName
		,[TXN Count] = count('x')		
	FROM remitTran trn WITH(NOLOCK)
	WHERE
		trn.tranStatus = 'Hold' AND 
		trn.payStatus = 'Unpaid' AND
		trn.approvedBy IS NULL AND
		trn.tranType = 'D'
	group by trn.sAgent,trn.sAgentName
END
/*
	exec proc_approveHoldTranDomestic @flag='detail',@sAgent ='1006'
*/
IF @flag = 'detail'	
BEGIN
	declare @sql as varchar(max)
	set @sql ='select [S.N.],[Tran Id],[Control No],[Amount],[Txn Date],[User],[Sender Id],[Sender Name],[Sender Address],[Receiver Id],[Receiver Name] from 
	(
	SELECT 
	     [S.N.] = row_number()over(order by trn.id)
		,[Tran Id] = trn.id
		,[Control No] = dbo.FNADecryptString(trn.controlNo)
		,[Amount] = trn.tAmt
		,[Txn Date] = trn.createdDate
		,[User] = trn.createdBy
		,[Sender Id] = sen.membershipId
		,[Sender Name] = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
		,[Sender Address] = sen.address
		,[Receiver Id] = rec.membershipId
		,[Receiver Name] = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')		
		--,[Receiver Address] = rec.address
		,controlNo = trn.controlNo
		,sAgent = trn.sAgent
		,createdBy = trn.createdBy
		,createdDate= trn.createdDate
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	WHERE
		trn.tranStatus = ''Hold'' and 
		trn.payStatus = ''Unpaid'' and
		trn.approvedBy IS NULL AND
		trn.tranType = ''D''
	)x where 1=1 '

	if @sAgent is not null
		set @sql = @sql+ ' and sAgent = '''+@sAgent+''''

	if @controlNo is not null
		set @sql = @sql+ ' and controlNo = '''+dbo.FNAEncryptString(@controlNo) +''''
	
	if @txnUser is not null
		set @sql = @sql+ ' and createdBy = '''+ @txnUser +''''

	if @txnDate is not null
		set @sql = @sql+ ' and convert(varchar,createdDate,101) = '''+ convert(varchar,@txnDate,101) +''''
				
	if @amt is not null
		set @sql = @sql+ ' and Amount = '''+ @amt +''''

	if @sender is not null
		set @sql = @sql+ ' and [Sender Name] like ''%'+ @sender +'%'''

	if @receiver is not null
		set @sql = @sql+ ' and [Receiver Name] like ''%'+ @receiver +'%'''

	exec(@sql)

END

IF @flag = 'approve'
BEGIN

	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE id = @tranId AND createdBy = @user)
	BEGIN
		EXEC proc_errorHandler 1, 'Process denied for same user', @tranId
		RETURN	
	END
	DECLARE @tranStatus VARCHAR(20) = NULL,		
			@userId INT, 
			@sendPerTxn MONEY, 
			@sendPerDay MONEY, 
			@sendTodays MONEY, 
			@sBranch INT


	SELECT @tranStatus = tranStatus, @cAmt = cAmt, @controlNo = dbo.FNADecryptString(controlNo) 
		FROM remitTran WITH(NOLOCK) WHERE id = @tranId

	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @tranId
		RETURN
	END
	IF (@tranStatus = 'Payment')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been approved and ready for payment', @tranId
		RETURN
	END
	IF (@tranStatus = 'Paid')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is already been paid', @tranId
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is cancelled', @tranId
		RETURN
	END
	IF (@tranStatus = 'Lock')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is locked. Please Contact HO', @tranId
		RETURN
	END

	SELECT @sendPerDay = sendPerDay, @sendPerTxn = sendPerTxn, @sendTodays = ISNULL(sendTodays, 0) 
		FROM userWiseTxnLimit WITH(NOLOCK) WHERE userId = @userId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
	IF(@cAmt > @sendPerTxn)
	BEGIN
		EXEC proc_errorHandler 1, 'Transfer Amount exceeds user per transaction limit.', @tranId
		RETURN
	END
	IF(@sendTodays > @sendPerDay)
	BEGIN
		EXEC proc_errorHandler 1, 'User Per Day Transaction Limit exceeded.', @tranId
		RETURN
	END
	BEGIN TRANSACTION
		UPDATE remitTran SET
			  tranStatus				= 'Payment'					
			 ,approvedBy				= @user
			 ,approvedDate				= GETDATE()
			 ,approvedDateLocal			= DBO.FNADateFormatTZ(GETDATE(), @user)
		WHERE id = @tranId
		
		UPDATE userWiseTxnLimit SET
			 sendTodays = ISNULL(sendTodays, 0) + @cAmt
		WHERE userId = @userId AND ISNULL(isActive, 'N') = 'Y'
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC proc_errorHandler 0, 'Transaction Approved Successfully', @tranId
END




GO
