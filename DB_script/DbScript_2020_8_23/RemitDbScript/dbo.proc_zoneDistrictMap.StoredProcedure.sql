USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_zoneDistrictMap]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_zoneDistrictMap]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@zone								VARCHAR(30)		= NULL
	,@districtId						INT				= NULL
	,@countryId							INT				= NULL
	,@districtName						VARCHAR(50)		= NULL
	,@apiDistrictCode					INT				= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
	SELECT
		 @logIdentifier = 'districtId'
		,@logParamMain = 'zoneDistrictMap'
		,@logParamMod = 'zoneDistrictMapMod'
		,@module = '20'
		,@tableAlias = ''
	
	IF @flag = 'll_g' -- Grid Location List
	BEGIN
		SELECT [value], [text] FROM (
		SELECT NULL [value], 'All' [text] UNION ALL
		SELECT 
			 districtCode
			,districtName = UPPER(districtName) 
		FROM api_districtList WITH(NOLOCK) 
		WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Y') = 'Y'
		)x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END	
				

		RETURN	
	END

	IF @flag = 'dl' -- Grid District List
	BEGIN

		SELECT [value], [text] FROM (
			SELECT NULL [value], 'All' [text] UNION ALL
			
			SELECT
				 zdm.districtName [value]
				,zdm.districtName [text]
			FROM zoneDistrictMap zdm WITH (NOLOCK) 
			WHERE ISNULL(zdm.isDeleted, 'N')  <> 'Y'  
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END	
		RETURN	
	END

	IF @flag = 'zl_g' -- Grid ZONE List
	BEGIN		
		SELECT [value], [text] FROM (
			SELECT NULL [value], 'All' [text] UNION ALL
			
			SELECT 
				 stateName
				,stateName 
			FROM countryStateMaster WITH(NOLOCK) 
			WHERE countryId = @countryId
			AND ISNULL(isDeleted, 'N') <> 'Y'
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END	
		RETURN	
	END
	
	IF @flag = 'l'
	BEGIN
		SELECT 
			 districtId
			,districtName 
		FROM zoneDistrictMap WITH(NOLOCK) 
		WHERE zone =@zone
		--zone = ISNULL(@zone, zone)
		AND ISNULL(isDeleted, 'N') <> 'Y'
		ORDER BY districtName
	END

	ELSE IF @flag = 'd'--populate all districts or district according to api district code
	BEGIN
		SELECT DISTINCT
			 zdm.districtId
			,zdm.districtName 
		FROM zoneDistrictMap zdm WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON zdm.districtId = alm.districtId		
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(apiDistrictCode, 0) = ISNULL(ISNULL(@apiDistrictCode, apiDistrictCode), 0)
		ORDER BY districtName
	END

	ELSE IF @flag = 'll' --Populate All Location or Locations according to District
	BEGIN
		SELECT DISTINCT
			 locationId		= districtCode
			,locationName	= districtName
		FROM api_districtList adl WITH(NOLOCK)
		LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
		WHERE ISNULL(isDeleted, 'N') = 'N' AND ISNULL(adl.isActive,'Y')='Y'
		AND alm.districtId = ISNULL(@districtId, alm.districtId)
		ORDER BY districtName
	END

	ELSE IF @flag = 'country'						-- CountryName List
	BEGIN
		SELECT 
			locationId = countryId,
			locationName = countryName
		FROM countryMaster WITH(NOLOCK) --Where isnull(isOperativeCountry,'') ='Y'
		ORDER BY countryName ASC
		RETURN
	END


	ELSE IF @flag = 's'
	BEGIN
		SELECT [state] = zone FROM zoneDistrictMap WHERE districtId = @districtId 
		RETURN
	END
	ELSE IF @flag = 'dis' --Populate All District 
	BEGIN
		SELECT  
			 districtId=zdm.districtId
			,districtName=zdm.districtName 
		FROM zoneDistrictMap zdm WITH(NOLOCK)	   
		WHERE ISNULL(isDeleted, 'N') = 'N' 		
		ORDER BY districtName
	END
	ELSE IF @flag = 'dwl'  --- district wise location
	BEGIN
		SELECT [0] districtCode, [1] districtName FROM (
		SELECT NULL [0], 'All' [1] UNION ALL
		 SELECT 
			  ad.districtCode
			 , ad.districtName from apiLocationMapping adm WITH(NOLOCK)
		 INNER JOIN api_districtList ad on ad.districtCode=adm.apiDistrictCode
		 WHERE ISNULL(isDeleted, 'N') = 'N' 
		 AND districtId = @districtId	
		 ) x ORDER BY CASE WHEN CAST(x.[0] AS VARCHAR) IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE CAST(x.[1] AS VARCHAR) END		
   END

END TRY	
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @districtId
END CATCH	




GO
