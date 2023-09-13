USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TESTToday]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TESTToday](
	[baseCurrency] [varchar](20) NULL,
	[serviceCharge] [money] NULL,
	[sCurrCostRate] [float] NULL,
	[sCurrHoMargin] [float] NULL,
	[pCurrCostRate] [float] NULL,
	[pCurrHoMargin] [float] NULL
) ON [PRIMARY]
GO
