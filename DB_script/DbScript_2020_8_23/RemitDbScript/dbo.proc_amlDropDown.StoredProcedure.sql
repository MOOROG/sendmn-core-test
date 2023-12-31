USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_amlDropDown]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_amlDropDown]
	 @flag					VARCHAR(10)
	,@user					VARCHAR(30)
	,@sCountry				VARCHAR(50)		= NULL
	,@rCountry				VARCHAR(50)		= NULL
	,@sAgent				VARCHAR(50)		= NULL
	,@rAgent				VARCHAR(50)		= NULL
	,@sCurr					VARCHAR(50)		= NULL
	,@rCurr					VARCHAR(50)		= NULL
	,@rMode					VARCHAR(50)		= NULL
	,@dateType				VARCHAR(50)		= NULL
	,@frmDate				VARCHAR(50)		= NULL
	,@toDate				VARCHAR(50)		= NULL	

	,@sCustomer				VARCHAR(200)	= NULL
	,@recName				VARCHAR(200)	= NULL
	,@sIdType				VARCHAR(50)		= NULL
	,@sIdNo					VARCHAR(50)		= NULL
	,@searchType			VARCHAR(50)		= NULL
	,@searchValue			VARCHAR(50)		= NULL
	,@fromAmt				MONEY			= NULL
	,@toAmt				    MONEY			= NULL
	,@date					VARCHAR(50)		= NULL
	,@rptFor				VARCHAR(50)		= NULL
	,@searchBy				VARCHAR(20)		= NULL
	,@country				VARCHAR(200)	= NULL
	,@idType				VARCHAR(50)		= NULL
    ,@idNumber				VARCHAR(50)		= NULL
    ,@company				VARCHAR(200)	= NULL
	,@senderName			VARCHAR(500)	= NULL

	,@pageNumber			INT				= 1
	,@pageSize				INT				= 50
	,@isExportFull			VARCHAR(10)		= NULL
	,@customerId			BIGINT			= NULL
	,@recMobile				VARCHAR(25)		= NULL
	,@amtType				VARCHAR(20)		= NULL

AS
SET NOCOUNT ON

BEGIN TRY 
	DECLARE @table VARCHAR(MAX),@sql VARCHAR(MAX),@globalFilter VARCHAR(MAX) = '',@URL	VARCHAR(MAX) = '',@reportHead VARCHAR(100) = '',@localFilter AS VARCHAR(500)
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	SET @recName = REPLACE(@recName,'__',' ')
	SET @company = REPLACE(@company,'__',' ')
	SET @country = REPLACE(@country,'__',' ')
	SET @rCountry = REPLACE(@rCountry,'__',' ')
	SET @senderName = REPLACE(@senderName,'__',' ')
	SET @rMode = REPLACE(@rMode,'__',' ')
	SET @sCountry = REPLACE(@sCountry,'__',' ')
	SET @globalFilter = ' AND rt.tranStatus <> ''Cancel'''
	SET @company = REPLACE(@company,'-',NULL)
	SET @idType = REPLACE(@idType,'__',' ')
	SET @idNumber = REPLACE(@idNumber,'__',' ')
	
	IF @sCountry IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Sender Country', @sCountry
		SET @globalFilter = @globalFilter + ' AND rt.sCountry = ''' + @sCountry + ''''
	END
	IF @rCountry IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiver Country', @rCountry
		SET @globalFilter = @globalFilter + ' AND rt.pCountry = ''' + @rCountry + ''''
	END	
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Sender Agent', am.agentName 
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sAgent
		SET @globalFilter = @globalFilter + ' AND rt.sAgent = ''' + @sAgent + ''''
	END
	IF @rAgent IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiver Agent', am.agentName 
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @rAgent
		SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @rAgent + ''''
	END	
	IF @rMode IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiving Mode', @rMode
		SET @globalFilter = @globalFilter + ' AND rt.paymentMethod = ''' + @rMode + ''''
	END	
	INSERT @FilterList
	SELECT 'Date Type',  
	case when @dateType = 'txnDate' then 'TXN Date'
		when @dateType = 'confirmDate' then 'Confirm Date'
		when @dateType = 'paidDate' then 'Paid Date' end

	IF @dateType = 'txnDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', CONVERT(varchar(20), CAST(@frmDate AS DATE),103)
		SET @globalFilter = @globalFilter + ' AND rt.createdDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', CONVERT(varchar(20),CAST(@toDate AS DATE),103)
		SET @globalFilter = @globalFilter + ' AND rt.createdDate <= ''' + @toDate + ' 23:59:59'''
	END	
	IF @dateType = 'confirmDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', CONVERT(varchar(20), CAST(@frmDate AS DATE),103)
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', CONVERT(varchar(20),CAST(@toDate AS DATE),103)
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate <= ''' + @toDate + ' 23:59:59'''
	END	
	IF @dateType = 'paidDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', CONVERT(varchar(20), CAST(@frmDate AS DATE),103)
		SET @globalFilter = @globalFilter + ' AND rt.paidDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', CONVERT(varchar(20),CAST(@toDate AS DATE),103)
		SET @globalFilter = @globalFilter + ' AND rt.paidDate <= ''' + @toDate + ' 23:59:59'''
	END	

	IF @rptFor = 'Sender'
		SET @localFilter = ' LEFT JOIN vwtranSenders TS WITH (NOLOCK) ON RT.id=TS.tranId'
	ELSE
		SET @localFilter = ' LEFT JOIN vwtranReceivers TS WITH (NOLOCK) ON RT.id=TS.tranId'
		
	SET @table ='
		SELECT 			
			[S.N]					= ROW_NUMBER() OVER (ORDER BY RT.senderName),
			[TXN Date]				= RT.createdDate,
			[TXN No.]			    = ''<span class = "link" onclick ="ViewTranDetail('' + CAST(RT.id AS VARCHAR(50)) + '');">'' + CAST(RT.id AS VARCHAR) + ''</span>'',
			[Sender Name]			= RT.senderName, 
			[Sender ID]				= isnull(ts.idType,'''')+''-''+ isnull(ts.idNumber,''''),	
			[Receiver Name]			= RT.receiverName,
			[Receiver ID]			= isnull(tr.idType2,tr.idType)+''-''+ isnull(tr.idNumber2,tr.idNumber),		
			[Receiving_Country]		= RT.pCountry,
			[Receiving_Branch]		= RT.pBranchName,
			[Receiving_Currency]	= RT.payoutCurr,
			[Receiving_Amount]		= RT.pAmt,
			
			[Collection_Currency]	= RT.collCurr,
			[Collection_Amount]		= '+CASE WHEN @flag='sbc_ddl' THEN 'RT.tAmt' ELSE 'RT.cAmt' END+',				
			[Sending_Country]		= RT.sCountry,
			[Sending_USD Amount]	= ('+CASE WHEN @flag='sbc_ddl' THEN 'RT.tAmt' ELSE 'RT.cAmt' END+'/RT.sCurrCostRate),
			[Sending_Agent]			= RT.sAgentName,
			[Sending_Branch]		= RT.sBranchName,
			[Sending_User]			= RT.createdBy			
				
		FROM vwremitTran RT WITH (NOLOCK)
		LEFT JOIN vwtranSenders TS WITH (NOLOCK) ON RT.id=TS.tranId
		LEFT JOIN vwtranReceivers TR WITH (NOLOCK) ON RT.id=TR.tranId
		WHERE 1=1 '
			
		IF @flag='ssmt_ddl'
		BEGIN
			SET @reportHead ='MIS Report Drilldown'	
			IF @senderName IS NOT NULL 
			BEGIN
				SET @table  =  @table +' AND RT.senderName='''+@senderName +'''' 
			END
			IF @country IS NOT NULL 
			BEGIN
				SET @table  =  @table +' AND TS.nativecountry='''+@country +'''' 
			END	
			IF @idType IS NOT NULL 
			BEGIN
				SET @table  =  @table + ' AND TS.idType='''+@idType +''''
			END	
			IF @idNumber IS NOT NULL 
			BEGIN
				SET @table  =  @table + ' AND TS.idNumber='''+@idNumber +'''' 
			END	
			IF @company IS NOT NULL 
			BEGIN
				SET @table  =  @table + ' AND TS.companyName='''+@company +'''' 
			END										
		END

		IF @flag='sbmt_ddl'
		BEGIN
			SET @reportHead ='MIS Report Drilldown'
			
			IF @recName IS NOT NULL
				SET @table  =  @table + ' AND RT.receiverName  = '''+@recName +''''
			IF @country IS NOT NULL
				SET @table = @table +' AND RT.pCountry='''+@country+''''
		END
	
		IF @flag='sbc_ddl'
		BEGIN 
			IF @searchBy = 'sender' and @searchValue IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Sender ID No', @idNumber
				SET @table = @table + ' AND ts.customerId=''' + CAST(@customerId AS VARCHAR) + ''''	
			END
			IF @searchBy = 'receiver'
			BEGIN
				INSERT @FilterList
				SELECT 'Receiver ID No', CASE WHEN @searchType = 'rname' THEN 'RECEIVER NAME' WHEN @searchType = 'rmobile' THEN 'RECEIVER MOBILE' END
				
				SET @table = @table + ' AND tr.fullName = ISNULL('''+ @recName  +''',tr.fullName)' 
				SET @table = @table + ' AND TR.mobile LIKE ISNULL(''%'+ @recMobile  +''',tr.mobile)' 

				SET @table = @table + CASE WHEN @searchType = 'rname' THEN ' AND TR.receiverName=''' + @searchValue + '''' WHEN @searchType = 'rmobile' THEN ' AND TR.mobile LIKE ISNULL(''%'+ @searchValue  +''',tr.mobile)' END	
			END	

			SET @reportHead ='Search By Customer Drilldown'
			
			IF @recName IS NOT NULL 
			BEGIN
				SET @table  =  @table + CASE WHEN @searchBy ='sender' THEN ' AND rt.senderName='''+@recName +''''
										 ELSE ' AND rt.receiverName='''+@recName +'''' END
			END
			
			if @date is not null
				set @table = @table+' AND RIGHT(CONVERT(VARCHAR, rt.createdDate, 103), 7) = '''+@date +''''
				
			IF @idType='normalId'  
			BEGIN  
				IF @searchBy = 'sender'  
				BEGIN  				
					SET @table = @table+' and ts.idNumber='''+isnull(@idNumber,'''')+''' and rt.senderName='''+isnull(@senderName,'''')+''''									
				END    
				ELSE  
				BEGIN  
					SET @table = @table+' and tr.idNumber='''+isnull(@idNumber,'''')+' and rt.receiverName='''+isnull(@recName,'''')+''''														
				END  
			END  
		END

		IF @flag='cr_ddl'
		BEGIN
			SET @reportHead ='Customer Report Drilldown'
			--SET @globalFilter = ' AND RT.payoutCurr=''NPR'''
			DECLARE @amtColumnMain VARCHAR(20)
			SET @amtColumnMain = CASE WHEN @amtType = 'chkBoxcAmt' THEN 'rt.cAmt' ELSE 'rt.pAmt' END			

			IF @sCountry is not null 
			BEGIN
				INSERT @FilterList
				SELECT 'Sender Country', @sCountry
				SET @globalFilter = @globalFilter + ' AND RT.sCountry = ''' + @sCountry + ''''
			END
			IF @rCountry is not null
			BEGIN
				INSERT @FilterList
				SELECT 'Receiver Country', @rCountry
				SET @globalFilter = @globalFilter + ' AND RT.pCountry = ''' + @rCountry + ''''
			END	
			IF @sAgent IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Sender Agent', am.agentName 
				FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sAgent
				SET @globalFilter = @globalFilter + ' AND RT.sAgent = ''' + @sAgent + ''''
			END
			IF @rAgent IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Receiver Agent', am.agentName 
				FROM agentMaster am WITH(NOLOCK) WHERE agentId = @rAgent
				SET @globalFilter = @globalFilter + ' AND RT.pAgent = ''' + @rAgent + ''''
			END	
			IF @rMode IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Receiving Mode', @rMode
				SET @globalFilter = @globalFilter + ' AND RT.paymentMethod = ''' + @rMode + ''''
			END	
	
			INSERT @FilterList
			SELECT 'Date Type',  
			case when @dateType = 'txnDate' then 'TXN Date'
				when @dateType = 'confirmDate' then 'Confirm Date'
				when @dateType = 'paidDate' then 'Paid Date' end	

			IF @dateType = 'txnDate'
			BEGIN
				INSERT @FilterList
				SELECT 'From Date', @frmDate
				SET @globalFilter = @globalFilter + ' AND RT.createdDate >= ''' + @frmDate + ''''
				INSERT @FilterList
				SELECT 'To Date', @toDate
				SET @globalFilter = @globalFilter + ' AND RT.createdDate <= ''' + @toDate + ' 23:59:59'''
			END	
			IF @dateType = 'confirmDate'
			BEGIN
				INSERT @FilterList
				SELECT 'From Date', @frmDate
				SET @globalFilter = @globalFilter + ' AND RT.approvedDate >= ''' + @frmDate + ''''
				INSERT @FilterList
				SELECT 'To Date', @toDate
				SET @globalFilter = @globalFilter + ' AND RT.approvedDate <= ''' + @toDate + ' 23:59:59'''
			END	
			IF @dateType = 'paidDate'
			BEGIN
				INSERT @FilterList
				SELECT 'From Date', @frmDate
				SET @globalFilter = @globalFilter + ' AND RT.paidDate >= ''' + @frmDate + ''''
				INSERT @FilterList
				SELECT 'To Date', @toDate
				SET @globalFilter = @globalFilter + ' AND RT.paidDate <= ''' + @toDate + ' 23:59:59'''
			END	

			IF @fromAmt IS NOT NULL AND @toAmt IS NOT NULL
			BEGIN
				SET @table = @table +'  AND ' + @amtColumnMain + ' >=  '''+ CAST(@fromAmt AS VARCHAR) +''' AND ' + @amtColumnMain + ' <=  '''+ CAST(@toAmt AS VARCHAR) +''''
			END

			IF @idType is not NULL
			BEGIN
				SET @table = @table +' AND ts.idType='''+@idType+''''
			END
			
			IF @idNumber is not null
			BEGIN
				SET @table = @table +' AND ts.idNumber='''+@idNumber+''''
			END
		
			IF @recName is not null
			BEGIN
				SET @table = @table +' AND rt.senderName='''+@recName+''''
			END
		END

		IF @flag='cd_ddl'
		BEGIN
			SET @reportHead ='Customer Daily Report Drilldown'
			--SET @globalFilter = ' AND RT.payoutCurr=''NPR'''
			SET @amtColumnMain = 'rt.cAmt'	

			IF @sCountry is not null 
			BEGIN
				INSERT @FilterList
				SELECT 'Sender Country', @sCountry
				SET @globalFilter = @globalFilter + ' AND RT.sCountry = ''' + @sCountry + ''''
			END
			IF @rCountry is not null
			BEGIN
				INSERT @FilterList
				SELECT 'Receiver Country', @rCountry
				SET @globalFilter = @globalFilter + ' AND RT.pCountry = ''' + @rCountry + ''''
			END	
			IF @sAgent IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Sender Agent', am.agentName 
				FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sAgent
				SET @globalFilter = @globalFilter + ' AND RT.sAgent = ''' + @sAgent + ''''
			END
			IF @rAgent IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Receiver Agent', am.agentName 
				FROM agentMaster am WITH(NOLOCK) WHERE agentId = @rAgent
				SET @globalFilter = @globalFilter + ' AND RT.pAgent = ''' + @rAgent + ''''
			END	
			IF @rMode IS NOT NULL
			BEGIN
				INSERT @FilterList
				SELECT 'Receiving Mode', @rMode
				SET @globalFilter = @globalFilter + ' AND RT.paymentMethod = ''' + @rMode + ''''
			END	
	
			INSERT @FilterList
			SELECT 'Date Type',  
			case when @dateType = 'txnDate' then 'TXN Date'
				when @dateType = 'confirmDate' then 'Confirm Date'
				when @dateType = 'paidDate' then 'Paid Date' end	

			IF @dateType = 'txnDate'
			BEGIN
				INSERT @FilterList
				SELECT 'From Date', @frmDate
				SET @globalFilter = @globalFilter + ' AND RT.createdDate >= ''' + @frmDate + ''''
				INSERT @FilterList
				SELECT 'To Date', @toDate
				SET @globalFilter = @globalFilter + ' AND RT.createdDate <= ''' + @toDate + ' 23:59:59'''
			END	
			IF @dateType = 'confirmDate'
			BEGIN
				INSERT @FilterList
				SELECT 'From Date', @frmDate
				SET @globalFilter = @globalFilter + ' AND RT.approvedDate >= ''' + @frmDate + ''''
				INSERT @FilterList
				SELECT 'To Date', @toDate
				SET @globalFilter = @globalFilter + ' AND RT.approvedDate <= ''' + @toDate + ' 23:59:59'''
			END	
			IF @dateType = 'paidDate'
			BEGIN
				INSERT @FilterList
				SELECT 'From Date', @frmDate
				SET @globalFilter = @globalFilter + ' AND RT.paidDate >= ''' + @frmDate + ''''
				INSERT @FilterList
				SELECT 'To Date', @toDate
				SET @globalFilter = @globalFilter + ' AND RT.paidDate <= ''' + @toDate + ' 23:59:59'''
			END	

			IF @fromAmt IS NOT NULL AND @toAmt IS NOT NULL
			BEGIN
				SET @table = @table +'  AND ' + @amtColumnMain + ' >=  '''+ CAST(@fromAmt AS VARCHAR) +''' AND ' + @amtColumnMain + ' <=  '''+ CAST(@toAmt AS VARCHAR) +''''
			END

			IF @idType is not NULL
			BEGIN
				SET @table = @table +' AND ts.idType='''+@idType+''''
			END
			
			IF @idNumber is not null
			BEGIN
				SET @table = @table +' AND ts.idNumber='''+@idNumber+''''
			END
		
			IF @recName is not null
			BEGIN
				SET @table = @table +' AND rt.senderName='''+@recName+''''
			END
		END

		IF @flag='tc_ddl'
		BEGIN
			SET @reportHead ='Top Customer Drilldown'	
			IF @recName IS NOT NULL 
			BEGIN
				SET @table  =  @table + CASE WHEN @rptFor = 'Sender' THEN ' AND rt.senderName='''+@recName +'''' ELSE ' AND rt.receiverName='''+@recName +'''' END
			END	
			IF @country IS NOT NULL 
			BEGIN
				SET @table  =  @table + CASE WHEN @rptFor = 'Sender' THEN ' AND TS.nativeCountry='''+@country +'''' ELSE ' AND TR.nativeCountry='''+@country +'''' END
			END	
			IF @idType IS NOT NULL 
			BEGIN
				SET @table  =  @table + CASE WHEN @rptFor = 'Sender' THEN ' AND TS.idType='''+@idType +'''' ELSE ' AND TR.idType='''+@idType +'''' END
			END	
			IF @idNumber IS NOT NULL 
			BEGIN
				SET @table  =  @table + CASE WHEN @rptFor = 'Sender' THEN ' AND TS.idNumber='''+@idNumber +'''' ELSE ' AND TR.idNumber='''+@idNumber +'''' END
			END	
			IF @company IS NOT NULL 
			BEGIN
				SET @table  =  @table + CASE WHEN @rptFor = 'Sender' THEN ' AND TS.companyName='''+@company +'''' ELSE ' AND TR.companyName='''+@company +'''' END
			END	
		END

		SET @table = @table + @globalFilter 
	
		PRINT @table
		EXEC(@table)

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
  
SELECT * FROM @FilterList
   
SELECT 'AML Reports : '+@reportHead title

END TRY

BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage ,NULL 
END CATCH




GO
