USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cooperativeReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_cooperativeReport]
		 @flag				VARCHAR(10)	 = NULL
		,@user				VARCHAR(30)  = NULL
		,@fromDate			VARCHAR(50)	 = NULL
		,@toDate			VARCHAR(50)	 = NULL
		,@agentGrp			VARCHAR(50)	 = NULL
		,@agent				VARCHAR(50)	 = NULL
		,@branch			VARCHAR(50)	 = NULL
		,@table             VARCHAR(MAX) = NULL
		,@pageNumber		INT			 = NULL
		,@pageSize			INT			 = NULL
		
AS 
/*

EXEC proc_cooperativeReport @flag ='rpt' 
, @user = 'netra'
, @agentGrp = '8026'
, @agent = NULL
, @branch = NULL
, @fromDate = '2016-05-18'
, @toDate = '2016-05-29'
, @pageNumber = 1
, @pageSize = 100



*/


	
SET NOCOUNT ON;
SET XACT_ABORT ON ;	
BEGIN TRY

	DECLARE @sql1				VARCHAR(MAX) 
			,@sql2				VARCHAR(MAX) 
			,@sql3				VARCHAR(MAX)
			,@sqlEP				VARCHAR(MAX)
			,@sqlPO				VARCHAR(MAX)
			,@sqlCancel			VARCHAR(MAX)
			,@mainSql			VARCHAR(MAX)

 IF @flag = 'rpt'
 BEGIN
	
	IF @agentGrp IS NULL
	BEGIN
		
		SELECT @agentGrp=am.agentGrp FROM dbo.applicationUsers u WITH(NOLOCK) 
		INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON u.agentId=am.agentId WHERE u.userName=@user
	END
		-- Domestic Send
		SET @sql1 =' SELECT 
					sAgent
				   ,sBranch
				   ,sendCount = count(''x'')
			   FROM vwRemitTran rt WITH(NOLOCK) 
			   INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sAgent = am.agentId
			   WHERE (am.agentGrp = 8026 OR am.agentGrp = 9906) and tranType = ''D''
			   AND rt.approvedDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		  
		IF @agent IS NOT NULL
			SET @sql1 = @sql1 + ' AND sAgent = '''+@agent+''''
		
		IF @branch IS NOT NULL
			SET @sql1 = @sql1 + ' AND sBranch = '''+@branch+''''

		IF @agentGrp IS NOT NULL
				SET @sql1 = @sql1 + ' AND am.agentGrp = '''+@agentGrp+''''

		SET @sql1= @sql1+'  GROUP BY sBranch,sAgent'
		 
		-- Domestic Cancel
		SET @sqlCancel =' SELECT 
					sAgent
				   ,sBranch
				   ,cancelCount = count(''x'')
			   FROM vwRemitTran rt WITH(NOLOCK) 
			   INNER JOIN agentMaster am WITH(NOLOCK) ON rt.sAgent = am.agentId
			   WHERE  (am.agentGrp = 8026 OR am.agentGrp = 9906) and tranType = ''D'' and tranStatus = ''Cancel''
			   AND rt.cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		  
		IF @agent IS NOT NULL
			SET @sqlCancel = @sqlCancel + ' AND sAgent = '''+@agent+''''
		
		IF @branch IS NOT NULL
			SET @sqlCancel = @sqlCancel + ' AND sBranch = '''+@branch+''''

		IF @agentGrp IS NOT NULL
			SET @sqlCancel = @sqlCancel + ' AND am.agentGrp = '''+@agentGrp+''''

		SET @sqlCancel= @sqlCancel+'  GROUP BY sBranch,sAgent'

		 
		 --Domestic Paid
		SET @sql2 ='SELECT 
						 pAgent						
						,pBranch
						,payCount = count(*)
						--,payAmount = SUM(pAmt)
				FROM vwRemitTran rt WITH(NOLOCK) 
				INNER JOIN agentMaster am WITH(NOLOCK)
				ON rt.pAgent = am.agentId
				WHERE  (am.agentGrp = 8026 OR am.agentGrp = 9906) AND rt.sCountry = ''Nepal'' and tranType =''D''
				AND rt.paidDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		  
		IF @agent IS NOT NULL
			SET @sql2 = @sql2 + ' AND pAgent = '''+@agent+''''
		
		IF @branch IS NOT NULL
			SET @sql2 = @sql2 + ' AND pBranch = '''+@branch+''''
		
		IF @agentGrp IS NOT NULL
			SET @sql2 = @sql2 + ' AND am.agentGrp = '''+@agentGrp+''''

		SET @sql2= @sql2+' GROUP BY pBranch,pAgent'
		
		-- International Paid
		SET @sql3 ='SELECT 
						 pAgent
						,pBranch
						,payCount = count(*)
						--,payAmount = SUM(pAmt)
				FROM vwRemitTran rt WITH(NOLOCK) 
				INNER JOIN agentMaster am WITH(NOLOCK)
				ON rt.pAgent = am.agentId
				WHERE  (am.agentGrp = 8026 OR am.agentGrp = 9906) AND rt.sCountry <> ''Nepal''
				AND rt.paidDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		 
		IF @agent IS NOT NULL
			SET @sql3 = @sql3 + ' AND pAgent = '''+@agent+''''
		
		IF @branch IS NOT NULL
			SET @sql3 = @sql3 + ' AND pBranch = '''+@branch+''''

		IF @agentGrp IS NOT NULL
			SET @sql3 = @sql3 + ' AND am.agentGrp = '''+@agentGrp+''''
			 
		SET @sql3= @sql3+' GROUP BY pBranch,pAgent'
		 
 		-- ## EP
		SET @sqlEP ='SELECT 
								 pAgent
								,pBranch
								,payCount = count(''x'')
					FROM errPaidTran ep WITH(NOLOCK) 
					INNER JOIN agentMaster am WITH(NOLOCK) ON ep.oldPBranch = am.agentId
					inner join remitTran rt with(nolock) on rt.id = ep.tranId
					WHERE  (am.agentGrp = 8026 OR am.agentGrp = 9906)  
						AND ep.approvedDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		 
		IF @agent IS NOT NULL
			SET @sqlEP = @sqlEP + ' AND pAgent = '''+@agent+''''
		
		IF @branch IS NOT NULL
			SET @sqlEP = @sqlEP + ' AND pBranch = '''+@branch+''''		
		IF @agentGrp IS NOT NULL
			SET @sqlEP = @sqlEP + ' AND am.agentGrp = '''+@agentGrp+''''	 
		
		SET @sqlEP= @sqlEP+' GROUP BY pBranch,pAgent '

		-- ## PO
		SET @sqlPO ='SELECT 
						 newPAgent
						,newPBranch
						,payCount = count(''x'')
					FROM errPaidTran ep WITH(NOLOCK) 
					INNER JOIN agentMaster am WITH(NOLOCK) ON ep.newPBranch = am.agentId
					inner join remitTran rt with(nolock) on rt.id = ep.tranId
					WHERE  (am.agentGrp = 8026 OR am.agentGrp = 9906) 
					AND ep.newPaidDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		 
		IF @agent IS NOT NULL
			SET @sqlPO = @sqlPO + ' AND newPAgent = '''+@agent+''''
		
		IF @branch IS NOT NULL
			SET @sqlPO = @sqlPO + ' AND newPBranch = '''+@branch+''''

		IF @agentGrp IS NOT NULL
			SET @sqlPO = @sqlPO + ' AND am.agentGrp = '''+@agentGrp+''''
			 
		SET @sqlPO= @sqlPO+' GROUP BY newPAgent,newPBranch '

		IF CONVERT(VARCHAR,GETDATE(),101)  < = CONVERT(VARCHAR,CAST(@toDate AS DATETIME),101)
		BEGIN
			SET @mainSql ='
			select 
				a.agentId
				,a.agentName sBranchName
				,case when b.agentId = 1002 then a.agentName else b.agentName end sAgentName
				,case when b.agentId = 1002 then a.agentId else a.parentId end parentId
				,balance = CASE 
								WHEN a.isSettlingAgent = ''Y'' 
							THEN DBO.FNAGetAvailableBalance(a.agentId) 
								WHEN ISNULL(a.isSettlingAgent,''N'') <> ''Y'' AND ISNULL(B.isSettlingAgent,''N'') = ''Y'' AND a.isHeadOffice = ''Y''
							THEN DBO.FNAGetAvailableBalance(B.agentId) 
								ELSE 0 
							END
				,a.agentGrp
			from agentMaster a with(nolock) 
			inner join agentMaster b with(nolock) on a.parentId = b.agentId									 
			where ISNULL(a.agentBlock,''U'') <> ''B''
			AND ISNULL(B.agentBlock,''U'') <> ''B''
			AND (( (a.agentGrp = 8026 OR a.agentGrp = 9906) and a.agentType = 2904) 
			OR (a.agentType = 2903 and a.actasbranch=''Y'' AND  (a.agentGrp = 8026 OR a.agentGrp = 9906)))'
		END
		ELSE
		BEGIN
		SET @mainSql ='
			select 
				 a.agentId
				,a.agentName sBranchName
				,case when b.agentId = 1002 then a.agentName else b.agentName end sAgentName
				,case when b.agentId = 1002 then a.agentId else a.parentId end parentId
				,balance =										
							CASE 
								WHEN a.isSettlingAgent = ''Y'' 
							THEN bal.balance
								WHEN ISNULL(a.isSettlingAgent,''N'') <> ''Y'' AND ISNULL(B.isSettlingAgent,''N'') = ''Y'' AND a.isHeadOffice = ''Y''
							THEN bal.balance
							ELSE 0 END
				,a.agentGrp
			from agentMaster a with(nolock) 
			inner join agentMaster b with(nolock) on a.parentId = b.agentId		
			LEFT join
			(
				SELECT agentId,balance = ISNULL(amt,0) FROM RemittanceLogData.dbo.agentClosingBalanceHistory bh WITH(NOLOCK) 
				WHERE CONVERT(VARCHAR,balDate,101) = CONVERT(VARCHAR,CAST('''+@toDate+''' AS DATETIME),101)
			)bal ON a.agentId = bal.agentId OR a.parentId = bal.agentId									 
			where ISNULL(a.agentBlock,''U'') <> ''B''
				AND ISNULL(B.agentBlock,''U'') <> ''B''
				AND (( (a.agentGrp = 8026 OR a.agentGrp = 9906)  and a.agentType = 2904) 
				OR (a.agentType = 2903 and a.actasbranch=''Y'' AND  (a.agentGrp = 8026 OR a.agentGrp = 9906) ))'
		END

	
		SET @table ='
				SELECT 
					  [SN] = row_number() over(order by a.sBranchName)
					, [Agent] = a.sBranchName
					, [Domestic Transaction_Send] = isnull(b.sendCount,0)
					, [Domestic Transaction_Paid] = isnull(c.payCount,0)
					, [Domestic Transaction_Cancel] = isnull(g.cancelCount,0)
					, [Int''l <br/>Paid] = isnull(d.payCount,0)
					, [EP] = isnull(e.payCount,0)
					, [PO] = isnull(f.payCount,0)
					, [Closing Balance_Payable] = CASE WHEN balance >= 0 THEN balance ELSE 0 END 
					, [Closing Balance_Receivable] = CASE WHEN balance < 0 THEN balance ELSE 0 END 
				FROM 
				  (  
					'+@mainSql+'					  
				  )a 
				  LEFT JOIN
				  ( '+@sql1 +')b ON a.agentId = b.sBranch 
				  LEFT JOIN 
				  (' +@sql2 +' )c ON a.agentId = c.pBranch 
				  LEFT JOIN 
				  (' +@sql3 +' )d ON a.agentId = d.pBranch 
				   LEFT JOIN 
				  (' +@sqlEP +' )e ON a.agentId = e.pBranch 
				   LEFT JOIN 
				  (' +@sqlPO +' )f ON a.agentId = f.newPBranch 
				  LEFT JOIN 
				  (' +@sqlCancel +' )g ON a.agentId = g.sBranch 
				  where 1=1 '
				
			IF @agent IS NOT NULL
				SET @table = @table + ' AND a.parentId = '''+@agent+''''
		
			IF @branch IS NOT NULL
				SET @table = @table + ' AND a.agentId = '''+@branch+''''

			IF @agentGrp IS NOT NULL
				SET @table = @table + ' AND a.agentGrp = '''+@agentGrp+''''
		  	
			SET @table = @table + ' order by  a.sBranchName'		
		    PRINT @table
				
			EXEC(@table)
		
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			

			SELECT 'From Date' head,@fromDate VALUE
			UNION ALL 
			SELECT 'TO Date' head,@toDate VALUE
			UNION ALL 
			SELECT 'Agent' head,CASE WHEN @agent IS NULL THEN 'All' ELSE (SELECT agentName from agentMaster where agentId=@agent) END  VALUE
			UNION ALL 
			SELECT 'Branch' head,CASE WHEN @branch IS NULL THEN 'All' ELSE (SELECT agentName from agentMaster where agentId=@branch) END  VALUE
			UNION ALL 
			SELECT 'Agent Group' AS head, detailTitle AS VALUE from dbo.staticDataValue where valueId= @agentGrp 

			SELECT 'Transaction Report Super Agent (Cooperative)' title	
END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id, ERROR_LINE()
     print error_line()
END CATCH




GO
