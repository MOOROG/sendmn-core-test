USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userWiseTxnLimit]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userWiseTxnLimit](
	[limitId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[limitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userWiseTxnLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_873DFFC1_2FD1_4AF9_91A7_9BE3E4CE2527_1700513437]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
