SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER  PROCEDURE Proc_ThirdPartyExRate
		@FLAG				VARCHAR(30)
	--grid parameters
	,@user						VARCHAR(50)		= NULL
	,@pageSize					VARCHAR(50)		= NULL
	,@pageNumber				VARCHAR(50)		= NULL
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(50)		= NULL
    ,@settlementRate			MONEY			= NULL
    ,@jmeMarginRate 		    MONEY			= NULL
    ,@customerRate 			    MONEY 			= NULL
    ,@overrideTFCustRate	    MONEY 			= NULL
    ,@EnableDisable			    char(1)			= NULL
    ,@rowId					    INT				= NULL
	,@rateMarginOverTFRate		MONEY			= NULL 
	,@countryName				VARCHAR(100)	= NULL
	,@agentName					VARCHAR(100)	= NULL
	,@country                   INT				= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
		DECLARE  @table				VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			DECLARE @NEW_RECORD INT, @MSG VARCHAR(200)
	IF @FLAG = 'S'
	BEGIN
		SET @sortBy = 'ROW_ID'
		SET @sortOrder = 'desc'

		SET @table = '( 
						SELECT  TPARS.ROW_ID ,
								CM.countryCode,
								CM.countryName,
						        CM.countryName +'' (''+TPARS.PAYOUT_CURRENCY+'')'' [Payout_Country] ,
						        AM.agentName [Payout_Partner] ,
						        TPARS.PARTNER_CUSTOMER_RATE ,
						        TPARS.PARTNER_SETTLEMENT_RATE ,
						        TPARS.RATE_MARGIN_OVER_PARTNER_RATE ,
						        TPARS.JME_MARGIN ,
						        TPARS.OVERRIDE_CUSTOMER_RATE ,
								IS_ACTIVE = CASE WHEN TPARS.IS_ACTIVE = 1 THEN ''YES'' ELSE ''NO'' END
						FROM    dbo.TP_API_RATE_SETUP TPARS ( NOLOCK )
						        INNER JOIN dbo.countryMaster CM ON CM.countryId = TPARS.PAYOUT_COUNTRY
						        INNER JOIN dbo.agentMaster AM ON AM.agentId = TPARS.PAYOUT_PARTNER
					 '

		SET @sql_filter = ''
		SET @table = @table + ')x'

		IF @countryName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''

		IF @agentName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND Payout_Partner LIKE ''%' + @agentName + '%'''

		SET @select_field_list  = '
				ROW_ID,countryCode,countryName,Payout_Country,Payout_Partner,PARTNER_CUSTOMER_RATE,PARTNER_SETTLEMENT_RATE,RATE_MARGIN_OVER_PARTNER_RATE,JME_MARGIN,OVERRIDE_CUSTOMER_RATE,IS_ACTIVE'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	ELSE IF @FLAG = 'update'
	BEGIN 
	INSERT INTO dbo.TP_API_RATE_SETUP_HISTORY
	        ( API_RATE_SETUP_ROW_ID ,SENDING_COUNTRY ,PAYOUT_COUNTRY ,SENDING_CURRENCY ,PAYOUT_CURRENCY ,PAYOUT_PARTNER ,
	          PARTNER_CUSTOMER_RATE ,PARTNER_SETTLEMENT_RATE ,RATE_MARGIN_OVER_PARTNER_RATE ,JME_MARGIN ,
	          OVERRIDE_CUSTOMER_RATE ,IS_ACTIVE ,CREATED_BY ,CREATED_DATE)
	SELECT ROW_ID,SENDING_COUNTRY,PAYOUT_COUNTRY,SENDING_COUNTRY,PAYOUT_COUNTRY,PAYOUT_PARTNER,
			  PARTNER_CUSTOMER_RATE,PARTNER_SETTLEMENT_RATE,RATE_MARGIN_OVER_PARTNER_RATE,JME_MARGIN,
			  OVERRIDE_CUSTOMER_RATE,IS_ACTIVE,@user,GETDATE()
	FROM dbo.TP_API_RATE_SETUP WHERE ROW_ID = @rowId
	UPDATE dbo.TP_API_RATE_SETUP SET PARTNER_CUSTOMER_RATE=@customerRate
									,PARTNER_SETTLEMENT_RATE=@settlementRate
									,RATE_MARGIN_OVER_PARTNER_RATE=@rateMarginOverTFRate
									,JME_MARGIN=@jmeMarginRate
									,OVERRIDE_CUSTOMER_RATE=@overrideTFCustRate
									,IS_ACTIVE  =CASE WHEN @EnableDisable ='Y' THEN 1 ELSE 0 end 
									,MODIFIED_BY = @user
									,MODIFIED_DATE= GETDATE()
					WHERE ROW_ID = @rowId
	SELECT '0' ErrorCode , 'Record has been updated successfully.' Msg , @rowId	 
	END 
END

GO

