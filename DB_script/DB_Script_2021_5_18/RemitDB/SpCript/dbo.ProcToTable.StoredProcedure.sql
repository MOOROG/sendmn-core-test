USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcToTable]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[ProcToTable]
(
     @SPAndParameters nvarchar(max)
    ,@tempTable VARCHAR(20)
)
AS
BEGIN


    DECLARE @Driver nvarchar(20)
    DECLARE @ConnectionString nvarchar(200)
    DECLARE @SQL nvarchar(max)
    DECLARE @SQL2 nvarchar(max)
    DECLARE @RowsetSQL nvarchar(max)
 
    SET @Driver = '''' + 'MSDASQL' + ''''
    SET @ConnectionString = '''' +'DRIVER={SQL Server};SERVER=192.168.2.1;UID=domestic_user;PWD=ime1234' + ''''
    SET @RowsetSQL = '''' +'SET FMTONLY OFF ' + '' + @SPAndParameters + '' + ''''
    SET @SQL = ' SELECT * INTO ' + @tempTable + ' FROM OPENROWSET('
 
    SET @SQL = @SQL + @Driver + ',' + @ConnectionString + ',' + @RowsetSQL + ')'
    
    EXEC (@SQL)
	PRINT(@SQL)
END

GO
