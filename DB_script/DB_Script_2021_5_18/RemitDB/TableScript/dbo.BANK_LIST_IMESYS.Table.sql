USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BANK_LIST_IMESYS]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BANK_LIST_IMESYS](
	[AgentType] [varchar](50) NULL,
	[CompanyName] [varchar](100) NULL,
	[Branch] [varchar](100) NULL,
	[agentCode] [varchar](50) NOT NULL,
	[agent_branch_Code] [varchar](50) NOT NULL,
	[DomCode] [int] NULL
) ON [PRIMARY]
GO
