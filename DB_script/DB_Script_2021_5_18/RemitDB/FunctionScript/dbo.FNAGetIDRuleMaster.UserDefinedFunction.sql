USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetIDRuleMaster]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SELECT * FROM dbo.FNAGetIDRuleMaster(4616, 151, NULL, NULL, NULL, NULL, NULL)
*/
CREATE FUNCTION [dbo].[FNAGetIDRuleMaster](
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
	
	SELECT @sCustType = customerType FROM customers WITH(NOLOCK) WHERE customerId = @senderId
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
	IF EXISTS(SELECT 'x' FROM cisMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent)
	BEGIN
		--sAgent Vs rAgent
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sAgent = @sAgent AND rAgent = @rAgent
	    
		--sAgent Vs rGroup
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sAgent = @sAgent AND rGroup = @rGroup
		
		 --sAgent Vs rZip
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sAgent = @sAgent AND rZip = @rZip

		 --sAgent Vs rState
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sAgent = @sAgent AND rState = @rState
			
		 --sAgent Vs rCountry
		INSERT @list
		SELECT cisMasterId  FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sAgent = @sAgent AND rCountry = @rCountry
	END


	--2 S Group Vs Receiving Other
	IF EXISTS(SELECT 'x' FROM cisMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup)
	BEGIN
		--sGroup Vs rAgent
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sGroup = @sGroup AND rAgent = @rAgent
	    
		--sGroup Vs rGroup
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sGroup = @sGroup AND rGroup = @rGroup
		
		 --sGroup Vs rZip
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sGroup = @sGroup  AND rZip = @rZip

		 --sGroup Vs rState
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sGroup = @sGroup AND rState = @rState

		 --sGroup Vs rCountry
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sGroup = @sGroup AND rCountry = @rCountry
	END


	--3 S ZIP VS RECEIVING OTHER
	IF EXISTS(SELECT 'x' FROM cisMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sZip = @sZip)
	BEGIN
		--sZip Vs rAgent
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sZip = @sZip AND rAgent = @rAgent
	    
		--sZip Vs rGroup
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sZip = @sZip AND rGroup = @rGroup
		
		 --sZip Vs rZip
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sZip = @sZip AND rZip = @rZip

		 --sZip Vs rState
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sZip = @sZip AND rState = @rState

		 --sZip Vs rCountry
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sZip = @sZip AND rCountry = @rCountry

	END

	--4 S State Vs Receiving Other
	IF EXISTS(SELECT 'x' FROM cisMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sZip = @sZip)
	BEGIN
		--sState Vs rAgent
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sState = @sState AND rAgent = @rAgent
	    
		--sState Vs rGroup
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sState = @sState AND rGroup = @rGroup
		
		--sState Vs rZip
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sState = @sState AND rZip = @rZip

		--sState Vs rState
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sState = @sState AND rState = @rState

		--sState Vs rCountry
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sState = @sState AND rCountry = @rCountry
		
	END


	--5 S Country Vs Receiving Other
	IF EXISTS(SELECT 'x' FROM cisMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry)
	BEGIN
		--sCountry Vs rAgent
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sCountry = @sCountry AND rAgent = @rAgent
	    
		--sCountry Vs rGroup
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sCountry = @sCountry AND rGroup = @rGroup
		
		--sCountry Vs rZip
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sCountry = @sCountry AND rZip = @rZip

		--sCountry Vs rState
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sCountry = @sCountry AND rState = @rState
		
		--sCountry Vs rCountry
		INSERT @list
		SELECT cisMasterId FROM cisMaster WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCustType = @sCustType OR sCustType IS NULL) AND sCountry = @sCountry AND rCountry = @rCountry
		
	END
	
	RETURN
END
GO
