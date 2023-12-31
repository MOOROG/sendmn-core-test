USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiErrorLogs]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiErrorLogs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[methodName] [varchar](max) NULL,
	[errorMsg] [varchar](max) NULL,
	[errorDetails] [varchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[ip] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
