USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_certificateExpiryReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procEDURE [dbo].[proc_certificateExpiryReport]
		 @flag                  VARCHAR(50)		= NULL				
		,@id					INT				= NULL
		,@user                  VARCHAR(200)	= NULL
		,@agentId				VARCHAR(10)		= NULL		
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
		SET @sql ='SELECT
						 [S.N.]			= row_number()over(order by am.agentState,am.agentName)
						,[Agent Id]		= am.agentId
						,[Zone]			= am.agentState
						,[District]		= am.agentDistrict
						,[Agent Name]	= am.agentName
						,[Phone]		= am.agentPhone1
						,[User Name]	= au.userName
						,[Exp.Date]		= CONVERT(VARCHAR,DATEADD(year,1,au.dcApprovedDate),101)
					FROM applicationUsers au WITH(NOLOCK)
					INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = au.agentId
					WHERE 
						ISNULL(au.isDeleted,''n'')<>''Y'' 
						AND ISNULL(au.isActive,''Y'')=''Y''
						AND ISNULL(am.agentBlock,''U'') = ''U''
					AND DATEADD(year,1,au.dcApprovedDate) BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
				IF @agentId IS NOT NULL 
				SET @sql = @sql + ' AND am.agentId='''+ @agentId +''''

				EXEC(@sql)
				EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
				SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value	 UNION All
				SELECT 'Agent Name' head,case when @agentId is null then 'All Agent' else
					(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId) end VALUE 
	   
			   SELECT 'Certificate Expiry Report' title
	END

END


GO
