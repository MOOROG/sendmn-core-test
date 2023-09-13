SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER  PROC [dbo].[proc_autocomplete] (
	 @category VARCHAR(50) 
	,@searchText VARCHAR(50) 
	,@param1 VARCHAR(50) = NULL
	,@param2 VARCHAR(50) = NULL
	,@param3 VARCHAR(50) = NULL	
)
AS

DECLARE @SQL AS VARCHAR(MAX)
IF @category = 'user'
BEGIN
	DECLARE @branchList TABLE(branchId INT)
	
	IF @param1 IS NULL					
		BEGIN
			INSERT INTO @branchList
				SELECT 
				agentId
			  FROM agentMaster
			  WHERE agentType = '2904' 
			   AND parentId = @param2
			   AND ISNULL(isDeleted, 'N') <> 'Y'
			   AND ISNULL(isActive, 'N') = 'Y'
		END
	
	IF @param1 IS NULL AND @param2 IS NULL
		BEGIN
			SELECT TOP 20
				userID,
				userName
			FROM applicationUsers
			WHERE userName LIKE ISNULL(@searchText, '') + '%'
			AND ISNULL(isDeleted,'N' )<> 'Y'
			AND ISNULL(isActive, 'N') = 'Y'
			ORDER BY userName ASC
			RETURN
		END
		
	IF @param1 IS NOT NULL AND @param2 IS NOT NULL
		BEGIN
			INSERT INTO @branchList
				SELECT @param1
		END
		
	SELECT TOP 20
		  userID,
		  userName
	 FROM applicationUsers
	 WHERE userName LIKE ISNULL(@searchText, '') + '%'
	 AND agentId  IN (SELECT branchId FROM @branchList)
	 ORDER BY userName ASC
	RETURN
END

IF @category = 'menuSearchAdmin'
BEGIN
	IF @param1 = 'admin'
	BEGIN
	    SELECT TOP 20 linkPage, menuName FROM dbo.applicationMenus WITH(NOLOCK) WHERE AgentMenuGroup IS NULL
		AND menuName LIKE ISNULL(@searchText, '') + '%'
	END
	ELSE
	BEGIN
        SELECT TOP 20 AM.linkPage ,
                AM.menuName
        FROM    dbo.applicationUserRoles AR WITH(NOLOCK)
                INNER JOIN dbo.applicationRoleFunctions AF WITH(NOLOCK) ON AF.roleId = AR.roleId
                INNER JOIN dbo.applicationMenus AM WITH(NOLOCK) ON AM.functionId = AF.functionId
                INNER JOIN dbo.applicationUsers AU WITH(NOLOCK) ON AU.userId = AR.userId
        WHERE   AU.userName = @param1
                AND AM.AgentMenuGroup IS NULL
				AND menuName LIKE ISNULL(@searchText, '') + '%';
	END
    
END
IF @category='agentRatingList'
BEGIN
  SELECT TOP 20 agentId,agentName FROM agentlistriskprofile 
  WHERE 
  agentName LIKE ISNULL(@searchText, '') + '%'
  ORDER BY agentName ASC
  RETURN
END
IF @category = 'menuSearchAgent'
BEGIN
        SELECT TOP 20 AM.linkPage ,
            AM.menuName
    FROM    dbo.applicationUserRoles AR WITH(NOLOCK)
            INNER JOIN dbo.applicationRoleFunctions AF WITH(NOLOCK) ON AF.roleId = AR.roleId
            INNER JOIN dbo.applicationMenus AM WITH(NOLOCK) ON AM.functionId = AF.functionId
            INNER JOIN dbo.applicationUsers AU WITH(NOLOCK) ON AU.userId = AR.userId
    WHERE   AU.userName = @param1
            AND AM.AgentMenuGroup IS NOT NULL
			AND menuName LIKE ISNULL(@searchText, '') + '%';
END

IF @category = 'users'
BEGIN

	IF @param1 IS NOT NULL 
	BEGIN
		SELECT TOP 20
		userID,
		userName
		FROM applicationUsers WITH(NOLOCK)
		WHERE userName LIKE ISNULL(@searchText, '') + '%'
		AND agentId = @param1
		AND ISNULL(isDeleted,'N' )<> 'Y'
		AND ISNULL(isActive, 'N') = 'Y'
		ORDER BY userName ASC
		RETURN
	END
	
	SELECT TOP 20
		userID,
		userName
	FROM applicationUsers WITH(NOLOCK)
	WHERE userName LIKE ISNULL(@searchText, '') + '%'
	AND ISNULL(isDeleted,'N' )<> 'Y'
	AND ISNULL(isActive, 'N') = 'Y'
	ORDER BY userName ASC
	
	RETURN
END

IF @category = 'country'
BEGIN
	SELECT TOP 20
		countryId,
		countryName
	FROM countryMaster 
	WHERE countryName LIKE ISNULL(@searchText, '') + '%'
	AND ISNULL(isOperativeCountry,'')='Y'
	ORDER BY countryName ASC
	
	RETURN
END

IF @category = 'countryOp'
BEGIN
	SELECT TOP 20
		countryId,
		countryName
	FROM countryMaster 
	WHERE countryName LIKE ISNULL(@searchText, '') + '%'
	ORDER BY countryName ASC
	
	RETURN
END

IF @category = 'countrySend'
BEGIN
	
	SELECT TOP 20
		countryId,
		countryName
	FROM countryMaster 
	WHERE countryName LIKE ISNULL(@searchText, '') + '%'
	AND ISNULL(isOperativeCountry,'') = 'Y'
	AND ISNULL(operationType,'B') IN ('B','S','R') 
	ORDER BY countryName ASC
	RETURN
END

IF @category = 'countryPay'
BEGIN
	SELECT TOP 20
		countryId,
		countryName
	FROM countryMaster 
	WHERE countryName LIKE ISNULL(@searchText, '') + '%'
	AND ISNULL(isOperativeCountry,'') = 'Y'
	AND ISNULL(operationType,'B') IN ('B','R') 
	ORDER BY countryName ASC	
	RETURN
END
IF @category = 'branch'
BEGIN
	SELECT TOP 20
		agentId,
		agentName
	FROM agentMaster
	WHERE agentType = '2904' 
	AND parentId = @param1
	AND ISNULL(isDeleted, 'N') <> 'Y'
	AND agentName LIKE ISNULL(@searchText, '') + '%'
	ORDER BY agentName ASC	
	RETURN
END

IF @category = 'branchExt' -- branch filter external or internal
BEGIN
	
	IF RIGHT(@param1,1) = 'I'
	BEGIN
		SELECT TOP 20
			agentId,
			agentName
		FROM agentMaster
		WHERE agentType = '2904' 
		AND parentId = LEFT(@param1,LEN(@param1)-1)
		AND ISNULL(isDeleted, 'N') <> 'Y'
		AND agentName LIKE ISNULL(@searchText, '') + '%'
		ORDER BY agentName ASC	
		RETURN
	END
	IF RIGHT(@param1,1) = 'E'
	BEGIN
		SELECT TOP 20
			ebb.extBranchId agentId
				,branchName agentName
		FROM externalBank eb
		LEFT JOIN externalBankBranch ebb ON eb.extBankId=ebb.extbankid
		WHERE eb.extBankId = LEFT(@param1,LEN(@param1)-1)
		AND ebb.branchName LIKE ISNULL(@searchText, '') + '%'
		ORDER BY branchName 
		RETURN
	END
END

IF @category = 'agentWiseUser'   -- --@author:bibash; Select branch user according to the branch parent
BEGIN	
	
	IF @param1 IS NOT NULL AND @param2 IS NULL
	BEGIN
		SELECT TOP 20
		userID,
		userName
		FROM applicationUsers au WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId= au.agentId  
		WHERE userName LIKE ISNULL(@searchText, '') + '%'
		AND am.parentId = @param1
		AND ISNULL(au.isDeleted,'N' )<> 'Y'
		AND ISNULL(au.isActive, 'N') = 'Y'
		ORDER BY userName ASC
		RETURN	
	END
	ELSE IF @param2 IS NOT NULL AND @param1 IS NULL
	BEGIN
	  SELECT TOP 20
		userID,
		userName
		FROM applicationUsers au WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId= au.agentId  
		WHERE userName LIKE ISNULL(@searchText, '') + '%'
		AND am.agentCountryId = @param2
		AND ISNULL(au.isDeleted,'N' )<> 'Y'
		AND ISNULL(au.isActive, 'N') = 'Y'
		ORDER BY userName ASC 
		RETURN
	 END	 
	ELSE
	BEGIN
	  SELECT TOP 20
		userID,
		userName
		FROM applicationUsers au WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId= au.agentId  
		WHERE userName LIKE ISNULL(@searchText, '') + '%'
		AND am.parentId = @param1
		AND am.agentCountryId = @param2
		AND ISNULL(au.isDeleted,'N' )<> 'Y'
		AND ISNULL(au.isActive, 'N') = 'Y'
		ORDER BY userName ASC 
		RETURN
	 END
END

IF @category = 's-r-agent'						-- sending / receiving agent according to sending /receiving country
BEGIN
	SELECT TOP 20
		agentId,
		agentName
	FROM agentMaster
	WHERE agentType = '2903' 
	AND ISNULL(isDeleted, 'N') <> 'Y'
	AND agentName LIKE ISNULL(@searchText, '') + '%'
	AND agentCountryId = @param1
	ORDER BY agentName ASC
	RETURN
END

IF @category = 'agent'
BEGIN
	SELECT TOP 20 a.agentId,agentName agentName 
	FROM 
	(
		SELECT  
			agentId,
			agentName+ISNULL('(' + b.districtName + ')', '') agentName
		FROM agentMaster a WITH(NOLOCK) 
		LEFT JOIN api_districtList b WITH(NOLOCK) ON a.agentLocation = b.districtCode
		WHERE 
		----(actAsBranch = 'Y' OR agentType = 2904) AND
			 ISNULL(a.isDeleted, 'N') = 'N'
			AND ISNULL(a.isActive, 'N') = 'Y'
			AND ISNULL(agentBlock,'U') <>'B'
			and a.parentId not IN (1543,5006)
	)A WHERE A.agentName LIKE '%'+ ISNULL(@searchText, '') + '%'
	ORDER BY A.agentName
	RETURN
END

IF @category = 'all-agent'
BEGIN
	SELECT TOP 20
		agentId,
		agentName
	FROM agentMaster
	WHERE agentName LIKE ISNULL(@searchText, '') + '%'
	AND agentCountry = 'Nepal'
	AND ISNULL(isDeleted, 'N') = 'N'
	AND ISNULL(isActive, 'N') = 'Y'
	ORDER BY agentName ASC
	RETURN
END


IF @category = 'adminUser'
BEGIN
	SELECT TOP 20
		userID,
		userName
	FROM applicationUsers
	WHERE userName LIKE ISNULL(@searchText, '') + '%'
	AND userType = 'HO'
	ORDER BY userName ASC
	
	RETURN
END

IF @category = 'internalBranch'					   -- --@author:bibash; Select  internal branchName 
BEGIN
	SELECT TOP 20 branch.agentId, branch.agentName FROM agentMaster agent WITH(NOLOCK)
	INNER JOIN agentMaster branch WITH(NOLOCK) ON  branch.parentId= agent.agentId
	WHERE ISNULL(branch.isDeleted, 'N') <> 'Y'
	AND branch.agentType = '2904' AND agent.isInternal ='Y'
	AND branch.agentName LIKE ISNULL(@searchText, '') + '%'
	ORDER BY  branch.agentName ASC
RETURN	
END
--EXEC proc_autocomplete @category='benBankByCountryName', @searchText='PRIME', @param1='Bangladesh'

IF @category = 'benBankByCountryName'		-->> Beneficiary Bank  By Country Name
BEGIN
	SET @SQL = 'SELECT TOP 20 * FROM 
	(
		SELECT agentId bankId,agentName+'' (Bank)'' BankName
		FROM agentMaster WITH(NOLOCK)  WHERE agentType=2903 AND agentCountry = '''+@param1+'''
		UNION ALL
		SELECT extBankId bankId,bankName+'' (Ext. Bank)'' BankName
		FROM externalBank WITH(NOLOCK) WHERE country = '''+@param1+'''
		AND isnull(internalCode,'''') NOT IN (SELECT agentid FROM agentMaster WITH(NOLOCK) WHERE agentType=2903 AND agentCountry = '''+@param1+''')
	)x WHERE BankName LIKE ''%'+@searchText+'%'''

	SET @SQL = @SQL+ ' ORDER BY  BankName ASC'
PRINT(@SQL);
	EXEC(@SQL)
END

IF @category = 'sendAgentByCountryName'		-->> Sending Agent By Country Name 
BEGIN
	 
	SET @SQL = 'SELECT TOP 20 agentId, agentName 
	FROM agentMaster WITH(NOLOCK)
	WHERE agentName LIKE ''%'+@searchText+'%'''
	
	IF @param1 IS NOT NULL
		SET @SQL = @SQL + ' AND agentCountry = '''+@param1+''''
	
	SET @SQL = @SQL+ ' ORDER BY  agentName ASC'
	
	EXEC(@SQL)
	
END

IF @category = 'value'							-- Select Values of ColumnName Accroding to TableName 
BEGIN
	SET @SQL = 'SELECT TOP 20 ' +@param2+ ' id, ' +@param2+ ' FROM ' + @param1 + ' WITH(NOLOCK) WHERE ' +@param2+' LIKE '''+@searchText+'%'' ORDER BY ''' + @param2 +''' ASC'
	PRINT @SQL
	EXEC (@SQL)
	RETURN

END

IF @category = 'allBranch'					    --@author:bibash; Select all branch name
BEGIN
	SELECT TOP 20 branch.agentId, branch.agentName FROM agentMaster agent WITH(NOLOCK)
	INNER JOIN agentMaster branch WITH(NOLOCK) ON  branch.parentId= agent.agentId
	WHERE ISNULL(branch.isDeleted, 'N') <> 'Y'
	AND branch.agentType = '2904'
	AND branch.agentName LIKE ISNULL(@searchText, '') + '%'
	ORDER BY  branch.agentName ASC
RETURN	
END

IF @category = 'pbranchByAgent'		-- Select branchName List According to AgentName By pralhad
BEGIN
	DECLARE @branchSelection VARCHAR(50)
	SELECT @branchSelection=ISNULL(branchSelection,'A') FROM receiveTranLimit WHERE agentId = @param1
	
	SELECT TOP 20
		agentId [serviceTypeId],
		agentName [typeTitle],@branchSelection [branchSelection]
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2904'
	AND am.parentId = @param1
	AND agentName LIKE @searchText+'%'
	ORDER BY agentName ASC
	RETURN	
END

IF @category = 'internalAgentByExtBankId' -->> Selecting Agent by External Bank Id
BEGIN
	DECLARE @countryId INT,@countryName AS VARCHAR(200)
	SELECT @countryName = country FROM externalBank WITH(NOLOCK) WHERE extBankId=@param1
	SELECT @countryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName=@countryName
	SELECT a.agentId,a.agentName FROM agentMaster a WITH(NOLOCK) INNER JOIN
	(
		SELECT agentId FROM receiveTranLimit WITH(NOLOCK) WHERE countryId=ISNULL(@countryId,countryId) AND tranType='3'
	)b ON a.agentId=b.agentId
	WHERE ISNULL(a.isDeleted, 'N') <> 'Y'
	AND a.agentName LIKE ISNULL(@searchText, '') + '%'
	RETURN
END

IF @category = 'agent-a'
BEGIN
	SELECT TOP 20
		 am.agentId
		,am.agentName
		,am.agentLocation
		,am.agentCountry
		,COALESCE(am.agentMobile1, am.agentMobile2, am.agentPhone1, am.agentPhone2)  Phone
		,pa.agentName parentName
	FROM agentMaster am WITH(NOLOCK)
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON am.parentId = pa.agentId 
	WHERE am.agentId = @searchText
	RETURN
END
IF	@category='allBank'
BEGIN
	SELECT TOP 20
		bankId = extBankId,
		bankName 
	FROM externalBank 
	WHERE internalCode IS NOT NULL
	RETURN
END

IF	@category='ime-private-agent'
BEGIN
	--SELECT TOP 20 a.agentId,agentName+'|'+CAST(agentId AS VARCHAR) agentName 
	--FROM 
	--(
	--	SELECT  agentId,agentName+' '+b.districtName agentName
	--	FROM agentMaster a WITH(NOLOCK) 
	--	LEFT JOIN api_districtList b WITH(NOLOCK) ON a.agentLocation=b.districtCode
	--	WHERE       actAsBranch = 'Y' 
	--			AND agentType = 2903
	--			AND ISNULL(a.isDeleted, 'N') = 'N'
	--			--AND ISNULL(a.isActive, 'N') = 'Y'
	--			OR (agentType = 2904 and parentId = 4618)
	--			OR (agentType = 2904 and parentId = 21107)
	--			OR (agentType = 2904 and parentId = 22194)
	--			OR a.agentId = 1194
	--			--OR (a.agentId = 20653)
	--			OR (agentType = 2904)	
	--)A WHERE A.agentName LIKE '%'+@searchText+'%' ORDER BY A.agentName


	SELECT TOP 20 a.agentId,agentName+'|'+CAST(agentId AS VARCHAR) agentName 
	FROM 
	(
		SELECT  agentId,agentName+' '+b.districtName agentName
		FROM agentMaster a WITH(NOLOCK) 
		LEFT JOIN api_districtList b WITH(NOLOCK) ON a.agentLocation=b.districtCode
		WHERE       
				agentGrp <> '4301'
				AND ISNULL(a.isDeleted, 'N') = 'N'
				AND (
						(agentType = 2903 AND actAsBranch = 'Y')					
						OR agentType = 2904
				)
	)A WHERE A.agentName LIKE '%'+@searchText+'%' ORDER BY A.agentName



END

IF	@category='domestic-agent'
BEGIN
	SELECT TOP 20 a.agentId,agentName+'|'+CAST(agentId AS VARCHAR) agentName 
	FROM 
	(
		SELECT  agentId,agentName+' '+b.districtName agentName
		FROM agentMaster a WITH(NOLOCK) LEFT JOIN api_districtList b WITH(NOLOCK)
		ON a.agentLocation=b.districtCode
		WHERE   agentType = 2903
				AND ISNULL(a.isDeleted, 'N') = 'N'
				AND ISNULL(a.isActive, 'N') = 'Y'
	)A WHERE A.agentName LIKE '%'+@searchText+'%' ORDER BY A.agentName

END
IF @category='CountryAgentLogin'
BEGIN
	SELECT TOP 20
	  agentId,
	  agentName
	 FROM agentMaster
	 WHERE agentName LIKE ISNULL(@searchText, '') + '%'
	 AND agentCountryId = @param1
	 AND ISNULL(isDeleted, 'N') = 'N'
	 AND ISNULL(isActive, 'N') = 'Y'
	 ORDER BY agentName ASC
	 RETURN
END
IF @category='CountryAgentTxn'
BEGIN
	SELECT TOP 20
	  agentId,
	  agentName
	 FROM agentMaster
	 WHERE agentName LIKE ISNULL(@searchText, '') + '%'
	 AND agentCountry = @param1
	 AND ISNULL(isDeleted, 'N') = 'N'
	 AND ISNULL(isActive, 'N') = 'Y'
	 ORDER BY agentName ASC
	 RETURN
END
IF @category='AgentUser'
BEGIN
	 SELECT TOP 20
	  userId,
	  userName
	 FROM applicationUsers
	 WHERE userName LIKE ISNULL(@searchText, '') + '%'
	 AND agentId = @param1
	 AND ISNULL(isDeleted, 'N') = 'N'
	 AND ISNULL(isActive, 'N') = 'Y'
	 ORDER BY userName ASC
	 RETURN
END

-------->>>>For transaction Analysis Report--------->>>>
IF @category='zoneRpt'
BEGIN
	 SELECT top 20
			 stateId
			,stateName 
		FROM countryStateMaster a WITH(NOLOCK) 
		inner join countryMaster b with(nolock) on a.countryId=b.countryId
		WHERE (b.countryName = @param1 or b.countryId=@param1) 
			AND stateName like '%'+@searchText+'%'
			AND ISNULL(A.isDeleted, 'N') <> 'Y'
		ORDER BY stateName
	 RETURN
END

IF @category='districtRpt'
BEGIN
	SELECT top 20
			districtId
		,districtName 
	FROM zoneDistrictMap WITH(NOLOCK) 
	WHERE zone = isnull(@param1,zone)
	AND ISNULL(isDeleted, 'N') <> 'Y' 
	AND districtName like '%'+@searchText+'%'
	ORDER BY districtName
	 RETURN
END

IF @category='locationRpt'
BEGIN
	 SELECT  DISTINCT top 20
			 locationId		= districtCode
			,locationName	= districtName
		FROM api_districtList adl WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
		WHERE ISNULL(isDeleted, 'N') = 'N' 
			AND ISNULL(adl.isActive,'Y')='Y'
			AND alm.districtId = ISNULL(@param1, alm.districtId) 
			AND districtName like '%'+@searchText+'%' 
		ORDER BY districtName
	 RETURN
END

IF @category='agentRpt'
BEGIN
	SELECT top 20
			 agentId
			,agentName 
		FROM agentMaster with(nolock) 
		WHERE agentType = 2903 
			AND agentCountry='Nepal'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			--AND ISNULL(isActive, 'N') = 'Y'	
			AND ISNULL(agentBlock,'U') <>'B'
			AND agentName like '%'+@searchText+'%' 
			AND agentGrp = isnull(@param1,agentGrp)
		ORDER BY agentName
	 RETURN
END

IF @category='agentdistRpt'
BEGIN
	SELECT top 20
			 agentId
			,agentName 
		FROM agentMaster with(nolock) 
		WHERE agentType = 2903 
			AND agentCountry='Nepal'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			--AND ISNULL(isActive, 'N') = 'Y'	
			AND ISNULL(agentBlock,'U') <>'B'
			AND agentName like '%'+@searchText+'%' 
			AND agentDistrict = isnull(@param1,agentDistrict)
		ORDER BY agentName
	 RETURN
END



IF @category='branchRpt'
BEGIN
	 select top 20
		  agentId
		 ,agentName 
	 from agentMaster with (nolock) 
	 where parentId = @param1 
		AND agentName LIKE '%'+@searchText+'%'
		AND ISNULL(agentBlock,'U') <>'B'
	 RETURN
END

IF @category='countryRptInt'
BEGIN	 
	 select top 20
	  countryId
	 ,countryName 
	 from countryMaster with(nolock) where countryName like '%'+@searchText+'%'
	 RETURN
END

IF @category='agentRptInt'
BEGIN	 
	 SELECT top 20
			 agentId
			,agentName 
		FROM agentMaster 
		WHERE ISNULL(isSettlingAgent, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			--AND ISNULL(isActive, 'N') = 'Y'	
			AND ISNULL(agentBlock,'U') <>'B'
			AND agentName like '%'+@searchText+'%' 
			AND (agentCountry <> 'Nepal' or agentId = 4734)
			AND agentCountryId = isnull(@param1,agentCountryId)
		ORDER BY agentName 
	 RETURN
END

IF @category='branchRptInt'
BEGIN	 
	 select top 20
		  agentId
		 ,agentName 
	 from agentMaster with (nolock) 
	 where parentId=@param1 
		AND agentName LIKE '%'+@searchText+'%' 
		AND parentId = @param1
		--AND ISNULL(isDeleted, 'N') <> 'Y'
		AND ISNULL(isActive, 'N') = 'Y'	
		AND ISNULL(agentBlock,'U') <>'B'
	 RETURN
END


IF @category='send-agent'
BEGIN	 
	SELECT TOP 20 map_code,agent_name
	FROM SendMnPro_Account.dbo.agentTable with(nolock)
        WHERE agent_status<>'n' AND AGENT_TYPE='receiving' 
        AND (IsMainAgent ='y' OR ISNULL(central_sett,'n') ='n') 
		AND	agent_name like '%'+@searchText+'%'
		ORDER BY agent_name
	 RETURN
END

IF @category = 'agentSummBal' -->>Agent summary Balance Rpt Ddl
BEGIN

	SELECT TOP 20
		 mapcodeInt
		,agentName
	FROM agentMaster am WITH(NOLOCK) 
	where agentName like '%'+@searchText+'%' 
		and mapcodeInt is not null 
		AND ISNULL(agentBlock,'U') <>'B'
	order by agentName asc
	RETURN	
 END 

IF @category = 'd-agentname-only'  
BEGIN
	SELECT TOP 20
		agentName 
	FROM agentMaster a WITH(NOLOCK) 
	WHERE agentCountry = 'Nepal'
	AND (actAsBranch = 'Y' OR agentType = 2904)
	AND ISNULL(a.isDeleted, 'N') = 'N'
	--AND ISNULL(a.isActive, 'N') = 'Y'
	AND ISNULL(agentBlock,'U') <>'B'
	AND A.agentName LIKE '%'+@searchText+'%' 
	ORDER BY A.agentName
END
IF @category = 'd-agent-only'  
BEGIN
		SELECT TOP 20 a.agentId,agentName  
		FROM 
		(
			SELECT  agentId,agentName+' '+b.districtName agentName
			FROM agentMaster a WITH(NOLOCK) 
			LEFT JOIN api_districtList b WITH(NOLOCK) ON a.agentLocation=b.districtCode
			WHERE  agentCountry = 'Nepal'
				AND (actAsBranch = 'Y' OR agentType = 2904)
				AND ISNULL(a.isDeleted, 'N') = 'N'
				--AND ISNULL(a.isActive, 'N') = 'Y'
				AND ISNULL(agentBlock,'U') <>'B'
		)A WHERE A.agentName LIKE '%'+@searchText+'%' ORDER BY A.agentName
END


---->>>>>For Customer report

IF @category='sAgent'
BEGIN
	SELECT top 20
			 agentId
			,agentName 
		FROM agentMaster with(nolock) 
		WHERE agentType = 2903 
			AND agentCountry='Nepal'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			--AND ISNULL(isActive, 'N') = 'Y'	
			AND ISNULL(agentBlock,'U') <>'B'
			AND agentName like '%'+@searchText+'%' 
			AND agentState =isnull(@param1,agentState)
		ORDER BY agentName
	 RETURN
END

IF @category = 'sZone'  
BEGIN
 SELECT top 20
			 stateId
			,stateName 
		FROM countryStateMaster a WITH(NOLOCK) 
		inner join countryMaster b with(nolock) on a.countryId=b.countryId
		WHERE (b.countryName = 'Nepal' or b.countryId=151) 			
		AND ISNULL(A.isDeleted, 'N') <> 'Y'
		AND stateName  like '%'+@searchText+'%' 
		ORDER BY stateName
END

IF @category='send-agent-regional'
BEGIN	 
	SELECT TOP 20 map_code,agent_name
	FROM SendMnPro_Account.dbo.agentTable  at with(nolock) 
		INNER JOIN userZoneMapping zp WITH(NOLOCK) ON at.agentZone = zp.zoneName
        WHERE agent_status<>'n' 
		AND AGENT_TYPE='receiving' 
        AND (IsMainAgent ='y' OR ISNULL(central_sett,'n') ='n') 
		AND zp.userName = @param1
		AND	agent_name like '%'+@searchText+'%'
		and zp.isDeleted IS null
		ORDER BY agent_name
	 RETURN
END

-- ## regional transaction analysis report
IF @category='zone-r-rpt'
BEGIN
	 SELECT TOP 20
			 stateId
			,stateName 
		FROM countryStateMaster a WITH(NOLOCK) 
		inner join countryMaster b with(nolock) on a.countryId=b.countryId
		inner JOIN dbo.userZoneMapping zm WITH(nolock) ON a.stateName = zm.zoneName
		WHERE (b.countryName = @param1 or b.countryId=@param1) 
			AND stateName like '%'+@searchText+'%'
			AND ISNULL(A.isDeleted, 'N') <> 'Y'
			AND zm.userName = @param2
			AND zm.isDeleted IS null
		ORDER BY stateName
	 RETURN
END

IF @category='district-r-rpt'
BEGIN
	SELECT top 20
		 districtId
		,districtName 
	FROM zoneDistrictMap d WITH(NOLOCK) 
	INNER JOIN countryStateMaster z WITH(NOLOCK) ON d.zone = z.stateId
	INner JOIN dbo.userZoneMapping zm WITH(NOLOCK) ON z.stateName = zm.zoneName
	WHERE d.zone = isnull(@param1,d.zone)
	AND ISNULL(d.isDeleted, 'N') <> 'Y' 
	AND d.districtName like '%'+@searchText+'%'
	AND zm.userName = @param2
	AND zm.isDeleted IS NULL
	ORDER BY districtName
	RETURN
END

IF @category='location-r-rpt'
BEGIN
		SELECT DISTINCT
			 locationId		= adl.districtCode
			,locationName	= adl.districtName
		FROM api_districtList adl WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
		LEFT JOIN zoneDistrictMap d WITH(NOLOCK) ON alm.districtId = d.districtId
		LEFT JOIN countryStateMaster z WITH(NOLOCK) ON d.zone = z.stateId
		LEFT JOIN dbo.userZoneMapping zm WITH(NOLOCK) ON z.stateName = zm.zoneName
		WHERE ISNULL(adl.isDeleted, 'N') = 'N' 
			AND ISNULL(adl.isActive,'Y')='Y'
			AND alm.districtId = ISNULL(@param1, alm.districtId) 
			AND adl.districtName like '%'+@searchText+'%' 
			AND zm.userName = @param2
            AND zm.isDeleted IS NULL
		ORDER BY adl.districtName
	 RETURN
END

IF @category='agent-r-rpt'
BEGIN
	SELECT top 20
			 agentId
			,agentName 
		FROM agentMaster am with(nolock) 
		INNER JOIN dbo.userZoneMapping zm WITH(NOLOCK) ON am.agentState = zm.zoneName
		WHERE agentType = 2903 
			AND agentCountry='Nepal'
			AND ISNULL(am.isDeleted, 'N') <> 'Y'
			AND ISNULL(agentBlock,'U') <>'B'
			AND agentName like '%'+@searchText+'%' 
			AND agentLocation = isnull(@param1,agentLocation)
			and zm.userName = @param2
            AND zm.isDeleted IS NULL
		ORDER BY agentName
	 RETURN
END

IF @category='branch-r-rpt'
BEGIN
	 select top 20
		  agentId
		 ,agentName 
	 from agentMaster am with (nolock) 
	 INNER JOIN dbo.userZoneMapping zm WITH(NOLOCK) ON am.agentState = zm.zoneName
	 where am.parentId = @param1 
		and am.agentName like '%'+@searchText+'%'
		AND ISNULL(am.isDeleted, 'N') <> 'Y'
		AND ISNULL(agentBlock,'U') <>'B'
		and zm.userName = @param2
        AND zm.isDeleted IS null
	 RETURN
END
IF	@category='ext-bank'
BEGIN
	SELECT TOP 20
		bankId = extBankId,
		bankName 
	FROM externalBank ext
	WHERE ext.internalCode IS NOT NULL
		AND ISNULL(ext.isBlocked,'N') <> 'Y'
		AND ISNULL(ext.isDeleted,'N') <> 'Y'
		AND ext.bankName like '%'+@searchText+'%'
	RETURN
END

IF @category='agent-sett'
BEGIN	 
	SELECT TOP 20 am.agentId,am.agentName
	FROM agentMaster am WITH(NOLOCK) 
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND ISNULL(am.isActive, 'N') = 'Y'	
	AND	agentName like '%'+@searchText+'%'
	and agentType IN (2903) 
	AND agentCountry = 'Nepal'
	ORDER BY agentName
	RETURN
END
IF @category='agentList'
BEGIN
	select top 20
		  agentId
		 ,agentName 
	 from agentMaster am with (nolock) 
	 where agentName like '%'+@searchText+'%'
	 AND ISNULL(apiAgent, 'N') = 'N'
	 AND ISNULL(ISACTIVE, 'Y') = 'Y'
	 AND ISNULL(ISDELETED, 'N') = 'N'
	 RETURN
END

IF @category='zoneagendistrictRpt'
BEGIN
		IF @param1 is not null and @param2 is null
		BEGIN
			SELECT top 20
				 agentId
				,agentName 
			FROM agentMaster with(nolock) 
			WHERE (agentType = '2904' OR (agentType = 2903 AND actAsBranch = 'Y')) 
				AND agentCountry='Nepal'
				AND ISNULL(isDeleted, 'N') <> 'Y'
				--AND ISNULL(isActive, 'N') = 'Y'	
				AND ISNULL(agentBlock,'U') <>'B'
				AND agentName like '%'+@searchText+'%' 
				AND agentState =isnull(@param1,agentState)			
			ORDER BY agentName
			RETURN
		END
		
		IF @param2 is not null and @param1 is null
			BEGIN
				SELECT top 20
					 agentId
					,agentName 
				FROM agentMaster with(nolock) 
				WHERE (agentType = '2904' OR (agentType = 2903 AND actAsBranch = 'Y'))
					AND agentCountry='Nepal'
					AND ISNULL(isDeleted, 'N') <> 'Y'
					--AND ISNULL(isActive, 'N') = 'Y'	
					AND ISNULL(agentBlock,'U') <>'B'
					AND agentName like '%'+@searchText+'%' 
					AND agentDistrict =isnull(@param2,agentDistrict)			
				ORDER BY agentName
				RETURN
			END
		
		IF @param1 is not null and  @param2 is not null 
			BEGIN
				SELECT top 20
					 agentId
					,agentName 
				FROM agentMaster with(nolock) 
				WHERE (agentType = '2904' OR (agentType = 2903 AND actAsBranch = 'Y'))
					AND agentCountry='Nepal'
					AND ISNULL(isDeleted, 'N') <> 'Y'
					--AND ISNULL(isActive, 'N') = 'Y'	
					AND ISNULL(agentBlock,'U') <>'B'
					AND agentName like '%'+@searchText+'%'
					AND agentState =isnull(@param1,agentState)	 
					AND agentDistrict =isnull(@param2,agentDistrict)			
				ORDER BY agentName
				RETURN
			END
		
		SELECT top 20
			 agentId
			,agentName 
		FROM agentMaster with(nolock) 
		WHERE (agentType = '2904' OR (agentType = 2903 AND actAsBranch = 'Y'))
			AND agentCountry='Nepal'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			--AND ISNULL(isActive, 'N') = 'Y'	
			AND ISNULL(agentBlock,'U') <>'B'
			AND agentName like '%'+@searchText+'%' 			
		ORDER BY agentName

		
END
IF @category = 'cooperative' 
BEGIN
	SELECT TOP 20
			 agentId
			,agentName
			,agentType FROM agentMaster (NOLOCK) 
		WHERE (agentGrp='8026' OR agentGrp = '9906') AND agentType='2903'
		      AND ISNULL(isDeleted, 'N') <> 'Y'
		      AND agentName LIKE '%' + @searchText +'%' 
			  AND agentId<>@param1
		ORDER BY agentName ASC
END
IF @category = 'co-agent'						-- cooperative branch list
BEGIN
	IF EXISTS(select 'x' from agentMaster (NOLOCK) 	WHERE ISNULL(isDeleted, 'N') <> 'Y'	AND parentId=@param1) 
		BEGIN
			SELECT TOP 20
				 agentId
				,agentName
				,agentType
				,parentId FROM agentMaster (NOLOCK) 
			WHERE ISNULL(isDeleted, 'N') <> 'Y'				
				AND parentId=@param1 
			ORDER BY agentName ASC
			RETURN
		END
		ELSE
		BEGIN
			SELECT TOP 20
				 agentId
				,agentName
				,agentType
				,parentId FROM agentMaster (NOLOCK) 
			WHERE ISNULL(isDeleted, 'N') <> 'Y'			
				AND agentId=@param1
		    ORDER BY agentName ASC
			RETURN
		END	
END
IF @category='Reconcil-agent'
BEGIN
	SELECT TOP 20
			 agentId
			,agentName+'|'+CAST(agentId AS VARCHAR)
		 FROM agentMaster (NOLOCK) 
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		      AND agentName LIKE '%' + @searchText +'%' 			
		ORDER BY agentName ASC
END
ELSE IF @category='agentByGrp'
BEGIN
	Select TOP 20 agentId,agentName
	from dbo.agentMaster (NOLOCK)
	where agentName like @searchText + '%' 
	AND agentGrp = @param1
	order by agentName

END
ELSE IF @category='locationRpt'
BEGIN
	 SELECT  DISTINCT top 20
			 locationId		= districtCode
			,locationName	= districtName
		FROM api_districtList adl WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
		WHERE ISNULL(isDeleted, 'N') = 'N' 
			AND ISNULL(adl.isActive,'Y')='Y'
			AND alm.districtId = ISNULL(@param1, alm.districtId) 
			AND districtName like '%'+@searchText+'%' 
		ORDER BY districtName
	 RETURN
END
ELSE IF @category='cityList'
BEGIN
	select cityName,cityName from CityMaster(nolock)
	where cityName like '%'+@searchText+'%' 
END
ELSE IF @category='CustomerInfo'
BEGIN
	if len(@searchText)<2
	begin
		select top 35 idNumber,idNumber +' | '+fullName from CustomerMaster(nolock) where 1=2
		return
	end
	select top 35 idNumber,idNumber +' | '+fullName +' | '+ ISNULL(CONVERT(VARCHAR(10), DOB, 121),'')+' | '+isnull(mobile,'') +' | '+ isnull(zipcode,'')  
	from CustomerMaster(nolock)
	where idNumber like @searchText+'%' or fullName like @searchText+'%'
END
ELSE IF @category='CustomerEmail'
BEGIN
	if len(@searchText)<2
	begin
		select top 35 customerId,email +' | '+mobile from CustomerMaster(nolock) where 1=2
		return
	end
	select top 35 customerId,email +' | '+mobile from CustomerMaster(nolock)
	where email like @searchText+'%'
END
ELSE IF @category='CustomerInfoWallet'
BEGIN
	if len(@searchText)<2
	begin
		select top 35 walletAccountNo,walletAccountNo +' | '+fullName from CustomerMaster(nolock) where 1=2
		return
	end
	select top 35 walletAccountNo,walletAccountNo +' | '+fullName from CustomerMaster(nolock)
	where walletAccountNo like @searchText+'%' or fullName like @searchText+'%'
END
IF @category='searchCustomer'
BEGIN
	IF @param1 = 'receiverName'
	BEGIN
		IF LEN(@searchText) < 3
		BEGIN
			SELECT RECEIVERID, FULLNAME FROM  RECEIVERINFORMATION (NOLOCK) WHERE 1=2
			RETURN
		END
		SET @SQL = 'SELECT TOP 20 RI.RECEIVERID, [detail] = ISNULL(RI.firstName,'''') + ISNULL('' '' + RI.middleName,'''') + ISNULL('' '' + RI.lastName1,'''') + '' [CustomerName:'' + isnull(CM.FULLNAME, '''') + ''] [CustID: ''+ISNULL(isnull(postalCode, membershipid),customerId)+''] [MOB:'' + isnull(RI.mobile, '''') + ''] ''+ISNULL(''|''+RI.email,'''') 
					FROM receiverInformation RI (NOLOCK)
					INNER JOIN CUSTOMERMASTER CM ( NOLOCK) ON CM.CUSTOMERID = RI.CUSTOMERID 
					WHERE 1 = 1  '

		SET @SQL += 'AND RI.FULLNAME LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		PRINT @SQL
		EXEC(@SQL)
	END	
	ELSE
	BEGIN
	IF LEN(@searchText) < 3
		BEGIN
			SELECT CUSTOMERID, FULLNAME FROM  customerMaster (NOLOCK) WHERE 1=2
			RETURN
		END
	
		SET @SQL = 'SELECT TOP 20 customerId, [detail] = fullName + '' [ID:'' + ISNULL(isnull(postalCode, membershipid),customerId) + ''] [MOB:'' + isnull(mobile, '''') + ''] [DOB:'' + isnull(convert(varchar, DOB, 102), '''') + ''] ''+ISNULL(''|''+email,'''') 
				FROM customerMaster (NOLOCK) WHERE 1 = 1
				and isActive=''Y'' '
	
		IF @param1 = 'name'
		BEGIN
			SET @SQL += 'AND fullName LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'email'
		BEGIN
			SET @SQL += 'AND email LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'membershipId'
		BEGIN
			SET @SQL += 'AND membershipId LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'customerId'
		BEGIN
			SET @SQL += 'AND POSTALCODE = '''+ISNULL(@searchText, '''') + ''''
		END
		ELSE IF @param1 = 'membershipId'
		BEGIN
			SET @SQL += 'AND membershipId = '''+ISNULL(@searchText, '''') + ''''
		END
		ELSE IF @param1 = 'dob'
		BEGIN
			SET @SQL += 'AND CONVERT(VARCHAR(10), DOB, 121) = '''+ISNULL(@searchText, '''') + ''''
		END
		ELSE IF @param1 = 'mobile'
		BEGIN
			SET @SQL += 'AND mobile LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'idNumber'
		BEGIN
			SET @SQL += 'AND idNumber LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		PRINT(@SQL)
		EXEC(@SQL)
	END

	
END;
IF @category='searchCustomerForSendPage'
BEGIN
	IF LEN(@searchText) < 3
		BEGIN
			SELECT CUSTOMERID, FULLNAME FROM  customerMaster (NOLOCK) WHERE 1=2
			RETURN
		END
		SET @SQL = 'SELECT TOP 20 customerId, [detail] = fullName + '' [ID:'' + isnull(membershipid,CM.customerId) + ''] [MOB:'' + isnull(mobile, '''') + ''] [DOB:'' + isnull(convert(varchar, DOB, 102), '''') + ''] ''+ISNULL(''[''+email,'''')
					FROM customerMaster (NOLOCK) CM
					LEFT JOIN COUNTRYSTATEMASTER CSM (NOLOCK) ON CSM.STATEID = CM.STATE
					WHERE 1 = 1 AND CM.approvedDate IS NOT NULL '
		IF @param1 = 'name'
		BEGIN
			SET @SQL += 'AND fullName LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'email'
		BEGIN
			SET @SQL += 'AND email LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'membershipId'
		BEGIN
			SET @SQL += 'AND membershipId LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'mobile'
		BEGIN
			SET @SQL += 'AND mobile LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'customerId'
		BEGIN
			SET @SQL += 'AND postalCode = '''+ISNULL(@searchText, '''') + ''''
		END
		ELSE IF @param1 = 'dob'
		BEGIN
			SET @SQL += 'AND CONVERT(VARCHAR(10), DOB, 121) = '''+ISNULL(@searchText, '''') + ''''
		END
		ELSE IF @param1 = 'membershipId'
		BEGIN
			SET @SQL += 'AND membershipId = '''+ISNULL(@searchText, '''') + ''''
		END
		ELSE IF @param1 = 'idNumber'
		BEGIN
			SET @SQL += 'AND idNumber LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		PRINT(@SQL)
		EXEC(@SQL)
END;
IF @category='searchCustomerForLog'
BEGIN
	IF LEN(@searchText) < 3
		BEGIN
			SELECT CUSTOMERID, FULLNAME FROM  customerMaster (NOLOCK) WHERE 1=2
			RETURN
		END
		SET @SQL = 'SELECT TOP 20 customerId, [detail] = fullName + '' [ID:'' + isnull(obpId, customerId) + ''] [MOB:'' + isnull(mobile, '''') + ''] [DOB:'' + isnull(convert(varchar, DOB, 102), '''') + ''] ''+ISNULL(''|''+email,'''') 
					FROM customerMaster (NOLOCK) WHERE 1 = 1 AND approvedDate IS NOT NULL '
		IF @param1 = 'name'
		BEGIN
			SET @SQL += 'AND fullName LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'email'
		BEGIN
			SET @SQL += 'AND email LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'customerId'
		BEGIN
			SET @SQL += 'AND obpid LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'membershipId'
		BEGIN
			SET @SQL += 'AND membershipId LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'mobile'
		BEGIN
			SET @SQL += 'AND mobile LIKE ''%'+ISNULL(@searchText, '''') + '%'''
		END
		ELSE IF @param1 = 'dob'
		BEGIN
			SET @SQL += 'AND CONVERT(VARCHAR(10), DOB, 121) = '''+ISNULL(@searchText, '''') + ''''
		END
		--PRINT(@SQL)
		EXEC(@SQL)
END;
ELSE IF @category='referralCode'
BEGIN
	IF LEN(@searchText) >= 3
	BEGIN
		SELECT TOP 30 REFERRAL_CODE, REFERRAL_NAME 
		FROM REFERRAL_AGENT_WISE (NOLOCK)
		WHERE REFERRAL_CODE LIKE @searchText+'%' OR REFERRAL_NAME LIKE @searchText+'%' 
		AND IS_ACTIVE = 1
		--AND AGENT_ID = 0
		
		--AND REFERRAL_TYPE_CODE <> 'RB'
		RETURN;
	END
	SELECT TOP 30 REFERRAL_CODE, REFERRAL_NAME 
	FROM REFERRAL_AGENT_WISE (NOLOCK)
	WHERE 1=2
	RETURN;
END
ELSE IF @category='referralChange'
BEGIN
	IF LEN(@searchText) >= 3
	BEGIN
		SELECT TOP 30 REFERRAL_CODE, REFERRAL_NAME 
		FROM REFERRAL_AGENT_WISE (NOLOCK)
		WHERE REFERRAL_CODE LIKE @searchText+'%' OR REFERRAL_NAME LIKE @searchText+'%' 
		AND IS_ACTIVE = 1
		RETURN;
	END
	SELECT TOP 30 REFERRAL_CODE, REFERRAL_NAME 
	FROM REFERRAL_AGENT_WISE (NOLOCK)
	WHERE 1=2
	RETURN;
END

ELSE IF @category='CustomerName'
BEGIN
	IF LEN(@searchText) < 3
	BEGIN
		SELECT TOP 30 customerId, [detail] = fullName + '[' + isnull(idNumber, '') + '] | ' +ISNULL(email,'') 
		FROM customerMaster WITH (NOLOCK) WHERE 1=2
		RETURN
	END
	SELECT TOP 30 customerId, [detail] = fullName + '[' + isnull(idNumber, '') + '] | ' + ISNULL(email,'') 
	FROM customerMaster WITH (NOLOCK) 
	WHERE fullName LIKE @searchText+'%'
	RETURN
END
ELSE IF @category='ReceiverName'
BEGIN
	SELECT TOP 30*
	FROM (SELECT 
				receiverId, 
				fullname= firstName+ISNULL(' '+middleName,'')+ISNULL(' '+lastName1,'')+ISNULL(' '+lastName2,'') 
			FROM dbo.receiverInformation WITH (NOLOCK)
	)X
	WHERE X.fullname LIKE @searchText+'%'
	RETURN
END
ELSE IF @category = 'mapBankData'
BEGIN
	IF LEN(@searchText) < 3
	BEGIN
		SELECT TOP 30 ROW_ID, [detail] = BANK_NAME
		FROM API_BANK_LIST_TMP WITH (NOLOCK) WHERE 1=2
		RETURN
	END
	SELECT TOP 30 ROW_ID, [detail] = BANK_NAME + ISNULL(' | ' + BANK_CODE1, '')
	FROM API_BANK_LIST_TMP WITH (NOLOCK) 
	WHERE BANK_NAME LIKE '%' + @searchText+'%'
	RETURN
END
ELSE IF @category = 'CASHRPT'
BEGIN
	IF LEN(@searchText) < 3
	BEGIN
		SELECT TOP 30 ROW_ID, [detail] = REFERRAL_NAME
		FROM REFERRAL_AGENT_WISE WITH (NOLOCK) WHERE 1=2
		RETURN
	END
	SELECT TOP 30 REFERRAL_CODE, [detail] = REFERRAL_NAME
	FROM REFERRAL_AGENT_WISE WITH (NOLOCK) 
	WHERE REFERRAL_NAME LIKE '%' + @searchText+'%'
	AND REFERRAL_TYPE_CODE = 'RC'
	RETURN
END
--EXEC proc_autocomplete @category='CustomerName', @searchText='dham'
GO