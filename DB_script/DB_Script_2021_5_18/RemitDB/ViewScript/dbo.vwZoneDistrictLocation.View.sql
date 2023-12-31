USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwZoneDistrictLocation]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwZoneDistrictLocation] 

AS

SELECT 
DISTINCT
	 locationId		= adl.districtCode
	,locationName	= adl.districtName
	,districtId		= dis.districtId
	,districtName	= dis.districtName			
	,zoneId			= zon.stateId
	,zoneName		= zon.stateName			
FROM api_districtList adl WITH(NOLOCK)
LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
LEFT JOIN zoneDistrictMap dis WITH(NOLOCK) ON dis.districtId=alm.districtId
left join countryStateMaster zon with(nolock) on zon.stateId=dis.zone

		


GO
