USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tpTxnList]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tpTxnList](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[tranId] [int] NOT NULL,
	[controlNo] [varchar](50) NOT NULL,
	[transferredDate] [datetime] NOT NULL,
	[pAgent] [int] NOT NULL,
	[status] [varchar](10) NULL
) ON [PRIMARY]
GO
