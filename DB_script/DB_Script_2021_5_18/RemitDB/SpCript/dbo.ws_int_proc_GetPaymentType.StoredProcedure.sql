USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetPaymentType]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_GetPaymentType]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_GetPaymentType

GO
*/
 --EXEC ws_proc_GetPaymentType @AGENT_CODE = 'MYHQ01', @USER_ID = 'api001', @PASSWORD = 'ime@9999',@AGENT_SESSION_ID='1234567',@PAYOUT_COUNTRY='NEPAL'

CREATE proc [dbo].[ws_int_proc_GetPaymentType](	 
	 @AGENT_CODE			VARCHAR(50)
	,@USER_ID				VARCHAR(50)
	,@PASSWORD				VARCHAR(50)
	,@AGENT_SESSION_ID		VARCHAR(150)
	,@PAYOUT_COUNTRY		VARCHAR(50)
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
		DECLARE @apiRequestId BIGINT
		INSERT INTO requestApiLogOther(
		AGENT_CODE			
		,USER_ID 			
		,PASSWORD 			
		
		,AGENT_SESSION_ID
		,PAYOUT_COUNTRY
		,METHOD_NAME
		,REQUEST_DATE


		)
		SELECT
		@AGENT_CODE				
		,@USER_ID 			
		,@PASSWORD 			
		
		,@AGENT_SESSION_ID
		,@PAYOUT_COUNTRY	
		,'ws_int_proc_GetPaymentType'
		,GETDATE()

		SET @apiRequestId = SCOPE_IDENTITY()	

	DECLARE @errCode INT
	DECLARE @autMsg	VARCHAR(500)
	EXEC ws_int_proc_checkAuthntication @USER_ID, @PASSWORD, @AGENT_CODE, @errCode OUT, @autMsg OUT

	DECLARE @errorTable TABLE(AGENT_TXN_REF_ID VARCHAR(150),PAYMENT_TYPE CHAR(1),PAYMENT_DESCRIPTION VARCHAR(100),ANYWHERE_ALLOWED CHAR(1))

	INSERT INTO @errorTable (AGENT_TXN_REF_ID)
	SELECT @AGENT_SESSION_ID

	IF(@errCode = 1)
	BEGIN
		SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
		SELECT '1002' CODE, 'You are required to change your password!' MESSAGE, * FROM @errorTable
		RETURN
	END
	------------------VALIDATION-------------------------------
	IF @PAYOUT_COUNTRY IS NULL
	BEGIN
		SELECT '1001' CODE, 'PAYOUT COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT SESSION ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END

	DECLARE		
		@sCountryId		INT, 
		@sBranch		INT,
		@sAgent			INT,
		@pcountryId		INT

	-->>PICK AGENTID ,COUNTRY FROM USER
	SELECT 
		@sCountryId = au.countryId, 
		@sBranch = au.agentId,
		@sAgent = sb.parentId
	FROM applicationUsers au WITH(NOLOCK)
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON au.agentId = sb.agentId
	WHERE userName = @USER_ID AND ISNULL(au.isDeleted, 'N') = 'N'
	
	SELECT @pcountryId  = countryId FROM countryMaster WITH (NOLOCK) WHERE countryName = @PAYOUT_COUNTRY
	
	IF NOT EXISTS(
		SELECT 
			'X'
		FROM countryReceivingMode crm WITH(NOLOCK) 
		INNER JOIN  sendTranLimit SL WITH (NOLOCK) 
			ON crm.countryId = SL.receivingCountry 
			AND SL.receivingCountry = @pcountryId
			AND SL.countryId = @sCountryId 
		WHERE SL.agentId IS  NULL
		AND receivingAgent IS NULL
		AND ISNULL(isActive,'N')='Y'
		AND ISNULL(isDeleted,'N')='N'
	)
	BEGIN
		SELECT '3008' CODE, 'You are not allowed to send to country '+ @PAYOUT_COUNTRY MESSAGE, * FROM @errorTable
		RETURN;
	END

	SELECT 
		 PAYMENT_TYPE			= CASE 
									WHEN serviceTypeId = 1 THEN 'c' 
									WHEN serviceTypeId = 2 THEN 'b' 								
								END
		,PAYMENT_DESCRIPTION	= UPPER(typetitle)
		,ANYWHERE_ALLOWED
		,CODE					= '0'
		,MESSAGE				= 'Success'
		,AGENT_TXN_REF_ID		= @AGENT_SESSION_ID
	FROM serviceTypeMaster stm WITH (NOLOCK)
	INNER JOIN (
		-->>Receiving Mode Checking Countrywise For Payment Type ALL
		SELECT
			receivingMode, maxLimitAmt, CASE WHEN ISNULL(crm.agentSelection, 'X') IN ('O','N') THEN 'Y' ELSE 'N' END ANYWHERE_ALLOWED 
		FROM countryReceivingMode crm WITH(NOLOCK) 
		INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
		WHERE SL.countryId = @sCountryId AND SL.receivingCountry = @pcountryId
		AND SL.agentId IS NULL AND SL.tranType IS NULL AND receivingAgent IS NULL
		--AND SL.currency = @currency

		UNION ALL
		 
		-->>Receiving Mode Checking AgentWise For Payment Type ALL
		SELECT 
			receivingMode, maxLimitAmt, CASE WHEN ISNULL(crm.agentSelection, 'X') IN ('O','N') THEN 'U' ELSE 'N' END ANYWHERE_ALLOWED 
		FROM countryReceivingMode crm WITH(NOLOCK) 
		INNER JOIN sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
		AND SL.receivingCountry = @pcountryId AND SL.countryId = @sCountryId 
		WHERE agentId = @sAgent
		AND SL.tranType IS NULL
		AND receivingAgent IS NULL
		AND ISNULL(isActive,'N') = 'Y'
		AND ISNULL(isDeleted,'N') = 'N'

		UNION ALL
		 
		-->>Receiving Mode Checking Countrywise For Payment Type Specific
		SELECT tranType, MAX(maxLimitAmt) maxLimitAmt, CASE WHEN ISNULL(crm.agentSelection, 'X') IN ('O','N') THEN 'Y' ELSE 'N' END ANYWHERE_ALLOWED 
		FROM countryReceivingMode crm WITH(NOLOCK) 
		INNER JOIN  sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
		WHERE sl.countryId = @sCountryId 
		AND SL.receivingCountry = @pcountryId
		AND ISNULL(isActive,'N') = 'Y'
		AND ISNULL(isDeleted,'N') = 'N'
		AND SL.agentId IS NULL
		--AND ISNULL(collmode, ISNULL(@collectionmode, 0)) = ISNULL(@collectionmode, 0)
		--AND ISNULL(customerType, ISNULL(@customerType,0)) = ISNULL(@customerType, 0)
		AND SL.tranType IS NOT NULL
		AND SL.receivingAgent IS NULL
		--AND SL.currency = @currency  
		GROUP BY tranType, agentSelection
		  
		UNION ALL

		-->>Receiving Mode Checking AgentWise For Payment Type Specific
		SELECT tranType, MAX(maxLimitAmt) maxLimitAmt, CASE WHEN ISNULL(crm.agentSelection, 'X') IN ('O','N') THEN 'y' ELSE 'n' END ANYWHERE_ALLOWED 
		FROM countryReceivingMode crm WITH(NOLOCK) 
		INNER JOIN sendTranLimit SL WITH (NOLOCK) ON crm.countryId = SL.receivingCountry 
		WHERE sl.countryId = @sCountryId 
		AND SL.receivingCountry = @pcountryId
		AND SL.agentId = @sAgent
		AND ISNULL(isActive,'N') = 'Y'
		AND ISNULL(isDeleted,'N') = 'N'
		AND receivingAgent IS NULL
		--AND ISNULL(collmode, ISNULL(@collectionmode, 0)) = ISNULL(@collectionmode, 0)
		--AND ISNULL(customerType, ISNULL(@customerType, 0)) = ISNULL(@customerType, 0)
		AND SL.tranType IS NOT NULL
		AND SL.receivingAgent IS NULL
		--AND SL.currency = @currency
		GROUP BY tranType, agentSelection
	) X
	ON  X.receivingMode = stm.serviceTypeId
	WHERE ISNULL(STM.isActive,'N') = 'Y' AND ISNULL(STM.isDeleted,'N') = 'N'
	--AND (STM.serviceTypeId NOT IN (3,5))
	AND STM.serviceTypeId IN (1,2,3)
	GROUP BY serviceTypeId, typetitle, ANYWHERE_ALLOWED
	HAVING MIN(X.maxLimitAmt) > 0
	ORDER BY serviceTypeId ASC

	UPDATE requestApiLogOther SET 
			errorCode = '0'
		,errorMsg = 'Success'			
	WHERE rowId = @apiRequestId

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRAN
SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, * FROM @errorTable
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error', 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, 'ws_proc_GetPaymentType', @USER_ID, GETDATE()
END CATCH

GO
