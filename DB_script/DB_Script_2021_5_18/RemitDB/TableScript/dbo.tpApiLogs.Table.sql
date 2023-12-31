USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tpApiLogs]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tpApiLogs](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[providerName] [varchar](200) NULL,
	[methodName] [varchar](200) NULL,
	[controlNo] [varchar](50) NULL,
	[requestXml] [varchar](max) NULL,
	[responseXml] [varchar](max) NULL,
	[requestedBy] [varchar](30) NULL,
	[requestedDate] [datetime] NULL,
	[responseDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
