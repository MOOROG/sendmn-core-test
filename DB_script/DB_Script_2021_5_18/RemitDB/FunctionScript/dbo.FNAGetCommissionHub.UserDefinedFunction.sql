USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCommissionHub]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetCommissionHub](
		 @masterId		BIGINT
		,@masterType	CHAR(1)
		,@collAmt		MONEY
		,@payAmt		MONEY
		,@serviceCharge MONEY
		,@hubComm		MONEY
		,@sAgentComm	MONEY
		,@commType		CHAR(1)
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
		
		
	/*		
		4200	Send Amount
		4201	Pay Amount
		4202	Service Fee
	*/
	
	
		
	
		
	IF @masterType = 'S'
	BEGIN
		IF @commType = 'p'
		BEGIN
			SELECT @commissionBase = commissionBase FROM scPayMasterHub WHERE scPayMasterHubId = @masterId	
			SELECT @amt = CASE @commissionBase 
					WHEN 4200 THEN @collAmt 
					WHEN 4201 THEN @payAmt 
					WHEN 4202 THEN @serviceCharge 
					WHEN 4203 THEN @hubComm
					WHEN 4204 THEN @sAgentComm
					END	
		
			SELECT
				 @pcntAmt = @amt * pcnt / 100.0
				,@minAmt = minAmt
				,@maxAmt = maxAmt
			FROM scPayDetailHub
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND scPayMasterHubId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
		ELSE
		BEGIN
			SELECT @commissionBase = commissionBase FROM scSendMasterHub WHERE scSendMasterHubId = @masterId	
			SELECT @amt = CASE @commissionBase 
					WHEN 4200 THEN @collAmt 
					WHEN 4201 THEN @payAmt 
					WHEN 4202 THEN @serviceCharge 
					WHEN 4203 THEN @hubComm
					WHEN 4204 THEN @sAgentComm
					END
		
			SELECT
				 @pcntAmt = @amt * pcnt / 100.0
				,@minAmt = minAmt
				,@maxAmt = maxAmt
			FROM scSendDetailHub
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND scSendMasterHubId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
	END
	ELSE
	BEGIN
		IF @commType = 'p'
		BEGIN
			
			SELECT @commissionBase = commissionBase FROM dcPayMasterHub WHERE dcPayMasterHubId = @masterId	
			SELECT @amt = CASE @commissionBase 
					WHEN 4200 THEN @collAmt 
					WHEN 4201 THEN @payAmt 
					WHEN 4202 THEN @serviceCharge 
					WHEN 4203 THEN @hubComm
					WHEN 4204 THEN @sAgentComm
					END
		
			SELECT
				 @pcntAmt = @amt * pcnt / 100.0
				,@minAmt = minAmt
				,@maxAmt = maxAmt
			FROM dcPayDetailHub
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND dcPayMasterHubId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
		ELSE
		BEGIN
			
			SELECT @commissionBase = commissionBase FROM dcSendMasterHub WHERE dcSendMasterHubId = @masterId	
			SELECT @amt = CASE @commissionBase 
					WHEN 4200 THEN @collAmt 
					WHEN 4201 THEN @payAmt 
					WHEN 4202 THEN @serviceCharge 
					WHEN 4203 THEN @hubComm
					WHEN 4204 THEN @sAgentComm
					END
		
			SELECT
				 @pcntAmt = @amt * pcnt / 100.0
				,@minAmt = minAmt
				,@maxAmt = maxAmt
			FROM dcSendDetailHub
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND dcSendMasterHubId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
	END
	
	RETURN (
	SELECT
		CASE
			WHEN @pcntAmt < @minAmt THEN @minAmt
			WHEN @pcntAmt > @maxAmt THEN @maxAmt
			ELSE @pcntAmt
		END
	)
END
GO
