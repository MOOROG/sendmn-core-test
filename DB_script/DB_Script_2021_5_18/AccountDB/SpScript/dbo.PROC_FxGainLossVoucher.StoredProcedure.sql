USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_FxGainLossVoucher]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[PROC_FxGainLossVoucher]
	@date VARCHAR(10)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

begin

	if (isdate(@date))=0
	begin
		exec proc_errorHandler 1,'Invalid Date',null
		return
	end
	IF EXISTS(select 'A' from tran_master(nolock) where tran_date = @date AND field2='Remittance FX')
	begin
		exec proc_errorHandler 1,'FX already calculated.',null
		return
	end	

	declare @TxnFx varchar(20),@TradingFX varchar(20),@TradingFX_vnd VARCHAR(20)
	set @TxnFx		= '900141084569'

	declare @CLR_BAL_AMT float
	declare @SYSTEM_RESERVED_AMT float
	declare @LIEN_AMT float
	declare @UTILISED_AMT float
	declare @AVAILABLE_AMT float
	declare @DR_BAL_LIM float
	declare @totalRows int
	declare @Part_Id int
	declare @ac_num  varchar(20)
	declare @TotalAmt numeric(20,2)
	declare @trntype varchar(2)
	declare @totalDR numeric(20,2)
	declare @totalCR numeric(20,2)
	declare @ref_num varchar(20)
	declare @acct_ownership varchar(2), @billref varchar(50),@isnew varchar(2),@sessionID varchar(20) 

	set @sessionID = left(NEWID(),20)

	-- AC Masters values
	-- Temp Voucher values

	select sum(TxnGain) TxnGain,sum(TradingGL) TradingGL,pAgent,acct_rpt_code,TradingAc into #tempGainLoss from (
		select sum(c.TxnGain) TxnGain,TradingGL = sum(c.TradingGL),r.pAgent
			,acct_rpt_code = CASE WHEN R.pAgent IN( 2090,221271,1056) then 'TPU' else 'TP' end
			,TradingAc = '900141055635'
		from CorrenpondentLibilities c(nolock)
		inner join SendMnPro_Remit.dbo.remitTran r(nolock) on r.id = c.TranId
		where c.TxnDate = @date
		group by r.pAgent
		union all
		select 0 TxnGain,TradingGL = sum(c.TradingKrw),r.pAgent,acct_rpt_code='TP'
			,TradingAc = CASE WHEN R.pAgent =2090 THEN '900141066363' WHEN R.pAgent = 221271 THEN '900141047518' WHEN R.pAgent =1056 THEN '900141009020' END
		from CorrenpondentLibilities_Other c(nolock)
		inner join SendMnPro_Remit.dbo.remitTran r(nolock) on r.id = c.TranId
		where c.TxnDate = @date
		group by r.pAgent
	)x group by pAgent,acct_rpt_code,TradingAc

	ALTER TABLE #tempGainLoss ADD AccNum varchar(20),ActualGain money

	update t set t.AccNum = a.acct_num
		,t.ActualGain = case when t.TxnGain = 0 then t.TradingGL else t.TxnGain + t.TradingGL end
	from #tempGainLoss t
	inner join ac_master a(nolock) on a.agent_id = t.pAgent and a.acct_rpt_code = t.acct_rpt_code
	
	CREATE TABLE #tempsumTrn(Part_Id INT IDENTITY,acctnum VARCHAR(20),part_tran_type VARCHAR(5),tran_amt MONEY)
	
	INSERT INTO #tempsumTrn(acctnum,part_tran_type,tran_amt)	
	SELECT AccNum,CASE WHEN ActualGain>0 THEN 'DR' ELSE 'CR' END,abs(ActualGain)
	from #tempGainLoss

-- entry for trading FX
	INSERT INTO #tempsumTrn(acctnum,part_tran_type,tran_amt)	
	SELECT TradingAc,CASE WHEN SUM(TradingGL) < 0 THEN 'DR' ELSE 'CR' END,abs(SUM(TradingGL))
	from #tempGainLoss
	group by TradingAc

-- entry for transaction FX
	INSERT INTO #tempsumTrn(acctnum,part_tran_type,tran_amt)	
	SELECT @TxnFx,CASE WHEN SUM(TxnGain) < 0 THEN 'DR' ELSE 'CR' END,abs(sum(TxnGain))
	from #tempGainLoss

	--select dbo.FunGetACName(acctnum),* from #tempsumTrn
	--select * from #tempGainLoss
	--return

	select @Part_Id = max(Part_Id) from #tempsumTrn

	if not exists(select * from #tempsumTrn where part_tran_type='cr')
	begin
		exec proc_errorHandler 1,'CR Transaction is missing',null
		return;	
	end
				
	if not exists(select * from #tempsumTrn where part_tran_type='dr')
	begin
		exec proc_errorHandler 1,'DR Transaction is missing',null
			return;	
	end
				
	select @totalDR = sum(tran_amt) from #tempsumTrn where part_tran_type='dr'
				
	select @totalCR = sum(tran_amt) from #tempsumTrn where part_tran_type='cr'
	
	if ISNULL(@totalDR,0)<>ISNULL(@totalCR,0.1)
	begin	
		exec proc_errorHandler 1,'DR and CR amount not Equal',null
		return
	end


BEGIN TRANSACTION
	
	select @ref_num = journal_voucher from billSetting (NOLOCK)
	IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
	update billSetting set journal_voucher=cast(journal_voucher as float)+1 
	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
-- Start loop count
set @totalRows=1
while @Part_Id >=  @totalRows
begin
			-- row wise trn values
			select @ac_num = acctnum
				,@TotalAmt = tran_amt
				,@trntype = part_tran_type
			from #tempsumTrn where Part_Id = @totalRows
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,0
			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		-- UPDATE BILL BY BILLL	
		Exec procEntryBillByBill @sessionID,@date,@ac_num,@ref_num,@billref,@isnew,@trntype,'J',@TotalAmt

set @totalRows=@totalRows+1
end
	
	insert into tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date,
		tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
		,field2,fcy_Curr,usd_amt,usd_rate)

	SELECT 'system',t.acctnum,a.gl_code,t.part_tran_type,@ref_num,t.tran_amt,@date,'J',1
			,ROW_NUMBER() OVER(ORDER BY a.acct_num desc),GETDATE() 
			,dbo.[FNAGetRunningBalance](t.acctnum,t.tran_amt,t.part_tran_type)
			,'Remittance FX',ISNULL(ac_currency,'KRW')
			,CASE WHEN T.acctnum IN ('900141084569','900141055635','900141066363','900141047518','900141009020' ) THEN T.tran_amt ELSE NULL END
			,CASE WHEN T.acctnum IN ('900141084569','900141055635','900141066363','900141047518','900141009020' ) THEN 1 ELSE NULL END
	FROM #tempsumTrn t
	inner join ac_master a(nolock) on a.acct_num = t.acctnum
	
	IF (@@ERROR <> 0) GOTO QuitWithRollback

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
	select top 1 @ref_num,'FX - Gainloss voucher generated on :'+ @date,1,@date,'J'

	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
COMMIT TRANSACTION
 
select 0 as errocode,'Voucher generated successfully' as msg,null as id

drop table #tempsumTrn

GOTO  EndSave

QUITWITHROLLBACK:
ROLLBACK TRANSACTION 

ENDSAVE: 

end

GO
