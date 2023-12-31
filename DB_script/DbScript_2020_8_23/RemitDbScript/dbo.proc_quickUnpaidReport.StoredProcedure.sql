USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_quickUnpaidReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_quickUnpaidReport]
(
	 @flag			VARCHAR(10)=NULL
	,@user			VARCHAR(30)=NULL
	,@sAgent		VARCHAR(10)=NULL
	,@searchBy		VARCHAR(50)=NULL
	,@searchText	varchar(100)=NULL
	,@tranId		VARCHAR(100)=NULL

)
AS 
SET NOCOUNT ON
BEGIN
	IF @flag='s'
	BEGIN
	DECLARE @sql VARCHAR(MAX)
	
	SET @sql='SELECT  
					[S.N.]	= row_number() over(order by x.[Tran Id]),
					[Tran Id],	
					[Sending Agent],
					[Sender Name] = SenderName,
					[Receiver Name] = ReceiverName,
					[Tran Status],
					[Payment Method],					
					[Tran Date],
					[Payout Amount],
					[Payout Location] 	
			FROM (
				 SELECT
						 [Tran Id]			= ''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(rt.id AS VARCHAR)+'''''')">''+CAST(rt.id AS VARCHAR)+''</a>''
						,[Tran Status]		= rt.payStatus
						,[Payment Method]	= rt.paymentMethod
						,[Sending Agent]	= rt.sAgentName
						,[SenderName]		= ts.firstName+''''+ISNULL(ts.middleName,'''')+''''+ISNULL(ts.lastName1,'''')
						,[ReceiverName]		= tr.firstName+''''+ISNULL(tr.middleName,'''')+''''+ISNULL(tr.lastName1,'''')
						,[Payout Location]	= l.districtName
						,[Tran Date]		= rt.createdDate
						,[Payout Amount]	= rt.pAmt
						,sAgent				= rt.sAgent
						,membershipId		= ts.membershipId	
					FROM remitTran rt WITH(NOLOCK)
					LEFT JOIN api_districtList l ON rt.pLocation=l.districtCode
					INNER JOIN tranSenders ts ON rt.id=ts.tranId
					INNER JOIN tranReceivers tr ON rt.id=tr.tranId 
					WHERE payStatus = ''Unpaid'' 
						AND tranStatus=''Payment'' 
				) x where 1=1'		
		IF @searchBy IS NOT NULL AND @searchText IS NOT NULL
			SET @sql=@sql + ' AND '+@searchBy+' LIKE ''%'+@searchText+'%'''
		IF @sAgent IS NOT NULL
			SET @sql=@sql + ' AND sAgent ='+@sAgent		
		print @sql
		EXEC (@sql)
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'Sending Agent' head, case when @sAgent is null then 'All' else (select agentName from agentMaster with(nolock) where agentId=@sAgent) end  value
		UNION ALL  
		SELECT  'Search By' head, @searchBy value
		UNION ALL  
		SELECT 'Search Text' head, @searchText value	
		
		SELECT 'Search Transacton -Unpaid' title
	END	
	IF @flag='searchBy'
	BEGIN
		SELECT 'SenderName' valText,'Sender Name' txtText UNION ALL		
		SELECT 'ReceiverName','Receiver Name' UNION ALL		
		SELECT 'membershipId','Membership Id' 		
	END
END






GO
