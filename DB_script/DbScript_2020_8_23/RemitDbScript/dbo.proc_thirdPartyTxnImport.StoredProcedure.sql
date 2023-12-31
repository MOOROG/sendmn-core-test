USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_thirdPartyTxnImport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_thirdPartyTxnImport]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[proc_thirdPartyTxnImport]

GO
*/
/*
	SELECT COUNT(*) FROM remitTran
	SELECT COUNT(*) FROM [ThirdPaymentRemitTran]
	SELECT * FROM [ThirdPaymentRemitTran]
	DELETE FROM remitTran WHERE controlNo IN (SELECT dbo.FNAEncryptString(TRN_REF_NO) FROM [ThirdPaymentRemitTran])
	SELECT * FROM remitTran WHERE controlNo IN (SELECT dbo.FNAEncryptString(TRN_REF_NO) FROM [ThirdPaymentRemitTran])
	SELECT * FROM #tempTran
	EXEC proc_thirdPartyTxnImport
*/

CREATE procEDURE [dbo].[proc_thirdPartyTxnImport]
AS 
SET NOCOUNT ON;

--return;


IF OBJECT_ID('tempdb..#tempTran') IS NOT NULL
	DROP TABLE #tempTran
	
	DELETE FROM [ThirdPaymentRemitTran] 						
	FROM [ThirdPaymentRemitTran] T
	INNER JOIN
	remitTran rt ON rt.controlNo = dbo.FNAEncryptString(T.TRN_REF_NO)
	
	/*	
     DELETE T 
     from [ThirdPaymentRemitTran] T, remitTran M 
     Where dbo.FNAEncryptString(T.TRN_REF_NO) = M.controlNo
    */

    SELECT dbo.FNAEncryptString(TRN_REF_NO) as controlNoEncrypted,* INTO #tempTran FROM [FastMoneyPro_remit].[dbo].[ThirdPaymentRemitTran] WITH(NOLOCK) WHERE TRN_TYPE IN ('Cash Pay', 'Cash Payment')

	--1. Main Table Insert------------------------------------------------------------------------------------------------------
	INSERT INTO remitTran(
		 controlNo,customerRate,serviceCharge,handlingFee
		,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency
		,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency
		,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,sCountry
		,pSuperAgent,pSuperAgentName
		,pAgent,pAgentName
		,pBranch,pBranchName,pCountry
		,pState,pDistrict,pLocation,paymentMethod
		,collCurr,tAmt,cAmt,pAmt,payoutCurr
		,relWithSender,tranStatus,payStatus
		,createdDate,createdDateLocal,createdBy,approvedBy,approvedDate,approvedDateLocal
		,paidDate,paidDateLocal,paidBy
		,tranType,oldSysTranNo			
	)	
	SELECT 
		 trn.controlNoEncrypted,NULL,0,0
		,SC_S_AGENT,S_CURR,0,S_CURR
		,pAgentComm = CASE WHEN SC_P_AGENT = 0 AND LEFT(TRN_REF_NO,2) <> 'MG' THEN (SELECT amount FROM dbo.FNAGetPayComm(NULL, NULL, NULL, 1002, 151, pb.agentLocation, pb.agentId, 'NPR', 1, S_AMT, P_AMT, NULL, NULL, NULL))
						ELSE SC_P_AGENT END
		,'NPR',0,'NPR'
		,4641,'International Agents',sa.agentId,sa.agentName,sb.agentId,sb.agentName,S_COUNTRY
		,1002,'International Money Express (IME) Pvt. Ltd'
		,ISNULL(pa.agentId, pb.agentId),ISNULL(pa.agentName, pb.agentName)
		,pb.agentId,pb.agentName,'Nepal'
		,pb.agentState,pb.agentDistrict,pb.agentLocation,'Cash Payment'
		,S_CURR,FLOOR(S_AMT),FLOOR(S_AMT),FLOOR(P_AMT),'NPR'
		,REL_WITH_SEN,'Paid','Paid'
		,TRN_DATE,TRN_DATE,'I:' + APPROVE_BY,'I:' + APPROVE_BY,TRN_DATE,TRN_DATE
		,PAID_DATE,PAID_DATE,PAIDBY
		,'I',ROWID
	FROM #tempTran trn
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON trn.S_BRANCH = sb.mapCodeInt
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.S_AGENT = sa.mapCodeInt
	--INNER JOIN agentMaster sa WITH(NOLOCK) ON sa.agentId = sb.parentId
	LEFT JOIN agentMaster pb WITH(NOLOCK) ON trn.P_BRANCH = pb.mapCodeInt AND (pb.agentType = 2904 OR pb.actAsBranch = 'Y')
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON pa.agentId = pb.parentId AND pa.agentType = 2903
	--LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.P_AGENT = pa.mapCodeInt
	
	--2. Sender Information---------------------------------------------------------------------------------------------------------
	INSERT INTO tranSenders(
		 tranId,firstName,[address],mobile,idType,idNumber
	)
	SELECT
		 rt.id,SENDER_NAME,SENDER_ADDRESS,SENDER_PHONE,SENDER_ID_TYPE,SENDER_ID_NO
	FROM #tempTran trn
	INNER JOIN remitTran rt WITH(NOLOCK) ON trn.controlNoEncrypted = rt.controlNo
	--End-------------------------------------------------------------------------------------------------------------------------------
	
	--3. Receiver Information------------------------------------------------------------------------------------------------------------------
	INSERT INTO tranReceivers(
		 tranId,firstName,address,mobile,idType,idNumber,idType2,idNumber2
	)
	SELECT
		 rt.id,RECEIVER_NAME,RECEIVER_ADDRESS,RECEIVER_PHONE,RECEIVER_ID_TYPE,RECEIVER_ID_NO,RECEIVER_ID_TYPE,RECEIVER_ID_NO
	FROM #tempTran trn
	INNER JOIN remitTran rt WITH(NOLOCK) ON trn.controlNoEncrypted = rt.controlNo
	--End--------------------------------------------------------------------------------------------------------------------------------------
	
	--Delete migrated records------------------------------------------------------------------------------------------------------------------
	DELETE FROM [ThirdPaymentRemitTran]						
	FROM [ThirdPaymentRemitTran] ttrn
	INNER JOIN #tempTran tt ON ttrn.ROWID = tt.ROWID
	





GO
