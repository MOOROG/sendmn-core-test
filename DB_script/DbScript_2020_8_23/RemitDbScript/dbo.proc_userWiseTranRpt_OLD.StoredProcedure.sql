USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userWiseTranRpt_OLD]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_userWiseTranRpt @FLAG='UW',@FROMDATE='1/10/2012',@TODATE='10/10/2012',@USERNAME=NULL,@userType='HO'

EXEC proc_userWiseTranRpt @FLAG='UW',@FROMDATE='1/10/2012',@TODATE='10/10/2012',@USERNAME=NULL,@userType='Agent'

EXEC proc_userWiseTranRpt @FLAG='UWHO',@FROMDATE='09/20/2012',@TODATE='09/21/2012',@USERNAME=NULL

*/
CREATE procEDURE [dbo].[proc_userWiseTranRpt_OLD]
	@flag				VARCHAR(20),
	@fromDate			VARCHAR(20)	= NULL,
	@toDate				VARCHAR(30) = NULL,
	@userName			VARCHAR(50)	= NULL,
	@userType			VARCHAR(50)	= NULL,
	@user				VARCHAR(50)	= NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

	SET @TODATE  = @TODATE + ' 23:59:59'
	
	IF OBJECT_ID('tempdb..#tempTable2') IS NOT NULL 
	DROP TABLE #tempTable2	
			
	CREATE TABLE #tempTable2
	(
		agentType varchar(50) null
	)	

	IF @userType='HO'
	BEGIN
		INSERT INTO #tempTable2
		SELECT '2901'
	END	

	IF @userType='Agent'
	BEGIN
		INSERT INTO #tempTable2
		SELECT valueId FROM staticDataValue WHERE valueId<>2901 and typeID=2900
	END	
	
	IF @userType IS NULL
	BEGIN
		INSERT INTO #tempTable2
		SELECT valueId FROM staticDataValue WHERE typeID=2900
	END		
	
	--select * from #tempTable2
	IF @FLAG='UWHO'
	BEGIN
				
			IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL 
			DROP TABLE #tempTable
			IF OBJECT_ID('tempdb..#tempTable1') IS NOT NULL 
			DROP TABLE #tempTable1	

			
			CREATE TABLE #tempTable
			(
				userName varchar(50) null,
				branchId int null,
				sendCount int null,
				sendAmount money null,			
				paidCount int null,			
				paidAmount money null
			)	
			CREATE TABLE #tempTable1
			(
				userName varchar(50) null,
				branchId int null,
				sendCount int null,
				sendAmount money null,			
				paidCount int null,			
				paidAmount money null
			)		
		
		-- Send & Paid Transaction User Wise 
			insert into #tempTable
			select x.userName,x.sBranch,x.TranCount ,x.cAmt ,y.TranCount ,y.pAmt 
			from 
			(
				select * from 
				(
					SELECT a.userName
							FROM applicationUsers  a WITH(NOLOCK) 
							INNER JOIN agentMaster b WITH(NOLOCK) ON a.agentId=b.agentId
							INNER JOIN #tempTable2 C WITH(NOLOCK) ON C.agentType=b.agentType
							where a.userName =ISNULL(@userName,a.userName)
				)a
				inner join
				(		
					select sBranch,createdBy ,COUNT(*) TranCount,SUM(cAmt) cAmt
							from remitTran with(nolock) where approvedDate between @fromDate and @toDate
							and createdBy =ISNULL(@userName,createdBy)
							and approvedDate is not null
							group by createdBy,sBranch
							
				)b on a.userName=b.createdBy 
			)x
			inner join 
			(
					
				select * from 
				(
					SELECT a.userName
							FROM applicationUsers  a WITH(NOLOCK) 
							INNER JOIN agentMaster b with(nolock) on a.agentId=b.agentId
							INNER JOIN #tempTable2 C WITH(NOLOCK) ON C.agentType=b.agentType
							where a.userName =ISNULL(@userName,a.userName)
				)a
				inner join
				(		
					select pBranch,paidBy,COUNT(*) TranCount,SUM(pAmt) pAmt 
							from remitTran with(nolock)	where tranStatus='Paid'
							and paidDate between @fromDate and @toDate
							and paidBy =ISNULL(@userName,paidBy) and paidDate between @fromDate and @toDate
							group by paidBy,pBranch
							
				)b on a.userName=b.paidBy
			)y on y.pBranch=x.sBranch and x.createdBy=y.paidBy			
			
			
			insert into #tempTable1(userName,branchId,sendCount,sendAmount,paidCount,paidAmount)
			select a.userName,b.sBranch,b.TranCount,b.cAmt,null,null 
			from 
			(
				select a.userName
						from applicationUsers  a  with(nolock) 
						inner join agentMaster b with(nolock) on a.agentId=b.agentId
						INNER JOIN #tempTable2 C WITH(NOLOCK) ON C.agentType=b.agentType
						where a.userName =ISNULL(@userName,a.userName)
			)a
			inner join
			(		
				select sBranch,createdBy ,COUNT(*) TranCount,SUM(cAmt) cAmt
						from remitTran with(nolock) where approvedDate between @fromDate and @toDate
						and createdBy =ISNULL(@userName,createdBy)
						and approvedDate is not null
						group by createdBy,sBranch
						
			)b on a.userName=b.createdBy 				
			
			DELETE FROM #tempTable1 						
			FROM #tempTable1 t
			INNER JOIN #tempTable ds ON t.branchId = ds.branchId
			AND  ds.userName = t.userName 
			
			insert into #tempTable 
			select * from #tempTable1			
			
			delete from #tempTable1
			
			insert into #tempTable1
			select a.userName,b.pBranch,null,null,b.TranCount,b.pAmt 
			from 
			(
				SELECT a.userName
						from applicationUsers  a with(nolock) 
						INNER JOIN agentMaster b with(nolock) on a.agentId=b.agentId
						INNER JOIN #tempTable2 C WITH(NOLOCK) ON C.agentType=b.agentType
						where a.userName =ISNULL(@userName,a.userName)
			)a
			inner join
			(		
				select pBranch,paidBy,COUNT(*) TranCount,SUM(pAmt) pAmt 
							from remitTran with(nolock)	
							where tranStatus='Paid' and paidDate between @fromDate and @toDate
							and paidBy =ISNULL(@userName,paidBy) 
							group by paidBy,pBranch
						
			)b on a.userName=b.paidBy 
			
			DELETE FROM #tempTable1 						
			FROM #tempTable1 t
			INNER JOIN #tempTable ds ON t.branchId = ds.branchId
			AND  ds.userName = t.userName 
			
			insert into #tempTable 
			select * from #tempTable1
			
			select distinct userName [HEAD] from #tempTable
			
			select userName [HEAD]
					,b.agentName [Agent Name]
					,isnull(sendCount,0) [#Send Trans]
					,isnull(sendAmount,0) [Send Amount]
					,isnull(paidCount,0) [#Paid Trans]
					,isnull(paidAmount,0) [Paid Amount]
			from #tempTable a with(nolock) inner join agentMaster b with(nolock) on a.branchId=b.agentId
			order by userName				
			
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'User' head,isnull(@USERNAME,'All') value


			SELECT 'USER WISE DETAIL TRANSACTION REPORT' title
		
	END
	
	
	IF @FLAG='UW'
	BEGIN
			select
				 c.userName [User Name]
				,isnull(A.TranCount,0) [#Send Tran]
				,isnull(a.cAmt,0) [Send Amount]
				,isnull(b.TranCount,0) [#Paid Tran]
				,isnull(b.pAmt,0) [Paid Amount] 
			from 
			(
					SELECT a.userName
						from applicationUsers  a with(nolock) 
						INNER JOIN agentMaster b with(nolock) on a.agentId=b.agentId
						INNER JOIN #tempTable2 C WITH(NOLOCK) ON C.agentType=b.agentType
						where a.userName =ISNULL(@userName,a.userName)
			)c
			left join 
			(
				select createdBy ,COUNT(*) TranCount,SUM(cAmt) cAmt
				from remitTran with(nolock)	
				WHERE approvedDate BETWEEN @FROMDATE AND @TODATE
				and createdBy =ISNULL(@userName,createdBy)
				and approvedDate is not null
				group by createdBy
				
			)a on c.userName=a.createdBy
			left join
			(
				select paidBy,COUNT(*) TranCount,SUM(pAmt) pAmt  
				from remitTran with(nolock)	where tranStatus='Paid' AND paidDate BETWEEN @FROMDATE AND @TODATE
				and paidBy =ISNULL(@userName,paidBy) 
				group by paidBy

			)b on c.userName=b.paidBy 
			where c.userName = ISNULL(@USERNAME,c.userName) AND a.TranCount is not null or b.TranCount is not null 
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'User' head,isnull(@USERNAME,'All') value


			SELECT 'USER WISE SUMMARY TRANSACTION REPORT' title
	END
	



GO
