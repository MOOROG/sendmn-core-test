USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[JP_LOG]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JP_LOG](
	[XML_DATA] [nvarchar](max) NULL,
	[DOWNLOAD_DATE] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
