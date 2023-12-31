USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_MapCodeReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_MapCodeReport](
	 @functionID		VARCHAR(100) = NULL
	,@user				VARCHAR(30) 
	,@pageFrom			INT = NULL
	,@pageTo			INT = NULL
	,@branch			INT = NULL
	,@agent				INT	= NULL
	,@fxml				XML = NULL
	,@qxml				XML = NULL
	,@dxml				XML = NULL
	,@flag				VARCHAR(3) = NULL
	,@bankId			INT = NULL
)AS

SET NOCOUNT ON

IF @functionID='20168000'
BEGIN
	SET @pageFrom = ISNULL(NULLIF(@pageFrom, 0), 1)
	SET @pageTo = ISNULL(@pageTo, @pageFrom)
	DECLARE @pageSize INT = 50

	DECLARE @mapCodeFormat VARCHAR(50)

	SELECT
		 @mapCodeFormat = p.value('@mapcodeformat','VARCHAR(50)')			
	FROM @fxml.nodes('/root/row') AS tmp(p)

	IF @mapCodeFormat='N'
	BEGIN
	SELECT 
		 [New Ext Bank ID] =  extBankId
		,[Bank Name] = bankName
		,[Branch MapCode] = branchMapCode		
		,[Branch Name] = branchName		
		,[Is Head Office] = case when isHeadOffice	 ='Y' then 'Yes' else '' end	
	FROM (		
		SELECT 
			ROW_NUMBER() OVER (ORDER BY extBankId ASC) row_Id		
			,*
		FROM (
			SELECT * FROM (
							SELECT eb.extBankId, bankName, branchMapCode = ebb.extBranchId, branchName ,ebb.isHeadOffice
							FROM dbo.externalBank eb WITH(NOLOCK) 
							LEFT JOIN dbo.externalBankBranch ebb WITH(NOLOCK) ON eb.extBankId = ebb.extBankId
							WHERE internalCode IN (
							SELECT agentId FROM dbo.agentMaster WITH(NOLOCK) WHERE agentType IN (2903) AND ISNULL(actAsBranch, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
							)
							--AND ISNULL(ebb.isHeadOffice, 'N') = 'Y'
							AND ISNULL(eb.isDeleted, 'N') = 'N'
							AND ISNULL(ebb.isDeleted, 'N') = 'N'
							AND ISNULL(eb.isBlocked,'N') = 'N'
							AND ISNULL(ebb.isBlocked,'N') = 'N'

							UNION ALL

							SELECT eb.extBankId, bankName, branchMapCode = ebb.extBranchId, branchName ,ebb.isHeadOffice
							FROM dbo.externalBank eb WITH(NOLOCK) 
							LEFT JOIN dbo.externalBankBranch ebb WITH(NOLOCK) ON eb.extBankId = ebb.extBankId
							WHERE internalCode IN (
							SELECT agentId FROM dbo.agentMaster WITH(NOLOCK) WHERE agentType IN (2905) AND ISNULL(actAsBranch, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
							)
							AND ISNULL(eb.isDeleted, 'N') = 'N'
							AND ISNULL(ebb.isDeleted, 'N') = 'N'
							AND ISNULL(eb.isBlocked,'N') = 'N'
							AND ISNULL(ebb.isBlocked,'N') = 'N'
						) xx
			
			) x 
	)x WHERE row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
		ORDER BY bankName, branchName	
	END
	ELSE IF @mapCodeFormat='O'
	BEGIN

	SELECT 
		 [Old Ext Bank ID] =  extBankId
		,[Bank Name] = bankName
		,[Branch MapCode] = branchMapCode		
		,[Branch Name] = branchName				
	FROM (		
		SELECT 
			ROW_NUMBER() OVER (ORDER BY extBankId ASC) row_Id		
			,*
		FROM (
			SELECT * FROM (
							SELECT 
								eb.extBankId, bankName, branchMapCode = bm.mapCodeInt, branchName = bm.agentName 
							FROM dbo.externalBank eb WITH(NOLOCK) 
							INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON eb.internalCode = am.agentId
							INNER JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId
							WHERE am.agentType = 2903
								AND ISNULL(am.actAsBranch, 'N') = 'N' 
								AND ISNULL(am.isActive, 'N') = 'Y' 
								AND ISNULL(am.isDeleted, 'N') = 'N'
								--AND ISNULL(bm.isHeadOffice, 'N') = 'Y'
								AND ISNULL(eb.isDeleted, 'N') = 'N'
								AND ISNULL(bm.isActive, 'N') = 'Y'
								AND ISNULL(bm.isDeleted, 'N') = 'N'
								AND ISNULL(eb.isBlocked,'N') = 'N'
								AND bm.mapCodeInt IS NOT NULL

							UNION ALL

							SELECT 
								eb.extBankId, bankName, branchMapCode = bm.mapCodeInt, branchName = bm.agentName 
							FROM dbo.externalBank eb WITH(NOLOCK) 
							INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON eb.internalCode = am.agentId
							INNER JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId
							WHERE am.agentType = 2905
								AND ISNULL(am.actAsBranch, 'N') = 'N' 
								AND ISNULL(am.isActive, 'N') = 'Y' 
								AND ISNULL(am.isDeleted, 'N') = 'N'
								AND ISNULL(eb.isDeleted, 'N') = 'N'
								AND ISNULL(bm.isActive, 'N') = 'Y'
								AND ISNULL(bm.isDeleted, 'N') = 'N'
								AND ISNULL(eb.isBlocked,'N') = 'N'
								AND bm.mapCodeInt IS NOT NULL
						) xx			
				)x
		)x  WHERE row_Id BETWEEN (@pageFrom -1) * @pageSize + 1 AND @pageTo * @pageSize
			ORDER BY bankName, branchName
							
	END

	UPDATE #params SET 
		 ReportTitle='MapCode Report'
		,Filters= 'MapCode System=' +CASE WHEN @mapCodeFormat='N' THEN 'NEW SYSTEM' ELSE 'OLD SYSTEM' END
		,NoHeader = CASE WHEN @pageFrom > 1 THEN 1 ELSE 0 END		
		,IncludeSerialNo=1
		,PageNumber=@pageFrom
		,PageSize=@pageSize
		,LoadMode = 3	

	SELECT * FROM #params

	RETURN
END

IF @flag ='rpt'
BEGIN
	SELECT 
		 [Bank ID] =  extBankId
		,[Bank Name] = bankName
		,[Branch MapCode] = branchMapCode		
		,[Branch Name] = branchName		
		,[Is Head Office] = case when isHeadOffice	 ='Y' then 'Yes' else '' end	
	FROM (		
		SELECT 
			ROW_NUMBER() OVER (ORDER BY extBankId ASC) row_Id		
			,*
		FROM 
		(
			SELECT * FROM 
			(
				SELECT eb.extBankId, bankName, branchMapCode = ebb.extBranchId, branchName ,ebb.isHeadOffice
				FROM dbo.externalBank eb WITH(NOLOCK) 
				LEFT JOIN dbo.externalBankBranch ebb WITH(NOLOCK) ON eb.extBankId = ebb.extBankId
				WHERE internalCode IN (
				SELECT agentId FROM dbo.agentMaster WITH(NOLOCK) 
					WHERE agentType IN (2903) 
						AND ISNULL(actAsBranch, 'N') = 'N' 
						AND ISNULL(isActive, 'N') = 'Y' 
						AND ISNULL(isDeleted, 'N') = 'N'
				)
				AND eb.extBankId = ISNULL(@bankId,eb.extBankId)
				AND ISNULL(eb.isDeleted, 'N') = 'N'
				AND ISNULL(ebb.isDeleted, 'N') = 'N'
				AND ISNULL(eb.isBlocked,'N') = 'N'
				AND ISNULL(ebb.isBlocked,'N') = 'N'
				

				UNION ALL

				SELECT eb.extBankId, bankName, branchMapCode = ebb.extBranchId, branchName ,ebb.isHeadOffice
				FROM dbo.externalBank eb WITH(NOLOCK) 
				LEFT JOIN dbo.externalBankBranch ebb WITH(NOLOCK) ON eb.extBankId = ebb.extBankId
				WHERE internalCode IN (
				SELECT agentId FROM dbo.agentMaster WITH(NOLOCK) 
					WHERE agentType IN (2905) 
						AND ISNULL(actAsBranch, 'N') = 'N' 
						AND ISNULL(isActive, 'N') = 'Y' 
						AND ISNULL(isDeleted, 'N') = 'N'
				)
				AND eb.extBankId = ISNULL(@bankId,eb.extBankId)
				AND ISNULL(eb.isDeleted, 'N') = 'N'
				AND ISNULL(ebb.isDeleted, 'N') = 'N'
				AND ISNULL(eb.isBlocked,'N') = 'N'
				AND ISNULL(ebb.isBlocked,'N') = 'N'
			) xx			
		) x 
	)x ORDER BY bankName, branchName	

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
					
	SELECT 'Bank Name' head,CASE WHEN @bankId IS NULL THEN 'All' ELSE (SELECT bankName FROM dbo.externalBank WITH(NOLOCK) WHERE extBankId = @bankId) END VALUE

	SELECT 'Bank & Branch List' title

	RETURN
END 


GO
