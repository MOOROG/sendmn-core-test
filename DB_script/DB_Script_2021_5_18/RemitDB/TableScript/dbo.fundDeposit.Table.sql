USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fundDeposit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fundDeposit](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[agentId] [int] NOT NULL,
	[bankId] [int] NOT NULL,
	[branchId] [int] NULL,
	[amount] [money] NOT NULL,
	[remarks] [varchar](max) NULL,
	[isDeleted] [varchar](1) NULL,
	[createdBy] [varchar](200) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](200) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](200) NULL,
	[approvedDate] [datetime] NULL,
	[isActive] [varchar](1) NULL,
	[isEnable] [varchar](1) NULL,
	[depositedDate] [datetime] NULL,
	[voucherDoc] [varchar](200) NULL,
	[status] [varchar](20) NULL,
	[approveRejectRemark] [varchar](300) NULL,
	[VoucherNo] [bigint] NULL,
	[verifiedDate] [datetime] NULL,
	[verifiedBy] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
