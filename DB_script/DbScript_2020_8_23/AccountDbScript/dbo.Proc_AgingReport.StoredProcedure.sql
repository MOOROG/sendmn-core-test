ALTER  PROC [dbo].[Proc_AgingReport]
@walletAccountNo VARCHAR(20) = NULL

AS
SET NOCOUNT ON;

SELECT walletAccountNo,availableBalance = availableBalance*-1 INTO #Wallet 
FROM SendMnPro_Remit.dbo.customerMaster(NOLOCK) 
WHERE availableBalance > 0
AND walletAccountNo = ISNULL(@walletAccountNo,walletAccountNo)

TRUNCATE TABLE tblAgingReport

DECLARE @loop INT=1,@availableBalance MONEY
WHILE EXISTS(SELECT TOP 1 'A' FROM #Wallet)
BEGIN
	
	SELECT TOP 1 @walletAccountNo = walletAccountNo,@availableBalance = availableBalance FROM #Wallet  
	print @loop
	EXEC proc_LoadDummyAgingData @walletAccountNo,@availableBalance

	DELETE FROM #Wallet WHERE walletAccountNo = @walletAccountNo
	SET @loop = @loop +1
END


SELECT 
  x.walletNo
 ,SUM(x.LessThan24) AS LessThan24
 ,SUM(x.OneToTwo) AS OneToTwo
 ,SUM(x.ThreeToSeven) AS ThreeToSeven
 ,SUM(x.EigntToTen) AS EigntToTen
 ,SUM(x.ElevenToFifteen) AS ElevenToFifteen
 ,SUM(x.sixteenTo30) AS sixteenTo30
 ,SUM(x.OneTo2Month) AS OneTo2Month
 ,SUM(x.TwoTo3Month) AS TwoTo3Month
 ,SUM(x.ThreeTo6Month) AS ThreeTo6Month
 ,SUM(x.MoreThan6Month) AS MoreThan6Month
 ,SUM(x.Total) AS Total
FROM (
SELECT 
   T.walletNo
  ,CASE WHEN T.ageDay<1 THEN SUM(T.agingAmt) ELSE 0 END AS LessThan24
  ,CASE WHEN T.ageDay BETWEEN 1 AND 2  THEN SUM(T.agingAmt) ELSE 0 END AS OneToTwo
  ,CASE WHEN T.ageDay BETWEEN 3 AND 7 THEN SUM(T.agingAmt) ELSE 0 END AS ThreeToSeven
  ,CASE WHEN T.ageDay BETWEEN 8 AND 10 THEN SUM(T.agingAmt) ELSE 0 END AS EigntToTen
  ,CASE WHEN T.ageDay BETWEEN 11 AND 15 THEN SUM(T.agingAmt) ELSE 0 END AS ElevenToFifteen
  ,CASE WHEN T.ageDay BETWEEN 16 AND 30 THEN SUM(T.agingAmt) ELSE 0 END AS sixteenTo30
  ,CASE WHEN T.ageDay BETWEEN 31 AND 60 THEN SUM(T.agingAmt) ELSE 0 END AS OneTo2Month
  ,CASE WHEN T.ageDay BETWEEN 61 AND 90 THEN SUM(T.agingAmt) ELSE 0 END AS TwoTo3Month
  ,CASE WHEN T.ageDay BETWEEN 91 AND 180 THEN SUM(T.agingAmt) ELSE 0 END AS ThreeTo6Month
  ,CASE WHEN T.ageDay > 180 THEN SUM(T.agingAmt) ELSE 0 END AS MoreThan6Month
  ,SUM(T.agingAmt) AS Total
FROM tblAgingReport AS T 
GROUP BY T.ageDay,T.walletNo
)x GROUP BY x.walletNo


GO
