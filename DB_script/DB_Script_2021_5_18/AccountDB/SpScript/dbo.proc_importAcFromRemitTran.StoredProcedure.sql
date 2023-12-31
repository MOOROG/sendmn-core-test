USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_importAcFromRemitTran]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_importAcFromRemitTran]
	 @flag			VARCHAR(20)
	,@date			VARCHAR(50)	= NULL
	,@fromDate		VARCHAR(50) = NULL
	,@toDate		VARCHAR(50)	= NULL
	,@returnMsg		CHAR(1)		= NULL
AS

SET NOCOUNT ON;

DECLARE @count INT

SET @returnMsg = ISNULL(@returnMsg, 'Y')

IF @date IS NULL AND @fromDate IS NULL AND @toDate IS NULL
BEGIN
	SET @date =  CONVERT(VARCHAR(20), GETDATE(), 101)
	
	IF CAST(GETDATE() AS TIME) BETWEEN '00:00:00' AND '08:00:00'
	BEGIN
		SET @fromDate = CONVERT(VARCHAR(20), GETDATE() - 1, 101)
	END
	ELSE
	BEGIN
		SET @fromDate = CONVERT(VARCHAR(20), GETDATE(), 101)
	END
	SET @toDate = CONVERT(VARCHAR(20), GETDATE(), 101)
END
ELSE IF @date IS NOT NULL
BEGIN
	SET @fromDate = @date
	SET @toDate = @date
END

IF @flag='s'
BEGIN
    SELECT 
		 TRN_REF_NO						= controlNo
		,S_AGENT						= sam.mapCodeInt
		,S_BRANCH						= sbm.mapCodeInt
		,P_AGENT						= pam.mapCodeInt
		,P_BRANCH						= pbm.mapCodeInt
		,S_CURR							= collCurr
		,S_AMT							= cAmt
		,TRN_TYPE						= CASE WHEN paymentMethod = 'Cash Payment' THEN 'Cash Pay'
											WHEN paymentMethod = 'Bank Deposit' THEN 'Bank Transfer'
											ELSE paymentMethod END
		,PAY_STATUS						= CASE WHEN payStatus IN ('Unpaid','Post') THEN 'Un-Paid' ELSE payStatus END
		,TRN_STATUS						= CASE WHEN tranStatus = 'Paid' THEN 'Payment' ELSE tranStatus END
		,SC_TOTAL						= serviceCharge  
		,SC_HO							= serviceCharge - ISNULL(sAgentComm, 0)
		,SC_S_AGENT						= ISNULL(sAgentComm, 0)
		,SC_P_AGENT						= ISNULL(pAgentComm, 0)
		,USD_AMT						= ROUND(cAmt/case when (ISNULL(rt.sCurrCostRate,0) - (ISNULL(sCurrHoMargin,0) * -1)) = 0 then 1 else (ISNULL(rt.sCurrCostRate,0) - (ISNULL(sCurrHoMargin,0) * -1)) end  ,4,1)
		,P_CURR							= payoutCurr
		,NPR_USD_RATE					= pCurrCostRate - ISNULL(pCurrHoMargin, 0)
		,EX_USD							= rt.sCurrCostRate - (ISNULL(rt.sCurrHoMargin, 0) * -1)
		,EX_FLC							= rt.customerRate
		,P_AMT							= FLOOR(pAmt)
		,P_AMT_ACT						= rt.pAmt
		,TRN_DATE						= rt.approvedDate
		,PAID_DATE						= rt.paidDate
		,CANCEL_DATE					= rt.cancelApprovedDate
		,SENDER_NAME					= senderName
		,RECEIVER_NAME					= receiverName
		,AGENT_SETTLEMENT_RATE			= rt.agentCrossSettRate
		,AGENT_EX_GAIN					= rt.agentFxGain
		,AGENT_RECEIVERSCOMMISSION		= rt.pSuperAgentComm
		,SETTLEMENT_RATE				= rt.pCurrCostRate
		,TRANNO							= rt.id
		,TRANIdNew						= rt.id
		,S_COUNTRY						= sCountry
		,PAIDBY							= rt.paidBy
		,SenderPhoneno					= sen.mobile
		,CustomerId						= rt.accountNo
		,SCURRCOSTRATE					= rt.SCURRCOSTRATE
	INTO #TEMP_SENDTXN
	FROM SendMnPro_Remit.dbo.remitTran rt WITH(READPAST)
	INNER JOIN SendMnPro_Remit.dbo.tranSenders sen WITH(READPAST) ON rt.id = sen.tranId
	INNER JOIN SendMnPro_Remit.dbo.agentMaster sam WITH(NOLOCK) ON rt.sAgent = sam.agentId
	INNER JOIN SendMnPro_Remit.dbo.agentMaster sbm WITH(NOLOCK) ON rt.sBranch = sbm.agentId
	LEFT JOIN SendMnPro_Remit.dbo.agentMaster pam WITH(NOLOCK) ON rt.pAgent = pam.agentId
	LEFT JOIN SendMnPro_Remit.dbo.agentMaster pbm WITH(NOLOCK) ON rt.pBranch = pbm.agentId
	LEFT JOIN REMIT_TRN_MASTER ac WITH (NOLOCK) ON rt.controlNo = ac.TRN_REF_NO 
	WHERE ac.TRN_REF_NO IS NULL 
	AND rt.approvedDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
	AND rt.tranType = 'I'
	
	DELETE T
	FROM #TEMP_SENDTXN T, REMIT_TRN_MASTER  M WITH(NOLOCK)
	WHERE T.TRN_REF_NO = M.TRN_REF_NO
	
	INSERT INTO REMIT_TRN_MASTER 
    (  
		 TRN_REF_NO
		,S_AGENT
		,S_BRANCH,P_AGENT,P_BRANCH
		,S_CURR
		,S_AMT
		,TRN_TYPE
		,PAY_STATUS
		,TRN_STATUS
		,SC_TOTAL  
		,SC_HO
		,SC_S_AGENT
		,SC_P_AGENT
		,USD_AMT
		,P_CURR
		,NPR_USD_RATE  
		,EX_USD
		,EX_FLC
		,P_AMT
		,P_AMT_ACT
		,TRN_DATE
		,PAID_DATE
		,CANCEL_DATE
		,SENDER_NAME,RECEIVER_NAME
		,AGENT_SETTLEMENT_RATE
		,AGENT_EX_GAIN
		,AGENT_RECEIVERSCOMMISSION
		,SETTLEMENT_RATE
		,TRANNO
		,TranIdNew
		,S_COUNTRY
		,PAIDBY
		,SenderPhoneno
		,CustomerId
		,SCURRCOSTRATE
    )  

	SELECT 
		 TRN_REF_NO
		,S_AGENT
		,S_BRANCH,P_AGENT,P_BRANCH
		,S_CURR
		,S_AMT
		,TRN_TYPE
		,PAY_STATUS
		,TRN_STATUS
		,SC_TOTAL  
		,SC_HO
		,SC_S_AGENT
		,SC_P_AGENT
		,USD_AMT
		,P_CURR
		,NPR_USD_RATE  
		,EX_USD
		,EX_FLC
		,P_AMT
		,P_AMT_ACT
		,TRN_DATE
		,PAID_DATE
		,CANCEL_DATE
		,SENDER_NAME,RECEIVER_NAME
		,AGENT_SETTLEMENT_RATE
		,AGENT_EX_GAIN
		,AGENT_RECEIVERSCOMMISSION
		,SETTLEMENT_RATE
		,TRANNO
		,TRANIdNew
		,S_COUNTRY
		,PAIDBY
		,SenderPhoneno
		,CustomerId
		,SCURRCOSTRATE
	FROM #TEMP_SENDTXN WITH (NOLOCK)
	
	--------Samba comission update 
	------UPDATE REMIT_TRN_MASTER SET SC_HO = '1.87', SC_TOTAL = '1.87', SC_S_AGENT = '0' 
	------WHERE TRN_DATE BETWEEN @fromDate AND @toDate +' 23:59:59.998'
	------AND S_AGENT = '20300000'
	 
	--UK,RIYA update 
	UPDATE REMIT_TRN_MASTER SET SC_HO = '0', SC_TOTAL = '0', SC_S_AGENT = '0' 
	WHERE TRN_DATE BETWEEN @fromDate AND @toDate +' 23:59:59.998' 
	AND S_AGENT IN('12500000','33200000')

	--Money Gram Comission update 
	UPDATE REMIT_TRN_MASTER SET SC_HO = '0', SC_TOTAL = '0', SC_S_AGENT = '0', SC_P_AGENT = 0
	WHERE TRN_DATE BETWEEN @fromDate AND @toDate +' 23:59:59.998' 
	AND S_AGENT = '26400000'
 
	SELECT @count = COUNT('X') FROM #TEMP_SENDTXN
	
	IF @returnMsg = 'Y'
		SELECT 'IMPORT SUCCESS' MSG
	ELSE
		PRINT('IMPORT SUCCESS')
	PRINT('From Date : ' + @fromDate + ', To Date : ' + @toDate)
	PRINT ('No. of send import : ' + CAST(@count AS VARCHAR))
END
	
IF @flag = 'p'
BEGIN
	SELECT 
		 TRN_REF_NO						= controlNo
		,P_AGENT						= pam.mapCodeInt
		,P_BRANCH						= pbm.mapCodeInt
		,PAY_STATUS						= CASE payStatus WHEN 'Unpaid' THEN 'Un-Paid' ELSE payStatus END
		,TRN_STATUS						= CASE WHEN tranStatus = 'Paid' THEN 'Payment' ELSE tranStatus END
		,SC_P_AGENT						= ISNULL(pAgentComm, 0)
		,P_CURR							= payoutCurr
		,P_AMT							= pAmt
		,TRN_DATE						= rt.approvedDate
		,PAID_DATE						= rt.paidDate
		,SENDER_NAME					= senderName
		,RECEIVER_NAME					= receiverName
		,AGENT_SETTLEMENT_RATE			= rt.agentCrossSettRate
		,AGENT_RECEIVERSCOMMISSION		= rt.pSuperAgentComm
		,SETTLEMENT_RATE				= rt.pCurrCostRate
		,TRANNO							= rt.id
		,P_COUNTRY						= pCountry
		,paid_date_cost_rate			= rt.pDateCostRate
		,PAIDBY							= rt.paidBy
		,SCURRCOSTRATE					= rt.SCURRCOSTRATE
	INTO #TEMPPAID
	FROM SendMnPro_Remit.dbo.remitTran rt WITH(READPAST)
	INNER JOIN SendMnPro_Remit.dbo.agentMaster sam WITH(NOLOCK) ON rt.sAgent = sam.agentId
	INNER JOIN SendMnPro_Remit.dbo.agentMaster sbm WITH(NOLOCK) ON rt.sBranch = sbm.agentId
	LEFT JOIN  SendMnPro_Remit.dbo.agentMaster pam WITH(NOLOCK) ON rt.pAgent = pam.agentId
	LEFT JOIN  SendMnPro_Remit.dbo.agentMaster pbm WITH(NOLOCK) ON rt.pBranch = pbm.agentId
	LEFT JOIN REMIT_TRN_MASTER ac WITH (NOLOCK) ON rt.controlNo = ac.TRN_REF_NO 
	WHERE ac.PAID_DATE IS NULL 
	AND RT.paiddate BETWEEN @fromDate AND @toDate + ' 23:59:59'
	AND rt.tranType = 'I'

	UPDATE rtm SET 
		   PAID_DATE			= p.PAID_DATE
		  ,PAY_STATUS			= p.PAY_STATUS
		  ,P_AGENT				= P.P_AGENT
		  ,P_BRANCH				= P.P_BRANCH
		  ,SC_P_AGENT			= p.SC_P_AGENT 
		  ,PAIDBY				= p.paidBy
		  ,P_AMT_ACT			= p.P_AMT
		  ,SCURRCOSTRATE		= p.SCURRCOSTRATE
		  --,AGENT_RECEIVERSCOMMISSION= p.AGENT_RECEIVERSCOMMISSION

	FROM REMIT_TRN_MASTER rtm 
	INNER JOIN #TEMPPAID p ON rtm.TRN_REF_NO = p.TRN_REF_NO  
	AND rtm.PAID_DATE IS NULL
	
	SELECT @count = COUNT('X') FROM #TEMPPAID
	
	IF @returnMsg = 'Y'
		SELECT 'IMPORT SUCCESS' MSG
	ELSE
		PRINT('IMPORT SUCCESS')
	PRINT('From Date : ' + @fromDate + ', To Date : ' + @toDate)
	PRINT ('No. of paid import : ' + CAST(@count AS VARCHAR))
END	


IF @flag = 'c'
BEGIN
	SELECT 
		 TRN_REF_NO				= controlNo
		,CANCEL_DATE			= rt.cancelApprovedDate
		,CANCEL_BY				= rt.cancelApprovedBy
		,SCURRCOSTRATE			= rt.SCURRCOSTRATE
		,P_AMT_ACT				= rt.pAmt
		,AGENT_RECEIVERSCOMMISSION	= rt.pSuperAgentComm
	INTO #TEMPCANCEL
	FROM SendMnPro_Remit.dbo.remitTran rt WITH(READPAST)
	LEFT JOIN REMIT_TRN_MASTER ac WITH (NOLOCK) ON rt.controlNo = ac.TRN_REF_NO 
	where ac.CANCEL_DATE IS NULL
	AND RT.cancelapproveddate BETWEEN @date AND @date +' 23:59:59'
	AND rt.tranType = 'I'
	 

	UPDATE S SET 
		 CANCEL_DATE			= p.CANCEL_DATE
		,TRN_STATUS				= 'Cancel'
		,P_AMT_ACT				= p.P_AMT_ACT
		,SCURRCOSTRATE			= p.SCURRCOSTRATE
		--,AGENT_RECEIVERSCOMMISSION= p.AGENT_RECEIVERSCOMMISSION

    FROM REMIT_TRN_MASTER s, #TEMPCANCEL p
   	WHERE S.TRN_REF_NO = p.TRN_REF_NO   
	AND S.CANCEL_DATE IS NULL

	SELECT @count = COUNT('X') FROM #TEMPCANCEL
	
	IF @returnMsg = 'Y'
		SELECT 'IMPORT SUCCESS' MSG
	ELSE
		PRINT('IMPORT SUCCESS')
	PRINT('From Date : ' + @fromDate + ', To Date : ' + @toDate)
	PRINT ('No. of cancel import : ' + CAST(@count AS VARCHAR))
END 



GO
