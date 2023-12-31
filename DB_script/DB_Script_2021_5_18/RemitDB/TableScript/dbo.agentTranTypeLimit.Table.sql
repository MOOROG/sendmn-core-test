USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentTranTypeLimit]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentTranTypeLimit](
	[agentTranTypeLimitId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[serviceType] [int] NULL,
	[tranLimitMax] [money] NULL,
	[tranLimitMin] [money] NULL,
	[isDefaultDepositMode] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentTranTypeLimit_agentTranTypeLimitId] PRIMARY KEY CLUSTERED 
(
	[agentTranTypeLimitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentTranTypeLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_15474186_A2A5_4E96_8334_9B6236BC397D_695009557]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
