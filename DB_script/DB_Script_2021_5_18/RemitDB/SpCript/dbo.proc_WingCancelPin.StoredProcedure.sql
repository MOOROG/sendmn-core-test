USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_WingCancelPin]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---- proc_WingCancelPin @flag = 'list'
CREATE proc [dbo].[proc_WingCancelPin]
@flag		varchar(20),
@id			int = null,
@tpRefNo	varchar(20) = null,
@tpTranId	varchar(30) = null
as
set nocount on;

declare @controlNo varchar(20),@deliveryMethod varchar(50)

if @flag = 'list'
begin
	select c.id,dbo.fnadecryptstring(controlno) [gmeNo],createddate,createdby,paymentMethod
	into #temp
	from canceltranhistory(nolock) c where pagent ='221226' 
	and ContNo is null 

	alter table #temp add response varchar(max)

	update t set t.response=v.responsexml from vwTpApilogs(nolock) v
	inner join #temp t on t.gmeNo = v.controlNo
	where v.methodName='CommitWingTxnAccount'

	--update #temp set response=replace(response,'<?xml version="1.0" encoding="utf-16"?>','<?xml version="1.0" encoding="UTF-8"?>')
	update #temp set response=replace(response,'<WingTxnResponseDetailsCommon xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">','<WingTxnResponseDetailsCommon>')
	--update #temp set response=replace(response,'</WingTxnResponseDetailsCommon>','')
	--update #temp set response=replace(response,'<transaction_id>','')

	delete from #temp where response is null
	delete from #temp where response like '%<error_code>%'

	select * from #temp 
end
ELSE IF @flag = 'approve-wing'
BEGIN
	select @deliveryMethod = paymentMethod,@controlNo = controlno from canceltranhistory (nolock) where id = @id
			
	if @deliveryMethod <> 'Mobile Wallet'
		update canceltranhistory set controlno = dbo.FNAEncryptString(@tpRefNo) where id = @id

	UPDATE canceltranhistory SET 
				controlno		= case when @deliveryMethod = 'Mobile Wallet' then @controlNo else dbo.FNAEncryptString(@tpRefNo) end
				,controlNo2		= @controlNo
				,ContNo			= @tpTranId
				,paystatus		= 'Post'
	WHERE id = @id

	SELECT 0 ErrorCode,'Transaction has been sent successfully' Msg, @id id, case when @deliveryMethod = 'Mobile Wallet' then @controlNo else @tpRefNo end extra

END;
GO
