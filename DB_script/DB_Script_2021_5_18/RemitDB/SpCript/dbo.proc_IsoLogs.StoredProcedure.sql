USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_IsoLogs]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_IsoLogs](
	 @flag			 VARCHAR(10)	= 	NULL
	,@user  		 VARCHAR(30)	= 	NULL
	,@controlNo		 VARCHAR(30)	=	NULL
	,@rowId			 INT			= 	NULL
	,@pageSize		 INT			=	NULL
	,@pageNumber	 INT			=	NULL
	,@sortBy		VARCHAR(50)		=	NULL
	,@sortOrder		VARCHAR(50)		=	NULL
	
	,@tranId		VARCHAR(200)	= NULL
	,@accountNo		VARCHAR(200)	= NULL	

	,@status		VARCHAR(50)		=	NULL
	,@txnfromDate	VARCHAR(50)		=	NULL
	,@txntoDate		VARCHAR(50)		=	NULL
	,@processedfromDate	VARCHAR(50)		=	NULL
	,@processedtoDate		VARCHAR(50)		=	NULL
	
)AS
SET NOCOUNT ON
SET	XACT_ABORT ON
BEGIN
	DECLARE
		 @table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
	IF @flag='s'
	BEGIN		
		SET @sortBy='tranId'
		SET @sortOrder='DESC'

		SET @table='
		(	
			SELECT 
				 rowId				= q.rowId
				,tranId				= tm.id
				,controlNo			= dbo.fnadecryptstring(tm.controlNo)				
				,bankName			= isnull(tm.pAgentName,tm.pBankName)+'' (''+ replace(replace(isnull(tm.pBankBranchName,tm.pBranchName),isnull(tm.pAgentName,tm.pBankName),''''),''-'','''') +'')''
				,accountNo			= tm.accountNo
				,pAmt				= ISNULL(tm.pAmt,0)
				,receiverName		= tm.receiverName
				,senderName			= tm.senderName				
				,logStatus			= q.status
				,processDate		= q.processDate
				,responseMsg	    = q.resMsg
				,createdDate		= tm.createdDate															
			FROM remitTran tm WITH(NOLOCK) 
			INNER JOIN tranReceivers tr WITH(NOLOCK) ON tm.id = tr.tranId
			INNER JOIN tranSenders sen WITH(NOLOCK) ON tm.id = sen.tranId
			INNER JOIN acDepositQueueIso q WITH(NOLOCK) ON q.tranId = tm.id
			WHERE tm.paymentMethod = ''BANK DEPOSIT''
				and tm.expectedPayoutAgent =''iso''							
		)x'
						
		SET @sql_filter = ''
		
		
		IF @status IS NOT NULL AND @status<>''
			SET @sql_filter=@sql_filter+' AND logStatus='''+@status+''''


		IF @txnfromDate IS NOT NULL AND @txntoDate IS NOT NULL
			SET @sql_filter=@sql_filter+ ' AND createdDate BETWEEN   ''' + @txnfromDate + ''' and  ''' + @txntoDate  + ' 23:59:59'''

		IF @processedfromDate IS NOT NULL AND @processedtoDate IS NOT NULL
			SET @sql_filter=@sql_filter+' AND processDate BETWEEN   ''' + @txnfromDate + ''' and  ''' + @txntoDate  + ' 23:59:59'''


					
		IF @controlNo IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND controlNo = ''' +@controlNo+''''				
		IF @tranId IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND tranId = ''' +@tranId+''''		
		IF @accountNo IS NOT NULL  
			SET @sql_filter=@sql_filter + ' AND accountNo = ''' +@accountNo+''''

			


		SET @select_field_list = '
								 rowId
								,tranId
								,controlNo
								,bankName
								,accountNo								
								,pAmt
								,receiverName
								,senderName
								,logStatus
								,processDate
								,responseMsg
							'
							

PRINT @table

PRINT @sql_filter

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
END

GO
