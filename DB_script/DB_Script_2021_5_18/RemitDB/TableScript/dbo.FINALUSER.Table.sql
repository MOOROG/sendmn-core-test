USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[FINALUSER]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FINALUSER](
	[mapCodeInt] [varchar](10) NULL,
	[agentCode] [varchar](50) NULL,
	[employeeId] [varchar](10) NULL,
	[username] [varchar](50) NULL,
	[userFullName] [varchar](150) NULL
) ON [PRIMARY]
GO
