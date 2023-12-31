USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_addMenu]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_addMenu]
	 @module			VARCHAR(2)
	,@functionId		VARCHAR(8)	
	,@menuName			VARCHAR(50)
	,@menuDescription	VARCHAR(50)
	,@linkPage			VARCHAR(255)
	,@menuGroup			VARCHAR(50)
	,@position			INT
	,@isActive			CHAR(1)
	,@groupPosition		INT
	,@AgentMenuGroup    VARCHAR(50) = NULL
	,@AgentMenuIcon		VARCHAR(50) = NULL
	
AS


IF NOT EXISTS (SELECT 'X' FROM applicationMenus WHERE functionId = @functionId)
BEGIN	
 select 'dhan'
	INSERT INTO applicationMenus (
		module, functionId, menuName, menuDescription, linkPage, menuGroup, position, isActive, groupPosition,AgentMenuGroup,AgentMenuIcon
	)
	SELECT @module, @functionId, @menuName, @menuDescription, @linkPage, @menuGroup, @position, @isActive, @groupPosition, @AgentMenuGroup,@AgentMenuIcon
	select @menuName  + ' menu added.'		
END



GO
