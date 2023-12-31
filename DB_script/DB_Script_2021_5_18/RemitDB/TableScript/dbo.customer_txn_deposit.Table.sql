USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customer_txn_deposit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer_txn_deposit](
	[CUSTOMER] [int] NULL,
	[tranId] [bigint] NOT NULL,
	[tranDate] [datetime] NOT NULL,
	[depositAmount] [money] NOT NULL,
	[paymentAmount] [money] NOT NULL,
	[particulars] [nvarchar](500) NOT NULL,
	[closingBalance] [money] NOT NULL,
	[isAuto] [bit] NOT NULL,
	[bankName] [nvarchar](150) NOT NULL,
	[processedBy] [varchar](50) NULL,
	[processedDate] [datetime] NULL,
	[customerId] [bigint] NULL,
	[isSkipped] [bit] NULL,
	[skippedBy] [varchar](50) NULL,
	[skippedDate] [datetime] NULL,
	[isSettled] [bit] NULL,
	[TRAN_ID] [bigint] NULL,
	[is_voucher_gen] [int] NOT NULL
) ON [PRIMARY]
GO
