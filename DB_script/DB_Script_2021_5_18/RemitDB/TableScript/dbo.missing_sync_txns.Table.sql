USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[missing_sync_txns]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[missing_sync_txns](
	[controlno] [varchar](100) NULL,
	[id] [bigint] NOT NULL,
	[createddate] [datetime] NULL
) ON [PRIMARY]
GO
