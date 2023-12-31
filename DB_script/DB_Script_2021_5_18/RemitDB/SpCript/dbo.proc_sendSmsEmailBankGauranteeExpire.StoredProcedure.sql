USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendSmsEmailBankGauranteeExpire]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_sendSmsEmailBankGauranteeExpire](
	@flag VARCHAR(30)=NULL
)AS
SET XACT_ABORT ON
SET NOCOUNT ON
BEGIN
		
	DECLARE @currDate date,@before15Days date
	SET @currDate=convert(date,GETDATE(),101)	
	SET @before15Days=convert(date,DATEADD(DAY,-15,@currDate),101)
	---select @currDate,@before15Days

	IF OBJECT_ID('tempdb..#smsTemp') IS NOT NULL
		DROP TABLE #smsTemp
	IF OBJECT_ID('tempdb..#notSend') IS NOT NULL
		DROP TABLE #notSend
	IF OBJECT_ID('tempdb..#tempbank') IS NOT NULL
		DROP TABLE #tempbank


	--select * from SMSQueue where msg like '%bank Guarantee%'
	--delete from SMSQueue where msg like '%bank Guarantee%'
	SELECT DISTINCT agentId,sentDate INTO #smsTemp FROM SMSQueue (NOLOCK) WHERE msg like '%bank Guarantee%'

	SELECT * INTO #notSend FROM 
	(
		SELECT 
			 bank.agentId agentId
			,bank.guaranteeNo guaranteeNo
			,bank.bgId bgId
			,bank.amount amount
			,bank.bankName bankName
			,CONVERT(date,bank.issuedDate,101) issuedDate
			,CONVERT(date,bank.expiryDate,101) expiryDate
			,CONVERT(date,bank.followUpDate,101) followUpDate
			,sms.agentId as smsAgentId
		FROM bankGuarantee (NOLOCK) bank 
		left join #smsTemp sms on bank.agentId=sms.agentId
		WHERE sms.agentId is null OR dateDiff(DAY,sentDate,getdate())>=7
		--AND other condition Goes here
	) x


	SELECT 							
		 agentName= am.agentName
		,agentId=am.agentId	
		,branchId=am.agentId		
		,[Guarantee No.] = bg.guaranteeNo
		,Amount  = bg.amount
		,BankName = bg.bankName
		,issuedDate = convert(date,bg.issuedDate,101)
		,expiryDate = convert(date,bg.expiryDate,101)
		,followUpDate = convert(date,bg.followUpDate,101)
		,agentMobile=am.agentMobile1
		,agentEmail=am.agentEmail1
		,smsMsg='Dear IME Agent, Your Bank Guarantee is going to expire on '+convert(varchar,bg.expiryDate,101)+'. Kindly proceed to renew.IME Ltd'

		,emailMsg='Dear IME Agent <strong>'+am.agentName+'</strong>,
				<br /><br />Your Bank Guarantee is going to expire on <strong>'+convert(varchar,bg.expiryDate,101)+'</strong>. <br/>Kindly proceed to renew.
				<br />Please contact IME Sales Department for further support and assistance.<br/>IME Ltd<br/><br/><br/><br/><br/><br/><br/><br/>'
		INTO #tempbank 
		FROM dbo.agentMaster am WITH(NOLOCK) 			
		INNER JOIN #notSend bg WITH(NOLOCK) ON am.agentid = bg.agentId
		WHERE am.isSettlingAgent = 'Y' 
		AND (agentType = 2903 or agentType =2904) 
		and am.agentCountry ='Nepal'
		and am.parentId <> 5576
		AND followUpDate=@currDate OR convert(date,DATEADD(DAY,-15,expiryDate),101)=@currDate
		
		--select @currDate,@before15Days
		
		INSERT INTO SMSQueue(mobileNo,msg,createdDate,createdBy,country,agentId,branchId)
		SELECT agentMobile,smsMsg,GETDATE(),'admin','Nepal',agentId,branchId FROM #tempbank 
		--WHERE followUpDate=@currDate OR convert(varchar,DATEADD(DAY,-15,expiryDate),101)=@currDate

		INSERT INTO SMSQueue(email,subject,msg,createdDate,createdBy,country,agentId,branchId)
		SELECT agentEmail,'Bank Guarantee Expiry Notification',emailMsg,GETDATE(),'admin','Nepal',agentId,branchId FROM #tempbank 
		--WHERE followUpDate=@currDate OR convert(varchar,DATEADD(DAY,-15,expiryDate),101)=@currDate

		--add record to email admins		

		DECLARE @adminEmailText NVARCHAR(MAX);
		SELECT @adminEmailText = COALESCE(@adminEmailText + '<br/>', '') + emailMsg
		FROM #tempbank 

		INSERT INTO SMSQueue(email,subject,msg,createdDate,createdBy,country,agentId,branchId)
		SELECT email,'Bank Guarantee Expiry Notification',@adminEmailText as emailMsg,GETDATE() createdDate,'admin' createdBy,'Nepal' country,agent agentId,agent branchId 
		FROM SystemEmailSetup 
		WHERE isbankGuaranteeExpiry='Yes' 
		AND isnull(isDeleted,'N')='N'
END

GO
