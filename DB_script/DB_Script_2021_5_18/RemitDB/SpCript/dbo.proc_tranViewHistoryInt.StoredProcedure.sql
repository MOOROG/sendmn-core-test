USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranViewHistoryInt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_tranViewHistory]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].proc_tranViewHistory

GO
*/
CREATE proc [dbo].[proc_tranViewHistoryInt]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@tranId			VARCHAR(30)		= NULL	
	,@controlNo			VARCHAR(50)		= NULL	
	,@agentId			VARCHAR(30)		= NULL
	,@tranViewType		VARCHAR(50)		= NULL
	,@remarks			VARCHAR(MAX)	= NULL
	,@ip				VARCHAR(100)	= NULL
	,@dcInfo			VARCHAR(100)	= NULL	
	,@rowId				INT				= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
	
AS
	IF @controlNo IS NULL
	BEGIN
		IF ISNUMERIC(@tranId) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Transaction ID', NULL
			RETURN
		END
		SELECT @controlNo = dbo.FNADecryptString(controlNo) FROM remitTran WITH(NOLOCK) WHERE id = @tranId OR holdTranId = @tranId
	END
		
	
	IF @tranId IS NULL
		SELECT @tranId=id FROM remitTran WITH(NOLOCK) WHERE controlNo=dbo.FNAEncryptString(@controlNo)
	IF @flag = 'i'
	BEGIN
		INSERT INTO tranViewHistory (			 
			 agentId
			,tranViewType
			,createdBy
			,createdDate
			,tranId
			,controlNumber
			,remarks
			,dcInfo
			--,ipAddress
		)
		SELECT 		 
			 @agentId
			,@tranViewType
			,@user
			,GETDATE()
			,@tranId
			,@controlNo
			,@remarks
			,@dcInfo
			--,@ip
			
	END
	
	IF @flag = 'i1'
	BEGIN
		INSERT INTO tranViewHistory (	
			 
			 agentId
			,tranViewType
			,createdBy
			,createdDate
			,tranId
			,remarks
		)
		SELECT 		 
			 @agentId
			,@tranViewType
			,@user
			,GETDATE()
			,@tranId
			,@remarks
			
		SET @rowId = SCOPE_IDENTITY()
		EXEC proc_errorHandler 0, 'Success.', @rowId

	END

GO
