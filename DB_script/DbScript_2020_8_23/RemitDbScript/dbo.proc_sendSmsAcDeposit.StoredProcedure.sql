USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendSmsAcDeposit]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC proc_sendSmsAcDeposit @flag='sms'
*/
CREATE proc [dbo].[proc_sendSmsAcDeposit] 
(	 
	 @flag	VARCHAR(50)
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON

IF @flag = 'sms'
BEGIN
		-- ## Start Send SMS To Sender
		DECLARE @smsToSender	CHAR(1)
			   ,@sMobile		VARCHAR(100)
			   ,@sAgent			INT
			   ,@tranId			INT
			   ,@maxRows		INT
			   ,@minRows		INT
			   ,@controlNo		VARCHAR(50)
			   ,@pBranch		INT
			   ,@user			VARCHAR(50)
			   ,@sCountry		VARCHAR(200)
	
		IF OBJECT_ID('tempdb..#tempTbl') IS NOT NULL
			DROP TABLE #tempTbl
		
		IF EXISTS(select 'X' from smsQueueAcDepositTxn WITH(NOLOCK))
		BEGIN
			SELECT tranId INTO #tempTbl FROM smsQueueAcDepositTxn WITH(NOLOCK)
			ALTER TABLE #tempTbl ADD rowId INT IDENTITY(1,1)
			SELECT @maxRows = COUNT('X') FROM #tempTbl
			SET @minRows = 1
			WHILE @maxRows >=  @minRows
			BEGIN
				SELECT @tranId = tranId FROM #tempTbl WHERE rowId = @minRows
				SELECT 
					@sMobile = mobile, 
					@sAgent = sAgent,
					@controlNo = dbo.FNADecryptString(controlNO),
					@pBranch = pBranch,
					@user = paidBy,
					@sCountry = sCountry
				FROM remitTran rt WITH(NOLOCK) INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
				WHERE rt.id = @tranId AND rt.paidDate IS NOT NULL

				SELECT 
					@smsToSender = ISNULL(SendSMSToSender,'N') 
				FROM agentBusinessfunction WITH(NOLOCK) WHERE agentId = @sAgent

				IF @smsToSender = 'Y' AND @sMobile IS NOT NULL
				BEGIN
					EXEC proc_SMSData 
						 @flag				= 'SMSToSenderACDeposit'
						,@controlNo			= @controlNo
						,@branchId			= @pBranch
						,@user				= @user
						,@sAgent			= @sAgent
						,@senderMobile		= @sMobile	
						,@sCountry			= @sCountry
				END
				SET @minRows = @minRows+1
			END			
			DELETE FROM smsQueueAcDepositTxn WHERE tranId IN (SELECT tranId FROM #tempTbl)
			DROP TABLE #tempTbl
		END
		
END




GO
