USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionRpt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_transactionRpt]
	 @flag								VARCHAR(20)
	,@user								VARCHAR(50)		=   NULL
	,@sCountry							VARCHAR(100)	=	NULL
	,@rCountry							VARCHAR(100)	=	NULL
	,@sAgent							VARCHAR(100)	=	NULL
	,@rAgent							VARCHAR(100)	=	NULL
	,@sBranch							VARCHAR(100)	=	NULL
	,@rBranch							VARCHAR(100)	=	NULL
	,@sFirstName						VARCHAR(100)	=	NULL
	,@rFirstName						VARCHAR(100)	=	NULL
	,@sMiddleName						VARCHAR(100)	=	NULL
	,@rMiddleName						VARCHAR(100)	=	NULL
	,@sLastName							VARCHAR(100)	=	NULL
	,@rLastName							VARCHAR(100)	=	NULL
	,@sSecondLastName					VARCHAR(100)	=	NULL
	,@rSecondLastName					VARCHAR(100)	=	NULL
	,@sMobile							VARCHAR(100)	=	NULL
	,@rMobile							VARCHAR(100)	=	NULL
	,@sEmail							VARCHAR(100)	=	NULL
	,@rEmail							VARCHAR(100)	=	NULL
	,@sIdNumber							VARCHAR(100)	=	NULL
	,@rIdNumber							VARCHAR(100)	=	NULL
	,@sState							VARCHAR(500)	=	NULL
	,@rState							VARCHAR(500)	=	NULL
	,@sCity								VARCHAR(100)	=	NULL
	,@rCity								VARCHAR(100)	=	NULL
	,@sZip								VARCHAR(100)	=	NULL
	,@rZip								VARCHAR(100)	=	NULL
	,@tranNo							VARCHAR(100)	=	NULL
	,@icn								VARCHAR(100)	=	NULL
	,@senderCompany						VARCHAR(100)	=	NULL
	,@cAmtFrom							VARCHAR(100)	=	NULL
	,@cAmtTo							VARCHAR(100)	=	NULL
	,@pAmtFrom							VARCHAR(100)	=	NULL
	,@pAmtTo							VARCHAR(100)	=	NULL
	,@localDateFrom						VARCHAR(100)	=	NULL
	,@localDateTo						VARCHAR(100)	=	NULL
	,@confirmDateFrom					VARCHAR(100)	=	NULL
	,@confirmDateTo						VARCHAR(100)	=	NULL
	,@paidDateFrom						VARCHAR(100)	=	NULL
	,@paidDateTo						VARCHAR(100)	=	NULL
	,@cancelledDateFrom					VARCHAR(100)	=	NULL
	,@cancelledDateTo					VARCHAR(100)	=	NULL
	,@receivingMode						VARCHAR(100)	=	NULL
	,@status							VARCHAR(100)	=	NULL
	,@reportIn							VARCHAR(100)	=	NULL
	,@rptTemplate						VARCHAR(100)	=	NULL
	,@fromDate							VARCHAR(100)	=	NULL
	,@toDate							VARCHAR(100)	=	NULL
	,@dateType							VARCHAR(100)	=	NULL
	,@isAdvanceSearch					VARCHAR(100)	=	NULL
	,@pageNumber						VARCHAR(100)	=	NULL
	,@pageSize							VARCHAR(100)	=	NULL     
	,@sortBy							VARCHAR(50)		=	NULL
	,@sortOrder							VARCHAR(5)		=	NULL
	,@isExportMode						VARCHAR(1)		=   NULL
	,@tranType							VARCHAR(50)		=	NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;
	
	IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL 
	DROP TABLE #tempTable	
	CREATE TABLE #tempTable(HEAD VARCHAR(50),VALUE VARCHAR(200))
			
	DECLARE @table AS VARCHAR(MAX),@fields AS VARCHAR(MAX),@SQL1 AS VARCHAR(MAX),@sCountryName as varchar(50),@rCountryName as varchar(50)
	IF @FLAG='rpt'
    BEGIN    
		if @status = 'Unpaid'
			set @status ='Payment'
		SELECT @sCountryName = countryName FROM countryMaster WITH(NOLOCK) WHERE countryId=@sCountry
		SELECT @rCountryName = countryName FROM countryMaster WITH(NOLOCK) WHERE countryId=@rCountry
			
		SELECT @fields = fields FROM ReportTemplate with(nolock) WHERE id = @rptTemplate
		declare @linkIcn as varchar(max) = '''<span class = "link" onclick ="ViewTranDetail('' + cast([TranNo] as varchar) + '');">''+ cast([TranNo] as varchar)+''</span>'' as [TranNo]'	
		set @fields = replace(@fields,'[TranNo]',@linkIcn)

		SET @table=
			'SELECT ROW_NUMBER() OVER (ORDER BY [TranNo]) AS [S.N.],'+@fields+' 
			 FROM DBO.vw_transactionRpt WITH(NOLOCK) WHERE 1=1 '
			 
		IF @isAdvanceSearch='N'
		BEGIN
			
			IF @sCountry  IS NOT NULL AND @sCountryName	 IS NOT NULL
				SET @table=@table+' AND sCountry='''+@sCountryName+''''
			  
			IF @rCountry IS NOT NULL
				SET @table=@table+' AND pCountry='''+@rCountryName+''''	
			
			IF @sAgent IS NOT NULL
				SET @table=@table+' AND sAgent='''+@sAgent+''''
			  
			IF @rAgent IS NOT NULL
				SET @table=@table+' AND pAgent='''+@rAgent+''''	
			    	
			IF @sBranch IS NOT NULL
				SET @table=@table+' AND sBranch='''+@sBranch+''''
			  
			IF @rBranch IS NOT NULL
				SET @table=@table+' AND pBranch='''+@rBranch+''''

			IF @dateType='confirmDate'   	
				SET @table=@table+' AND approvedDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'+''''
					
			IF @dateType='localDate'   	
				SET @table=@table+' AND createdDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'+''''

			IF @dateType='paidDate'   	
				SET @table=@table+' AND paidDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'+''''
					
			IF @dateType='cancelledDate'   	
				SET @table=@table+' AND cancelApprovedDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'+''''				  
		
			IF @receivingMode IS NOT NULL
				SET @table=@table+' AND paymentMethod='''+@receivingMode+''''

			IF @status IS NOT NULL 
				SET @table=@table+' AND tranStatus='''+@status+''''

			IF @tranType IS NOT NULL 
				SET @table=@table+' AND tranType='''+@tranType+''''

		END	
		ELSE
		BEGIN
		
			IF @sCountry IS NOT NULL
				SET @table=@table+' AND sCountry='''+@sCountryName+''''
						
			IF @sAgent IS NOT NULL
				SET @table=@table+' AND sAgent='''+@sAgent+''''
			 			    	
			IF @sBranch IS NOT NULL
				SET @table=@table+' AND sBranch='''+@sBranch+''''
							  
			IF @rCountry IS NOT NULL
				SET @table=@table+' AND pCountry='''+@rCountryName+''''	
					 
			IF @rAgent IS NOT NULL
				SET @table=@table+' AND pAgent='''+@rAgent+''''	
			  
			IF @rBranch IS NOT NULL
				SET @table=@table+' AND pBranch='''+@rBranch+''''	
			 
			IF @sFirstName IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender First Name',@sFirstName)
				SET @table=@table+' AND senFirstName LIKE ''%' + @sFirstName + '%'''
			END	
			IF @rFirstName IS NOT NULL	
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver First Name',@rFirstName)		
				SET @table=@table+' AND recFirstName LIKE ''%' + @rFirstName + '%'''
			END	
			IF @sMiddleName IS NOT NULL		
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Middle Name',@sMiddleName)			
				SET @table=@table+' AND senMiddleName LIKE ''%' + @sMiddleName + '%'''
			END	
			IF @rMiddleName IS NOT NULL		
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Middle Name',@rMiddleName)			
				SET @table=@table+' AND recMiddleName LIKE ''%' + @rMiddleName + '%'''
			END	
			IF @sLastName IS NOT NULL			
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Last Name',@sLastName)		
				SET @table=@table+' AND senLastName LIKE ''%' + @sLastName + '%'''
			END	
			IF @rLastName IS NOT NULL	
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Last Name',@rLastName)				
				SET @table=@table+' AND recLastName LIKE ''%' + @rLastName + '%'''
			END
			IF @sSecondLastName IS NOT NULL			
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Second Last Name',@sSecondLastName)		
				SET @table=@table+' AND senSecondLastName LIKE ''%' + @sSecondLastName + '%'''
			END	
			IF @rSecondLastName IS NOT NULL	
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Second Last Name',@rSecondLastName)				
				SET @table=@table+' AND recSecondLastName LIKE ''%' + @rSecondLastName + '%'''
			END
			IF @sMobile IS NOT NULL	
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Mobile',@sMobile)			
				SET @table=@table+' AND senMobile LIKE ''%' + @sMobile + '%'''
			END
				
			IF @rMobile IS NOT NULL		
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Mobile',@rMobile)				
				SET @table=@table+' AND recMobile LIKE ''%' + @rMobile + '%'''
			END
				
			IF @sEmail IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Email',@sEmail)
				SET @table=@table+' AND senEmail LIKE ''%' + @sEmail + '%'''
			END	
			IF @rEmail IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Email',@rEmail)			
				SET @table=@table+' AND recEmail LIKE ''%' + @rEmail + '%'''	
			END					
			IF @sIdNumber IS NOT NULL		
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Id Number',@sIdNumber)		
				SET @table=@table+' AND senIdNumber LIKE ''%' + @sIdNumber + '%'''
			END		
			IF @rIdNumber IS NOT NULL
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Id Number',@rIdNumber)				
				SET @table=@table+' AND recIdNumber LIKE ''%' + @rIdNumber + '%'''
			END
			IF @sState IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Full Name',@sState)			
				SET @table=@table+' AND senState LIKE ''%' + @sState + '%'''
			END		
			IF @rState IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Full Name',@rState)			
				SET @table=@table+' AND recState LIKE ''%' + @rState + '%'''				
			END		
			IF @sCity IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender City',@sCity)			
				SET @table=@table+' AND senCity LIKE ''%' + @sCity + '%'''
			END		
			IF @rCity IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver City',@rCity)			
				SET @table=@table+' AND recCity LIKE ''%' + @rCity + '%'''	
			END	
			IF @sZip IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Zip',@sZip)			
				SET @table=@table+' AND senZip = ''' + @sZip + ''''
			END
			IF @rZip IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Receiver Zip',@rZip)			
				SET @table=@table+' AND recZip = ''' + @rZip + ''''	
			END						
			IF @tranNo IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Tran No',@tranNo)			
				SET @table=@table+' AND TranNo = ''' + @tranNo + ''''
			END		
			IF @icn IS NOT NULL
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('ICN',@icn)				
				SET @table=@table+' AND controlNo = ''' + @icn + ''''
			END	
			IF @senderCompany IS NOT NULL	
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Sender Company',@senderCompany)			
				SET @table=@table+' AND senderCompany LIKE ''%' + @senderCompany + '%'''		
				
			END												
			IF @cAmtFrom IS NOT NULL AND @cAmtTo IS NOT NULL
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Collection Amount From',@cAmtFrom)
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Collection Amount To',@cAmtTo)
				SET @table=@table+' AND cAmt BETWEEN '''+ @cAmtFrom +''' AND '''+ @cAmtTo +''''
			END
			IF @pAmtFrom IS NOT NULL AND @pAmtTo IS NOT NULL
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Payout Amount From',@pAmtFrom)
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Payout Amount To',@pAmtTo)
				SET @table=@table+' AND pAmt BETWEEN '''+ @pAmtFrom +''' AND '''+ @pAmtTo +''''			
			END					 
			IF @confirmDateFrom IS NOT NULL AND @confirmDateTo IS NOT NULL  
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Confirm Date From',@confirmDateFrom) 	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Confirm Date To',@confirmDateTo) 
				SET @table=@table+' AND approvedDate BETWEEN '''+ @confirmDateFrom +''' AND '''+ @confirmDateTo +' 23:59:59'+''''
			END			
			IF @localDateFrom IS NOT NULL AND @localDateTo IS NOT NULL 
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Local Date From',@localDateFrom) 	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Local Date To',@localDateTo) 
				SET @table=@table+' AND createdDate BETWEEN '''+ @localDateFrom +''' AND '''+ @localDateTo +' 23:59:59'+''''
			END	
			IF @paidDateFrom IS NOT NULL AND @paidDateTo IS NOT NULL 
			BEGIN	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Paid Date From',@paidDateFrom) 	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Paid Date To',@paidDateTo) 
				SET @table=@table+' AND paidDate BETWEEN '''+ @paidDateFrom +''' AND '''+ @paidDateTo +' 23:59:59'+''''
			END		
			IF @cancelledDateFrom IS NOT NULL AND @cancelledDateTo 	IS NOT NULL
			BEGIN			
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Cancelled Date From',@cancelledDateFrom) 	
				INSERT INTO #tempTable(HEAD,VALUE)VALUES('Cancelled Date To',@cancelledDateTo) 
				SET @table=@table+' AND cancelApprovedDate BETWEEN '''+ @cancelledDateFrom +''' AND '''+ @cancelledDateTo +' 23:59:59'+''''				  
			END
		
			IF @receivingMode IS NOT NULL
				SET @table=@table+' AND paymentMethod='''+@receivingMode+''''

			IF @status IS NOT NULL 
				SET @table=@table+' AND tranStatus='''+@status+''''

			IF @tranType IS NOT NULL 
				SET @table=@table+' AND tranType='''+@tranType+''''

		END
		PRINT @TABLE
		--EXEC(@table)
		IF ISNULL(@isExportMode,'N') <> 'Y'
		BEGIN
			SET @SQL1='
			SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @table +') AS tmp;

			SELECT * FROM 
			(
			SELECT * 
			FROM 
			(
				'+ @table +'
			) AS aa
			) AS tmp WHERE 1 = 1 AND  tmp.[S.N.] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''
		
			print(@sql1);
			EXEC(@SQL1)
		END	
		ELSE
		BEGIN
			PRINT @TABLE
			EXEC(@table)
		END	
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		IF @isAdvanceSearch='Y'
		BEGIN		
			SELECT 'Sending Country' head,ISNULL(@sCountryName,'All') VALUE
			UNION ALL
			SELECT 'Receiving Country' head,ISNULL(@rCountryName,'All') VALUE
			UNION ALL
			SELECT 'Sending Agent' head,CASE WHEN  @sAgent IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent) END VALUE
			UNION ALL
			SELECT 'Receiving Agent' head,CASE WHEN  @rAgent IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@rAgent) END VALUE
			UNION ALL
			SELECT 'Receiving Branch' head,CASE WHEN  @rBranch IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@rBranch) END VALUE
			UNION ALL
			SELECT 'Sending Branch' head,CASE WHEN  @sBranch IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sBranch) END VALUE
			UNION ALL
			SELECT * FROM 
			(
				SELECT * FROM #tempTable
			)a
			UNION ALL
			SELECT 'Tran Type' head,case when @tranType IS NULL THEN 'All' WHEN @tranType ='D' THEN 'Domestic' ELSE 'International' end VALUE
			UNION ALL
			SELECT 'Status' head,case when ISNULL(@status,'All') = 'Payment' then 'Unpaid' else ISNULL(@status,'All') end VALUE
			UNION ALL
			SELECT 'Receiving Mode',ISNULL(@receivingMode,'All')
			UNION ALL
			SELECT 'Report In ' head,case when @reportIn='cCurr' THEN 'Collection Currency' ELSE 'USD' END VALUE
			UNION ALL
			SELECT 'Report Template' head,(SELECT templateName FROM ReportTemplate WITH(NOLOCK) WHERE id= @rptTemplate) VALUE
		END
		ELSE
		BEGIN
			SELECT 'Sending Country' head,ISNULL(@sCountryName,'All') VALUE
			UNION ALL
			SELECT 'Receiving Country' head,ISNULL(@rCountryName,'All') VALUE
			UNION ALL
			SELECT 'Sending Agent' head,CASE WHEN  @sAgent IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent) END VALUE
			UNION ALL
			SELECT 'Receiving Agent' head,CASE WHEN  @rAgent IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@rAgent) END VALUE
			UNION ALL
			SELECT 'Receiving Branch' head,CASE WHEN  @sBranch IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sBranch) END VALUE
			UNION ALL
			SELECT 'Sending Branch' head,CASE WHEN  @rBranch IS NULL THEN 'All' ELSE
				(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@rBranch) END VALUE
			UNION ALL
			SELECT 'From Date' head,@fromDate VALUE
			UNION ALL
			SELECT 'To Date' head,@toDate VALUE
			UNION ALL
			SELECT 'Date Type' head,@dateType VALUE			
			UNION ALL
			SELECT 'Receiving Mode',ISNULL(@receivingMode,'All')
			UNION ALL
			SELECT 'Tran Type' head,case when @tranType IS NULL THEN 'All' WHEN @tranType ='D' THEN 'Domestic' ELSE 'International' end VALUE
			UNION ALL
			SELECT 'Status' head,case when ISNULL(@status,'All') = 'Payment' then 'Unpaid' else ISNULL(@status,'All') end VALUE
			UNION ALL
			SELECT 'Report In ' head,case when @reportIn='cCurr' THEN 'Collection Currency' ELSE 'USD' END VALUE
			UNION ALL
			SELECT 'Report Template' head,(SELECT templateName FROM ReportTemplate WITH(NOLOCK) WHERE id= @rptTemplate) VALUE
		END
		SELECT 'Transaction Report' title					
    END 





GO
