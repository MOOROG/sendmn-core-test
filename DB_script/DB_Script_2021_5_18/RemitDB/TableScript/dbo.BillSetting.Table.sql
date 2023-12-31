USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BillSetting]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillSetting](
	[rowid] [int] NOT NULL,
	[company_id] [int] NULL,
	[bill_sales] [varchar](50) NULL,
	[bill_purchase] [varchar](50) NULL,
	[bill_cash_sales] [varchar](50) NULL,
	[voucher_number] [varchar](50) NULL,
	[journal_voucher] [varchar](50) NULL,
	[sales_voucher] [varchar](50) NULL,
	[payment_voucher] [varchar](50) NULL,
	[receipt_voucher] [varchar](50) NULL,
	[purchase_voucher] [varchar](50) NULL,
	[contra_voucher] [varchar](50) NULL,
	[fund_receive_voucher] [varchar](50) NULL,
	[fund_movement] [varchar](50) NULL,
	[fund_exchange_voucher] [varchar](50) NULL,
	[manual_voucher] [varchar](50) NULL,
	[TRAN_VOUCHER] [varchar](50) NULL,
	[TRADING_VOUCHER] [varchar](50) NULL,
	[EXCHANGE_VOUCHER] [varchar](50) NULL,
	[TRANSIT_VOUCHER] [varchar](50) NULL,
	[TRANSACTION_VOUCHER] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_BillSetting_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BillSetting] ADD  CONSTRAINT [MSrepl_tran_version_default_3C665B50_6686_4DF6_863C_304D7433213C_18099105]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
