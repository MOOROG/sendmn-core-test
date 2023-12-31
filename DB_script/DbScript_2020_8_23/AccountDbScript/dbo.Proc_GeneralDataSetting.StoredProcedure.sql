USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[Proc_GeneralDataSetting]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_GeneralDataSetting]
	  @FLAG					VARCHAR(1)
	  ,@USER				VARCHAR(50) 	= NULL
      ,@TYPE_TITLE			VARCHAR(50)		= NULL
	  ,@TYPE_DESC			VARCHAR(500)	= NULL
      ,@refid				INT				= NULL
      ,@id					VARCHAR(10)		= NULL
      ,@ref_rec_type		VARCHAR(50) 	= NULL
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
	SET @sortBy = 'TYPE_TITLE'	
		
	SET @table = '(
					SELECT 
						ROWID
						,TYPE_TITLE
						,TYPE_DESC
						FROM staticDataType 
						WITH (NOLOCK) WHERE 1=1 
				) x'	
					  

	SET @sqlFilter = ''
	IF @TYPE_TITLE IS NOT NULL
		SET @sqlFilter +=' AND  TYPE_TITLE LIKE '''+@TYPE_TITLE + '%'''			
	
	IF @TYPE_DESC IS NOT NULL
			SET @sqlFilter +=' AND TYPE_DESC LIKE '''+@TYPE_DESC+'%'''
			
			
	SET @selectFieldList = 'ROWID,TYPE_TITLE, TYPE_DESC'
			
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

IF @FLAG='A'
	BEGIN	
	IF @sortBy IS NULL  
	SET @sortBy = 'ref_code'	
		
	SET @table = '(
					SELECT 
						refid
						,ref_code
						,ref_desc
						,CREATED_BY
						,CREATED_DATE
						,MODIFIED_BY
						,MODIFIED_DATE
						FROM ref_master 
						WITH (NOLOCK) WHERE 
						ref_rec_type = '''+@ref_rec_type+'''
				) x'	
					  

	SET @sqlFilter = ''
	
	IF @TYPE_TITLE IS NOT NULL
			SET @sqlFilter +=' AND  ref_code LIKE  '''+@TYPE_TITLE + '%'''
			
	IF @TYPE_DESC IS NOT NULL
			SET @sqlFilter +=' AND ref_desc LIKE '''+@TYPE_DESC + '%'''
			
	SET @selectFieldList = 'refid,ref_code,ref_desc, CREATED_BY,CREATED_DATE,MODIFIED_BY,MODIFIED_DATE'
			
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

IF @FLAG='v'
BEGIN	
	SELECT 
		ref_code
		,ref_desc
		,CREATED_BY
		,CREATED_DATE
		,MODIFIED_BY
		,MODIFIED_DATE
		,s.TYPE_TITLE as title
		FROM ref_master r WITH (NOLOCK) 
		INNER JOIN staticDataType s ON r.ref_rec_type = s.ROWID
		WHERE 1=1 AND refid = @refid
						
	RETURN
END



IF @FLAG='r'
BEGIN	
	 
	SELECT 
		ROWID
		,'General Data Settings' as title
		,TYPE_TITLE as ref_code
		,TYPE_DESC as ref_desc		
	FROM staticDataType 
	WITH (NOLOCK) WHERE 1=1 AND ROWID = @id
						
	RETURN
END



END

IF @FLAG='U' 
BEGIN 
	UPDATE ref_master   
		SET   
			ref_code			=	@TYPE_TITLE,  
			ref_desc			=	@TYPE_DESC,  
			MODIFIED_BY		=	@USER,  
			MODIFIED_DATE	=	GETDATE()
			WHERE refid			=	@refid
				
		exec proc_errorHandler 0,'Record updated successfully!',null 
RETURN
END 

IF @FLAG='I'  
BEGIN   
	INSERT INTO ref_master(ref_rec_type, ref_code, ref_desc, CREATED_BY, CREATED_DATE)  

	VALUES ( @ref_rec_type, @TYPE_TITLE, @TYPE_DESC, @USER, GETDATE() )
			
	exec proc_errorHandler 0,'Record added successfully!',null 
RETURN
END

ELSE IF @FLAG='D'
BEGIN
	DELETE FROM ref_master WHERE refid = @refid;
	exec proc_errorHandler 0,'Record deleted successfuly',@refid
	RETURN
END
GO
