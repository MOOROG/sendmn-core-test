USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentCommissionRuleHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentCommissionRuleHistory](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id] [int] NULL,
	[agentId] [int] NULL,
	[ruleId] [int] NULL,
	[ruleType] [char](2) NULL,
	[modType] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentCommissionRuleHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentCommissionRuleHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_51EE8365_7469_45A9_87E1_232FA257835E_1729089596]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
