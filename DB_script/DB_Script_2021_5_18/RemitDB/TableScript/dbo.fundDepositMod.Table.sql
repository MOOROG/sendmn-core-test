USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fundDepositMod]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fundDepositMod](
	[rowId] [int] NOT NULL,
	[agentId] [int] NULL,
	[bankId] [int] NULL,
	[branchId] [int] NULL,
	[amount] [money] NULL,
	[remarks] [varchar](max) NULL,
	[isDeleted] [varchar](1) NULL,
	[createdBy] [varchar](200) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](200) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](200) NULL,
	[approvedDate] [datetime] NULL,
	[isActive] [varchar](1) NULL,
	[isEnable] [varchar](1) NULL,
	[modType] [varchar](1) NULL,
	[depositedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_fundDepositMod_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[fundDepositMod] ADD  CONSTRAINT [MSrepl_tran_version_default_F0158E05_6DA4_49FE_861E_CCD1525BEA69_2108026741]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
