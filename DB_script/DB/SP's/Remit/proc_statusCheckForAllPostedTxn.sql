USE FastMoneyPro_Remit
GO

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE proc_statusCheckForAllPostedTxn
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
			rt.id										tranId,
			rt.pSuperAgentName							ProviderName,
			rt.pSuperAgent								ProviderId,
			dbo.decryptDb(rt.controlNo)					PINNo,
			CASE 
				rt.pSuperAgent WHEN '393880' 
				THEN  NULL
				ELSE dbo.decryptDb(rt.controlNo2) 
				END										ControlNo,
			rt.createdBy								userName
			FROM remittran rt(NOLOCK)
			WHERE rt.payStatus ='POST';
END
GO
