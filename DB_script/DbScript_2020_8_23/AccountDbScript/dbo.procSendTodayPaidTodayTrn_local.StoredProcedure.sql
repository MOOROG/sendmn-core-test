ALTER  proc [dbo].[procSendTodayPaidTodayTrn_local]
	@flag		char(1),
	@date		varchar(20),
	@time		varchar(20),
	@company_id varchar(20),
	@user		varchar(50)=null
AS

IF @time NOT IN ('14','17','24')
BEGIN
	EXEC proc_errorHandler 1,'Wrong time is selected for voucher generation!',null
	RETURN;
END
ELSE IF @time ='24'
	SET @time = ' '+ '23:59:59'
ELSE
	SET @time = ' '+ @time+':00:00'

if @flag = 'a'
BEGIN

		SET NOCOUNT ON;
		SET XACT_ABORT ON;

		DECLARE @error_msg VARCHAR(250)
		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20), @dblTotalAmtNPR as float
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @SUB_AGN_PAY as VARCHAR(20),@SUB_AGN_DCOM as VARCHAR(20),
				@GLB_REM_DOM as VARCHAR(20),@AGN_COMM_RC as VARCHAR(20),
				@REM_PAY_DOM as VARCHAR(20),@REM_PAY_UNPAY as VARCHAR(20)
				
		-----------------------------
		--'20'
		--select @SUB_AGN_PAY = value from configTable WHERE cat='Payable to Sub Agent - Principle'	
		set @SUB_AGN_PAY='20'
		
		--'22'
		--select @SUB_AGN_DCOM = value from configTable WHERE cat='Sub Agent (D. Comm.) R C LOCAL'
		set @SUB_AGN_DCOM='22'
		
		select @GLB_REM_DOM = acct_num from ac_master WHERE acct_name='Remitance Account - Domestic Transactions'
		
		select @AGN_COMM_RC = acct_num from ac_master WHERE acct_name='Commission Expenses - Domestic Paid'
		
		select @REM_PAY_DOM = acct_num from ac_master with (nolock) WHERE acct_name = 'Settlement Bank Domestic - Machhapuchre Bank'
		select @REM_PAY_UNPAY = acct_num from ac_master with (nolock) WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank (UNPAID)'
		
		
		-----------------------------
		IF OBJECT_ID(N'TEMPDB..#REMIT_TRN_LOCAL') IS NOT NULL
			DROP TABLE #REMIT_TRN_LOCAL
		
		--IF EXISTS(
		--SELECT * 
		--	FROM REMIT_TRN_LOCAL C with (nolock)
		--	WHERE CONFIRM_DATE < @date
		--	AND P_DATE < @date
		--	AND F_STODAY_PTODAY is null
		--	AND PAY_STATUS = 'Paid' and CAST(CONFIRM_DATE AS DATE) = CAST(P_DATE AS DATE)
		--)
		--BEGIN
		--	EXEC proc_errorHandler 1,'Back Date Voucher Generation pending.',null
		--	RETURN;
		--END

		SELECT * 
		  INTO  #REMIT_TRN_LOCAL
		FROM REMIT_TRN_LOCAL C with (nolock)
			WHERE CONFIRM_DATE between @date and @date + @time
			AND P_DATE between @date and @date + @time
			AND F_STODAY_PTODAY is null
			AND PAY_STATUS='Paid'

        IF not exists(SELECT TOP 1 TRAN_ID FROM #REMIT_TRN_LOCAL with (nolock))
		begin
			exec proc_errorHandler 1,'NO RECORDS',null
			return;
		end

		if exists(Select top 1 R_AGENT from #REMIT_TRN_LOCAL r with (nolock)
		where R_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable with (nolock)) )
		BEGIN
				DECLARE @strMissingList varchar(300)

				SELECT top 1 @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(R_AGENT AS varchar(100))+'-'+ dbo.decryptDbLocal(TRN_REF_NO)
				FROM #REMIT_TRN_LOCAL
				WHERE R_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable with (nolock))
				GROUP BY R_AGENT,TRN_REF_NO

				SET @error_msg = 'AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList
				exec proc_errorHandler 1, @error_msg,null
				RETURN;
	    END


	   UPDATE #REMIT_TRN_LOCAL set  R_AGENT = ISNULL(a.central_sett_code,t.R_AGENT)
		FROM #REMIT_TRN_LOCAL as t
	     join agentTable as a WITH(NOLOCK) on a.AGENT_IME_CODE= t.R_AGENT
		
		
	   UPDATE #REMIT_TRN_LOCAL set  R_AGENT = a.AGENT_IME_CODE
		FROM #REMIT_TRN_LOCAL as t
	     join agentTable as a WITH(NOLOCK) on a.map_code= t.R_AGENT


	   IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit

		
	   --##### Send Today &  Paid Today
	   SELECT ACCT_NUM,AMT,TRN_TYPE, gl_code
			into #_tzRemittanceTranHit
			FROM (
				
			-- Remittance Payable Global Remit  domestic (payout)
			SELECT @GLB_REM_DOM AS 'ACCT_NUM',
				SUM(ROUND_AMT)AS AMT , 'DR' AS 'TRN_TYPE', '12' as gl_code
			FROM #REMIT_TRN_LOCAL with (nolock)
			
				
			UNION ALL
			
			-- Sub Agent (payout)
			SELECT M.acct_num as ACCT_NUM ,SUM(ROUND_AMT)AS AMT 
				,'CR' AS TRN_TYPE, @SUB_AGN_PAY
			FROM #REMIT_TRN_LOCAL C  with (nolock)
				JOIN agentTable A with (nolock) ON C.R_AGENT=A.AGENT_IME_CODE
				JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
			WHERE acct_rpt_code=@SUB_AGN_PAY 
				and isnull(A.AGENT_IME_CODE,'0')<>'0'
			GROUP BY acct_num
			
		)AL
		
		
	    IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_2') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_2

		--##### Send Today &  Paid Today drop table #_tzRemittanceTranHit_2
		SELECT ACCT_NUM,AMT,TRN_TYPE,gl_code
			into #_tzRemittanceTranHit_2
			FROM (
				
			-- Agent Commission (D. Remitt. R C)
			SELECT @AGN_COMM_RC AS 'ACCT_NUM',
				SUM(R_SC)AS AMT , 'DR' AS 'TRN_TYPE','18' as gl_code
			FROM #REMIT_TRN_LOCAL with (nolock)
			  
				
			UNION ALL
				
			-- Sub Agent (D. Comm.) R C
			
			SELECT ACCT_NUM,
				SUM(R_SC)AS AMT , 'CR' AS 'TRN_TYPE' , @SUB_AGN_DCOM
			FROM #REMIT_TRN_LOCAL C with (nolock)
				JOIN agentTable A with (nolock) ON C.R_AGENT=A.AGENT_IME_CODE
				JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
			WHERE ACCT_RPT_CODE=@SUB_AGN_DCOM and isnull(A.AGENT_IME_CODE,'0')<>'0'
			GROUP BY acct_num
			
		)AL2
	
	
	--ADDED  FOR TRANSACTION PAID AFTER FINAL SETTLEMENT i.e. AFTER FIRST VOUCHER GENERATION
	DECLARE @NEWAMT MONEY 
	SELECT @NEWAMT=SUM(P_AMT) FROM #REMIT_TRN_LOCAL
	WHERE ISNULL(F_STODAY_NOTPTODAY,'N') ='Y'
	AND F_STODAY_PTODAY IS NULL 
	AND F_PTODAY_SYESTERDAY IS NULL 
	AND P_DATE IS NOT NULL


	    IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_3') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_3

	
		SELECT ACCT_NUM,AMT,TRN_TYPE,gl_code
			into #_tzRemittanceTranHit_3
			FROM (
			SELECT @REM_PAY_DOM ACCT_NUM ,@NEWAMT AMT ,'Dr' TRN_TYPE, '4' gl_code
			UNION ALL
			SELECT @REM_PAY_UNPAY,@NEWAMT,'Cr', '4') X
				

	--select trn_type, SUM(AMT)  from #_tzRemittanceTranHit
	--group by trn_type

	-- return;


	IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_all') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_all

	select acct_num,sum(amt)AMT,trn_type
		into #_tzRemittanceTranHit_all
		 from(
			select * from #_tzRemittanceTranHit
			union all
			select * from #_tzRemittanceTranHit_2
		)x
	group by acct_num,trn_type
		
		
	-- ########## CR and DR Balance
	if ( Select  cast(isnull(sum(AMT),0)as float) from #_tzRemittanceTranHit_all where trn_type='DR' and ISNULL(AMT,0) >0 group by trn_type )
		<> ( select  cast(isnull(sum(AMT),0)as float) from #_tzRemittanceTranHit_all  where trn_type='CR' and ISNULL(AMT,0) >0 group by trn_type )
	begin
	
			declare @ControlNo varchar(50)
			
			SELECT top 1 @ControlNo = dbo.decryptDbLocal(T1.TRN_REF_NO)
				FROM #REMIT_TRN_LOCAL T1 with (nolock)
				LEFT JOIN (
				SELECT TRN_REF_NO, (ROUND_AMT)AS AMT 
				FROM #REMIT_TRN_LOCAL C  with (nolock)
					JOIN agentTable A with (nolock) ON C.R_AGENT=A.AGENT_IME_CODE
					JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
				WHERE acct_rpt_code='20' 
					and isnull(A.AGENT_IME_CODE,'0')<>'0'
			)A ON T1.TRN_REF_NO = A.TRN_REF_NO 
			WHERE A.TRN_REF_NO is null
			
			SET @error_msg = 'DR and CR Balance is not Equal, check this ICN:'+ @ControlNo
				exec proc_errorHandler 1, @error_msg,null
				RETURN;
					
	end
		
	--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit_all add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit_all

	
	--############ Voucher no Generation logic 
	select @strRefNum=isnull( TRANSACTION_VOUCHER ,1) from BillSetting 
	   where company_id=@company_id

BEGIN TRANSACTION
		
	--########### Start loop count
	set @intTotalRows=1
	while @intPartId >=  @intTotalRows
	begin
				-- row wise trn values
				SELECT @strAccountNum=ACCT_NUM,@dblTotalAmtNPR=AMT,@strTranType=TRN_TYPE 
				FROM #_tzRemittanceTranHit_all
				where RowID=@intTotalRows
				
					IF (@@ERROR <> 0) GOTO QuitWithRollback 
					
				Exec ProcDrCrUpdateFinal @strTranType ,@strAccountNum, @dblTotalAmtNPR,0
					IF (@@ERROR <> 0) GOTO QuitWithRollback 
					
	set @intTotalRows=@intTotalRows+1
	end
	
		
		if exists( select * from #_tzRemittanceTranHit t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0 )
		begin
				
			    -- ######### Insert first set into tran master table
				insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
					,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
					tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
				Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM),
					TRN_TYPE,@strRefNum ,isnull(AMT,0),0,0,@date,'s','1',
					ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
				from #_tzRemittanceTranHit t, ac_master a 
				where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
				
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
				Select @strRefNum,'Local Remittance Send Today Paid Today','s','1',@date
					
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
			
		end
		
		
		if exists( select top 1 * from #_tzRemittanceTranHit_2 t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0 )
		begin
			set @strRefNum=@strRefNum+1 
				-- ######### Insert second set into tran master table
				insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
					,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
					tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
				Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM),
					TRN_TYPE,@strRefNum ,isnull(AMT,0),0,0,@date,'s','1',
					ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
				from #_tzRemittanceTranHit_2  t, ac_master a 
				where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
				Select @strRefNum,'Local Remittance Send Today Paid Today','s','1',@date
					
				IF (@@ERROR <> 0) GOTO QuitWithRollback
				
		end
		
		
		
			if exists( select top 1 * from #_tzRemittanceTranHit_3 t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0 )
		    begin
				set @strRefNum=@strRefNum+1 
				-- ######### Insert second set into tran master table
				insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
					,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
					tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
				Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM),
					TRN_TYPE,@strRefNum ,isnull(AMT,0),0,0,@date,'s','1',
					ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
				from #_tzRemittanceTranHit_3  t, ac_master a 
				where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
				Select @strRefNum,'Send Today Paid Today After final settlement','s','1',@date
					
				IF (@@ERROR <> 0) GOTO QuitWithRollback
		end
		
	-- ########## UPDATE BILLSETTING
	update BillSetting set TRANSACTION_VOUCHER=@strRefNum+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		
	-- ########## Update flag
	update REMIT_TRN_LOCAL set F_STODAY_PTODAY='y'
	FROM REMIT_TRN_LOCAL R,#REMIT_TRN_LOCAL T
	WHERE R.TRAN_ID = t.TRAN_ID
	AND R.F_STODAY_PTODAY is null
	AND R.PAY_STATUS='Paid'

	
	UPDATE C SET C.todaysPaid = todaysPaid - SAMT FROM SendMnPro_Remit.dbo.creditlimit c
	INNER JOIN (
		SELECT R_AGENT,SUM(ROUND_AMT) SAMT FROM #REMIT_TRN_LOCAL GROUP BY R_AGENT
	) L ON C.agentId = l.R_AGENT
		
	IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
	COMMIT TRANSACTION
	exec proc_errorHandler 0,'PROCESS COMPLETED',null

	SELECT @strMissingList = 'Local Remittance Send Today Paid Today : '+@date+@time

	Exec JobHistoryRecord 'i','Remittance Voucher','',@strRefNum,@strMissingList,'',@user

GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 


EndSave: 

END

GO
