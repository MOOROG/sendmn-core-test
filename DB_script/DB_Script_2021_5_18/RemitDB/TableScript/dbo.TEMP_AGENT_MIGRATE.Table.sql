USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMP_AGENT_MIGRATE]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_AGENT_MIGRATE](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AgentName] [varchar](200) NULL,
	[EXT] [varchar](200) NULL,
	[DOM] [varchar](200) NULL,
	[MATCH] [varchar](200) NULL,
	[ACDEPOSIT_CODE] [varchar](200) NULL,
	[ACDEPOSIT_CODE1] [varchar](200) NULL
) ON [PRIMARY]
GO
