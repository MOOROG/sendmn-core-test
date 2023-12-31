USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_exportTransaction]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_exportTransaction]  
	@fldmon VARCHAR(5000)=null,  
	@agentid VARCHAR(50)=null,  
	@ddDate VARCHAR(50)=null,  
	@fromDate VARCHAR(50)=null,  
	@toDate VARCHAR(50)=null,  
	@receiverCountry VARCHAR(50)=null,  
	@payoutagentid VARCHAR(50)=null,  
	@paymentType VARCHAR(50)=null,  
	@branch_id VARCHAR(50)=null,  
	@trn_status VARCHAR(50)=null,
	@user VARCHAR(20) = null,
	@userType VARCHAR(20) = null 

AS
SET NOCOUNT ON;
DECLARE  @sql VARCHAR(MAX)  

SET @fldmon = REPLACE(@fldmon,'|','+'',''+')

SET @sql=' 
SELECT '+ @fldmon +'
		 ,''DS:SwiftSystem'' [API Partner ID]
		 ,rt.sBranchName as [Sending Branch] 
from remitTran rt with(NOLOCK)  
inner join tranSenders sen with(nolock) on rt.id = sen.tranId
inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
where rt.tranStatus <> ''Cancel'' 
and '+ @ddDate+' between '''+@fromDaTe+'''  and '''+@toDate+' 23:59:59''
and rt.sAgent='''+ @agentid +'''' 

IF @branch_id is not null  
	SET @sql=@sql+' and rt.sBranch='''+ @branch_id +''''

IF @receiverCountry is not null  
	SET @sql=@sql+' and rt.pCountry='''+ @receiverCountry +''''  

IF @paymentType is not null  
	SET @sql=@sql+' and rt.paymentMethod='''+ @paymentType +''''  

IF @trn_status is not null  
	SET @sql=@sql+' and rt.tranStatus='''+@trn_status +''''  

PRINT @sql
EXEC(@sql)



GO
