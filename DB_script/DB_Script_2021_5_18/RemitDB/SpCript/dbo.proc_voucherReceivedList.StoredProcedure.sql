USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_voucherReceivedList]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec proc_LoginViewLogs @flag = 's', @reason='Admin Login'

CREATE proc [dbo].[proc_voucherReceivedList]
			 @flag				VARCHAR(50)
			,@rowId				BIGINT			= NULL
			,@agentId			VARCHAR(50)		= NULL
			,@fromDate			VARCHAR(50)		= NULL
			,@toDate			VARCHAR(30)		= NULL
			,@agentName			VARCHAR(200)	= NULL
			,@sortBy			VARCHAR(50)		= NULL
			,@sortOrder			VARCHAR(50)		= NULL
			,@pageSize			INT				= NULL
			,@pageNumber		INT				= NULL
			,@user				VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;

IF @flag = 's'
BEGIN 
	
	   DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)			
	
			SET @sortBy = 'createdDate'
			SET @sortOrder = 'DESC'					
	
		SET @table = '(
							select a.id,b.agentName,a.fromDate,a.toDate,a.createdBy,a.createdDate
							from voucherReceive a with(nolock) inner join agentMaster b with(nolock) on a.agentId=b.agentId
							where a.isDeleted is null
					'		
					
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			   id
			 , agentName
			 , fromDate
			 , toDate
			 , createdBy
			 , createdDate
			'
			
		IF @agentName IS NOT NULL
			SET @table = @table + ' AND b.agentName LIKE ''' + @agentName + '%'''

		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
			SET @table = @table + ' AND cast(a.fromDate as date) BETWEEN   ''' + cast(@fromDate as varchar(11))  + ''' and  ''' + cast(@toDate as varchar(11))  + ' 23:59:59'''
		
		SET @table = @table+' )x'
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

ELSE IF @flag = 'u'
BEGIN
		BEGIN TRANSACTION
		
		UPDATE voucherReceive SET
				 agentId		=	@agentId
				,fromDate		=	@fromDate
				,toDate			=	@toDate
				,modifiedBy		=	@user
				,modifiedDate	=	GETDATE()	
		WHERE id=@rowId
		
		SET @rowId = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowId
END

ELSE IF @flag = 'i'
BEGIN
		BEGIN TRANSACTION
		
		INSERT INTO voucherReceive(agentId,fromDate,toDate,createdBy,createdDate)VALUES
		(@agentId,@fromDate,@toDate,@user,getdate()) 
	 				
				
		SET @rowId = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
END

ELSE IF @flag = 'a'
BEGIN
		
		SELECT B.agentName
			,A.agentId
			,convert(varchar,A.fromDate,101) fromDate
			,convert(varchar,A.toDate,101) toDate
			,A.createdBy 
			,A.createdDate 
		FROM voucherReceive A WITH(NOLOCK) INNER JOIN agentMaster B WITH(NOLOCK) 
		ON A.agentId=B.agentId
		WHERE A.id=@rowId

END

--EXEC proc_voucherReceivedList  @flag = 'a', @user = 'admin', @rowId = '5'

GO
