USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionVoucherEntry_Old]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_transactionVoucherEntry_Old]
(
	@controlNo	VARCHAR(30) 
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
DELETE FROM temp_tran WHERE sessionID=@controlNo

DECLARE @controlNoEnc VARCHAR(50) = dbo.fnaencryptstring(@controlNo)
	
IF EXISTS (SELECT 'A' FROM tran_master(NOLOCK) WHERE field1=@controlNo AND tran_type='j' AND entry_user_id='system' )
BEGIN
	IF NOT EXISTS (SELECT TOP 1 * 
					FROM tran_master(NOLOCK) 
					WHERE field1 = @controlNo 
					AND tran_type='j' 
					AND entry_user_id='system' 
					AND isnull(acct_type_code,'') = 'Reverse'
	)
	BEGIN
		RETURN
	END
END
	
BEGIN TRANSACTION
	
	DECLARE @customerId BIGINT,@ReferalCode VARCHAR(20), @customerEmail VARCHAR(80), @pAgent INT,@pBank INT, @customerAccNum VARCHAR(50)
		, @cAmt MONEY, @tAmt MONEY,@pAmt MONEY,@sCurrCostRate MONEY,@sCurrHoMargin MONEY, @serviceCharge MONEY, @pAgentComm MONEY,@ID INT
		, @pCountry VARCHAR(40),@payMode  VARCHAR(30)

	DECLARE @pAgentPrincipleAcc VARCHAR(50), @GMEserviceChargeIncomeAcc VARCHAR(50), @GMECommissionExpencesAcc VARCHAR(50),
		@pAgenetCommPayableAcc VARCHAR(50),@TxnDate date,@tranType CHAR(1),@sBranchName VARCHAR(100),@pAgentCommCurrency VARCHAR(5)
		,@extraPayComm MONEY,@pCurrCostRate MONEY,@pCurrHoMargin MONEY,@sRouteId VARCHAR(20),@kftcNarration NVARCHAR(500)
	
	DECLARE @pSuperAgent INT,@pSuperAgentName VARCHAR(100),@pAgentName VARCHAR(100),@pCurr VARCHAR(5),@CutomerRate DECIMAL(10,8)

	SELECT @customerEmail = createdBy, @pAgent = pAgent, @pBank = pBank, @cAmt = round(cAmt, 0), @tAmt = round(tAmt, 0), @pAmt = pAmt
		, @sCurrCostRate = (sCurrCostRate+ISNULL(sCurrHoMargin,0)), @serviceCharge = serviceCharge, @pAgentComm = pAgentComm, @pAgentCommCurrency = pAgentCommCurrency
		, @ID = id, @pCountry = pCountry, @payMode = paymentMethod, @TxnDate = approvedDate, @tranType = tranType, @sCurrHoMargin = sCurrHoMargin
		, @sBranchName = sBranchName, @pCurr = payoutCurr, @CutomerRate = customerRate, @pCurrCostRate = pCurrCostRate, @pCurrHoMargin = pCurrHoMargin
		, @sRouteId = sRouteId
	from SendMnPro_Remit.dbo.remitTran (nolock) 
	where controlno = @controlNoEnc

	IF EXISTS(SELECT 'A' FROM SendMnPro_Remit.dbo.remitTran (NOLOCK) where id = @ID AND isnull(pAgentComm,0)=0)
	BEGIN
		IF @pAgent = 393228
		BEGIN
			SET @pAgentCommCurrency='USD'
			SELECT 
				@pAgentComm = (SELECT amount FROM SendMnPro_Remit.dbo.FNAGetPayComm
				(sBranch,(SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
					NULL, sAgent, (SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = 'Russian Federation'),
					null, @pAgent,@pAgentCommCurrency
					,(SELECT serviceTypeId from SendMnPro_Remit.dbo.servicetypemaster(nolock) where typeTitle = paymentMethod)
					, cAmt, pAmt, serviceCharge, NULL, NULL
				))
			FROM SendMnPro_Remit.dbo.remitTran(NOLOCK)
			WHERE id = @ID
		END
		ELSE
		BEGIN
			SELECT @pAgentCommCurrency = commissionCurrency FROm SendMnPro_Remit.dbo.scpaymaster(NOLOCK)
			where rCountry = (SELECT TOP 1 countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = @pCountry) 
			and tranType = (SELECT TOP 1 serviceTypeId from SendMnPro_Remit.dbo.servicetypemaster(nolock) where typeTitle = @payMode)
			and rsAgent = @pSuperAgent

			SET @pAgentCommCurrency = CASE WHEN @pAgent = 221271 THEN @pCurr ELSE @pAgentCommCurrency END

			SELECT 
					@pAgentComm = (SELECT amount FROM SendMnPro_Remit.dbo.FNAGetPayComm
					(sBranch,(SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
						NULL, sAgent, (SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = pCountry),
						null, @pAgent,@pAgentCommCurrency
						,(SELECT serviceTypeId from SendMnPro_Remit.dbo.servicetypemaster(nolock) where typeTitle = paymentMethod)
						, cAmt, pAmt, serviceCharge, NULL, NULL
					))
			FROM SendMnPro_Remit.dbo.remitTran(NOLOCK)
			WHERE id = @ID
		END
		UPDATE SendMnPro_Remit.dbo.remitTran set pAgentComm = @pAgentComm,pAgentCommCurrency = @pAgentCommCurrency where id = @ID

	END
	----## FROM TRANGLO TRANSACTION IN CAMBODIA PAYOUT COMM IS COMMISSION SETUP + 0.1 % OF PAYOUT AMT 
	IF @pAgent = 224389 and @pCountry = 'Cambodia' and @pAgentComm=3.5
	begin
		SELECT @extraPayComm = (@pAmt/100.00 * 0.1),@pAgentComm = @pAgentComm+@extraPayComm
		UPDATE SendMnPro_Remit.dbo.remitTran set pAgentComm = @pAgentComm where id = @ID
	END

	IF @pAgent = 224389 and @pCountry = 'Cambodia'
	BEGIN
		SELECT @extraPayComm = @pAgentComm - 3.5
	END
	----## IN SRILANKA FOR COMMERCIAL BANK IN USD TRANSACTION PAY AGENT COMM IS 1 $
	IF @pAgent = 221271 and @pCountry = 'Sri Lanka' AND @PCURR ='USD' AND @pBank = 221275
	BEGIN
		SELECT @pAgentComm = 1
		UPDATE SendMnPro_Remit.dbo.remitTran set pAgentComm = @pAgentComm where id = @ID AND @pAgent = 221271
	END
	
	DECLARE @SMSBody VARCHAR(90) = 'Your transaction GME No: '+@controlNo+' is successfully sent. Thank you for using GME.'
	DECLARE @Mobile VARCHAR(20)
	
	IF @tranType = 'I'
	BEGIN
		SET @customerAccNum = '100241011536' --Kwangju Bank-(345648)KRW
	END
	ELSE 
	BEGIN
		SELECT @customerId = customerId, @customerAccNum = walletAccountNo ,@Mobile = mobile,@ReferalCode = referelCode
		from SendMnPro_Remit.dbo.customerMaster (nolock) where email = @customerEmail
	END
	IF @sRouteId = 'A'
	BEGIN

		SELECT @kftcNarration = Narration FROM SendMnPro_Remit.dbo.[FNA_KFTC_CUST_DETAILBY_TXN](@ID)

		----SET @customerAccNum = '100241027580' --Kwangju-(574382) CMS Customer Account-KRW
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2)	
		SELECT @controlNo,'system','100241027580','j','dr',@cAmt,@cAmt,1,@TxnDate
			,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
		UNION ALL 
		SELECT @controlNo,'system',@customerAccNum,'j','cr',@cAmt,@cAmt,1,@TxnDate
			,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
	END
	----## SMS TO IDENTIFY EVERY CUSTOMRE
	IF NOT EXISTS(SELECT TOP 1 'A' FROM KT_SMS.DBO.SDK_SMS_REPORT(nolock) WHERE SMS_MSG LIKE '%'+@controlNo+'%')
		exec SendMnPro_Remit.dbo.proc_CallToSendSMS @FLAG = 'I',@SMSBody = @SMSBody,@MobileNo = @Mobile

	set @GMEserviceChargeIncomeAcc = '900141035109'
	set @GMECommissionExpencesAcc = '910141036526'

	SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TP'
	SELECT @pAgenetCommPayableAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TC'

	IF @pAgent IN(2090,221271,393229,393862) AND @pCurr = 'USD'
	BEGIN
		SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TPU'
	END
	IF @pAgent IN(221271) AND @pCurr = 'USD'
	BEGIN
		SELECT @pAgenetCommPayableAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TCU'
	END
	--
IF @ReferalCode IN('PRIME','GMELK01','JENFOOD','Khan Kim')
BEGIN
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)	

	SELECT @controlNo,'system',Acct_num,'j','CR',1000,1000,1,@TxnDate
		,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
	FROM AC_MASTER(NOLOCK) WHERE acct_rpt_code = @ReferalCode
	
	--SELECT @controlNo,'system','500441084699','j','CR',1000,1000,1,@TxnDate
	--	,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
	UNION ALL
	SELECT @controlNo,'system','910141049600','j','DR',1000,1000,1,@TxnDate
		,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
END
--voucher entry for customer
INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)	
SELECT @controlNo,'system',@customerAccNum,'j','dr',@cAmt,@cAmt,1,@TxnDate
	,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'

--voucher entry for GME service charge income
INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)
SELECT @controlNo,'system',@GMEserviceChargeIncomeAcc,'j','cr',@serviceCharge,1,@serviceCharge,@TxnDate
	,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'

--voucher entry for payout agent principle payable
IF @pAgent in( 2090,221271,1056,393229,392227,393862) AND @pCurr <> 'USD'
BEGIN
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)	
	SELECT @controlNo,'system',@pAgentPrincipleAcc,'j','cr'
	,@pAmt
	,CASE WHEN @pAgent = 1056 THEN @pCurrCostRate ELSE @CutomerRate END
	,@tAmt,@TxnDate
	,'USDVOUCHER',@pCurr,@customerEmail,@controlNo,'Remittance Voucher'
END
ELSE 
BEGIN
INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)	
SELECT @controlNo,'system',@pAgentPrincipleAcc,'j','cr',@tAmt/@sCurrCostRate,@sCurrCostRate,@tAmt,@TxnDate
	,'USDVOUCHER','USD',@customerEmail,@controlNo,'Remittance Voucher'
END
--voucher entry for payout agent commission payable
INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,tran_date,usd_amt,usd_rate
	,rpt_code,trn_currency,emp_name,field1,field2)
SELECT @controlNo,'system',@pAgenetCommPayableAcc,'j','cr'
	,CASE WHEN @pAgentCommCurrency = 'USD' THEN(@pAgentComm*@sCurrCostRate) WHEN @pAgentCommCurrency IN('LKR','IDR') THEN(@pAgentComm/@CutomerRate) ELSE @pAgentComm END
	,@TxnDate
	,CASE WHEN @pAgentCommCurrency = 'KRW' THEN @pAgentComm/@sCurrCostRate ELSE @pAgentComm END
	,CASE WHEN @pAgentCommCurrency IN('LKR','IDR') THEN @CutomerRate ELSE @sCurrCostRate END
	,'USDVOUCHER'
	,CASE WHEN @pAgentCommCurrency IN('LKR') THEN 'LKR' WHEN @pAgentCommCurrency IN('IDR') THEN 'IDR' ELSE 'USD' END
	,@customerEmail,@controlNo,'Remittance Voucher'

--voucher entry for GME commission expences
IF @pAgent = 224389 and @pCountry = 'Cambodia'
BEGIN
	----Cambodia BANK CHARGE 0.1% book account: 910141036095 | Bank Charge By Foreign Settlement Bank
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2)	
	SELECT @controlNo,'system','910141036095','j','dr'
		,ROUND(@extraPayComm*@sCurrCostRate,4),1,ROUND(@extraPayComm*@sCurrCostRate,4),@TxnDate
		,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
END

BEGIN
	IF ISNULL(@extraPayComm,0) > 0
		SET @pAgentComm = @pAgentComm - @extraPayComm

	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2)	
	SELECT @controlNo,'system',@GMECommissionExpencesAcc,'j','dr'
		,CASE WHEN @pAgentCommCurrency = 'USD' THEN(@pAgentComm*@sCurrCostRate) WHEN @pAgentCommCurrency IN('LKR','IDR') THEN(@pAgentComm/@CutomerRate) ELSE @pAgentComm END
		,1
		,CASE WHEN @pAgentCommCurrency = 'USD' THEN(@pAgentComm*@sCurrCostRate) WHEN @pAgentCommCurrency IN('LKR','IDR') THEN(@pAgentComm/@CutomerRate) ELSE @pAgentComm END
		,@TxnDate
		,'USDVOUCHER','KRW',@customerEmail,@controlNo,'Remittance Voucher'
END
--SELECT a.acct_name,t.* FROM temp_tran t(nolock)
--inner join ac_master a(nolock) on a.acct_num = t.acct_num
-- WHERE sessionID = @controlNo
commit transaction
--return	
declare @narration VARCHAR(500) = 'Remittance :'+@controlNo+' by:'+@customerEmail +' from '+@sBranchName+'-branch on dtd: '+cast(@TxnDate as VARCHAR)

IF LEN(@kftcNarration) > 1
	SET @narration = @narration + ISNULL(@kftcNarration,'')


exec [spa_saveTempTrnUSD] @flag='i',@sessionID=@controlNo,@date=@TxnDate,@narration=@narration,@company_id=1,@v_type='j',@user='system'

---- IF PARTNER BNI THEN MARGIN IS @pCurrHoMargin ELSE @sCurrHoMargin
UPDATE tran_master SET SendMargin = CASE WHEN @pAgent = 392227 THEN @pCurrHoMargin ELSE @sCurrHoMargin END where field1= @controlNo

	--save to main table from  temp table


GO
