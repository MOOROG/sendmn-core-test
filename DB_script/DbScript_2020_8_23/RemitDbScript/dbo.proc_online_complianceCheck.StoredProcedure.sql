USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_complianceCheck]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_online_complianceCheck]
(  
    @flag				VARCHAR(50) 
  , @user				VARCHAR(100) 
  , @senderId			VARCHAR(50) = NULL 
  , @benId				VARCHAR(50) = NULL 
  , @rMobile			VARCHAR(20) = NULL 
  , @raccountNo			VARCHAR(50) = NULL 
  , @pCountryId			INT			= NULL 
  , @deliveryMethod		VARCHAR(50) = NULL 
  , @deliveryMethodId	INT			= NULL 
  , @sBranch			INT			= NULL 
  ,	@pBranch			INT			= NULL 
  , @agentRefId			VARCHAR(50) = NULL 
  , @collCurr			VARCHAR(3)  = NULL 
  ,	@sIdType			VARCHAR(30)	= NULL
  , @sIdNo				VARCHAR(25) = NULL
  ,	@rfName				VARCHAR(80)	= NULL
  , @cAmt				MONEY		= NULL
  , @sCountry			VARCHAR(30)	= NULL
  , @pCountry			VARCHAR(30)	= NULL
  , @sMobile			VARCHAR(25)	= NULL
  , @senderName VARCHAR(100) 
)

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	BEGIN
	DECLARE  @pStateId INT
			,@totalRows INT 
			,@count INT 
			,@id INT 
			,@tAmt MONEY = NULL 
			,@csMasterId INT 
			,@complianceRes VARCHAR(20) 
			
			,@collModeDesc VARCHAR(50)
			,@compFinalRes VARCHAR(20)
			,@errorCode VARCHAR(5)
			,@msg VARCHAR(MAX)

	IF @collCurr <> 'GBP'
		BEGIN
			SET @sBranch = '32916';
		END;
	ELSE
		BEGIN
			SET @sBranch = '32915';				
		END;

	IF @flag = 'complianceCheck'
	BEGIN
		DECLARE @complianceRuleId INT, @complienceMessage VARCHAR(1000), @shortMsg VARCHAR(150), @complienceErrorCode INT
  
		EXEC [proc_complianceRuleDetail] 
		   @user    = @user
		   ,@sIdType   = @sIdType
		   ,@sIdNo    = @sIdNo
		   ,@receiverName  = @rfName
		   ,@cAmt    = @cAmt
		   ,@country   = @sCountry
		   ,@message   = @complienceMessage OUTPUT
		   ,@shortMessage  = @shortMsg    OUTPUT
		   ,@errCode   = @complienceErrorCode OUTPUT
		   ,@ruleId   = @complianceRuleId  OUTPUT
    
		IF(@complienceErrorCode <> 0)
		BEGIN  
			IF(@complienceErrorCode = 1)
			BEGIN
				SET @errorCode=101
				--SELECT 101 errorCode,@msg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
			END 
			ELSE 
			BEGIN
				SET @errorCode=102
				INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
				SELECT @complianceRuleId, NULL, @agentRefId

				--SELECT 102 errorCode,@msg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
			END
   
			INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName, receiverCountry, payOutAmt,
			complianceId, complianceReason, complainceDetailMessage, createdBy, createdDate, logType)

			SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @rfName, @pCountry, @cAmt, @complianceRuleId, @shortMsg, @complienceMessage, @user, GETDATE(),
			'online'

			DECLARE @tempRowId INT = @@IDENTITY

			SELECT @errorCode errorCode
				,complianceReason msg
				, id 
				,CASE WHEN @errorCode=102 THEN 'HOLD' ELSE 'Blocked' END vtype 
			FROM ComplianceLog 
			WHERE id = @tempRowId
			
			--SELECT
			--	@errorCode
			--	,csDetailRecId = ''
			--	,[S.N.]  = ROW_NUMBER()OVER(ORDER BY id) 
			--	,[Remarks] = complianceReason
			--	,[Action] = CASE WHEN @complienceErrorCode=102 THEN 'HOLD' ELSE 'Blocked' END
			----,[Matched Tran ID] = ''
			--FROM ComplianceLog 
			--WHERE id = @tempRowId
			RETURN
		END
		ELSE   
		BEGIN
			SELECT 0 errorCode,'Success' msg, 0 id
		END
	END
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
		
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	
	EXEC proc_errorHandler 1, @errorMessage, @user
	
END CATCH		
GO
