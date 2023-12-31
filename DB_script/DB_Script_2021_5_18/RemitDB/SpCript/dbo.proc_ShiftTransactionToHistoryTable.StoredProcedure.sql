USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ShiftTransactionToHistoryTable]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Exec proc_ShiftTransactionToHistoryTable @flag = 'u', @user = 'admin'
	  
*/
CREATE proc [dbo].[proc_ShiftTransactionToHistoryTable]
 	 @flag                              VARCHAR(50)		= NULL
	,@user						 VARCHAR(50)		= NULL
AS

If @FLAG ='u'
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

 BEGIN TRANSACTION
   
    --select * into remitTranHistory from remitTran where 1=2
    INSERT INTO remitTranHistory
    (
	  [id]
	 ,[controlNo]
      ,[sCurrCostRate]
      ,[sCurrHoMargin]
      ,[pCurrCostRate]
      ,[pCurrHoMargin]
      ,[sCurrAgentMargin]
      ,[pCurrAgentMargin]
      ,[sCurrSuperAgentMargin]
      ,[pCurrSuperAgentMargin]
      ,[customerRate]
      ,[sAgentSettRate]
      ,[pDateCostRate]
      ,[serviceCharge]
      ,[handlingFee]
      ,[sAgentComm]
      ,[sAgentCommCurrency]
      ,[sSuperAgentComm]
      ,[sSuperAgentCommCurrency]
      ,[sHubComm]
      ,[sHubCommCurrency]
      ,[pAgentComm]
      ,[pAgentCommCurrency]
      ,[pSuperAgentComm]
      ,[pSuperAgentCommCurrency]
      ,[pHubComm]
      ,[pHubCommCurrency]
      ,[promotionCode]
      ,[promotionType]
      ,[pMessage]
      ,[sCountry]
      ,[sSuperAgent]
      ,[sSuperAgentName]
      ,[sAgent]
      ,[sAgentName]
      ,[sBranch]
      ,[sBranchName]
      ,[pCountry]
      ,[pSuperAgent]
      ,[pSuperAgentName]
      ,[pAgent]
      ,[pAgentName]
      ,[pBranch]
      ,[pBranchName]
      ,[pState]
      ,[pDistrict]
      ,[pLocation]
      ,[paymentMethod]
      ,[pBank]
      ,[pBankName]
      ,[pBankBranch]
      ,[pBankBranchName]
      ,[accountNo]
      ,[collMode]
      ,[collCurr]
      ,[tAmt]
      ,[cAmt]
      ,[pAmt]
      ,[payoutCurr]
      ,[relWithSender]
      ,[purposeOfRemit]
      ,[sourceOfFund]
      ,[tranStatus]
      ,[payStatus]
      ,[createdDate]
      ,[createdDateLocal]
      ,[createdBy]
      ,[modifiedDate]
      ,[modifiedDateLocal]
      ,[modifiedBy]
      ,[approvedDate]
      ,[approvedDateLocal]
      ,[approvedBy]
      ,[paidDate]
      ,[paidDateLocal]
      ,[paidBy]
      ,[cancelRequestDate]
      ,[cancelRequestDateLocal]
      ,[cancelRequestBy]
      ,[cancelReason]
      ,[refund]
      ,[cancelApprovedDate]
      ,[cancelApprovedDateLocal]
      ,[cancelApprovedBy]
      ,[blockedDate]
      ,[blockedBy]
      ,[lockedDate]
      ,[lockedDateLocal]
      ,[lockedBy]
      ,[payTokenId]
      ,[sendEOD]
      ,[payEOD]
      ,[cancelEOD]
      ,[tranType]
    )
   SELECT 
	  [id]
	 ,[controlNo]
      ,[sCurrCostRate]
      ,[sCurrHoMargin]
      ,[pCurrCostRate]
      ,[pCurrHoMargin]
      ,[sCurrAgentMargin]
      ,[pCurrAgentMargin]
      ,[sCurrSuperAgentMargin]
      ,[pCurrSuperAgentMargin]
      ,[customerRate]
      ,[sAgentSettRate]
      ,[pDateCostRate]
      ,[serviceCharge]
      ,[handlingFee]
      ,[sAgentComm]
      ,[sAgentCommCurrency]
      ,[sSuperAgentComm]
      ,[sSuperAgentCommCurrency]
      ,[sHubComm]
      ,[sHubCommCurrency]
      ,[pAgentComm]
      ,[pAgentCommCurrency]
      ,[pSuperAgentComm]
      ,[pSuperAgentCommCurrency]
      ,[pHubComm]
      ,[pHubCommCurrency]
      ,[promotionCode]
      ,[promotionType]
      ,[pMessage]
      ,[sCountry]
      ,[sSuperAgent]
      ,[sSuperAgentName]
      ,[sAgent]
      ,[sAgentName]
      ,[sBranch]
      ,[sBranchName]
      ,[pCountry]
      ,[pSuperAgent]
      ,[pSuperAgentName]
      ,[pAgent]
      ,[pAgentName]
      ,[pBranch]
      ,[pBranchName]
      ,[pState]
      ,[pDistrict]
      ,[pLocation]
      ,[paymentMethod]
      ,[pBank]
      ,[pBankName]
      ,[pBankBranch]
      ,[pBankBranchName]
      ,[accountNo]
      ,[collMode]
      ,[collCurr]
      ,[tAmt]
      ,[cAmt]
      ,[pAmt]
      ,[payoutCurr]
      ,[relWithSender]
      ,[purposeOfRemit]
      ,[sourceOfFund]
      ,[tranStatus]
      ,[payStatus]
      ,[createdDate]
      ,[createdDateLocal]
      ,[createdBy]
      ,[modifiedDate]
      ,[modifiedDateLocal]
      ,[modifiedBy]
      ,[approvedDate]
      ,[approvedDateLocal]
      ,[approvedBy]
      ,[paidDate]
      ,[paidDateLocal]
      ,[paidBy]
      ,[cancelRequestDate]
      ,[cancelRequestDateLocal]
      ,[cancelRequestBy]
      ,[cancelReason]
      ,[refund]
      ,[cancelApprovedDate]
      ,[cancelApprovedDateLocal]
      ,[cancelApprovedBy]
      ,[blockedDate]
      ,[blockedBy]
      ,[lockedDate]
      ,[lockedDateLocal]
      ,[lockedBy]
      ,[payTokenId]
      ,[sendEOD]
      ,[payEOD]
      ,[cancelEOD]
      ,[tranType] 
    FROM remitTran
    where  
	   paidDate IS NOT NULL 
	OR cancelApprovedDate IS NOT NULL


    DELETE
    FROM remitTran
    WHERE  
	   paidDate IS NOT NULL 
	OR cancelApprovedDate IS NOT NULL
	
	UPDATE creditLimit SET
		 todaysSent			= 0
		,todaysPaid			= 0
		,todaysCancelled	= 0
		,topUpTillYesterday = topUpToday
		,topUpToday			= 0
	
	UPDATE userWiseTxnLimit SET
		 sendTodays			= 0
		,payTodays			= 0
		,cancelTodays		= 0

COMMIT TRANSACTION



END

GO
