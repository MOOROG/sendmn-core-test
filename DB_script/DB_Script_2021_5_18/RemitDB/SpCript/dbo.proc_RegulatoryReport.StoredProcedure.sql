USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_RegulatoryReport]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC proc_RegulatoryReport @DATE='2018-09-14'
CREATE proc [dbo].[proc_RegulatoryReport]
@DATE DATETIME
AS
SET NOCOUNT ON;
SET ARITHABORT ON;

select sbranch [Handling branch]
	,[TransferDel] = '1',r.cancelApprovedDate
	,r.id [SerialNo],1 [formOfRemit]
	,r.createdDate [remitDT]
	,collCurr,tAmt [RemittanceAmt],sCurrCostRate+ISNULL(sCurrHoMargin,0) [USDExRate]
	,[RemitUSDAmt] = CAST(tAmt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)) AS DECIMAL(16,2))
	,serviceCharge,senderName = left(senderName,60)
,[SenderVerificationType] = s.idType
,[SenderVerificationNum] = s.idNumber
,[Controlno] = dbo.FNADecryptString(r.controlNo)
,receiverName = LEFT(r.receiverName,60),CM.countryCode [BeneficiaryCountry]
,c.countryCode,s.customerId
INTO #TEMP
from remitTran r(nolock)
INNER join tranSenders s (nolock) on s.tranId = r.Id
LEFT JOIN countryMaster C(NOLOCK) ON C.countryName = S.nativeCountry
LEFT JOIN countryMaster CM (NOLOCK) ON CM.COUNTRYNAME = R.pCountry
where 1=1 
--and FORMAT(r.createdDate,'yyyyMMdd') <> FORMAT(ISNULL(r.cancelApprovedDate,'2000-01-01'),'yyyyMMdd')
AND (r.createdDate between @DATE and  @DATE+' 23:59:59' OR r.cancelApprovedDate between @DATE and  @DATE+' 23:59:59')

ALTER TABLE #TEMP ADD [zipcode] VARCHAR(20)

DELETE FROM #TEMP WHERE FORMAT([remitDT],'yyyyMMdd') = FORMAT(ISNULL(cancelApprovedDate,'2000-01-01'),'yyyyMMdd')

UPDATE #TEMP SET cancelApprovedDate = NULL WHERE FORMAT(cancelApprovedDate,'yyyyMMdd') > @DATE

UPDATE t set t.[zipcode] = 'A' + RIGHT('000000'+CAST(m.swiftCode AS VARCHAR(6)),6) FROM #TEMP T
INNER JOIN agentMaster m(nolock) on m.agentId = t.[Handling branch]

SELECT [Handling branch],[zipcode]
		,[TransferDel] = CASE WHEN FORMAT(ISNULL(cancelApprovedDate,'2200-01-01'),'yyyyMMdd') >FORMAT(CAST(@DATE AS DATE),'yyyyMMdd') THEN '1' ELSE '2' END 
		,[SerialNo],[formOfRemit]
		,[remitDT] = FORMAT([remitDT],'yyyyMMdd')
		,[remitTime] = 'H' + RIGHT('000000'+CAST(FORMAT(remitDT,'HHmmss') AS VARCHAR(6)),6)
		,collCurr,[RemittanceAmt],[USDExRate],[RemitUSDAmt]
		,serviceCharge,senderName
		,[SenderVerificationType] = CASE 
								WHEN LEN(REPLACE(SenderVerificationNum, '-', '')) <> '13' THEN '99'
								WHEN LEFT(RIGHT(REPLACE(SenderVerificationNum, '-', ''), 7), 1) = '0' THEN 'P02'
								WHEN LEFT(RIGHT(REPLACE(SenderVerificationNum, '-', ''), 7), 1) IN ('1', '2', '3', '4') THEN 'P01'
								WHEN LEFT(RIGHT(REPLACE(SenderVerificationNum, '-', ''), 7), 1) IN ('5', '6') THEN 'P04'
								ELSE '99'
							END
		,[SenderVerificationNum] = replace(SenderVerificationNum,'-','') 
		,[SenderCountry] = CASE WHEN SenderVerificationType IN ('Alien Registration Card','National ID') AND LEFT(RIGHT(REPLACE(SenderVerificationNum, '-', ''), 7), 1) IN ('1', '2', '3', '4') THEN 'KR' ELSE countryCode END
		,[SumUSDAmt],[Controlno],receiverName,[BeneficiaryCountry]
FROM(
	SELECT y.SumUSDAmt,s.* FROM #TEMP s
	LEFT JOIN(
		SELECT [SumUSDAmt] = SUM(tAmt/(sCurrCostRate+sCurrHoMargin)),s.customerId
		FROM remitTran r(NOLOCK)
		INNER JOIN tranSenders s (NOLOCK) ON s.tranId = r.Id
		--WHERE R.tranStatus <> 'Cancel'
		GROUP BY s.customerId
	) y ON y.customerId = s.customerId
)X
ORDER BY [SerialNo], [TransferDel]
GO
