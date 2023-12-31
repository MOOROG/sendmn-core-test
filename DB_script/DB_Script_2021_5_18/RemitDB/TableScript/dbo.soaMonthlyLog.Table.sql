USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[soaMonthlyLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[soaMonthlyLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[agentId] [varchar](50) NOT NULL,
	[branchId] [int] NOT NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[soaType] [varchar](20) NULL,
	[createdDate] [datetime] NULL,
	[message] [varchar](max) NULL,
	[logType] [varchar](50) NULL,
	[npMonth] [varchar](20) NULL,
	[npYear] [varchar](10) NULL,
	[createdBy] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
