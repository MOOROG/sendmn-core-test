USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ViewCountryInfo]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_ViewCountryInfo]
     @flag				VARCHAR(50)
	,@countryId			INT			= NULL
	,@sortBy			VARCHAR(50)	= NULL
	,@sortOrder			VARCHAR(5)	= NULL
	,@pageSize			INT			= NULL
	,@pageNumber		     INT	= NULL
    ,@user				VARCHAR(50)	= NULL
AS
SET NOCOUNT ON;

IF @flag = 's'
BEGIN 
	
	DECLARE @agentList VARCHAR(MAX)

	SET @agentList = (SELECT STUFF((SELECT ', ' + CAST(agentName AS VARCHAR(MAX))FROM 
		(SELECT DISTINCT ISNULL(aM.agentName,'All Agent') agentName FROM rsList1 sC
			LEFT JOIN agentMaster aM on sC.rsAgentId =aM.agentId
			WHERE sc.RScountryId = @countryId AND  listType='IN' AND ISNULL(SC.isDeleted,'N')<>'Y') x 
	 for xml path('')),1,2,''))

	SELECT NULL [countryInfo]
	UNION ALL
	SELECT 'SEND RESTRICTIONS: '  [countryInfo]
	UNION ALL 
	SELECT ' * Send Money Transfer are available in: '+ISNULL(@agentList,'')
	UNION ALL
	SELECT ' ADDITIONAL RESTRICTIONS: '
	UNION ALL
	SELECT ' TIME ZONE: ' + CONVERT(VARCHAR(50),CURRENT_TIMESTAMP)
	UNION ALL
	SELECT ' ACCEPTABLE FORMS OF IDENTIFICATION: '
	UNION ALL
	SELECT distinct '- '+SD.detailTitle FROM countryIdType cI WITH(NOLOCK)
	LEFT JOIN staticDataValue SD WITH (NOLOCK) ON cI.IdTypeId =SD.valueId
	WHERE countryId=@countryId AND ISNULL(isDeleted,'N')<>'Y'
	UNION ALL
	SELECT CAST(DATEPART(YYYY,GETDATE()) AS VARCHAR)+' MAJOR BUSINESS HOLIDAYS - The following days are National Holidays and in-country Customers Service Center may be closed:'
	UNION ALL
	SELECT '- '+DATENAME(M,[eventDate])+'  '+ CAST(DATEPART(DD,[eventDate]) AS VARCHAR)+'     '+ eventName [event] FROM countryHolidayList
	WHERE countryId  = @countryId AND ISNULL(isDeleted,'N')<>'Y'
	----UNION ALL
	----SELECT countrySpecificMsg FROM [message] 
	----WHERE countrySpecificMsg IS NOT NULL
	----AND ISNULL(countryId,@countryId) = @countryId
	----AND msgType IN('S','R')

END


GO
