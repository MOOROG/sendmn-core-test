USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[IDMistMatch]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IDMistMatch](
	[id] [bigint] NOT NULL,
	[holdTranId] [bigint] NULL,
	[controlNo] [varchar](20) NULL
) ON [PRIMARY]
GO
