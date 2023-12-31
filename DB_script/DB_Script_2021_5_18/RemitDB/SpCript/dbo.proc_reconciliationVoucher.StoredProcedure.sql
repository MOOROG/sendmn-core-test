USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reconciliationVoucher]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_reconciliationVoucher]
	 @flag				VARCHAR(50)
	,@rowId				BIGINT			= NULL
	,@tranId			VARCHAR(50)		= NULL
	,@agentId			VARCHAR(50)		= NULL
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(30)		= NULL
	,@agentName			VARCHAR(200)	= NULL
	,@boxNo				VARCHAR(50)		= NULL
	,@fileNo			VARCHAR(50)		= NULL
	,@vouType			VARCHAR(20)		= NULL
	,@remarks			VARCHAR(MAX)	= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@pageSize			VARCHAR(50)		= NULL
	,@pageNumber		VARCHAR(50)		= NULL
	,@user				VARCHAR(50)		= NULL
	,@status			VARCHAR(50)		= NULL
	,@receivedId		VARCHAR(50)		= NULL
	,@controlNo			VARCHAR(20)     = NULL
	,@tranAmt           VARCHAR(50)     = NULL
	,@senderName		VARCHAR(50)		= NULL
	,@receiverName		VARCHAR(50)		= NULL
	,@createdBy			VARCHAR(50)		= NULL
	,@createdDate		DATE			= NULL
	,@voucherType		VARCHAR(50)		= NULL
	,@sendCardNo		VARCHAR(50)		= NULL
	,@recCardNo			VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE 
		 @selectFieldList	VARCHAR(MAX)
		,@extraFieldList	VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@sqlFilter			VARCHAR(MAX)	
		,@modeType			VARCHAR(50)		
		,@newValue			VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@maxNo				VARCHAR(50)
		,@SEND_D			INT
		,@PAID_D			INT
		,@PAID_I			INT
		,@receiveId			VARCHAR(50)
		,@sql				VARCHAR(MAX)
		,@sql1				VARCHAR(MAX)

	
			
IF @flag = 's' AND @controlNo IS NULL
BEGIN
	SET @sortBy = 'createdDate'
	SET @sortOrder = 'DESC'					
	
	SET @table = '(
					select  
						a.id
						,b.agentName
						,voucherType = CASE 
											WHEN a.voucherType = ''sd'' THEN ''Send Domestic''
											WHEN a.voucherType = ''pi'' THEN ''Pay International''
											WHEN a.voucherType = ''pd'' THEN ''Pay Domestic'' 
											ELSE ''All''
										END											
						,a.fromDate
						,a.toDate
						,a.createdBy
						,a.createdDate
						,a.boxNo
						,status = CASE WHEN c.receivedId IS NOT NULL THEN ''In Progress'' ELSE ''Not Started'' END
					FROM voucherReceive a with(nolock) 
					INNER JOIN agentMaster b WITH(NOLOCK) ON a.agentId=b.agentId
					LEFT JOIN (
						SELECT 
							receivedId 
						FROM voucherReconcilation WITH(NOLOCK) 
						GROUP BY receivedId
					) c ON a.id = c.receivedId
						WHERE a.isDeleted IS NULL 
					'		
										
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			  id
			 ,agentName
			 ,voucherType
			 ,fromDate
			 ,toDate
			 ,createdBy
			 ,createdDate
			 ,status
			 ,boxNo
			'
			
		IF @agentName IS NOT NULL
			SET @table = @table + ' AND b.agentName LIKE ''' + @agentName + '%'''
		
		if @createdBy is not null
			SET @table = @table + ' AND a.createdBy LIKE ''' + @createdBy + '%'''

		if @boxNo is not null
			SET @table = @table + ' AND a.boxNo = ''' + @boxNo + ''''
			
		if @voucherType is not null
			SET @table = @table + ' AND a.voucherType = ''' + @voucherType + ''''
						
		IF @createdDate IS NOT NULL
			SET @table = @table + ' AND cast(a.createdDate as date) = ''' + cast(@createdDate AS VARCHAR(11))  + ''''
			
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
			SET @table = @table + ' AND cast(a.fromDate as date) BETWEEN   ''' + CAST(@fromDate AS VARCHAR(11))  + ''' and  ''' + CAST(@toDate AS VARCHAR(11))  + ' 23:59:59'''
		
		 SET @table = @table+' ) x'
		 
		 --PRINT @table		 
		  EXEC dbo.proc_paging
			 @table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber
	RETURN

END

IF @flag = 's' and @controlNo IS NOT NULL
BEGIN	


	DECLARE @paidDate VARCHAR(50),@approvedDate VARCHAR(50),@pBranch VARCHAR(50),@sBranch VARCHAR(50)
	SELECT 
		@approvedDate = approvedDate,@paidDate = paidDate,@pBranch = pBranch,@sBranch = sBranch
	FROM vwRemitTranArchive rt WITH(NOLOCK) 
	WHERE controlNo = dbo.FNAEncryptString(@controlNo)

	SET @sortBy = 'createdDate'
	SET @sortOrder = 'DESC'	
				
	SET @table = '(
			SELECT 
				id			= vr.id,
				agentName	= am.agentName,
				voucherType = CASE 
								WHEN voucherType =''sd'' THEN ''Send-D'' 
								WHEN voucherType =''pd'' THEN ''Paid-D'' 
								WHEN voucherType =''pi'' THEN ''Paid-I'' 
								ELSE ''All'' 
							  END,
				fromDate = fromDate,
				toDate = toDate,
				createdBy = vr.createdBy,
				createdDate = vr.createdDate,
				status = CASE WHEN c.receivedId IS NOT NULL THEN ''In Progress'' ELSE ''Not Started'' END,			
				boxNo = boxNo
			FROM voucherReceive vr WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON vr.agentId = am.agentid 
			LEFT JOIN (
				SELECT 
					receivedId 
				FROM voucherReconcilation WITH(NOLOCK) 
				GROUP BY receivedId
			) c on vr.id = c.receivedId
				WHERE '''+@approvedDate+''' BETWEEN fromDate AND toDate 
					AND vr.agentId = '''+@sBranch+'''
			
			UNION ALL
			SELECT 
				id			= vr.id,
				agentName	= am.agentName,
				voucherType = CASE 
									WHEN voucherType =''sd'' THEN ''Send Domestic'' 
									WHEN voucherType =''pd'' THEN ''Pay Domestic'' 
									WHEN voucherType =''pi'' THEN ''Pay International'' 
									ELSE ''All'' 
							  END,
				fromDate = fromDate,
				toDate = toDate,
				createdBy = vr.createdBy,
				createdDate = vr.createdDate,
				status = CASE WHEN c.receivedId IS NOT NULL THEN ''In Progress'' ELSE ''Not Started'' END,			
				boxNo = boxNo
			FROM voucherReceive vr WITH(NOLOCK)
			INNER JOIN agentMaster am WITH(NOLOCK) ON vr.agentId = am.agentid 
			LEFT JOIN (
				SELECT 
					receivedId 
				FROM voucherReconcilation WITH(NOLOCK) 
				GROUP BY receivedId
			) c on vr.id = c.receivedId
				WHERE '''+@paidDate+''' BETWEEN fromDate AND toDate 
					AND vr.agentId = '''+@pBranch+''' 
					AND vr.isDeleted is null)x'
	
										
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			  id
			 ,agentName
			 ,voucherType
			 ,fromDate
			 ,toDate
			 ,createdBy
			 ,createdDate
			 ,status
			 ,boxNo
			'

		 
		 PRINT @table
		 
		  EXEC dbo.proc_paging
			 @table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber	



		RETURN

END

IF @flag = 'u'
BEGIN
		IF EXISTS(SELECT 'x' FROM voucherReceive WITH(NOLOCK) WHERE agentId = @agentId  and voucherType = @vouType
		and id <> @rowid AND ((@fromDate between fromDate and toDate) or (@toDate between fromDate and toDate)))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not receive multiple times with same date.', '' 
			RETURN;
		END

		IF EXISTS(SELECT 'x' FROM voucherReceive WITH(NOLOCK) WHERE agentId = @agentId AND id <> @rowid  and voucherType = @vouType
		AND ((fromDate BETWEEN @fromDate AND @toDate) OR (toDate BETWEEN @fromDate AND @toDate)))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not receive multiple times with same date.', '' 
			RETURN;
		END
		--BEGIN TRANSACTION		

		IF @vouType IS NULL
		BEGIN
			SELECT @SEND_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE approvedDate between @fromDate and @toDate+' 23:59:59'
			AND RT.SBRANCH = @agentId AND TRANTYPE = 'D'
			SELECT @PAID_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
			AND RT.PBRANCH = @agentId AND TRANTYPE='D'
			SELECT @PAID_I = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
			AND RT.PBRANCH = @agentId AND TRANTYPE ='I'
		END

		IF @vouType = 'pd'
			SELECT @PAID_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
				AND RT.PBRANCH = @agentId AND TRANTYPE='D' 

		IF @vouType = 'pi'
			SELECT @PAID_I = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
				AND RT.PBRANCH = @agentId AND TRANTYPE='I'

		IF @vouType = 'sd'
			SELECT @SEND_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE approvedDate between @fromDate and @toDate+' 23:59:59'
				AND RT.sBranch = @agentId AND TRANTYPE='D'

		UPDATE voucherReceive SET
				 agentId		=	@agentId
				,voucherType    =   @vouType
				,fromDate		=	@fromDate
				,toDate			=	@toDate
				,boxNo			=   @boxNo
				,modifiedBy		=	@user
				,SEND_D			=	@SEND_D
				,PAID_D			=	@PAID_D
				,PAID_I			=   @PAID_I
		WHERE id=@rowId
		
		SET @rowId = SCOPE_IDENTITY()			
			
		--IF @@TRANCOUNT > 0
		--COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowId
END

IF @flag = 'i'
BEGIN
	
		IF EXISTS(SELECT 'x' FROM voucherReceive WITH(NOLOCK) WHERE agentId = @agentId  and voucherType = @vouType
		AND ((@fromDate BETWEEN fromDate AND toDate) OR (@toDate BETWEEN fromDate AND toDate)))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not receive multiple times with same date.', '' 
			RETURN;
		END

		IF EXISTS(SELECT 'x' FROM voucherReceive WITH(NOLOCK) WHERE agentId = @agentId  and voucherType = @vouType
		AND ((fromDate BETWEEN @fromDate AND @toDate) OR (toDate BETWEEN @fromDate AND @toDate)))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not receive multiple times with same date.', '' 
			RETURN;
		END

		if @boxNo is null or @boxNo = ''
		begin
			update autoNumberSetting set receiveBox = receiveBox + 1 
			select @maxNo = receiveBox from autoNumberSetting
			select @boxNo = 'BOX'+ cast(@maxNo as varchar)  
			insert into boxNumberList(boxNo,createdBy,createdDate,flag)
			select @boxNo,@user,getdate(),'a'
		end	

		IF @vouType IS NULL
		BEGIN
			SELECT @SEND_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE approvedDate between @fromDate and @toDate+' 23:59:59'
			AND RT.SBRANCH = @agentId AND TRANTYPE = 'D'
			SELECT @PAID_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
			AND RT.PBRANCH = @agentId AND TRANTYPE = 'D'
			SELECT @PAID_I = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
			AND RT.PBRANCH = @agentId AND TRANTYPE = 'I'
		END

		IF @vouType = 'pd'
			SELECT @PAID_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
				AND RT.PBRANCH = @agentId AND TRANTYPE='D' 

		IF @vouType = 'pi'
			SELECT @PAID_I = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE paidDate between @fromDate and @toDate+' 23:59:59'
				AND RT.PBRANCH = @agentId AND TRANTYPE='I'

		IF @vouType = 'sd'
			SELECT @SEND_D = COUNT('X') 
			FROM vwRemitTranArchive rt with(nolock) WHERE approvedDate between @fromDate and @toDate+' 23:59:59'
				AND RT.sBranch = @agentId AND TRANTYPE='D'

		INSERT INTO voucherReceive(agentId,voucherType,fromDate,toDate,createdBy,createdDate,boxNo,SEND_D,PAID_D,PAID_I)VALUES
		(@agentId,@vouType,@fromDate,@toDate,@user,GETDATE(),@boxNo,@SEND_D,@PAID_D,@PAID_I) 	
			
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentId
END

IF @flag = 'a'
BEGIN
		
		SELECT B.agentName
			,A.agentId
			,A.voucherType
			,CONVERT(VARCHAR,A.fromDate,101) fromDate
			,CONVERT(VARCHAR,A.toDate,101) toDate
			,A.boxNo
			,A.createdBy 
			,A.createdDate 
		FROM voucherReceive A WITH(NOLOCK) INNER JOIN agentMaster B WITH(NOLOCK) 
		ON A.agentId=B.agentId
		WHERE A.id=@rowId

END

IF @flag = 'tran-list'
BEGIN
		If @controlNo is not null
			SET @controlNo= dbo.FNAEncryptString(UPPER(@controlNo))

		IF @vouType='sd'
		BEGIN
			SET @sql = 'select * from 
			(
				SELECT   mas.id 
						,controlNo		= dbo.FNADecryptString(mas.controlNo)
						,tranAmt		= mas.pAmt
						,senderName		=  sen.firstName + ISNULL('' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
						,receiverName	= rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
						,address		= rec.address
						,contact		= COALESCE(rec.mobile, rec.homephone, rec.workphone)
						,idType			= ISNULL(rec.idType, rec.idType2)
						,idno			= ISNULL(rec.idNumber, rec.idNumber2) 
						,status			= CASE when vr.tranid is not null and vr.voucherType = ''sd'' then ''1'' else ''0'' END
				from vwRemitTranArchive mas with(nolock) 
				inner join vwTranSendersArchive sen with(nolock) on mas.id=sen.tranId
				inner join vwTranReceiversArchive rec with(nolock) on mas.id=rec.tranId
				left join  voucherReconcilation vr with(nolock) on mas.id=vr.tranId AND voucherType=''sd''
				where approvedDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''
				AND (vr.status is null OR vr.status=''Complain'')	
				and isnull(sCountry,'''') = ''Nepal''
				and sBranch='+@agentId+''		
		
		IF @controlNo IS NOT NULL AND LEN(@controlNo) >= 5
			SET @sql=@sql +' and mas.controlNo like ''%'+@controlNo+'%'''

		IF @controlNo IS NOT NULL AND LEN(@controlNo) < 5
			SET @sql=@sql +' and mas.controlNo = '''+@controlNo+''''

		IF @tranAmt IS NOT NULL and isnumeric(@tranAmt) = 1
			SET @sql=@sql +' and mas.pAmt='''+@tranAmt+''''
			
		IF @tranAmt IS NOT NULL and isnumeric(@tranAmt) = 0
			SET @sql=@sql +' and 1=2'
			
		IF @sendCardNo IS NOT NULL
				SET @sql=@sql +' and sen.membershipId='''+@sendCardNo+''''	
		
		IF @recCardNo IS NOT NULL
				SET @sql=@sql +' and rec.membershipId='''+@recCardNo+''''
					
			
		
		SET @sql=@sql + ')x'
		END
			
		ELSE IF @vouType='pd'
		BEGIN
			SET @sql = 'select * from 
				(
					SELECT   
						 mas.id
						,controlNo		= [dbo].FNADecryptString(mas.controlNo)
						,tranAmt		= mas.pAmt
						,senderName		= sen.firstName + ISNULL('' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
						,receiverName	= rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
						,address			= rec.address
						,contact			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
						,idType			= ISNULL(rec.idType, rec.idType2)
						,idno			= ISNULL(rec.idNumber, rec.idNumber2) 
						,status			= CASE when vr.tranid is not null and vr.voucherType = ''pd'' then ''1'' else ''0'' END
				from vwRemitTranArchive mas with(nolock) 
				inner join vwTranSendersArchive sen with(nolock) on mas.id=sen.tranId
				inner join vwTranReceiversArchive rec with(nolock) on mas.id=rec.tranId
				left join  voucherReconcilation vr with(nolock) on mas.id=vr.tranId AND voucherType=''pd''
				where mas.paidDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''
				AND (vr.status is null OR vr.status=''Complain'')	
				and isnull(sCountry,'''') = ''Nepal''
				and pBranch = '''+@agentId+'''
			  '	
		IF @controlNo IS NOT NULL AND LEN(@controlNo) >= 5
			SET @sql=@sql +' and mas.controlNo like ''%'+@controlNo+'%'''

		IF @controlNo IS NOT NULL AND LEN(@controlNo) < 5
			SET @sql=@sql +' and mas.controlNo = '''+@controlNo+''''
			
		IF @tranAmt IS NOT NULL and isnumeric(@tranAmt) = 1
			SET @sql=@sql +' and mas.pAmt='''+@tranAmt+''''	

		IF @tranAmt IS NOT NULL and isnumeric(@tranAmt) = 0
			SET @sql=@sql +' and 1=2'
			
		IF @sendCardNo IS NOT NULL
				SET @sql=@sql +' and sen.membershipId='''+@sendCardNo+''''	
		
		IF @recCardNo IS NOT NULL
				SET @sql=@sql +' and rec.membershipId='''+@recCardNo+''''
		
		SET @sql=@sql + ')x'
		END

     	ELSE IF @vouType='pi'
		BEGIN
			SET @sql = 'select * from 
				 (
					SELECT  
					     mas.id
						,controlNo			= [dbo].FNADecryptString(mas.controlNo)
						,tranAmt			= mas.pAmt
						,senderName			= sen.firstName + ISNULL('' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
						,receiverName		= rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
						,address				= rec.address
						,contact				= COALESCE(rec.mobile, rec.homephone, rec.workphone)
						,idType				= ISNULL(rec.idType, rec.idType2)
						,idno				= ISNULL(rec.idNumber, rec.idNumber2) 
						,status			    = CASE when vr.tranid is not null and vr.voucherType = ''pi'' then ''1'' else ''0'' END
					from vwRemitTranArchive mas with(nolock) 
					inner join vwTranSendersArchive sen with(nolock) on mas.id=sen.tranId
					inner join vwTranReceiversArchive rec with(nolock) on mas.id=rec.tranId
					left join  voucherReconcilation vr with(nolock) on mas.id=vr.tranId  AND voucherType=''pi''
					where mas.paidDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''
					and isnull(sCountry,'''') <>''Nepal''
					AND (vr.status is null OR vr.status=''Complain'')	
					and pBranch = '''+@agentId+'''	
				'			
			
			IF @controlNo IS NOT NULL AND LEN(@controlNo) >= 5
				SET @sql=@sql +' and mas.controlNo like ''%'+@controlNo+'%'''

			IF @controlNo IS NOT NULL AND LEN(@controlNo) < 5
				SET @sql=@sql +' and mas.controlNo = '''+@controlNo+''''

			IF @tranAmt IS NOT NULL and isnumeric(@tranAmt) = 1
				SET @sql=@sql +' and mas.pAmt='''+@tranAmt+''''	

			IF @tranAmt IS NOT NULL and isnumeric(@tranAmt) = 0
				SET @sql=@sql +' and 1=2'
			
			IF @sendCardNo IS NOT NULL
				SET @sql=@sql +' and sen.membershipId='''+@sendCardNo+''''	
		
			IF @recCardNo IS NOT NULL
				SET @sql=@sql +' and rec.membershipId='''+@recCardNo+''''

					
			SET @sql=@sql + ')x'
		END

			SET @sql = @sql+' where 1=1 '	
			if @status is not null
				SET @sql = @sql+' and x.status = '''+ @status +''''

			IF @senderName IS NOT NULL 
				SET @sql=@sql +' and x.senderName Like '''+@senderName+'%'''

			IF @receiverName IS NOT NULL 
				SET @sql=@sql +' and x.receiverName Like '''+@receiverName+'%'''


			SET @sql1='
			SELECT * FROM 
			(
				SELECT 
						 rowId				= ROW_NUMBER() OVER (ORDER BY id DESC)  
						,id					= aa.id
						,[S.N.]				= row_number()over(order by aa.id desc)
						,[Control No]		= controlNo
						,[Payout Amount]	= tranAmt
						,[Sender Name]		= senderName
						,[Receiver Name]	= receiverName
						,[Id Type]			= idType
						,[Id No.]			= idno
						,[status]			= status				
				FROM 
				(
					'+ @sql +'
				) AS aa
			) AS tmp'
	
			print(@sql1)

			EXEC(@sql1)

			
END

IF @flag='reconcileVou'
BEGIN
	IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE tranId = @tranId and voucherType = @vouType)
	BEGIN
		SELECT 'Sorry, This Transaction already done.' AS MSG;
		RETURN;
	END
	IF @user IS NULL
	BEGIN
		SELECT 'Your session has expired. Please relogin to the system.' AS MSG;
		RETURN
	END

	IF @vouType='sd'
	BEGIN
		INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
		SELECT @receivedId,@boxNo,@fileNo,@tranId,@remarks,'Reconciled',@vouType,approvedDate,@user,GETDATE(),@agentId
		FROM vwRemitTranArchive WITH(NOLOCK) WHERE id=@tranId
	END
	ELSE
	BEGIN		
		INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
		SELECT @receivedId,@boxNo,@fileNo,@tranId,@remarks,'Reconciled',@vouType,paidDate,@user,GETDATE(),@agentId
		FROM vwRemitTranArchive WITH(NOLOCK) WHERE id=@tranId	
	END
	
	SELECT 'SUCCESS' AS MSG;
END

IF @flag='complainVou'
BEGIN

	IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE tranId = @tranId and voucherType = @vouType)
	BEGIN
		SELECT 'Sorry, This Transaction already done.' AS MSG;
		RETURN;
	END
	IF @user IS NULL
	BEGIN
		SELECT 'Your session has expired. Please relogin to the system.' AS MSG;
		RETURN
	END
	IF @vouType='sd'
	BEGIN
		INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
		SELECT @receivedId,@boxNo,@fileNo,@tranId,@remarks,'Complain',@vouType,approvedDate,@user,GETDATE(),@agentId
		FROM vwRemitTranArchive WITH(NOLOCK) WHERE id=@tranId
	END
	ELSE
	BEGIN
		INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
		SELECT @receivedId,@boxNo,@fileNo,@tranId,@remarks,'Complain',@vouType,paidDate,@user,GETDATE(),@agentId
		FROM vwRemitTranArchive WITH(NOLOCK) WHERE id=@tranId
	END
	
	SELECT 'COMPLAIN LODGED' AS MSG;
END

IF @flag = 'aRec'
BEGIN
		
		SELECT B.agentName
			,A.agentId
			,A.voucherType
			,CONVERT(VARCHAR,A.fromDate,101) fromDate
			,CONVERT(VARCHAR,A.toDate,101) toDate
			,A.createdBy 
			,A.createdDate 
		FROM voucherReceive A WITH(NOLOCK) INNER JOIN agentMaster B WITH(NOLOCK) 
		ON A.agentId=B.agentId
		WHERE A.id=@rowId

END

IF @flag = 'delete'
BEGIN
		IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE receivedId = @rowId)
		BEGIN
			EXEC proc_errorHandler 1, 'Failed to Delete, Already in progress.', @rowId
			RETURN
		END
		DELETE FROM voucherReceive WHERE ID = @rowId
		
		SET @modeType = 'delete'
		EXEC proc_errorHandler 0, 'Record has been Deleted successfully.', @rowId
		
		EXEC [dbo].proc_GetColumnToRow  'voucherReceive', 'id', @rowId, @newValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modeType, 'Voucher Received Reconciliation', @rowId, @user, @oldValue, @newValue

		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to Delete.', @rowId
			RETURN
		END
END
/*
IF @flag='rec-vou'
BEGIN
	IF @user IS NULL
	BEGIN
		SELECT 'Your session has expired. Please relogin to the system.' AS MSG;
		RETURN
	END

	DECLARE @sBranch int, @pBranch int
	if @controlNo is not null and @tranId is null
		select @tranId = id from vwRemitTranArchive rt with(nolock) where controlNo = dbo.fnaencryptstring(@controlNo)
	
	select @tranType = tranType from vwRemitTranArchive rt with(nolock) where id = @tranid

	if @tranType ='D' and @vouType ='pi'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Invalid, Type: International', '' 
		RETURN;
	END

	IF EXISTS(SELECT 'x' FROM voucherReconcilation WITH(NOLOCK) WHERE tranId = @tranId and voucherType = @vouType)
	BEGIN
		SELECT 'Sorry, This Transaction already reconcilied.' AS MSG;
		RETURN;
	END

	IF @vouType='sd'
	BEGIN
		INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
		SELECT @receivedId,@boxNo,@fileNo,@tranId,@remarks,'Reconciled',@vouType,approvedDate,@user,GETDATE(),@agentId
		FROM vwRemitTranArchive WITH(NOLOCK) WHERE id=@tranId
	END
	ELSE
	BEGIN		
		INSERT INTO voucherReconcilation(receivedId,boxNo,fileNo,tranId,remarks,status,voucherType,voucherDate,createdBy,createdDate,agentId)
		SELECT @receivedId,@boxNo,@fileNo,@tranId,@remarks,'Reconciled',@vouType,paidDate,@user,GETDATE(),@agentId
		FROM vwRemitTranArchive WITH(NOLOCK) WHERE id=@tranId	
	END
	
	SELECT 'SUCCESS' AS MSG;
END



IF @flag = 'recon'
BEGIN
		SET @pageSize = 200
		If @controlNo is not null
			SET @controlNo= dbo.FNAEncryptString(@controlNo)	

		SELECT @receiveId = id FROM voucherReceive WITH(NOLOCK) WHERE agentId = @agentId 
		AND fromDate BETWEEN @fromDate AND @toDate+' 23:59:59'

		IF @receiveId = NULL OR @receiveId =''
		BEGIN
			SELECT * from voucherReceive WITH(NOLOCK) WHERE 1=2
			RETURN;
		END	   	   
		
		IF @vouType='sd'
		BEGIN
			SET @sql = 'select * from 
			(
				SELECT   mas.id 
						,controlNo		= dbo.FNADecryptString(mas.controlNo)
						,tranAmt		= mas.pAmt
						,senderName		=  sen.firstName + ISNULL('' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
						,receiverName	= rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
						,address		= rec.address
						,contact		= COALESCE(rec.mobile, rec.homephone, rec.workphone)
						,idType			= ISNULL(rec.idType, rec.idType2)
						,idno			= ISNULL(rec.idNumber, rec.idNumber2) 
						,status			= CASE WHEN vr.tranId is Null THEN ''0'' ELSE ''1'' END
				from vwRemitTranArchive mas with(nolock) 
				inner join vwTranSendersArchive sen with(nolock) on mas.id=sen.tranId
				inner join vwTranReceiversArchive rec with(nolock) on mas.id=rec.tranId
				left join  voucherReconcilation vr with(nolock) on mas.id=vr.tranId
				where approvedDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''			
				and sBranch='+@agentId+''		
		
		IF @controlNo IS NOT NULL 
			SET @sql=@sql +' and mas.controlNo='''+@controlNo+''''
		IF @tranAmt IS NOT NULL 
			SET @sql=@sql +' and mas.tAmt='''+@tranAmt+''''
		
		SET @sql=@sql + ')x'
		END
			
		ELSE IF @vouType='pd'
		BEGIN
			SET @sql = 'select * from 
				(
					SELECT   
						 mas.id
						,controlNo		= [dbo].FNADecryptString(mas.controlNo)
						,tranAmt		= mas.pAmt
						,senderName		=  sen.firstName + ISNULL('' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
						,receiverName	= rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
						,address			= rec.address
						,contact			= COALESCE(rec.mobile, rec.homephone, rec.workphone)
						,idType			= ISNULL(rec.idType, rec.idType2)
						,idno			= ISNULL(rec.idNumber, rec.idNumber2) 
						,status			= CASE WHEN vr.tranId is Null THEN ''0'' ELSE ''1'' END
				from vwRemitTranArchive mas with(nolock) 
				inner join vwTranSendersArchive sen with(nolock) on mas.id=sen.tranId
				inner join vwTranReceiversArchive rec with(nolock) on mas.id=rec.tranId
				left join  voucherReconcilation vr with(nolock) on mas.id=vr.tranId
				where approvedDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''
				and sCountry = ''Nepal''
				and pBranch = '''+@agentId+'''
			  '	
		IF @controlNo IS NOT NULL 
			SET @sql=@sql +' and mas.controlNo='''+@controlNo+''''
		IF @tranAmt IS NOT NULL 
			SET @sql=@sql +' and mas.tAmt='''+@tranAmt+''''	
		
		SET @sql=@sql + ')x'
		END

     	ELSE IF @vouType='pi'
		BEGIN
			SET @sql = 'select * from 
				 (
					SELECT  
					     mas.id
						,controlNo		= [dbo].FNADecryptString(mas.controlNo)
						,tranAmt			= mas.pAmt
						,senderName			= sen.firstName + ISNULL('' '' + sen.middleName, '''') + ISNULL('' '' + sen.lastName1, '''') + ISNULL('' '' + sen.lastName2, '''')
						,receiverName		= rec.firstName + ISNULL('' '' + rec.middleName, '''') + ISNULL('' '' + rec.lastName1, '''') + ISNULL('' '' + rec.lastName2, '''')
						,address				= rec.address
						,contact				= COALESCE(rec.mobile, rec.homephone, rec.workphone)
						,idType				= ISNULL(rec.idType, rec.idType2)
						,idno				= ISNULL(rec.idNumber, rec.idNumber2) 
						,status			    = CASE WHEN vr.tranId is Null THEN ''0'' ELSE ''1'' END
					from vwRemitTranArchive mas with(nolock) 
					inner join vwTranSendersArchive sen with(nolock) on mas.id=sen.tranId
					inner join vwTranReceiversArchive rec with(nolock) on mas.id=rec.tranId
					left join  voucherReconcilation vr with(nolock) on mas.id=vr.tranId
					where approvedDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59''
					and sCountry<>''Nepal''
					and pBranch = '''+@agentId+'''	
				'			
			
			IF @controlNo IS NOT NULL 
				SET @sql=@sql +' and mas.controlNo='''+@controlNo+''''
			IF @tranAmt IS NOT NULL 
				SET @sql=@sql +' and mas.tAmt='''+@tranAmt+''''		
			SET @sql=@sql + ')x'
		END

			if @status is null
				set @status = '0'

			SET @sql = @sql+' where x.status = '''+@status+''''
			IF @senderName IS NOT NULL 
				SET @sql=@sql +' and x.senderName Like '''+@senderName+'%'''
			IF @receiverName IS NOT NULL 
				SET @sql=@sql +' and x.receiverName Like '''+@receiverName+'%'''

			SET @sql1='
			SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @sql +') AS tmp;

			SELECT * FROM 
			(
				SELECT 
						 rowId		= ROW_NUMBER() OVER (ORDER BY id DESC)  
						,id			= aa.id
						,[S.N.]		= row_number()over(order by aa.id desc)
						,[Control No] = controlNo
						,[Payout Amount] = tranAmt
						,[Sender Name] = senderName
						,[Receiver Name] = receiverName
						,[Id Type] = idType
						,[Id No.] = idno
						,[status]	= status				
				FROM 
				(
					'+ @sql +'
				) AS aa
			) AS tmp WHERE 1 = 1 AND  tmp.rowId BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''
	
			EXEC(@sql1)

			print(@sql1)
			--exec(@sql)
END
*/



GO
