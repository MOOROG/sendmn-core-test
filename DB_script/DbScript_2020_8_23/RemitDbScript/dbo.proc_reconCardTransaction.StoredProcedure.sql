USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reconCardTransaction]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_reconCardTransaction]
	 @flag				VARCHAR(50)
	,@rowId				BIGINT			= NULL
	,@controlNo			VARCHAR(50)		= NULL
	,@memId				VARCHAR(50)		= NULL
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
	
		SET @sortBy = 'txnDate'
		SET @sortOrder = 'DESC'					
	
		SET @table = '
		(		
			SELECT * 
			FROM 
			(
					SELECT 
							 agentName			= rt.sAgentName
							,controlNo			= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.fnadecryptstring(rt.controlNo) + '''''')">'' +dbo.fnadecryptstring(rt.controlNo)  + ''</a>''
							,pAmt				= rt.pAmt
							,memId				= cm.membershipId 
							,senderName			= rt.senderName
							,receiverName		= rt.receiverName
							,payStatus			= rt.payStatus
							,txnDate			= rt.createdDateLocal
							,txnType			= ''Send''
						FROM remitTran rt WITH(NOLOCK) 
						INNER JOIN transenders ts WITH(NOLOCK) ON rt.id=ts.tranId 
						INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId
						WHERE cm.membershipId ='''+@memId+''' 
						UNION ALL
						SELECT 
							 agentName			= rt.sAgentName
							,controlNo			= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.fnadecryptstring(rt.controlNo) + '''''')">'' + dbo.fnadecryptstring(rt.controlNo) + ''</a>''
							,pAmt				= rt.pAmt
							,memId				= cm.membershipId 
							,senderName			= rt.senderName
							,receiverName		= rt.receiverName
							,payStatus			= rt.payStatus
							,txnDate			= rt.createdDateLocal
							,txnType			= ''Paid''
						FROM remitTran rt WITH(NOLOCK) 
						INNER JOIN tranReceivers ts WITH(NOLOCK) ON rt.id=ts.tranId 
						INNER JOIN customerMaster cm WITH(NOLOCK)ON ts.membershipId=cm.membershipId 
						WHERE cm.membershipId = '''+@memId+'''
			)a
		'						

		SET @table = @table+' )x'
		 
		 
		SET @sqlFilter = '' 
		
		SET @selectFieldList = '
								   agentName
								 , controlNo
								 , pAmt
								 , memId
								 , senderName
								 , receiverName
								 , payStatus
								 , txnDate
								 , txnType							 
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
				
	END	


		
		









GO
