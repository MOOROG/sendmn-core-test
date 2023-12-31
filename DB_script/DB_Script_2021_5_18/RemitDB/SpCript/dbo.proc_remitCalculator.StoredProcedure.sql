USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_remitCalculator]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec proc_remitCalculator @flag='cal',@agentId='3885',@collCurrency='MYR',@payCountryId='104',@payCorrency='INR',@tranType='1',@amount='1200'
exec proc_remitCalculator @flag='cal',@agentId='3885',@collCurrency='MYR',@payCountryId='151',@payCorrency='NPR',@tranType='1',@amountRec='30000'
EXEC proc_serviceTypeMaster 'l2'

SELECT * FROM COUNTRYMASTER WHERE COUNTRYNAME='NEPAL'
*/
CREATE proc [dbo].[proc_remitCalculator]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@collCurrency						VARCHAR(30)		= NULL	
	,@payCountryId						INT				= NULL
	,@payCorrency						VARCHAR(50)		= NULL
	,@tranType							INT				= NULL
	,@amount							MONEY		    = NULL
	,@amountRec							FLOAT			= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


BEGIN TRY

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE @table AS VARCHAR(MAX)
		
	IF @flag = 'a'
	BEGIN
		
		SELECT a.currencyId,b.currencyCode FROM agentCurrency a WITH(NOLOCK) 
		INNER JOIN currencyMaster b WITH(NOLOCK)  ON a.currencyId=b.currencyId
		WHERE agentId=@agentId	
	
	END
	IF @flag = 'cal'
	BEGIN		
			IF @amountRec =0
				SET @amountRec=NULL
			IF @amount =0
				SET @amount=NULL
				
				
			DECLARE @rate AS FLOAT,@fee AS FLOAT,@tranTypeName AS VARCHAR(50)
			SELECT @rate = CAST(ISNULL(customerCrossRate, 0) AS DECIMAL(11, 6)) 
			FROM dbo.FNAGetExRateForTran(@agentId, NULL, @payCountryId, @collCurrency, @payCorrency,@tranType,@user)
			
			SELECT @fee = amount FROM [dbo].FNAGetSC(@agentId, NULL, @payCountryId,	NULL, NULL , @tranType, @amount, @collCurrency)
			SELECT @tranTypeName=typeTitle FROM serviceTypeMaster WHERE serviceTypeId=@tranType
			
			IF @amountRec IS NULL AND @amount IS NOT NULL
			BEGIN
				SELECT @collCurrency collCurr
						,countryName
						,@payCorrency payCurr
						,'<font color=''red''><b>'+cast(@rate as varchar)+ '</b></font>' rate
						,dbo.ShowDecimal(@amount) sendAmt
						,'<font color=''red''><b>'+ dbo.ShowDecimal((@amount*@rate))+ '</b></font>' recAmount
						,'<font color=''red''><b>'+dbo.ShowDecimal(ISNULL(@fee,0))+ '</b></font>' Fee		
						,@tranTypeName tranType	 
				FROM countryMaster a WITH(NOLOCK) WHERE countryId=@payCountryId
			END
			IF @amount IS NULL AND @amountRec IS NOT NULL
			BEGIN		

				SELECT @collCurrency collCurr
						,countryName
						,@payCorrency payCurr
						,'<font color=''red''><b>'+cast(@rate as varchar)+ '</b></font>' rate
						,'<font color=''red''><b>'+dbo.ShowDecimal(@amountRec/case when @rate=0 then 1 ELSE @rate end)+ '</b></font>' sendAmt
						,dbo.ShowDecimal(@amountRec) recAmount
						,'<font color=''red''><b>'+dbo.ShowDecimal(ISNULL(@fee,0))+ '</b></font>' Fee		
						,@tranTypeName tranType	 
				FROM countryMaster a WITH(NOLOCK) WHERE countryId=@payCountryId
			END
			IF @amount IS NULL and @amountRec is null
			BEGIN		

				SELECT @collCurrency collCurr
						,countryName
						,@payCorrency payCurr
						,'<font color=''red''><b>'+cast(@rate as varchar)+ '</b></font>' rate
						,'0.00' sendAmt
						,'0.00' recAmount
						,'0.00' Fee		
						,@tranTypeName tranType	  FROM countryMaster a WITH(NOLOCK) WHERE countryId=@payCountryId
			END
	
	END


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH


GO
