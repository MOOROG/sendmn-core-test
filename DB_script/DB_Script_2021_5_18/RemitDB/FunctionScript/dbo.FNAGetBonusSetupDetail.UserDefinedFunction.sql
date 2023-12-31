USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetBonusSetupDetail]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM bonusOperationSetup WITH(NOLOCK)
create FUNCTION [dbo].[FNAGetBonusSetupDetail](
	 @sCountry INT, @sAgent INT, @sBranch INT
	,@pCountry INT, @pAgent INT
)
RETURNS @list TABLE (bonusId BIGINT, maxPointsPerTxn INT, minTxnForRedeem INT)
AS
BEGIN
	DECLARE @bonusSchemeId INT, @maxPointsPerTxn INT, @minTxnForRedeem INT
	IF EXISTS(SELECT 'X' FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch = @sBranch AND ISNULL(isActive, 'N') = 'Y')
	BEGIN
		SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch = @sBranch AND receivingCountry = @pCountry AND receivingAgent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch = @sBranch AND receivingCountry = @pCountry AND receivingAgent IS NULL AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch = @sBranch AND receivingCountry IS NULL AND receivingAgent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch = @sBranch AND receivingCountry IS NULL AND receivingAgent IS NULL AND ISNULL(isActive, 'N') = 'Y'
		INSERT INTO @list
		SELECT @bonusSchemeId, @maxPointsPerTxn, @minTxnForRedeem
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch IS NULL AND ISNULL(isActive, 'N') = 'Y')
	BEGIN
		SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch IS NULL AND receivingCountry = @pCountry AND receivingAgent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch IS NULL AND receivingCountry = @pCountry AND receivingAgent IS NULL AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch IS NULL AND receivingCountry IS NULL AND receivingAgent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent = @sAgent AND sendingBranch IS NULL AND receivingCountry IS NULL AND receivingAgent IS NULL AND ISNULL(isActive, 'N') = 'Y'
		INSERT INTO @list
		SELECT @bonusSchemeId, @maxPointsPerTxn, @minTxnForRedeem
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent IS NULL AND sendingBranch IS NULL AND ISNULL(isActive, 'N') = 'Y')
	BEGIN
		SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent IS NULL AND sendingBranch IS NULL AND receivingCountry = @pCountry AND receivingAgent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent IS NULL AND sendingBranch IS NULL AND receivingCountry = @pCountry AND receivingAgent IS NULL AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent IS NULL AND sendingBranch IS NULL AND receivingCountry IS NULL AND receivingAgent = @pAgent AND ISNULL(isActive, 'N') = 'Y'
		IF @bonusSchemeId IS NULL
			SELECT @bonusSchemeId = bonusSchemeId, @maxPointsPerTxn = maxPointsPerTxn, @minTxnForRedeem = minTxnForRedeem FROM bonusOperationSetup WITH(NOLOCK) WHERE sendingCountry = @sCountry AND sendingAgent IS NULL AND sendingBranch IS NULL AND receivingCountry IS NULL AND receivingAgent IS NULL AND ISNULL(isActive, 'N') = 'Y'
		INSERT INTO @list
		SELECT @bonusSchemeId, @maxPointsPerTxn, @minTxnForRedeem
		RETURN
	END
	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END
GO
