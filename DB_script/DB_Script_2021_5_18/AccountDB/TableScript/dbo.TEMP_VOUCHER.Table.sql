USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[TEMP_VOUCHER]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_VOUCHER](
	[DT] [varchar](10) NOT NULL,
	[NAME] [varchar](41) NOT NULL,
	[AMT] [varchar](8) NOT NULL
) ON [PRIMARY]
GO
