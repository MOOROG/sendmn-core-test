USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_saveFCYTempTrn]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_saveFCYTempTrn]
	@flag			CHAR(1),
	@sessionID		VARCHAR(50),
	@date			VARCHAR(20),
	@narration		VARCHAR(500),
	@company_id		VARCHAR(20),
	@v_type			VARCHAR(20),
	@tran_ref_code	VARCHAR(50)=NULL,
	@user			VARCHAR(50)
AS

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	if @company_id='' or @company_id is null
		set @company_id = '1'
		
	if @v_type is null 
		set @v_type = 'j'

BEGIN TRY
IF @FLAG='I'
BEGIN

	IF NOT EXISTS(SELECT TRAN_ID FROM temp_transaction WHERE SESSIONID = @SESSIONID )
	BEGIN	
		EXEC proc_errorHandler 1,'No Transaction to save!',null
		RETURN
	END

	IF (ISDATE(@DATE)) = 0 OR @DATE > GETDATE()
	BEGIN
		EXEC proc_errorHandler 1,'Invalid Date',null
		RETURN
	END
	
	----if exists(select 'n' from dbo.VOUCHER_SETTING where V_CODE = @v_type and approval_mode = 'y')
	----BEGIN
	----Exec spa_tempTrnToApprove @flag='i', @sessionid=@sessionid,@narration=@narration,@tran_ref_code=@tran_ref_code,@user=@user,@date=@date,@v_type=@v_type
	----	return 
	----END
	
	
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

	CREATE TABLE #tempsumTrn (Part_Id int identity,acct_num varchar(20), 
	TotalAmt numeric(20,2), part_tran_type varchar(2),fcyAmt MONEY,rate FLOAT,currency VARCHAR(5))

	insert into #tempsumTrn(acct_num,TotalAmt,part_tran_type, fcyAmt, rate,currency)
	SELECT acct_num,lcyamt TotalAmt,tran_type,fcyAmt, apprate,currency
	FROM temp_transaction (NOLOCK )	where  sessionID = @sessionID 
	AND lcyamt <> 0

	select @Part_Id = max(Part_Id) from #tempsumTrn


	IF NOT EXISTS(SELECT * FROM #TEMPSUMTRN WHERE PART_TRAN_TYPE = 'CR')
	BEGIN
		exec proc_errorHandler 1,'CR Transaction is missing',null
		RETURN;	
	END

	IF NOT EXISTS(SELECT * FROM #TEMPSUMTRN WHERE PART_TRAN_TYPE = 'DR')
	BEGIN
		exec proc_errorHandler 1,'DR Transaction is missing',null
		RETURN;	
	END
		
	SELECT @totalDR = sum(TotalAmt) from #tempsumTrn where part_tran_type = 'dr'
				
	select @totalCR = sum(TotalAmt) from #tempsumTrn where part_tran_type = 'cr'


	IF ISNULL(@TOTALDR,0) <> ISNULL(@TOTALCR,0)
	BEGIN	
		EXEC proc_errorHandler 1,'DR and CR amount not Equal',null
		RETURN
	END


BEGIN TRANSACTION
	
	IF @v_type = 'j'
	BEGIN

		SELECT @ref_num = journal_voucher from billSetting where company_id = @company_id
		
		update billSetting set journal_voucher = cast(journal_voucher as float)+1 where company_id = @company_id
	END
	IF @V_TYPE='Y'
	BEGIN

		select @ref_num = payment_voucher from billSetting where company_id = @company_id
		
		update billSetting set payment_voucher=cast(payment_voucher as float)+1 where company_id=@company_id
	END
	
	IF @V_TYPE='C'
	BEGIN

		select @ref_num = contra_voucher from billSetting where company_id = @company_id
		
		update billSetting set contra_voucher=cast(contra_voucher as float)+1 where company_id=@company_id
	END
	
	IF @V_TYPE='R'
	BEGIN

		select @ref_num = receipt_voucher from billSetting where company_id = @company_id
		
		update billSetting set receipt_voucher=cast(receipt_voucher as float)+1 where company_id=@company_id
	END

-- Start loop count
SET @TOTALROWS = 1
WHILE @PART_ID >=  @TOTALROWS
BEGIN
			-- row wise trn values
			select @ac_num = acct_num,@TotalAmt = TotalAmt,	@trntype = part_tran_type
				
			from #tempsumTrn where Part_Id = @totalRows
			
			Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,0
			
		-- UPDATE BILL BY BILLL	
		Exec procEntryBillByBill @sessionID,@date,@ac_num,@ref_num,@billref,@isnew,@trntype,@v_type,@TotalAmt
		

set @totalRows = @totalRows+1
END
	
	INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code
		,part_tran_type,ref_num,rpt_code,tran_amt,fcy_currency,fcy_amt,sys_rate,app_rate,tran_date,
		tran_type,company_id,part_tran_srl_num,created_date,RunningBalance)
	select C.createdby,c.acct_num,a.gl_code,
		C.tran_type,@ref_num,@tran_ref_code,C.lcyamt,C.currency,c.fcyamt,c.apprate,c.apprate,@date,
		@v_type,@company_id,ROW_NUMBER() OVER(ORDER BY tran_type desc) AS SrNo,GETDATE()
	 , dbo.[FNAGetRunningBalance](c.acct_num,c.lcyamt,c.tran_type)
	from temp_transaction c, ac_master a 
	where c.acct_num = a.acct_num and sessionID = @sessionID

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],
		[otherinfo],company_id,tranDate,tran_type )
	select @ref_num,@narration,@tran_ref_code,@company_id,@date,@v_type
	
	
delete from temp_transaction where sessionID = @sessionID

COMMIT TRANSACTION
 
SELECT 0 AS errocode,'Save Success voucher No: 
<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+cast(@date as varchar(15)) 
+'&type=trannumber&tran_num='+ CAST(@ref_num AS VARCHAR(5)) +'&vouchertype='+@v_type+''' > '+ CAST(@REF_NUM AS VARCHAR(5)) +' </a>' AS   msg,null AS id

DROP TABLE #tempsumTrn

END

END TRY
BEGIN CATCH

IF @@ERROR <> 0
ROLLBACK TRANSACTION 

END CATCH
GO
