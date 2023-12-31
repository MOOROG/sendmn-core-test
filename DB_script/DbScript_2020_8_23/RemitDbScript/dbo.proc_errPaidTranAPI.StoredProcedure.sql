USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_errPaidTranAPI]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_errPaidTranAPI]
	 @flag				VARCHAR(100)= NULL
	,@user				VARCHAR(50)	= NULL
	,@id				INT			= NULL
	,@functionId		VARCHAR(50) = NULL
	,@newPBranch		INT			= NULL
	,@newDeliveryMethod	VARCHAR(100)= NULL

AS

/*
	EXEC [proc_errPaidTranAPI] @flag = 'c',@user = 'imeadmin',@functionId = '20122330',@id = '1'
	EXEC [proc_errPaidTranAPI] @flag = 'p',@user = 'admin',@id = '2'
	EXEC [proc_errPaidTranAPI] @flag = 'p',@user = 'bijay',@id = '10', @newPBranch = '4617'
*/

SET NOCOUNT ON
DECLARE 
	 @inter_domestic	CHAR(1)
	,@mapCode			VARCHAR(8)
	,@agentType			INT
	,@controlNo         VARCHAR(50)
	,@remarks			VARCHAR(MAX)
	,@pAgentComm		MONEY	
	,@requestedBy		VARCHAR(50)

	--- ## CALLING API WHILE APPROVING ERROR PAID TRANSACTION
	IF @flag = 'c'	
	BEGIN
		SELECT TOP 1 
			 @remarks		= ISNULL(narration, '') + ' (Approved By: S:' + @user + ')'
			,@controlNo		= dbo.FNADecryptString(controlNo)
			,@newPBranch	= newPBranch
			,@requestedBy	= a.createdBy
		FROM errPaidTran A WITH(NOLOCK) 
		INNER JOIN remitTran trn WITH(NOLOCK) ON trn.id = A.tranId
		WHERE A.eptid = @id

		IF NOT EXISTS (SELECT 'X' FROM errPaidTran WITH(NOLOCK) WHERE eptId = @id AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM errPaidTranHistory WITH(NOLOCK) WHERE eptId = @id and approvedBy is null)
		BEGIN
			SELECT 'ERROR', '', 'Modification has not been approved yet'
			RETURN
		END
	
		IF @user IS NULL
		BEGIN
			SELECT 'ERROR', '', 'Your session is expired. Please re-login to the system'
			RETURN
		END
		SELECT 'SUCCESS', '', 'EP has been approved successfully.'
		RETURN
	END

	--## Pay Order
	ELSE IF @flag = 'p'		
	BEGIN
		SELECT 'SUCCESS', '', 'Pay order has been done successfully.'
		RETURN
	END


GO
