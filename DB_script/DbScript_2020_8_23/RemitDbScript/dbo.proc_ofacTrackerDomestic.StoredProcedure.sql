USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ofacTrackerDomestic]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
declare @Result1 varchar(max)
EXEC proc_ofacTracker @flag = 't', @name = 'Saroj Chalisee', @Result=@Result1 output
print @Result1

*/

CREATE proc [dbo].[proc_ofacTrackerDomestic]
	 @flag			CHAR(10)		= NULL
	,@user			VARCHAR(50)		= NULL
	,@name			VARCHAR(100)	= NULL
	,@Result		VARCHAR(MAX)	= NULL OUTPUT
	
AS

SET NOCOUNT ON;
DECLARE @firstName VARCHAR(100), @middleName VARCHAR(100), @lastName1 VARCHAR(100), @lastName2 VARCHAR(100)
DECLARE @possibleCombinations TABLE(name VARCHAR(200))
IF @flag = 't'
BEGIN   	   
	
	SELECT @firstName = firstName, @middleName = middleName, @lastName1 = lastName1, @lastName2 = lastName2 FROM dbo.FNASplitName(@name)	
	INSERT INTO @possibleCombinations
	SELECT ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '') UNION ALL
	SELECT ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @lastName1, '') UNION ALL
	SELECT ISNULL(@firstName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName2, '') UNION ALL
	SELECT ISNULL(@firstName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @middleName, '') UNION ALL
	SELECT ISNULL(@firstName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') UNION ALL
	SELECT ISNULL(@firstName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @middleName, '') UNION ALL
	
	SELECT ISNULL(@middleName, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '') UNION ALL
	SELECT ISNULL(@middleName, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @lastName1, '') UNION ALL
	SELECT ISNULL(@middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName2, '') UNION ALL
	SELECT ISNULL(@middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @firstName, '') UNION ALL
	SELECT ISNULL(@middleName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName1, '') UNION ALL
	SELECT ISNULL(@middleName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @firstName, '') UNION ALL
	
	SELECT ISNULL(@lastName1, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName2, '') UNION ALL
	SELECT ISNULL(@lastName1, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @firstName, '') UNION ALL
	SELECT ISNULL(@lastName1, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName2, '') UNION ALL
	SELECT ISNULL(@lastName1, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @middleName, '') UNION ALL
	SELECT ISNULL(@lastName1, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @firstName, '') UNION ALL
	SELECT ISNULL(@lastName1, '') + ISNULL(' ' + @lastName2, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @middleName, '') UNION ALL
	
	SELECT ISNULL(@lastName2, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @firstName, '') UNION ALL
	SELECT ISNULL(@lastName2, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName1, '') UNION ALL
	SELECT ISNULL(@lastName2, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @firstName, '') UNION ALL
	SELECT ISNULL(@lastName2, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @middleName, '') UNION ALL
	SELECT ISNULL(@lastName2, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') UNION ALL
	SELECT ISNULL(@lastName2, '') + ISNULL(' ' + @firstName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @middleName, '')
	
	IF(SELECT OFAC_TRAN FROM OFACSetting WITH(NOLOCK)) = 'part'
	BEGIN
		SELECT @Result = COALESCE(@Result + ', ', '') +  ofacKey
		FROM
		(
			SELECT distinct TOP 20 
				CAST(OFAC.ofacKey AS varchar(100)) ofacKey
			FROM blacklist OFAC ,
			 (SELECT * FROM dbo.split(' ',@name))N
			WHERE OFAC.name like '%'+ N.value +'%'	AND isManual = 'd'	
			and ISNULL(isdeleted,'N') <> 'Y'
			and ISNULL(isActive,'Y') ='Y'	
		)X
		SET @Result = REPLACE(@Result,' ','')
		RETURN;
	END 
	ELSE
	BEGIN
		
		SELECT @Result = COALESCE(@Result + ', ', '') +  ofacKey
		FROM
		(
			SELECT distinct TOP 20  
				CAST(ofacKey AS varchar(100)) ofacKey   
			FROM blacklist o WITH(NOLOCK)   
			WHERE o.name = @name 
			AND isManual ='d'
			and ISNULL(isdeleted,'N') <> 'Y'
			and ISNULL(isActive,'Y') ='Y'
		)X
		SET @Result = REPLACE(@Result,' ','')
		RETURN;
	END
END





GO
