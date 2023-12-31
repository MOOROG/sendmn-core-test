USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnDocumentsForAgent]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_txnDocumentsForAgent]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(50)		= NULL
	,@rowId				BIGINT			= NULL
	,@tranId			VARCHAR(50)		= NULL
	,@agentId			VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(30)		= NULL
	,@agent				VARCHAR(200)	= NULL		
	,@status			VARCHAR(50)		= NULL
	,@receivedId		VARCHAR(50)		= NULL
	,@controlNo			VARCHAR(20)     = NULL
	,@tranAmt           VARCHAR(50)     = Null
	,@senderName		VARCHAR(50)		= NULL
	,@receiverName		VARCHAR(50)		= NULL
	,@createdBy			VARCHAR(50)		= NULL
	,@createdDate		DATE			= NULL	
	,@fileDescription	VARCHAR(100)	= NULL
	,@fileType			VARCHAR(100)	= NULL	
	,@txnYear			VARCHAR(100)	= NULL	
	,@fileName			VARCHAR(100)	= NULL	
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@pageSize			VARCHAR(50)		= NULL
	,@pageNumber		VARCHAR(50)		= NULL
	,@txnType			VARCHAR(50)		= NULL
	,@userName			VARCHAR(100)    = NULl
	,@isDocUpload		VARCHAR(100)    = NULL
	,@vouType			VARCHAR(20)		= NULL
	,@remarks			VARCHAR(Max)	= NULL
	,@agentName			VARCHAR(200)	= NULL
	,@pAmt				VARCHAR(100)    = NULL
	,@sendCardNo		VARCHAR(50)		= NULL
	,@recCardNo			VARCHAR(50)		= NULL
			
AS

/*
EXEC proc_txnDocuments @flag='deleteDoc',@user='admin',@rowId='28'
*/
SET NOCOUNT ON;
CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
DECLARE	 @table			        VARCHAR(MAX)	  
		,@selectFieldList	VARCHAR(MAX)
		,@extraFieldList	VARCHAR(MAX)
		,@sqlFilter			VARCHAR(MAX)	
		,@sql				VARCHAR(MAX)
	
IF @flag = 's'
BEGIN	 	
	IF @sortBy IS NULL  
		SET @sortBy = 'id'
	IF @sortOrder IS NULL  
		SET @sortOrder = 'DESC'			
		SET @table = '(	SELECT DISTINCT
							rt.id,controlNo	= dbo.FNADecryptString(rt.controlNo) 
							,tranAmt	= rt.pAmt
							,senderName = rt.senderName
							,receiverName = rt.receiverName
							,txnType1 = CASE WHEN rT.sAgent = '''+@agent+'''   AND tranType = ''D'' THEN ''sd''
												WHEN pAgent = '''+@agent+'''   AND tranType = ''D'' THEN ''pd''
												WHEN pAgent = '''+@agent+'''   AND tranType = ''I'' THEN ''pi'' END
							,txnType = CASE WHEN rT.sAgent  = '''+@agent+'''   AND tranType = ''D'' THEN ''Send Domestic''
												WHEN pAgent = '''+@agent+'''   AND tranType = ''D'' THEN ''Paid Domestic''
												WHEN pAgent = '''+@agent+'''   AND tranType = ''I'' THEN ''Paid Intl'' END
							,createdDate =rt.createdDate
							,[status] = CASE WHEN v.tranId IS NULL THEN ''Not-Reconciled'' ELSE v.status END
							,isDocUpload = CASE WHEN d.tdId IS NOT NULL THEN ''Y'' ELSE ''N'' END	
							
							FROM remitTran rt(NOLOCK)
							LEFT JOIN txnDocuments D(NOLOCK) ON RT.id = D.tdId AND D.AGENTID = '''+@agent+''' --AND D.txnType<>D.txnType
							LEFT JOIN voucherReconcilation V (NOLOCK) on d.tdId = v.tranId and d.txnType = v.voucherType
							WHERE rT.tranType IS NOT NULL and (rT.sagent = '''+@agent+''' or rT.pagent = '''+@agent+''')  '			
			
		SET @sqlFilter = '' 
	print @table
	IF @controlNo IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND controlNo LIKE ''' +@controlNo+''''	

	IF @txnType IS NOT NULL 
		SET @sqlFilter=@sqlFilter + ' AND txnType1 = ''' +@txnType+''''		

	IF @status IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND status = ''' +@status+''''	

	IF @isDocUpload IS NOT NULL
		SET @sqlFilter=@sqlFilter + ' AND isDocUpload = ''' +@isDocUpload+''''	
		
	IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
	BEGIN
		IF ISNULL(@txnType,'') = 'sd'
		BEGIN
		 SET @table = @table + ' AND rt.createdDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'''
		END
		ELSE IF ISNULL(@txnType,'') IN('pd','pi')
		BEGIN
		 SET @table = @table + ' AND rt.PaidDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'''
		END
		ELSE
		BEGIN		  
			SET @table = @table + ' AND (rt.createdDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'''
			SET @table = @table + ' OR rt.PaidDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'')'
		END
	END
		
	SET @table = @table + ')x'

	SET @table='(SELECT 
					   x.id
					 , x.controlNo
					 , x.tranAmt								
					 , x.senderName
					 , x.receiverName
					 ,x.txnType
					 ,convert(varchar,x.createdDate,101) as createdDate
					 ,x.txnType1
					 ,x.status
					-- ,link1=CASE WHEN x.status=''Reconciled'' THEN ''<a class="button" style="text-decoration:none;color:white; !important" href="BrowseDoc.aspx?status=''+x.status+''&txnType=''+x.txnType1+''&id=''+cast(x.id as varchar)+''">Browse Doc</a>'' ELSE ''<a c

lass="button" style="text-decoration:none;color:white; !important" href="BrowseDoc.aspx?txnType=''+x.txnType1+''&id=''+cast(x.id as varchar)+''">Browse Doc</a><input type="button" value="Scan" onclick=''''ScanDocument("''+cast(id as varchar)+''", "''+cont

rolNo+''","''+txnType1+''");''''/>'' END 
					 ,link=CASE WHEN x.status=''Reconciled'' THEN ''<input type="button" value="Browse Doc" onClick=OpenInNewWindow("BrowseDoc.aspx?status=''+x.status+''&txnType=''+x.txnType1+''&id=''+cast(x.id as varchar)+''")></a>'' ELSE ''<input type="button" value="

Browse Doc" onClick=OpenInNewWindow("BrowseDoc.aspx?txnType=''+x.txnType1+''&id=''+cast(x.id as varchar)+''")></a><input type="button" value="Scan" onclick=''''ScanDocument("''+cast(id as varchar)+''", "''+controlNo+''","''+txnType1+''");''''/>'' END 				

	
					 ,x.isDocUpload
	
	              FROM '+@table+ ')a';


	SET @selectFieldList = '
					   id
					 , controlNo
					 , tranAmt								
					 , senderName
					 , receiverName
					 ,txnType
					 ,createdDate
					 ,txnType1
					 ,status
					 ,link	
					 ,isDocUpload		
					 '	
	
	print @table

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
IF @flag = 'i'
BEGIN			
	SELECT 
		@controlNo=dbo.FNADecryptString(controlNo) 
		FROM remittran WITH(NOLOCK) 
	WHERE id=@rowId	

	DECLARE @sn INT
	SELECT 
		 @sn = COUNT(*)
		FROM txnDocuments (NOLOCK) WHERE controlNo = @controlNo
	SELECT @sn = ISNULL(@sn, 0) + 1	
		SET @fileName = @ControlNo + +'_'+ CAST(@sn AS VARCHAR) + '.' + @fileType
	
	INSERT INTO txnDocuments (tdId, controlNo, [fileName], fileDescription, fileType, [year], agentId, createdBy, createdDate,txnType)
		SELECT @rowId, @controlNo, @fileName, @fileDescription, @fileType, @txnYear, @agentId, @user, GETDATE(),@txnType
	SET @rowId = SCOPE_IDENTITY()		
	EXEC proc_errorHandler 0, 'File Uploaded Successfully', @fileName
	RETURN
END
ELSE IF @flag='displayDoc'
BEGIN
	SELECT 
		rowId
		,tdId	
		,fileName
		,fileDescription
		,createdBy
		,createdDate
		,[year]
		,agentId
		,txnType
	FROM txnDocuments WITH(NOLOCK) 
	WHERE tdId=@rowId 
		AND (isDeleted = 'N' OR isDeleted IS NULL)
		AND txnType=@txnType
		RETURN
END
ELSE IF @flag = 'a'
BEGIN
	SELECT * FROM txnDocuments WITH(NOLOCK) WHERE rowId = @rowId 
	RETURN
END
ELSE IF @flag='image-display'
BEGIN
	SELECT 
		 [fileName] = fileName
		 ,fileDescription
		 ,agentId
		FROM txnDocuments a WITH(NOLOCK)
		WHERE tdid=@rowId AND isDeleted IS NULL		
	    RETURN	
END	
ELSE IF @flag='deleteDoc'
BEGIN
	SELECT @tranId=tdid from txnDocuments WHERE rowId = @rowId		

	IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE tranId = @tranId and status='Reconciled' AND voucherType=@txnType)
	BEGIN		
		EXEC proc_errorHandler 1, 'Document Already Reconciled!! You Cannot Delete this document', NULL
	    RETURN
	END
	DECLARE @path VARCHAR(255)
		SELECT 
			@path = CAST([Year] AS VARCHAR(20)) + '\' + CAST(agentId AS VARCHAR(20)) + '\' + [fileName]
		FROM txnDocuments (NOLOCK) WHERE rowId = @rowId
		DELETE txnDocuments WHERE rowId = @rowId
		EXEC proc_errorHandler 0, 'File Deleted Successfully', @path
		RETURN
END	
ELSE IF @flag='at'
BEGIN
	SELECT  NULL [value], 'Select' [text] UNION ALL			
	SELECT 'sd','Send Domestic'    UNION ALL	
	SELECT 'pd','Paid Domestic'    UNION ALL	
	SELECT 'pi','Paid International'
	RETURN

END
ELSE IF @flag='isDoc'
BEGIN
	SELECT NULL [value], 'Select' [text] UNION ALL			
	SELECT 'y','Yes' UNION ALL	
	SELECT 'n','No' 
	RETURN
END
ELSE IF @flag='status'
BEGIN
	SELECT NULL as value, 'Select' [text] UNION ALL			
	SELECT 'Reconciled','Reconciled' UNION ALL	
	SELECT 'Complain','Complain'  UNION ALL	
	SELECT 'Not-Reconciled','Not-Reconciled'
	RETURN
END
IF @flag = 'agent-wise'
BEGIN
	SET @sql =	'SELECT
		x.[date] As Date
		,count([Transaction]) AS [Transaction]
		,count([Upload Transaction]) AS [Upload Transaction]
		,count([Transaction])-count([Upload Transaction]) AS [Remaining Transaction]			
		 FROM 
			 (
				SELECT 
					[date]=CONVERT(VARCHAR,rt.createdDate,101)
					,rt.id AS [Transaction]
					,td.tdId AS [Upload Transaction]											
				FROM remitTran rt LEFT JOIN txnDocuments td ON rt.id=td.tdId
				WHERE (rt.sAgent='''+@agentId+''' or rt.pAgent='''+@agentId+''')
				AND rt.createdDate BETWEEN '''+@fromDate+''' and '''+@toDate+' 23:59:59''	'
								
			
	IF @controlNo is not null 
		SET @sql = @sql +' AND dbo.FNADecryptString(rt.controlNo)='''+ @controlNo +''''	
			
	IF @isDocUpload IS NOT NULL
		BEGIN
			SET @sql = @sql + CASE @isDocUpload WHEN 'Y' THEN ' AND  td.tdId IS NOT NULL ' ELSE  ' AND  td.tdId IS NULL ' END 
		END		
		SET @sql= @sql +	')x WHERE 1=1 '	

		SET @sql=@sql+' GROUP by x.[date]'

	    PRINT @sql
		EXEC(@sql)									


		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value ,NULl
		UNION ALL
		SELECT  'ICN' head, @controlNo  value ,NULL
		UNION ALL 
		SELECT  'Is Doc-Uploaded' head, @isDocUpload  value ,NULL
		SELECT 'Agent Send/Paid - Reconciliation Report ' title
		RETURN;
END
IF @flag = 'list'
BEGIN	 	
	IF @sortBy IS NULL  
		SET @sortBy = 'id'
	IF @sortOrder IS NULL  
		SET @sortOrder = 'DESC'			
		SET @table = '(	
						SELECT
						 controlNo 
						,agentName 
						,id 
						,DATE
						,txnType 
						,txnType1 
						,agent 
						,status
						,senderName
						,receiverName
						,pAmt
						,sendCardNo
						,recCardNo
					 FROM
					  (					
						SELECT DISTINCT 
								controlNo 
								,agentName 
								,id 
								,MAX(date) As DATE
								,txnType 
								,txnType1 
								,agent 
								,status
								,senderName
								,receiverName
								,pAmt
								,sendCardNo
								,recCardNo
							FROM
							 (
								  SELECT      
									   controlNo=dbo.fnaDecryptString(rt.controlNo)     
									  ,agentName=am.agentName
									  ,id=rt.id 
									  ,td.date
									  ,txnType=  CASE 
													WHEN  td.txnTYpe=''sd''   THEN ''Send Domestic'' 
													WHEN  td.txnTYpe=''pd''   THEN ''Paid Domestic'' 
													WHEN  td.txnTYpe=''pi''   THEN ''Paid Intl''  
												END 
									  ,txnType1 = td.txnType 
									  ,agent=td.agentId  
									  ,status=CASE WHEN vr.tranId IS NULL THEN ''Not-Reconciled'' ELSE vr.status END
									  ,rt.senderName
									  ,rt.receiverName
									  ,rt.pAmt
									  ,sendCardNo=sen.membershipId
									  ,recCardNo=rec.membershipId
									FROM 
									(
										   SELECT Distinct 
												agentId
												,tdid
												,txnType
												,date = max(createdDate)
											 FROM txnDocuments (NOLOCK) WHERE 1 = 1 
											 ' +
												CASE WHEN @txnType IS NOT NULL THEN 'AND txnType = ''' +@txnType+'''' ELSE '' END
											  +
											 '
											 GROUP BY agentId, tdid, txnType
									 ) td 
									INNER JOIN dbo.remitTran rt ON td.tdId=rt.id
									INNER JOIN agentMaster am  (NOLOCK) ON am.agentId=td.agentId  
									LEFT JOIN dbo.voucherReconcilation vr ON vr.tranId = rt.id and vr.vouchertype = td.txnType
									INNER JOIN tranSenders sen with(nolock) on rt.id=sen.tranId
			                 		INNER JOIN tranReceivers rec with(nolock) on rt.id=rec.tranId
							 )xx GROUP BY  controlNo,agentName,id,txnType,txnType1,agent,status,senderName ,receiverName,pAmt,sendCardNo,recCardNo
					  )yy  WHERE 1=1 
				   ) pp'
		

	SET @sqlFilter = '' 

	IF @controlNo IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND controlNo = ''' +@controlNo+''''	

	IF @agentName IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND agentName LIKE ''' +@agentName+'%'''	
	
	IF @senderName IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND senderName LIKE ''' +@senderName+'%'''	

	IF @receiverName IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND receiverName LIKE ''' +@receiverName+'%'''
		
	IF @pAmt IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND pAmt = ''' +@pAmt+''''	

	IF @txnType IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND txnType1 = ''' +@txnType+''''	

	IF @status IS NOT NULL  
		SET @sqlFilter=@sqlFilter + ' AND status = ''' +@status+''''	
		
	IF @sendCardNo IS NOT NULL
		SET @sqlFilter=@sqlFilter +' and sendCardNo ='''+@sendCardNo+''''	
																				
	IF @recCardNo IS NOT NULL
		SET @sqlFilter=@sqlFilter +' and recCardNo ='''+@recCardNo+''''
					

	IF @fromDate IS NOT NULL  AND @toDate IS NOT NULL
		SET @sqlFilter = @sqlFilter + ' AND date BETWEEN ''' + CONVERT(VARCHAR,@fromDate,101) + ''' AND ''' + CONVERT(VARCHAR,@toDate,101) + ' 23:59:59'''	
	

	SET @selectFieldList = '
					   id
					 , controlNo
					 , agent								
					 , date
					 , status
					 , txnType
					 ,txnType1
					 ,agentName
					 ,senderName
					 ,receiverName
					 ,pAmt
					 ,sendCardNo
					 ,recCardNo
					 '	

	

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
ELSE IF @flag='approve'
BEGIN
	IF NOT EXISTS(SELECT 'x' FROM txnDocuments WITH(NOLOCK) WHERE tdid = @tranId )
	BEGIN		
		  EXEC proc_errorHandler 1, 'Document Has been Deleted!!', NULL
		  RETURN
	END
	IF @user IS NULL
	BEGIN
	    EXEC proc_errorHandler 1, 'Your session has expired. Please relogin to the system.' , NULL
		RETURN
	END
	
	IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE tranId = @tranId AND voucherType = @vouType AND agentId=@agentId)
	BEGIN
		  UPDATE voucherReconcilation SET status='Reconciled' ,remarks=@remarks WHERE tranId = @tranId AND voucherType = @vouType AND agentId=@agentId
		  EXEC proc_errorHandler 0, 'Document Reconciled Successfully', NULL
		  
	END

	IF @vouType='sd'
		BEGIN
			INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
				SELECT '','','',@tranId,@remarks,'Reconciled',@vouType,approvedDate,@user,GETDATE(),@agentId
			FROM remittran WITH(NOLOCK) WHERE id=@tranId
			
		END
	IF @vouType='pd'
		BEGIN
			INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
				SELECT '','','',@tranId,@remarks,'Reconciled',@vouType,approvedDate,@user,GETDATE(),@agentId
			FROM remittran WITH(NOLOCK) WHERE id=@tranId
			
		END
	IF @vouType='pi'
		BEGIN		
			INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
				SELECT '','','',@tranId,@remarks,'Reconciled',@vouType,paidDate,@user,GETDATE(),@agentId
			FROM remittran WITH(NOLOCK) WHERE id=@tranId
				
		END	
		EXEC proc_errorHandler 0, 'Document Reconciled Successfully', NULL
		
        UPDATE txnDocuments  SET 
				--approvedBy = @user
			   --,approvedDate = GetDate()
			   status = 'Approved'	 
		  WHERE tdid = @tranId and txnType = @vouType AND agentId=@agentId

       EXEC proc_errorHandler 0, 'Document Uploaded Successfully', NULL

END
ELSE IF @flag='reject'
BEGIN	
	
	IF NOT EXISTS(SELECT 'x' FROM txnDocuments WITH(NOLOCK) WHERE tdid = @tranId )
	BEGIN		
		  EXEC proc_errorHandler 1, 'Document has been Deleted!!', NULL
		  RETURN
	END
	IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Please relogin to the system.' , NULL
			RETURN
		END
	IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE tranId = @tranId and voucherType = @vouType AND agentId=@agentId)
		BEGIN
		  UPDATE voucherReconcilation SET status='Complain' ,remarks=@remarks WHERE tranId=@tranId AND voucherType = @vouType AND agentId=@agentId
		  EXEC proc_errorHandler 0, 'Document Rejected Successfully' , NULL
		  
		END
	IF @vouType='sd'
		BEGIN
			INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
				SELECT '','','',@tranId,@remarks,'Complain',@vouType,approvedDate,@user,GETDATE(),@agentId
			FROM remittran WITH(NOLOCK) WHERE id=@tranId
			
		END
   IF @vouType='pd'
		BEGIN
			INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
				SELECT '','','',@tranId,@remarks,'Complain',@vouType,approvedDate,@user,GETDATE(),@agentId
			FROM remittran WITH(NOLOCK) WHERE id=@tranId
			
		END
	IF @vouType='pi'
		BEGIN
			INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
				SELECT '','','',@tranId,@remarks,'Complain',@vouType,paidDate,@user,GETDATE(),@agentId
			FROM remittran WITH(NOLOCK) WHERE id=@tranId			
		END
	
		EXEC proc_errorHandler 0, 'Document Rejected Successfully' , NULL

		 Update txnDocuments  Set 
					--approvedBy=@user
				  --,approvedDate=GetDate()
				  status='Rejected'
			  WHERE tdid = @tranId and txnType = @vouType AND agentId=@agentId

		EXEC proc_errorHandler 0, 'Document Rejected Successfully', NULL
		RETURN

END
ELSE IF @flag = 'details'
BEGIN
	SELECT DISTINCT
			agentName=am.agentName
			,txnType =  CASE WHEN  td.txnTYpe='sd'  THEN 'Send Domestic' 
							WHEN  td.txnTYpe='pd'   THEN 'Paid Domestic' 
							WHEN  td.txnTYpe='pi'   THEN 'Paid Intl'  
						END 
			,rt.senderName
			,rt.receiverName
			,rt.pAmt
			,status=CASE WHEN vr.tranId IS NULL THEN 'Not-Reconciled' ELSE vr.status END
			,controlNo=dbo.FNADecryptString(rt.controlNo)
			,remarks=vr.remarks
			FROM remittran rt 
			INNER JOIN txnDocuments td (NOLOCK) ON td.tdId=rt.id
			INNER JOIN agentMaster am  (NOLOCK) ON am.agentId=td.agentId
			LEFT JOIN dbo.voucherReconcilation vr ON vr.tranId=rt.id and vr.voucherType = td.txnType
			WHERE rt.id = @rowId AND td.txnType=@txnType
		    RETURN
END




GO
