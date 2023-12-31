USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentRating]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_agentRating]
(
		@flag					VARCHAR(50)			= NULL
		,@arDetailId			VARCHAR(50)			= NULL	
--		,@branchId				VARCHAR(50)			= NULL
		,@rmBranchId			INT					= NULL
		,@agentID				INT					= NULL
		,@agentId1				INT					= NULL
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
		,@agentType				VARCHAR(10)			= NULL
		,@ratingBy				VARCHAR(50)			= NULL
		,@ardId					VARCHAR(10)			= NULL 
	
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
		,@hasRight			CHAR(1)
		,@reviewRight		CHAR(1)
		,@approveRight		CHAR(1)
		,@initiateRight		CHAR(1)
		,@batchId			INT
		,@startIndex		INT
		,@catFlag			INT
		,@catCount			INT
		,@subCatFlag		INT
		,@subCatCount		INT
		,@SubCatExists		CHAR(1)
		,@ratingIDs			VARCHAR(MAX)

		IF @flag = 'i'
		BEGIN
			-- select * from agentratingdetail
			IF EXISTS (SELECT 'x' FROM agentRatingDetail WITH(NOLOCK) WHERE agentId=@agentID and approvedBy is null and isnull(isActive,'Y')='Y')
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, there is already active assessement exists for this agent, which has not been approved yet. Please kindly do inactive or review the existing record and try again.', @agentID
				RETURN
			END		
			IF EXISTS (SELECT 'x' FROM agentRatingDetail WITH(NOLOCK) WHERE agentId=@agentID AND ISNULL(isActive,'Y')='Y' AND toDate>=@fromDate)
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, Assessement is already exists for this date. Please kindly another date.', @agentID
				RETURN
			END
			
			BEGIN TRANSACTION

				SELECT @batchId = ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT))

				INSERT INTO agentRatingDetail (					
					agentId
					,agentType
					,fromDate
					,toDate
					,createdBy
					,createdDate					
					,isActive
					,batchId
				)
				SELECT
					@agentID
					,@agentType
					,@fromDate
					,@toDate
					,@user
					,GETDATE()					
					,@isActive
					,@batchId					
			
			----- Create agent rating template for all branch -----
			IF OBJECT_ID('tempdb..#agentBranchTbl') IS NOT NULL
				DROP TABLE #agentBranchTbl

			CREATE TABLE #agentBranchTbl(rowId INT IDENTITY(1,1),branchId INT,branchName VARCHAR(100),parentId INT)
			
			INSERT INTO #agentBranchTbl
			SELECT DISTINCT
			 branchId= am.agentId
			,branchName = am.agentName
			,@agentID
			FROM agentMaster am WITH(NOLOCK)
			WHERE am.agentCountry='Malaysia' AND agentType = 2904 AND parentId = @agentId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y'
			
			IF EXISTS(SELECT 'X' FROM #agentBranchTbl WHERE parentId = @agentID)
			BEGIN
					DECLARE @sIndex INT = 1, @rCount INT

					SELECT @rCount = COUNT(rowid) FROM #agentBranchTbl

					IF(@rCount=1)
					BEGIN
						DECLARE @branchId VARCHAR(50)
						SELECT @branchId=branchId FROM #agentBranchTbl WHERE parentId = @agentID
						UPDATE agentRatingDetail SET branchId=@branchId,hasSingleBranch='Y' WHERE agentId = @agentID
					END
					ELSE
					BEGIN
						WHILE (@sIndex <= @rCount)
						BEGIN
							INSERT INTO agentRatingDetail (					
								 agentId
								,agentType
								,fromDate
								,toDate
								,createdBy
								,createdDate					
								,isActive
								,branchId
								,batchId
							)
							SELECT
								@agentID
								,@agentType
								,@fromDate
								,@toDate
								,@user
								,GETDATE()					
								,@isActive
								,branchId
								,@batchId
								FROM #agentBranchTbl WHERE rowId = @sIndex

							SET @sIndex = @sIndex + 1 
						END 
					END
			END 
			
			
													
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentID
		END
					
		ELSE IF @flag='rad' -- Rating agent details : Branch List
		BEGIN
			SET @sortBy = 'agentName'			
			SET @initiateRight = dbo.FNAHasRight(@user, '20191210')		--Intiate
			SET @hasRight = dbo.FNAHasRight(@user, '20191220')			--Rating
			SET @reviewRight = dbo.FNAHasRight(@user, '20191230')		--Review
			SET @approveRight = dbo.FNAHasRight(@user, '20191240')		--Approve
			
			

			SELECT a.ardetailid,general,operations,security,compliance,others,overall  INTO  #RATINGDETAIL from 
				 (select  ardetailid,  general=dbo.FNAGetAgentRating('merge','general',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='General') A  
			  LEFT JOIN (select  ardetailid,  operations=dbo.FNAGetAgentRating('merge','operations',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='operations')B on B.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  security=dbo.FNAGetAgentRating('merge','security',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='security') C on C.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  compliance=dbo.FNAGetAgentRating('merge','compliance',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='compliance') D on D.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  others=dbo.FNAGetAgentRating('merge','others',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='others') E on E.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  overall=dbo.FNAGetAgentRating('merge','overall',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='overall') F on F.ardetailid=a.ardetailid
			  
			SET @table = '(
				SELECT
					 arDetailid = ard.ratingId
					,ard.agentId,am.agentName ,branchName= ISNULL(m.agentName,'''')	,ard.fromDate,ard.toDate,general,operations,security ,compliance ,others,overall 
					,ard.createdBy,ard.createdDate,rankedBy = ard.ratingBy,rankingDate  = ard.ratingDate,reviewedDate = ard.reviewedDate,ard.reviewerComment
					,ard.approvedBy,ard.approvedDate,approverComment,ard.isActive									
					,scorelink = 
						CASE 
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NULL AND ard.reviewedDate IS NULL AND ard.approvedDate IS NULL THEN 
							CASE WHEN '''+@hasRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=rating&arId=''+CAST(ard.ratingId AS VARCHAR)+''&aId=''+CAST(ard.agentId AS VARCHAR)
							+''">Rating</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId AS VARCHAR)+''&aId=''+CAST(ard.agentId AS VARCHAR)+''">Mark Inactive</a>&nbsp;''
							ELSE ''''
							END
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NOT NULL AND ard.reviewedBy IS NULL THEN 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=review&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							+''">Review</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''
							<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							+''">Details</a>&nbsp;
								''
							END
							WHEN ard.isActive=''y'' AND ard.reviewedDate IS NOT NULL AND ard.approvedDate IS NULL AND ard.reviewedBy <> ''' + @user + ''' THEN 
							CASE WHEN '''+@approveRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=approve&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							+''">Approve</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''
								<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''">Details</a>&nbsp;
								''
							END
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NOT NULL THEN
							+ ''<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							+''">Details</a>&nbsp;|&nbsp;''
							+case when isnull(ard.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>''
							ELSE '''' END
							ELSE ''
								<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''">Details</a>&nbsp;|&nbsp;''
							+case when isnull(ard.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>''
							ELSE '''' END
						END
				FROM agentRatingDetail ard WITH(NOLOCK)
				INNER JOIN agentListRiskProfile am WITH(NOLOCK) ON am.agentId=ard.agentId
				LEFT JOIN #RATINGDETAIL rd WITH(NOLOCK) ON ard.ratingId = rd.ardetailid
				INNER JOIN agentMaster m on m.agentId= ard.branchId
				WHERE 1 = 1 AND ISNULL(ard.branchId,'''') <> '''') x'
						
													
			SET @sql_filter = ''
			
				
			IF @agentID is not NULL
				SET @sql_filter=@sql_filter+'  And agentId =  '''+CAST(@agentID AS VARCHAR)+''''
				
			IF @agentID1 is not NULL
				SET @sql_filter=@sql_filter+'  And agentId =  '''+CAST(@agentID1 AS VARCHAR)+''''
					
			IF @fromDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND fromDate BETWEEN ''' + CONVERT(VARCHAR, @fromDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @fromDate, 101) + ' 23:59:59'''
		
		    IF @toDate IS NOT NULL AND @toDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND toDate BETWEEN ''' + CONVERT(VARCHAR, @toDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @toDate, 101) + ' 23:59:59'''
				
			
			IF @reviewedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND reviewedDate BETWEEN ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ' 23:59:59'''
			
			
			IF @approvedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR, @approvedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @approvedDate, 101) + ' 23:59:59'''		
		
		
			--IF @category is not NULL
			--	SET @sql_filter=@sql_filter+'  And riskCategory =  '''+CAST(@category AS VARCHAR)+''''
			
			
			IF @isActive IS NOT NULL AND @isActive<>'All'
				SET @sql_filter = @sql_filter + ' And isActive='''+@isActive+''''			
			ELSE IF @isActive IS NULL
				SET @sql_filter = @sql_filter + ' And isActive=''1'''						
		
			
			--IF @score is not NULL
			--	-- SET @sql_filter=@sql_filter+'  And score =  '''+ @score +''''	
			--	SET @sql_filter=@sql_filter+'  And score ='''+ CAST(@score AS VARCHAR)+''' ' 	
				
			IF @rating is not NULL
				SET @sql_filter=@sql_filter+'  And dbo.FNAGetAgentRating(''rating'','''+@category+''',x.arDetailid) =  '''+CAST(@rating AS VARCHAR)+''''	
					
			--print @table+''+@sql_filter	
			
			
			SET @select_field_list ='
				 arDetailid
				,agentId
				,agentName
				,branchName
				,rankedBy				
				,rankingDate
				,fromDate
				,toDate
				,general
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
		
		ELSE IF @flag='rad-agent' -- Rating agent details : Agent List
		BEGIN
			SET @sortBy = 'agentName'			
			SET @initiateRight = dbo.FNAHasRight(@user, '20191210')		--Intiate
			SET @hasRight = dbo.FNAHasRight(@user, '20191220')			--Rating
			SET @reviewRight = dbo.FNAHasRight(@user, '20191230')		--Review
			SET @approveRight = dbo.FNAHasRight(@user, '20191240')		--Approve			
			
			
			SELECT a.ardetailid,general,operations,security,compliance,others,overall  INTO  #RatingDetailBranch from 
				 (select  ardetailid,  general=dbo.FNAGetAgentRating('merge','general',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='General') A  
			  LEFT JOIN (select  ardetailid,  operations=dbo.FNAGetAgentRating('merge','operations',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='operations')B on B.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  security=dbo.FNAGetAgentRating('merge','security',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='security') C on C.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  compliance=dbo.FNAGetAgentRating('merge','compliance',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='compliance') D on D.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  others=dbo.FNAGetAgentRating('merge','others',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='others') E on E.ardetailid=a.ardetailid
			  LEFT JOIN (select  ardetailid,  overall=dbo.FNAGetAgentRating('merge','overall',ardetailid) from agentratingsummary  WITH(NOLOCK) where riskcategory='overall') F on F.ardetailid=a.ardetailid
			 
			SET @table = '(
				SELECT
					 arDetailid = ard.ratingId,ard.agentId,agentName=''<a href="List.aspx?aId=''+CAST(ard.agentId AS VARCHAR)+''">''+am.agentName+''</a>''
					,ard.fromDate,ard.toDate,general,operations,security ,compliance ,others,overall
					,ard.createdBy,ard.createdDate,rankedBy = ard.ratingBy,rankingDate  = ard.ratingDate
					,reviewedDate = ard.reviewedDate,ard.reviewerComment,ard.approvedBy,ard.approvedDate,approverComment,ard.isActive
					,scorelink = 
						CASE 
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NULL AND ard.reviewedDate IS NULL AND ard.approvedDate IS NULL THEN 
							CASE WHEN '''+@hasRight+'''=''Y'' AND dbo.FNAGetAgentRatingUtilities(''getlabel'',ard.batchId)<>'''' THEN
							''<a href="PreviewAndRateAgent.aspx?type=rating&arId=''+CAST(ard.ratingId AS VARCHAR)+''&aId=''+CAST(ard.agentId AS VARCHAR)
								+''&aName=''+CAST(am.agentName AS VARCHAR)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
								+''&ron=''+ISNULL(CAST(ard.reviewedDate AS VARCHAR),'''')
								+''&r=''+CAST(ISNULL(ard.reviewedBy,'''') AS VARCHAR)
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+CAST(ard.fromDate AS VARCHAR)+'' to ''+ CAST(ard.toDate AS VARCHAR)
								+''">''+dbo.FNAGetAgentRatingUtilities(''getlabel'',ard.batchId)+''</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId AS VARCHAR)+''&aId=''+CAST(ard.agentId AS VARCHAR)+''">Mark Inactive</a>&nbsp;''
							ELSE ''''
							END
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NOT NULL AND ard.reviewedBy IS NULL THEN 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN
							''<a href="PreviewAndRateAgent.aspx?type=review&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Review</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''
								<a href="PreviewAndRateAgent.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Details</a>&nbsp;
								''
							END
							WHEN ard.isActive=''y'' AND ard.reviewedDate IS NOT NULL AND ard.approvedDate IS NULL AND ard.reviewedBy <> ''' + @user + ''' THEN 
							CASE WHEN '''+@approveRight+'''=''Y'' THEN
							''<a href="PreviewAndRateAgent.aspx?type=approve&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Approve</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''
								<a href="PreviewAndRateAgent.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Details</a>&nbsp;
								''
							END
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NOT NULL THEN
							+ ''<a href="PreviewAndRateAgent.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							+''&aName=''+cast(am.agentName as varchar)
							+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
							+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
							+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
							+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
							+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
							+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
							+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
							+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)							
							+''">Details</a>&nbsp;|&nbsp;''
							+case when isnull(ard.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>''
							ELSE '''' END
							ELSE ''
								<a href="PreviewAndRateAgent.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Details</a>&nbsp;|&nbsp;''
							+case when isnull(ard.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''">Mark Inactive</a>''
							ELSE '''' END
						END
				FROM agentRatingDetail ard WITH(NOLOCK)
				INNER JOIN agentListRiskProfile am WITH(NOLOCK) ON am.agentId=ard.agentId
				LEFT JOIN #RatingDetailBranch rd WITH(NOLOCK) ON ard.ratingId = rd.ardetailid
				WHERE 1 = 1 AND (ISNULL(ard.branchId,'''') = '''' OR hasSingleBranch=''Y'')) x'
						
			
			--print (@table)													
			SET @sql_filter = ''
			
				
			IF @agentID is not NULL
				SET @sql_filter=@sql_filter+'  And agentId =  '''+CAST(@agentID AS VARCHAR)+''''
				
				
			IF @fromDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND fromDate BETWEEN ''' + CONVERT(VARCHAR, @fromDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @fromDate, 101) + ' 23:59:59'''
		
		    IF @toDate IS NOT NULL AND @toDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND toDate BETWEEN ''' + CONVERT(VARCHAR, @toDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @toDate, 101) + ' 23:59:59'''
				
			
			IF @reviewedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND reviewedDate BETWEEN ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ' 23:59:59'''
			
			
			IF @approvedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR, @approvedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @approvedDate, 101) + ' 23:59:59'''		
		
		
			--IF @category is not NULL
			--	SET @sql_filter=@sql_filter+'  And riskCategory =  '''+CAST(@category AS VARCHAR)+''''
			
			
			IF @isActive IS NOT NULL AND @isActive<>'All'
				SET @sql_filter = @sql_filter + ' And isActive='''+@isActive+''''			
			ELSE IF @isActive IS NULL
				SET @sql_filter = @sql_filter + ' And isActive=''1'''						
		
			
			--IF @score is not NULL
			--	-- SET @sql_filter=@sql_filter+'  And score =  '''+ @score +''''	
			--	SET @sql_filter=@sql_filter+'  And score ='''+ CAST(@score AS VARCHAR)+''' ' 	
				
			IF @rating is not NULL
				SET @sql_filter=@sql_filter+'  And dbo.FNAGetAgentRating(''rating'','''+@category+''',x.arDetailid) =  '''+CAST(@rating AS VARCHAR)+''''	
			
			SET @select_field_list ='
				 arDetailid
				,agentId
				,agentName
				,rankedBy				
				,rankingDate
				,fromDate
				,toDate
				,general
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
		
		ELSE IF @flag='rc' -- Rating Criteria
		BEGIN
			DECLARE @ctScript VARCHAR(MAX)
			IF OBJECT_ID('tempdb..##tmpTable') IS NOT NULL
			BEGIN
				DROP TABLE ##tmpTable
			END
			
			CREATE TABLE ##tmpTable(
				rowId			INT IDENTITY(1,1),
				[type]			VARCHAR(10), 
				displayOrder	VARCHAR(10),
				[weight]		MONEY,
				[description]	VARCHAR(2500),
				[summaryDescription]	VARCHAR(250),
				[ParentId]		VARCHAR(10)
				)

			IF ISNULL(@agentType,'') = ''
			BEGIN
				SELECT @agentType = agentType FROM agentratingdetail WITH(NOLOCK) WHERE ratingId = @arDetailId 
			END

			SET @startIndex = 1
			IF ISNULL(@agentType,'') <> ''
			BEGIN
				-- Full Agent:70;HYBRID:135;Hotel:198

				SELECT @startIndex = MIN(rowId) FROM agentRatingMaster WITH(NOLOCK) WHERE agentType = @agentType
				--DBCC CHECKIDENT (##tmpTable, reseed, @startIndex)
				
				IF OBJECT_ID('tempdb..##tmpTable') IS NOT NULL
				BEGIN
					DROP TABLE ##tmpTable
				END

				SET @ctScript = '	
				CREATE TABLE ##tmpTable(
				rowId			INT IDENTITY(' + CAST(@startIndex AS VARCHAR) + ',1),
				[type]			VARCHAR(10), 
				displayOrder	VARCHAR(10),
				[weight]		MONEY,
				[description]	VARCHAR(2500),
				[summaryDescription]	VARCHAR(250),
				[ParentId]		VARCHAR(10)
				)
				'
				
				EXEC (@ctScript)		
			END	

			--DECLARE @catFlag INT, @catCount INT,@subCatFlag INT, @subCatCount INT, @SubCatExists CHAR(1)
			SET @catFlag = 1
			SET @catCount=(SELECT COUNT(rowId) FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='A' AND ISNULL(agentType,'')=ISNULL(@agentType,''))
			
			WHILE (@catFlag <=@catCount)
				BEGIN

					INSERT INTO ##tmpTable
					SELECT [type],displayOrder,[weight],[description],summaryDescription,'' FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='A' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND
					displayOrder= @catFlag

					SET @subCatFlag = 1
					SET @subCatCount=(SELECT COUNT(rowId) FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='B' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND
					displayOrder LIKE CAST(@catFlag AS VARCHAR)+'.%') --AND CHARINDEX('.',displayOrder)>0)
					
					IF @subCatCount=0
					BEGIN
						SET @subCatCount=1
						SET @SubCatExists='N'
					END
					ELSE
						SET @SubCatExists='Y'
						
					WHILE (@subCatFlag <=@subCatCount)
						BEGIN
							--print @SubCatExists+' '+CAST(@subCatCount AS VARCHAR)
							
							IF(@SubCatExists='Y')
							BEGIN
								INSERT INTO ##tmpTable
								SELECT [type],displayOrder,[weight],[description],'',CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)
								FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='B' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND 
								displayOrder= CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)
							END
							ELSE
							BEGIN
								INSERT INTO ##tmpTable
								SELECT 'B',CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR),null,'','',CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)								
							END
							
							INSERT INTO ##tmpTable
							SELECT [type],ROW_NUMBER() OVER(ORDER BY displayOrder) AS displayOrder,[weight],[description],'',
							CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR) 
							FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='C' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND
							displayOrder LIKE CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)+'.%'
							ORDER BY displayOrder
							
							SET @subCatFlag = @subCatFlag + 1 -- sub cat loop
						END
						
					SET @catFlag = @catFlag + 1 -- main loop
				END
				
				
			IF EXISTS (SELECT 'x' FROM agentRating WITH(NOLOCK) WHERE arDetailid=@arDetailId)
				BEGIN
				
				DECLARE @branchCount INT,@isBranch CHAR(1),@branchRatingId INT = 0

				SELECT @batchId = batchId
				,@isBranch = CASE  WHEN ISNULL(branchId,'')= '' THEN 'N'  ELSE 'Y' END 
				FROM agentratingdetail WHERE ratingId = @arDetailId 

				IF @isBranch='N'
				BEGIN
					SELECT @branchCount = COUNT('x') FROM agentratingdetail WHERE batchID = @batchId AND ISNULL(branchId,'') <> ''
					IF @branchCount=1
						SELECT @branchRatingId = ratingId FROM agentratingdetail WHERE batchID = @batchId AND ISNULL(branchId,'') <> ''
					
				END
				ELSE
					SET @branchCount = 0

				SELECT
				am.rowId
				,am.[type]
				,am.displayOrder
				,am.[weight]
				,am.[description]
				,am.summaryDescription
				,am.ParentId							
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
				 FROM ##tmpTable am WITH(NOLOCK)
				 LEFT JOIN 
				 (
					 SELECT rowId,ar.arMasterId,ar.Score
					 ,remarks = CASE  
								WHEN @isBranch='N' AND @branchCount = 1  THEN 
								(SELECT remarks FROM agentRating x
									INNER JOIN agentRatingDetail y
								 ON					 
								 x.arDetailid=y.ratingId
								 WHERE y.ratingId=@branchRatingId and x.arMasterId=ar.arMasterId)

								ELSE ar.remarks END

					 ,ard.isActive,ard.reviewedBy,ard.reviewedDate,ard.reviewerComment,ard.approvedBy,ard.approvedDate,ard.approverComment,ard.ratingBy,ard.ratingDate,ratingComment = ard.agentRatingComment FROM 
					 agentRating ar WITH(NOLOCK) 
					 INNER JOIN agentRatingDetail ard WITH(NOLOCK)
					 ON					 
					 ar.arDetailid=ard.ratingId
					 WHERE --ard.isActive='y' and 
					 ard.ratingId=@arDetailId
				 					
				 ) x ON x.arMasterId= am.rowId
				--WHERE x.isActive='Y' 
				ORDER BY rowId
			
			SELECT rowId, arMasterId,arDetailId,riskCategory, ROUND(score,2) AS score, rating FROM agentRatingSummary where arDetailid=@arDetailId
				
			END
			ELSE
				BEGIN
							
				SELECT *,'' score,'' remarks,'' reviewedBy,'' reviewedDate,'' reviewerComment,'' approvedBy,'' approvedDate ,'' approverComment,'' ratingBy, '' ratingDate, '' ratingComment FROM ##tmpTable	ORDER BY rowId			
				SELECT rowId, arMasterId,arDetailId,riskCategory, ROUND(score,2) AS score, rating FROM agentRatingSummary where arDetailid=@arDetailId
			END
				
			DROP TABLE ##tmpTable
			
			SELECT * FROM agentScoremaster
				
		END		
		
		ELSE IF @flag = 'i-ar'
		BEGIN
			
			IF EXISTS(SELECT 'X' FROM dbo.agentRatingDetail WITH (NOLOCK) WHERE ratingId = @arDetailId AND branchId IS NULL) -- Check if rating is for Branch or Agent.
			BEGIN
				SELECT @batchId = batchId FROM agentRatingDetail WITH(NOLOCK) WHERE ratingId = @arDetailId

				IF EXISTS(SELECT 'X' FROM dbo.agentRatingDetail WITH (NOLOCK) WHERE batchId = @batchId AND branchId IS NOT NULL AND ratingDate IS NULL)
				BEGIN
					EXEC proc_errorHandler 1, 'Sorry, Branch rating is not completed yet. Please complete branch rating first and try again later.', @agentID
				END
			END

			BEGIN TRANSACTION
				
				IF EXISTS (SELECT 'x' FROM agentRating WITH(NOLOCK) WHERE arDetailid=@arDetailId)
				BEGIN					
					DELETE FROM agentRating WHERE arDetailid=@arDetailId					
				END
						
							
				INSERT INTO agentRating(					
					arMasterId
					,arDetailid
					,score
					,remarks
					,modifiedBy
					,modifieddate					
				)
				SELECT
				 p.value('@rowId','VARCHAR(50)')
				,p.value('@arDetaildId','VARCHAR(50)')
				,p.value('@score','VARCHAR(50)')				
				,p.value('@remarks','VARCHAR(2500)')
				,@user
				,GETDATE()				
				FROM @xml.nodes('/root/row') AS tmp(p)

				UPDATE agentRatingDetail
					set modifiedBy = @user
					,modifiedDate = GETDATE()
					,ratingDate = CASE WHEN @isRatingCompleted='Y' THEN GETDATE() ELSE NULL END
					,ratingBy = CASE WHEN @isRatingCompleted='Y' THEN @ratingBy	ELSE NULL END				
					--,ratingComment=@ratingComment
					WHERE ratingId = @arDetailId			  				

			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentID
			EXEC proc_agentRating @flag = 'rc', @user=@user,@agentId=@agentID,@arDetailId=@arDetailId
		END
		ELSE IF @flag = 'agentcomment'
		BEGIN
		
			UPDATE agentRatingDetail
					set 
					--modifiedBy=@user
					--,modifiedDate=GETDATE()
					--ratingBy=@user
					--,ratingDate=GETDATE()
						 agentRatingComment = @ratingComment
						,reviewedByAgent	= @user
						,reviewedDateAgent	= GETDATE()
					WHERE ratingId = @arDetailId	
					
		EXEC proc_errorHandler 0, 'Agent Comment Added  successfully.', @arDetailId	
		
		END
		ELSE IF @flag = 'review'
		BEGIN
		
			UPDATE agentRatingDetail
					set 
					--modifiedBy=@user
					--,modifiedDate=GETDATE()
					reviewedBy=@user
					,reviewedDate=GETDATE()
					,reviewerComment=@reviewerComment
					WHERE ratingId=@arDetailId	
					
		EXEC proc_errorHandler 0, 'Review Comment Added  successfully.', @arDetailId	
		
		END
		ELSE IF @flag = 'approve'
		BEGIN
		
			UPDATE agentRatingDetail
					set 
					--modifiedBy=@user
					--,modifiedDate=GETDATE()
					approvedBy=@user
					,approvedDate=GETDATE()
					,approverComment=@approverComment
					WHERE ratingId=@arDetailId	
					
		EXEC proc_errorHandler 0, 'Agent Rating Approved successfully.', @arDetailId	
		
		END
		ELSE IF @flag='ddlStatus'
		BEGIN
		
			SELECT 'All' [value], 'All' [text] UNION ALL
			SELECT 'Y' ,'Active' UNION ALL
			SELECT 'N','Inactive'
		
		END		
		ELSE IF @flag='ddlCategory'
		BEGIN		
			SELECT NULL [value] ,'All' [text] UNION ALL
			SELECT summaryDescription,summaryDescription FROM agentRatingMaster WHERE [type]='A' AND summaryDescription IS NOT NULL
			UNION ALL
			SELECT 'Overall','Overall'
		END
		ELSE IF @flag='ddlRating'
		BEGIN
		    		    
			SELECT NULL [value],'All' [text] UNION ALL
			SELECT rating,rating FROM agentScoremaster WHERE rating IS NOT NULL
		END
		ELSE IF @flag='ddlagentType'
		BEGIN		
			--SELECT 'Select' AS detailTitle  ,'' AS valueId, 1 As OrderType UNION ALL
			SELECT DISTINCT agentType AS detailTitle, agentType AS valueId FROM agentRatingMaster WHERE [type]='A' AND agentType IS NOT NULL
			ORDER BY agentType			
		END
		ELSE IF @flag='ddlratingby'
		BEGIN

			SELECT 
			 detailTitle = au.firstName + ISNULL(' ' + au.middleName, '') + ISNULL(' ' + au.lastName, '')		
			,valueId = au.userName
			FROM applicationUsers au
			INNER JOIN (
			SELECT
				arf.functionId functionId
				,aur.userId
			FROM applicationRoleFunctions arf WITH(NOLOCK)
			INNER JOIN applicationUserRoles aur WITH(NOLOCK) ON arf.roleId = aur.roleId
			INNER JOIN applicationRoles ar on  aur.roleId = ar.roleId 
			WHERE arf.roleId IN (SELECT roleId FROM applicationUserRoles)
			and  ar.roleType='H' AND functionId='20191220' --@roleType
		
			UNION
			SELECT
					auf.functionId  functionId
				,auf.userId
			FROM applicationUserFunctions auf WITH(NOLOCK)
			) x ON au.userId = x.userId
			WHERE x.functionId = '20191220'--@functionId
			ORDER BY au.firstName

		END
		ELSE IF @flag='summary'
		BEGIN
		    		    
			IF EXISTS (SELECT 'x' FROM agentRatingSummary WITH(NOLOCK) WHERE arDetailId=@arDetailId)
				BEGIN					
					DELETE FROM agentRatingSummary WHERE arDetailid=@arDetailId					
				END
				
				-- SELECT * FROM agentRatingSummary		
				/*		
				INSERT INTO agentRatingSummary(					
					arMasterId
					,arDetailId
					,riskCategory
					,score
					,rating
				)
				SELECT
				 p.value('@arMasterId','VARCHAR(50)')
				,@arDetailId
				,p.value('@riskCategory','VARCHAR(50)')
				,p.value('@score','VARCHAR(50)')				
				,p.value('@rating','VARCHAR(2500)')							
				FROM @xml.nodes('/root/row') AS tmp(p) */
				
				-- NEW Script to calculate summary
				
					 INSERT INTO agentratingsummary ( arMasterId ,arDetailId, riskCategory, score, rating)					 
					 SELECT x.rowid,@arDetailId arDetailId ,summarydescription,score,rating  FROM 

					 (SELECT  rowid,displayorder,summarydescription,[weight] FROM agentratingmaster WHERE TYPE='A' AND ISNULL(agentType,'') = ISNULL(@agentType,'')) x
					 inner join 
					  (
					 select substring ( displayorder, 1,1) sn , round(sum( cast(weight as money)  *score/100.00),2) score from 
					 agentratingmaster a with (nolock) inner join agentrating  ad with (nolock) 
					 on a.rowid=ad.armasterid
					 and ardetailid=@arDetailId
					 group by substring ( displayorder, 1,1)
					 ) y on x.displayorder=y.sn
					, agentscoremaster s where  y.score between s.scorefrom and s.scoreto

					UNION ALL

					 select 99,@arDetailId,'Overall', score ,rating  from 

					(
					 select   round(sum (score *cast (x.weight as money) /100.00),2)  score  from 

					 (select  rowid,displayorder,summarydescription,weight from agentratingmaster where type='A' AND ISNULL(agentType,'') = ISNULL(@agentType,'')) x
					 inner join 
					  (
					 select substring ( displayorder, 1,1) sn , round(sum( cast (weight as money ) *score/100.00),2) score from 
					 agentratingmaster a with (nolock) inner join agentrating  ad with (nolock) 
					 on a.rowid=ad.armasterid
					 and ardetailid=@arDetailId
					 group by substring ( displayorder, 1,1)
					 ) y on x.displayorder=y.sn ) zz
					, agentscoremaster s where zz.score between s.scorefrom and s.scoreto
				
				
				EXEC proc_errorHandler 0, 'Agent Rating Summary added successfully.', @agentID
				
		END
		ELSE IF @flag='inactive'
		BEGIN
			BEGIN TRANSACTION
			
				UPDATE agentRatingDetail
				set isactive=@isActive
				WHERE agentId=@agentID  And ratingId=@arDetailId	
																							
				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
				EXEC proc_errorHandler 0, 'Record has been updated successfully.', @arDetailId
		
		END		
		----DISPLAY GRID FOR RM 
		ELSE IF @flag='rad_rm' -- Rating Agent details
		BEGIN
			IF @sortBy IS NULL
				SET @sortBy = 'agentName'
			IF @sortOrder IS NULL
				SET @sortOrder = 'ASC'
		DECLARE @userType VARCHAR(5)
		--SELECT @userType=userType,@rmBranchId=agentId FROM applicationUsers WHERE userName=@user
		CREATE TABLE #rmBranch (agentId INT,agentName VARCHAR(100))
		
			--IF @userType = 'RH'
			--	BEGIN
			--		INSERT INTO #rmBranch
			--		SELECT distinct
			--			agent.agentId, agent.agentName 
			--		FROM (
			--			SELECT
			--				am.agentId 
			--				,am.agentName
			--			FROM agentMaster am WITH(NOLOCK)
			--			INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
			--			WHERE rba.agentId = @rmBranchId 
			--			AND ISNULL(rba.isDeleted, 'N') = 'N'
			--			AND ISNULL(rba.isActive, 'N') = 'Y'
						
			--			UNION ALL
			--			SELECT agentId, agentName
			--			FROM agentMaster WITH(NOLOCK) WHERE agentId = @rmBranchId
			--		) agent 
			--	END
			--ELSE
			--BEGIN
			
			--	INSERT INTO #rmBranch
			--	SELECT agentId, agentName
			--	FROM agentMaster WITH(NOLOCK) WHERE agentId = @rmBranchId
			
			--END
		
			INSERT INTO #rmBranch
			SELECT agentId, agentName
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @rmBranchId
			
			--SET @hasRight='N'
			--IF @userType = 'RH'			
				SET @hasRight = dbo.FNAHasRight(@user, '40241110')-- Rating
			SET @reviewRight = 'N'-- Review
				
			SET @table = '(
					SELECT
						 arDetailid = ard.ratingId
						,ard.agentId
						,agentName = am.agentName
						,ard.fromDate
						,ard.toDate
						,general=dbo.FNAGetAgentRating(''merge'',''general'',ard.ratingId)
						,operations=dbo.FNAGetAgentRating(''merge'',''operations'',ard.ratingId)
						,security=dbo.FNAGetAgentRating(''merge'',''security'',ard.ratingId)
						,compliance=dbo.FNAGetAgentRating(''merge'',''compliance'',ard.ratingId)
						,others=dbo.FNAGetAgentRating(''merge'',''others'',ard.ratingId)
						,overall=dbo.FNAGetAgentRating(''merge'',''overall'',ard.ratingId)
						,ard.createdBy
						,ard.createdDate
						,rankedBy = ard.ratingBy
						,rankingDate  = ard.ratingDate
						,reviewedDate = ard.reviewedDate
						,ard.reviewerComment
						,ard.approvedBy
						,ard.approvedDate
						,approverComment
						,ard.isActive
						,scorelink = 
							CASE WHEN ard.isActive=''y'' AND ard.ratingDate IS NOT NULL THEN 
							CASE WHEN '''+@hasRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=agentcomment&arId=''+CAST(ard.ratingId AS VARCHAR)+''&aId=''+CAST(ard.agentId AS VARCHAR)
							    +''&aName=''+CAST(am.agentName AS VARCHAR)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ron=''+ISNULL(CAST(ard.reviewedDate AS VARCHAR),'''')
								+''&r=''+CAST(ISNULL(ard.reviewedBy,'''') AS VARCHAR)								
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')								
								+''&rPeriod=''+CAST(ard.fromDate AS VARCHAR)+'' to ''+ CAST(ard.toDate AS VARCHAR)
								+''">Add Comment</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId AS VARCHAR)+''&aId=''+CAST(ard.agentId AS VARCHAR)+''"></a>&nbsp;''
							ELSE ''''
							END
							WHEN ard.isActive=''y'' AND ard.ratingDate IS NOT NULL AND ard.reviewedBy is null then 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=review&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							    +''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Review</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''"></a>&nbsp;''
							ELSE ''
							<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Details</a>&nbsp;
							''
							END
							when ard.isActive=''y'' and ard.reviewedDate is not null AND ard.approvedDate is null and ard.reviewedBy<>'''+@user+''' then 
							CASE WHEN '''+@reviewRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=approve&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							    +''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Approve</a>&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''"></a>&nbsp;''
							ELSE ''
							<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Details</a>&nbsp;
							''
							END
							WHEN ard.isActive=''y'' and ard.ratingDate IS NOT NULL THEN 
							+ ''<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
							+''&aName=''+cast(am.agentName as varchar)
							+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
							+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
							+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
							+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
							+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
							+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
							+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
							+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)							
							+''">Details</a>&nbsp;''
							else
							''<a href="Manage.aspx?type=riskhistory&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)
								+''&aName=''+cast(am.agentName as varchar)
								+''&atype=''+CAST(ISNULL(ard.agentType,'''') AS VARCHAR)
								+''&ron=''+isnull(cast(ard.reviewedDate as varchar),'''')
								+''&r=''+cast(isnull(ard.reviewedBy,'''') as varchar)
								+''&ratedby=''+CAST(ISNULL(ard.ratingBy,'''') AS VARCHAR)
								+''&ratedon=''+ISNULL(CAST(ard.ratingDate AS VARCHAR),'''')								
								+''&appby=''+CAST(ISNULL(ard.approvedBy,'''') AS VARCHAR)
								+''&appon=''+ISNULL(CAST(ard.approvedDate AS VARCHAR),'''')
								+''&rPeriod=''+cast(ard.fromDate as varchar)+'' to ''+ cast(ard.toDate as varchar)
								+''">Details</a>&nbsp;''
							+case when isnull(ard.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&arId=''+CAST(ard.ratingId as varchar)+''&aId=''+cast(ard.agentId as varchar)+''"></a>''
							else '''' end
							end
					FROM agentRatingDetail ard WITH(NOLOCK)
					INNER JOIN agentMaster am on am.agentId=ard.agentId
					INNER JOIN #rmBranch T ON T.agentId = ard.agentId
					WHERE 1 = 1
						) x'
						
			
			
			--print 	@table														
			SET @sql_filter = ''
			
				
			IF @agentID is not NULL
				SET @sql_filter=@sql_filter+'  And agentId =  '''+CAST(@agentID AS VARCHAR)+''''
				
				
			IF @fromDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND fromDate BETWEEN ''' + CONVERT(VARCHAR, @fromDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @fromDate, 101) + ' 23:59:59'''
		
		    IF @toDate IS NOT NULL AND @toDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND toDate BETWEEN ''' + CONVERT(VARCHAR, @toDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @toDate, 101) + ' 23:59:59'''
				
			
			IF @reviewedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND reviewedDate BETWEEN ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @reviewedDate, 101) + ' 23:59:59'''
			
			
			IF @approvedDate IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND approvedDate BETWEEN ''' + CONVERT(VARCHAR, @approvedDate, 101) + ''' AND ''' + CONVERT(VARCHAR, @approvedDate, 101) + ' 23:59:59'''		
		
		
			--IF @category is not NULL
			--	SET @sql_filter=@sql_filter+'  And operations =  '''+CAST(@category AS VARCHAR)+''''
			
			
			IF @isActive IS NOT NULL AND @isActive<>'All'
				SET @sql_filter = @sql_filter + ' And isActive='''+@isActive+''''			
			ELSE IF @isActive IS NULL
				SET @sql_filter = @sql_filter + ' And isActive=''Y'''			
							
		
			
			--IF @score is not NULL
			--	-- SET @sql_filter=@sql_filter+'  And score =  '''+ @score +''''	
			--	SET @sql_filter=@sql_filter+'  And score ='''+ CAST(@score AS VARCHAR)+''' ' 	
				
			IF @rating is not NULL
				SET @sql_filter=@sql_filter+'  And dbo.FNAGetAgentRating(''rating'','''+@category+''',x.arDetailid) =  '''+CAST(@rating AS VARCHAR)+''''	
					
			--print @table+''+@sql_filter	
			
			
			SET @select_field_list ='
				 arDetailid
				,agentId
				,agentName
				,rankedBy				
				,rankingDate
				,fromDate
				,toDate
				,general
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
		ELSE IF @flag in('rc-preview')
		BEGIN
			IF OBJECT_ID('tempdb..##tmpTablePreview') IS NOT NULL
			BEGIN
				DROP TABLE ##tmpTablePreview
			END

		    CREATE TABLE ##tmpTablePreview(
				rowId			INT IDENTITY(1,1),
				[type]			VARCHAR(10), 
				displayOrder	VARCHAR(10),
				[weight]		MONEY,
				[description]	VARCHAR(2500),
				[summaryDescription]	VARCHAR(250),
				[ParentId]		VARCHAR(10)
			)
			
			SET @startIndex = 1
			IF ISNULL(@agentType,'') <> ''
			BEGIN
				-- Full Agent:70;HYBRID:135;Hotel:198

				SELECT @startIndex = MIN(rowId) FROM agentRatingMaster WITH(NOLOCK) WHERE agentType = @agentType
				--DBCC CHECKIDENT (#tmpTablePreview, reseed, @startIndex)

				IF OBJECT_ID('tempdb..##tmpTablePreview') IS NOT NULL
				BEGIN
					DROP TABLE ##tmpTablePreview
				END

				SET @ctScript = '	
				CREATE TABLE ##tmpTablePreview(
				rowId			INT IDENTITY(' + CAST(@startIndex AS VARCHAR) + ',1),
				[type]			VARCHAR(10), 
				displayOrder	VARCHAR(10),
				[weight]		MONEY,
				[description]	VARCHAR(2500),
				[summaryDescription]	VARCHAR(250),
				[ParentId]		VARCHAR(10)
				)
				'
				
				EXEC (@ctScript)
			END			
						
			SET @catFlag = 1
			SET @catCount=(SELECT COUNT(rowId) FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='A' AND ISNULL(agentType,'')=ISNULL(@agentType,''))
			
			WHILE (@catFlag <=@catCount)
				BEGIN

					INSERT INTO ##tmpTablePreview
					SELECT [type],displayOrder,[weight],[description],summaryDescription,'' FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='A' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND
					displayOrder= @catFlag

					SET @subCatFlag = 1
					SET @subCatCount=(SELECT COUNT(rowId) FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='B' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND
					displayOrder LIKE CAST(@catFlag AS VARCHAR)+'.%') --AND CHARINDEX('.',displayOrder)>0)
					
					IF @subCatCount=0
					BEGIN
						SET @subCatCount=1
						SET @SubCatExists='N'
					END
					ELSE
						SET @SubCatExists='Y'
						
					WHILE (@subCatFlag <=@subCatCount)
						BEGIN
							--print @SubCatExists+' '+CAST(@subCatCount AS VARCHAR)
							
							IF(@SubCatExists='Y')
							BEGIN
								INSERT INTO ##tmpTablePreview
								SELECT [type],displayOrder,[weight],[description],'',CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)
								FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='B' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND 
								displayOrder= CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)
							END
							ELSE
							BEGIN
								INSERT INTO ##tmpTablePreview
								SELECT 'B',CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR),null,'','',CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)								
							END
							
							INSERT INTO ##tmpTablePreview
							SELECT [type],ROW_NUMBER() OVER(ORDER BY displayOrder) AS displayOrder,[weight],[description],'',
							CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR) 
							FROM agentRatingMaster WITH(NOLOCK) WHERE [type]='C' AND ISNULL(agentType,'')=ISNULL(@agentType,'') AND
							displayOrder LIKE CAST(@catFlag AS VARCHAR)+'.'+CAST(@subCatFlag AS VARCHAR)+'.%'
							ORDER BY displayOrder
							
							SET @subCatFlag = @subCatFlag + 1 -- sub cat loop
						END
						
					SET @catFlag = @catFlag + 1 -- main loop
				END
			
			SELECT @batchId = batchid FROM dbo.agentRatingDetail WHERE ratingId = @arDetailId AND branchId IS NULL

			IF OBJECT_ID('tempdb..#ratingIDs') IS NOT NULL
			DROP TABLE #ratingIDs

			SELECT ratingId INTO #ratingIDs FROM dbo.agentRatingDetail WHERE batchId=@batchId AND branchId IS NOT NULL

										
			IF EXISTS (SELECT 'x' FROM agentRating WITH(NOLOCK) WHERE arDetailid IN (SELECT ratingId FROM #ratingIDs))
				BEGIN
				
				SELECT
				am.rowId
				,am.[type]
				,am.displayOrder
				,am.[weight]
				,am.[description]
				,am.summaryDescription
				,am.ParentId							
				,score=dbo.ShowDecimal(x.Score)
				,'' AS remarks
				,x.reviewedBy
				,x.reviewedDate
				,x.reviewerComment
				,x.approvedBy
				,x.approvedDate
				,x.approverComment
				,x.ratingBy
				,x.ratingDate
				,x.ratingComment					
				 FROM ##tmpTablePreview am WITH(NOLOCK)
				 LEFT JOIN 
				 (
					 SELECT rowId,ar.arMasterId,Score = dbo.FNAGetAgentRatingMaxScore('preview',ar.arMasterId,@batchId),ar.remarks,ard.isActive,ard.reviewedBy,ard.reviewedDate,ard.reviewerComment,ard.approvedBy,ard.approvedDate,ard.approverComment,ard.ratingBy,ard.ratingDate,ratingComment = ard.agentRatingComment FROM 
					 agentRating ar WITH(NOLOCK) 
					 INNER JOIN agentRatingDetail ard WITH(NOLOCK)
					 ON					 
					 ar.arDetailid=ard.ratingId
					 WHERE ard.isActive='y' and ard.ratingId IN(SELECT TOP 1 ratingId FROM #ratingIDs)

					 --SELECT rowId,ar.arMasterId,x.Score,ar.remarks,ard.isActive,ard.reviewedBy,ard.reviewedDate,ard.reviewerComment,ard.approvedBy,ard.approvedDate,ard.approverComment,ard.ratingBy,ard.ratingDate,ratingComment = ard.agentRatingComment FROM 
						--agentRating ar WITH(NOLOCK) 
						--INNER JOIN agentRatingDetail ard WITH(NOLOCK)
						--ON					 
						--ar.arDetailid=ard.ratingId
						--INNER JOIN
						--(
						--SELECT arMasterId, Score = MAX(score)
						--FROM agentRating ar where arDetailid IN (SELECT ratingId FROM #ratingIDs)
						--GROUP BY arMasterId
						--)x ON ar.arMasterId=x.arMasterId AND ar.score=x.Score

						--WHERE ard.isActive='y' and ard.ratingId IN(SELECT ratingId FROM #ratingIDs)

				 					
				 ) x ON x.arMasterId= am.rowId
				--WHERE x.isActive='Y' 
				ORDER BY rowId
			
				
				-- This below code is just to compose summary table in GUI. It will return 0 as score.
				SELECT * FROM (
				SELECT rowId= CASE ars.riskCategory 
								WHEN 'General' THEN 1
								WHEN 'Operations' THEN 2
								WHEN 'Compliance' THEN 3
								WHEN 'Security'	THEN 4
								WHEN 'Others'	THEN 5
								WHEN 'Overall' THEN 6
								ELSE ars.rowId END
				, ars.arMasterId,ars.arDetailId,ars.riskCategory,rating,0 AS Score
				FROM agentRatingSummary ars 
				INNER JOIN
				(
					SELECT ars.arMasterId, Score = MAX(score)
					FROM agentRatingSummary ars where arDetailid IN(SELECT ratingId FROM #ratingIDs)
					GROUP BY arMasterId
				)x ON ars.arMasterId=x.arMasterId AND ars.score=x.Score
				WHERE ars.arDetailId IN(SELECT ratingId FROM #ratingIDs)
				)xx
				ORDER BY CAST(rowId AS INT) ASC
				
			END
			ELSE
				BEGIN
							
				SELECT *,'' score,'' remarks,'' reviewedBy,'' reviewedDate,'' reviewerComment,'' approvedBy,'' approvedDate ,'' approverComment,'' ratingBy, '' ratingDate, '' ratingComment FROM ##tmpTablePreview	ORDER BY rowId			
				SELECT rowId, arMasterId,arDetailId,riskCategory, ROUND(score,2) AS score, rating FROM agentRatingSummary where arDetailid=@arDetailId
			END
				
			DROP TABLE ##tmpTablePreview
			
			SELECT * FROM agentScoremaster			
		
		END
		
		ELSE IF(@flag= 'getArInfoByArdId')
		BEGIN 
			SELECT 
					arId				= CAST(ard.ratingId AS VARCHAR)
					,aId				= cast(ard.agentId AS VARCHAR)
					,aName				= cast(am.agentName AS VARCHAR)
					,aBranchName		= cast(m.agentName AS VARCHAR)
					,atype				= CAST(ISNULL(ard.agentType,'') AS VARCHAR)
					,ron				= ISNULL(CAST(ard.reviewedDate AS VARCHAR),'')
					,r					= cast(ISNULL(ard.reviewedBy,'') AS VARCHAR)
					,ratedby			= CAST(ISNULL(ard.ratingBy,'') AS VARCHAR)
					,ratedon			= ISNULL(CAST(ard.ratingDate AS VARCHAR),'')								
					,appby				= CAST(ISNULL(ard.approvedBy,'') AS VARCHAR)
					,appon				= ISNULL(CAST(ard.approvedDate AS VARCHAR),'')
					,rPeriod			= CAST(ard.fromDate as varchar)+' to '+ CAST(ard.toDate AS VARCHAR)
			FROM agentRatingDetail ard WITH(NOLOCK)
				INNER JOIN agentListRiskProfile am WITH(NOLOCK) ON am.agentId=ard.agentId
				INNER JOIN agentMaster m on m.agentId= ard.branchId
			WHERE ARD.ratingId= @ardId
			RETURN 
		END 		
		
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentID
END CATCH
GO
