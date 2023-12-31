USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_gbilSearchTxn]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_gbilSearchTxn](
	 @flag				VARCHAR(10)			= NULL
	,@user				VARCHAR(20)			= NULL
	,@fromDate			VARCHAR(40)			= NULL  
	,@toDate			VARCHAR(40)			= NULL 
	,@searchBy			VARCHAR(10)			= NULL
	,@searchValue		VARCHAR(50)			= NULL   
	,@sortBy			VARCHAR(50)			= NULL
	,@sortOrder			VARCHAR(5)			= NULL
	,@pageSize			INT					= NULL
	,@pageNumber		INT					= NULL
)AS

IF @flag='rpt'
BEGIN
		
	DECLARE @sql VARCHAR(MAX)
	SET @sql= 
			'SELECT 
				[S.N.] = row_number()over(order by rt.id),
				[IME Control No] = dbo.FNADecryptString(rt.controlNo),
				[Sender Name] = rt.senderName,
				[Receiver Name] = rt.receiverName,
				[Payout Amount] = rt.pAmt,
				[TXN Date] = rt.createdDate,
				[Sending Agent] =rt.sBranchName,
				[Receiving Agent] = rt.pBranchName
			FROM remitTran rt WITH(NOLOCK) 
				WHERE rt.createdDate between '''+@fromDate+''' AND '''+@toDate+'''
				AND rt.tranType = ''D'''


		IF @searchBy ='sName'
			SET @sql = @sql+' AND rt.senderName LIKE '''+@searchValue+'%'''
			
		IF @searchBy ='rName'
			SET @sql = @sql+' AND rt.receiverName LIKE '''+@searchValue+'%'''

		IF @searchBy ='icn'
			SET @sql = @sql+' AND rt.controlNo = '''+ dbo.FNAEncryptString(@searchValue)+''''
		
		print(@sql)
		EXEC(@sql)

		SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id	
		SELECT 'Date Range' head,@fromDate+'-'+@toDate VALUE UNION ALL 
		SELECT 'Search By' head, case when @searchBy ='sName' then 'Sender Name' when @searchBy = 'rName' then 'Receiver Name' else 'IME Control Number' end VALUE UNION ALL
		SELECT 'Search Value' head,@searchValue VALUE 

		SELECT 'Search Transaction  Report' title	
END


GO
