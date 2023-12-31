USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAValidatePassword]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	
*/
CREATE FUNCTION [dbo].[FNAValidatePassword](@pwd	VARCHAR(50))
RETURNS @list TABLE (errorCode INT, errorMsg VARCHAR(200), id VARCHAR(50))
AS
BEGIN
	DECLARE 
		 @minPwdLength	INT
		,@specialCharNo	INT
		,@numericNo		INT
		,@capNo			INT
	
	SELECT TOP 1
		 @minPwdLength = minPwdLength
		,@specialCharNo = specialCharNo
		,@numericNo = numericNo
		,@capNo = capNo
	FROM passwordFormat WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y'
	
	DECLARE @tblCountChar TABLE (strString VARCHAR(20))
	DECLARE @character TABLE (id INT IDENTITY(1,1), chr CHAR(1))
	
	DECLARE 
		 @count	INT
		,@maxLen INT
		,@specialCharCount INT
		,@numericCount INT
		,@capCount INT
	
	--Password word to each character in each row
	-----------------------------------------------------------------------------------------
	INSERT INTO @tblCountChar VALUES(@pwd)

	;WITH CharacterOccurrance AS
	 (
	   SELECT SUBSTRING(strString, 1, 1) AS Characters,
			  STUFF(strString, 1, 1, '') AS ProcessedString,
			  1 AS RunningNumber
	   FROM @tblCountChar
	   UNION ALL
	   SELECT SUBSTRING(ProcessedString, 1, 1) AS Characters,
			  STUFF(ProcessedString, 1, 1, '') AS ProcessedString,
			  RunningNumber + 1 AS RunningNumber
	   FROM CharacterOccurrance
	   WHERE LEN(ProcessedString) > 0
	 )

	INSERT INTO @character 
	SELECT Characters
	FROM CharacterOccurrance 
	-------------------------------------------------------------------------------------------------
	
	SELECT @maxLen = COUNT(*) FROM @character
	SELECT 
		 @count = 1
		,@specialCharCount = 0
		,@numericCount = 0
		,@capCount = 0
	
	--Check Password Length
	------------------------------------------------------------------------------------------
	IF (@maxLen < @minPwdLength)
	BEGIN
		INSERT INTO @list
		SELECT 1, 'Password must be at least of ' + CAST(@minPwdLength AS VARCHAR) + ' characters', NULL
		RETURN
	END
	------------------------------------------------------------------------------------------
	
	--Count special character, numeric character and capital character
	------------------------------------------------------------------------------------------
	WHILE(@count <= @maxLen)
	BEGIN
		IF ((SELECT chr FROM @character WHERE id = @count) LIKE '%[^a-zA-Z0-9]%')
			SET @specialCharCount = @specialCharCount + 1
		
		IF((SELECT chr FROM @character WHERE id = @count) LIKE '%[0-9]%')
			SET @numericCount = @numericCount + 1
		
		IF(SELECT dbo.FNACheckCapital((SELECT chr FROM @character WHERE id = @count))) = 1
			SET @capCount = @capCount + 1
		SET @count = @count + 1
	END
	-------------------------------------------------------------------------------------------
	
	INSERT INTO @list
	SELECT 0, NULL, NULL
		
	IF (@specialCharCount < @specialCharNo) OR (@numericCount < @numericNo) OR (@capCount < @capNo)
	BEGIN
		IF (@specialCharCount < @specialCharNo)
		BEGIN
			UPDATE @list SET
				 errorCode =  1
				,errorMsg = ISNULL(errorMsg + ';', '') + 'Must define ' + CAST(@specialCharNo AS VARCHAR) + ' special character(s)'
				,id = NULL
		END
		IF (@numericCount < @numericNo)
		BEGIN
			UPDATE @list SET
				 errorCode =  1
				,errorMsg = ISNULL(errorMsg + ';', '') + 'Must define ' + CAST(@numericNo AS VARCHAR) + ' numeric character(s)'
				,id = NULL
		END
		IF (@capCount < @capNo)
		BEGIN
			UPDATE @list SET
				 errorCode =  1
				,errorMsg = ISNULL(errorMsg + ';', '') + '<br/>Must define ' + CAST(@capNo AS VARCHAR) + ' capital letter(s)'
				,id = NULL
		END
		RETURN
	END
	UPDATE @list SET
	 errorCode =  0
	,errorMsg = errorMsg + 'Password Validation Successful'
	,id = NULL
	RETURN
END
GO
