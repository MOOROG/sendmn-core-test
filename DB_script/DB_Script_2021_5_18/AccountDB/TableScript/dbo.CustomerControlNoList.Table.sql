USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[CustomerControlNoList]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerControlNoList](
	[ControlNo] [varchar](20) NULL,
	[controlNoEnc] [varchar](20) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[TxnDate] [date] NULL
) ON [PRIMARY]
GO
