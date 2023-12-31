USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reconUpdate]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_reconUpdate]
			 @flag				VARCHAR(50)
			,@rowId				BIGINT			= NULL
			,@tranId			VARCHAR(50)		= NULL
			,@controlNo			VARCHAR(50)		= NULL
			,@boxNo				VARCHAR(50)		= NULL
			,@fileNo			VARCHAR(50)		= NULL
			,@remarks			VARCHAR(MAX)	= NULL
			,@sortBy			VARCHAR(50)		= NULL
			,@sortOrder			VARCHAR(50)		= NULL
			,@pageSize			INT				= NULL
			,@pageNumber		INT				= NULL
			,@user				VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
/*
EXEC proc_reconUpdate @flag='genBox'
EXEC proc_reconUpdate @flag='genBox1'
*/
BEGIN TRY
	DECLARE 
		 @maxNo BIGINT
		,@boxCode VARCHAR(50)

	IF @flag = 'genBox1'
	BEGIN	
		SELECT @maxNo = reconcileBox FROM autoNumberSetting (NOLOCK)
		SET @maxNo = ISNULL(@maxNo, 0) + 1
		SELECT @boxCode = 'BOX-'+ CAST(@maxNo AS VARCHAR)  

		BEGIN TRAN
			UPDATE autoNumberSetting SET reconcileBox = @maxNo		
			INSERT INTO boxNumberList(boxNo,createdBy,createdDate,flag)
			SELECT @boxCode,@user,GETDATE(),'b'
		COMMIT TRAN
		SELECT @boxCode
	END

	IF @flag = 's'
	BEGIN 
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)			
	
		SET @sortBy = 'id'
		SET @sortOrder = 'DESC'					
	
		SET @table = '
			(		
				SELECT
					rec.id
					,rec.receivedId
					,rec.boxNo
					,rec.fileNo
					,rec.tranId
					,rec.remarks
					,voucherType = CASE 
									WHEN rec.voucherType =''sd'' THEN ''Send Domestic''
									WHEN rec.voucherType =''pd'' THEN ''Paid Domestic''
									WHEN rec.voucherType =''pi'' THEN ''Paid International''
								END
					,txnType=rec.voucherType
					,rec.createdBy
					,rec.createdDate
					,rec.status
					,controlNo= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.fnadecryptstring(rt.controlNo) + '''''')">'' + dbo.fnadecryptstring(rt.controlNo) + ''</a>''			
					,rec.agentId
					,icn=dbo.fnadecryptstring(rt.controlNo)
			FROM voucherReconcilation rec WITH(NOLOCK) 
			INNER JOIN vwRemitTranArchive rt with(nolock) ON rec.tranId = rt.id
			WHERE rec.status =''Reconciled'' 
		'						
		IF @tranId is not null
			SET @table = @table + ' AND rec.tranId = '''+ @tranId +''''
		IF @controlNo is not null
			SET @table = @table + ' AND rt.controlNo = '''+ dbo.FNAEncryptString(@controlNo) +''''

		SET @table = @table+' ) x'
		 
		 
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
								id
								,receivedId
								,boxNo
								,fileNo
								,tranId
								,controlNo
								,remarks
								,voucherType
								,createdBy
								,createdDate
								,status
								,agentId
								,icn
								,txnType								 
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
		RETURN
				
	END	
	
	IF	@flag= 'a'
	BEGIN
		SELECT 
			 rec.id
			,controlNo ='<a href="#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo=' + dbo.fnadecryptstring(rt.controlNo) + ''')">' + dbo.fnadecryptstring(rt.controlNo) + '</a>'
			,rec.boxNo
			,rec.fileNo
			,rec.remarks
			,vouType = CASE 
							WHEN rec.voucherType = 'sd' THEN 'Send Domestic'
							WHEN rec.voucherType = 'pd' THEN 'Paid Domestic'
							WHEN rec.voucherType = 'pi' THEN 'Paid International'
						END
		FROM voucherReconcilation rec WITH(NOLOCK) 
		INNER JOIN vwRemitTranArchive rt WITH(NOLOCK) ON rec.tranId = rt.id	
		WHERE rec.id=@rowId
		RETURN							
	END	

	IF @flag='update'
	BEGIN
		UPDATE voucherReconcilation	SET
			 boxNo			=	@boxNo
			,fileNo			=	@fileNo
			,remarks		=	@remarks
			,modifiedBy		=	@user
			,modifiedDate	=	GETDATE()
		WHERE id=@rowId
									
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowId
		RETURN
	END

	IF @flag='update-complain'
	BEGIN 
		UPDATE voucherReconcilation	 SET
			 remarks		=	@remarks
			,modifiedBy		=	@user
			,modifiedDate	=	GETDATE()
			,status			=   'Complain'
		WHERE id = @rowId
									
		EXEC proc_errorHandler 0, 'Record has been updated as complain successfully.', @rowId
	END	
END TRY
BEGIN CATCH
IF @@TRANCOUNT>0 ROLLBACK TRAN
SELECT 1 ErrorCode, ERROR_MESSAGE() Msg, NULL ID
END CATCH



		
		








GO
