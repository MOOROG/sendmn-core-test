USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnDocumentReport]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_txnDocumentReport]
	 @functionID		VARCHAR(100)
	,@user				VARCHAR(30)
	,@pageFrom			INT
	,@pageTo			INT
	,@branch			INT
	,@agent				INT	
	,@fxml				XML = NULL
	,@qxml				XML = NULL
	,@dxml				XML = NULL
	,@downloadAll		CHAR(1) = NULL
AS

SET NOCOUNT ON
SET @pageFrom = ISNULL(NULLIF(@pageFrom, 0), 1)
SET @pageTo = ISNULL(@pageTo, @pageFrom)
DECLARE @pageSize INT = 50

DECLARE @f1 VARCHAR(500), @f2 VARCHAR(500), @q1 VARCHAR(500),  @d1 VARCHAR(500) ,  @d2 VARCHAR(500),@d3 VARCHAR(500)

DECLARE @country VARCHAR(50),@agentId INT,@branchId INT,@fromDate VARCHAR(10),@toDate VARCHAR(10),
		@hdnrootUrl VARCHAR(500),@agentName VARCHAR(250),@branchName VARCHAR(250)

DECLARE @grandTotal VARCHAR(2000),@filter VARCHAR(1000)

 SELECT
			 @country = p.value('@country','VARCHAR(50)')
			,@agentId = p.value('@agent','VARCHAR(250)')		
			,@branchId = p.value('@branch','VARCHAR(100)')		
			,@fromDate = p.value('@fromdate','VARCHAR(100)')		
			,@toDate = p.value('@todate','VARCHAR(100)')
			,@hdnrootUrl = p.value('@hdnrooturl','VARCHAR(500)')		
		FROM @fxml.nodes('/root/row') AS tmp(p)
		


	IF ISNULL(@toDate,'')=''
		SET @toDate=@fromDate

		
	SELECT @country=countryName FROM countryMaster WHERE countryId=@country
	
	
	SET @filter = 'Country = ' + @country
	  +' | Agent = ' + (SELECT agentName FROM agentmaster WHERE agentId=@agentId)	  
	  +' | Branch = ' +  CASE WHEN isnull(@branchId,'')='' THEN 'All' ELSE (SELECT agentName FROM agentmaster WHERE agentId=@branchId) END
	  +' | From Date =' +@fromDate
	  +' | To Date =' +@toDate
	  
	--print @fromDate+' '+@toDate+' '+ @country	

IF @functionID = '20168400'
BEGIN

		SELECT 
		--[Create Date]=y.createdDate,
		--[Agent]=y.sAgent,
		[Agent Name]=y.sAgentName,
		--[Branch]=y.sBranch,
		[Branch Name]=y.sBranchName,
		[No. Of Txn]='<span style="cursor:pointer;color:blue;" onclick="DrillDown(''20168400-d1'',''' + CAST(y.sAgent AS VARCHAR) + '|'+ CAST(y.sBranch AS VARCHAR) + ''');">' + CAST(y.txn AS VARCHAR) + '</span>',
		[Form Uploaded]='<span style="cursor:pointer;color:blue;" onclick="DrillDown(''20168400-d2'',''' + CAST(y.sAgent AS VARCHAR) + '|'+ CAST(y.sBranch AS VARCHAR) + ''');">' + CAST(y.form AS VARCHAR) + '</span>',
		[Receipt Uploaded]='<span style="cursor:pointer;color:blue;" onclick="DrillDown(''20168400-d3'',''' + CAST(y.sAgent AS VARCHAR) + '|'+ CAST(y.sBranch AS VARCHAR) + ''');">' + CAST(y.receipt AS VARCHAR) + '</span>',
		[Remaining Form]='<span style="cursor:pointer;color:blue;" onclick="DrillDown(''20168400-d4'',''' + CAST(y.sAgent AS VARCHAR) + '|'+ CAST(y.sBranch AS VARCHAR) + ''');">' + CAST((txn-form) AS VARCHAR) + '</span>',
		[Remaining Receipt]= '<span style="cursor:pointer;color:blue;" onclick="DrillDown(''20168400-d5'',''' + CAST(y.sAgent AS VARCHAR) + '|'+ CAST(y.sBranch AS VARCHAR) + ''');">' + CAST((txn-receipt) AS VARCHAR) + '</span>'  
		FROM (
				SELECT  ROW_NUMBER() OVER (ORDER BY x.sAgent ASC) row_Id,
				COUNT(tranId) txn,SUM(ISNULL(x.form,0)) form,SUM(ISNULL(x.receipt,0)) receipt,x.sAgent,x.sAgentName,x.sBranch,x.sBranchName--,x.createdDate 
				FROM (			
						SELECT tr.id tranId
						,du.form
						,du.receipt
						,tr.sAgent,sAgentName,sBranch,sBranchName,tr.createdDate
						FROM vwRemitTran tr
						LEFT JOIN (
						SELECT SUM(form) form,SUM(receipt) receipt,tranId FROM (
							SELECT 
							CASE WHEN du.fileType='form' THEN 1 ELSE 0 END AS form
							,CASE WHEN du.fileType='receipt' THEN 1 ELSE 0 END AS receipt
							,tranId
							FROM txnDocUpload du
							)a GROUP BY tranId
						)du  ON du.tranId=tr.id
						--txnDocUpload du on du.tranId=tr.id
						WHERE tr.createdDate between @fromDate and @toDate+' 23:59:59'
						and tr.sCountry=ISNULL(@country,tr.sCountry)
						and tr.sAgent=ISNULL(@agentId,tr.sAgent)
						and tr.sBranch=ISNULL(@branchId,tr.sBranch)
					)x 
			GROUP BY x.sAgent,x.sAgentName,x.sBranch,x.sBranchName--,x.createdDate
		)y
		WHERE y.row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize

	

	UPDATE #params SET 
		ReportTitle='Txn Document Upload Report'
		,Filters= @filter
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END
		--,FieldAlignment = '|L|R|R|R'
		--,FieldFormat = '||N|N|N'
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize
		--,TotalTextCol = 0
		--,TotalText ='<b>Total</b>'
		--,TotalFields ='2|3|4'

		,LoadMode = 1
		--,MergeColumnHead=1

		--,HasGrandTotal =0
		--,GTotalText='[Grand Total]'
		--,GTData = @grandTotal

	SELECT * FROM #params

RETURN
END

IF @functionID = '20168400-d1'
BEGIN	
		
	SELECT
		 @q1 = p.value('@q1','VARCHAR(20)')				
	FROM @qxml.nodes('/root/row') AS tmp(p)
	
	
	SELECT
		 @d1 = p.value('@d1','VARCHAR(20)')
		 ,@d2 =p.value('@d2','VARCHAR(20)')
		 --,@d3 =p.value('@d3','VARCHAR(20)')
	FROM @dxml.nodes('/root/row') AS tmp(p)	

	
	
	
			SELECT 
				[Tran No]=x.tranId
				,[Sender Name]=x.senderName
				,[Sender ID]=x.Id
				,[Receiver Name]=x.receiverName
				,[Form]= '<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.form+'&df='+x.txnDocFolder+'" target="_blank">' + x.form + '</a>'				
				,[Receipt]='<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.receipt+'&df='+x.txnDocFolder+'" target="_blank">' + x.receipt + '</a>'
		
				FROM (
						SELECT 
							ROW_NUMBER() OVER (ORDER BY tr.id ASC) row_Id,
							tr.id tranId,tr.senderName,ts.customerId as Id,tr.receiverName, du.receipt, du.form ,du.txnDocFolder
						FROM vwRemitTran tr
						INNER JOIN vwTranSenders ts ON tr.id=ts.tranId	
						LEFT JOIN (
							SELECT 
								MAX(form) form,MAX(receipt) receipt,tranId,MAX(txnDocFolder) txnDocFolder
							FROM (
								SELECT 
									CASE WHEN du.fileType='form' THEN [fileName] ELSE '' END AS form
									,CASE WHEN du.fileType='receipt' THEN [fileName] ELSE '' END AS receipt
									,tranId
									,ISNULL(txnDocFolder,'') AS txnDocFolder
								FROM txnDocUpload du
							)a GROUP BY tranId
						)du  on du.tranId=tr.id
												
						WHERE tr.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
						AND tr.sCountry=ISNULL(@country,tr.sCountry)
						AND tr.sAgent=@d1
						AND tr.sBranch=@d2
										
				)x 
				

						
				WHERE x.row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
		
		----------------------
	
	
	SET @agentName= (SELECT agentName FROM agentmaster WHERE agentId=@d1)
	SET @branchName= (SELECT agentName FROM agentmaster WHERE agentId=@d2)
	--set @filter = 'Country = ' + isnull(@country,'All')
	-- +' | Agent = '+@d1
	-- +' | Branch = ' + @d2
	-- +' | Date =' +@d3
	

	UPDATE #params SET 
		ReportTitle='Txn Document Upload Report Drilldown ' + ISNULL('-' + @agentName, '') + ISNULL('-' + @branchName, '') 
		,Filters= @filter
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END
		,FieldAlignment = '||||||'
		,FieldFormat ='||||||'
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize		
		--,TotalTextCol = 0
		--,TotalText ='<b>Total</b>'
		--,TotalFields ='5|6|7'

		--,SubTotalBy = 0
		--,SubTotalTextCol =0
		--,SubTotalText ='<b>Country Total</b>'
		--,SubTotalFields ='5|6|7'


		--,HasGrandTotal =1
		--,GTotalText='[Grand Total]'
		--,GTData = @grandTotal

		,LoadMode = 1
		--,MergeColumnHead=1

	SELECT * FROM #params

RETURN
END

ELSE IF @functionID = '20168400-d2'
BEGIN	
		
	SELECT
		 @q1 = p.value('@q1','VARCHAR(20)')				
	FROM @qxml.nodes('/root/row') AS tmp(p)
	
	
	SELECT
		 @d1 = p.value('@d1','VARCHAR(20)')
		 ,@d2 =p.value('@d2','VARCHAR(20)')
		 --,@d3 =p.value('@d3','VARCHAR(20)')
	FROM @dxml.nodes('/root/row') AS tmp(p)	

	
	
	
			SELECT 
				[Tran No]=x.tranId
				,[Sender Name]=x.senderName
				,[Sender ID]=x.Id
				,[Receiver Name]=x.receiverName				
				,[Form]= '<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.form+'&df='+x.txnDocFolder+'" target="_blank">' + x.form + '</a>' 				
				,[Receipt]='<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.receipt+'&df='+x.txnDocFolder+'" target="_blank">' + x.receipt + '</a>'	
				FROM (
						SELECT 
							ROW_NUMBER() OVER (ORDER BY tr.id ASC) row_Id,
							tr.id tranId,tr.senderName,ts.customerId as Id,tr.receiverName,du.receipt, du.form,du.txnDocFolder
						FROM vwRemitTran tr
						INNER JOIN vwTranSenders ts on tr.id=ts.tranId	
						--LEFT JOIN txnDocUpload du on du.tranId=tr.id						
						LEFT JOIN (
							SELECT 
								MAX(form) form,MAX(receipt) receipt,tranId,MAX(txnDocFolder) txnDocFolder
							FROM (
								SELECT 
									CASE WHEN du.fileType='form' THEN [fileName] ELSE '' END AS form
									,CASE WHEN du.fileType='receipt' THEN [fileName] ELSE '' END AS receipt
									,tranId
									,ISNULL(txnDocFolder,'') AS txnDocFolder
								FROM txnDocUpload du
							)a GROUP BY tranId
						)du  ON du.tranId=tr.id
											 						
						WHERE tr.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
						AND tr.sCountry=isnull(@country,tr.sCountry)
						AND tr.sAgent=@d1
						AND tr.sBranch=@d2			
						AND form<>''					
				)x 
		WHERE x.row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
		
		----------------------
	
	
	
	
	--SET @filter = 'Country = ' + isnull(@country,'All')
	-- +' | Agent = '+@d1
	-- +' | Branch = ' + @d2
	-- +' | Date =' +@d3
	SET @agentName= (SELECT agentName FROM agentmaster WHERE agentId=@d1)
	SET @branchName= (SELECT agentName FROM agentmaster WHERE agentId=@d2)

	UPDATE #params SET 
		ReportTitle='Txn Document Upload Report Drilldown ' + ISNULL('-' + @agentName, '') + ISNULL('-' + @branchName, '') 
		,Filters= @filter
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END
		,FieldAlignment = '||||||'
		,FieldFormat ='||||||'
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize		
		--,TotalTextCol = 0
		--,TotalText ='<b>Total</b>'
		--,TotalFields ='5|6|7'

		--,SubTotalBy = 0
		--,SubTotalTextCol =0
		--,SubTotalText ='<b>Country Total</b>'
		--,SubTotalFields ='5|6|7'


		--,HasGrandTotal =1
		--,GTotalText='[Grand Total]'
		--,GTData = @grandTotal

		,LoadMode = 1
		--,MergeColumnHead=1

	SELECT * FROM #params

RETURN
END

ELSE IF @functionID = '20168400-d3'
BEGIN	
		
	SELECT
		 @q1 = p.value('@q1','VARCHAR(20)')				
	FROM @qxml.nodes('/root/row') AS tmp(p)
	
	
	SELECT
		 @d1 = p.value('@d1','VARCHAR(20)')
		 ,@d2 =p.value('@d2','VARCHAR(20)')
		 --,@d3 =p.value('@d3','VARCHAR(20)')
	FROM @dxml.nodes('/root/row') AS tmp(p)	

	
	
	
			SELECT 
				[Tran No]=x.tranId
				,[Sender Name]=x.senderName
				,[Sender ID]=x.Id
				,[Receiver Name]=x.receiverName				
				,[Form]= '<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.form+'&df='+x.txnDocFolder+'" target="_blank">' + x.form + '</a>' 				
				,[Receipt]='<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.receipt+'&df='+x.txnDocFolder+'" target="_blank">' + x.receipt + '</a>'			
				FROM (
						SELECT 
							ROW_NUMBER() OVER (ORDER BY tr.id ASC) row_Id,
							tr.id tranId,tr.senderName,ts.customerId as Id,tr.receiverName,du.receipt, du.form,du.txnDocFolder
						FROM vwRemitTran tr
						INNER JOIN vwTranSenders ts on tr.id=ts.tranId	
						--LEFT JOIN txnDocUpload du on du.tranId=tr.id						 						
						LEFT JOIN (
							SELECT 
								MAX(form) form,MAX(receipt) receipt,tranId ,MAX(txnDocFolder) txnDocFolder
							FROM (
								SELECT 
									CASE WHEN du.fileType='form' THEN [fileName] ELSE '' END AS form
									,CASE WHEN du.fileType='receipt' THEN [fileName] ELSE '' END AS receipt
									,tranId
									,ISNULL(txnDocFolder,'') AS txnDocFolder
								FROM txnDocUpload du
							)a GROUP BY tranId
						)du  ON du.tranId=tr.id
						
						WHERE tr.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
						AND tr.sCountry=ISNULL(@country,tr.sCountry)
						AND tr.sAgent=@d1
						AND tr.sBranch=@d2
						AND receipt<>''							
				)x 
		WHERE x.row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
		
		----------------------
	
	
	
	
	--set @filter = 'Country = ' + isnull(@country,'All')
	-- +' | Agent = '+@d1
	-- +' | Branch = ' + @d2
	-- +' | Date =' +@d3
	
	SET @agentName= (SELECT agentName FROM agentmaster WHERE agentId=@d1)
	SET @branchName= (SELECT agentName FROM agentmaster WHERE agentId=@d2)

	UPDATE #params SET 
		ReportTitle='Txn Document Upload Report Drilldown ' + ISNULL('-' + @agentName, '') + ISNULL('-' + @branchName, '') 
		,Filters= @filter
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END
		,FieldAlignment = '||||||'
		,FieldFormat ='||||||'
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize		
		--,TotalTextCol = 0
		--,TotalText ='<b>Total</b>'
		--,TotalFields ='5|6|7'

		--,SubTotalBy = 0
		--,SubTotalTextCol =0
		--,SubTotalText ='<b>Country Total</b>'
		--,SubTotalFields ='5|6|7'


		--,HasGrandTotal =1
		--,GTotalText='[Grand Total]'
		--,GTData = @grandTotal

		,LoadMode = 1
		--,MergeColumnHead=1

	SELECT * FROM #params

RETURN
END

ELSE IF @functionID = '20168400-d4'
BEGIN	
		
	SELECT
		 @q1 = p.value('@q1','VARCHAR(20)')				
	FROM @qxml.nodes('/root/row') AS tmp(p)
	
	
	SELECT
		 @d1 = p.value('@d1','VARCHAR(20)')
		 ,@d2 =p.value('@d2','VARCHAR(20)')
		 --,@d3 =p.value('@d3','VARCHAR(20)')
	FROM @dxml.nodes('/root/row') AS tmp(p)	

	
	
	
			SELECT 
				[Tran No]=x.tranId
				,[Sender Name]=x.senderName
				,[Sender ID]=x.Id
				,[Receiver Name]=x.receiverName				
				,[Form]= '<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.form+'&df='+x.txnDocFolder+'" target="_blank">' + x.form + '</a>' 				
				,[Receipt]='<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.receipt+'&df='+x.txnDocFolder+'" target="_blank">' + x.receipt + '</a>'			
				FROM (
						SELECT 
							ROW_NUMBER() OVER (ORDER BY tr.id ASC) row_Id,
							tr.id tranId,tr.senderName,ts.customerId AS Id,tr.receiverName,form,receipt,du.txnDocFolder
						FROM vwRemitTran tr
						INNER JOIN vwTranSenders ts ON tr.id=ts.tranId
						--LEFT JOIN (
						--			select 
						--			tranId,					
						--			from txnDocUpload du  where fileType='form'
						--)du	on du.tranId=tr.id
						
						LEFT JOIN (
							SELECT 
								MAX(form) form,MAX(receipt) receipt,tranId,MAX(txnDocFolder) txnDocFolder
							FROM (
								SELECT 
									CASE WHEN du.fileType='form' THEN [fileName] ELSE '' END AS form
									,CASE WHEN du.fileType='receipt' THEN [fileName] ELSE '' END AS receipt
									,tranId
									,ISNULL(txnDocFolder,'') AS txnDocFolder
								FROM txnDocUpload du WHERE fileType='form'
							)a GROUP BY tranId
						)du  ON du.tranId=tr.id
									 						
						WHERE tr.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
						AND tr.sCountry=ISNULL(@country,tr.sCountry)
						AND tr.sAgent=@d1
						AND tr.sBranch=@d2
						AND du.tranId IS NULL		
				)x 
		WHERE x.row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
		
		----------------------
	
	
	
	
	--set @filter = 'Country = ' + isnull(@country,'All')
	-- +' | Agent = '+@d1
	-- +' | Branch = ' + @d2
	-- +' | Date =' +@d3
	
	SET @agentName= (SELECT agentName FROM agentmaster WHERE agentId=@d1)
	SET @branchName= (SELECT agentName FROM agentmaster WHERE agentId=@d2)

	UPDATE #params SET 
		ReportTitle='Txn Document Upload Report Drilldown ' + ISNULL('-' + @agentName, '') + ISNULL('-' + @branchName, '') 
		,Filters= @filter
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END
		,FieldAlignment = '||||||'
		,FieldFormat ='||||||'
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize		
		--,TotalTextCol = 0
		--,TotalText ='<b>Total</b>'
		--,TotalFields ='5|6|7'

		--,SubTotalBy = 0
		--,SubTotalTextCol =0
		--,SubTotalText ='<b>Country Total</b>'
		--,SubTotalFields ='5|6|7'


		--,HasGrandTotal =1
		--,GTotalText='[Grand Total]'
		--,GTData = @grandTotal

		,LoadMode = 1
		--,MergeColumnHead=1

	SELECT * FROM #params

RETURN
END

ELSE IF @functionID = '20168400-d5'
BEGIN	
		
	SELECT
		 @q1 = p.value('@q1','VARCHAR(20)')				
	FROM @qxml.nodes('/root/row') AS tmp(p)
	
	
	SELECT	
		 @d1 = p.value('@d1','VARCHAR(20)')
		 ,@d2 =p.value('@d2','VARCHAR(20)')
		 --,@d3 =p.value('@d3','VARCHAR(20)')
	FROM @dxml.nodes('/root/row') AS tmp(p)	

	
	
	
			SELECT 
				[Tran No]=x.tranId
				,[Sender Name]=x.senderName
				,[Sender ID]=x.Id
				,[Receiver Name]=x.receiverName
			
				,[Form]= '<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.form+'&df='+x.txnDocFolder+'" target="_blank">' + x.form + '</a>' 				
				,[Receipt]='<a href="'+@hdnrootUrl+'/img.ashx?type=txn&id='+x.receipt+'&df='+x.txnDocFolder+'" target="_blank">' + x.receipt + '</a>'			
				FROM (
						SELECT 
							ROW_NUMBER() OVER (ORDER BY tr.id ASC) row_Id,
							tr.id tranId,tr.senderName,ts.customerId as Id,tr.receiverName,form,receipt,du.txnDocFolder
						FROM vwRemitTran tr
						INNER JOIN vwTranSenders ts on tr.id=ts.tranId	
						--LEFT JOIN (
						--select tranId
						--	from txnDocUpload  where fileType='receipt'
						--)du	on du.tranId=tr.id
						LEFT JOIN (
							SELECT 
								MAX(form) form,MAX(receipt) receipt,tranId,MAX(txnDocFolder) txnDocFolder 
							FROM (
								SELECT 
									CASE WHEN du.fileType='form' THEN [fileName] ELSE '' END AS form
									,CASE WHEN du.fileType='receipt' THEN [fileName] ELSE '' END AS receipt
									,tranId
									,ISNULL(txnDocFolder,'') AS txnDocFolder
								FROM txnDocUpload du WHERE fileType='receipt'
							)a GROUP BY tranId
						)du  ON du.tranId=tr.id
									 						
						WHERE tr.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
						AND tr.sCountry=ISNULL(@country,tr.sCountry)
						AND tr.sAgent=@d1
						AND tr.sBranch=@d2
						AND du.tranId IS NULL	 		
				)x 
		WHERE x.row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
		
		----------------------
	
	
	
	
	--set @filter = 'Country = ' + isnull(@country,'All')
	-- +' | Agent = '+@d1
	-- +' | Branch = ' + @d2
	-- +' | Date =' +@d3
	SET @agentName= (SELECT agentName FROM agentmaster WHERE agentId=@d1)
	SET @branchName= (SELECT agentName FROM agentmaster WHERE agentId=@d2)

	UPDATE #params SET 
		ReportTitle='Txn Document Upload Report Drilldown ' + ISNULL('-' + @agentName, '') + ISNULL('-' + @branchName, '') 
		,Filters= @filter
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END
		,FieldAlignment = '||||||'
		,FieldFormat ='||||||'
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize		
		--,TotalTextCol = 0
		--,TotalText ='<b>Total</b>'
		--,TotalFields ='5|6|7'

		--,SubTotalBy = 0
		--,SubTotalTextCol =0
		--,SubTotalText ='<b>Country Total</b>'
		--,SubTotalFields ='5|6|7'


		--,HasGrandTotal =1
		--,GTotalText='[Grand Total]'
		--,GTData = @grandTotal

		,LoadMode = 1
		--,MergeColumnHead=1

	SELECT * FROM #params

RETURN
END



GO
