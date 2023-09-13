USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[vietnam_txn]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[vietnam_txn](
	[id] [bigint] IDENTITY(100000000,1) NOT NULL,
	[controlno] [varchar](100) NULL,
	[pagentcomm] [money] NULL,
	[pCurrCostRate] [float] NULL
) ON [PRIMARY]
GO
