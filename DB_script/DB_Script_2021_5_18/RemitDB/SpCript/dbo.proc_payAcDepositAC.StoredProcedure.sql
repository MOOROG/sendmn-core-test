USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payAcDepositAC]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_payAcDepositAC]
     @flag				VARCHAR(20) 
    ,@user				VARCHAR(50)		= NULL
	,@tranIds			VARCHAR(MAX)	= NULL
	,@mapCodeInt		VARCHAR(100)	= NULL
	,@parentMapCodeInt	VARCHAR(100)	= NULL
AS

SET NOCOUNT ON;
	DECLARE @tranDetail TABLE(tranId VARCHAR(50),controlNoEncrypted VARCHAR(50), controlNoDomEncrypted VARCHAR(50))
	DECLARE @sql VARCHAR(MAX)
	SET @sql = 'SELECT id, controlNo, controlNoDomEnc = dbo.encryptDbLocal(dbo.FNADecryptString(controlNo)) FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ')'
	INSERT INTO @tranDetail
	EXEC (@sql)
	
IF @flag = 'payDom'
	BEGIN
		UPDATE SendMnPro_Account.dbo.REMIT_TRN_LOCAL SET
			 R_BRANCH				= rt.pBankBranchName
			,R_BANK					= rt.pLocation
			,R_AGENT				= rt.pAgent
			,paidBy					= rt.paidBy
			,P_DATE					= rt.paidDate
			,PAY_STATUS				= rt.payStatus
			,R_SC					= rt.pAgentComm
			,TranIdNew				= rt.id
		FROM SendMnPro_Account.dbo.REMIT_TRN_LOCAL rtl
		INNER JOIN @tranDetail td ON rtl.TRN_REF_NO = td.controlNoDomEncrypted
		INNER JOIN remitTran rt ON td.controlNoEncrypted = rt.controlNo
		----INNER JOIN agentMaster am ON rt.pAgent = am.agentId
	END
IF @flag = 'payIntl'
	BEGIN
		UPDATE SendMnPro_Account.dbo.REMIT_TRN_MASTER SET
			 P_BRANCH			= rt.pBranch
			,P_AGENT			= rt.pAgent
			,paidBy				= rt.paidBy
			,PAID_DATE			= rt.paidDate
			,PAY_STATUS			= 'Paid'
			,SC_P_AGENT			= rt.pAgentComm
			,TranIdNew			= rt.id
		FROM SendMnPro_Account.dbo.REMIT_TRN_MASTER rtm
		INNER JOIN @tranDetail td ON rtm.TRN_REF_NO = td.controlNoEncrypted
		INNER JOIN remitTran rt ON td.controlNoEncrypted = rt.controlNo
		----INNER JOIN agentMaster am ON rt.pAgent = am.agentId
		----INNER JOIN agentMaster bm ON rt.pBranch = bm.agentid
	END
IF @flag = 'payDomIso'
	BEGIN
		UPDATE SendMnPro_Account.dbo.REMIT_TRN_LOCAL SET
			 R_BRANCH				= rt.pBranch
			,R_BANK					= rt.pLocation
			,R_AGENT				= rt.pAgent
			,paidBy					= rt.paidBy
			,P_DATE					= rt.paidDate
			,PAY_STATUS				= rt.payStatus
			,R_SC					= rt.pAgentComm
			,TranIdNew				= rt.id
		FROM SendMnPro_Account.dbo.REMIT_TRN_LOCAL rtl
		INNER JOIN @tranDetail td ON rtl.TRN_REF_NO = td.controlNoDomEncrypted
		INNER JOIN remitTran rt ON td.controlNoEncrypted = rt.controlNo
		----INNER JOIN agentMaster am ON rt.pAgent = am.agentId
		----INNER JOIN agentMaster bm ON rt.pBranch = bm.agentid
	END
IF @flag = 'payCooperative'
	BEGIN
		UPDATE SendMnPro_Account.dbo.REMIT_TRN_LOCAL SET
			 R_BRANCH				= rt.pBankBranchName
			,R_BANK					= rt.pLocation
			,R_AGENT				= rt.pAgent
			,paidBy					= rt.paidBy
			,P_DATE					= rt.paidDate
			,PAY_STATUS				= rt.payStatus
			,R_SC					= rt.pAgentComm
			,TranIdNew				= rt.id
		FROM SendMnPro_Account.dbo.REMIT_TRN_LOCAL rtl
		INNER JOIN @tranDetail td ON rtl.TRN_REF_NO = td.controlNoDomEncrypted
		INNER JOIN remitTran rt ON td.controlNoEncrypted = rt.controlNo
		----INNER JOIN agentMaster am ON rt.pAgent = am.agentId
	END







GO
