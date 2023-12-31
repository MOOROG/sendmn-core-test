USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerTxnHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerTxnHistory](
	[Tranno] [int] NOT NULL,
	[refno] [varchar](50) NOT NULL,
	[senderFax] [varchar](50) NULL,
	[senderPassport] [varchar](50) NULL,
	[SenderName] [varchar](100) NOT NULL,
	[sender_mobile] [varchar](50) NULL,
	[SenderAddress] [varchar](200) NULL,
	[SenderCountry] [varchar](50) NULL,
	[customerId] [varchar](50) NULL,
	[receiverIDDescription] [varchar](50) NULL,
	[receiverID] [varchar](50) NULL,
	[receiverName] [varchar](100) NULL,
	[ReceiverPhone] [varchar](50) NULL,
	[receiver_mobile] [varchar](20) NULL,
	[ReceiverAddress] [varchar](200) NULL,
	[ReceiverCity] [varchar](100) NULL,
	[ReceiverCountry] [varchar](50) NULL,
	[rBankACNo] [varchar](50) NULL,
	[rBankName] [varchar](100) NULL,
	[rBankBranch] [varchar](100) NULL,
	[rBankID] [varchar](50) NULL,
	[ben_bank_id] [varchar](50) NULL,
	[ben_bank_name] [varchar](200) NULL,
	[rBankAcType] [varchar](200) NULL,
	[receiveAgentID] [varchar](50) NULL,
	[expected_payoutagentid] [varchar](50) NULL,
	[paymentType] [varchar](50) NULL,
	[paidAmt] [money] NULL,
	[confirmDate] [datetime] NULL,
	[paidCType] [varchar](50) NULL,
	[receiveCType] [varchar](50) NULL,
	[pagent] [varchar](50) NULL,
	[pagentname] [varchar](200) NULL,
	[pbranch] [varchar](50) NULL,
	[pbranchname] [varchar](200) NULL,
	[pbank] [varchar](50) NULL,
	[pbankname] [varchar](200) NULL,
	[pbankbranch] [varchar](50) NULL,
	[pbankbranchname] [varchar](200) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[membershipId] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerTxnHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_A87FDFF2_147A_4150_9153_4813170A4ADA_1156563554]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
