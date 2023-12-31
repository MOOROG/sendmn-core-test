USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNASplitName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNASplitName](@fullName VARCHAR(200))
RETURNS @list TABLE(firstName VARCHAR(100), middleName VARCHAR(100), lastName1 VARCHAR(100), lastName2 VARCHAR(100), fullName VARCHAR(200))
AS
BEGIN
	DECLARE @nameTable TABLE(id INT, value VARCHAR(100))
	DECLARE @firstName VARCHAR(100), @middleName VARCHAR(100), @lastName1 VARCHAR(100), @lastName2 VARCHAR(100)
	
	INSERT INTO @nameTable
	SELECT * FROM dbo.split(' ', @fullName)

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

GO
