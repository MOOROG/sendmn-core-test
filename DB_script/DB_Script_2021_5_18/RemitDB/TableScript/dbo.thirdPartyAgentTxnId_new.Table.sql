USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[thirdPartyAgentTxnId_new]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[thirdPartyAgentTxnId_new](
	[agentTxnId] [varchar](50) NULL,
	[agentId] [int] NULL
) ON [PRIMARY]
GO
