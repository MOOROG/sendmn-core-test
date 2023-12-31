USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAHasRight]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAHasRight](@userName VARCHAR(50), @functionId VARCHAR(1000))
RETURNS CHAR(1)
AS
BEGIN
	--RETURN 'Y'
	
	IF EXISTS(SELECT 'X' FROM dbo.FNAGetAdmins() WHERE admin = @userName)	
		RETURN 'Y'
			
	DECLARE @hasRight CHAR(1), @userId INT
	SET @hasRight = 'N'
	
	SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName

	IF @functionId IN ('10101300,10101310','20181700','10101300')
		RETURN 'Y'
	

	IF EXISTS(
			SELECT 
				arf.functionId functionId
			FROM applicationRoleFunctions arf WITH(NOLOCK)
			INNER JOIN applicationUserRoles aur WITH(NOLOCK) ON arf.roleId = aur.roleId
			WHERE aur.userId =@userId
		 AND arf.functionId IN (SELECT value FROM [dbo].[Split](',', @functionId)) 
	)
	BEGIN
		SET @hasRight = 'Y'
	END
	
	RETURN @hasRight
END

GO
