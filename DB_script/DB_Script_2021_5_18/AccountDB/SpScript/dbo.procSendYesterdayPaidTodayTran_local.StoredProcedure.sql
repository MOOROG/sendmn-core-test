USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procSendYesterdayPaidTodayTran_local]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[procSendYesterdayPaidTodayTran_local]
@flag		char(1),
@date		varchar(20),
@time		varchar(20),
@company_id varchar(20),
@user		varchar(50)=null

---- EXEC [procSendYesterdayPaidTodayTran_local] @flag='a' ,@date='2017-02-10',@time='24',@company_id='1',@user='system'
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

	set nocount on;
	set xact_abort on;
	
		DECLARE @error_msg VARCHAR(250)
		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20), @dblTotalAmtNPR as float
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @REM_PAY_GBL as VARCHAR(20),@REM_PAY_DOM as VARCHAR(20),
				@REM_PAY_UNPAY as VARCHAR(20),@REM_PAY_RC as VARCHAR(20),
				@SUB_AGN_PRN as VARCHAR(20),@SUB_AGN_DCOM as VARCHAR(20),
				@REM_PAY_UNP_OLD as VARCHAR(20),@REM_PAY_GBL_OLD as VARCHAR(20),
				@CUTOFFDATE as VARCHAR(20)
		-------------------------------------
		select @REM_PAY_GBL = acct_num from ac_master with (nolock) WHERE acct_name = 'Remitance Account - Domestic Transactions'		
		
		select @REM_PAY_DOM = acct_num from ac_master with (nolock) WHERE acct_name = 'Settlement Bank Domestic - Machhapuchre Bank'
		
		select @REM_PAY_UNPAY = acct_num from ac_master with (nolock) WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank (UNPAID)'
		
		select @REM_PAY_RC = acct_num from ac_master with (nolock) WHERE acct_name='Commission Expenses - Domestic Paid'		
		
		--gl_code='20'
		-- select @SUB_AGN_PRN = acct_num from ac_master with (nolock) WHERE acct_name='Payable to Sub Agent - Principle'
		set @SUB_AGN_PRN='20'
		
		--gl_code='22'
		-- select @SUB_AGN_DCOM = acct_num from ac_master with (nolock) WHERE acct_name='Sub Agent (D. Comm.) R C LOCAL'
		set @SUB_AGN_DCOM='22'
		
		
		select @REM_PAY_UNP_OLD=acct_num from ac_master with (nolock) WHERE acct_name='Remittance Payable - Global Remit (Unpaid OLD)'
		
		select @REM_PAY_GBL_OLD=acct_num from ac_master with (nolock) WHERE acct_name='Remittance Payable Global Remit (OLD)'
		--------------------------------------
		
		set @CUTOFFDATE = '2009-10-10'
		
		IF OBJECT_ID(N'TEMPDB..#REMIT_TRN_LOCAL') IS NOT NULL
			DROP TABLE #REMIT_TRN_LOCAL
		
		----IF EXISTS(
		----	SELECT * 
		----	FROM REMIT_TRN_LOCAL C with (nolock)
		----	WHERE P_DATE < @date 
		----	AND ISNULL(CONFIRM_DATE,0) not between @date and @date + @time
		----	AND F_PTODAY_SYESTERDAY is null
		----	AND PAY_STATUS = 'Paid'
		----)
		----BEGIN
		----	EXEC proc_errorHandler 1,'Back Date Voucher Generation pending.',null
		----	RETURN;
		----END

			SELECT * 
				INTO  #REMIT_TRN_LOCAL
			FROM REMIT_TRN_LOCAL C with (nolock)
			WHERE P_DATE between @date and @date + @time
			AND ISNULL(CONFIRM_DATE,0) not between @date and @date + @time
			AND F_PTODAY_SYESTERDAY is null
			AND PAY_STATUS='Paid'


	     IF NOT EXISTS(SELECT top 1 TRAN_ID FROM #REMIT_TRN_LOCAL WITH (NOLOCK))
		BEGIN

			exec proc_errorHandler 1,'NO RECORDS',null
			return;

		END


		if exists(Select R_AGENT from #REMIT_TRN_LOCAL r with (nolock)
		where R_AGENT not in (select isnull(map_code,0) from agentTable(NOLOCK))
		)
		begin
		
				DECLARE @strMissingList varchar(100)

				SELECT top 1 @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(R_AGENT AS varchar(20)) +','+ CAST( dbo.decryptDbLocal(TRN_REF_NO) AS varchar(20))
				FROM #REMIT_TRN_LOCAL with (nolock)
				where R_AGENT not in (select isnull(map_code,0) from agentTable(NOLOCK))
				

				SET @error_msg = 'AGENT MISSING IN ACCOUNTING SYSTEM: '+ @strMissingList
				EXEC proc_errorHandler 1, @error_msg,null
				RETURN;
				
		end
		

	 --   UPDATE #REMIT_TRN_LOCAL set  R_AGENT = ISNULL(a.central_sett_code,t.R_AGENT)
		--    FROM #REMIT_TRN_LOCAL as t
		--   join agentTable as a WITH(NOLOCK) on a.AGENT_IME_CODE= t.R_AGENT
    		
    		
		--UPDATE #REMIT_TRN_LOCAL set  R_AGENT = a.AGENT_IME_CODE
		--    FROM #REMIT_TRN_LOCAL as t
		--   join agentTable as a WITH(NOLOCK) on a.map_code= t.R_AGENT

		
		IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit


		SELECT ACCT_NUM,isnull(AMT,0) AMT,TRN_TYPE,gl_code
		into #_tzRemittanceTranHit
		FROM (
		
				-- Remittance Payable - Global Remit (Payout)
				SELECT @REM_PAY_GBL AS ACCT_NUM,
					ISNULL(SUM(ROUND_AMT),0) AS AMT , 'DR' AS 'TRN_TYPE', '12' as gl_code
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid'
					AND CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1
					AND cast(@date as datetime) -1 +' 23:59:59'
					
								
				UNION ALL
				
				-- Sub Agentwise (payout) 
				SELECT M.acct_num,
					ISNULL(SUM(ROUND_AMT),0) AS AMT , 'CR' AS 'TRN_TYPE',@SUB_AGN_PRN
				FROM #REMIT_TRN_LOCAL C with (nolock) 
					JOIN agentTable A with (nolock) ON C.R_AGENT=A.map_code
					JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
				WHERE PAY_STATUS='Paid' 
					AND CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 
					   AND cast(@date as datetime) -1 +' 23:59:59'
					AND acct_rpt_code=@SUB_AGN_PRN
					
				GROUP BY M.acct_num
				
				UNION ALL
				
				-- Remittance Payable Global Remit  domestic
				SELECT @REM_PAY_DOM AS 'ACT',
					ISNULL(SUM(ROUND_AMT),0) AS AMT , 'DR' AS 'TRN_TYPE' ,'4'
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid' 
				AND CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 AND cast(@date as datetime) -1 +' 23:59:59'
				and F_PTODAY_SYESTERDAY is null
				
				UNION ALL
				
				-- Remittance Payable - Global Remit (Unpaid)
				
				SELECT @REM_PAY_UNPAY AS 'ACT',
					ISNULL(SUM(ROUND_AMT),0) AS AMT , 'CR' AS 'TRN_TYPE' ,'2'
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid' 
				AND CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 AND cast(@date as datetime) -1 +' 23:59:59'
				
		) Al
		

		IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_2') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_2

		SELECT ACCT_NUM,isnull(AMT,0) AMT,TRN_TYPE ,gl_code
		into #_tzRemittanceTranHit_2
		FROM (

				-- Agent Commission (D. Remitt. R C) RC
				SELECT @REM_PAY_RC AS 'ACCT_NUM',
					ISNULL(SUM(R_SC),0) AS AMT , 'DR' AS 'TRN_TYPE','18' as gl_code 
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid' 
				AND CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 AND cast(@date as datetime) -1 +' 23:59:59'
				
				
				UNION ALL
				
				-- Sub Agent (D. Comm.) RC
				SELECT M.acct_num,
					ISNULL(SUM(R_SC),0) AS AMT , 'CR' AS 'TRN_TYPE', @SUB_AGN_DCOM
				FROM #REMIT_TRN_LOCAL C  with (nolock)
				JOIN agentTable A with (nolock) ON C.R_AGENT=A.map_code
				JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
				WHERE PAY_STATUS='Paid' 
				AND CONFIRM_DATE  between cast(@CUTOFFDATE as datetime) +1 AND cast(@date as datetime) -1 +' 23:59:59'
				AND acct_rpt_code=@SUB_AGN_DCOM
				GROUP BY M.acct_num
		) Al
		
		
		-- ############ OLD UNPAID LOGIC
		IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_old') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_old


		SELECT ACCT_NUM,isnull(AMT,0) AMT,TRN_TYPE,gl_code
		into #_tzRemittanceTranHit_old
		FROM (
				-- Remittance Payable Global Remit- (Unpaid OLD)
				SELECT @REM_PAY_GBL_OLD AS ACCT_NUM,
					ISNULL(SUM(ROUND_AMT+R_SC),0) AS AMT , 'DR' AS 'TRN_TYPE', '12' as gl_code
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid'
				AND CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
				AND convert(varchar,P_DATE,102)=convert(varchar,cast(@date as datetime),102)
				and F_PTODAY_SYESTERDAY is null
								
				UNION ALL
				
				-- Sub Agentwise (payout)
				SELECT M.acct_num,
					ISNULL(SUM(ROUND_AMT+R_SC),0) AS AMT , 'CR' AS 'TRN_TYPE', @SUB_AGN_PRN
				FROM #REMIT_TRN_LOCAL C with (nolock)
					JOIN agentTable A with (nolock) ON C.R_AGENT=A.map_code
					JOIN ac_master M with (nolock) ON M.agent_id=A.agent_id
				WHERE PAY_STATUS='Paid' 
					AND CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
					AND acct_rpt_code=@SUB_AGN_PRN
				GROUP BY M.acct_num
				
				UNION ALL
				
				-- Remittance Payable Global Remit  domestic
				SELECT @REM_PAY_DOM AS 'ACT',
					ISNULL(SUM(ROUND_AMT+R_SC),0) AS AMT , 'DR' AS 'TRN_TYPE' ,'4'
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid' 
				AND CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
				
				UNION ALL
				
				-- OLD Remittance Payable - Global Remit (Unpaid OLD)
				SELECT @REM_PAY_UNP_OLD AS 'ACT',
					ISNULL(SUM(ROUND_AMT+R_SC),0) AS AMT , 'CR' AS 'TRN_TYPE' ,'2'
				FROM #REMIT_TRN_LOCAL with (nolock)
				WHERE PAY_STATUS='Paid' 
					AND CONFIRM_DATE <= @CUTOFFDATE+ ' 23:59:59'
					
			
		) Al


		IF OBJECT_ID(N'TEMPDB..#_tzRemittanceTranHit_all') IS NOT NULL
			DROP TABLE #_tzRemittanceTranHit_all


				-- ######## Merging all table in one
				select acct_num,sum(amt)AMT,trn_type
					into #_tzRemittanceTranHit_all
					 from(
						select * from #_tzRemittanceTranHit
						union all
						select * from #_tzRemittanceTranHit_2
						union all
						select * from #_tzRemittanceTranHit_old
					)x
				group by acct_num,trn_type
	
		
	-- ########## CR and DR Balance
	declare @dr money,@cr money

	Select @dr = isnull(sum(AMT),0) FROM #_tzRemittanceTranHit_all where trn_type='DR' AND ISNULL(AMT,0) >0 group by trn_type
	Select @cr = isnull(sum(AMT),0) from #_tzRemittanceTranHit_all where trn_type='CR' AND ISNULL(AMT,0) >0 group by trn_type

	----SELECT * FROM #_tzRemittanceTranHit_all
	----RETURN
	-- ########## CR and DR Balance
	IF (ISNULL(@dr,0) <> ISNULL(@cr,0))
	BEGIN
			exec proc_errorHandler 1,'DR and CR Balance is not Equal',null
			RETURN;			
	END

	--############ Voucher no Generation logic 
	select @strRefNum=isnull( TRANSACTION_VOUCHER ,1) from BillSetting with (nolock) where company_id=@company_id

BEGIN TRANSACTION
	
	-- ########## UPDATE BILLSETTING
	update BillSetting set TRANSACTION_VOUCHER=isnull(TRANSACTION_VOUCHER ,1)+ 3 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		
		--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit_all add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit_all
		
		
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
	
			-- ######### Insert into tran master table
			
		if exists( select * from #_tzRemittanceTranHit t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0 )
		begin
		
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
			Select @strRefNum,'Unpaid Till Yesterday And Paid Today','s','1',@date
				
		
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			
			
		end
		
			
		if exists(select * from #_tzRemittanceTranHit_2 t, ac_master a 
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
			from #_tzRemittanceTranHit_2 t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Unpaid Till Yesterday And Paid Today','s','1',@date
				
		
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			
			
		end
		
		if exists( select * from #_tzRemittanceTranHit_old t, ac_master a 
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
			from #_tzRemittanceTranHit_old t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Unpaid Till Yesterday And Paid Today','s','1',@date
				
		
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
		end 
		
		update BillSetting set TRANSACTION_VOUCHER=@strRefNum + 1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
			
		-- ########## Update flag
		update REMIT_TRN_LOCAL set F_PTODAY_SYESTERDAY = 'y'
		FROM REMIT_TRN_LOCAL R,#REMIT_TRN_LOCAL T
		WHERE  R.TRAN_ID = t.TRAN_ID
		AND R.F_PTODAY_SYESTERDAY is null
		AND R.PAY_STATUS = 'Paid'

	
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		UPDATE C SET C.todaysPaid = todaysPaid - SAMT FROM SendMnPro_Remit.dbo.creditlimit c
		INNER JOIN (
		SELECT R_AGENT,SUM(ROUND_AMT) SAMT FROM #REMIT_TRN_LOCAL GROUP BY R_AGENT
		) L ON C.agentId = l.R_AGENT
		
COMMIT TRANSACTION
 
exec proc_errorHandler 0,'PROCESS COMPLETED',null

SELECT @strMissingList = 'Unpaid Till Yesterday And Paid Today : '+@date+@time

Exec JobHistoryRecord 'i','Remittance Voucher','',@strRefNum,@strMissingList,'',@user

GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 


EndSave: 

end







GO
