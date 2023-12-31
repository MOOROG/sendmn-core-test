USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procGetDataFromIMESystem_LOCAL]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetDataFromIMESystem_LOCAL]
	@trn_type as char(1),
	@date varchar(20)=null,
	@user varchar(50)=null
AS
	SET NOCOUNT ON;

	DECLARE @sqlQuery VARCHAR(8000)
	DECLARE @finalQuery VARCHAR(8000)
	
    if @date is null or @date=''
    set @date=CAST(GETDATE() AS DATE)

    if @user is null 
    set @user = 'admin'

if @trn_type='a'
begin

	Exec proc_limitupdateEOd_job;

	EXEC PROC_BAL_MISMATCH;
	
	 SELECT 'PROCESS COMPLETED' as REMARKS
    RETURN;
    
END 



if @trn_type='s'
begin

    SELECT 'PROCESS COMPLETED' as REMARKS
    RETURN;

	
	-- ########## Clean the old data
	truncate table LOCAL_SEND_DATA_CONFIRM
	
	
	
	INSERT INTO LOCAL_SEND_DATA_CONFIRM(
			refno,agentid,district_code, SenderName,ReceiverName,
			paidAmt,paidCType,receiveAmt,receiveCType,SCharge,rBankID,rBankBranch,
			otherCharge,TransStatus,status,TotalRoundAmt,PaidDate,senderCommission,
			ReceiverCommission,receiveAgentId,confirmDate,ext_commission,bank_id,SEmpID
			,paidBy,paymentType,tranno
			)
	SELECT 
		refno,agentid,district_code, SenderName,ReceiverName,
		paidAmt,paidCType,receiveAmt,receiveCType,SCharge,rBankID,rBankBranch,
		otherCharge,TransStatus,status,TotalRoundAmt,PaidDate,senderCommission,
		ReceiverCommission,receiveAgentId,confirmDate,ext_commission,bank_id
		,SEmpID, paidBy,paymentType,tranno
	FROM AccountTransaction with(nolock)
	WHERE confirmDate between @date AND @date + ' 23:59:59'
	
	
	
	delete LOCAL_SEND_DATA_CONFIRM 
		from  LOCAL_SEND_DATA_CONFIRM p ,REMIT_TRN_LOCAL s
	where s.TRN_REF_NO=p.REFNO
	
	--update LOCAL_SEND_DATA_CONFIRM set [rBankID]=[bank_id]
	--where convert(varchar,confirmDate,102)=convert(varchar,cast(@date as datetime),102)

	
	-- ################### Insert send transaction
	INSERT INTO REMIT_TRN_LOCAL 
		 ([TRN_REF_NO] ,[S_AGENT] ,[SENDER_NAME] ,[RECEIVER_NAME] ,[S_AMT] ,[P_AMT] 
		 ,[ROUND_AMT] ,[TOTAL_SC] ,[OTHER_SC] ,[S_SC] ,[R_SC] ,[EXT_SC] ,[TRN_TYPE] ,[R_BANK] 
		 ,[R_BANK_NAME] ,[R_BRANCH] ,[R_AGENT] ,[TRN_STATUS] ,[PAY_STATUS] ,[TRN_DATE] ,[P_DATE] 
		 ,[CONFIRM_DATE],bank_id,SEmpID, paidBy,tranno)
	SELECT 
		[REFNO],[AGENTID],[SenderName],[ReceiverName],[paidAmt],[receiveAmt],
		[TotalroundAmt],[Scharge],[otherCharge],[senderCommission],[receiverCommission],
		[ext_commission], [paymentType],[receiveAgentID],
		[rBankName],[rBankBranch],case when isnull(a.bank_id,0)=0 then [rBankID] else a.bank_id end
		,[TransStatus],[status],[local_DOT],[paidDate],
		[confirmDate],bank_id,SEmpID, paidBy,tranno
	FROM LOCAL_SEND_DATA_CONFIRM a
	

	
	--#############  ALL Process completed
	Select 'PROCESS COMPLETED' as REMARKS
    --Exec JobHistoryRecord 'i','DATA IMPORTED','DOMESTIC','SEND',@user ,'',@user
	

     --EXEC PROC_UPDATE_SEND_PAID
	
end

if @trn_type='p'
begin

     --SELECT 'PROCESS COMPLETED' AS REMARKS
     --RETURN;

	-- Exec procGetDataFromIMESystem_LOCAL 'p','2012-11-28'

	-- ########## Clean the old data
	TRUNCATE TABLE LOCAL_PAID_DATA
	-- alter table LOCAL_PAID_DATA add paymentType varchar(20)

		
	--INSERT INTO LOCAL_PAID_DATA(
	--		refno,agentid,district_code, SenderName,ReceiverName,
	--		paidAmt,paidCType,receiveAmt,receiveCType,SCharge,rBankID,rBankBranch,
	--		otherCharge,TransStatus,status,TotalRoundAmt,PaidDate,senderCommission,
	--		ReceiverCommission,receiveAgentId,confirmDate,ext_commission,bank_id,SEmpID
	--		,paidBy,paymentType,tranno
	--		)
	--SELECT 
	--	refno,agentid,district_code, SenderName,ReceiverName,
	--	paidAmt,paidCType,receiveAmt,receiveCType,SCharge,rBankID,rBankBranch,
	--	otherCharge,TransStatus,status,TotalRoundAmt,PaidDate,senderCommission,
	--	ReceiverCommission,receiveAgentId,confirmDate,ext_commission,bank_id
	--	,SEmpID, paidBy,paymentType,tranno
	--FROM hremit.dbo.AccountTransaction with(nolock)
	--WHERE paidDate between @date AND @date + ' 23:59:59'
 --    and paymentType ='bank transfer'
	
	--
	UPDATE REMIT_TRN_LOCAL 
		SET P_DATE=paidDate,
			 R_SC=[receiverCommission],EXT_SC=ext_commission,
			 [R_BRANCH]=rBankBranch,
			 [R_AGENT]=case when ISNULL(p.bank_id,0) = 0 then rBankId else p.bank_id end,
			 [TRN_STATUS]=[TransStatus] 
		     ,[PAY_STATUS]=[status]
			,bank_id=p.bank_id
			,paidBy=p.paidBy
			,RECEIVER_NAME = p.ReceiverName
	from REMIT_TRN_LOCAL s, LOCAL_PAID_DATA p
	where s.TRN_REF_NO=p.REFNO
     and (P_DATE is null  OR PAY_STATUS = 'un-Paid')
     
	--
	DELETE LOCAL_PAID_DATA
	FROM  LOCAL_PAID_DATA p ,REMIT_TRN_LOCAL s
	WHERE s.TRN_REF_NO=p.REFNO

	
	-- ################### Insert send transaction
	INSERT INTO REMIT_TRN_LOCAL 
		 ([TRN_REF_NO] ,[S_AGENT] ,[SENDER_NAME] ,[RECEIVER_NAME] ,[S_AMT] ,[P_AMT] 
		 ,[ROUND_AMT] ,[TOTAL_SC] ,[OTHER_SC] ,[S_SC] ,[R_SC] ,[EXT_SC] ,[TRN_TYPE] ,[R_BANK] 
		 ,[R_BANK_NAME] ,[R_BRANCH] ,[R_AGENT] ,[TRN_STATUS] ,[PAY_STATUS] ,[TRN_DATE] ,[P_DATE] 
		 ,[CONFIRM_DATE],bank_id,SEmpID, paidBy,tranno)
	SELECT 
		[REFNO],[AGENTID],[SenderName],[ReceiverName],[paidAmt],[receiveAmt],
		[TotalroundAmt],[Scharge],[otherCharge],[senderCommission],[receiverCommission],
		[ext_commission], [paymentType],[receiveAgentID],
		[rBankName],[rBankBranch],[rBankID],[TransStatus],[status],[local_DOT],[paidDate],
		[confirmDate],bank_id,SEmpID, paidBy,tranno
	FROM LOCAL_PAID_DATA a

	--where 
	--	confirmDate not between @date  and  @date +' 23:59:59'
	--	and paidDate between @date  and  @date +' 23:59:59'
	
	update REMIT_TRN_LOCAL  
		set R_AGENT = t.bank_id
	from REMIT_TRN_LOCAL r, LOCAL_PAID_DATA t
	where r.TRN_REF_NO = t.refno 
	and isnull(t.bank_id,0) > 0
	and (F_STODAY_PTODAY IS Null and F_PTODAY_SYESTERDAY IS NULL)

	
	--#############  ALL Process completed
	Select 'PROCESS COMPLETED' as REMARKS
	--EXEC PROC_UPDATE_SEND_PAID


     --Exec JobHistoryRecord 'i','DATA IMPORTED','DOMESTIC','PAID',@user ,'',@user

end

if @trn_type='c'
begin

      SELECT 'PROCESS COMPLETED' AS REMARKS
      RETURN;

	--alter table LOCAL_CANCEL_DATA add ReceiverCommission money

	-- ########## Clean the old data
	truncate table LOCAL_CANCEL_DATA
	


		--insert into LOCAL_CANCEL_DATA(
		--					refno,CancelDate,DOT, ReceiverCommission
		--				)
						
		--SELECT
		--		refno,deldate,DOT, ReceiverCommission
		--		FROM hremit.dbo.AccountTransactionCancel with(nolock)
		--		WHERE deldate between @date and @date + ' 23:59:59'
				
	--#############  ALL Process completed
	update REMIT_TRN_LOCAL 
		set CANCEL_DATE=CancelDate, TRN_STATUS='Cancel'
		    ,R_SC = P.ReceiverCommission
	from REMIT_TRN_LOCAL s, LOCAL_CANCEL_DATA p
	where s.TRN_REF_NO=p.REFNO
	and (F_CODAY_SYESTERDAY IS Null and F_STODAY_CTODAY IS NULL)
          -- and R_SC =0

	--#############  ALL Process completed
	Select 'PROCESS COMPLETED' as REMARKS
	Exec JobHistoryRecord 'i','DATA IMPORTED','DOMESTIC','CANCEL',@user ,'',@user
	

end





GO
