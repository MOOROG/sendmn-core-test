USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customer_account]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer_account](
	[walletaccountno] [varchar](100) NULL,
	[customerid] [bigint] IDENTITY(1,1) NOT NULL,
	[new_wallet] [varchar](20) NULL
) ON [PRIMARY]
GO
