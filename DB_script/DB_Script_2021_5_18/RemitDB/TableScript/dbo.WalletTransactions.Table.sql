USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[WalletTransactions]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WalletTransactions](
	[WalletTransactionId] [bigint] IDENTITY(1,1) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[customerId] [int] NOT NULL,
	[bankId] [int] NULL,
	[controlNo] [varchar](15) NULL,
	[tranId] [int] NULL,
	[remarks] [varchar](50) NOT NULL,
	[amount] [money] NOT NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[status] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WalletTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
