

ALTER procEDURE [dbo].[proc_complianceReleaseReport](
--declare	 
	@flag				VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@fromDate			VARCHAR(50)     = NULL
	,@toDate			VARCHAR(50)		= NULL
	,@releasedBy		VARCHAR(50)		= NULL
	,@includesystem		CHAR(1)			= NULL
	,@reportType		VARCHAR(20)		= NULL
	,@idNumber			VARCHAR(20)		= NULL
	,@customerName		VARCHAR(100)	= NULL
	,@holdReason		VARCHAR(50)		= NULL
)
AS 
BEGIN TRY	
	SET NOCOUNT ON
	--SELECT  @flag='s',@fromDate='2016-04-21',@toDate='2016-04-26',@releasedBy=null,@includesystem='N',@idNumber=null,@customerName=null,@reportType='Detail-Report',@holdReason=null
	IF @flag ='s'
	BEGIN
			
		DECLARE @SQL VARCHAR(MAX)

		IF OBJECT_ID(N'tempdb..#REASON') IS NOT NULL
		DROP TABLE #REASON

		SELECT
			csDetailRecId 
			,condition
			,[Remarks] = RTRIM(LTRIM(dbo.FNAGetDataValue(condition) + ' ' + 
				CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
				WHEN checkType = 'Count' THEN 'Transaction Count' END
			+ ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' day(s) ' + dbo.FNAGetDataValue(criteria) )) 
		INTO #REASON
		FROM csDetailRec cdr (NOLOCK)
		
		CREATE NONCLUSTERED INDEX idx_CSDETAILrecID ON #REASON(CSDETAILrecID, [Remarks])
	
		IF OBJECT_ID(N'tempdb..#TEMP') IS NOT NULL
			DROP TABLE #TEMP

		CREATE TABLE #TEMP
		(
			TRANID BIGINT,
			APPROVEDDATE DATETIME,
			APPROVEDBY VARCHAR(200)
		)

		SET @SQL = 'SELECT 
						DISTINCT TRANID, APPROVEDDATE, ISNULL(APPROVEDBY,''SYSTEM'') APPROVEDBY	
					FROM remittrancompliance  WITH (NOLOCK)
					WHERE APPROVEDDATE BETWEEN '''+ @fromDate+''' AND '''+  @toDate + ' 23:59:59:998'''


		IF @includesystem='N'
		BEGIN
			SET @SQL=@SQL +'AND APPROVEDBY<>''SYSTEM'''
		END

		INSERT INTO #TEMP(TRANID,APPROVEDDATE,APPROVEDBY)
		EXEC (@SQL) 

		--PRINT @SQL

		CREATE NONCLUSTERED INDEX idx_temp ON #TEMP(TRANID, APPROVEDDATE) INCLUDE (APPROVEDBY)
		ALTER TABLE  #TEMP ADD TRANDATE DATETIME,TAT BIGINT,REASON VARCHAR(MAX), approvedremarks VARCHAR(MAX)
	
		UPDATE t SET 
			TRANDATE= CREATEDDATELOCAL		
		FROM #TEMP t
		INNER JOIN VWREMITTRANALL VW WITH (NOLOCK) ON T.TRANID = VW.HOLDTRANID
	
		UPDATE t SET 
			TRANDATE= CREATEDDATELOCAL		
		FROM #TEMP t
		INNER JOIN VWREMITTRANALL VW WITH (NOLOCK) ON T.TRANID = ID
		WHERE HOLDTRANID IS NULL

		UPDATE #TEMP SET TAT = DATEDIFF(SECOND, TRANDATE, approvedDate)
		UPDATE t SET 
			approvedremarks = rc.approvedremarks 
		FROM #TEMP t
		INNER JOIN remittrancompliance rc WITH (NOLOCK) on t.tranId=rc.tranId
	

		IF @reportType='Summary-Date'
		BEGIN
			SELECT 
			 [Released Date]= CONVERT(VARCHAR(10),approvedDate, 102)
			,[Compliance_Average TAT(Min)]= AVG(TAT)/60
			,[Compliance_MAX TAT(Min)]= MAX(TAT)/60
			,[Compliance_MIN TAT(Sec)]= MIN(TAT)
			,[Compliance_TXN]= COUNT(*)
			 FROM #TEMP  
			 GROUP BY CONVERT(VARCHAR(10),approvedDate, 102)

			UNION ALL

			SELECT 
			 [Released Date]= 'Total'
			,[Compliance_Average TAT(Min)]= AVG(TAT)/60
			,[Compliance_MAX TAT(Min)]= MAX(TAT)/60
			,[Compliance_MIN TAT(Sec)]= MIN(TAT)
			,[Compliance_TXN]= COUNT(*)
			 FROM #TEMP
			 ORDER BY CONVERT(VARCHAR(10),approvedDate, 102)
		END	

		IF @reportType='Summary-User'
		BEGIN
			SELECT 
				[Released By],[Compliance_Average TAT(Min)],[Compliance_MAX TAT(Min)],[Compliance_MIN TAT(Sec)],[Compliance_TXN]
			FROM (
				SELECT 
					 1 SN
					,[Released By]= approvedBy 
					,[Compliance_Average TAT(Min)]= AVG(TAT)/60
					,[Compliance_MAX TAT(Min)]= MAX(TAT)/60
					,[Compliance_MIN TAT(Sec)]= MIN(TAT)
					,[Compliance_TXN]= COUNT(*)
				FROM #TEMP  
				GROUP BY approvedBy
				UNION ALL

				SELECT 
					 2 SN,
					 [Released By]= 'Total'
					,[Compliance_Average TAT(Min)]= AVG(TAT)/60
					,[Compliance_MAX TAT(Min)]= MAX(TAT)/60
					,[Compliance_MIN TAT(Sec)]= MIN(TAT)
					,[Compliance_TXN]= COUNT(*)
				FROM #TEMP
			) x
			ORDER BY SN, [Released By]
		END


	IF @reportType='Summary-Reason'
	BEGIN
		SELECT 
			R.complainceDetailMessage Reason,COUNT(*) TXN 
		FROM remittrancompliance RC WITH (NOLOCK)
		INNER JOIN #TEMP T ON RC.TRANID=T.TRANID
		INNER JOIN compliancelog R WITH (NOLOCK) ON R.tranid=RC.tranid
			WHERE RC.REASON IS NULL
		GROUP BY   complainceDetailMessage

		UNION ALL
		SELECT
			RC.reason, COUNT(*) TXN 
		FROM remittrancompliance RC WITH (NOLOCK)
		INNER JOIN #TEMP T ON RC.TRANID=T.TRANID
			WHERE RC.REASON IS NOT NULL
		GROUP BY   RC.reason		
		UNION ALL
		SELECT  'Unique Transaction' reason, COUNT(*) FROM #TEMP
	END

	IF @reportType='Detail-Report'
	BEGIN
		IF @holdReason is NOT NULL
		BEGIN
			ALTER TABLE #TEMP ADD FLAG INT
			UPDATE #TEMP SET FLAG = 1  FROM #TEMP T 
			INNER JOIN remittrancompliance RC WITH (NOLOCK) ON T.TRANID=RC.TRANID
			WHERE rc.REASON IS NOT NULL
			AND RC.REASON LIKE '%'+@holdReason+'%'

			UPDATE #TEMP SET FLAG=1 FROM #TEMP T 
			INNER JOIN  remittrancompliance RC WITH (NOLOCK) ON T.TRANID=RC.TRANID
			INNER JOIN (
				SELECT * FROM #REASON WHERE REMARKS LIKE '%'+ @holdReason+'%'
			) X ON RC.CSDETAILTRANID=X.CSDETAILRECID
			WHERE rc.REASON IS  NULL
			DELETE FROM #TEMP WHERE FLAG IS NULL
		END
		
		;WITH temptable
		AS
		(
			SELECT 
				t.TRANID,rc.REASON Remarks 
			FROM #TEMP T
			INNER JOIN remittrancompliance RC WITH (NOLOCK) ON T.TRANID=RC.TRANID
				WHERE rc.REASON IS NOT NULL
			GROUP BY t.TRANID,rc.REASON
			UNION ALL
			SELECT 
				t.TRANID,Remarks = complianceReason
			FROM #TEMP T
			INNER JOIN remitTranCompliance RC WITH (NOLOCK) ON T.TRANID=RC.TRANID
			INNER JOIN compliancelog R WITH (NOLOCK) ON R.tranid=RC.tranid
				WHERE rc.REASON IS NULL
			GROUP BY t.TRANID,r.complianceReason
		)
				
		 UPDATE #TEMP SET reason=x.DATASOURCE
		 FROM #TEMP t
		 INNER JOIN (
			SELECT
				ct.tranid,
				STUFF
					(
						(
							SELECT 
								',' + Remarks
							FROM (
							SELECT 
								TRANID, Remarks 
							FROM temptable
						) sht
						WHERE sht.tranid = ct.tranid
						FOR XML PATH('')
						,type
					).value('.', 'varchar(max)'), 1, 1, ''
				) AS DATASOURCE
			FROM (
				SELECT 
					TRANID 
				FROM #TEMP 
				GROUP BY TRANID
			) ct
		--INNER JOIN #TEMP cd ON ct.TRANID = cd.TRANID
	) x ON  t.TRANID=x.TRANID
	

	DECLARE @Filter VARCHAR(MAX) = ''

	IF @idNumber IS NOT NULL
		SET @Filter= @Filter + ' AND TS.idNumber='''+@idNumber+''''

	IF @customerName is NOT NULL
		SET @Filter= @Filter + ' AND TS.fullName='''+@customerName+''''
	IF @releasedBy is NOT NULL
		SET @Filter= @Filter + ' AND t.approvedby='''+@releasedBy+''''


	--SET @SQL='
	SET @SQL = '
	SELECT 	
		--[S.N]= ROW_NUMBER() OVER (ORDER BY [TXN No.]),
		*
	FROM (
		SELECT 	
			[TXN Date]= RT.createdDate,
			[TXN No.]    = RT.id,
			[JME No.]    = DBO.DECRYPTDB(RT.CONTROLNO),
			[Sender Name]= RT.senderName,
			[ID Type]= TS.idType,
			[ID Number]= TS.idNumber,
			[Receiver Name]= RT.receiverName,
			[Sending_Country]= RT.sCountry,
			[Sending_Agent]= RT.sAgentName,
			[Sending_Branch]= RT.sBranchName,
			[Sending_User]= RT.createdBy,
			[Collection_Currency]= RT.collCurr,
			[Collection_Amount]= RT.cAmt,
			[Receiving_Currency]= RT.payoutCurr,
			[Receiving_Amount]= RT.pAmt,
			[Receiving_Country]= RT.pCountry,
			[Hold Reason]= t.reason,
			[Approved By]=t.approvedby,
			[Approved On]=t.approveddate,
			[Approver Remarks]=t.approvedremarks	
		FROM vwremitTranAll RT WITH (NOLOCK)
		INNER JOIN VWtranSendersall TS WITH (NOLOCK) ON RT.id=TS.tranId
		INNER JOIN vwtranReceiversALL TR WITH (NOLOCK) ON RT.id=TR.tranId
		LEFT JOIN staticDataValue SV WITH (NOLOCK) ON ts.idType = SV.detailtitle
		INNER JOIN #TEMP t on RT.holdtranid=t.tranid 
		WHERE 1=1 ' + @Filter + '
		
		UNION ALL
		SELECT 	
			[TXN Date]= RT.createdDate,
			[TXN No.]    = RT.id,
			[JME No.]    = DBO.DECRYPTDB(RT.CONTROLNO),
			[Sender Name]= RT.senderName,
			[ID Type]= TS.idType,
			[ID Number]= TS.idNumber,
			[Receiver Name]= RT.receiverName,
			[Sending_Country]= RT.sCountry,
			[Sending_Agent]= RT.sAgentName,
			[Sending_Branch]= RT.sBranchName,
			[Sending_User]= RT.createdBy,
			[Collection_Currency]= RT.collCurr,
			[Collection_Amount]= RT.cAmt,
			[Receiving_Currency]= RT.payoutCurr,
			[Receiving_Amount]= RT.pAmt,
			[Receiving_Country]= RT.pCountry,
			[Hold Reason]= t.reason,
			[Approved By]=t.approvedby,
			[Approved On]=t.approveddate,
			[Approver Remarks]=t.approvedremarks	
		FROM vwremitTranAll RT WITH (NOLOCK)
		INNER JOIN VWtranSendersall TS WITH (NOLOCK) ON RT.id=TS.tranId
		INNER JOIN vwtranReceiversALL TR WITH (NOLOCK) ON RT.id=TR.tranId
		LEFT JOIN staticDataValue SV WITH (NOLOCK) ON ts.idType = SV.detailtitle
		INNER JOIN #TEMP t on RT.ID=t.tranid 
		WHERE RT.holdtranid IS NULL ' + @Filter + '
	) x'
		
	EXEC (@SQL) 
	--PRINT @SQL
END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	IF OBJECT_ID(N'tempdb..#filter') IS NOT NULL
	DROP TABLE #filter

	CREATE TABLE #filter(head varchar(200), value varchar(500))
	INSERT INTO #filter(head,value)
	SELECT 'From Date' head, value = @fromDate UNION ALL		
	SELECT 'To Date' head,  value = @toDate
		
	IF @releasedBy IS NOT NULL
	INSERT INTO #filter(head,value)	VALUES('released By', @releasedBy)
	
	INSERT INTO #filter(head,value)	VALUES('Include System Release', CASE WHEN @includesystem = 'Y' THEN 'YES' ELSE 'NO' END)
		
	IF @idNumber IS NOT NULL
	INSERT INTO #filter(head,value)	VALUES('Id Number', @idNumber)
		
	IF @customerName IS NOT NULL
	INSERT INTO #filter(head,value)	VALUES('Customer Name', @customerName)
		
	IF @reportType IS NOT NULL
	INSERT INTO #filter(head,value)	VALUES('Report Type', @reportType)

	IF @holdReason IS NOT NULL
	INSERT INTO #filter(head,value)	VALUES('Hold Reason', @holdReason)
		
	SELECT * FROM #filter
		
		SELECT 'Compliance Release Report' title
		RETURN	
	END
	
	ELSE IF @flag = 'ddl'
	BEGIN
		SELECT  'Transaction Amount' Value,  'Transaction Amount' Reason UNION ALL
		SELECT  'Transaction Count' Value, 'Transaction Count' Reason  UNION ALL
		SELECT 'Multiple POS' Value, 'Multiple POS' Reason UNION ALL
		SELECT 'Suspected Duplicate' Value, 'Suspected Duplicate' Reason
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
END CATCH





