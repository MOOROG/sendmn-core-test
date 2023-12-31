USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetGIBLCommission]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetGIBLCommission](
		 @sBranch			INT
		,@ControlNo			VARCHAR(20)
		,@deliveryMethodId	INT
		,@provider			VARCHAR(20)
		)
RETURNS @list TABLE (sAgentComm MONEY,pAgentComm MONEY, commissionCurrency VARCHAR(3))
AS
BEGIN
	
	DECLARE @sCountrName VARCHAR(50),@payAmt MONEY,@subPartner INT,@pAgentComm MONEY

	--SELECT @sCountrName = countryName FROM countrymaster(nolock) where countryid = @sCountry
	IF @provider = 'GIBL'
	BEGIN
		SELECT @sCountrName = RCURRENCY FROM globalBankPayHistory (NOLOCK) WHERE RADNO = @ControlNo

		SELECT TOP 1
			@sCountrName = cm.countryName
		FROM countryMaster cm WITH(NOLOCK) 
		INNER JOIN countryCurrency cc WITH(NOLOCK) ON cm.countryId = cc.countryId
		INNER JOIN currencyMaster currM WITH(NOLOCK) ON currM.currencyId = cc.currencyId
		WHERE currM.currencyCode = @sCountrName

		INSERT INTO @list
		SELECT 
			sAgentComm = CASE @sCountrName 
							WHEN 'INDIA' THEN 80 
							WHEN 'United Arab Emirates' THEN 90 
							ELSE 118 END
			,pAgentComm = CASE @sCountrName 
							WHEN 'INDIA' THEN 60 
							WHEN 'United Arab Emirates' THEN 75 
							ELSE 85 END
			,CURR ='NPR'
	END

	ELSE IF @provider = 'KOREA' --## SUNMAN GLOBAL;--
	BEGIN
		--SELECT @subPartner = A.businessType  FROM AGENTMASTER A(nolock)
		--WHERE A.AgentId = @sBranch

		INSERT INTO @list
		SELECT 
			sAgentComm = 1
			--,pAgentComm = CASE WHEN @subPartner IN (6201) THEN 100 ELSE 85 END
			,pAgentComm = 100
		,CURR ='NPR'
	END

	ELSE IF @provider = 'GIBLTFS'
	BEGIN
	INSERT INTO @list
		SELECT 
			sAgentComm = 118
			,pAgentComm = 85
			,CURR ='NPR'
	END
	ELSE IF @provider = 'EBL'
	BEGIN
		INSERT INTO @list
		SELECT sAgentComm = CASE WHEN amount <= 50000 THEN 50 
								 WHEN amount BETWEEN 50000.01 AND 100000 THEN 75 
								 ELSE 100 END 
				,pAgentComm = CASE WHEN amount <= 100000 THEN 50 ELSE 75 END
				,CURR ='NPR'
		FROM eblPayHistory(nolock) where radNo = @ControlNo
	END
	ELSE IF @provider = 'SUNMAN' --## SUNMAN GLOBAL;--
	BEGIN
		SELECT @subPartner = A.businessType  FROM AGENTMASTER A(nolock)
		--INNER JOIN staticDataValue V ON A.businessType = v.valueId
		WHERE A.AgentId = @sBranch

		INSERT INTO @list
		SELECT 
			sAgentComm = 1.2
			,pAgentComm = CASE WHEN @subPartner IN (6201,6202) THEN 100 ELSE 85 END
		,CURR ='NPR'
	END
	ELSE IF @provider = 'MAX' --## MAX MONEY--
	BEGIN
		SELECT @subPartner = A.businessType  FROM AGENTMASTER A(nolock)
		--INNER JOIN staticDataValue V ON A.businessType = v.valueId
		WHERE A.AgentId = @sBranch

		--SELECT @payAmt = Amount FROM MaxMoneyPayHistory(NOLOCK) WHERE refNo = @ControlNo

		INSERT INTO @list
		SELECT 
			sAgentComm = 4.5
			,pAgentComm = CASE WHEN @subPartner IN (6201,6202) THEN 100 ELSE 85 END
		,CURR ='NPR'
	END
	ELSE IF @provider = 'KUMARI'
	BEGIN
		
		SELECT @payAmt = Amount,@subPartner = ISNULL(subPartnerId,1)
		FROM kumariBankPayHistory(NOLOCK) WHERE RefNo = @ControlNo

		IF @subPartner = 1 -- KUMARI OWN TXN --
		BEGIN
			INSERT INTO @list
			SELECT 
				sAgentComm = CASE WHEN @payAmt BETWEEN 1 AND 10000 THEN 30
									 WHEN @payAmt BETWEEN 10000.01 AND 25000 THEN 45
									 WHEN @payAmt BETWEEN 25000.01 AND 50000 THEN 60
									 WHEN @payAmt BETWEEN 50000.01 AND 100000 THEN 75
									 WHEN @payAmt BETWEEN 100000.01 AND 200000 THEN 105
									 WHEN @payAmt BETWEEN 200000.01 AND 900000 THEN 135
								END
				,pAgentComm = CASE WHEN @payAmt BETWEEN 1 AND 10000 THEN 25
									 WHEN @payAmt BETWEEN 10000.01 AND 25000 THEN 40
									 WHEN @payAmt BETWEEN 25000.01 AND 50000 THEN 55
									 WHEN @payAmt BETWEEN 50000.01 AND 100000 THEN 70
									 WHEN @payAmt BETWEEN 100000.01 AND 200000 THEN 100
									 WHEN @payAmt BETWEEN 200000.01 AND 900000 THEN 130
								END
			,CURR ='NPR'	
		END
		ELSE IF @subPartner = 10000267  -- JME Nepal --
		BEGIN
			INSERT INTO @list
			SELECT 
				sAgentComm = CASE WHEN @payAmt BETWEEN 1 AND 100000 THEN 70
									 WHEN @payAmt BETWEEN 100000.01 AND 300000 THEN 85
									 WHEN @payAmt BETWEEN 300000.01 AND 500000 THEN 110
									 WHEN @payAmt BETWEEN 500000.01 AND 1000000 THEN 130
									 WHEN @payAmt BETWEEN 1000000.01 AND 9000000 THEN 130
								END
				,pAgentComm = CASE WHEN @payAmt BETWEEN 1 AND 100000 THEN 60
									 WHEN @payAmt BETWEEN 100000.01 AND 300000 THEN 60
									 WHEN @payAmt BETWEEN 300000.01 AND 500000 THEN 60
									 WHEN @payAmt BETWEEN 500000.01 AND 1000000 THEN 60
									 WHEN @payAmt BETWEEN 1000000.01 AND 9000000 THEN 60
								END
			,CURR ='NPR'	
		END
		ELSE IF @subPartner = 10000268 --Xpress Money --
		BEGIN
			INSERT INTO @list
			SELECT 
				sAgentComm = 70
				,pAgentComm = 50
			,CURR ='NPR'	
		END
		ELSE IF @subPartner IN( 10000263) --MAX Money --
		BEGIN
			INSERT INTO @list
			SELECT 
				sAgentComm = 105
				,pAgentComm = 75
			,CURR ='NPR'	
		END
	END

	RETURN
END	
GO
