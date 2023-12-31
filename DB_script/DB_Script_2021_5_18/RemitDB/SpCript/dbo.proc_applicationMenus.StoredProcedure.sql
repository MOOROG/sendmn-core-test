USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationMenus]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_applicationMenus]

	 @flag			VARCHAR(10) = NULL

	,@userName		VARCHAR(50) = NULL



AS

/*

exec proc_applicationMenus @flag='s',@userName = 'admin'



SELECT dbo.FNAIsAdmin(NULL)

*/


SET NOCOUNT ON;


IF NULLIF(@flag, 's') IS NULL

BEGIN

	DECLARE @agentType INT

	

	SELECT @agentType = am.agentType 

	FROM applicationUsers au WITH(NOLOCK) 

	LEFT JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId WHERE au.userName = @userName

	 

	IF dbo.FNAIsAdmin(@userName) = 'Y'	

	BEGIN

		SELECT 

			am.* 

		FROM applicationMenus am WITH(NOLOCK)		

		WHERE ISNULL(am.isActive, 'Y') = 'Y'

			

		ORDER BY am.groupPosition ASC, am.position ASC		

		RETURN	

	END

	

	IF(@agentType IN (2903,2904))

	BEGIN

		SELECT 

			am.* 

		FROM applicationMenus am WITH(NOLOCK)

		WHERE am.functionId IN (

				SELECT functionId FROM applicationUserFunctions auf WITH(NOLOCK) WHERE [userId] IN 

				(SELECT userId FROM applicationUsers WHERE userName = @userName)

				UNION

				SELECT functionId FROM applicationRoleFunctions arf WITH(NOLOCK) WHERE roleId IN 

				(SELECT roleId FROM applicationUserRoles aur WITH(NOLOCK) WHERE [userId] IN 

				(SELECT userId FROM applicationUsers WHERE userName = @userName))

			) 

		AND ISNULL(am.isActive, 'Y') = 'Y' 

		AND am.functionId NOT IN (

									 '20111000','20111100','20111200','20111300','20111400'							--Exchange Rate

									,'20141000','20141100'															--Service Charge

									,'20131000','20131100','20131200','20131300'									--Commission Agent

									,'20191000','20191100','20191200','20191300'									--Commission Super Agent

									,'20201000','20201100','20201200','20201300'									--Commission Hub

									,'20171000','20171100'															--Compliance

									,'20101200','20101300','20101400','20101500','20101600','20101700','20101800'	--Administration

								)

		ORDER BY 

			 am.groupPosition ASC

			,am.position ASC

		RETURN

	END

	

	SELECT 

		am.* 

	FROM applicationMenus am WITH(NOLOCK)

	WHERE am.functionId IN (

			SELECT functionId FROM applicationUserFunctions auf WITH(NOLOCK) WHERE [userId] IN 

			(SELECT userId FROM applicationUsers WHERE userName = @userName)

			UNION

			SELECT functionId FROM applicationRoleFunctions arf WITH(NOLOCK) WHERE roleId IN 

			(SELECT roleId FROM applicationUserRoles aur WITH(NOLOCK) WHERE [userId] IN 

			(SELECT userId FROM applicationUsers WHERE userName = @userName))

		) 

	AND ISNULL(am.isActive, 'Y') = 'Y' 

	--AND am.functionId <> '30101050'

	ORDER BY 

		 am.groupPosition ASC

		,am.position ASC

END

ELSE IF @flag = 'l'

BEGIN

	SELECT 

		functionId 

	FROM applicationMenus am WITH(NOLOCK)

	WHERE ISNULL(isActive, 'y') = 'y' 

	ORDER BY

		 groupPosition ASC

		,position ASC

END




GO
