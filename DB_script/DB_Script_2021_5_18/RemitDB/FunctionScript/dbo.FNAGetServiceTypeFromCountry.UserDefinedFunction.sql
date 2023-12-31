USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetServiceTypeFromCountry]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetServiceTypeFromCountry](@rsCountryId VARCHAR(20),@agentId VARCHAR(20))
RETURNS @serviceList TABLE(serviceTypeId INT,typeTitle VARCHAR(100)) 
AS
BEGIN
	IF EXISTS(SELECT 'A' FROM rsList1 WHERE rsCountryId =@rsCountryId AND countryId = 
					(SELECT agentCountryId FROM agentMaster WHERE agentId = @agentId) 
				AND tranType IS NOT NULL)
		BEGIN
		INSERT INTO @serviceList
		SELECT serviceTypeId,typeTitle 
			FROM serviceTypeMaster 
			WHERE ISNULL(isDeleted,'N')='N' AND ISNULL(isActive,'Y')='Y'
			AND serviceTypeId IN (SELECT tranType FROM rsList1 WHERE rsCountryId =@rsCountryId
			AND countryId = (SELECT agentCountryId FROM agentMaster WHERE agentId = @agentId))
		
		END
		ELSE
		 INSERT INTO @serviceList
		 SELECT serviceTypeId,typeTitle 
			FROM serviceTypeMaster 
			WHERE ISNULL(isDeleted,'N')='N' AND ISNULL(isActive,'Y')='Y'
		UNION ALL SELECT NULL,NULL
	
	RETURN
END		



GO
