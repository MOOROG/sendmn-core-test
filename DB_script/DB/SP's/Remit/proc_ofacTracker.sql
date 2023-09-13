use fastmoneypro_remit
go
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_ofacTracker]') AND TYPE IN (N'P', N'PC'))
      DROP PROCEDURE [dbo].proc_ofacTracker
GO
*/
/*
declare @Result1 varchar(max)
EXEC proc_ofacTracker @flag = 't', @name = 'premlal rokaya', @Result=@Result1 output
print @Result1
select * from blackList where entNum ='2983651' 
IBANEZ LOPEZ, Raul Alberto
declare @Result1 varchar(max)
EXEC proc_ofacTracker @flag = 'S', @name = 'Sunita Pathak B K', @Result=@Result1 output
print @Result1

*/

ALTER proc [dbo].[proc_ofacTracker]
	 @flag			CHAR(10)		= NULL
	,@user			VARCHAR(50)		= NULL
	,@name			NVARCHAR(100)	= NULL
	,@Result		VARCHAR(MAX)	= NULL OUTPUT
	
AS

SET NOCOUNT ON;
DECLARE @firstName NVARCHAR(100), @middleName NVARCHAR(100), @lastName1 NVARCHAR(100), @lastName2 NVARCHAR(100)
DECLARE @possibleCombinations TABLE(name NVARCHAR(200))
IF @flag = 't'
BEGIN   	   

	SELECT @firstName = firstName, @middleName = middleName, @lastName1 = lastName1, @lastName2 = lastName2 FROM dbo.FNASplitName_UNICODE(@name)		

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
			SELECT distinct TOP 100 
				CAST(OFAC.ofacKey AS varchar(100)) ofacKey
			FROM blacklist OFAC ,
			 (SELECT * FROM dbo.split_UNICODE(' ',@name) WHERE LEN(VALUE) > 3)N
			WHERE (' ' + OFAC.name + ' ' like '% '+ N.value + '[ .]%' OR ' ' + OFAC.name + ' ' like '% '+ N.value + '[ ,]%')
			AND ISNULL(ofac.isActive,'Y') <> 'N' 
			and ISNULL(isdeleted,'N') <> 'Y'		
		)X
		SET @Result = REPLACE(@Result,' ','')
		RETURN;
	END 
	ELSE
	BEGIN
		
		SELECT @Result = COALESCE(@Result + ', ', '') +  ofacKey
		FROM
		(
			SELECT distinct TOP 100  
				CAST(ofacKey AS varchar(100)) ofacKey   
			FROM blacklist OFAC 
			WHERE OFAC.name = @name
			AND ISNULL(ofac.isActive,'Y') <> 'N' 
			and ISNULL(isdeleted,'N') <> 'Y'
		)X
		SET @Result = REPLACE(@Result,' ','')
		RETURN;
	END

END

IF @flag = 's'
BEGIN        
    IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL 
    DROP TABLE #tempMaster
	
    IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL 
    DROP TABLE #tempDataTable	

	CREATE TABLE #tempDataTable
	(			
		DATA NVARCHAR(MAX) NULL
	)

    CREATE TABLE #tempMaster
    (			
	    ROWID INT IDENTITY(1,1)	
	   ,ofacKey NVARCHAR(200) NULL
    )    	

	SELECT @firstName = firstName, @middleName = middleName, @lastName1 = lastName1, @lastName2 = lastName2 FROM dbo.FNASplitName_UNICODE(@name)	
	
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

	IF (select OFAC_TRAN from OFACSetting with(nolock)) = 'part'
	BEGIN
		INSERT INTO #tempMaster (ofacKey)
		SELECT distinct TOP 20  ofacKey  
		FROM blacklist OFAC with(nolock),
			(select * from dbo.split_UNICODE(' ',@name) WHERE LEN(VALUE) > 3)N
		WHERE (' ' + OFAC.name + ' ' like '% '+ N.value + '[ .]%' OR ' ' + OFAC.name + ' ' like '% '+ N.value + '[ ,]%')
		AND ISNULL(ofac.isActive,'Y') <> 'N' 
		and ISNULL(isdeleted,'N') <> 'Y'
	END 
	ELSE
	BEGIN		  
		  INSERT INTO #tempMaster (ofacKey)
		  SELECT distinct TOP 20 ofacKey  
		  FROM blacklist OFAC with(nolock)
		  WHERE OFAC.name  = @name
		  AND ISNULL(ofac.isActive,'Y') <> 'N' 
		  and ISNULL(isdeleted,'N') <> 'Y'
	END
	
	
	DECLARE @TNA_ID AS INT,@MAX_ROW_ID AS INT,@ROW_ID AS INT=1,@ofacKeyId NVARCHAR(200),
	@SDN NVARCHAR(MAX)='',@ADDRESS NVARCHAR(MAX)='',@REMARKS AS NVARCHAR(MAX)='',
	@ALT AS NVARCHAR(MAX)='',@DATA AS NVARCHAR(MAX)='',@DATA_SOURCE AS NVARCHAR(200)=''
	
	
	SELECT @MAX_ROW_ID=MAX(ROWID) FROM #tempMaster
	
	WHILE @MAX_ROW_ID >=  @ROW_ID
	BEGIN		
		
		SELECT @ofacKeyId = ofacKey FROM #tempMaster WHERE ROWID=@ROW_ID		

		SELECT @SDN='<b>'+entNum+'</b>,  <b>Name:</b> '+name,@DATA_SOURCE='<b>Data Source:</b> '+dataSource
		FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'		
		
		SELECT @ADDRESS=ISNULL(address,'')+', '+isnull(city,'')+', '+ISNULL(state,'')+', '+ISNULL(zip,'')+', '+ISNULL(country,'')
		FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='add'
		
		SELECT @ALT = COALESCE(@ALT + ', ', '') +
				CAST(ISNULL(NAME,'') AS NVARCHAR(MAX))
		FROM  blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='alt'
			
				
		SELECT @REMARKS=ISNULL(remarks,'')
		FROM blacklist with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'

		SET @SDN=rtrim(ltrim(@SDN))
		SET @ADDRESS=rtrim(ltrim(@ADDRESS))
		SET @ALT=rtrim(ltrim(@ALT))
		SET @REMARKS=rtrim(ltrim(@REMARKS))	
		
		SET @SDN=REPLACE(@SDN,', ,','')
		SET @ADDRESS=REPLACE(@ADDRESS,', ,','')
		SET @ALT=REPLACE(@ALT,', ,','')
		SET @REMARKS=REPLACE(@REMARKS,', ,','')
				
		SET @SDN=REPLACE(@SDN,'-0-','')
		SET @ADDRESS=REPLACE(@ADDRESS,'-0-','')
		SET @ALT=REPLACE(@ALT,'-0-','')
		SET @REMARKS=REPLACE(@REMARKS,'-0-','')
		
		SET @SDN=REPLACE(@SDN,',,','')
		SET @ADDRESS=REPLACE(@ADDRESS,',,','')
		SET @ALT=REPLACE(@ALT,',,','')
		SET @REMARKS=REPLACE(@REMARKS,',,','')
		
		IF @DATA_SOURCE IS NOT NULL AND @DATA_SOURCE<>'' 
			SET @DATA=@DATA_SOURCE
			
		IF @SDN IS NOT NULL AND @SDN<>'' 
			SET @DATA=@DATA+'<BR>'+@SDN
			
		IF @ADDRESS IS NOT NULL AND @ADDRESS<>'' 
			SET @DATA=@DATA+'<BR><b>Address: </b>'+@ADDRESS
			
		IF @ALT IS NOT NULL AND @ALT<>'' AND @ALT<>' '
			SET @DATA=@DATA+'<BR>'+'<b>a.k.a :</b>'+@ALT+''

		IF @REMARKS IS NOT NULL AND @REMARKS<>'' 
			SET @DATA=@DATA+'<BR><b>Other Info :</b>'+@REMARKS

		INSERT INTO #tempDataTable		
		SELECT REPLACE(@DATA,'<BR><BR>','')
		
		SET @ROW_ID=@ROW_ID+1
	END
		
	ALTER TABLE #tempDataTable ADD ROWID INT IDENTITY(1,1)
	SELECT ROWID [S.N.],DATA [Contents] FROM #tempDataTable 
END




