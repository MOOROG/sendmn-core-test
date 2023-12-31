USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ExchangeRateLog]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_ExchangeRateLog]
(	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(100)	= NULL
	,@userName			VARCHAR(100)	= NULL
	,@updatedDate		VARCHAR(50)		= NULl
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
) 
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
			
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'			
			SET @table = '(
							SELECT 
							 erth.rowId
							,cm.countryName
							,am.agentName
							,cCurrency = ''1 USD - ''+ CAST(cRate AS VARCHAR)+ '' ''+ cCurrency
							,updatedBy = erth.createdBy
							,updatedDate = DATEADD(MINUTE,-135,erth.createdDate)
							,erth.approvedBy
							,approvedDate= DATEADD(MINUTE,-135,erth.approvedDate)
							,pCurrency = ''1 USD - ''+ CAST(erth.pRate AS VARCHAR)+'' NPR'' 
							FROM exRateTreasuryHistory erth WITH(NOLOCK)
							INNER JOIN countryMaster cm WITH(NOLOCK) ON erth.cCountry = cm.countryId
							INNER JOIN agentMaster am WITH(NOLOCK) ON erth.cAgent = am.agentId
							inner join applicationUsers au with(nolock) on erth.createdBy = au.username
							where au.agentId = 1001'		
					
		SET @sqlFilter = '' 
		
		SET @selectFieldList = 'rowId
							 , countryName
							 , agentName
							 , cCurrency
							 , pCurrency
							 , updatedBy
							 , updatedDate
							 , approvedBy
							 , approvedDate'
			
		IF @userName IS NOT NULL
			SET @table = @table + ' AND erth.createdBy = ''' + @userName + ''''
			
		IF @updatedDate IS NOT NULL
			SET @table = @table + ' AND erth.createdDate BETWEEN ''' +  @updatedDate + ''' AND ''' +  @updatedDate + ' 23:59:59'''
	
		SET @table = @table + ')x'
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



GO
