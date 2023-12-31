USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_branchUserList]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

[proc_agentMaster] @flag = 'bc', @agentId = '1'
[proc_agentMaster] @flag = 's', @user = 'admin', @parentId = 1

*/
CREATE PROC [dbo].[proc_branchUserList]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
	 ,@agentId							INT				= NULL
	 ,@isActAsBranch					VARCHAR(10)		= NULL
	 ,@agentType						INT				= NULL
	 ,@parentId							INT				= NULL
	 ,@agentName						VARCHAR(100)	= NULL
	 ,@userName							VARCHAR(100)	= NULL
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL



AS
SET NOCOUNT ON
	
DECLARE @glcode VARCHAR(10), @acct_num VARCHAR(20);
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
       

SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@tableName				VARCHAR(50)
		,@logIdentifier			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@tableAlias			VARCHAR(100)
		,@modType				VARCHAR(6)
		,@module				INT	
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@table					VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@ApprovedFunctionId	INT	
		
	SELECT
		 @logIdentifier = 'userId'
		,@logParamMain = 'applicationUsers'
		,@tableAlias = 'Application User'
		,@module = 20
		,@ApprovedFunctionId = 20101030
	
	IF @flag = 'su'						
	BEGIN
		IF @isActAsBranch ='Y' and  @agentType = '2903' -- ## private agents
		BEGIN
			SET @table = '(
					select   userId			=	a.userId
							,agentId		=	a.agentId
							,userName		=	a.userName
							,userFullName	=	isnull(firstName,'''')+'' ''+isnull(middleName,'''')+'' ''+isnull(lastName,'''')
							,address		=	address
							,countryName	=	c.countryName
							,agentName		=	b.agentName
							,agentCode		=	a.agentCode
							,employeeId		=	a.employeeId
							,lockStatus		=   CASE WHEN ISNULL(a.isLocked, ''N'') = ''N'' THEN ''N | <a href="#" onclick="UnlockUser('' + CAST(a.userId AS VARCHAR) + '')">Lock</a>''
											WHEN ISNULL(a.isLocked, ''N'') = ''Y'' THEN ''Y | <a href="#" onclick="UnlockUser('' + CAST(a.userId AS VARCHAR) + '')">Unlock</a>'' END   
													
					from applicationUsers a with(nolock) inner join agentMaster b with(nolock) on a.agentId=b.agentId
					left join countryMaster c with(nolock) on c.countryId=a.countryId
					where userName=''' +  @user + ''' and isnull(a.isActive,''Y'') = ''Y''				
				) x '

		END
		ELSE IF @agentType = '2904' -- ## Consolidate Bank & Finance
		BEGIN
			SET @table = '(
					select   userId			=	a.userId
							,agentId		=	a.agentId
							,userName		=	a.userName
							,userFullName	=	isnull(firstName,'''') + isnull('' '' + middleName,'''')+ isnull('' '' + lastName,'''')
							,address		=	address
							,countryName	=	c.countryName
							,agentName		=	b.agentName
							,agentCode		=	a.agentCode
							,employeeId		=	a.employeeId	
							,lockStatus		=   CASE WHEN ISNULL(a.isLocked, ''N'') = ''N'' THEN ''N'' | <a href="#" onclick="UnlockUser('' + CAST(a.userId AS VARCHAR) + '')">Lock</a>''
											WHEN ISNULL(a.isLocked, ''N'') = ''Y'' THEN ''Y'' | <a href="#" onclick="UnlockUser('' + CAST(a.userId AS VARCHAR) + '')">Unlock</a>'' END   
												
					from applicationUsers a with(nolock) inner join 
					(
						SELECT agentId,agentName from agentMaster where parentId=''' + CAST(@parentId AS VARCHAR) + ''' 	
					)b on a.agentId=b.agentId
					left join countryMaster c with(nolock) on c.countryId=a.countryId
					where isnull(a.isActive,''Y'') = ''Y''				
				) x'
		END
		--PRINT (@table)
		IF @sortBy IS NULL
		   SET @sortBy = 'userId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
					
		SET @sql_filter = ''		
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' and agentName LIKE ''%' + @agentName + '%'''	
					
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' and userName LIKE ''%' + @userName + '%'''	
			
		SET @select_field_list ='
									userId
								   ,agentId
								   ,userName
								   ,userFullName              
								   ,address  
								   ,countryName
								   ,agentName   
								   ,agentCode
								   ,employeeId
								   ,lockStatus
								'        	
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

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
