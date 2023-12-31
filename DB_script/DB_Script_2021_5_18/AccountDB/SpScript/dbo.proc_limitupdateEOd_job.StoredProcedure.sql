USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_limitupdateEOd_job]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_limitupdateEOd_job]
AS
SET NOCOUNT ON;
BEGIN

    UPDATE agentTable SET todaysSend =0, todaysPaid =0
	   ,todaysCancel=0, todaysEP=0, todaysPO=0

    UPDATE cl SET
	   cl.topUpTillYesterday = CASE WHEN v.clr_bal_amt >= 0 THEN 0 ELSE
		   (CASE WHEN v.clr_bal_amt * (-1) > ISNULL(cl.limitAmt, 0) THEN (v.clr_bal_amt * (-1) - ISNULL(cl.limitAmt, 0)) ELSE 0 END)
		  END
	   ,cl.yesterdaysBalance = v.clr_bal_amt
	   
	FROM SendMnPro_Remit.dbo.creditLimit cl WITH(NOLOCK)
	INNER JOIN SendMnPro_Remit.dbo.agentMaster am WITH(NOLOCK) ON cl.agentId = am.agentId
	INNER JOIN vWAgentClrBal v ON v.map_code = am.mapCodeInt

	-- ## Limit Restet.
	UPDATE SendMnPro_Remit.dbo.creditLimit SET
       todaysSent   = 0
      ,todaysPaid   = 0
      ,todaysCancelled = 0
      ,topUpToday   = 0
	  ,todaysAddedMaxLimit = 0
	  ,todaysEPI = 0
	  ,todaysPOI = 0

     -- ## User Wise Limit Restet.
	UPDATE SendMnPro_Remit.dbo.userWiseTxnLimit SET
      sendTodays   = 0
     ,payTodays   = 0
     ,cancelTodays  = 0
	 
    UPDATE SendMnPro_Remit.dbo.tranViewAttempt 
    SET continuosAttempt = 0, wholeDayAttempt = 0 

    TRUNCATE TABLE SendMnPro_Remit.dbo.tempRemitTran 

	-- ## Reset Limit IF Bank Guatantee is expired or going to expire after 7 days.
	DECLARE 
		@today		DATETIME = DATEADD(DAY,7,CONVERT(VARCHAR, GETDATE(), 101)),
		@lastBgId	BIGINT

	UPDATE SendMnPro_Remit.dbo.creditLimit SET 
		limitAmt = 0,
		topUpToday = 0
	FROM SendMnPro_Remit.dbo.creditLimit cr,
	(
			SELECT DISTINCT cr.agentId 
			FROM SendMnPro_Remit.dbo.creditLimit cr WITH(NOLOCK) 
			INNER JOIN SendMnPro_Remit.dbo.bankGuarantee bg WITH(NOLOCK) ON cr.agentId = bg.agentId
			WHERE bg.expiryDate < @today
			AND ISNULL(bg.isDeleted,'N') <>'Y'
			AND ISNULL(bg.isActive,'Y')<>'N'
			AND ISNULL(cr.limitAmt,0) > 0
	)t WHERE cr.agentId = t.agentId

END









GO
