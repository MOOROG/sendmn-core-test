USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[idMismatchLog]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[idMismatchLog](
	[id] [bigint] NOT NULL,
	[holdTranId] [bigint] NULL
) ON [PRIMARY]
GO
