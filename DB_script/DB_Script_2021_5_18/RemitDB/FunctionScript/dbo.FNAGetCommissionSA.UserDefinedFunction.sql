USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCommissionSA]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

select dbo.FNAGetCommissionSA('1','s','20000','19000','1000','200','300','s')

*/

CREATE FUNCTION [dbo].[FNAGetCommissionSA](
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
			SELECT @commissionBase = commissionBase FROM scPayMasterSA WHERE scPayMasterSAId = @masterId	
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
			FROM scPayDetailSA
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND scPayMasterSAId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
		ELSE
		BEGIN
			SELECT @commissionBase = commissionBase FROM scSendMasterSA WHERE scSendMasterSAId = @masterId	
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
			FROM scSendDetailSA
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND scSendMasterSAId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
	END
	ELSE
	BEGIN
		IF @commType = 'p'
		BEGIN
			
			SELECT @commissionBase = commissionBase FROM dcPayMasterSA WHERE dcPayMasterSAId = @masterId	
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
			FROM dcPayDetailSA
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND dcPayMasterSAId = @masterId
				AND @amt BETWEEN fromAmt and toAmt
		END
		ELSE
		BEGIN
			
			SELECT @commissionBase = commissionBase FROM dcSendMasterSA WHERE dcSendMasterSAId = @masterId	
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
			FROM dcSendDetailSA
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND dcSendMasterSAId = @masterId
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
