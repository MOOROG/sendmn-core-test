USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fundTransfer]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fundTransfer](
	[fundTrxId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sAgent] [int] NOT NULL,
	[agent] [int] NOT NULL,
	[trnAmt] [money] NOT NULL,
	[trnType] [char](1) NOT NULL,
	[trnDate] [datetime] NOT NULL,
	[remarks] [varchar](1000) NULL,
	[isApproved] [char](1) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[isDeleted] [varchar](1) NULL,
 CONSTRAINT [pk_idx_fundTransfer_fundTrxId] PRIMARY KEY CLUSTERED 
(
	[fundTrxId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
