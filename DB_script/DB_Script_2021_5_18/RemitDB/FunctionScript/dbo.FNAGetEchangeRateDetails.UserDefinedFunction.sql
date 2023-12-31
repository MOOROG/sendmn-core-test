USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetEchangeRateDetails]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetEchangeRateDetails](@masterId BIGINT, @masterType CHAR(1), @lookInTable VARCHAR(4))
RETURNS @list TABLE(cost MONEY, margin MONEY, agentMargin MONEY, ve MONEY, ne MONEY)
AS
BEGIN
	DECLARE
		 @cost MONEY
		,@margin MONEY
		,@agentMargin MONEY
		,@ve MONEY
		,@ne MONEY
		
	
	IF @masterType = 'S'
	BEGIN
		IF @lookInTable = 'MAIN'
		BEGIN
			SELECT 
				 @cost = cost
				,@margin = margin
				,@agentMargin = agentMargin
				,@ve = ve
				,@ne = ne
			FROM seRate 
			WHERE 
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND seRateId = @masterId		
		END
		ELSE
		BEGIN
			SELECT 
				 @cost = cost
				,@margin = margin
				,@agentMargin = agentMargin
				,@ve = ve
				,@ne = ne
			FROM seRateHistory 
			WHERE 
				approvedBy IS NULL
				AND seRateId = @masterId		
		END
	END
	ELSE
	BEGIN
		IF @lookInTable = 'MAIN'
		BEGIN
			SELECT 
				 @cost = cost
				,@margin = margin
				,@ve = ve
				,@ne = ne
			FROM deRate 
			WHERE
				ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N' 
				AND deRateId = @masterId
		END
		ELSE
		BEGIN
			SELECT 
				 @cost = cost
				,@margin = margin
				,@ve = ve
				,@ne = ne
			FROM deRateHistory 
			WHERE
				approvedBy IS NULL
				AND deRateId = @masterId
				
		END
	END
		
	INSERT @list	
	SELECT 
		 cost = @cost
		,margin = @margin
		,agentMargin = @agentMargin
		,ve = @ve
		,ne = @ne
		
	RETURN	
END
GO
