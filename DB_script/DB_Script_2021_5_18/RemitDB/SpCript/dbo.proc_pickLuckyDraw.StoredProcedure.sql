USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_pickLuckyDraw]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_pickLuckyDraw]
	 @flag		CHAR(1) = 's'
	,@user		VARCHAR(30)   
	
AS
SET NOCOUNT ON;
/*

EXEC [proc_pickLuckyDraw] @flag='s' ,@user='admin'
*/
DECLARE
	 @fromDate DATETIME, @toDate DATETIME,@sCountry VARCHAR(100), @sAgent VARCHAR(100)
	,@pAgent1 VARCHAR(100), @pAgent2 VARCHAR(100), @pAgent3 VARCHAR(100), @pAgent4 VARCHAR(100), @pAgent5 VARCHAR(100)
	,@luckyDrawType VARCHAR(50), @controlNo VARCHAR(20), @id BIGINT,@prize VARCHAR(50)
	,@dateField VARCHAR(50)

	SELECT
		 @fromDate = fromDate, 
		 @toDate = toDate,
		 @sCountry = cm.countryName, 
		 @sAgent = sAgent,
		 @pAgent1 = pAgent1, 
		 @pAgent2 = pAgent2, 
		 @pAgent3 = pAgent3, 
		 @pAgent4 = pAgent4,
		 @pAgent5 = pAgent5, 
		 @luckyDrawType = luckyDrawType
	FROM luckyDrawSetup lds with(nolock) 
	left join countryMaster cm with(nolock) on lds.sCountry = cm.countryId
	WHERE flag = @flag 
	--set @sCountry = 'Malaysia'
	
	SET @prize= CASE @luckyDrawType 
					WHEN  'Sender_Daily'    THEN 'Smart Phone'
					WHEN  'Sender_Weekly'	THEN 'IPad'
					WHEN  'Receiver_Daily'  THEN 'Luggage Bag'
					WHEN  'Receiver_Weekly' THEN 'Digital Camera'  
					ELSE 'Unknown'
				END

	DECLARE @pAgentList VARCHAR(MAX) = ''
	IF @pAgent1 IS NOT NULL SET @pAgentList = @pAgentList + ' OR pAgent=' + @pAgent1 
	IF @pAgent2 IS NOT NULL SET @pAgentList = @pAgentList + ' OR pAgent=' + @pAgent2 
	IF @pAgent3 IS NOT NULL SET @pAgentList = @pAgentList + ' OR pAgent=' + @pAgent3 
	IF @pAgent4 IS NOT NULL SET @pAgentList = @pAgentList + ' OR pAgent=' + @pAgent4 
	IF @pAgent5 IS NOT NULL SET @pAgentList = @pAgentList + ' OR pAgent=' + @pAgent5 

	IF @pAgentList <> '' 
		SET @pAgentList = SUBSTRING(@pAgentList, 4, 8000)
	ELSE
		SET @pAgentList = NULL
		
	DECLARE @sql VARCHAR(MAX) = '
	SELECT
		 Id
		,controlNo		
	FROM remitTran rt WITH(NOLOCK)
	WHERE approvedDate > ''2015-09-01''
	and '+case when @flag ='s' then 'approvedDate' else 'paidDate' end+ ' BETWEEN ''' +  CONVERT(VARCHAR, @fromDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @toDate, 101) + ' 23:59:59''
	AND pCountry = ''Nepal''
	--ANS sCountry =''Japan''
	AND tranStatus = ''Paid''
	--AND LEFT(rt.controlno,1) = ''R''
	AND LEN(rt.controlNo) = 11'
	

	+ CASE WHEN @flag = 'r' THEN ' AND payStatus=''Paid''' ELSE '' END

	IF @sCountry IS NOT NULL SET @sql = @sql + ' AND sCountry=''' + @sCountry + ''''
	IF @sAgent IS NOT NULL SET @sql = @sql + ' AND sAgent=' + @sAgent 

	SET @sql  = @sql + ISNULL(' AND (' + @pAgentList + ')', '')



	DECLARE @luckyNumbers TABLE(Id bigint, controlNo VARCHAR(20))


	INSERT INTO @luckyNumbers(Id, controlNo)	
	EXEC (@sql)
	PRINT @sql

	DELETE FROM @luckyNumbers 						
		FROM @luckyNumbers t
		INNER JOIN WinnerHistory h ON t.controlNo = h.controlNo

	DELETE FROM @luckyNumbers 						
		FROM @luckyNumbers t
		INNER JOIN remitTran rt ON t.controlNo = rt.controlNo
		INNER JOIN errPaidTran ep ON rt.id = ep.tranId

	--DELETE @luckyNumbers WHERE controlNo IN (SELECT controlNo FROM WinnerHistory WITH(NOLOCK))
	
	--DELETE @luckyNumbers WHERE controlNo IN (
	--SELECT ld.controlNo FROM errPaidTran ep WITH(NOLOCK) 
	--	inner join remitTran rt with(nolock) on ep.tranId = rt.id 
	--	inner join @luckyNumbers ld on ld.controlNo = rt.controlNo
	--	)
		
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
	
	INSERT INTO WinnerHistory(ID,controlNo, drawnDate,createdBy)
	SELECT @id,@controlNo, GETDATE(),@user
	
	IF @flag = 'r'
	BEGIN
		SELECT 
			 ErrorCode = '0'
			,Pin = dbo.FNADecryptString(@controlNo)			
			,Name = UPPER(tr.firstName + ISNULL(' ' + tr.middleName, '') + ISNULL(' ' + tr.lastName1, '') + ISNULL(' ' + tr.lastName2 , ''))
			,[Date] =  CONVERT(VARCHAR, rt.paidDate, 107)
			,Prize = @prize
			,Agent = rt.pAgentName
			,Country  = 'Nepal '-- + isnull(rt.pAgentName,'')
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId		
		WHERE rt.id = @id
	END
	ELSE
	BEGIN
		SELECT 
			 ErrorCode = '0'
			,Pin = dbo.FNADecryptString(@controlNo)			
			,Name = UPPER(ts.firstName + ISNULL(' ' + ts.middleName, '') + ISNULL(' ' + ts.lastName1, '') + ISNULL(' ' + ts.lastName2 , ''))
			,[Date] = CONVERT(VARCHAR, rt.createdDate, 107) 
			,Prize = @prize
			,Agent = rt.sAgentName
			,Country  = rt.sCountry			
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId		
		WHERE rt.id = @id
	END
END




GO
