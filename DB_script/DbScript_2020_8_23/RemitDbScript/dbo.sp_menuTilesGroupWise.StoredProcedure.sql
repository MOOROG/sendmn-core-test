USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[sp_menuTilesGroupWise]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[sp_menuTilesGroupWise] 
	@flag VARCHAR(30)

AS
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN
	    IF @flag = 'adminstration'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup IN ('administration', 'Application Settings', 'User Management')
			AND isActive = 'Y'
			
			SELECT 'Administration' AS title
		END
		
		IF @flag = 'sub_administration'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE functionId IN ('20101800', '20101900')
			AND isActive = 'Y'
			
			SELECT 'Administration >> Sub-Administration' AS title
		END

		ELSE IF @flag = 'customer_management'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE functionId IN ('20821800', '20822000')
			AND isActive = 'Y'

			SELECT 'Administration >> Customer Management' AS title
		END

		ELSE IF @flag = 'applicationsetting'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'Application Settings'
			AND isActive = 'Y'

			SELECT 'Administration >> Application Settings' AS title
		END
		
		ELSE IF @flag = 'system_security'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'Notifications'
			AND isActive = 'Y'

			SELECT 'Administration >> System Security' AS title
		END

		ELSE IF @flag = 'remittance'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup IN ('Credit Risk Management', 'Domestic Operation', 'Remittance', 'Reports')
			AND isActive = 'Y'

			SELECT 'Remittance' AS title
		END

		ELSE IF @flag = 'servicecharge_and_commission'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'Remittance'
			AND isActive = 'Y'

			SELECT 'Remittance >> Service Charge & Commission' AS title
		END
		
		ELSE IF @flag = 'creditrisk_management'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup IN ('Credit Risk Management', 'Domestic Operation')
			AND isActive = 'Y'

			SELECT 'Remittance >> Credit Risk Management' AS title
		END
		
		ELSE IF @flag = 'transaction'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'transaction'
			AND isActive = 'Y'

			SELECT 'Remittance >> Transaction' AS title
		END

		ELSE IF @flag = 'report'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'reports'
			AND isActive = 'Y'

			SELECT 'Remittance >> Reports' AS title
		END

		ELSE IF @flag = 'account'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup IN ('BILL & VOUCHER','Account Report-Remittance', 'ACCOUNT SETTING', 'ACCOUNT REPORT')
			AND isActive = 'Y'

			SELECT 'Account' AS title
		END

		ELSE IF @flag = 'remittance_report'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'Account Report-Remittance'
			AND isActive = 'Y'

			SELECT 'Account >> Remittance Report' AS title
		END

		ELSE IF @flag = 'account_report'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'ACCOUNT REPORT'
			AND isActive = 'Y'

			SELECT 'Account >> Account Report' AS title
		END

		ELSE IF @flag = 'sub_account'
		BEGIN
		    SELECT menuName, linkPage, menuDescription, menuGroup FROM dbo.applicationMenus (NOLOCK) 
			WHERE menuGroup = 'ACCOUNT SETTING'
			AND isActive = 'Y'

			SELECT 'Account >> Sub-Account' AS title
		END
	END
	 

GO
