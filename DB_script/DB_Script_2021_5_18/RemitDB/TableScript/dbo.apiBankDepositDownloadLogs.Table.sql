USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiBankDepositDownloadLogs]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiBankDepositDownloadLogs](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[createdDate] [datetime] NULL,
	[downloadQty] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[providerName] [varchar](150) NULL
) ON [PRIMARY]
GO
