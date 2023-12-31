USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[RemitDataLog]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RemitDataLog](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[createdBy] [varchar](35) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[moduleName] [varchar](150) NULL,
	[txnCount] [int] NULL,
	[pAmtCount] [money] NULL
) ON [PRIMARY]
GO
