use fastmoneypro_account
go

--proc_transactionVoucherEntry '213966733'
ALTER PROC proc_transactionVoucherEntry_Job
(
	@controlNo	VARCHAR(30)
	,@refNum VARCHAR(30) = NULL 
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
DELETE FROM temp_tran WHERE sessionID=@controlNo

DECLARE @controlNoEnc VARCHAR(50) = dbo.fnaencryptstring(@controlNo)
	
IF EXISTS (SELECT 'A' FROM tran_master(NOLOCK) WHERE field1=@controlNo AND tran_type='j' AND entry_user_id='system' AND  field2 = 'Remittance Voucher' AND ACCT_TYPE_CODE IS NULL)
BEGIN
	select 1 as errocode,'Voucher already generated!' as   msg,null as id
	RETURN
END
	
BEGIN TRANSACTION
	DECLARE @customerId BIGINT,@ReferalCode VARCHAR(20), @customerEmail VARCHAR(80), @pAgent INT,@pBank INT, @customerAccNum VARCHAR(50)
		, @cAmt MONEY, @tAmt MONEY,@pAmt MONEY,@sCurrCostRate DECIMAL(10, 4),@sCurrHoMargin DECIMAL(10, 4), @serviceCharge DECIMAL(10, 4), @pAgentComm MONEY
		, @pCountryId INT,@payMode  VARCHAR(30), @pCountry VARCHAR(50), @payModeId INT, @sAgent INT , @userId int, @tpTranNo BIGINT
		, @sCountryId INT = 113, @collMode VARCHAR(30), @holdtranid BIGINT, @sAgentCommAccount VARCHAR(30), @sAgentComm MONEY, @sAgentCommCurrency	VARCHAR(5)
		, @senderName VARCHAR(250)

	DECLARE @pAgentPrincipleAcc VARCHAR(50), @JMEserviceChargeIncomeAcc VARCHAR(50), @JMECommissionExpencesAcc VARCHAR(50), @tranId BIGINT
		, @pAgenetCommPayableAcc VARCHAR(50),@TxnDate date,@tranType CHAR(1),@sBranchName VARCHAR(100),@pAgentCommCurrency VARCHAR(5)
		, @extraPayComm MONEY,@pCurrCostRate DECIMAL(10, 6),@pCurrHoMargin DECIMAL(10, 4),@sRouteId VARCHAR(20),@kftcNarration NVARCHAR(500), @sBranch INT, @forexGainLoss DECIMAL(10, 4)
	
	DECLARE @pSuperAgent INT,@pSuperAgentName VARCHAR(100),@pAgentName VARCHAR(100),@pCurr VARCHAR(5),@CutomerRate DECIMAL,@introducer VARCHAR(50)
	
	SELECT @customerEmail = RT.createdBy, @pAgent = pAgent, @pBank = pBank, @cAmt = round(cAmt, 0), @tAmt = round(tAmt, 0), @pAmt = pAmt
		, @sCurrCostRate = (sCurrCostRate+ISNULL(sCurrHoMargin,0)), @serviceCharge = serviceCharge, @pAgentComm = pAgentComm, @pAgentCommCurrency = pAgentCommCurrency
		, @pCountryId = CM.COUNTRYID, @payMode = paymentMethod, @payModeId = serviceTypeId, @TxnDate = RT.createdDate, @tranType = tranType
		, @sCurrHoMargin = sCurrHoMargin, @sBranchName = sBranchName, @sBranch = RT.sBranch, @pCurr = payoutCurr, @CutomerRate = customerRate, @pCurrCostRate = pCurrCostRate
		, @pCurrHoMargin = pCurrHoMargin, @sRouteId = sRouteId, @pCountry = RT.PCOUNTRY, @sAgent = RT.SAGENT, @pSuperAgent = RT.PSUPERAGENT, @collMode = COLLMODE
		, @holdtranid = rt.holdtranid, @sAgentComm = sAgentComm, @sAgentCommCurrency = sAgentCommCurrency, @customerId = TS.customerId
		, @introducer = RT.promotionCode, @forexGainLoss = ISNULL(RT.agentFxGain, 0)
		, @userId = AU.userId, @tranId = RT.id
		, @tpTranNo = RT.UPLOADLOGID
		, @senderName = TS.FULLNAME
	FROM FastMoneyPro_Remit.DBO.remitTran RT(NOLOCK)
	LEFT JOIN FastMoneyPro_Remit.DBO.APPLICATIONUSERS AU(NOLOCK) ON AU.USERNAME = RT.CREATEDBY
	INNER JOIN FastMoneyPro_Remit.DBO.tranSenders TS(NOLOCK) ON TS.tranId = RT.id
	LEFT JOIN FastMoneyPro_Remit.DBO.COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = RT.pCountry
	LEFT JOIN FastMoneyPro_Remit.DBO.servicetypemaster ST(NOLOCK) ON ST.typeTitle = RT.paymentMethod
	WHERE controlno = @controlNoEnc

	DECLARE @Mobile VARCHAR(25), @isSAgentInternalAgent CHAR(1), @sendingCommExpences VARCHAR(30) = '910139266612', @agentCommPayableAcc VARCHAR(30), @forexGainLossAcc VARCHAR(30)
	,@partnerPayable MONEY, @referralAccountNo VARCHAR(30), @referralAccountNoComm VARCHAR(30), @unpaidRemittanceMitatsuAcc VARCHAR(30) = '139286032', @advancePaymentUnpaidRemittanceAcc VARCHAR(30) = '100339261593'
	,@deferredRevenueAcc VARCHAR(30) = '4839223256', @marketingIncentivePayableAcc VARCHAR(30) = '9539277135', @marketPromotionAcc VARCHAR(30) = '910639248385', @deferredRevenue MONEY
	,@REFERRAL_TYPE CHAR(2)

	
	SELECT @deferredRevenue = ISNULL(@serviceCharge, 0) - ISNULL(@pAgentComm, 0)
	--Calculate fx
	IF @pSuperAgent NOT IN (394132)
		SET @partnerPayable = ROUND((@pAmt/@pCurrCostRate), 2)--@tAmt - @forexGainLoss
	
	SELECT @isSAgentInternalAgent = CASE WHEN ISNULL(isIntl, 0) = 1 THEN 'N' ELSE 'Y' END
	FROM FastMoneyPro_Remit.dbo.AGENTMASTER (NOLOCK)
	WHERE AGENTID = @sAgent

	DECLARE @REFERRAL_BRANCH_ID INT, @REFERRAL_ID INT

	IF ISNULL(@introducer, '') <> ''
	BEGIN
		SELECT @REFERRAL_TYPE = REFERRAL_TYPE_CODE, @REFERRAL_BRANCH_ID = BRANCH_ID, @REFERRAL_ID = ROW_ID
		FROM FastMoneyPro_Remit.DBO.REFERRAL_AGENT_WISE (NOLOCK) 
		WHERE REFERRAL_CODE = @introducer 
	END
	
	IF @collMode = 'Cash Collect'
	BEGIN
		IF @isSAgentInternalAgent = 'Y' AND ISNULL(@introducer, '') = ''
		BEGIN
			SELECT @customerAccNum = ACCT_NUM
			FROM ac_master AC(NOLOCK)
			WHERE agent_id = @userId
			AND acct_rpt_code='TCA'
		END
		ELSE IF @isSAgentInternalAgent = 'Y' AND ISNULL(@introducer, '') <> ''
		BEGIN
			IF @REFERRAL_TYPE = 'RB' 
			BEGIN
				IF EXISTS(SELECT 1 FROM FastMoneyPro_Remit.dbo.APPLICATIONUSERS (NOLOCK) WHERE USERID = @userId AND AGENTID = @sAgent)
				BEGIN
					SELECT @customerAccNum = ACCT_NUM
					FROM ac_master AC(NOLOCK)
					WHERE agent_id = @userId
					AND acct_rpt_code='TCA'
				END
				ELSE
				BEGIN
					SELECT @customerAccNum = ACCT_NUM
					FROM ac_master AC(NOLOCK)
					WHERE  acct_rpt_code='BVA'
					AND AGENT_ID = @sAgent
				END
			END
			ELSE
			BEGIN
				--if introducer principle amount is booked in Cash In Transit acc
				SELECT @customerAccNum = ACCT_NUM
				FROM AC_MASTER (NOLOCK)
				WHERE 1=1
				AND AGENT_ID = @REFERRAL_BRANCH_ID
				AND ACCT_RPT_CODE = 'CTA'
				
				SELECT @referralAccountNo = ACCT_NUM 
				FROM AC_MASTER (NOLOCK) 
				WHERE AGENT_ID = @REFERRAL_ID 
				AND ACCT_RPT_CODE = 'RA' 
				AND GL_CODE = 0

				SELECT @referralAccountNoComm = ACCT_NUM 
				FROM AC_MASTER (NOLOCK) 
				WHERE AGENT_ID = @REFERRAL_ID 
				AND ACCT_RPT_CODE = 'RAC' 
				AND GL_CODE = 0
			END
			
		END
		ELSE 
		BEGIN
			SELECT @customerAccNum = ACCT_NUM
			FROM ac_master AC(NOLOCK)
			INNER JOIN FastMoneyPro_Remit.dbo.APPLICATIONUSERS AU(NOLOCK) ON AU.USERID = AC.AGENT_ID
			WHERE AU.AGENTID = @sAgent
			AND acct_rpt_code='TCA'

			SELECT @agentCommPayableAcc = ACCT_NUM
			FROM ac_master AC(NOLOCK)
			WHERE agent_id = @sAgent
			AND acct_rpt_code='ACP'
		END
	END
	ELSE IF @collMode = 'Bank Deposit'
	BEGIN
		--IF NOT EXISTS (SELECT 1 FROM FastMoneyPro_Remit.DBO.CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE TRAN_ID = @tpTranNo AND TRANDATE >= '2019-01-01')
		--BEGIN
		--	SET @customerAccNum = '139247111'
		--END
		--ELSE
		--BEGIN
		--	SET @customerAccNum = '101139273793'
		--	--SELECT @customerAccNum = walletAccountNo 
		--	--FROM FastMoneyPro_Remit.dbo.customerMaster (NOLOCK)
		--	--WHERE customerId = @customerId
		--END
		
		IF @REFERRAL_TYPE = 'RR'
		BEGIN
			SELECT @referralAccountNoComm = ACCT_NUM 
			FROM AC_MASTER (NOLOCK) 
			WHERE AGENT_ID = @REFERRAL_ID 
			AND ACCT_RPT_CODE = 'RAC' 
			AND GL_CODE = 0
		END 
		
		SET @customerAccNum = '101139273793'

		IF @isSAgentInternalAgent = 'N'
		BEGIN
			SELECT @agentCommPayableAcc = ACCT_NUM
			FROM ac_master AC(NOLOCK)
			WHERE agent_id = @sAgent
			AND acct_rpt_code='ACP'
		END
	END
	
	SELECT @JMEserviceChargeIncomeAcc = acct_num FROM ac_master (NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code = 'TPS'
	--set @JMEserviceChargeIncomeAcc = '900141035109'
	SELECT @JMECommissionExpencesAcc = ACCT_NUM FROM AC_MASTER (NOLOCK) WHERE AGENT_ID = @pAgent AND acct_rpt_code = 'TC'
	SELECT @forexGainLossAcc = ACCT_NUM FROM AC_MASTER (NOLOCK) WHERE AGENT_ID = @pAgent AND acct_rpt_code = 'TFX'
	
	IF(@pAgent = 394133)
	BEGIN
		SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code = 'TPA' AND ac_currency = 'VND'
	END
	ELSE
	BEGIN
		SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code = 'TPA'
	END
	SET @sAgentComm = CASE WHEN @sAgentCommCurrency = 'JPY' THEN ISNULL(@sAgentComm, 0) ELSE ISNULL(@sAgentComm, 0) * @sCurrCostRate END
	
	--voucher entry for customer
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
	SELECT @controlNo,'system',@customerAccNum,'j','dr',@cAmt,@cAmt,1,@TxnDate
		,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer

	-----------------------New entries for unpaid remittances (for mitatsu)-------------------------------
	--Unpaid Remittance (Mitatsusaimu)
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
	SELECT @controlNo,'system',@unpaidRemittanceMitatsuAcc,'j','cr',@tAmt,@tAmt,1,@TxnDate
		,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer

	--Advance Payment-Unpaid Remittance
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
	SELECT @controlNo,'system',@advancePaymentUnpaidRemittanceAcc,'j','dr',@tAmt,@tAmt,1,@TxnDate
		,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer

	----DEFERRED REVENUE ACC
	--INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	--	,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
	--SELECT @controlNo,'system',@deferredRevenueAcc,'j','cr',@deferredRevenue,@deferredRevenue,1,@TxnDate
	--	,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer

	----------------------------------------New part end----------------------------------------------
	
	--voucher entry for payout agent principle payable
	IF(@pAgent = 394133)
	BEGIN
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@pAgentPrincipleAcc,'j','cr',@pAmt,@pAmt/@tAmt,@pAmt/(@pAmt/@tAmt)--@pcurrCostRate
			,@TxnDate,'USDVOUCHER',@pCurr,@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch
	END
	ELSE
	BEGIN
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@pAgentPrincipleAcc,'j','cr',@partnerPayable,1,@partnerPayable,@TxnDate
			,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch
	END
	
	IF @isSAgentInternalAgent = 'Y' AND ISNULL(@introducer, '') <> '' 
	BEGIN
		IF @REFERRAL_TYPE = 'RR'
		BEGIN
			SELECT @sAgentComm = ISNULL(PAID_COMMISSION, 0) + ISNULL(PAID_FX, 0) + ISNULL(PAID_FLAT, 0) + ISNULL(PAID_NEW_CUSTOMER, 0) 
			FROM FastMoneyPro_Remit.dbo.REFERRAL_INCENTIVE_TRANSACTION_WISE (NOLOCK) 
			WHERE TRAN_ID = @tranId
			AND IS_CANCEL = 0

			--voucher entry for referral agent
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
			SELECT @controlNo,'system',@marketingIncentivePayableAcc,'j','cr',@sAgentComm,@sAgentComm,1,@TxnDate
				,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer

			--voucher entry for referral agent
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
			SELECT @controlNo,'system',@referralAccountNoComm,'j','cr',@sAgentComm,@sAgentComm,1,@TxnDate
				,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer

			--voucher entry for referral agent
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
			SELECT @controlNo,'system',@marketPromotionAcc,'j','dr',@sAgentComm,@sAgentComm,1,@TxnDate
				,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer
		END
		IF @REFERRAL_TYPE IN ('RR', 'RC') AND @collMode = 'Cash Collect'
		BEGIN
			--voucher entry for referral agent
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id,CHEQUE_NO)	
			SELECT @controlNo,'system',@referralAccountNo,'j','dr',@cAmt,@cAmt,1,@TxnDate
				,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch,@introducer
		END
	END
	
	IF ISNULL(@serviceCharge, 0) <> 0
	BEGIN
		--voucher entry for JME service charge income
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)
		SELECT @controlNo,'system',@JMEserviceChargeIncomeAcc,'j','cr',@serviceCharge,1,@serviceCharge,@TxnDate
			,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch
	END
	
	IF @pCountry <> 'VIETNAM'
	BEGIN
		--voucher entry for forex gain/loss
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@forexGainLossAcc,'j','cr',@forexGainLoss,1,@forexGainLoss,@TxnDate
			,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch
	END

	IF ISNULL(@extraPayComm,0) > 0
		SET @pAgentComm = @pAgentComm - @extraPayComm
	
	IF ISNULL(@pAgentComm, 0) <> 0
	BEGIN
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,tran_date,usd_amt,usd_rate
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@JMECommissionExpencesAcc,'j','dr'
			,CASE WHEN @pAgentCommCurrency = 'JPY' THEN @pAgentComm ELSE @pAgentComm/(@pAmt/@tAmt) END--@pcurrCostRate END
			,@TxnDate
			,@pAgentComm
			,1
			,'USDVOUCHER','JPY',@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch

		--voucher entry for payout agent commission payable
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,tran_date,usd_amt,usd_rate
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)
		SELECT @controlNo,'system',@pAgentPrincipleAcc,'j','cr'
			,CASE WHEN @pAgentCommCurrency = 'JPY' THEN @pAgentComm ELSE @pAgentComm/(@pAmt/@tAmt) END--@pcurrCostRate END
			,@TxnDate
			,@pAgentComm
			,CASE WHEN @pAgentCommCurrency = 'JPY' THEN 1 ELSE @pAmt/@tAmt END
			,'USDVOUCHER'
			,@pAgentCommCurrency
			,@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch
	
	END
	
	
	IF @isSAgentInternalAgent = 'N'
	BEGIN
		--voucher entry for sending agent commission payable
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,tran_date,usd_amt,usd_rate
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)
		SELECT @controlNo,'system',@sendingCommExpences,'j','dr'
			,@sAgentComm
			,@TxnDate
			,@sAgentComm
			,1
			,'USDVOUCHER'
			,@sAgentCommCurrency
			,@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch

		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,tran_date,usd_amt,usd_rate
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)
		SELECT @controlNo,'system',@agentCommPayableAcc,'j','cr'
			,@sAgentComm
			,@TxnDate
			,@sAgentComm
			,1
			,'USDVOUCHER'
			,@sAgentCommCurrency
			,@customerEmail,@controlNo,'Remittance Voucher', @sAgent, @sBranch
	END

	--SELECT a.acct_name,t.* FROM temp_tran t(nolock)
	--INNER JOIN ac_master a(nolock) on a.acct_num = t.acct_num
	--WHERE sessionID = @controlNo
	--rollback transaction
	--RETURN
	COMMIT TRANSACTION

--return	
--DECLARE @narration VARCHAR(500) = 'Remittance :'+@controlNo+' by:'+@customerEmail +' from '+@sBranchName+'-branch on dtd: '+cast(@TxnDate as VARCHAR)
DECLARE @narration VARCHAR(100) = 'Remittance No (Send) : '+@controlNo + ' - ' + ISNULL(@senderName, '') 


IF ISNULL(@refNum, '') <> ''
BEGIN
	EXEC [spa_saveTempTrnUSDManual] @flag='i',@sessionID=@controlNo,@date=@TxnDate,@narration=@narration,@company_id=1,@v_type='j',@user='system', @ref_num = @refNum
END
ELSE
BEGIN
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@controlNo,@date=@TxnDate,@narration=@narration,@company_id=1,@v_type='j',@user='system'
END
---- IF PARTNER BNI THEN MARGIN IS @pCurrHoMargin ELSE @sCurrHoMargin
UPDATE tran_master SET SendMargin = CASE WHEN @pAgent = 392227 THEN @pCurrHoMargin ELSE @sCurrHoMargin END where field1= @controlNo

	--save to main table from  temp table

--delete from tran_master where ref_num = 379
--delete from tran_masterDetail where ref_num = 379


--update billSetting set journal_voucher = 379


