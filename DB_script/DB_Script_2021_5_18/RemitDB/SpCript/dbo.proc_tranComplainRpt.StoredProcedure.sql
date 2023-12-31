USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranComplainRpt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_tranComplainRpt]
     @flag				VARCHAR(50)
	,@tranId			VARCHAR(50)		= NULL	
	,@controlNo			VARCHAR(50)		= NULL
	,@complainUser		VARCHAR(200)	= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@searchBy			VARCHAR(100)	= NULL
	,@msgType			VARCHAR(100)	= NULL
	,@txnType			VARCHAR(100)	= NULL
	,@paymentMethod		VARCHAR(100)	= NULL
	,@status			VARCHAR(50)		= NULL
	,@reportType		VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL

AS
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @controlNoEncrypted VARCHAR(100)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	
	SELECT @pageSize = 10, @pageNumber = 1
	
	declare @sql as varchar(max),@rptBy as varchar(50)
	DECLARE 
			 @select_field_list VARCHAR(MAX)
			,@extra_field_list  VARCHAR(MAX)
			,@table             VARCHAR(MAX)
			,@sql_filter        VARCHAR(MAX)
	
	
		
		
IF @flag = 'a'
BEGIN
	SET @SQL='SELECT 
					RT.sCountry [COUNTRY],
					RT.sBranchName [AGENT],
					TM.tranId [TRAN ID],		
					[CONTROL NO]=''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(RT.controlNo) + '''''')">'' + dbo.FNADecryptString(RT.controlNo) + ''</a>'',	
					[COMPLAIN] = TM.MESSAGE,
					TM.status [STATUS],
					RT.paymentMethod [TRAN TYPE],
					TM.createdBy [USER],
					CONVERT(VARCHAR,TM.createdDate,107) [DATE]					
		FROM tranModifyLog TM WITH(NOLOCK)
		INNER JOIN remitTran RT WITH(NOLOCK) ON TM.tranId=RT.id
		INNER JOIN applicationUsers AU WITH(NOLOCK) ON AU.userName=TM.createdBy 
		INNER JOIN agentMaster AM WITH(NOLOCK) ON AM.agentId = AU.agentId'			
	
		SET @sql=@sql+ ' WHERE TM.createdDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'+''''
			
		IF @msgType ='O'
			SET @sql=@sql+ ' AND ISNULL(MsgType,''O'') NOT IN (''C'',''M'',''MODIFY'')'

		IF @msgType ='M'
			SET @sql=@sql+ ' AND MsgType IN (''M'',''MODIFY'')'
			
		IF @msgType = 'C'
			SET @sql=@sql+ ' AND MsgType ='''+@msgType+''''	
				
		IF @paymentMethod IS NOT NULL
			SET @sql=@sql+ ' AND RT.paymentMethod='''+@paymentMethod+''''	
				
		IF @status IS NOT NULL
			SET @sql=@sql+ ' AND status='''+@status+''''
				
		IF @searchBy ='Head Office'
			SET @sql=@sql+ ' AND au.agentId = 1001'
			
		IF @searchBy ='Agent'
			SET @sql=@sql+ ' AND au.agentId<>1001'

		IF @txnType = 'D'
			SET @sql=@sql+ ' AND RT.sCountry = ''Nepal'''
		
		IF @txnType = 'I'
			SET @sql=@sql+ ' AND RT.sCountry <> ''Nepal'''
						
		SET @sql=@sql+ ' ORDER BY TM.createdDate DESC'				
			
		PRINT (@SQL)
		EXEC(@sql)

			
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) VALUE
		UNION ALL
		SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) VALUE
		UNION ALL
		SELECT 'TXN Type' head, case when @txnType ='D' then 'Domestic' else 'International' end VALUE
		UNION ALL
		SELECT 'Payment Method' head,ISNULL(@paymentMethod,'All') VALUE
		UNION ALL
		SELECT 'Ticket By' head,ISNULL(@searchBy,'All') VALUE
		UNION ALL
		SELECT 'Msg Type' head, case when @msgType = 'C' then 'Complain' when @msgType in ('M','Modify') then 'Modify' when @msgType = 'O' then 'Other' else 'All' end VALUE
		UNION ALL
		SELECT 'Msg Status' head,ISNULL(@status,'All') VALUE
		
		SELECT 'Transaction Complain (Trouble Ticket) View Log' title
END

IF @flag = 's'				
BEGIN	
	SET @table = '(
		select  
				id=TM.rowid,
				tranId=TM.tranId,
				controlNo=''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(RT.controlNo) + '''''')">'' + dbo.FNADecryptString(RT.controlNo) + ''</a>'',
				complainType=isnull(TM.MsgType,''Others''),
				userAgent=AM.agentName,
				complainUser=TM.createdBy,
				complainDate=TM.createdDate,
				remarks=message 
					
		from tranModifyLog TM WITH(NOLOCK)
		inner join remitTran RT WITH(NOLOCK) ON TM.tranId = RT.id-- or rt.controlNo = tm.controlNo)
		left join applicationUsers AU WITH(NOLOCK) on AU.userName=TM.createdBy 
		left join agentMaster AM WITH(NOLOCK) ON AM.agentId=AU.agentId	
		where [status] =''Not Resolved''
		AND TM.MsgType = ''c''
			'
	
	SET @sql_filter = ''
	
		 
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND RT.controlNo = ''' + @controlNoEncrypted + '''' 
		
	IF @complainUser IS NOT NULL
		SET @table = @table + ' AND TM.createdBy LIKE ''%' + @complainUser + '%'''
	
			
	SET @select_field_list ='
				 id
				,tranId
				,controlNo
				,complainType
				,userAgent
				,complainUser
				,complainDate
				,remarks				
			   '
	SET @table = @table + ') x'
		
		--select @table
		--return;	
	EXEC dbo.proc_paging
            @table
           ,@sql_filter
           ,@select_field_list
           ,@extra_field_list
           ,@sortBy
           ,@sortOrder
           ,@pageSize
           ,@pageNumber
END

IF @flag='rc'
BEGIN
	
	SET @sql = 'UPDATE tranModifyLog SET 
					 status = ''Resolved''
					 ,resolvedBy='''+@user+'''
					 ,resolvedDate='''+cast(GETDATE() as varchar)+'''
				WHERE rowId IN (' + @tranId + ')
				'	
	EXEC(@sql)	
	
	EXEC proc_errorHandler 0, 'Complain (Trouble Ticket) Solved Successfully.', NULL
END


IF @flag='tranAccessRpt'
BEGIN
	
	SELECT id,tranViewType,agentId,createdBy,createdDate,tranId,remarks FROM tranViewHistory A WITH(NOLOCK) 
	WHERE A.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59' AND 
	ISNULL(tranViewType,'A')=ISNULL(@reportType,ISNULL(tranViewType,'A'))	
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value
	UNION ALL
	SELECT 'Report Type' head, ISNULL(@reportType,'All') value

	SELECT 'Transaction Access Report' title

END

GO
