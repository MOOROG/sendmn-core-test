USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_branchRatingNEW]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_branchRatingNEW]
(
		@flag					VARCHAR(50)			= NULL
		,@brDetailId			VARCHAR(50)			= NULL	
		,@branchId				VARCHAR(50)			= NULL
		,@rmBranchId			INT					= NULL
		,@agentID				INT					= NULL		
		,@fromDate				DATE				= NULL
		,@toDate				DATE				= NULL		
		,@createdDate			DATETIME			= NULL
		,@ratingComment			VARCHAR(2500)		= NULL
		,@modifiedBy			VARCHAR(50)			= NULL		
		,@modifedDate			DATETIME			= NULL		
		,@reviewedDate			DATETIME			= NULL
		,@reviewerComment		VARCHAR(2500)		= NULL
		,@approverComment		VARCHAR(2500)		= NULL
		,@remarks				VARCHAR(2500)		= NULL
		,@isActive				VARCHAR(5)			= NULL			
		,@user					VARCHAR(50)			= NULL
		,@sortBy                VARCHAR(50)			= NULL
		,@sortOrder             VARCHAR(5)			= NULL
		,@pageSize              INT					= NULL
		,@pageNumber            INT					= NULL
		,@xml					XML					= NULL
		,@isRatingCompleted		CHAR(1)				= NULL
		,@rating				VARCHAR(10)			= NULL
		,@approvedDate			DATETIME			= NULL
		,@category				VARCHAR(50)			= NULL
	
	
)
AS

SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
		
		DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@errorMsg			VARCHAR(MAX)
		
		
		IF @flag = 'i'
		BEGIN
			-- select * from branchratingdetailNEW
			IF EXISTS (SELECT 'x' FROM branchratingdetailNEW WITH(NOLOCK) WHERE branchId=@branchId and approvedBy is null and isnull(isActive,'Y')='Y')
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, there is already active assessement exists for this branch, which has not been approved yet. Please kindly do inactive or review the existing record and try again.', @branchId
				RETURN
			END		
			IF EXISTS (SELECT 'x' FROM branchratingdetailNEW WITH(NOLOCK) WHERE branchId=@branchId AND ISNULL(isActive,'Y')='Y' AND toDate>=@fromDate)
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, Assessement is already exists for this date. Please kindly another date.', @branchId
				RETURN
			END
			
			BEGIN TRANSACTION
				INSERT INTO branchratingdetailNEW (					
					branchId
					,fromDate
					,toDate
					,createdBy
					,createdDate					
					,isActive
				)
				SELECT
					@branchId
					,@fromDate
					,@toDate
					,@user
					,GETDATE()					
					,@isActive					
													
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentID
		END
					
		IF @flag='rbd' -- Rating branch details
		BEGIN
			SET @sortBy = 'branchName'					
			DECLARE @hasRight CHAR(1),@reviewRight CHAR(1),@approveRight CHAR(1),@initiateRight CHAR(1)
					
			
			SET @initiateRight = dbo.FNAHasRight(@user, '20191600')		--Intiate 20191600
			SET @hasRight = dbo.FNAHasRight(@user, '20191620')			--Rating 20191620
			SET @reviewRight = dbo.FNAHasRight(@user, '20191630')		--Review 20191630
			SET @approveRight = dbo.FNAHasRight(@user, '20191640')		--Approve
				
			SET @table = '(
					SELECT
						 brDetailid = brd.ratingId
						,brd.branchId
						,branchName = am.agentName						
						,brd.fromDate
						,brd.toDate
						,operations=dbo.FNAGetBranchRatingNEW(''merge'',''Operation-General'',brd.ratingId)
						,security=dbo.FNAGetBranchRatingNEW(''merge'',''Security-Maintenance'',brd.ratingId)
						,compliance=dbo.FNAGetBranchRatingNEW(''merge'',''Compliance-Regulatory'',brd.ratingId)		
						,others = ''''				
						,overall=dbo.FNAGetBranchRatingNEW(''merge'',''overall'',brd.ratingId)
						,brd.createdBy
						,brd.createdDate						
						,rankedBy = brd.ratingBy
						,rankingDate  = brd.ratingDate
						,reviewedDate = brd.reviewedDate
						,brd.reviewerComment
						,brd.approvedBy
						,brd.approvedDate
						,approverComment
						,brd.isActive
																	
						,scorelink = 
							CASE WHEN brd.isActive=''y'' AND brd.ratingDate IS NULL AND brd.reviewedDate IS NULL AND brd.approvedDate IS NULL THEN 
							CASE WHEN '''+@hasRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=rating&brId=''+CAST(brd.ratingId AS VARCHAR)+''&bId=''+CAST(brd.branchId AS VARCHAR)
							    +''&bName=''+CAST(am.agentName AS VARCHAR)
								+''&ron=''+ISNULL(CAST(brd.reviewedDate AS VARCHAR),'''')
								+''&r=''+CAST(ISNULL(brd.reviewedBy,'''') AS VARCHAR)
								+''&rPeriod=''+CAST(brd.fromDate AS VARCHAR)+'' to ''+ CAST(brd.toDate AS VARCHAR)
								
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								
								+''">Rating</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&brId=''+CAST(brd.ratingId AS VARCHAR)+''&bId=''+CAST(brd.branchId AS VARCHAR)+''">Mark Inactive</a>&nbsp;''
							ELSE ''''
							END
							
							
							when brd.isActive=''y'' and brd.ratingDate is not null AND brd.ratingComment IS NOT NULL AND brd.reviewedBy is null then 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=review&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
							    +''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Review</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''
							
							<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp;
							
							''
							END
							
							when brd.isActive=''y'' and brd.reviewedDate is not null AND brd.approvedDate is null and brd.reviewedBy<>'''+@user+''' then 
							CASE WHEN '''+@approveRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=approve&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
							    +''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Approve</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''
							
							<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp;
							
							''
							END
							when brd.isActive=''y'' and brd.ratingDate is not null then 
							+ ''<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
							+''&bName=''+cast(am.agentName as varchar)
							+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
							+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
							+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
							+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
							+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
							+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
							+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')							
							+''">Details</a>&nbsp;''									
						
							else
							''<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp;''
							+case when isnull(brd.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)+''">Mark Inactive</a>''
							else '''' end
							end
						
						
					FROM branchratingdetailNEW brd WITH(NOLOCK)
					INNER JOIN agentMaster am on am.agentId=brd.branchId					
						WHERE 1 = 1 ) x'
						
			
			
			print 	@table														
			SET @sql_filter = ''
			
				
			IF @agentID is not NULL
				SET @sql_filter=@sql_filter+'  And branchId =  '''+CAST(@agentID AS VARCHAR)+''''
				
				
			IF @fromDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND fromDate BETWEEN ''' + CONVERT(VARCHAR, @fromDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @fromDate, 101) + ' 23:59:59'''
		
		    IF @toDate IS NOT NULL AND @toDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND toDate BETWEEN ''' + CONVERT(VARCHAR, @toDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @toDate, 101) + ' 23:59:59'''
				
			
			IF @reviewedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND reviewedDate BETWEEN ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ' 23:59:59'''
			
			
			IF @approvedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR, @approvedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @approvedDate, 101) + ' 23:59:59'''		
		
		
			IF @isActive IS NOT NULL AND @isActive<>'All'
				SET @sql_filter = @sql_filter + ' And isActive='''+@isActive+''''			
			ELSE IF @isActive IS NULL
				SET @sql_filter = @sql_filter + ' And isActive=''1'''						
						
			IF @rating is not NULL
				SET @sql_filter=@sql_filter+'  And dbo.FNAGetBranchRatingNEW(''rating'','''+@category+''',x.brDetailid) =  '''+CAST(@rating AS VARCHAR)+''''	
					
			print @table+''+@sql_filter	
			
			
			SET @select_field_list ='
				 brDetailid
				,branchId
				,branchName
				,rankedBy				
				,rankingDate
				,fromDate
				,toDate
				,operations
				,security
				,compliance	
				,others			
				,overall
				,reviewedDate
				,approvedDate
				,createdBy
				,scorelink '
				
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
		
		ELSE IF @flag = 'rc' -- Rating Criteria
		BEGIN
			
		    CREATE TABLE #tmpTable(
				rowId					INT,
				[type]					VARCHAR(10), 
				displayOrder			VARCHAR(10),
				[weight]				MONEY,
				[description]			VARCHAR(2500),
				[summaryDescription]	VARCHAR(250),
				[ParentId]				VARCHAR(10)
			)
			
			DECLARE @catFlag INT, @catCount INT,@subCatFlag INT, @subCatCount INT
			SET @catFlag = 1
			SET @catCount=(SELECT COUNT(rowId) FROM branchRatingMasterNEW WITH(NOLOCK) WHERE [type] = 'A')

			WHILE (@catFlag <=@catCount)
			BEGIN
				INSERT INTO #tmpTable
				SELECT rowId, [type], displayOrder, [weight], [description], summaryDescription, '' FROM branchRatingMasterNEW WITH(NOLOCK)
				WHERE [type] = 'A' AND displayOrder = @catFlag

				SET @subCatFlag = 1
				SET @subCatCount=(SELECT COUNT(rowId) FROM branchRatingMasterNEW WITH(NOLOCK)
				WHERE [type] = 'B' AND displayOrder LIKE CAST(@catFlag AS VARCHAR)+'.%') --AND CHARINDEX('.',displayOrder)>0)

				WHILE(@subCatFlag <= @subCatCount)
				BEGIN
					INSERT INTO #tmpTable
					SELECT rowId, [type], displayOrder, [weight], [description], '', CAST(@catFlag AS VARCHAR) + '.' + CAST(@subCatFlag AS VARCHAR)
					FROM branchRatingMasterNEW WITH(NOLOCK) WHERE [type] = 'B' AND
					displayOrder = CAST(@catFlag AS VARCHAR) + '.' + CAST(@subCatFlag AS VARCHAR)

					INSERT INTO #tmpTable
					SELECT rowId, [type], ROW_NUMBER() OVER(ORDER BY CAST(REPLACE(displayOrder, '.', '') AS INT) ASC) AS displayOrder,[weight],[description],'',
					CAST(@catFlag AS VARCHAR) + '.' + CAST(@subCatFlag AS VARCHAR) 
					FROM branchRatingMasterNEW WITH(NOLOCK) WHERE [type]='C' AND
					displayOrder LIKE CAST(@catFlag AS VARCHAR) + '.' + CAST(@subCatFlag AS VARCHAR)+'.%'
					
					SET @subCatFlag = @subCatFlag + 1 -- sub cat loop
				END
					
				SET @catFlag = @catFlag + 1 -- main loop
			END
				
				
			IF EXISTS (SELECT 'x' FROM branchRatingNEW WITH(NOLOCK) WHERE brDetailid = @brDetailId)
			BEGIN
				SELECT
					 bm.rowId
					,bm.[type]
					,bm.displayOrder
					,bm.[weight]
					,bm.[description]
					,bm.summaryDescription
					,bm.ParentId							
					,score=dbo.ShowDecimal(x.score)
					,x.remarks
					,x.reviewedBy
					,x.reviewedDate
					,x.reviewerComment
					,x.approvedBy
					,x.approvedDate
					,x.approverComment
					,x.ratingBy
					,x.ratingDate
					,x.ratingComment					
				FROM #tmpTable bm WITH(NOLOCK)
				LEFT JOIN 
				(
					SELECT rowId,br.brMasterId,br.Score,br.remarks,brd.isActive,brd.reviewedBy,brd.reviewedDate,brd.reviewerComment,brd.approvedBy,brd.approvedDate,brd.approverComment,brd.ratingBy,brd.ratingDate,brd.ratingComment 
					FROM branchRatingNEW br WITH(NOLOCK) 
					INNER JOIN branchratingdetailNEW brd WITH(NOLOCK) ON br.brDetailid = brd.ratingId
					WHERE brd.isActive='y' and brd.ratingId = @brDetailId					
				) x ON x.brMasterId= bm.rowId
				--WHERE x.isActive='Y' 
				ORDER BY rowId	
			END
			ELSE
			BEGIN
				SELECT *,'' score,'' remarks,'' reviewedBy,'' reviewedDate,'' reviewerComment,'' approvedBy,'' approvedDate ,'' approverComment,'' ratingBy, '' ratingDate, '' ratingComment FROM #tmpTable	ORDER BY rowId
			END
				
			DROP TABLE #tmpTable
			
			
			/*
			IF ISNULL(@brDetailId, 0) <> 0
			BEGIN
				SELECT
					  rowId					= brm.rowId
					 ,type
					 ,displayOrder			= RIGHT(displayOrder, CASE WHEN LEN(displayOrder) > 4 THEN (LEN(displayOrder) - 4) ELSE LEN(displayOrder) END)
					 ,weight
					 ,description			= ISNULL(description, '')
					 ,summaryDescription	= ISNULL(summaryDescription, '')
					 ,ParentId				= LEFT(displayOrder, 3)
					 ,score					= ISNULL(score, 0)
					 ,remarks
					 ,reviewedBy
					 ,reviewedDate
					 ,reviewerComment
					 ,approvedBy
					 ,approvedDate
					 ,approverComment
					 ,ratingBy				= ISNULL(ratingBy, br.modifiedBy)
					 ,ratingDate			= ISNULL(ratingDate, br.modifieddate)
					 ,ratingComment
				FROM dbo.branchRatingMasterNew brm WITH(NOLOCK)
				LEFT JOIN branchRatingNew br WITH(NOLOCK) ON brm.rowId = br.brMasterId
				LEFT JOIN dbo.branchRatingDetailNew brd WITH(NOLOCK) ON br.brDetailid = brd.ratingId
				WHERE br.brDetailid = @brDetailId OR br.brDetailid IS NULL
				ORDER BY brm.rowId
			END
			ELSE
			BEGIN
				SELECT
					 rowId					= brm.rowId
					,type
					,displayOrder			= RIGHT(displayOrder, CASE WHEN LEN(displayOrder) > 4 THEN (LEN(displayOrder) - 4) ELSE LEN(displayOrder) END)
					,weight
					,description			= ISNULL(description, '')
					,summaryDescription		= ISNULL(summaryDescription, '')
					,ParentId				= LEFT(displayOrder, 3)
					,score					= ''
					,remarks				= ''
					,reviewedBy				= ''
					,reviewedDate			= ''
					,reviewerComment		= ''
					,approvedBy				= ''
					,approvedDate			= ''
					,approverComment		= ''
					,ratingBy				= ''
					,ratingDate				= ''
					,ratingComment			= ''
				FROM dbo.branchRatingMasterNew brm WITH(NOLOCK)
				ORDER BY brm.rowId
			END
			*/
			
			SELECT rowId, brMasterId,brDetailId,riskCategory, ROUND(score,2) AS score, rating FROM branchRatingSummaryNEW WITH(NOLOCK) WHERE brDetailId=@brDetailId
			
			SELECT * FROM branchScoremaster
		END		
		
		ELSE IF @flag = 'i-br'
		BEGIN
			BEGIN TRANSACTION
				
				IF EXISTS (SELECT 'x' FROM branchRatingNEW WITH(NOLOCK) WHERE brDetailid=@brDetailId)
				BEGIN					
					DELETE FROM branchRatingNEW WHERE brDetailid=@brDetailId					
				END
						
							
				INSERT INTO branchRatingNEW(					
					brMasterId
					,brDetailid
					,score
					,remarks
					,modifiedBy
					,modifieddate					
				)
				SELECT
				 p.value('@rowId','VARCHAR(50)')
				,p.value('@brDetaildId','VARCHAR(50)')
				,p.value('@score','VARCHAR(50)')				
				,p.value('@remarks','VARCHAR(2500)')
				,@user
				,GETDATE()				
				FROM @xml.nodes('/root/row') AS tmp(p)

				UPDATE branchratingdetailNEW
					set modifiedBy=@user
					,modifiedDate= GETDATE()
					,ratingDate= CASE WHEN @isRatingCompleted='Y' THEN GETDATE() ELSE NULL END
					,ratingBy=@user										
					WHERE ratingId=@brDetailId					
			  				

			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @branchId
			EXEC proc_branchRating @flag = 'rc', @user=@user,@branchId=@branchId,@brDetailId=@brDetailId
		END
		ELSE IF @flag = 'branchcomment'
		BEGIN
		
			UPDATE branchratingdetailNEW
					set 					
						 ratingComment = @ratingComment
						,reviewedByBranch	= @user
						,reviewedDateBranch	= GETDATE()
					WHERE ratingId = @brDetailId	
					
		EXEC proc_errorHandler 0, 'Branch Rating Comment added  successfully.', @brDetailId	
		
		END
		ELSE IF @flag = 'review'
		BEGIN
		
			UPDATE branchratingdetailNEW
					set 					
					reviewedBy=@user
					,reviewedDate=GETDATE()
					,reviewerComment=@reviewerComment
					WHERE ratingId=@brDetailId	
					
		EXEC proc_errorHandler 0, 'Review Comment Added  successfully.', @brDetailId	
		
		END
		ELSE IF @flag = 'approve'
		BEGIN
		
			UPDATE branchratingdetailNEW
					set 					
					approvedBy=@user
					,approvedDate=GETDATE()
					,approverComment=@approverComment
					WHERE ratingId=@brDetailId	
					
		EXEC proc_errorHandler 0, 'Branch Rating Approved successfully.', @brDetailId	
		
		END
		ELSE IF @flag='ddlStatus'
		BEGIN
		
			SELECT 'All' 'value', 'All' AS 'text' UNION ALL
			SELECT 'Y','Active' UNION ALL
			SELECT 'N','Inactive'
		
		END		
		ELSE IF @flag='ddlCategory'
		BEGIN		
			SELECT NULL 'value','All' AS 'text' UNION ALL
			SELECT summaryDescription,summaryDescription FROM branchRatingMasterNEW WHERE [type]='A' AND summaryDescription IS NOT NULL
			UNION ALL
			SELECT 'Overall','Overall'
		END
		ELSE IF @flag='ddlRating'
		BEGIN
		    		    
			SELECT NULL 'value','All' 'text' UNION ALL
			SELECT rating,rating FROM branchScoremaster WHERE rating IS NOT NULL
		END
		ELSE IF @flag='summary'
		BEGIN
		    		    
			IF EXISTS (SELECT 'x' FROM branchRatingSummaryNEW WITH(NOLOCK) WHERE brDetailid=@brDetailId)
				BEGIN					
					DELETE FROM branchRatingSummaryNEW WHERE brDetailid=@brDetailId					
				END
							
				
					INSERT INTO branchRatingSummaryNEW ( brMasterId ,brDetailId, riskCategory, score, rating)					 
					 SELECT x.rowid,@brDetailId brDetailId ,summarydescription,score,rating  FROM 

					 (SELECT  rowid,displayorder,summarydescription,[weight] FROM branchRatingMasterNEW WHERE TYPE='A') x
					 INNER JOIN 
					  (
					 SELECT SUBSTRING( displayorder, 1,1) sn , ROUND(SUM( CAST([weight] AS MONEY)  *score/100.00),2) score FROM 
					 branchRatingMasterNEW b WITH (NOLOCK) INNER JOIN branchRatingNEW  bd WITH (NOLOCK) 
					 ON b.rowid=bd.brMasterId
					 AND brDetailid=@brDetailId
					 GROUP BY SUBSTRING( displayorder, 1,1)
					 ) y ON x.displayorder=y.sn
					, branchScoremaster s WHERE  y.score BETWEEN s.scorefrom AND s.scoreto

					UNION ALL

					 SELECT 99,@brDetailId,'Overall', score ,rating  FROM 

					(
					 SELECT   ROUND(SUM (score * CAST (x.[weight] AS MONEY) /100.00),2)  score  FROM 

					 (SELECT  rowid,displayorder,summarydescription,[weight] FROM branchRatingMasterNEW WHERE TYPE='A') x
					 INNER JOIN 
					  (
					 SELECT SUBSTRING( displayorder, 1,1) sn , ROUND(SUM( CAST ([weight] AS MONEY ) *score/100.00),2) score FROM 
					 branchRatingMasterNEW b WITH (NOLOCK) INNER JOIN branchRatingNEW  bd WITH (NOLOCK) 
					 ON b.rowid=bd.brMasterId
					 AND brDetailid=@brDetailId
					 GROUP BY SUBSTRING ( displayorder, 1,1)
					 ) y ON x.displayorder=y.sn ) zz
					, branchScoremaster s WHERE zz.score BETWEEN s.scorefrom AND s.scoreto
				
				EXEC proc_errorHandler 0, 'Branch Rating Summary added successfully.', @branchId
				
		END
		ELSE IF @flag='inactive'
		BEGIN
			BEGIN TRANSACTION
			
				UPDATE branchratingdetailNEW
				set isactive=@isActive
				WHERE branchId=@branchId  And ratingId=@brDetailId	
																							
				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
				EXEC proc_errorHandler 0, 'Record has been updated successfully.', @brDetailId
		
		END
		
		----DISPLAY GRID FOR RM 
		IF @flag='rbd_rm' -- Rating branch details
		BEGIN
		DECLARE @userType VARCHAR(5)
		SELECT @userType=userType,@rmBranchId=agentId FROM applicationUsers WHERE userName=@user
		CREATE TABLE #rmBranch (agentId INT,agentName VARCHAR(100))
		
		IF @userType = 'RH'
		BEGIN
				INSERT INTO #rmBranch
				SELECT distinct
					branch.agentId, branch.agentName 
				FROM (
					SELECT
						am.agentId 
						,am.agentName
					FROM agentMaster am WITH(NOLOCK)
					INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
					WHERE rba.agentId = @rmBranchId 
					AND ISNULL(rba.isDeleted, 'N') = 'N'
					AND ISNULL(rba.isActive, 'N') = 'Y'
					
					UNION ALL
					SELECT agentId, agentName
					FROM agentMaster WITH(NOLOCK) WHERE agentId = @rmBranchId
				) branch 
			END
			ELSE
			BEGIN
			
				INSERT INTO #rmBranch
				SELECT agentId, agentName
				FROM agentMaster WITH(NOLOCK) WHERE agentId = @rmBranchId
			
			END
			
			SET @hasRight='N'			
			IF @userType = 'RH'
				SET @hasRight = dbo.FNAHasRight(@user, '40241210')-- Rating				
			
			SET @reviewRight = 'N'-- Review
			
			
			SELECT a.brdetailid,operations,[security],compliance,overall  INTO  #RATINGDETAIL from 
			  (select  brDetailId,operations=dbo.FNAGetBranchRatingNEW('merge','Operation-General',brDetailId) from branchRatingSummaryNEW  WITH(NOLOCK) where riskcategory='Operation-General') A  
			  LEFT JOIN (select  brDetailId,  [security]=dbo.FNAGetBranchRatingNEW('merge','Security-Maintenance',brDetailId) from branchRatingSummaryNEW  WITH(NOLOCK) where riskcategory='Security-Maintenance')B on B.brDetailId=a.brDetailId
			  LEFT JOIN (select  brDetailId,  compliance=dbo.FNAGetBranchRatingNEW('merge','Compliance-Regulatory',brDetailId) from branchRatingSummaryNEW  WITH(NOLOCK) where riskcategory='Compliance-Regulatory') C on C.brDetailId=a.brDetailId			  
			  LEFT JOIN (select  brDetailId,  overall=dbo.FNAGetBranchRatingNEW('merge','overall',brDetailId) from branchRatingSummaryNEW  WITH(NOLOCK) where riskcategory='overall') E on E.brDetailId=a.brDetailId
			  
			  
				
			SET @table = '(
					SELECT
						 brDetailid = brd.ratingId
						,brd.branchId
						,branchName = am.agentName 						
						,brd.fromDate
						,brd.toDate
						,operations,security ,compliance ,overall
						,others = ''''						
						,brd.createdBy
						,brd.createdDate						
						,rankedBy = brd.ratingBy
						,rankingDate  = brd.ratingDate
						,reviewedDate = brd.reviewedDate
						,brd.reviewerComment
						,brd.approvedBy
						,brd.approvedDate
						,approverComment
						,brd.isActive																	
						,scorelink =
						
							CASE WHEN brd.isActive=''y'' AND brd.ratingDate IS NULL AND brd.reviewedDate IS NULL AND brd.approvedDate IS NULL THEN 
							CASE WHEN '''+@hasRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=rating&brId=''+CAST(brd.ratingId AS VARCHAR)+''&bId=''+CAST(brd.branchId AS VARCHAR)
							    +''&bName=''+CAST(am.agentName AS VARCHAR)
								+''&ron=''+ISNULL(CAST(brd.reviewedDate AS VARCHAR),'''')
								+''&r=''+CAST(ISNULL(brd.reviewedBy,'''') AS VARCHAR)
								+''&rPeriod=''+CAST(brd.fromDate AS VARCHAR)+'' to ''+ CAST(brd.toDate AS VARCHAR)								
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')								
								+''">Rating</a>&nbsp;''							
							ELSE ''
							
							<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp; 
							
							''
							END													 							
							WHEN brd.isActive=''y'' AND brd.ratingDate IS NOT NULL AND brd.ratingComment IS NULL THEN 
							''<a href="Manage.aspx?type=branchcomment&brId=''+CAST(brd.ratingId AS VARCHAR)+''&bId=''+CAST(brd.branchId AS VARCHAR)
							    +''&bName=''+CAST(am.agentName AS VARCHAR)
								+''&ron=''+ISNULL(CAST(brd.reviewedDate AS VARCHAR),'''')
								+''&r=''+CAST(ISNULL(brd.reviewedBy,'''') AS VARCHAR)
								+''&rPeriod=''+CAST(brd.fromDate AS VARCHAR)+'' to ''+ CAST(brd.toDate AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Add Comment</a>&nbsp;''							
							WHEN brd.isActive=''y'' and brd.ratingDate is not null AND brd.ratingComment IS NOT NULL AND brd.reviewedBy is null then 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN 
							''<a href="Manage.aspx?type=review&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
							    +''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Review</a>&nbsp;''							
							ELSE '' 
							<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp; 

							''
							END							
							WHEN brd.isActive=''y'' and brd.reviewedDate is not null AND brd.approvedDate is null and brd.reviewedBy<>'''+@user+''' then 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=approve&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
							    +''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Approve</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)+''"></a>&nbsp;''
							ELSE ''
							
							<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp;
							
							''
							END												
							ELSE
							''<a href="Manage.aspx?type=riskhistory&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)
								+''&bName=''+cast(am.agentName as varchar)
								+''&ron=''+isnull(cast(brd.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(brd.reviewedBy,'''') as varchar)
								+''&rPeriod=''+cast(brd.fromDate as varchar)+'' to ''+ cast(brd.toDate as varchar)
								+''&ratedby=''+CAST(ISNULL(brd.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(brd.ratingDate AS VARCHAR),'''')
								+''&appby=''+CAST(ISNULL(brd.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(brd.approvedDate AS VARCHAR),'''')
								+''">Details</a>&nbsp;''
							
							+ CASE WHEN isnull(brd.isActive,''y'')=''y'' THEN
							+ ''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&brId=''+CAST(brd.ratingId as varchar)+''&bId=''+cast(brd.branchId as varchar)+''"></a>''
							ELSE '''' END
							
							END
					FROM branchratingdetailNEW brd WITH(NOLOCK)
					INNER JOIN agentMaster am on am.agentId=brd.branchId
					INNER JOIN #rmBranch T ON T.agentId = brd.branchId
					LEFT JOIN #RATINGDETAIL rd WITH(NOLOCK) ON brd.ratingId = rd.brdetailid
					WHERE 1 = 1
						) x'
						
			
			
			print 	@table														
			SET @sql_filter = ''
			
				
			IF @agentID is not NULL
				SET @sql_filter=@sql_filter+'  And branchId =  '''+CAST(@agentID AS VARCHAR)+''''
				
				
			IF @fromDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND fromDate BETWEEN ''' + CONVERT(VARCHAR, @fromDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @fromDate, 101) + ' 23:59:59'''
		
		    IF @toDate IS NOT NULL AND @toDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND toDate BETWEEN ''' + CONVERT(VARCHAR, @toDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @toDate, 101) + ' 23:59:59'''
				
			
			IF @reviewedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND reviewedDate BETWEEN ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ' 23:59:59'''
			
			
			IF @approvedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR, @approvedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @approvedDate, 101) + ' 23:59:59'''		
		
			
			
			IF @isActive IS NOT NULL AND @isActive<>'All'
				SET @sql_filter = @sql_filter + ' And isActive='''+@isActive+''''			
			ELSE IF @isActive IS NULL
				SET @sql_filter = @sql_filter + ' And isActive=''1'''			
							
				
			IF @rating is not NULL
				SET @sql_filter=@sql_filter+'  And dbo.FNAGetBranchRatingNEW(''rating'','''+@category+''',x.brDetailid) =  '''+CAST(@rating AS VARCHAR)+''''	
					
			print @table+''+@sql_filter	
			
			
			SET @select_field_list ='
				 brDetailid
				,branchId
				,branchName
				,rankedBy				
				,rankingDate
				,fromDate
				,toDate
				,operations
				,security
				,compliance				
				,overall
				,others
				,reviewedDate
				,approvedDate
				,createdBy
				,scorelink '
				
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
				
		
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @branchId
END CATCH
GO
