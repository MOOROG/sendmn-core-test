USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[PERIODICRBA]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PERIODICRBA](
	[dt] [varchar](7) NULL,
	[customerid] [int] NULL,
	[txnamount] [money] NULL,
	[txncount] [int] NULL,
	[outletsused] [int] NULL,
	[bnfcountrycount] [int] NULL,
	[bnfcount] [int] NULL,
	[nonnativetxn] [varchar](1) NULL,
	[txnrba] [money] NULL,
	[rba] [money] NULL,
	[finalrba] [money] NULL
) ON [PRIMARY]
GO
