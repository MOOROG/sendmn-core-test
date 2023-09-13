ALTER  proc [dbo].[procSendTodayCancelTodayTrn_local]
@flag char(1),
@date varchar(20),
@time		varchar(20),
@company_id varchar(20),
@user varchar(50)=null

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

if @flag='a'
begin
		-- ## FOR STATUS SYNC
		EXEC PROC_SyncDomTxnStatus @FLAG = 'C'

		set nocount on;
		set xact_abort on;

		DECLARE @error_msg VARCHAR(250)
		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20), @dblTotalAmtNPR as float
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @PAY_SUB_AGN as VARCHAR(20),@GLB_REM_PAY as VARCHAR(20),
				@GLB_REM_DOM as VARCHAR(20),@REM_COMM_SC as VARCHAR(20),
				@REM_COMM_RC as VARCHAR(20),@REM_COMM_HO as VARCHAR(20),@REM_PAY_DOM AS VARCHAR(20), @REM_PAY_UNPAY AS VARCHAR(20),@REM_DCOM_SC AS VARCHAR(20)
		-------------------------
		--'20'
		-- select @PAY_SUB_AGN=value from configTable WHERE cat='Payable to Sub Agent - Principle'	
		set @PAY_SUB_AGN='20'
		
		select @GLB_REM_PAY = acct_num from ac_master WHERE acct_name='Remitance Account - Domestic Transactions'
		
		select @GLB_REM_DOM = acct_num from ac_master WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank'
		
		select @REM_COMM_SC = acct_num from ac_master WHERE acct_name='Commission Income - Sending Agent'
		
		select @REM_COMM_RC = acct_num from ac_master WHERE acct_name='Commission Income - Paying Agent'
		
		select @REM_COMM_HO = acct_num from ac_master WHERE acct_name='Commission Income - Head Office'
		
		select @REM_PAY_DOM = acct_num from ac_master WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank'
		
		select @REM_PAY_UNPAY = acct_num from ac_master with (nolock) WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank (UNPAID)'

		select @REM_DCOM_SC = acct_num from ac_master WHERE acct_name='Commission Expenses - Domestic Send'
		-------------------------
	
	   IF OBJECT_ID(N'TEMPDB..#REMIT_TRN_LOCAL') IS NOT NULL
			DROP TABLE #REMIT_TRN_LOCAL


	   UPDATE REMIT_TRN_LOCAL set R_SC =0 
	   where R_SC  is null 
	   AND CANCEL_DATE between @date and @date + @time
		
		
		----IF EXISTS(
		----		 SELECT 'A' 
		----		FROM REMIT_TRN_LOCAL C with (nolock)
		----		WHERE CONFIRM_DATE < @date
		----		AND CANCEL_DATE < @date
		----		AND F_STODAY_CTODAY is null
		----		AND TRN_STATUS = 'Cancel'
		----)
		----BEGIN
		----	EXEC proc_errorHandler 1,'Back Date Voucher Generation pending.',null
		----	RETURN;
		----END

	   SELECT * 
		  INTO #REMIT_TRN_LOCAL
		FROM REMIT_TRN_LOCAL C with (nolock)
			WHERE CONFIRM_DATE between @date and @date + @time
			AND CANCEL_DATE between @date and @date + @time
			AND F_STODAY_CTODAY is null
			AND TRN_STATUS = 'Cancel'
		
		IF not exists(SELECT top 1 TRAN_ID FROM #REMIT_TRN_LOCAL with (nolock)) 
		BEGIN
			exec proc_errorHandler 1,'NO RECORDS',null
			return;
		end

		if exists(Select S_AGENT from #REMIT_TRN_LOCAL r with (nolock)
		where S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable)
		)
		begin
				DECLARE @strMissingList varchar(100)

				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(S_AGENT AS varchar(20))
				FROM #REMIT_TRN_LOCAL
				where S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable)	
				group by S_AGENT

				SET @error_msg = 'AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList
				EXEC proc_errorHandler 1, @error_msg,null
				RETURN;
				
	  end


	   UPDATE #REMIT_TRN_LOCAL set  S_AGENT = ISNULL(a.central_sett_code,t.S_AGENT)
		FROM #REMIT_TRN_LOCAL as t
	    join agentTable as a WITH(NOLOCK) on a.AGENT_IME_CODE= t.S_AGENT
		
		
	   UPDATE #REMIT_TRN_LOCAL set  S_AGENT = a.AGENT_IME_CODE
		FROM #REMIT_TRN_LOCAL as t
	    join agentTable as a WITH(NOLOCK) on a.map_code= t.S_AGENT


		 IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit

	--##### Send Today &  Paid Today

		SELECT ACCT_NUM,isnull(AMT,0)as AMT, TRN_TYPE,gl_code
			into #_tzRemittanceTranHit
			FROM (
			
			
				-- Remittance Payable - Global Remit (payout)
				SELECT @GLB_REM_PAY AS ACCT_NUM,
					SUM(ROUND_AMT)AS AMT , 'DR' AS 'TRN_TYPE','12' as gl_code 
				FROM #REMIT_TRN_LOCAL with (nolock)
				
				
				UNION ALL
				
				-- Global Remit GBL
				SELECT @GLB_REM_DOM AS 'ACT',
					SUM(ISNULL(EXT_SC,0))AS AMT , 'DR' AS 'TRN_TYPE', '4'
				FROM #REMIT_TRN_LOCAL with (nolock)
				
				UNION ALL
			
				-- Remittance Commission - Global Remit (SC)
				SELECT @REM_COMM_SC AS 'ACT',
				SUM(isnull(S_SC,0))AS AMT , 'DR' AS 'TRN_TYPE','13'
				FROM #REMIT_TRN_LOCAL with (nolock)
			
					
				UNION ALL
				
				-- Remittance Commission - Global Remit (RC)
				SELECT @REM_COMM_RC AS 'ACT',
					SUM(R_SC) AS AMT , 'DR' AS 'TRN_TYPE','13' 
				FROM #REMIT_TRN_LOCAL with (nolock)
				
				
				UNION ALL
				
				-- Remittance Commission - Global Remit (HO)
				SELECT @REM_COMM_HO AS 'ACT',
					SUM(TOTAL_SC-(S_SC+R_SC+ISNULL(EXT_SC,0))) AS AMT , 'DR' AS 'TRN_TYPE','13' 
				FROM #REMIT_TRN_LOCAL with (nolock)
				
					
				UNION ALL
				
				--Sub Agent	(Payout +SC+  RC + GBL + HO)			
				SELECT acct_num ,SUM(ROUND_AMT + TOTAL_SC)AS AMT ,
				    'CR' AS 'TRN_TYPE',@PAY_SUB_AGN 
				FROM #REMIT_TRN_LOCAL C  with (nolock)
				JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
				JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
				WHERE acct_rpt_code=@PAY_SUB_AGN
				GROUP BY acct_num

							
				UNION ALL

				SELECT ACCT_NUM,
				SUM(S_SC)AS AMT , 'DR' AS 'TRN_TYPE', '101'
				FROM #REMIT_TRN_LOCAL C  with (nolock)
				JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
				JOIN ac_master M  with (nolock) ON M.agent_id=A.agent_id
				WHERE --- TRN_STATUS<>'Cancel' AND
				acct_rpt_code='22' 
				GROUP BY acct_num

				
				UNION ALL
				
		 			-- Agent Commission (D. Remitt. S C)
				SELECT @REM_DCOM_SC AS 'ACCT_NUM',
				SUM(S_SC)AS AMT , 'CR' AS 'TRN_TYPE', '18' as gl_code
				FROM #REMIT_TRN_LOCAL with (nolock)


				

		)AL
		
	--ADDED  FOR TRANSACTION PAID AFTER FINAL SETTLEMENT i.e. AFTER FIRST VOUCHER GENERATION
	DECLARE @NEWAMT MONEY 
	SELECT @NEWAMT=SUM(P_AMT) FROM #REMIT_TRN_LOCAL
	WHERE ISNULL(F_STODAY_NOTPTODAY,'N') ='Y'
	AND F_STODAY_CTODAY IS NULL 
	AND F_CODAY_SYESTERDAY IS NULL 
	AND CANCEL_DATE IS NOT NULL
	


	    IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_1') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_1

	
		SELECT ACCT_NUM,AMT,TRN_TYPE,gl_code
			into #_tzRemittanceTranHit_1
			FROM (
			SELECT @REM_PAY_DOM ACCT_NUM ,@NEWAMT AMT ,'Dr' TRN_TYPE, '4' gl_code
			UNION ALL
			SELECT @REM_PAY_UNPAY,@NEWAMT,'Cr', '4') X
			
				
	
	
	IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_all') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_all

	select acct_num,sum(amt)AMT,trn_type
		into #_tzRemittanceTranHit_all
		 from(
			select * from #_tzRemittanceTranHit
			union all
			select * from #_tzRemittanceTranHit_1
	
		)x
	group by acct_num,trn_type
		
	Alter table #_tzRemittanceTranHit_all add RowID INT IDENTITY(1,1)
	select @intPartId=max(RowID) from #_tzRemittanceTranHit_all
	
	declare @dr money,@cr money

	Select @dr = isnull(sum(AMT),0) FROM #_tzRemittanceTranHit_all where trn_type='DR' AND ISNULL(AMT,0) >0 group by trn_type
	Select @cr = isnull(sum(AMT),0) from #_tzRemittanceTranHit_all where trn_type='CR' AND ISNULL(AMT,0) >0 group by trn_type

		
	-- ########## CR and DR Balance
	if (ISNULL(@dr,0) <> ISNULL(@cr,0))
	begin
			exec proc_errorHandler 1,'DR and CR Balance is not Equal',null
			return;		
			
			select * from #_tzRemittanceTranHit
			select * from #_tzRemittanceTranHit_1
	end
	
	
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
	
	/*	
	--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit_all add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit_all
	
	--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit
	
	
		-- ########## CR and DR Balance
		if (Select isnull(sum(AMT),0) from #_tzRemittanceTranHit 
				    where trn_type='DR' group by trn_type)
			<> (select isnull(sum(AMT),0) from #_tzRemittanceTranHit  
				    where trn_type='CR' group by trn_type)
		begin

				Select  'DR and CR Balance is not Equal' as REMARKS
				return;			
		end
	
	
		
	
	
	############ Voucher no Generation logic 
	select @strRefNum=isnull( TRANSACTION_VOUCHER ,1) from BillSetting with (nolock) where company_id=@company_id

BEGIN TRANSACTION

	 ########## UPDATE BILLSETTING
	update BillSetting set TRANSACTION_VOUCHER=isnull(TRANSACTION_VOUCHER ,1)+1 where company_id=@company_id	
	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	
	--########### Start loop count
	set @intTotalRows=1
	while @intPartId >=  @intTotalRows
	begin
				-- row wise trn values
				SELECT @strAccountNum=ACCT_NUM,@dblTotalAmtNPR=AMT,@strTranType=TRN_TYPE 
				FROM #_tzRemittanceTranHit
				where RowID=@intTotalRows
				
					IF (@@ERROR <> 0) GOTO QuitWithRollback 
					
				Exec ProcDrCrUpdateFinal @strTranType ,@strAccountNum, @dblTotalAmtNPR,0
					IF (@@ERROR <> 0) GOTO QuitWithRollback 
					
	set @intTotalRows=@intTotalRows+1
	end
	
	*/
			-- ######### Insert into tran master table
	
		if exists( select * from #_tzRemittanceTranHit t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0 )
		begin
				
			insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
				,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
				tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
			Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM) ,
				TRN_TYPE,@strRefNum ,AMT,0,0,@date,'s','1',
				ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
			from #_tzRemittanceTranHit t, ac_master a  
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Local Remittance Cancel','s','1',@date
				
			IF (@@ERROR <> 0) GOTO QuitWithRollback
				
		end
		
			
		if exists( select * from #_tzRemittanceTranHit_1 t, ac_master a 
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
				from #_tzRemittanceTranHit_1 t, ac_master a 
				where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
				Select @strRefNum,'Local Remittance Cancel After final settlement','s','1',@date
					
				IF (@@ERROR <> 0) GOTO QuitWithRollback
		end
		
	-- ########## UPDATE BILLSETTING
	update BillSetting set TRANSACTION_VOUCHER = @strRefNum+1 where company_id=@company_id
	IF (@@ERROR <> 0) GOTO QuitWithRollback 		
			
	-- ########## Update flag
	update REMIT_TRN_LOCAL set F_STODAY_CTODAY='y'
	FROM REMIT_TRN_LOCAL R,#REMIT_TRN_LOCAL T
	WHERE R.TRAN_ID = t.TRAN_ID
	AND  R.F_STODAY_CTODAY is null
	AND R.TRN_STATUS = 'Cancel'

	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	UPDATE C SET C.todaysCancelled = todaysCancelled - SAMT FROM SendMnPro_Remit.dbo.creditlimit c
	INNER JOIN (
		SELECT S_AGENT,SUM(ROUND_AMT+ISNULL(TOTAL_SC,0)) SAMT FROM #REMIT_TRN_LOCAL GROUP BY S_AGENT
	) L ON C.agentId = l.S_AGENT
		
COMMIT TRANSACTION
 
	exec proc_errorHandler 0,'PROCESS COMPLETED',null

	SELECT @strMissingList = 'Local Remittance Cancel : '+@date+@time

	Exec JobHistoryRecord 'i','Remittance Voucher','',@strRefNum,@strMissingList,'',@user

GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 


EndSave: 

end





GO
