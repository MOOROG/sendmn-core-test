USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_uploadFile]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_uploadFile]
(
	@flag			varchar(1),	
	@rowId			int = 0 output,
	@controlNo		VARCHAR(50)  =NULL,
	@fileDesc		varchar(max) = null,
	@fileType		varchar(200) = null,
	@createdBy		varchar(100) = null,	
	@createdDate	varchar(50)  = null,
	@agentId		int			 = null
	
)

as
declare @tranId as int,@encryptedControlNo as varchar(200)
select @tranId=id from remitTran where controlNo=dbo.FNAEncryptString(@controlNo)
set @encryptedControlNo=dbo.FNAEncryptString(@controlNo)

if @flag = 'i'--inserted deposit slip in log
begin
	--select dbo.FNADecryptString(controlNo),* from tranModifyLog order by rowid desc
	--select * from remitTran
	--select dbo.FNADecryptString(controlNo),* from remitTran WHERE tranStatus='paid'

	INSERT INTO tranModifyLog(
				tranId,controlNo,message,
				createdBy,createdDate,fileType
				)
		 VALUES
			   (
				@tranId,@encryptedControlNo,@fileDesc,@createdBy,GETDATE(),@fileType	
			   )
	set @rowId = SCOPE_IDENTITY()
end
else if @flag = 'd'
begin
	delete from tranModifyLog where rowId=@rowId
end

else if @flag='a'--checking multiple deposit slip upload
begin
	if exists(select 'X' from tranModifyLog 
	where (tranId=@tranId OR controlNo=@encryptedControlNo) AND fileType IS NOT NULL)
	begin
		select '1' msg
	end
	else
	begin
		select '0' msg
	end
end

ELSE IF @flag='s'--search txn for upload deposit slip(ADMIN PANEL)
BEGIN
	SELECT id,pAgent,pAgentName FROM remitTran 
	WHERE controlNo=@encryptedControlNo  and paymentMethod='Bank Deposit' and tranStatus='Paid'

END



ELSE IF @flag='s1'--search txn for upload deposit slip (AGENT PANEL)
BEGIN
	SELECT id,pAgent,pAgentName FROM remitTran 
	WHERE controlNo=@encryptedControlNo  and paymentMethod='Bank Deposit' and tranStatus='Paid'
	AND pBranch=@agentId
END



GO
