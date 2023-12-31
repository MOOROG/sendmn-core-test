USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_convertDate]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_convertDate]
	 @flag					VARCHAR(20)
	,@engDate				VARCHAR(20)	= NULL
	,@nepDate				VARCHAR(20) = NULL
	,@user					VARCHAR(50)	= NULL
AS

SET NOCOUNT ON;
/*
EXEC proc_convertDate @flag = 'A', @engDate = '12345',@nepDate='12/52/2045'
*/

IF @flag = 'A'
BEGIN
	IF ISDATE(@engDate) = 0 
		SET @engDate = NULL

	DECLARE @date AS VARCHAR(50)
	SET @nepDate=REPLACE(@nepDate,'/','-')
	SET @nepDate=REPLACE(@nepDate,'.','-')
	IF @engDate IS NULL	
	BEGIN
		
		IF ISNUMERIC(REPLACE(@nepDate, '-', '')) = 0
		BEGIN
			SELECT '' Result
			RETURN
		END

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
			  END,	@YYYY=RIGHT(@nepDate,4) 
		

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
		SELECT CONVERT(VARCHAR,CAST(@date AS DATE),101) Result
	END
				
	IF @nepDate IS NULL	
	BEGIN
		IF ISDATE(@engDate) = 1
		BEGIN
			SELECT @date = NEP_DATE FROM tbl_calendar WHERE ENG_DATE = @engDate
			SELECT REPLACE(@date,'-','/')  Result
		END
		ELSE
		BEGIN
			SELECT NULL Result
		END		
	END	
END







GO
