USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACheckCapital]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNACheckCapital](@P_String CHAR(1))
RETURNS BIT
AS
BEGIN
 
	DECLARE @V_RetValue BIT
	DECLARE @V_Position INT
	 
	SET @V_Position = 1
	SET @V_RetValue = 0   
	 
	--Loop through all the characters
	WHILE @V_Position <= DATALENGTH(@P_String)
			   AND @V_RetValue = 0
	BEGIN
	 
		 --Check if ascii value of the character is between 65 & 90
		 --Note: Ascii value of A is 65 and Z is 90
		IF ASCII(SUBSTRING(@P_String, @V_Position, 1))
				BETWEEN 65 AND 90
			SELECT @V_RetValue = 1
		ELSE
			SELECT @V_RetValue = 0     
	   --Move to next character       
	   SET @V_Position = @V_Position + 1
	END
	 
	--Return the value
	RETURN @V_RetValue
 
END
GO
