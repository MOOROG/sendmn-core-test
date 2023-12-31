USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_KFTCApiLogs]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [proc_KFTCApiLogs] @flag='s',@user='',@REQUESTEDBY='maxkim@gmeremit.com'

CREATE PROCEDURE [dbo].[proc_KFTCApiLogs](
	 @flag			 VARCHAR(10)	
	,@user  		 VARCHAR(30)	
	,@REQUESTEDBY	 VARCHAR(100)	=	NULL
	,@requestedDate	 DATETIME		=   NULL	
	,@rowId			 INT			= 	NULL
	,@pageSize		 INT			=	NULL
	,@pageNumber	 INT			=	NULL
	,@sortBy		VARCHAR(50)		=	NULL
	,@sortOrder		VARCHAR(50)		=	NULL	
)AS
SET NOCOUNT ON
SET	XACT_ABORT ON
BEGIN
	DECLARE
		 @table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
	IF @flag='s'
	BEGIN		
		SET @sortBy='rowId'
		SET @sortOrder='DESC'

		SET @table='
		(	
			SELECT l.rowId
				  ,l.METHODNAME
				  ,m.Email	
				  ,''KFTC'' as Provider			 
				  ,l.REQUESTEDBY
				  ,l.REQUESTDT AS requestedDate
				  ,l.RESPONSEDT AS responseDate
				  ,l.RESPONSECODE AS errorCode
				  ,l.RESPONSEMSG AS errorMessage
			  FROM VW_KFTC_LOG L
			  INNER JOIN customerMaster m(nolock) on m.customerId = l.REQUESTEDBY
			  WHERE 1=1 
		)x'
						
		SET @sql_filter = ''		
		IF @REQUESTEDBY IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND Email = '''+@REQUESTEDBY+''''
						
		IF @requestedDate IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND requestedDate BETWEEN ''' +@requestedDate+''' AND ''' +@requestedDate+' 23:59:59'' '				
			
		SET @select_field_list = '
								 rowId
								,methodName
								,Provider
								,Email								
								,requestedBy
								,requestedDate
								,responseDate
								,errorCode
								,errorMessage
							'
							
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
	IF @flag='a'
	BEGIN
				SELECT l.rowId
					  ,l.methodName
					  ,m.Email
					  ,providerName = 'KFTC'
					  ,l.requestXml
					  ,l.responseXml
					  ,l.requestedBy
					  ,l.REQUESTDT requestedDate
					  ,l.RESPONSEDT responseDate
					  ,l.RESPONSECODE errorCode
					  ,l.RESPONSEMSG errorMessage
			  FROM VW_KFTC_LOG L
			  INNER JOIN customerMaster m(nolock) on m.customerId = l.REQUESTEDBY
			  WHERE rowId = @rowId
	END
END


GO
