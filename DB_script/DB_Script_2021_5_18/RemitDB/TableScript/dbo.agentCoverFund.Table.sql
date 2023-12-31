USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentCoverFund]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentCoverFund](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[openingBal] [money] NULL,
	[todaysPaid] [money] NULL,
	[todaysCancel] [money] NULL,
	[todaysDeal] [money] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentCoverFund_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentCoverFund] ADD  CONSTRAINT [MSrepl_tran_version_default_25CFC9C9_692F_4501_ACE3_124D3018F141_1522468848]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
