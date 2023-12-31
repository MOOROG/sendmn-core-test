USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[billSetting]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[billSetting](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[company_id] [int] NULL,
	[journal_voucher] [varchar](50) NULL,
	[receipt_voucher] [varchar](50) NULL,
	[contra_voucher] [varchar](50) NULL,
	[payment_voucher] [varchar](50) NULL,
	[manual_voucher] [varchar](50) NULL,
	[transaction_voucher] [int] NULL,
	[CommonDate] [date] NULL
) ON [PRIMARY]
GO
