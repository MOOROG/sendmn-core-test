USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_releaseComplianceTxn]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_releaseComplianceTxn]
	 @flag                  VARCHAR(50)		= NULL
	,@user                  VARCHAR(200)	= NULL
	,@controlNo				VARCHAR(100)	= NULL
	,@sBranchName			VARCHAR(100)	= NULL
	,@sortBy                VARCHAR(50)		= NULL
	,@sortOrder             VARCHAR(5)		= NULL
	,@pageSize              INT				= NULL
	,@pageNumber            INT				= NULL
	,@Msg					VARCHAR(20)		= NULL

AS
/*
[proc_releaseComplianceTxn] @flag = 's'  ,@pageNumber='1', @pageSize='10', @sortBy='sBranchName', @sortOrder='asc', @user = 'netra'
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY

	DECLARE
		 @sql				VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)	
	
	IF @flag='s'
	BEGIN

		SET @table = '
			(
			SELECT 	 tranId = rt.id			
					,controlNo=dbo.fnadecryptstring(rt.controlNo)
					,rt.sBranchName
					,rt.createdBy 
					,rt.createdDate
					,rt.pAmt
					,type = ''OFAC''
					,receiverName = receiverName
					,senderName = senderName
			FROM remitTran rt WITH(NOLOCK)
			INNER JOIN remitTranOfac ofac with(nolock) on rt.id = ofac.tranId
			WHERE (rt.tranStatus	= ''Hold'' OR rt.tranStatus	= ''OFAC Hold'' OR rt.tranStatus	= ''OFAC/Compliance Hold'') AND createdDate > ''2015-01-01''
			AND rt.tranType = ''D'' and ofac.approvedDate is null
			
			UNION ALL
			
			SELECT 	 DISTINCT tranId = rt.id			
					,controlNo=dbo.fnadecryptstring(rt.controlNo)
					,rt.sBranchName
					,rt.createdBy 
					,rt.createdDate
					,rt.pAmt
					,type = ''Compliance''
					,receiverName = receiverName
					,senderName = senderName
			FROM remitTran rt WITH(NOLOCK)
			INNER JOIN remitTranCompliance comp with(nolock) on rt.id = comp.tranId
			WHERE (rt.tranStatus	= ''Hold'' OR rt.tranStatus	= ''Compliance Hold'' OR rt.tranStatus	= ''OFAC/Compliance Hold'') AND createdDate > ''2015-01-01''
			AND rt.tranType = ''D'' and comp.approvedDate is null)
			
			 '
		IF @sortBy IS NULL
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '( 
			select 
				 tranId 						
				,controlNo= ''<a href="'+dbo.FNAGetURL()+'Remit/Transaction/ApproveOFAC/ComplianceDom/Manage.aspx?controlNo='' + main.controlNo + ''">'' + main.controlNo + ''</a>''
				,type 
				,receiverName
				,senderName
				,sBranchName
				,createdBy
				,createdDate
				,pAmt	
				,hasChanged = ''''				
				FROM ' + @table + ' main
				) x'
					
		SET @sql_filter = ''
		
		IF @controlNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND controlNo LIKE ''%' + @controlNo + '%'''	
		IF @sBranchName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sBranchName LIKE ''' + @sBranchName + '%'''

		SET @select_field_list ='			 
			 controlNo
			,sBranchName
			,type
			,receiverName
			,senderName
			,hasChanged
			,createdBy
			,createdDate
			,pAmt
			,tranId
			'
			
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

END TRY
BEGIN CATCH

     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @controlNo

END CATCH



GO
