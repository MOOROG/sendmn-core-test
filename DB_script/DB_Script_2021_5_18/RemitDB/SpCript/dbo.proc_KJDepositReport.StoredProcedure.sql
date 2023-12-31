USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_KJDepositReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_KJDepositReport]
@flag varchar(10),
@startDate varchar(10),
@endDate varchar(20),
@user	varchar(40),
@searchType varchar(30) = null,
@searchValue varchar(150) = null

as
set nocount on
if @flag = 's'
begin
		SELECT D.bankName [Bank Name],SUM(T.deposit) [Sum Amount],COUNT(1) [No of Txn]
		FROM dbo.CUSTOMER_TRANSACTIONS T(NOLOCK)
		INNER JOIN  dbo.CUSTOMER_DEPOSIT_LOGS D(NOLOCK) ON T.refereceId = D.tranId
		where D.tranDate between @startDate and @endDate+' 23:59:59'
		GROUP BY D.bankName
end
if @flag = 'd'
begin
		SELECT D.bankName [Bank Name],D.tranDate [Received On],C.fullName [Customer Name],T.deposit
		FROM dbo.CUSTOMER_TRANSACTIONS T(NOLOCK)
		INNER JOIN  dbo.CUSTOMER_DEPOSIT_LOGS D(NOLOCK) ON T.refereceId = D.tranId
		INNER JOIN dbo.customerMaster C(NOLOCK) ON T.customerId = C.customerId
		WHERE D.tranDate between @startDate and @endDate+' 23:59:59'
end
if @flag = 'statement'
begin
	SELECT CM.fullName [CUSTOMER NAME]
			,CM.email [CUSTOMER EMAIL]
			,CT.particulars [PARTICULARS]
			,CT.deposit [DEPOSITED AMOUNT]
			,CT.withdraw [WITHDRAW/SEND AMOUNT]
	FROM CUSTOMER_TRANSACTIONS CT(NOLOCK)
	INNER JOIN customerMaster CM(NOLOCK) ON CM.customerId = CT.customerId
	WHERE CT.customerId = @searchValue 
	AND CT.tranDate BETWEEN @startDate AND @endDate + ' 23:59:59'
end
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			
SELECT  'From Date ' head,@startDate value union all
SELECT  'To Date ' head,@endDate value 
		
SELECT 'Bank Deposit Report' title
GO
