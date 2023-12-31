USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userWiseTxnLimitHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userWiseTxnLimitHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[limitId] [int] NULL,
	[userId] [int] NULL,
	[sendPerDay] [money] NULL,
	[sendPerTxn] [money] NULL,
	[sendTodays] [money] NULL,
	[payPerDay] [money] NULL,
	[payPerTxn] [money] NULL,
	[payTodays] [money] NULL,
	[cancelPerDay] [money] NULL,
	[cancelPerTxn] [money] NULL,
	[cancelTodays] [money] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[modType] [varchar](10) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_userWiseTxnLimitHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userWiseTxnLimitHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_C138708E_52E5_43DD_8861_D6CE4EC27C5C_1764513665]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
