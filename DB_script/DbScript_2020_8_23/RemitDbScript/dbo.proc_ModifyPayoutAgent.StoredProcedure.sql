USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ModifyPayoutAgent]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_ModifyPayoutAgent](
	 @flag					VARCHAR(10)=NULL
	,@user					VARCHAR(30)=NULL
	,@controlNo				VARCHAR(30)=NULL
	,@tranId				VARCHAR(10)=NULL
	,@oldAccountNo			VARCHAR(30)=NULL
	,@bankAccountNo			VARCHAR(30)=NULL
	,@extBankId				VARCHAR(10)=NULL
	,@extBankName			VARCHAR(100)=NULL
	,@extBankBranchId		VARCHAR(10)=NULL
	,@extBankBranchName		VARCHAR(50)=NULL	
	,@controlNoEncrypted	VARCHAR(30)=NULL
	,@oldBankBranch			VARCHAR(50)=NULL
	,@oldBankName			VARCHAR(100)=NULL
	
	
)AS

SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
	
	SET @controlNoEncrypted=dbo.FNAEncryptString(@controlNo)
	IF @flag='bankList'
	BEGIN
		SELECT extBankId,bankName from externalBank WITH(NOLOCK)
		ORDER BY bankName
	END
	
	IF @flag='bankBranch'
	BEGIN
		SELECT 
			 extBranchId
			,branchName 
		FROM externalBankBranch
		WHERE extBankId= @extBankId
		ORDER BY branchName
	END
	
	IF @flag='u'
	BEGIN
		if (RIGHT(@controlNo,1) = 'D')
		begin
			EXEC proc_errorHandler 1,'Invalid Transaction, You can not update for Domestic Transaction.',null
			return
		end
		
		DECLARE @pAgent INT, @pAgentName VARCHAR(200) 

		select  @pAgent = internalCode,
				@pAgentName = bankName
		from externalBank with(nolock) where extBankId = @extBankId

		UPDATE remitTran SET
			 accountNo = @bankAccountNo
			,pBank = @extBankId
			,pBankName = @extBankName
			,pBankBranch = @extBankBranchId
			,pBankBranchName = @extBankBranchName
			,modifiedBy = @user
			,modifiedDate = GETDATE()
			,pAgent = @pAgent
			,pAgentName = @pAgentName
		WHERE controlNo = @controlNoEncrypted
				
		----*update transaction log*------
		insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
		select @tranId,'Branch Name:'+ isnull(@oldBankBranch,'')+' has been changed to '+isnull(@extBankBranchName,''),@user,GETDATE(),'MODIFY'
		
		insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
		select @tranId,'Agent Name:'+ isnull(@oldBankName,'')+' has been changed to '+isnull(@extBankName,''),@user,GETDATE(),'MODIFY'
		
		insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
		select @tranId,'Account No:'+ isnull(@oldAccountNo,'')+' has been changed to '+isnull(@bankAccountNo,''),@user,GETDATE(),'MODIFY'
		
		EXEC proc_errorHandler 0,'Payout agent successfully changed',null
	END
END




GO
