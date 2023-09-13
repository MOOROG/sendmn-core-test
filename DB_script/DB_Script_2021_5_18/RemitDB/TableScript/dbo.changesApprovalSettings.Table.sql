USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[changesApprovalSettings]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[changesApprovalSettings](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[functionId] [int] NOT NULL,
	[mainTable] [varchar](255) NULL,
	[modTable] [varchar](255) NULL,
	[pKfield] [varchar](255) NULL,
	[spName] [varchar](255) NULL,
	[pageName] [varchar](255) NULL
) ON [PRIMARY]
GO
