USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_RBAExceptionRpt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_RBAExceptionRpt]

 @flag					VARCHAR(30)			= NULL
,@assessement			VARCHAR(30)			= NULL
,@customerId			VARCHAR(50)			= NULL
,@fromDate				VARCHAR(10)			= NULL
,@toDate				VARcHAR(10)			= NULL
,@sCountry				VARCHAR(250)		= NULL
,@sAgent				VARCHAR(20)			= NULL
,@sbranch				VARCHAR(20)			= NULL
,@reportType			VARCHAR(10)			= NULL
,@risk					VARCHAR(10)			= NULL
,@repCategory			VARCHAR(15)			= NULL
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

declare @url varchar(100)
	set @url='&fd='+isnull(@fromDate,'')+'&td='+isnull(@todate,'')+'&c='+isnull(@scountry,'')+'&a='+isnull(@sAgent,'')+'&b='+isnull(@sbranch,'')

IF @sCountry IS NOT NULL AND ISNUMERIC(@sCountry) = 1
	SELECT @sCountry = countryName FROM dbo.countryMaster WITH(NOLOCK) WHERE countryId = @sCountry
			
 IF(@flag='rbaer') -- Exception Rpt
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

		-- SELECT @fromDate='2014-09-01', @toDate='2014-09-30',@reportType='TXN'

		IF @reportType='TXN'
		BEGIN
		
			IF OBJECT_ID(N'tempdb..#RBATXN') IS NOT NULL
			   DROP TABLE #RBATXN

				SELECT  
				   SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo  THEN 1 ELSE 0 END ) 'HTXN'
				,  SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo AND DOB IS NOT NULL AND purposeOfRemit IS NOT NULL  THEN 1 ELSE 0 END ) HCOMPLETED_CDD
				,  SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo AND te.eddremarks IS NOT NULL THEN 1 ELSE 0 END ) HCOMPLETED_EDD
				
				,  SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo  THEN 1 ELSE 0 END ) 'MTXN'
				,  SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND DOB IS NOT NULL AND purposeOfRemit IS NOT NULL  THEN 1 ELSE 0 END ) MCOMPLETED_CDD				
				,  SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND te.eddremarks IS NOT NULL THEN 1 ELSE 0 END ) MCOMPLETED_EDD
				
				,  SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo  THEN 1 ELSE 0 END ) 'LTXN'
				,  SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo   AND DOB IS NOT NULL AND purposeOfRemit IS NOT NULL  THEN 1 ELSE 0 END ) LCOMPLETED_CDD
				,  SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo  AND te.eddremarks IS NOT NULL THEN 1 ELSE 0 END ) LCOMPLETED_EDD
				INTO #RBATXN
				FROM TRANSENDERS S WITH (NOLOCK)
				INNER JOIN REMITTRAN R WITH (NOLOCK) ON S.TRANID=R.ID
				LEFT JOIN tranEdd te WITH(NOLOCK) ON R.controlNo = te.controlNo
				WHERE R.CREATEDDATE  BETWEEN @fromDate  AND @toDate + ' 23:59:59:998'
				AND RBA IS NOT NULL
				AND ISNULL(@sCountry,scountry)=sCountry
				AND ISNULL(@sAgent,sAgent)=sAgent
				AND ISNULL(@sbranch,sBranch)=sBranch
 

			IF OBJECT_ID(N'tempdb..#RBASUSPICIOUSTXN') IS NOT NULL
			   DROP TABLE #RBASUSPICIOUSTXN


				SELECT  
				 SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo  THEN 1 ELSE 0 END ) 'SHTXN'
				,  SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo  THEN 1 ELSE 0 END ) 'SMTXN'
				,  SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo  THEN 1 ELSE 0 END ) 'SLTXN'
				INTO #RBASUSPICIOUSTXN
				FROM TRANSENDERS S WITH (NOLOCK)  INNER JOIN REMITTRAN R WITH (NOLOCK) ON S.TRANID=R.ID 
				INNER JOIN suspiciousTxnRpt ST WITH (NOLOCK) ON R.CONTROLNO=ST.CONTROLNO
				WHERE R.CREATEDDATE  BETWEEN @fromDate  AND @toDate + ' 23:59:59:998'
				AND RBA IS NOT NULL
				AND ISNULL(@sCountry,scountry)=sCountry
				AND ISNULL(@sAgent,sAgent)=sAgent
				AND ISNULL(@sbranch,sBranch)=sBranch
 

			 IF OBJECT_ID(N'tempdb..#RBATXNREPORT') IS NOT NULL
			   DROP TABLE #RBATXNREPORT


				 SELECT 'HIGH' RISK, HTXN TXN ,HCOMPLETED_CDD CDD, HCOMPLETED_EDD EDD  INTO #RBATXNREPORT FROM #RBATXN UNION ALL
				 SELECT 'MEDIUM' RISK, MTXN TXN ,MCOMPLETED_CDD CDD, MCOMPLETED_EDD EDD FROM #RBATXN UNION ALL
				 SELECT 'LOW' RISK, LTXN TXN ,LCOMPLETED_CDD CDD, LCOMPLETED_EDD EDD FROM #RBATXN  

				ALTER TABLE  #RBATXNREPORT ADD STR INT 

				UPDATE #RBATXNREPORT SET STR=SHTXN FROM #RBATXNREPORT R, #RBASUSPICIOUSTXN RS WHERE R.RISK='HIGH'
				UPDATE #RBATXNREPORT SET STR=SMTXN FROM #RBATXNREPORT R, #RBASUSPICIOUSTXN RS WHERE R.RISK='MEDIUM'
				UPDATE #RBATXNREPORT SET STR=SLTXN FROM #RBATXNREPORT R, #RBASUSPICIOUSTXN RS WHERE R.RISK='LOW'
				
				SELECT 
				RISK		=	'<a onClick="openReport(''risk'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ x.RISK+'</a>',
				TXN			=	'<a onClick="openReport(''txn'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.TXN AS VARCHAR)+'</a>',
				CDD			=	'<a onClick="openReport(''cdd'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.CDD AS VARCHAR)+'</a>',
				EDD			=	'<a onClick="openReport(''edd'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.EDD AS VARCHAR)+'</a>',
				[STR]		=	'<a onClick="openReport(''str'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.[STR] AS VARCHAR)+'</a>',
				P_CDD		=	'<a onClick="openReport(''pcdd'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.P_CDD AS VARCHAR)+'</a>' ,
				P_EDD		=	'<a onClick="openReport(''pedd'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.P_EDD AS VARCHAR)+'</a>' ,
				P_STR		=	'<a onClick="openReport(''pstr'',''txn'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.P_STR AS VARCHAR)+'</a>' 

				FROM
				(
				SELECT RISK, ISNULL(TXN,0) TXN, ISNULL(CDD,0) CDD, ISNULL(EDD,0) EDD, ISNULL([STR],0) [STR]
					, ISNULL(TXN,0) - ISNULL(CDD,0) P_CDD
					, CASE WHEN RISK <> 'LOW' THEN ISNULL(TXN,0)-ISNULL(EDD,0) ELSE 0 END P_EDD
					, CASE WHEN RISK = 'HIGH' THEN ISNULL(TXN,0)-ISNULL([STR],0) ELSE 0 END P_STR
					 FROM #RBATXNREPORT
				 )x
				 
			
		END 

		IF @reportType='CUSTOMER'
		BEGIN
			IF OBJECT_ID(N'tempdb..#RBATXNC') IS NOT NULL
			   DROP TABLE #RBATXNC

				SELECT  
				 SUM( CASE WHEN  ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @HIGHrFrom AND @HIGHrTo  THEN 1 ELSE 0 END ) 'HTXN'
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @HIGHrFrom AND @HIGHrTo AND DOB IS NOT NULL AND purposeOfRemit IS NOT NULL  THEN 1 ELSE 0 END ) HCOMPLETED_CDD
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @HIGHrFrom AND @HIGHrTo AND te.eddremarks IS NOT NULL THEN 1 ELSE 0 END ) HCOMPLETED_EDD
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @MEDIUMrFrom AND @MEDIUMrTo  THEN 1 ELSE 0 END ) 'MTXN'
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND DOB IS NOT NULL AND purposeOfRemit IS NOT NULL  THEN 1 ELSE 0 END ) MCOMPLETED_CDD
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @MEDIUMrFrom AND @MEDIUMrTo AND te.eddremarks IS NOT NULL THEN 1 ELSE 0 END ) MCOMPLETED_EDD
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @LOWrFrom AND @LOWrTo  THEN 1 ELSE 0 END ) 'LTXN'
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @LOWrFrom AND @LOWrTo   AND DOB IS NOT NULL AND purposeOfRemit IS NOT NULL  THEN 1 ELSE 0 END ) LCOMPLETED_CDD
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @LOWrFrom AND @LOWrTo  AND te.eddremarks IS NOT NULL THEN 1 ELSE 0 END ) LCOMPLETED_EDD
				INTO #RBATXNC
				FROM TRANSENDERS S WITH (NOLOCK)
				INNER JOIN REMITTRAN R WITH (NOLOCK) ON S.TRANID=R.ID
				LEFT JOIN tranEdd te WITH(NOLOCK) ON R.controlNo = te.controlNo
				WHERE R.CREATEDDATE  BETWEEN @fromDate  AND @toDate + ' 23:59:59:998'
				AND RBA IS NOT NULL
				AND ISNULL(@sCountry,scountry)=sCountry
				AND ISNULL(@sAgent,sAgent)=sAgent
				AND ISNULL(@sbranch,sBranch)=sBranch
			 

			IF OBJECT_ID(N'tempdb..#RBASUSPICIOUSTXNC') IS NOT NULL
			   DROP TABLE #RBASUSPICIOUSTXNC


				SELECT  
				 SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @HIGHrFrom AND @HIGHrTo  THEN 1 ELSE 0 END ) 'SHTXN'
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @MEDIUMrFrom AND @MEDIUMrTo  THEN 1 ELSE 0 END ) 'SMTXN'
				,  SUM( CASE WHEN ISNULL(CUSTOMERRISKPOINT,0) BETWEEN @LOWrFrom AND @LOWrTo  THEN 1 ELSE 0 END ) 'SLTXN'
				INTO #RBASUSPICIOUSTXNC
				FROM TRANSENDERS S WITH (NOLOCK)  INNER JOIN REMITTRAN R WITH (NOLOCK) ON S.TRANID=R.ID 
				INNER JOIN suspiciousTxnRpt ST WITH (NOLOCK) ON R.CONTROLNO=ST.CONTROLNO
				WHERE R.CREATEDDATE  BETWEEN @fromDate  AND @toDate + ' 23:59:59:998'
				AND RBA IS NOT NULL
				AND ISNULL(@sCountry,scountry)=sCountry
				AND ISNULL(@sAgent,sAgent)=sAgent
				AND ISNULL(@sbranch,sBranch)=sBranch
			 


			 IF OBJECT_ID(N'tempdb..#RBATXNREPORTC') IS NOT NULL
			   DROP TABLE #RBATXNREPORTC


				 SELECT 'HIGH' RISK, HTXN TXN ,HCOMPLETED_CDD CDD, HCOMPLETED_EDD EDD  INTO #RBATXNREPORTC FROM #RBATXNC UNION ALL
				 SELECT 'MEDIUM' RISK, MTXN TXN ,MCOMPLETED_CDD CDD, MCOMPLETED_EDD EDD FROM #RBATXNC UNION ALL
				 SELECT 'LOW' RISK, LTXN TXN ,LCOMPLETED_CDD CDD, LCOMPLETED_EDD EDD FROM #RBATXNC  

				ALTER TABLE  #RBATXNREPORTC ADD STR INT 

				UPDATE #RBATXNREPORTC SET STR=SHTXN FROM #RBATXNREPORTC R, #RBASUSPICIOUSTXNC RS WHERE R.RISK='HIGH'
				UPDATE #RBATXNREPORTC SET STR=SMTXN FROM #RBATXNREPORTC R, #RBASUSPICIOUSTXNC RS WHERE R.RISK='MEDIUM'
				UPDATE #RBATXNREPORTC SET STR=SLTXN FROM #RBATXNREPORTC R, #RBASUSPICIOUSTXNC RS WHERE R.RISK='LOW'
				
				SELECT 
					RISK		=	'<a onClick="openReport(''risk'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ x.RISK+'</a>',
					TXN			=	'<a onClick="openReport(''txn'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.TXN AS VARCHAR)+'</a>',
					CDD			=	'<a onClick="openReport(''cdd'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.CDD AS VARCHAR)+'</a>',
					EDD			=	'<a onClick="openReport(''edd'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.EDD AS VARCHAR)+'</a>',
					[STR]		=	'<a onClick="openReport(''str'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.[STR] AS VARCHAR)+'</a>',
					P_CDD		=	'<a onClick="openReport(''pcdd'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.P_CDD AS VARCHAR)+'</a>' ,
					P_EDD		=	'<a onClick="openReport(''pedd'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.P_EDD AS VARCHAR)+'</a>' ,
					P_STR		=	'<a onClick="openReport(''pstr'',''customer'','''+x.RISK+''','''+@url+''')" class="contentlink">'+ CAST(x.P_STR AS VARCHAR)+'</a>' 
				FROM
					(
					
					SELECT RISK, ISNULL(TXN,0) TXN, ISNULL(CDD,0) CDD, ISNULL(EDD,0) EDD, ISNULL([STR],0) [STR]
					, ISNULL(TXN,0) - ISNULL(CDD,0) P_CDD
					, CASE WHEN RISK <> 'LOW' THEN ISNULL(TXN,0)-ISNULL(EDD,0) ELSE 0 END P_EDD
					, CASE WHEN RISK = 'HIGH' THEN ISNULL(TXN,0)-ISNULL([STR],0) ELSE 0 END P_STR
					FROM #RBATXNREPORTC
				 )x
			
		END 

END

 IF(@flag='rbaer-dl')
 BEGIN
 
DECLARE @rFrom	MONEY,@rTo	MONEY
SELECT @rFrom = ISNULL(rFrom,0) ,@rTo = ISNULL(rTo,0)  FROM RBAScoreMaster WHERE [TYPE] = @risk
	
 SET @table = '
	SELECT
	  rt.sCountry
	, rt.sAgentName
	, rt.sBranchName
	, controlNoEnc = rt.controlNo
	, rt.holdTranId
	, rt.createdBy
	, rt.createdDate
	, rt.senderName
	, ts.nativeCountry
	, ts.IdType
	, ts.IdNumber
	, ts.dob
	, ts.Occupation
	, rt.purposeOfRemit
	, rt.sourceOfFund
	, rt.cAmt
	, te.eddremarks
	, rt.pCountry
	, rt.paymentMethod
	, rt.receiverName
	, ts.RBA AS txnRBA
	, ts.CUSTOMERRISKPOINT AS cusRBA
	FROM tranSenders ts WITH (NOLOCK) 
	INNER JOIN remitTran rt WITH (NOLOCK) ON ts.tranId=rt.ID	 
 	LEFT JOIN suspiciousTxnRpt str WITH(NOLOCK) ON str.CONTROLNO = rt.CONTROLNO
 	LEFT JOIN tranEdd te WITH(NOLOCK) ON rt.controlNo = te.controlNo
	WHERE ts.customerId IS NOT NULL '
	
		
	IF ISNULL(@risk,'') <> '' AND @reportType = 'TXN'
		SET @table = @table+' AND ts.RBA IS NOT NULL AND ts.RBA BETWEEN ' + CAST(@rFrom AS VARCHAR) + ' AND ' + CAST(@rTo AS VARCHAR) + ' '
	
	IF ISNULL(@risk,'') <> '' AND @reportType = 'CUSTOMER'
		SET @table = @table+'  AND ts.CUSTOMERRISKPOINT IS NOT NULL AND ts.CUSTOMERRISKPOINT BETWEEN ' + CAST(@rFrom AS VARCHAR) + ' AND ' + CAST(@rTo AS VARCHAR) + ' '
		
	IF ISNULL(@repCategory,'') = 'CDD'
		SET @table = @table+'  AND cu.dob IS NOT NULL AND purposeOfRemit IS NOT NULL '
	
	IF ISNULL(@repCategory,'') = 'EDD'
		SET @table = @table+'  AND te.eddremarks IS NOT NULL '
	
	IF ISNULL(@repCategory,'')='STR'
		SET @table = @table+'  AND str.controlNo IS NOT NULL '
		
	IF ISNULL(@repCategory,'') = 'PCDD'
		SET @table = @table+'  AND (ts.dob IS NULL OR purposeOfRemit IS NULL) '
	
	IF ISNULL(@repCategory,'') = 'PEDD'
		SET @table = @table+'  AND te.eddremarks IS NULL '
	
	IF ISNULL(@repCategory,'')='PSTR'
		SET @table = @table+'  AND str.STATUS IS NULL '
	
	
	IF ISNULL(@fromDate,'') <> '' AND ISNULL(@toDate,'') <> ''
		SET @table = @table + ' AND rt.createdDate BETWEEN '''+ @fromDate +''' AND '''+ @toDate +' 23:59:59'''
	
	IF ISNULL(@sCountry,'') <> ''
			SET @table=@table+'  AND rt.sCountry = ''' + @sCountry + ''' '
	
	IF ISNULL(@sAgent,'') <> ''
			SET @table=@table+'  AND rt.sAgent = ''' + @sAgent + ''' '
	
	IF ISNULL(@sbranch,'') <> ''
			SET @table=@table+'  AND rt.sBranch = ''' + @sbranch + ''' '
	
	
	
	SET @sql = 'SELECT 
						COUNT(*) AS TXNCOUNT
						,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
						,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
					FROM (' + @table + ') x'
		PRINT @sql
		EXEC (@sql)
			
		SET @sql = '
				SELECT
				 [Country]			= sCountry
				,[Agent]			= sAgentName
				,[Branch]			= sBranchName
				,[Tran Id]			= holdTranId
				,[User]				= createdBy
				,[Date]				= createdDate
				,[Sender Name]		= senderName
				,[Native Country]	= nativeCountry
				,[ID Type]			= idType
				,[ID Number]		= IdNumber
				,[DOB]				= dob
				,[Occupation]		= Occupation
				,[Purpose]			= purposeOfRemit
				,[Source Of Fund]	= sourceOfFund
				,[Coll. Amt.]		= cAmt
				,[EDD Remarks]		= eddRemarks
				,[Payout Country]	= pCountry
				,[Payment Mode]		= paymentMethod
				,[Receiver]			= receiverName
				,[TXN RBA]			= txnRBA
				,[Customer RBA]		= cusRBA
				
				
			FROM (		
				SELECT 
					ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS [S.N],* 
				FROM (' + @table + ') x		
			) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		PRINT @sql
		EXEC (@sql)
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		DECLARE @fCountry VARCHAR(50),@fAgent VARCHAR(100),@fBranch VARCHAR(100)
		
		--SELECT @fCountry = countryName FROM countryMaster WITH(NOLOCK) WHERE countryId=@sCountry
		SELECT @fAgent=agentName FROM agentMaster WHERE agentId=@sAgent
		SELECT @fBranch=agentName FROM agentMaster WHERE parentId=@sAgent and agentId=@sbranch
		
		SELECT 'From Date' head, @fromDate VALUE
		UNION ALL
		SELECT 'To Date' head, @toDate VALUE
		UNION ALL
		SELECT 'Country' head, ISNULL(UPPER(@sCountry),'ALL') VALUE
		UNION ALL
		SELECT 'Agent' head, ISNULL(UPPER(@fAgent),'ALL') VALUE
		UNION ALL
		SELECT 'Branch' head, ISNULL(UPPER(@fBranch),'ALL') VALUE
		UNION ALL
		SELECT 'Report Type' head, ISNULL(UPPER(@reportType),'ALL') VALUE
		
		SELECT 'RBA Exception Report' title
	
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
