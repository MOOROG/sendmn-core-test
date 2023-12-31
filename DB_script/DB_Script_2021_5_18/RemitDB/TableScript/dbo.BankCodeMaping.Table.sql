USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BankCodeMaping]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankCodeMaping](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[mainBankCode] [int] NULL,
	[subBankCode] [int] NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[isEnabled] [char](1) NULL
) ON [PRIMARY]
GO
