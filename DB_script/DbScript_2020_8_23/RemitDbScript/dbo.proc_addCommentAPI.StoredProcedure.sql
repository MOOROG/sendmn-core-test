USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_addCommentAPI]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_addCommentAPI] (
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
	,@tranId			INT				= NULL
	,@message			VARCHAR(200)	= NULL
	,@sendSmsEmail		VARCHAR(10)		= NULL
)
AS

DECLARE
	 @sAgent			INT
	,@tAmt				MONEY
	,@cAmt				MONEY
	,@pAmt				MONEY

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	
EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT
DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.dbo.FNAENCRYPTSTRING(@controlNo)




DECLARE 
	 @msg VARCHAR(MAX)
	,@mobileNo	 VARCHAR(100)
	,@country	 VARCHAR(100)
	,@branchId   VARCHAR(100)
	,@agentId	 VARCHAR(100)
	,@email      VARCHAR(100)
	,@subject    VARCHAR(100)
	,@agentName	 VARCHAR(100)
	,@branchName VARCHAR(100)

--IF @message IS NOT NULL
--BEGIN
--	SET @msg= 'Dear Customer, '+@message+' '+'Please confirm the detail and visit sending agent,if modification required.'    
	
			
--	--Check Mobile No and Email
--	SELECT 
--		@mobileNo=ts.mobile,@country=ts.country  
--	FROM RemitTran rt (NOLOCK)
--	INNER JOIN tranSenders ts (NOLOCK) on rt.id = ts.tranId
--	WHERE rt.controlNo=dbo.dbo.FNAENCRYPTSTRING(@controlNo) AND ts.mobile IS NOT NULL
		
--	SET @subject='Trouble Ticket'			
	
--	SELECT 
--			@agentId=rt.sAgent
--		,@agentName=am.agentName
--		,@branchId=rt.sBranch  
--	FROM remitTran rt 
--	INNER JOIn tranSenders ts (NOLOCK) on ts.tranId=rt.id
--	INNER JOIn agentMaster am (NOLOCK) on am.agentId=rt.sAgent 
--	WHERE rt.id=@tranId

--	SELECT 
--		@branchName= am.agentName 
--	FROM remitTran rt (NOLOCK)
--	INNER JOIn tranSenders ts (NOLOCK) on ts.tranId=rt.id  
--	INNER JOIN agentMaster am (NOLOCK) on am.agentId=rt.sBranch
--	WHERE rt.id=@tranId AND agentType = '2904' 
		

		
		    
--		SET @email=
--				(
--					SELECT am.agentEmail1 
--					FROM remitTran rt  (NOLOCK)
--					INNER JOIN agentMaster am  (NOLOCK) ON rt.sAgent=am.agentId
--					WHERE rt.id=@tranId and am.agentEmail1 IS NOT NULL
--				)

--		DECLARE @emailContent VARCHAR(MAX)			
--		SET @emailContent='Dear<strong>' +' ' + @agentName  +' - ' + @branchName +'</strong>, <br/><br/>Following message has been raised from IME.<br/>" '+@message +'"<br/><br/>' +'ICN:'+' '+@controlNo+'
--		<br/>Please email to <a href="javascript:void(0);"> support@imeremit.com.np </a>  for any queries.<br/><br/>Thank you, <br/>IME Support Team <br/><br/><br/><br/>'

--END
	     

--Add Comment API----------------------------------------------------------------------------------------------------
IF @flag = 'i'
BEGIN
	EXEC proc_errorHandler 0, 'SUCCESS.', @password

	IF (@sendSmsEmail='sms')
	BEGIN
		 
		SELECT @mobileNo = mobile FROM tranSenders(nolock) WHERE TRANID = @tranId
		SELECT @message = LEFT(@message,90),@mobileNo = ISNULL(@mobileNo,'')

		EXEC sp_InsertIntoSMSQueue 'sms' ,@user ,@message,@country,NULL,@agentId ,@branchId ,@mobileNo	,@controlNo,NULL,@tranId
		EXEC proc_errorHandler 0,' ',@email

		EXEC proc_CallToSendSMS @FLAG = 'I',@SMSBody = @message,@MobileNo = @mobileNo

		RETURN					
	END
			
	IF (@sendSmsEmail='email' OR @sendSmsEmail='both') AND @email IS NOT NULL
	BEGIN				
		EXEC sp_InsertIntoSMSQueue 'email' ,@user,@message, @country,@email,@agentId ,@branchId ,NULL,@controlNo , @subject,@tranId	
		EXEC proc_errorHandler 0,' ',@email
		RETURN					
	END
	 RETURN 						  
END										 	


GO
