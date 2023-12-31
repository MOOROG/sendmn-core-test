USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[UsdStockSummary_Other]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsdStockSummary_Other](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[UsdAmt] [money] NOT NULL,
	[Rate] [money] NOT NULL,
	[KRWAmt] [money] NOT NULL,
	[TxnDate] [date] NOT NULL,
	[TxnType] [char](1) NULL,
	[tranId] [bigint] NULL,
	[Curr] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
