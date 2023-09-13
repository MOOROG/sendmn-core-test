USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BRANCH_CASH_IN_OUT_HISTORY]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BRANCH_CASH_IN_OUT_HISTORY](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[inAmount] [money] NOT NULL,
	[outAmount] [money] NOT NULL,
	[branchId] [int] NOT NULL,
	[userId] [int] NOT NULL,
	[referenceId] [bigint] NOT NULL,
	[tranDate] [datetime] NOT NULL,
	[head] [varchar](100) NOT NULL,
	[remarks] [nvarchar](250) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[mode] [varchar](2) NULL,
	[fromAcc] [varchar](30) NULL,
	[toAcc] [varchar](30) NULL,
	[MAIN_TABLE_ROW_ID] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BRANCH_CASH_IN_OUT_HISTORY] ADD  DEFAULT ((0)) FOR [referenceId]
GO
