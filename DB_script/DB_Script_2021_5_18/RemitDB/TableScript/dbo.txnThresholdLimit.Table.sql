USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[txnThresholdLimit]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnThresholdLimit](
	[ttlId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](30) NULL,
	[pAgent] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[remarks] [varchar](max) NULL,
 CONSTRAINT [pk_idx_txnThresholdLimit_ttlId] PRIMARY KEY CLUSTERED 
(
	[ttlId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[txnThresholdLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_1D65B53F_8FAD_4BCC_A19B_6CA4F6D950BD_1373560277]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
