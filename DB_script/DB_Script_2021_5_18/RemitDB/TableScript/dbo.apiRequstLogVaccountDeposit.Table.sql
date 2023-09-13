USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiRequstLogVaccountDeposit]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiRequstLogVaccountDeposit](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[RequestJSon] [nvarchar](max) NULL,
	[logDate] [datetime] NULL,
	[ResponseMsg] [nvarchar](max) NULL,
	[MethodName] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[apiRequstLogVaccountDeposit] ADD  DEFAULT (getdate()) FOR [logDate]
GO
