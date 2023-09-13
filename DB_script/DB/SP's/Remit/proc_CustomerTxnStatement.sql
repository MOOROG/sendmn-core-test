

ALTER PROC proc_CustomerTxnStatement
@fromDate	VARCHAR(10) = null,
@toDate		VARCHAR(20) = null,
@IdNumber	VARCHAR(20) = null,
@User		VARCHAR(50) ,
@flag		VARCHAR(10) = null,
@chargeAmt	MONEY		= NULL,
@refundAmt	MONEY		= NULL

AS
SET NOCOUNT ON;

IF @flag IS NULL
BEGIN
	DECLARE @customerName VARCHAR(100), @customerId BIGINT

	SELECT @customerName = firstName, @customerId = customerId FROM customermaster (NOLOCK) WHERE REPLACE(idnumber, '-', '') = REPLACE(@IdNumber, '-', '')

	SELECT senderName = ISNULL(s.fullname, r.senderName)
			,s.idNumber,createdDate = CONVERT(VARCHAR,r.createdDate,111)
		,controlNo = dbo.FNADecryptString(r.controlNo),r.receiverName,r.cAmt,r.pAmt,R.payoutCurr
	FROM remitTran r(NOLOCK)
	INNER JOIN tranSenders s (NOLOCK) ON s.tranId = r.id
	WHERE s.customerId = @customerId
	AND r.transtatus <> 'Cancel'
	AND r.approvedDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
	ORDER BY CONVERT(VARCHAR,r.createdDate,111)
END
ELSE IF @flag = 'search'
BEGIN
	IF NOT EXISTS(SELECT 1 FROM customerMaster (NOLOCK) WHERE walletAccountNo = @IdNumber)
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid customer requested for refund', NULL
		RETURN
	END

	SELECT errorCode = 0, customerName = firstName, idNumber, availableBalance = ISNULL(availableBalance, 0) 
	FROM customerMaster (NOLOCK) WHERE walletAccountNo = @IdNumber
END
ELSE IF @flag = 'refund'
BEGIN
	IF NOT EXISTS(SELECT 1 FROM customerMaster (NOLOCK) WHERE walletAccountNo = @IdNumber)
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid customer requested for refund', NULL
		RETURN
	END
	declare @availableBalance money,@rowId int,@Narration varchar(max)
	SELECT @availableBalance = ISNULL(availableBalance, 0)
	FROM customerMaster (NOLOCK) WHERE walletAccountNo = @IdNumber

	if not exists(select 'a' from TblVirtualBankDepositDetail(nolock) where virtualAccountNo = @IdNumber)
	BEGIN
		EXEC proc_errorHandler 1, 'Balance not found for refund', NULL
		RETURN
	END
	IF ISNULL(@refundAmt,0) <= 0 
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid amount requested for refund', NULL
		RETURN
	END
	IF ISNULL(@availableBalance - (@refundAmt),0)< 0
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid amount requested for refund', NULL
		RETURN
	END

	DELETE FROM FastMoneyPro_Account.dbo.temp_tran WHERE SESSIONID = @IdNumber

	begin transaction
		insert into TblVirtualBankDepositDetail(processId,obpId,customerName,virtualAccountNo,amount,receivedOn,partnerServiceKey
		,institution,depositor,no,logDate)
		select top 1 0,obpId,customerName,virtualAccountNo,- @refundAmt,getdate(),'000'
		,institution,depositor,no,getdate() from TblVirtualBankDepositDetail (nolock)
		where virtualAccountNo= @IdNumber

		set @rowId = @@IDENTITY

		update customerMaster set availableBalance=availableBalance- @refundAmt where walletAccountNo = @IdNumber

		INSERT INTO FastMoneyPro_Account.dbo.temp_tran(entry_user_id,acct_num,part_tran_type,tran_amt,field1,field2
		,sessionID,refrence)
		SELECT @User,'100241011536','cr',(@refundAmt - ISNULL(@chargeAmt,0)),@IdNumber,'Refund Deposit',@IdNumber,@rowId union all
		SELECT @User,@IdNumber,'dr',@refundAmt,@IdNumber,'Refund Deposit',@IdNumber,@rowId  
		IF ISNULL(@chargeAmt,0) >0 
		BEGIN
			INSERT INTO FastMoneyPro_Account.dbo.temp_tran(entry_user_id,acct_num,part_tran_type,tran_amt,field1,field2
				,sessionID,refrence)
			SELECT @User,'910141097092','cr',ISNULL(@chargeAmt,0),@IdNumber,'Refund Deposit',@IdNumber,@rowId
		END
			

    commit transaction

	SELECT @fromDate = convert(varchar,getdate(),101),@Narration='being amount refunded to primary ac : '+@IdNumber
	exec FastMoneyPro_Account.dbo.[spa_saveTempTrn] @flag='i',@sessionID= @IdNumber,@date=@fromDate,@narration=@Narration,@company_id=1,@v_type='j',@user=@user
END
