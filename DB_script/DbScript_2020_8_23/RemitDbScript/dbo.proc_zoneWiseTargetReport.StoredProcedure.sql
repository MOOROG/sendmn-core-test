USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_zoneWiseTargetReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_zoneWiseTargetReport]
(
	 @flag			VARCHAR(50)		= NULL
	,@zone			VARCHAR(50)		= NULL
	,@yr			VARCHAR(50)		= NULL
	,@user			VARCHAR(50)		= NULL
	,@pageNumber	VARCHAR(10)		= NULL
	,@pageSize		VARCHAR(10)		= NULL
)
AS 
BEGIN

/*
proc_zoneWiseTargetReport
EXEC proc_zoneWiseTargetReport @flag ='a',@zone = null,@yr ='72-73'
proc_zoneWiseTargetReport
EXEC proc_zoneWiseTargetReport @flag ='rpt_regional',@zone = null,@yr ='72-73',@user='admin'
*/
	
	DECLARE @zoneTarget table(zoneName varchar(50), targetDomTxn money,targetEduPay money,targetTopup money,targetRemitCard money)			
	DECLARE 
		@yearStartDate VARCHAR(50),
		@yearEndDate VARCHAR(50),
		@sql VARCHAR(MAX)

	SELECT @yearStartDate = EN_YEAR_START_DATE,@yearEndDate = EN_YEAR_END_DATE
			FROM FiscalYear WITH(NOLOCK) WHERE FISCAL_YEAR_NEPALI = @yr
	
	IF @flag = 'rpt'
	BEGIN    
		SET @sql = '			
			SELECT 
				 zoneName
				,targetDomTxn
				,targetEduPay
				,targetTopup
				,targetRemitCard 
		FROM RemittanceLogData.dbo.zoneWiseTargetSetup z
		INNER JOIN FiscalYear m WITH(NOLOCK) on m.FISCAL_YEAR_NEPALI = z.yr 
		WHERE z.yr = '''+ @yr +''' and z.yrMonth is null '
	   
		IF @zone IS NOT NULL 
			SET @sql = @sql + ' AND zoneName = '''+@zone+''''		

		INSERT INTO @zoneTarget(zoneName,targetDomTxn,targetEduPay,targetTopup,targetRemitCard)
		EXEC(@sql)
	END
	IF @flag = 'rpt_regional'
	BEGIN    
		SET @sql = '			
			SELECT 
				 z.zoneName
				,targetDomTxn
				,targetEduPay
				,targetTopup
				,targetRemitCard 
		FROM RemittanceLogData.dbo.zoneWiseTargetSetup z
		INNER JOIN FiscalYear m WITH(NOLOCK) on m.FISCAL_YEAR_NEPALI = z.yr 
		INNER JOIN userZoneMapping um WITH(NOLOCK) ON um.zoneName = z.zoneName
		WHERE z.yr = '''+ @yr +''' and z.yrMonth is null '
	   
		IF @zone IS NOT NULL 
			SET @sql = @sql + ' AND z.zoneName = '''+@zone+''''		
		IF @user IS NOT NULL 
			SET @sql = @sql + ' AND um.userName = '''+@user+''''	

		INSERT INTO @zoneTarget(zoneName,targetDomTxn,targetEduPay,targetTopup,targetRemitCard)
		EXEC(@sql)
	END
	IF NOT EXISTS (SELECT 's' FROM @zoneTarget)
	BEGIN    
		SELECT '<font color="red"><b>Target has not been setup for this year.</b></font>' Remarks	
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	
		SELECT  'Year' head, @yr value
		UNION ALL
		SELECT 'Zone' head, CASE WHEN @zone IS NULL THEN 'ALL' ELSE @zone END
		SELECT 'Yearly Target & Estimited workdone '+ISNULL('for '+@yr+' ','')
		RETURN;
	END
	/*Count Valid Domestic Txn*/
	SELECT * INTO #domestic FROM(	
		SELECT zone = am.agentState, total = COUNT('X') 
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = rt.sBranch
		INNER JOIN @zoneTarget zt  ON zt.zoneName = am.agentState
		WHERE tranType = 'D' 
		AND rt.approvedDate BETWEEN @yearStartDate AND @yearEndDate+' 23:59:59'
		AND tr.stdCollegeId IS NULL 
		AND tranStatus <> 'Cancel'
		AND ISNULL(rt.sCountry,'')='Nepal'
		GROUP BY am.agentState
	)dom
		
	/*Edu pay*/
	SELECT * INTO #eduPay FROM(	
		SELECT zone = am.agentState, total = COUNT('X') FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranReceivers tr WITH(NOLOCK) ON tr.tranId = rt.id
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = rt.sBranch
		INNER JOIN @zoneTarget zt ON zt.zoneName = am.agentState
		WHERE tranType = 'D' 
		AND rt.approvedDate BETWEEN @yearStartDate AND @yearEndDate+' 23:59:59'
		AND tr.stdCollegeId IS NOT NULL 
		AND tranStatus <> 'Cancel'
		AND ISNULL(rt.sCountry,'')='Nepal'
		GROUP BY am.agentState
	)ep
		
	/*Top up*/
	SELECT * INTO #topup FROM(	
		SELECT zone = am.agentState, total = COUNT('X') FROM remitTran rt WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = rt.sBranch
		INNER JOIN @zoneTarget zt ON zt.zoneName = am.agentState
		WHERE tranType = 'B' 
		AND rt.approvedDate BETWEEN @yearStartDate AND @yearEndDate+' 23:59:59'
		AND tranStatus <> 'Cancel'
		AND ISNULL(rt.sCountry,'')='Nepal'
		GROUP BY am.agentState
	)tp
		
	/*Remit Card*/
	SELECT * INTO #remitCard FROM(
		SELECT zone = am.agentState, total = COUNT(*) FROM remitTran rt WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = rt.sBranch
		INNER JOIN @zoneTarget zt ON zt.zoneName = am.agentState		
		WHERE rt.approvedDate BETWEEN @yearStartDate AND @yearEndDate+' 23:59:59'
		AND paymentMethod = 'IME REMIT CARD' 
		AND tranStatus <> 'Cancel'
		AND ISNULL(rt.sCountry,'')='Nepal'
		GROUP BY am.agentState
	)RC
	DECLARE @date  AS datetime = GETDATE(),
		@startDate AS DATETIME,
		@endDate AS DATETIME,
		@daysInPer MONEY,
		@days MONEY
	SELECT @startDate = EN_YEAR_START_DATE, @endDate = EN_YEAR_END_DATE  
	FROM dbo.FiscalYear WHERE @date BETWEEN EN_YEAR_START_DATE AND EN_YEAR_END_DATE
	SELECT @days = DATEDIFF(DAY,@startDate,@date)
	SELECT @daysInPer = ROUND((@days* 100.00)/365,2)

	SELECT [Sending Zone] = zoneName
		,[Domestic_Yearly <br> Target] = CAST(zt.targetDomTxn AS INT)
		,[Domestic_Achieved] = ISNULL(CAST(d.total AS INT),0)
		,[Domestic_Work <br> done% Till] = CAST(ISNULL(ROUND((d.total/zt.targetDomTxn)*100,2),0)  AS DECIMAL(10,2))

		,[Domestic_Estimited <br> work done %] = CAST(ISNULL(((ROUND((d.total/zt.targetDomTxn)*100,2))/@days*365),0)  AS DECIMAL(10,2))
		
		,[Topup_Yearly <br> Target] = CAST(zt.targetTopup AS INT)
		,[Topup_Achieved] = ISNULL(CAST(t.total AS INT),0)
		,[Topup_Work <br>done% Till] = CAST(ISNULL(ROUND((t.total/zt.targetTopup)*100,2),0)  AS DECIMAL(10,2))
		,[Topup_Estimited<br> work done %] = CAST(ISNULL(((ROUND((t.total/zt.targetTopup)*100,2))/@days*365),0) AS DECIMAL(10,2))
		
		,[Card_Yearly<br> Target] = CAST(zt.targetRemitCard AS INT)
		,[Card_Achieved] = ISNULL(CAST(c.total AS INT),0)
		,[Card_Work<br> done% Till] = CAST(ISNULL(ROUND((c.total/zt.targetRemitCard)*100,2),0) AS DECIMAL(10,2))
		,[Card_Estimited<br> work done %] = CAST(ISNULL(((ROUND((c.total/zt.targetRemitCard)*100,2))/@days*365),0) AS DECIMAL(10,2))
		
		,[EDUPAY_Yearly<br> Target] = CAST(zt.targetEduPay AS INT)
		,[EDUPAY_Achieved] = ISNULL(CAST(e.total AS INT),0)
		,[EDUPAY_Work<br> done% Till] = CAST(ISNULL(ROUND((e.total/zt.targetEduPay)*100,2),0) AS DECIMAL(10,2))
		,[EDUPAY_Estimited<br> work done %] = CAST(ISNULL(((ROUND((e.total/zt.targetEduPay)*100,2))/@days*365),0) AS DECIMAL(10,2))
		
	FROM @zoneTarget zt
	LEFT JOIN #domestic d on d.zone = zt.zoneName
	LEFT JOIN #topup t on t.zone = zt.zoneName 
	LEFT JOIN #remitCard c on c.zone = zt.zoneName 
	LEFT JOIN #eduPay e on e.zone = zt.zoneName 

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	

	SELECT @startDate = EN_YEAR_START_DATE, @endDate = EN_YEAR_END_DATE  
	FROM dbo.FiscalYear WHERE @date BETWEEN EN_YEAR_START_DATE AND EN_YEAR_END_DATE
	SELECT @days = DATEDIFF(DAY,@startDate,@date)
	SELECT @daysInPer = ROUND((@days* 100.00)/365,2)
	select 'DAY Passed','<font color="red">'+cast(CAST(ROUND(@days,0) AS INT) as varchar)+'</font>' value
	union all
	select '</br>Required WORK Done Till','<font color="red">'+cast(@daysInPer as varchar)+'%</font>' value
	UNION all
	SELECT  '</br>Year' head, @yr value
	UNION ALL
	SELECT '</br>Zone' head, CASE WHEN @zone IS NULL THEN 'ALL' ELSE @zone END

	SELECT 'Yearly Target & Estimited workdone '+ISNULL('for the year of: '+@yr+' ','')
END




GO
