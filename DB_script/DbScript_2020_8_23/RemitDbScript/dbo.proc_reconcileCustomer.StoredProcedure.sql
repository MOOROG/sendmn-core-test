USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reconcileCustomer]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_reconcileCustomer]
 	 @flag              VARCHAR(50)		= NULL
	,@user              VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@agentId			VARCHAR(100)	= NULL
	,@memId				VARCHAR(10)		= NULL
	,@remarks			VARCHAR(MAX)    = NULL
	,@rptType			VARCHAR(20)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(10)		= NULL
	,@pageNumber		INT				= NULL
	,@pageSize			INT				= NULL
            
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE @table VARCHAR(MAX)
	/*
		EXEC proc_reconcileCustomer @flag='s',@user='admin',
			@fromDate = '2014-06-24',
			@toDate = '2014-06-28',
			@agentId =NULL,
			@memId = NULL
	*/
	IF @flag = 's'
	BEGIN
		SET @table ='
			SELECT  				 
				 customerId = main.customerId
				,[S.N.] = ROW_NUMBER() OVER(ORDER BY main.customerId )
				,[Membership Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName, '''')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created By]	= main.createdBy
				,[Created Date] = main.createdDate
				,[Approved By] = main.approvedBy
				,[Approved Date] = main.approvedDate
			FROM customerMaster main WITH(NOLOCK)
				LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
			WHERE rejectedDate IS NULL AND reconciledDate IS NULL AND main.customerStatus = ''Approved'' AND ISNULL(main.isDeleted,''N'') = ''N'''

			IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
				SET @table = @table+ 'AND main.createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''

			IF @agentId IS NOT NULL
				SET @table = @table+ 'AND main.agentId = '''+@agentId+''''
			IF @memId IS NOT NULL
				SET @table = @table+ 'AND main.membershipId = '''+@memId+''''	

			EXEC(@TABLE)
			
	END	
	ELSE IF @flag = 'reconcile'
	BEGIN
		BEGIN TRANSACTION
		UPDATE customerMaster 
		SET
			 reconciledDate  = GETDATE()
			,reconciledBy = @user
			,reconcileRemarks = @remarks
		WHERE membershipId = @memId

		--ALTER TABLE customerMaster ADD reconciledBy VARCHAR(50),reconciledDate DATETIME,reconcileRemarks VARCHAR(MAX)

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION		
		
		EXEC proc_errorHandler 0, 'Record reconciled successfully.', @memId
	END
	IF @flag = 'rpt'
	BEGIN
		SET @pageNumber	= ISNULL(@pageNumber, 1)
		SET @pageSize	= ISNULL(@pageSize, 100)
		DECLARE @sql VARCHAR(MAX)
		IF @rptType = 'detail'
		BEGIN
			SET @table ='
				SELECT  	 
					 [Membership Id] = main.membershipId
					,[Name] = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName, '''')
					,[Mobile] = main.mobile
					,[Agent Name] = am.agentName
					,[Created By]	= main.createdBy
					,[Created Date] = main.createdDate
					,[Approved By] = main.approvedBy
					,[Approved Date] = main.approvedDate
					,[Reconciled By] = main.reconciledBy
					,[Reconciled Date] = main.reconciledDate
					,[Reconciled Remarks] = main.reconcileRemarks
				FROM customerMaster main WITH(NOLOCK)
					LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
				WHERE main.reconciledDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''

			IF @agentId IS NOT NULL
				SET @table = @table+ 'AND main.agentId = '''+@agentId+''''
			IF @memId IS NOT NULL
				SET @table = @table+ 'AND main.membershipId = '''+@memId+''''	
		END
		IF @rptType = 'summary'
		BEGIN
			SET @table ='
				SELECT 
					[Agent Name] = am.agentName,
					[Count] = COUNT(''x'') 
				FROM dbo.customerMaster main WITH(NOLOCK) INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON main.agentId  = am.agentId
				WHERE main.reconciledDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''

			IF @agentId IS NOT NULL
				SET @table = @table+ 'AND main.agentId = '''+@agentId+''''
			IF @memId IS NOT NULL
				SET @table = @table+ 'AND main.membershipId = '''+@memId+''''	

			SET @table = @table+ ' GROUP BY am.agentName'
		END

		SET @sql = 'SELECT 
						COUNT(*) AS TXNCOUNT
						,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
						,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
					FROM (' + @table + ') x'
		EXEC (@sql)
		SET @sql = '
				SELECT *
				FROM (
					SELECT 
						[S.N.] = ROW_NUMBER() OVER(ORDER BY [Agent Name]),* 
					FROM (' + @table + ') x		
				) AS tmp WHERE [S.N.] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		PRINT(@sql)
		EXEC (@sql)
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT 'Date Range' head, @fromDate +' To ' + @toDate value 
		UNION ALL
		SELECT 'Agent Name' head, CASE WHEN @agentId IS NOT NULL THEN (SELECT agentName FROM dbo.agentMaster am WITH(NOLOCK) WHERE agentId = @agentId) ELSE 'All' END	value  
		UNION ALL
		SELECT 'Membership Id' head, @memId value  
		SELECT 'Customer Reconciliation Report'  title
	
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentId
END CATCH



GO
