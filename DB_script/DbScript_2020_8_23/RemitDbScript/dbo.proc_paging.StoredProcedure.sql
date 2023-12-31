USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_paging]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC	[dbo].[proc_paging]
	@table					VARCHAR(MAX)	= NULL
	,@sqlFilter				VARCHAR(MAX)	= NULL
	,@selectFieldList		VARCHAR(MAX)	= NULL
	,@extraFieldList		VARCHAR(MAX)	= NULL
	,@sortBy				VARCHAR(100)	= NULL
	,@sortOrder				VARCHAR(5)		= NULL
	,@pageSize				INT				= NULL
	,@pageNumber			INT				= NULL
	,@noPaging				CHAR(1)			= NULL
AS


IF NULLIF(@pageSize, 0) IS NULL
	SET @pageSize =  10

IF NULLIF(@pageNumber, 0) IS NULL
	SET @pageNumber =  1

IF @sortOrder IS NULL  
	SET @sortOrder = 'ASC'
	
IF NULLIF(@pageSize, 0) IS NULL 
	SET @pageSize =  10 
IF NULLIF(@pageNumber, 0) IS NULL 	
	SET @pageNumber =  1

DECLARE	
	@sqlCount VARCHAR(MAX)
	,@sql VARCHAR(MAX)
					
SET	@sql = '
			SELECT
				{select_field_list}						
			FROM ' + @table + '  WHERE 1 = 1
		   ' + '
		   '
		   + ISNULL(@sqlFilter, '')
			


SET @sqlCount	= REPLACE(@sql, '{select_field_list}', 'COUNT_BIG(*) total_row')
SET @sql		= REPLACE(@sql, '{select_field_list}', 'ROW_NUMBER() OVER (ORDER BY {sort_by} {sort_order}) rowid_by_ROW_NUMBER, ' + @selectFieldList)

SET @sql = '
			SELECT rowid_by_ROW_NUMBER - ' + CAST(((@pageNumber - 1) * @pageSize) AS VARCHAR(50))  + ' SN,' 			
			+ @selectFieldList + ISNULL(@extraFieldList, '') + '
			FROM ( 
				' + @sql + '
			) x ' 
			+ CASE 
				WHEN @pageSize <> -1 THEN '
					WHERE rowid_by_ROW_NUMBER BETWEEN ' 
					+ CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR(50)) 
					+ ' AND ' + CAST((@pageNumber * @pageSize) AS VARCHAR(50))
				ELSE ''
			  END
SET @sql = REPLACE(@sql, '{sort_by}',		@sortBy )
SET @sql = REPLACE(@sql, '{sort_order}',	@sortOrder)		
		
		PRINT @sql
--Calculating page numbers starts
DECLARE 
	 @totalRows INT
	,@totalPage INT


IF OBJECT_ID(N'tempdb..#totalRows') IS NOT NULL
	DROP Table  #totalRows
	
CREATE TABLE #totalRows (totalRows BIGINT)

EXEC ('INSERT #totalRows(totalRows) SELECT ISNULL((' + @sqlCount + '), 0)')

SET @totalRows = ISNULL((SELECT totalRows FROM #totalRows), 0)

SET @totalPage =  @totalRows / @pageSize

IF @totalRows % @pageSize > 0
	SET @totalPage = @totalPage + 1
IF @pageSize <> -1
	SELECT @totalRows totalRow, ABS(@pageNumber)  pageNumber, @totalPage totalPage, ABS(@pageSize) pageSize
ELSE
	SELECT @totalRows totalRow, 1  pageNumber, 1 totalPage, @totalRows pageSize


--Calculating page numbers ends
PRINT @sql
EXEC (@sql)




GO
