USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentSearchAutocomplete]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_agentSearchAutocomplete @FLAG='A',@user='ADMIN',@searchField='BAJ'
EXEC proc_agentSearchAutocomplete @FLAG='b',@searchField='global'
EXEC proc_agentSearchAutocomplete @FLAG='c',@searchField='baj'

*/
CREATE proc [dbo].[proc_agentSearchAutocomplete]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@searchField						VARCHAR(200)	= NULL
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @flag = 'a'				
	BEGIN
			SELECT A.agentName,A.agentId FROM 
			(
				SELECT TOP 20 agentId,agentName+' '+b.districtName agentName
				FROM agentMaster a WITH(NOLOCK) LEFT JOIN api_districtList b WITH(NOLOCK)
				ON a.agentLocation=b.districtCode
				WHERE (actAsBranch = 'Y' OR agentType = 2904)
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
			)A WHERE A.agentName LIKE '%'+@searchField+'%' ORDER BY A.agentName
	END
	
	IF @flag = 'b' -- Populate agent bank List only		
	BEGIN
			
			SELECT TOP 20 agentName+'|'+CAST(agentId AS VARCHAR) agentName,a.agentId
				FROM agentMaster a WITH(NOLOCK) 
				WHERE isnull(isSettlingAgent,'N')='Y' and isnull(actAsBranch,'N')='N'
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
						AND A.agentName LIKE '%'+@searchField+'%' ORDER BY A.agentName
			
	END
	
	IF @flag = 'c' -- Populate agent (IME Private Agents)	
	BEGIN
			
			SELECT TOP 20 agentName+'|'+CAST(agentId AS VARCHAR) agentName,a.agentId FROM 
			(
				SELECT  agentId,agentName+' '+b.districtName agentName
				FROM agentMaster a WITH(NOLOCK) LEFT JOIN api_districtList b WITH(NOLOCK)
				ON a.agentLocation=b.districtCode
				WHERE       actAsBranch = 'Y' 
						AND agentType = 2903
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
			)A WHERE A.agentName LIKE '%'+@searchField+'%' ORDER BY A.agentName
			
	END

	IF @flag = 'cv2' -- Populate agent (IME Private Agents)	INCLUDING ime co-operative
	BEGIN			
			--SELECT TOP 20 * FROM
			--(
			--SELECT  a.agentId,a.agentName
			--FROM agentMaster a WITH(NOLOCK) 
			--WHERE       actAsBranch = 'Y' 
			--		AND (agentType = 2903 and actAsBranch = 'Y')
			--		AND ISNULL(a.isDeleted, 'N') = 'N'
			--		OR (agentType = 2904)	
			--		--OR (agentId = 20653)
			--)X WHERE agentName LIKE '%'+@searchField+'%'	
			--ORDER BY agentName

			SELECT TOP 20 * FROM
			(
			SELECT  a.agentId,a.agentName
			FROM agentMaster a WITH(NOLOCK) 
			WHERE   
					agentGrp <> '4301'
					AND ISNULL(a.isDeleted, 'N') = 'N'
					AND (
							(agentType = 2903 AND actAsBranch = 'Y')					
							OR agentType = 2904
						)	
					
			)X WHERE agentName LIKE '%'+@searchField+'%'	
			ORDER BY agentName

	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH


GO
