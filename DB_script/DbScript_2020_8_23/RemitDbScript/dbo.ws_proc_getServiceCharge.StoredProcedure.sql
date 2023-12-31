USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_getServiceCharge]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_proc_getServiceCharge] (  
	 @flag				VARCHAR(50) = NULL  
	,@USER_ID			VARCHAR(50) = NULL  
	,@PASSWORD			VARCHAR(50) = NULL  
	,@AGENT_CODE		VARCHAR(50) = NULL  
	,@AGENT_SESSION_ID	VARCHAR(50) = NULL  
	,@PAYMENT_MODE		VARCHAR(20) = NULL  
	,@PAYOUT_AMOUNT		VARCHAR(20) = NULL  
	,@DISTRICT_ID		VARCHAR(20) = NULL  
)  
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
  
BEGIN TRY     
	DECLARE  
		 @errCode				VARCHAR(100)  
		,@sBranch				VARCHAR(20)		= NULL  
		,@deliveryMethod		VARCHAR(50)		= NULL  
		,@pLocation				INT				= NULL  
		,@serviceCharge			MONEY			= NULL  
		,@sAgentComm			MONEY			= NULL  
		,@sSuperAgentComm		MONEY			= NULL  
		,@deliveryMethodId		INT				= NULL  
		,@pLocationName			VARCHAR(200)	= NULL  

	EXEC proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT  
  
	IF (@errCode = 1)  
	BEGIN  
		EXEC proc_errorHandler 1000 , 'Authentication Fail', NULL   
		RETURN  
	END 
	
	IF @AGENT_SESSION_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'Agent Session Id is Empty' , NULL 
			RETURN
		END 
	
	IF @PAYMENT_MODE IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'Payment Mode Field is Empty' , NULL 
			RETURN
		END
	IF @PAYMENT_MODE <> 'C' AND @PAYMENT_MODE <> 'B'
		BEGIN
            EXEC proc_errorHandler 1105, 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank',NULL
			RETURN
        END 
        
	IF @DISTRICT_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'District Id is Empty' , NULL 
			RETURN
		END
	IF ISNUMERIC(@DISTrICT_ID)=0 AND @DISTRICT_ID IS NOT NULL
		BEGIN
			EXEC proc_errorHandler 1102, 'District Id Must Be Numeric' , NULL 
			RETURN
		END 
	SELECT 
		@sBranch = agentId     
	FROM applicationUsers WITH(NOLOCK)  
	WHERE userName = @USER_ID  
   
 -->> ##  CALCULATING SERVICE CHARGE    
	SET @deliveryMethod = 
		CASE UPPER(@PAYMENT_MODE)
			WHEN 'C' THEN 'Cash Payment' 
			WHEN 'B' THEN 'Bank Deposit' 
		END    
   
	SELECT 
		 @pLocationName = districtName  
		,@pLocation = @DISTRICT_ID   
	FROM api_DistrictList WITH(NOLOCK) 
	WHERE districtCode = @DISTRICT_ID    
   
	SELECT 
		@deliveryMethodId = serviceTypeId   
	FROM serviceTypeMaster WITH(NOLOCK) 
	WHERE typeTitle = @deliveryMethod 
	AND ISNULL(isDeleted, 'N') = 'N'  
   
	SELECT   
		 @serviceCharge  = ISNULL(serviceCharge, 0)  
		,@sAgentComm  = ISNULL(sAgentComm, 0)  
		,@sSuperAgentComm = ISNULL(ssAgentComm, 0)  
	FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @pLocation, @deliveryMethodId, @PAYOUT_AMOUNT)  
   
   
	SELECT  
		 100 errorCode  
		,'Location :' + @pLocationName msg  
		,@AGENT_SESSION_ID AGENT_SESSION_ID   
		,CAST(@PAYOUT_AMOUNT AS MONEY) + @serviceCharge COLLECT_AMT  
		,'NPR' COLLECT_CURRENCY  
		,@serviceCharge SERVICE_CHARGE  
		,@PAYOUT_AMOUNT PAYOUT_AMOUNT  
		,'NPR' PAYOUT_CURRENCY  
  
  
END TRY  
BEGIN CATCH  
	IF @@TRANCOUNT > 0  
	ROLLBACK TRANSACTION  
	EXEC proc_errorHandler 9999, 'Exceptional Error Occured From DB', @USER_ID  
END CATCH  
  


GO
