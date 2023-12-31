USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_autocomplete]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_online_autocomplete] (
	 @Category		VARCHAR(50) 
	,@SearchText	VARCHAR(50) 
	,@Param1		VARCHAR(50) = NULL
	,@Param2		VARCHAR(50) = NULL
	,@Param3		VARCHAR(50) = NULL
	,@Param4		VARCHAR(50) = NULL
)
AS
SET NOCOUNT ON

DECLARE @SQL VARCHAR(MAX)
IF @category='agentCity'
BEGIN
	SELECT value = stateName, [text] = stateName  FROM dbo.countriesStates rcs WITH(NOLOCK)
	INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode  WHERE countryId = @param1
	AND stateName LIKE @searchText + '%' ORDER BY stateName
END

GO
