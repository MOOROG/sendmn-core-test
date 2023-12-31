USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_WalletStatement]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[mobile_proc_WalletStatement]
	@startDate	VARCHAR(10)	= NULL,
	@endDate	VARCHAR(10)	= NULL,
	@UserID		VARCHAR(50)
AS
SET NOCOUNT ON;

DECLARE @acnum VARCHAR(20)
SELECT @acnum = walletAccountNo FROM customerMaster(nolock)
WHERE USERNAME = @UserID 


DECLARE @SQL VARCHAR(MAX)

IF @endDate IS NULL
	SELECT @endDate = CAST(GETDATE() AS DATE), @startDate= CAST(DATEADD(M,-3,GETDATE()) AS DATE)
DECLARE @RESULT TABLE(ID INT IDENTITY(1,1),TRNDate VARCHAR(10),tran_rmks VARCHAR(MAX),DRTotal DECIMAL(18,2),cRTotal DECIMAL(18,2),end_clr_balance DECIMAL(18,2),ref_num VARCHAR(20))

--INSERT INTO @RESULT
--Exec FastMoneyPro_Account.dbo.spa_branchstatement @flag='S' ,@acnum=@acnum,@startDate=@startDate,@endDate=@endDate,@company_id='1'

--UPDATE @RESULT SET tran_rmks = CASE 
--				WHEN field2='Send Voucher' THEN 'Control No :'+field1 
--				WHEN field2='Fund Deposit' THEN 'Amount Deposited' 
--			ELSE tran_rmks 
--			END  

--SELECT * FROM @RESULT

SET @SQL = '
SELECT CONVERT(VARCHAR,TRNDATE,102) AS TRNDATE,TRAN_RMKS,DRTOTAL,CRTOTAL,END_CLR_BALANCE,ref_num
FROM ( 
	SELECT 0 SN, '''+@startDate+''' TRNDATE, ''BALANCE BROUGHT FORWARD'' TRAN_RMKS, 0 DRTOTAL,0 CRTOTAL,ISNULL(END_CLR_BALANCE,0) END_CLR_BALANCE,'''' ref_num
	FROM (
		SELECT SUM (CASE WHEN PART_TRAN_TYPE=''DR'' THEN TRAN_AMT*-1 ELSE TRAN_AMT END) END_CLR_BALANCE
		FROM SendMNPro_Account.DBO.VW_PostedAccountDetail  WITH (NOLOCK) 
		WHERE ACC_NUM = '''+@acnum+''' AND TRAN_DATE < '''+@startDate+'''
		
		GROUP BY ACC_NUM
	) CA '	 

IF @endDate IS NOT NULL
BEGIN
SET @SQL = @SQL+' UNION ALL 
	SELECT TOP(1000) 1 SN,TRAN_DATE AS TRNDATE
	,TRAN_RMKS = CASE 
					WHEN field2=''Send Voucher'' THEN CASE WHEN acct_type_code IS NULL THEN ''Control No :''+field1 ELSE '' Cancellation of Control No :''+field1 END 
					WHEN field2=''Wallet Deposit'' THEN ''Wallet Load'' 
					WHEN field2=''Bank Deposit'' THEN ''Wallet Withdraw'' 
					WHEN field2=''Paid Voucher'' THEN ''Wallet Redeem'' 
					WHEN field2=''Refund Voucher'' THEN ''Amount Refunded'' 
					ELSE field2
				END 
	,CASE WHEN PART_TRAN_TYPE = ''DR'' THEN TRAN_AMT ELSE 0 END AS DRTOTAL
	,CASE WHEN PART_TRAN_TYPE = ''CR'' THEN TRAN_AMT ELSE 0 END AS CRTOTAL
	,0 BALANCE,ref_num
	FROM SendMNPro_Account.DBO.VW_PostedAccountDetail T WITH (NOLOCK)
	WHERE ACC_NUM = '''+@acnum +''' 
	AND T.COMPANY_ID=1  
	AND TRAN_DATE BETWEEN '''+@startDate+''' AND '''+@endDate+' 23:59:59''
	ORDER BY CREATED_DATE
) 
A ORDER BY TRNDATE'

END
ELSE 
BEGIN
SET @SQL = @SQL+' UNION ALL 
	SELECT TOP(7) 1 SN,TRAN_DATE AS TRNDATE
	,TRAN_RMKS = CASE 
					WHEN field2=''Send Voucher'' THEN CASE WHEN acct_type_code IS NULL THEN ''Control No :''+field1 ELSE '' Cancellation of Control No :''+field1 END 
					WHEN field2=''Wallet Deposit'' THEN ''Wallet Load'' 
					WHEN field2=''Bank Deposit'' THEN ''Wallet Withdraw'' 
					WHEN field2=''Paid Voucher'' THEN ''Wallet Redeem'' 
					WHEN field2=''Refund Voucher'' THEN ''Amount Refunded'' 
					ELSE field2
				END 
	,CASE WHEN PART_TRAN_TYPE = ''DR'' THEN TRAN_AMT ELSE 0 END AS DRTOTAL
	,CASE WHEN PART_TRAN_TYPE = ''CR'' THEN TRAN_AMT ELSE 0 END AS CRTOTAL
	,0 BALANCE,ref_num
	FROM SendMNPro_Account.DBO.VW_PostedAccountDetail T WITH (NOLOCK)
	WHERE ACC_NUM = '''+@acnum +'''
	AND T.COMPANY_ID=1 
	AND TRAN_DATE BETWEEN '''+@startDate+''' AND '''+@endDate+' 23:59:59''
	ORDER BY CREATED_DATE
) 
A ORDER BY TRNDATE desc'

END

--PRINT @SQL
INSERT INTO @RESULT
EXEC(@SQL)


SELECT * FROM @RESULT

GO
