USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranViewHistory]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_tranViewHistory]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@tranId			VARCHAR(30)		= NULL	
	,@controlNo			VARCHAR(50)		= NULL	
	,@agentId			VARCHAR(30)		= NULL
	,@tranViewType		VARCHAR(50)		= NULL
	,@remarks			VARCHAR(MAX)	= NULL
	,@rowId				INT				= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
AS
	
	IF @tranId IS NULL
		SELECT @tranId=id FROM remitTran WHERE controlNo=dbo.FNAEncryptString(@controlNo)
	
		

	IF @flag = 'i'
	BEGIN
		INSERT INTO tranViewHistory (				 
			 agentId
			,tranViewType
			,createdBy
			,createdDate
			,tranId
			,remarks
			,controlnumber
		)
		SELECT 		 
			 @agentId
			,@tranViewType
			,@user
			,GETDATE()
			,@tranId
			,@remarks
			,@controlNo
			
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
			,controlnumber
		)
		SELECT 		 
			 @agentId
			,@tranViewType
			,@user
			,GETDATE()
			,@tranId
			,@remarks
			,@controlNo
			
		SET @rowId = SCOPE_IDENTITY()
		EXEC proc_errorHandler 0, 'Success.', @rowId

	END

GO
