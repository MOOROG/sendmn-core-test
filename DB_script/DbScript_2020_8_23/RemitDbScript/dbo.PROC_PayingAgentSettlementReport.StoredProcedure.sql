USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_PayingAgentSettlementReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_PayingAgentSettlementReport]
@fdate varchar(10)
,@toDate varchar(20)
,@flag varchar(10)
,@user varchar(50)
,@agentId INT = null

AS
SET NOCOUNT ON
--select @fdate='2017-10-10',@toDate='2017-10-13'

set @toDate = @toDate +' 23:59:59'

if @flag = 's'
begin
	select pAgentName 'Paying Agent' ,cnt [Count] 
	,'Average NPR Rate' = pCurrCostRate/cnt,tAmt 'Principal KRW',pAmt 'Principal NPR'
	,principalUSD 'Principal USD',commUSD 'Comm USD' from (
		select pAgentName,cnt = count('a'),pCurrCostRate = sum(pCurrCostRate),tAmt=sum(tAmt),pAmt = sum(pAmt)
			,'principalUSD' = sum(pAmt/pCurrCostRate) ,'commUSD' = sum(sAgentComm/pCurrCostRate)
		from remittran(nolock)
		where createdDate between @fdate and  @toDate
		AND pAgent  = ISNULL(@agentId,pAgent)
		GROUP BY pAgentName
	)x

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	SELECT  'From Date ' head,@fdate value
	UNION ALL  
	SELECT  'To Date ' head,@toDate value
	   
	SELECT 'Paying Agent Settlement Report Summary' title

end
else if @flag = 'detail1'
begin
	select pAgentName 'Paying Agent',controlno = dbo.FNADecryptString(controlNo),'USD-NPR' = pCurrCostRate,'Principal KRW' = tAmt,
		'Principal NPR' = pAmt,'Comm KRW' = sAgentComm,'Principal USD' = pAmt/pCurrCostRate,'Comm USD'=sAgentComm/pCurrCostRate
		,'USD-KRW'=sCurrCostRate
	from remittran(nolock)
	where createdDate between @fdate and  @toDate
	AND ISNULL(pAgent, 1056) = ISNULL(@agentId,1056)

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	SELECT  'From Date ' head,@fdate value
	UNION ALL  
	SELECT  'To Date ' head,@toDate value
	   
	SELECT 'Paying Agent Settlement Report Summary' title

end

GO
