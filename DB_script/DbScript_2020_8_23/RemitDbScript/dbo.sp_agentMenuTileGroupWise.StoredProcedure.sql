USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[sp_agentMenuTileGroupWise]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[sp_agentMenuTileGroupWise]
	@flag CHAR(30)

AS 
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN
	    IF @flag = 'send_money'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE AgentMenuGroup = 'SEND MONEY'
			AND isActive = 'Y'
			
			SELECT 'Send Money' AS title
		END

		ELSE IF @flag = 'pay_money'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE AgentMenuGroup = 'Remittance'
			AND isActive = 'Y'
			
			SELECT 'Pay Money' AS title
		END

		ELSE IF @flag = 'reports'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE AgentMenuGroup = 'AGENT REPORT'
			AND isActive = 'Y'
			
			SELECT 'Reports' AS title
		END

		ELSE IF @flag = 'other_services'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE AgentMenuGroup = 'Other Services'
			AND isActive = 'Y'
			
			SELECT 'Other Services' AS title
		END
	END

GO
