USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcTDSCalculateMonthly]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[ProcTDSCalculateMonthly] 
	@dateFrom varchar(20),
	@dateTo varchar(20),
	@date varchar(20),
	@company_id varchar(5)=null,
	@user varchar(50)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
BEGIN
----EXEC [ProcTDSCalculateMonthly] @dateFrom ='2016-12-16',@dateTo='2017-01-13',@date='2017-01-13',@company_id=1,@user='SYSTEM'
	-- ############## Record history
		Exec JobHistoryRecord 'i','TDS CALCULATE','FOR INTERNATIONAL AND DOMESTIC AGENT','',@user ,'',@user
		
		declare @decUsdRate as decimal(10,6),@dblTotalAmtNPR as float
		declare @intPartId int, @intTotalRows as int, @strRefNum as varchar(20)
		declare @strAccountNum as varchar(25), @dblTotalAmtUSD as float, @strTranType as varchar(5)
		declare @dblSagent as float
		
		
	if not exists(select tran_id from tran_master t with (nolock), ac_master a with (nolock)
	where t.acc_num=a.acct_num  and t.tran_date between @dateFrom and @dateTo +' 23:59'
				and t.CHEQUE_NO is null and (a.acct_rpt_code='21' or a.acct_rpt_code='22')
			)
		begin
			--select 'NO TRANSACTION FOUND' as REMARKS
			exec proc_errorHandler 1,'NO TRANSACTION FOUND',null
			return;
		end

		SELECT	agent_id, ACCT_NUM, acct_name, TRN_TYPE, AMT,TDS
			into #_tzRemittanceTranHit1
		FROM (
				
				SELECT agent_id, acc_num as ACCT_NUM, acct_name, 'DR' TRN_TYPE,
						sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) as AMT, 00.0000 TDS
					FROM tran_master t with (nolock), ac_master a with (nolock)
					where t.acc_num=a.acct_num and tran_date between @dateFrom and @dateTo +' 23:59'
						and ( acct_rpt_code='21') and isnull(CHEQUE_NO,'') <>'TDS'
						AND T.rpt_code = 's'
					group by acc_num,agent_id,acct_name
				
				UNION ALL
				
					SELECT c.agent_id, c.acct_num, acct_name, 'CR' TRN_TYPE,AMT
					--,CASE WHEN CONSTITUTION IN ('Cooperative form','Limited Company') THEN 0.015 ELSE 0.15  END TDS
					,0.15  TDS
					 FROM(
						SELECT agent_id, acc_num,
							sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) as AMT
						FROM tran_master t with (nolock), ac_master a
						where t.acc_num=a.acct_num 
						and tran_date between @dateFrom and @dateTo +' 23:59'
						and ( acct_rpt_code = '21') and isnull(CHEQUE_NO,'') <>'TDS'
						AND T.rpt_code = 's'
						group by acc_num,agent_id
					)a, ac_master c , agenttable at 
					where a.agent_id=c.agent_id 
					and at.agent_id=a.agent_id
					and c.acct_rpt_code = '20'
		)a

	----SELECT * FROM #_tzRemittanceTranHit1
	----RETURN
	SELECT agent_id,  ACCT_NUM, acct_name, TRN_TYPE, AMT,TDS 
			into #_tzRemittanceTranHit2
			FROM (

					SELECT agent_id, acc_num as ACCT_NUM, acct_name, 'DR' TRN_TYPE,
						sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) as AMT, 00.0000 TDS
					FROM tran_master t with (nolock), ac_master a with (nolock)
					where t.acc_num=a.acct_num and tran_date between @dateFrom and @dateTo +' 23:59'
						and ( acct_rpt_code='22')
						and isnull(CHEQUE_NO,'') <>'TDS'
						AND T.rpt_code = 's'
					group by acc_num,agent_id,acct_name
					
					UNION ALL
				
					SELECT c.agent_id, c.acct_num, acct_name, 'CR' TRN_TYPE,AMT 
					--,CASE WHEN CONSTITUTION IN ('Cooperative form','Limited Company') THEN 0.015 ELSE 0.15  END TDS
					,0.15  TDS
					FROM(
						SELECT agent_id, acc_num,
							sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) as AMT
						FROM tran_master t with (nolock), ac_master a
						where t.acc_num=a.acct_num and tran_date between @dateFrom and @dateTo +' 23:59'
							and ( acct_rpt_code='22')
							and isnull(CHEQUE_NO,'') <>'TDS'
							AND T.rpt_code = 's'
						group by acc_num,agent_id
					)a, ac_master c , AGENTTABLE AT
					where a.agent_id = c.agent_id 
					AND A.AGENT_ID = AT.AGENT_ID
					and c.acct_rpt_code = '20'
)a


SELECT agent_id, ACCT_NUM, acct_name, TRN_TYPE,  AMT 
			INTO  #_tzRemittanceTranHit3
			FROM (
			SELECT am.agent_id, am.acct_num as ACCT_NUM, acct_name,'DR' TRN_TYPE, ROUND(AMT*TDS,0) AMT 
			FROM (
			SELECT AGENT_ID,TDS, SUM(AMT) AMT
			FROM 
			(
				SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit1 WHERE TDS=0.015
				UNION ALL
				SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit2 WHERE TDS=0.015
			)  X GROUP BY AGENT_ID,TDS ) Z,	AC_MASTER AM WHERE Z.AGENT_ID=AM.AGENT_ID AND AM.ACCT_RPT_CODE='20'
	
			UNION ALL
			
			SELECT '', '331000214' as ACCT_NUM, 'TDS Payable' ,'CR' TRN_TYPE, SUM(AMT) AMT 
			FROM (
				SELECT AGENT_ID, ROUND(AMT*TDS,0) AMT
					FROM (
						SELECT AGENT_ID,TDS, SUM(AMT) AMT FROM 
						(
							SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit1 WHERE TDS = 0.015
							UNION ALL
							SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit2 WHERE TDS = 0.015
						)  X GROUP BY AGENT_ID,TDS 	
					) Y 
				) Z
			) XY
	
	SELECT agent_id, ACCT_NUM, acct_name, TRN_TYPE,  AMT 
			INTO  #_tzRemittanceTranHit4
			FROM (
			SELECT am.agent_id, am.acct_num as ACCT_NUM, acct_name,'DR' TRN_TYPE, ROUND(AMT*TDS,0) AMT 
			FROM (
			SELECT AGENT_ID,TDS, SUM(AMT) AMT
			FROM 
			(
				SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit1 WHERE TDS=0.15
				UNION ALL
				SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit2 WHERE TDS=0.15
			)  X GROUP BY AGENT_ID,TDS ) Z,
			AC_MASTER AM WHERE Z.AGENT_ID=AM.AGENT_ID AND AM.ACCT_RPT_CODE='20'
	
			UNION ALL
			
			SELECT '', '331000214' as ACCT_NUM, 'TDS Payable' ,'CR' TRN_TYPE, SUM(AMT) AMT 
			FROM (
				SELECT AGENT_ID, ROUND(AMT*TDS,0) AMT
					FROM (
						SELECT AGENT_ID,TDS, SUM(AMT) AMT	FROM 
						(
							SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit1 WHERE TDS=0.15
							UNION ALL
							SELECT AGENT_ID, TDS, AMT FROM #_tzRemittanceTranHit2 WHERE TDS=0.15
						)  X GROUP BY AGENT_ID,TDS 	
					) Y 
				) Z
			) XY
	

	SELECT * INTO 
	#_tzRemittanceTranHit
	FROM(
		SELECT agent_id, ACCT_NUM, acct_name, TRN_TYPE,  AMT  FROM #_tzRemittanceTranHit1
		UNION ALL
		SELECT agent_id, ACCT_NUM, acct_name, TRN_TYPE,  AMT  FROM #_tzRemittanceTranHit2
		UNION ALL
		SELECT agent_id, ACCT_NUM, acct_name, TRN_TYPE,  AMT  FROM #_tzRemittanceTranHit3
		UNION ALL
		SELECT agent_id, ACCT_NUM, acct_name, TRN_TYPE,  AMT  FROM #_tzRemittanceTranHit4
	)A


		--Select  cast(sum(AMT)as money) from #_tzRemittanceTranHit where trn_type='DR' group by trn_type
		--Select  cast(sum(AMT)as money) from #_tzRemittanceTranHit where trn_type='CR' group by trn_type
		--return;
	DECLARE @DRAMT MONEY,@CRAMT MONEY
	
	Select @DRAMT = cast(sum(AMT)as money) from #_tzRemittanceTranHit where trn_type = 'DR'
	Select @CRAMT = cast(sum(AMT)as money) from #_tzRemittanceTranHit where trn_type = 'CR'
	
	--SELECT * FROM #_tzRemittanceTranHit
	--return
	if (ISNULL(@DRAMT,0)<> ISNULL(@CRAMT,0))
	begin
		exec proc_errorHandler 1,'DR and CR Balance is not Equal' ,null
		return;			
	end	
	
	--########### Create Temp table for Agent list drop table ##_tzTempSendAgentList
		select distinct agent_id into #_tzTempSendAgentList 
		from #_tzRemittanceTranHit 

		Alter table #_tzTempSendAgentList add RowID INT IDENTITY(1,1)


BEGIN TRANSACTION

		--############ Voucher no Generation logic 
	select @strRefNum = isnull( journal_voucher ,1) from BillSetting where company_id = @company_id
	
	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	-- ########## UPDATE BILLSETTING
	update BillSetting set journal_voucher=isnull(journal_voucher ,1)+3  where company_id=@company_id
		
	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	Alter table #_tzRemittanceTranHit add RowID INT IDENTITY(1,1)
	select @intPartId = max(RowID) from #_tzRemittanceTranHit

	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	--########### Start loop count
set @intTotalRows=1
while @intPartId >=  @intTotalRows
begin
			-- row wise trn values
			-- @strAccountNum, @dblTotalAmt, @strTranType

			select @strAccountNum=ACCT_NUM,@dblTotalAmtNPR=AMT,@strTranType=TRN_TYPE from #_tzRemittanceTranHit where RowID=@intTotalRows
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
			Exec ProcDrCrUpdateFinal @strTranType ,@strAccountNum, @dblTotalAmtNPR,0
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
set @intTotalRows=@intTotalRows+1
end

			
		insert into tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
			tran_type,company_id,part_tran_srl_num,created_date,CHEQUE_NO
			,RunningBalance,acct_type_code)
		Select @user,c.ACCT_NUM , dbo.[FunGetGLCode](c.ACCT_NUM),	TRN_TYPE,@strRefNum ,AMT,0,0,@date,
			'j','1',ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo, GETDATE(),'TDS'
			, dbo.[FNAGetRunningBalance](c.ACCT_NUM,AMT,TRN_TYPE),'COMM.PAY'
		from #_tzRemittanceTranHit1 c 
		where  ISNULL(AMT,0) <> 0
			
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
		Select @strRefNum  ,'Internation Commission Paid For The TRN From: '+@dateFrom+' To: '+@dateTo ,'j','1',@date
	

		IF (@@ERROR <> 0) GOTO QuitWithRollback
			
			
		insert into tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
			tran_type,company_id,part_tran_srl_num,created_date,CHEQUE_NO
			 ,RunningBalance, acct_type_code)
		Select @user,c.ACCT_NUM , dbo.[FunGetGLCode](c.ACCT_NUM),TRN_TYPE,@strRefNum+1 ,AMT,0,0,@date,
			'j','1',ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo, GETDATE(),'TDS'
			, dbo.[FNAGetRunningBalance](c.ACCT_NUM,AMT,TRN_TYPE),'COMM.PAY'
		from #_tzRemittanceTranHit2 c 
		where  ISNULL(AMT,0) <> 0
			
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
		Select @strRefNum+1  ,'Domestic Commission Paid For The TRN From: '+@dateFrom+' To: '+@dateTo ,'j','1',@date

		IF (@@ERROR <> 0) GOTO QuitWithRollback

			insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
			,part_tran_type,ref_num,tran_amt,usd_amt, usd_rate, tran_date,
			tran_type,company_id,part_tran_srl_num,created_date,CHEQUE_NO,RunningBalance)
		Select @user,c.ACCT_NUM , dbo.[FunGetGLCode](c.ACCT_NUM),
			TRN_TYPE,@strRefNum+2 ,AMT,0,0,@date,
			'j','1',ROW_NUMBER() OVER(ORDER BY TRN_TYPE desc) AS SrNo, GETDATE(),'TDS'
			, dbo.[FNAGetRunningBalance](c.ACCT_NUM,AMT,TRN_TYPE)
		from #_tzRemittanceTranHit4 c 
		where  ISNULL(AMT,0) <> 0
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],tran_type, company_id,tranDate )
		Select @strRefNum+2 ,'TDS on commission PAID Deducted @ 15 Percent For The TRN From: '+@dateFrom+' To: '+@dateTo ,'j','1',@date
	

		IF (@@ERROR <> 0) GOTO QuitWithRollback

		update tran_master set CHEQUE_NO='TDS' 
		from tran_master t , ac_master a 
		where t.acc_num=a.acct_num  and t.tran_date between @dateFrom and @dateTo +' 23:59'
		and t.CHEQUE_NO is null and (a.acct_rpt_code='21' or a.acct_rpt_code='22')
				
				
COMMIT TRANSACTION

	--SELECT 'PROCESS COMPLETED' AS REMARKS
	exec proc_errorHandler 0,'PROCESS COMPLETED',null
--########## Drop TEMP TABLE
	drop table #_tzRemittanceTranHit
	drop table #_tzTempSendAgentList

GOTO  EndSave

QuitWithRollback:
COMMIT TRANSACTION 


EndSave: 

end

END TRY
BEGIN CATCH
	IF @@ERROR <> 0
		ROLLBACK TRANSACTION
	exec proc_errorHandler 1,'Error In Application',null
END CATCH

GO
