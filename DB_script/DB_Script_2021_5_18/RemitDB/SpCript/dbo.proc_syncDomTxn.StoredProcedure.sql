USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_syncDomTxn]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT TOP 1 paid_Date = paidDate + paidTime, * FROM hremit.dbo.AccountTransaction
--EXEC proc_syncDomTxn
CREATE procEDURE [dbo].[proc_syncDomTxn]
    @flag varchar(20)
AS

SET NOCOUNT ON

CREATE TABLE #txn (id INT IDENTITY(1,1),tranNo VARCHAR(50))

if @flag ='cashpayNewSync'
begin
	   --1. Transaction Generated by New System but Paid By Old System Synchronize-----------------------------------------------------------------------
	   IF OBJECT_ID('tempdb..#TEMP1') IS NOT NULL
		   DROP TABLE #TEMP1
	   IF OBJECT_ID('tempdb..#TEMP2') IS NOT NULL
		   DROP TABLE #TEMP2

	   SELECT dbo.decryptDblocal(refno) AS refno, Tranno, SEmpID INTO #TEMP1
	   FROM hremit.dbo.AccountTransaction WITH (NOLOCK)
	   WHERE paidDate BETWEEN '2012-12-01' AND '2012-12-16 23:59'

	   SELECT dbo.FNADecryptString(controlNo)AS controlNo INTO #TEMP2
	   FROM remitTran WITH (NOLOCK)
	   WHERE paidDate BETWEEN '2012-12-01' AND '2012-12-16 23:59'
	   AND ISNULL(sCountry,'') = 'Nepal'

	   /*
	   SELECT A.refno, A.Tranno, A.SEmpID
	   FROM #TEMP1 A
	   WHERE A.refno NOT IN (SELECT controlNo from #TEMP2)
	   */

		--TRUNCATE TABLE #txn
	   INSERT INTO #txn
	   SELECT A.Tranno FROM #TEMP1 A
	   WHERE A.refno NOT IN (SELECT controlNo from #TEMP2)
	   --SELECT * FROM @txn

	   IF NOT EXISTS(SELECT 'X' FROM #txn)
		   RETURN
	   UPDATE rt SET
		    rt.pBranch						= pb.agentId
		   ,rt.pBranchName					= pb.agentName
		   ,rt.pAgent						= ISNULL(pa.agentId, pb.agentId)
		   ,rt.pAgentName					= ISNULL(pa.agentName, pb.agentName)
		   ,rt.pSuperAgent					= 1002
		   ,rt.pSuperAgentName				= 'International Money Express (IME) Pvt. Ltd'
		   ,rt.pAgentComm					= acTrn.receiverCommission
		   ,rt.pAgentCommCurrency			= 'NPR'
		   ,rt.pSuperAgentComm				= 0
		   ,rt.pSuperAgentCommCurrency		= 'NPR'
		   ,rt.pCountry					= 'Nepal'
		   ,rt.pState						= pb.agentState
		   ,rt.pDistrict					= pb.agentDistrict
		   ,rt.tranStatus					= 'Paid'
		   ,rt.payStatus					= 'Paid'
		   ,rt.paidBy						= 'D:' + acTrn.paidBy
		   ,rt.paidDate					= acTrn.paidDate + acTrn.paidTime
		   ,rt.paidDateLocal				= acTrn.paidDate + acTrn.paidTime
	   FROM remitTran rt
	   INNER JOIN hremit.dbo.AccountTransaction acTrn ON dbo.FNADecryptString(rt.controlNo) = dbo.decryptDbLocal(acTrn.refno)
	   INNER JOIN #txn txn ON acTrn.Tranno = txn.tranNo
	   INNER JOIN agentMaster pb ON pb.mapCodeInt = acTrn.rBankID
	   LEFT JOIN agentMaster pa ON pb.parentId = pa.agentId AND pa.agentType = 2903

	   UPDATE rec SET
		    rec.idType2					= acTrn.rec_id_type
		   ,rec.idNumber2					= acTrn.rec_id_no
		   ,rec.mobile						= acTrn.ReceiverPhone
	   FROM tranReceivers rec
	   INNER JOIN remitTran rt ON rec.tranId = rt.id
	   INNER JOIN hremit.dbo.AccountTransaction acTrn ON dbo.FNADecryptString(rt.controlNo) = dbo.decryptDbLocal(acTrn.refno)
	   INNER JOIN #txn txn ON acTrn.Tranno = txn.tranNo

end 

if @flag ='cashpayOldImport'
begin

    --------------------------------------------------------------------------------------------------------------------------------------
    --2. Old System Unpaid and Paid Transaction Import------------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#TEMP3') IS NOT NULL
	    DROP TABLE #TEMP3
    IF OBJECT_ID('tempdb..#TEMP4') IS NOT NULL
	    DROP TABLE #TEMP4

    SELECT dbo.decryptDblocal(refno) AS refno, Tranno, SEmpID INTO #TEMP3
    FROM hremit.dbo.AccountTransaction WITH (NOLOCK)
    WHERE DOT BETWEEN '2010-12-18' AND '2012-12-18 23:59' and paymentType='Cash Pay' 
    and status='un-paid' and TransStatus ='Payment'

     DELETE T 
     from #TEMP3 T, remitTran M 
     Where (T.refno) = dbo.FNADecryptstring(M.controlNo)

    SELECT dbo.FNADecryptString(controlNo)AS controlNo INTO #TEMP4
    FROM remitTran WITH (NOLOCK)
    WHERE createdDate BETWEEN '2010-12-19' AND '2012-12-19 23:59'
    AND ISNULL(sCountry,'') = 'Nepal'

    /*

    SELECT A.refno, A.Tranno, A.SEmpID FROM #TEMP3 A 
    WHERE A.refno NOT IN (SELECT controlNo from #TEMP4)

    select * from #TEMP3

    */

    INSERT INTO #txn
    SELECT A.Tranno FROM #TEMP3 A

    -- select * from #txn


    IF NOT EXISTS(SELECT 'X' FROM #txn)
	    RETURN

    --1. Main Table Insert-----------------------------------------------------------------------------------------------------------------------
    --SELECT TOP 1 * FROM hremit.dbo.AccountTransaction WHERE rBankID IS NOT NULL ORDER BY Tranno DESC
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
		dbo.FNAEncryptString(dbo.decryptDbLocal(actrn.refNo)),NULL,actrn.SCharge,0
	    ,actrn.senderCommission,actrn.paidCType,0,actrn.paidCType
	    ,actrn.receiverCommission,'NPR',0,'NPR'
	    ,1002,'International Money Express (IME) Pvt. Ltd',ISNULL(sa.agentId, sb.agentId),ISNULL(sa.agentName, sb.agentName),sb.agentId,sb.agentName,actrn.SenderCountry
	    ,1002,'International Money Express (IME) Pvt. Ltd'
	    ,ISNULL(pa.agentId, pb.agentId),ISNULL(pa.agentName, pb.agentName)
	    ,pb.agentId,pb.agentName,'Nepal'
	    ,pb.agentState,pb.agentDistrict,receiveAgentID,CASE WHEN actrn.paymentType = 'Cash Pay' THEN 'Cash Payment' WHEN actrn.paymentType = 'Bank Transfer' THEN 'Bank Deposit' END
	    ,actrn.paidCType,actrn.paidAmt - actrn.SCharge,actrn.paidAmt,actrn.TotalRoundAmt,'NPR'
	    ,NULL,actrn.TransStatus,CASE WHEN actrn.[status] = 'Un-Paid' THEN 'Unpaid' ELSE actrn.[status] END
	    ,actrn.confirmDate,actrn.confirmDate,CASE WHEN LEFT(actrn.sEmpId,2)='S:' THEN actrn.SEmpID ELSE 'D:' + actrn.SEmpID END,CASE WHEN LEFT(actrn.approve_by,2)='S:' THEN actrn.approve_by ELSE 'D:' + actrn.approve_by END,actrn.confirmDate,actrn.confirmDate
	    ,actrn.paidDate,actrn.paidDate,CASE WHEN LEFT(actrn.paidBy, 2) = 'S:' THEN RIGHT(actrn.paidBy, LEN(actrn.paidBy) - 2) ELSE actrn.paidBy END
	    ,'D',NULL
    FROM hremit.dbo.AccountTransaction actrn
    INNER JOIN #txn t ON actrn.Tranno = t.tranNo
    LEFT JOIN agentMaster sb WITH(NOLOCK) ON sb.mapCodeDom = actrn.agentid
    LEFT JOIN agentMaster sa WITH(NOLOCK) ON sa.agentId = sb.parentId AND sa.agentType = 2903
    LEFT JOIN agentMaster pb WITH(NOLOCK) ON pb.mapCodeInt = actrn.rBankID AND (pb.agentType = 2904 OR pb.actAsBranch = 'Y')
    LEFT JOIN agentMaster pa WITH(NOLOCK) ON pa.agentId = pb.parentId

    --2. Sender Information---------------------------------------------------------------------------------------------------------
    INSERT INTO tranSenders(
		tranId,firstName,[address],mobile,homePhone,idType,idNumber
    )
    SELECT
		rt.id,actrn.SenderName,actrn.SenderAddress,actrn.SenderPhoneno,actrn.SenderPhoneno,actrn.id_type,actrn.id_no
    FROM hremit.dbo.AccountTransaction actrn
    INNER JOIN #txn t ON actrn.Tranno = t.tranNo
    INNER JOIN remitTran rt WITH(NOLOCK) ON dbo.decryptDbLocal(actrn.refno) = dbo.FNADecryptString(rt.controlNo)
    --End-------------------------------------------------------------------------------------------------------------------------------

    --3. Receiver Information------------------------------------------------------------------------------------------------------------------
    INSERT INTO tranReceivers(
		tranId,firstName,[address],mobile,idType,idNumber,idType2,idNumber2
    )
    SELECT
		rt.id,actrn.ReceiverName,actrn.ReceiverAddress,actrn.ReceiverPhone,actrn.rec_id_type,actrn.rec_id_no,actrn.rec_id_type,actrn.rec_id_no
    FROM hremit.dbo.AccountTransaction actrn
    INNER JOIN #txn t ON actrn.Tranno = t.tranNo
    INNER JOIN remitTran rt WITH(NOLOCK) ON dbo.decryptDbLocal(actrn.refno) = dbo.FNADecryptString(rt.controlNo)
    --End--------------------------------------------------------------------------------------------------------------------------------------

end

if @flag ='acDepositNewSync'		--A/C Deposit Txn Synchronize(New System)
begin
	   --1. Transaction Generated by New System(A/C Deposit) but Paid By Old System Synchronize-----------------------------------------------------------------------
	   IF OBJECT_ID('tempdb..#TEMP5') IS NOT NULL
		   DROP TABLE #TEMP5
	   IF OBJECT_ID('tempdb..#TEMP6') IS NOT NULL
		   DROP TABLE #TEMP6

	   SELECT dbo.decryptDblocal(refno) AS refno, Tranno, SEmpID INTO #TEMP5
	   FROM hremit.dbo.AccountTransaction WITH (NOLOCK)
	   WHERE paidDate BETWEEN CAST(GETDATE() - 1 AS DATE) AND GETDATE() AND paymentType = 'Bank Transfer'

	   SELECT dbo.FNADecryptString(controlNo)AS controlNo INTO #TEMP6
	   FROM remitTran WITH (NOLOCK)
	   WHERE paidDate BETWEEN CAST(GETDATE() - 1 AS DATE) AND GETDATE() AND paymentMethod = 'Bank Deposit'
	   AND ISNULL(sCountry,'') = 'Nepal'

	   /*
	   SELECT A.refno, A.Tranno, A.SEmpID
	   FROM #TEMP5 A
	   WHERE A.refno NOT IN (SELECT controlNo from #TEMP6)
	   */

		--TRUNCATE TABLE #txn
	   INSERT INTO #txn
	   SELECT A.Tranno FROM #TEMP5 A
	   WHERE A.refno NOT IN (SELECT controlNo from #TEMP6)
	   --SELECT * FROM @txn

	   IF NOT EXISTS(SELECT 'X' FROM #txn)
		BEGIN
			EXEC proc_errorHandler 1, 'No transaction to synchronise', NULL
			RETURN
		END
	   UPDATE rt SET
		    rt.pAgentComm					= acTrn.receiverCommission
		   ,rt.pAgentCommCurrency			= 'NPR'
		   ,rt.pSuperAgentComm				= 0
		   ,rt.pSuperAgentCommCurrency		= 'NPR'
		   ,rt.pCountry						= 'Nepal'
		   ,rt.pState						= pb.agentState
		   ,rt.pDistrict					= pb.agentDistrict
		   ,rt.tranStatus					= 'Paid'
		   ,rt.payStatus					= 'Paid'
		   ,rt.paidBy						= 'D:' + acTrn.paidBy
		   ,rt.paidDate						= acTrn.paidDate
		   ,rt.paidDateLocal				= acTrn.paidDate
	   FROM remitTran rt
	   INNER JOIN hremit.dbo.AccountTransaction acTrn ON dbo.FNADecryptString(rt.controlNo) = dbo.decryptDbLocal(acTrn.refno)
	   INNER JOIN #txn txn ON acTrn.Tranno = txn.tranNo
	   LEFT JOIN agentMaster pb ON acTrn.rBankID = pb.mapCodeDomAc AND pb.agentType IN (2903,2905)
		
		/*
	   UPDATE rec SET
		    rec.idType2						= acTrn.rec_id_type
		   ,rec.idNumber2					= acTrn.rec_id_no
		   ,rec.mobile						= acTrn.ReceiverPhone
	   FROM tranReceivers rec
	   INNER JOIN remitTran rt ON rec.tranId = rt.id
	   INNER JOIN hremit.dbo.AccountTransaction acTrn ON dbo.FNADecryptString(rt.controlNo) = dbo.decryptDbLocal(acTrn.refno)
	   INNER JOIN #txn txn ON acTrn.Tranno = txn.tranNo
	   */
	   SELECT 0, 'Operation successful, Total no. of transactions synchronised : ' + CAST(COUNT(*) AS VARCHAR), NULL FROM #txn

end 

if @flag ='acDepositOldImport'		--A/C Deposit Txn Import(From Old System)
begin
    --------------------------------------------------------------------------------------------------------------------------------------
    --3. Old System Bank Deposit(Paid) Transaction Import------------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#TEMP7') IS NOT NULL
	    DROP TABLE #TEMP7
    IF OBJECT_ID('tempdb..#TEMP8') IS NOT NULL
	    DROP TABLE #TEMP8

    SELECT dbo.decryptDblocal(refno) AS refno, Tranno, SEmpID INTO #TEMP7
    FROM hremit.dbo.AccountTransaction WITH (NOLOCK)
    WHERE paidDate BETWEEN '2012-12-01' AND '2012-12-17 23:59' and paymentType = 'Bank Transfer'
    and [status] = 'Paid'

	DELETE T
	from #TEMP7 T, remitTran M
	Where (T.refno) = dbo.FNADecryptstring(M.controlNo)

	--TRUNCATE TABLE #txn
    INSERT INTO #txn
    SELECT A.Tranno FROM #TEMP7 A

    -- 8624 WHERE A.refno NOT IN (SELECT controlNo from #TEMP4)


    IF NOT EXISTS(SELECT 'X' FROM #txn)
	    RETURN

    --SELECT * FROM #
    --SELECT COUNT(*), dbo.fnadecryptstring(controlNo) FROM #tmpTran GROUP BY controlNo HAVING COUNT(*) > 1
    --1. Main Table Insert-----------------------------------------------------------------------------------------------------------------------
    --SELECT TOP 1 * FROM hremit.dbo.AccountTransaction WHERE rBankID IS NOT NULL ORDER BY Tranno DESC
    INSERT INTO remitTran(
		controlNo,customerRate,serviceCharge,handlingFee
	    ,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency
	    ,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency
	    ,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,sCountry
	    ,pSuperAgent,pSuperAgentName
	    ,pAgent,pAgentName
	    ,pBranch,pBranchName,pCountry
	    ,pState,pDistrict,pLocation,paymentMethod
	    ,pBank,pBankName,pBankBranch,pBankBranchName,accountNo
	    ,collCurr,tAmt,cAmt,pAmt,payoutCurr
	    ,relWithSender,tranStatus,payStatus
	    ,createdDate,createdDateLocal,createdBy,approvedBy,approvedDate,approvedDateLocal
	    ,paidDate,paidDateLocal,paidBy
	    ,tranType,oldSysTranNo			
    )	

    SELECT 
   --COUNT(*) 
		DISTINCT
		controlNo = dbo.FNAEncryptString(dbo.decryptDbLocal(actrn.refNo)),custRate = NULL,serviceCharge=actrn.SCharge,hfee=0
	    ,actrn.senderCommission,actrn.paidCType,ssAgentComm=0,ssAgentCommCurr=actrn.paidCType
	    ,actrn.receiverCommission,pAgentCommCurr='NPR',psAgentComm=0,psAgentCommCurr='NPR'
	    ,ssa=1002,ssan='International Money Express (IME) Pvt. Ltd',sa=ISNULL(sa.agentId, sb.agentId),san=ISNULL(sa.agentName, sb.agentName),sb=sb.agentId,sbn=sb.agentName,actrn.SenderCountry
	    ,psa=NULL,psan=NULL
	    ,pa=NULL,pan=NULL
	    ,pb=NULL,pbn=NULL,rCountry='Nepal'
	    ,pb.agentState,pb.agentDistrict,actrn.receiveAgentID,dm='Bank Deposit'
	    ,pBank = pa.agentId,pBankName = pa.agentName,pBankBranch = pb.agentId,pBankBranchName = pb.agentName,actrn.bank_account_detail
	    ,collCurr=actrn.paidCType,tAmt=actrn.paidAmt - actrn.SCharge,pAmt=actrn.paidAmt,actrn.TotalRoundAmt,pCurr='NPR'
	    ,rel=NULL,actrn.TransStatus,actrn.[status]
	    ,cdate=actrn.confirmDate,cDatel=actrn.confirmDate,cUser='D:' + actrn.SEmpID,appUser='D:' + actrn.approve_by,appdate=actrn.confirmDate,appdatel=actrn.confirmDate
	    ,pDate=actrn.paidDate,pDatel=actrn.paidDate,pUser=CASE WHEN LEFT(actrn.paidBy, 2) = 'S:' THEN RIGHT(actrn.paidBy, LEN(actrn.paidBy) - 2) ELSE actrn.paidBy END
	    ,tranType='D',oldSysTNo=NULL
    FROM hremit.dbo.AccountTransaction actrn WITH(NOLOCK)
    INNER JOIN #txn t ON actrn.Tranno = t.tranNo
    LEFT JOIN agentMaster sb WITH(NOLOCK) ON sb.mapCodeDom = actrn.agentid
    LEFT JOIN agentMaster sa WITH(NOLOCK) ON sa.agentId = sb.parentId AND sa.agentType = 2903
    LEFT JOIN agentMaster pb WITH(NOLOCK) ON pb.mapCodeDomAc = actrn.rBankID 
				AND pb.agentType IN (2903)
    LEFT JOIN agentMaster pa WITH(NOLOCK) ON pa.agentId = pb.parentId
    WHERE pb.agentId IS NOT NULL



    --2. Sender Information---------------------------------------------------------------------------------------------------------
    INSERT INTO tranSenders(
		tranId,firstName,[address],mobile,homePhone,idType,idNumber
    )
    SELECT
		rt.id,actrn.SenderName,actrn.SenderAddress,actrn.SenderPhoneno,actrn.SenderPhoneno,actrn.id_type,actrn.id_no
    FROM hremit.dbo.AccountTransaction actrn WITH(NOLOCK)
    INNER JOIN #txn t ON actrn.Tranno = t.tranNo
    INNER JOIN remitTran rt WITH(NOLOCK) ON dbo.decryptDbLocal(actrn.refno) = dbo.FNADecryptString(rt.controlNo)
    --End-------------------------------------------------------------------------------------------------------------------------------

    --3. Receiver Information------------------------------------------------------------------------------------------------------------------
    
    INSERT INTO tranReceivers(
		tranId,firstName,[address],mobile,idType,idNumber,idType2,idNumber2
    )
    SELECT
		rt.id,actrn.ReceiverName,actrn.ReceiverAddress,actrn.ReceiverPhone,actrn.rec_id_type,actrn.rec_id_no,actrn.rec_id_type,actrn.rec_id_no
    FROM hremit.dbo.AccountTransaction actrn WITH(NOLOCK)
    INNER JOIN #txn t ON actrn.Tranno = t.tranNo
    INNER JOIN remitTran rt WITH(NOLOCK) ON dbo.decryptDbLocal(actrn.refno) = dbo.FNADecryptString(rt.controlNo)
    
    --End--------------------------------------------------------------------------------------------------------------------------------------

end



GO
