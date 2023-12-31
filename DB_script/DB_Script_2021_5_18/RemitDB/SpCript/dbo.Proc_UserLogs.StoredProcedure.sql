USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_UserLogs]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_UserLogs]
	   @FLAG				VARCHAR(1)
	  ,@USER				VARCHAR(50) 	= NULL
      ,@logType				VARCHAR(50)		= NULL
	  ,@IP					VARCHAR(500)	= NULL
	  ,@rowId				INT				= NULL
      ,@Reason				VARCHAR(2000)	= NULL
      ,@createdBy			VARCHAR(10)		= NULL
      ,@createdDateGMT		DATETIME 		= NULL
      ,@UserData			VARCHAR(MAX)	= NULL
      ,@sortBy				VARCHAR(50)		= NULL
      ,@sortOrder			VARCHAR(5)		= NULL
	  ,@pageSize			INT				= NULL
	  ,@pageNumber			INT				= NULL 
	  
AS
BEGIN
SET NOCOUNT ON;
IF @FLAG='S'
	BEGIN	
		DECLARE 
				 @selectFieldList	VARCHAR(MAX)
				,@extraFieldList	VARCHAR(MAX)
				,@table				VARCHAR(MAX)
				,@sqlFilter			VARCHAR(MAX)
		IF @sortBy IS NULL  
		SET @sortBy = 'USER'	
			
		SET @table = '(SELECT rowId, logType, IP, Reason, createdBy, createdDate FROM dbo.LoginLogs WHERE 1=1) x'	
						  

		SET @sqlFilter = ''
		IF @createdBy IS NOT NULL
			SET @sqlFilter +=' AND  createdBy LIKE '''+@createdBy + '%'''			

		IF @logType IS NOT NULL
				SET @sqlFilter +=' AND logType ='''+@logType+''''
				
				
		SET @selectFieldList = 'rowId, logType, IP, Reason, createdBy, createdDate'
				
				EXEC dbo.proc_paging
				@table					
				,@sqlFilter			
				,@selectFieldList		
				,@extraFieldList		
				,@sortBy				
				,@sortOrder			
				,@pageSize				
				,@pageNumber

		RETURN
	END
IF @FLAG='T'
	BEGIN	
		
		SELECT fieldValue FROM dbo.LoginLogs WHERE rowId = @rowId
		
		RETURN
	END
END

GO
