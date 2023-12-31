USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procGetDataFromIMESystem]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetDataFromIMESystem]
	@trn_type as char(1),
	@date varchar(20)=null,
	@user varchar(50)=null
AS

	SET NOCOUNT ON;

	DECLARE @sqlQuery VARCHAR(8000), @date2 varchar(20)
	DECLARE @finalQuery VARCHAR(8000)
    DECLARE @maxTranno bigint, @maxPaidDate varchar(200), @maxCancelDate varchar(200)


     --select dateadd(mi,isNUll(480,345),getutcdate())

 --    set @date2 = @date +' 23:59:59'

	--if @date is null or @date=''
	--begin
	--   	set @date=cast(GETDATE() as date)
	--	set @date2  = DATEADD(S,-45,(dateadd(mi,isNUll(480,345),getutcdate())))
 --    end

    --print @date2

if @trn_type='s'
begin


	EXEC proc_importAcFromRemitTran @flag = 's', @date=@date

	RETURN;

end

---- ########## Clean the old data
--truncate table [CONFIRM_FROM_IMESYSTEM]


--INSERT INTO CONFIRM_FROM_IMESYSTEM
--(
--			REFNO,AGENTID,BRANCH_CODE,dot,paidamt,paidctype,receiveamt,
--			receivectype,exchangerate,today_dollar_rate,dollar_amt,Scharge,
--			paymentType,rbankid,rbankname,rbankbranch,othercharge,
--			transstatus,status,TotalroundAmt,sendercommission,receiverCommission,receiveAgentid,
--			confirmDate,local_Dot,agent_settlement_rate,agent_ex_gain,ho_dollar_rate,
--			agent_receiverSCommission, SenderName,ReceiverName,paiddate,cancel_date
--			,payout_settle_usd,SenderPhoneno,CustomerId, tranno,SenderCountry
--)
--SELECT 
--			REFNO,AGENTID,BRANCH_CODE,dot,paidamt,paidctype,receiveamt,
--			receivectype,exchangerate,today_dollar_rate,dollar_amt,Scharge,
--			paymentType,rbankid,rbankname,rbankbranch,othercharge,
--			transstatus,status,TotalroundAmt,sendercommission,receiverCommission,receiveAgentid,
--			confirmDate,local_Dot,agent_settlement_rate,agent_ex_gain,ho_dollar_rate,
--			agent_receiverSCommission, SenderName,ReceiverName,paiddate
--			,cancel_date,payout_settle_usd,SenderPhoneno,rBankACNo,tranno, SenderCountry
--FROM ime_plus_02.dbo.AccountTransaction with(nolock)
--WHERE confirmDate between @date and @date2
----AND refno='RJPJQPKMPMI'

--UPDATE CONFIRM_FROM_IMESYSTEM SET receiverCommission=0 WHERE AGENTID='26400000'
----print @finalQuery
----EXEC(@finalQuery)
----return;

--delete [CONFIRM_FROM_IMESYSTEM] 
--from  [CONFIRM_FROM_IMESYSTEM] p ,[REMIT_TRN_MASTER] s
--where s.TRN_REF_NO= left(p.REFNO,20) 


---- ######### Insert form TEMP TABLE Daywise Summary
--INSERT INTO [REMIT_TRN_MASTER] (
--	  [TRN_REF_NO],[S_AGENT],[S_BRANCH],[P_AGENT],[P_BRANCH],[S_CURR],[S_AMT],[TRN_TYPE],[SC_TOTAL]
--      ,[SC_HO],[SC_S_AGENT],[SC_P_AGENT],[EX_USD],[USD_AMT],[P_CURR],NPR_USD_RATE,
--      [EX_FLC],[P_AMT],[TRN_DATE],SENDER_NAME,RECEIVER_NAME,CANCEL_DATE,PAID_DATE
--      ,PAY_STATUS,TRN_STATUS, agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,SETTLEMENT_RATE
--      ,SenderPhoneno,CustomerId, tranno, S_COUNTRY)

--SELECT 
--		  left([REFNO],20),[AGENTID] ,[BRANCH_CODE],
--		  [receiveAgentid],cast([rbankid] as varchar) ,[paidctype],
--		  [paidamt],paymentType,[Scharge],
--		  [Scharge]-Isnull(sendercommission,0),[sendercommission],
--		  case when [AGENTID]= '26400000' then 0 else receiverCommission end,
--		  [exchangerate],[dollar_amt]
--		  ,'NPR',ho_dollar_rate,
--		  [today_dollar_rate],round([TotalroundAmt],0,1),[confirmDate],SenderName,ReceiverName,CANCEL_DATE,paiddate
--		  ,status,transstatus,agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,payout_settle_usd
--		  ,SenderPhoneno,CustomerId, tranno, SenderCountry
--FROM [CONFIRM_FROM_IMESYSTEM]

----convert(varchar,confirmDate,102)=convert(varchar,cast(@date as datetime),102)
----and TRAN_ID in (SELECT min(TRAN_ID) FROM [CONFIRM_FROM_IMESYSTEM] group by [REFNO])
	

----Samba comission update	
--update REMIT_TRN_MASTER set SC_HO='1.87', SC_TOTAL='1.87', SC_S_AGENT='0' 
--where TRN_DATE  between @date  and  @date +' 23:59:59.998'
--and S_AGENT='20300000'
 
----UK,RIYA update	
--update REMIT_TRN_MASTER set SC_HO='0', SC_TOTAL='0', SC_S_AGENT='0' 
--where TRN_DATE  between @date  and  @date +' 23:59:59.998' 
-- AND  S_AGENT IN('12500000','33200000')
 
 
-- --Money Gram Comission update	
--update REMIT_TRN_MASTER set SC_HO='0', SC_TOTAL='0', SC_S_AGENT='0' ,SC_P_AGENT=0
--where TRN_DATE  between @date  and  @date +' 23:59:59.998' 
-- AND  S_AGENT ='26400000' 
		
----Japan tran type update	
--UPDATE REMIT_TRN_MASTER   SET TRN_TYPE='Cash Pay'
--WHERE TRN_DATE  between @date  and  @date +' 23:59:59.998' 
--AND TRN_TYPE ='Discount Cash Payment'
--AND S_AGENT='33300135'

--UPDATE REMIT_TRN_MASTER   SET TRN_TYPE='Bank Transfer'
--WHERE TRN_DATE  between @date  and  @date +' 23:59:59.998'  
--AND TRN_TYPE ='Discount Account Deposit'
--AND S_AGENT='33300135'

--Select 'PROCESS COMPLETED' as REMARKS
--Exec JobHistoryRecord 'i','DATA IMPORTED','INTERNATIONAL','SEND',@user ,'',@user


if @trn_type='p'
begin

	EXEC proc_importAcFromRemitTran @flag = 'p' , @date=@date

	return;
	
end
	
 --    DECLARE @FromDate DATETIME, @toDate DATETIME
 --    if @date is null or @date=''  
 --    begin
	--   SET @FromDate = DATEADD(MI,-10, GETDATE())
	--   SET @toDate = DATEADD(MI,-1, GETDATE())
	--   --SELECT @FromDate, @toDate, GETDATE()
 --    end
 --    else
 --    begin
	--   SET @FromDate = @date
	--   SET @toDate = @date +' 23:59'
 --    end
	
	---- ########## Clean the old data
	--TRUNCATE TABLE PAID_FROM_IMESYSTEM
	
	---- ######### GET DATA FROM IME SYSTEM USING LINKED SERVER
 --    --alter table CONFIRM_FROM_IMESYSTEM add SenderCountry varchar(200)

		
 --     INSERT INTO PAID_FROM_IMESYSTEM
	--   (
	--			REFNO,AGENTID,BRANCH_CODE,dot,paidamt,paidctype,receiveamt,
	--			receivectype,exchangerate,today_dollar_rate,dollar_amt,Scharge,
	--			paymentType,rbankid,rbankname,rbankbranch,othercharge,
	--			transstatus,status,TotalroundAmt,sendercommission,receiverCommission,receiveAgentid,
	--			confirmDate,local_Dot,agent_settlement_rate,agent_ex_gain,ho_dollar_rate,
	--			agent_receiverSCommission, SenderName,ReceiverName,paiddate,cancel_date
	--			,payout_settle_usd,SenderPhoneno,CustomerId, tranno, paidBy,SenderCountry
	--   )
	-- SELECT 
	--		REFNO,AGENTID,BRANCH_CODE,dot,paidamt,paidctype,receiveamt,
	--		receivectype,exchangerate,today_dollar_rate,dollar_amt,Scharge,
	--		paymentType,rbankid,rbankname,rbankbranch,othercharge,
	--		transstatus,status,TotalroundAmt,sendercommission,receiverCommission,receiveAgentid,
	--		confirmDate,local_Dot,agent_settlement_rate,agent_ex_gain,ho_dollar_rate,
	--		agent_receiverSCommission, SenderName,ReceiverName,paiddate
	--		,cancel_date,payout_settle_usd,SenderPhoneno,rBankACNo,tranno, paidBy, SenderCountry
	--FROM ime_plus_02.dbo.moneySend with(nolock)
	--WHERE PODDate between @FromDate and @toDate

	--UPDATE PAID_FROM_IMESYSTEM SET receiverCommission=0 WHERE AGENTID='26400000'
	
     
	---- ######### UPDATE BACK DATE PAID DATA
		
	--UPDATE REMIT_TRN_MASTER 
	--SET 
	--		 PAID_DATE=p.paiddate,
	--		 PAY_STATUS=p.[status],
	--		 P_AGENT=receiveAgentid, 
	--		 P_BRANCH=rbankid,
	--		 RECEIVER_NAME=p.ReceiverName
	--		,SC_P_AGENT=CASE WHEN [S_AGENT]= '26400000' THEN 0 ELSE receiverCommission END
	--		,paidBy=p.paidBy
	--FROM REMIT_TRN_MASTER s, PAID_FROM_IMESYSTEM p
	--WHERE s.TRN_REF_NO=left(p.REFNO,20)
	--	AND (PAY_STATUS = 'Un-paid' OR PAID_DATE is null)

	----
	--delete PAID_FROM_IMESYSTEM 
	--from  PAID_FROM_IMESYSTEM p ,[REMIT_TRN_MASTER] s
	--where s.TRN_REF_NO=left(p.REFNO,20)

	---- 
	--INSERT INTO [REMIT_TRN_MASTER] (
	--	  [TRN_REF_NO],[S_AGENT],[S_BRANCH],[P_AGENT],[P_BRANCH],[S_CURR],[S_AMT],[TRN_TYPE],[SC_TOTAL]
	--	  ,[SC_HO],[SC_S_AGENT],[SC_P_AGENT],[EX_USD],[USD_AMT],[P_CURR],NPR_USD_RATE,
	--	  [EX_FLC],[P_AMT],[TRN_DATE], SENDER_NAME,RECEIVER_NAME,CANCEL_DATE,PAID_DATE
	--	  ,PAY_STATUS,TRN_STATUS,agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,SETTLEMENT_RATE
	--	  ,SenderPhoneno,CustomerId ,paidBy, approve_by,tranno, S_COUNTRY)
	--SELECT 
	--	[REFNO],[AGENTID],[BRANCH_CODE],[receiveAgentid],[rbankid],[paidctype],[paidamt],paymentType,[Scharge],
	--	[Scharge]-Isnull(sendercommission,0),[sendercommission],
	--	 CASE WHEN AGENTID= '26400000' THEN 0 ELSE receiverCommission END,[exchangerate],[dollar_amt]
	--	,'NPR',ho_dollar_rate,
	--	[today_dollar_rate],round([TotalroundAmt],0,1),[confirmDate],SenderName,ReceiverName,CANCEL_DATE,paiddate
	--	,status,transstatus,agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,payout_settle_usd
	--	,SenderPhoneno,CustomerId,paidBy, approve_by,tranno, SenderCountry
	--FROM PAID_FROM_IMESYSTEM with (nolock)
	

 --    --RIA comission update	
	------update REMIT_TRN_MASTER set SC_HO='0', SC_TOTAL='0', SC_S_AGENT='0' 
	------	where PAID_DATE  between @date  and  @date2
	------	and S_AGENT='33200000'
	
	--	--UK,RIYA  Comission update	
	--	update REMIT_TRN_MASTER set SC_HO='0', SC_TOTAL='0', SC_S_AGENT='0' 
	--	where PAID_DATE  between @date  and  @date +' 23:59:59.998' 
	--	 AND  S_AGENT IN('33200000','26400000')

	--	-- Money Gram Comission update	
	--	update REMIT_TRN_MASTER set SC_HO='0', SC_TOTAL='0', SC_S_AGENT='0',SC_P_AGENT=0 
	--	where PAID_DATE  between @date  and  @date +' 23:59:59.998' 
	--	 AND  S_AGENT ='26400000'
		 

	----Samba comission update	
	--update REMIT_TRN_MASTER set SC_HO='1.87', SC_TOTAL='1.87', SC_S_AGENT='0' 
	--	where PAID_DATE  between @date  and  @date2
	--	and S_AGENT='20300000'
		
	----Japan tran type update	
	--UPDATE REMIT_TRN_MASTER   SET TRN_TYPE='Cash Pay'
	--WHERE PAID_DATE  between @date  and  @date +' 23:59:59.998'  
	--AND TRN_TYPE ='Discount Cash Payment'
	--AND S_AGENT='33300135'

	--UPDATE REMIT_TRN_MASTER   SET TRN_TYPE='Bank Transfer'
	--WHERE PAID_DATE  between @date  and  @date2
	--AND TRN_TYPE ='Discount Account Deposit'
	--AND S_AGENT='33300135'	


	---- SHOW MESSAGE
	--Select 'PROCESS COMPLETED' as REMARKS
    --EXEC JobHistoryRecord 'i','DATA IMPORTED','INTERNATIONAL','PAID',@user ,'',@user
	

	--EXEC PROC_UPDATE_SEND_PAID


if @trn_type='c'
begin
	
	
	EXEC proc_importAcFromRemitTran @flag = 'c', @date=@date

	return;
	
end	
	--Exec JobHistoryRecord 'i','DATA IMPORTED','INTERNATIONAL','CANCEL',@user ,'',@user
		
	---- ########## Clean the old data
	--truncate table CANCLETRN_FROM_IMESYSTEM
	
	--INSERT INTO CANCLETRN_FROM_IMESYSTEM(
	--								REFNO,AGENTID,BRANCH_CODE,dot,paidamt,paidctype,receiveamt,
	--								receivectype,exchangerate,today_dollar_rate,dollar_amt,Scharge,
	--								paymentType,rbankid,rbankname,rbankbranch,othercharge,
	--								transstatus,status,TotalroundAmt,sendercommission,receiverCommission,receiveAgentid,
	--								confirmDate,local_Dot,agent_settlement_rate,agent_ex_gain,ho_dollar_rate,
	--								agent_receiverSCommission, SenderName,ReceiverName,paiddate,cancel_date
	--								,payout_settle_usd,SenderPhoneno,CustomerId, tranno
	--							)
	-- SELECT 
	--						REFNO,AGENTID,BRANCH_CODE,dot,paidamt,paidctype,receiveamt,
	--						receivectype,exchangerate,today_dollar_rate,dollar_amt,Scharge,
	--						paymentType,rbankid,rbankname,rbankbranch,othercharge,
	--						transstatus,status,TotalroundAmt,sendercommission,receiverCommission,receiveAgentid,
	--						confirmDate,local_Dot,agent_settlement_rate,agent_ex_gain,ho_dollar_rate,
	--						agent_receiverSCommission, SenderName,ReceiverName,paiddate
	--						,cancel_date,payout_settle_usd,SenderPhoneno,CustomerId,tranno
	--FROM ime_plus_02.dbo.AccountTransaction with(nolock)
	--WHERE cancel_date between @date and @date2
	
 --   -- select * from CANCLETRN_FROM_IMESYSTEM	
	----
	--update REMIT_TRN_MASTER set 
	--   CANCEL_DATE=p.CANCEL_DATE
	--   ,P_AGENT=receiveAgentid, 
	--   P_BRANCH=rbankid, 
	--   SC_P_AGENT=receiverCommission,
	--   TRN_STATUS='Cancel'
	--from REMIT_TRN_MASTER s, CANCLETRN_FROM_IMESYSTEM p
	--where s.TRN_REF_NO=p.REFNO
	--      and F_CANCEL is null

	----and s.CANCEL_DATE is null

	----
	--DELETE CANCLETRN_FROM_IMESYSTEM 
	--FROM  CANCLETRN_FROM_IMESYSTEM p ,[REMIT_TRN_MASTER] s
	--WHERE s.TRN_REF_NO=p.REFNO
	

	---- ######### INSERT BACK DATE Cancel DATA
	--	INSERT INTO REMIT_TRN_MASTER (
	--	  [TRN_REF_NO],[S_AGENT],[S_BRANCH],[P_AGENT],[P_BRANCH],[S_CURR],[S_AMT],[TRN_TYPE],[SC_TOTAL]
	--	  ,[SC_HO],[SC_S_AGENT],[SC_P_AGENT],[EX_USD],[USD_AMT],[P_CURR],NPR_USD_RATE,
	--	  [EX_FLC],[P_AMT],[TRN_DATE], SENDER_NAME,RECEIVER_NAME,CANCEL_DATE,PAID_DATE
	--	   ,PAY_STATUS,TRN_STATUS,agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,SETTLEMENT_RATE
	--	  ,SenderPhoneno,CustomerId,paidBy, approve_by, tranno)
	--	SELECT
	--		 left( [REFNO],20),[AGENTID],[BRANCH_CODE],[receiveAgentid],[rbankid],[paidctype],[paidamt],paymentType,[Scharge],
	--		  [Scharge]-Isnull(sendercommission,0),[sendercommission],[receiverCommission],[exchangerate],[dollar_amt]
	--		  ,'NPR',ho_dollar_rate,
	--		  [today_dollar_rate],round([TotalroundAmt],0,1),[confirmDate],SenderName,ReceiverName,CANCEL_DATE,paiddate
	--		  ,status,transstatus,agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,payout_settle_usd
	--		  ,SenderPhoneno,CustomerId,paidBy, approve_by, tranno
	--	FROM CANCLETRN_FROM_IMESYSTEM with(nolock)
	--Select 'PROCESS COMPLETED' as REMARKS
	
--end

if @trn_type='n'
begin
	
	--EXEC IME_SWIFT_REMIT_V0.dbo.proc_sync_MoneySendtoRemitTran;
	--EXEC IME_SWIFT_REMIT_V0.dbo.proc_sync_payOnly;

	Select 'PROCESS COMPLETED' as REMARKS
	
end


if @trn_type='m'
begin

	Return;
	

    --   TRUNCATE TABLE TempErroneouslyPayment
 
	--INSERT INTO TempErroneouslyPayment(
	--						 ref_no, tranno, Amount, mode,agentCode, branch_code,approved_ts, companyName, sno, approved_by,invoice_no
	--)
	--SELECT 
	--	ref_no, tranno, Amount, mode,agentCode, branch_code,approved_ts, companyName, sno, approved_by,invoice_no
	--FROM ime_plus_02.dbo.ErroneouslyPayment with(nolock) 	
	--WHERE approved_ts between @date and @date +' 23:59:59.998'

 --    delete TempErroneouslyPayment 
	-- from  TempErroneouslyPayment t ,ErroneouslyPaymentNew m
	-- where t.invoice_no=m.EP_invoiceNo

	-- delete TempErroneouslyPayment 
	-- from  TempErroneouslyPayment t ,ErroneouslyPaymentNew m
	-- where t.invoice_no=m.PO_invoiceNo


	--   -- EP Insert 
	--   INSERT INTO ErroneouslyPaymentNew
	--   (
	--    ref_no,tranno,amount,EP_commission, PO_commission
	--   ,EP_AgentCode,EP_BranchCode
	--   ,EP_date,EP_User,EP_invoiceNo
	--   )
	--   SELECT 
	--		 ref_no, tranno, Amount,0,0
	--		 , agentCode, branch_code,approved_ts, approved_by,invoice_no
	--   FROM TempErroneouslyPayment with(nolock) 	
	--   WHERE mode ='dr' and companyName<>'Commission Account'
	--   -- EP Commission Update 
	--   update Er
	--	  set EP_commission = T.Amount 
	--   FROM ErroneouslyPaymentNew Er,
	--   (SELECT 
	--		 Amount, invoice_no
	--   FROM TempErroneouslyPayment 	
	--   WHERE mode ='dr' and companyName='Commission Account'
	--   )T
	--   WHERE Er.EP_invoiceNo = T.invoice_no


	--   -- PO Update 
	--   UPDATE Er
	--	  SET 
	--	   PO_AgentCode = agentCode
	--	  ,PO_BranchCode = branch_code
	--	  ,PO_date = approved_ts
	--	  ,PO_User = approved_by
	--	  ,PO_invoiceNo = invoice_no
	--   FROM ErroneouslyPaymentNew Er,
	--   (SELECT 
	--		  ref_no, tranno, Amount
	--		 , agentCode, branch_code,approved_ts, approved_by,invoice_no
	--   FROM TempErroneouslyPayment 	
	--   WHERE mode ='cr' and companyName<>'Commission Account'
	--   )T
	--   WHERE Er.ref_no = T.ref_no


	--   -- PO Commission Update 
	--   update Er
	--	  set PO_commission = T.Amount 
	--   FROM ErroneouslyPaymentNew Er,
	--   (SELECT 
	--		 Amount, invoice_no
	--   FROM TempErroneouslyPayment 	
	--   WHERE mode ='cr' and companyName='Commission Account'
	--   )T
	--   WHERE Er.PO_invoiceNo = T.invoice_no


	--   DELETE T	
	--   FROM TempErroneouslyPayment T, ErroneouslyPaymentNew Er
	--   WHERE Er.ref_no = T.ref_no

	--   -- EP Insert  
	--   INSERT INTO ErroneouslyPaymentNew
	--   (
	--    ref_no,tranno,amount,EP_commission, PO_commission
	--   ,PO_AgentCode,PO_BranchCode
	--   ,PO_date,PO_User,PO_invoiceNo
	--   )
	--   SELECT 
	--		 ref_no, tranno, Amount,0,0
	--		 , agentCode, branch_code,approved_ts, approved_by,invoice_no
	--   FROM TempErroneouslyPayment with(nolock) 	
	--   WHERE mode ='cr' and companyName<>'Commission Account'


	--   -- PO Commission Update 
	--   update Er
	--	  set PO_commission = T.Amount 
	--   FROM ErroneouslyPaymentNew Er,
	--   (SELECT 
	--		 Amount, invoice_no
	--   FROM TempErroneouslyPayment 	
	--   WHERE mode ='cr' and companyName='Commission Account'
	--   )T
	--   WHERE Er.PO_invoiceNo = T.invoice_no


	   Select 'PROCESS COMPLETED' as REMARKS

end




GO
