USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCountryCurrency]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----select * from dbo.GetCountryCurrency(203,1,2091)

CREATE FUNCTION [dbo].[GetCountryCurrency]
(
	@countryId int,@payoutMethodId INT,@agentId INT
)
RETURNS 
@CountryCurrency TABLE 
(
	[Key] VARCHAR(10) NULL,[value] VARCHAR(20) NULL
)
AS
BEGIN
	IF @countryId = 203
	BEGIN
		IF @payoutMethodId = 1 AND @agentId IN(2091,2093)
		BEGIN
			INSERT INTO @CountryCurrency([Key],[value])
			SELECT [Key] = 1 , [Value] = 'VND' UNION ALL
			SELECT [Key] = 0 , [Value] = 'USD'
		END
		ELSE IF @payoutMethodId = 12
		BEGIN
			INSERT INTO @CountryCurrency([Key],[value])
			SELECT [Key] = 1 , [Value] = 'VND' UNION ALL
			SELECT [Key] = 0 , [Value] = 'USD'
		END
		ELSE
		BEGIN
			INSERT INTO @CountryCurrency([Key],[value])
			SELECT [Key] = 1 , [Value] = 'VND'
		END
	END
	ELSE IF @countryId = 42
	BEGIN
		IF @agentId IN (221297,221281)
		BEGIN
			INSERT INTO @CountryCurrency([Key],[value])
			SELECT [Key] = 1 , [Value] = 'LKR'
		END
		IF @payoutMethodId = 2
		BEGIN
			INSERT INTO @CountryCurrency([Key],[value])
			SELECT [Key] = 1 , [Value] = 'LKR' UNION ALL
			SELECT [Key] = 0 , [Value] = 'USD'
		END
		ELSE
		BEGIN
			INSERT INTO @CountryCurrency([Key],[value])
			SELECT [Key] = 1 , [Value] = 'LKR'
		END
	END
	ELSE
	BEGIN
		INSERT INTO @CountryCurrency([Key],[value])
		SELECT DISTINCT [Key] = case when isnull(isDefault, 'Y') = 'Y' then 1 else 0 end , [Value] = CM.currencyCode
		FROM countryCurrency a(NOLOCK) 
		inner join currencyMaster cm(nolock) on cm.currencyId = a.currencyId
		where ISNULL(a.isActive, 'Y')  = 'Y' AND ISNULL(a.isDeleted, 'N') = 'N'
		and cm.currencyCode <> 'KRW'
		and a.countryId = @countryId
	END
	RETURN 
END
GO
