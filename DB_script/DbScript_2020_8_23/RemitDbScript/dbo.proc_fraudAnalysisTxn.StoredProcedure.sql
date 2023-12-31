USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_fraudAnalysisTxn]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_fraudAnalysisTxn](
	 @flag			VARCHAR(100)
	,@fromDate 		VARCHAR(30)=NULL
	,@toDate	  	VARCHAR(30)=NULL
	,@count	  		VARCHAR(30)=NULL
	,@sCountry		VARCHAR(30)=NULL
	,@rCountry		VARCHAR(30)=NULL
	,@reportBy		VARCHAR(30)=NULL
	,@operator		VARCHAR(30)=NULL
	,@User varchar(50)=NULL
	,@userName		varchar(50) = null
	,@agent			VARCHAR(30)=NULL
	,@agentUser		VARCHAR(50)=NULL
)AS

SET NOCOUNT ON
------------------- START ######## SAME USER DIFF IP SUMMARY
--DECLARE @fromDate varchar(20)= '2014-2-22', @toDate varchar(20)='2014-2-22 23:59', @User varchar(50)
DECLARE @sql VARCHAR(MAX)



if @flag ='Same User Vs Multiple IP'
BEGIN
	-- ############## SAME USER DIFF IP
	SET @sql='SELECT sAgentName, createdBy
	,IpUsed = ''<a href="reports.aspx?reportName=10122200_txn&reportByTxn=detail&rCountry='+ISNULL(@rCountry,'')+'&sCountry='+ISNULL(@sCountry,'')+'&fromTxnDate='+@fromDate+'&toTxnDate='+@toDate+'&UserName=''+CreatedBy+''">''+CAST(count(*) AS VARCHAR)+''</a>''
	FROM
	(
		SELECT
			distinct sAgentName, createdBy, LEFT(ipAddress,6) ipAddress,sCountry
		from  remitTran T WITH (NOLOCK), tranSenders S WITH (NOLOCK)
		where T.id = S.tranId
		 AND createdDate between '''+ @fromDate +''' AND '''+ @toDate + ' 23:59:59''
		 AND S.ipAddress is not null
	)A WHERE 1=1 '
	
	IF @sCountry IS NOT NULL
		SET @sql  =  @sql +' AND sCountry=''' + @sCountry + ''''
	
	--IF @rCountry IS NOT NULL
	--	SET @sql  =  @sql +' AND pCountry=''' + @rCountry + ''''
	
	SET @sql = @sql +
			'GROUP BY createdBy,sAgentName
			HAVING COUNT(*) '+@operator +@count
	
	
	 -- AND sCountry=''' + @sCountry + '''' + 
		--' AND pCountry=''' + @rCountry + '''' +
	
	print @sql
	EXEC(@sql)
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			
		SELECT 'rCountry' head,@rCountry VALUE
		UNION ALL
		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL 
		SELECT 'TO Date' head,@toDate VALUE		

		SELECT 'Fraud Transaction Reporting - Summary'+(@flag) title

END


if @flag ='Same User Vs Multiple Certificate'
BEGIN

	-- ############## SAME USER DIFF Certificate
	SET @sql='
		SELECT sAgentName, createdBy
		,DcUsed = ''<a href="reports.aspx?reportName=10122200_txn&reportByTxn=detail&rCountry='+ISNULL(@rCountry,'')+'&sCountry='+ISNULL(@sCountry,'')+'&fromTxnDate='+@fromDate+'&toTxnDate='+@toDate+'&UserName=''+CreatedBy+''">''+CAST(count(*) AS VARCHAR)+''</a>''
		FROM
		(
			SELECT
				distinct sAgentName, createdBy, S.dcInfo,sCountry
			from  remitTran T WITH (NOLOCK), tranSenders S WITH (NOLOCK)
			where T.id = S.tranId
			 AND createdDate between '''+ @fromDate +''' AND '''+ @toDate + ' 23:59:59''
			AND S.ipAddress is not null
		)A where 1=1 '
		
	IF @sCountry IS NOT NULL
		SET @sql  =  @sql +' AND sCountry=''' + @sCountry + ''''
	
	--IF @rCountry IS NOT NULL
	--	SET @sql  =  @sql +' AND pCountry=''' + @rCountry + ''''
	
	SET @sql = @sql +
			'GROUP BY createdBy,sAgentName
			HAVING COUNT(*) '+@operator +@count
	
	--print @sql
	EXEC(@sql)
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
				
			SELECT 'rCountry' head,@rCountry VALUE
			UNION ALL
			SELECT 'From Date' head,@fromDate VALUE
			UNION ALL 
			SELECT 'TO Date' head,@toDate VALUE		

			SELECT 'Fraud Transaction Reporting - Summary'+(@flag) title

END

if @flag ='OffHour'
BEGIN

	-- ############## Off Hour Txn Report
	SET @sql='
		SELECT sAgentName, createdBy
		,[OffHour Txn] = ''<a href="reports.aspx?reportName=10122200_txn&reportByTxn=detailOffHrs&rCountry='+ISNULL(@rCountry,'')+'&sCountry='+ISNULL(@sCountry,'')+'&fromTxnDate='+@fromDate+'&toTxnDate='+@toDate+'&UserName=''+CreatedBy+''">''+CAST(SUM(CNT) AS VARCHAR)+''</a>''
		FROM
		(
			SELECT
				 sAgentName, createdBy,sCountry,COUNT(*) CNT
			from  remitTran T WITH (NOLOCK), tranSenders S WITH (NOLOCK)
			where T.id = S.tranId
			 AND createdDate between '''+ @fromDate +''' AND '''+ @toDate + ' 23:59:59''
			 AND (CAST(createdDate AS TIME) > ''23:00:00'' OR CAST(createdDate AS TIME) < ''08:00:00'')
			AND S.ipAddress is not null
			GROUP BY sAgentName, createdBy,sCountry
			
		)A where 1=1 '
		
	IF @sCountry IS NOT NULL
		SET @sql  =  @sql +' AND sCountry=''' + @sCountry + ''''
	
	--IF @rCountry IS NOT NULL
	--	SET @sql  =  @sql +' AND pCountry=''' + @rCountry + ''''
	
	SET @sql = @sql +
			'GROUP BY createdBy,sAgentName
			HAVING SUM(CNT) '+@operator +@count
	
	--print @sql
	EXEC(@sql)
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
				
			SELECT 'rCountry' head,@rCountry VALUE
			UNION ALL
			SELECT 'From Date' head,@fromDate VALUE
			UNION ALL 
			SELECT 'TO Date' head,@toDate VALUE		

			SELECT 'Fraud Transaction Reporting - Summary'+(@flag) title

END

-->>Same day User Created and Txn Generate
if @flag ='samedayuserTXN'
BEGIN

	SET @sql='
		SELECT sAgentName [Sending Agent], createdBy [Created By]
		,[Same day Txn] = ''<a href="reports.aspx?reportName=10122200_txn&reportByTxn=detailsamedayuserTXN&sCountry='+ISNULL(@sCountry,'')+'&fromTxnDate='+@fromDate+'&toTxnDate='+@toDate+'&UserName=''+CreatedBy+''">''+CAST(SUM(CNT) AS VARCHAR)+''</a>''
		FROM
		(
			SELECT
				 sAgentName , t.createdBy ,sCountry ,COUNT(*) CNT
			from  remitTran T WITH (NOLOCK)
			inner join tranSenders S WITH (NOLOCK) on  T.id = S.tranId
			inner join applicationusers u with(nolock) on u.username=t.createdby and cast(t.createdDate as date)=cast(u.createdDate as date)
			where  t.createdDate between '''+ @fromDate +''' AND '''+ @toDate + ' 23:59:59'' 
			----and u.createdDate between '''+ @fromDate +''' AND '''+ @toDate + ' 23:59:59''
			AND S.ipAddress is not null
			GROUP BY sAgentName, t.createdBy,sCountry
			
		)A where 1=1 '
		
	IF @sCountry IS NOT NULL
		SET @sql  =  @sql +' AND sCountry=''' + @sCountry + ''''
	
	--IF @rCountry IS NOT NULL
	--	SET @sql  =  @sql +' AND pCountry=''' + @rCountry + ''''
	
	SET @sql = @sql +
			'GROUP BY createdBy,sAgentName
			HAVING SUM(CNT) '+@operator +@count
	
	print @sql
	EXEC(@sql)
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
				
			SELECT 'rCountry' head,@rCountry VALUE
			UNION ALL
			SELECT 'From Date' head,@fromDate VALUE
			UNION ALL 
			SELECT 'TO Date' head,@toDate VALUE		

			SELECT 'Fraud Transaction Reporting - Summary'+(@flag) title

END
if @flag ='detail'
BEGIN

-- ############## SAME USER DETAIL IP And DC info
	SELECT 
		 TOP 500  
		[Tran No] = '<span class = "link" onclick ="ViewTranDetail(' + 
			CAST(T.id AS VARCHAR(50)) + ');">' +  CAST(T.id AS VARCHAR(50)) + '</span>'
		,sAgentName, sBranchName
		,createdBy, ipAddress, dcInfo, cAmt, createdDate
		,pCountry
	FROM  remitTran T WITH (NOLOCK)
	INNER JOIN  tranSenders S WITH (NOLOCK) ON T.id = S.tranId 
	WHERE createdDate between  @fromDate AND @toDate+' 23:59:59'
	 AND createdBy = @userName
	 AND T.sCountry = ISNULL(@SCOUNTRY,T.sCountry)

	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
	SELECT 'rCountry' head,@rCountry VALUE
	UNION ALL
	SELECT 'From Date' head,@fromDate VALUE
	UNION ALL 
	SELECT 'TO Date' head,@toDate VALUE		

	SELECT 'Fraud Transaction Reporting - Detail' title

END

if @flag ='detailOffHrs'
BEGIN

-- ############## SAME USER DETAIL IP And DC info
	SELECT 
		 TOP 500  
		[Tran No] = '<span class = "link" onclick ="ViewTranDetail(' + 
			CAST(T.id AS VARCHAR(50)) + ');">' +  CAST(T.id AS VARCHAR(50)) + '</span>'
		,sAgentName, sBranchName
		,createdBy, ipAddress, dcInfo, cAmt, createdDate
		,pCountry
	FROM  remitTran T WITH (NOLOCK)
	INNER JOIN  tranSenders S WITH (NOLOCK) ON T.id = S.tranId 
	WHERE createdDate between  @fromDate AND @toDate+' 23:59:59'
	 AND createdBy = @userName
	 AND T.sCountry = ISNULL(@SCOUNTRY,T.sCountry)
	 AND (CAST(createdDate AS TIME) > '23:00:00' OR CAST(createdDate AS TIME) < '08:00:00')
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
	SELECT 'rCountry' head,@rCountry VALUE
	UNION ALL
	SELECT 'From Date' head,@fromDate VALUE
	UNION ALL 
	SELECT 'TO Date' head,@toDate VALUE		

	SELECT 'Fraud Transaction Reporting - Detail' title

END

if @flag ='detailsamedayuserTXN'
BEGIN

-- ############## SAME USER DETAIL IP And DC info

----SELECT TOP 5 sAgent,sAgentName,sBranch,sBranchName FROM remitTran
	SELECT 
		 TOP 500  
		[Tran No] = '<span class = "link" onclick ="ViewTranDetail(' + 
			CAST(T.id AS VARCHAR(50)) + ');">' +  CAST(T.id AS VARCHAR(50)) + '</span>'
		,sAgentName [Agent Name] , sBranchName [Branch Name]
		,t.createdBy [Created by], ipAddress [Ip Address], dcInfo [Dc Info], cAmt [C.Amount],u.createdDate 'User Created Date', t.createdDate 'Txn Date'
		,pCountry [Receiving Country]
	FROM  remitTran T WITH (NOLOCK)
	INNER JOIN  tranSenders S WITH (NOLOCK) ON T.id = S.tranId 
	inner join applicationusers u with(nolock) on u.username=t.createdby and cast(t.createdDate as date)=cast(u.createdDate as date)
	WHERE t.createdDate between  @fromDate AND @toDate+' 23:59:59'
	--and u.createdDate between  @fromDate AND @toDate+' 23:59:59'
	 AND t.createdBy = @userName
	 AND T.sCountry = ISNULL(@SCOUNTRY,T.sCountry)

	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
	SELECT 'Sending Country' head,@sCountry VALUE
	UNION ALL
	SELECT 'From Date' head,@fromDate VALUE
	UNION ALL 
	SELECT 'TO Date' head,@toDate VALUE		

	SELECT 'Fraud Transaction Reporting - Same Day User Created and Txn Generated Detail' title

RETURN
END


GO
