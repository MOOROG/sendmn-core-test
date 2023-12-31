USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGETDOB_FROM_ALIENCARD]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGETDOB_FROM_ALIENCARD]
(
  @aliencardno as VARCHAR(30)
 ,@type AS VARCHAR(4)
)
RETURNS  VARCHAR(20)
AS
BEGIN		
	DECLARE @DOB VARCHAR(20)
	IF ISNUMERIC(REPLACE(@aliencardno,'-','')) = 0
	RETURN NULL
	SET @DOB = 
       (CONVERT(varchar(4), 
	   CASE
			WHEN @type IN	('1','2','5','6') THEN 1900 + CAST(LEFT(@aliencardno,2) AS int)
			ELSE 2000 + CAST(LEFT(@aliencardno,2) AS int)	
			END)
			+ '-' + RIGHT(LEFT(@aliencardno,4),2) + '-' + RIGHT(@aliencardno,2))
	IF ISDATE(@DOB) = 0
		SET @DOB = NULL
	RETURN @DOB
END


--select dbo.FNAGETDOB_FROM_ALIENCARD('123456test','8')
GO
