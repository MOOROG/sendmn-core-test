USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_addCommentAPI_122315]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_addCommentAPI_122315] (
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
	,@tranId			INT				= NULL
	,@message			VARCHAR(200)	= NULL
	,@sendSmsEmail		VARCHAR(10)			= NULL
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
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)




DECLARE @msg VARCHAR(MAX)
		,@mobileNo	 VARCHAR(100)
		,@country	 VARCHAR(100)
		,@branchId   VARCHAR(100)
		,@agentId	 VARCHAR(100)
		,@email      VARCHAR(100)
		,@subject    VARCHAR(100)
		SET @msg= 'Dear Customer,ICN('+@controlNo+'):'+' '+@message+' '+'Please confirm the detail and visit sending agent,if modification required.'
        SET @mobileNo =(SELECT mobile FROM tranSenders WHERE tranId = @tranId)
		SET @country =(SELECT country FROM tranSenders WHERE tranId = @tranId)	
		
		 SELECT 
		   @agentId=rt.sAgent
		  ,@branchId=rt.sBranch  from remitTran rt 
		  INNER JOIn tranSenders ts on ts.tranId=rt.id  WHERE tranid=@tranId

		
		    
		   SET @email=
		    (
			   SELECT am.agentEmail1 FROM remitTran rt
			   INNER JOIN agentMaster am ON rt.sAgent=am.agentId
			   WHERE rt.id=@tranId)
	     

--Add Comment API----------------------------------------------------------------------------------------------------
IF @flag = 'i'
BEGIN
	EXEC proc_errorHandler 0, 'SUCCESS.', @password

	IF @sendSmsEmail iS NOT NULL
	BEGIN
		IF @sendSmsEmail='sms'		   
		BEGIN
			EXEC sp_InsertIntoSMSQueue 'sms' ,@user ,@msg,@country,NULL,@agentId ,@branchId ,@mobileNo	,@controlNo,NULL,@tranId
			RETURN
		END
		ELSE IF @sendSmsEmail='email'
		BEGIN
			EXEC sp_InsertIntoSMSQueue 'email' ,@user ,@msg,@country,@email,@agentId ,@branchId ,NULL,@controlNo , @subject,@tranId
			RETURN
		END
	   ELSE IF @sendSmsEmail='both'		   
			BEGIN
				EXEC sp_InsertIntoSMSQueue 'both' ,@user ,@msg,@country,@email,@agentId ,@branchId ,@mobileNo,@controlNo,@subject,@tranId									
				EXEC proc_errorHandler 0,' ',@user
				RETURn					
			END
	END
	 RETURN 
									 
										  
END										 	
										 	
----------------------------------------------------------------------------------------------------------------


 


GO
