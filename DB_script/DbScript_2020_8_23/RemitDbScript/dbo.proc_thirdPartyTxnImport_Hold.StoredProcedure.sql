USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_thirdPartyTxnImport_Hold]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC [proc_thirdPartyTxnImport_Hold]
	
*/

CREATE procEDURE [dbo].[proc_thirdPartyTxnImport_Hold]
AS 

return;


SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN



    IF OBJECT_ID('tempdb..#tempTran') IS NOT NULL
	DROP TABLE #tempTran


	BEGIN TRANSACTION

		
		DELETE FROM [ThirdPaymentRemitTran] 						
		FROM [ThirdPaymentRemitTran] T
		INNER JOIN remitTran rt WITH (NOLOCK) ON rt.controlNo = dbo.FNAEncryptString(T.TRN_REF_NO)
		
		
		DELETE FROM [ThirdPaymentRemitTran] 						
		FROM [ThirdPaymentRemitTran] T
		INNER JOIN remitTranTemp rt WITH (NOLOCK) ON rt.controlNo = dbo.FNAEncryptString(T.TRN_REF_NO)
		

		SELECT dbo.FNAEncryptString(TRN_REF_NO) as controlNoEncrypted,* INTO #tempTran 
		FROM [ThirdPaymentRemitTran] WITH(NOLOCK) 
		WHERE TRN_TYPE IN ('Cash Pay', 'Cash Payment')

		--1. Main Table Insert------------------------------------------------------------------------------------------------------
		INSERT INTO remitTranTemp(
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
			,createdDate,createdDateLocal,createdBy
			,paidDate,paidDateLocal,paidBy
			,tranType			
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
			,REL_WITH_SEN,'Hold','Unpaid'
			,TRN_DATE,TRN_DATE,'I:' + APPROVE_BY
			,PAID_DATE,PAID_DATE,PAIDBY
			,'I'
		FROM #tempTran trn
		LEFT JOIN agentMaster sb WITH(NOLOCK) ON trn.S_BRANCH = sb.mapCodeInt
		LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.S_AGENT = sa.mapCodeInt
		LEFT JOIN agentMaster pb WITH(NOLOCK) ON trn.P_BRANCH = pb.mapCodeInt AND (pb.agentType = 2904 OR pb.actAsBranch = 'Y')
		LEFT JOIN agentMaster pa WITH(NOLOCK) ON pa.agentId = pb.parentId AND pa.agentType = 2903

		
		--2. Sender Information---------------------------------------------------------------------------------------------------------
		INSERT INTO tranSendersTemp(
			 tranId,firstName,[address],mobile,idType,idNumber
		)
		SELECT
			 rt.id,SENDER_NAME,SENDER_ADDRESS,SENDER_PHONE,SENDER_ID_TYPE,SENDER_ID_NO
		FROM #tempTran trn
		INNER JOIN remitTranTemp rt WITH(NOLOCK) ON trn.controlNoEncrypted = rt.controlNo
		--End-------------------------------------------------------------------------------------------------------------------------------
		
		--3. Receiver Information------------------------------------------------------------------------------------------------------------------
		INSERT INTO tranReceiversTemp(
			 tranId,firstName,address,mobile,idType,idNumber,idType2,idNumber2
		)
		SELECT
			 rt.id,RECEIVER_NAME,RECEIVER_ADDRESS,RECEIVER_PHONE,RECEIVER_ID_TYPE,RECEIVER_ID_NO,RECEIVER_ID_TYPE,RECEIVER_ID_NO
		FROM #tempTran trn
		INNER JOIN remitTranTemp rt WITH(NOLOCK) ON trn.controlNoEncrypted = rt.controlNo
		--End--------------------------------------------------------------------------------------------------------------------------------------
		
		--Delete migrated records------------------------------------------------------------------------------------------------------------------
		DELETE FROM [ThirdPaymentRemitTran]						
		FROM [ThirdPaymentRemitTran] ttrn
		INNER JOIN #tempTran tt ON ttrn.ROWID = tt.ROWID
		


COMMIT TRANSACTION


END




GO
