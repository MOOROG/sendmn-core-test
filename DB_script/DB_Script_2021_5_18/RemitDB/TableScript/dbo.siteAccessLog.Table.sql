USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[siteAccessLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[siteAccessLog](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[dcId] [varchar](100) NULL,
	[dcUserName] [varchar](100) NULL,
	[ipAddress] [varchar](100) NULL,
	[accessDate] [datetime] NULL
) ON [PRIMARY]
GO
