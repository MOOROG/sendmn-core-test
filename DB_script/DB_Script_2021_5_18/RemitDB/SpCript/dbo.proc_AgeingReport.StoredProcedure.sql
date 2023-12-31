USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_AgeingReport]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Customer Wallet Aging Report
--proc_AgeingReport @flag='days',@user='admin'

CREATE PROCEDURE [dbo].[proc_AgeingReport](
	@Flag VARCHAR(20)=NULL,
	@User VARCHAR(100)=NULL
)AS
BEGIN
	IF @Flag='amount'
	BEGIN
		DECLARE @MoreThan3Mil MONEY= 3000000
		,@MoreThan4Mil MONEY= 4000000
		,@MoreThan5Mil MONEY= 5000000
		,@MoreThan6Mil MONEY= 6000000
		,@MoreThan7Mil MONEY= 7000000
		,@MoreThan8Mil MONEY= 8000000
		,@MoreThan9Mil MONEY= 9000000
		,@MoreThan10Mil MONEY= 10000000

		SELECT 
				 SUM(CASE WHEN x.amount<@MoreThan3Mil THEN x.amount ELSE 0 END) AS MoreThan3Mil
				,SUM(CASE WHEN x.amount>@MoreThan3Mil AND x.amount<@MoreThan4Mil THEN x.amount ELSE 0 END) AS MoreThan4Mil
				,SUM(CASE WHEN x.amount>@MoreThan4Mil AND x.amount<@MoreThan5Mil THEN x.amount ELSE 0 END) AS MoreThan5Mil
				,SUM(CASE WHEN x.amount>@MoreThan5Mil AND x.amount<@MoreThan6Mil THEN x.amount ELSE 0 END) AS MoreThan6Mil
				,SUM(CASE WHEN x.amount>@MoreThan6Mil AND x.amount<@MoreThan7Mil THEN x.amount ELSE 0 END) AS MoreThan7Mil
				,SUM(CASE WHEN x.amount>@MoreThan7Mil AND x.amount<@MoreThan8Mil THEN x.amount ELSE 0 END) AS MoreThan8Mil
				,SUM(CASE WHEN x.amount>@MoreThan8Mil AND x.amount<@MoreThan9Mil THEN x.amount  ELSE 0 END) AS MoreThan9Mil
				,SUM(CASE WHEN x.amount>@MoreThan9Mil AND x.amount<@MoreThan10Mil THEN x.amount ELSE 0 END) AS MoreThan10Mil
				,x.virtualAccountNo
		FROM (
			SELECT
				SUM(TVBDD.amount) AS amount,TVBDD.virtualAccountNo
			FROM dbo.TblVirtualBankDepositDetail AS TVBDD(NOLOCK)
			GROUP BY TVBDD.virtualAccountNo
		)x GROUP BY x.virtualAccountNo

	END
	IF @Flag='days'
	BEGIN
		DECLARE @today DATE=GETDATE()
		DECLARE @For1 DATETIME=DATEADD(DAY,-1,@today),@For2 DATETIME=DATEADD(DAY,-2,@today)
		,@For3 DATETIME=DATEADD(DAY,-3,@today),@For7 DATETIME=DATEADD(DAY,-7,@today),@For30 DATETIME=DATEADD(DAY,-30,@today)
		,@ForMore1Month DATETIME=DATEADD(MONTH,-1,@today),@ForMore6Month DATETIME=DATEADD(MONTH,-6,@today)

		SELECT 
			 SUM(x.LessThan24Hr) LessThan24Hr
			,SUM(x.For1To2Days) For1To2Days
			,SUM(x.For3To7Days) For3To7Days
			,SUM(x.MonthMoreThan1) MonthMoreThan1
			,SUM(MonthMoreThan1And6) MonthMoreThan1And6
			,SUM(x.MoreThan6Month) MoreThan6Month 
		FROM (
			SELECT
				 CASE WHEN TVBDD.logDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE() THEN SUM(TVBDD.amount) ELSE 0 END AS LessThan24Hr
				,CASE WHEN TVBDD.logDate BETWEEN @For2 AND @For1 THEN SUM(TVBDD.amount) ELSE 0 END AS For1To2Days
				,CASE WHEN TVBDD.logDate BETWEEN @For7 AND @For3 THEN SUM(TVBDD.amount) ELSE 0 END AS For3To7Days
				,CASE WHEN TVBDD.logDate BETWEEN @For30 AND @For7 THEN SUM(TVBDD.amount) ELSE 0 END AS For7To30Days
				,CASE WHEN TVBDD.logDate < CAST(@For30 AS DATE) THEN SUM(TVBDD.amount) ELSE 0 END AS MonthMoreThan1
				,CASE WHEN TVBDD.logDate BETWEEN @ForMore6Month AND @ForMore1Month THEN SUM(TVBDD.amount) ELSE 0 END AS MonthMoreThan1And6
				,CASE WHEN TVBDD.logDate < @ForMore6Month THEN SUM(TVBDD.amount) ELSE 0 END AS MoreThan6Month
			FROM dbo.TblVirtualBankDepositDetail AS TVBDD(NOLOCK)
			GROUP BY TVBDD.logDate
		)x
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'Report Type' head, CASE WHEN @Flag='amount' THEN 'Amount Wise' ELSE 'Date wise' end value

	SELECT 'Ageing Report' AS Title 

END
GO
