USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[extraLimit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[extraLimit](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[amount] [money] NULL,
	[status] [varchar](20) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_extraLimit_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[extraLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_C51223B3_01A1_4F3C_9A55_C3610E88A8F8_1763849696]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
