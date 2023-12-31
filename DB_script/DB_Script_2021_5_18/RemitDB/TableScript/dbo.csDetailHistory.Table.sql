USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[csDetailHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[csDetailHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csDetailId] [bigint] NULL,
	[condition] [int] NULL,
	[collMode] [int] NULL,
	[paymentMode] [int] NULL,
	[tranCount] [int] NULL,
	[amount] [money] NULL,
	[period] [int] NULL,
	[nextAction] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[isEnable] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[profession] [int] NULL,
	[documentRequired] [bit] NULL,
 CONSTRAINT [pk_idx_csDetailHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csDetailHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_0B8A0FB6_3AC4_4245_AF2F_EB672FDD5F32_259688173]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
