USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userWiseTranRptAgent]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*EXEC proc_userWiseTranRpt @FLAG='UW',@FROMDATE='1/10/2012',@TODATE='10/10/2012',@USERNAME=NULL,@userType='HO'

EXEC proc_userWiseTranRpt @FLAG='UW',@FROMDATE='1/10/2012',@TODATE='10/10/2012',@USERNAME=NULL,@userType='Agent'
EXEC proc_userWiseTranRptAgent @FLAG='A',@FROMDATE='11/30/2012',@TODATE='11/30/2012',@USERNAME=NULL,@agentId=2055

select * from 


*/
CREATE procEDURE [dbo].[proc_userWiseTranRptAgent]
	@flag				VARCHAR(20),
	@fromDate			VARCHAR(30)	= NULL,
	@toDate				VARCHAR(30) = NULL,
	@userName			VARCHAR(50)	= NULL,
	@agentId			INT			= NULL,
	@user				VARCHAR(50)	= NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

	SET @TODATE  = @TODATE + ' 23:59:59'
	DECLARE @SQL AS VARCHAR(MAX)
	IF @FLAG='A'
	BEGIN
			IF OBJECT_ID('tempdb..#tempTable2') IS NOT NULL 
			DROP TABLE #tempTable2	
			
			
			CREATE TABLE #tempTable2
			(
				userName VARCHAR(50) null,
				sendTran INT null,
				sendAmount MONEY NULL,
				paidTran	INT NULL,
				paidAmount	MONEY NULL				
			)
			
			insert into #tempTable2	
			select approvedBy ,COUNT(*) ,SUM(cAmt),NULL,NULL  
			from remitTran a with(nolock) WHERE A.approvedDate BETWEEN @FROMDATE AND @TODATE
				AND A.sBranch=@agentId
				and A.createdBy =ISNULL(@userName,A.createdBy)				
				and A.approvedDate is not null
				group by A.approvedBy
				
			insert into #tempTable2	
			select A.paidBy,NULL,NULL,COUNT(*),SUM(A.pAmt) from remitTran A with(nolock) 
				WHERE A.tranStatus='Paid' 
				AND A.pBranch=@agentId
				AND paidDate BETWEEN @FROMDATE AND @TODATE
				AND A.paidBy =ISNULL(@userName,A.paidBy) 
				group by A.paidBy
				
			SELECT   userName [User Name]
					,SUM(ISNULL(sendTran,0)) [#Send Tran]
					,SUM(ISNULL(sendAmount,0)) [Send Amount]
					,SUM(ISNULL(paidTran,0)) [#Paid Tran]
					,SUM(ISNULL(paidAmount,0)) [Paid Amount]
			FROM #tempTable2
			GROUP BY userName
			
			--RETURN;
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'User' head,isnull(@USERNAME,'All') value


			SELECT 'USER WISE SUMMARY TRANSACTION REPORT' title
	END
	
	IF @FLAG='s'
	BEGIN
			
			SET @SQL ='SELECT 
					 --[Control No]			=''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(main.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
					 [Control No]			= dbo.FNADecryptString(controlNo)
					,[Send Date]			= CONVERT(VARCHAR,MAIN.approvedDate,101)		
					,[Sending Country]		= sCountry
					,[Sending Location]		= SLOC.districtName
					,[Sending Agent]		= sAgentName
					,[Sending Branch]		= sBranchName
					,[Sending Amt]			= cAmt
					,[Sending Currency]		= collCurr
					,[Status]				= MAIN.tranStatus
					,[Receiving Country]	= ISNULL(pCountry,''-'')
					,[Receiving Location]	= PLOC.locationName
					,[Receiving Agent]		= ISNULL(pAgentName,''-'')
					,[Receiving Branch]		= ISNULL(pBranchName,''-'')
					,[Receiving Amt]		= pAmt
					,[Receiving Currency]	= payoutCurr
					,[Tran Type]			= MAIN.paymentMethod
					,[Sender Name]=TSEND.firstName + ISNULL('' '' + TSEND.middleName, '''') + ISNULL('' '' + TSEND.lastName1, '''') + ISNULL('' '' + TSEND.lastName2,'''')
					,[Receiver Name]=TREC.firstName + ISNULL('' '' + TREC.middleName, '''') + ISNULL('' '' + TREC.lastName1, '''') + ISNULL('' '' + TREC.lastName2, '''')
				FROM remitTran MAIN WITH(NOLOCK)  
				LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
				LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
				LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
				LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
				LEFT JOIN tranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
				LEFT JOIN tranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
				WHERE MAIN.approvedDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +'''  
				AND MAIN.sBranch='+CAST(@agentId AS VARCHAR)+' and MAIN.approvedDate is not null AND
				MAIN.createdBy = '''+@userName+''''
			
			EXEC(@SQL)	
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'User' head,isnull(@USERNAME,'All') value


			SELECT 'USER WISE DETAIL SEND TRANSACTION REPORT' title
	END
	
	IF @FLAG='p'
	BEGIN
	
			SET @SQL ='SELECT 
					-- [Control No]			=''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(main.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
					 [Control No]			= dbo.FNADecryptString(controlNo)
					,[Send Date]			= CONVERT(VARCHAR,MAIN.approvedDate,101)		
					,[Sending Country]		= sCountry
					,[Sending Location]		= SLOC.districtName
					,[Sending Agent]		= sAgentName
					,[Sending Branch]		= sBranchName
					,[Sending Amt]			= cAmt
					,[Sending Currency]		= collCurr
					,[Status]				= MAIN.tranStatus
					,[Receiving Country]	= ISNULL(pCountry,''-'')
					,[Receiving Location]	= PLOC.locationName
					,[Receiving Agent]		= ISNULL(pAgentName,''-'')
					,[Receiving Branch]		= ISNULL(pBranchName,''-'')
					,[Receiving Amt]		= pAmt
					,[Receiving Currency]	= payoutCurr
					,[Tran Type]			= MAIN.paymentMethod
					,[Sender Name]=TSEND.firstName + ISNULL('' '' + TSEND.middleName, '''') + ISNULL('' '' + TSEND.lastName1, '''') + ISNULL('' '' + TSEND.lastName2,'''')
					,[Receiver Name]=TREC.firstName + ISNULL('' '' + TREC.middleName, '''') + ISNULL('' '' + TREC.lastName1, '''') + ISNULL('' '' + TREC.lastName2, '''')
				FROM remitTran MAIN WITH(NOLOCK)  
				LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
				LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
				LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
				LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
				LEFT JOIN tranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
				LEFT JOIN tranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
				WHERE MAIN.paidDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +'''  
				AND MAIN.pBranch='+CAST(@agentId AS VARCHAR)+' and MAIN.approvedDate is not null AND
				MAIN.paidBy = '''+@userName+''' AND MAIN.tranStatus=''Paid'' '
				
			
			--SELECT (@SQL)
			--RETURN;
			EXEC(@SQL)
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'User' head,isnull(@USERNAME,'All') value


			SELECT 'USER WISE PAID TRANSACTION REPORT' title
	END

GO
