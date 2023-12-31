USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetComplianceRuleMaster]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetComplianceRuleMaster]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].FNAGetComplianceRuleMaster

GO	
*/
/*
	SELECT * FROM dbo.FNAGetComplianceRuleMaster(10037, 151, NULL, NULL, NULL, NULL, NULL)
*/
CREATE FUNCTION [dbo].[FNAGetComplianceRuleMaster](
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
	
	SELECT @sCustType = customerType FROM customerMaster WITH(NOLOCK) WHERE customerId = @senderId
	SELECT @rCustType = customerType FROM customerMaster WITH(NOLOCK) WHERE customerId = @benId
	
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
	IF EXISTS(SELECT 'x' FROM csMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' 
		AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent)
	BEGIN
		--sAgent Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType = @sCustType AND sAgent = @sAgent AND rAgent = @rAgent
		
		--sAgent Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType IS NULL AND sAgent = @sAgent AND rAgent = @rAgent
		
		 --sAgent Vs rCountry
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType = @sCustType AND sAgent = @sAgent AND rCountry = @rCountry AND rAgent IS NULL
	
		 --sAgent Vs rCountry
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType IS NULL AND sAgent = @sAgent AND rCountry = @rCountry AND rAgent IS NULL
	
		 --sAgent Vs anywhere
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType = @sCustType AND sAgent = @sAgent AND rCountry IS NULL AND rAgent IS NULL
	
		--sAgent Vs anywhere
		INSERT @list
		SELECT csMasterId  FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType IS NULL AND sAgent = @sAgent AND rCountry IS NULL AND rAgent IS NULL
	END

	--5 S Country Vs Receiving Other
	IF EXISTS(SELECT 'x' FROM csMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' 
		AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND sAgent IS NULL)
	BEGIN
		--sCountry Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType = @sCustType AND sCountry = @sCountry AND sAgent IS NULL AND rAgent = @rAgent
		
		--sCountry Vs rAgent
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType IS NULL AND sCountry = @sCountry AND sAgent IS NULL AND rAgent = @rAgent
		
		--sCountry Vs rCountry
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType = @sCustType AND sCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry AND rAgent IS NULL
		
		--sCountry Vs rCountry
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType IS NULL AND sCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry AND rAgent IS NULL
		
		--sCountry Vs anywhere
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType = @sCustType AND sCountry = @sCountry AND sAgent IS NULL AND rCountry IS NULL
		
		--sCountry Vs anywhere
		INSERT @list
		SELECT csMasterId FROM csMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND sCustType IS NULL AND sCountry = @sCountry AND sAgent IS NULL AND rCountry IS NULL
	END
	
	RETURN
END
GO
