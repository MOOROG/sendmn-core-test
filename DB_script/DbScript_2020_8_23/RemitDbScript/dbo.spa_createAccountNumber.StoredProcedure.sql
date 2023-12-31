USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[spa_createAccountNumber]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_createAccountNumber]
	 @flag char(1)
	,@gl_code varchar(6)
AS

SET NOCOUNT ON;

IF @flag = 'a'
BEGIN
	
	DECLARE @bookedId VARCHAR(20), @uniqueNum VARCHAR(2)
	
	IF LEN(@gl_code) = 1
		SET @gl_code=@gl_code+'0'
	
	SET @gl_code= LEFT(@gl_code,2)

	SELECT @bookedId = 1 + IDENT_CURRENT('ac_master')
	
	SET @uniqueNum = REPLACE(RIGHT((RAND()*5),1),'.','0')
	
	SELECT CAST(@gl_code AS VARCHAR) + CAST(@bookedid AS VARCHAR) + CAST(@uniquenum AS VARCHAR) AS acNum
	
END


GO
