USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetAPI]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_GetAPI](
	 @user		VARCHAR(50)	OUTPUT
	,@code		VARCHAR(50)	OUTPUT
	,@userName	VARCHAR(50)	OUTPUT
	,@password	VARCHAR(50)	OUTPUT
)
AS
SET NOCOUNT ON

DECLARE 
	 @agentId		INT
	,@districtId	VARCHAR(100)
	,@district		VARCHAR(100)

--SELECT @agentId = agentId FROM applicationUsers WHERE userName = @user
--SELECT @district = agentDistrict FROM agentMaster WHERE agentId = @agentId
--SELECT @districtId = districtId FROM zoneDistrictMap WHERE districtName = @district

--SELECT 
--	 @code		= userCode
--	,@userName	= userName
--	,@password	= password
--FROM apiUsers WHERE districtId = @districtId 

SELECT @code = '123@123', @userName = 'swift_api', @password = 'ktmnepal1'

RETURN





GO
