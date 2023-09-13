
ALTER PROC PROC_HIGH_CHART
(
	@flag VARCHAR(20) ='high-chart'
	,@country VARCHAR(30) = NULL
	,@User		VARCHAR(50)
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @flag = 'country'
	BEGIN
		SELECT TOP 5 pCountry, count(10) [count] 
		FROM remittran (NOLOCK) 
		GROUP BY pcountry 
		ORDER BY [count] DESC
	END
	IF @flag = 'high-chart'
	BEGIN
		IF (SELECT dbo.FNAHasRight(@User,'90100000') )='N'
			RETURN
		DECLARE @DATE VARCHAR(10),@MonthStart date,@MonthEnd datetime,@YearStart date,@YearEnd datetime

		IF OBJECT_ID('tempdb..#TEMPCOUNTRY') IS NOT NULL DROP TABLE #TEMPCOUNTRY

		SELECT @YearStart	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		   ,@YearEnd	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)+' 23:59:59'

		SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0)) +' 23:59:59'

		SELECT approvedDate,pCountry 
		into #tempRemit 
		FROM remittran(NOLOCK)
		where approvedDate between @YearStart and @YearEnd

		IF NOT EXISTS(SELECT * FROM #tempRemit WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd)
		BEGIN
			SELECT @MonthStart = DATEADD(MONTH, -1, @MonthStart), @MonthEnd = DATEADD(MONTH, -1, @MonthEnd)
		END
		
		SELECT TOP 5 pCountry, count(10) [count] INTO #TEMPCOUNTRY FROM #tempRemit 
		WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
		GROUP BY pcountry 
		ORDER BY [count] DESC

		DECLARE @cntCountry INT; SET @cntCountry = 1
		WHILE @cntCountry <= (SELECT COUNT(1) FROM #TEMPCOUNTRY)
		BEGIN
			SELECT TOP 1 @country = pCountry FROM #TEMPCOUNTRY
			ORDER BY [count] DESC

			DELETE FROM #TEMPCOUNTRY WHERE pCountry = @country

			SET @cntCountry = @cntCountry + 1

			IF OBJECT_ID('tempdb..#TEMPJAN') IS NOT NULL DROP TABLE #TEMPJAN
			IF OBJECT_ID('tempdb..#TEMPFEB') IS NOT NULL DROP TABLE #TEMPFEB
			IF OBJECT_ID('tempdb..#TEMPMAR') IS NOT NULL DROP TABLE #TEMPMAR
			IF OBJECT_ID('tempdb..#TEMPAPR') IS NOT NULL DROP TABLE #TEMPAPR
			IF OBJECT_ID('tempdb..#TEMPMAY') IS NOT NULL DROP TABLE #TEMPMAY
			IF OBJECT_ID('tempdb..#TEMPJUNE') IS NOT NULL DROP TABLE #TEMPJUNE
			IF OBJECT_ID('tempdb..#TEMPJULY') IS NOT NULL DROP TABLE #TEMPJULY
			IF OBJECT_ID('tempdb..#TEMPAUG') IS NOT NULL DROP TABLE #TEMPAUG
			IF OBJECT_ID('tempdb..#TEMPSEP') IS NOT NULL DROP TABLE #TEMPSEP
			IF OBJECT_ID('tempdb..#TEMPOCT') IS NOT NULL DROP TABLE #TEMPOCT
			IF OBJECT_ID('tempdb..#TEMNOV') IS NOT NULL DROP TABLE #TEMNOV
			IF OBJECT_ID('tempdb..#TEMPDEC') IS NOT NULL DROP TABLE #TEMPDEC

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-01-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPJAN FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]
			
			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-02-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPFEB FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]
			
			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-03-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPMAR FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-04-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPAPR FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]


			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-05-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPMAY FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-06-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPJUNE FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]


			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-07-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPJULY FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-08-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPAUG FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-09-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPSEP FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-10-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPOCT FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-11-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMNOV FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]

			SELECT @DATE = CAST(YEAR(GETDATE()) AS VARCHAR)+'-12-01'
			SELECT @MonthStart = DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0)
			,@MonthEnd = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @DATE) + 1, 0)) +' 23:59:59'

			SELECT DAY(approveddate) [day], COUNT(1) [count] INTO #TEMPDEC FROM #tempRemit 
			WHERE approvedDate BETWEEN @MonthStart AND @MonthEnd
			AND pCountry = @country
			GROUP BY DAY(approveddate)
			ORDER BY [day]


			DECLARE @HIGHCHART TABLE([DAY] INT, JAN INT, FEB INT, MARCH INT, APR INT, MAY INT, JUNE INT
										, JULY INT, AUG INT, SEP INT, OCT INT, NOV INT, DECEMBER INT)

		
			DECLARE @cnt INT; SET @cnt = 1
			WHILE @cnt <=32
			BEGIN
				INSERT INTO @HIGHCHART 
				SELECT @CNT, 0,0,0,0,0,0,0,0,0,0,0,0
				SET @cnt = @cnt + 1
			END

			UPDATE T2 SET T2.JAN = T1.cumulative
			FROM (SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
			FROM #TEMPJAN t1
			INNER JOIN #TEMPJAN t2 on t1.[day] >= t2.[day]
			GROUP BY t1.[day], t1.[count]
			) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.FEB = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPFEB t1
				INNER JOIN #TEMPFEB t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.MARCH = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPMAR t1
				INNER JOIN #TEMPMAR t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.APR = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPAPR t1
				INNER JOIN #TEMPAPR t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.MAY = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPMAY t1
				INNER JOIN #TEMPMAY t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.JUNE = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPJUNE t1
				INNER JOIN #TEMPJUNE t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.JULY = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPJULY t1
				INNER JOIN #TEMPJULY t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.AUG = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPAUG t1
				INNER JOIN #TEMPAUG t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.SEP = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPSEP t1
				INNER JOIN #TEMPSEP t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.OCT = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMPOCT t1
				INNER JOIN #TEMPOCT t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			UPDATE T2 SET T2.NOV = T1.cumulative
			FROM 
				(SELECT t1.[day], t1.[count], SUM(ISNULL(t2.[count], 0)) as cumulative
				FROM #TEMNOV t1
				INNER JOIN #TEMNOV t2 on t1.[day] >= t2.[day]
				GROUP BY t1.[day], t1.[count]) T1 
			INNER JOIN @HIGHCHART T2 ON T2.[DAY] = T1.[day]

			SELECT @country countryName
			SELECT * FROM @HIGHCHART
			SET @cnt = @cnt + 1

			DELETE FROM @HIGHCHART
		END
		
	END
END




