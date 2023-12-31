USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reconComplainResolve]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_reconComplainResolve]
	 @flag				VARCHAR(50)
	,@rowId				BIGINT			= NULL
	,@tranId			VARCHAR(50)		= NULL
	,@controlNo			VARCHAR(50)		= NULL
	,@remarks			VARCHAR(MAX)	= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
	,@user				VARCHAR(50)		= NULL
	,@agentName			VARCHAR(200)	= NULL
AS
SET NOCOUNT ON;

IF @flag = 's'
BEGIN 
	   DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)			
	
		SET @sortBy = 'id'
		SET @sortOrder = 'DESC'					
	
		SET @table = '
		(		
			select
				 rec.id,
				 rec.receivedId,
				 rec.tranId,
				 rec.remarks,
				 voucherType = case when rec.voucherType = ''sd'' then ''Send Domestic''
									when rec.voucherType = ''pd'' then ''Paid Domestic''
									when rec.voucherType = ''pi'' then ''Paid International'' end,
				 rec.createdBy,
				 rec.createdDate,
				 rec.status,
				 controlNo= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.fnadecryptstring(rt.controlNo) + '''''')">'' + dbo.fnadecryptstring(rt.controlNo) + ''</a>'',
				 am.agentName
			from voucherReconcilation rec with(nolock) 
			inner join vwRemitTranArchive rt with(nolock) on rec.tranId = rt.id
			inner join agentMaster am with(nolock) on rec.agentId = am.agentId
			where rec.status =''Complain'' 
		'						
		if @tranId is not null
			set @table = @table + ' and rec.tranId = '''+@tranId+''''

		if @controlNo is not null
			set @table = @table + ' and rt.controlNo = '''+ dbo.FNAEncryptString(@controlNo) +''''

		if @agentName is not null
			set @table = @table + ' and AM.agentName LIKE ''%'+ @agentName +'%'''

		SET @table = @table+' )x'
		 
		print(@table)
		 
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
								   id
								 , receivedId
								 , tranId
								 , controlNo
								 , remarks
								 , voucherType
								 , createdBy
								 , createdDate
								 , status
								 , agentName
								 
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

IF @flag='a'
BEGIN
	select 
		 rec.id
		,controlNo ='<a href="#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo=' + dbo.fnadecryptstring(rt.controlNo) + ''')">' + dbo.fnadecryptstring(rt.controlNo) + '</a>'
		,rec.boxNo
		,rec.fileNo
		,rec.remarks
		,vouType = case when rec.voucherType = 'sd' then 'Send Domestic'
						when rec.voucherType = 'pd' then 'Paid Domestic'
						when rec.voucherType = 'pi' then 'Paid International'
					end
	from voucherReconcilation rec with(nolock)	
	inner join vwRemitTranArchive rt with(nolock) on rec.tranId = rt.id	
	where rec.id=@rowId													
END

IF @flag='resolve'
BEGIN
	UPDATE voucherReconcilation SET
		 status='Reconciled'
		,resolvedBy = @user
		,resolvedDate = getdate()
		,resolvedRemarks = @remarks
	where id=@rowId
											
	EXEC proc_errorHandler 0, 'Complain record has been resolved successfully.', @rowId	
END










GO
