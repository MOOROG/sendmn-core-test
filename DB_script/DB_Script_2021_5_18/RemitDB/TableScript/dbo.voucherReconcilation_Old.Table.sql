USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[voucherReconcilation_Old]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[voucherReconcilation_Old](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[receivedId] [int] NULL,
	[boxNo] [varchar](100) NULL,
	[fileNo] [varchar](100) NULL,
	[tranId] [int] NULL,
	[remarks] [varchar](max) NULL,
	[status] [varchar](50) NULL,
	[voucherType] [varchar](50) NULL,
	[voucherDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[storeLocation] [varchar](200) NULL,
	[locationCreatedBy] [varchar](50) NULL,
	[locationCreatedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[agentId] [int] NULL,
	[resolvedBy] [varchar](50) NULL,
	[resolvedDate] [datetime] NULL,
	[resolvedRemarks] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
