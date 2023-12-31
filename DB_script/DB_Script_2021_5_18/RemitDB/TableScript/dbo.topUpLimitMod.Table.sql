USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[topUpLimitMod]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[topUpLimitMod](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tulId] [int] NULL,
	[userId] [int] NULL,
	[currency] [int] NULL,
	[limitPerDay] [money] NULL,
	[perTopUpLimit] [money] NULL,
	[modType] [varchar](6) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[maxCreditLimitForAgent] [money] NULL,
 CONSTRAINT [pk_idx_topUpLimitMod_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[topUpLimitMod] ADD  CONSTRAINT [MSrepl_tran_version_default_1D28AA2D_E750_4EF8_97AF_C42C3A23211D_1740129540]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
