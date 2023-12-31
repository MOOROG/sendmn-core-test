USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnDocuments]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[proc_txnDocuments]
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
	,@txnType			VARCHAR(10)		= NULL
	,@icn				VARCHAR(50)		= NULL
	,@voucherType		VARCHAR(50)		= NULL
			
AS

/*
EXEC proc_txnDocuments @flag='deleteDoc',@user='admin',@rowId='28'
*/
SET NOCOUNT ON;
IF @flag = 'i'
BEGIN			
	SELECT 
		@controlNo=dbo.FNADecryptString(controlNo) 
	FROM vwRemitTranArchive WITH(NOLOCK) 
	WHERE id=@rowId	
	
--	EXEC proc_txnDocuments @flag='i', 
--@user = null, @rowId = '5674003', @tranId = '5674003', @fileDescription = null, 
--@fileType = 'jpg', @txnYear = '2016', @agentId = '4616', @txnType = 'sd'


	DECLARE @sn INT
	SELECT 
		@sn = COUNT(*)
	FROM txnDocuments (NOLOCK) WHERE controlNo = @controlNo
	SELECT @sn = ISNULL(@sn, 0) + 1	
	SET @fileName = @ControlNo + +'_'+ CAST(@sn AS VARCHAR) + '.' + @fileType
	--SET @fileDescription = @fileName
	--IF EXISTS (SELECT 'x' FROM txnDocuments (NOLOCK) WHERE controlNo = @controlNo AND tdId=@rowId AND [fileName]=@fileName)
	--BEGIN
	--	DELETE  FROM txnDocuments WHERE controlNo = @controlNo AND tdId=@rowId AND [fileName]=@fileName
	--END	
	INSERT INTO txnDocuments (tdId, controlNo, [fileName], fileDescription, fileType, [year], agentId, createdBy, createdDate,txnType)
	SELECT @rowId, @controlNo, @fileName, @fileDescription, @fileType, @txnYear, @agentId, @user, GETDATE(),@txnType
	SET @rowId = SCOPE_IDENTITY()		
	EXEC proc_errorHandler 0, 'File Uploaded Successfully', @fileName
	RETURN
END

ELSE IF @flag = 'test'
BEGIN
	SELECT fileName, fileDescription, [year], agentId FROM txnDocuments WITH(NOLOCK) WHERE controlNo = @controlNo
	RETURN 
	--EXEC proc_txnDocuments @flag='test', @controlNo='7180061158D'
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
	FROM txnDocuments WITH(NOLOCK) 
		WHERE tdId=@rowId
			AND (isDeleted = 'N' OR isDeleted IS NULL)
			AND txnType=@txnType
		--ORDER BY CASE WHEN fileDescription = 'Voucher' THEN 0 ELSE 1 END ASC
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
	DECLARE @path VARCHAR(255)
	SELECT 
		@path = CAST([Year] AS VARCHAR(20)) + '\' + CAST(agentId AS VARCHAR(20)) + '\' + [fileName]
	FROM txnDocuments (NOLOCK) WHERE rowId = @rowId
	DELETE txnDocuments WHERE rowId = @rowId
	EXEC proc_errorHandler 0, 'File Deleted Successfully', @path
END	
ELSE IF @flag='cd'
BEGIN	
	SELECT '0' as errorCode,'Continue' as msg ,SUM(v+i+b) as id from (	select 
		 case when fileDescription='Voucher' then 2 else 0 end as v
		,case when fileDescription='Id' then 1 else 0 end as i
		,case when fileDescription='Both' then 4 else 0 end as b		
	from txnDocuments where agentId=@agentId AND txnType=@voucherType AND tdId=@tranId
	UNION ALL 
	SELECT 0,0,0
	)x	
	RETURN
END




GO
