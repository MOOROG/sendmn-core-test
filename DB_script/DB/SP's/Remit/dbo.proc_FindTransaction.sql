SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROCEDURE [dbo].[proc_FindTransaction]
	 @flag							VARCHAR(20)
	,@user							VARCHAR(30)	
	,@searchByText					VARCHAR(300)= NULL
	,@searchBy						VARCHAR(50) = NULL
	,@fromDate						VARCHAR(20)	= NULL
	,@controlNo						VARCHAR(50)	= NULL
	,@tranId						VARCHAR(50)	= NULL
    ,@PageSize						VARCHAR(20) = NULL
    ,@PageNumber					VARCHAR(20) = NULL
AS

SET NOCOUNT ON;
-- ## AGENT TRANSACTION REPORT (LOCAL)
IF @flag = 'A'
BEGIN
		SET @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
		DECLARE @AGENTID AS INT,@SQL AS VARCHAR(MAX)
		SELECT @AGENTID = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		SET @SQL='
			SELECT  
				[Control No] = ''<a href="#" onclick="OnClickNo(''''''+dbo.FNADecryptString(controlNo)+'',''+A.tranStatus+'''''')">'' + dbo.FNADecryptString(controlNo) + ''</a>'',
				[CustomerId] = ISNULL(CM.POSTALCODE,CM.MEMBERSHIPID),
				[Sender Name]=C.firstName + ISNULL('' '' + C.middleName, '''') + ISNULL('' '' + C.lastName1, '''') + ISNULL('' '' + C.lastName2,''''),
				[Receiver Name]=D.firstName + ISNULL('' '' + D.middleName, '''') + ISNULL('' '' + D.lastName1, '''') + ISNULL('' '' + D.lastName2, ''''),
				[Tran Amt]=dbo.ShowDecimal(tAmt),
				[Location Name]=B.districtName,
				[Send Date]=CONVERT(VARCHAR, createdDateLocal, 111),
				[Approve Date]=CONVERT(VARCHAR, A.approvedDate, 111),
				[Paid Date] =A.paidDate,
				[Pay Status]=case when A.tranStatus=''Payment'' then ''Unpaid'' else 	A.tranStatus end,	
				[Collection Mode] = A.collmode
			FROM remitTran A WITH(NOLOCK) 
			INNER JOIN tranSenders C WITH(NOLOCK) ON A.id = C.tranId 
			INNER JOIN tranReceivers D WITH(NOLOCK) ON A.id = D.tranId
			LEFT JOIN api_districtList B WITH(NOLOCK) ON A.pLocation=B.districtCode
			LEFT JOIN CUSTOMERMASTER CM (NOLOCK) ON CM.CUSTOMERID = C.CUSTOMERID
			WHERE 1 = 1 '
			--WHERE sBranch=+CAST(@AGENTID AS VARCHAR(20)) +    (LOGIC REMOVED TO ALLOW ALL USERS TO SEE THE ALL TRANSACTIONS

		IF @fromDate IS NOT NULL 
			SET @SQL = @SQL + ' AND A.approvedDate BETWEEN ''' + CONVERT(VARCHAR, CAST(@FROMDATE AS DATETIME), 101) + ''' AND ''' + CONVERT(VARCHAR, CAST(@FROMDATE AS DATETIME), 101) + ' 23:59:59'''
			
		IF @controlNo IS NOT NULL 
			SET @SQL = @SQL + ' AND controlNo= '''+ dbo.FNAEncryptString(@controlNo) +''''
		
		IF @tranId IS NOT NULL AND ISNUMERIC(@tranId) = 1
			SET @SQL = @SQL + ' AND A.holdtranid = ' + CAST(@tranId AS VARCHAR)
			
		IF @searchByText IS NOT NULL AND @searchBy ='sender'
			SET @SQL =@SQL+ ' AND C.firstName LIKE ''%' + @searchByText + '%'''
		
		IF @searchByText IS NOT NULL AND @searchBy ='receiver'
			SET @SQL =@SQL+ ' AND D.firstName LIKE ''%' + @searchByText + '%'''
		--PRINT(@SQL)
		EXEC(@SQL)
END







GO

