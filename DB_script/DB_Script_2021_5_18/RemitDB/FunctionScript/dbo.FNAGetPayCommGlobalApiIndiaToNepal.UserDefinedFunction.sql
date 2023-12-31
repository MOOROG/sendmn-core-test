USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetPayCommGlobalApiIndiaToNepal]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetPayCommGlobalApiIndiaToNepal](
		 @sBranch			BIGINT
		,@sCountry			INT
		,@sLocation			INT
		,@rsAgent			BIGINT
		,@rCountry			BIGINT
		,@rLocation			BIGINT
		,@rBranch			BIGINT
		,@payoutCurr		VARCHAR(3)
		,@serviceType		INT
		,@collAmt			MONEY
		,@payAmt			MONEY
		,@serviceCharge		MONEY
		,@hubComm			MONEY
		,@sAgentComm		MONEY
		)
RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY, commissionCurrency VARCHAR(3))
AS
BEGIN
	DECLARE @masterType CHAR(1) = 'S'
	INSERT INTO @list
	SELECT 28, @masterType, [dbo].FNAGetCommission(28, 'S', NULL, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency 
	FROM scPayMaster WHERE scPayMasterId = '28'
	--SELECT 28,'S',50,'NPR'
	RETURN
END	

GO
