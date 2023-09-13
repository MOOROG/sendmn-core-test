SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

--EXEC proc_referralReport @flag = 'transaction-rpt',@startDate = '2018-03-01',@endDate = '2018-03-31',@user = 'admin',@referralCode = '9424010704321',@country = 'Cambodia'

ALTER PROC proc_referralReport
(
	@flag			VARCHAR(50)
	,@startDate		VARCHAR(10)
	,@endDate		VARCHAR(30)
	,@user			VARCHAR(30) = NULL
	,@referralCode	VARCHAR(30) = NULL
	,@country		VARCHAR(10) = NULL
	
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @sqlRegister varchar(MAX)

BEGIN
	IF @flag = 'register-rpt'
	BEGIN
	
		set @sqlRegister='SELECT 
								[Referral Name] = dbo.FunGetWalletName(cm.referelCode)
								,[Referral Code] = cm.referelCode
								,[Native Country] = cr.countryName 
								,[No Of Registered] = ''<a href="#" onclick="OpenInNewWindow(''''/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerreportdrilldowntotalreferrerdetail&startDate=' + @startDate + '&endDate='+ @endDate + 
									'&referralCode=''+cm.referelCode+''&flag=detail-customer-drilldown-report'''')">'' + CAST(count(1) AS VARCHAR) + ''</a>''
							FROM customermaster (NOLOCK) cm
							JOIN countrymaster (NOLOCK) cr ON cr.countryId=cm.nativeCountry 
							WHERE 1 = 1  AND referelCode IS NOT NULL
							--AND LEN(cm.referelCode) = 13 AND LEFT(cm.referelCode,5) = ''94240''
							and cm.ApprovedDate BETWEEN ''' + @startDate + ''' AND ''' + @endDate + ' 23:59:59'''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister = @sqlRegister + ' AND cm.referelCode = ''' + @referralCode + ''''
		
		if @country is not null
			SET @sqlRegister = @sqlRegister + ' AND cr.countryName  = ''' + @country + ''''

		SET @sqlRegister = @sqlRegister+' GROUP BY cm.referelCode,cr.countryName order by 1 '

		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Register Report' title
	END
	ELSE IF @flag = 'transaction-rpt'
	BEGIN
		SET @sqlRegister='
		SELECT 
			[Referral Name] = dbo.FunGetWalletName(cm.referelCode) 
			,[Referral Code] = cm.referelCode
			,[Native Country] = cr.countryName 
			,[No Of Txn] = ''<a href="#" onclick="OpenInNewWindow(''''/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=txnreportdrilldowntotalreferrerdetail&startDate=' + @startDate + '&endDate='+ @endDate + 
								'&referralCode=''+cm.referelCode+''&flag=detail-txn-drilldown-report'''')">'' + CAST(COUNT(1) AS VARCHAR) + ''</a>''
		FROM customermaster (NOLOCK) cm
		JOIN tranSenders (NOLOCK) ts on ts.customerid = cm.customerid
		JOIN remitTran (NOLOCK) rt on rt.id = ts.tranId
		JOIN countrymaster (NOLOCK) cr ON cr.countryId = cm.nativeCountry 
		WHERE 1 = 1 and
		 cm.ApprovedDate BETWEEN ''' + @startDate + ''' AND ''' + @endDate + ' 23:59:59'''
		
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister=@sqlRegister+' AND cm.referelCode = ''' + @referralCode + ''''
		
		if @country is not null
			SET @sqlRegister = @sqlRegister + ' AND cr.countryName  = ''' + @country + ''''

		SET @sqlRegister=@sqlRegister+' GROUP BY cm.referelCode, cr.countryName  order by 1  '
		
		EXEC(@sqlRegister)
		print @sqlRegister
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Transaction Report' title		
	END

	ELSE IF @flag = 'detail-customer-report'
	BEGIN
		set @sqlRegister='
						SELECT 
							[Referral Code]	 = cm.referelCode
							,[Referral Name] = dbo.FunGetWalletName(cm.referelCode) 
							,[Customer Name] = cm.fullName
							,[Id Number]	 = cm.idNumber
							,[Mobile No]	 = cm.Mobile
							,[Register Date] = cm.approvedDate
							,[Register By]	 = cm.approvedBy
						FROM customermaster (NOLOCK) cm
						WHERE 1 = 1 and 
						 cm.Approveddate BETWEEN '''+@startDate+''' AND '''+@endDate+''''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister=@sqlRegister+' AND cm.referelCode='''+@referralCode+''''

		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, CASE WHEN @referralCode IS NULL THEN 'N/A' ELSE @referralCode END
		
		SELECT 'Customer Report Drill Down Detail' title
	END
	ELSE IF @flag = 'detail-txn-report'
	BEGIN
		--LEN(cm.referelCode) = 13 AND LEFT(cm.referelCode,5) = ''94240''
		set @sqlRegister='
						SELECT 
							[Referral Code]  = cm.referelCode
							,[Referral Name] = dbo.FunGetWalletName(cm.referelCode) 
							,[Customer Name] = cm.fullName 
							,[Id Number]	 = cm.idNumber
							,[Mobile No]	 = cm.Mobile
							,[Control No]    = dbo.fnadecryptstring(rt.controlNo)
							,[Tran Date]     = rt.approvedDate
						FROM customermaster (NOLOCK) cm
						JOIN tranSenders (NOLOCK) ts on ts.customerid=cm.customerid
						JOIN remitTran (NOLOCK) rt on rt.id=ts.tranId
						WHERE 1 = 1
						'

		IF @startDate IS NOT NULL AND @endDate IS NOT NULL
			SET @sqlRegister = @sqlRegister+' and rt.approvedDate BETWEEN ''' + @startDate + ''' AND ''' + @endDate + ''''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister = @sqlRegister+' AND cm.referelCode = '''+@referralCode+''''

		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Txn Report Drill Down Detail' title
	END
	ELSE IF @flag = 'detail-customer-drilldown-report'
	BEGIN
		set @sqlRegister='
						SELECT 
							[Referral Name]   = dbo.FunGetWalletName(cm.referelCode) 
							,[Referral Code]  = cm.referelCode
							,[Customer Name]  = cm.fullName
							,[Native Country] = cr.countryName 
							,[Id Number]	  = cm.idNumber
							,[Mobile No]	  = cm.Mobile
							,[Register Date]  = cm.approvedDate
							,[Register By]	  = cm.approvedBy
						FROM customermaster (NOLOCK) cm
						JOIN countrymaster (NOLOCK) cr ON cr.countryId = cm.nativeCountry 
						WHERE 1 = 1'
		
		IF @startDate IS NOT NULL AND @endDate IS NOT NULL
			SET @sqlRegister=@sqlRegister+' and cm.ApprovedDate BETWEEN '''+@startDate+''' AND '''+@endDate+''''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister=@sqlRegister+' AND cm.referelCode='''+@referralCode+''''
		
		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Detail Report' title
	END
	ELSE IF @flag = 'detail-txn-drilldown-report'
	BEGIN
		set @sqlRegister='
						SELECT 
							[Referral Name]   = dbo.FunGetWalletName(cm.referelCode)
							,[Referral Code]  = cm.referelCode
							,[Customer Name]  = cm.fullName
							,[Native Country] = cr.countryName 
							,[Id Number]	  = cm.idNumber
							,[Mobile No]	  = cm.Mobile
							,[Control No]     = dbo.fnadecryptstring(rt.controlNo)
							,[Sending Amount] = rt.tAmt
						FROM customermaster (NOLOCK) cm
						join tranSenders (nolock) ts on ts.customerid=cm.customerid
						join remitTran (nolock) rt on rt.id=ts.tranId
						JOIN countrymaster (NOLOCK) cr ON cr.countryId=cm.nativeCountry 
						WHERE 1 = 1'

		IF @startDate IS NOT NULL AND @endDate IS NOT NULL
			SET @sqlRegister=@sqlRegister+' and rt.ApprovedDate BETWEEN '''+@startDate+''' AND '''+@endDate+''''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister=@sqlRegister+' AND cm.referelCode='''+@referralCode+''''
		
		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Detail Report' title
	END

	IF @flag = 'summary-rpt'
	BEGIN
		set @sqlRegister='SELECT 
								 promotionCode [Refferal No]
								,pCountry [Country]
								,[No Of Txn] = ''<a href="#" onclick="OpenInNewWindow(''''/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=txnreportdrilldowntotalreferrerdetail&startDate=' + @startDate + '&endDate='+ @endDate + 
								'&referralCode=''+promotionCode+''&country=''+pCountry+''+&flag=detail-drilldown-report'''')">'' + CAST(COUNT(1) AS VARCHAR) + ''</a>''
								,SUM(cAmt) [Total Amount]
								FROM dbo.remitTran
							WHERE ISNULL(promotionCode,'''')!=''''
							AND ApprovedDate BETWEEN ''' + @startDate + ''' AND ''' + @endDate + ' 23:59:59'''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister = @sqlRegister + ' AND promotionCode = ''' + @referralCode + ''''
		
		if @country is not null
			SET @sqlRegister = @sqlRegister + ' AND pCountry  = ''' + @country + ''''

		SET @sqlRegister =@sqlRegister+'GROUP BY promotionCode,pCountry ';
			PRINT @sqlRegister
		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Register Report' title
	END

	IF @flag = 'details-rpt'
	BEGIN
		set @sqlRegister='SELECT 
									dbo.FNADecryptString(controlNo) [Control No],
									promotionCode [Referral Code],
									pCountry [Country]
									FROM dbo.remitTran
							WHERE ISNULL(promotionCode,'''')!=''''
							AND ApprovedDate BETWEEN ''' + @startDate + ''' AND ''' + @endDate + ' 23:59:59'''
		IF ISNULL(@referralCode, '') <> ''
			SET @sqlRegister = @sqlRegister + ' AND promotionCode = ''' + @referralCode + ''''
		
		if @country is not null
			SET @sqlRegister = @sqlRegister + ' AND pCountry  = ''' + @country + ''''

		--SET @sqlRegister =@sqlRegister+'GROUP BY promotionCode,pCountry ';
			PRINT @sqlRegister
		EXEC(@sqlRegister)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Register Report' title
	END

	IF @flag='detail-drilldown-report'
	BEGIN
	    SET @sqlRegister='SELECT  
							[Control No]=''  <span class="link" onclick="ViewTranDetailByControlNo(''+dbo.FNADecryptString(controlNo)+'');">'' + dbo.FNADecryptString(controlNo) + ''</span>''
							,approvedDate [TXN Date]
							,sCountry [Sending Country]
							,sAgentName [Sending Agent]
							,sBranchName [Sending Branch]
							,collCurr [Sending Currency]
							,tranStatus [Status]
							,pCountry [Receiving Country]
							,pLocation [Receiving Location]
							,pAgentName [Receiving Agent]
							,pBranchName [Receiving Branch]
							,pAmt [Receiving Amt]
							,accountNo [Account No.]
							,tranStatus [Tran Type]
							,senderName [Sender Name]
							,receiverName [Receiver Name]
						FROM dbo.remitTran (NOLOCK)
						WHERE ISNULL(promotionCode,'''')!=''''' 
		IF @referralCode IS NOT NULL
			SET @sqlRegister = @sqlRegister + ' AND promotionCode = ''' + @referralCode + ''''
		IF @startDate IS NOT NULL AND @endDate IS NOT NULL
			SET @sqlRegister = @sqlRegister + ' AND ApprovedDate BETWEEN ''' + @startDate + ''' AND ''' + @endDate + ' 23:59:59'''
		IF @country IS NOT NULL
			SET @sqlRegister = @sqlRegister + ' AND pCountry = ''' + @country + ''''
		PRINT @sqlRegister		
		EXEC(@sqlRegister)
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'From Date' head, @startDate value union all
		SELECT  'To Date' head, @endDate value  UNION ALL	
		SELECT 'Referral Code' head, @referralCode
		
		SELECT 'Summary Report' title
	END
END

GO

