USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_eodOfTransaction]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procEDURE [dbo].[Proc_eodOfTransaction]

	@USER	VARCHAR(100),
	@DATE	VARCHAR(20)
	
AS
BEGIN

	---##### PROCEDURE FOR SENDING TANSACTIO  EOD
	EXEC proc_sendEODRemit @USER,@DATE
	
	---##### PROCEDURE FOR PAID TANSACTIO  EOD
	EXEC proc_paidEODRemit @USER,@DATE
	
	---##### PROCEDURE FOR CANCEL TANSACTIO  EOD
	EXEC proc_cancelEODRemit @USER,@DATE

END


GO
