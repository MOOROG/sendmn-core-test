USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[ErrorLogs]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLogs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[errorPage] [varchar](max) NULL,
	[errorMsg] [varchar](max) NULL,
	[errorDetails] [varchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
