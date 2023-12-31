USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_importSettlementRate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <5/8/2019,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[proc_importSettlementRate] 
	@XML		NVARCHAR(MAX)	= NULL,
    @user		NVARCHAR(35) ,
    @flag		VARCHAR(10),
	@sessionId	varchar(60)	= NULL 
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
IF @flag = 'i'
	BEGIN	
		IF OBJECT_ID('tempdb..#exRate') IS NOT NULL DROP TABLE #txnDetails

		DECLARE @XMLDATA XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@CODE','VARCHAR(20)') AS 'Code'
					,p.value('@COUNTRY','VARCHAR(150)') AS 'Country'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@CURRENCYPAIR','varchar(10)') AS 'CurrencyPair'
					,p.value('@SETTLMENTRATE','varchar(10)') AS 'SettlementRate'
		INTO #exRate
		FROM @XMLDATA.nodes('/root/row') AS apiStates(p)
		
		SELECT Country,CurrencyPair,SettlementRate INTO #exRate1
		FROM #exRate
		GROUP BY Country,CurrencyPair,SettlementRate

		DECLARE @sendingCurrency varchar(20),@payoutCurrency varchar(5),@payoutCountryId VARCHAR(50),@currencyPair VARCHAR(10)

		ALTER TABLE #exRate1 ADD countryId INT, sendingCurrency VARCHAR(5), payoutCurrency VARCHAR(5)

		UPDATE ER SET ER.countryId = CM.countryId, sendingCurrency = (SELECT fname FROM dbo.SplitToRow('/',CurrencyPair)), 
					payoutCurrency = (SELECT MNAME FROM dbo.SplitToRow('/',CurrencyPair))	
		FROM #exRate1 ER(NOLOCK)
		INNER JOIN dbo.countryMaster CM(NOLOCK) ON CM.countryName = ER.Country

		BEGIN TRANSACTION
			INSERT INTO dbo.TP_API_RATE_SETUP_HISTORY( API_RATE_SETUP_ROW_ID ,SENDING_COUNTRY ,PAYOUT_COUNTRY ,SENDING_CURRENCY ,PAYOUT_CURRENCY ,
						PAYOUT_PARTNER ,PARTNER_CUSTOMER_RATE ,PARTNER_SETTLEMENT_RATE ,RATE_MARGIN_OVER_PARTNER_RATE ,JME_MARGIN ,OVERRIDE_CUSTOMER_RATE ,
						IS_ACTIVE ,CREATED_BY ,CREATED_DATE)
			SELECT	ROW_ID,SENDING_COUNTRY,PAYOUT_COUNTRY,SENDING_CURRENCY,PAYOUT_CURRENCY,
						PAYOUT_PARTNER,PARTNER_CUSTOMER_RATE,PARTNER_SETTLEMENT_RATE,RATE_MARGIN_OVER_PARTNER_RATE,JME_MARGIN,OVERRIDE_CUSTOMER_RATE,
						IS_ACTIVE,@USER,GETDATE() 
			FROM #exRate1 E
			INNER JOIN dbo.TP_API_RATE_SETUP TA(NOLOCK) ON TA.PAYOUT_COUNTRY = e.countryId AND TA.SENDING_CURRENCY = E.sendingCurrency
						AND TA.SENDING_COUNTRY = '113' AND TA.PAYOUT_CURRENCY = E.payoutCurrency

			UPDATE TA SET TA.PARTNER_SETTLEMENT_RATE =ROUND(E.SettlementRate,4),
					TA.RATE_MARGIN_OVER_PARTNER_RATE =ROUND(E.SettlementRate * TA.JME_MARGIN,4),
					TA.PARTNER_CUSTOMER_RATE = ROUND(E.SettlementRate - (E.SettlementRate * TA.JME_MARGIN),4) 	
			FROM #exRate1 E
			INNER JOIN dbo.TP_API_RATE_SETUP TA(NOLOCK) ON TA.PAYOUT_COUNTRY = e.countryId AND TA.SENDING_CURRENCY = E.sendingCurrency
						AND TA.SENDING_COUNTRY = '113' AND TA.PAYOUT_CURRENCY = E.payoutCurrency

		COMMIT TRANSACTION
		EXEC dbo.proc_errorHandler 0, 'Success', NULL
		
    END 
END TRY
BEGIN CATCH
	IF @@TRANCOUNT <> 0
			ROLLBACK TRAN
    DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH
GO
