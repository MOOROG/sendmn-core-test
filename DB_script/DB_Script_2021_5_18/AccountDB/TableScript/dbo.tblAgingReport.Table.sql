USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[tblAgingReport]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAgingReport](
	[walletNo] [varchar](20) NULL,
	[agingAmt] [money] NULL,
	[ageDay] [int] NULL
) ON [PRIMARY]
GO
