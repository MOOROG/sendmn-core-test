SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER proc [dbo].[proc_transactionVoucherEntry]
(
@controlNo		VARCHAR(30)
,@refNum		VARCHAR(30) = NULL 
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;

DELETE FROM temp_tran WHERE sessionID=@controlNo

DECLARE	@controlNoEnc	VARCHAR(50) = dbo.fnaencryptstring(@controlNo),
		@senderName		VARCHAR(250),
		@userId			INT,
		@tranId			BIGINT,
		@pAgent			INT,
		@sAgent			INT,
		@msg			VARCHAR(500),
		@collMode		VARCHAR(30),
		@pCurr			VARCHAR(5),
		@cAmt			MONEY, 
		@tAmt			MONEY,
		@pAmt			MONEY,
		@CutomerRate	MONEY,
		@pCurrCostRate	MONEY,
		@TxnDate date,
		@customerEmail VARCHAR(80),
		@pAgentComm MONEY,
		@ServiceCharge MONEY,
		@narration VARCHAR(100),
		@tranType	VARCHAR(5),
		@srouteID	VARCHAR(20),
		@customerId	VARCHAR(20),
		@vNarration VARCHAR(200) = 'Remittance Voucher'


DECLARE @Teller_Principle_Acc	VARCHAR(25),
		@TellerBranch_Comm_ACC	VARCHAR(25),
		@PBranch_Principle_ACC	VARCHAR(25),
		@PBranch_Comm_Payable_ACC	VARCHAR(25),
		@payCommExpenseAcc			VARCHAR(50) = '141000175' --161 : MG comm Payable Expenses

IF EXISTS (SELECT 'A' FROM tran_master(NOLOCK) WHERE 
field1=@controlNo 
AND tran_type='j' 
AND entry_user_id='system' 
AND  field2 = 'Send Voucher'
 AND ACCT_TYPE_CODE IS NULL)
BEGIN
	SET @msg = 'Voucher already generated!'
	--select 1 as errocode, @msg as   msg,null as id

	INSERT INTO VoucherLog(controlNo,Msg,createdDate,createdBy)
	SELECT @controlNo,@msg,GETDATE(),'system'
	RETURN
END

BEGIN TRANSACTION

	SELECT 
	@tranId = RT.id,
	@senderName = TS.FULLNAME,
	@userId = AU.userId,
	@pAgent			= pAgent,
	@sAgent = RT.SAGENT,
	@collMode = COLLMODE,
	@pCurr = payoutCurr,
	@cAmt = round(cAmt, 0), 
	@tAmt = round(tAmt, 0), 
	@pAmt = pAmt,
	@ServiceCharge =serviceCharge,
	@pAgentComm = pAgentComm,
	@CutomerRate = customerRate, 
	@pCurrCostRate = pCurrCostRate,
	@TxnDate = RT.approvedDate,
	@customerEmail = RT.createdBy,
	@tranType	= rt.tranType,
	@srouteID	= rt.srouteId,
	@customerId = ts.customerId
	FROM FastMoneyPro_Remit.dbo.remitTran RT(NOLOCK)
	LEFT JOIN FastMoneyPro_Remit.dbo.APPLICATIONUSERS AU(NOLOCK) ON AU.USERNAME = RT.CREATEDBY
	INNER JOIN FastMoneyPro_Remit.dbo.tranSenders TS(NOLOCK) ON TS.tranId = RT.id
	LEFT JOIN FastMoneyPro_Remit.dbo.COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = RT.pCountry
	LEFT JOIN FastMoneyPro_Remit.dbo.servicetypemaster ST(NOLOCK) ON ST.typeTitle = RT.paymentMethod
	WHERE controlno = @controlNoEnc

	IF EXISTS(SELECT 'x' FROM  temp_tran WHERE sessionID = @controlNo)
		DELETE  FROM temp_tran WHERE sessionID = @controlNo

	--Check Account Opening Logic

	IF ISNULL(@pAgentComm,'0') = '0' OR @pAgentComm = ''
	BEGIN
		COMMIT TRANSACTION
		SET @msg = 'Payout Commission Missing'
		SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	IF ISNULL(@ServiceCharge,'0') = '0' OR @ServiceCharge = ''
	BEGIN
		COMMIT TRANSACTION
		SET @msg = 'Service Charge Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 
	
	IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'TCP')
	BEGIN
		COMMIT TRANSACTION
		SET @msg = CAST(ISNULL(@pAgent,'0') AS VARCHAR) + ' : Payout Partner Commission Payable Account Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'TP')
	BEGIN
		COMMIT TRANSACTION
		SET @msg =CAST(ISNULL(@pAgent,'0') AS VARCHAR) + ' : Payout Partner Principle Account Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	select @PBranch_Principle_ACC = acct_num from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'TP'
	select @PBranch_Comm_Payable_ACC = acct_num from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'TCP'

	IF @collMode = 'Cash Collect'
	BEGIN
		IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @userId and acct_rpt_code = 'TCA')
		BEGIN
			COMMIT TRANSACTION
			SET @msg = CAST(ISNULL(@userId,'0') AS VARCHAR) + ' : Teller Principle Account Missing'
			--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
			RETURN
		END 

		IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'CAC')
		BEGIN
			COMMIT TRANSACTION
			SET @msg =CAST(ISNULL(@sAgent,'0') AS VARCHAR) + ' : Teller Branch Commission Account Missing'
			--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
			RETURN
		END 

		select @Teller_Principle_Acc = acct_num from ac_Master where agent_Id = @userId and acct_rpt_code = 'TCA'
		select @TellerBranch_Comm_ACC = acct_num from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'CAC'
		
	END
	IF @collMode = 'Bank Deposit'
	BEGIN
		IF @srouteId = 'w' and @tranType = 'o'
		BEGIN 
			SET @userId = @customerId
			SET @vNarration = 'Wallet Voucher'
			SET @payCommExpenseAcc = '161000456'  --163: wallet Txn comm payable

			IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @userId and acct_rpt_code = 'WAC')
			BEGIN
				COMMIT TRANSACTION
				SET @msg =CAST(ISNULL(@userId,'0') AS VARCHAR) + ' : Customer Principle Account Missing'
				--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
				INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
				SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
				RETURN
			END 

			select @Teller_Principle_Acc = acct_num from ac_Master where agent_Id = @userId and acct_rpt_code = 'WAC'
			select @TellerBranch_Comm_ACC ='161001762' --gl:162 Wallet Direct Comm Income
		END 
	END

	--Teller Princle Account :DR
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @controlNo,'system',@Teller_Principle_Acc,'s','DR',@cAmt,@cAmt,@CutomerRate,@TxnDate
		,@vNarration,'MNT',@customerEmail,@controlNo,'Send Voucher', @userId, @sAgent

	--Payout Partner Princle Account :CR
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @controlNo,'system',@PBranch_Principle_ACC,'s','CR',@tAmt,@tAmt,@CutomerRate,@TxnDate
	,@vNarration,'MNT',@customerEmail,@controlNo,'Send Voucher', @sAgent, @pAgent

	--Teller Branch Commision Payable Account :CR and Service Charge bookin account 
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @controlNo,'system',@TellerBranch_Comm_ACC,'s','CR',@ServiceCharge,@ServiceCharge,@CutomerRate,@TxnDate
	,@vNarration,'MNT',@customerEmail,@controlNo,'Send Voucher', @userId, @sAgent

	


	--Expenses on behalf of Payout Partner Commission Payable
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @controlNo,'system',@payCommExpenseAcc,'s','DR',@pAgentComm,@pAgentComm,@CutomerRate,@TxnDate
		,@vNarration,'MNT',@customerEmail,@controlNo,'Send Voucher', @userId, @sAgent

	
	--Payout Partner Commission Payable Account :CR
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @controlNo,'system',@PBranch_Comm_Payable_ACC,'s','CR',@pAgentComm,@pAgentComm,@CutomerRate,@TxnDate
	,@vNarration,'MNT',@customerEmail,@controlNo,'Send Voucher', @sAgent, @pAgent

COMMIT TRAN 
	SET @narration = 'Remittance Send Voucher RefNo : '+@controlNo 

	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@controlNo,@date=@TxnDate,@narration=@narration,@company_id=1,@v_type='s',@user='system'


GO

