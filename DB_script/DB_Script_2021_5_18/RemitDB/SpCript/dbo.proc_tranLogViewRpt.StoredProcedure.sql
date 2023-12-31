USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranLogViewRpt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_tranLogViewRpt]
     @flag				VARCHAR(50)
	,@tranId			VARCHAR(50)		= NULL	
	,@controlNo			VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@searchBy			VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL

AS
SET NOCOUNT ON;
declare @sql as varchar(max)
	
IF @flag = 'tranId'
BEGIN
	/*
		select * from tranViewHistory

	*/
	
	set @sql='
	
	select  RT.id [Tran Id],
			dbo.FNADecryptString(RT.controlNo) [Control No.],
			isnull(TM.tranViewType,''Others'') [View Type],
			AM.agentName [Agent Name],
			TM.createdBy [User],
			convert(varchar,TM.createdDate,107) [Date],
			remarks [Remarks]
				
	from tranViewHistory TM with(nolock) 
	inner join remitTran RT with(nolock) on TM.tranId=RT.id
	inner join applicationUsers AU with(nolock) on AU.userName=TM.createdBy 
	left join agentMaster AM WITH(NOLOCK) ON AM.agentId=AU.agentId	
	where 1=1	'
	
	if @tranId is not null
		set @sql=@sql+ ' and TM.tranId='''+@tranId +''''
	
	if @controlNo is not null
		set @sql=@sql+ ' and RT.controlNo='''+ dbo.FNAEncryptString(@controlNo)+'''' 

	exec(@sql)
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'Tran ID' head, @tranId value
	UNION ALL
	SELECT 'Control No/ Ref. No.' head,  @controlNo value

	SELECT 'Transaction View Log' title
END

IF @flag = 'ByDate'
BEGIN
	/*
		select * from tranViewHistory
	*/
	
	SELECT 
	 RT.id [Tran Id],
			dbo.FNADecryptString(RT.controlNo) [Control No.],
			ISNULL(TM.tranViewType,'Others') [View Type],
			AM.agentName [Agent Name],
			TM.createdBy [User],
			CONVERT(VARCHAR,TM.createdDate,107) [Date],
			remarks [Remarks]
				
	FROM tranViewHistory TM WITH(NOLOCK) 
	INNER JOIN remitTran RT WITH(NOLOCK) ON TM.controlNumber=dbo.decryptDb(RT.controlNo)
	LEFT JOIN applicationUsers AU WITH(NOLOCK) ON AU.userName=TM.createdBy 
	LEFT JOIN agentMaster AM WITH(NOLOCK) ON AM.agentId=AU.agentId	
	
	WHERE TM.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'
	AND ISNULL(TM.tranViewType,'Na')=ISNULL(@searchBy, ISNULL(TM.tranViewType,'Na'))
	ORDER BY TM.createdDate DESC

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) VALUE
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) VALUE
	UNION ALL
	SELECT 'Search By' head, @searchBy VALUE

	SELECT 'Transaction View Log' title
END





GO
