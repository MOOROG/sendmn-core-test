USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procSendTodayNotPaidTodayTrn_local]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec [procSendTodayNotPaidTodayTrn_local] 'a' ,'',1

 CREATE	 proc [dbo].[procSendTodayNotPaidTodayTrn_local]
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

if @flag='a'
begin

		SET NOCOUNT ON;
		SET XACT_ABORT ON;

		DECLARE @error_msg VARCHAR(250)
		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20), @dblTotalAmtNPR as float
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @REM_PAY_GLB as VARCHAR(20),@GLB_REM_DOM as VARCHAR(20)
		
		----------------------------------------
		select @REM_PAY_GLB=acct_num from ac_master with (nolock) WHERE acct_name = 'Settlement Bank Domestic - Machhapuchre Bank (UNPAID)'
		
		select @GLB_REM_DOM = acct_num from ac_master with (nolock) WHERE acct_name='Settlement Bank Domestic - Machhapuchre Bank'
		----------------------------------------
		

		IF OBJECT_ID(N'TEMPDB..#REMIT_TRN_LOCAL') IS NOT NULL
			DROP TABLE #REMIT_TRN_LOCAL


	     SELECT * 
		  INTO  #REMIT_TRN_LOCAL
		FROM REMIT_TRN_LOCAL C with (nolock)
		WHERE CONFIRM_DATE between @date and @date + @time
		----AND PAY_STATUS='Un-Paid' 
		----AND TRN_STATUS='Payment' 
		AND isnull(P_DATE,0) NOT BETWEEN @date and @date + @time
		AND isnull(CANCEL_DATE,0) NOT BETWEEN @date and @date + @time
		AND F_STODAY_NOTPTODAY is null
		     

		
	    IF not exists(SELECT top 1 TRAN_ID FROM #REMIT_TRN_LOCAL with (nolock))
		begin
			exec proc_errorHandler 1,'NO RECORDS',null
			return;
		end


		if exists(Select top 1 S_AGENT from #REMIT_TRN_LOCAL r with (nolock)
		where S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable))
		begin
				DECLARE @strMissingList varchar(100)

				SELECT @strMissingList = COALESCE(@strMissingList + ', ', '') + 
				   CAST(S_AGENT AS varchar(20))
				FROM #REMIT_TRN_LOCAL
				where S_AGENT not in (select isnull(AGENT_IME_CODE,0) from agentTable with (nolock))
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
	SELECT ACCT_NUM,AMT,TRN_TYPE,gl_code
			into #_tzRemittanceTranHit
			FROM (
			
				-- Remittance Payable Global Remit  domestic (payout)
				SELECT @REM_PAY_GLB AS ACCT_NUM,
						SUM(ROUND_AMT )AS AMT , 'DR' AS TRN_TYPE, '20' as gl_code
				FROM #REMIT_TRN_LOCAL with (nolock)
					
					
				UNION ALL
				
				-- Remittance Payable Global Remit  domestic
				SELECT @GLB_REM_DOM as'ACT',
					SUM(ROUND_AMT )AS AMT , 'CR' AS 'TRN_TYPE', '4'
				FROM #REMIT_TRN_LOCAL with (nolock)
				
		)AL
		
		
	--########### Create Temp table for Agent list
		Alter table #_tzRemittanceTranHit add RowID INT IDENTITY(1,1)
		select @intPartId=max(RowID) from #_tzRemittanceTranHit
	
		
	-- ########## CR and DR Balance
	declare @dr money,@cr money

	Select @dr = isnull(sum(AMT),0) FROM #_tzRemittanceTranHit where trn_type='DR' AND ISNULL(AMT,0) >0 group by trn_type
	Select @cr = isnull(sum(AMT),0) from #_tzRemittanceTranHit where trn_type='CR' AND ISNULL(AMT,0) >0 group by trn_type

	-- ########## CR and DR Balance
	IF (ISNULL(@dr,0) <> ISNULL(@cr,0))
	BEGIN
			exec proc_errorHandler 1,'DR and CR Balance is not Equal',null
			RETURN;			
	END

	--############ Voucher no Generation logic 
	select @strRefNum=isnull( TRANSACTION_VOUCHER ,1) from BillSetting where company_id=@company_id

BEGIN TRANSACTION

	-- ########## UPDATE BILLSETTING
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
	
			-- ######### Insert into tran master table
			insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
				,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
				tran_type,company_id,part_tran_srl_num,created_date,rpt_code)
			Select @user,a.ACCT_NUM,dbo.FunGetGLCode(a.ACCT_NUM),
				TRN_TYPE,@strRefNum ,AMT,0,0,@date,'s','1',
				ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo,GETDATE(),'s'
			from #_tzRemittanceTranHit t, ac_master a 
			where t.ACCT_NUM=a.acct_num and isnull(AMT,0)>0
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
			Select @strRefNum,'Remittance Send Today And Not Paid Today','s','1',@date
				
		
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			
		-- ########## Update flag
		update REMIT_TRN_LOCAL set F_STODAY_NOTPTODAY='y'
		FROM REMIT_TRN_LOCAL R,#REMIT_TRN_LOCAL T
		WHERE R.TRAN_ID = t.TRAN_ID
		AND R.F_STODAY_NOTPTODAY is null

		IF (@@ERROR <> 0) GOTO QuitWithRollback
				

COMMIT TRANSACTION
 
	 exec proc_errorHandler 0,'PROCESS COMPLETED',null

	 SELECT @strMissingList = 'Remittance Send Today And Not Paid Today : '+@date+@time

	Exec JobHistoryRecord 'i','Remittance Voucher','',@strRefNum,@strMissingList,'',@user

GOTO  EndSave

QuitWithRollback:
ROLLBACK TRANSACTION 


EndSave: 	

end





GO
