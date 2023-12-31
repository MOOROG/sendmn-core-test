USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_BankDepositVoucher]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_BankDepositVoucher](
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
		 @narration VARCHAR(100)

DECLARE @sAgent_Comm_ReceivableAc	VARCHAR(25),
		@sAgent_PrincipleAc	VARCHAR(25),
		@pAgent_commissionAc	VARCHAR(25),
		@pAgent_PrincipleAc	VARCHAR(25)

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
	@customerEmail = RT.createdBy
	FROM SendMnPro_Remit.dbo.remitTran RT(NOLOCK)
	LEFT JOIN SendMnPro_Remit.dbo.APPLICATIONUSERS AU(NOLOCK) ON AU.USERNAME = RT.CREATEDBY
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
	--	SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	
	IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'CAC')
	BEGIN
		COMMIT TRANSACTION
		SET @msg =ISNULL(@pAgent,'0') + ' : Payout Partner Comm Account Missing'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 

	IF NOT EXISTS(select 'x' from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'VAC')
	BEGIN
		COMMIT TRANSACTION
		SET @msg =ISNULL(@pAgent,'0') + ' : Payout Partner Principle Account Missing'
	--	SELECT 1 AS errocode,   @msg AS msg,null AS id
		
		INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
		SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		RETURN
	END 


		--DECLARE @KoreaAgentId VARCHAR(20)
		
		--SELECT @KoreaAgentId = agentId FROM SendMnPro_Remit.dbo.Vw_GetAgentID WHERE SearchText = 'koreaAgent'

	--IF @sAgent = @KoreaAgentId
	--BEGIN
	--	SET @ServiceCharge = (@ServiceCharge*@CutomerRate)  -- KRW * Rate = MNT 
	--END

	IF @collMode = 'Bank Deposit'
	BEGIN
		select @sAgent_Comm_ReceivableAc = acct_num  from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'TCR'
		select @sAgent_PrincipleAc = acct_num from ac_Master where agent_Id = @sAgent and acct_rpt_code = 'TP'

		select @pAgent_commissionAc = acct_num  from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'CAC'
		select @pAgent_PrincipleAc = acct_num  from ac_Master where agent_Id = @pAgent and acct_rpt_code = 'VAC'


		--sAgent_Comm_ReceivableAc :DR
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@sAgent_Comm_ReceivableAc,'s','DR',@ServiceCharge,@ServiceCharge,@CutomerRate,@TxnDate
			,'Remittance Voucher','MNT',@customerEmail,@controlNo,'Paid Voucher', @sAgent, @sAgent

		--sAgent_PrincipleAc :DR
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@sAgent_PrincipleAc,'s','DR',@pAmt,@pAmt,@CutomerRate,@TxnDate
			,'Remittance Voucher','MNT',@customerEmail,@controlNo,'Paid Voucher', @sAgent, @sAgent

		--pAgent_commissionAc :CR 
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@pAgent_commissionAc,'s','CR',@ServiceCharge,@ServiceCharge,@CutomerRate,@TxnDate
			,'Remittance Voucher','MNT',@customerEmail,@controlNo,'Paid Voucher', @pAgent, @pAgent


		--pAgent_PrincipleAc : CR 
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@pAgent_PrincipleAc,'s','CR',@pAmt,@pAmt,@CutomerRate,@TxnDate
			,'Remittance Voucher','MNT',@customerEmail,@controlNo,'Paid Voucher', @pAgent, @pAgent

	END
	IF @collMode = 'Cash Collect'
	BEGIN
		select 'dhan now'
	END

	IF NOT EXISTS (SELECT 'x' from temp_tran)
	BEGIN 
		COMMIT TRAN 
		  SET @msg = 'No Transaction Found For Voucher Generation : '+@controlNo + ' - ' + ISNULL(@senderName, '') 

			INSERT INTO VoucherLog(tranID,controlNo,Msg,createdDate,createdBy)
			SELECT @tranId,@controlNo,@msg,GETDATE(),'system'
		--SELECT 1 AS errocode,   @msg AS msg,null AS id
		RETURN
	END


COMMIT TRAN 
	SET @narration = 'Remittance No (bank deposit txn), PinNo :  '+@controlNo 

	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@controlNo,@date=@TxnDate,@narration=@narration,
	@company_id=1,@v_type='s',@user='system'









GO
