USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[VW_KFTC_LOG]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_KFTC_LOG] AS SELECT * FROM TBL_KFTC_LOG(NOLOCK)
GO
