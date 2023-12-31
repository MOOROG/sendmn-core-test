USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[LoginLogs]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoginLogs](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[logType] [varchar](50) NULL,
	[IP] [varchar](100) NULL,
	[Reason] [varchar](2000) NULL,
	[fieldValue] [varchar](2000) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[UserData] [varchar](max) NULL,
	[agentId] [int] NULL,
	[loginType] [varchar](15) NULL,
	[dcSerialNumber] [varchar](100) NULL,
	[dcUserName] [varchar](100) NULL,
	[createdDateGMT] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
