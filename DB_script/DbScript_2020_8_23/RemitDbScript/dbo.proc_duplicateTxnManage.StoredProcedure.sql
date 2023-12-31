USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_duplicateTxnManage]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_duplicateTxnManage]
	 @oldSysId		BIGINT
	,@newSysId		BIGINT

AS

DECLARE @pSuperAgent INT, @pSuperAgentName VARCHAR(100), @pAgent INT, @pAgentName VARCHAR(100),
@pBranch INT, @pBranchName VARCHAR(100), @pState VARCHAR(100), @pDistrict VARCHAR(100), @paidDate DATETIME, @paidDateLocal DATETIME, 
@paidBy VARCHAR(30), @rIdType VARCHAR(50), @rIdNumber VARCHAR(50), @rIdPlaceOfIssue VARCHAR(100)


IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE id = @oldSysId)
BEGIN
	EXEC proc_errorHandler 1, 'No record found', NULL
	RETURN
END
SELECT 
	 @pSuperAgent		= pSuperAgent
	,@pSuperAgentName	= pSuperAgentName
	,@pAgent			= pAgent
	,@pAgentName		= pAgentName
	,@pBranch			= pBranch
	,@pBranchName		= pBranchName
	,@pState			= pState
	,@pDistrict			= pDistrict
	,@paidDate			= paidDate
	,@paidDateLocal		= paidDateLocal
	,@paidBy			= paidBy
	,@rIdType			= rec.idType
	,@rIdNumber			= rec.idNumber
	,@rIdPlaceOfIssue	= rec.idPlaceOfIssue
FROM remitTran rt WITH(NOLOCK)
INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId WHERE rt.id = @oldSysId

UPDATE remitTran SET
	 pSuperAgent		= @pSuperAgent
	,pSuperAgentName	= @pSuperAgentName
	,pAgent				= @pAgent
	,pAgentName			= @pAgentName
	,pBranch			= @pBranch
	,pBranchName		= @pBranchName
	,pState				= @pState
	,pDistrict			= @pDistrict
	,paidDate			= @paidDate
	,paidDateLocal		= @paidDateLocal
	,paidBy				= @paidBy
WHERE id = @newSysId

UPDATE tranReceivers SET
	 idType2			= @rIdType
	,idNumber2			= @rIdNumber
	,idPlaceOfIssue2	= @rIdPlaceOfIssue
WHERE tranId = @newSysId

DELETE FROM remitTran WHERE id = @oldSysId


GO
