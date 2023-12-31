USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_emailLogs]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_online_emailLogs](
	 @Flag				VARCHAR(50)
	,@RowId				BIGINT			= NULL
	,@ControlNo         VARCHAR(50)     = NULL
	,@Email				VARCHAR(200)    = NULL
	,@SentDate			DATETIME		= NULL
	,@CreatedBy			VARCHAR(30)		= NULL
	,@AgentId			INT				= NULL
	,@BranchId			INT				= NULL
	,@PriorityIndex		INT				= NULL
	,@Country			VARCHAR(200)	= NULL
	,@MobileNo			VARCHAR(20)		= NULL
	,@Subject			VARCHAR(200)	= NULL
	,@Msg				VARCHAR(MAX)	= NULL
	,@Cc				VARCHAR(255)	= NULL
	,@Bcc				VARCHAR(255)	= NULL
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON
BEGIN TRY

IF @flag = 'i'
BEGIN
	INSERT INTO smsQueue(mobileNo
						 ,email
						 ,subject
						 ,msg
						 ,createdDate
						 ,createdBy
						 ,sentDate
						 ,priorityIndex
						 ,country
						 ,agentId
						 ,branchId
						 ,controlNo
						 ,cc
						 ,bcc
						)
						SELECT 
						 @MobileNo
						,@Email
						,@Subject
						,@Msg
						,GETDATE()
						,@CreatedBy
						,@SentDate
						,@PriorityIndex
						,@Country
						,@AgentId
						,@BranchId
						,@ControlNo
						,@Cc
						,@Bcc
				SET @rowId = SCOPE_IDENTITY()
				EXEC proc_errorHandler 0, 'Success', @rowId

END

ELSE IF @flag = 'u'
BEGIN
	UPDATE SMSQueue SET sentDate = GETDATE() WHERE rowId = @rowId
	EXEC proc_errorHandler 0, 'Success', @rowId
END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH
GO
