ALTER  proc [dbo].[Proc_CashDepositVoucher](
@controlNo		VARCHAR(30)
,@refNum		VARCHAR(30) = NULL 
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
-- Proc_CashDepositVoucher @refNum ='', @controlNo	 =''
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


DECLARE @sAgent_Comm_ReceivableAc	VARCHAR(25),
		@sAgent_PrincipleAc	VARCHAR(25),
		@pAgent_commissionAc	VARCHAR(25),
		@Teller_pAgent_PrincipleAc	VARCHAR(25)

IF EXISTS (SELECT 'A' FROM tran_master(NOLOCK) WHERE 
field1=@controlNo 
AND tran_type='j' 
AND entry_user_id='system' 
AND  field2 = 'Paid Voucher'
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
	@collMode = paymentMethod,
	@pCurr = payoutCurr,
	@cAmt = round(cAmt, 0), 
	@tAmt = round(tAmt, 0), 
	@pAmt = pAmt,
	@ServiceCharge =serviceCharge,
	@pAgentComm = pAgentComm,
	@CutomerRate = customerRate, 
	@pCurrCostRate = pCurrCostRate,
	@TxnDate = RT.paidDate,
	@customerEmail = RT.createdBy,
	@customerId = ts.customerId,
	@tranType	= rt.tranType
	FROM SendMnPro_Remit.dbo.remitTran RT(NOLOCK)
	LEFT JOIN SendMnPro_Remit.dbo.APPLICATIONUSERS AU(NOLOCK) ON AU.USERNAME = RT.paidBy
	INNER JOIN SendMnPro_Remit.dbo.tranSenders TS(NOLOCK) ON TS.tranId = RT.id
	LEFT JOIN SendMnPro_Remit.dbo.COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = RT.pCountry
	LEFT JOIN SendMnPro_Remit.dbo.servicetypemaster ST(NOLOCK) ON ST.typeTitle = RT.paymentMethod
	WHERE controlno = @controlNoEnc

	--Check Account Opening Logic
	IF ISNULL(@ServiceCharge,'0') = '0' OR @ServiceCharge = ''
	BEGIN
		COMMIT TRANSACTION
		SET @msg = 'Service Charge Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'TCR')
	BEGIN
		COMMIT TRANSACTION
		SET @msg =ISNULL(@sAgent,'0') + ' : Send Agent Comm Receivable Account Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'TP')
	BEGIN
		COMMIT TRANSACTION
		SET @msg = ISNULL(@sAgent,'0') + ' : Send Agent Principle Account Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	IF @sAgent = '394432'
	BEGIN
	
		IF ISNULL(@CutomerRate,'0') = '0' OR @CutomerRate = ''
		BEGIN
			COMMIT TRANSACTION
			SET @msg = 'ExRate Missing'
			--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
			RETURN
		END 

		SET @ServiceCharge = (@ServiceCharge*@CutomerRate)   --KRW * Rate = MNT 
		
	END

	select @sAgent_Comm_ReceivableAc = acct_num  from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'TCR'
	select @sAgent_PrincipleAc = acct_num from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'TP'

	IF @collMode = 'Cash payment'  and @tranType = 'M' and @pAgent = '394420'  --Wallet Online Branch 
	BEGIN
		
		SET @vNarration = 'Wallet Voucher'
		SET @userId = @customerId

		IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @userId and acct_rpt_code = 'WAC')
		BEGIN
			COMMIT TRANSACTION
			SET @msg =CAST(ISNULL(@userId,'0') AS VARCHAR) + ' : Customer Principle Account Missing'
			--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
			RETURN
		END 

		SET @pAgent_commissionAc = '161000439' --Wallet Txn Commission
		select @Teller_pAgent_PrincipleAc = acct_num from ac_Master where agent_Id = @userId and acct_rpt_code = 'WAC'

	END 
	 
	IF @collMode = 'Cash payment' and @tranType != 'M'
	BEGIN
		IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @userId and acct_rpt_code = 'TCA')
		BEGIN
			COMMIT TRANSACTION
			SET @msg =ISNULL(@userId,'0') + ' : Teller Principle Account Missing'
			--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
			RETURN
		END 

		IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'CAC')
		BEGIN
			COMMIT TRANSACTION
			SET @msg =ISNULL(@pAgent,'0') + ' : Payout Partner Comm Account Missing'
		--	SELECT 1 AS errocode,   @msg AS msg,null AS id
		
			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
			RETURN
		END 

		select @pAgent_commissionAc = acct_num  from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'CAC'
		select @Teller_pAgent_PrincipleAc = acct_num  from ac_Master where agent_Id = @userId and acct_rpt_code = 'TCA'
	END
		--sAgent_Comm_ReceivableAc :DR
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@sAgent_Comm_ReceivableAc,'s','DR',@ServiceCharge,@ServiceCharge,@CutomerRate,@TxnDate
			,@vNarration,'MNT',@customerEmail,@controlNo,'Paid Voucher', @sAgent, @sAgent

		--sAgent_PrincipleAc :DR
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@sAgent_PrincipleAc,'s','DR',@pAmt,@pAmt,@CutomerRate,@TxnDate
			,@vNarration,'MNT',@customerEmail,@controlNo,'Paid Voucher', @sAgent, @sAgent

		--pAgent_commissionAc :CR 
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@pAgent_commissionAc,'s','CR',@ServiceCharge,@ServiceCharge,@CutomerRate,@TxnDate
			,@vNarration,'MNT',@customerEmail,@controlNo,'Paid Voucher', @pAgent, @pAgent


		--pAgent_PrincipleAc : CR 
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@Teller_pAgent_PrincipleAc,'s','CR',@pAmt,@pAmt,@CutomerRate,@TxnDate
			,@vNarration,'MNT',@customerEmail,@controlNo,'Paid Voucher', @userId, @userId
 
	IF NOT EXISTS (SELECT 'x' from temp_tran)
	BEGIN 
		COMMIT TRAN 
		 SET @msg = 'No Transaction Found For Voucher Generation : '+@controlNo + ' - ' + ISNULL(@senderName, '') 
		 
	--	SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END


COMMIT TRAN 
	SET @narration = 'Remittance No (cash txn)  PinNo :  '+@controlNo 

	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@controlNo,@date=@TxnDate,@narration=@narration,
	@company_id=1,@v_type='s',@user='system'









GO
