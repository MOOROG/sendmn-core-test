USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwBankLists]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwBankLists] AS 
	select * from KoreanBankList(NOLOCK) --WHERE ISACTIVE = 1

GO
