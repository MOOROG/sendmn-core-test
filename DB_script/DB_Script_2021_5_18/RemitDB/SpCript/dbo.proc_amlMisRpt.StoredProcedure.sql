USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_amlMisRpt]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_amlMisRpt]
	 @flag					VARCHAR(10)
	,@user					VARCHAR(30)
	-------------------------------------------
	,@sCountry				VARCHAR(50) = NULL
	,@rCountry				VARCHAR(50) = NULL
	,@sAgent				VARCHAR(50) = NULL
	,@rAgent				VARCHAR(50) = NULL
	,@rMode					VARCHAR(50) = NULL
	,@dateType				VARCHAR(50)	= NULL
	,@frmDate				VARCHAR(50) = NULL
	,@toDate				VARCHAR(50) = NULL
	-------------------------------------------
	,@mrType				VARCHAR(10) = NULL		
	
	-------------------------------------------	
	,@pageNumber			INT			= 1
	,@pageSize				INT			= 50
	,@isExportFull			VARCHAR(1)	= NULL
AS
SET NOCOUNT ON
BEGIN TRY 
	DECLARE @table VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @globalFilter VARCHAR(MAX) = ''
	DECLARE @URL	VARCHAR(MAX) = ''
	DECLARE @reportHead		VARCHAR(100) = ''
	
	SET @rMode = REPLACE(@rMode,'__',' ')

	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	SET @pageNumber	= ISNULL(@pageNumber, 1)
	SET @pageSize	= ISNULL(@pageSize, 100)

	SET @globalFilter = ' AND rt.tranStatus <> ''Cancel'' and rt.tranType <> ''B'' '
	
	IF @sCountry is not null and @sCountry <> '3rd Party Agent'
	BEGIN
		INSERT @FilterList
		SELECT 'Sender Country', @sCountry
		SET @globalFilter = @globalFilter + ' AND rt.sCountry = ''' + @sCountry + ''''
	END
	IF @rCountry is not null and @rCountry <> '3rd Party Agent'
	BEGIN
		INSERT @FilterList
		SELECT 'Receiver Country', @rCountry
		SET @globalFilter = @globalFilter + ' AND rt.pCountry = ''' + @rCountry + ''''
	END		

	IF @sAgent IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Sender Agent', am.agentName 
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sAgent
		SET @globalFilter = @globalFilter + ' AND rt.sAgent = ''' + @sAgent + ''''
	END
	IF @rAgent IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiver Agent', am.agentName 
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @rAgent
		SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @rAgent + ''''
	END	
	IF @rMode IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiving Mode', @rMode
		SET @globalFilter = @globalFilter + ' AND rt.paymentMethod = ''' + @rMode + ''''
	END	
	INSERT @FilterList
	SELECT 'Date Type',  
	case when @dateType = 'txnDate' then 'TXN Date'
		when @dateType = 'confirmDate' then 'Confirm Date'
		when @dateType = 'paidDate' then 'Paid Date' end

	IF @dateType = 'txnDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.createdDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', @toDate
		SET @globalFilter = @globalFilter + ' AND rt.createdDate <= ''' + @toDate + ' 23:59:59'''
	END	
	IF @dateType = 'confirmDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', @toDate
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate <= ''' + @toDate + ' 23:59:59'''
	END	
	IF @dateType = 'paidDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.paidDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', @toDate
		SET @globalFilter = @globalFilter + ' AND rt.paidDate <= ''' + @toDate + ' 23:59:59'''
	END	

	IF @flag = 'mr'
	BEGIN
		SET @reportHead ='MIS Report'
		
		IF @mrType = 'ssmt' -->> Same Sender Multiple Txns
		BEGIN		
			SET @URL='"Reports.aspx?dateType='+@dateType+'&frmDate='+@frmDate+'&toDate='+@toDate+'&sCountry='+ISNULL(replace(@sCountry,' ','__'),'')+'&sAgent='+ISNULL(@sAgent,'')
			+'&rMode='+ISNULL(REPLACE(@rMode,' ','__'),'')+'&rCountry='+ISNULL(replace(@rCountry,' ','__'),'')
			+'&rAgent='+ISNULL(@rAgent,'')
			+'&reportName=amlddlreport&flag=ssmt_ddl&senderName=''+ISNULL(REPLACE([Sender_Name],'' '',''__''),'''')+''&country=''+ISNULL(REPLACE(ts.nativecountry,'' '',''__''),'''')+''&idType=''+ISNULL(ts.idType,'''') +''&idNumber=''+ISNULL(ts.idNumber,'''') +''"'
		
			INSERT @FilterList
			SELECT 'Search By', 'Same Sender Multiple TXNS Summary'
			
			SET @table = '
			SELECT 
			 --[Sender_Member ID]
			[Sender_Name] = ''<span class = "link" onclick =ViewAMLDDLReport('+@URL+');>'' + [Sender_Name] + ''</span>''  
			,[Sender_Nationality]
			,[Sender_Id type]
			,[Sender_ID Number]
			,[Number of TXN]
			,[Transaction_Amount]
			,[Transaction_Currency]
			,[Transaction_Payout Amount]
			,senderName = [Sender_Name]
			FROM 
				(SELECT			 
					 --[Sender_Member ID]				= ts.membershipId
					[Sender_Name]					= rt.SenderName
					,[Sender_Nationality]			= ts.nativecountry 
					,[Sender_Id type]				= ts.idType 
					,[Sender_ID Number]				= ts.idNumber
					,[Number of TXN]				= COUNT(*)			
					,[Transaction_Amount]			= SUM(rt.cAmt) 
					,[Transaction_Currency]			= rt.collCurr 
					,[Transaction_Payout Amount]	= SUM(rt.pAmt) 
					,ts.nativecountry    
					,ts.idType  
					,ts.idNumber  
				FROM vwremitTran rt WITH(NOLOCK)
				LEFT JOIN agentMaster ams WITH(NOLOCK) ON rt.sBranch = ams.agentId
				LEFT JOIN vwtranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId	
				WHERE 1 = 1 and rt.tranStatus <>''cancel''
			'
			
			SET @table = @table + @globalFilter + ' 
				GROUP BY 	
					 --ts.membershipId 
					rt.SenderName
					,ts.nativecountry
					,ts.idType
					,ts.idNumber
					,rt.collCurr
				HAVING COUNT(1) > 1
			)ts'

			IF @isExportFull = 'Y'
			BEGIN
			
				SET @sql = '
					SELECT
						 [SN]	= [S.N]
						--,[Sender_Member ID]
						,[Sender_Name]
						,[Sender_Nationality]
						,[Sender_Id type]
						,[Sender_ID Number]
						,[Number of TXN]	
						,[Transaction_Amount]
						,[Transaction_Currency]
						,[Transaction_Payout Amount]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Number of TXN] DESC,senderName ) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp'
		
				PRINT @sql
				EXEC (@sql)	
			END
			ELSE
			BEGIN
				SET @sql = 'SELECT 
								COUNT(*) AS TXNCOUNT
								,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
								,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
							FROM (' + @table + ') x'
				EXEC (@sql)
			
				SET @sql = '
					SELECT
						 [SN]	= [S.N]
						--,[Sender_Member ID]
						,[Sender_Name]
						,[Sender_Nationality]
						,[Sender_Id type]
						,[Sender_ID Number]
						,[Number of TXN]	
						,[Transaction_Amount]
						,[Transaction_Currency]
						,[Transaction_Payout Amount]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Number of TXN] DESC,senderName ) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		
				PRINT @sql
				EXEC (@sql)				
			END		
		END
		
		IF @mrType = 'sbmt' -->> Same Beneficiary Multiple TXNS
		BEGIN
			SET @URL='"Reports.aspx?dateType='+@dateType+'&frmDate='+@frmDate+'&toDate='+@toDate+'&sCountry='+ISNULL(replace(@sCountry,' ','__'),'')+'&sAgent='+ISNULL(@sAgent,'')
			+'&rMode='+ISNULL(REPLACE(@rMode,' ','__'),'')+'&rCountry='+ISNULL(replace(@rCountry,' ','__'),'')+'&rAgent='+ISNULL(@rAgent,'')
			+'&reportName=amlddlreport&isAdmin=Y&flag=sbmt_ddl&recName=''+ISNULL(REPLACE(rt.receiverName,'' '',''__''),'''')+''&country=''+ISNULL(rt.pCountry,'''')+''"'
			INSERT @FilterList
			SELECT 'Search By', 'Same Beneficiary Multiple TXNS Summary'
				
			SET @table = '
				SELECT			 
					 [Receiver''s_Name]					= rt.receiverName
					,[Receiver''s_Payout Country]		= ''<span class = "link" onclick =ViewAMLDDLReport('+@URL+');>'' +rt.pCountry + ''</span>''  
					,[Number of TXN]					= COUNT(*)			
					,[Payout_USD AMT]					= SUM(ISNULL(rt.tAmt / NULLIF(rt.sCurrCostRate, 0), 0))
					,[Payout_Currency]					= rt.payoutCurr 
					,[Payout_Amount]					= SUM(rt.pAmt)				
				FROM vwremitTran rt WITH(NOLOCK)
				LEFT JOIN vwtranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId	
				WHERE 1 = 1 
			'
			
			SET @table = @table + @globalFilter + ' 
			GROUP BY 			 
				 rt.receiverName
				,rt.pCountry
				,rt.payoutCurr
			HAVING COUNT(*) > 1
				'
				
			IF @isExportFull = 'Y'
			BEGIN				
				SET @sql = '
					SELECT
						 [Sno.]	= [S.N]
						,[Receiver''s_Name]
						,[Receiver''s_Payout Country]
						,[Number of TXN]	
						,[Payout_USD AMT]
						,[Payout_Currency]
						,[Payout_Amount]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Number of TXN] DESC) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp '
			
				PRINT @sql
				EXEC (@sql)
			END
			ELSE
			BEGIN
				SET @sql = 'SELECT 
								COUNT(*) AS TXNCOUNT
								,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
								,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
							FROM (' + @table + ') x'
				EXEC (@sql)
				
				SET @sql = '
					SELECT
						 [Sno.]	= [S.N]
						,[Receiver''s_Name]
						,[Receiver''s_Payout Country]
						,[Number of TXN]	
						,[Payout_USD AMT]
						,[Payout_Currency]
						,[Payout_Amount]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Number of TXN] DESC) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
			
				PRINT @sql
				EXEC (@sql)
			END					
		END	
			
		IF @mrType = 'sssb' -->> Same Sender to Same Beneficiary
		BEGIN		
			INSERT @FilterList
			SELECT 'Search By', 'Same Sender to Same Beneficiary'
			
			SET @table = '
				SELECT			 
				 [TXN No.]					= rt.id
				,[TXN Date]					= rt.createdDate
				,[Sender''s_Membership ID]	= ts.membershipId				
				,[Sender''s_Name]			= rt.senderName
				,[Sender''s_Nationality]	= ts.nativeCountry  
				,[Sender''s_ID Type]		= ts.idType 
				,[Sender''s_ID Number]		= ts.idNumber
				,[Number of TXN] = 1
				,[Receiver''s_Name]			= rt.receiverName
				,[Receiver''s_Payout Country]		= rt.pCountry
				
				,[Collection_USD AMT]		= SUM(ISNULL(rt.cAmt / (NULLIF(rt.sCurrCostRate, 0)+ISNULL(RT.scurrhomargin,0)), 0))
				,[Collection_Currency]		= rt.collCurr 
				,[Collection_Amount]		= rt.cAmt

				,[Payout_USD AMT]			= (ISNULL(rt.tAmt / NULLIF(rt.sCurrCostRate, 0), 0))
				,[Payout_Currency]			= rt.payoutCurr 
				,[Payout_Amount]			= (rt.pAmt)	
				,[Payout_Branch]			= rt.pBranchName	
				,[Posted By]				= rt.createdBy 
				
			FROM vwremitTran rt WITH(NOLOCK)
			LEFT JOIN vwtranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
			LEFT JOIN vwtranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
			WHERE 1 = 1 AND	rt.senderName =	rt.receiverName
			'		
			SET @table = @table + @globalFilter 
			IF @isExportFull = 'Y'
			BEGIN	
				SET @sql = '
					SELECT
						 [Sno.]	= [S.N]
						,[TXN No.] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([TXN No.] AS VARCHAR(50)) + '');">'' + CAST([TXN No.] AS VARCHAR(50)) + ''</span>''		
						,[TXN Date]
						,[Sender''s_Membership ID]
						,[Sender''s_Name]
						,[Sender''s_Nationality]
						,[Sender''s_Id type]
						,[Sender''s_ID Number]
						,[Receiver''s_Name]
						,[Receiver''s_Payout Country]
						,[Collection_USD AMT]
						,[Collection_Currency]
						,[Collection_Amount]
						,[Payout_USD AMT]
						,[Payout_Currency]
						,[Payout_Amount]
						,[Payout_Branch]	
						,[Posted By]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Number of TXN] DESC) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp ' 
				PRINT @sql
				EXEC (@sql)	
			END
			ELSE
			BEGIN
				SET @sql = 'SELECT 
								COUNT(*) AS TXNCOUNT
								,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
								,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
							FROM (' + @table + ') x'
				PRINT @sql
				EXEC (@sql)

				SET @sql = '
					SELECT
						 [Sno.]	= [S.N]
						,[TXN No.] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([TXN No.] AS VARCHAR(50)) + '');">'' + CAST([TXN No.] AS VARCHAR(50)) + ''</span>''		
						,[TXN Date]
						,[Sender''s_Membership ID]
						,[Sender''s_Name]
						,[Sender''s_Nationality]
						,[Sender''s_Id type]
						,[Sender''s_ID Number]
						,[Receiver''s_Name]
						,[Receiver''s_Payout Country]
						,[Collection_USD AMT]
						,[Collection_Currency]
						,[Collection_Amount]
						,[Payout_USD AMT]
						,[Payout_Currency]
						,[Payout_Amount]
						,[Payout_Branch]
						,[Posted By]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Number of TXN] DESC) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
				PRINT @sql
				EXEC (@sql)				
			END	
		END	
			
		IF @mrType = 'sncrc' -->> Sender's Native Country and Receiver's Country differs
		BEGIN
			INSERT @FilterList
			SELECT 'Search By', 'Sender''s Native Country and Receiver''s Country differs'
			
			SET @table = '
					SELECT			 
						 [TXN No.]					= rt.id
						,[TXN Date]					= rt.createdDate
						
						,[Sender''s_Name]			= rt.senderName
						,[Sender''s_Nationality]	= ts.nativeCountry  
						,[Sender''s_Id type]		= isnull(ts.idType,'''')+''-''+ isnull(ts.idNumber,'''')
						,[Number of TXN]			= 1
						,[Receiver''s_Name]				= rt.receiverName
						,[Receiver''s_Id type]			= isnull(tr.idType2,tr.idType)+''-''+ isnull(tr.idNumber2,tr.idNumber)
						,[Receiver''s_Payout Country]	= rt.pCountry
						
						,[Collection_USD AMT]		= (ISNULL(rt.cAmt / NULLIF(rt.sCurrCostRate, 0), 0))
						,[Collection_Currency]		= rt.collCurr 
						,[Collection_Amount]		= rt.cAmt

						,[Payout_USD AMT]			= (ISNULL(rt.tAmt / NULLIF(rt.sCurrCostRate, 0), 0))
						,[Payout_Currency]			= rt.payoutCurr 
						,[Payout_Amount]			= (rt.pAmt)	
						,[Receiver''s_Payout Branch]			= rt.pBranchName
						,[Posted By]				= rt.createdBy 	
				FROM vwremitTran rt WITH(NOLOCK)
				LEFT JOIN vwtranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				LEFT JOIN vwtranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId	
				WHERE REPLACE(ts.nativeCountry,''NPL'',''Nepal'')  <> rt.pCountry
			'
			
			SET @table = @table + @globalFilter 
				
			IF @isExportFull = 'Y'
			BEGIN				
				SET @sql = '
					SELECT
						 [Sno.]	= [S.N]
						,[TXN No.] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([TXN No.] AS VARCHAR(50)) + '');">'' +  CAST([TXN No.] AS VARCHAR(50)) + ''</span>''
						,[TXN Date]
						
						,[Sender''s_Name]
						,[Sender''s_Nationality]
						,[Sender''s_Id type]

						,[Receiver''s_Name]
						,[Receiver''s_Id type]
						,[Receiver''s_Payout Country]
						,[Receiver''s_Payout Branch]
						,[Collection_USD AMT]
						,[Collection_Currency]
						,[Collection_Amount]

						,[Payout_USD AMT]
						,[Payout_Currency]
						,[Payout_Amount]						
						,[Posted By]
						
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Sender''s_Name]) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp'
			
				PRINT @sql
				EXEC (@sql)	
			END
			ELSE
			BEGIN
				SET @sql = 'SELECT 
								COUNT(*) AS TXNCOUNT
								,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
								,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
							FROM (' + @table + ') x'
				PRINT @sql
				EXEC (@sql)
				
				SET @sql = '
					SELECT
						 [Sno.]	= [S.N]
						,[TXN No.] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([TXN No.] AS VARCHAR(50)) + '');">'' +  CAST([TXN No.] AS VARCHAR(50)) + ''</span>''
						,[TXN Date]
						,[Sender''s_Name]
						,[Sender''s_Nationality]
						,[Sender''s_Id type]

						,[Receiver''s_Name]
						,[Receiver''s_Id type]
						,[Receiver''s_Payout Country]
						,[Receiver''s_Payout Branch]
						,[Collection_USD AMT]
						,[Collection_Currency]
						,[Collection_Amount]

						,[Payout_USD AMT]
						,[Payout_Currency]
						,[Payout_Amount]
						,[Posted By]
					FROM (		
						SELECT 
							ROW_NUMBER() OVER (ORDER BY [Sender''s_Name]) AS [S.N],* 
						FROM (' + @table + ') x		
					) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
			
				PRINT @sql
				EXEC (@sql)	
			END	
		END

		IF @mrType = 'ssmtd' -->> Same Sender Multiple Txns
		BEGIN	
		
			INSERT @FilterList
			SELECT 'Search By', 'Same Sender Multiple TXN Detail'

			CREATE TABLE #SameSenderMultipleTxn(membershipId VARCHAR(50) ,senderName VARCHAR(200), nativeCountry VARCHAR(100), idType varchar(50),idNumber varchar(50))
			DECLARE @SUMMARYTBL VARCHAR(MAX)

			SET @SUMMARYTBL ='SELECT			 
				 membershipId = ts.membershipId
				,rt.SenderName
				,ts.nativecountry    
				,ts.idType  
				,ts.idNumber  
			FROM vwremitTran rt WITH(NOLOCK)
			LEFT JOIN agentMaster ams WITH(NOLOCK) ON rt.sBranch = ams.agentId
			LEFT JOIN vwtranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId	
			WHERE 1 = 1'
			SET @SUMMARYTBL = @SUMMARYTBL + @globalFilter + ' 
			GROUP BY 	
					ts.membershipId
				,rt.SenderName
				,ts.nativecountry
				,ts.idType
				,ts.idNumber
			HAVING COUNT(*) > 1'

			INSERT INTO #SameSenderMultipleTxn(membershipId,senderName,nativeCountry,idType,idNumber)
			EXEC (@SUMMARYTBL)

			SET @table ='
			SELECT 
				[S.N]					= ROW_NUMBER() OVER (ORDER BY RT.senderName),
				[TXN Date]				= RT.createdDate,
				[TXN No.]			    = ''<span class = "link" onclick ="ViewTranDetail('' + CAST(RT.id AS VARCHAR(50)) + '');">'' + CAST(RT.id AS VARCHAR) + ''</span>'',
				[Sender Name]			= upper(RT.senderName), 
				[Sender ID]				= isnull(ts.idType,'''')+''-''+ isnull(ts.idNumber,''''),	
				[Receiver Name]			= RT.receiverName,
				[Receiver ID]			= isnull(tr.idType2,tr.idType)+''-''+ isnull(tr.idNumber2,tr.idNumber),		
				[Receiving_Country]		= RT.pCountry,
				[Receiving_Branch]		= RT.pBranchName,
				[Receiving_Currency]	= RT.payoutCurr,
				[Receiving_Amount]		= RT.pAmt,
				
				[Collection_Currency]	= RT.collCurr,
				[Collection_Amount]		= '+CASE WHEN @flag='sbc_ddl' THEN 'RT.tAmt' ELSE 'RT.cAmt' END+',				
				[Sending_Country]		= RT.sCountry,
				[Sending_USD Amount]	= ('+CASE WHEN @flag='sbc_ddl' THEN 'RT.tAmt' ELSE 'RT.cAmt' END+'/RT.sCurrCostRate),
				[Sending_Agent]			= RT.sAgentName,
				[Sending_Branch]		= RT.sBranchName,
				[Sending_User]			= RT.createdBy
			FROM vwremitTran RT WITH (NOLOCK)
			inner JOIN vwtranSenders TS WITH (NOLOCK) ON RT.id=TS.tranId
			inner JOIN vwtranReceivers TR WITH (NOLOCK) ON RT.id=TR.tranId
			inner JOIN
			(
				select * from  #SameSenderMultipleTxn
			) temp1 on isnull(temp1.nativeCountry,'''') = isnull(TS.nativecountry,'''')
						and isnull(temp1.idType,'''') = isnull(TS.idType,'''') 
						and isnull(temp1.idNumber,'''') = isnull(TS.idNUmber,'''')
						and isnull(temp1.senderName,'''') = RT.senderName
			
			WHERE 1=1 '

			SET @table = @table + @globalFilter;
				
			IF @isExportFull = 'Y'
			BEGIN				
				SET @sql = '
					SELECT *
					FROM (		
						SELECT * 
						FROM (' + @table + ') x		
					) AS tmp '
			
				PRINT @sql
				EXEC (@sql)	
			END
			ELSE
			BEGIN
				SET @sql = 'SELECT 
								COUNT(*) AS TXNCOUNT
								,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
								,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
							FROM (' + @table + ') x'
				PRINT @sql
				EXEC (@sql)
				
				SET @sql = '
					SELECT *
					FROM (		
						SELECT * 
						FROM (' + @table + ') x		
					) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
			
				PRINT @sql
				EXEC (@sql)	
			END			
		END

		IF @mrType = 'sbmtd' -->> Same Beneficiary Multiple TXNS
		BEGIN

			INSERT @FilterList
			SELECT 'Search By', 'Same Beneficiary Multiple TXN Detail'
			CREATE TABLE #SameBeneficiaryMultipleTxn(receiverName VARCHAR(50) ,pCountry VARCHAR(200))
			DECLARE @SUMMARYTBL1 VARCHAR(MAX)

			SET @SUMMARYTBL1 ='SELECT			 
								 rt.receiverName
								,rt.pCountry		
							FROM vwremitTran rt WITH(NOLOCK)
							LEFT JOIN vwtranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId	
							WHERE 1 = 1'
			SET @SUMMARYTBL1 = @SUMMARYTBL1 + @globalFilter + ' 
							GROUP BY 			 
								 rt.receiverName
								,rt.pCountry
							HAVING COUNT(*) > 1'

			INSERT INTO #SameBeneficiaryMultipleTxn(receiverName,pCountry)
			EXEC (@SUMMARYTBL1)

			SET @table ='
			SELECT 
				[S.N]					= ROW_NUMBER() OVER (ORDER BY RT.receiverName),
				[TXN Date]				= RT.createdDate,
				[TXN No.]			    = ''<span class = "link" onclick ="ViewTranDetail('' + CAST(RT.id AS VARCHAR(50)) + '');">'' + CAST(RT.id AS VARCHAR) + ''</span>'',
				[Receiver Name]			= UPPER(RT.receiverName),
				[Sender Name]			= UPPER(RT.senderName),				
				[Receiver ID]			= isnull(tr.idType2,tr.idType)+''-''+ isnull(tr.idNumber2,tr.idNumber),					
				[Sending_Country]		= RT.sCountry,
				[Sending_Agent]			= RT.sAgentName,
				[Sending_Branch]		= RT.sBranchName,
				[Sending_User]			= RT.createdBy,
				[USD Amount]			= ('+CASE WHEN @flag='sbc_ddl' THEN 'RT.tAmt' ELSE 'RT.cAmt' END+'/RT.sCurrCostRate),
				[Collection_Currency]	= RT.collCurr,
				[Collection_Amount]		= '+CASE WHEN @flag='sbc_ddl' THEN 'RT.tAmt' ELSE 'RT.cAmt' END+',
				[Receiving_Currency]	= RT.payoutCurr,
				[Receiving_Amount]		= RT.pAmt,
				[Receiving_Branch]		= RT.pBranchName,
				[Receiving_Country]		= RT.pCountry
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN vwtranSenders TS WITH (NOLOCK) ON RT.id=TS.tranId
			INNER JOIN vwtranReceivers TR WITH (NOLOCK) ON RT.id=TR.tranId
			INNER JOIN
			(
				SELECT * FROM #SameBeneficiaryMultipleTxn
			) temp1 on isnull(temp1.receiverName,'''') = isnull(RT.receiverName,'''')
						and isnull(temp1.pCountry,'''') = isnull(RT.pCountry,'''') 
			WHERE 1=1 '	
			SET @table = @table + @globalFilter;
				
			IF @isExportFull = 'Y'
			BEGIN				
				SET @sql = '
					SELECT *
					FROM (		
						SELECT * 
						FROM (' + @table + ') x		
					) AS tmp '
			
				PRINT @sql
				EXEC (@sql)	
			END
			ELSE
			BEGIN
				SET @sql = 'SELECT 
								COUNT(*) AS TXNCOUNT
								,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
								,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
							FROM (' + @table + ') x'
				PRINT @sql
				EXEC (@sql)
				
				SET @sql = '
					SELECT *
					FROM (		
						SELECT * 
						FROM (' + @table + ') x		
					) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
			
				PRINT @sql
				EXEC (@sql)	
			END			
		END	
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	  
	SELECT * FROM @FilterList	   
	SELECT 'AML Reports : '+@reportHead title

END TRY

BEGIN CATCH
	 IF @@TRANCOUNT > 0
	 ROLLBACK TRANSACTION
	 DECLARE @errorMessage VARCHAR(MAX)
	 SET @errorMessage = ERROR_MESSAGE()
	 EXEC proc_errorHandler 1, @errorMessage ,NULL 
END CATCH


GO
