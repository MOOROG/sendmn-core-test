USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempTransactionMailQueue]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempTransactionMailQueue](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[status] [varchar](10) NULL
) ON [PRIMARY]
GO
