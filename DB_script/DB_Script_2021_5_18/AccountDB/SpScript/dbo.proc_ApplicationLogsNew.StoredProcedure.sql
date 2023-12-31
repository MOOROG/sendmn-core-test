USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_ApplicationLogsNew]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[proc_ApplicationLogsNew]
    (
      @flag            CHAR(15)             ,
      @user            VARCHAR(25)    = NULL ,
      @sortBy          VARCHAR(50)    = NULL ,
      @sortOrder       VARCHAR(5)     = NULL ,
      @pageSize        INT = NULL ,
      @pageNumber      INT = NULL ,
      @logId           INT = NULL,
	  @createdDate     varchar(30) = NULL ,
	  @createdBy       varchar(20)= NULL

    )
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
		DECLARE @sql                    VARCHAR(MAX) ,
				@select_field_list		VARCHAR(MAX) ,
				@extra_field_list		VARCHAR(MAX) ,
				@table					VARCHAR(MAX) ,
				@sql_filter				VARCHAR(MAX) ,
				@ApprovedFunctionId		INT ,
				@msg                    VARCHAR(200) ,
				@parentAgentId          INT;
    IF @flag = 's'
        BEGIN
            IF @sortBy IS NULL
                SET @sortBy = 'id';
            IF @sortOrder IS NULL
                SET @sortOrder = 'ASC';
            SET @table = '(
							SELECT 
								id, 
								errorPage, 
								errorMsg, 
								errorDetails, 
								createdBy, 
								createdDate 
								FROM ErrorLogs (nolock)
						) x';
					
            SET @sql_filter = '';		
            IF @logId IS NOT NULL
                SET @sql_filter = @sql_filter + '  AND id=''' + cast(@logId as varchar) + '''';

			IF @createdDate IS NOT NULL
				SET @sql_filter = @sql_filter + '  AND createdDate between '''+@createdDate+''' and  '''+@createdDate+' 23:59:59''';

			IF   @createdBy  IS NOT NULL
				SET @sql_filter = @sql_filter + '  AND createdBy= '''+  @createdBy +''' ';
			
			
            SET @select_field_list = '
					id
					,errorPage
					,errorMsg
					,errorDetails
					,createdBy
					,createdDate
					';        	
            
            EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
                @extra_field_list, @sortBy, @sortOrder, @pageSize, @pageNumber;
        END;



		
GO
