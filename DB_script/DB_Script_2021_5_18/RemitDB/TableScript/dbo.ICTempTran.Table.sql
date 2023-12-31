USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ICTempTran]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICTempTran](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company_id] [int] NULL,
	[control_no] [varchar](200) NULL,
	[sender_name] [varchar](200) NULL,
	[sender_address] [text] NULL,
	[sender_country] [varchar](200) NULL,
	[sender_city] [varchar](200) NULL,
	[sender_phone] [text] NULL,
	[receiver_name] [varchar](200) NULL,
	[receiver_address] [text] NULL,
	[receiver_country] [varchar](200) NULL,
	[receiver_city] [varchar](200) NULL,
	[receiver_phone] [text] NULL,
	[currency_type] [varchar](200) NULL,
	[amount] [float] NULL,
	[commission] [float] NULL,
	[paid_amount] [float] NULL,
	[payment_type] [varchar](200) NULL,
	[rec_bank_ac_no] [varchar](200) NULL,
	[rec_bank_name] [varchar](200) NULL,
	[rec_bank_branch_name] [varchar](200) NULL,
	[send_date] [datetime] NULL,
	[pay_send] [char](1) NULL,
	[paid_user] [varchar](200) NULL,
	[branch_code] [varchar](50) NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
