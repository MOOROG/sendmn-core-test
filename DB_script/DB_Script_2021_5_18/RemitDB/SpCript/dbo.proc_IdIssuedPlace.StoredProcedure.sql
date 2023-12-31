USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_IdIssuedPlace]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[proc_IdIssuedPlace]
 @flag					VARCHAR(50)		= NULL
,@user                  VARCHAR(30)		= NULL
,@idType				VARCHAR(25)		= NULL
,@countryId				INT				= NULL
,@sortBy                VARCHAR(50)		= NULL
,@sortOrder             VARCHAR(5)		= NULL
,@pageSize              INT				= NULL
,@pageNumber            INT				= NULL

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	
	IF ISNULL(@countryId,'')=''
		SET @countryId='151'
	
	IF ISNULL(@idType,'')<>''
	BEGIN
		IF @idType = '1304' -- Driving License
			SET @flag = 'zone'
		ELSE IF @idType = '1302' -- Passport
			SET @flag = 'country'
		ELSE
			SET @flag = 'district'
	END
	ELSE
		SET @flag = 'district'

	IF @flag = 'district' -- District List
	BEGIN		
		SELECT
			zdm.districtName valueId
			,zdm.districtName detailTitle

		FROM zoneDistrictMap zdm WITH (NOLOCK) 
		WHERE ISNULL(zdm.isDeleted, 'N')  <> 'Y'
		ORDER BY districtName
		RETURN	
	END

	IF @flag = 'zone' -- ZONE List
	BEGIN			
		SELECT 
			stateName valueId
			,stateName detailTitle
		FROM countryStateMaster WITH(NOLOCK) 
		WHERE countryId = @countryId
		AND ISNULL(isDeleted, 'N') <> 'Y'			
		ORDER BY stateName
		RETURN	

	END	

	IF @flag = 'country'
	BEGIN		
				
		SELECT 
			 countryName valueId
			,countryName detailTitle
			,1 rankId
		FROM countryMaster WITH(NOLOCK) 		
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		ORDER BY detailTitle
		
	END

END TRY	

BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, NULL

END CATCH	

GO
