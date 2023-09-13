SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
----select dbo.TEST(203,1,2091)

ALTER FUNCTION [dbo].GetAllowCurrency
(
	@countryId int,@payoutMethodId INT,@agentId INT
)
RETURNS VARCHAR(20)
--@CountryCurrency TABLE 
--(
--	[Key] VARCHAR(10) NULL,[value] VARCHAR(20) NULL
--)
AS
BEGIN
	DECLARE @currency VARCHAR(20)
	IF @countryId = 203
	BEGIN
		IF @payoutMethodId = 1 AND @agentId IN(2091,2093)
		BEGIN
			SET @currency =  'VND,USD'
		END
		ELSE IF @payoutMethodId = 12
		BEGIN
			SET @currency =  'VND,USD'
		END
		ELSE
		BEGIN
			SET @currency =  'VND'
		END
	END
	ELSE IF @countryId = 42
	BEGIN
		IF @agentId IN (221297,221281)
		BEGIN
			SET @currency =  'LKR'
		END
		IF @payoutMethodId = 2
		BEGIN
			SET @currency =  'LKR,USD'
		END
		ELSE
		BEGIN
			SET @currency =  'LKR'
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @currency = CM.currencyCode
		FROM countryCurrency a(NOLOCK) 
		inner join currencyMaster cm(nolock) on cm.currencyId = a.currencyId
		where ISNULL(a.isActive, 'Y')  = 'Y' AND ISNULL(a.isDeleted, 'N') = 'N'
		and cm.currencyCode <> 'MNT'
		and a.countryId = @countryId
	END

	RETURN  @currency
END
GO

