USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[txn_move]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txn_move](
	[camt] [money] NULL,
	[outAmt] [int] NOT NULL,
	[sagent] [int] NULL,
	[userid] [int] NOT NULL,
	[id] [bigint] NOT NULL,
	[createddate] [datetime] NULL,
	[head] [varchar](8) NOT NULL,
	[remarks] [varchar](110) NULL,
	[createdby] [varchar](6) NOT NULL,
	[createdte] [datetime] NOT NULL,
	[mode] [int] NULL,
	[idNew] [int] NULL,
	[fromAcc] [int] NULL,
	[toAcc] [varchar](30) NULL,
	[controlno] [varchar](100) NULL
) ON [PRIMARY]
GO
