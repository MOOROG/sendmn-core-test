USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_AutoDebit_REPORT]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC PROC_AutoDebit_REPORT  @flag='S',@statusType='1'

CREATE PROCEDURE [dbo].[PROC_AutoDebit_REPORT] 
	@startDate	VARCHAR(20)= null,
	@endDate		VARCHAR(20)=null,
	@statusType		CHAR(30)		= NULL,
	@flag		CHAR(1) ='s',
	@user VARCHAR(50) = NULL,
	@pageNumber INT			= NULL,
	@agentId VARCHAR(50)	= NULL,
	@pageSize	INT			= NULL
 AS 
 SET NOCOUNT ON;
 BEGIN
    DECLARE @sql VARCHAR(max)= null
	IF @flag ='s'
	BEGIN
		
		IF @startDate IS NULL
			SELECT  @startDate = CONVERT(VARCHAR,GETDATE(),101),@endDate = CONVERT(VARCHAR,GETDATE(),101)

		SET @sql =	'SELECT csm.FirstName AS [Customer Name]
							,csm.idNumber AS [Id Number]
							,csm.walletAccountNo AS [GME Wallet NO]
							, Kct.bankTranId AS [Bank Tran ID]
							,Kct.apiTranDtm AS [Bank Tran Date]
							,kcs.accountNum AS [Account No]
							,kcs.bankName AS [Bank Name]
							,kcs.accountName AS [Account Name]
							,Kct.tranAmt AS [Tran Amount]
					FROM dbo.customerMaster csm(NOLOCK)
					INNER JOIN  KFTC_customer_transfer Kct (NOLOCK) ON csm.customerId = kct.customerId
					INNER JOIN dbo.KFTC_CUSTOMER_SUB kcs(NOLOCK) ON kct.fintechUseNo = kcs.fintechUseNo WHERE 1=1'
		
		IF @startDate IS NOT NULL
			SET @SQL = @SQL +' AND CAST(Kct.bankTranDate AS DATE) Between '''+@startDate +''' AND '''+@endDate +' 23:59:59'''
		IF @statusType IS NOT NULL
			SET @sql = @sql + ' AND Kct.errorCode =' + @statusType 
		
		SET @sql = 'SELECT [Customer Name],[Id Number],[GME Wallet NO],[Bank Tran ID],[Bank Tran Date] = LEFT([Bank Tran Date],8)+'' ''+RIGHT([Bank Tran Date],9) ,[Account No],[Bank Name],[Account Name],[Tran Amount] FROM ('+ @sql +' )X'
	
		EXEC(@SQL)
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT 'From Date' head, @startDate value UNION ALL
		SELECT 'To Date', @endDate UNION ALL
		SELECT 'Status Type', ISNULL(@statusType,'All')
		SELECT 'Auto Debit Transaction Report' title

	END
END




GO
