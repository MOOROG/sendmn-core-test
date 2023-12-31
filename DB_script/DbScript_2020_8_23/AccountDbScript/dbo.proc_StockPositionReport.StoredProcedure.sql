ALTER  proc [dbo].[proc_StockPositionReport]
@flag		varchar(10),
@user		varchar(50),
@fromDate	varchar(10) = null,
@toDate		varchar(20) = null

as
set nocount on;
if @flag = 's'
begin
	declare @result table(UsdAmt money,Rate money,KRWAmt money,TxnDate varchar(10),Currency varchar(5))
	if @fromDate is null or @fromDate = cast(getdate() as date)
	begin
		INSERT INTO @result
		select top 1 UsdAmt,Rate,KRWAmt,TxnDate = convert(varchar,TxnDate,101),'USD' from UsdStockSummary(nolock) order by id desc 

		INSERT INTO @result
		select s.UsdAmt,s.Rate,s.KRWAmt,TxnDate = convert(varchar,s.TxnDate,101),x.Curr from UsdStockSummary_other s(nolock)
		inner join (
			select id = max(id),Curr from UsdStockSummary_other(nolock)
			where curr <> 'USD'
			group by Curr
		)x on s.Id = x.id 
	end
	else
	begin
		INSERT INTO @result
		select s.UsdAmt,s.Rate,s.KRWAmt,TxnDate = convert(varchar,s.TxnDate,101),'USD' from UsdStockSummary s(nolock)
		inner join (
			select id = max(id),TxnDate from UsdStockSummary(nolock)
			group by TxnDate
		)x on s.Id = x.id
		WHERE X.TxnDate BETWEEN @fromDate AND @toDate +' 23:59:59'

		INSERT INTO @result
		select s.UsdAmt,s.Rate,s.KRWAmt,TxnDate = convert(varchar,s.TxnDate,101),x.Curr from UsdStockSummary_other s(nolock)
		inner join (
			select id = max(id),TxnDate,Curr from UsdStockSummary_other(nolock)
			where curr <> 'USD'
			group by TxnDate,Curr
		)x on s.Id = x.id
		WHERE X.TxnDate BETWEEN @fromDate AND @toDate +' 23:59:59'

	end
	
	SELECT * FROM @result

end
ELSE if @flag = 'P'
begin
	IF EXISTS(SELECT TOP 1 'A' FROM SendMnPro_Remit.dbo.remitTran(NOLOCK) WHERE pAgent IS NULL)
	BEGIN
		update t set t.pAgentName=m.agentName from SendMnPro_Remit.dbo.remitTran t
		INNER JOIN SendMnPro_Remit.dbo.agentMaster m(nolock) on m.agentId = t.pAgent
		WHERE T.pAgent IS NULL
	END

	SELECT t.pAgentName,UsdAmt = SUM(C.UsdAmt),TxnGain = SUM(TxnGain),TradingGL=SUM(TradingGL),TxnDate =convert(varchar,TxnDate,101)
	from CorrenpondentLibilities c(nolock)
	inner join SendMnPro_Remit.dbo.remitTran t(nolock) on t.id = c.TranId
	WHERE TxnDate BETWEEN @fromDate AND @toDate +' 23:59:59'
	GROUP BY t.pAgentName,convert(varchar,TxnDate,101)
end
ELSE if @flag = 'D'
begin
	IF EXISTS(SELECT TOP 1 'A' FROM SendMnPro_Remit.dbo.remitTran(NOLOCK) WHERE pAgent IS NULL)
	BEGIN
		update t set t.pAgentName=m.agentName from SendMnPro_Remit.dbo.remitTran t
		INNER JOIN SendMnPro_Remit.dbo.agentMaster m(nolock) on m.agentId = t.pAgent
		WHERE T.pAgent IS NULL
	END

	SELECT c.ControlNo,t.pAgentName,TxnDate,UsdAmt,Rate,KRWAmt,TxnGain,TradingGL,PositionUsd,BuyRate,PositionKrw 
	from CorrenpondentLibilities c(nolock)
	inner join SendMnPro_Remit.dbo.remitTran t(nolock) on t.id = c.TranId
	WHERE TxnDate BETWEEN @fromDate AND @toDate +' 23:59:59'
	order by t.Id desc 
end

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
SELECT  'From Date' head, @fromDate value union all
SELECT  'To Date' head, @toDate value
		
SELECT 'Register Report' title
GO
