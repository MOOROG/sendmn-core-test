USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_SMSQueue]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_SMSQueue] (
	 @flag VARCHAR(50)
	,@rowId BIGINT = NULL
)

AS

IF @flag = 'u'
BEGIN
	UPDATE SMSQueue SET
		 sentDate = GETDATE()
		,isInProcess = 0
	WHERE rowId = @rowId
	SELECT 0 errorCode, 'SMS has been Sent Sucessfully' Msg, @rowId Id
	RETURN;
END

IF @flag = 's'
BEGIN
	DECLARE @t TABLE(t_RowID bigint PRIMARY KEY)

	INSERT @t
	SELECT 
		 rowId		
	FROM SMSQueue WITH(NOLOCK)
	WHERE sentDate IS NULL AND (isInProcess IS NULL OR isInProcess = 0)
	
	
	UPDATE q SET q.isInProcess = 1
	FROM SMSQueue q
	INNER JOIN @t t ON q.rowId = t.t_RowID

	SELECT
		 rowId
		,mobileNo = CASE WHEN LEN(mobileNo) = 10 AND (mobileNo LIKE '98%' OR mobileNo LIKE '97%') THEN '977' + mobileNo ELSE mobileNo END
		,msg
		,email		
		,subject
	FROM SMSQueue WITH(NOLOCK)
	INNER JOIN @t t ON SMSQueue.rowId = t.t_RowID	
	ORDER BY priorityIndex ASC
	RETURN;
END




GO
