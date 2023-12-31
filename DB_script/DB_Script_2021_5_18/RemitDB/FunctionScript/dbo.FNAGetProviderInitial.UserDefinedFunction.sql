USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetProviderInitial]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetProviderInitial] (@provider VARCHAR(10))
RETURNS VARCHAR(5)
AS
BEGIN
	RETURN (SELECT 
		CASE @provider
			--WHEN '4670' THEN  'CE' 
			--WHEN '4726' THEN  'EZ'
			--WHEN '4909' THEN  'XM'
			--WHEN '4869' THEN  'RI'
			WHEN '4854' THEN  'MG'
			--WHEN '4816' THEN  'IC'
			WHEN '4734' THEN  'GB'
			ELSE 'IM'
		END)

END
GO
