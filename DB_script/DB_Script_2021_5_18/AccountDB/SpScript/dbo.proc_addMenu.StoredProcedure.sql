USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_addMenu]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[proc_addMenu]
	 @module			VARCHAR(2)
	,@functionId		VARCHAR(8)	
	,@menuName			VARCHAR(50)
	,@menuDescription	VARCHAR(50)
	,@linkPage			VARCHAR(255)
	,@menuGroup			VARCHAR(50)
	,@position			INT
	,@isActive			CHAR(1)
	,@groupPosition		INT
	
AS


IF NOT EXISTS (SELECT 'X' FROM applicationMenus WHERE functionId = @functionId)
BEGIN	
	INSERT INTO applicationMenus (
		module, functionId, menuName, menuDescription, linkPage, menuGroup, position, isActive, groupPosition
	)
	SELECT @module, @functionId, @menuName, @menuDescription, @linkPage, @menuGroup, @position, @isActive, @groupPosition
	PRINT @menuName  + ' menu added.'		
END


GO
