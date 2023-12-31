USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentBlockMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentBlockMod](
	[id] [int] NULL,
	[agentId] [varchar](30) NULL,
	[agentStatus] [varchar](30) NULL,
	[remarks] [varchar](255) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[modType] [varchar](30) NULL
) ON [PRIMARY]
GO
