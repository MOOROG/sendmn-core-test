
ALTER FUNCTION [dbo].[FNAGetPayCommCurrency] 
(
@sSuperAgent		BIGINT
,@sAgent			BIGINT
,@sBranch			BIGINT
,@sCountry			INT
,@rsAgent			BIGINT
,@rBranch			BIGINT
,@rCountry			INT
)  
RETURNS varchar(5) AS  
BEGIN 
	DECLARE @pAgentCommCurrency VARCHAR(5)

	SELECT @pAgentCommCurrency = COMMISSIONCURRENCY 
	FROM scPayMaster (NOLOCK) WHERE SCOUNTRY = @sCountry AND SSAGENT = @sSuperAgent AND SAGENT = @sAgent AND SBRANCH = @sBranch AND RCOUNTRY = @rCountry AND RSAGENT = @rsAgent 

	IF @pAgentCommCurrency IS NULL
		SELECT @pAgentCommCurrency = COMMISSIONCURRENCY 
		FROM scPayMaster (NOLOCK) WHERE SCOUNTRY = @sCountry AND SSAGENT = @sSuperAgent AND SAGENT = @sAgent AND SBRANCH IS NULL AND RCOUNTRY = @rCountry AND RSAGENT = @rsAgent

	IF @pAgentCommCurrency IS NULL
		SELECT @pAgentCommCurrency = COMMISSIONCURRENCY 
		FROM scPayMaster (NOLOCK) WHERE SCOUNTRY = @sCountry AND SSAGENT = @sSuperAgent AND SAGENT IS NULL AND SBRANCH IS NULL AND RCOUNTRY = @rCountry AND RSAGENT = @rsAgent

	IF @pAgentCommCurrency IS NULL
		SELECT @pAgentCommCurrency = COMMISSIONCURRENCY 
		FROM scPayMaster (NOLOCK) WHERE SCOUNTRY = @sCountry AND SSAGENT = @sSuperAgent AND SAGENT IS NULL AND SBRANCH IS NULL AND RCOUNTRY = @rCountry AND RSAGENT IS NULL

	IF @pAgentCommCurrency IS NULL
		SELECT @pAgentCommCurrency = COMMISSIONCURRENCY 
		FROM scPayMaster (NOLOCK) WHERE SCOUNTRY = @sCountry AND SSAGENT IS NULL AND SAGENT IS NULL AND SBRANCH IS NULL AND RCOUNTRY = @rCountry AND RSAGENT = @rsAgent
	
	return @pAgentCommCurrency
end







