USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_RBAEvaluatedCustomers]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_RBAEvaluatedCustomers]
 @flag					VARCHAR(30)			= NULL
,@assessement			VARCHAR(30)			= NULL
,@customerId			VARCHAR(50)			= NULL
,@RBAStatus				VARCHAR(15)			= NULL
,@pendingTxnGE30		VARCHAR(10)			= NULL -- GreaterThanOrEqual to 30
,@pendingTxnL30			VARCHAR(10)			= NULL -- LessThan 30
,@remarks				VARCHAR(100)		= NULL
,@user					VARCHAR(50)			= NULL
,@sortBy                VARCHAR(50)			= NULL
,@sortOrder             VARCHAR(5)			= NULL
,@pageSize              INT					= NULL
,@pageNumber            INT					= NULL	

AS 
 
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
 
	SET @pageNumber	= ISNULL(@pageNumber, 1)
	SET @pageSize	= ISNULL(@pageSize, 100)
	
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
		
 IF(@flag='rba-ec')
 BEGIN
 
	 DECLARE 
	 @LOWrFrom		MONEY
	,@LOWrTo		MONEY
	,@MEDIUMrFrom	MONEY
	,@MEDIUMrTo		MONEY
	,@HIGHrFrom		MONEY
	,@HIGHrTo		MONEY	

	SELECT @LOWrFrom=rFrom ,@LOWrTo=rTo  FROM RBAScoreMaster WHERE TYPE='LOW'
	SELECT @MEDIUMrFrom=rFrom ,@MEDIUMrTo=rTo  FROM RBAScoreMaster WHERE TYPE='MEDIUM'
	SELECT @HIGHrFrom=rFrom ,@HIGHrTo=rTo  FROM RBAScoreMaster WHERE TYPE='HIGH'

	SELECT 
	ASSESSMENT		=	'<a onClick="showReport(''as'','''+x.ASSESSMENT+''','''')" class="contentlink">'+ x.ASSESSMENT+'</a>',
	CLEARED			=	'<a onClick="showReport(''rs'',''CLEARED'','''+x.ASSESSMENT+''')" class="contentlink">'+ CAST(x.CLEARED AS VARCHAR)+'</a>',
	PENDING_GE_30	=	'<a onClick="showReport(''pge30'',''PENDING_GE_30'','''+x.ASSESSMENT+''')" class="contentlink">'+ CAST(x.PENDING_GE_30 AS VARCHAR)+'</a>',
	PENDING_L_30	=	'<a onClick="showReport(''pl30'',''PENDING_L_30'','''+x.ASSESSMENT+''')" class="contentlink">'+ CAST(x.PENDING_L_30 AS VARCHAR)+'</a>',
	BLOCKED			=	'<a onClick="showReport(''rs'',''BLOCKED'','''+x.ASSESSMENT+''')" class="contentlink">'+ CAST(x.BLOCKED AS VARCHAR)+'</a>',
	x.TOTAL FROM (
	SELECT 'HIGH' ASSESSMENT 
	,  CLEARED			= SUM(CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo AND RBASTATUS='CLEARED' THEN 1 ELSE 0 END ) 
	,  PENDING_GE_30	= SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo AND RBASTATUS IS NULL AND DATEDIFF(D,LASTTXNDATE,GETDATE()) >=30  THEN 1 ELSE 0 END ) 
	,  PENDING_L_30		= SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo AND RBASTATUS IS NULL AND DATEDIFF(D,LASTTXNDATE,GETDATE()) <30  THEN 1 ELSE 0 END ) 
	,  BLOCKED			= SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo AND RBASTATUS='BLOCKED' THEN 1 ELSE 0 END ) 
	,  TOTAL			= SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo  THEN 1 ELSE 0 END ) 
	FROM CUSTOMERS WITH (NOLOCK) WHERE RBA IS NOT NULL
	UNION ALL
	SELECT 'MEDIUM' ASSESSMENT 
	,  CLEARED			= SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND RBASTATUS='CLEARED' THEN 1 ELSE 0 END ) 
	,  PENDING_GE_30	= SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND RBASTATUS IS NULL AND DATEDIFF(D,LASTTXNDATE,GETDATE()) >=30  THEN 1 ELSE 0 END ) 
	,  PENDING_L_30		= SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND RBASTATUS IS NULL AND DATEDIFF(D,LASTTXNDATE,GETDATE()) <30  THEN 1 ELSE 0 END ) 
	,  BLOCKED			= SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND RBASTATUS='BLOCKED' THEN 1 ELSE 0 END ) 
	,  TOTAL			= SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo  THEN 1 ELSE 0 END ) 
	FROM CUSTOMERS WITH (NOLOCK) WHERE RBA IS NOT NULL
	UNION ALL
	SELECT 'LOW' ASSESSMENT 
	, CLEARED			= SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo AND RBASTATUS='CLEARED' THEN 1 ELSE 0 END ) 
	, PENDING_GE_30		= SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo AND RBASTATUS IS NULL AND DATEDIFF(D,LASTTXNDATE,GETDATE()) >=30  THEN 1 ELSE 0 END ) 
	, PENDING_L_30		= SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo AND RBASTATUS IS NULL AND DATEDIFF(D,LASTTXNDATE,GETDATE()) <30  THEN 1 ELSE 0 END ) 
	, BLOCKED			= SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo AND RBASTATUS='BLOCKED' THEN 1 ELSE 0 END ) 
	, TOTAL				= SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo  THEN 1 ELSE 0 END ) 
	FROM CUSTOMERS WITH (NOLOCK) WHERE RBA IS NOT NULL
	)x

				
	

END

 IF(@flag='rba-ec-dl')
 BEGIN
 
	DECLARE 
	 @rFrom		MONEY
	,@rTo		MONEY
	
	SELECT @rFrom=rFrom ,@rTo=rTo  FROM RBAScoreMaster WHERE TYPE=@assessement
	
	DECLARE @cusRBALink VARCHAR(5000)
	SET @cusRBALink='<a href="#" onclick="OpenInNewWindow(''''/Remit/RiskBaseAnalysis/cusRBACalcDetails.aspx?'
 SET @table = '
	SELECT
	customerId
	,[Name] = UPPER(fullname)
	,mobile
	,idType = sd.detailTitle
	,idNumber
	,country = cm.countryName
	,RBA	= ''' + @cusRBALink + 'customerId=''+ CAST(customerId AS VARCHAR)+''&dt=''+ (SELECT MAX(dt) FROM PERIODICRBA WITH(NOLOCK) WHERE customerId = customerId) +'''''')">'' + CONVERT(VARCHAR, RBA, 2) + ''</a>''
	--,RBA
	,lastTxnDate
	,[Status]=RBASTATUS
	,pendingRemarks 
	,''Action''= CASE RBASTATUS WHEN ''CLEARED'' THEN ''<a class="link" onclick="ShowRemarks(this,''''BLOCKED'''',''''''+ CAST(customerId AS VARCHAR)+'''''')"> BLOCK </a>''
			   WHEN ''BLOCKED'' THEN ''<a class="link" onclick="ShowRemarks(this,''''CLEARED'''',''''''+ CAST(customerId AS VARCHAR)+'''''')"> CLEAR </a>''
			   ELSE ''<a class="link" onclick="ShowRemarks(this,''''CLEARED'''',''''''+ CAST(customerId AS VARCHAR)+'''''')"> CLEAR </a> | <a class="link" onclick="ShowRemarks(this,''''BLOCKED'''',''''''+ CAST(customerId AS VARCHAR)+'''''')"> BLOCK </a> | <a class="link" onclick="ShowRemarks(this,''''PENDINGRELEASE'''',''''''+ CAST(customerId AS VARCHAR)+'''''')"> PENDING RELEASE REMARKS </a>'' 
			   END
	, ''Links''= ''<a class="link" onclick="OpenInNewWindow(''''../../Remit/Administration/CustomerSetup/CustomerDocument/DocumentView.aspx?customerId=''+CAST(customerId AS VARCHAR)+'''''');"><img alt = "Documents" title = "Documents" src="../../Images/uploadIdImage.gif" height="16" widht="16" /></a>&nbsp;''
			   +''<a class="link" onclick="OpenInNewWindow(''''../../Remit/Administration/CustomerSetup/TranHistory.aspx?customerId=''+CAST(customerId AS VARCHAR)+''&idNumber=''+CAST(customerId AS VARCHAR)+'''''');"><img alt = "History" title = "History" src="../../Images/view-detail-icon.png" /></a>&nbsp;''
			   +''<a class="link" onclick="OpenInNewWindow(''''../../Remit/Administration/CustomerSetup/CustomerLimit/ListCustomerLimit.aspx?customerId=''+CAST(customerId AS VARCHAR)+'''''');"><img alt = "Limit" title = "Limit" src="../../Images/limit.png" /></a>''
	 FROM CUSTOMERS cu WITH (NOLOCK) 
	 
	 LEFT JOIN countryMaster cm WITH(NOLOCK) ON cu.country = cm.countryId
 	 LEFT JOIN staticDataValue sd WITH(NOLOCK) ON sd.valueId = cu.idType
 	 LEFT JOIN (
 		SELECT cid = RP.customerId, RP.pendingRemarks FROM RBApendingRemarks RP
 		INNER JOIN (
 			SELECT rowId = MAX(rowId),customerId FROM RBApendingRemarks WITH(NOLOCK) GROUP BY customerId
 		)Y ON Y.customerId = RP.customerId
 	 )rpr on CU.customerId = rpr.cid
	 
	 WHERE RBA IS NOT NULL 
	'
		
	IF ISNULL(@assessement,'') <> ''
	BEGIN 
		SET @table=@table + '  AND RBA BETWEEN ' + CAST(@rFrom AS VARCHAR) + ' AND ' + CAST(@rTo AS VARCHAR) + '' 
	END
	IF ISNULL(@RBAStatus,'') <> ''
			SET @table=@table+'  AND RBASTATUS = ''' + @RBAStatus + ''' '
	
	IF ISNULL(@pendingTxnGE30,'') <> ''
			SET @table=@table+'  AND DATEDIFF(D,LASTTXNDATE,GETDATE()) >= 30 AND RBASTATUS IS NULL '
	
	IF ISNULL(@pendingTxnL30,'') <> ''
			SET @table=@table+'  AND DATEDIFF(D,LASTTXNDATE,GETDATE()) < 30 AND RBASTATUS IS NULL '

	SET @sql = 'SELECT 
						COUNT(*) AS TXNCOUNT
						,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
						,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
					FROM (' + @table + ') x'
		PRINT @sql
		EXEC (@sql)
			
		SET @sql = '
			SELECT
				 [Customer Id]				= customerId
				,[Customer Name]			= Name
				,[Mobile No.]				= mobile
				,[ID Type]					= idType
				,[ID No.]					= idNumber
				,[Country]					= country
				,[RBA]						= RBA
				,[Last Txn Date]			= lastTxnDate
				,[Status]					= Status
				,[Pending Release Remarks]  = pendingRemarks
				,[Action]					= Action
				,Links
			FROM (		
				SELECT 
					ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS [S.N],* 
				FROM (' + @table + ') x		
			) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		PRINT @sql
		EXEC (@sql)
	
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		--DECLARE @filterQuery VARCHAR(MAX)
		--SET @filterQuery='
		--SELECT ''ASSESSMENT'' head, '+@assessement+' VALUE '
		
		--IF ISNULL(@RBAStatus,'') <> ''
		--	SET @filterQuery=@filterQuery+' UNION ALL SELECT ''RBA STATUS'' head, ' + @RBAStatus + ' VALUE '
	
		--IF ISNULL(@pendingTxnGE30,'') <> ''
		--	SET @filterQuery=@filterQuery+' UNION ALL SELECT ''PENDING'' head, ''Last TXN date>=30 Days'' VALUE '
			
		--IF ISNULL(@pendingTxnL30,'') <> ''
		--SET @filterQuery=@filterQuery+' UNION ALL SELECT ''PENDING'' head, ''Last TXN date<30 Days'' VALUE '
			
		SELECT 'ASSESSMENT' head, UPPER(@assessement) VALUE
		UNION ALL
		SELECT 'RBA STATUS' head, ISNULL(UPPER(@RBAStatus),'ALL') VALUE
		UNION ALL
		SELECT 'PENDING' head, CASE WHEN @pendingTxnGE30 IS NULL AND @pendingTxnL30 IS NULL THEN 'ALL' ELSE 
		CASE WHEN @pendingTxnGE30 IS NULL THEN 'LAST TXN DATE <30 DAYS' ELSE	'LAST TXN DATE>=30 DAYS' END END VALUE
		
		SELECT 'RBA Customer Report' title
	
 END
 
 IF @flag = 'reviewstatus'
 BEGIN
	DECLARE @oldStatus VARCHAR(15)
	
	SELECT @oldStatus = rbaStatus FROM dbo.customers WITH(NOLOCK) WHERE customerId = @customerId
	
	BEGIN TRAN
		INSERT INTO RBAreviewhistory(customerid,oldStatus,newStatus,remarks,reviewedBy,reviewedDate)
		SELECT @customerId, @oldStatus, @RBAStatus, @remarks, @user, GETDATE()

		UPDATE customers SET RBASTATUS = @RBAStatus WHERE customerId = @customerId
	COMMIT TRAN
		
	EXEC proc_errorHandler '0', 'success', @customerId
	
 END
 
 IF @flag = 'pendingRemarks'
 BEGIN
	INSERT INTO RBApendingRemarks(customerid,pendingRemarks,createdBy,createdDate)
	SELECT @customerId, @remarks, @user, GETDATE()
	EXEC proc_errorHandler '0', 'success', @customerId
 END
 
 IF @flag='calculationDetail'
 BEGIN
	DECLARE @RBA MONEY,@type VARCHAR(20)
		
	SELECT @RBA = RBA FROM customers WITH(NOLOCK) WHERE customerId = @customerId
	SELECT @type = TYPE FROM RBAScoreMaster where @RBA BETWEEN rFrom AND rTo
 
	SELECT  
		c.fullName
		,dob = CONVERT(varchar,dob,101)
		,gender
		,nativeCountry = cm.countryName
		,country = cm1.countryName
		,idType = sdv.detailTitle
		,idNumber
		,state
		,city
		,address
		,mobile
		,email
		,rba = cast(@RBA as decimal(10,2))
		,[type] = @type
	FROM customers c WITH(NOLOCK)
	INNER JOIN countryMaster cm WITH(NOLOCK) ON c.nativeCountry = cm.countryId
	INNER JOIN countryMaster cm1 WITH(NOLOCK) ON c.country = cm1.countryId
	INNER JOIN staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = c.idType
	WHERE customerId = @customerId
	
	---RBA Calculation Summary---
     SELECT [taRating] = 20 , [taWeight] = 10,[paRating] = 80 , [paWeight] = 10
  
	--RBA Calculation Summary-Transaction Assesement---
    SELECT Criteria,remarks Description, isnull(rangefrom,1) [Range From], ISNULL(rangeto,100) [Range To], ISNULL(rating,100) Rating, ISNULL(Weight,100) Weight
    FROM  rbacriteria WHERE assessmenttype='Transaction'

    --RBA Calculation Summary-Periodic Assesement--
    SELECT Criteria,ISNULL(remarks,criteria) Description, isnull(rangefrom,1) [Range From], ISNULL(rangeto,100) [Range To], ISNULL(rating,100) Rating, ISNULL(Weight,100) Weight
    FROM  rbacriteria WHERE assessmenttype='Periodic'
	
	RETURN	
 END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @customerId
END CATCH



GO
