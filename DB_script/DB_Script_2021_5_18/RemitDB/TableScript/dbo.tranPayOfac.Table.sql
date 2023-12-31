USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranPayOfac]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranPayOfac](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[tranId] [bigint] NULL,
	[provider] [bigint] NULL,
	[blackListId] [varchar](max) NULL,
	[approvedRemarks] [varchar](500) NULL,
	[approvedBy] [varchar](100) NULL,
	[approvedDate] [datetime] NULL,
	[reason] [varchar](max) NULL,
	[flag] [char](1) NULL,
	[pAmt] [money] NULL,
	[controlNo] [varchar](50) NULL,
	[pBranch] [int] NULL,
	[senderName] [varchar](200) NULL,
	[receiverName] [varchar](200) NULL,
	[txnDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[rMemId] [varchar](50) NULL,
	[rIdType] [varchar](100) NULL,
	[rIdNumber] [varchar](100) NULL,
	[rPlaceOfIssue] [varchar](200) NULL,
	[rContactNo] [varchar](200) NULL,
	[rRelationType] [varchar](100) NULL,
	[rRelativeName] [varchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
