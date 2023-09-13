
ALTER PROC [dbo].[proc_dropDownLists]
     @flag			VARCHAR(200)
    ,@param			VARCHAR(200)		= NULL
    ,@param1		VARCHAR(200)		= NULL
    ,@user			VARCHAR(30)			= NULL
    ,@branchId		INT					= NULL
    ,@country		VARCHAR(50)			= NULL
    ,@agentId		VARCHAR(50)			= NULL
    ,@countryId		INT					= NULL
    ,@countryName   VARCHAR(100)		= NULL
    ,@userType		VARCHAR(20)			= NULL
    ,@groupId		INT					= NULL
AS
SET NOCOUNT ON;

IF @flag = 'cal'							--@author:bijay; Populate Agent according to country
BEGIN

    SELECT 
	   agentId, 
	   agentName 
	FROM agentMaster WITH (NOLOCK)
    WHERE agentCountry=@param 
    AND agentType='2903'
    AND ISNULL(agentBlock,'U') <>'B'
    ORDER BY agentName	
    RETURN;
END

IF @flag = 'alc'							--@author:bijay; Select Agent According to CountryId
BEGIN
		SELECT
			 agentId
			,agentName
		FROM agentMaster WITH(NOLOCK)
		WHERE agentType = '2903'
		AND agentCountryId = @param
		AND ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(isActive, 'N') = 'Y'
		ORDER BY agentName

		RETURN
END

ELSE IF @flag = 'rbl'						--@author:bijay; Get Regional Branch List according to bank branch
BEGIN	
    SELECT * FROM (
	SELECT
		 am.agentId 
		,am.agentName
	FROM agentMaster am WITH(NOLOCK)
	INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
	WHERE rba.agentId = @param 
	AND ISNULL(rba.isDeleted, 'N') = 'N'
	AND ISNULL(rba.isActive, 'N') = 'Y'
     
    UNION ALL
	
	SELECT
		 am.agentId 
		,am.agentName
	FROM agentMaster am WITH(NOLOCK)
     WHERE  agentId = @param 
    )a ORDER BY agentName

    
	RETURN
END

ELSE IF @flag = 'bul'						--@author:bijay; Get Branch User List
BEGIN
	IF @user IS NULL
	BEGIN
		SELECT
			 userId
			,userName
		FROM applicationUsers WITH(NOLOCK)
		WHERE agentId = @param 
		--AND userName <> @user
		AND ISNULL(isActive, 'N') = 'Y'
		AND ISNULL(isDeleted, 'N') = 'N'
	END
	ELSE
	BEGIN
		SELECT
			 userId
			,userName
		FROM applicationUsers WITH(NOLOCK)
		WHERE agentId = @param 
		AND userName <> @user
		AND ISNULL(isActive, 'N') = 'Y'
		AND ISNULL(isDeleted, 'N') = 'N'
	END	
END

ELSE IF @flag = 'collModeByAgent'			--@author:bijay; Collection Mode By Agent Specific CountryId
BEGIN
	SELECT @countryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	SELECT 
		 valueId
		,detailTitle 
	FROM countryCollectionMode ccm WITH(NOLOCK)
	INNER JOIN staticDataValue sdv WITH(NOLOCK) ON ccm.collMode = sdv.valueId
	WHERE countryId = @countryId
END

ELSE IF @flag = 'collModeByCountry'			--@author:bijay; Collection Mode By CountryId
BEGIN
	SELECT 
		 valueId 
		,detailTitle  
	FROM countryCollectionMode ccm WITH(NOLOCK)
	INNER JOIN staticDataValue sdv WITH(NOLOCK) ON ccm.collMode = sdv.valueId
	WHERE countryId = @param
END

ELSE IF @flag = 'collModeByCountryName'		--@author:bijay; Collection Mode By CountryName
BEGIN
	SELECT 
		 valueId 
		,detailTitle 
	FROM countryCollectionMode ccm WITH(NOLOCK)
	INNER JOIN countryMaster cm WITH(NOLOCK) ON ccm.countryId = cm.countryId
	INNER JOIN staticDataValue sdv WITH(NOLOCK) ON ccm.collMode = sdv.valueId
	WHERE cm.countryName = @param
END

ELSE IF @flag = 'recModeByAgentWithCountry'	--@author:bijay; Receiving Mode By agent specific country
BEGIN
	SELECT @countryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	SELECT
		 serviceTypeId
		,typeTitle
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId
END

ELSE IF @flag = 'recModeByCountry'			--@author:bijay; Receiving Mode By CountryId
BEGIN
	
	SELECT
		 serviceTypeId
		,typeTitle
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @param
END

ELSE IF @flag = 'recModeByCountryName'		--@author:bijay; Receiving Mode By CountryName
BEGIN
	SELECT
		 serviceTypeId
		,typeTitle
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN countryMaster cm WITH(NOLOCK) ON crm.countryId = cm.countryId
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE cm.countryName = @param
END

ELSE IF @flag = 'recModeByAgent'			--@author:bijay; Receiving Mode By Agent
BEGIN
	SELECT @countryId = agentCountryId, @countryName = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	SELECT
		 serviceTypeId
		,typeTitle
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId AND crm.applicableFor = 'A'
	AND serviceTypeId NOT IN (
		SELECT tranType FROM receiveTranLimit WHERE (agentId = @param OR countryId = @countryId) AND (maxLimitAmt = 0 OR agMaxLimitAmt = 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		)
	UNION ALL
	SELECT
		 serviceTypeId
		,typeTitle
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId AND crm.applicableFor = 'S' AND
	serviceTypeId IN (SELECT tranType FROM receiveTranLimit WHERE agentId = @param AND (maxLimitAmt > 0 OR agMaxLimitAmt > 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
END

ELSE IF @flag = 'recModeByAgent2'			--@author:bijay; Receiving Mode By Agent
BEGIN
	SELECT @countryId = agentCountryId, @countryName = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	SELECT
		 serviceTypeId
		,typeDesc
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId AND crm.applicableFor = 'A'
	AND serviceTypeId NOT IN (
		SELECT tranType FROM receiveTranLimit WHERE (agentId = @param OR countryId = @countryId) AND (maxLimitAmt = 0 OR agMaxLimitAmt = 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		)
	UNION ALL
	SELECT
		 serviceTypeId
		,typeDesc
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId AND crm.applicableFor = 'S' AND
	serviceTypeId IN (SELECT tranType FROM receiveTranLimit WHERE agentId = @param AND (maxLimitAmt > 0 OR agMaxLimitAmt > 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
END

ELSE IF @flag = 'recModeByAgentCashExclude'	--@author:bijay; Receiving Mode By Agent(Cash Exclude)
BEGIN
	SELECT @countryId = agentCountryId, @countryName = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	
	SELECT
		 serviceTypeId
		,typeDesc
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId AND crm.applicableFor = 'A'
	AND serviceTypeId NOT IN (
		SELECT tranType FROM receiveTranLimit WHERE (agentId = @param OR countryId = @countryId) AND (maxLimitAmt = 0 OR agMaxLimitAmt = 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		)
	AND typeTitle <> 'Cash Payment'
	UNION ALL
	SELECT
		 serviceTypeId
		,typeDesc
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	WHERE countryId = @countryId AND crm.applicableFor = 'S' AND
	serviceTypeId IN (SELECT tranType FROM receiveTranLimit WHERE agentId = @param AND (maxLimitAmt > 0 OR agMaxLimitAmt > 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
END

ELSE IF @flag = 'recModeByAgentCashExclude2'--@author:bijay; Receiving Mode By Agent(Cash Exclude)
BEGIN
	SELECT @countryId = agentCountryId, @countryName = agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	
	SELECT [0], [1] FROM (
			SELECT NULL [0], 'Select Receiving Mode' [1] UNION ALL
			
			SELECT
				 typeDesc [0]
				,typeDesc [1]
			FROM countryReceivingMode crm WITH(NOLOCK)
			INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
			WHERE countryId = @countryId AND crm.applicableFor = 'A'
			AND serviceTypeId NOT IN (
				SELECT tranType FROM receiveTranLimit WHERE (agentId = @param OR (countryId = @countryId AND agentId IS NULL)) AND (maxLimitAmt = 0 OR agMaxLimitAmt = 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
			AND typeTitle <> 'Cash Payment'
			UNION ALL
			SELECT
				 typeDesc [0]
				,typeDesc [1]
			FROM countryReceivingMode crm WITH(NOLOCK)
			INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
			WHERE countryId = @countryId AND crm.applicableFor = 'S' AND
			serviceTypeId IN (SELECT tranType FROM receiveTranLimit WHERE agentId = @param AND (maxLimitAmt > 0 OR agMaxLimitAmt > 0) AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		) x ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END	
		RETURN
END


ELSE IF @flag = 'recAgentByRecMode'
BEGIN
	DECLARE @applicableFor CHAR(1)
	--SELECT * FROM countryReceivingMode
	SELECT @applicableFor = applicableFor FROM countryReceivingMode WITH(NOLOCK) WHERE countryId = @country AND receivingMode = @param
	SELECT agentId, agentName INTO #tempAgent FROM agentMaster WHERE agentCountryId = @country AND ISNULL(isActive, 'N') = 'Y'
	IF(@applicableFor = 'A')
	BEGIN
		DELETE FROM #tempAgent
		FROM #tempAgent t
		INNER JOIN receiveTranLimit rtl WITH(NOLOCK) ON t.agentId = rtl.agentId
		WHERE (rtl.maxLimitAmt = 0 OR rtl.agMaxLimitAmt = 0) AND ISNULL(rtl.isActive, 'N') = 'Y' AND ISNULL(rtl.isDeleted, 'N') = 'N'
		
		SELECT * FROM #tempAgent
	END
	ELSE
	BEGIN
		SELECT t.agentId, t.agentName
		FROM #tempAgent t WITH(NOLOCK)
		INNER JOIN receiveTranLimit rtl WITH(NOLOCK) ON t.agentId = rtl.agentId
		WHERE (rtl.maxLimitAmt > 0 OR rtl.agMaxLimitAmt > 0) AND ISNULL(rtl.isActive, 'N') = 'Y' AND ISNULL(rtl.isDeleted, 'N') = 'N'
	END
END

ELSE IF @flag = 'currListByAgent'			--@author:bijay; Currency List by agent specific country
BEGIN
	SELECT @countryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @param
	SELECT 
		 currencyId = curr.currencyCode
		,curr.currencyCode
	FROM countryCurrency cc 
	INNER JOIN currencyMaster curr ON cc.currencyId = curr.currencyId
	WHERE ISNULL(cc.isDeleted, 'N') = 'N'
	AND cc.countryId = @countryId 
	
	RETURN
END

ELSE IF @flag='BranchUserTransfer'
BEGIN
	DECLARE @parentId INT
	--DECLARE @agentId  INT
	SELECT @parentId = parentId
	,@agentId = am.agentId
	FROM agentmaster am
	INNER JOIN applicationUsers au ON am.agentId = au.agentID
	WHERE au.userName = @user

	SELECT
	 am.agentId,
	 am.agentName 
	FROM agentmaster am
	WHERE am.parentId = @parentId AND agentId <> @agentId
	ORDER BY agentName
END

-- EXEC proc_dropDownLists @flag='cNameCH',@param='akmnazmul'
ELSE IF @flag='cNameCH'
BEGIN
		SELECT
			 countryId
			,countryName
		FROM countryMaster cm WITH(NOLOCK)  
		INNER JOIN 
		(
				SELECT DISTINCT agentCountryId FROM agentMaster am WITH(NOLOCK) 
				INNER JOIN 
				(
					SELECT DISTINCT agentId FROM dbo.FNAAgentUserListForCH(@param) x WHERE agentId IS NOT NULL
				)CH ON CH.agentId=am.agentId	
				
		)a ON a.agentCountryId=cm.countryId
		WHERE ISNULL(cm.isDeleted, 'N') = 'N'
		AND ISNULL(cm.isOperativeCountry, 'N') = 'Y'
		ORDER BY cm.countryName
END

ELSE IF @flag = 'alcC'				-- Select Agent According to CountryName for Country Head 
BEGIN
	SELECT
		 am.agentId
		,agentName
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	INNER JOIN 
	(
		SELECT DISTINCT agentId FROM dbo.FNAAgentUserListForCH(@param) x WHERE agentId IS NOT NULL
	)CH ON CH.agentId=am.agentId
	WHERE agentType = 2903
	AND am.agentCountry = @param1
	AND ISNULL(am.isDeleted, 'N') = 'N'
	--AND ISNULL(am.isActive, 'N') = 'Y'
	AND ISNULL(am.agentBlock,'U') <>'B'
	ORDER BY am.agentName
	RETURN
END

ELSE IF @flag = 'alCH'				-- Select Agent for Country Head 
BEGIN
	SELECT
		 am.agentId
		,agentName
	FROM agentMaster am WITH(NOLOCK)
	INNER JOIN 
	(
		SELECT DISTINCT agentId FROM dbo.FNAAgentUserListForCH(@param) x WHERE agentId IS NOT NULL
	)CH ON CH.agentId=am.agentId
	WHERE agentType = 2903
	AND ISNULL(am.isDeleted, 'N') = 'N'
	AND ISNULL(am.isActive, 'N') = 'Y'
	ORDER BY am.agentName
	RETURN
END

ELSE IF @flag = 'agentList' -- to select agent name and branch name
BEGIN
	SELECT 
		TOP 20
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE agentName LIKE '%'+@param + '%'
	AND ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2903'
	AND ISNULL(agentBlock,'U') <>'B'
	RETURN	
END

ELSE IF @flag = 'userList' -- To select user name 
BEGIN
	SELECT 
		TOP 20
		userName 
	FROM applicationUsers 
	WHERE userName LIKE @param + '%'
	AND ISNULL(isDeleted, 'N') <> 'Y'
	RETURN
END

ELSE IF @flag = 'branchList' -- to select agent name 
BEGIN
	SELECT 
		TOP 20
		agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE agentName LIKE @param + '%'
	AND ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2904'
	RETURN	
END

ELSE IF @flag = 'roleType'  --@author:bibash; SELECT roleType to show in grid filter.
BEGIN
	SELECT 'NULL' [0], 'All' [1]
			UNION ALL 
	SELECT 'H' [0], 'HO/Admin' [1]
		UNION ALL 
	SELECT 'A' [0], 'Agent' [1]
	RETURN	
END

ELSE IF @flag = 'countryAuto'						-- CountryName List
BEGIN
	SELECT 
		countryId,
		countryName
	FROM countryMaster WHERE countryName LIKE @param
	ORDER BY countryName ASC
	RETURN
END

ELSE IF @flag = 'country'						-- CountryName List
BEGIN
	SELECT 
		countryId,
		countryName
	FROM countryMaster WITH(NOLOCK) --Where isnull(isOperativeCountry,'') ='Y'
	ORDER BY countryName ASC
	RETURN
END

ELSE IF @flag = 'countryOp'						-- CountryName List
BEGIN
	SELECT 
		countryId,
		countryName
	FROM countryMaster WITH(NOLOCK) Where isnull(isOperativeCountry,'') ='Y'
	ORDER BY countryName ASC
	RETURN
END

ELSE IF @flag = 'sCountry'						-- Sending CountryName List
BEGIN
	SELECT countryId,countryName
	FROM countryMaster (nolock)
	WHERE ISNULL(isOperativeCountry,'') ='Y'
	AND ISNULL(operationType, '') = 'S'
	order by countryName
	RETURN
END

ELSE IF @flag = 'pCountry'						-- Receiving CountryName List
BEGIN
	SELECT 
		countryId,
		countryName
	FROM countryMaster WHERE countryId <>250  
	   AND ISNULL(isOperativeCountry,'') ='Y' AND (operationType ='R' OR operationType ='B')
	ORDER BY countryName ASC
	RETURN
END

ELSE IF @flag = 'mg-country'						-- Receiving CountryName List
BEGIN
	SELECT DISTINCT
			countryId = isoNumeric,
			UPPER(countryName) countryName
	FROM countryMaster CM WITH (NOLOCK)
	INNER JOIN mgDelivery MGD WITH (NOLOCK) ON CM.isoNumeric = MGD.Country 
	WHERE CM.isoNumeric IS NOT NULL AND CM.countryName <>'Malaysia'
	ORDER BY countryName ASC
	
	RETURN
END

ELSE IF @flag = 'mg-calc-mode'
BEGIN
	SELECT 'QINC_FEE' code,'By Collection Amt' VALUE
	UNION ALL 
	SELECT 'QRECEIVE_FEE', 'By Payout Amt'
END

ELSE IF @flag = 'mg-delivery-mode'
BEGIN
	SELECT DeliveryOptionCode code, DeliveryOptionName VALUE, country FROM mgDelivery WITH(NOLOCK) WHERE country = @param	
	RETURN
END

ELSE IF @flag = 'mg-do'
BEGIN
	SELECT sno code, DeliveryOptionName value, country FROM mgDelivery WITH(NOLOCK) WHERE country = @param
	RETURN
END

ELSE IF @flag = 'agent'						   -- Select agentName List According to CountryName
BEGIN
	SELECT	
		agentId,
		agentName 
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2903'
	AND am.agentCountryId = @country 
	--AND isActive = 'Y'
	AND ISNULL(am.agentBlock,'U') <>'B'
	ORDER BY agentName ASC
	RETURN	
END
ELSE IF @flag = 'agents_ForSoa'						   -- Select agentName List According to CountryName fro soa report of admin
BEGIN
	SELECT agentId, agentName
	FROM dbo.agentMaster (NOLOCK) 
	WHERE ISNULL(isSettlingAgent, 'N') = 'Y'
	AND ISNULL(isActive, 'Y') = 'Y' 
	AND ISNULL(isDeleted, 'N') = 'N'
	AND parentId = DBO.FNAGetIntlAgentId()
	AND agentType IN (2903, 2904)
	AND agentCountryId = @param1
	AND ISNULL(isApiPartner, 0) <> 1
	RETURN	
END

ELSE IF @flag = 'agent_1'						   -- Select agentName List According to CountryName
BEGIN
	SELECT	
		agentId,
		agentName 
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2903'
	AND am.agentCountry = @country 
	AND ISNULL(agentBlock,'U') <>'B'
	ORDER BY agentName ASC
	RETURN	
END

ELSE IF @flag = 'agentOld'	-- FOR OLD SYSTEM 
BEGIN
	SELECT	
		 mapCodeInt agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2903'
	AND am.agentCountryId = @country AND isActive = 'Y'
	ORDER BY agentName ASC
	RETURN	
END

ELSE IF @flag = 'branch'					   -- Select branchName List According to CountryName and AgentName
BEGIN
	SELECT
		agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2904' AND isActive = 'Y'
	AND am.agentCountryId = ISNULL(@country,am.agentCountryId) AND  am.parentId = ISNULL(@agentId,am.parentId) 
	ORDER BY agentName ASC
	RETURN	
END

ELSE IF @flag = 'branch_1'					   -- Select branchName List According to CountryName and AgentName
BEGIN
	SELECT
		agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND isActive = 'Y'
	AND am.parentId = @agentId
	ORDER BY agentName ASC
	RETURN	
END

ELSE IF @flag = 'countryWiseBankListForCollectionDetail'			-- list of bankName and Cash
BEGIN
		SELECT '0' countryBankId ,'CASH' bankName 
		UNION ALL
		SELECT DISTINCT countryBankId, bankName FROM countryBanks
		WHERE ISNULL(isActive, 'N') = 'Y' 
		AND ISNULL(isDeleted, '') <> 'Y'		
		AND countryId = ISNULL(@countryId, countryId)
		
		RETURN
END

ELSE IF @flag='deliveryMethod'
BEGIN
	SELECT 			
		stm.serviceTypeId 
		,stm.typeTitle
	FROM serviceTypeMaster stm WITH (NOLOCK) 
	WHERE ISNULL(stm.isDeleted, 'N')  <> 'Y'
	AND ISNULL(stm.isActive, 'N') = 'Y' 
END

ELSE IF @flag = 'stateByCountryName' ---Added by Pralhad
BEGIN
	SELECT stateId
		,stateName 
	FROM countryMaster CM WITH (NOLOCK)
	INNER JOIN countryStateMaster CS WITH (NOLOCK) ON CM.countryId=CS.countryId
	WHERE CM.countryName = @country
	ORDER BY stateName
	RETURN
END

ELSE IF @flag = 'custSearchType' ---Added by Pralhad  CUSTOMER SEARCH TYPE
BEGIN
	SELECT detailTitle,detailDesc FROM staticDataValue
	WHERE typeID=7600
	ORDER BY detailTitle
	RETURN
END

ELSE IF @flag = 'basis' --- Scheme Bonus Setup basis 
BEGIN
	SELECT valueId,detailTitle FROM staticDataValue
	WHERE typeID = 7800
	ORDER BY detailTitle
	RETURN
END

ELSE IF @flag = 'gift-item' --- Scheme Prize Setup Gift Item 
BEGIN
	SELECT valueId,detailTitle FROM staticDataValue
	WHERE typeID = 7900
	ORDER BY detailTitle
	RETURN
END

ELSE IF @flag='custClass' ---- ADDED BY RIWAJ Customer Classification for Scheme Setup 
	BEGIN
	SELECT valueId,detailTitle FROM staticDataValue
	WHERE typeID = 8000
	ORDER BY detailTitle	
	RETURN
	END
	
ELSE IF @flag = 'cusRedeem'
BEGIN
	SELECT 'NULL' [0], 'Select' [1]
			UNION ALL 
	SELECT 'CNM' [0], 'Customer Name' [1]
			UNION ALL 
	SELECT 'CID' [0], 'Customer ID' [1]
		UNION ALL 
	SELECT 'CNU' [0], 'Customer Number' [1]
		UNION ALL 
	SELECT 'Passport' [0], 'Passport/NRIC' [1]
			UNION ALL 
	SELECT 'MOB' [0], 'Mobile No' [1]
	RETURN	
END

ELSE IF @flag = 'recAgentByRecModeAjaxagent'
BEGIN

	DECLARE @applicableFor1 CHAR(1),@agentSelection CHAR(1)
	--SELECT * FROM countryReceivingMode
	SELECT @applicableFor1 = applicableFor,@agentSelection=agentSelection FROM countryReceivingMode WITH(NOLOCK) WHERE countryId = @country AND receivingMode = ISNULL(@param,0)
	
	DECLARE @tempAgent TABLE (agentId INT, agentName VARCHAR(500))
	INSERT INTO @tempAgent
	SELECT agentId, agentName FROM agentMaster WHERE agentCountryId = @country AND ISNULL(isActive, 'N') = 'Y' AND agentType='2903'

	IF(@applicableFor1 = 'A')
	BEGIN
		DELETE FROM @tempAgent
		FROM @tempAgent t
		INNER JOIN receiveTranLimit rtl WITH(NOLOCK) ON t.agentId = rtl.agentId
		WHERE (rtl.maxLimitAmt = 0 OR rtl.agMaxLimitAmt = 0) AND ISNULL(rtl.isActive, 'N') = 'Y' AND ISNULL(rtl.isDeleted, 'N') = 'N'
		
		SELECT agentId [serviceTypeId],agentName [typeTitle],@agentSelection [agentSelect] FROM @tempAgent
		ORDER BY agentName
	END
	ELSE
	BEGIN

		--SELECT t.agentId [serviceTypeId], t.agentName [typeTitle],@agentSelection [agentSelect]
		--FROM @tempAgent t 
		--INNER JOIN receiveTranLimit rtl WITH(NOLOCK) ON t.agentId = rtl.agentId
		--WHERE (rtl.maxLimitAmt > 0 OR rtl.agMaxLimitAmt > 0) AND ISNULL(rtl.isActive, 'N') = 'Y' AND ISNULL(rtl.isDeleted, 'N') = 'N'
		--ORDER BY agentName

		SELECT * FROM
		(
		    SELECT t.agentId [serviceTypeId], t.agentName [typeTitle],@agentSelection [agentSelect]
		    FROM @tempAgent t 
		    INNER JOIN receiveTranLimit rtl WITH(NOLOCK) ON t.agentId = rtl.agentId
		    WHERE (rtl.maxLimitAmt > 0 OR rtl.agMaxLimitAmt > 0) AND ISNULL(rtl.isActive, 'N') = 'Y' AND ISNULL(rtl.isDeleted, 'N') = 'N'
    		
		    UNION ALL
    		
		    SELECT extBankId, bankName ,'E'  FROM externalBank E, countryMaster C
		    WHERE E.country = C.countryName AND C.countryId = @country --AND ISNULL(C.isActive, 'N') = 'Y'
		 )A
		ORDER BY [typeTitle]
	END
END

ELSE IF @flag = 'branchAjax'					   -- Select branchName List According to AgentName By pralhad
BEGIN
	SELECT
		agentId [serviceTypeId],
		agentName [typeTitle]
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2904'
	AND am.parentId = @agentId
	ORDER BY agentName ASC
	RETURN	
END

IF @flag = 'countryPay'
BEGIN
	SELECT
		countryId,
		countryName
	FROM countryMaster 
	WHERE ISNULL(isOperativeCountry,'') = 'Y'
	AND ISNULL(operationType,'B') IN ('B','R') 
	ORDER BY countryName ASC	
	RETURN
END
IF @flag = 'a-countryPay'
BEGIN
	SELECT
		countryId,
		UPPER(countryName) countryName
	FROM countryMaster 
	WHERE ISNULL(isOperativeCountry,'') = 'Y'
	AND ISNULL(operationType,'B') IN ('B','R') 
	ORDER BY countryName ASC	
	RETURN
END
IF @flag = 'a-countrySend'
BEGIN
	SELECT
		countryId,
		UPPER(countryName) countryName
	FROM countryMaster 
	WHERE ISNULL(isOperativeCountry,'') = 'Y'
	AND ISNULL(operationType,'B') IN ('B','S') 
	AND countryName='JAPAN'      -- new added as send country is always korea other remove this condition: sugg by (Prahlad Sir)
	ORDER BY countryName ASC	
	RETURN;
END
IF @flag = 'provider'
BEGIN	
	SELECT agentId Id, apiDescription Name FROM apiRoutingTable WHERE agentId IS NOT NULL	
	RETURN
END

IF @flag = 'provider_n_us'
BEGIN
	SELECT NULL Id, 'All' Name UNION ALL
 	SELECT isnull(CAST(agentId AS VARCHAR),'111') Id, apiDescription Name FROM apiRoutingTable
	RETURN
END

IF @flag = 'rh-branch'
BEGIN
	IF @userType = 'RH'
	BEGIN
		SELECT distinct
			branch.agentId, branch.agentName agentName
		FROM (
			SELECT
				am.agentId 
				,am.agentName
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
			WHERE rba.agentId = @branchId 
			AND ISNULL(rba.isDeleted, 'N') = 'N'
			AND ISNULL(rba.isActive, 'N') = 'Y'
			
			UNION ALL
			SELECT agentId, agentName
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @branchId
		) branch ORDER BY agentName ASC	
		RETURN
	END
	
	IF @userType = 'AH'
	BEGIN
		SELECT DISTINCT A.agentId,A.agentName 
		FROM agentMaster A WITH(NOLOCK)
		INNER JOIN applicationUsers U WITH (NOLOCK) ON A.agentId = U.agentId
		WHERE parentId = (SELECT parentId FROM agentMaster WITH (NOLOCK) WHERE agentId =@branchId )
		RETURN
	END

	SELECT agentId, agentName
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @branchId

	UNION ALL
	
	SELECT agentId, agentName
	FROM agentMaster WITH(NOLOCK) 
	WHERE PARENTID=393877
	AND actasbranch = 'N'
	RETURN
END

IF @flag = 'rh-branch1'
BEGIN
	SELECT agentId, agentName
	FROM agentMaster WITH(NOLOCK) 
	WHERE parentId = @agentId
	AND ISNULL(isDeleted, 'N') = 'N'
	AND ISNULL(isActive, 'N') = 'Y'
	ORDER BY agentName
	RETURN
END

IF @flag = 'rh-branchOld'-- FOR OLD SYSTEM SEARCH
BEGIN
	IF @userType = 'RH'
	BEGIN
		SELECT 
			branch.agentId, branch.agentName agentName
		FROM (
			SELECT
				am.mapCodeInt  agentId
				,am.agentName
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
			WHERE rba.agentId = @branchId 
			AND ISNULL(rba.isDeleted, 'N') = 'N'
			AND ISNULL(rba.isActive, 'N') = 'Y'
			
			UNION ALL
			SELECT mapCodeInt agentId, agentName
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @branchId
		) branch ORDER BY agentName ASC	
		RETURN
	END
	IF @userType = 'AH'
	BEGIN
		SELECT DISTINCT A.mapCodeInt agentId,A.agentName 
		FROM agentMaster A WITH(NOLOCK)
		INNER JOIN applicationUsers U WITH (NOLOCK) ON A.agentId = U.agentId
		WHERE parentId = (SELECT parentId FROM agentMaster WITH (NOLOCK) WHERE agentId =@branchId )
		RETURN
	END
	SELECT mapCodeInt agentId, agentName
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @branchId
	RETURN
END

IF @flag = 'occupation'
BEGIN
	SELECT 
		 occupationId
		,detailTitle
	FROM occupationMaster WITH(NOLOCK)
	WHERE ISNULL(isActive,'N') <> 'N'
		AND ISNULL(isDeleted,'N') <> 'Y'
		ORDER BY detailTitle ASC
	RETURN
END

ELSE IF @flag = 'rh-branch-g'		-- @Naren SELECT Regional Branch Name  For Grid Filter.			   
BEGIN
	DECLARE @BRANCHLIST TABLE(agentId VARCHAR(200), agentName VARCHAR(200))
	IF @userType = 'RH'
	BEGIN
		INSERT INTO @BRANCHLIST
		SELECT 
			branch.agentId, branch.agentName agentName
		FROM (
			SELECT
				am.agentId 
				,am.agentName
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
			WHERE rba.agentId = 13391 
			AND ISNULL(rba.isDeleted, 'N') = 'N'
			AND ISNULL(rba.isActive, 'N') = 'Y'
			
			UNION ALL
			SELECT agentId, agentName
			FROM agentMaster WITH(NOLOCK) WHERE agentId = 13391
		) branch ORDER BY agentName ASC	
	
	
	SELECT NULL [0],'All' [1]
	UNION ALL
	SELECT * FROM @BRANCHLIST	
	RETURN	
	END
END

IF @FLAG ='ofacType'
BEGIN
	SELECT NULL [0],'All' [1]
	UNION ALL
	SELECT 'OFAC','OFAC' UNION ALL
	SELECT 'Compliance','Compliance' UNION ALL
	SELECT 'OFAC/Compliance' ,'OFAC/Compliance'
	
END

ELSE IF @flag = 'r-s-currency'
BEGIN
	SELECT  DISTINCT cm.currencyCode 
		,cm.currencyDesc
	FROM countryCurrency  cc
	INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	WHERE cc.countryId = ISNULL(@countryId,'') 
	--AND  ISNULL(cm.isactive , 'N')= 'Y' 
	AND  ISNULL(cm.isDeleted , 'N')= 'N' 
	RETURN
END

ELSE IF @flag = 'r-currency'
BEGIN
	SELECT DISTINCT 
		cm.currencyCode 
		,cm.currencyDesc
	FROM countryCurrency  cc
	INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	WHERE cc.countryId = @countryId
	AND applyToAgent = 'Y'
	AND (spFlag = 'B' OR spFlag = 'P')  
	--AND  ISNULL(cm.isactive , 'N')= 'Y' 
	AND  ISNULL(cm.isDeleted , 'N')= 'N' 
	RETURN
END

ELSE IF @flag = 's-currency'
BEGIN
	SELECT  DISTINCT 
		cm.currencyCode 
		,cm.currencyDesc
	FROM countryCurrency  cc
	INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	WHERE cc.countryId = @countryId
	AND applyToAgent = 'Y'
	AND (spFlag = 'B' OR spFlag = 'S')  
	--AND  ISNULL(cm.isactive , 'N')= 'Y' 
	AND  ISNULL(cm.isDeleted , 'N')= 'N' 
	RETURN
END

ELSE IF @flag = 'app-table'
BEGIN
	SELECT DISTINCT 
		LTRIM(RTRIM(tableName)) AS tableName
	FROM applicationLogs WHERE tableName <> '' ORDER BY LTRIM(RTRIM(tableName)) ASC 
	RETURN
END

ELSE IF @flag = 'internalAgent' 
BEGIN
	SELECT 
		 agentId = a.agentId
		,agentName = a.agentName + ' - ' + CASE WHEN agentType = 2903 THEN 'Internal' ELSE 'External' END
	FROM agentMaster a WITH(NOLOCK) 
	WHERE agentCountry=@countryName
	AND ISNULL(a.isDeleted, 'N') <> 'Y'
	AND ISNULL(a.isActive, 'Y') = 'Y'
	AND agentType IN (2903, 2905) AND ISNULL(actAsBranch, 'N') = 'N'
	ORDER BY agentName
	RETURN;
	
END

ELSE IF @flag = 'internalAgent1' -->> DDL for assigning agent bank code >> Agent Wise Bank Code
BEGIN
	SELECT @countryName = country FROM externalBank WITH(NOLOCK) WHERE extBankId=@param
	SELECT a.agentId,a.agentName FROM agentMaster a WITH(NOLOCK)
	WHERE agentName LIKE '%bank%'
		AND agentCountry=@countryName
		AND ISNULL(a.isDeleted, 'N') <> 'Y'
		AND ISNULL(a.isActive,'Y')='Y'
		AND agentType=2903
	RETURN
END

ELSE IF @flag = 'routThroughBank'	-->> Internal Bank List Only Agent
BEGIN
	SELECT @countryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName=@countryName
	SELECT a.agentId,a.agentName FROM agentMaster a WITH(NOLOCK) INNER JOIN
	(
		SELECT agentId FROM receiveTranLimit x WITH(NOLOCK) 
		WHERE countryId=ISNULL(@countryId,countryId) AND tranType='3'
		AND ISNULL(x.isDeleted, 'N') <> 'Y'
		AND ISNULL(x.isActive,'Y')='Y'
		AND x.approvedDate IS NOT NULL
		AND X.maxLimitAmt<>0
	)b ON a.agentId=b.agentId
	WHERE ISNULL(a.isDeleted, 'N') <> 'Y'

END

ELSE IF @flag = 'timeZone'
BEGIN
	SELECT TIMEZONE_ID , TIMEZONE_NAME  FROM time_zones
RETURN
END

IF @flag = 'ps' --Pay Status
 BEGIN
	SELECT 
		valueId, detailDesc, detailTitle
	FROM staticDataValue WHERE typeId = 5500
	RETURN
 END
 
 IF @flag = 'ts' --Tran Status
 BEGIN
	IF @param1 = 'unpaid'
	BEGIN
		SELECT 
			valueId, detailDesc, detailTitle
		FROM staticDataValue WHERE typeId = 5400
		AND detailTitle <> 'Paid'
		RETURN
	END
	ELSE
	BEGIN
		SELECT 
			valueId, detailTitle, detailDesc 
		FROM staticDataValue WHERE typeId = 5400
		AND detailTitle = CASE 
							WHEN @param1 = 'Paid' THEN 'Paid' 
							WHEN @param1 = 'Post' THEN 'Payment' 
							ELSE ISNULL(@param1, detailTitle)
						  END
		RETURN	
	END
 END
 
 IF @flag = 'userList1' -->>User List By Branch Id
 BEGIN
	SELECT 
		userName
	FROM applicationUsers am WITH(NOLOCK)
	 WHERE
	 	approvedDate IS NOT NULL
	 	AND agentId = @branchId
	RETURN
 END
 
IF @flag = 'agentByCountryName' -->>User List By Branch Id
 BEGIN
	SELECT	
		agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2903'
	AND am.agentCountry = @country
	AND ISNULL(agentBlock,'U') <>'B'
	ORDER BY agentName ASC
	RETURN	
 END

IF @flag ='allCurr'  --@author:bibash; Select All Currency
BEGIN
	SELECT currencyId, currencyCode FROM currencyMaster WHERE ISNULL(isDeleted,'N')<>'Y'
END

IF @flag = 'recCountrySc'		-->> select receiving country for service charge (Only list of service defined)
BEGIN	
	-->> @countryId is sending country!
	SELECT a.countryId,a.countryName FROM countryMaster a WITH(NOLOCK) INNER JOIN
	(
		SELECT DISTINCT rCountry 
			FROM sscMaster WITH(NOLOCK) WHERE sCountry=@countryId
	)b ON a.countryId=b.rCountry
	ORDER BY a.countryName	
	RETURN
END

IF @flag = 'IdtypeByCountry'-- DISPLAY ID TYPE BY COUNTRY ID
BEGIN
	SELECT 
			countryIdtypeId,
			SV.detailTitle 
	FROM countryIdType CI WITH (NOLOCK)
	INNER JOIN staticDataValue SV WITH (NOLOCK) ON CI.IdTypeId = SV.valueId
	 WHERE countryId = ISNULL(@country,'0')
END

IF @flag = 'bankList'
BEGIN
	SELECT 0 countryBankId,'Cash Collection' bankName UNION ALL
	SELECT countryBankId,bankName 
		FROM countryBanks WITH (NOLOCK) WHERE isActive='Y' AND countryId = @countryId ORDER BY bankName
END

IF @flag='TPAgent'
BEGIN
	SELECT 4670 agentId, 'Cash Express' agentName UNION ALL
	SELECT 4726 agentId, 'EZ Remit' agentName UNION ALL
	SELECT 4734 agentId, 'Global API' agentName UNION ALL
	SELECT 4869 agentId, 'RIA Remit' agentName UNION ALL
	SELECT 4909 agentId, 'XPress Money' agentName UNION ALL
	SELECT 4854 agentId, 'Money Gram' agentName UNION ALL
	SELECT 4816 agentId, 'Instant Cash' agentName 
END

IF @flag = 'agentSettCurr' -->>User List By Branch Id
BEGIN

	SELECT	
		ISNULL(agentSettCurr,'MYR') agentSettCurr
	FROM agentMaster am WITH(NOLOCK)
	WHERE am.agentId = @agentId
	RETURN	
 END
 
IF @flag = 'agentSummBal' -->>Agent summary Balance Rpt Ddl
BEGIN

	SELECT
		 mapcodeInt
		,agentName
	FROM agentMaster am WITH(NOLOCK) where mapcodeInt is not null order by agentName asc
	RETURN	
 END 
 
IF @flag = 'remitProduct' -- @author: Bibash
BEGIN
	SELECT value = 'S', [text] = 'Normal Send'
	union all 
	SELECT value = 'T', [text] = 'Topup'
	union all 
	SELECT value = 'E', [text] = 'Edu Pay'
	RETURN	
 END
 
IF @flag='mgCountry'
BEGIN
	SELECT countryCode,countryName FROM mgCountries (nolock)
	where isnull(sendActive,'False') = 'True'
END

IF @flag='mgCountryState'
BEGIN
	SELECT stateCode = stateProvinceCode, stateName = stateProvinceName FROM mgStateProvince(nolock) WHERE countryCode = @param
END

IF @flag = 'sZone'  
BEGIN
 SELECT top 20
			 stateId
			,stateName 
		FROM countryStateMaster a WITH(NOLOCK) 
		inner join countryMaster b with(nolock) on a.countryId=b.countryId
		WHERE (b.countryName = 'Nepal' or b.countryId=151) 			
		AND ISNULL(A.isDeleted, 'N') <> 'Y'
		ORDER BY stateName
END

IF @flag = 'agent-grp'  
BEGIN
	SELECT valueId,detailTitle FROM staticdataValue WITH(NOLOCK) where typeId = 4300
	AND ISNULL(isActive,'Y') <> 'N'
	RETURN;
END

ELSE IF @flag = 'intl-agents-ro' --## Select only int'l agents for soa/settlement - regional overseas
BEGIN
	SELECT	
		am.agentId,
		am.agentName 
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	INNER JOIN dbo.userAgentMapping uam WITH(NOLOCK) ON am.agentId = uam.agentId
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	and uam.userName = @user
	AND am.agentType = '2903'
	AND am.agentCountryId <> '151' 
	AND ISNULL(am.agentBlock,'U') <>'B'
	ORDER BY agentName ASC
	RETURN	

END
ELSE IF @flag = 'agentListAll' -- to select agent name and branch name for filter
BEGIN
	SELECT
		TOP 20
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE agentName LIKE @param + '%'
	AND ISNULL(am.isDeleted, 'N') <> 'Y'	
	RETURN	
END
ELSE IF @flag='tranType'
BEGIN
	
	SELECT 
		UPPER([0]) [0], UPPER([1]) [1]
	FROM (
		SELECT 'Cash Payment' [0], 'Cash Payment' [1] UNION ALL 
		SELECT 'Bank Deposit' [0], 'Bank Deposit' [1] UNION ALL 
		SELECT 'FOREIGN EMP. BOND' [0], 'FOREIGN EMP. BOND' [1]
	) X
END
ELSE IF @flag='isoPayStatus'
BEGIN
	SELECT '' as value, 'All'AS text UNION ALL
	SELECT 'Pending' as value, 'Pending'AS text UNION ALL
	SELECT 'Ready'	 as value,'Ready'	AS text UNION ALL
	SELECT 'Success' AS value,'Paid'	AS text UNION ALL
	SELECT 'Error'	 as value,'Error'	AS text 
END

ELSE IF @flag='pickBranchById'
BEGIN
	DECLARE @COUNTRY_ID INT, @COLL_MODE INT

	SELECT @COUNTRY_ID = CM.COUNTRYID, @COLL_MODE = PAYMENT_TYPE_ID
	FROM API_BANK_LIST ABL(NOLOCK)
	INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = ABL.BANK_COUNTRY
	WHERE BANK_ID = @agentId 

	IF @COUNTRY_ID = 151
	BEGIN
		SELECT NULL agentId,agentName = 'Any Branch'
		RETURN
	END
	ELSE IF @COUNTRY_ID IN (105, 174) AND @COLL_MODE = 2
	BEGIN
		SELECT APBL.ID agentId, APL.PAYOUT_NAME + ' - ' + APBL.BRANCH_NAME agentName
		FROM API_PAYOUT_LOACTION APL(NOLOCK) 
		INNER JOIN API_PAYOUT_BRANCH_LOACTION APBL(NOLOCK) ON APL.Id  = APBL.PAYOUT_ID
		WHERE APL.BANK_ID = @agentId
		RETURN
	END
	SELECT agentId = BRANCH_ID
		,agentName = BRANCH_NAME
	FROM API_BANK_BRANCH_LIST am WITH (NOLOCK) 
	WHERE BANK_ID = @agentId 
	AND IS_ACTIVE = 1
END

ELSE IF @flag='Partneragent'
BEGIN
	SELECT am.agentId,am.agentName 
	FROM AgentMaster am WITH (NOLOCK) 
	inner join TblPartnerwiseCountry t(nolock) on t.AgentId = am.AgentId
	WHERE agentType = 2903 AND t.CountryId = @country
	AND ISNULL(t.IsActive,0) = 1
	AND ISNULL(am.isDeleted, 'N') <> 'Y'
END
ELSE IF @flag='r-country-list'
BEGIN
	SELECT countryId, countryName FROM countryMaster CM(NOLOCK)
	WHERE ISNULL(isOperativeCountry, 'N') = 'Y'
	AND operationType IN ('R', 'B')
	AND  ISNULL(isDeleted, 'N') = 'N'
	AND ISNULL(isActive, 'Y') = 'Y'
END
ELSE IF @flag='branch-list'
BEGIN
	SELECT agentId, agentName FROM agentMaster (NOLOCK)
	WHERE parentId = 1008
	AND ISNULL(isActive, 'Y') = 'Y'
	AND ISNULL(isDeleted, 'N') = 'N'
END
ELSE IF @flag = 'partner-list'
BEGIN
	SELECT distinct AM.agentId, AM.agentName FROM TblPartnerwiseCountry(nolock) c
	INNER JOIN agentMaster AM(NOLOCK) on c.AgentId = am.parentId
	where am.isSettlingAgent='Y' and am.isApiPartner = 1 AND agentType=2903
	UNION ALL 
	SELECT agentId,agentName FROM agentMaster(NOLOCK) WHERE agentId in (1056,1036)
	ORDER BY 1
END
ELSE IF @flag = 'user-list'
BEGIN
	SELECT DISTINCT approvedBy FROM CUSTOMERMASTER (NOLOCK)
	WHERE approvedBy IS NOT NULL 
	ORDER BY approvedBy
END
ELSE IF @flag='rCountry-payoutPartner' --get country name for receiving agent
BEGIN
	SELECT COUNTRYID, COUNTRYNAME 
	FROM COUNTRYMASTER (NOLOCK) 
	WHERE ISNULL(ISOPERATIVECOUNTRY, 'N') = 'Y' 
	AND ISNULL(OPERATIONTYPE, '') IN ('R', 'B')
	AND ISNULL(ISACTIVE, 'Y') = 'Y' 
AND ISNULL(ISDELETED, 'N') = 'N'
END
ELSE IF @flag='rAgent-payoutPartner' --get country name for receiving agent
BEGIN
	SELECT A.AGENTID, A.AGENTNAME
	FROM TblPartnerwiseCountry T(NOLOCK)
	INNER JOIN agentMaster A(NOLOCK) ON A.PARENTID = T.AGENTID
	WHERE COUNTRYID = @param1
	AND ISNULL(A.ISSETTLINGAGENT, 'N') = 'Y'
AND ISNULL(T.ISACTIVE, 0) = 1
END

ELSE IF @flag = 'branchAndAgents'					   -- Select branchName List According to CountryName and AgentName
BEGIN
	SELECT
		agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType IN ('2903','2903') AND isActive = 'Y'
	AND ISNULL(am.agentBlock,'U') <>'B' 
	AND am.agentCountryId = ISNULL(@country,am.agentCountryId) AND  am.parentId = ISNULL(@agentId,am.parentId)
	ORDER BY agentName ASC
	RETURN	
END

ELSE IF @flag ='PopulateLocation'
BEGIN	
		DECLARE @deliveryMethodId INT, @PAYOUTPARTNER INT, @pCountryId INT, @maxPayoutLimit MONEY
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster(nolock) where typeTitle = @param
		
		SELECT @PAYOUTPARTNER = TP.AGENTID
		FROM TblPartnerwiseCountry TP(NOLOCK)
		INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = TP.AGENTID
		WHERE TP.CountryId = @pCountryId
		AND ISNULL(TP.PaymentMethod, @deliveryMethodId) = @deliveryMethodId
		AND ISNULL(TP.IsActive, 1) = 1
		AND ISNULL(AM.ISACTIVE, 'Y') = 'Y'
		AND ISNULL(AM.ISDELETED, 'N') = 'N'

		
		select @maxPayoutLimit = maxLimitAmt from receiveTranLimit(NOLOCK) 
		WHERE countryId = @pCountryId AND tranType = @deliveryMethodId
		and sendingCountry = @countryId

		IF @param IN ('CASH PAYMENT', 'DOOR TO DOOR')
		BEGIN
			IF EXISTS(SELECT TOP 1 'A' FROM API_BANK_LIST AP(NOLOCK) 
			INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AP.BANK_COUNTRY
			WHERE CM.COUNTRYID = @pCountryId AND API_PARTNER_ID = @PAYOUTPARTNER AND PAYMENT_TYPE_ID IN (1, 12, 0))
			BEGIN

				SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME = AL.BANK_NAME,maxPayoutLimit = @maxPayoutLimit
				FROM API_BANK_LIST AL(NOLOCK)
				INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY
				WHERE CM.COUNTRYID = @pCountryId
				AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)
				AND AL.IS_ACTIVE = 1
				AND AL.API_PARTNER_ID = @PAYOUTPARTNER
				ORDER BY AL.BANK_NAME
			END
			ELSE
			BEGIN
				SELECT bankId = '', 0 NS,FLAG = 'E',AGENTNAME = '[ANY WHERE]',maxPayoutLimit = @maxPayoutLimit
			END
		END	
		ELSE IF @param = 'BANK DEPOSIT'
		BEGIN
			SELECT * FROM 
			(
				SELECT bankId = '', 0 NS,FLAG = 'E',AGENTNAME = '[SELECT BANK]' ,maxPayoutLimit = @maxPayoutLimit
				UNION ALL
				SELECT bankId=AL.BANK_ID, 0 NS,FLAG = 'E',AGENTNAME = AL.BANK_NAME,maxPayoutLimit = @maxPayoutLimit
				FROM API_BANK_LIST AL(NOLOCK)
				INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY
				WHERE CM.COUNTRYID = @pCountryId
				AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)
				AND AL.IS_ACTIVE = 1
				AND AL.API_PARTNER_ID = @PAYOUTPARTNER
			)X
			ORDER BY X.AGENTNAME
			RETURN
		END	
		ELSE
		BEGIN
			SELECT bankId=AL.BANK_ID, 
					0 NS,
					FLAG = 'E',
					AGENTNAME = AL.BANK_NAME,
					maxPayoutLimit = @maxPayoutLimit 
			FROM API_BANK_LIST AL(NOLOCK)
			INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY
			WHERE CM.COUNTRYID = @pCountryId
			AND AL.PAYMENT_TYPE_ID IN (0, @deliveryMethodId)
			AND AL.IS_ACTIVE = 1
			AND AL.API_PARTNER_ID = @PAYOUTPARTNER
			ORDER BY AL.BANK_NAME
			
			RETURN
		END
	END
ELSE IF @flag = 'JpyOnly'
BEGIN
	SELECT currencyId, currencyCode FROM currencyMaster WHERE ISNULL(isDeleted,'N')<>'Y' and currencyId = '5'
END


