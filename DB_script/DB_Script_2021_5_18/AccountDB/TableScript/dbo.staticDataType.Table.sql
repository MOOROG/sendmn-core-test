USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[staticDataType]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[staticDataType](
	[ROWID] [int] NOT NULL,
	[TYPE_TITLE] [varchar](200) NULL,
	[TYPE_DESC] [varchar](500) NULL
) ON [PRIMARY]
GO
