USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procSendYesterdayCancelTodayTrn_local]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[procSendYesterdayCancelTodayTrn_local]
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

IF @flag='a'
BEGIN
		-- ## FOR STATUS SYNC
		EXEC PROC_SyncDomTxnStatus @FLAG = 'C'

		SET NOCOUNT ON;
		SET XACT_ABORT ON;

		DECLARE @error_msg VARCHAR(250)
		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20), @dblTotalAmtNPR as float
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @REM_PAY_GBL as VARCHAR(20),@REM_COM_GBL as VARCHAR(20),
				@SUB_AGN_PRN as VARCHAR(20),@GBL_REM_DOM as VARCHAR(20),
				@REM_PAY_UNP as VARCHAR(20),@REM_PAY_UNP_OLD as VARCHAR(20),
				@CUTOFFDATE as VARCHAR(20),@REM_PAY_GBL_OLD as VARCHAR(20),
				@REM_COMM_SC AS VARCHAR(20),@GLB_REM_DOM AS VARCHAR(20),@REM_COMM_HO VARCHAR(20),@REM_DCOM_SC VARCHAR(20)
		------------------------------
		--'121004702'
			select  @REM_PAY_GBL = acct_num from ac_master WHERE acct_name ='Remitance Account - Domestic Transactions'
			
			select @REM_PAY_GBL_OLD = acct_num from ac_master WHERE acct_name ='Remittance Payable Settlement Bank (OLD)'
		
			select @REM_COM_GBL = acct_num from ac_master WHERE acct_name='Commission Income - Paying Agent'
	    
	    --gl_code='20'
		-- select @SUB_AGN_PRN = value from configTable WHERE cat='Payable to Sub Agent - Principle'
	    set @SUB_AGN_PRN='20'
	    
			select @REM_COMM_SC = acct_num from ac_master WHERE acct_name='Commission Income - Sending Agent'
			select @GLB_REM_DOM = acct_num from ac_master WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank'
			select @REM_COMM_HO = acct_num from ac_master WHERE acct_name='Commission Income - Head Office'
			select @REM_DCOM_SC = acct_num from ac_master WHERE acct_name='Commission Expenses - Domestic Send'

			select @GBL_REM_DOM = acct_num from ac_master WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank'
		
			select @REM_PAY_UNP = acct_num from ac_master WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank (UNPAID)'
		
			select @REM_PAY_UNP_OLD = acct_num from ac_master WHERE acct_name='Remittance Payable - Settlement Bank (Unpaid OLD)'
		-------------------------------------
		SET @CUTOFFDATE='2009-10-10'
		
		IF OBJECT_ID(N'TEMPDB..#REMIT_TRN_LOCAL') IS NOT NULL
			DROP TABLE #REMIT_TRN_LOCAL
		
		----IF EXISTS(
		----		SELECT 'A' 
		----		FROM REMIT_TRN_LOCAL C with (nolock)
		----		WHERE CANCEL_DATE < @date
		----		AND ISNULL(CONFIRM_DATE,0) not between @date and @date + @time
		----		AND F_CODAY_SYESTERDAY is null
		----		AND TRN_STATUS='Cancel'
		----)
		----BEGIN
		----	EXEC proc_errorHandler 1,'Back Date Voucher Generation pending.',null
		----	RETURN;
		----END

		SELECT * 
		  INTO  #REMIT_TRN_LOCAL
		FROM REMIT_TRN_LOCAL C with (nolock)
		WHERE CANCEL_DATE between @date and @date + @time
		AND ISNULL(CONFIRM_DATE,0) not between @date and @date + @time
		AND F_CODAY_SYESTERDAY is null
		AND TRN_STATUS='Cancel'


		IF NOT EXISTS(SELECT TOP 1 TRAN_ID FROM #REMIT_TRN_LOCAL with (nolock))
		BEGIN
			EXEC proc_errorHandler 1,'NO RECORDS',null
			RETURN;
		END

		
		if exists(Select top 1 S_AGENT from #REMIT_TRN_LOCAL r with (nolock)
		where S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable))
		BEGIN
				DECLARE @strMissingList varchar(100)

				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(S_AGENT AS varchar(20))
				FROM #REMIT_TRN_LOCAL with (nolock)
				where S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable)
				group by S_AGENT

				SET @error_msg = 'AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList
				EXEC proc_errorHandler 1, @error_msg,null
				RETURN;
	   END
	

	   UPDATE #REMIT_TRN_LOCAL set  S_AGENT = ISNULL(a.central_sett_code,t.S_AGENT)
		FROM #REMIT_TRN_LOCAL as t
	    join agentTable as a WITH(NOLOCK) on a.AGENT_IME_CODE= t.S_AGENT
		
		
	   UPDATE #REMIT_TRN_LOCAL set  S_AGENT = a.AGENT_IME_CODE
		FROM #REMIT_TRN_LOCAL as t
	    join agentTable as a WITH(NOLOCK) on a.map_code= t.S_AGENT


		IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit

	-- ############ Unpaid Till Yesterday & Cancel Today drop table #_tzRemittanceTranHit
			SELECT ACCT_NUM,AMT,TRN_TYPE, gl_code
				into #_tzRemittanceTranHit
			FROM (
			
					-- Remittance Payable - Global Remit	(Payout)		Dr.
					SELECT @REM_PAY_GBL AS 'ACCT_NUM',
						ISNULL(SUM(ROUND_AMT),0) AS AMT , 'DR' AS 'TRN_TYPE','12' as gl_code 
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE 
						CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 AND cast(@date as datetime) -1 +' 23:59:59'
						
					
					UNION ALL
					
					--Remittance Commission - Global Remit (RC)	 (RC)		Dr.
					SELECT @REM_COM_GBL AS 'ACCT_NUM',
						ISNULL(SUM(R_SC),0) AS AMT , 'DR' AS 'TRN_TYPE', '13' 
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 AND cast(@date as datetime) -1 +' 23:59:59'
					
					UNION ALL
			
					-- Remittance Commission - Global Remit (SC)
					SELECT @REM_COMM_SC AS 'ACT',
					SUM(isnull(S_SC,0))AS AMT , 'DR' AS 'TRN_TYPE','13'
					FROM #REMIT_TRN_LOCAL with (nolock)

					UNION ALL
				
					-- Global Remit GBL
					SELECT @GLB_REM_DOM AS 'ACT',
						SUM(ISNULL(EXT_SC,0))AS AMT , 'DR' AS 'TRN_TYPE', '4'
					FROM #REMIT_TRN_LOCAL with (nolock)

					UNION ALL

					-- Remittance Commission - Global Remit (HO)
					SELECT @REM_COMM_HO AS 'ACT',
						SUM(TOTAL_SC-(S_SC+R_SC+ISNULL(EXT_SC,0))) AS AMT , 'DR' AS 'TRN_TYPE','13' 
					FROM #REMIT_TRN_LOCAL with (nolock)
				
					UNION ALL
					
					-- Sub Agent (Payout + RC)		CR
					SELECT ACCT_NUM ,SUM(ROUND_AMT + ISNULL(TOTAL_SC,0))AS AMT ,'CR' AS 'TRN_TYPE',@SUB_AGN_PRN
					FROM #REMIT_TRN_LOCAL C with (nolock)
						JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
						JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
					WHERE 
						CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 
						AND cast(@date as datetime) -1 +' 23:59:59'
						AND acct_rpt_code=@SUB_AGN_PRN 
					GROUP BY ACCT_NUM
					
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

					UNION ALL
					
					-- Global Remit						(Payout)		Dr.
					SELECT @GBL_REM_DOM AS 'ACT',
						ISNULL(SUM(ROUND_AMT),0) AS AMT , 'DR' AS 'TRN_TYPE', '4'
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE 
						CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 
					   AND cast(@date as datetime) -1 +' 23:59:59'
				
					UNION ALL

					--To	Remittance Payable - Global Remit (Unpaid)	 (Payout)			
					SELECT @REM_PAY_UNP AS 'ACT',
						ISNULL(SUM(ROUND_AMT),0) AS AMT , 'CR' AS 'TRN_TYPE', '2' 
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE 
						CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 
					     AND cast(@date as datetime) -1 +' 23:59:59'
	
	 )al
				
	-- OLD LOGIC
	IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_old') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_old



	SELECT ACCT_NUM,AMT,TRN_TYPE, gl_code
				into #_tzRemittanceTranHit_old
			FROM (
			
					-- Remittance Payable - Global Remit	(Payout)		Dr.
					SELECT @REM_PAY_GBL_OLD AS 'ACCT_NUM',
						ISNULL(SUM(ROUND_AMT+ ISNULL(R_SC,0)),0) AS AMT , 'DR' AS 'TRN_TYPE','12' as gl_code 
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
						
					
					UNION ALL	
					
					-- Sub Agent (Payout + RC)		CR
					SELECT ACCT_NUM ,SUM(ROUND_AMT + ISNULL(R_SC,0))AS AMT ,'CR' AS 'TRN_TYPE',@SUB_AGN_PRN
					FROM #REMIT_TRN_LOCAL C  with (nolock)
						JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
						JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
					WHERE CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
						AND acct_rpt_code=@SUB_AGN_PRN 
					GROUP BY ACCT_NUM
					
					UNION ALL
					
					-- Global Remit						(Payout)		Dr.
					SELECT @GBL_REM_DOM AS 'ACT',
						ISNULL(SUM(ROUND_AMT+ ISNULL(R_SC,0)),0) AS AMT , 'DR' AS 'TRN_TYPE', '4'
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
							
					
					UNION ALL

					--To	Remittance Payable - Global Remit (Unpaid OLD)	 (Payout)			
					SELECT @REM_PAY_UNP_OLD AS 'ACT',
						ISNULL(SUM(ROUND_AMT+ISNULL(R_SC,0)),0) AS AMT , 'CR' AS 'TRN_TYPE', '2' 
					FROM #REMIT_TRN_LOCAL with (nolock)
					WHERE CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
						
	)b
		
 
		
	IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_all') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_all

	-- ######## Merging all table in one
				select acct_num,sum(amt)AMT,trn_type
					into #_tzRemittanceTranHit_all
					 from(
						SELECT * FROM #_tzRemittanceTranHit
						UNION ALL
						SELECT * FROM #_tzRemittanceTranHit_old
					)x
				group by acct_num,trn_type
				
		
	declare @dr money,@cr money

	Select @dr = isnull(sum(AMT),0) FROM #_tzRemittanceTranHit where trn_type='DR' group by trn_type
	Select @cr = isnull(sum(AMT),0) from #_tzRemittanceTranHit where trn_type='CR' group by trn_type

	-- ########## CR and DR Balance
	IF (ISNULL(@dr,0) <> ISNULL(@cr,0))
	BEGIN
			exec proc_errorHandler 1,'DR and CR Balance is not Equal',null
			RETURN;			
	END

	Select @dr = isnull(sum(AMT),0) FROM #_tzRemittanceTranHit_all where trn_type='DR' group by trn_type
	Select @cr = isnull(sum(AMT),0) from #_tzRemittanceTranHit_all where trn_type='CR' group by trn_type

	-- ########## CR and DR Balance
	IF (ISNULL(@dr,0) <> ISNULL(@cr,0))
	BEGIN
			exec proc_errorHandler 1,'DR and CR Balance is not Equal',null
			RETURN;			
	END
	
		--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit_all add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit_all
	
	
	--############ Voucher no Generation logic 
	select @strRefNum=isnull( TRANSACTION_VOUCHER ,1) from BillSetting 
	   where company_id=@company_id


BEGIN TRANSACTION

	-- ########## UPDATE BILLSETTING
	

	IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
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
		
			-- ######### Insert into tran master table
			insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
				,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
				tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
			Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM),
				TRN_TYPE,@strRefNum ,AMT,0,0,cast(@date as datetime),'s','1',
				ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
			from #_tzRemittanceTranHit t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Unpaid Till Yesterday And Cancel Today','s','1',@date
		
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
		end
		
		if exists( select * from #_tzRemittanceTranHit_old t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0 )
		begin
			set @strRefNum=@strRefNum+1
			insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
				,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
				tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
			Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM),
				TRN_TYPE,@strRefNum ,AMT,0,0,cast(@date as datetime),'s','1',
				ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
			from #_tzRemittanceTranHit_old t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Unpaid Till Yesterday And Cancel Today','s','1',@date
		
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		end
		
	update BillSetting set TRANSACTION_VOUCHER=@strRefNum + 1	where company_id=@company_id	
	
			
	-- ########## Update flag
		update REMIT_TRN_LOCAL set F_CODAY_SYESTERDAY='y'
		FROM REMIT_TRN_LOCAL R,#REMIT_TRN_LOCAL T
		WHERE R.TRAN_ID = t.TRAN_ID
		AND R.F_CODAY_SYESTERDAY is null
		AND R.TRN_STATUS='Cancel'
			
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		UPDATE C SET C.todaysCancelled = todaysCancelled - SAMT FROM SendMnPro_Remit.dbo.creditlimit c
		INNER JOIN (
		SELECT S_AGENT,SUM(ROUND_AMT+ISNULL(TOTAL_SC,0)) SAMT FROM #REMIT_TRN_LOCAL GROUP BY S_AGENT
		) L ON C.agentId = l.S_AGENT
		
COMMIT TRANSACTION
 
	exec proc_errorHandler 0,'PROCESS COMPLETED',null
	SELECT @strMissingList = 'Unpaid Till Yesterday And Cancel Today : '+@date+@time

	Exec JobHistoryRecord 'i','Remittance Voucher','',@strRefNum,@strMissingList,'',@user

GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 


EndSave: 
		
end







GO
