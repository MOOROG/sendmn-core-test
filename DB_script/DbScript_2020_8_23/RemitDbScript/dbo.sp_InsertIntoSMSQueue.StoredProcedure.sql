USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertIntoSMSQueue]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_InsertIntoSMSQueue] (
	@flag						 VARCHAR(10)
	,@user			             VARCHAR(50)		= NULL
	,@msg				         VARCHAR(MAX)		= NULL
	,@country					 VARCHAR(50)        = NULL
	,@email						 VARCHAr(MAX)		= NULL
	,@agentId					 VARCHAR(50)        = NULL
	,@branchId					 VARCHAR(50)        = NULL
	,@mobileNo					 VARCHAR(100)		= NULL
	,@controlNo					 VARCHAR(100)		= NULL
	,@subject   				 VARCHAR(100)		= NULL
	,@tranId				     INT        		= NULL
)
AS

SET NOCOUNT ON
SET XACT_ABORT ON


IF NULLIF(@msg, '') IS NULL
BEGIN
	EXEC proc_errorHandler 1, 'SMS/EMAIL content is Required.', NULL
	RETURN
END

IF @flag='sms'
BEGIN
 	IF @mobileNo IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Mobile No is Required.', NULL
		RETURN
	END
		
	IF LEN(@mobileNo) < 10
	BEGIN
		EXEC proc_errorHandler 1, 'Valid Mobile No is Required.', NULL
		RETURN
	END

	INSERT INTO SMSQueue
	(
		mobileNo
		,msg
		,createdDate
		,createdBy
		,country
		,agentId
		,branchId
		,controlNo
		,tranId
	)
	SELECT
		 @mobileNo
		,@msg
		,GETDATE()
		,@user
		,@country
		,@agentId
		,@branchId
		,@controlNo 
		,@tranId	 
		 
		
END 
ELSE IF @flag='email'
BEGIN
	IF @email IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Email No is Required.', NULL
		RETURN
	END
	INSERT INTO SMSQueue (
		email
		,msg
		,createdDate
		,createdBy
		,country
		,agentId
		,branchId
		,controlNo
		,tranId
		,subject
	)
	SELECT				 
		@email
		,@msg
		,GETDATE()
		,@user
		,@country
		,@agentId
		,@branchId 
		,@controlNo
		,@tranId	
		,@subject			 
			 
END
ELSE IF @flag='both'
BEGIN
	IF @email IS NULL OR @mobileNo IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Mobile No or Email is Required.', NULL
		RETURN
	END

	INSERT INTO SMSQueue (			    
		email
		,msg
		,createdDate
		,createdBy
		,country
		,agentId
		,branchId
		,mobileNo
		,controlNo
		,tranId
		,subject
	)
	SELECT			     
		@email
		,@msg
		,GETDATE()
		,@user
		,@country
		,@agentId
		,@branchId
		,@mobileNo 
		,@controlNo
		,@tranId	
		,@subject  		 
			 
END



GO
