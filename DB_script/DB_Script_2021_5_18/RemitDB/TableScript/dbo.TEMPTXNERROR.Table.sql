USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMPTXNERROR]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMPTXNERROR](
	[TRANID] [bigint] NULL,
	[ERROR_MSG] [varchar](500) NULL
) ON [PRIMARY]
GO
