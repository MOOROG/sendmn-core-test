USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetNumber_LuckyDraw]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_GetNumber_LuckyDraw]
	 @flag		CHAR(1) = 's'
	,@user		VARCHAR(50)   
	
AS
SET NOCOUNT ON;
/*

EXEC [proc_GetNumber_LuckyDraw] @flag='s' ,@user='admin'
*/
DECLARE
	 @fromDate DATETIME, @toDate DATETIME,@sCountry VARCHAR(100), @sAgent VARCHAR(100), @sAgent1 VARCHAR(100)
	,@pAgent1 VARCHAR(100), @pAgent2 VARCHAR(100), @pAgent3 VARCHAR(100), @pAgent4 VARCHAR(100), @pAgent5 VARCHAR(100)
	,@luckyDrawType VARCHAR(50), @controlNo VARCHAR(20), @id BIGINT,@prize VARCHAR(50)
	,@dateField VARCHAR(50), @drawTypeCode CHAR(1)

	SELECT @luckyDrawType = 'Sender_NewYear',@drawTypeCode='NY'

	SET @prize= CASE @luckyDrawType 
					WHEN  'Sender_NewYear'    THEN 'KRW 2,075,000 '
					ELSE 'Unknown'
				END

	SET @drawTypeCode= CASE @luckyDrawType 
					WHEN  'Sender_NewYear'    THEN 'NY'
					ELSE 'Unknown'
				END

IF(SELECT COUNT(1) FROM WinnerHistory(NOLOCK))=3
BEGIN
	SELECT 
			 ErrorCode = '0'
			,Pin = dbo.FNADecryptString(rt.controlNo)			
			,Name = rt.senderName
			,[Date] = CONVERT(VARCHAR, rt.approveddate, 107) 
			,Prize = @prize
			,Agent = rt.sAgentName
			,Country  = rt.pCountry			
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN WinnerHistory ts WITH(NOLOCK) ON rt.id = ts.id	
		order by ts.drawnDate	
		RETURN
END
	DECLARE @luckyNumbers TABLE(Id bigint, controlNo VARCHAR(20))
		
	INSERT INTO @luckyNumbers(Id, controlNo)	
	SELECT  Id,controlNo
	FROM remitTran rt WITH(NOLOCK)	
	WHERE approvedDate BETWEEN '2018-03-28' AND '2018-04-30 23:59:59'
	AND pCountry = 'Nepal'
	AND tranStatus <> 'cancel'

	DELETE FROM @luckyNumbers 						
	FROM @luckyNumbers t
	INNER JOIN WinnerHistory h (NOLOCK) ON t.Id = h.Id

	SELECT TOP 1
		@controlNo = controlNo, @id = Id
	FROM (
		SELECT TOP 90 PERCENT
			IDL2 = NEWID(),*
		FROM (
			SELECT
				IDL = NEWID(), *
			FROM @luckyNumbers
		) round1 ORDER BY IDL ASC
	) round2  ORDER BY IDL2 ASC
	

IF @controlNo IS NULL
BEGIN
	SELECT 
		 ErrorCode = '0'
		,Pin = 'ERROR'
		,Name = 'ERROR'		
		,Date = 'ERROR'
		,Prize = @luckyDrawType
		,Agent = 'ERROR'
		,Country  = 'ERROR'
		RETURN
END
ELSE
BEGIN
	INSERT INTO WinnerHistory(ID,controlNo, drawnDate,createdBy, srFlag, drawType)
	SELECT @id,@controlNo, GETDATE(),@user, @flag, @drawTypeCode
	BEGIN
		SELECT 
			 ErrorCode = case when @controlNo = rt.controlNo then '1' else '0' end
			,Pin = dbo.FNADecryptString(rt.controlNo)			
			,Name = rt.senderName
			,[Date] = CONVERT(VARCHAR, rt.approveddate, 107) 
			,Prize = @prize
			,Agent = rt.sAgentName
			,Country  = rt.pCountry			
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN WinnerHistory ts WITH(NOLOCK) ON rt.id = ts.id	
		order by ts.drawnDate	
	END
END


GO
