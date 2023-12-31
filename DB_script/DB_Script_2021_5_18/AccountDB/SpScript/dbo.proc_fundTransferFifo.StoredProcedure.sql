USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_fundTransferFifo]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [proc_fundTransferFifo]  @ReceivingPartner=4,@DATE ='2018-07-24',@Ids='1,',@TxnAmt='2002060,',@User ='admin'

CREATE proc [dbo].[proc_fundTransferFifo]
	@ReceivingPartner	INT,
	@user				VARCHAR(50),
	@DATE				varchar(10),
	@TxnAmt				VARCHAR(MAX),
	@Ids				VARCHAR(MAX)
AS

	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	declare @v_type varchar(1) = 'J'
	declare @dealBank INT,@transferType  varchar(50)

begin try

	IF NOT EXISTS(SELECT 'A' FROM dbo.tblPayoutAgentAccount(nolock) where rowId = @ReceivingPartner)
	BEGIN	
		EXEC Proc_errorHandler 1,'Invalid Receiving partner ',null
		RETURN
	END

	IF (ISDATE(@DATE))=0 OR @DATE IS NULL
	BEGIN
		EXEC proc_errorHandler 1,'Invalid Date',null
		RETURN
	END
	IF @DATE <> CAST(GETDATE() AS DATE)
	BEGIN
		EXEC proc_errorHandler 1,'No back/future-date entries to be allowed',null
		RETURN
	END
	
	DECLARE @MSG VARCHAR(500)=''
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
	DECLARE @partnerNostroAcc varchar(20), @partnerCorrespondAcc varchar(20)

	select	@partnerNostroAcc		= receiveUSDNostro
			,@partnerCorrespondAcc  = receiveUSDCorrespondent 
			,@transferType			= transferType
	from tblPayoutAgentAccount (nolock)
	where rowId = @ReceivingPartner

	 select @dealBank = rowId from DealBankSetting(NOLOCK) where BuyAcNo = @partnerNostroAcc

	IF @dealBank IS NULL AND @transferType = 'Inter Bank Transfer'
	BEGIN	
		EXEC Proc_errorHandler 1,'Dealing Bank is missing,please goto Accounts>>bill & Voucher>>Treasury Deal Booking and Add Bank',null
		RETURN
	END

	--SELECT  
	--		BANKID = p.value('@BANKID', 'INT') ,
	--		Amount = p.value('@AMOUNT', 'MONEY') 
	--INTO #transferDetail
 --   FROM    @xml.nodes('/root/row') AS tmp ( p );

	create table #transferDetail(BANKID int,Amount money,Rate money,balAmt money,BuyAcNo VARCHAR(20))

	insert into #transferDetail(BANKID,Amount)
	SELECT i.value,a.value FROM DBO.Split(',',@TxnAmt) A
	INNER JOIN DBO.Split(',',@Ids) I ON I.id = A.id
	WHERE LEN(A.value) > 0

	DELETE FROM #transferDetail WHERE ISNULL(Amount,0) = 0

	update t set t.Rate = (a.clr_bal_amt/a.usd_amt),t.balAmt = a.usd_amt*-1,BuyAcNo = D.BuyAcNo FROM DealBankSetting D(NOLOCK)
	INNER JOIN #transferDetail T ON T.BANKID = D.RowId
	INNER JOIN ac_master a(nolock) on a.acct_num = d.BuyAcNo

	IF EXISTS( select 'a' from #transferDetail where isnull(balAmt,0) < Amount)
	BEGIN
		select @MSG = @MSG+','+cast(BANKID as varchar)  from #transferDetail where isnull(Rate,0) = 0
		set @MSG = 'Remaining balance is not found for Bank '+@MSG

		exec proc_errorHandler 1,@MSG,null
		RETURN
	END
	IF EXISTS( select 'a' from #transferDetail where isnull(Rate,0) = 0)
	BEGIN
		select @MSG = @MSG+','+cast(BANKID as varchar)  from #transferDetail where isnull(Rate,0) = 0
		set @MSG = 'Invalid Bank Rate found for operation '+@MSG

		exec proc_errorHandler 1,@MSG,null
		RETURN
	END
	
	CREATE TABLE #tempsumTrn(Part_Id Int identity(1,1),acct_num VARCHAR(20),TotalAmt NUMERIC(20,2),part_tran_type VARCHAR(2),rate money
		,UsdAmt money,curr varchar(5),DealBookingId int,contractNo varchar(50),BankId int)
	
	DECLARE @bankId int,@RemainAmt MONEY

	DECLARE @UsdAmt MONEY
	

	INSERT INTO #tempsumTrn(acct_num,part_tran_type,rate,curr,DealBookingId,UsdAmt,contractNo,TotalAmt,BankId)
	select BuyAcNo,'CR',Rate,'USD',NULL,Amount,dbo.FunGetACName(BuyAcNo),Amount*Rate,BANKID
	FROM #transferDetail(nolock)

	select @RemainAmt=sum(TotalAmt), @UsdAmt= SUM(UsdAmt) FROM #tempsumTrn

	INSERT INTO #tempsumTrn(acct_num,part_tran_type,rate,curr,DealBookingId,UsdAmt,contractNo,TotalAmt,BankId)
	select @partnerNostroAcc,'DR',round(@RemainAmt/@UsdAmt,4),'USD',NULL,@UsdAmt,acct_name,@RemainAmt,@ReceivingPartner
	FROM ac_master(nolock) where acct_num = @partnerNostroAcc

	--SELECT * FROM #tempsumTrn
	--RETURN

	----## FOR Transfer To PARTNER Nostro USD To Correspondents Account
	--IF EXISTS (SELECT 1 FROM ac_master (NOLOCK) WHERE acct_num = @partnerCorrespondAcc)
	--BEGIN
	--	INSERT INTO #tempsumTrn(acct_num,part_tran_type,rate,curr,DealBookingId,UsdAmt,contractNo,TotalAmt)
	--	select @partnerNostroAcc,'CR',@RemainAmt/@UsdAmt,'USD',NULL,@UsdAmt,acct_name,@RemainAmt
	--	FROM ac_master(nolock) where acct_num = @partnerNostroAcc					
	--	UNION ALL
	--	select @partnerCorrespondAcc,'DR',@RemainAmt/@UsdAmt,'USD',NULL,@UsdAmt,acct_name,@RemainAmt
	--	FROM ac_master(nolock) where acct_num = @partnerNostroAcc
	--END

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
	
-- Start loop count
set @totalRows=1
while @Part_Id >=  @totalRows
begin
			-- row wise trn values
			select @ac_num = acct_num,@TotalAmt = TotalAmt,@trntype = part_tran_type,@UsdAmt = UsdAmt
			from #tempsumTrn where Part_Id = @totalRows
			
			Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,@UsdAmt
			
		-- UPDATE BILL BY BILLL	
		Exec procEntryBillByBill @ref_num,@date,@ac_num,@ref_num,'','',@trntype,@v_type,@TotalAmt
		

set @totalRows=@totalRows+1
end
	
	UPDATE d set d.RemainingAmt = d.RemainingAmt - isnull(t.UsdAmt,0) FROM #tempsumTrn T
	INNER JOIN DealBookingHistory D ON T.DealBookingId = D.RowId

	INSERT INTO tran_master (
		entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
		,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
		,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,fcy_Curr,field2)
	SELECT 
		@user,c.acct_num,a.gl_code,part_tran_type,@ref_num,c.TotalAmt,@date,BankId,@v_type,1,
		ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
		 , dbo.[FNAGetRunningBalance](c.acct_num,c.TotalAmt,part_tran_type)
		 ,C.UsdAmt,C.rate,'1',1,@user,c.contractNo,c.curr,'Fund Transfer'
	FROM #tempsumTrn c(NOLOCK), ac_master a (NOLOCK)
	WHERE c.acct_num = a.acct_num 

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
	select top 1 @ref_num,'Being Fund transfered to '+nameOfPartner+' on '+@date,1,@date,@v_type
	FROM dbo.tblPayoutAgentAccount(nolock) where rowId = @ReceivingPartner

	update billSetting set journal_voucher = cast(journal_voucher as float)+1  

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
