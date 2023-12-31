USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[CorrenpondentLibilities_Other]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrenpondentLibilities_Other](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TranId] [bigint] NOT NULL,
	[UsdAmt] [money] NOT NULL,
	[Rate] [money] NOT NULL,
	[KRWAmt] [money] NOT NULL,
	[TxnDate] [date] NOT NULL,
	[TxnGain] [money] NOT NULL,
	[TradingGL] [money] NULL,
	[PositionUsd] [money] NULL,
	[PositionKrw] [money] NULL,
	[DealRowId] [int] NULL,
	[BuyRate] [money] NULL,
	[ControlNo] [varchar](30) NULL,
	[Curr] [varchar](5) NOT NULL,
	[TxnType] [char](1) NULL,
	[UsdRate] [money] NULL,
	[TradingKrw] [money] NULL
) ON [PRIMARY]
GO
