USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[report_format]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_format](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[lable] [varchar](200) NULL,
	[reportid] [int] NULL,
	[type] [varchar](1) NULL,
	[grp] [varchar](100) NULL,
	[grp_main] [varchar](50) NULL
) ON [PRIMARY]
GO
