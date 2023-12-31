USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[balanceTopUpHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[balanceTopUpHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[btId] [int] NULL,
	[agentId] [int] NULL,
	[amount] [money] NULL,
	[topUpDate] [datetime] NULL,
	[modType] [varchar](6) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_balanceTopUpHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[balanceTopUpHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_120EEB6A_76D0_4CDC_B37D_3F6E53539C86_951778548]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
