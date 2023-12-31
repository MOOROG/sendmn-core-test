USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_pwdChangedLogs]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec proc_pwdChangedLogs @flag = 's',@fromDate='2014-02-01',@toDate ='2014-02-04'

CREATE proc [dbo].[proc_pwdChangedLogs]
			 @flag				VARCHAR(50)
			,@fromDate			VARCHAR(50)		= NULL
			,@toDate			VARCHAR(50)		= NULL	
			,@branchName		VARCHAR(50)		= NULL	
			,@agentName			VARCHAR(50)		= NULL
			,@userName			VARCHAR(50)		= NULL		
			,@sortBy			VARCHAR(50)		= NULL
			,@sortOrder			VARCHAR(50)		= NULL
			,@pageSize			INT				= NULL
			,@pageNumber		INT				= NULL
			,@user				VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;

IF @flag = 's'
BEGIN 	
	   DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)
			
		SET @sortBy = 'pwdChangedDate'
		SET @sortOrder = 'desc'					
	
		SET @table = '(
						select 						 
							 agentName = am.agentName
							,userName = pwd.userName							
							,pwdChangedDate = pwd.createdDate
							,pwdChangedBy = pwd.createdBy
							,lastPwdChangedDate = au.lastPwdChangedOn 
						from passwordHistory pwd with(nolock) 
						inner join applicationUsers au with(nolock) on pwd.userName = au.userName
						inner join agentMaster am with(nolock) on au.agentId = am.agentId
						where 1=1
					'
					
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			   agentName
			 , userName
			 , pwdChangedDate
			 , pwdChangedBy
			 , lastPwdChangedDate
			'
					
		IF @fromDate IS NOT NULL and @toDate is not null
			SET @table = @table + ' AND pwd.createdDate between ''' + @fromDate  + ''' and ''' + @toDate +' 23:59:59'''

		IF @branchName IS NOT NULL
			SET @table = @table + ' AND am.agentName like ''%' + @branchName + '%'''

		IF @userName IS NOT NULL
			SET @table = @table + ' AND pwd.userName like ''%' + @userName + '%'''

		SET @table =  @table +') x '

		EXEC dbo.proc_paging
			 @table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber	

END




GO
