USE [SendMnPro_LogDb]
GO
/****** Object:  Table [dbo].[tblThirdpartyWebHookLog]    Script Date: 5/18/2021 5:12:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblThirdpartyWebHookLog](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[Provider] [varchar](30) NULL,
	[processId] [varchar](40) NULL,
	[methodName] [varchar](50) NULL,
	[requestedBy] [varchar](100) NULL,
	[log_date] [datetime] NULL,
	[level] [varchar](255) NULL,
	[logger] [nvarchar](255) NULL,
	[message] [nvarchar](max) NULL,
	[exception] [nvarchar](max) NULL,
	[TranId] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
