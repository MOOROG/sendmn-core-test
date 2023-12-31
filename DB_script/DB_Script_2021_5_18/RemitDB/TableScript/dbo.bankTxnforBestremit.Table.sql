USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankTxnforBestremit]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankTxnforBestremit](
	[CONTROLNO] [varchar](100) NULL,
	[SENDAGENT] [int] NULL,
	[SENDERNAME] [varchar](500) NULL,
	[SENDERADDRESS] [varchar](200) NULL,
	[SENDER_MOBILE] [varchar](100) NULL,
	[SENDERCITY] [varchar](150) NULL,
	[SENDERCOUNTRY] [varchar](100) NULL,
	[RECEIVERNAME] [varchar](500) NULL,
	[RECEIVERADDRESS] [varchar](500) NULL,
	[RECEIVERPHONE] [varchar](100) NULL,
	[RECEIVERCITY] [varchar](150) NULL,
	[RECEIVERCOUNTRY] [varchar](100) NULL,
	[TRANSFERAMOUNT] [money] NULL,
	[SCURRCOSTRATE] [float] NULL,
	[RCURRCOSTRATE] [float] NULL,
	[PAYOUTAMT] [money] NULL,
	[PAYOUTCURRENCY] [varchar](3) NULL,
	[PAYMENTTYPE] [varchar](50) NULL,
	[BANKNAME] [varchar](100) NULL,
	[BANKBRANCH] [varchar](100) NULL,
	[BANKACCOUNTNO] [varchar](200) NULL,
	[BANKCODE] [int] NULL,
	[BANKBRANCHCODE] [varchar](200) NULL,
	[TRNDATE] [datetime] NULL,
	[RECEIVERMOBILE] [varchar](100) NULL,
	[ISLOCAL] [varchar](1) NOT NULL,
	[TRANID] [bigint] NOT NULL
) ON [PRIMARY]
GO
