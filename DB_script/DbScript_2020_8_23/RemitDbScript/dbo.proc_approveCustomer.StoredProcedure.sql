USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_approveCustomer]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_approveCustomer]
 	 @flag              VARCHAR(50)		= NULL
	,@user              VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@agentId			VARCHAR(100)	= NULL
	,@status			VARCHAR(200)	= NULL
	,@membershipId		VARCHAR(10)		= NULL
	,@isDoc				VARCHAR(10)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(10)		= NULL
	,@mode				CHAR(2)			= NULL
	,@zone				VARCHAR(50)		= NULL
	,@agentGrp 			VARCHAR(50)		= NULL
	,@district			VARCHAR(50)     = NULL
            
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY	
	/*
		EXEC proc_approveCustomer @flag='s',@user='admin',
			@fromDate = '2014-06-24',
			@toDate = '2014-06-28',
			@agentId =NULL,
			@status = NULL
	*/

DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))
DECLARE 
	 @table			VARCHAR(MAX)	= NULL
	,@url			VARCHAR(max)	= ''			
	,@gobalFilter	VARCHAR(MAX)	= ''	
    ,@tempSql		VARCHAR(MAX)    = ''

IF ISDATE(@fromDate) = 1 AND ISDATE(@toDate) = 1
BEGIN
	INSERT INTO @FilterList 
	SELECT 'From Date',@fromDate UNION ALL
	SELECT 'To Date',@toDate
	SET @gobalFilter=@gobalFilter+' AND main.createdDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ' 23:59:59'''
END
ELSE IF ISDATE(@fromDate) = 1 
BEGIN
	INSERT INTO @FilterList 
	SELECT 'From Date',@fromDate 
	SET @gobalFilter=@gobalFilter+' AND main.createdDate> ''' + @fromDate + ''''
END
ELSE IF ISDATE(@toDate) = 1 
BEGIN
	INSERT INTO @FilterList 
	SELECT 'To Date',@toDate 
	SET @gobalFilter=@gobalFilter+' AND main.createdDate< ''' + @toDate + ''''
END


IF @agentId IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId 
		SET @url=@url+'&agentId='+@agentId
		SET @gobalFilter=@gobalFilter+' AND am.agentId ='''+@agentId+''''
	END	
IF @status IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Status',@status
		SET @url=@url+'&status='+@status
		SET @gobalFilter=@gobalFilter+' AND main.customerStatus ='''+@status+''''
	END	
	IF @zone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Zone',@zone
		SET @url=@url+'&sZone='+@zone
		SET @gobalFilter=@gobalFilter+' AND am.agentState ='''+@zone+''''
	END	
	IF @district IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'District',@district
		SET @url=@url+'&district='+@district
		SET @gobalFilter=@gobalFilter+' AND am.agentDistrict ='''+@district+''''
	END	
IF @agentGrp IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Agent Group',detailTitle FROM dbo.staticDataValue WITH(NOLOCK) WHERE valueId=@agentGrp 
		SET @url=@url+'&agentGrp='+@agentGrp
		SET @gobalFilter=@gobalFilter+' AND am.agentGrp ='''+@agentGrp+''''
	END	
IF @memberShipId IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Membership Id',@memberShipId
		SET @url=@url+'&memberShipId='+@memberShipId
		SET @gobalFilter=@gobalFilter+' AND cast(main.memberShipId as varchar) ='''+@memberShipId+''''
	END
IF @isDoc IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Document Uploaded',@isDoc
		SET @url=@url+'&isDoc='+@isDoc

		IF @isDoc='Yes'
		BEGIN
			SET @gobalFilter=@gobalFilter+' AND cd.customerId is not null and cd.cdId is not null'
		END

		IF @isDoc='NO'
		BEGIN
			SET @gobalFilter=@gobalFilter+' AND cd.customerId is null and cd.cdId is null'
		END

	END	
	IF @flag='s'
	BEGIN
	 SET @gobalFilter=@gobalFilter
		SET @table='
		SELECT 
				 customerId = main.customerId				
				,[Mem. Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName, '''')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created Date] = main.createdDate
				,[Is Uploaded] = case when cd.customerId is null then ''No'' else ''Yes'' end			
				,[Status] = customerStatus
				,[Subject] = ci.subject
				,[HO-Complain] = ci.description
				,[Agent Group]=CASE WHEN am.agentGrp=''4301'' THEN ''Bank & Finance''
									WHEN am.agentGrp=''6207'' THEN ''Private Agents''
									WHEN am.agentGrp=''8026'' THEN ''Cooperative''
									WHEN am.agentGrp=''8027'' THEN ''School & College''
									WHEN am.agentGrp=''4300'' THEN ''IME Center''
									WHEN am.agentGrp=''8028'' THEN ''International Agents''
									ELSE ''ALL''
								END
				,[Zone]= am.agentState
				,[District]= am.agentDistrict
			FROM customerMaster main WITH(NOLOCK)
			LEFT JOIN  (
				SELECT customerId, MAX(cdId) cdId FROM customerDocument WITH(NOLOCK) GROUP BY customerId
			) cd on main.customerId = cd.customerId
			LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
			LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = ''Y''
			WHERE rejectedDate IS NULL AND (main.isDeleted = ''N'' OR main.isDeleted IS NULL) ' + @gobalFilter

		SET @tempSql='select customerId, [S.N.]=row_number() over(order by [Mem. Id]),[Mem. Id],[Name],[Mobile],[Agent Name],[Created Date],[Is Uploaded],[Status],[Subject],[HO-Complain],[Agent Group],[Zone],[District] FROM ('+@table+')X'
        PRINT @tempSql
		EXEC(@tempSql)
		--RETURN
	END

	IF @flag = 'ss'
	BEGIN	
		SELECT  x.customerId
				,[S.N.] = row_number() over(order by x.customerId) 
				,[Mem. Id]
				,[Name]
				,[Mobile]
				,[Agent Name]
				,[Created Date]
				,[Is Uploaded]
				,[Status]
				,[Subject]
				,[HO-Complain]
				,[Agent Group]
				,[Zone]
				,[District]
		FROM	
		(	
			SELECT distinct 
				 
				 customerId = main.customerId
				,[Mem. Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '') + ISNULL( ' ' + main.middleName, '')+ ISNULL( ' ' + main.lastName, '')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created Date] = main.createdDate
				,[Is Uploaded] = case when cd.customerId is null then 'No' else 'Yes' end			
				,[Status] = customerStatus
				,[Subject] = ci.subject
				,[HO-Complain] = ci.description
				,[Agent Group]=CASE WHEN am.agentGrp='4301' THEN 'Bank & Finance'
									WHEN am.agentGrp='6207' THEN 'Private Agents'
									WHEN am.agentGrp='8026' THEN 'Cooperative'
									WHEN am.agentGrp='8027' THEN 'School & College'
									WHEN am.agentGrp='4300' THEN 'IME Center'
									WHEN am.agentGrp='8028' THEN 'International Agents'
									ELSE 'ALL'
								END
				,[Zone]= main.pZone
				,[District]= main.pDistrict
			FROM customerMaster main WITH(NOLOCK)
				LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
				LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
				LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = 'Y'
			WHERE rejectedDate IS NULL 
			AND main.agentId = ISNULL(@agentId,main.agentId)
			AND main.customerStatus = ISNULL(@status,main.customerStatus)
			AND main.membershipId = ISNULL(@membershipId,main.membershipId)
			AND ISNULL(main.isDeleted,'N') = 'N'
		)X WHERE [Is Uploaded] = ISNULL(@isDoc,[Is Uploaded])
	END	
	IF @flag = 's-dash'
	BEGIN	
		SELECT  x.customerId
				,[S.N.] = row_number() over(order by x.customerId) 
				,[Mem. Id]
				,[Name]
				,[Mobile]
				,[Agent Name]
				,[Created Date]
				,[Is Uploaded]
				,[Status]
				,[Subject]
				,[HO-Complain]
		FROM	
		(	
			SELECT distinct 
				 
				 customerId = main.customerId
				,[Mem. Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '') + ISNULL( ' ' + main.middleName, '')+ ISNULL( ' ' + main.lastName, '')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created Date] = main.createdDate
				,[Is Uploaded] = case when cd.customerId is null then 'No' else 'Yes' end			
				,[Status] = customerStatus
				,[Subject] = ci.subject
				,[HO-Complain] = ci.description
			FROM customerMaster main WITH(NOLOCK)
				LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
				INNER JOIN agentMaster am with(nolock) on am.agentId = main.agentId
				LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = 'Y'
			WHERE rejectedDate IS NULL 
			AND am.agentState = ISNULL(@zone,am.agentState)
			AND main.customerStatus = ISNULL(@status,main.customerStatus)
			AND ISNULL(main.isDeleted,'N') = 'N'
		)X WHERE 1=1
	END	
	IF @flag = 's_summary'
	BEGIN
		SELECT [Zone] = x.agentState,
			   [Pending] = SUM(x.Pending),
			   [Complain] = SUM(x.Complain),
			   [Updated] = SUM(x.Updated)
		FROM
		(
			SELECT am.agentState
				,CASE WHEN cm.customerStatus='Pending' THEN COUNT('a') ELSE 0 END 'Pending'
				,CASE WHEN cm.customerStatus='Complain' THEN COUNT('a')ELSE 0 END 'Complain'
				,CASE WHEN cm.customerStatus='Updated' THEN COUNT('a')ELSE 0 END 'Updated'	
			FROM dbo.customerMaster cm WITH(NOLOCK) 
			INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON cm.agentId = am.agentId
			WHERE cm.rejectedDate IS NULL 
			AND ISNULL(cm.isDeleted,'N') = 'N'
			GROUP BY am.agentState,cm.customerStatus
		)x GROUP BY x.agentState		
	END
	IF @flag = 's_detail'
	BEGIN	
		IF @mode = '1'
			SET @status = 'Pending'
		IF @mode = '2'
			SET @status = 'Updated'
		IF @mode = '3'
			SET @status = 'Complain'
		SELECT  x.customerId
				,[S.N.] = row_number() over(order by x.customerId) 
				,[Mem. Id]
				,[Name]
				,[Mobile]
				,[Agent Name]
				,[Created Date]
				,[Is Uploaded]
				,[Status]
				,[Subject]
				,[HO-Complain]
		FROM	
		(	
			SELECT distinct 
				 
				 customerId = main.customerId
				,[Mem. Id] = main.membershipId
				,[Name] = ISNULL(main.firstName, '') + ISNULL( ' ' + main.middleName, '')+ ISNULL( ' ' + main.lastName, '')
				,[Mobile] = main.mobile
				,[Agent Name] = am.agentName
				,[Created Date] = main.createdDate
				,[Is Uploaded] = case when cd.customerId is null then 'No' else 'Yes' end			
				,[Status] = customerStatus
				,[Subject] = ci.subject
				,[HO-Complain] = ci.description
			FROM customerMaster main WITH(NOLOCK)
				LEFT JOIN customerDocument cd with(nolock) on main.customerId = cd.customerId
				LEFT JOIN agentMaster am with(nolock) on am.agentId = main.agentId
				LEFT JOIN customerInfo ci WITH(NOLOCK) ON main.customerId = ci.customerId and ci.setPrimary = 'Y'
			WHERE rejectedDate IS NULL 
			AND main.customerStatus = @status
			AND ISNULL(main.isDeleted,'N') = 'N'
		)X WHERE [Is Uploaded] = ISNULL(@isDoc,[Is Uploaded])
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
