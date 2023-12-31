USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcApi_RateSheet]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

exec ProcApi_RateSheet @flag = 'api' ,@user='admin' ,@country='NEPAL'

*/

CREATE proc [dbo].[ProcApi_RateSheet]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@country                          VARCHAR(100)		= NULL
AS
BEGIN

    -- SELECT * FROM seRate 
    
    --SELECT R.countryName as country, rat.cost as   ExRate
	   --FROM seRate rat, countryMaster S , countryMaster R 
    --WHERE rat.sCountry = S.countryId and rat.rCountry = R.countryId
    --AND  sCountry=@country

    DECLARE @costRate FLOAT, @countryId INT
    SELECT @countryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @country
    SELECT @costRate = cost FROM deRate WITH(NOLOCK) WHERE country = @countryId

    SELECT 
	   Currency = cm.currencyCode ,Rate = cost/@costRate 
    FROM deRate r
    INNER JOIN currencyMaster cm WITH(NOLOCK) ON r.localCurrency = cm.currencyId
    WHERE spFlag = 'S'



END


GO
