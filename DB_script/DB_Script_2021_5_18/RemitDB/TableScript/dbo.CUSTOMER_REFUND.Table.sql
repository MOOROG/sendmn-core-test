USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CUSTOMER_REFUND]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CUSTOMER_REFUND](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[customerId] [bigint] NOT NULL,
	[refundAmount] [money] NOT NULL,
	[refundCharge] [money] NOT NULL,
	[refundRemarks] [varchar](200) NULL,
	[refundChargeRemarks] [varchar](200) NULL,
	[createdBy] [varchar](40) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[approvedBy] [varchar](40) NULL,
	[approvedDate] [datetime] NULL,
	[isDeleted] [bit] NOT NULL,
	[deletedBy] [varchar](40) NULL,
	[deletedDate] [datetime] NULL,
	[collMode] [varchar](15) NULL,
	[bankId] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CUSTOMER_REFUND] ADD  DEFAULT ((0)) FOR [refundCharge]
GO
ALTER TABLE [dbo].[CUSTOMER_REFUND] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
