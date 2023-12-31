USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_saveDealBookingVoucher]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec spa_saveDealBookingVoucher  @date ='10/17/2017',@BankId ='1',@UsdAmt ='1000',@Rate ='1212',@LCYAmt ='1212000',@Dealer =null,@MaturityDate ='10/20/2017',@ContractNo ='test',@User ='admin'

CREATE proc [dbo].[spa_saveDealBookingVoucher]
	@date			VARCHAR(20),
	@BankId			INT,
	@UsdAmt			MONEY,
	@Rate			MONEY,
	@LcyAmt			MONEY,
	@Dealer			VARCHAR(100),
	@user			VARCHAR(50),
	@MaturityDate	varchar(10) = null,
	@ContractNo		VARCHAR(50) = null
AS

	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	declare @v_type varchar(1) = 'J'


begin try

	IF ISNULL(@LcyAmt,0) <=0
	BEGIN	
		EXEC Proc_errorHandler 1,'Invalid Dealing amount',null
		RETURN
	END

	IF (ISDATE(@DATE))=0 or @DATE is null
	BEGIN
		EXEC proc_errorHandler 1,'Invalid Date',null
		RETURN
	END
	IF (ISNUMERIC(@UsdAmt))=0 or ISNULL(@UsdAmt,0)  = 0
	BEGIN
		EXEC proc_errorHandler 1,'Invalid USD Amount',null
		RETURN
	END
	IF (ISNUMERIC(@Rate))=0 or ISNULL(@Rate,0)  = 0
	BEGIN
		EXEC proc_errorHandler 1,'Invalid Rate',null
		RETURN
	END
	IF (ISNUMERIC(@LcyAmt))=0 or ISNULL(@LcyAmt,0)  = 0
	BEGIN
		EXEC proc_errorHandler 1,'Invalid Lcy Amount',null
		RETURN
	END
	
	DECLARE @CLR_BAL_AMT float
	DECLARE @SYSTEM_RESERVED_AMT float
	DECLARE @LIEN_AMT float
	DECLARE @UTILISED_AMT float
	DECLARE @AVAILABLE_AMT float
	DECLARE @DR_BAL_LIM float
	DECLARE @totalRows int
	DECLARE @Part_Id int
	DECLARE @ac_num  varchar(20)
	DECLARE @TotalAmt numeric(20,2)
	DECLARE @trntype varchar(2)
	DECLARE @totalDR numeric(20,2)
	DECLARE @totalCR numeric(20,2)
	DECLARE @ref_num varchar(20)
	DECLARE @acct_ownership varchar(2), @billref varchar(50),@isnew varchar(2)

	-- AC Masters values
	-- Temp Voucher values

	DECLARE @UsdRate money,@curr varchar(5),@OKRW MONEY,@OUSD MONEY

	CREATE TABLE #tempsumTrn (Part_Id INT IDENTITY,acct_num VARCHAR(20), 
	TotalAmt NUMERIC(20,2), part_tran_type VARCHAR(2), rate money, UsdAmt money,curr varchar(5))

	UPDATE AC_MASTER 
		SET CLR_BAL_AMT = AMT,available_amt = AMT
	FROM ac_master A,(
	SELECT ACC_NUM
		, SUM (CASE WHEN PART_TRAN_TYPE = 'Dr' THEN ISNULL(TRAN_AMT,0)*-1 ELSE ISNULL(TRAN_AMT,0) END) AMT 
	FROM TRAN_MASTER WITH (NOLOCK) GROUP BY ACC_NUM) X
	WHERE A.acct_num = X.acc_num
	AND isnull(A.clr_bal_amt,0) <> isnull(X.AMT,0)

	UPDATE AC_MASTER 
		SET usd_amt = X.USDAMT
	FROM ac_master A,(
	SELECT ACC_NUM
		, SUM (CASE WHEN PART_TRAN_TYPE = 'Dr' THEN ISNULL(usd_amt,0)*-1 ELSE ISNULL(usd_amt,0) END) USDAMT 
	FROM TRAN_MASTER WITH (NOLOCK) GROUP BY ACC_NUM) X
	WHERE A.acct_num = X.acc_num
	AND isnull(A.usd_amt,0) <> isnull(X.USDAMT,0)

	if exists(select 'a' from DealBankSetting(nolock) where RowId = @BankId and Settle_PayCurr = 1)
	begin
		--select top 1 @UsdRate = Rate from UsdStockSummary (nolock) where TxnDate = @date order by Id desc
		--IF @UsdRate IS NULL
		--	select top 1 @UsdRate = Rate from UsdStockSummary (nolock) order by Id desc

		SELECT @curr = a.ac_currency from DealBankSetting d(nolock) 
		INNER JOIN ac_master a(nolock) on a.acct_num = d.BuyAcNo
		WHERE D.RowId = @BankId

		SELECT @ac_num = SellAcNo from DealBankSetting(nolock) WHERE RowId = @BankId

		SELECT @OKRW = SUM(case when part_tran_type='DR' then tran_amt*-1 else tran_amt end)
			,@OUSD = ISNULL(SUM(case when part_tran_type='DR' then usd_amt*-1 else usd_amt end),0)
		FROM tran_master(NOLOCK) 
		WHERE tran_date < CAST(GETDATE() AS DATE) AND ACC_NUM = @ac_num

		SELECT @OKRW = ISNULL(@OKRW,0) - ISNULL(SUM(tran_amt),0),@OUSD = ISNULL(@OUSD,0) - ISNULL(SUM(ISNULL(usd_amt,0)),0)
		FROM tran_master(NOLOCK) 
		WHERE tran_date  BETWEEN CAST(GETDATE() AS DATE) AND GETDATE() AND ACC_NUM = @ac_num
		AND part_tran_type = 'DR'

		SELECT @UsdRate = @OKRW / @OUSD

		INSERT INTO #tempsumTrn(acct_num,TotalAmt,part_tran_type,rate,UsdAmt,curr)
		select SellAcNo,(@UsdAmt*@UsdRate),'CR',@UsdRate,@UsdAmt,CASE WHEN d.Settle_PayCurr = 1 then ISNULL(a.ac_currency,'KRW') else 'KRW' END
		from DealBankSetting d(nolock) 
		inner join ac_master a(nolock) on a.acct_num = d.SellAcNo
		where RowId = @BankId 
		union all
		select BuyAcNo,(@UsdAmt*@UsdRate),'DR',@Rate,@LcyAmt,CASE WHEN d.Settle_PayCurr = 1 then ISNULL(a.ac_currency,'USD') else 'USD' END
		from DealBankSetting D(nolock) 
		inner join ac_master a(nolock) on a.acct_num = d.BuyAcNo
		where RowId = @BankId
	end
	ELSE
	BEGIN
		INSERT INTO #tempsumTrn(acct_num,TotalAmt,part_tran_type,rate,UsdAmt,curr)
		select SellAcNo,@LcyAmt,'CR',1,@LcyAmt,'KRW' from DealBankSetting(nolock) where RowId = @BankId union all
		select BuyAcNo,@LcyAmt,'dr',@Rate,@UsdAmt,'USD' from DealBankSetting(nolock) where RowId = @BankId
	END
	SELECT @Part_Id = max(Part_Id) FROM #tempsumTrn

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
				
	SELECT @totalDR = SUM(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'dr' 
				
	SELECT @totalCR = SUM(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'cr'


	if ISNULL(@totalDR,0.001) <> @totalCR
	begin	
		exec proc_errorHandler 1,'DR and CR amount not Equal',null
		return
	end
BEGIN TRANSACTION
	
	select @ref_num = journal_voucher from billSetting(NOLOCK) 
	declare @dollar money
-- Start loop count
set @totalRows=1
while @Part_Id >=  @totalRows
begin
			-- row wise trn values
			select @ac_num = acct_num,@TotalAmt = TotalAmt,@trntype = part_tran_type,@dollar = UsdAmt
			from #tempsumTrn where Part_Id = @totalRows
			
			Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,@dollar
			
		-- UPDATE BILL BY BILLL	
		Exec procEntryBillByBill @ref_num,@date,@ac_num,@ref_num,'','',@trntype,@v_type,@TotalAmt
		

set @totalRows = @totalRows+1
end
	
	INSERT INTO tran_master (
		entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
		,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
		,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,fcy_Curr,field2)
	SELECT 
		@user,c.acct_num,a.gl_code,part_tran_type,@ref_num,c.TotalAmt,@date,'',@v_type,1,
		ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
		 , dbo.[FNAGetRunningBalance](c.acct_num,c.TotalAmt,part_tran_type)
		 ,C.UsdAmt,C.rate,'1',1,@user,@ContractNo,c.curr,'Deal Booking'
	FROM #tempsumTrn c(NOLOCK), ac_master a (NOLOCK)
	WHERE c.acct_num = a.acct_num 

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
	select top 1 @ref_num,'being Fund deal for the date '+@date,1,@date,@v_type

	update billSetting set journal_voucher=cast(journal_voucher as float)+1  

	INSERT INTO dbo.DealBookingHistory( DealDate ,BankId ,UsdAmt ,Rate ,LcyAmt ,Dealer ,ContractNo ,MaturityDate 
		,RemainingAmt,CreatedBy ,CreatedDate,refNum,LcyCurr)
	SELECT @date, @BankId, @UsdAmt, @Rate, @LcyAmt, @Dealer, @ContractNo, @MaturityDate
		,@UsdAmt, @user, GETDATE(),@ref_num,@curr
	
	--SET @Part_Id = SCOPE_IDENTITY()
	--if isnull(@curr,'USD')='USD'
	--BEGIN 
	--	declare @stockUsd money,@stockKrw money
	--	select top 1 @stockUsd = UsdAmt ,@stockKrw = KRWAmt  from UsdStockSummary(nolock) order by id desc

	--	select @stockUsd = isnull(@stockUsd,0) + @UsdAmt,@stockKrw = isnull(@stockKrw,0)+@LcyAmt

	--	insert into UsdStockSummary(UsdAmt,Rate,KRWAmt,TxnDate,tranId)
	--	select @stockUsd,@stockKrw/@stockUsd,@stockKrw,@date,@Part_Id
	--END
	--ELSE if isnull(@curr,'USD') <> 'USD'
	--BEGIN 
	--	SELECT @stockUsd =0,@stockKrw =0
	--	select top 1 @stockUsd = UsdAmt ,@stockKrw = KRWAmt  from UsdStockSummary_Other(nolock) WHERE Curr=@curr order by id desc

	--	select @stockUsd = isnull(@stockUsd,0) + @UsdAmt,@stockKrw = isnull(@stockKrw,0)+@LcyAmt

	--	insert into UsdStockSummary_Other(UsdAmt,Rate,KRWAmt,TxnDate,tranId,Curr)
	--	select @stockUsd,@stockKrw/@stockUsd,@stockKrw,@date,@Part_Id,@curr
	--END
COMMIT TRANSACTION
 
select 0 as errocode,'Save Success voucher No: 
<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+cast(@date as varchar(15)) 
+'&type=trannumber&tran_num='+ cast(@ref_num as varchar(50)) +'&vouchertype='+@v_type+''' > '
+ cast(@ref_num as varchar(50)) +' </a>' as   msg,null as id

DROP TABLE #tempsumTrn

end try
begin catch
if @@trancount <> 0
rollback transaction

select 1 as errocode,ERROR_MESSAGE() msg,null as id

end catch

GO
