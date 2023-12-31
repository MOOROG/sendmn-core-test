USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[vwTpApilogs]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[vwTpApilogs](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[providerName] [varchar](200) NULL,
	[methodName] [varchar](200) NULL,
	[controlNo] [varchar](50) NULL,
	[requestXml] [varchar](max) NULL,
	[responseXml] [varchar](max) NULL,
	[requestedBy] [varchar](30) NULL,
	[requestedDate] [datetime] NULL,
	[responseDate] [datetime] NULL,
	[errorCode] [varchar](20) NULL,
	[errorMessage] [varchar](max) NULL,
	[processId] [varchar](40) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
