/*
alter table agentMaster add BANKCODE	varchar(50),BANKBRANCH	varchar(50),BANKACCOUNTNUMBER	varchar(50),ACCOUNTHOLDERNAME	varchar(50)
alter table agentMasterMod add BANKCODE	varchar(50),BANKBRANCH	varchar(50),BANKACCOUNTNUMBER	varchar(50),ACCOUNTHOLDERNAME	varchar(50)

*/

ALTER PROC [dbo].[proc_agentMaster]
    @flag VARCHAR(50) = NULL ,
    @user VARCHAR(30) = NULL ,
    @agentId VARCHAR(30) = NULL ,
    @parentId VARCHAR(30) = NULL ,
    @agentName NVARCHAR(100) = NULL ,
    @agentCode VARCHAR(50) = NULL ,
    @agentAddress VARCHAR(200) = NULL ,
    @agentCity VARCHAR(100) = NULL ,
    @agentCountryId INT = NULL ,
    @agentCountry VARCHAR(100) = NULL ,
    @agentState VARCHAR(100) = NULL ,
    @agentDistrict VARCHAR(100) = NULL ,
    @agentZip VARCHAR(20) = NULL ,
    @agentLocation INT = NULL ,
    @agentPhone1 VARCHAR(50) = NULL ,
    @agentPhone2 VARCHAR(50) = NULL ,
    @agentFax1 VARCHAR(50) = NULL ,
    @agentFax2 VARCHAR(50) = NULL ,
    @agentMobile1 VARCHAR(50) = NULL ,
    @agentMobile2 VARCHAR(50) = NULL ,
    @agentEmail1 VARCHAR(100) = NULL ,
    @agentEmail2 VARCHAR(100) = NULL ,
	@bankBranch VARCHAR(50)=NULL,
	@bankCode  VARCHAR(50)=NULL,
	@bankAccountNumber  VARCHAR(50)=NULL,
	@accHolderName VARCHAR(50)=NULL,
    @businessOrgType INT = NULL ,
    @businessType INT = NULL ,
    @agentRole CHAR(1) = NULL ,
    @agentType INT = NULL ,
    @allowAccountDeposit CHAR(1) = NULL ,
    @actAsBranch CHAR(1) = NULL ,
    @contractExpiryDate DATETIME = NULL ,
    @renewalFollowupDate DATETIME = NULL ,
    @isSettlingAgent CHAR(1) = NULL ,
    @agentGroup INT = NULL ,
    @businessLicense VARCHAR(100) = NULL ,
    @agentBlock CHAR(1) = NULL ,
    @agentcompanyName VARCHAR(200) = NULL ,
    @companyAddress VARCHAR(200) = NULL ,
    @companyCity VARCHAR(100) = NULL ,
    @companyCountry VARCHAR(100) = NULL ,
    @companyState VARCHAR(100) = NULL ,
    @companyDistrict VARCHAR(100) = NULL ,
    @companyZip VARCHAR(50) = NULL ,
    @companyPhone1 VARCHAR(50) = NULL ,
    @companyPhone2 VARCHAR(50) = NULL ,
    @companyFax1 VARCHAR(50) = NULL ,
    @companyFax2 VARCHAR(50) = NULL ,
    @companyEmail1 VARCHAR(100) = NULL ,
    @companyEmail2 VARCHAR(100) = NULL ,
    @localTime INT = NULL ,
    @localCurrency INT = NULL ,
    @agentDetails VARCHAR(MAX) = NULL ,
    @parentName VARCHAR(100) = NULL ,
    @haschanged CHAR(1) = NULL ,
    @isActive CHAR(1) = NULL ,
    @isDeleted CHAR(1) = NULL ,
    @sortBy VARCHAR(50) = NULL ,
    @sortOrder VARCHAR(5) = NULL ,
    @pageSize INT = NULL ,
    @pageNumber INT = NULL ,
    @populateBranch CHAR(1) = NULL ,
    @headMessage VARCHAR(MAX) = NULL ,
    @mapCodeInt VARCHAR(20) = NULL ,
    @mapCodeDom VARCHAR(20) = NULL ,
    @commCodeInt VARCHAR(20) = NULL ,
    @commCodeDom VARCHAR(20) = NULL ,
    @urlRoot VARCHAR(200) = NULL ,
    @joinedDate DATETIME = NULL ,
    @mapCodeIntAc VARCHAR(50) = NULL ,
    @mapCodeDomAc VARCHAR(50) = NULL ,
    @payOption INT = NULL ,
    @agentSettCurr VARCHAR(50) = NULL ,
    @contactPerson1 VARCHAR(200) = NULL ,
    @contactPerson2 VARCHAR(200) = NULL ,
    @isHeadOffice CHAR(1) = NULL ,
    @locationCode VARCHAR(200) = NULL,
	@isIntl BIT = NULL ,
	@isApiPartner BIT = NULL,
	@partnerBankcode VARCHAR(15) = NULL,
	@branchCode VARCHAR(3)=NULL,
	@intlSuperAgentId BIGINT=NULL,
	@isInternal	CHAR(1)=NULL
	
AS
    SET NOCOUNT ON
	
    DECLARE @glcode VARCHAR(10) , @acct_num VARCHAR(20)
    CREATE TABLE #tempACnum ( acct_num VARCHAR(20) );

    SET XACT_ABORT ON
    BEGIN TRY
	
	IF @mapCodeInt IS NULL
		SET @mapCodeInt = ISNULL(@mapCodeInt,@agentId)

        CREATE TABLE #msg ( errorCode INT , msg VARCHAR(100) , id INT )

        DECLARE @sql VARCHAR(MAX) ,
            @oldValue VARCHAR(MAX) ,
            @newValue VARCHAR(MAX) ,
            @tableName VARCHAR(50) ,
            @logIdentifier VARCHAR(100) ,
            @logParamMain VARCHAR(100) ,
            @tableAlias VARCHAR(100) ,
            @modType VARCHAR(6) ,
            @module INT ,
            @select_field_list VARCHAR(MAX) ,
            @extra_field_list VARCHAR(MAX) ,
            @table VARCHAR(MAX) ,
            @sql_filter VARCHAR(MAX) ,
            @ApprovedFunctionId INT		
				
        SELECT  @logIdentifier = 'agentId' , @logParamMain = 'agentMaster' , @tableAlias = 'Agent Setup'
				,@module = 20 , @ApprovedFunctionId = 20111030	
IF @flag = 'au'
BEGIN
    SELECT  @agentId = agentId
    FROM    applicationUsers WITH ( NOLOCK )
    WHERE   userName = @user
    SELECT  agentId ,
            agentName ,
            agentType = ISNULL(agentType, 0)
    FROM    agentMaster WITH ( NOLOCK )
    WHERE   agentId = @agentId
    RETURN
END	
ELSE IF @flag = 'agl'
BEGIN
    SELECT  agentId ,
            agentName ,
            agentAddress
    FROM    agentMaster WITH ( NOLOCK )
    WHERE   agentCountry = @agentCountry
            AND ISNULL(isSettlingAgent, 'N') = 'Y'
            AND ISNULL(isDeleted, 'N') <> 'Y'
            AND ISNULL(isActive, 'N') = 'Y'
    ORDER BY agentName ASC
    RETURN
END	
ELSE IF @flag = 'banklist'		-- Populate Bank List for Domestic A/C Deposit(Send)
BEGIN
  --SELECT  agentId ,
  --              agentName
  --      FROM    agentMaster WITH ( NOLOCK )
  --      WHERE   IsDom = 1
  --              AND ISNULL(isDeleted, 'N') <> 'Y'
  --              AND ISNULL(isActive, 'N') = 'Y'
  --              AND ISNULL(agentBlock, 'U') <> 'Y'
  --      ORDER BY agentName
	SELECT  agentId ,agentName
		FROM    agentMaster WITH ( NOLOCK )
		WHERE   ISNULL(isActive, 'N') = 'Y'
				AND agentType=2903
		ORDER BY agentName

END	
ELSE IF @flag = 'banklist2'		--All Bank and FInance list doing A/C Deposit(International/Domestic)
BEGIN
    SELECT  agentId ,
            agentName
    FROM    agentMaster WITH ( NOLOCK )
    WHERE   ( ( 
				( allowAccountDeposit = 'Y' OR payOption IN ( 20 )) AND agentType = 2903 )
                OR ( payOption = 40 AND agentType = 2905
				)
            )
            AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(agentBlock, 'U') <> 'B'
    ORDER BY agentName
END
ELSE IF @flag = 'bbl'			--Populate Bank Branch list
BEGIN
	IF EXISTS(	
		SELECT  agentId ,agentName = UPPER(agentName)
		FROM    agentMaster WITH ( NOLOCK )
		WHERE  ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') <> 'Y'
				AND ISNULL(agentBlock, 'U') <> 'B'
				AND parentId = @parentId AND agentType = 2904
	)
	BEGIN
		SELECT  agentId ,
				agentName = UPPER(agentName)
		FROM    agentMaster WITH ( NOLOCK )
		WHERE  ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') <> 'Y'
				AND ISNULL(agentBlock, 'U') <> 'B'
				AND parentId = @parentId
				AND agentType = 2904
		ORDER BY agentName
		RETURN
	END
    
	SELECT  agentId =0,	agentName = 'Any Branch'

    RETURN
END	

ELSE IF @flag = 'bc'			--breadCrumb
BEGIN 
    DECLARE @breadCrumb VARCHAR(500) = NULL ,@agName VARCHAR(MAX)
    WHILE ( @agentId <> 0 )
        BEGIN
            SELECT  @agentName = agentName ,
                    @agentId = parentId ,
                    @agentType = agentType ,
                    @actAsBranch = ISNULL(actAsBranch,
                                'N')
            FROM    agentMaster WITH ( NOLOCK )
            WHERE   agentId = @agentId
            IF @agentType = 2900
                SET @agName = '<img src="'+ @urlRoot + '/Images/headoffice.png" />'+ @agentName
            ELSE IF @agentType = 2901
                    SET @agName = '<img src="'+ @urlRoot+ '/Images/hub.png" />'+ @agentName
            ELSE IF @agentType = 2902
                    SET @agName = '<img src="'+ @urlRoot+ '/Images/superagent.png" />'+ @agentName
            ELSE IF @agentType = 2903 AND @actAsBranch = 'N'
                    SET @agName = '<img src="' + @urlRoot + '/Images/agents.png" />'+ @agentName
            ELSE IF @agentType = 2903 AND @actAsBranch = 'Y'
					SET @agName = '<img src="'+ @urlRoot + '/Images/branch.png" />' + @agentName
            ELSE IF @agentType = 2904
                    SET @agName = '<img src="'+ @urlRoot + '/Images/branch.png" />'+ @agentName
            SET @breadCrumb = @agName + ISNULL(' » ' + @breadCrumb,'')
        END
    SELECT  @breadCrumb
    RETURN
END	
ELSE IF @flag = 'hl'
BEGIN
 SELECT  [0] , [1]
    FROM ( SELECT    NULL [0] , 'All' [1]
                UNION ALL
                SELECT    am.agentId [0] ,am.agentName [1] FROM agentMaster am  WITH ( NOLOCK )
                WHERE     am.agentType = 2901
                        AND ISNULL(am.isDeleted, 'N') <> 'Y'
                        AND ISNULL(am.isActive,'N') = 'Y'
            ) x
    ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END
    RETURN
END	
ELSE IF @flag = 'hl2'
BEGIN
    SELECT  agentId ,
            agentName
    FROM    agentMaster WITH ( NOLOCK )
    WHERE   agentType = 2901
            AND ISNULL(isDeleted, 'N') <> 'Y'
            AND ISNULL(isActive, 'N') = 'Y'	
    RETURN
END	
ELSE IF @flag = 'sal'				-- Select Super Agent
BEGIN
    SELECT  agentId ,
            agentName
    FROM    agentMaster WITH ( NOLOCK )
    WHERE   agentType = 2902
--AND agentCountryId = @agentCountry
            AND ISNULL(isDeleted,
                    'N') <> 'Y'
            AND ISNULL(isActive,
                    'N') = 'Y'
    RETURN
END	
ELSE IF @flag = 'alc'				-- Select Agent According to CountryId
BEGIN
    SELECT  agentId ,
            agentName
    FROM    agentMaster WITH ( NOLOCK )
    WHERE   agentType = 2903
AND agentCountryId = @agentCountryId
AND ISNULL(isDeleted,'N') = 'N'
--AND ISNULL(isActive, 'N') = 'Y'
            AND ISNULL(agentBlock,'U') <> 'B'
    ORDER BY agentName
    RETURN
END
ELSE IF @flag = 'alc1'				-- Select Agent According to Country Name
BEGIN
    SELECT
            agentId ,
            agentName
    FROM  agentMaster WITH ( NOLOCK )
    WHERE agentType = 2903
            AND agentCountry = @agentCountry
            AND ISNULL(isDeleted,
            'N') = 'N'
--AND ISNULL(isActive, 'N') = 'Y'
            AND ISNULL(agentBlock,
            'U') <> 'B'
    ORDER BY agentName
    RETURN
END	
ELSE IF @flag = 'cal'
BEGIN
    SELECT
        countryId ,
        countryName
    FROM countryMaster WITH ( NOLOCK )
    WHERE  ISNULL(isDeleted,'N') <> 'Y'
        AND ISNULL(isOperativeCountry,'N') = 'Y'
    ORDER BY countryName
    RETURN
END	
ELSE IF @flag = 'al'				-- Select Agent according to Super Agent and Country
BEGIN
    SELECT agentId ,agentName
    FROM agentMaster WITH ( NOLOCK )
    WHERE  agentType = 2903
    AND agentCountryId = @agentCountry
    AND parentId = @parentId AND ISNULL(isActive, 'N') = 'Y'	
	AND isSettlingAgent = 'Y'

    RETURN	
END	
ELSE IF @flag = 'al1'				-- Select Agent according to Super Agent and Country
BEGIN
	SELECT agentId ,agentName
	FROM agentMaster WITH ( NOLOCK )
	WHERE agentType = 2903
	AND agentCountry = @agentCountry
	AND parentId = @parentId
	AND ISNULL(isDeleted,'N') <> 'Y'
	AND ISNULL(isActive,'N') = 'Y'	
RETURN	
END	
ELSE IF @flag = 'al2'				-- Select Agent according to Hub and Country
BEGIN
	;
	WITH
	ret
	AS ( SELECT agentId ,parentId ,agentType ,agentCountryId ,agentName ,actAsBranch ,isDeleted ,isActive
		FROM agentMaster (nolock)	WHERE agentId = @agentId
		UNION ALL
		SELECT t.agentId ,t.parentId ,t.agentType ,t.agentCountryId ,t.agentName ,t.actAsBranch ,t.isDeleted ,t.isActive
		FROM agentMaster t
		INNER JOIN ret r ON t.parentId = r.agentId
	)
	SELECT
	agentId ,agentName
	FROM ret WITH ( NOLOCK )
	WHERE ( agentType = 2903 )
	AND agentCountryId = ISNULL(@agentCountry,agentCountryId)
	AND ISNULL(isDeleted,'N') <> 'Y' AND ISNULL(isActive,'N') = 'Y'	
RETURN	
END	
ELSE IF @flag = 'al3' --Select All Agent
BEGIN
	SELECT agentId ,agentName
	FROM agentMaster(NOLOCK)
	WHERE
	--agentType = 2903 AND 
	ISNULL(isSettlingAgent,'N') = 'Y'
	AND ISNULL(isDeleted,'N') <> 'Y'
	ORDER BY agentName
RETURN
END	
ELSE IF @flag = 'al4' --Select Agent According to User
BEGIN
	SELECT @parentId = agentId
	FROM applicationUsers WITH ( NOLOCK )
	WHERE userName = @user;
	WITH
	ret
	AS ( SELECT * FROM agentMaster( NOLOCK )
	WHERE agentId = @parentId
	UNION ALL
	SELECT t.* FROM agentMaster t( NOLOCK )
	INNER JOIN ret r ON t.parentId = r.agentId
	)
	SELECT agentId , agentName
	FROM ret WITH ( NOLOCK )
	WHERE ISNULL(isDeleted, 'N') <> 'Y'
	AND ISNULL(isActive, 'N') = 'Y'	
RETURN
END	
ELSE IF @flag = 'al5' --Select All Agent
BEGIN
	SELECT agentId ,agentName
	FROM agentMaster (NOLOCK)
	WHERE	( 
		( agentType = 2903 AND ISNULL(actAsBranch,'N') = 'Y')
		OR agentType = 2903 OR agentType = 2901
		)
	AND ISNULL(isDeleted,'N') <> 'Y'
	AND ISNULL(isActive,'N') = 'Y'
	AND ISNULL(agentBlock,'U') <> 'B'
	ORDER BY agentName
RETURN
END	
ELSE IF @flag = 'al6' --Select international Agent
BEGIN
	SELECT agentId , agentName
	FROM agentMaster(NOLOCK)
	WHERE agentCountry <> 'Nepal'
	AND ISNULL(isSettlingAgent, 'N') = 'Y'
	AND ISNULL(isDeleted, 'N') <> 'Y'
	--AND ISNULL(isActive, 'N') = 'Y'	
	AND ISNULL(agentBlock, 'U') <> 'B'
	ORDER BY agentName
RETURN
END	
ELSE IF @flag = 'al7' --Select domestic Agent
BEGIN
	SELECT agentId , agentName
	FROM agentMaster(NOLOCK)
	WHERE agentType = 2903
	AND agentCountry = 'Nepal'
	AND ISNULL(isDeleted, 'N') <> 'Y'
	AND ISNULL(isActive, 'N') = 'Y'
	ORDER BY agentName
RETURN
END	
ELSE IF @flag = 'all' --Select Agent from locationId
BEGIN
	SELECT agentId , agentName
	FROM agentMaster(NOLOCK)
	WHERE agentType IN ( 2903, 2904 )
	AND agentLocation = @agentLocation
	AND ISNULL(isSettlingAgent, 'N') = 'Y'
	AND ISNULL(isDeleted, 'N') <> 'Y'
	--AND ISNULL(isActive, 'N') = 'Y'
	AND ISNULL(agentBlock, 'U') <> 'B'
	ORDER BY agentName
RETURN
END	
ELSE  IF @flag = 'bl'				-- Select Branch According to Agent
BEGIN
	SELECT  agentId ,
            agentName = UPPER(agentName)
    FROM    agentMaster WITH ( NOLOCK )
    WHERE  ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			AND ISNULL(agentBlock, 'U') <> 'B'
			AND agentType=2904
			--AND IsIntl = 1
			AND parentId = @parentId
    ORDER BY agentAddress
    RETURN
RETURN
END	
ELSE  IF @flag = 'bankbl'				-- Select Branch According to Agent
BEGIN
	SELECT  agentId ,
            agentName = UPPER(agentName)
    FROM    agentMaster WITH ( NOLOCK )
    WHERE  ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') <> 'Y'
			AND ISNULL(agentBlock, 'U') <> 'B'
			AND agentType=2903
			AND IsIntl = 1
			--AND parentId = @parentId
    ORDER BY agentAddress
    RETURN
RETURN
END	
ELSE  IF @flag = 'hc'						--hasChanged
BEGIN
	SELECT
	[0] , [1]
	FROM
	( SELECT NULL [0] , 'All' [1]
		UNION ALL
	SELECT 'Y' [0] , 'Yes' [1]
	UNION ALL
	SELECT 'N' [0] , 'No' [1]
	) x
	ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END
RETURN
END	
ELSE  IF @flag = 'rbl'					-- ## Regional Branch List
BEGIN
	SELECT am.agentId , am.agentName
	FROM agentMaster am
	WITH ( NOLOCK )
	INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId
	WHERE rba.agentId = @agentId
	AND ISNULL(rba.isDeleted, 'N') <> 'Y'
	AND ISNULL(rba.isActive, 'Y') = 'Y'
RETURN
END	
		
ELSE IF @flag = 'rblByAId'					--Regional Branch List
BEGIN
	SELECT mapCodeInt agentId , agentName
	FROM agentMaster a
	WITH ( NOLOCK )
	INNER JOIN regionalBranchAccessSetup rba ON a.agentId = rba.memberAgentId
	LEFT JOIN api_districtList b
	WITH ( NOLOCK ) ON a.agentLocation = b.districtCode
	WHERE rba.agentId = @agentId
	AND ISNULL(a.isDeleted, 'N') = 'N'
	AND ISNULL(a.isActive, 'N') = 'Y'
						
RETURN
END

ELSE IF @flag = 'rblByAId2'					-- ## Regional Branch List
BEGIN
	SELECT   agentId = a.agentId ,
   agentName = a.agentName
    FROM     agentMaster a WITH ( NOLOCK )
    WHERE    a.parentId = @parentId
            AND ISNULL(a.isDeleted, 'N') = 'N'
            AND ISNULL(a.isActive, 'N') = 'Y'
            AND ISNULL(a.apiAgent, 'N') = 'N'
    ORDER BY a.agentName;

RETURN
END

ELSE IF @flag = 'n'
BEGIN
	SELECT COUNT(*)
	FROM
	agentMaster
	WHERE
	( ISNULL(actAsBranch, 'N') = 'Y' OR agentType = 2904 )
	AND ISNULL(isDeleted, 'N') = 'N'
END
	
ELSE IF @flag IN ('s', 's2' )
BEGIN
	DECLARE @hasRight CHAR(1)
	SET @hasRight = dbo.FNAHasRight(@user,CAST(@ApprovedFunctionId AS VARCHAR))
	IF ( @user IN ('admin','admin1' ) OR @parentId = 10001)
	BEGIN
		SET @table = '(
			SELECT
			parentId = ISNULL(amh.parentId, am.parentId)
			,agentId = ISNULL(amh.agentId, am.agentId)
			,agentCode = ISNULL(amh.agentCode, am.agentCode)
			,mapCodeInt = ISNULL(amh.mapCodeInt, am.mapCodeInt)
			,agentName = ISNULL(amh.agentName, am.agentName)
			,agentAddress = ISNULL(amh.agentAddress, am.agentAddress)
			,agentCity = ISNULL(amh.agentCity, am.agentCity)
			,agentCountry = ISNULL(amh.agentCountry, am.agentCountry)
			,agentState = ISNULL(amh.agentState, am.agentState)
			,agentDistrict = ISNULL(amh.agentDistrict, am.agentDistrict)
			,agentZip = ISNULL(amh.agentZip, am.agentZip)
			,agentLocation = ISNULL(amh.agentLocation, am.agentLocation)
			,agentPhone1 = ISNULL(amh.agentPhone1, am.agentPhone1)
			,agentPhone2 = ISNULL(amh.agentPhone2, am.agentPhone2)
			,agentFax1 = ISNULL(amh.agentFax1, am.agentFax1)
			,agentFax2 = ISNULL(amh.agentFax2, am.agentFax2)
			,agentMobile1 = ISNULL(amh.agentMobile1, am.agentMobile1)
			,agentMobile2 = ISNULL(amh.agentMobile2, am.agentMobile2)
			,agentEmail1 = ISNULL(amh.agentEmail1, am.agentEmail1)
			,agentEmail2 = ISNULL(amh.agentEmail2, am.agentEmail2)
			,bankBranch=ISNULL(amh.bankBranch, am.bankBranch)
			,bankCode=ISNULL(amh.bankCode, am.bankCode)
			,bankAccountNumber=ISNULL(amh.bankAccountNumber, am.bankAccountNumber)
			,accountHolderName=ISNULL(amh.accountHolderName, am.accountHolderName)
			,businessOrgType = ISNULL(amh.businessOrgType, am.businessOrgType)
			,businessType = ISNULL(amh.businessType, am.businessType)
			,agentRole = ISNULL(amh.agentRole, am.agentRole)
			,agentType = ISNULL(amh.agentType, am.agentType)
			,actAsBranch = ISNULL(amh.actAsBranch, am.actAsBranch)
			,contractExpiryDate = ISNULL(amh.contractExpiryDate, am.contractExpiryDate)
			,renewalFollowupDate = ISNULL(amh.renewalFollowupDate, am.renewalFollowupDate)
			,isSettlingAgent = ISNULL(amh.isSettlingAgent, am.isSettlingAgent)
			,agentGrp = ISNULL(amh.agentGrp, am.agentGrp)
			,businessLicense = ISNULL(amh.businessLicense, am.businessLicense)
			,agentBlock = ISNULL(amh.agentBlock, am.agentBlock)
			,isActive = ISNULL(amh.isActive, am.isActive)
			,localTime = ISNULL(amh.localTime, am.localTime)
			,am.createdDate
			,am.createdBy
			,amh.modType
			,modifiedDate = CASE WHEN am.approvedBy IS NULL THEN am.createdDate ELSE amh.createdDate END
			,modifiedBy = CASE WHEN am.approvedBy IS NULL THEN am.createdBy ELSE amh.createdBy END
			,hasChanged = CASE WHEN (am.approvedBy IS NULL) OR 
			(amh.agentId IS NOT NULL)  
			THEN ''Y'' ELSE ''N'' END
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentMasterMod amh ON am.agentId = amh.agentId
			AND (
			amh.createdBy = ''' + @user + ''' 
			OR ''Y'' = ''' + @hasRight + '''
			)
			WHERE ISNULL(am.isDeleted, ''N'')  <> ''Y''
			AND (
			am.approvedBy IS NOT NULL 
			OR am.createdBy = ''' + @user + ''' 
			OR ''Y'' = ''' + @hasRight
			+ '''
			)
			--AND NOT(ISNULL(amh.modType, '''') = ''D'' AND amh.createdBy = '''
			+ @user + ''')  
			) '

	--print @table
	END
ELSE
	BEGIN
			IF OBJECT_ID('tempdb..#agentId') IS NOT NULL
	DROP TABLE #agentId
		
		CREATE TABLE #agentId ( agentId INT )	
				INSERT INTO #agentId
	SELECT agentId
	FROM agentMaster(nolock) WHERE ISNULL(isDeleted,'N') = 'N' 
		
				DELETE FROM #agentId
FROM #agentId ag
INNER JOIN agentGroupMaping agm ON agm.agentId = ag.agentId
WHERE agm.groupCat = '6900' AND ISNULL(agm.isDeleted, 'N') = 'N'
			
INSERT INTO #agentId
SELECT DISTINCT agm.agentId
FROM userGroupMapping ugm (nolock)
INNER JOIN agentGroupMaping agm (nolock) ON agm.groupDetail = ugm.groupDetail
AND ISNULL(agm.isDeleted, 'N') = 'N'
AND ISNULL(ugm.isDeleted,'N') = 'N'
WHERE ugm.userName = @user

																																																																															SET @table = '(
SELECT
parentId = ISNULL(amh.parentId, am.parentId)
,agentId = ISNULL(amh.agentId, am.agentId)
,agentCode = ISNULL(amh.agentCode, am.agentCode)
,mapCodeInt = ISNULL(amh.mapCodeInt, am.mapCodeInt)
,agentName = ISNULL(amh.agentName, am.agentName)
,agentAddress = ISNULL(amh.agentAddress, am.agentAddress)
,agentCity = ISNULL(amh.agentCity, am.agentCity)
,agentCountry = ISNULL(amh.agentCountry, am.agentCountry)
,agentState = ISNULL(amh.agentState, am.agentState)
,agentDistrict = ISNULL(amh.agentDistrict, am.agentDistrict)
,agentZip = ISNULL(amh.agentZip, am.agentZip)
,agentLocation = ISNULL(amh.agentLocation, am.agentLocation)
,agentPhone1 = ISNULL(amh.agentPhone1, am.agentPhone1)
,agentPhone2 = ISNULL(amh.agentPhone2, am.agentPhone2)
,agentFax1 = ISNULL(amh.agentFax1, am.agentFax1)
,agentFax2 = ISNULL(amh.agentFax2, am.agentFax2)
,agentMobile1 = ISNULL(amh.agentMobile1, am.agentMobile1)
,agentMobile2 = ISNULL(amh.agentMobile2, am.agentMobile2)
,agentEmail1 = ISNULL(amh.agentEmail1, am.agentEmail1)
,agentEmail2 = ISNULL(amh.agentEmail2, am.agentEmail2)
,bankBranch=ISNULL(amh.bankBranch, am.bankBranch)
,bankCode=ISNULL(amh.bankCode, am.bankCode)
,bankAccountNumber=ISNULL(amh.bankAccountNumber, am.bankAccountNumber)
,accountHolderName=ISNULL(amh.accountHolderName, am.accountHolderName)
,businessOrgType = ISNULL(amh.businessOrgType, am.businessOrgType)
,businessType = ISNULL(amh.businessType, am.businessType)
,agentRole = ISNULL(amh.agentRole, am.agentRole)
,agentType = ISNULL(amh.agentType, am.agentType)
,actAsBranch = ISNULL(amh.actAsBranch, am.actAsBranch)
,contractExpiryDate = ISNULL(amh.contractExpiryDate, am.contractExpiryDate)
,renewalFollowupDate = ISNULL(amh.renewalFollowupDate, am.renewalFollowupDate)
,isSettlingAgent = ISNULL(amh.isSettlingAgent, am.isSettlingAgent)
,agentGrp = ISNULL(amh.agentGrp, am.agentGrp)
,businessLicense = ISNULL(amh.businessLicense, am.businessLicense)
,agentBlock = ISNULL(amh.agentBlock, am.agentBlock)
,isActive = ISNULL(amh.isActive, am.isActive)
,localTime = ISNULL(amh.localTime, am.localTime)
,am.createdDate
,am.createdBy
,amh.modType
,modifiedDate = CASE WHEN am.approvedBy IS NULL THEN am.createdDate ELSE amh.createdDate END
,modifiedBy = CASE WHEN am.approvedBy IS NULL THEN am.createdBy ELSE amh.createdBy END
,hasChanged = CASE WHEN (am.approvedBy IS NULL) OR 
(amh.agentId IS NOT NULL)  
THEN ''Y'' ELSE ''N'' END
FROM agentMaster am WITH(NOLOCK)
INNER JOIN
(
--select distinct agentId from 
--(
--	select agentId from agentMaster
--	where agentId not in(
--	select distinct b.agentId from agentGroupMaping b where	b.groupCat=''6900'' and isDeleted is null) 
--	union all				
--	select distinct b.agentId from userGroupMapping a inner join agentGroupMaping b on a.groupDetail=b.groupDetail
--	where a.userName=''' + @user
+ '''  and b.isDeleted is null
--)a 			
							
SELECT DISTINCT agentId FROM #agentId 
								
)b on am.agentId = b.agentId
LEFT JOIN agentMasterMod amh ON am.agentId = amh.agentId
AND (
amh.createdBy = ''' + @user + ''' 
OR ''Y'' = ''' + @hasRight + '''
)
WHERE ISNULL(am.isDeleted, ''N'')  <> ''Y''
AND (
am.approvedBy IS NOT NULL 
OR am.createdBy = ''' + @user + ''' 
OR ''Y'' = ''' + @hasRight
+ '''
)
--AND NOT(ISNULL(amh.modType, '''') = ''D'' AND amh.createdBy = '''
+ @user + ''')  
) '
	PRINT(@table)
	END
END	
	
ELSE IF @flag = 'a'
BEGIN
	IF EXISTS ( SELECT  'X' FROM    agentMasterMod WITH ( NOLOCK ) WHERE   agentId = @agentId AND createdBy = @user )
	BEGIN
		SELECT  m.* ,
				contractExpiryDate1 = CONVERT(VARCHAR, m.contractExpiryDate, 101) ,
				renewalFollowupDate1 = CONVERT(VARCHAR, m.renewalFollowupDate, 101) ,
				am.modifiedBy ,
				am.modifiedDate,
				am.branchCode
		FROM  agentMasterMod m WITH ( NOLOCK )
				LEFT JOIN agentMaster am WITH ( NOLOCK ) ON m.agentId = am.agentId
		WHERE   m.agentId = @agentId	
	END
	ELSE
	BEGIN
		SELECT  * ,
				contractExpiryDate1 = CONVERT(VARCHAR, contractExpiryDate, 101) ,
				renewalFollowupDate1 = CONVERT(VARCHAR, renewalFollowupDate, 101)
		FROM    agentMaster
		WHERE   agentId = @agentId		
	END
END
	
IF @flag = 'pullDefault'
BEGIN
		
    SELECT  * ,
            contractExpiryDate1 = CONVERT(VARCHAR, contractExpiryDate, 101) ,
            renewalFollowupDate1 = CONVERT(VARCHAR, renewalFollowupDate, 101)
    FROM    agentMaster
    WHERE   agentId = @agentId		
		
END

ELSE IF @flag = 'i'
BEGIN
    IF EXISTS ( SELECT  'X' FROM    agentMaster(nolock)
                WHERE   agentName = @agentName
                AND agentType IN ( 2901, 2902, 2903, 2904 )
                AND ISNULL(isDeleted, 'N') <> 'Y'
                AND ISNULL(isActive, 'N') = 'Y' )
    BEGIN
        EXEC proc_errorHandler 1, 'Agent with this name already exists', NULL
		RETURN
    END
    IF @payOption = 20
        SET @mapCodeIntAc = @mapCodeInt
		
    BEGIN TRANSACTION
			
	INSERT  INTO agentMaster
		(parentId , agentName , agentAddress , agentCity , agentCountryId , agentCountry , agentState ,  agentDistrict ,
		agentZip , agentLocation , agentPhone1 , agentPhone2 , agentFax1 , agentFax2 , agentMobile1 , agentMobile2 ,  agentEmail1 ,
		agentEmail2 , bankBranch, bankCode, bankAccountNumber, accountHolderName, businessOrgType , businessType , agentRole ,
		agentType , allowAccountDeposit , actAsBranch , contractExpiryDate , renewalFollowupDate , isSettlingAgent ,  agentGrp ,
		businessLicense , agentBlock , agentCompanyName , companyAddress , companyCity , companyCountry , companyState ,
		companyDistrict , companyZip , companyPhone1 , companyPhone2 ,companyFax1 , companyFax2 , companyEmail1 , companyEmail2 ,
		localTime , localCurrency , agentDetails ,  createdDate , createdBy , headMessage , mapCodeInt , mapCodeDom ,
		commCodeInt , commCodeDom , joinedDate , mapCodeIntAc , mapCodeDomAc , payOption , isActive,isMigrated , agentSettCurr , 
		contactPerson1 , contactPerson2 ,isHeadOffice, IsIntl, isApiPartner, routingCode,branchCode
	)
	SELECT  @parentId , @agentName , @agentAddress , @agentCity , @agentCountryId , @agentCountry , @agentState , @agentDistrict ,
		@agentZip , @agentLocation , @agentPhone1 ,@agentPhone2 , @agentFax1 , @agentFax2 , @agentMobile1 , @agentMobile2 , @agentEmail1 ,
		@agentEmail2 , @bankBranch, @bankCode, @bankAccountNumber, @accHolderName, @businessOrgType ,@businessType ,@agentRole ,
		@agentType ,@allowAccountDeposit ,@actAsBranch ,@contractExpiryDate ,@renewalFollowupDate ,@isSettlingAgent , @agentGroup ,
		@businessLicense ,@agentBlock ,@agentcompanyName ,@companyAddress ,@companyCity ,@companyCountry ,@companyState ,
		@companyDistrict ,@companyZip ,@companyPhone1 ,@companyPhone2 ,@companyFax1 ,@companyFax2 ,@companyEmail1 ,@companyEmail2 ,
		@localTime ,@localCurrency ,@agentDetails ,GETDATE() ,@user ,@headMessage ,@mapCodeInt ,@mapCodeDom ,@commCodeInt ,@commCodeDom ,
		@joinedDate ,@mapCodeIntAc ,@mapCodeDomAc ,@payOption ,'N','Y' ,@agentSettCurr ,
		@contactPerson1 ,@contactPerson2 ,@isHeadOffice, @IsIntl, @isApiPartner, @partnerBankcode,@branchCode
                    
    SET @agentId = SCOPE_IDENTITY()
			
    UPDATE  agentMaster
    SET     agentCode = 'JME' + CAST(@agentId AS VARCHAR) ,
            mapCodeInt = @agentId ,
            mapCodeDom = @agentId ,
            mapCodeIntAc = @agentId ,
            mapCodeDomAc = @agentId ,
            commCodeInt = '10' + CAST(@agentId AS VARCHAR) ,
            commCodeDom = '11' + CAST(@agentId AS VARCHAR)
    WHERE   agentId = @agentId
			
    COMMIT TRANSACTION
        
    EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentId
	--INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
	INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
	VALUES (@agentId,CASE WHEN @actAsBranch = 'Y' THEN 'B' ELSE 'A' END,@agentName,0,0,0,0)
END
    
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS ( SELECT  'X' FROM    agentMaster WITH ( NOLOCK ) 
		WHERE agentId = @agentId AND approvedBy IS NULL AND createdBy <> @user )
	BEGIN
		EXEC proc_errorHandler 1,'You can not modify this record. Previous Modification has not been approved yet.',@agentId
		RETURN
	END 
	IF EXISTS ( SELECT  'X'	FROM    agentMasterMod WITH ( NOLOCK )WHERE   agentId = @agentId AND createdBy <> @user )
	BEGIN
		EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.',@agentId
		RETURN
	END
	IF @payOption = 20
		SET @mapCodeIntAc = @mapCodeInt	
	
	IF EXISTS ( SELECT  'X' FROM    agentMaster WITH ( NOLOCK )  
		WHERE   agentId = @agentId AND approvedBy IS NULL AND createdBy = @user )
	BEGIN

	UPDATE  agentMaster
	SET     
		agentName = @agentName,
		agentAddress = @agentAddress ,
		agentCity = @agentCity ,
		agentCountryId = @agentCountryId ,
		agentCountry = @agentCountry ,
		agentState = @agentState ,
		agentDistrict = @agentDistrict ,
		agentZip = @agentZip ,
		agentLocation = @agentLocation ,
		agentPhone1 = @agentPhone1 ,
		agentPhone2 = @agentPhone2 ,
		agentFax1 = @agentFax1 ,
		agentFax2 = @agentFax2 ,
		agentMobile1 = @agentMobile1 ,
		agentMobile2 = @agentMobile2 ,
		agentEmail1 = @agentEmail1 ,
		agentEmail2 = @agentEmail2 ,
		bankBranch = @bankBranch,
		bankCode = @bankCode,
		bankAccountNumber = @bankAccountNumber,										
		accountHolderName=@accHolderName,
		businessOrgType = @businessOrgType ,
		businessType = @businessType ,
		agentRole = @agentRole ,
		agentType = @agentType ,
		allowAccountDeposit = @allowAccountDeposit ,
		contractExpiryDate = @contractExpiryDate ,
		renewalFollowupDate = @renewalFollowupDate ,
		agentGrp = @agentGroup ,
		businessLicense = @businessLicense ,
		agentBlock = @agentBlock ,
		agentCompanyName = @agentcompanyName ,										
		companyAddress = @companyAddress ,
		companyCity = @companyCity ,
		companyCountry = @companyCountry ,
		companyState = @companyState ,
		companyDistrict = @companyDistrict ,
		companyZip = @companyZip ,
		companyPhone1 = @companyPhone1 ,
		companyPhone2 = @companyPhone2 ,
		companyFax1 = @companyFax1 ,
		companyFax2 = @companyFax2 ,
		companyEmail1 = @companyEmail1 ,
		companyEmail2 = @companyEmail2 ,
		localTime = @localTime ,
		localCurrency = @localCurrency ,
		isActive = @isActive ,
		agentDetails = @agentDetails ,
		headMessage = @headMessage ,
		mapCodeInt = @mapCodeInt ,
		mapCodeDom = @mapCodeDom ,
		commCodeInt = @commCodeInt ,
		commCodeDom = @commCodeDom ,
		mapCodeIntAc = @mapCodeIntAc ,
		mapCodeDomAc = @mapCodeDomAc ,
		payOption = @payOption ,
		agentSettCurr = @agentSettCurr ,
		contactPerson1 = @contactPerson1 ,
		contactPerson2 = @contactPerson2 ,
		isHeadOffice = @isHeadOffice ,
		isApiPartner = @isApiPartner ,
		IsIntl = @isIntl,
		routingCode = @partnerBankcode
	WHERE   agentId = @agentId

	EXEC FastMoneyPro_account.[dbo].[spa_agentdetail] @flag = 'u',
		@agent_id = @agentId,
		@agent_name = @agentName,
		@agent_short_name = NULL,
		@agent_address = '5',
		@agent_city = @agentCity,
		@agent_address2 = @agentAddress,
		@agent_phone = @agentPhone1,
		@agent_fax = @agentFax1,
		@agent_email = @agentEmail1,
		@agent_contact_person = NULL,
		@agent_contact_person_mobile = NULL,
		@agent_status = @isActive,
		@bankbranch = @bankBranch,
		@bankcode	= @bankCode,
		@bankaccno	= @bankAccountNumber,
		@accholderName=@accHolderName,
		@MAP_code = @mapCodeInt,
		@MAP_code2 = @commCodeInt,
		@agenttype = @agentType,
		@agent_imecode = @mapCodeDom,
		@TDS_PCNT = 0.00,
		@tid = @commCodeDom,
		@agentzone = @agentState,
		@agentdistrict = @agentdistrict,
		@agent_panno = @businessLicense,
		@username = @user,
		@company_id = '1',
		@commissionDeduction = 5,
		@agent_country = @agentCountry
	END 
	ELSE
	BEGIN																																																																																																																									BEGIN
		DELETE  FROM agentMasterMod WHERE   agentId = @agentId

		INSERT  INTO agentMasterMod
		(
			agentId , agentCode ,parentId ,agentName ,agentAddress ,agentCity ,agentCountryId ,agentCountry ,agentState ,agentDistrict ,
			agentZip ,agentLocation ,agentPhone1 ,agentPhone2 ,agentFax1 ,agentFax2 ,agentMobile1 ,agentMobile2 ,agentEmail1 ,agentEmail2 ,
			bankbranch,bankcode,bankaccountnumber,accountHolderName,businessOrgType ,businessType ,agentRole ,agentType ,
			allowAccountDeposit ,contractExpiryDate ,renewalFollowupDate ,isSettlingAgent ,agentGrp ,businessLicense ,agentBlock ,
			agentCompanyName ,companyAddress ,companyCity,companyCountry ,companyState ,companyDistrict ,companyZip ,companyPhone1 ,
			companyPhone2 ,companyFax1 ,companyFax2 ,companyEmail1 ,companyEmail2 ,localTime ,localCurrency ,isActive ,agentDetails ,
			createdDate ,createdBy ,modType ,headMessage ,mapCodeInt ,mapCodeDom ,commCodeInt ,commCodeDom ,mapCodeIntAc ,
			mapCodeDomAc ,payOption ,agentSettCurr ,contactPerson1 ,contactPerson2 ,isHeadOffice, IsIntl, isApiPartner, routingCode
		)
		SELECT  
		@agentId ,@agentCode ,@parentId ,@agentName ,@agentAddress ,@agentCity ,@agentCountryId ,@agentCountry ,@agentState ,@agentDistrict ,
		@agentZip ,@agentLocation ,@agentPhone1 ,@agentPhone2 ,@agentFax1 ,@agentFax2 ,@agentMobile1 ,@agentMobile2 ,@agentEmail1 ,@agentEmail2 ,
		@bankbranch,@bankcode,@bankaccountnumber,@accHolderName,@businessOrgType ,@businessType ,@agentRole ,@agentType ,
		@allowAccountDeposit ,@contractExpiryDate ,@renewalFollowupDate ,@isSettlingAgent ,@agentGroup ,@businessLicense ,@agentBlock ,
		@agentcompanyName ,@companyAddress ,@companyCity ,@companyCountry ,@companyState ,@companyDistrict ,@companyZip ,@companyPhone1 ,
		@companyPhone2 ,@companyFax1 ,@companyFax2 ,@companyEmail1 ,@companyEmail2 ,@localTime ,@localCurrency ,@isActive ,@agentDetails ,
		GETDATE() ,@user ,'U' ,@headMessage ,@mapCodeInt ,@mapCodeDom ,@commCodeInt ,@commCodeDom ,@mapCodeIntAc ,
		@mapCodeDomAc ,@payOption ,@agentSettCurr ,@contactPerson1 ,@contactPerson2 ,@isHeadOffice, @IsIntl, @isApiPartner, @partnerBankcode
	END
	END
	EXEC proc_errorHandler 0, 'Record updated successfully', @agentId
END

ELSE IF @flag = 'd'
BEGIN
    IF EXISTS ( SELECT  'X' FROM    agentMaster WITH ( NOLOCK )
                WHERE   agentId = @agentId AND approvedBy IS NULL  AND createdBy <> @user )
    BEGIN
        EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @agentId
        RETURN
    END 
    IF EXISTS ( SELECT  'X' FROM    agentMasterMod WITH ( NOLOCK )
                WHERE   agentId = @agentId AND createdBy <> @user )
    BEGIN
        EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.',  @agentId
        RETURN
    END
    BEGIN TRANSACTION	
    IF EXISTS ( SELECT  'X' FROM    agentMaster WITH ( NOLOCK )
                WHERE   agentId = @agentId AND approvedBy IS NULL AND createdBy = @user )
    BEGIN
        DELETE  FROM agentMaster  WHERE   agentId = @agentId
    END
    ELSE
    BEGIN
        DELETE  FROM agentMasterMod WHERE   agentId = @agentId
        INSERT  INTO agentMasterMod
		( agentId ,parentId , agentName , agentCode ,agentAddress ,agentCity ,agentCountryId ,agentCountry ,agentState ,
		agentDistrict ,agentZip ,agentLocation ,agentPhone1 ,agentPhone2 ,agentFax1 ,agentFax2 ,agentMobile1 ,agentMobile2 ,
		agentEmail1 ,agentEmail2 ,bankbranch,bankcode,bankaccountnumber,accountHolderName,businessOrgType ,businessType ,
		agentRole ,agentType ,allowAccountDeposit ,actAsBranch ,contractExpiryDate ,renewalFollowupDate ,agentGrp ,businessLicense ,
		agentBlock ,agentCompanyName ,companyAddress ,companyCity ,companyCountry ,companyState ,companyDistrict ,companyZip ,
		companyPhone1 ,companyPhone2 ,companyFax1 ,companyFax2 ,companyEmail1 ,companyEmail2 ,localTime ,localCurrency ,isActive ,
		agentDetails ,createdDate ,createdBy ,modType ,headMessage ,mapCodeInt ,mapCodeDom ,commCodeInt ,commCodeDom ,
		mapCodeIntAc ,mapCodeDomAc ,payOption ,contactPerson1 ,contactPerson2 ,isHeadOffice, routingCode
			)
        SELECT  
		agentId ,parentId ,agentName ,agentCode ,agentAddress ,agentCity ,@agentCountryId ,agentCountry ,agentState ,
		agentDistrict ,agentZip ,agentLocation ,agentPhone1 ,agentPhone2 ,agentFax1 ,agentFax2 ,agentMobile1 ,agentMobile2 ,
		agentEmail1 ,agentEmail2 ,bankbranch,bankcode,bankaccountnumber,accountHolderName,businessOrgType ,businessType ,
		agentRole ,agentType ,allowAccountDeposit ,actAsBranch ,contractExpiryDate ,renewalFollowupDate ,agentGrp ,businessLicense ,
		agentBlock ,agentCompanyName ,companyAddress ,companyCity ,companyCountry ,companyState ,companyDistrict ,companyZip ,
		companyPhone1 ,companyPhone2 ,companyFax1 ,companyFax2 ,companyEmail1 ,companyEmail2 ,localTime ,localCurrency ,isActive ,
		agentDetails ,GETDATE() ,@user ,'D' ,@headMessage ,@mapCodeInt ,@mapCodeDom ,@commCodeInt ,@commCodeDom ,
		@mapCodeIntAc ,@mapCodeDomAc ,@payOption ,@contactPerson1 ,@contactPerson2 ,isHeadOffice, @partnerBankcode
		FROM    agentMaster
		WHERE   agentId = @agentId
    END
		
    COMMIT TRANSACTION

    EXEC proc_errorHandler 0,'Record deleted successfully', @agentId
END	

ELSE IF @flag = 's'
BEGIN
	IF @sortBy IS NULL
		SET @sortBy = 'agentId'
	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'
	SET @table = '(
		SELECT
		main.parentId
		,main.agentId
		,main.agentCode
		,main.mapCodeInt
		,main.agentName                    
		,main.agentAddress 
		,main.agentCity
		,agentLocation = adl.districtName
		,main.agentDistrict
		,main.agentState
		,countryName = main.agentCountry 
		,main.agentPhone1
		,main.agentPhone2                  
		,main.agentType
		,main.actAsBranch
		,main.contractExpiryDate
		,main.renewalFollowupDate
		,main.isSettlingAgent
		,main.haschanged
		,agentType1 = sdv.detailTitle
		,main.modifiedBy
		,main.createdBy	
		,main.businessOrgType
		,main.businessType
		,main.agentBlock
		,main.isActive
		FROM ' + @table
		+ ' main 
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.agentType = sdv.valueId
		LEFT JOIN api_districtList adl WITH(NOLOCK) ON main.agentLocation = adl.districtCode
		WHERE main.agentType NOT IN (2905,2906)
	) x'
					
	SET @sql_filter = ''		

	IF @businessType IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND businessType = ''' + CAST(@businessType AS VARCHAR) +''''
		
	IF @haschanged IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
			
	IF @agentCountry IS NOT NULL
		SET @sql_filter = @sql_filter  + ' AND ISNULL(countryName, '''') = ''' + CAST(@agentCountry AS VARCHAR) + ''''
			
	IF @agentType IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND ISNULL(agentType, '''') = ' + CAST(@agentType AS VARCHAR)

	IF @agentName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
		
		
	IF @agentLocation IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') = ' + CAST(@agentLocation AS VARCHAR)
		
	IF @agentId IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND agentId = ' + CAST(@agentId AS VARCHAR)
			
	IF @parentId IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND parentId = '+ CAST(@parentId AS VARCHAR)

	IF @businessOrgType IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND isnull(businessOrgType,'''') = ''' + CAST(@businessOrgType AS VARCHAR) + ''''
		
	IF @businessType IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND isnull(businessType,'''') = ''' + CAST(@businessType AS VARCHAR) + ''''
		
	IF @actAsBranch IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND ISNULL(actAsBranch, ''N'') = ''' + @actAsBranch + ''''
		
	IF @populateBranch = 'Y'
		SET @sql_filter = @sql_filter + ' AND (ISNULL(agentType, '''') = 2904 OR actAsBranch = ''Y'')'
		
	IF @contractExpiryDate IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND contractExpiryDate = ''' + @contractExpiryDate + ''''
		
	IF @renewalFollowupDate IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND renewalFollowupDate = ''' + @renewalFollowupDate + '''' 
			
	IF @isSettlingAgent IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND ISNULL(isSettlingAgent, ''N'') = '''  + @isSettlingAgent + ''''
			
	IF @agentCode IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND agentCode = ''' + @agentCode  + ''''
		
	IF @mapCodeInt IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND mapCodeInt = ''' + @mapCodeInt + ''''

	--IF @isInternal IS NOT NULL
	--	SET @sql_filter = @sql_filter + ' AND isIntl = ''' + CASE WHEN @isInternal = 'Y' THEN '0' ELSE '1' END+ ''''

	IF @agentBlock IS NOT NULL
	BEGIN
		IF @agentBlock = 'Y'
			SET @agentBlock = 'B'
		ELSE
			SET @agentBlock = 'U'
		SET @sql_filter = @sql_filter + ' AND ISNULL(agentBlock,''U'') = ''' + @agentBlock + ''''
	END

	IF @isActive IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND ISNULL(isActive,''Y'') = ''' + @isActive + ''''

	
	SET @select_field_list = '
		parentId
		,agentId
		,agentCode
		,mapCodeInt
		,agentName               
		,agentAddress
		,agentCity 
		,agentLocation
		,agentDistrict
		,agentState
		,agentPhone1
		,agentPhone2              
		,agentType
		,agentType1
		,contractExpiryDate
		,renewalFollowupDate
		,isSettlingAgent
		,countryName
		,haschanged
		,modifiedBy
		,createdBy
		,isActive
		,agentBlock
		,businessType
	'        	
--PRINT @table	
	EXEC dbo.proc_paging @table, @sql_filter,@select_field_list, @extra_field_list,@sortBy, @sortOrder, @pageSize,@pageNumber
END
	
ELSE IF @flag = 't'
BEGIN		
    SET @sql = '
	SELECT
	main.parentId
	,main.agentId
	,main.agentName                    
	,main.agentAddress                    
	,main.agentType
	,agentGroup = ag.detailTitle
	,agentType1 = sdv.detailTitle
	,main.haschanged
	,main.modifiedBy					
	FROM ' + @table
				+ ' main 
	LEFT JOIN staticDataValue sdv ON main.agentType = sdv.valueId
	LEFT JOIN staticDataValue ag ON main.agentGrp = ag.valueId
	WHERE ISNULL(main.parentId, '''') = ''' + ISNULL(@parentId,
										'') + ''''
--PRINT @sql		
    EXECUTE (@sql)
END	
	
ELSE IF @flag = 'reject'
BEGIN
	IF NOT EXISTS ( SELECT 'X' FROM  agentMaster WITH ( NOLOCK ) WHERE agentId = @agentId AND approvedBy IS NULL )
    AND NOT EXISTS ( SELECT 'X' FROM agentMasterMod WITH ( NOLOCK ) WHERE agentId = @agentId )
    BEGIN
        EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>',  @agentId
        RETURN
    END
		
	IF EXISTS ( SELECT  'X' FROM    agentMaster WHERE   agentId = @agentId AND approvedBy IS NULL )
    BEGIN --New record
        BEGIN TRANSACTION
        SET @modType = 'Reject'
        EXEC [dbo].proc_GetColumnToRow @logParamMain, @logIdentifier, @agentId, @oldValue OUTPUT
        INSERT  INTO #msg( errorCode , msg , id)
        EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentId, @user, @oldValue, @newValue
	
		IF EXISTS ( SELECT 'x' FROM #msg WHERE errorCode <> '0' )
		BEGIN
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1,  'Failed to reject the transaction.', @agentId
			RETURN
		END
			DELETE  FROM agentMaster WHERE   agentId = @agentId				
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
    END
	ELSE
    BEGIN
        BEGIN TRANSACTION
        SET @modType = 'Reject'
        EXEC [dbo].proc_GetColumnToRow @logParamMain, @logIdentifier, @agentId, @oldValue OUTPUT
        INSERT  INTO #msg  ( errorCode , msg , id )
        EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentId, @user,  @oldValue,  @newValue
        IF EXISTS ( SELECT 'x' FROM #msg WHERE errorCode <> '0' )
        BEGIN
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
                EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentId
				RETURN
        END
        DELETE  FROM agentMasterMod WHERE   @agentId = @agentId
        IF @@TRANCOUNT > 0
     COMMIT TRANSACTION
    END
	EXEC proc_errorHandler 0, 'Changes rejected successfully.', @agentId
END
	
ELSE IF @flag = 'approve'
BEGIN
	SELECT @intlSuperAgentId = DBO.FNAGetIntlAgentId();
	IF NOT EXISTS ( SELECT 'X' FROM agentMaster WITH ( NOLOCK ) WHERE agentId = @agentId AND approvedBy IS NULL )
		AND NOT EXISTS ( SELECT 'X' FROM agentMasterMod WITH ( NOLOCK )  WHERE agentId = @agentId )
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>',@agentId
		RETURN
	END
		
	BEGIN TRANSACTION
	IF EXISTS ( SELECT 'X' FROM  agentMaster(nolock) WHERE approvedBy IS NULL AND agentId = @agentId )
		SET @modType = 'I'
	ELSE
		SELECT  @modType = modType , @payOption = payOption FROM agentMasterMod(nolock) WHERE   agentId = @agentId
			
	IF @modType = 'I'
	BEGIN --New record
		UPDATE  agentMaster  SET isActive = 'Y' ,
			approvedBy = @user ,
			approvedDate = GETDATE()
		WHERE   agentId = @agentId
				
		EXEC [dbo].proc_GetColumnToRow @logParamMain,@logIdentifier,@agentId,@newValue OUTPUT
				
		--Account Creation (for partners)
		IF EXISTS ( SELECT 	'X'	FROM agentMaster(nolock) WHERE 	agentId = @agentId	AND ISNULL(isSettlingAgent,	'N') = 'Y' AND isApiPartner = 1 AND ISNULL(isIntl, 0) = 0 AND parentId <> @intlSuperAgentId)
		BEGIN
			SELECT @agentName = agentName+' - Principle' FROM agentMaster(NOLOCK) WHERE agentId = @agentId
			
			SELECT @acct_num = MAX(CAST(ACCT_NUM as bigint)+1) FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE gl_code='77'
			SET @acct_num = ISNULL(@acct_num, 771000001)
			----## AUTO CREATE LEDGER FOR PARTNER AGENT
			insert into FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
			acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
			lien_amt, utilised_amt, available_amt,created_date,created_by,company_id)
			values(@acct_num,@agentName,'77', @agentId,'c',0,'TP',getdate(),0,0,0,0,0,getdate(),@user,1)

			SELECT @acct_num = MAX(cast(ACCT_NUM as bigint)+1) ,@agentName = replace(@agentName,'Principle','Comm Payable')
			FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE gl_code='78'

			SET @acct_num = ISNULL(@acct_num, 781000001)

			insert into FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
			acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
			lien_amt, utilised_amt, available_amt,created_date,created_by,company_id)
			values(@acct_num,@agentName,'78', @agentId,'c',0,'TC',getdate(),0,0,0,0,0,getdate(),@user,1)

			INSERT INTO creditLimit (
				agentId ,currency ,	limitAmt ,perTopUpAmt ,maxLimitAmt ,expiryDate ,isActive ,createdBy ,createdDate ,approvedBy 
				,approvedDate ,topUpTillYesterday ,topUpToday ,todaysSent ,todaysPaid ,todaysCancelled ,lienAmt
			)
			SELECT @agentId ,5 ,0 ,0 ,0 ,@contractExpiryDate ,'Y' ,@user ,GETDATE() ,@user 
				,GETDATE() ,0 ,0 ,0 ,0 ,0 ,0
		END	
		----Account Creation (for own branches)
		--IF EXISTS ( SELECT 	'X'	FROM agentMaster(nolock) WHERE 	agentId = @agentId	AND ISNULL(isSettlingAgent,	'N') = 'Y' AND isApiPartner = 0 AND ISNULL(isIntl, 0) = 0 AND parentId = @intlSuperAgentId AND ISNULL(actAsBranch, 'N') = 'Y')
		--BEGIN
			
		--	SELECT @agentName = agentName+' - Receivable' FROM agentMaster(NOLOCK) WHERE agentId = @agentId
			
		--	SELECT @acct_num = MAX(CAST(ACCT_NUM as bigint)+1) FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE gl_code='104'
		--	SET @acct_num = ISNULL(@acct_num, 1041000001)
		--	----## AUTO CREATE LEDGER FOR PARTNER AGENT, BR = BRANCH RECEIVABLE
		--	insert into FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
		--	acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
		--	lien_amt, utilised_amt, available_amt,created_date,created_by,company_id)
		--	values(@acct_num,@agentName,'104', @agentId,'c',0,'BR',getdate(),0,0,0,0,0,getdate(),@user,1)

		--	INSERT INTO creditLimit (
		--		agentId ,currency ,	limitAmt ,perTopUpAmt ,maxLimitAmt ,expiryDate ,isActive ,createdBy ,createdDate ,approvedBy 
		--		,approvedDate ,topUpTillYesterday ,topUpToday ,todaysSent ,todaysPaid ,todaysCancelled ,lienAmt
		--	)
		--	SELECT @agentId ,5 ,0 ,0 ,0 ,@contractExpiryDate ,'Y' ,@user ,GETDATE() ,@user 
		--		,GETDATE() ,0 ,0 ,0 ,0 ,0 ,0
		--END
		--Account Creation (for partners)
		--IF EXISTS ( SELECT 	'X'	FROM agentMaster(nolock) 
		--			WHERE 	agentId = @agentId	AND ISNULL(isSettlingAgent,	'N') = 'Y' 
		--			AND ISNULL(isIntl, 0) = 1 AND isApiPartner = 0 
		--			AND parentId = @intlSuperAgentId AND ISNULL(actAsBranch, 'N') = 'N')
		--BEGIN
		--	SELECT @agentName = agentName+' - Principle Receivable' FROM agentMaster(NOLOCK) WHERE agentId = @agentId
			
		--	SELECT @acct_num = MAX(CAST(ACCT_NUM as bigint)+1) FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE gl_code='105'
		--	SET @acct_num = ISNULL(@acct_num, 1051000001)
		--	----## AUTO CREATE LEDGER FOR PARTNER AGENT, AR = AGENT RECEIVABLE
		--	insert into FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
		--	acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
		--	lien_amt, utilised_amt, available_amt,created_date,created_by,company_id)
		--	values(@acct_num,@agentName,'105', @agentId,'c',0,'APR',getdate(),0,0,0,0,0,getdate(),@user,1)

		--	insert into FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
		--	acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
		--	lien_amt, utilised_amt, available_amt,created_date,created_by,company_id)
		--	values(@acct_num+1,replace(@agentName,'Principle Receivable','Comm Payable'),'105', @agentId,'c',0,'ACP',getdate(),0,0,0,0,0,getdate(),@user,1)

		--	INSERT INTO creditLimit (
		--		agentId ,currency ,	limitAmt ,perTopUpAmt ,maxLimitAmt ,expiryDate ,isActive ,createdBy ,createdDate ,approvedBy 
		--		,approvedDate ,topUpTillYesterday ,topUpToday ,todaysSent ,todaysPaid ,todaysCancelled ,lienAmt
		--	)
		--	SELECT @agentId ,5 ,0 ,0 ,0 ,@contractExpiryDate ,'Y' ,@user ,GETDATE() ,@user 
		--		,GETDATE() ,0 ,0 ,0 ,0 ,0 ,0
		--END
	END
	ELSE
	IF @modType = 'U'
	BEGIN
		EXEC [dbo].proc_GetColumnToRow @logParamMain,@logIdentifier,@agentId,@oldValue OUTPUT				
				
		UPDATE main
		SET   main.parentId = mode.parentId ,
		main.agentName = mode.agentName ,
		main.agentAddress = mode.agentAddress ,
		main.agentCity = mode.agentCity ,
		main.agentCountry = mode.agentCountry ,
		main.agentState = mode.agentState ,
		main.agentDistrict = mode.agentDistrict ,
		main.agentZip = mode.agentZip ,
		main.agentLocation = mode.agentLocation ,
		main.agentPhone1 = mode.agentPhone1 ,
		main.agentPhone2 = mode.agentPhone2 ,
		main.agentFax1 = mode.agentFax1 ,
		main.agentFax2 = mode.agentFax2 ,
		main.agentMobile1 = mode.agentMobile1 ,
		main.agentMobile2 = mode.agentMobile2 ,
		main.agentEmail1 = mode.agentEmail1 ,
		main.agentEmail2 = mode.agentEmail2 ,
		main.bankbranch=mode.bankBranch,
		main.bankCode=mode.bankCode,
		main.bankaccountnumber=mode.bankaccountnumber,
		main.accountholdername=mode.accountholdername,
		main.businessOrgType = mode.businessOrgType ,
		main.businessType = mode.businessType ,
		main.agentRole = mode.agentRole ,
		main.agentType = mode.agentType ,
		main.allowAccountDeposit = mode.allowAccountDeposit ,
		main.contractExpiryDate = mode.contractExpiryDate ,
		main.renewalFollowupDate = mode.renewalFollowupDate ,
		main.agentGrp = mode.agentGrp ,
		main.businessLicense = mode.businessLicense ,
		main.agentBlock = mode.agentBlock ,
		main.agentCompanyName = mode.agentCompanyName ,
		main.companyAddress = mode.companyAddress ,
		main.companyCity = mode.companyCity ,
		main.companyCountry = mode.companyCountry ,
		main.companyState = mode.companyState ,
		main.companyDistrict = mode.companyDistrict ,
		main.companyZip = mode.companyZip ,
		main.companyPhone1 = mode.companyPhone1 ,
		main.companyPhone2 = mode.companyPhone2 ,
		main.companyFax1 = mode.companyFax1 ,
		main.companyFax2 = mode.companyFax2 ,
		main.companyEmail1 = mode.companyEmail1 ,
		main.companyEmail2 = mode.companyEmail2 ,
		main.localTime = mode.localTime ,
		main.localCurrency = mode.localCurrency ,
		main.agentDetails = mode.agentDetails ,
		main.headMessage = mode.headMessage ,
		main.mapCodeInt = mode.mapCodeInt ,
		main.mapCodeDom = mode.mapCodeDom ,
		main.commCodeInt = mode.commCodeInt ,
		main.commCodeDom = mode.commCodeDom ,
		main.mapCodeIntAc = mode.mapCodeIntAc ,
		main.mapCodeDomAc = mode.mapCodeDomAc ,
		main.payOption = mode.payOption ,
		main.modifiedDate = GETDATE() ,
		main.modifiedBy = @user ,
		main.isActive = mode.isActive ,
		main.agentSettCurr = mode.agentSettCurr ,
		main.contactPerson1 = mode.contactPerson1 ,
		main.contactPerson2 = mode.contactPerson2 ,
		main.isHeadOffice = mode.isHeadOffice ,
		main.isIntl = mode.IsIntl ,
		main.isApiPartner = mode.isApiPartner,
		main.routingCode = mode.routingCode
		FROM  agentMaster main
		INNER JOIN agentMasterMod mode ON mode.agentId = main.agentId
		WHERE mode.agentId = @agentId
	
	EXEC [dbo].proc_GetColumnToRow @logParamMain,@logIdentifier,@agentId,@newValue OUTPUT

--Agent Account Creation
	--IF EXISTS ( SELECT 'X' FROM	agentMaster WITH ( NOLOCK )	WHERE agentId = @agentId AND ISNULL(isSettlingAgent,'N') = 'Y' )
	--BEGIN
	--IF NOT EXISTS ( SELECT 'X'	FROM creditLimit WITH ( NOLOCK ) WHERE agentId = @agentId )
	--BEGIN
	--	SELECT @agentCountry = agentCountry ,@contractExpiryDate = contractExpiryDate
	--	FROM agentMaster WITH ( NOLOCK )
	--	WHERE agentId = @agentId
	--	INSERT INTO creditLimit (
	--		agentId ,currency ,limitAmt ,perTopUpAmt ,maxLimitAmt ,expiryDate ,isActive ,createdBy ,createdDate ,approvedBy ,
	--		approvedDate ,topUpTillYesterday ,topUpToday ,todaysSent ,todaysPaid ,todaysCancelled ,lienAmt
	--	)
	--	SELECT @agentId ,'KRW' ,0 ,0 ,0 ,@contractExpiryDate ,'Y' ,@user ,GETDATE() ,@user ,
	--		GETDATE() ,0 ,0 ,0 ,0 ,0 ,0
	--	END
	--END

--End Commission Account Creation
	END
	ELSE
	IF @modType = 'D'
	BEGIN
		EXEC [dbo].proc_GetColumnToRow @logParamMain,@logIdentifier,@agentId,@oldValue OUTPUT
		UPDATE agentMaster
		SET isDeleted = 'Y' ,isActive = 'N' ,modifiedDate = GETDATE() ,modifiedBy = @user
		WHERE agentId = @agentId
				
	END
			
		DELETE  FROM agentMasterMod WHERE   agentId = @agentId
			
		INSERT  INTO #msg ( errorCode ,	msg ,id)
		EXEC proc_applicationLogs 'i',NULL, @modType,@tableAlias, @agentId,@user, @oldValue,@newValue, @module

		IF EXISTS ( SELECT 'x' FROM  #msg WHERE errorCode <> '0' )
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1,'Could not approve the changes.',@agentId
			RETURN
		END
				
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
			
	EXEC proc_errorHandler 0,'Changes approved successfully.',@agentId

END	
	
ELSE IF @flag = 'AGENTDDL'	  --AGENT BUT NOT ACT AS BRANCH & SUPER AGENT LIST ONLY	## using only in message setting
BEGIN
    SELECT  agentId ,
            agentName
    FROM    agentMaster
    WHERE   agentCountryId = @agentCountryId
            AND agentType IN ( 2902, 2903 )
            AND ISNULL(actAsBranch, 'N') = 'N'
END

ELSE IF @flag = 's2'
BEGIN
    IF @sortBy IS NULL
        SET @sortBy = 'agentId'
  IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'
    SET @table = '(
		SELECT
			main.parentId
			,main.agentId
			,main.agentCode
			,main.mapCodeInt
			,main.agentName                    
			,main.agentAddress 
			,main.agentCity
			,agentLocation = adl.districtName
			,main.agentDistrict
			,main.agentState
			,countryName = main.agentCountry 
			,main.agentPhone1
			,main.agentPhone2                  
			,main.agentType
			,main.actAsBranch
			,main.contractExpiryDate
			,main.renewalFollowupDate
			,main.isSettlingAgent
			,main.haschanged
			,agentType1 = sdv.detailTitle
			,main.modifiedBy
			,main.createdBy	
			,main.businessOrgType
			,main.businessType
			,main.agentBlock
			,main.isActive
			,link = CASE WHEN main.agentRole = ''B'' THEN ''<a href="SendingLimit/List.aspx?agentId='' + CAST(main.agentId AS VARCHAR) + ''">Collection Limit</a> | <a href="ReceivingLimit/List.aspx?agentId='' + CAST(main.agentId AS VARCHAR) + ''">Receiving Limit<










/a>''									WHEN main.agentRole = ''S'' THEN ''<a href="SendingLimit/List.aspx?agentId='' + CAST(main.agentId AS VARCHAR) + ''">Collection Limit</a>''
					WHEN main.agentRole = ''R'' THEN ''<a href="ReceivingLimit/List.aspx?agentId='' + CAST(main.agentId AS VARCHAR) + ''">Receiving Limit</a>''
					ELSE ''Please define operation type'' END 
		FROM ' + @table
        + ' main 
		LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.agentType = sdv.valueId
		LEFT JOIN api_districtList adl WITH(NOLOCK) ON main.agentLocation = adl.districtCode
		WHERE main.agentType = 2903 AND main.agentRole IS NOT NULL
	) x'
					
    SET @sql_filter = ''		
		
    IF @haschanged IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
			
    IF @agentCountry IS NOT NULL
        SET @sql_filter = @sql_filter  + ' AND ISNULL(countryName, '''') LIKE ''%' + CAST(@agentCountry AS VARCHAR) + '%'''
			
    IF @agentType IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND ISNULL(agentType, '''') = '  + CAST(@agentType AS VARCHAR)

    IF @agentName IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
		
    IF @agentLocation IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') = ' + CAST(@agentLocation AS VARCHAR)
		
    IF @agentId IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND agentId = ' + CAST(@agentId AS VARCHAR)
			
    IF @parentId IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND parentId = ' + CAST(@parentId AS VARCHAR)

    IF @businessOrgType IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND isnull(businessOrgType,'''') = '''  + CAST(@businessOrgType AS VARCHAR) + ''''
		
    IF @businessType IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND isnull(businessType,'''') = ''' + CAST(@businessType AS VARCHAR) + ''''
		
    IF @actAsBranch IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND ISNULL(actAsBranch, ''N'') = ''' + @actAsBranch + ''''
		
    IF @populateBranch = 'Y'
      SET @sql_filter = @sql_filter + ' AND (ISNULL(agentType, '''') = 2904 OR actAsBranch = ''Y'')'
		
    IF @contractExpiryDate IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND contractExpiryDate = ''' + @contractExpiryDate + ''''
		
    IF @renewalFollowupDate IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND renewalFollowupDate = ''' + @renewalFollowupDate + '''' 
			
    IF @agentCode IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND agentCode = ''' + @agentCode + ''''
		
    IF @mapCodeInt IS NOT NULL
      SET @sql_filter = @sql_filter + ' AND mapCodeInt = ''' + @mapCodeInt + ''''

    IF @agentBlock IS NOT NULL
        BEGIN
            IF @agentBlock = 'Y'
                SET @agentBlock = 'B'
            ELSE
                SET @agentBlock = 'U'
            SET @sql_filter = @sql_filter + ' AND agentBlock = ''' + @agentBlock + ''''
        END

    IF @isActive IS NOT NULL
        SET @sql_filter = @sql_filter + ' AND isActive = ''' + @isActive + ''''
						
    SET @select_field_list = '
		parentId
		,agentId
		,agentCode
		,mapCodeInt
		,agentName               
		,agentAddress
		,agentCity 
		,agentLocation
		,agentDistrict
		,agentState
		,agentPhone1
		,agentPhone2              
		,agentType
		,agentType1
		,contractExpiryDate
		,renewalFollowupDate
		,isSettlingAgent
		,countryName
		,haschanged
		,modifiedBy
		,createdBy
		,isActive
		,agentBlock
		,link
		'        	

    EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list, @sortBy, @sortOrder, @pageSize, @pageNumber
    RETURN
END	
ELSE IF @flag = 'cobankList'
BEGIN
    SELECT  agentId ,
            agentName ,
            agentType
    FROM    agentMaster (NOLOCK)
    WHERE   agentGrp IN ( '8026', '9906' )
            AND agentType = '2903'
            AND ISNULL(isDeleted, 'N') <> 'Y'
    ORDER BY agentName ASC
    RETURN

END
ELSE IF @flag = 'co-agent'						-- cooperative branch list
BEGIN
    SELECT  agentId ,
            agentName ,
            agentType ,
            parentId
    FROM    agentMaster (NOLOCK)
    WHERE   ISNULL(isDeleted, 'N') <> 'Y'
            AND parentId = @agentId
    UNION ALL
    SELECT  agentId ,
            agentName ,
            agentType ,
            parentId
    FROM    agentMaster (NOLOCK)
    WHERE   ISNULL(isDeleted, 'N') <> 'Y'
            AND agentId = @agentId
    RETURN
		
END

IF @flag ='getBranchList'
BEGIN
    SELECT agentId,agentName FROM dbo.agentMaster WHERE parentId='393877'
	AND ISNULL(isActive,'Y')<>'N'
END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION
    SELECT  1 error_code , ERROR_MESSAGE() mes , NULL id
END CATCH


