USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_searchTxnOldAPI_TEST]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_searchTxnOldAPI_TEST]
	 @flag VARCHAR(50)
	,@user VARCHAR(50)			= NULL
	,@controlNo VARCHAR(50)		= NULL
	,@criteria	VARCHAR(50)		= NULL
	,@value		VARCHAR(200)	= NULL
	
AS

SET NOCOUNT ON

IF @flag = 'SearchTicket'
BEGIN
	
	SELECT 
		 rowId
		,message Comments
		,trn.createdBy PostedBy
		,trn.createdDate DatePosted
		,isnull(trn.fileType,'')fileType
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.controlNo = @controlNo --OR trn.controlNo = @controlNoEncrypted
	ORDER BY trn.createdDate DESC

END


GO
