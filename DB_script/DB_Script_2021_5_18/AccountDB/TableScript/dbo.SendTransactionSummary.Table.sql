USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[SendTransactionSummary]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SendTransactionSummary](
	[TRAN_ID] [int] IDENTITY(1,1) NOT NULL,
	[S_AGENT] [float] NULL,
	[S_CURR] [varchar](10) NULL,
	[USD_AMT] [money] NULL,
	[NPR_AMT] [money] NULL,
	[USD_RATE] [decimal](12, 6) NULL,
	[P_CURR] [varchar](10) NULL,
	[TRAN_DATE] [datetime] NULL,
	[REMAIN_AMT] [money] NULL,
	[WeightedRate] [money] NULL,
	[cummNPR] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
