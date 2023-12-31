USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_IpAccessLogs]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CREATE TABLE IpAccessLogs(id int identity(1,1) primary key,ip varchar(100),createdDate datetime,fieldValue varchar(100))

CREATE procEDURE [dbo].[proc_IpAccessLogs]
		 @id			   varchar(10)		= NULL
		,@ip				VARCHAR(100)	= NULL
		,@createdDate		VARCHAR(50)		= NULL
		,@fieldValue		VARCHAR(100)	= NULL
		,@flag				VARCHAR(20)		= NULL
		,@sortBy			VARCHAR(50)		= NULL
		,@sortOrder			VARCHAR(50)		= NULL
		,@pageSize			INT				= NULL
		,@pageNumber		INT				= NULL
		,@user				VARCHAR(50)		= NULL
AS
BEGIN
	IF @flag='s'
	BEGIN
	
		 DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
		
		SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'	
			
			
		SET @table = '( SELECT
							id
							,ip
							,createdDate
							,fieldValue
						FROM IpAccessLogs
					    
					  '
			
				
		set @sqlFilter=''
		
		SET @selectFieldList = '
			id
			 ,ip
			 , createdDate
			 , fieldValue			 
		'
				
	IF @createdDate IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdDate BETWEEN ''' + @createdDate +''' AND ''' + @createdDate + ' 23:59:59'''
	
	IF @ip IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND ip = ''' + @ip + ''''
		
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
	IF @flag='i'
		BEGIN
			INSERT INTO IpAccessLogs
			(
				 ip
				,createdDate
				,fieldValue
			)	
			select
				@ip			
				,GETDATE()	
				,@fieldValue				
		END	
	IF @flag='e'
		BEGIN
			SELECT 0 errCode,'Value is Invalid!' msg
		END
	
	
END

GO
