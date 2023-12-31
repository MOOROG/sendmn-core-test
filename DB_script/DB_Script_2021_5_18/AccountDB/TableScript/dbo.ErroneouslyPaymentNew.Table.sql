USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[ErroneouslyPaymentNew]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErroneouslyPaymentNew](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[ref_no] [varchar](50) NULL,
	[tranno] [nchar](10) NULL,
	[amount] [money] NULL,
	[EP_commission] [money] NULL,
	[EP_AgentCode] [varchar](50) NULL,
	[EP_BranchCode] [varchar](50) NULL,
	[EP_date] [date] NULL,
	[EP_User] [varchar](50) NULL,
	[EP_vo] [varchar](50) NULL,
	[EP_V_Type] [varchar](50) NULL,
	[PO_commission] [money] NULL,
	[PO_AgentCode] [varchar](50) NULL,
	[PO_BranchCode] [varchar](50) NULL,
	[PO_date] [date] NULL,
	[PO_User] [varchar](50) NULL,
	[PO_vo] [varchar](50) NULL,
	[PO_V_Type] [varchar](50) NULL,
	[EP_invoiceNo] [int] NULL,
	[PO_invoiceNo] [int] NULL,
	[REV_ManualVouNo] [varchar](100) NULL,
	[REV_ManualVouDate] [varchar](20) NULL,
	[REV_ManualVouType] [varchar](50) NULL
) ON [PRIMARY]
GO
