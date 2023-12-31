USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_enrollCommReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_enrollCommReport]
	 @flag							VARCHAR(20)
	,@user							VARCHAR(30)	
	,@fromDate						VARCHAR(20)	= NULL
	,@toDate						VARCHAR(20)	= NULL
	,@date							VARCHAR(20)	= NULL
    ,@AgentId						VARCHAR(30) = NULL
    ,@PageSize						VARCHAR(20) = NULL
    ,@PageNumber					VARCHAR(20) = NULL
AS

SET NOCOUNT ON;
DECLARE @COMM_RATE AS MONEY,@SQL AS VARCHAR(MAX),@SQL1 AS VARCHAR(MAX)

IF EXISTS(SELECT commRate FROM enrollCommSetup WHERE agentId is null)
BEGIN
	SELECT @COMM_RATE=commRate FROM enrollCommSetup WHERE agentId is null
END
ELSE					
BEGIN
	SET @COMM_RATE=0;
END
				
IF @flag = 'ECR'
BEGIN
	/*
	SELECT * FROM enrollCommSetup
	select * from agentMaster where agentid=18
	select * from applicationUsers where agentId=18
	select * from applicationUsers where username='bharat1'
	select * from customers where createdBy in ('yubaraj','nirakar1','bharat1')
	exec proc_enrollCommReport @flag='ECR',@user='admin',
	@fromDate='5/5/2012',@toDate='5/7/2012',@AgentId =null,@PageSize='100',@PageNumber='1'
	
	exec proc_enrollCommReport @flag='ECR',@user='admin',
	@fromDate='5/5/2012',@toDate='5/7/2012',@AgentId ='9',@PageSize='100',@PageNumber='1'
	*/
	
	if @AgentId is null
	begin
				
				SET @SQL='SELECT * FROM 
				(
					SELECT c.agentName [Agent Name]
						, COUNT(*) [No Of Customer]
						, '+CAST(@COMM_RATE AS VARCHAR)+' [Commission Rate]
						, (COUNT(*)*'+CAST(@COMM_RATE AS VARCHAR)+') [Amount] 
					FROM customers a WITH(NOLOCK) 
					INNER JOIN applicationUsers b with(nolock) on a.createdBy=b.userName
					INNER JOIN agentMaster c with(nolock) on c.agentId=b.agentId 
					
					WHERE a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
							AND c.agentId not in (select agentId from enrollCommSetup where agentId is not null)					
					group by c.agentName,c.agentId
					
					
					union all
					
					SELECT c.agentName [Agent Name]
						, COUNT(*) [No Of Customer]
						, d.commRate [Commission Rate]
						, (COUNT(*)*d.commRate) [Amount] 
					from customers a with(nolock) 
						inner join applicationUsers b with(nolock) on a.createdBy=b.userName
						inner join agentMaster c with(nolock) on c.agentId=b.agentId 
						inner join enrollCommSetup d with(nolock) on d.agentId=c.agentId
					where c.agentId in (select agentId from enrollCommSetup where agentId is not null)
						and a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
					group by c.agentName,d.commRate,c.agentId
				)A'

	end

	if @AgentId is not null
	begin
	
			if exists(select * from enrollCommSetup where agentId=@AgentId)
			begin

				SET @SQL='SELECT c.agentName [Agent Name]
				, COUNT(*) [No Of Customer]
				, d.commRate [Commission Rate]
				, (COUNT(*)*d.commRate) [Amount] 
				from customers a with(nolock) 
				inner join applicationUsers b with(nolock) on a.createdBy=b.userName
				inner join agentMaster c with(nolock) on c.agentId=b.agentId 
				inner join enrollCommSetup d with(nolock) on d.agentId=c.agentId
				where c.agentId ='+@AgentId+'
				and a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
				group by c.agentName,d.commRate,c.agentId'
				
				
			end
			else
			begin

				SET @SQL='SELECT c.agentName [Agent Name]
				, COUNT(*) [No Of Customer]
				, '+CAST(@COMM_RATE AS VARCHAR)+' [Commission Rate]
				, (COUNT(*)*'+CAST(@COMM_RATE AS VARCHAR)+') [Amount] 
				FROM customers a WITH(NOLOCK) 
				INNER JOIN applicationUsers b with(nolock) on a.createdBy=b.userName
				INNER JOIN agentMaster c with(nolock) on c.agentId=b.agentId 

				WHERE a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
				AND c.agentId = '+@AgentId+'
				group by c.agentName,c.agentId'
			end			

	end
	
		
	SET @SQL1='
	SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @SQL +') AS tmp;

	SELECT * FROM 
	(
		SELECT ROW_NUMBER() OVER (ORDER BY [Agent Name] DESC) AS rowId,* 
		FROM 
		(
			'+ @SQL +'
		) AS aa
	) AS tmp WHERE 1 = 1 AND  tmp.rowId BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''
	
	EXEC(@SQL1)
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value

	SELECT 'Enrollment Commission Summary Report' title
END

IF @flag = 'ECDR'
BEGIN
	/*
	SELECT * FROM enrollCommSetup
	select * from agentMaster where agentid=18
	select * from applicationUsers where agentId=18
	select * from applicationUsers where username='bharat1'
	select * from customers where createdBy in ('yubaraj','nirakar1','bharat1')
	exec proc_enrollCommReport @flag='ECDR',@user='admin',@fromDate='2011-01-02',
				@toDate='2012-07-01',@AgentId=NULL,@PageSize='100',@PageNumber='1'
	*/
	
	if @AgentId is null
	begin
			
			SET @SQL='SELECT * FROM 
			(
				SELECT 				
					  c.agentName [Agent Name]
					, CONVERT(VARCHAR,a.createdDate,101) [Date]
					, COUNT(*) [No Of Customer]
					, '+CAST(@COMM_RATE AS VARCHAR)+' [Commission Rate]
					, (COUNT(*)*'+CAST(@COMM_RATE AS VARCHAR)+') [Amount] 
				FROM customers a WITH(NOLOCK) 
				INNER JOIN applicationUsers b with(nolock) on a.createdBy=b.userName
				INNER JOIN agentMaster c with(nolock) on c.agentId=b.agentId 
				
				WHERE a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
						AND c.agentId not in (select agentId from enrollCommSetup where agentId is not null)					
				group by c.agentName,c.agentId,CONVERT(VARCHAR,a.createdDate,101) 
			
			
				UNION ALL
				
				SELECT c.agentName [Agent Name]
					, CONVERT(VARCHAR,a.createdDate,101) [Date]
					, COUNT(*) [No Of Customer]
					, d.commRate [Commission Rate]
					, (COUNT(*)*d.commRate) [Amount] 
				from customers a with(nolock) 
					inner join applicationUsers b with(nolock) on a.createdBy=b.userName
					inner join agentMaster c with(nolock) on c.agentId=b.agentId 
					inner join enrollCommSetup d with(nolock) on d.agentId=c.agentId
				where 
					c.agentId in (select agentId from enrollCommSetup where agentId is not null)	
					and a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
				group by c.agentName,d.commRate,c.agentId,CONVERT(VARCHAR,a.createdDate,101)
			
			) A '
			
			
			
	end
	
	if @AgentId is NOT null
	begin
	
			if exists(select * from enrollCommSetup where agentId=@AgentId)
			begin			
				SET @SQL='SELECT c.agentName [Agent Name]
					, CONVERT(VARCHAR,a.createdDate,101) [Date]
					, COUNT(*) [No Of Customer]
					, d.commRate [Commission Rate]
					, (COUNT(*)*d.commRate) [Amount] 
				from customers a with(nolock) 
					inner join applicationUsers b with(nolock) on a.createdBy=b.userName
					inner join agentMaster c with(nolock) on c.agentId=b.agentId 
					inner join enrollCommSetup d with(nolock) on d.agentId=c.agentId
				where c.agentId =ISNULL(@AgentId,C.agentId)
					and a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
				group by c.agentName,d.commRate,c.agentId,CONVERT(VARCHAR,a.createdDate,101)
				'
			END
			ELSE
			BEGIN
				SELECT @COMM_RATE=commRate FROM enrollCommSetup WHERE agentId is null
				
				SET @SQL='SELECT c.agentName [Agent Name]
					, CONVERT(VARCHAR,a.createdDate,101) [Date]
					, COUNT(*) [No Of Customer]
					, '+CAST(@COMM_RATE AS VARCHAR)+' [Commission Rate]
					, (COUNT(*)*'+CAST(@COMM_RATE AS VARCHAR)+') [Amount] 
				from customers a with(nolock) 
					inner join applicationUsers b with(nolock) on a.createdBy=b.userName
					inner join agentMaster c with(nolock) on c.agentId=b.agentId 
					inner join enrollCommSetup d with(nolock) on d.agentId=c.agentId
				where c.agentId ='+@AgentId+'
					and a.createdDate BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+'''
				group by c.agentName,d.commRate,c.agentId,CONVERT(VARCHAR,a.createdDate,101)
				'
			END
			
	end
	
	SET @SQL1='
		SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @SQL +') AS tmp;

		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER (ORDER BY [Agent Name] DESC) AS rowId,* 
			FROM 
			(
				'+ @SQL +'
			) AS aa
		) AS tmp WHERE 1 = 1 AND  tmp.rowId BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''
	
	EXEC(@SQL1)
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value

	SELECT 'Enrollment Commission Detail Report' title
END






GO
