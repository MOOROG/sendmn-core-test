USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetProviderByControlNo]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[proc_GetProviderByControlNo]
(
	@flag			VARCHAR(10)	= NULL,
	@user			VARCHAR(255) = NULL,
	@controlNo		VARCHAR(30) = NULL
	
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @len	INT
SET @len = LEN(@controlNo)

BEGIN 


IF(@len IN(11))
BEGIN
	IF ((LEFT(@controlNo,3) = '788') OR ((LEFT(@controlNo,3) = '700')) )
	BEGIN
		SELECT 'IME-I' ID, 'Mongolia Remit' Name
		RETURN
	END

	IF LEFT(@controlNo,2) = '80'
	BEGIN
		SELECT '394432' ID, 'GME Korea Remit' Name  
		RETURN
	END
END
        
END

















GO
