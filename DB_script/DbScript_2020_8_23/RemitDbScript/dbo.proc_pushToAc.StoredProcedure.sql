ALTER  PROC [dbo].[proc_pushToAc]
	@flag varchar(1),
	@controlNoEncrypted VARCHAR(20)
	 
AS
SET NOCOUNT ON
SET XACT_ABORT ON

IF @flag = 'i'
BEGIN
	INSERT INTO SendMnPro_Account.dbo.[REMIT_TRN_MASTER] (
		  [TRN_REF_NO],[S_AGENT],[S_BRANCH],[P_AGENT],[P_BRANCH],[S_CURR],[S_AMT],[TRN_TYPE],[SC_TOTAL]
		  ,[SC_HO],[SC_S_AGENT],[SC_P_AGENT],[EX_USD],[USD_AMT],[P_CURR],NPR_USD_RATE,
		  [EX_FLC],[P_AMT],[TRN_DATE],SENDER_NAME,RECEIVER_NAME,CANCEL_DATE,PAID_DATE
		  ,PAY_STATUS,TRN_STATUS, agent_ex_gain,agent_receiverSCommission,agent_settlement_rate,SETTLEMENT_RATE
		  ,SenderPhoneno,CustomerId, tranno, S_COUNTRY,paidBy, TranIdNew,APPROVE_BY)

	SELECT LEFT(REFNO, 20)
			  ,AGENTID 
			  ,BRANCH_CODE
			  ,receiveAgentid
			  ,CAST(rbankid AS VARCHAR) 
			  ,paidctype
			  ,paidamt
			  ,paymentType
			  ,Scharge
			  ,Scharge-ISNULL(sendercommission,0)
			  ,sendercommission
			  ,receiverCommission
			  ,exchangerate
			  ,dollar_amt
			  ,'NPR'
			  ,ho_dollar_rate
			  ,today_dollar_rate
			  ,ROUND(TotalroundAmt,0,1)
			  ,confirmDate
			  ,SenderName
			  ,ReceiverName
			  ,CANCEL_DATE
			  ,paiddate
			  ,status
			  ,transstatus
			  ,agent_ex_gain
			  ,agent_receiverSCommission
			  ,agent_settlement_rate
			  ,payout_settle_usd
			  ,SenderPhoneno
			  ,CustomerId
			  ,tranno
			  ,SenderCountry 
			  ,paidBy
			  ,tranno
			  ,approvedBy
	FROM 
	(
		SELECT 
			 REFNO = controlNo
			,AGENTID = sam.agentId
			,BRANCH_CODE = sbm.agentId
			,dot = rt.createdDateLocal
			,paidamt = cAmt
			,paidctype = collCurr
			,receiveamt = pAmt
			,receivectype = payoutCurr
			,exchangerate = ISNULL(rt.sCurrCostRate,0) - (ISNULL(rt.sCurrHoMargin,0) * -1) 
			,today_dollar_rate = customerRate
			,dollar_amt = ROUND(cAmt/case when (ISNULL(sCurrCostRate,0) - (ISNULL(sCurrHoMargin,0) * -1)) = 0 then 1 else (ISNULL(sCurrCostRate,0) - (ISNULL(sCurrHoMargin,0) * -1)) end  ,4,1)
			,Scharge = serviceCharge
			,paymentType = 
					CASE WHEN paymentMethod ='Cash Payment' THEN 'Cash Pay' 
					WHEN paymentMethod='Bank Deposit' THEN 'Bank Transfer' 
					WHEN paymentMethod='FOREIGN EMP. BOND' THEN 'FOREIGN EMP. BOND'					
					END
			,rbankid = pbm.agentId
			,rbankname = CASE WHEN paymentmethod = 'Bank Deposit' THEN rt.pBankName ELSE pAgentName end
			,rbankbranch = CASE WHEN paymentmethod = 'Bank Deposit' THEN rt.pBankBranchName ELSE pBranchName end
			,othercharge = 0 
			,transstatus = CASE WHEN payStatus = 'Paid' THEN 'Payment' ELSE tranStatus END 
			,status = CASE WHEN payStatus = 'Unpaid' THEN 'Un-paid' ELSE payStatus END
			,TotalroundAmt = pAmt
			,sendercommission = sAgentComm
			,receiverCommission = pAgentComm
			,receiveAgentid = pam.agentId
			,confirmDate = rt.approvedDate
			,local_Dot = rt.createdDate 
			,agent_settlement_rate = agentCrossSettRate
			,agent_ex_gain = agentFxGain
			,ho_dollar_rate = pCurrCostRate - pCurrHoMargin
			,agent_receiverSCommission = pAgentComm
			,SenderName = senderName
			,ReceiverName = receiverName
			,paiddate = paidDate
			,paidBy = rt.paidBy
			,cancel_date = cancelApproveddate
			,payout_settle_usd = pCurrCostRate
			,SenderPhoneno = sen.homePhone
			,CustomerId = rt.accountNo
			,tranno = rt.id
			,SenderCountry = sCountry
			,rt.approvedBy
		FROM remitTran rt WITH(NOLOCK)
		LEFT JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranid
		LEFT JOIN agentMaster sam WITH(NOLOCK) ON rt.sAgent = sam.agentId
		LEFT JOIN agentMaster sbm WITH(NOLOCK) ON rt.sBranch = sbm.agentId
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON rt.pAgent = pam.agentId
		LEFT JOIN agentMaster pbm WITH(NOLOCK) ON rt.pBranch = pbm.agentId
		WHERE controlNo = @controlNoEncrypted
	)x

END






GO
