

ALTER FUNCTION [dbo].[FNASplitName_UNICODE](@fullName NVARCHAR(200))
RETURNS @list TABLE(firstName NVARCHAR(100), middleName NVARCHAR(100), lastName1 NVARCHAR(100), lastName2 NVARCHAR(100), fullName NVARCHAR(200))
AS
BEGIN
	DECLARE @nameTable TABLE(id INT, value NVARCHAR(100))
	DECLARE @firstName NVARCHAR(100), @middleName NVARCHAR(100), @lastName1 NVARCHAR(100), @lastName2 NVARCHAR(100)
	
	INSERT INTO @nameTable
	SELECT * FROM dbo.split_UNICODE(' ', @fullName)

	SELECT @firstName = value FROM @nameTable WHERE id = 1
	SELECT @middleName = value FROM @nameTable WHERE id = 2
	SELECT @lastName1 = value FROM @nameTable WHERE id = 3
	SELECT @lastName2 = COALESCE(ISNULL(@lastName2 + ' ', ''), '') + value FROM @nameTable WHERE id > 3
	IF @middleName IS NULL
	BEGIN
		INSERT INTO @list
		SELECT @firstName, @middleName, @lastName1, @lastName2, @fullName
		RETURN
	END
	IF @lastName1 IS NULL
	BEGIN
		SET @lastName1 = @middleName
		SET @middleName = NULL
		
		INSERT INTO @list
		SELECT @firstName, @middleName, @lastName1, @lastName2, @fullName
		RETURN
	END

	INSERT INTO @list
	SELECT @firstName, @middleName, @lastName1, @lastName2, @fullName
	RETURN
END


