USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mgPointCodeSetup]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mgPointCodeSetup](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[mgAgentId] [varchar](50) NULL,
	[agentId] [int] NULL,
	[mapCodeInt] [varchar](50) NULL,
	[agentName] [varchar](200) NULL,
	[letterHead] [varchar](500) NULL,
	[agentSequence] [varchar](50) NULL,
	[Token] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [char](1) NULL
) ON [PRIMARY]
GO
