USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[IsBankAccountValidationReq]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT dbo.IsBankAccountValidationReq(36,2,224388)

CREATE FUNCTION [dbo].[IsBankAccountValidationReq] 
(
	@country INT,@deliveryMethod INT,@bank bigint
)
RETURNS BIT
AS
BEGIN

	DECLARE @isAccalidate BIT=0,@agentId INT
	
	SELECT @agentId = AgentId FROM TblPartnerwiseCountry (NOLOCK)
	WHERE COUNTRYID = @country
	AND ISNULL(PaymentMethod, @deliveryMethod) = @deliveryMethod 
	AND IsActive = 1

	IF @country IN (36,105, 45) AND @deliveryMethod = 2 and @agentId =224388 --## tanglo
	BEGIN
		SET @isAccalidate = 1 
	END
	ELSE IF @country = 105 AND @deliveryMethod = 2 AND @agentId = 392226
	BEGIN
		SET @isAccalidate = 1 
		--SELECT @isAccalidate = CASE WHEN AGENTCODE = '0' THEN 0 ELSE 1 END 
		--FROM agentMaster (NOLOCK) WHERE agentId = @bank
	END
	ELSE IF @country IN (169) AND @deliveryMethod = 2 and @agentId = 224388 
	AND @bank IN (242480, 242455, 242458, 242460, 242459, 242454, 242462, 242463, 242484, 242473, 242456, 242464, 242453, 242469, 242466, 242467, 242468, 242481, 242476, 242479, 242452)
	BEGIN
		SET @isAccalidate = 1 
	END
	ELSE IF @country = 16 AND @deliveryMethod = 13 AND @agentId = 224388
	BEGIN
		SET @isAccalidate = 1
	END
	ELSE 
		SET @isAccalidate = 0

	RETURN @isAccalidate;

	--SELECT * FROM (
	--	SELECT 36 countryId,2 as deliveryMethod,224388 as partnerId,1 as isAccalidate  union 
	--	SELECT 105 countryId,2 as deliveryMethod,224388 as partnerId,1 as isAccalidate union 
	--	SELECT 45 countryId,2 as deliveryMethod,224388 as partnerId,1 as isAccalidate union 
	--	SELECT 105 countryId,2 as deliveryMethod,392226 as partnerId,1 as isAccalidate union 
	--	SELECT 169 countryId,2 as deliveryMethod,224388 as partnerId,1 as isAccalidate 
	--)X

END
GO
