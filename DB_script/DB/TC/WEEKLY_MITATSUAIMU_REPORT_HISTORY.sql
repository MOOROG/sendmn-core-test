
CREATE TABLE WEEKLY_MITATSUAIMU_REPORT_HISTORY
(
	ROW_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY
	,RPT_DATE DATE NOT NULL
	,JP_POST MONEY NOT NULL DEFAULT(0)
	,MUFJ MONEY NOT NULL DEFAULT(0)
	,CASH_COLLECT MONEY NOT NULL DEFAULT(0)
	,INDONESIA_JP_POST MONEY NOT NULL DEFAULT(0)
	,JP_POST_RETURN MONEY NOT NULL DEFAULT(0)
	,MUFJ_RETURN MONEY NOT NULL DEFAULT(0)
	,INDONESIA_JP_POST_RETURN MONEY NOT NULL DEFAULT(0)
	,CASH_COLLECT_RETURN MONEY NOT NULL DEFAULT(0)
	,DAILY_PAYOUT MONEY NOT NULL DEFAULT(0)
	,SERVICE_CHARGE_INCOME MONEY NOT NULL DEFAULT(0)
	,SERVICE_CHARGE_CANCEL MONEY NOT NULL DEFAULT(0)
	,OLD_MITATSUSAIMU_VALUE MONEY NOT NULL
	,NEW_MITATSUSAIMU_VALUE MONEY NOT NULL
)

--INSERT INTO WEEKLY_MITATSUAIMU_REPORT_HISTORY
--SELECT '2019-12-31', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,18588697

DELETE FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY WHERE ROW_ID > 979

SELECT * FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY

SELECT 43196132-5000
43191132.00

SELECT COUNT(0), RPT_DATE 
FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY
GROUP BY RPT_DATE
order by count(0) desc


SELECT SUM(CAMT)
FROM REMITTRAN (NOLOCK)
WHERE CAST(CREATEDDATE AS DATE) = '2019-01-04'
AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
AND COLLMODE = 'CASH COLLECT'
AND CAMT <> 121450

SELECT SUM(CAMT)
FROM REMITTRAN (NOLOCK)
WHERE CAST(CREATEDDATE AS DATE) = '2019-01-06'
AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
AND COLLMODE = 'CASH COLLECT'
AND TRANSTATUS = 'CANCEL'
AND CAMT = 79000

UPDATE R SET  R.CASH_COLLECT = CASH_COLLECT - 20000, R.CASH_COLLECT_RETURN = 0 
FROM WEEKLY_MITATSUAIMU_REPORT_HISTORY R WHERE ROW_ID = 445

--33JP212369066

select * from FastMoneyPro_Account.dbo.tran_master where ref_num in ('138091', '138009')				
SELECT * FROM TXN_SYNC_STATUS WHERE 1=1
--AND CAST(CREATEDDAATE AS DATE)= '2019-01-06'
--AND CAST(PAIDDATE AS DATE) <> CAST(PAIDDATE AS DATE)
AND CONTROLNO = '21340408'

--02-03
--33JP212158014 (paid figure not match due because it was paid on that day and cancelled later)
select transtatus,tamt, paystatus,cancelapproveddate,paiddate,dbo.decryptdb(controlno),createddate,* from remittran
where 1=1
and CAST(ISNULL(PAIDDATE, '1990-01-01') AS DATE) = '2019-02-03' 
and PAYSTATUS <> 'paid'
and uploadlogid in (
)

--UPDATE REMITTRAN SET CANCELAPPROVEDDATE = '2019-07-02' WHERE CONTROLNO = DBO.FNAENCRYPTSTRING('21933580')


SELECT TRANSTATUS, PAYSTATUS, CANCELAPPROVEDDATE,CANCELAPPROVEDBY,* FROM REMITTRAN (NOLOCK) WHERE CONTROLNO = DBO.FNAENCRYPTSTRING('33JP212369066')

UPDATE REMITTRAN SET CANCELAPPROVEDBY = NULL
WHERE TRANSTATUS <> 'CANCEL'
AND CREATEDDATE > '2019-01-01'

SELECT TOP 100 CREATEDDATE,TRANSTATUS, PAYSTATUS, CANCELAPPROVEDDATE,CANCELAPPROVEDBY FROM REMITTRAN WHERE CANCELAPPROVEDBY IS NOT NULL
AND TRANSTATUS <> 'CANCEL'
AND CREATEDDATE > '2019-01-01'

UPDATE S SET S.CUSTOMERID=15944 
--SELECT S.CUSTOMERID
FROM REMITTRAN R
INNER JOIN TRANSENDERS S ON S.TRANID= R.ID
WHERE R.CONTROLNO = DBO.FNAENCRYPTSTRING('33JP212559657')

SELECT * FROM CUSTOMERMASTER WHERE POSTALCODE='22756'
SELECT * FROM CUSTOMERMASTER WHERE CUSTOMERID='18206'

SELECT S.*
FROM REMITTRAN R
INNER JOIN TRANSENDERS S ON S.TRANID= R.ID
WHERE R.CONTROLNO = DBO.FNAENCRYPTSTRING('21741399')

select servicecharge,createddate,cancelapproveddate,* from cancelTranHistory where CONTROLNO = DBO.FNAENCRYPTSTRING('21741399')
select servicecharge,createddate,cancelapproveddate,* from cancelTranHistory where CONTROLNO = DBO.FNAENCRYPTSTRING('21514556')

select * from transenders where customerid=23746

--update REMITTRAN set transtatus='Cancel', paystatus='Cancel', cancelapprovedby='SYSTEM', cancelapproveddate='2019-01-13'
SELECT TRANSTATUS, PAYSTATUS,SERVICECHARGE,cancelapproveddate,camt,* FROM REMITTRAN 
where CONTROLNO = DBO.FNAENCRYPTSTRING('33JP212808593')


SELECT DBO.DECRYPTDB(CONTROLNO) CONTROLNO, R.UPLOADLOGID TRANNO, S.FULLNAME, R.CAMT 
FROM REMITTRAN R(NOLOCK) 
INNER JOIN TRANSENDERS S (NOLOCK) ON S.TRANID = R.ID
WHERE CAST(R.CREATEDDATE AS DATE) = '2019-01-13'
AND CAST(CREATEDDATE AS DATE) <> CAST(ISNULL(CANCELAPPROVEDDATE, '1900-01-01') AS DATE)
AND COLLMODE = 'CASH COLLECT'

SELECT DBO.DECRYPTDB(CONTROLNO),createddate,transtatus,paiddate, * FROM REMITTRAN WHERE controlno='LLciKJKJNQIJM'
SELECT DBO.DECRYPTDB(CONTROLNO),CREATEDDATE,cancelapproveddate,transtatus,paiddate,S.CUSTOMERID, * 
FROM REMITTRAN R
INNER JOIN TRANSENDERS S ON S.TRANID = R.ID 
WHERE controlno=dbo.fnaencryptstring('33JP212697790')

UPDATE R SET R.TRANSTATUS = 'CANCEL', R.PAYSTATUS = 'UNPAID'
FROM REMITTRAN R
INNER JOIN TRANSENDERS S ON S.TRANID = R.ID 
WHERE controlno=dbo.fnaencryptstring('33JP212697790')

SELECT CAMT,COLLMODE,* FROM REMITTRAN R
INNER JOIN TRANSENDERS S ON S.TRANID = R.ID
WHERE S.CUSTOMERID=41762
AND CAST(R.CREATEDDATE AS DATE) = '2019-10-01'

--update REMITTRAN set cancelapproveddate = '2019-07-17' WHERE controlno=dbo.fnaencryptstring('21420178')

