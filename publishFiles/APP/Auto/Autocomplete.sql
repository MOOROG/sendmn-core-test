ALTER PROC proc_autocomplete (
	 @category VARCHAR(20) 
	,@searchText VARCHAR(20) 
	,@param1 VARCHAR(20) = NULL
	,@param2 VARCHAR(20) = NULL
	,@param3 VARCHAR(20) = NULL
)
AS

IF @category = 'agent'
BEGIN
	SELECT TOP 20
		agentId,
		agentName
	FROM agentMaster
	WHERE agentName LIKE ISNULL(@searchText, '') + '%'
	ORDER BY agentName ASC
	
	RETURN
END

IF @category = 'user'
BEGIN
	SELECT TOP 20
		userID,
		userName
	FROM applicationUsers
	WHERE userName LIKE ISNULL(@searchText, '') + '%'
	ORDER BY userName ASC
	
	RETURN
END
IF @category = 'users'
BEGIN
	SELECT TOP 20
		userID,
		userName
	FROM applicationUsers
	WHERE userName LIKE ISNULL(@searchText, '') + '%'
	AND userType LIKE ISNULL(@param1, '') + '%'
	ORDER BY userName ASC
	
	RETURN
END

IF @category = 'country'
BEGIN
	SELECT TOP 20
		countryId,
		countryName
	FROM countryMaster 
	WHERE countryName LIKE ISNULL(@searchText, '') + '%'
	
	ORDER BY countryName ASC
	
	RETURN
END