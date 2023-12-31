USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_addCommentAPI_122215]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_addCommentAPI_122215] (
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
	,@tranId			INT				= NULL
	,@message			VARCHAR(200)	= NULL
)
AS

DECLARE
	 @sAgent			INT
	,@tAmt				MONEY
	,@cAmt				MONEY
	,@pAmt				MONEY

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	
EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT
DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

--Add Comment API----------------------------------------------------------------------------------------------------
IF @flag = 'i'
BEGIN
	EXEC proc_errorHandler 0, 'SUCCESS.', @password
	RETURN;
END

----------------------------------------------------------------------------------------------------------------


GO
