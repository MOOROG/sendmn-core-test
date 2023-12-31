USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_OMRemitGate_GetUnpaidList]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_OMRemitGate_GetUnpaidList]
	@flag char(1),
	@user varchar(50)=NULL,
	@fromDate varchar(50)=NULL,
	@toDate varchar(50)=NULL,
	@session_id varchar(200)=NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;


IF @fromDate is null
begin
	SET @fromDate = CONVERT(varchar(20), getdate(), 101)
	SET @toDate = CONVERT(varchar(20), getdate(), 101) +' 23:59'
end

DECLARE @table_name VARCHAR(200),@sql VARCHAR(max)
SET @table_name = '[10.20.30.42].RemittanceDBIntregration.dbo.REMIT_TRN_MASTER_IRH'

IF @flag='s' 
BEGIN

    SELECT [TRN_REF_NO], dbo.decryptDb([TRN_REF_NO2]) [TRN_REF_NO2],[SENDER_NAME]+ '-' + isnull(TXN_STATUS,'') [SENDER_NAME],[RECEIVER_NAME],[TRN_DATE],[P_AMT],[DOWNLODED_TS]  
    FROM sambaRemitGateData with(nolock) WHERE APPROVED_TS is NULL

END

IF @flag='j' --- RUN FROM JOB
BEGIN

	Exec [proc_OMRemitGate_GetUnpaidList] @flag='i', @user='system'
	Exec [proc_OMRemitGate_GetUnpaidList] @flag='a', @user='system'

END

IF @flag='i' --- insert in temporary table.... iremit_process.OMRemitGate_tempSave
BEGIN

    DECLARE @count VARCHAR(20)

    delete from sambaRemitGateData
    SET @sql='
    INSERT INTO sambaRemitGateData(
    [TRN_REF_NO],[TRN_REF_NO2],[SENDER_NAME],[SENDER_COUNTRY],[SENDER_ADDRESS],[SENDER_ADDRESS2],
    [SENDER_PH],[SENDER_EMAIL],[SENDER_CARD_NO],[RECEIVER_NAME],[RECEIVER_COUNTRY],[RECEIVER_ADDRESS],
    [RECEIVER_ADDRESS2],[RECEIVER_PH],[RECEIVER_EMAIL],[RECEIVER_CARD_NO],[S_AGENT],[S_BRANCH],[S_CURR],[S_AMT],
    [P_AGENT],[P_BRANCH],[P_CURR],[P_AMT],[SC_TOTAL],[SC_HO],[SC_S_AGENT],[SC_P_AGENT],[SC_OTHER],[COLLECTED_AMT],
    [USD_AMT],[EX_LC],[EX_USD],[EX_FLC],[TRN_TYPE],[TRN_STATUS],[PAY_STATUS],[TRN_DATE],[PAID_DATE],[CANCEL_DATE],
    [SETTLEMENT_RATE],[TRN_MODE],[TH_TRANNO],[GAIN_LOSS],[RAN],[DOWNLODED_TS])
    SELECT
    [TRN_REF_NO],[TRN_REF_NO2],[SENDER_NAME],[SENDER_COUNTRY],[SENDER_ADDRESS],[SENDER_ADDRESS2],
    [SENDER_PH],[SENDER_EMAIL],[SENDER_CARD_NO],[RECEIVER_NAME],[RECEIVER_COUNTRY],[RECEIVER_ADDRESS],
    [RECEIVER_ADDRESS2],[RECEIVER_PH],[RECEIVER_EMAIL],[RECEIVER_CARD_NO],[S_AGENT],[S_BRANCH],[S_CURR],[S_AMT],
    [P_AGENT],[P_BRANCH],[P_CURR],[P_AMT],[SC_TOTAL],[SC_HO],[SC_S_AGENT],[SC_P_AGENT],[SC_OTHER],[COLLECTED_AMT],
    [USD_AMT],[EX_LC],[EX_USD],[EX_FLC],[TRN_TYPE],[TRN_STATUS],[PAY_STATUS],[TRN_DATE],[PAID_DATE],[CANCEL_DATE],
    [SETTLEMENT_RATE],[TRN_MODE],[TH_TRANNO],[GAIN_LOSS],[RAN],getdate()
    from '+@table_name+' where len(TRN_REF_NO2)=8
    AND TRN_DATE  between '''+ @fromDate +''' AND '''+ @toDate +''' '

    EXEC(@sql)

    SET @count = @@ROWCOUNT

    UPDATE sambaRemitGateData SET TRN_REF_NO2 = dbo.encryptDB(TRN_REF_NO2)

    UPDATE S 
		 SET  TXN_STATUS='<font color="red">Duplicate</font>'
    FROM sambaRemitGateData S with(nolock) , remitTran R with(nolock) 
    WHERE S.TRN_REF_NO2 = R.controlNo 

     If @count = 0
     BEGIN
		  SELECT '1' errorCode, 'No Data Found For Import!'   msg, NUll id	   
		  RETURN;
     END
     ELSE
     BEGIN
		  SELECT '0' errorCode, @count+'Row(s) Successfully Imported '   msg, NUll id
		  RETURN
     END
END

ELSE IF @flag = 'a'
BEGIN


    DECLARE @sAgent varchar(20), @sAgentName varchar(200), 
	        @sBranch varchar(20), @sBranchName varchar(200), @today_time varchar(20)
	       ,@scharge varchar(20),@digi_info varchar(20), @tranId int

	SET @sAgent='4876'
	SET @sAgentName='Samba Online'
	SET @sBranch='4877'
	SET @sBranchName='Samba Online - Riyadh online'
     SET @today_time = GETDATE()
	SET @digi_info = 'IMP'
     SET @scharge ='0'
	    
    SELECT * into #tbl_integration_swift FROM sambaRemitGateData with(nolock) 
    WHERE APPROVED_TS is NULL

    DELETE T
    FROM #tbl_integration_swift T, dbo.remitTran S with(nolock) 
    WHERE S.controlNo = T.TRN_REF_NO2

	SET @count = (SELECT COUNT(*) FROM #tbl_integration_swift)

     If @count = 0
     BEGIN
		  SELECT '1' errorCode, ' No Data Found !'   msg, NUll id	   
		  RETURN;
     END


	BEGIN TRANSACTION

     INSERT INTO remitTran(controlNo, sAgent, sAgentName, sBranch, sBranchName, senderName, 
		   sCountry, receiverName,pCountry, 
		  createdDate, createdDateLocal, createdBy, approvedBy, approvedDate, approvedDateLocal,
		  cAmt, tAmt, pAmt,payoutCurr,customerRate,sAgentSettRate,agentCrossSettRate,
	       collCurr, collMode, paymentMethod,tranStatus, payStatus,serviceCharge,sAgentComm,
	       tranType,sCurrCostRate,pCurrCostRate, sCurrHoMargin, sCurrAgentMargin)

      SELECT  TRN_REF_NO2 controlNo,@sAgent sAgent, @sAgentName sAgentName,@sBranch sBranch
	   ,@sBranchName sBranchName,SENDER_NAME senderName,
	   'Saudi Arabia' sCountry, RECEIVER_NAME receiverName,'Nepal' pCountry,
	   TRN_DATE,TRN_DATE ,@user createdBy,@user approvedBy,TRN_DATE,TRN_DATE, 
	   USD_AMT cAmt, USD_AMT tAmt, P_AMT pAmt,'NPR' payoutCurr,cast(P_AMT/USD_AMT AS MONEY)customerRate,1 sAgentSettRate,cast(P_AMT/USD_AMT AS MONEY) agentCrossSettRate,
	   'USD' collCurr,'Cash Pay' collMode,'Cash Payment' paymentMethod,
	   'Payment' tranStatus,'Unpaid' payStatus,isNULL(@scharge,0) serviceCharge,'0' sAgentComm,'i'
	   ,1,cast(P_AMT/USD_AMT AS MONEY), 0, 0
	FROM #tbl_integration_swift 
	WHERE APPROVED_TS is NULL 

 
  
     INSERT INTO tranSenders(
			 tranId
			,firstName
			,middleName
			,lastName1
			,lastName2
			,fullName
			,[address]
			,nativeCountry
			,dcInfo
			,membershipId
		)

    SELECT rt.id
		  ,(SELECT firstName FROM dbo.FNASplitName(actrn.SENDER_NAME)) firstName
		  ,(SELECT middleName FROM dbo.FNASplitName(actrn.SENDER_NAME)) middleName
		  ,(SELECT lastName1 FROM dbo.FNASplitName(actrn.SENDER_NAME)) lastName1
		  ,(SELECT lastName2 FROM dbo.FNASplitName(actrn.SENDER_NAME)) lastName2
	       ,SENDER_NAME fullName
		  ,'Riyad'
		  ,'Nepal'
		  ,@digi_info
		  ,isNull(RAN,'')
    FROM #tbl_integration_swift  actrn
    INNER JOIN remitTran rt WITH(NOLOCK) ON actrn.TRN_REF_NO2 = rt.controlNo

    INSERT INTO tranReceivers(
			 tranId
			,firstName
			,middleName
			,lastName1
			,lastName2
			,fullName
			,address
			,dcInfo
		)

    SELECT rt.id
		  ,(SELECT firstName FROM dbo.FNASplitName(actrn.RECEIVER_NAME)) firstName
		  ,(SELECT middleName FROM dbo.FNASplitName(actrn.RECEIVER_NAME)) middleName
		  ,(SELECT lastName1 FROM dbo.FNASplitName(actrn.RECEIVER_NAME)) lastName1
		  ,(SELECT lastName2 FROM dbo.FNASplitName(actrn.RECEIVER_NAME)) lastName2
	       ,RECEIVER_NAME fullName
		  ,isNULL(RECEIVER_ADDRESS,'')+' '+isNULL(RECEIVER_ADDRESS2,'')
		  ,@digi_info
    FROM #tbl_integration_swift  actrn
    INNER JOIN remitTran rt WITH(NOLOCK) ON actrn.TRN_REF_NO2 = rt.controlNo


    DELETE S 
    FROM sambaRemitGateData S, #tbl_integration_swift T
    WHERE S.TRN_REF_NO = T.TRN_REF_NO2

    INSERT INTO PinQueueList(ICN)
    SELECT TRN_REF_NO2 FROM #tbl_integration_swift
    
    DELETE S 
    FROM sambaRemitGateData S, remitTran R with(nolock) 
    WHERE S.TRN_REF_NO2 = R.controlNo


	COMMIT TRANSACTION
	
	SELECT '0' errorCode, @count+' Row(s) Successfully Approved '   msg, NUll id
	RETURN;

END



GO
