USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_getDistrictList]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_proc_getDistrictList] (
	 @flag						VARCHAR(50) = NULL
	,@USER_ID					VARCHAR(50) = NULL
	,@PASSWORD					VARCHAR(50)	= NULL
	,@AGENT_CODE				VARCHAR(50)	= NULL
	,@AGENT_SESSION_ID			VARCHAR(50)	= NULL
	,@PAYMENT_TYPE				VARCHAR(20) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
-------------------------VALIDATION FOR AUTHENTICATION-------------------------------------
DECLARE @errCode INT
EXEC proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT

	IF (@errCode=1 )
	BEGIN
		EXEC proc_errorHandler 1000 , 'Authentication Fail', NULL 
		RETURN
	END
	
	IF @AGENT_SESSION_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'Agent Session Id is Empty' , NULL 
			RETURN
		END 
	
	IF @PAYMENT_TYPE IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'Payment Type Field is Empty' , NULL 
			RETURN
		END
	IF @PAYMENT_TYPE <> 'C' AND @PAYMENT_TYPE <> 'B'
		BEGIN
            EXEC proc_errorHandler 1105, 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank',NULL
			RETURN
        END

	SELECT 100 ErrorCode,'Success' Msg,districtCode DISTRICT_ID,districtName DISTRICT_NAME 
	FROM API_DISTRICTLIST

----SELECT 
----	 100 ErrorCode
----	,'Success' Msg
----	,id DISTRICT_ID
----	,Name DISTRICT_NAME
----FROM (
----	SELECT 1 id, 'Jhapa' Name UNION ALL 
----	SELECT 2 id, 'Morang' Name UNION ALL
----	SELECT 3 id, 'Sunsari' Name UNION ALL
----	SELECT 4 id, 'Kathmandu' Name UNION ALL
----	SELECT 5 id, 'Bhaktapur' Name 
----) x

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	EXEC proc_errorHandler 9999, 'Exceptional Error Occured From DB', @USER_ID
END CATCH

GO
