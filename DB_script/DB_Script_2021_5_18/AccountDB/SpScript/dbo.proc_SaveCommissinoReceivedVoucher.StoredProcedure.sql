USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_SaveCommissinoReceivedVoucher]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_SaveCommissinoReceivedVoucher]
	@User		VARCHAR(50),
	@sAgentId	INT,
	@BankAcNum varchar(20),
	@UsdAmt		MONEY,
	@exRate		MONEY,
	@date		varchar(20),
	@strCheckNo varchar(20),
	@srtNarration varchar(300)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @company_id VARCHAR(10) = '1'

BEGIN TRY
begin

	IF @USDAmt = 0 OR @exRate = 0
	BEGIN	
		EXEC proc_errorHandler 1 ,'Invalid amount entered',null
		RETURN
	END

	IF (ISDATE(@date)) = 0 OR CAST(@date AS DATE) > CAST(GETDATE() AS DATE)
	BEGIN
		EXEC Proc_errorHandler 1 ,'Invalid Date',null
		RETURN
	END

	DECLARE @totalRows int
	DECLARE @Part_Id int
	DECLARE @ac_num  varchar(20)
	DECLARE @TotalAmt numeric(20,2)
	DECLARE @trntype varchar(2)
	DECLARE @totalDR numeric(20,2)
	DECLARE @totalCR numeric(20,2)
	DECLARE @ref_num varchar(20)
	DECLARE @USD_AMT numeric(20,2)
	DECLARE @strSAgent as varchar(20) 

	-- AC Masters values
	-- Temp Voucher values

	create table #tempsumTrn (Part_Id int identity(1,1),acct_num varchar(20), 
	TotalAmt numeric(20,2), part_tran_type varchar(2), USD_AMT numeric(20,2),exRate MONEY )

-- ## GET Sending agent Id
DECLARE @Commissino_AC varchar(30) = '731022985',@WeightedRate MONEY

	INSERT INTO #tempsumTrn(acct_num,part_tran_type,USD_AMT,exRate,TotalAmt)
	SELECT A.acct_num,'DR',@usdAmt,@EXRATE,ROUND(@usdAmt*@EXRATE,0)
	FROM ac_master A(NOLOCK)
	INNER JOIN agenttable T (NOLOCK) ON A.agent_id = T.agent_id
	WHERE T.map_code = @sAgentId AND A.acct_rpt_code = '4'
	UNION ALL
	SELECT @Commissino_AC,'CR',@usdAmt,@EXRATE,ROUND(@usdAmt*@EXRATE,0)

	----## FOR BANK ENTRY
	INSERT INTO #tempsumTrn(acct_num,part_tran_type,USD_AMT,exRate,TotalAmt)
	SELECT @BankAcNum,'DR',@usdAmt,@EXRATE,ROUND(@usdAmt*@EXRATE,0)
	UNION ALL
	SELECT A.acct_num,'CR',@usdAmt,@EXRATE,ROUND(@usdAmt*@EXRATE,0)
	FROM ac_master A(NOLOCK)
	INNER JOIN agenttable T (NOLOCK) ON A.agent_id = T.agent_id
	WHERE T.map_code = @sAgentId AND A.acct_rpt_code = '4'


	SELECT @ref_num = receipt_voucher from billSetting(NOLOCK) where company_id = @company_id
	SELECT @Part_Id = max(Part_Id) from #tempsumTrn

	SELECT @totalDR = sum(TotalAmt) from #tempsumTrn where part_tran_type = 'dr' 
	SELECT @totalCR = sum(TotalAmt) from #tempsumTrn where part_tran_type = 'cr'

--SELECT * FROM #tempsumTrn 
--RETURN

	-- conditions 1 for Total DR CR equal 
IF ISNULL(@totalDR,0) <> ISNULL(@totalCR,1)
BEGIN	
	EXEC Proc_errorHandler 1 ,'DR and CR amount not Equal',null
	RETURN
END

SET @strSAgent = NULL
BEGIN TRANSACTION		

--Start loop count
set @totalRows = 1
while @Part_Id >=  @totalRows
begin
			-- row wise trn values
		select @ac_num = acct_num,@TotalAmt = round(TotalAmt,0),@trntype = part_tran_type,@USD_AMT = USD_AMT
		from #tempsumTrn where Part_Id = @totalRows
			
		Exec ProcDrCrUpdateFinal @trntype ,@ac_num,@USD_AMT,@TotalAmt

set @totalRows = @totalRows+1
end

	-- ######### Insert into Transaction Table
		INSERT INTO tran_master (
			entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,rpt_code,tran_amt,tran_date,
			tran_type,company_id,CHEQUE_NO,part_tran_srl_num,
			created_date, usd_amt,usd_rate,RunningBalance)
		SELECT @User,c.acct_num,a.gl_code,lower(part_tran_type),@ref_num,A.acct_rpt_code,c.TotalAmt,@date
			,'r',@company_id,@strCheckNo,ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo
			,GETDATE(),c.USD_AMT,c.exRate, dbo.[FNAGetRunningBalance](c.acct_num,c.TotalAmt,part_tran_type)
		FROM #tempsumTrn c
		INNER JOIN ac_master a (NOLOCK) ON c.acct_num = a.acct_num 


		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
		SELECT TOP 1 @ref_num,@srtNarration,@company_id,@date,'r'
		
	DECLARE @remainAmt MONEY,@CUMM_NPR DECIMAL(10,2)
	SET @WeightedRate = NULL

	SELECT @remainAmt = ISNULL(REMAIN_AMT,0) + @USD_AMT
			,@CUMM_NPR = (ISNULL(CUMM_NPR,0) + ROUND(@USD_AMT * @exRate,0))
	FROM FundTransactionSummary (NOLOCK) 
	WHERE R_BANK = @BankAcNum ORDER BY TRAN_ID DESC 

	SELECT @WeightedRate = @CUMM_NPR/@remainAmt

	IF @WeightedRate IS NULL
		SELECT @WeightedRate = @exRate , @remainAmt = @USD_AMT

	INSERT INTO FundTransactionSummary 
		(S_AGENT,USD_AMT,NPR_AMT,USD_RATE,TRAN_DATE,REMAIN_AMT,R_BANK,REMAIN_AMT_EXCHANGE
		,ref_num,vtype,FUND_ID,WeightedRate,CUMM_NPR)
	SELECT @sAgentId,@USD_AMT,round(@USD_AMT*@exRate,0),@exRate,@date,@USD_AMT,@BankAcNum,@remainAmt,
		@ref_num,'R',NULL,@WeightedRate,@CUMM_NPR
	
-- ######### update voucher number
	UPDATE billSetting set receipt_voucher = cast(receipt_voucher as float)+1 

COMMIT TRANSACTION

-- ######### Delete temp TRansaction
	DROP TABLE #tempsumTrn

--####### Final message select 'Saved, Process Complete: '+ @ref_num as Success
	
	SELECT @srtNarration = 'Save Success voucher No: 
		<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+ cast(@date as varchar) +'&type=trannumber&tran_num='+ cast(@ref_num as varchar) +'&vouchertype=r'' > '+ cast(@ref_num as varchar) +' </a>' 
	
	EXEC proc_errorHandler 0 ,@srtNarration,@ref_num

END

END TRY

BEGIN CATCH

IF @@TRANCOUNT <> 0 
ROLLBACK TRANSACTION

SET @srtNarration = ERROR_MESSAGE()
EXEC proc_errorHandler 1 ,@srtNarration,NULL

END CATCH
GO
