USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempCommBank]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempCommBank](
	[agentName] [varchar](200) NULL,
	[branchName] [varchar](200) NULL,
	[agentCode] [varchar](50) NULL,
	[agentrole] [char](2) NULL,
	[agenttype] [int] NULL,
	[parentid] [int] NULL
) ON [PRIMARY]
GO
