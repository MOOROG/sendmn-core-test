USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_commissionLogs]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_commissionLogs](
	 @flag				VARCHAR(10)			= NULL
	,@user				VARCHAR(20)			= NULL
	,@fromDate			VARCHAR(40)			= NULL  
	,@toDate			VARCHAR(40)			= NULL    
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
)AS
BEGIN
	IF @flag='racl'
	BEGIN
		SET @toDate=@toDate+' 23:59:59.999'
		SELECT 				
				agentName=isnull(am.agentName,'ALL')
				,pm.code
				,old.approvedBy
				,old.approvedDate
				,new.modifiedBy
				,new.modifiedDate
				,newminAmt=new.minAmt
				,newmaxAmt=new.maxAmt
				,oldminAmt=old.minAmt
				,oldmaxAmt=old.maxAmt		
			FROM scPayDetail new WITH(NOLOCK)
			INNER JOIN scPayDetailHistory old with(NOLOCK) ON old.scPayDetailId=new.scPayDetailId
			LEFT JOIN scPayMaster pm on pm.scPayMasterId=new.scPayMasterId
			LEFT JOIN agentCommissionRule cr ON pm.scPayMasterId=cr.ruleId
			LEFT JOIN agentMaster am on am.agentId=cr.agentId
			WHERE old.approvedDate BETWEEN @fromDate AND @toDate	
			order by old.approvedDate,new.modifiedDate desc			

		SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id	
		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL 
		SELECT 'To Date' head,@toDate VALUE		

		SELECT 'Receiving Agent Commission Log Report' title	

	END

	IF @flag = 's'
	BEGIN	
		DECLARE 
				 @selectFieldList	VARCHAR(MAX)
				,@extraFieldList	VARCHAR(MAX)
				,@table				VARCHAR(MAX)
				,@sqlFilter			VARCHAR(MAX)
		
		IF @sortBy IS NULL  
			SET @sortBy = 'approvedDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'			
			SET @table = '(
							SELECT 				
								rowId=new.scPayDetailId
								,agentName=isnull(am.agentName,''ALL'')
								,pm.code
								,old.approvedBy
								,old.approvedDate
								,new.modifiedBy
								,new.modifiedDate		
							FROM scPayDetail new WITH(NOLOCK)
							INNER JOIN scPayDetailHistory old with(NOLOCK) ON old.scPayDetailId=new.scPayDetailId
							LEFT JOIN scPayMaster pm on pm.scPayMasterId=new.scPayMasterId
							LEFT JOIN agentCommissionRule cr ON pm.scPayMasterId=cr.ruleId
							LEFT JOIN agentMaster am on am.agentId=cr.agentId
						    WHERE 1=1'		
					
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
								   rowId
								 , agentName
								 , code								
								 , approvedBy
								 , approvedDate
								 , modifiedBy
								 , modifiedDate
							 '
					
		IF @fromDate IS NOT NULL and @toDate is not null		
			SET @table = @table + ' AND old.approvedDate BETWEEN ''' +  @fromDate + ''' AND ''' +  @toDate + ' 23:59:59'''
	
		SET @table = @table + ')x'

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
END



GO
