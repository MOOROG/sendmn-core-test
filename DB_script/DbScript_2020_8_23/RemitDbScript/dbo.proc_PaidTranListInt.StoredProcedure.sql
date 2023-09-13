USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PaidTranListInt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_PaidTranListInt]
	@Sagent INT = NULL
	,@payAgent INT = NULL
	,@PBranch INT = NULL
	,@orderBy	VARCHAR(50) = NULL
	,@fromDate DATETIME
	,@toDate DATETIME
	,@FLAG CHAR(1)
	,@rCountry	VARCHAR(50) = NULL
	,@pageSize		INT			= NULL
	,@pageNumber	INT			= NULL
	,@user			VARCHAR(50)

AS
SET NOCOUNT ON;
SET @TODATE = @TODATE + ' 23:59:59'
DECLARE @REPORTHEAD VARCHAR(200),@maxReportViewDays int
----DECLARE @Sagent INT,@payAgent INT,@PBranch INT,@orderBy	VARCHAR(50),@fromDate DATETIME,@toDate DATETIME,@FLAG CHAR(1)
----SELECT @Sagent = NULL,@payAgent=NULL,@PBranch=NULL,@fromDate='2012-10-12',@toDate='2012-11-21',@FLAG='D'

SET @pageSize = ISNULL(@pageSize,500)

	SET @pageNumber = ISNULL(@pageNumber,1)
	
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
	
	IF CAST(DATEDIFF(DD,@fromDate,@toDate) AS INT)>@maxReportViewDays
	BEGIN
		SELECT 'Paid Transaction  Report List' title
		EXEC proc_errorHandler '1', 'Report viewing range exceeded.', 0
		RETURN
	END

IF @FLAG='S'
BEGIN
	SET @REPORTHEAD = 'Paid Transaction Summary List'
	
	SELECT DISTINCT LO.districtName+'»'+pAgentName [HEAD] FROM (
		SELECT 
			pLocation,pAgentName
		FROM remittran 
		WHERE sCountry<>'Nepal'
		AND pCountry = @rCountry
		AND paidDate BETWEEN @fromDate AND @toDate
		AND ISNULL(sAgent,0) = ISNULL(@Sagent,ISNULL(sAgent,0))
		AND ISNULL(pBranch,0)=ISNULL(@PBranch,ISNULL(pBranch,0))
		AND ISNULL(pAgent,0) = isnull(@payAgent,ISNULL(pAgent,0))
		GROUP BY pLocation,pAgentName,sBranchName
	)X
	INNER JOIN api_districtlist LO ON LO.ROWID = X.PLOCATION
	
	SELECT LO.districtName+'»'+pAgentName [HEAD],sBranchName ,TRN Nos,PAMT [Payout Amt],PCOMM [Comm Agent] FROM (
		SELECT 
			pLocation,pAgentName,sBranchName,COUNT(*) TRN,SUM(pAmt) PAMT,SUM(pagentComm) PCOMM
		FROM remittran 
		WHERE sCountry<>'Nepal'
		AND pCountry = @rCountry
		AND paidDate BETWEEN @fromDate AND @toDate
		AND ISNULL(sAgent,0) = ISNULL(@Sagent,ISNULL(sAgent,0))
		AND ISNULL(pBranch,0)=ISNULL(@PBranch,ISNULL(pBranch,0))
		AND ISNULL(pAgent,0) = isnull(@payAgent,ISNULL(pAgent,0))
		GROUP BY pLocation,pAgentName,sBranchName
	)X
	INNER JOIN api_districtlist LO ON LO.ROWID = X.PLOCATION
END 

IF @FLAG='D'
BEGIN
	SET @REPORTHEAD = 'Paid Transaction Detail List'
	
	SELECT DISTINCT LO.districtName+'»'+pAgentName [Payout By]
			
	FROM (
		SELECT 
			pLocation,pAgentName
		FROM remittran RT
		INNER JOIN tranreceivers R ON RT.ID = R.tranId
		INNER JOIN transenders S ON RT.ID = S.TRANID
		WHERE sCountry<>'Nepal'
		AND pCountry = @rCountry
		AND paidDate BETWEEN @fromDate AND @toDate
		AND ISNULL(sAgent,0) = ISNULL(@Sagent,ISNULL(sAgent,0))
		AND ISNULL(pBranch,0)=ISNULL(@PBranch,ISNULL(pBranch,0))
		AND ISNULL(rt.pAgent,0) = isnull(@payAgent,ISNULL(rt.pAgent,0))
	
	)X
	INNER JOIN api_districtlist LO ON LO.ROWID = X.PLOCATION
	
	SELECT LO.districtName+'»'+pAgentName [HEAD]
			--,trnno+'<BR>'+sender [Sender]
			,[Sender] =trnno+'<BR>'+ '<a href = "#" onclick="OpenInNewWindow('''+DBO.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=Y&tranId='+CAST(ID AS VARCHAR)+''')">'+CAST(sender AS VARCHAR)+'</a>'
			,Receiver
			,CAST(approvedDateLocal AS VARCHAR)+'(S:'+approvedBy+')'+'<BR>'+CONVERT(VARCHAR,paidDate,101) [Local DOT/Paid Date]
			,CAST(sAmt AS VARCHAR)+' '+sCurr [Send Amt],PAMT [Receive Amt] ,sBranchName [Generated By]
	FROM (
		SELECT 
			rt.id,pLocation,pAgentName,sBranchName,PAMT,dbo.FNADecryptString(controlNo) [trnno],paidDate,approvedDateLocal,approvedBy
			,tAmt sAmt,collCurr sCurr,R.firstname+' ' +ISNULL(R.middleName,' ')+' '+isnull(R.lastName1,ISNULL(R.lastName2,' ')) [receiver]
			,S.firstname +' '+ISNULL(S.middleName,' ')+' '+isnull(S.lastName1,ISNULL(S.lastName2,' ')) [sender]
		FROM remittran RT
		INNER JOIN tranreceivers R ON RT.ID = R.tranId
		INNER JOIN transenders S ON RT.ID = S.TRANID
		WHERE sCountry<>'Nepal'
		AND pCountry = @rCountry
		AND paidDate BETWEEN @fromDate AND @toDate
		AND ISNULL(sAgent,0) = ISNULL(@Sagent,ISNULL(sAgent,0))
		AND ISNULL(pBranch,0)=ISNULL(@PBranch,ISNULL(pBranch,0))
		AND ISNULL(rt.pAgent,0) = isnull(@payAgent,ISNULL(rt.pAgent,0))
	
	)X
	INNER JOIN api_districtlist LO ON LO.ROWID = X.PLOCATION

END


EXEC proc_errorHandler '0', 'Report has been prepared successfully.',0

SELECT 'From Date' head, CONVERT(VARCHAR, @fromDate, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR, @toDate, 101)+'<br>' value
UNION ALL
SELECT 'Sending Agent' head, ISNULL((SELECT agentName FROM agentMaster WHERE agentId = @sagent),'All')+'<br>' value
UNION ALL
SELECT 'Payout Agent' head, ISNULL((SELECT agentName FROM agentMaster WHERE agentId = @payAgent),'All')+'<br>' value
UNION ALL
SELECT 'Payout Branch' head, ISNULL((SELECT agentName FROM agentMaster WHERE agentId = @PBranch),'All') value

SELECT @REPORTHEAD title


GO
