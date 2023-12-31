USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[payTranDetail]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payTranDetail](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[code] [varchar](10) NULL,
	[controlNo] [varchar](20) NULL,
	[agentTxnRefId] [varchar](30) NULL,
	[sendAgent] [varchar](150) NULL,
	[senderName] [varchar](200) NULL,
	[senderAddress] [varchar](200) NULL,
	[senderMobile] [varchar](20) NULL,
	[senderCity] [varchar](50) NULL,
	[senderCountry] [varchar](30) NULL,
	[receiverName] [varchar](200) NULL,
	[receiverAddress] [varchar](200) NULL,
	[receiverCity] [varchar](50) NULL,
	[receiverCountry] [varchar](30) NULL,
	[payoutAmt] [money] NULL,
	[payoutCurr] [varchar](3) NULL,
	[paymentType] [varchar](20) NULL,
	[txnDate] [datetime] NULL,
	[sendLocationId] [int] NULL,
	[payoutLocationId] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[createdDateLocal] [datetime] NULL,
 CONSTRAINT [pk_idx_payTranDetail_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
