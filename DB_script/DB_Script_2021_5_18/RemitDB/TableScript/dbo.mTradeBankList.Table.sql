USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mTradeBankList]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mTradeBankList](
	[country] [varchar](50) NULL,
	[bankCode] [varchar](50) NULL,
	[bankName] [varchar](200) NULL,
	[branchCode] [varchar](50) NULL,
	[branchName] [varchar](200) NULL,
	[payAgentCode] [varchar](4) NOT NULL,
	[serviceType] [varchar](1) NOT NULL,
	[newCode] [varchar](100) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AgentId] [int] NULL
) ON [PRIMARY]
GO
