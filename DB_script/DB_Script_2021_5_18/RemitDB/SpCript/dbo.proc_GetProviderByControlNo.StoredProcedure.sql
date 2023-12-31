USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetProviderByControlNo]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_GetProviderByControlNo]
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

DECLARE @KoreaAgentId VARCHAR(20)
DECLARE @RiaAgentId VARCHAR(20)


SELECT @RiaAgentId = agentId FROM Vw_GetAgentID WHERE SearchText = 'riaAgent'
SELECT @KoreaAgentId = agentId FROM Vw_GetAgentID WHERE SearchText = 'koreaAgent'


IF(@len IN(11))
BEGIN
	IF ((LEFT(@controlNo,3) = '788') OR ((LEFT(@controlNo,3) = '700')) )
	BEGIN
		SELECT 'IME-I' ID, 'Mongolia Remit' Name
		RETURN
	END

	IF LEFT(@controlNo,2) = '80'
	BEGIN
		SELECT @KoreaAgentId ID, 'GME Korea Remit' Name  
		RETURN
	END

	IF LEFT(@controlNo,2) IN ('12','13','44','95') 
	BEGIN
		SELECT @RiaAgentId ID, 'Ria Remit' Name
		RETURN
	END
END
        
END




















 
GO
