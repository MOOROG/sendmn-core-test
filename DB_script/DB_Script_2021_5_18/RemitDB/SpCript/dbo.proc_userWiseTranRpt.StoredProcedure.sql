USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userWiseTranRpt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC proc_userWiseTranRpt_new2 @FLAG='UWHO',@FROMDATE='10/18/2013',@TODATE='10/18/2013',@USERNAME=null,@userType='HO'
EXEC proc_userWiseTranRpt_new2 @FLAG='UW',@FROMDATE='10/18/2013',@TODATE='10/18/2013',@USERNAME=null,@userType='HO'
EXEC proc_userWiseTranRpt @FLAG='UW',@FROMDATE='10/18/2013',@TODATE='10/18/2013',@USERNAME=null,@userType='Agent'
*/
CREATE procEDURE [dbo].[proc_userWiseTranRpt]
	@flag				VARCHAR(20),
	@fromDate			VARCHAR(20)	= NULL,
	@toDate				VARCHAR(30) = NULL,
	@userName			VARCHAR(50)	= NULL,
	@userType			VARCHAR(50)	= NULL,
	@user				VARCHAR(50)	= NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;


	IF OBJECT_ID('tempdb..#tempAgentType') IS NOT NULL 
	DROP TABLE #tempAgentType	
		
	CREATE TABLE #tempAgentType
	(
		agentType varchar(50) null
	)	

	IF @userType='HO'
	BEGIN
		INSERT INTO #tempAgentType
		SELECT '2901'
	END	

	IF @userType='Agent'
	BEGIN
		INSERT INTO #tempAgentType
		SELECT valueId FROM staticDataValue WHERE valueId <> 2901 and typeID=2900
	END	
	
	IF @userType IS NULL
	BEGIN
		INSERT INTO #tempAgentType
		SELECT valueId FROM staticDataValue WHERE typeID=2900
	END	
	DECLARE @TABLE TABLE 
	(
		BRANCHID INT,
		BRANCHNAME VARCHAR(200) ,
		USERNAME VARCHAR(50),
		TXNSEND INT,
		AMOUNTSEND MONEY,
		TXNPAID INT, 
		AMOUNTPAID MONEY
	)
		IF (DATEDIFF(DAY, @fromDate,@toDate) > 7 )
		BEGIN	
				IF @FLAG ='UWHO'
				BEGIN
					SELECT DISTINCT USERNAME [HEAD] FROM @TABLE
			
					SELECT 		 
					 [HEAD]					= USERNAME
					,[Agent Name]			= BRANCHNAME
					,[#Send Trans]			= SUM(ISNULL(TXNSEND,0)) 
					,[Send Amount]			= SUM(ISNULL(AMOUNTSEND,0)) 
					,[#Paid Trans]			= SUM(ISNULL(TXNPAID,0)) 
					,[Paid Amount]			= SUM(ISNULL(AMOUNTPAID,0))
					FROM @TABLE 
					GROUP BY BRANCHNAME,USERNAME,BRANCHID

			
					EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

					SELECT 'From Date' head,@FROMDATE value
					UNION ALL
					SELECT 'To Date' head,@TODATE value
					UNION ALL
					SELECT 'User' head,isnull(@USERNAME,'All') value
					SELECT 'USER WISE DETAIL REPORT-<font color="red"> Invalid date Range (max 7 days) to view this report</font>' title
					return;
				END
				ELSE
				BEGIN
					SELECT 		 
					 [HEAD]					= USERNAME
					,[#SEND Trans]			= SUM(ISNULL(TXNSEND,0)) 
					,[SEND Amount]			= SUM(ISNULL(AMOUNTSEND,0)) 
					,[#Paid Trans]			= SUM(ISNULL(TXNPAID,0)) 
					,[Paid Amount]			= SUM(ISNULL(AMOUNTPAID,0)) 
					FROM @TABLE GROUP BY USERNAME
			
					EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

					SELECT 'From Date' head,@FROMDATE value
					UNION ALL
					SELECT 'To Date' head,@TODATE value
					UNION ALL
					SELECT 'User' head,isnull(@USERNAME,'All') value


					SELECT 'USER WISE SUMMARY REPORT- <font color="red"> Invalid date Range (max 7 days) to view this report</font>' title
				END
		 END
	SET @TODATE  = @TODATE + ' 23:59:59'
	IF @FLAG='UWHO'
	BEGIN
	
		INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNSEND,AMOUNTSEND)
		SELECT		
				sBranch,
				sBranchName,
				txn.createdBy,
				COUNT('x'),
				SUM(cAmt) 
		FROM remitTran txn WITH(NOLOCK) 
		inner join applicationUsers au with(nolock) on au.userName = txn.createdBy
		inner join agentMaster am with(nolock) on au.agentId = am.agentId		
		inner join #tempAgentType at with(nolock) on at.agentType = am.agentType 
		WHERE txn.createdDate BETWEEN @fromDate AND @toDate
		AND txn.createdby = isnull(@userName,txn.createdBy)
		GROUP BY txn.createdBy,sBranchName,sBranch

		INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNPAID,AMOUNTPAID)
		SELECT  
					pBranch,
					pBranchName,
					txn.paidBy,
					COUNT('x'),
					SUM(pAmt) 
		FROM remitTran txn WITH(NOLOCK) 
		inner join applicationUsers au with(nolock) on au.userName = txn.paidBy
		inner join agentMaster am with(nolock) on au.agentId = am.agentId		
		inner join #tempAgentType at with(nolock) on at.agentType = am.agentType 
		WHERE txn.paidDate BETWEEN @fromDate AND @toDate
		AND txn.paidBy = isnull(@userName,txn.paidBy)
		GROUP BY txn.paidBy,pBranchName,pBranch

		SELECT DISTINCT USERNAME [HEAD] FROM @TABLE
			
		SELECT 		 
			 [HEAD]					= USERNAME
			,[Agent Name]				= BRANCHNAME
			,[#Send Trans]			= SUM(ISNULL(TXNSEND,0)) 
			,[Send Amount]			= SUM(ISNULL(AMOUNTSEND,0)) 
			,[#Paid Trans]			= SUM(ISNULL(TXNPAID,0)) 
			,[Paid Amount]			= SUM(ISNULL(AMOUNTPAID,0)) 
		FROM @TABLE 
		GROUP BY BRANCHNAME,USERNAME,BRANCHID

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
			INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNSEND,AMOUNTSEND)
			SELECT		
						sBranch,
						sBranchName,
						txn.createdBy,
						COUNT('x'),
						SUM(cAmt) 
			FROM vwRemitTran txn WITH(NOLOCK) 
			inner join applicationUsers au with(nolock) on au.userName = txn.createdBy
			inner join agentMaster am with(nolock) on au.agentId = am.agentId		
			inner join #tempAgentType at with(nolock) on at.agentType = am.agentType 
			WHERE txn.createdDate BETWEEN @fromDate AND @toDate
			AND txn.createdby = isnull(@userName,txn.createdBy)
			GROUP BY txn.createdBy,sBranchName,sBranch

			INSERT INTO @TABLE(BRANCHID,BRANCHNAME,USERNAME,TXNPAID,AMOUNTPAID)
			SELECT  
						pBranch,
						pBranchName,
						paidBy,
						COUNT('x'),
						SUM(pAmt) 
			FROM vwRemitTran txn WITH(NOLOCK) 
			inner join applicationUsers au with(nolock) on au.userName = txn.paidBy
			inner join agentMaster am with(nolock) on au.agentId = am.agentId		
			inner join #tempAgentType at with(nolock) on at.agentType = am.agentType 
			WHERE txn.paidDate BETWEEN @fromDate AND @toDate
			AND txn.paidBy = isnull(@userName,txn.paidBy)
			GROUP BY paidBy,pBranchName,pBranch

			SELECT 		 
				 [HEAD]					= USERNAME
				,[#SEND Trans]			= SUM(ISNULL(TXNSEND,0)) 
				,[SEND Amount]			= SUM(ISNULL(AMOUNTSEND,0)) 
				,[#Paid Trans]			= SUM(ISNULL(TXNPAID,0)) 
				,[Paid Amount]			= SUM(ISNULL(AMOUNTPAID,0)) 
			FROM @TABLE GROUP BY USERNAME

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'User' head,isnull(@USERNAME,'All') value


			SELECT 'USER WISE SUMMARY TRANSACTION REPORT' title
	END



GO
