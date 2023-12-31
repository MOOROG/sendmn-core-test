USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_SMSRpt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_SMSRpt]
		 @flag				VARCHAR(10)	 = NULL
		,@user				VARCHAR(30)  = NULL
		,@fromDate			VARCHAR(50)	 = NULL
		,@toDate			VARCHAR(50)	 = NULL
		,@country			VARCHAR(100) = NULL
		,@pageNumber		INT			 = NULL
		,@pageSize			INT			 = NULL
	
		
	AS 
	
SET NOCOUNT ON;
SET XACT_ABORT ON ;	
BEGIN TRY
		
 IF @flag = 's' -- summary
 BEGIN
		DECLARE @sql VARCHAR(MAX),@URL VARCHAR(500)
		SET @URL='"Reports.aspx?reportName=20164500&rptType=d&fromDate='+@fromDate+'&toDate='+@toDate+'&country=''+ISNULL(REPLACE(isnull(sms.Country,''Manual Sent''),'' '',''__''),'''')+''"'
		
		SET @sql ='SELECT 
						 [S.N.] = ROW_NUMBER()OVER(ORDER BY country) 
						,[Country] = ''<span class = "link" onclick =ViewAMLDDLReport('+@URL+');>'' + isnull(sms.country,''Manual Sent'') + ''</span>''  
						,[Total SMS] = COUNT(''X'')  
					FROM SMSQueue sms WITH(NOLOCK) 
						WHERE sms.mobileNo IS NOT NULL 
						AND sms.sentDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''

		IF @country IS NOT NULL 
			SET @sql = @sql + ' AND sms.country = '''+ @country +''''

		SET @sql = @sql + ' GROUP BY sms.COUNTRY'

		print(@sql)
		EXEC(@sql)
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			
		SELECT 'Country' head,@country VALUE
		UNION ALL
		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL 
		SELECT 'TO Date' head,@toDate VALUE		

		SELECT 'SMS Reporting - Summary' title
END

 IF @flag = 'd' -- detail
 BEGIN
		SET @country = REPLACE(@country,'__',' ')
		SET @sql ='SELECT 
						 [S.N.] = row_number() over(order by sms.rowId)
						,[Country] = sms.country
						,[Mobile] = sms.mobileNo
						,[Message] = sms.msg
						,[Sent Date & Time] = sms.sentDate
						,[Control No] = dbo.fnadecryptString(sms.controlNo)
					 FROM smsqueue sms with(nolock) 
						WHERE sms.mobileNo is not null 
						AND sms.sentDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''

		
		if @country is not null and @country <> 'Manual Sent'
			SET @sql = @sql +' AND sms.country='''+ @country +'''' 
		if @country is not null and @country = 'Manual Sent'
			SET @sql = @sql +' AND sms.country IS NULL'
			 
		--PRINT(@sql)
		EXEC(@sql)
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			
		SELECT 'Country' head,@country VALUE
		UNION ALL
		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL 
		SELECT 'TO Date' head,@toDate VALUE		

		SELECT 'SMS Reporting - Detail' title	
END


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
     print error_line()
END CATCH

GO
