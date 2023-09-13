
--exec [proc_LoginViewLogs] @flag = 's'  ,@pageNumber='1', @pageSize='10', @sortBy='rowid', @sortOrder='ASC', @user = 'admin1'

ALTER proc [dbo].[proc_LoginViewLogs]
			@flag				VARCHAR(50)
			,@Id				BIGINT			= NULL
			,@logType			VARCHAR(50)		= NULL	
			,@IP				VARCHAR(50)		= NULL
			,@agent				VARCHAR(50)		= NULL
			,@reason			VARCHAR(50)		= NULL
			,@createdBy			VARCHAR(30)		= NULL
			,@createdDate		DATE	 		= NULL
			,@sortBy			VARCHAR(50)		= NULL
			,@sortOrder			VARCHAR(50)		= NULL
			,@pageSize			INT				= NULL
			,@pageNumber		INT				= NULL
			,@user				VARCHAR(50)		= NULL
			,@isLocked			CHAR(1)			= NULL
AS
SET NOCOUNT ON;

IF @flag = 's'
BEGIN 
	
	   DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
		SET @sortBy = 'createdDate'
		SET @sortOrder = 'DESC'	

		DECLARE @hasRight CHAR(1), @ViewHOLoginLogsFunctionId VARCHAR(50),@SubSql varchar(max)
		SET @ViewHOLoginLogsFunctionId = '10121210'
		SELECT @hasRight = dbo.FNAHasRight(@user, @ViewHOLoginLogsFunctionId)						
		
		if @hasRight ='Y'
			Set @SubSql =  ' where 1=1 '
		else
			Set @SubSql =  ' where 1=1 and b.agentId <> 1001 ' 

		SET @table = '(
							SELECT 
									 rowId 
									,al.createdDate 
									,B.agentCode
									,B.employeeId
									,B.userName createdBy
									,IP
									,Reason
									,logType										
									,al.userData
									,B.isLocked	
									,b.userId
									,LOGIN_COUNTRY = ISNULL(al.LOGIN_COUNTRY+ '' (''+al.LOGIN_COUNTRY_CODE+'' )'', ''-'')
									,ADDRESS = ISNULL(LOGIN_REGION + '', ''+LOGIN_CITY+'', ''+LOGIN_ZIPCODDE, ''-'')
									, OTP_ATTEMPT = ISNULL(CASE WHEN IS_SUCCESSFUL = 1 THEN ''Successful'' WHEN IS_SUCCESSFUL = 0 THEN ''Invalid'' ELSE NULL END, ''-'')
									,lockStatus = CASE WHEN ISNULL(B.isLocked, ''N'') = ''N'' THEN ''No''
											WHEN ISNULL(B.isLocked, ''N'') = ''Y'' THEN ''Yes | <a href="#" onclick="UnlockUser('' + CAST(B.userId AS VARCHAR) + '')">Unlock</a> | <a id="showSlab_'' + CAST(rowId AS VARCHAR) + ''" 
											href="#" onclick="ShowSlab('' + CAST(rowId AS VARCHAR) + '','''''' + B.userName + '''''')">View Reason</a>'' END  			
							FROM LoginLogs al WITH(NOLOCK)
							LEFT JOIN agentMaster A ON al.agentId = A.agentId
							LEFT JOIN applicationUsers B on B.UserName=al.CreatedBy'+ @SubSql +''		
					
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			   rowId
			 , createdDate
			 , agentCode
			 , employeeId
			 , createdBy
			 , IP
			 , Reason
			 , logType
			 , userData
			 , isLocked
			 , lockStatus
			 ,userId
			 ,OTP_ATTEMPT
			 ,LOGIN_COUNTRY
			 ,ADDRESS
			'

		IF @logType IS NOT NULL
			SET @table = @table + ' AND logType = ''' + @logType + ''''
			
		IF @createdDate IS NOT NULL
			SET @table = @table + ' AND cast(al.createdDate as date) = ''' + cast(@createdDate as varchar(11))  + ''''
	
			
		IF @IP IS NOT NULL
			SET @table = @table + ' AND IP = ''' + @IP + ''''
			
		IF @agent IS NOT NULL
			SET @table = @table + ' AND A.agentCode LIKE ''' + @agent + '%'''

		IF @reason IS NOT NULL
			SET @table = @table + ' AND Reason LIKE ''' + @reason + '%'''
			

		IF @createdBy IS NOT NULL
			SET @table = @table + ' AND B.userName = ''' + @createdBy + ''''
		
		IF @isLocked IS NOT NULL
			SET @table = @table + ' AND ISNULL(isLocked, ''N'') = ''' + @isLocked + ''''

		  SET @table =  @table +') x '


		  SET @extraFieldList = ',''<a href ="manage.aspx?log_Id='' + CAST(rowid AS VARCHAR(50)) + ''"><img border = "0" title = "View Log" src="' + '../../../images/but_view.gif" /></a>'

		  SET @extraFieldList = @extraFieldList + ' &nbsp;<a href="ResetPassword.aspx?userId='' + cast(userId as varchar) + ''&userName='' + createdBy + ''"><img border = "0" src="../../../images/icon_reset.gif" title="Reset Password" alt="Reset Password" /></a

> ''[edit]'

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

ELSE IF @flag = 'type'
BEGIN
	SELECT * FROM (
			SELECT NULL [value], 'All' [text] UNION ALL
			
			SELECT 'Login' [0], 'Login' [1] UNION ALL
			SELECT 'Login fails' [0], 'Login fails' [1]	UNION ALL
			SELECT 'Logout' [0], 'Logout' [1]
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END
		RETURN
END





