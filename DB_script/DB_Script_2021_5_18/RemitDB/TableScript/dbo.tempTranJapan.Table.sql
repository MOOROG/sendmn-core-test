USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempTranJapan]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempTranJapan](
	[sender_name] [varchar](200) NULL,
	[sender_address] [varchar](300) NULL,
	[sender_mobile] [varchar](50) NULL,
	[sender_city] [varchar](200) NULL,
	[sender_country] [varchar](100) NULL,
	[senders_identity_type] [varchar](100) NULL,
	[sender_identity_number] [varchar](100) NULL,
	[receiver_name] [varchar](100) NULL,
	[receiver_address] [varchar](200) NULL,
	[receiver_contact_number] [varchar](200) NULL,
	[receiver_city] [varchar](10) NULL,
	[receiver_country] [varchar](100) NULL,
	[collect_amt] [money] NULL,
	[payoutamt] [money] NULL,
	[paymenttype] [varchar](100) NULL,
	[bankid] [varchar](20) NULL,
	[bank_name] [varchar](100) NULL,
	[bank_branch_name] [varchar](100) NULL,
	[bank_account_number] [varchar](100) NULL,
	[trndate] [datetime] NULL,
	[cclient] [varchar](100) NULL,
	[payout_agent_id] [varchar](20) NULL,
	[receiver_identity_type] [varchar](100) NULL,
	[receiver_identity_number] [varchar](20) NULL,
	[pinumber] [varchar](20) NULL
) ON [PRIMARY]
GO
