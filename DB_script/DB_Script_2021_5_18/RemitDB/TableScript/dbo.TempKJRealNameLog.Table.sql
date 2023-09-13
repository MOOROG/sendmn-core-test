USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TempKJRealNameLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempKJRealNameLog](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[RequestJSon] [nvarchar](max) NULL,
	[logDate] [datetime] NULL,
	[ResponseMsg] [nvarchar](max) NULL,
	[BankAcNo] [varchar](30) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
