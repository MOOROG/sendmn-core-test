USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_creditLimitRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_creditLimitRpt]
	 @flag				VARCHAR(20)
	,@user				VARCHAR(50)	=   NULL
	,@fromDate			VARCHAR(20)	=	NULL
	,@toDate			VARCHAR(20)	=	NULL
	,@agentId			VARCHAR(50)	=	NULL
	,@userName			VARCHAR(50)	=	NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;
DECLARE @SQL VARCHAR(MAX)
IF @flag='rpt'
BEGIN   	 
	SET @SQL = ' 
		SELECT 
			[S.N.]						= ROW_NUMBER()OVER(order BY am.agentName,bt.createdDate),
			[Agent Name]				= am.agentName,
			[Approved Amount]			= CASE WHEN  ISNULL(bt.btStatus,''Requested'') = ''Requested'' THEN 0 else bt.amount end,
			[Requested_Amount]			= CASE WHEN  ISNULL(bt.btStatus,''Requested'') = ''Requested'' THEN bt.amount ELSE reqAmt end,		
			[Requested_Date]			= bt.createdDate,
			[Requested_User]			= bt.createdBy,
			[Status]					= CASE WHEN bt.btStatus IS NULL THEN ''Requested'' ELSE bt.btStatus END,  
			[Approved/Rejected_User]	= bt.approvedBy,
			[Approved/Rejected_Date]	= bt.approvedDate,
			[Approved/Rejected_Remarks]	= remarks		
		FROM balanceTopUp bt WITH(NOLOCK) 
		INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON bt.agentId = am.agentId 
		WHERE bt.createdDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'''

	IF @agentId IS NOT NULL
		SET @SQL = @SQL+' AND bt.agentId = '''+@agentId+''''

	IF @userName IS NOT NULL
		SET @SQL = @SQL+' AND (bt.createdBy = '''+@userName+''' OR bt.approvedBy = '''+@userName+''')'
	
	EXEC(@SQL)	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	
		
	SELECT 'From Date' head,@fromDate VALUE
	UNION ALL
	SELECT 'To Date' head,@toDate value
	UNION ALL
	SELECT 'Agent Name' head,CASE WHEN @agentId IS NULL THEN 'All' ELSE (SELECT agentNAme FROM dbo.agentMaster am WITH(NOLOCK) WHERE agentId = @agentId) END value
	UNION ALL
	SELECT 'User Name' head,@userName value
			
	SELECT 'Topup History Limit Report' title					
END 




GO
