USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_settlementDdl_v2]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_settlementDdl_v2]
	@user				VARCHAR(50) = NULL,
	@flag				VARCHAR(20),
	@pCountry			VARCHAR(20)	= NULL,
	@sAgent				VARCHAR(50),
	@sBranch			VARCHAR(20)	= NULL,
	@fromDate			VARCHAR(30) = NULL,
	@toDate				VARCHAR(50)	= NULL,
	@pageNumber			VARCHAR(50)	= NULL,
	@pageSize			VARCHAR(50)	= NULL

AS

SET NOCOUNT ON;
SET ANSI_NULLS ON;


IF(DATEDIFF(D,@fromDate,@toDate))>31 
BEGIN
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	EXEC proc_errorHandler '1', '<font color="red"><b>Report can view only 31 days</b></font>', NULL
	RETURN;
END

DECLARE @cutOffDate VARCHAR(20) = '2014-10-20'


IF @pCountry = 'All'
	SET @pCountry = NULL

IF @fromDate > =  @cutOffDate
BEGIN
	IF @flag='SEND'
	BEGIN
		IF OBJECT_ID(N'tempdb..#SETTLEMENTSEND') IS NOT NULL
			DROP TABLE #SETTLEMENTSEND

			SELECT   id,controlNo,holdTranId
					,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
					,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
					,customerRate,sAgentSettRate
					,pDateCostRate,agentFxGain
					,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
					,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
					,pCountry ,pAgent,pAgentName,pBranch,pBranchName
					,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
					,createdDate
					,approvedDate
					,paidDate
					,cancelApprovedDate
			INTO #SETTLEMENTSEND
			FROM remitTran WITH (NOLOCK) 
			WHERE 1=1
				AND SAGENT=@sAgent  
				AND APPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' 
				AND pCountry = isnull(@pCountry,pCountry) 
				AND sBranch = isnull(@sBranch,sBranch)

		  SELECT 
			[DATE]							=	approvedDate  
			,[Tran No.]						=	ISNULL(HOLDTRANID,ID) 
			,[ICN]							=   dbo.fnadecryptstring(controlNo)  
			,[Sender Name]					=	SENDERNAME
			,[Receiver Name]				=	RECEIVERNAME
			,[Collection_Currency]			=	collCurr 
			,[Collection_Collection Amt]	=	(camt) 
			,[Collection_Total Charge]		=	(ISNULL(serviceCharge,0)) 
			,[Collection_Payout Amt]		=	(camt-ISNULL(serviceCharge,0)) 
			,[Collection_Agent Commission]	=	(ISNULL(sAgentComm,0)) 
			,[Collection_Ex. Gain]			=	(ISNULL(agentFxGain,0)) 
			,[Collection_Sett. Amount]		=	(camt) - (ISNULL(sAgentComm,0))  - (ISNULL(agentFxGain,0)) 
			,[Sett. Amount USD]				=	(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)) - (ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))   - (ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))  
			,[Receive_Currency]				=	payoutCurr 
			,[Receive_Rate]					=	CUSTOMERRATE  
			,[Receive_Amount]				=	PAMT  
			,[Rate against USD_Collection]	=	SCURRCOSTRATE + ISNULL(SCURRHOMARGIN,0) 
			,[Rate against USD_Receive]		=	PCURRCOSTRATE - ISNULL(PCURRHOMARGIN,0) - ISNULL (PCURRAGENTMARGIN,0) 

		FROM #SETTLEMENTSEND
		 ORDER BY approvedDate
	

	END

	IF @flag='PAID'
	BEGIN
  
		IF OBJECT_ID(N'tempdb..#SETTLEMENTPaid') IS NOT NULL
			DROP TABLE #SETTLEMENTPaid

			SELECT   id,controlNo,holdTranId
					,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
					,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
					,customerRate,sAgentSettRate
					,pDateCostRate,agentFxGain
					,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
					,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
					,pCountry ,pAgent,pAgentName,pBranch,pBranchName
					,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
					,createdDate
					,approvedDate
					,paidDate
					,cancelApprovedDate
			INTO #SETTLEMENTPaid
			FROM remitTran WITH (NOLOCK) 
			WHERE 1=1
				AND pAGENT=@sAgent  
				AND paidDate BETWEEN @fromDate AND @toDate + ' 23:59:59' 
				AND sCountry = isnull(@pCountry,sCountry) 
				AND pBranch = isnull(@sBranch,pBranch)
  
  
			SELECT 
				 DATE							= paidDate  
				,[Tran No.]						= ISNULL(HOLDTRANID,ID) 
				,[ICN]							= dbo.fnadecryptstring( controlNo )
				,[Sender Name]					= SENDERNAME
				,[Receiver Name]				= RECEIVERNAME
				,[Collection_Currency]			= payoutCurr 
				,[Collection_Collection Amt]	= (pamt)
				,[Collection_Total Charge]		= 0  
				,[Collection_Payout Amt]		=(pamt) 
				,[Collection_Agent Commission]	=  ((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0)))*ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0)))) 
				,[Collection_Ex. Gain]			=  0 
				,[Collection_Settlement Amount] = (pamt) + ((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0)))*ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))))  
				,[Settlement Amount USD]		= (pamt/ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0)))) + ((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0))))  
				,[Receive_Currency]				= payoutCurr 
				,[Receive_Rate]					=  1 
				,[Receive_Amount]				= pamt 
				,[Rate against USD_Collection]	=  1  
				,[Rate against USD_Receive]		= ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))) 
			FROM #SETTLEMENTPaid
			ORDER BY paidDate

	END

	IF @flag='CANCEL'
	BEGIN

		IF OBJECT_ID(N'tempdb..#SETTLEMENTCANCEL') IS NOT NULL
			DROP TABLE #SETTLEMENTCANCEL

			SELECT     id,controlNo,holdTranId
					,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
					,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
					,customerRate,sAgentSettRate
					,pDateCostRate,agentFxGain
					,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
					,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
					,pCountry ,pAgent,pAgentName,pBranch,pBranchName
					,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
					,createdDate
					,approvedDate
					,paidDate
					,cancelApprovedDate
			INTO #SETTLEMENTCANCEL
			FROM remitTran WITH (NOLOCK) 
			WHERE 1=1
				AND sAGENT=@sAgent  
				AND cancelApprovedDate BETWEEN @fromDate AND @toDate + ' 23:59:59' 
				AND pCountry = isnull(@pCountry,pCountry) 
				AND sBranch = isnull(@sBranch,sBranch)

		SELECT 
			DATE							= cancelApprovedDate  
			,[Tran No.]						= ISNULL(HOLDTRANID,ID) 
			,[ICN]							= dbo.fnadecryptstring( controlNo )  
			,[Sender Name]					= SENDERNAME
			,[Receiver Name]				= RECEIVERNAME
			,[Collection_Currency]			= collCurr 
			,[Collection_Collection Amt]	= (camt) 
			,[Collection_Total Charge]		= (ISNULL(serviceCharge,0)) 
			,[Collection_Payout Amt]		= (camt-ISNULL(serviceCharge,0)) 
			,[Collection_Agent Commission]	= (ISNULL(sAgentComm,0)) 
			,[Collection_Ex. Gain]			= (ISNULL(agentFxGain,0)) 
			,[Collection_Settlement Amount]	= (camt) - (ISNULL(sAgentComm,0))  - (ISNULL(agentFxGain,0)) 
			,[Settlement Amount USD]		= (ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)) - (ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))   - (ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))  
			,[Receive_Currency]				= payoutCurr 
			,[Receive_Rate]					= CUSTOMERRATE  
			,[Receive_Amount]				= PAMT  
			,[Rate against USD_Collection]	= SCURRCOSTRATE + ISNULL(SCURRHOMARGIN,0)  
			,[Rate against USD_Receive]		= PCURRCOSTRATE - ISNULL(PCURRHOMARGIN,0) - ISNULL (PCURRAGENTMARGIN,0) 
		FROM #SETTLEMENTCANCEL
		ORDER BY cancelApprovedDate

 
	END
END
ELSE
BEGIN
	IF @flag='SEND'
	BEGIN
		IF OBJECT_ID(N'tempdb..#SETTLEMENTSEND1') IS NOT NULL
			DROP TABLE #SETTLEMENTSEND1

			SELECT   id,controlNo,holdTranId
					,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
					,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
					,customerRate,sAgentSettRate
					,pDateCostRate,agentFxGain
					,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
					,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
					,pCountry ,pAgent,pAgentName,pBranch,pBranchName
					,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
					,createdDate
					,approvedDate
					,paidDate
					,cancelApprovedDate
			INTO #SETTLEMENTSEND1
			FROM remitTran WITH (NOLOCK) 
			WHERE 1=1
				AND SAGENT=@sAgent  
				AND APPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' 
				AND pCountry = isnull(@pCountry,pCountry) 
				AND sBranch = isnull(@sBranch,sBranch)

		  SELECT 
			 [DATE]							=	approvedDate  
			,[Tran No.]						=	ISNULL(HOLDTRANID,ID) 
			,[ICN]							=   dbo.fnadecryptstring(controlNo)  
			,[Sender Name]					=	SENDERNAME
			,[Receiver Name]				=	RECEIVERNAME
			,[Collection_Currency]			=	collCurr 
			,[Collection_Collection Amt]	=	(camt) 
			,[Collection_Total Charge]		=	ROUND(ISNULL(serviceCharge,0),2) 
			,[Collection_Payout Amt]		=	ROUND(cAmt-ISNULL(serviceCharge,0),2) 
			,[Collection_Agent Commission]	=	ROUND(ISNULL(sAgentComm,0),2) 
			,[Collection_Ex. Gain]			=	ROUND(ISNULL(agentFxGain,0),2) 
			,[Collection_Sett. Amount]		=	ROUND(((cAmt) - ROUND(ISNULL(sAgentComm,0),2)  - ROUND(ISNULL(agentFxGain,0),2)),2) 
			,[Sett. Amount USD]				=	ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2) - ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2,1)   - ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2,1)
			,[Receive_Currency]				=	payoutCurr 
			,[Receive_Rate]					=	CUSTOMERRATE  
			,[Receive_Amount]				=	PAMT  
			,[Rate against USD_Collection]	=	SCURRCOSTRATE + ISNULL(SCURRHOMARGIN,0) 
			,[Rate against USD_Receive]		=	PCURRCOSTRATE - ISNULL(PCURRHOMARGIN,0) - ISNULL (PCURRAGENTMARGIN,0) 

		FROM #SETTLEMENTSEND1
		 ORDER BY approvedDate
	

	END

	IF @flag='CANCEL'
	BEGIN

		IF OBJECT_ID(N'tempdb..#SETTLEMENTCANCEL1') IS NOT NULL
			DROP TABLE #SETTLEMENTCANCEL1

			SELECT   id,controlNo,holdTranId
					,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
					,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
					,customerRate,sAgentSettRate
					,pDateCostRate,agentFxGain
					,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
					,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
					,pCountry ,pAgent,pAgentName,pBranch,pBranchName
					,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
					,createdDate
					,approvedDate
					,paidDate
					,cancelApprovedDate
			INTO #SETTLEMENTCANCEL1
			FROM remitTran WITH (NOLOCK) 
			WHERE 1=1
				AND sAGENT=@sAgent  
				AND cancelApprovedDate BETWEEN @fromDate AND @toDate + ' 23:59:59' 
				AND pCountry = isnull(@pCountry,pCountry) 
				AND sBranch = isnull(@sBranch,sBranch)

		SELECT 
			DATE							= cancelApprovedDate  
			,[Tran No.]						= ISNULL(HOLDTRANID,ID) 
			,[ICN]							= dbo.fnadecryptstring( controlNo )  
			,[Sender Name]					= SENDERNAME
			,[Receiver Name]				= RECEIVERNAME
			,[Collection_Currency]			= collCurr 
			,[Collection_Collection Amt]	= (camt) 
			,[Collection_Total Charge]		= (ISNULL(serviceCharge,0)) 
			,[Collection_Payout Amt]		= (camt-ISNULL(serviceCharge,0)) 
			,[Collection_Agent Commission]	= (ISNULL(sAgentComm,0)) 
			,[Collection_Ex. Gain]			= (ISNULL(agentFxGain,0)) 
			,[Collection_Settlement Amount]	= (camt) - (ISNULL(sAgentComm,0))  - (ISNULL(agentFxGain,0)) 
			,[Settlement Amount USD]		= (ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)) - (ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))   - (ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))  
			,[Receive_Currency]				= payoutCurr 
			,[Receive_Rate]					= CUSTOMERRATE  
			,[Receive_Amount]				= PAMT  
			,[Rate against USD_Collection]	= SCURRCOSTRATE + ISNULL(SCURRHOMARGIN,0)  
			,[Rate against USD_Receive]		= PCURRCOSTRATE - ISNULL(PCURRHOMARGIN,0) - ISNULL (PCURRAGENTMARGIN,0) 
		FROM #SETTLEMENTCANCEL1
		ORDER BY cancelApprovedDate

 
	END
END




EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT 'Sending Agent' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent),'ALL')  VALUE
UNION ALL
SELECT 'Sending Branch' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sBranch),'ALL')  VALUE
UNION ALL
SELECT 'Receiving Country' head,isnull(@pCountry,'All') VALUE 
UNION ALL
SELECT 'From Date' head,@fromDate value
UNION ALL
SELECT 'To Date' head,	@toDate

SELECT 'Transaction Settlement Report : '+@flag title




GO
