USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[missing_voucher]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[missing_voucher](
	[createddate] [datetime] NULL,
	[controlno] [varchar](100) NULL,
	[psuperagentname] [varchar](50) NULL,
	[id] [bigint] IDENTITY(100000000,1) NOT NULL
) ON [PRIMARY]
GO
