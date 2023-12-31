USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDomesticCommDetail]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetDomesticCommDetail](@masterId BIGINT, @transferAmount MONEY)
RETURNS @commDetail TABLE (serviceCharge MONEY, sAgentComm MONEY, ssAgentComm MONEY, pAgentComm MONEY, psAgentComm MONEY, bankComm MONEY)
AS
BEGIN	
	DECLARE
		 @serviceChargeMinAmt	MONEY
		,@serviceChargeMaxAmt	MONEY
		,@serviceChargePcntAmt	MONEY
		,@sAgentCommMinAmt		MONEY
		,@sAgentCommMaxAmt		MONEY
		,@sAgentCommPcntAmt		MONEY
		,@ssAgentCommMinAmt		MONEY
		,@ssAgentCommMaxAmt		MONEY
		,@ssAgentCommPcntAmt	MONEY
		,@pAgentCommMinAmt		MONEY
		,@pAgentCommMaxAmt		MONEY
		,@pAgentCommPcntAmt		MONEY
		,@psAgentCommMinAmt		MONEY
		,@psAgentCommMaxAmt		MONEY
		,@psAgentCommPcntAmt	MONEY
		,@bankCommMinAmt		MONEY
		,@bankCommMaxAmt		MONEY
		,@bankCommPcntAmt		MONEY
	
	SELECT 
		 @serviceChargePcntAmt	= @transferAmount * serviceChargePcnt / 100.0
		,@serviceChargeMinAmt	= serviceChargeMinAmt
		,@serviceChargeMaxAmt	= serviceChargeMaxAmt
		,@sAgentCommPcntAmt		= @transferAmount * sAgentCommPcnt / 100.0
		,@sAgentCommMinAmt		= sAgentCommMinAmt
		,@sAgentCommMaxAmt		= sAgentCommMaxAmt
		,@ssAgentCommPcntAmt	= @transferAmount * ssAgentCommPcnt / 100.0
		,@ssAgentCommMinAmt		= ssAgentCommMinAmt
		,@ssAgentCommMaxAmt		= ssAgentCommMaxAmt
		,@pAgentCommPcntAmt		= @transferAmount * pAgentCommPcnt/ 100.0
		,@pAgentCommMinAmt		= pAgentCommMinAmt
		,@pAgentCommMaxAmt		= pAgentCommMaxAmt
		,@psAgentCommPcntAmt	= @transferAmount * psAgentCommPcnt / 100.0
		,@psAgentCommMinAmt		= psAgentCommMinAmt
		,@psAgentCommMaxAmt		= psAgentCommMaxAmt
		,@bankCommPcntAmt		= @transferAmount * bankCommPcnt / 100.0
		,@bankCommMinAmt		= bankCommMinAmt
		,@bankCommMaxAmt		= bankCommMaxAmt
	FROM scDetail 
	WHERE 
		ISNULL(isActive, 'N') = 'Y'
		AND ISNULL(isDeleted, 'N') = 'N'
		AND scMasterId = @masterId
		AND @transferAmount BETWEEN fromAmt and toAmt
			
	INSERT INTO @commDetail		
	SELECT		
		 serviceCharge	= CASE 
							WHEN @serviceChargePcntAmt < @serviceChargeMinAmt THEN @serviceChargeMinAmt 
							WHEN @serviceChargePcntAmt > @serviceChargeMaxAmt THEN @serviceChargeMaxAmt
							ELSE @serviceChargePcntAmt
						  END
		,sAgentComm		= CASE
							WHEN @sAgentCommPcntAmt < @sAgentCommMinAmt THEN @sAgentCommMinAmt 
							WHEN @sAgentCommPcntAmt > @sAgentCommMaxAmt THEN @sAgentCommMaxAmt
							ELSE @sAgentCommPcntAmt
						  END
		,ssAgentComm	= CASE
							WHEN @ssAgentCommPcntAmt < @ssAgentCommMinAmt THEN @ssAgentCommMinAmt 
							WHEN @ssAgentCommPcntAmt > @ssAgentCommMaxAmt THEN @ssAgentCommMaxAmt
							ELSE @ssAgentCommPcntAmt
						  END
		,pAgentComm		= CASE
							WHEN @pAgentCommPcntAmt < @pAgentCommMinAmt THEN @pAgentCommMinAmt 
							WHEN @pAgentCommPcntAmt > @pAgentCommMaxAmt THEN @pAgentCommMaxAmt
							ELSE @pAgentCommPcntAmt
						  END
		,psAgentComm	= CASE
							WHEN @psAgentCommPcntAmt < @psAgentCommMinAmt THEN @psAgentCommMinAmt 
							WHEN @psAgentCommPcntAmt > @psAgentCommMaxAmt THEN @psAgentCommMaxAmt
							ELSE @psAgentCommPcntAmt
						  END
		,bankComm		= CASE
							WHEN @bankCommPcntAmt < @bankCommMinAmt THEN @bankCommMinAmt 
							WHEN @bankCommPcntAmt > @bankCommMaxAmt THEN @bankCommMaxAmt
							ELSE @bankCommPcntAmt
						  END
	RETURN
END
GO
