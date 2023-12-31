USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendTransactionLoadData]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

proc_sendTransactionLoadData  'b', 'admin'
EXEC proc_sendTransactionLoadData @flag = 'sc', @agentId = '48', @deliveryMethod = '1', @amount = '1111111', @mode = 'ta', @user = 'admin'

*/

CREATE proc [dbo].[proc_sendTransactionLoadData] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@sBranch			INT				= NULL
	,@sCountry			INT				= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sPhone			VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL	
	,@sTranId			VARCHAR(50)		= NULL	
	
	,@rCountry			INT				= NULL
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rPhone			VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL
	,@pSuperAgent		INT				= NULL
	,@pCountry			INT				= NULL
	,@pCountryName		VARCHAR(100)	= NULL
	,@collCurr			VARCHAR(3)		= NULL
	,@pCurrency			VARCHAR(3)		= NULL
	,@deliveryMethod 	VARCHAR(50)		= NULL
	,@pState			VARCHAR(100)	= NULL
	,@pDistrict			VARCHAR(100)	= NULL
	,@pLocation			INT				= NULL
	,@pBankBranch		INT				= NULL
	,@pCity				VARCHAR(30)		= NULL
	,@pPayer			VARCHAR(30)		= NULL
	,@customerId		INT				= NULL
	,@agentId			INT				= NULL
	,@senderId			INT				= NULL
	,@benId				INT				= NULL
	,@amount			MONEY			= NULL
	,@mode				VARCHAR(10)		= NULL
	,@msgType			CHAR(1)			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

--SELECT * FROM customers
--select * from customerDocument
--select * from customerIdentity


DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

DECLARE  @ssAgent	INT = NULL
		,@sAgent	INT = NULL
		,@rsAgent	INT = NULL
		,@rAgent	INT = NULL
		
		,@code						VARCHAR(50)
		,@userName					VARCHAR(50)
		,@password					VARCHAR(50)	
		
SET NOCOUNT ON
SET XACT_ABORT ON
--select * from customers

SELECT @pageSize = 15, @pageNumber = 1

--EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT

IF @flag = 'cti' --All transaction information (sender, receiver, payout)
BEGIN
	SELECT DISTINCT
		 c.customerId
		,c.membershipId
		,Name = c.firstName + ISNULL(' ' + c.middleName, '') + ISNULL(' ' + c.lastName1, '') + ISNULL(' ' + c.lastName2, '')
		,Country = cm.countryName
		,Address
		,[State] = csm.stateName
		,Phone = COALESCE(mobile, homePhone, workPhone)
		,city
	FROM customers c WITH(NOLOCK)	
	LEFT JOIN countryMaster cm WITH(NOLOCK) ON c.country = cm.countryId
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON c.state = csm.stateId
	WHERE c.customerId = @senderId
	
	SELECT DISTINCT
		 c.customerId
		,c.membershipId
		,Name = c.firstName + ISNULL( ' ' + c.middleName, '') + ISNULL( ' ' + c.lastName1, '') + ISNULL( ' ' + c.lastName2, '')
		,Country = cm.countryName
		,Address
		,[State] = csm.stateName
		,Phone = COALESCE(mobile, homePhone, workPhone)
		,city
	FROM customers c WITH(NOLOCK)	
	LEFT JOIN countryMaster cm WITH(NOLOCK) ON c.country = cm.countryId
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON c.state = csm.stateId
	WHERE c.customerId = @benId
	
	SELECT
		 agentId = NULL
		,agentCode = NULL
		,name = 'Any'
		,address = NULL
		,city = loc.districtName
		,state = csm.stateName
		,district = dist.districtName
		,Phone = NULL
		,country = cm.countryName
		,trn.createdDate
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON trn.pState = csm.stateId
	LEFT JOIN api_districtList loc WITH(NOLOCK) ON trn.pLocation = loc.districtCode
	LEFT JOIN zoneDistrictMap dist WITH(NOLOCK) ON trn.pDistrict = dist.districtId
	LEFT JOIN countryMaster cm WITH(NOLOCK) ON trn.pCountry = cm.countryId
	WHERE trn.controlNo = @controlNo
	

END

ELSE IF @flag = 'msg'
BEGIN
	DECLARE  @headMsg NVARCHAR(MAX)
			,@commonMsg NVARCHAR(MAX)
			,@countrySpecificMsg NVARCHAR(MAX)
		
	SELECT @sAgent = agentId FROM applicationUsers WHERE userName = @user
	SELECT @sCountry = agentCountry FROM agentMaster WHERE agentId = @sAgent
	
	--Head Message
	SELECT @headMsg = headMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y'
	IF(@headMsg IS NULL)
		SELECT @headMsg = headMsg FROM message WHERE countryId IS NULL AND headMsg IS NOT NULL AND ISNULL(isDeleted, 'N') <> 'Y'
		
	--Common Message
	SELECT @commonMsg = commonMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y'
	IF(@commonMsg IS NULL)
		SELECT @commonMsg = commonMsg FROM message WHERE countryId IS NULL AND commonMsg IS NOT NULL AND ISNULL(isDeleted, 'N') <> 'Y'
	
	--Country Specific Message
	SELECT @countrySpecificMsg = countrySpecificMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y'
	IF(@countrySpecificMsg IS NULL)
		SELECT @countrySpecificMsg = countrySpecificMsg FROM message WHERE countryId IS NULL AND countrySpecificMsg IS NOT NULL AND msgType = @msgType AND ISNULL(isDeleted, 'N') <> 'Y'
	
	SELECT @headMsg AS headMsg,@commonMsg AS commonMsg, @countrySpecificMsg AS countrySpecificMsg
END

ELSE IF @flag = 'sc'
BEGIN
	--EXEC proc_sendTransactionLoadData @flag = 'sc', @amount= '100000', @pLocation = '109'
	DECLARE @payoutMethod	CHAR(1)

	--SELECT 
	--	@sBranch = agentId
	--FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	
	--SELECT SC = ISNULL([dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountry, @pDistrict, @agentId , @deliveryMethod, @amount), 0)
	
	--DOMESTIC Service Charge:
	--SELECT @payoutMethod = CASE WHEN @deliveryMethod = 2201 THEN 'c'
	--							WHEN @deliveryMethod = 2202 THEN 'd' END
								
	Exec [192.168.2.1].ime_plus_01.dbo.spa_SOAP_Domestic_ServiceCharge 
		@code,@userName,@password,'1234',@amount, 'c', @pLocation

END

ELSE IF @flag = 'scTBL'
BEGIN
	DECLARE 
		 @masterId INT
		,@masterType CHAR(1)
		,@sc MONEY
	
	IF @sBranch IS NULL
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	
	DECLARE @deliveryMethodId INT
	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod
	
	IF @deliveryMethod = 'Bank Deposit'
	BEGIN
		SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
	END
	
	SELECT 
		 @masterId = masterId
		,@masterType = masterType 
		,@sc = amount
	FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountry, @pLocation, @agentId, @deliveryMethodId, @amount, @collCurr)
	
	IF(@masterType = 'S')
	BEGIN
		SELECT fromAmt, toAmt, pcnt, maxAmt, minAmt FROM sscDetail WHERE sscMasterId = @masterId
	END
	ELSE
	BEGIN
		SELECT fromAmt, toAmt, pcnt, maxAmt, minAmt FROM dscDetail WHERE dscMasterId = @masterId 
	END	
END

ELSE IF @flag = 'scLocal'
BEGIN
	--EXEC proc_sendTransactionLoadData @flag = 'sc', @amount= '100000', @pLocation = '109'
	DECLARE @agentType INT
	
	IF @sBranch IS NULL
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

	
	SELECT @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
	END	
	ELSE
	BEGIN
		SELECT @sAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	END
	SELECT @pSuperAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	SELECT @pCountry = countryId FROM countryMaster WITH(NOLOCK) 
		WHERE countryName = (SELECT agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent)
	
	IF @deliveryMethod = 'Bank Deposit'
	BEGIN
		SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
	END
				
	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod
	SELECT sc = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountry, @pLocation, @agentId , @deliveryMethodId, @amount, @collCurr)								
END

ELSE IF @flag = 'acBal'
BEGIN
	--EXEC proc_sendTransactionLoadData @flag = 'acBal', @user = 'shree_b1'
	DECLARE @settlingAgent INT
	
	IF @agentId IS NULL
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	ELSE
		SELECT @sBranch = @agentId
	
	SELECT @sAgent = parentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	IF @agentType = 2903
		SET @sAgent = @sBranch
	
	SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	
	SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @ssAgent AND isSettlingAgent = 'Y'
	
	SELECT 
		 availableBal	= ISNULL(dbo.FNAGetLimitBal(@settlingAgent), 0)
		,balCurrency	= cm.currencyCode
		,limExpiry		= ISNULL(CONVERT(VARCHAR, expiryDate, 101), 'N/A')
	FROM creditLimit cl
	LEFT JOIN currencyMaster cm WITH(NOLOCK) ON cl.currency = cm.currencyId
	WHERE agentId = @settlingAgent
END

ELSE IF @flag = 'er' --Exchage Rate
BEGIN
	--DECLARE 
	--	 @collCurr INT = 1 
	--	,@payCurr INT = 1


	SELECT
		 cm.currencyId 
		,cm.currencyCode
		,cm.currencyName
		--,exRate = [dbo].FNAGetEchangeRate(@sBranch, @agentId, @collCurr, @payCurr) 
	FROM agentCurrency ac WITH(NOLOCK)
	INNER JOIN (
		SELECT 
			parentId
		FROM agentMaster WHERE agentId = @agentId
	) agent ON agent.parentId = ac.agentId
	INNER JOIN currencyMaster cm WITH(NOLOCK) ON ac.currencyId = cm.currencyId
END

ELSE IF @flag = 'fer'
BEGIN
	DECLARE 
		 @isAnywhere CHAR(1)
		,@isTranMode CHAR(1)
		,@sending BIGINT
		,@receiving BIGINT
			
	SELECT @sending = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	SELECT @isAnywhere = CASE WHEN @agentId IS NULL THEN 'Y' ELSE 'N' END
	SELECT @receiving = CASE WHEN @isAnywhere = 'Y' THEN @pCountry ELSE @agentId END
	SELECT @receiving = CASE WHEN @agentId IS NULL THEN @pCountry ELSE @agentId END
	SELECT @sAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sending
	SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	SELECT @rAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
	SELECT @rsAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent
	
	
	--CREATE FUNCTION [dbo].FNAGetEchangeRateForTran(@ssAgent BIGINT, @sending BIGINT, @rsAgent BIGINT, @receiving BIGINT
	--, @collCurr INT, @payCurr INT, @isAnywhere CHAR(1), @isTranMode CHAR(1), @user VARCHAR(30))
	
	IF @collCurr = @pCurrency
	BEGIN
		SELECT 1
		RETURN
	END
	SELECT [dbo].FNAGetEchangeRateForTran(@ssAgent, @sending, @pSuperAgent, @receiving, @collCurr, @pCurrency, @isAnywhere, 'Y', @user)
END

ELSE IF @flag IN ('tranId', 'senderId') --Get Details By Tran Id OR sender ID
BEGIN	
	DECLARE @tranRowId BIGINT
	
	IF @senderId IS NOT NULL
	BEGIN		
		SELECT @tranRowId = ISNULL(lastTranId, 0) FROM customers WHERE customerId = @senderId		
		SELECT @agentId = pBranch FROM remitTran WHERE Id = @tranRowId		
		SELECT @senderId = customerId FROM tranSenders WITH(NOLOCK) WHERE tranId = @tranRowId		
		SELECT @benId = customerId FROM tranReceivers WITH(NOLOCK) WHERE tranId = @tranRowId		
	END	
	ELSE IF @sTranId IS NOT NULL --control Id
	BEGIN
		SELECT
			 @tranRowId = id
			,@agentId = pBranch
		FROM remitTran WHERE controlNo = @sTranId
		SELECT @senderId = customerId FROM tranSenders WITH(NOLOCK) WHERE tranId = @tranRowId
		SELECT @benId = customerId FROM tranReceivers WITH(NOLOCK) WHERE tranId = @tranRowId		
	END	
	SELECT SenderId = ISNULL(@senderId, 0), BenId = ISNULL(@benId, 0), AgentId = ISNULL(@agentId, 0)
END

ELSE IF @flag = 's'
BEGIN
	SET @table = '(
				SELECT DISTINCT
					 c.customerId
					,c.membershipId
					,Name = c.firstName + ISNULL( '' '' + c.middleName, '''') + ISNULL( '' '' + c.lastName1, '''') + ISNULL( '' '' + c.lastName2, '''')
					,Country = ccm.countryName
					,Address
					,[State] = csm.stateName
					,Phone = COALESCE(mobile, homePhone, workPhone)
					,city
				FROM customers c WITH(NOLOCK)
				LEFT JOIN customerIdentity ci WITH(NOLOCK) ON c.customerId = ci.customerId
				LEFT JOIN countryMaster ccm WITH(NOLOCK) ON c.country = ccm.countryId
				LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON c.state = csm.stateId
				WHERE ISNULL(ci.isDeleted, '''') <> ''Y'''	
			
	SET @sql_filter = ''
	
	IF @senderId IS NOT NULL
		SET @table = @table + ' AND c.customerId = ' + CAST(@senderId AS VARCHAR)
	
	
	IF @sCountry IS NOT NULL
		SET @table = @table + ' AND c.country = ' + CAST(@sCountry AS VARCHAR)
		
	IF @sFirstName IS NOT NULL
		SET @table = @table + ' AND c.firstName LIKE ''' + @sFirstName + '%'''
		
	IF @sMiddleName IS NOT NULL
		SET @table = @table + ' AND c.middleName LIKE ''' + @sMiddleName + '%'''
		
	IF @sLastName1 IS NOT NULL
		SET @table = @table + ' AND c.lastName1 LIKE ''' + @sLastName1 + '%'''
		
	IF @sLastName2 IS NOT NULL
		SET @table = @table + ' AND c.lastName2 LIKE ''' + @sLastName2 + '%'''		
	
	IF @sPhone IS NOT NULL
		SET @table = @table +	' AND (
									   ISNULL(c.homePhone, '''') LIKE ''' + @sPhone + '%''
									OR ISNULL(c.workPhone, '''') LIKE ''' + @sPhone + '%''
									OR ISNULL(c.mobile, '''') LIKE ''' + @sPhone  + '%''
								)'
	
	IF @sMemId IS NOT NULL
		SET @table = @table + ' AND c.membershipId = ''' + CAST(@sMemId AS VARCHAR) + ''''
		
	IF @sId IS NOT NULL
		SET @table = @table + ' AND ci.idNumber LIKE ''' + CAST(@sId AS VARCHAR) + '%'''
	
	IF (
			@senderId IS NULL 
		AND @sFirstName IS NULL 
		AND @sMiddleName IS NULL
		AND @sLastName1 IS NULL
		AND @sLastName2 IS NULL
		AND @sPhone IS NULL
		AND @sMemId IS NULL
		AND @sId IS NULL
		)
		SET @table = @table + ' AND 1<>1'
	
	SET @select_field_list ='
				 customerId
				,membershipId
				,Name				
				,Country 
				,Address
				,[State]
				,Phone
				,city
			   '
	SET @table = @table + ') x'
			
	EXEC dbo.proc_paging
            @table
           ,@sql_filter
           ,@select_field_list
           ,@extra_field_list
           ,@sortBy
           ,@sortOrder
           ,@pageSize
           ,@pageNumber

END

ELSE IF @flag = 'b'
BEGIN
	SET @table = '(
				SELECT DISTINCT
					 c.customerId
					,c.membershipId
					,Name = c.firstName + ISNULL( '' '' + c.middleName, '''') + ISNULL( '' '' + c.lastName1, '''') + ISNULL( '' '' + c.lastName2, '''')					
					,Country = ccm.countryName
					,Address
					,[State] = csm.stateName
					,Phone = COALESCE(mobile, homePhone, workPhone)
					,city
				FROM customers c WITH(NOLOCK)
				LEFT JOIN customerIdentity ci WITH(NOLOCK) ON c.customerId = ci.customerId
				LEFT JOIN countryMaster ccm WITH(NOLOCK) ON c.country = ccm.countryId
				LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON c.state = csm.stateId
				WHERE ISNULL(ci.isDeleted, '''') <> ''Y''
			'
				
	IF @benId IS NOT NULL
		SET @table = @table + ' AND c.customerId = ' + CAST(@benId AS VARCHAR)	
		
	IF @benId IS NULL
	BEGIN
		IF @rCountry IS NOT NULL
			SET @table = @table + ' AND c.country = ' + CAST(@rCountry AS VARCHAR)
			
		IF @rFirstName IS NOT NULL
			SET @table = @table + ' AND c.firstName LIKE ''' + @rFirstName + '%'''
			
		IF @rMiddleName IS NOT NULL
			SET @table = @table + ' AND c.middleName LIKE ''' + @rMiddleName + '%'''
			
		IF @rLastName1 IS NOT NULL
			SET @table = @table + ' AND c.LastName1 LIKE ''' + @rLastName1 + '%'''
			
		IF @rLastName2 IS NOT NULL
			SET @table = @table + ' AND c.LastName2 LIKE ''' + @rLastName2 + '%'''		
		
		IF @rPhone IS NOT NULL
			SET @table = @table +	' AND ( 
										   ISNULL(c.homePhone, '''') LIKE ''' + @rPhone + '%''
										OR ISNULL(c.workPhone, '''') LIKE ''' + @rPhone + '%''
										OR ISNULL(c.mobile, '''') LIKE ''' + @rPhone  + '%''
									   )'

		IF @rMemId IS NOT NULL
			SET @table = @table + ' AND c.membershipId = ''' + CAST(@rMemId AS VARCHAR) + ''''
		
		IF @rId IS NOT NULL
			SET @table = @table + ' AND ci.idNumber LIKE ''' + CAST(@rId AS VARCHAR) + '%'''
			
		IF (
			@benId IS NULL 
		AND @rFirstName IS NULL 
		AND @rMiddleName IS NULL
		AND @rLastName1 IS NULL
		AND @rLastName2 IS NULL
		AND @rPhone IS NULL
		AND @rMemId IS NULL
		AND @rId IS NULL
		)
			SET @table = @table + ' AND 1<>1'
	END 
	
	SET @table = @table + ') x'
	SET @sql_filter = ''
	SET @select_field_list ='
				 customerId
				,membershipId
				,Name				
				,Country 
				,Address
				,[State]
				,Phone
				,city
			   '			
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
	
	
END

ELSE IF @flag = 'p'
BEGIN
	SET @table = '(
		SELECT
			DISTINCT
			 am.agentId
			,am.agentCode
			,name = am.agentName
			,address = am.agentAddress
			,city = agentCity
			,district = agentDistrict
			,[State] = agentState			
			,Phone = COALESCE(agentMobile1, agentMobile2, agentPhone1, agentPhone2)
			,Country = am.agentCountry
		FROM agentMaster am WITH(NOLOCK)		
		LEFT JOIN agentCurrency ac WITH(NOLOCK) ON am.agentId = ac.agentId
		INNER JOIN currencyMaster cm WITH(NOLOCK) ON ac.currencyId = cm.currencyId
		WHERE 
			ISNULL(am.isDeleted, '''') <> ''Y'' 
			AND ISNULL(am.isActive, '''') = ''Y''
			AND (agentType = ''2904'' OR actAsBranch = ''Y'') 
			AND (am.parentId IN (SELECT agentId FROM agentMaster WHERE parentId = ' + CAST(ISNULL(@pSuperAgent,0) AS VARCHAR) + ') OR am.parentId = ' + CAST(ISNULL(@pSuperAgent, 0) AS VARCHAR) + ')
			'
		
		--PRINT (@table)	
		IF @agentId IS NOT NULL
			SET @table = @table + ' AND am.agentId = ' + CAST(@agentId AS VARCHAR)	
		
		IF @agentId IS NULL
		BEGIN
			--IF @pSuperAgent IS NOT NULL
			--	SET @table = @table + ' AND am.parentId IN (' + SELECT agentId FROM agentMaster WHERE parentId = @pCountry + ')'
				
			IF @pCountry IS NOT NULL
				SET @table = @table + ' AND am.agentCountry = ''' + @pCountryName + ''''
				
			IF @pCurrency IS NOT NULL
				SET @table = @table + ' AND cm.currencyCode = ''' + @pCurrency + ''''
				
			IF @pState IS NOT NULL
				SET @table = @table + ' AND am.agentState = ''' + @pState + ''''
			
			IF @pDistrict IS NOT NULL
				SET @table = @table + ' AND am.agentDistrict = ''' + @pDistrict + ''''
				
			IF @pLocation IS NOT NULL
				SET @table = @table + ' AND am.agentLocation = ' + CAST(@pLocation AS VARCHAR) 
					
			IF @pCity IS NOT NULL
				SET @table = @table + ' AND am.agentCity LIKE ''' + @pCity + '%'''
			
			--IF @deliveryMethod IS NOT NULL
			--	SET @table = @table + ' AND x.serviceType = ' + CAST(@deliveryMethod AS VARCHAR)
			
			IF @pPayer IS NOT NULL
				SET @table = @table + ' AND (
										am.agentName LIKE ''' + @pPayer + '%''
										OR am.agentCode LIKE ''' + @pPayer + '%''
									  ) 
									'
		END
							  
		SET @table = @table + ') x'
		
		SET @sql_filter = ''	
		SET @select_field_list ='
				 agentId
				,agentCode
				,name				
				,address 
				,country
				,city
				,[State]
				,Phone	
						
			   '
		
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber	

END

ELSE IF @flag = 'cust'
BEGIN
	SELECT
		 c.customerId
		,membershipId
		,Name = c.firstName + ISNULL( ' ' + c.middleName, '') + ISNULL(' ' + c.lastName1, '') + ISNULL(' ' + c.lastName2, '')
		,[state] = ISNULL(csm.stateName, 'NA')
		,[address] = ISNULL([address], 'NA')
		,Phone = COALESCE(mobile, homePhone, workPhone)	
		,country = ISNULL(ccm.countryName, 'NA')
	FROM customers c WITH(NOLOCK)
	LEFT JOIN countryMaster ccm WITH(NOLOCK) ON c.country =  ccm.countryId 
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON c.state = csm.stateId
	WHERE c.customerId = @customerId
END

ELSE IF @flag = 'pay'
BEGIN
	SELECT 
		 am.agentId
		,code = am.agentCode
		,name = am.agentName
		,address = am.agentAddress
		,city = agentCity
		,[State] = ISNULL(csm.stateName, 'NA')
		,Phone = COALESCE(agentMobile1, agentMobile2, agentPhone1, agentPhone2)
		,Country = am.agentCountry
		,am.parentId
		,am.agentType
	FROM agentMaster am WITH(NOLOCK)
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateId
	WHERE 
		ISNULL(am.isDeleted, '') <> 'Y'
		AND ISNULL(am.isActive, '') = 'Y'
		AND agentId = @agentId
END

ELSE IF @flag = 'p_curr'
BEGIN
	SELECT
		DISTINCT
		 currencyId = cm.currencyCode
		,cm.currencyCode
	FROM countryCurrency cc WITH(NOLOCK)
	INNER JOIN currencyMaster cm WITH(NOLOCK) ON cc.currencyId = cm.currencyId 
	WHERE cc.countryId = @pCountry --ISNULL(@pCountry, cc.countryId )
	AND (spFlag IS NULL OR spFlag = 5201)
	ORDER BY cm.currencyCode
END

ELSE IF @flag = 'c_curr'
BEGIN
	/*EXEC proc_sendTransactionLoadData @flag = 'c_curr', @user = 'ahalia'*/
	DECLARE @agentCountryId INT
	
	SELECT @agentId = agentId FROM applicationUsers WHERE userName = @user
	SELECT @agentCountryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId 
		
	SELECT DISTINCT currencyId, currencyCode, currencyName FROM
	(
		SELECT 
			 currencyId = cm.currencyCode
			,cm.currencyCode
			,currencyName = cm.currencyCode + ' - ' + cm.currencyName
		FROM countryCurrency cc WITH(NOLOCK)
		INNER JOIN currencyMaster cm WITH(NOLOCK) ON cc.currencyId = cm.currencyId
		WHERE countryId = @agentCountryId AND applyToAgent = 'Y' 
		UNION ALL
		SELECT
			 currencyId = cm.currencyCode
			,cm.currencyCode
			,currencyName = cm.currencyCode + ' - ' + cm.currencyName		
		FROM agentCurrency ac WITH(NOLOCK)
		INNER JOIN (
			SELECT 
				parentId
			FROM agentMaster WHERE agentId =  @agentId
		) agent ON agent.parentId = ac.agentId
		INNER JOIN currencyMaster cm WITH(NOLOCK) ON ac.currencyId = cm.currencyId 
	)x
	ORDER BY currencyCode ASC
	
END

ELSE IF @flag = 'dm' -- deliverymethod
BEGIN
	SELECT 			
		stm.serviceTypeId 
		,stm.typeTitle
	FROM serviceTypeMaster stm WITH (NOLOCK) 
	WHERE ISNULL(stm.isDeleted, 'N')  <> 'Y'
	AND ISNULL(stm.isActive, 'N') = 'Y' 
END

GO
