USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_imeRemitCardReIssue]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_imeRemitCardReIssue](
	 @flag				VARCHAR(50)			= NULL
	,@user				VARCHAR(20)			= NULL
	,@rowId				VARCHAR(20)			= NULL
	,@customerName		varchar(40)			= NULL
	,@oldRemitCardNo	varchar(40)			= NULL	
	,@newRemitCardNo	varchar(40)			= NULL
	,@remark			VARCHAR(200)		= NULL
	,@requestFor		VARCHAR(10)			= NULL
	,@modType			VARCHAR(10)			= NULL
	,@sortBy			VARCHAR(50)			= NULL
	,@sortOrder			VARCHAR(5)			= NULL
	,@pageSize			INT					= NULL
	,@pageNumber		INT					= NULL
	,@isApproved		CHAR(1)				= NULL
)AS
BEGIN

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), membershipId INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)		
		,@errorMsg			VARCHAR(MAX)

	SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'IME Remit Card Reissue'		
		,@module = '20'
		,@tableAlias = 'imeRemitCardReIssueRequest'


	IF @flag = 's'
	BEGIN	
		DECLARE 
				 @selectFieldList	VARCHAR(MAX)
				,@extraFieldList	VARCHAR(MAX)
				,@table				VARCHAR(MAX)
				,@sqlFilter			VARCHAR(MAX)
		
		DECLARE @hasRight CHAR(1)
		SET @hasRight = dbo.FNAHasRight(@user, '20832430')

		IF @sortBy IS NULL  
			SET @sortBy = 'CustomerName'
	
		IF @sortOrder IS NULL  
		SET @sortOrder = 'DESC'			
		SET @table = '(SELECT 
							 r.rowId
							,requestingFor = case when requestFor = ''C'' then ''IME Remit Card Loss'' else ''PIN Number Loss'' end
							,oldRemitCardNo = r.oldRemitCardNo
							,newRemitCardNo = r.newRemitCardNo
							,CustomerName = r.customerName
							,createdBy = r.createdBy
							,createdDate = r.createdDate
							,haschanged = CASE WHEN r.approvedBy IS NULL THEN ''Y'' ELSE ''N'' END
							,modifiedBy = ISNULL(r.modifiedBy,r.createdBy)	
							,isApproved = CASE WHEN (r.approvedBy IS NULL) THEN ''N'' ELSE ''Y'' END
						FROM imeRemitCardReIssueRequest r WITH(NOLOCK)
						WHERE 1=1
						)x'		
					
		SET @sqlFilter = '' 
		
		IF @customerName is not null	
			SET @sqlFilter=@sqlFilter+'AND CustomerName LIKE ''%'+@customerName+'%'''
		
		IF @oldRemitCardNo is not null	
			SET @sqlFilter=@sqlFilter+'AND oldRemitCardNo = '''+@oldRemitCardNo+''''

		IF @newRemitCardNo is not null	
			SET @sqlFilter=@sqlFilter+'AND newRemitCardNo = '''+@newRemitCardNo+''''

		IF @isApproved IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND isApproved = ''' + @isApproved + ''''

		SET @selectFieldList = '
								   rowId
								 , requestingFor
								 , oldRemitCardNo
								 , newRemitCardNo							
								 , CustomerName
								 , createdBy
								 , createdDate	
								 , haschanged
								 , modifiedBy
								 , isApproved						
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

	IF @flag='i'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM imeRemitCardMaster WITH(NOLOCK) 
			WHERE cardStatus IN ('Enrolled','Reserved') AND remitCardNo = @oldRemitCardNo)
		BEGIN
			SELECT '1' errorCode,'IME Remit Card has not been issued yet.' msg,null
			RETURN
		END

		--IF @requestFor = 'C'
		--BEGIN
		--	IF NOT EXISTS(SELECT 'X' FROM imeRemitCardMaster WITH(NOLOCK) WHERE cardStatus='Available' AND remitCardNo=@newRemitCardNo)
		--	BEGIN
		--		SELECT '1' errorCode,'New IME Remit Card not found.' msg,null
		--		RETURN
		--	END
		--END

		IF NOT EXISTS(SELECT 'X' FROM kycMaster km WITH(NOLOCK) WHERE remitCardNo = @oldRemitCardNo AND approvedDate IS NOT NULL)
		BEGIN
			SELECT '1' errorCode,'KYC cutomer not found.' msg,@oldRemitCardNo
			RETURN
		END

		IF EXISTS(SELECT 'X' FROM imeRemitCardReIssueRequest WITH(NOLOCK) 
			WHERE oldRemitCardNo = @oldRemitCardNo AND approvedDate is null)
		BEGIN
			SELECT '1' errorCode,'Earlier Request made has not been approved yet: '+@oldRemitCardNo+'.' msg,null
			RETURN
		END

		IF EXISTS(SELECT 'x' FROM dbo.kycMaster km WITH(NOLOCK) 
			WHERE approvedDate IS not NULL AND  remitCardNo = @newRemitCardNo)
		BEGIN
			SELECT '1' errorCode,'New Remit Card already in use, Please check once.' msg,null
			RETURN
		END 

		INSERT INTO imeRemitCardMaster (remitCardNo,accountNo,cardStatus,createdBy,createdDate)
		SELECT @newRemitCardNo,accountNo,'Available',@user,GETDATE() 
		FROM imeRemitCardMaster WITH(NOLOCK) WHERE remitCardNo = @oldRemitCardNo

		INSERT INTO imeRemitCardReIssueRequest(
			 oldRemitCardNo
			,newRemitCardNo
			,requestRemarks
			,requestFor
			,createdBy
			,createdDate	
			,customerName		
		)SELECT 
			 @oldRemitCardNo
			,@newRemitCardNo
			,@remark
			,@requestFor
			,@user
			,GETDATE()	
			,ISNULL(km.firstName, '') + ISNULL( ' ' + km.middleName, '')+ ISNULL( ' ' + km.lastName, '')
		FROM kycMaster km with(nolock) where km.remitCardNo = @oldRemitCardNo				

		SELECT '0' errorCode,'New IME Remit Card request has been made successfully. Waiting for approval.' msg,null
		RETURN
	END	

	IF @flag='a'
	BEGIN
		SELECT  
				 id=rowId
				,oldRemitCardNo
				,newRemitCardNo
				,Remarks=requestRemarks
				,createdBy
				,approvedDate
				,requestFor
		FROM imeRemitCardReIssueRequest WITH(NOLOCK) WHERE rowId=@rowId
		RETURN
	END

	IF @flag='u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM imeRemitCardReIssueRequest WITH(NOLOCK) WHERE rowId = @rowId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @rowId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM imeRemitCardReIssueRequestMod WITH(NOLOCK) WHERE reqId = @rowId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @rowId
			RETURN
		END 		

		IF NOT EXISTS(SELECT 'X' FROM imeRemitCardMaster WITH(NOLOCK) WHERE cardStatus IN ('Reserved','Enrolled') AND remitCardNo=@oldRemitCardNo)
		BEGIN
			SELECT '1' errorCode,'IME Remit Card has not been issued yet.' msg,null
			RETURN
		END

		IF NOT EXISTS(SELECT 'X' FROM kycMaster km WITH(NOLOCK) WHERE remitCardNo = @oldRemitCardNo AND approvedDate IS NOT NULL)
		BEGIN
			SELECT '1' errorCode,'KYC cutomer not found.' msg,@oldRemitCardNo
			RETURN
		END

		IF @requestFor = 'C'
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM imeRemitCardMaster WITH(NOLOCK) WHERE cardStatus='Available' AND remitCardNo = @newRemitCardNo)
			BEGIN
				SELECT '1' errorCode,'New IME Remit Card not found.' msg,null
				RETURN
			END
		END
		IF EXISTS(SELECT 'x' FROM dbo.kycMaster km WITH(NOLOCK) 
			WHERE approvedDate IS not NULL AND  remitCardNo = @newRemitCardNo)
		BEGIN
			SELECT '1' errorCode,'New Remit Card already in use, Please check once.' msg,null
			RETURN
		END 

		BEGIN TRANSACTION
		if not exists(select 'x' from imeRemitCardMaster with(nolock) where remitCardNo = @newRemitCardNo)
		begin
			INSERT INTO imeRemitCardMaster (remitCardNo,accountNo,cardStatus,createdBy,createdDate)
			SELECT @newRemitCardNo,accountNo,'Available',@user,GETDATE() 
			FROM imeRemitCardMaster WITH(NOLOCK) WHERE remitCardNo = @oldRemitCardNo
		end

		UPDATE imeRemitCardReIssueRequest 
		SET	 oldRemitCardNo	=@oldRemitCardNo
			,newRemitCardNo	=@newRemitCardNo
			,requestRemarks	=@Remark
			,modifiedBy		=@user
			,modifiedDate	=GETDATE()
			,requestFor		=@requestFor
			,customerName	=  ''
		FROM imeRemitCardReIssueRequest  A,
		(
			SELECT remitCardNo,customerName = ISNULL(km.firstName, '') + ISNULL( ' ' + km.middleName, '')+ ISNULL( ' ' + km.lastName, '')
			FROM kycMaster km WITH(NOLOCK) WHERE km.remitCardNo = @oldRemitCardNo
		)B WHERE B.remitCardNo = @oldRemitCardNo AND A.rowId=@rowId								
	
			
		IF @@ERROR = 0
		BEGIN
			COMMIT TRANSACTION
			SELECT '0' errorCode,'Your request has been modified successfully.' msg,null
			RETURN
		END
		ELSE 
		BEGIN				
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Modification Failed', @rowId
			RETURN
		END		
		RETURN
	END

	IF @flag='reject'
	BEGIN	
		UPDATE  imeRemitCardReIssueRequest SET										
					rejectedBy		=@user
				,rejectedDate		=GETDATE()									
		WHERE rowId=@rowId		

		SELECT '0' errorCode,'Your request has been rejected successfully.' msg,null	
		RETURN
	END

	IF @flag = 'approve'
	BEGIN		
		DECLARE @remitCardNo VARCHAR(20)=''
		
		IF NOT EXISTS(SELECT 'X' FROM imeRemitCardReIssueRequest WITH(NOLOCK) WHERE rowId = @rowId AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Request not found.', NULL
			RETURN
		END
		BEGIN TRANSACTION
		SELECT 
			 @remitCardNo=newRemitCardNo
			,@oldRemitCardNo=oldRemitCardNo 
			,@requestFor=LTRIM(requestFor)
		FROM imeRemitCardReIssueRequest WITH(NOLOCK) 
		WHERE rowId=@rowId		

		IF @requestFor='C'
		BEGIN
			UPDATE kycMaster SET 
				remitCardNo = @remitCardNo 
			WHERE remitCardNo = @oldRemitCardNo

			UPDATE customerMaster SET membershipId =  @remitCardNo 
				WHERE membershipId = @oldRemitCardNo
		END

		update imeRemitCardMaster set cardStatus = 'Enrolled' where remitCardNo  = @remitCardNo

		UPDATE imeRemitCardReIssueRequest SET 
			approvedBy = @user,approvedDate = GETDATE()
		WHERE rowId=@rowId		
					
		IF @@ERROR = 0
		BEGIN
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record approved successfully.', @rowId
			RETURN
		END
		ELSE 
		BEGIN				
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to approve record.', @rowId
			RETURN
		END
		RETURN
	END	

	IF @flag='a-agent'
	BEGIN
		SELECT  TOP 1
				 rowId
				,oldRemitCardNo
				,newRemitCardNo
				,requestRemarks
				,createdBy
				,approvedDate
				,requestFor
		FROM imeRemitCardReIssueRequest WITH(NOLOCK) 
		WHERE oldRemitCardNo = @oldRemitCardNo
			AND approvedDate IS NULL 
			AND rejectedDate IS NULL
		RETURN
	END
END


GO
