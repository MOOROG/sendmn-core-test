USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_graphicalReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC proc_graphicalReport @flag = 'a', @user = 'admin', 
@fromDate = '2012-6-6', @toDate = '2012-7-2',@DATETYPE='P',@groupBy='RAW'

EXEC proc_graphicalReport @flag = 'a', @user = 'admin', 
@fromDate = '2012-6-6', @toDate = '2012-7-2',@DATETYPE='P',@groupBy='SCW'
*/

CREATE procEDURE [dbo].[proc_graphicalReport]
	 @flag					VARCHAR(50) = NULL
	,@user					VARCHAR(50)	= NULL
	,@dateType				VARCHAR(50) = NULL
	,@fromDate				VARCHAR(50)	= NULL
	,@toDate				VARCHAR(50)	= NULL
	,@sCountry				VARCHAR(50)	= NULL
	,@sAgent				VARCHAR(50)	= NULL
	,@sBranch				VARCHAR(50)	= NULL
	,@rCountry				VARCHAR(50)	= NULL
	,@rAgent				VARCHAR(50)	= NULL
	,@rBranch				VARCHAR(50)	= NULL	
	,@groupBy				VARCHAR(50)	= NULL
	,@breakType				VARCHAR(50)	= NULL
	,@graphType				VARCHAR(50)	= NULL
AS

SET NOCOUNT ON;
SET ANSI_NULLS ON;
IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL 
DROP TABLE #tempMaster

	
IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL 
DROP TABLE #tempDataTable

IF @flag='a'
BEGIN	
	SET @toDate  = @toDate + ' 23:59:59'

	DECLARE @DateCondition VARCHAR(50),
			@GroupCondition varchar(50),
			@SQL VARCHAR(MAX),
			@maxReportViewDays INT,
			@GroupSelect VARCHAR(50)
		
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
			
	SELECT @DateCondition = CASE WHEN @DATETYPE = 'S' THEN 'approvedDate' 
							WHEN @DATETYPE = 'P' THEN 'paidDate' 
							WHEN @DATETYPE = 'C' THEN 'cancelApprovedDate' END

                                        
                                        						
	SELECT @GroupCondition   =	CASE 
									WHEN @GROUPBY = 'SCW' THEN 'sCountry' 
									WHEN @GROUPBY = 'SAW' THEN 'sAgent' 
									WHEN @GROUPBY = 'RCW' THEN 'pCountry' 
									WHEN @GROUPBY = 'RAW' THEN 'pAgent' 
									WHEN @GROUPBY = 'DW' THEN 'DW' 							
								END
								
	IF @GroupCondition IN ('sAgent','pAgent')
	BEGIN
		SET @SQL = 'SELECT AM.agentName Category ,SUM(tAmt) [Value]
					FROM remitTran RT WITH (NOLOCK)
					INNER JOIN agentMaster AM WITH (NOLOCK) ON RT.'+@GroupCondition+'=AM.agentId
					
					WHERE  RT.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
					
		IF @sCountry IS NOT NULL
			SET @SQL = @SQL + ' AND RT.sCountry = ''' + @sCountry + ''''
			
		IF @sAgent IS NOT NULL
			SET @SQL = @SQL + ' AND RT.sAgent = ''' + @sAgent + ''''
		
		IF @sBranch IS NOT NULL
			SET @SQL = @SQL + ' AND RT.sBranch = '''+ @sBranch +''''
		
		IF @rCountry IS NOT NULL
			SET @SQL = @SQL + ' AND RT.pCountry = ''' + @rCountry + ''''
			
		IF @rAgent IS NOT NULL
			SET @SQL = @SQL + ' AND RT.PAgent = ''' + @rAgent + ''''
		
		IF @rBranch IS NOT NULL
			SET @SQL = @SQL + ' AND RT.pBranch = '''+ @rBranch +''''
			
		SET @SQL = @SQL + ' GROUP BY AM.agentName'

		EXECUTE(@SQL)
	END
	
	IF @GroupCondition IN ('sCountry','pCountry')
	BEGIN
		SET @SQL = 'SELECT CM.countryName Category ,SUM(tAmt) [Value]
					FROM remitTran RT WITH (NOLOCK)
					INNER JOIN countryMaster CM WITH (NOLOCK) ON RT.'+@GroupCondition+'=CM.countryName
					
					WHERE  RT.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
					
		IF @sCountry IS NOT NULL
			SET @SQL = @SQL + ' AND RT.sCountry = ''' + @sCountry + ''''
			
		IF @sAgent IS NOT NULL
			SET @SQL = @SQL + ' AND RT.sAgent = ''' + @sAgent + ''''
		
		IF @sBranch IS NOT NULL
			SET @SQL = @SQL + ' AND RT.sBranch = '''+ @sBranch +''''
		
		IF @rCountry IS NOT NULL
			SET @SQL = @SQL + ' AND RT.pCountry = ''' + @rCountry + ''''
			
		IF @rAgent IS NOT NULL
			SET @SQL = @SQL + ' AND RT.PAgent = ''' + @rAgent + ''''
		
		IF @rBranch IS NOT NULL
			SET @SQL = @SQL + ' AND RT.pBranch = '''+ @rBranch +''''
			
		SET @SQL = @SQL + ' GROUP BY CM.countryName'
		EXECUTE(@SQL)
	END
	
	IF @GroupCondition IN ('DW')  -- >>GROUP BY DATEWISE
	BEGIN
		IF @breakType='D'
		BEGIN
			SET @SQL = 'SELECT CONVERT(VARCHAR,RT.'+ @DATECONDITION +',101) Category ,SUM(tAmt) [Value]
						FROM remitTran RT WITH (NOLOCK)						
						WHERE  RT.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
						
			IF @sCountry IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sCountry = ''' + @sCountry + ''''
				
			IF @sAgent IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sAgent = ''' + @sAgent + ''''
			
			IF @sBranch IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sBranch = '''+ @sBranch +''''
			
			IF @rCountry IS NOT NULL
				SET @SQL = @SQL + ' AND RT.pCountry = ''' + @rCountry + ''''
				
			IF @rAgent IS NOT NULL
				SET @SQL = @SQL + ' AND RT.PAgent = ''' + @rAgent + ''''
			
			IF @rBranch IS NOT NULL
				SET @SQL = @SQL + ' AND RT.pBranch = '''+ @rBranch +''''
				
			SET @SQL = @SQL + ' GROUP BY CONVERT(VARCHAR,RT.'+ @DATECONDITION +',101)'
			EXECUTE(@SQL)
		END
		IF @breakType='W'
		BEGIN
			SET @SQL = 'SELECT 
						 cast(DATEPART(wk,RT.'+ @DATECONDITION +') as varchar)+'' Week''  Category,
						SUM(tAmt) [Value]
						FROM remitTran RT WITH (NOLOCK)						
						WHERE  RT.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
						
			IF @sCountry IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sCountry = ''' + @sCountry + ''''
				
			IF @sAgent IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sAgent = ''' + @sAgent + ''''
			
			IF @sBranch IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sBranch = '''+ @sBranch +''''
			
			IF @rCountry IS NOT NULL
				SET @SQL = @SQL + ' AND RT.pCountry = ''' + @rCountry + ''''
				
			IF @rAgent IS NOT NULL
				SET @SQL = @SQL + ' AND RT.PAgent = ''' + @rAgent + ''''
			
			IF @rBranch IS NOT NULL
				SET @SQL = @SQL + ' AND RT.pBranch = '''+ @rBranch +''''
				
			SET @SQL = @SQL + ' GROUP BY DATEPART(YEAR,RT.'+ @DATECONDITION +'),
				DATEPART(wk,RT.'+ @DATECONDITION +')
				ORDER BY 1,2';
			print(@SQL)
			EXECUTE(@SQL)
		END
		IF @breakType='M'
		BEGIN
    
			SET @SQL = 'SELECT 
						DateName( month , DateAdd( month , MONTH(RT.'+ @DATECONDITION +') , 0 ) - 1 ) Category,
						SUM(tAmt) [Value]
						FROM remitTran RT WITH (NOLOCK)						
						WHERE RT.'+ @DATECONDITION +' is not null and
							  RT.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
						
			IF @sCountry IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sCountry = ''' + @sCountry + ''''
				
			IF @sAgent IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sAgent = ''' + @sAgent + ''''
			
			IF @sBranch IS NOT NULL
				SET @SQL = @SQL + ' AND RT.sBranch = '''+ @sBranch +''''
			
			IF @rCountry IS NOT NULL
				SET @SQL = @SQL + ' AND RT.pCountry = ''' + @rCountry + ''''
				
			IF @rAgent IS NOT NULL
				SET @SQL = @SQL + ' AND RT.PAgent = ''' + @rAgent + ''''
			
			IF @rBranch IS NOT NULL
				SET @SQL = @SQL + ' AND RT.pBranch = '''+ @rBranch +''''
				
			SET @SQL = @SQL + '  GROUP BY YEAR(RT.'+ @DATECONDITION +'), MONTH(RT.'+ @DATECONDITION +')
							     ORDER BY YEAR(RT.'+ @DATECONDITION +'), MONTH(RT.'+ @DATECONDITION +');'
			EXECUTE(@SQL)
		END
	END

END



GO
