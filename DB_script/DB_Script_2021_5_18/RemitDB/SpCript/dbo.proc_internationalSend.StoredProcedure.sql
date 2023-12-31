USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_internationalSend]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec proc_internationalSend @flag='cal',@agentId='3885',@collCurrency='MYR',@payCountryId='104',@payCorrency='INR',@tranType='1',@amount='1200'
EXEC proc_internationalSend @flag = 'fee', @agentId = '3885', @pCountry = '151', @cCurrency = 'MYR', 
@ExRate = '24.137074', @tranType = '1', @sendAmount = '300000', @recAmount = null, @user = 'admin'
*/
CREATE proc [dbo].[proc_internationalSend]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@cCurrency							VARCHAR(30)		= NULL	
	,@pCountry							INT				= NULL
	,@pCurrency							VARCHAR(50)		= NULL
	,@tranType							INT				= NULL
	,@sendAmount						FLOAT		    = NULL
	,@recAmount							FLOAT			= NULL
	,@ExRate							FLOAT			= NULL
	,@sMemberId							VARCHAR(50)		= NULL
	,@sFName							VARCHAR(200)	= NULL
	,@sMName							VARCHAR(200)	= NULL
	,@sLName							VARCHAR(200)	= NULL
	,@sMobile							VARCHAR(200)	= NULL
	,@sDOB								VARCHAR(200)	= NULL					
				

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


BEGIN TRY

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE @table AS VARCHAR(MAX),	@ServiceCharge AS FLOAT	
		
	IF @flag = 'a'
	BEGIN
		
		SELECT a.currencyId,b.currencyCode FROM agentCurrency a WITH(NOLOCK) 
		INNER JOIN currencyMaster b WITH(NOLOCK)  ON a.currencyId=b.currencyId
		WHERE agentId=@agentId	
	
	END
	IF @flag = 'exRate'
	BEGIN		
			IF @recAmount =0
				SET @recAmount=NULL
			IF @sendAmount =0
				SET @sendAmount=NULL				
				
			SELECT  CAST(ISNULL(customerCrossRate, 0) AS DECIMAL(11, 6)) ExRate
			FROM dbo.FNAGetExRateForTran(@agentId, NULL, @pCountry, @cCurrency, @pCurrency,@tranType,@user)

	END
	IF @flag = 'fee'
	BEGIN		
	
			IF @recAmount =0
				SET @recAmount=NULL
				
			IF @sendAmount =0
				SET @sendAmount=NULL	
							
			IF @recAmount IS NULL AND @sendAmount IS NOT NULL
			BEGIN	
			
				SELECT @ServiceCharge=ISNULL(amount,0) FROM [dbo].FNAGetSC(@agentId, NULL, @pCountry, NULL, NULL ,@tranType, @sendAmount, @cCurrency)
				
				SELECT '<font color=''red''><b>'+CAST(ISNULL(@ServiceCharge,'0.00') AS VARCHAR)+'</b></font>' ServiceCharge
						,'<font color=''red''><b>'+dbo.ShowDecimal(@sendAmount*@ExRate+@ServiceCharge)+'</b></font>' [cAmount]
						,dbo.ShowDecimalExceptComma(@sendAmount) sendAmount
						,dbo.ShowDecimalExceptComma(@sendAmount*@ExRate) recAmount
				
			END
			
			IF @recAmount IS NOT NULL AND @sendAmount IS NULL
			BEGIN	
				SET @sendAmount =@recAmount/@ExRate
				
				SELECT @ServiceCharge=ISNULL(amount,0) FROM [dbo].FNAGetSC(@agentId, NULL, @pCountry, NULL, NULL ,@tranType, @sendAmount, @cCurrency)
				SELECT '<font color=''red''><b>'+CAST(ISNULL(@ServiceCharge,'0.00') AS VARCHAR)+'</b></font>' ServiceCharge
						,'<font color=''red''><b>'+dbo.ShowDecimal(@ExRate*@sendAmount+@ServiceCharge)+'</b></font>' [cAmount]
						,dbo.ShowDecimalExceptComma(@sendAmount) sendAmount
						,dbo.ShowDecimalExceptComma(@recAmount) recAmount
			END

	END
	
	IF @flag=''
	BEGIN
	
		SELECT * FROM customers WHERE membershipId=@sMemberId 
		
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
