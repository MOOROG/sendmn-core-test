USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_TransactionviewLogs]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_TransactionviewLogs]
     @flag				VARCHAR(50)
	,@Id				BIGINT			= NULL
	,@tranViewType		VARCHAR(50)		= NULL	
	,@controlNumber		VARCHAR(50)		= NULL
	,@agent				VARCHAR(50)		= NULL
	,@AgentName			VARCHAR(50)		=NULL
	,@user				VARCHAR(30)		= NULL
	,@createdBy			VARCHAR(30)		= NULL
	,@createdDate		DATE	 		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
	,@tranId			BIGINT			= NULL
AS
SET NOCOUNT ON;

IF @flag = 's'
BEGIN 
	
	   DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
			
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		SET @table = '(
						SELECT 
							 al.id
							,case when al.tranId is not null then al.tranId else c.id end tranId
							,case when al.controlNumber is null then
								dbo.FNADecryptString(RT.controlNo) else al.controlNumber end
								as controlNumber
							,isnull(al.tranViewType, ''T'') as tranViewType
							,A.agentName						
							,al.createdBy
							,al.createdDate
						FROM tranViewHistory al WITH(NOLOCK)
						LEFT JOIN remitTran RT WITH(NOLOCK) ON al.tranId=RT.id
						LEFT JOIN agentMaster A ON al.agentId = A.agentId
						left join remitTran C with(nolock) on c.controlNo=al.controlNumber and c.paidby=al.createdBy						
					    WHERE 1=1 
					'		
					
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
			   id
			 , tranId
			 , controlNumber
			 , tranViewType
			 , createdBy
			 , createdDate
			 , agentName
			'
		
		IF @tranViewType IS NOT NULL
			SET @table = @table + ' AND tranViewType = ''' + @tranViewType + ''''
			
		IF @createdDate IS NOT NULL
			SET @table = @table + ' AND cast(al.createdDate as date) = ''' + cast(@createdDate as varchar(11))  + ''''
	
			
		IF @Id IS NOT NULL
			SET @table = @table + ' AND dataId = ''' + @Id + ''''
			
		IF @controlNumber IS NOT NULL
			SET @table = @table + ' AND controlNumber = ''' + dbo.FNAEncryptString(@controlNumber) + ''''
			
		IF @agent IS NOT NULL
			SET @table = @table + ' AND agentName LIKE ''' + @agent + '%'''
			

		IF @createdBy IS NOT NULL
			SET @table = @table + ' AND al.createdBy = ''' + @createdBy + ''''
		IF @tranId IS NOT NULL
			SET @table = @table + ' AND al.tranId = ''' + cast(@tranId as varchar)+ ''''
			
		IF (@tranViewType IS  NULL				
		  and @createdBy IS  NULL
		  and @agent IS NULL
		  and @createdDate IS NULL
		  and @controlNumber IS NULL
		  and @tranId IS NULL
		  )
		  begin

			 SET @table = @table + ' and 1=1 '

		  end 

		
		  SET @table =  @table +') x '



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





GO
