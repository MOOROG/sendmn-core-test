USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[temp_proc]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[temp_proc]
as
set xact_abort on;
begin
declare @customerId bigint
declare @nextMove int = 1

WHILE (@nextMove = 1)
BEGIN  
    SELECT TOP 1 @customerId = CUSTOMERID FROM  tempTranTable
	IF OBJECT_ID('tempdb..#TMPWORK') IS NOT NULL DROP TABLE #TMPWORK
	IF OBJECT_ID('tempdb..#transactionMain') IS NOT NULL DROP TABLE #transactionMain

	SELECT * INTO #TMPWORK FROM tempTranTable WHERE CUSTOMERID = @customerId

	SELECT  
			T1.customerid, 
			T1.approveddate, 
			MIN(T2.approveddate) AS Date2, 
			DATEDIFF("D", T1.approveddate, MIN(T2.approveddate)) AS DaysDiff into #transactionMain
	FROM    #TMPWORK T1
			LEFT JOIN #TMPWORK T2
				ON T1.customerid = T2.customerid
				AND T2.approveddate > T1.approveddate
	GROUP BY T1.customerid, T1.approveddate;

	insert into finalRes (customerId, date1, date2, daysDiff)
	select customerid, approveddate, Date2, DaysDiff from #transactionMain where daysDiff > 90

	DELETE FROM tempTranTable WHERE CUSTOMERID = @customerId

	IF NOT EXISTS(SELECT 1 FROM tempTranTable)
	BEGIN
		SET @nextMove = 0
	END  
END;
end
 
GO
