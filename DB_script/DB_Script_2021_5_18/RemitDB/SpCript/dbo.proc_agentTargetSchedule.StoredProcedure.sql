USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentTargetSchedule]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC  [proc_agentTargetSchedule] @date = '06/21/2016'
CREATE proc [dbo].[proc_agentTargetSchedule]
 		@date	VARCHAR(50) = NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN

		DECLARE  @month VARCHAR(50)
				,@year VARCHAR(20)
				,@StartDate VARCHAR(50)
				,@EndDate VARCHAR(50)
				,@endDate2 VARCHAR(20)

		/*
		if @date is null
			set @date = getdate()
		
		select @month = datename(month,@date)
	    select @year = datepart(year,@date)
		SET @StartDate = CONVERT(DateTime, LEFT(@month, 3) + ' 1 '+@year+'', 100);
		SET @EndDate = DATEADD(MONTH, 1, @StartDate) - 1;
		set @StartDate = convert(varchar,cast(@StartDate as datetime),101)
		set @EndDate = convert(varchar,cast(@EndDate as datetime),101)		
		exec proc_agentTargetSchedule
		
		*/
		SET @month = 'Ashad'
		SET @year = '2073'
		SET @StartDate = '06/15/2016'
		SET @EndDate = '07/15/2016'
		SET @endDate2 = CONVERT(VARCHAR, DATEADD(DAY, 1, @EndDate),101) 
		SET @date = CONVERT(VARCHAR,GETDATE(),101)

		IF (@date >= @StartDate OR @date <= @endDate2)
		BEGIN			
			IF EXISTS(SELECT TOP 1 'x' FROM RemittanceLogData.dbo.agentTarget WITH(NOLOCK) 
				WHERE yr = @year AND yrMonth = @month and userName is null)
			BEGIN
				-- ## UPDATE SEND TXN - normal 
				UPDATE RemittanceLogData.dbo.agentTarget SET
					 actualTxn = b.actual
				FROM RemittanceLogData.dbo.agentTarget a,
				(
					SELECT ag.sAgent,COUNT('x') actual 
					FROM remitTran rt WITH(NOLOCK) 
					INNER JOIN RemittanceLogData.dbo.agentTarget ag WITH(NOLOCK) ON rt.sAgent = ag.sAgent
					INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id =rec.tranId
					WHERE ag.yr = @year 
					AND yrMonth = @month 
					AND rt.approvedDate BETWEEN @StartDate AND @EndDate+' 23:59:59'
					AND tranType = 'D' 
					AND ag.userName IS NULL
					AND rt.tranStatus <> 'Cancel'
					AND ag.sAgent <> 4618
					and rec.stdCollegeId is null 
					GROUP BY ag.sAgent	
				)b WHERE a.sAgent = b.sAgent AND a.yr = @year AND a.yrMonth = @month and a.userName is null

				-- ## UPDATE SEND TXN - COOPERATIVE 
				UPDATE RemittanceLogData.dbo.agentTarget SET
					 actualTxn = b.actual
				FROM RemittanceLogData.dbo.agentTarget a,
				(
					SELECT ag.agentId,COUNT('x') actual 
					FROM remitTran rt WITH(NOLOCK) INNER JOIN RemittanceLogData.dbo.agentTarget ag WITH(NOLOCK) ON rt.sBranch = ag.agentId
					INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id =rec.tranId
					WHERE ag.yr = @year 
					AND yrMonth = @month 
					AND ag.userName IS NULL
					AND rt.approvedDate BETWEEN @StartDate AND @EndDate+' 23:59:59'
					AND tranType = 'D' 
					AND rt.tranStatus <> 'Cancel'
					AND ag.sAgent = 4618
					and rec.stdCollegeId is null 
					GROUP BY ag.agentId	
				)b WHERE a.agentId = b.agentId 
				AND a.yr = @year 
				AND a.yrMonth = @month 
				AND a.userName is null

			END
		END 
		/*
		IF @date IS NULL
			SET @date = GETDATE()

		SELECT @month = DATENAME(month,@date)
	    SELECT @year = DATEPART(year,@date)

		SET @StartDate = CONVERT(DATETIME, LEFT(@month, 3) + ' 1 '+@year+'', 100);
		SET @EndDate = DATEADD(MONTH, 1, @StartDate) - 1;

		SET @StartDate = CONVERT(VARCHAR,CAST(@StartDate AS DATETIME),101)
		SET @EndDate = CONVERT(VARCHAR,CAST(@EndDate AS DATETIME),101)
		
		IF EXISTS(SELECT 'x' FROM RemittanceLogData.dbo.agentTarget WITH(NOLOCK) WHERE yr = @year AND yrMonth = @month AND userName IS NOT NULL)
		BEGIN
			UPDATE RemittanceLogData.dbo.agentTarget SET
				 actualTxn = b.actual
			FROM RemittanceLogData.dbo.agentTarget a,
			(
				SELECT 
					userName = rt.createdBy,
					actual = COUNT('x')  
				FROM remitTran rt WITH(NOLOCK) 
				INNER JOIN RemittanceLogData.dbo.agentTarget ag WITH(NOLOCK) ON rt.createdBy = ag.username
				WHERE ag.yr = @year 
				AND yrMonth = @month 
				AND rt.approvedDate BETWEEN @StartDate AND @EndDate+' 23:59:59'
				AND tranType = 'I' 
				AND rt.tranStatus <> 'Cancel'
				AND ag.isIMEStaff IS null
				GROUP BY rt.createdBy	
			)b WHERE a.userName = b.userName 
					AND a.yr = @year 
					AND a.yrMonth = @month 
					AND a.isIMEStaff IS null		
					
					
			UPDATE RemittanceLogData.dbo.agentTarget SET
				 actualTxn = b.actual
			FROM RemittanceLogData.dbo.agentTarget a,
			(
					SELECT 
						agentId = rt.sBranch,
						actual = COUNT('x'),
						userName = b.userName 
					FROM remitTran rt WITH(NOLOCK) 
					INNER JOIN 
					(
						select distinct au.agentId,au.userName from RemittanceLogData.dbo.agentTarget ag WITH(NOLOCK) 
						inner join applicationusers au with(nolock) ON ag.userName = au.userName 	
						where ag.isIMEStaff = 'Y' 
							and ag.yr = @year 
							AND yrMonth = @month
		
					)b on rt.sBranch = b.agentId 
					WHERE  
						rt.approvedDate BETWEEN @StartDate AND @EndDate+' 23:59:59'
					AND tranType = 'I' 
					AND rt.tranStatus <> 'Cancel'	
					GROUP BY rt.sBranch	,b.userName 
			)b WHERE a.userName = b.userName 
					AND a.yr = @year 
					AND a.yrMonth = @month 
					AND a.isIMEStaff = 'Y'
		END	
		*/	
END



GO
