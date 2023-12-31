USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[CorrenpondentLibilities]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrenpondentLibilities](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TranId] [bigint] NOT NULL,
	[UsdAmt] [money] NOT NULL,
	[Rate] [money] NOT NULL,
	[KRWAmt] [money] NOT NULL,
	[TxnDate] [date] NOT NULL,
	[TxnGain] [money] NULL,
	[TradingGL] [money] NULL,
	[PositionUsd] [money] NULL,
	[PositionKrw] [money] NULL,
	[DealRowId] [int] NULL,
	[BuyRate] [money] NULL,
	[ControlNo] [varchar](30) NULL,
	[TxnType] [char](1) NULL
) ON [PRIMARY]
GO
