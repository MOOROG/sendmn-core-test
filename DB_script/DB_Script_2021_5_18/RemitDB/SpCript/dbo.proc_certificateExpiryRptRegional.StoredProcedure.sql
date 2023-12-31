USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_certificateExpiryRptRegional]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_certificateExpiryRptRegional]
		 @flag                  VARCHAR(50)		= NULL				
		,@id					INT				= NULL
		,@user                  VARCHAR(200)	= NULL	
		,@createdDate			DATETIME		= NULL		
		,@createdBy				VARCHAR(30)		= NULL				
		,@sortBy				VARCHAR(50)		= NULL
		,@sortOrder				VARCHAR(5)		= NULL
		,@pageSize				INT				= NULL
		,@pageNumber			INT				= NULL		
		,@fromDate				VARCHAR(20)		= NULL
		,@toDate				VARCHAR(20)		= NULL
AS
SET NOCOUNT ON
BEGIN
	IF @flag = 'rpt'
	BEGIN
		DECLARE @sql VARCHAR(MAX)
		SET @sql =
			'SELECT
						 [S.N.]			= row_number()over(order by am.agentName)
						,[Agent Id]		= am.agentId
						,[Agent Name]	= am.agentName
						,[User Name]	= au.userName
						,[Exp.Date]		= CONVERT(VARCHAR,DATEADD(year,1,au.dcApprovedDate),101)
			FROM applicationUsers au WITH(NOLOCK)
			INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = au.agentId
			INNER JOIN userZoneMapping zp WITH(NOLOCK) ON am.agentState = zp.zoneName
			WHERE ISNULL(au.isDeleted,''n'')<>''Y'' 
				AND ISNULL(au.isActive,''Y'')=''Y''
				AND ISNULL(am.agentBlock,''U'') = ''U''
				AND DATEADD(year,1,au.dcApprovedDate) BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''
				AND zp.userName='''+ @user +'''
				and zp.isDeleted is null'

			EXEC(@sql)
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
			SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	   
			SELECT 'Certificate Expiry Report' title
	END

END

GO
