USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[UsdStockSummary]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsdStockSummary](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[UsdAmt] [money] NOT NULL,
	[Rate] [money] NOT NULL,
	[KRWAmt] [money] NOT NULL,
	[TxnDate] [date] NOT NULL,
	[TxnType] [char](1) NULL,
	[tranId] [bigint] NULL
) ON [PRIMARY]
GO
