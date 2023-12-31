USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_IsoRequestResponseLogs]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_IsoRequestResponseLogs](
	  @flag								VARCHAR(10)		= NULL
	 ,@user								VARCHAR(30)		= NULL
	 ,@amount							VARCHAR(30)		= NULL
	 ,@rowId							VARCHAR(30)		= NULL
	 ,@remitCard						VARCHAR(20)		= NULL
	 ,@accountNo						VARCHAR(20)		= NULL
	 ,@createdDate						VARCHAR(20)		= NULL
	 ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL
)AS
BEGIN
	DECLARE
		 @sql				VARCHAR(MAX)		
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)		

	IF @flag='s'
	BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'logId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   
		SET @table = '(
						SELECT
								 rowId
								,remitCard		= CASE When cardNumber2 is not null then cardNumber+''-''+cardNumber2 else cardNumber end
								,accountNo	= CASE When accountNumber2 is not null then accountNumber+''-''+accountNumber2 else accountNumber end
								,status			= errorMessage
								,createdDate	= requestedDate
								,cardNumber
								,cardNumber2 
								,accountNumber
								,accountNumber2
								,amount=dbo.showDecimal(isnull(amount,0.00))
							from IsoDB.dbo.isoLogs
						)  x'
					
		SET @sql_filter = ''		
				
		IF @remitCard IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (cardNumber LIKE ''' + @remitCard + '%'' OR cardNumber2 LIKE ''' + @remitCard + '%'')'
		
		IF @accountNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (accountNumber LIKE ''' + @accountNo + '%'' OR accountNumber2 like '''+@accountNo+'%'')'
			
		IF @createdDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND createdDate between '''+@createdDate +''' and  '''+@createdDate + ' 23:59:59'''
		
		IF @amount IS NOT NULL	
		BEGIN	
			set @amount=cast(REPLACE(@amount,',','') as real)
			SET @sql_filter = @sql_filter + ' AND cast(REPLACE(amount,'','','''') as real) >='+@amount+''
		END
		

		SET @select_field_list ='
							 rowId
							,remitCard		
							,accountNo
							,amount	
							,status			
							,createdDate	
               '      
                 	
		--PRINT @table	
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
		SELECT
			 rowId
			,remitCard		= NULL --CASE When cardNumber2 is not null then cardNumber+'-'+cardNumber2 else cardNumber end
			,accountNo		= CASE When accountNumber2 is not null then accountNumber+'-'+accountNumber2 else accountNumber end
			,status			= errorMessage
			,rawRequest		= request
			,rawResponse	= response
			,Request		= request2
			,Response		= response2
			,reqDate		= requestedDate 
			,resDate		= responseDate 
			,method			= methodName 			
		from IsoDB.dbo.isoLogs where rowId=@rowId
	END
END


GO
