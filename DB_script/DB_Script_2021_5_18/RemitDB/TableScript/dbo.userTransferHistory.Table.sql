USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userTransferHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userTransferHistory](
	[userName] [varchar](50) NULL,
	[fromBranch] [int] NULL,
	[toBranch] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_userTransferHistory_rowid] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userTransferHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_2CD61597_27B9_465B_B6DD_6C3D54C8E2B0_522133301]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
