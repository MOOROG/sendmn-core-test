USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentDepositBank]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentDepositBank](
	[agentDepositBankId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[bankName] [int] NULL,
	[bankAcctNum] [varchar](30) NULL,
	[description] [varchar](100) NULL,
	[isDeleted] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentDepositBank_agentDepositBankId] PRIMARY KEY CLUSTERED 
(
	[agentDepositBankId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentDepositBank] ADD  CONSTRAINT [MSrepl_tran_version_default_F98A8FB7_CB4B_44B6_84C5_1F4CACA5782B_2026490298]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
