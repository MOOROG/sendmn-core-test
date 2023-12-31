USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetComplianceRuleMaster_Pay]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetComplianceRuleMaster_Pay](
		 @sBranch		INT
		,@rCountry		INT
		,@rState		INT
		,@rBranch		INT
		,@currency		INT
		,@senderId		INT
		,@benId			INT
		)
RETURNS @list TABLE (masterId BIGINT)
AS

BEGIN
/*

    1> Get the data in temp table 
    2> Create the temp for condition 
    3> Dynamic query create for checking TRN TEMP Vs Condition Temp (Loop may required)
    4> Data need to shift into main table so that each tran compain histry will be maintain
    5> 
    6> Compose the message with matched criteria
    7> 

*/

	DECLARE
		 @masterId	BIGINT
		,@ssAgent	INT 
		,@sCountry	INT
		,@sAgent	INT
		,@sZip		INT
		,@sCustType INT
		,@sState	INT
		,@sGroup	INT

		,@rAgent	INT
		,@rZip		INT
		,@rCustType INT
		,@rGroup	INT
	
	IF @senderId IS NOT NULL
	SELECT @sCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @senderId
	
	IF @benId IS NOT NULL
	SELECT @rCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @benId
	
	--1. Sending Agent Details
	SELECT 
		 @sAgent = am.parentId
		,@sGroup = am.agentGrp
		,@sZip = am.agentZip
		,@sState = csm.stateId
		,@sCountry = am.agentCountryId
	FROM agentMaster am WITH(NOLOCK)
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
	WHERE am.agentId = @sBranch
	
	--find the criteria
	
	--1 S Agent Vs Receiving Other
	IF EXISTS(SELECT 'x' FROM csMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND ruleScope='Pay')
	BEGIN

		--sAgent Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND sAgent = @sAgent AND rAgent = @rAgent
		AND ruleScope='Pay'
		--sAgent Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND sAgent = @sAgent AND rAgent = @rAgent
		AND ruleScope='Pay'
		 --sAgent Vs rCountry
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND sAgent = @sAgent AND rCountry = @rCountry AND rAgent IS NULL
		AND ruleScope='Pay'
		 --sAgent Vs rCountry
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND sAgent = @sAgent AND rCountry = @rCountry AND rAgent IS NULL
		AND ruleScope='Pay'
		 --sAgent Vs anywhere
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND sAgent = @sAgent AND rCountry IS NULL AND rAgent IS NULL
		AND ruleScope='Pay'
		--sAgent Vs anywhere
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND sAgent = @sAgent AND rCountry IS NULL AND rAgent IS NULL
		AND ruleScope='Pay'
	END

	--5 S Country Vs Receiving Other
	IF EXISTS(SELECT 'x' FROM csMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND sAgent IS NULL AND ruleScope='Pay')
	BEGIN
		--sCountry Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND sCountry = @sCountry AND sAgent IS NULL AND rAgent = @rAgent
		AND ruleScope='Pay'
		--sCountry Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND sCountry = @sCountry AND sAgent IS NULL AND rAgent = @rAgent
		AND ruleScope='Pay'
		--sCountry Vs rCountry
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND sCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry AND rAgent IS NULL
		AND ruleScope='Pay'
		--sCountry Vs rCountry
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND sCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry AND rAgent IS NULL
		AND ruleScope='Pay'
		--sCountry Vs anywhere
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND sCountry = @sCountry AND sAgent IS NULL AND rCountry IS NULL
		AND ruleScope='Pay'
		--sCountry Vs anywhere
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND sCountry = @sCountry AND sAgent IS NULL AND rCountry IS NULL
		AND ruleScope='Pay'
	END
	
	-- R Country Vs Sending Other
	IF EXISTS(SELECT 'x' FROM csMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND rCountry = @sCountry AND sAgent IS NULL AND ruleScope='Pay')
	BEGIN
		--sCountry Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND rCountry = @sCountry AND sAgent IS NULL AND rAgent = @rAgent
		AND ruleScope='Pay'
		--sCountry Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND rCountry = @sCountry AND sAgent IS NULL AND rAgent = @rAgent
		AND ruleScope='Pay'
		--sCountry Vs rCountry
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND rCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry AND rAgent IS NULL
		AND ruleScope='Pay'
		--sCountry Vs rCountry
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND rCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry AND rAgent IS NULL
		AND ruleScope='Pay'
		--sCountry Vs anywhere
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType = @sCustType AND rCountry = @sCountry AND sAgent IS NULL AND rCountry IS NULL
		AND ruleScope='Pay'
		--sCountry Vs anywhere
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCustType IS NULL AND rCountry = @sCountry AND sAgent IS NULL AND rCountry IS NULL
		AND ruleScope='Pay'
	END
	RETURN
END



GO
