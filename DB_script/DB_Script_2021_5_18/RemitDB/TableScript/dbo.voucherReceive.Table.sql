USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[voucherReceive]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[voucherReceive](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[agentId] [int] NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[voucherType] [varchar](20) NULL,
	[complain] [varchar](100) NULL,
	[boxNo] [varchar](50) NULL,
	[SEND_D] [int] NULL,
	[PAID_D] [int] NULL,
	[PAID_I] [int] NULL,
 CONSTRAINT [PK_voucherReceive] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
