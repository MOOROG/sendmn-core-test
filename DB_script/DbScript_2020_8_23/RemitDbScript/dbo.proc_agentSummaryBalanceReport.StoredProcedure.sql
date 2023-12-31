ALTER  proc [dbo].[proc_agentSummaryBalanceReport]
(	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(100)	= NULL
	,@mapCodeInt		VARCHAR(50) 	= NULL
	,@agentName			VARCHAR(50)		= NULL
	,@pageNumber		INT				= 1
	,@pageSize			INT				= 50
	,@agentGroup		VARCHAR(50)		= NULL	
) 
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON	
	DECLARE @sql VARCHAR(MAX)	
	IF @flag = 's'
	BEGIN		
			IF(OBJECT_ID('tempdb..#SecurityDeposit') IS NOT NULL)
			BEGIN
				DROP TABLE #SecurityDeposit
			END

			CREATE TABLE #SecurityDeposit
			(
				agentId			INT,
				value			VARCHAR(200) NULL
			)
			INSERT INTO #SecurityDeposit
			SELECT agentId, value = 'Cash Security: '+CAST(sum(isnull(cashDeposit,0)) as varchar) FROM cashSecurity WITH(NOLOCK)
			group by agentId
			UNION ALL
			SELECT agentId, value ='Bank Guarantee: '+CAST(sum(isnull(amount,0)) as varchar) FROM bankGuarantee WITH(NOLOCK) 
			group by agentId
			UNION ALL
			SELECT agentId, value ='Mortgage: '+CAST(sum(isnull(valuationAmount,0)) as varchar) FROM mortgage WITH(NOLOCK) 
			group by agentId
			UNION ALL
			SELECT agentId, value ='Fixed Deposit: '+CAST(sum(isnull(amount,0)) as varchar) FROM fixeddeposit WITH(NOLOCK)
			group by agentId
			
	
			SET @sql = '
					SELECT 
					 [Agent Name]			 = a.agent_name
					,[Agent Group]			 = stv.detailTitle
					,[Security Deposit]		 = value 			
					,[Closing Balance]		 = ISNULL(clr_bal_amt,0) + ISNULL(cr.todaysPaid,0) - ISNULL(cr.todaysSent,0) + ISNULL(cr.todaysPOI,0)  - ISNULL(cr.todaysEPI,0) + ISNULL(cr.todaysCancelled,0) 
					,[Todays Send]			 = ISNULL(cr.todaysSent,0) 
					,[Todays Paid]			 = ISNULL(cr.todaysPaid,0) 
					,[Todays Cancel]		 = ISNULL(cr.todaysCancelled,0)   
					,[Todays EP]			 = ISNULL(cr.todaysEPI,0) 
					,[Todays PO]			 = ISNULL(cr.todaysPOI,0)  
				FROM SendMnPro_Account.dbo.agentTable a WITH (NOLOCK) 
				INNER JOIN SendMnPro_Account.dbo.ac_master c WITH (NOLOCK) on a.agent_id = c.agent_id 
				INNER JOIN agentMaster am with(nolock) on a.map_code = am.mapCodeInt
				INNER JOIN dbo.creditLimit cr WITH(NOLOCK) ON am.agentId = cr.agentId
				LEFT JOIN staticDataValue stv with(nolock) on valueId = am.agentGrp
				LEFT JOIN #SecurityDeposit t with(nolock) on am.agentId=t.agentId
				WHERE acct_rpt_code =''20'' AND a.map_code <> 0 AND a.map_code is not null'
			
		IF @mapCodeInt IS NOT NULL 
			SET @sql = @sql + ' AND map_code='''+@mapCodeInt+''''
		
		IF @agentGroup IS NOT NULL 
			SET @sql = @sql + ' AND am.agentGrp='''+@agentGroup+''''
		
		SET @sql = @sql + ' ORDER BY stv.detailTitle,a.agent_name '
		EXEC(@sql)
		
	    EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			
		SELECT  'Agent' head, CASE WHEN @mapCodeInt IS NULL THEN 'ALL' ELSE @agentName END value 
		
		SELECT 'Agent Summary Balance Report' title
	END



GO
