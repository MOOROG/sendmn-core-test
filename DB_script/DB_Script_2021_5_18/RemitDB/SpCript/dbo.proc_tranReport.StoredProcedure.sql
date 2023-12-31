USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranReport]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

EXEC proc_tranReport @flag = 'r', @user = 'admin', @fromDate = '2012-6-6', @toDate = '2012-7-2',
 @reportType = 'S', @pageNumber = '1', @pageSize = '100', @sessionId = 'sdqz13btxutwh4ecp1n02gc2'

*/

CREATE procEDURE [dbo].[proc_tranReport]
	 @flag					VARCHAR(20)
	,@user					VARCHAR(30)	
	,@fromDate				DATETIME	= NULL
	,@toDate				DATETIME	= NULL
	,@reportType			CHAR(1)
	,@pageNumber			INT			= NULL
	,@pageSize				INT			= NULL
	,@sessionId				VARCHAR(60)
AS

SET NOCOUNT ON;
SET ANSI_NULLS ON;

--SET @toDate = @toDate + ' 23:59:59'

DECLARE @agentId INT,@maxReportViewDays INT

	SET @pageSize = ISNULL(@pageSize,500)

	SET @pageNumber = ISNULL(@pageNumber,1)
	
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60),@agentId = agentId FROM applicationUsers WHERE userName = @user
	
	IF CAST(DATEDIFF(DD,@fromDate,@toDate) AS INT)>@maxReportViewDays
	BEGIN
		SELECT CASE WHEN @reportType = 'S' THEN 'Transaction Report-Send' ELSE 'Transaction Report-Pay' END title
		EXEC proc_errorHandler '1', 'Report viewing range exceeded.', @agentId
		RETURN
	END


IF @reportType = 'S'
BEGIN
	IF NOT EXISTS(SELECT 'A'  FROM tbl_tranReport WITH (NOLOCK) WHERE SESSIONID = @sessionId AND [reportType] = 'S' 
				AND [fromDate] = @fromDate AND [toDate] = CAST(@toDate AS DATE)  )
	BEGIN
		
		DELETE FROM tbl_tranReport WHERE SESSIONID = @sessionId AND [reportType] = 'S'
		
		INSERT INTO tbl_tranReport
				([rowId],
				[reportType],
				[date],
				[controlNo],
				[trnAmt],
				[serviceCharge],
				[sendingAgent],
				[senderName],
				[senderAddress],
				[receiverName],
				[receiverAddress],
				[tranStatus],
				[sessionId],
				[fromDate],
				[toDate],
				[agentId])
		SELECT
			ROW_NUMBER() OVER ( ORDER BY agentName ASC)
			,'S'
			,[Date] = rt.approvedDate
			,[Reference No] ='<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId=' + CAST(rt.id AS VARCHAR) + ''')">' +  dbo.FNADecryptString(rt.controlNo) + '</a>'
			,[Sent Amount] = rt.tAmt
			,[Service <br /> Charge] = rt.serviceCharge
			,[Sending Agent] = sa.agentName
			,[Sender Name] = ts.firstName + ISNULL(' ' + ts.middleName, '') + ISNULL(' ' + ts.lastName1, '') + ISNULL(' ' + ts.lastName2, '')
			,[Sender <br /> Address] = ts.address	
			,[Receiver Name] = tr.firstName + ISNULL(' ' + tr.middleName, '') + ISNULL(' ' + tr.lastName1, '') + ISNULL(' ' + tr.lastName2, '')
			,[Receiver Address] = tr.address
			,[Tran Status] = rt.tranStatus
			,@sessionId
			,@fromDate
			,CAST(@toDate AS DATE)
			,@agentId
		
		FROM (
				SELECT
					approvedDate,id,controlNo,tAmt,serviceCharge,
					tranStatus,sAgent
				FROM remitTran rt WITH(NOLOCK)
				WHERE approvedDate BETWEEN ISNULL(@fromDate, '1900-01-01') 
					AND ISNULL(@toDate + '23:59:59', '2100-12-31')
				AND sBranch = CASE WHEN @agentId = 1 THEN sBranch ELSE @agentId END
		) rt

		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		INNER JOIN agentMaster sa WITH(NOLOCK) ON rt.sAgent = sa.agentId
		--LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON rt.tranStatus = sdv.valueId
		ORDER BY [Date] DESC

		SELECT 	TXNCOUNT = COUNT('A'),
				PAGESIZE = @pageSize
		 FROM tbl_tranReport
		 WHERE SESSIONID = @sessionId AND [reportType] = 'S'
	 
		 SELECT 
				[Date] = CONVERT(VARCHAR,[DATE],101),
				[Reference No] = [controlNo],
				[Sent Amount] = [trnAmt],
				[Service <br /> Charge] = [serviceCharge],
				[Sending Agent] = [sendingAgent],
				[Sender <br /> Address] = [senderName],
				[Receiver Name] = [senderAddress],
				[Receiver Name] = [receiverName],
				[Receiver Address] = [receiverAddress],
				[Tran Status] = [tranStatus]
		FROM tbl_tranReport WITH (NOLOCK)
		WHERE SESSIONID = @sessionId AND [reportType] = 'S'
		AND ROWID BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND @pageSize * @pageNumber

	END
	ELSE
	BEGIN
		SELECT 	TXNCOUNT = COUNT('A'),
				PAGESIZE = @pageSize
		 FROM tbl_tranReport
		 WHERE SESSIONID = @sessionId AND [reportType] = 'S'
	 
		 SELECT 
				[Date] = CONVERT(VARCHAR,[DATE],101),
				[Reference No] = [controlNo],
				[Sent Amount] = [trnAmt],
				[Service <br /> Charge] = [serviceCharge],
				[Sending Agent] = [sendingAgent],
				[Sender <br /> Address] = [senderName],
				[Receiver Name] = [senderAddress],
				[Receiver Name] = [receiverName],
				[Receiver Address] = [receiverAddress],
				[Tran Status] = [tranStatus]
		FROM tbl_tranReport WITH (NOLOCK)
		WHERE SESSIONID = @sessionId AND [reportType] = 'S'
		AND ROWID BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND @pageSize * @pageNumber
	END

END

ELSE IF @reportType = 'P'
BEGIN
	IF NOT EXISTS(SELECT 'A'  FROM tbl_tranReport WITH (NOLOCK) WHERE SESSIONID = @sessionId AND [reportType] = 'P' 
			AND [fromDate] = @fromDate AND [toDate] = CAST(@toDate AS DATE) )
	BEGIN
		
		DELETE FROM tbl_tranReport WHERE SESSIONID = @sessionId AND [reportType] = 'P'

		INSERT INTO tbl_tranReport
				([rowId],
				[reportType],
				[date],
				[controlNo],
				[trnAmt],
				[senderName],
				[senderAddress],
				[receiverName],
				[receiverAddress],
				[tranStatus],
				[sessionId],
				[fromDate],
				[toDate],
				[agentId])
	
		SELECT
			ROW_NUMBER() OVER (ORDER BY rt.createdDate ASC)
			,'P'
			,[Date] = rt.paidDate
			,[Reference No] ='<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId=' + CAST(rt.id AS VARCHAR) + ''')">' +  dbo.FNADecryptString(rt.controlNo) + '</a>'
			,[Payout Amount] = rt.pAmt
			,[Sender Name] = ts.firstName + ISNULL(' ' + ts.middleName, '') + ISNULL(' ' + ts.lastName1, '') + ISNULL(' ' + ts.lastName2, '')
			,[Sender <br /> Address] = ts.address	
			,[Receiver Name] = tr.firstName + ISNULL(' ' + tr.middleName, '') + ISNULL(' ' + tr.lastName1, '') + ISNULL(' ' + tr.lastName2, '')
			,[Receiver Address] = tr.address
			,[Tran Status] = rt.tranStatus
			,@sessionId
			,@fromDate
			,CAST(@toDate AS DATE)
			,@agentId
		FROM (
				SELECT
					*
				FROM remitTran rt WITH(NOLOCK)
				WHERE paidDate BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate + '23:59:59', '2100-12-31')
				AND pBranch = CASE WHEN @agentId = 1 THEN pBranch ELSE @agentId END
		) rt

		INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		INNER JOIN agentMaster sa WITH(NOLOCK) ON rt.sAgent = sa.agentId
		--LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON rt.tranStatus = sdv.valueId
		ORDER BY [Date] DESC
		
	SELECT 	TXNCOUNT = COUNT('A'),
				PAGESIZE = @pageSize
		 FROM tbl_tranReport
		 WHERE SESSIONID = @sessionId AND [reportType] = 'P'
	 
		 SELECT 
				[Date] = CONVERT(VARCHAR,[DATE],101),
				[Reference No] = [controlNo],
				[Sent Amount] = [trnAmt],
				[Sender <br /> Address] = [senderName],
				[Receiver Name] = [senderAddress],
				[Receiver Name] = [receiverName],
				[Receiver Address] = [receiverAddress],
				[Tran Status] = [tranStatus]
		FROM tbl_tranReport WITH (NOLOCK)
		WHERE SESSIONID = @sessionId AND [reportType] = 'P'
		AND ROWID BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND @pageSize * @pageNumber

	END
	ELSE
	BEGIN
		SELECT 	TXNCOUNT = COUNT('A'),
				PAGESIZE = @pageSize
		 FROM tbl_tranReport
		 WHERE SESSIONID = @sessionId AND [reportType] = 'P'
	 
		 SELECT 
				[Date] = CONVERT(VARCHAR,[DATE],101),
				[Reference No] = [controlNo],
				[Sent Amount] = [trnAmt],
				[Sender <br /> Address] = [senderName],
				[Receiver Name] = [senderAddress],
				[Receiver Name] = [receiverName],
				[Receiver Address] = [receiverAddress],
				[Tran Status] = [tranStatus]
		FROM tbl_tranReport WITH (NOLOCK)
		WHERE SESSIONID = @sessionId AND [reportType] = 'P'
		AND ROWID BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND @pageSize * @pageNumber
	END


END
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value

SELECT title = CASE WHEN @reportType = 'S' THEN 'Transaction Report-Send' ELSE 'Transaction Report-Pay' END


GO
