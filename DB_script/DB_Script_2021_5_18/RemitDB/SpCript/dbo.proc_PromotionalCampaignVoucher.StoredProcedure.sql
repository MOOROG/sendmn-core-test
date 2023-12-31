USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PromotionalCampaignVoucher]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC proc_PromotionalCampaignVoucher @flag = 'Report',@sDate ='2018-08-01',@tDate ='2018-08-31',@referalCode='9424010802601'
--EXEC proc_PromotionalCampaignVoucher @flag = 'Report_Old',@sDate ='2018-06-01',@tDate ='2018-06-30',@referalCode='9424010758109'

CREATE proc [dbo].[proc_PromotionalCampaignVoucher]
@flag varchar(10),
@sDate varchar(10) = NULL,
@tDate varchar(20) = NULL,
@referalCode varchar(20) = null,
@User	varchar(50) = NULL
as
set nocount on;

if @flag = 'Report'
begin
declare  @schemeDate date
SET @schemeDate = '2018-05-01'

select customerId,referelCode,SchemeStartDate INTO #REFERALCUSTOMER from customerMaster c(nolock) 
where referelCode is not null
and len(referelCode) = 13 and left(referelCode,5) = '94240'
and approvedDate between '2018-04-20' and @tDate+' 23:59:59'
--and SchemeStartDate between @sDate and @tDate

--DELETE FROM #REFERALCUSTOMER WHERE SchemeStartDate NOT BETWEEN @sDate and @tDate+' 23:59:59'

delete r from #REFERALCUSTOMER r
LEFT join VirtualAccountMapping v(nolock) on v.virtualAccNumber = r.referelCode
WHERE V.virtualAccNumber IS NULL

delete from #REFERALCUSTOMER where referelCode = '9424010921362'

SELECT Y.*,R.referelCode into #transaction 
FROM (
	select distinct customerId,referelCode FROM #REFERALCUSTOMER) R
	INNER JOIN(
	select s.tranId,t.approvedDate,s.customerId 
	from tranSenders s(nolock)
	inner join remittran t(nolock) on t.id = s.tranId
	WHERE T.approvedDate between @sDate and @tDate+' 23:59:59'
	and t.transtatus <> 'Cancel'
)Y ON R.customerId = Y.customerId

---- for first transaction
SELECT min(tranId) tranId,r.customerId into #firstTxn FROM #REFERALCUSTOMER R
INNER JOIN #transaction y ON R.customerId = Y.customerId
where y.approvedDate between @sDate and @tDate+' 23:59:59'
group by r.customerId

if exists(select 'a' from #firstTxn group by customerId having count(1)>1)
begin
	exec proc_errorHandler '1','First Txn count can not be duplicate',null
	return
end

ALTER TABLE #transaction ADD IsFirstTxn bit

--SELECT * FROM #transaction T
--INNER JOIN #firstTxn F ON F.id = T.id

update t set t.IsFirstTxn = 1 from #transaction T
INNER JOIN #firstTxn F ON F.tranId = T.tranId

delete from #transaction WHERE IsFirstTxn IS NULL

delete t from #transaction t
inner join PromotionalCampaignTxn p(nolock) on p.CustomerId = t.CustomerId
WHERE P.IsFirstTxn = 1

INSERT INTO PromotionalCampaignTxn(TranId,ApprovedDate,CustomerId,referelCode,IsFirstTxn,FirstTxnPay,RestTxnPay,SchemeType,RegdCustomer)
SELECT TranId,ApprovedDate,CustomerId,T.referelCode,IsFirstTxn
		,FirstTxnPay = case when IsFirstTxn = 1 then 10000 else 0 end
		,RestTxnPay = 0,'N',R.CNT
from #transaction T
INNER JOIN (SELECT COUNT(1) CNT,referelCode FROM #REFERALCUSTOMER GROUP BY referelCode) R ON R.referelCode = T.referelCode

select m.firstName [ReferalName],m.idNumber,c.referelCode,m.SchemeStartDate,m.city
		,RegdCustomer = (C.RegdCustomer)
		,[FirstTxn] = SUM(case when IsFirstTxn=1 then 1 else 0 end)
		--,[RestTxn] = SUM(case when IsFirstTxn IS NULL then 1 else 0 end)
		,[RestTxn] = 0
		,[NetPayable] = sum(FirstTxnPay),errorCode = 0
		,Country = (select countryName from countryMaster(nolock) where countryId = m.nativeCountry)
from PromotionalCampaignTxn c(nolock) 
INNER JOIN customerMaster m(nolock) on m.walletAccountNo = c.referelCode
where 
c.ApprovedDate between @sDate and DATEADD(D,1,@tDate)
and c.referelCode =  isnull(@referalCode,c.referelCode)
and isfirsttxn = 1 and SchemeType = 'N'
GROUP BY m.firstName,m.idNumber,c.referelCode,m.SchemeStartDate,m.city,m.nativeCountry,C.RegdCustomer
ORDER BY 1 

end

if @flag = 'Report_Old'
begin

select customerId,referelCode INTO #REFERALCUSTOMER_OLD from customerMaster c(nolock) 
where referelCode is not null
and len(referelCode) = 13 and left(referelCode,5) = '94240'
and approvedDate between '2018-04-01' and '2018-04-30 23:59:59'

delete r from #REFERALCUSTOMER_OLD r
LEFT join VirtualAccountMapping v(nolock) on v.virtualAccNumber = r.referelCode
WHERE V.virtualAccNumber IS NULL

delete from #REFERALCUSTOMER_OLD where referelCode = '9424010921362'

SELECT Y.*,R.referelCode into #transaction_OLD FROM #REFERALCUSTOMER_OLD R
INNER JOIN(
select s.tranId,t.approvedDate,s.customerId 
from tranSenders s(nolock)
inner join remittran t(nolock) on t.id = s.tranId
WHERE T.approvedDate between @sDate and @tDate+' 23:59:59'
and t.transtatus <> 'Cancel'
)Y ON R.customerId = Y.customerId

---- for first transaction
SELECT min(tranId) tranId,r.customerId into #firstTxn_OLD FROM #REFERALCUSTOMER_OLD R
INNER JOIN #transaction_OLD y ON R.customerId = Y.customerId
where y.approvedDate between @sDate and @tDate+' 23:59:59'
group by r.customerId

if exists(select 'a' from #firstTxn_OLD group by customerId having count(1)>1)
begin
	exec proc_errorHandler '1','First Txn count can not be duplicate',null
	return
end

ALTER TABLE #transaction_OLD ADD IsFirstTxn bit

--SELECT * FROM #transaction T
--INNER JOIN #firstTxn F ON F.id = T.id

update t set t.IsFirstTxn = 1 from #transaction_OLD T
INNER JOIN #firstTxn_OLD F ON F.tranId = T.tranId

delete t from #transaction_OLD t
inner join PromotionalCampaignTxn p(nolock) on p.CustomerId = t.CustomerId
WHERE P.IsFirstTxn = 1

DELETE FROM #transaction_OLD WHERE IsFirstTxn IS NULL 

INSERT INTO PromotionalCampaignTxn(TranId,ApprovedDate,CustomerId,referelCode,IsFirstTxn,FirstTxnPay,RestTxnPay,SchemeType,RegdCustomer)
SELECT TranId,ApprovedDate,CustomerId,T.referelCode,IsFirstTxn
		,FirstTxnPay = case when IsFirstTxn = 1 then 10000 else 0 end
		,RestTxnPay = 0,'O',R.CNT
from #transaction_OLD T
INNER JOIN (SELECT COUNT(1) CNT,referelCode FROM #REFERALCUSTOMER_OLD GROUP BY referelCode) R ON R.referelCode = T.referelCode

select m.firstName [ReferalName],m.idNumber,c.referelCode,m.SchemeStartDate,m.city
		,RegdCustomer = (C.RegdCustomer)
		,[FirstTxn] = SUM(case when IsFirstTxn=1 then 1 else 0 end)
		--,[RestTxn] = SUM(case when IsFirstTxn IS NULL then 1 else 0 end)
		,[RestTxn] = 0
		,[NetPayable] = sum(FirstTxnPay),errorCode = 0
		,Country = (select countryName from countryMaster(nolock) where countryId = m.nativeCountry)
from PromotionalCampaignTxn c(nolock) 
INNER JOIN customerMaster m(nolock) on m.walletAccountNo = c.referelCode
where 
c.ApprovedDate between @sDate and DATEADD(D,1,@tDate)
and c.referelCode =  isnull(@referalCode,c.referelCode)
and isfirsttxn = 1 and SchemeType = 'O'
GROUP BY m.firstName,m.idNumber,c.referelCode,m.SchemeStartDate,m.city,m.nativeCountry,C.RegdCustomer
ORDER BY 1 

end
GO
