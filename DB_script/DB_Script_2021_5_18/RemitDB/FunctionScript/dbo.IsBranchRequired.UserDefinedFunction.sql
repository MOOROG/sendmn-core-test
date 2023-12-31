USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[IsBranchRequired]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsBranchRequired] 
(
	@bankId BIGINT
)
RETURNS BIT
AS
BEGIN	
	IF EXISTS(SELECT 'x' FROM dbo.agentMaster(NOLOCK) AS AM WHERE AM.parentId = @bankId AND AM.agentCountryId = 151)
	BEGIN
		RETURN 0;
	END
	IF EXISTS(SELECT 'x' FROM dbo.agentMaster(NOLOCK) AS AM WHERE AM.parentId = @bankId AND AM.agentType = 2904 AND isActive ='Y')
	BEGIN
		RETURN 1;
	END
	RETURN 0;
END
GO
