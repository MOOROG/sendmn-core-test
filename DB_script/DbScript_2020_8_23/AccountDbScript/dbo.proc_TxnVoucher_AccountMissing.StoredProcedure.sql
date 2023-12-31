ALTER  proc [dbo].[proc_TxnVoucher_AccountMissing]
(
	@controlNo	varchar(30) 
)
as
set nocount on;
set xact_abort on;

delete from temp_tran WHERE sessionID=@controlNo

	declare @controlNoEnc varchar(50) = dbo.fnaencryptstring(@controlNo)
	
	IF not EXISTS (select 'a' from SendMnPro_Remit.dbo.remitTran(nolock) where controlNo = @controlNoEnc)
	BEGIN
		select 'Transaction not found in remittance'
		return
	END
	IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' )
	BEGIN
		select 'Voucher not generated yet'
		return
	END

BEGIN transaction

	declare @customerId bigint, @customerEmail varchar(80), @pAgent int, @customerAccNum varchar(50), @cAmt money, @tAmt money, 
		@sCurrCostRate money, @serviceCharge money, @pAgentComm money,@ID INT,@pCountry varchar(40),@payMode  varchar(30)
	declare @pAgentPrincipleAcc varchar(50), @GMEserviceChargeIncomeAcc varchar(50), @GMECommissionExpencesAcc varchar(50),
		@pAgenetCommPayableAcc varchar(50),@TxnDate date,@tranType CHAR(1),@sBranchName varchar(100),@agentSettCurr VARCHAR(10)
	
	DECLARE @pSuperAgent INT,@pSuperAgentName VARCHAR(100),@pAgentName VARCHAR(100),@pCurr VARCHAR(5),@CutomerRate DECIMAL(10,8)

	select @customerEmail = createdBy, @pAgent = pAgent, @cAmt = round(cAmt,0), @tAmt = round(tAmt,0),
		@sCurrCostRate = (sCurrCostRate+ISNULL(sCurrHoMargin,0)), @serviceCharge = serviceCharge, @pAgentComm = pAgentComm
		,@ID = id,@pCountry = pCountry,@payMode = paymentMethod,@TxnDate = approvedDate, @tranType = tranType
		,@sBranchName = sBranchName,@pCurr = payoutCurr,@CutomerRate = customerRate
	from SendMnPro_Remit.dbo.remitTran (nolock) 
	where controlno = @controlNoEnc


	select @agentSettCurr = agentSettCurr from SendMnPro_Remit.dbo.agentmaster(nolock) where agentid = @pAgent

	IF EXISTS(SELECT 'A' FROM SendMnPro_Remit.dbo.remitTran (NOLOCK) where id = @ID AND isnull(pAgentComm,0)=0)
	BEGIN
		IF @pCountry ='Nepal'
		BEGIN
			IF @pAgent IS NULL
			BEGIN
				SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,@pAgent = sAgent,@pAgentName = sAgentName
				FROM SendMnPro_Remit.dbo.FNAGetBranchFullDetails(1056)
			END

			select 
				@pAgentComm = (SELECT amount FROM SendMnPro_Remit.dbo.FNAGetPayComm
				(rt.sBranch,(SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), 
				NULL, NULL, 151, null, @pAgent, rt.sAgentCommCurrency
				,(select serviceTypeId from SendMnPro_Remit.dbo.servicetypemaster(nolock) where typeTitle = rt.paymentMethod)
				, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
				))
			from SendMnPro_Remit.dbo.remitTran rt(nolock) where id = @ID

			update SendMnPro_Remit.dbo.remitTran set pAgentComm = @pAgentComm,pAgent = @pAgent,pAgentName = @pAgentName where id = @ID

		END
		ELSE IF @pCountry ='vietnam' or @pAgent = 224389
		BEGIN
			----## set all txn for dongA
			SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,@pAgent = sAgent,@pAgentName = sAgentName
			FROM SendMnPro_Remit.dbo.FNAGetBranchFullDetails(@pAgent)

			SELECT 
					@pAgentComm = (SELECT amount FROM SendMnPro_Remit.dbo.FNAGetPayComm
					(sBranch,(SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
						NULL, sAgent, (SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = pCountry),
						null, @pAgent,'USD'
						,(select serviceTypeId from SendMnPro_Remit.dbo.servicetypemaster(nolock) where typeTitle = paymentMethod)
						, cAmt, pAmt, serviceCharge, NULL, NULL
					))
			FROM SendMnPro_Remit.dbo.remitTran(NOLOCK)
			WHERE id = @ID

			update SendMnPro_Remit.dbo.remitTran set pAgentComm = @pAgentComm,pAgent = @pAgent,pAgentName = @pAgentName where id = @ID

		END
		ELSE IF @pCountry ='SRI LANKA'
		BEGIN
			----## set all txn for dongA
			SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,@pAgent = sAgent,@pAgentName = sAgentName
			FROM SendMnPro_Remit.dbo.FNAGetBranchFullDetails(221271)

			SELECT 
					@pAgentComm = (SELECT amount FROM SendMnPro_Remit.dbo.FNAGetPayComm
					(sBranch,(SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = sCountry), 
						NULL, sAgent, (SELECT countryId FROM SendMnPro_Remit.dbo.countryMaster WITH(NOLOCK) WHERE countryName = pCountry),
						null, @pAgent,'LKR'
						,(select serviceTypeId from SendMnPro_Remit.dbo.servicetypemaster(nolock) where typeTitle = paymentMethod)
						, cAmt, pAmt, serviceCharge, NULL, NULL
					))
			FROM SendMnPro_Remit.dbo.remitTran(NOLOCK)
			WHERE id = @ID

			update SendMnPro_Remit.dbo.remitTran set pAgentComm = @pAgentComm,pagentcommcurrency='LKR',pAgent = @pAgent,pAgentName = @pAgentName where id = @ID

		END
	END
	IF @tranType = 'O'
	BEGIN
		select @customerId = customerId, @customerAccNum = walletAccountNo 
		from SendMnPro_Remit.dbo.customerMaster (nolock) where email = @customerEmail
	END
	ELSE IF @tranType = 'I'
	BEGIN
		SET @customerAccNum = '100241011536' --Kwangju Bank-(345648)KRW
	END
	set @GMEserviceChargeIncomeAcc = '900141035109'
	set @GMECommissionExpencesAcc = '910141036526'

	SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TP'
	SELECT @pAgenetCommPayableAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TC'

	IF @pAgent IN(2090,221271) AND @pCurr = 'USD'
	BEGIN
		SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TPU'
	END

	IF EXISTS(SELECT 'A' FROM SendMnPro_Remit.dbo.CUSTOMERMASTER(NOLOCK) WHERE len(referelCode)=13 and left(referelCode,5)='94240' 
			and walletAccountNo = @customerAccNum AND lastTranId IS NULL)
	BEGIN
		UPDATE SendMnPro_Remit.dbo.CUSTOMERMASTER SET lastTranId = @ID WHERE walletAccountNo = @customerAccNum
	END

--voucher entry for customer
IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @customerAccNum and field2='Remittance Voucher' )
BEGIN
	insert into tran_master(acc_num,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date
	,company_id,RunningBalance,usd_amt,usd_rate,employeeName,field1,field2,fcy_Curr)

	select top 1 @customerAccNum,entry_user_id,dbo.FunGetGLCode(@customerAccNum),1,'dr',ref_num,@cAmt,tran_date,tran_type,created_date
		,company_id,dbo.FNAGetRunningBalance(@customerAccNum,@cAmt,'dr'),@cAmt,1,@customerEmail,@controlNo,field2,'KRW'
	from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system'
END


--voucher entry for GME service charge income
IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @GMEserviceChargeIncomeAcc and field2='Remittance Voucher' )
BEGIN
	insert into tran_master(acc_num,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date
	,company_id,RunningBalance,usd_amt,usd_rate,employeeName,field1,field2,fcy_Curr)

	select top 1 @GMEserviceChargeIncomeAcc,entry_user_id,dbo.FunGetGLCode(@GMEserviceChargeIncomeAcc),2,'cr',ref_num,@serviceCharge,tran_date,tran_type,created_date
		,company_id,dbo.FNAGetRunningBalance(@GMEserviceChargeIncomeAcc,@serviceCharge,'cr'),@serviceCharge,1,@customerEmail,@controlNo,field2,'KRW'
	from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system'
END
IF EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @GMEserviceChargeIncomeAcc and field2='Remittance Voucher'
	and tran_amt is null )
BEGIN
	update tran_master set tran_amt = @serviceCharge,usd_amt=@serviceCharge
	where field1=@controlNo and tran_type='j' and entry_user_id='system' 
	and acc_num = @GMEserviceChargeIncomeAcc and field2='Remittance Voucher'
END

--voucher entry for payout agent principle payable
IF @pAgent in( 2090,221271,1056) AND @pCurr <> 'USD'
BEGIN
	IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @pAgentPrincipleAcc and field2='Remittance Voucher' )
	BEGIN
		insert into tran_master(acc_num,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date
		,company_id,RunningBalance,usd_amt,usd_rate,employeeName,field1,field2,fcy_Curr)

		select top 1 @pAgentPrincipleAcc,entry_user_id,dbo.FunGetGLCode(@pAgentPrincipleAcc),3,'cr',ref_num,@tAmt,tran_date,tran_type,created_date
			,company_id,dbo.FNAGetRunningBalance(@pAgentPrincipleAcc,@tAmt,'cr'),@tAmt*@CutomerRate,@CutomerRate,@customerEmail,@controlNo,field2,@pCurr
		from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system'
	END
	ELSE
	BEGIN
		UPDATE tran_master SET usd_amt=ROUND(@tAmt*@CutomerRate,2) ,usd_rate = @CutomerRate,fcy_Curr=@pCurr
		where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @pAgentPrincipleAcc and field2='Remittance Voucher' 
	END
END
ELSE 
BEGIN
	IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @pAgentPrincipleAcc and field2='Remittance Voucher' )
	BEGIN
		insert into tran_master(acc_num,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date
		,company_id,RunningBalance,usd_amt,usd_rate,employeeName,field1,field2,fcy_Curr)

		select top 1 @pAgentPrincipleAcc,entry_user_id,dbo.FunGetGLCode(@pAgentPrincipleAcc),3,'cr',ref_num,@tAmt,tran_date,tran_type,created_date
			,company_id,dbo.FNAGetRunningBalance(@pAgentPrincipleAcc,@tAmt,'cr'),@tAmt/@sCurrCostRate,@sCurrCostRate,@customerEmail,@controlNo,field2,'USD'
		from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system'
	END
END
--voucher entry for payout agent commission payable
IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @pAgenetCommPayableAcc and field2='Remittance Voucher' )
BEGIN
	insert into tran_master(acc_num,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date
	,company_id,RunningBalance,usd_amt,usd_rate,employeeName,field1,field2,fcy_Curr)

	select top 1 @pAgenetCommPayableAcc,entry_user_id,dbo.FunGetGLCode(@pAgenetCommPayableAcc),4,'cr',ref_num
	,CASE WHEN @pagent in(2140,224389,221226) THEN(@pAgentComm*@sCurrCostRate) WHEN @pagent in(221271) THEN(@pAgentComm*@CutomerRate) ELSE @pAgentComm END
	,tran_date,tran_type,created_date
	,company_id,dbo.FNAGetRunningBalance(@pAgenetCommPayableAcc,@tAmt,'cr')
	,CASE WHEN @pagent in(2140,224389,221226,221271) THEN @pAgentComm ELSE @pAgentComm/@sCurrCostRate END
	,CASE WHEN @pagent in(221271) THEN @CutomerRate ELSE @sCurrCostRate END
	,@customerEmail,@controlNo,field2
	,fcy_Curr = CASE WHEN @pagent in(221271) THEN 'LKR' ELSE 'USD' END
	from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system'
END
IF EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @pAgenetCommPayableAcc and field2='Remittance Voucher'
	and tran_amt is null 
	)
BEGIN
	update tran_master set tran_amt = CASE WHEN @pagent in(2140,224389,221226) THEN(@pAgentComm*@sCurrCostRate) WHEN @pagent in(221271) THEN(@pAgentComm*@CutomerRate) ELSE @pAgentComm END
						   ,usd_amt = CASE WHEN @pagent in(2140,224389,221226,221271) THEN @pAgentComm ELSE @pAgentComm/@sCurrCostRate END
						   ,usd_rate = CASE WHEN @pagent in(221271) THEN @CutomerRate ELSE @sCurrCostRate END
						   ,fcy_Curr = CASE WHEN @pagent in(221271) THEN 'LKR' ELSE 'USD' END
	where field1=@controlNo and tran_type='j' and entry_user_id='system' 
	and acc_num = @pAgenetCommPayableAcc and field2='Remittance Voucher'
END

--voucher entry for GME commission expences
IF not EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @GMECommissionExpencesAcc and field2='Remittance Voucher' )
BEGIN
	insert into tran_master(acc_num,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date
	,company_id,RunningBalance,usd_amt,usd_rate,employeeName,field1,field2,fcy_Curr)

	select top 1 @GMECommissionExpencesAcc,entry_user_id,dbo.FunGetGLCode(@GMECommissionExpencesAcc),5,'dr',ref_num
	,CASE WHEN @pagent in(2140,224389,221226) THEN(@pAgentComm*@sCurrCostRate) WHEN @pagent in(221271) THEN(@pAgentComm*@CutomerRate) ELSE @pAgentComm END
	,tran_date,tran_type,created_date
	,company_id,dbo.FNAGetRunningBalance(@GMECommissionExpencesAcc,@tAmt,'dr')
	,CASE WHEN @pagent in(2140,224389,221226) THEN(@pAgentComm*@sCurrCostRate) WHEN @pagent in(221271) THEN(@pAgentComm*@CutomerRate) ELSE @pAgentComm END
	,1,@customerEmail,@controlNo,field2,'KRW'
	from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system'
END
IF EXISTS (select 'A' from tran_master(nolock) where field1=@controlNo and tran_type='j' and entry_user_id='system' and acc_num = @GMECommissionExpencesAcc and field2='Remittance Voucher'
	and tran_amt is null 
	)
BEGIN
	update tran_master set tran_amt = CASE WHEN @pagent in(2140,224389,221226) THEN(@pAgentComm*@sCurrCostRate) WHEN @pagent in(221271) THEN(@pAgentComm*@CutomerRate) ELSE @pAgentComm END
						   ,usd_amt = CASE WHEN @pagent in(2140,224389,221226) THEN(@pAgentComm*@sCurrCostRate) WHEN @pagent in(221271) THEN(@pAgentComm*@CutomerRate) ELSE @pAgentComm END
	where field1=@controlNo and tran_type='j' and entry_user_id='system' 
	and acc_num = @GMECommissionExpencesAcc and field2='Remittance Voucher'
END

----SELECT a.acct_name,t.* FROM temp_tran t(nolock)
----inner join ac_master a(nolock) on a.acct_num = t.acct_num
---- WHERE sessionID = @controlNo
commit transaction
----return	
select dbo.FunGetACName(acc_num),field1,TRAN_AMT,USD_AMT,USD_RATE,FCY_CURR,* from tran_master(nolock) where field1 = @controlNo


GO
