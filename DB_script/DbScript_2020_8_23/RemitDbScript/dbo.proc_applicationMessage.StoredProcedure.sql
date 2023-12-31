USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationMessage]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
applicationMessage
*/
CREATE proc [dbo].[proc_applicationMessage]
	 @flag						VARCHAR(10)	
	,@admin						VARCHAR(30)			= NULL
	,@msgId						BIGINT				= NULL
	,@msgSubject				VARCHAR(MAX)		= NULL
	,@msgBody					VARCHAR(MAX)		= NULL
	,@msgDate					VARCHAR(10)			= NULL
	,@msgFrom					VARCHAR(30)			= NULL
	,@msgTo						VARCHAR(30)			= NULL
	,@sendEmailAlso				CHAR(1)				= NULL
	,@msgStatus					VARCHAR(20)			= NULL
	,@del						CHAR(1)				= NULL
	,@fullName					VARCHAR(50)			= NULL
	,@sortBy					VARCHAR(50)			= NULL
	,@sortOrder					VARCHAR(5)			= NULL
	,@pageSize					INT					= NULL
	,@pageNumber				INT					= NULL
AS

/*
	@flag
	s	= select all (with dynamic filters)
	i	= insert
	u	= update
	a	= select by role id
	d	= delete by role id
	l	= drop down list
		
	[applicationMessage]
	
*/
SET NOCOUNT ON
BEGIN TRY
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO applicationMessage(	
				 msgSubject
				,msgBody
				,msgDate
				,msgFrom
				,msgTo
				,sendEmailAlso
				,msgStatus
				,del
			)
			SELECT 
				 @msgSubject
				,@msgBody
				,GETDATE()
				,@msgFrom
				,@msgTo
				,@sendEmailAlso
				,@msgStatus
				,@del
				
			IF @sendEmailAlso = 'Y'
			BEGIN
				INSERT emailNotes(				
					 sendFrom
					,sendTo
					,subject
					,notesText
					,activeFlag
					,sendStatus
				)
				
				SELECT
					 @msgFrom
					,@msgTo
					,@msgSubject
					,@msgBody
					,'Y'
					,'N'
			END	
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		SET @msgId = SCOPE_IDENTITY()
		SELECT 0 errorCode, 'New message has been added successfully.' mes, @msgId id	
	END
	
	ELSE IF @flag='a'
	BEGIN
			   SELECT
					 msgSubject, msgBody, msgDate  
					,REPLACE(ISNULL(au.firstName, '') + ' ' + ISNULL(au.middleName, '') + ' ' + ISNULL(au.lastName, ''), ' ', ' ') [From Name]
					,REPLACE(ISNULL(au1.firstName, '') + ' ' + ISNULL(au1.middleName, '') + ' ' + ISNULL(au1.lastName, ''), ' ', ' ') [TO Name]
			   FROM applicationMessage am WITH(NOLOCK)
			   INNER JOIN applicationUsers au WITH(NOLOCK) ON am.msgFrom = au.userName
			   INNER JOIN applicationUsers au1 WITH(NOLOCK) ON am.msgTo =  au1.userName
			   WHERE msgId = @msgId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		DELETE FROM applicationMessage WHERE msgId = @msgId
		SELECT 0 errorCode, 'Message successfully deleted.' mes, @msgId id	
	END
	ELSE IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
			
		IF @sortBy IS NULL  
			SET @sortBy = 'msgDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'Desc'
		
		SET @msgTo = @admin
	
		--SET @table = '[custodian]'	
		
		SET @table = '(
						SELECT 
							 au.userName msgFrom
							,msgId
							,am.msgDate 
							,REPLACE(ISNULL(au.firstName, '''') + '' '' + ISNULL(au.middleName, '''')  + '' '' + ISNULL(au.lastName, ''''), ''  '', '' '') [fullName]
							,am.msgSubject, am.msgBody
							,am.msgTo
						FROM applicationMessage am WITH(NOLOCK)
						INNER JOIN [applicationusers] au WITH(NOLOCK) ON am.msgFrom = au.userName											
					) x '		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
								 msgFrom, msgDate
								,msgSubject, msgBody								
								,fullName, msgId
								,msgTo
							'
					
		IF @admin IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND msgTo  =''' + CAST(@admin AS VARCHAR) + ''''
						
		--IF @fullName IS NOT NULL
		--	SET @sqlFilter = @sqlFilter + ' AND fullName  LIKE''%' + @fullName + '%'''
		
		IF @msgSubject IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND msgSubject  LIKE''%' + @msgSubject + '%'''
			
		IF @msgDate IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND msgDate  = ''' + @msgDate + ''''
		
		
		SET @extraFieldList = ',''<a href ="manage.aspx?msgId='' + CAST(msgId AS VARCHAR(50)) + ''">Show</a>'''
		+ CASE dbo.FNAHasRight(@admin, 201010)
			WHEN 'Y' THEN ' + ''&nbsp;&nbsp;&nbsp;&nbsp;<img onclick = "DeleteNotification('' + CAST(msgId AS VARCHAR(50)) + '')" class = "showHand" border = "0" title = "Delete Notification" src="../images/delete.gif" />'''
			ELSE ''
		  END + ' [edit]' 
		
		
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
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT 1 errorCode, ERROR_MESSAGE() mes, @msgId id
END CATCH
		
		



GO
