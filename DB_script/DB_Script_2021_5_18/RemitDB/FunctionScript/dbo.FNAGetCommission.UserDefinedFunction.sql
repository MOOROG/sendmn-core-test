USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCommission]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetCommission](
		 @masterId				BIGINT
		,@masterType			CHAR(1)
		,@collAmt				MONEY			--For Commission Base
		,@payAmt				MONEY			--For Commission Base
		,@serviceCharge			MONEY			--For Commission Base
		,@tAmt				MONEY			--For Commission Base
		,@sAgentComm			MONEY			--For Commission Base
		,@commType				CHAR(1)			--Send/Pay
		,@sSettlementRate		FLOAT			--Sending Settlement Rate
		,@pSettlementRate		FLOAT			--Payout Settlement Rate
		,@collCurrency			VARCHAR(3)		--Collection Currency
		,@payoutCurrency		VARCHAR(3)		--Payout Currency
		)
RETURNS MONEY
AS
BEGIN	
	DECLARE
		 @minAmt			MONEY
		,@maxAmt			MONEY
		,@pcntAmt			MONEY
		,@commissionBase	INT
		,@amt				MONEY
		,@baseCurrency		VARCHAR(3)
		
	/*		
		4200	Coll Amount
		4201	Pay Amount
		4202	Service Fee
		4203	Hub Comm
		4204	Agent Comm
	*/	
	
	IF @commType = 'p'
	BEGIN
		SELECT @commissionBase = commissionBase, @baseCurrency = baseCurrency FROM scPayMaster WITH(NOLOCK) WHERE scPayMasterId = @masterId	
	
		SELECT @amt = CASE @commissionBase 
				WHEN 4200 THEN @collAmt 
				WHEN 4201 THEN @payAmt 
				WHEN 4202 THEN @serviceCharge 
				WHEN 4203 THEN @tAmt
				WHEN 4204 THEN @sAgentComm
				END
		
		--RETURN @amt
		SELECT
			 @pcntAmt = @amt * pcnt / 100.0
			,@minAmt = minAmt
			,@maxAmt = maxAmt
		FROM scPayDetail
		WHERE
			ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') = 'N'
			AND scPayMasterId = @masterId
			AND @amt BETWEEN fromAmt and toAmt
	END
	ELSE
	BEGIN
		SELECT @commissionBase = commissionBase FROM scSendMaster WHERE scSendMasterId = @masterId	
		SELECT @amt = CASE @commissionBase 
				WHEN 4200 THEN @collAmt 
				WHEN 4201 THEN @payAmt 
				WHEN 4202 THEN @serviceCharge 
				WHEN 4203 THEN @tAmt
				WHEN 4204 THEN @sAgentComm
				END
	
		SELECT
			 @pcntAmt = @amt * pcnt / 100.0
			,@minAmt = minAmt
			,@maxAmt = maxAmt
		FROM scSendDetail
		WHERE
			ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') = 'N'
			AND scSendMasterId = @masterId
			AND @amt BETWEEN fromAmt and toAmt
	END
	
	RETURN (
	SELECT
		CASE
			WHEN @pcntAmt < @minAmt THEN @minAmt
			WHEN @pcntAmt > @maxAmt AND @maxAmt <> 0 THEN @maxAmt
			ELSE @pcntAmt
		END
	)
END


GO
