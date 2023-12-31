USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[int_proc_payQueue]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[int_proc_payQueue] (
	 @flag VARCHAR(50)
	,@routeId VARCHAR(50) = NULL
	,@xml XML = NULL
	,@processId VARCHAR(50) = NULL
)
AS 
BEGIN TRY
	IF @flag = 's'
	BEGIN
		DECLARE @recordSize INT = 5000
		DECLARE @qSize INT
		SELECT 
			@qSize = COUNT(*) 
		FROM payQueue2 
		WHERE routeId = @routeId
		
		DECLARE @txnList TABLE(
			 controlNo			VARCHAR(50)
			,pAgent				INT 
			,pAgentName			VARCHAR(100)
			,pBranch			INT
			,pBranchName		VARCHAR(100)
			,paidBy				VARCHAR(30)
			,paidDate			DATETIME
			,paidBenIdType		VARCHAR(50)
			,paidBenIdNumber	VARCHAR(50)
		)
		
		INSERT @txnList(controlNo, pAgent, pAgentName, pBranch, pBranchName, paidBy, paidDate, paidBenIdType, paidBenIdNumber) 	
		SELECT TOP (@recordSize) 
			 controlNo
			,pAgent
			,pAgentName
			,pBranch
			,pBranchName
			,paidBy
			,paidDate
			,paidBenIdType
			,paidBenIdNumber
		FROM payQueue2 WITH(NOLOCK)
		WHERE routeId = @routeId
		
		UPDATE p SET 
			 processId	= @processId
			,qStatus	= 'Processing'
		FROM payQueue2 p
		INNER JOIN @txnList tl ON p.controlNo = tl.controlNo 
		
		SELECT 
			 controlNo
			,pAgent
			,pAgentName
			,pBranch
			,pBranchName
			,paidBy
			,paidDate
			,paidBenIdType
			,paidBenIdNumber	
		FROM @txnList
		
		SELECT CASE WHEN @qSize <= @recordSize THEN 'N' ELSE 'Y' END ReProcess
		RETURN
		
	END

	IF @flag = 'rlist'
	BEGIN	
		SELECT 
			 NEWID() Pid
			,routeId  = LTRIM(RTRIM(routeId))
		FROM payQueue2 WHERE routeId <> @routeId
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
			
			INSERT payQueueHistory2(
				 controlNo
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,paidBy
				,paidDate
				,paidBenIdType
				,paidBenIdNumber
				,routeId
				,processId
				,completedAt
				,qStatus
			)
			SELECT 
				 s.controlNo
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,paidBy
				,paidDate
				,paidBenIdType
				,paidBenIdNumber
				,routeId
				,processId
				,GETDATE()
				,'success'
			FROM payQueue2 p 
			INNER JOIN #syn s ON p.controlNo = s.controlNo
			
			DELETE p 
			FROM payQueue2 p 
			INNER JOIN #syn s ON p.controlNo = s.controlNo
		
		IF @@TRANCOUNT>0	
		COMMIT TRANSACTION	
		SELECT 0 errorCode, 'Processed sync logs successfully.' Msg, @processId Id
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
