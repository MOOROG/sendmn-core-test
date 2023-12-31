USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_soaMonthlyLog]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_soaMonthlyLog]
		 @flag                  VARCHAR(50)		= NULL				
		,@id					INT				= NULL
		,@user                  VARCHAR(200)	= NULL
		,@agentId				INT				= NULL
		,@branchId				INT 			= NULL
		,@agentName				VARCHAR(100)	= NULL
		,@soaType				VARCHAR(20)		= NULL
		,@createdDate			DATETIME		= NULL
		,@message				VARCHAR(MAX)    = NULL
		,@createdBy				VARCHAR(30)		= NULL				
		,@sortBy				VARCHAR(50)		= NULL
		,@sortOrder				VARCHAR(5)		= NULL
		,@pageSize				INT				= NULL
		,@pageNumber			INT				= NULL
		,@logType				VARCHAR(50)		= NULL
		,@npYear				VARCHAR(10)		= NULL
		,@npMonth				VARCHAR(20)		= NULL
		,@fromDate				VARCHAR(20)		= NULL
		,@toDate				VARCHAR(20)		= NULL
		,@mc					VARCHAR(10)		= NULL

AS
SET NOCOUNT ON
BEGIN
	DECLARE @MM AS VARCHAR(2),@DD AS VARCHAR(2), @YYYY AS VARCHAR(4),@nep_date VARCHAR(20)

	IF @flag = 'logType'
	BEGIN
		SELECT NULL [0],'All' [1] UNION ALL
		SELECT 'Agree' [0],'Agree' [1] UNION ALL
		SELECT 'Disagree' [0],'Disagree' [1] 
	END

	IF @flag = 'i'
	BEGIN
		
		IF EXISTS(SELECT 'x' FROM soaMonthlyLog WITH(NOLOCK) WHERE branchId = @branchId AND npYear = @npYear AND npMonth = @npMonth)
		BEGIN
			SELECT '1' errorCode, 'You have already agreed for balance confirmation.' mgs, @branchId
			RETURN;
		END	

		SELECT @nep_date=nep_date FROM tbl_calendar WITH(NOLOCK) WHERE ENG_DATE = CONVERT(VARCHAR,GETDATE(),102)
		SELECT 
			@DD = CASE WHEN LEN(REPLACE( SUBSTRING (@nep_date, CHARINDEX('-',@nep_date,1), 3),'-',''))=1 
			THEN '0'+REPLACE( SUBSTRING (@nep_date, CHARINDEX('-',@nep_date,1), 3),'-','') 
		ELSE 
			REPLACE( SUBSTRING (@nep_date, CHARINDEX('-',@nep_date,1), 3),'-','') END,
			
		@MM=CASE WHEN LEN(REPLACE(LEFT(@nep_date,3),'-',''))=1 
			THEN '0'+REPLACE(LEFT(@nep_date,3),'-','') 
		ELSE 
			CASE WHEN LEN(REPLACE(LEFT(@nep_date,2),'-',''))=1 
			THEN '0'+REPLACE(LEFT(@nep_date,2),'-','') 
			ELSE REPLACE(LEFT(@nep_date,2),'-','') END
				END,
		@YYYY=RIGHT(@nep_date,4)

		IF LEFT(@MM,1) = '0'
			SET @MM = RIGHT(@MM,1)

		IF @MM ='1'
		BEGIN
			SET @MM ='12'
			SET @YYYY = @YYYY - 1
		END
		ELSE
		BEGIN
			SET @MM = @MM - 1
		END

		IF @YYYY < @npYear
		BEGIN
			SELECT '1' errorCode,'Error: Year, You can not confirm for future year.' mgs, @branchId
			RETURN;
		END 
		IF @npMonth > @MM AND @npYear >= @YYYY
		BEGIN
    		SELECT '1' errorCode,'Error: Month, You can not confirm for future month.' mgs, @branchId
			RETURN;
		END

	    INSERT INTO soaMonthlyLog 
					(
						agentId
					   ,branchId
					   ,fromDate
					   ,toDate
					   ,soaType				  
					   ,createDdate
					   ,createdBy
					   ,message
					   ,logType
					   ,npYear
					   ,npMonth
				   )
				   SELECT
						@agentId
					   ,@branchId	
					   ,@fromDate
					   ,@toDate
					   ,@soaType			   
					   ,GETDATE()
					   ,@user
					   ,@message
					   ,@logType
					   ,@npYear
					   ,@npMonth
		IF @logType <> 'Agree'
		BEGIN
				SET @message = 'Your Balance Confirmation(RA) is DisAgree!! Please Contact Adminastator For Detail Information.'
				INSERT INTO SMSQueue (
				        agentId
					   ,branchId
					   ,msg
					   ,createdDate
					   ,createdBy)
					   SELECT
					    @agentId
					   ,@branchId
					   ,@message
					   ,GETDATE()
					   ,@user
		END

		SELECT '0' errorCode, CASE WHEN @logType = 'Agree' THEN 'I Agree.' ELSE 'I Do Not Agree.' END mgs, NULL
	END

	IF @flag='btnHideShow'
	BEGIN
		    IF EXISTS(SELECT 'a'  FROM soaMonthlyLog WITH(NOLOCK)
			WHERE soaType = @soaType AND branchId = @branchId AND fromDate = @fromDate AND toDate = @toDate 
				AND logType = 'Agree')
			BEGIN
				EXEC proc_errorHandler '1', 'Agree', NULL 
				RETURN
			END
			IF EXISTS(SELECT 'a'  FROM soaMonthlyLog WITH(NOLOCK)  WHERE soaType = @soaType AND branchId = @branchId 
					AND fromDate = @fromDate AND toDate = @toDate AND logType = 'Disagree')
			BEGIN
				EXEC proc_errorHandler '2', 'Disagree', NULL 
				RETURN
			END
			ELSE 
			BEGIN
				EXEC proc_errorHandler '0', 'Log Not Found.', NULL
				RETURN 
			END
	END

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
	
		SET @table = '
		(
			SELECT 
				id						
				,am.agentName 	
				,amb.agentName as BranchName				
				,fromdate = CONVERT(VARchAR, fromdate, 101)
				,toDate = CONVERT(VARchAR, toDate, 101)
				,soaType
				,sl.createdDate
				,sl.logType
				,sl.createdBy
				,sl.npYear
				,sl.npMonth
			FROM soaMonthlyLog sl WITH(NOLOCK)					
			INNER JOIN agentMaster am WITH(NOLOCK) ON sl.agentId=am.agentId
			INNER JOIN agentMaster amb WITH(NOLOCK) ON sl.branchId=amb.agentId
		) x'		
						
		
		SET @selectFieldList = '
								id
								,agentName
								,branchName
								,fromdate
								,toDate
								,soaType
								,createdDate
								,logType
								,createdBy
								,npYear
								,npMonth'		
		
		SET @sqlFilter = ''	
	
		IF @fromDate IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'''
	
		IF @npYear IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND npYear = ''' + @npYear + ''''
				
		IF @npMonth IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND npMonth = ''' + @npMonth + ''''

		IF @agentName IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND branchName LIKE  ''%' + @agentName + '%'''



		PRINT(@table)				
		
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

	IF @flag='report'
	BEGIN
		DECLARE @xml XML
	
		SELECT
			@xml = message
			,@fromDate=fromdate
			,@todate = todate
			,@soaType=soaType
		FROM soaMonthlyLog WITH(NOLOCK)
		  WHERE id=@id

		SELECT
			 Date = r.value('(DATE)[1]','DATETIME')
			,Particulars = REPLACE(r.value('(Particulars)[1]', 'VARchAR(1000)'), 'drildown.aspx', '../../AgentPanel/Reports/SoADomestic/drildownDomComm.aspx')		
			,DR = r.value('(DR)[1]', 'MONEY')
			,CR = r.value('(CR)[1]', 'MONEY')
		FROM @xml.nodes('/NewDataSet/Table') AS rpt(r)
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT  'From Date ' head, CONVERT(VARCHAR, @fromDate, 101)  value UNION ALL
		SELECT 'TO Date' head, CONVERT(VARCHAR, @todate, 101)  value UNION ALL
	
	
		SELECT 
			'Soa Type' head
			,(SELECT 
				CASE @soaType  
					WHEN 'soa' THEN 'Principle' 
					WHEN 'dcom' THEN 'Domistic Commission'
					WHEN 'icom' THEN 'International Commission'  
				END
			)	 
		SELECT 'Balance Confirmation(RA) Log Reports' title	 
		RETURN
	END  

	IF @flag = 'yr'
	BEGIN		
		SELECT '2070' [year] UNION ALL
		SELECT '2071'
	END
	
	IF @flag = 'month'
	BEGIN
		SELECT '1' monthNumber,'Baishak' [monthName] UNION ALL
		SELECT '2','Jestha' UNION ALL
		SELECT '3','Ashar' UNION ALL
		SELECT '4','Shrawan' UNION ALL
		SELECT '5','Bhadra' UNION ALL
		SELECT '6','Ashwin' UNION ALL
		SELECT '7','Kartik' UNION ALL
		SELECT '8','Mangsir' UNION ALL
		SELECT '9','Poush' UNION ALL
		SELECT '10','Magh' UNION ALL
		SELECT '11','Falgun' UNION ALL
		SELECT '12','Chaitra' 
	END

	IF @flag = 'rpt'
	BEGIN 	
		DECLARE @sql AS VARCHAR(MAX),@url AS VARCHAR(MAX)	
		IF @mc = 'false'
		BEGIN
			--SET @url = '"'+dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=10122200&flag=report&id=''+cast(ISNULL(sl.id,'''')as varchar) +''"'
			SET @sql ='SELECT 
				 [S.N.]			= row_number() over(order by sl.id)						
				,[Agent Name]	= am.agentName 			
				,[Year]			= sl.npYear
				,[Month]		= isnull(ml.Name,sl.npMonth)		
				,[Created By]	= sl.createdBy
				,[Created Date] = sl.createdDate
			FROM soaMonthlyLog sl WITH(NOLOCK)							
			INNER JOIN agentMaster am WITH(NOLOCK) ON sl.agentId = am.agentId
			LEFT JOIN monthList ml with(nolock) on sl.npMonth = ml.month_number
			WHERE sl.createdDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'''
		

			IF @npYear IS NOT NULL 
				SET @sql = @sql + ' AND sl.npYear = '''+@npYear+''''

			IF @npMonth IS NOT NULL 
				SET @sql = @sql + ' AND sl.npMonth = '''+@npMonth+''''

			IF @agentId IS NOT NULL 
				SET @sql = @sql + ' AND sl.agentId = '''+CAST(@agentId AS VARCHAR)+''''

			PRINT(@sql)
			EXEC(@sql)
		END
		ELSE
		BEGIN			
			SELECT agentId INTO #TEMP
			FROM agentMaster a WITH(NOLOCK) 
			WHERE agentCountry = 'Nepal'
			AND (actAsBranch = 'Y' OR agentType = 2904)
			AND ISNULL(a.isDeleted, 'N') = 'N'
			AND ISNULL(a.isActive, 'N') = 'Y'
			AND a.isSettlingAgent = 'Y'
			AND a.parentId <> 5576
			
			DELETE FROM #TEMP 
			FROM #TEMP T
			INNER JOIN soaMonthlyLog L WITH(NOLOCK) ON T.agentId = L.agentId
			WHERE L.npMonth = @npMonth
				AND L.npYear = @npYear
				--AND L.createdDate BETWEEN @fromDate AND @toDate+' 23:59:59'

			SELECT 
			     [S.N.]			= ROW_NUMBER() OVER(ORDER BY am.agentName)						
				,[Agent Name]	= am.agentName 			
				,[Year]			= @npYear
				,[Month]		= (SELECT Name FROM monthList WHERE month_number = @npMonth)		
				,[Created By]	= ''
				,[Created Date] = ''
			FROM #TEMP A INNER JOIN agentMaster am WITH(NOLOCK) ON A.agentId = am.agentId			
			ORDER BY am.agentName
		END
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
		SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' to '+CONVERT(VARCHAR,@toDate,101)  value UNION ALL
		SELECT 'Year',@npYear UNION ALL
		SELECT 'Month',(SELECT name FROM monthList WITH(NOLOCK) WHERE month_number = @npMonth) UNION ALL
		SELECT 'Agent',CASE WHEN @agentId IS NULL THEN 'All' ELSE (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId =@agentId) END UNION ALL
		SELECT 'Checked for missing confirmation',@mc
	   
		SELECT 'Balance Confirmation(RA) Log Report' title
	END

	IF @flag = 'GetCurrNepYM'
	BEGIN
		SELECT @nep_date= nep_date FROM tbl_calendar WITH(NOLOCK) WHERE ENG_DATE = CONVERT(VARCHAR,GETDATE(),102)
		SELECT 
			@DD = CASE WHEN LEN(REPLACE( SUBSTRING (@nep_date, CHARINDEX('-',@nep_date,1), 3),'-',''))=1 
			THEN '0'+REPLACE( SUBSTRING (@nep_date, CHARINDEX('-',@nep_date,1), 3),'-','') 
		ELSE 
			REPLACE( SUBSTRING (@nep_date, CHARINDEX('-',@nep_date,1), 3),'-','') END,
			
		@MM=CASE WHEN LEN(REPLACE(LEFT(@nep_date,3),'-',''))=1 
			THEN '0'+REPLACE(LEFT(@nep_date,3),'-','') 
		ELSE 
			CASE WHEN LEN(REPLACE(LEFT(@nep_date,2),'-',''))=1 
			THEN '0'+REPLACE(LEFT(@nep_date,2),'-','') 
			ELSE REPLACE(LEFT(@nep_date,2),'-','') END
				END,
		@YYYY=RIGHT(@nep_date,4)

		IF LEFT(@MM,1) = '0'
			SET @MM = RIGHT(@MM,1)

		IF @MM ='1'
		BEGIN
			SET @MM ='12'
			SET @YYYY = @YYYY - 1
		END
		ELSE
		BEGIN
			SET @MM = @MM - 1
		END
		
		SELECT @MM npMonth,@YYYY npYear
	END
END





GO
