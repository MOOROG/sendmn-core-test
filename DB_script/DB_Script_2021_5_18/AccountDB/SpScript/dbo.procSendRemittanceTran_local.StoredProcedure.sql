USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procSendRemittanceTran_local]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSendRemittanceTran_local]
@flag		char(1),
@date		varchar(20),
@time		varchar(20),
@company_id varchar(20),
@user		varchar(50)=null

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

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
begin

		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20), @dblTotalAmtNPR as float
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @PAY_SUB_AGN as VARCHAR(20), @SUB_AGN_DCOMM as VARCHAR(20),
			@GLB_REM_PAY as VARCHAR(20),@GLB_REM_DOM as VARCHAR(20),
			@REM_COMM_SC as VARCHAR(20),@REM_COMM_RC as VARCHAR(20),
			@REM_COMM_HO as VARCHAR(20),@REM_DCOM_SC as VARCHAR(20)
		
		-------------------------------------------------
		--'20'
		-- select @PAY_SUB_AGN = value from configTable WHERE cat='Payable to Sub Agent - Principle'	
		set @PAY_SUB_AGN='20'
		

		--'22'
		-- select @SUB_AGN_DCOMM = value from configTable WHERE cat='Sub Agent (D. Comm.) R C LOCAL'
		set @SUB_AGN_DCOMM='22'
		

		--'121004702'
		select @GLB_REM_PAY = acct_num from ac_master with (nolock) WHERE acct_name='Remitance Account - Domestic Transactions'
		
		--'401004688'
		select @GLB_REM_DOM = acct_num from ac_master with (nolock) WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank'
		
		--'131004648'
		select @REM_COMM_SC = acct_num from ac_master with (nolock) WHERE acct_name='Commission Income - Sending Agent'
		
		--'131004653'
		--select value from configTable WHERE cat='Remittance Commission - Global Remit (HO)'
		select @REM_COMM_RC = acct_num from ac_master with (nolock) WHERE acct_name='Commission Income - Paying Agent'
		
		--'131004665'
		select @REM_COMM_HO = acct_num from ac_master with (nolock) WHERE acct_name='Commission Income - Head Office'
		
		--'431085734'
		select @REM_DCOM_SC = acct_num from ac_master with (nolock) WHERE acct_name='Commission Expenses - Domestic Send'
		---------------------------------------------------------------------------------------------
	   
		 -- update configTable set value='431085734' where value='181004428'
		 --  select * from configTable

		 IF OBJECT_ID(N'TEMPDB..#REMIT_TRN_LOCAL') IS NOT NULL
			DROP TABLE #REMIT_TRN_LOCAL

		SELECT * 
		  INTO  #REMIT_TRN_LOCAL
		FROM REMIT_TRN_LOCAL C with (nolock)
		WHERE CONFIRM_DATE <= @date + @time
		AND  F_SENDTRN IS NULL
			

		IF NOT EXISTS(SELECT TRAN_ID FROM #REMIT_TRN_LOCAL with (nolock))
		begin
			exec proc_errorHandler 1,'NO RECORDS',null
			return;
		end

		if exists(Select S_AGENT from #REMIT_TRN_LOCAL r WITH (NOLOCK)
		WHERE S_AGENT not in (select isnull(AGENT_IME_CODE,0) FROM agentTable))
		begin
				DECLARE @strMissingList VARCHAR(300)

				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(S_AGENT AS varchar(20)) +'-'+ dbo.decryptDbLocal(TRN_REF_NO)
				FROM #REMIT_TRN_LOCAL
				where  S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable)
				GROUP BY S_AGENT,TRN_REF_NO

				SELECT @strMissingList = 'AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList
				exec proc_errorHandler 1,@strMissingList,null
				RETURN;
	     END
		
		IF EXISTS(SELECT S_AGENT from #REMIT_TRN_LOCAL r with (nolock) where S_AGENT=0)
		begin
				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(S_AGENT AS varchar(20)) +'-'+ dbo.decryptDbLocal(TRN_REF_NO)
				FROM #REMIT_TRN_LOCAL
				where S_AGENT is null

				SELECT @strMissingList = 'AGENT MAP CODE BLANK, PLEASE UPDATE: '+ @strMissingList 
				exec proc_errorHandler 1,@strMissingList,null
				RETURN;
	     end
	     
	     
		IF EXISTS(Select S_AGENT from #REMIT_TRN_LOCAL r with (nolock) where S_AGENT=0)
		begin
				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(S_AGENT AS varchar(20)) +'-'+ dbo.decryptDbLocal(TRN_REF_NO)
				FROM #REMIT_TRN_LOCAL
				where S_AGENT=0

				SELECT @strMissingList = 'AGENT Code 0  IN ACCOUNTING SYSTEM, PLEASE UPDATE: '+ @strMissingList
				exec proc_errorHandler 1,@strMissingList,null
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

	-- ############### First set entry
		SELECT ACCT_NUM,isnull(AMT,0) AMT,TRN_TYPE,gl_code 
		into #_tzRemittanceTranHit
		FROM (
		
			-- Principle ac agentwise
			SELECT M.acct_num as ACCT_NUM ,SUM(isnull(ROUND_AMT,0) + isnull(TOTAL_SC,0))AS AMT ,
			'DR' AS TRN_TYPE, @PAY_SUB_AGN as gl_code
			FROM #REMIT_TRN_LOCAL C with (nolock)
				JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
				JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
			WHERE acct_rpt_code=@PAY_SUB_AGN 
			GROUP BY acct_num
			
			UNION ALL
			
			-- Remittance Payable Global Remit  domestic
			SELECT @GLB_REM_PAY AS 'ACT',
			SUM(isnull(ROUND_AMT,0))AS AMT , 'CR' AS 'TRN_TYPE', '12'
			FROM #REMIT_TRN_LOCAL with (nolock)
			
			
			UNION ALL
			
			-- Global Remit AC domestic
			SELECT @GLB_REM_DOM AS 'ACT',
				SUM(isnull(EXT_SC,0))AS AMT , 'CR' AS 'TRN_TYPE' ,'4'
			FROM #REMIT_TRN_LOCAL with (nolock)
			
			
			UNION ALL
			
			-- Remittance Commission - Global Remit (SC)
			SELECT @REM_COMM_SC AS 'ACT',
			SUM(isnull(S_SC,0))AS AMT , 'CR' AS 'TRN_TYPE','13'
			FROM #REMIT_TRN_LOCAL with (nolock)
			
			
			UNION ALL
				
			-- Remittance Commission - Global Remit (RC)
			SELECT @REM_COMM_RC AS 'ACT',
			SUM(isnull(R_SC,0))AS AMT , 'CR' AS 'TRN_TYPE', '13'
			FROM #REMIT_TRN_LOCAL with (nolock)
			
			
			UNION ALL
			
			-- Remittance Commission - Global Remit (HO)
			SELECT @REM_COMM_HO AS 'ACT',
			SUM(isnull(TOTAL_SC,0)-isnull(R_SC,0)-isnull(S_SC,0)-isnull(EXT_SC,0))AS AMT , 'CR' AS 'TRN_TYPE','13' 
			FROM #REMIT_TRN_LOCAL with (nolock)
			
			
		) Al
		
	-- ############### Second set entry
		SELECT ACCT_NUM,isnull(AMT,0) AMT,TRN_TYPE,gl_code
		into #_tzRemittanceTranHit_second
		FROM (
	
			-- Agent Commission (D. Remitt. S C)
			SELECT @REM_DCOM_SC AS 'ACCT_NUM',
			SUM(S_SC)AS AMT , 'DR' AS 'TRN_TYPE', '18' as gl_code
			FROM #REMIT_TRN_LOCAL with (nolock)
		---	WHERE  TRN_STATUS<>'Cancel'
			
			
			union all
			
			-- Sub Agent (D. Comm.)
			SELECT ACCT_NUM,
				SUM(S_SC)AS AMT , 'CR' AS 'TRN_TYPE', @SUB_AGN_DCOMM
			FROM #REMIT_TRN_LOCAL C  with (nolock)
				JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
				JOIN ac_master M  with (nolock) ON M.agent_id=A.agent_id
			WHERE --- TRN_STATUS<>'Cancel' AND
				 acct_rpt_code=@SUB_AGN_DCOMM 
			GROUP BY acct_num
			
		)b


	    IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_all') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_all

	-- ######## Merging all table in one
		select acct_num,sum(amt)AMT,trn_type
		into #_tzRemittanceTranHit_all
		 from(
			select * from #_tzRemittanceTranHit
			union all
			select * from #_tzRemittanceTranHit_second
		)x
		group by acct_num,trn_type
	
	
	--select * from #_tzRemittanceTranHit_second t
	--inner join ac_master a on t.ACCT_NUM=a.acct_num
	--return
	
	--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit_all add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit_all


	   --Select isnull(sum(AMT),0) from #_tzRemittanceTranHit group by trn_type
	   --Select isnull(sum(AMT),0) from #_tzRemittanceTranHit_second group by trn_type
	if exists(SELECT dbo.decryptDbLocal(T1.TRN_REF_NO)
				FROM #REMIT_TRN_LOCAL T1 with (nolock)
				LEFT JOIN (
				SELECT TRN_REF_NO, (ROUND_AMT)AS AMT 
				FROM #REMIT_TRN_LOCAL C  with (nolock)
					JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
					JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
				WHERE acct_rpt_code='20' 
					and isnull(A.AGENT_IME_CODE,'0')<>'0'
			)A ON T1.TRN_REF_NO = A.TRN_REF_NO 
			WHERE A.TRN_REF_NO is null)
			
	begin
	
				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   'AgentCode:'+ CAST(S_AGENT AS varchar(20)) +'- ICN:'+ (TRN_REF_NO)
				FROM (
							SELECT dbo.decryptDbLocal(T1.TRN_REF_NO)TRN_REF_NO, S_AGENT
							FROM #REMIT_TRN_LOCAL T1 with (nolock)
							LEFT JOIN (
							SELECT TRN_REF_NO, (ROUND_AMT)AS AMT 
							FROM #REMIT_TRN_LOCAL C  with (nolock)
								JOIN agentTable A with (nolock) ON C.S_AGENT=A.AGENT_IME_CODE
								JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
							WHERE acct_rpt_code='20' 
								and isnull(A.AGENT_IME_CODE,'0')<>'0'
						)A ON T1.TRN_REF_NO = A.TRN_REF_NO 
						WHERE A.TRN_REF_NO is null
					)a

				SELECT @strMissingList = 'PRINCIPLE AC MISSING, PLEASE CREATE PRINCIPLE LEDGER: '+ @strMissingList
				exec proc_errorHandler 1,@strMissingList,null
				RETURN;
	
	end
	
	declare @dr money,@cr money

	Select @dr = isnull(sum(AMT),0) FROM #_tzRemittanceTranHit_all where trn_type='DR' AND isnull(AMT,0)>0 group by trn_type
	Select @cr = isnull(sum(AMT),0) from #_tzRemittanceTranHit_all where trn_type='CR' AND isnull(AMT,0)>0 group by trn_type

	-- ########## CR and DR Balance
	IF (ISNULL(@dr,0) <> ISNULL(@cr,0))
	BEGIN
		exec proc_errorHandler 1,'DR and CR Balance is not Equal',null
		RETURN;			
	END
	
	----select * from #_tzRemittanceTranHit t
	----left join ac_master a on t.ACCT_NUM = a.acct_num
	----select * from #_tzRemittanceTranHit_second t
	----left join ac_master a on t.ACCT_NUM = a.acct_num

	----return 

	--############ Voucher no Generation logic 
	select @strRefNum = isnull(TRANSACTION_VOUCHER ,1) from BillSetting with (nolock) where company_id=@company_id

BEGIN TRANSACTION


	--########### Start loop count
	set @intTotalRows=1
	while @intPartId >=  @intTotalRows
	begin
				
				-- row wise trn values
				select @strAccountNum=ACCT_NUM,@dblTotalAmtNPR=AMT,@strTranType=TRN_TYPE 
					from #_tzRemittanceTranHit_all where RowID=@intTotalRows
					
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
			Select @strRefNum,'Domestic Remittance Send','s','1',@date
				
			IF (@@ERROR <> 0) GOTO QuitWithRollback 		
			
			
	     end	
	
		if exists( select * from #_tzRemittanceTranHit_second t, ac_master a 
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
			from #_tzRemittanceTranHit_second t, ac_master a  
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Domestic Remittance Send','s','1',@date
				
		 end
		 
		 -- ########## UPDATE BILLSETTING
		update BillSetting set TRANSACTION_VOUCHER=@strRefNum+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		 
		-- ########## Update flag
		update REMIT_TRN_LOCAL set F_SENDTRN='y'
		FROM REMIT_TRN_LOCAL R,#REMIT_TRN_LOCAL T
		----WHERE R.TRN_REF_NO=T.TRN_REF_NO
		WHERE R.TRAN_ID = t.TRAN_ID
		AND R.CONFIRM_DATE <=@date + @time
		and R.F_SENDTRN is null

		UPDATE C SET C.todaysSent = todaysSent - SAMT FROM SendMnPro_Remit.dbo.creditlimit c
		INNER JOIN (
			SELECT S_AGENT,SUM(ROUND_AMT+ISNULL(TOTAL_SC,0)) SAMT FROM #REMIT_TRN_LOCAL GROUP BY S_AGENT
		) L ON C.agentId = l.s_agent


	IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
COMMIT TRANSACTION
	exec proc_errorHandler 0,'PROCESS COMPLETED',null

	SELECT @strMissingList = 'Domestic Remittance Send ON : '+@date+@time

	Exec JobHistoryRecord 'i','Remittance Voucher','',@strRefNum,@strMissingList,'',@user

GOTO  EndSave

QUITWITHROLLBACK:
ROLLBACK TRANSACTION 
ENDSAVE: 

END


GO
