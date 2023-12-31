USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payQueue]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_payQueue] (
	 @flag VARCHAR(50)
	,@routeId VARCHAR(50) = NULL
	,@xml XML = NULL
	,@processId VARCHAR(50) = NULL
)
AS
BEGIN TRY
	IF @flag = 's'
	BEGIN

		DECLARE @recordSize INT = 10
		DECLARE @qSize INT
		SELECT 
			@qSize = COUNT(*) 
		FROM payQueue 
		WHERE routeId = @routeId
		
		DECLARE @txnList TABLE(
			 controlNo	VARCHAR(50)
			,paidBy VARCHAR(30)
			,paidLocation VARCHAR(100)
			,paidDate DATETIME
			,paidDateUSDRate VARCHAR(50)
			,paidBeneficiaryIDtype VARCHAR(50)
			,paidBeneficiaryIDNumber VARCHAR(50)
			,rAgentID VARCHAR(50)
			,rBankBranch VARCHAR(300)
		)
		
		INSERT @txnList 	
		SELECT TOP (@recordSize) 
			 controlNo
			,paidBy
			,paidLocation
			,paidDate 
			,paidDateUSDRate 
			,paidBeneficiaryIDtype
			,paidBeneficiaryIDNumber
			,rAgentID
			,rBankBranch
		FROM payQueue WITH(NOLOCK)
		WHERE routeId = @routeId
		
		UPDATE p SET 
			 processId = @processId
			,qStatus = 'Processing'
		FROM payQueue p
		INNER JOIN @txnList tl ON p.controlNo = tl.controlNo 
		
		SELECT 
			*		
		FROM @txnList
		
		SELECT 'N' ReProcess
		RETURN
		
	END

	IF @flag = 'rlist'
	BEGIN	
		SELECT 
			 NEWID() Pid
			,routeId 
		FROM payQueue WHERE routeId <> @routeId
		GROUP BY routeId
		RETURN

	END

	IF @flag = 'syn'
	BEGIN
		SELECT
			 controlNo = p.value('@controlNo','VARCHAR(50)')
		INTO #syn
		FROM @xml.nodes('/root/row') AS tmp(p)	

		BEGIN TRANSACTION		
			
			INSERT payQueueHistory(controlNo, routeId, processId, qStatus, completedAt)
			SELECT 
				s.controlNo, routeId, @processId,'Success',GETDATE() 
			FROM payQueue p 
			INNER JOIN #syn s ON p.controlNo = s.controlNo
			
			DELETE p 
			FROM payQueue p 
			INNER JOIN #syn s ON p.controlNo = s.controlNo
		
		IF @@TRANCOUNT>0	
		COMMIT TRANSACTION	

		SELECT 0 errorCode, 'Processd sync logs successfully.' Msg, @processId Id
		RETURN
	END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0	
	ROLLBACK TRANSACTION	
	SELECT 1 errorCode, ERROR_MESSAGE() Msg, NULL Id
	SELECT 1 errorCode, ERROR_MESSAGE() Msg, NULL Id
END CATCH

GO
