USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentRiskProfiling]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_agentRiskProfiling]
(
	@flag					VARCHAR(50)			= NULL
	,@criteriaId			INT					= NULL
	,@topic					VARCHAR(200)		= NULL
	,@minimumScore			MONEY				= NULL
	,@maximumScore			MONEY				= NULL
	,@displayOrder			INT					= NULL
	,@createdBy				VARCHAR(50)			= NULL
	,@createdDate			DATETIME			= NULL
	,@modifiedBy			VARCHAR(50)			= NULL		
	,@modifedDate			DATETIME			= NULL
	,@isActive				VARCHAR(1)			= NULL
	,@scoringId				INT					= NULL
	,@scoreFrom				MONEY				= NULL
	,@scoreTo				MONEY				= NULL
	,@rating				VARCHAR(10)			= NULL
	,@assessementId			INT					= NULL
	,@agentID				INT					= NULL
	,@assessementDate		DATE				= NULL
	,@reviewedBy			VARCHAR(50)			= NULL
	,@reviewedDate			DATETIME			= NULL
	,@score					MONEY				= NULL
	,@reviewerComment		VARCHAR(2500)		= NULL
	,@detailId				INT					= NULL
	,@remarks				VARCHAR(2500)		= NULL			
	,@user					VARCHAR(50)			= NULL
	,@sortBy                VARCHAR(50)			= NULL
	,@sortOrder             VARCHAR(5)			= NULL
	,@pageSize              INT					= NULL
	,@pageNumber            INT					= NULL
	,@xml					XML					= NULL
	,@agentName				VARCHAR(100)		= NULL
	--,@searchCriteria		VARCHAR(50)			= NULL
	--,@searchValue			VARCHAR(50)			= NULL
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
			
			IF EXISTS (SELECT 'x' FROM riskAssessement WITH(NOLOCK) WHERE agentid=@agentID and reviewdBy is null and isnull(isActive,'Y')='Y')
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, there is already active assessement exists for this agent, which has not been reviewed yet. Please kindly do inactive or review existing record and try again.', @agentID
				RETURN
			END
			
			IF EXISTS (SELECT 'x' FROM riskAssessement WITH(NOLOCK) WHERE agentid=@agentID AND ISNULL(isActive, 'Y') = 'Y')
			BEGIN
				EXEC proc_errorHandler 1, 'Sorry, there is already active assessement exists for this agent, which has not been reviewed yet. Please kindly do inactive or review existing record and try again.', @agentID
				RETURN
			END
			
			BEGIN TRANSACTION
				INSERT INTO riskAssessement (					
					agentid
					,assessementDate
					,createdBy
					,createdDate
					,reviewdBy
					,reviewedDate
					,score
					,rating
					,reviewerComment
					,isActive
				)
				SELECT
					@agentID
					,@assessementDate					 
					,@createdBy
					,GETDATE()
					,@reviewedBy
					,@reviewedDate
					,@score
					,@rating
					,@reviewerComment
					,@isActive					
													
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentID
		END
		IF @flag = 'i-rp'
		BEGIN
			BEGIN TRANSACTION
				
								
				IF EXISTS (SELECT 'x' FROM ratingDetail WITH(NOLOCK) WHERE assessementId=@assessementId)
				BEGIN
					DELETE FROM ratingDetail WHERE assessementId=@assessementId
				END
			
				INSERT INTO ratingDetail(					
					assessementId
					,criteriaId
					,score					
					,remarks
					,createdBy					
					,createdDate
					,modifiedBy
					,modifiedDate
				)
				SELECT
				 p.value('@assessementId','VARCHAR(50)')
				,p.value('@criteriaId','VARCHAR(50)')
				,p.value('@score','VARCHAR(50)')				
				,p.value('@remarks','VARCHAR(2500)')
				,@user
				,GETDATE()
				,@user
				,GETDATE()
				FROM @xml.nodes('/root/row') AS tmp(p)

				UPDATE riskAssessement
					set score=@score
					,rating=@rating
					WHERE assessementId=@assessementId
					--and agentId=@agentID

			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentID
		END
		ELSE IF @flag='pc' -- profilingCriteria
		BEGIN
				IF EXISTS (SELECT 'x' FROM ratingDetail WITH(NOLOCK) WHERE assessementId=@assessementId)
				BEGIN
					SELECT pc.criteriaId,pc.topic,dbo.ShowDecimal(pc.minimumScore)as minimumScore,dbo.ShowDecimal(pc.maximumScore)as maximumScore,pc.displayOrder,
					dbo.showdecimal(rd.score)as score,rd.remarks,ra.createdBy,ra.createdDate,ra.reviewdBy,ra.reviewedDate,ra.reviewerComment
					FROM ratingDetail rd WITH(NOLOCK)
					INNER JOIN profilingCriteria pc on pc.criteriaId=rd.criteriaId
					INNER JOIN riskAssessement ra on ra.assessementId=rd.assessementId
					WHERE  rd.assessementId=@assessementId
					ORDER BY pc.displayOrder
			
				END
				ELSE
				BEGIN
					SELECT
					criteriaId,topic,dbo.ShowDecimal(minimumScore) as minimumScore,dbo.ShowDecimal(maximumScore) as maximumScore
					,displayOrder,'' as score,'' as remarks FROM profilingCriteria WITH(NOLOCK)
					WHERE isActive='Y'
					ORDER BY displayOrder
				END
				SELECT scoringId,scoreFrom,scoreTo,rating 
				FROM scoringCriteria WITH(NOLOCK) where isActive='Y'

		END
		--ELSE IF @flag='pc-review'
		--BEGIN
			
		--	SELECT pc.criteriaId,pc.topic,pc.minimumScore,pc.maximumScore,pc.displayOrder,
		--	score,remarks
		--	 FROM ratingDetail rd
		--	INNER JOIN profilingCriteria pc on pc.criteriaId=rd.criteriaId 
		--	WHERE  rd.assessementId=@assessementId
		--	ORDER BY pc.displayOrder
			
		--	SELECT scoringId,scoreFrom,scoreTo,rating 
		--	FROM scoringCriteria where isActive='Y'
			
		--END
		ELSE IF @flag='s'
		BEGIN
			SET @isActive = ISNULL(@isActive, 'Y')
			IF @isActive = 'A'
				SET @isActive = NULL
			--IF @sortBy IS NULL
				SET @sortBy = 'score,agentName'
			--IF @sortOrder IS NULL
				SET @sortOrder = ''
			
			DECLARE @hasRight CHAR(1),@reviewRight CHAR(1)
			SET @hasRight = dbo.FNAHasRight(@user, '20191020')-- Score/Inactive
			SET @reviewRight = dbo.FNAHasRight(@user, '20191030')-- Review
		
				
			SET @table = '(
					SELECT
						 ra.assessementId
						,ra.agentid
						,am.agentName						
						,assessementDate = ra.assessementDate					
						,ra.createdBy
						,ra.createdDate
						,ra.reviewdBy
						,reviewedDate = ra.reviewedDate
						,score=ra.score
						,ra.rating
						,ra.reviewerComment
						,ra.isActive
						,scorelink = case when ra.isActive=''y'' and ra.reviewedDate is null then 
							CASE WHEN '''+@hasRight+'''=''Y'' THEN
							''<a href="Manage.aspx?type=risk&aId=''+CAST(ra.assessementId as varchar)+''&agentId=''+cast(ra.agentid as varchar)+''">Score</a>&nbsp;''
								+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&aId=''+CAST(ra.assessementId as varchar)+''&agentId=''+cast(ra.agentid as varchar)+''">Mark Inactive</a>&nbsp;''
							ELSE ''''
							END 
								+ case when ISNULL(ra.score,0)> 0 THEN
							 + ''<a href="Manage.aspx?type=riskhistory&aId=''+CAST(ra.assessementId as varchar)+''&agentId=''+cast(ra.agentid as varchar)+''">Details</a>&nbsp;''
									+ case when ra.reviewedDate is null AND '''+@reviewRight+'''=''Y'' then 
							+''<a href="Manage.aspx?type=review&aId=''+CAST(ra.assessementId as varchar)+''&agentId=''+cast(ra.agentid as varchar)+''">Review</a>''
									ELSE ''''
									end
								ELSE ''''
							 	end						  
							else
							''<a href="Manage.aspx?type=riskhistory&aId=''+CAST(ra.assessementId as varchar)+''&agentId=''+cast(ra.agentid as varchar)+''">Details</a>&nbsp;''
							+case when isnull(ra.isActive,''y'')=''y'' then
							+''<a onclick="return confirm(''''Are you sure you want to inactive this assessement?'''');" href="List.aspx?type=inactive&aId=''+CAST(ra.assessementId as varchar)+''&agentId=''+cast(ra.agentid as varchar)+''">Mark Inactive</a>''
							else '''' end
							end
					FROM riskAssessement ra WITH(NOLOCK)
					INNER JOIN agentListRiskProfile am on ra.agentId=am.agentId
						WHERE 1 = 1 
						) x'
						
			SET @sql_filter = ''
			
						
			
			IF @agentID is not NULL
				SET @sql_filter=@sql_filter+'  And agentid =  '''+CAST(@agentId AS VARCHAR)+''''
			IF @isActive is not null and @isActive<>'A'
				SET @sql_filter = @sql_filter + ' And isActive='''+@isActive+''''
							
			IF @assessementDate IS NOT NULL
				 SET @sql_filter=@sql_filter+'  And assessementDate =  '''+ CAST(@assessementDate AS VARCHAR) +''' '
				
			IF @score is not NULL
				-- SET @sql_filter=@sql_filter+'  And score =  '''+ @score +''''	
				SET @sql_filter=@sql_filter+'  And score ='''+ CAST(@score AS VARCHAR)+''' ' 	
				
			IF @rating is not NULL
				SET @sql_filter=@sql_filter+'  And rating =  '''+CAST(@rating AS VARCHAR)+''''	
					
			print @table+''+@sql_filter	
			
			
			SET @select_field_list ='
				 assessementId
				,agentid
				,agentName
				,assessementDate				
				,createdBy
				,createdDate
				,reviewdBy
				,reviewedDate
				,score
				,rating
				,reviewerComment
				,isActive
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
		ELSE IF @flag='inactive'
		BEGIN
			BEGIN TRANSACTION
			
					UPDATE riskAssessement
					set isactive=@isActive
					WHERE assessementId=@assessementId
					and agentId=@agentID
																							
				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
				EXEC proc_errorHandler 0, 'Record has been updated successfully.', @agentID
		
		END
		ELSE IF @flag='i-r'
		BEGIN
			BEGIN TRANSACTION
			
					UPDATE riskAssessement
					set reviewdBy=@reviewedBy
					,reviewerComment=@reviewerComment
					,reviewedDate=GETDATE()
					WHERE assessementId=@assessementId
					and agentId=@agentID
																							
				IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
				EXEC proc_errorHandler 0, 'Record has been updated successfully.', @agentID
		
		END
		ELSE IF @flag='ddlStatus'
		BEGIN
		
			SELECT 'A' AS 'value', 'All' AS 'text' UNION ALL
			SELECT 'Y' ,'Active' UNION ALL
			SELECT 'N','Inactive'
		
		END		
		ELSE IF @flag='ddlRating'
		BEGIN		
			SELECT NULL 'value'  ,'All' AS 'text' UNION ALL
			SELECT 'LOW' ,'LOW' UNION ALL
			SELECT 'MEDIUM','MEDIUM' UNION ALL
			SELECT 'HIGH'  ,'HIGH'
		END
		
		ELSE IF @flag = 'l1'
		BEGIN
			SELECT agentId, agentName 
			FROM dbo.agentListRiskProfile WITH(NOLOCK)
			WHERE agentName LIKE '%' + ISNULL(@agentName, '') + '%'
			ORDER BY agentName
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
