USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNANepDateConversion]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
       
CREATE FUNCTION [dbo].[FNANepDateConversion](
	 @nepDate			VARCHAR(10)	
)
RETURNS VARCHAR(10) AS  
BEGIN
	DECLARE @date AS VARCHAR(50)
	SET @nepDate=REPLACE(@nepDate,'/','-')
	SET @nepDate=REPLACE(@nepDate,'.','-')
		
	DECLARE @MM AS VARCHAR(2),@DD AS VARCHAR(2), @YYYY AS VARCHAR(4)

	SELECT 
	@DD = CASE WHEN LEN(REPLACE( SUBSTRING (@nepDate, CHARINDEX('-',@nepDate,1), 3),'-',''))=1 
		THEN '0'+REPLACE( SUBSTRING (@nepDate, CHARINDEX('-',@nepDate,1), 3),'-','') 
	ELSE 
		REPLACE( SUBSTRING (@nepDate, CHARINDEX('-',@nepDate,1), 3),'-','') END,
		
	@MM=CASE WHEN LEN(REPLACE(LEFT(@nepDate,3),'-',''))=1 
		THEN '0'+REPLACE(LEFT(@nepDate,3),'-','') 
	ELSE 
		CASE WHEN LEN(REPLACE(LEFT(@nepDate,2),'-',''))=1 
		THEN '0'+REPLACE(LEFT(@nepDate,2),'-','') 
		ELSE REPLACE(LEFT(@nepDate,2),'-','') END
		  END,
	@YYYY=RIGHT(@nepDate,4) 
	

	IF @DD ='00'
	BEGIN
		DEcLARE @maxDate VARchAR(10)
		SELECT @maxDate =  max(nep_date) FROM  tbl_calendar WHERE nep_date like @MM + '-__-' + @YYYY			 
		SELECT @nepDate=@MM+'-'+SUBSTRING(@maxdate, 4, 2)+'-'+@YYYY		
	END
	ELSE 
	BEGIN
		SELECT @nepDate=@MM+'-'+@DD+'-'+@YYYY			
	END
	SELECT @date=ENG_DATE FROM tbl_calendar WHERE NEP_DATE=@nepDate
	SELECT @date = CONVERT(VARCHAR,CAST(@date AS DATE),101)
	return @date
END	



GO
