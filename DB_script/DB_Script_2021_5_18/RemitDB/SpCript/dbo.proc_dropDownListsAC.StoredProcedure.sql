USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dropDownListsAC]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_dropDownListsAC]
     @flag			VARCHAR(200)	
    ,@param			VARCHAR(200)	= NULL
    ,@user			VARCHAR(30)		= NULL
    
AS
SET NOCOUNT ON;

IF @flag = 'sAgent'							
BEGIN
	SELECT 
		agent_name,
		map_code 
	FROM SendMnPro_Account.dbo.agentTable WITH(NOLOCK)
	WHERE AGENT_TYPE = 'Sending' and isnull(agent_status,'y') = 'y'
	ORDER BY agent_name ASC
	RETURN;
END






GO
