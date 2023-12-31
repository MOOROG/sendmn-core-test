USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CUSTOMER_REFUNDMOD]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CUSTOMER_REFUNDMOD](
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
	[modType] [char](1) NOT NULL
) ON [PRIMARY]
GO
