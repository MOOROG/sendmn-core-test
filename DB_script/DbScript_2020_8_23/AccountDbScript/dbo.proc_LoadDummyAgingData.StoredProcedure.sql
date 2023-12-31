ALTER  PROC [dbo].[proc_LoadDummyAgingData]
@walletNo VARCHAR(20),
@availableBalance MONEY
AS
SET NOCOUNT ON;

IF EXISTS(SELECT 'A' FROM tblAgingReport(NOLOCK) WHERE walletNo = @walletNo)
	RETURN

CREATE TABLE #temp(rowId INT IDENTITY(1,1),[date] date,amount money, cp money, ageDay int, damount money, agingAmt MONEY,walletNo VARCHAR(20))

INSERT INTO #temp(walletNo,[date],amount)
SELECT walletNo,CAST(x.date AS DATE) AS date
,x.amount FROM(
--SELECT 9424010703938 AS walletNo,'3/9/2018' AS date ,-100000.00 AS amount
--UNION ALL SELECT 9424010703938 AS walletNo,'7/23/2018' ,-1000000.00
--UNION ALL SELECT 9424010703938 AS walletNo,'7/31/2018' ,-11000.00
--UNION ALL SELECT 9424010703938 AS walletNo,'7/31/2018' ,-11000.00
--UNION ALL SELECT 9424010703938 AS walletNo,'8/6/2018' ,-11000.00
--UNION ALL SELECT 9424010703938 AS walletNo,'8/24/2018' ,-1698600.00
--UNION ALL SELECT 9424010703938 AS walletNo,'8/31/2018' ,-11000.00
--UNION ALL SELECT 9424010703938 AS walletNo,'8/31/2018' ,-11000.00
--UNION ALL SELECT 9424010703938 AS walletNo,'8/31/2018' ,-11000.00
SELECT walletNo = acc_num,
 CAST(TM.created_date AS DATE) date ,TM.tran_amt*-1 amount
FROM dbo.tran_master AS TM(NOLOCK) WHERE TM.acc_num=@walletNo AND TM.part_tran_type='cr'

)x ORDER BY date ASC

INSERT INTO #temp(walletNo,date, amount, cp )
SELECT @walletNo,GETDATE(),0,@availableBalance

--SELECT walletAccountNo,GETDATE(),0,availableBalance*-1 FROM SendMnPro_Remit.dbo.customerMaster AS CM(NOLOCK) 
--WHERE CM.walletAccountNo = @walletNo

DECLARE @CNT INT
SELECT @CNT = MAX(rowId)-1 FROM #temp
WHILE @CNT >= 0
BEGIN
 DECLARE @CP MONEY,@AMT MONEY,@dAmt MONEY,@aMtt MONEY
 SELECT @CP=CP FROM #temp AS T WHERE T.rowId=(@CNT+1)
 SELECT @AMT=amount FROM #temp AS T WHERE T.rowId=(@CNT)
 UPDATE #temp SET cp=@CP-@AMT WHERE rowId=(@CNT)
IF @CP<0
	SELECT @dAmt=T.amount FROM #temp AS T WHERE T.rowId=(@CNT+1)
ELSE
	SELECT @dAmt=T.cp FROM #temp AS T WHERE T.rowId=(@CNT+2)

IF @dAmt<0
	SET @aMtt=@dAmt
ELSE
	SET @aMtt=0

 UPDATE #temp SET damount=@dAmt,agingAmt=@aMtt WHERE rowId=(@CNT+1)
 SET @CNT=@CNT-1
 
END

--delete from #temp where agingAmt = 0

UPDATE #temp SET ageDay = DATEDIFF(day,date,getdate())

insert into tblAgingReport(walletNo,agingAmt,ageDay)
select walletNo,agingAmt,ageDay from #temp


GO
