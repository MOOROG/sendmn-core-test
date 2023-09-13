-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <5/8/2019,>
-- =============================================
USE FastMoneyPro_Remit
GO

alter PROCEDURE proc_importSettlementRate 
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
		IF OBJECT_ID('tempdb..#exRate') IS NOT NULL DROP TABLE #exRate

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
