USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tblThirdParty_ApiDetailLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblThirdParty_ApiDetailLog](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[processId] [varchar](40) NULL,
	[date] [datetime] NULL,
	[thread] [varchar](255) NULL,
	[level] [varchar](255) NULL,
	[logger] [nvarchar](255) NULL,
	[message] [nvarchar](max) NULL,
	[exception] [nvarchar](max) NULL,
	[logBy] [varchar](100) NULL,
	[Provider] [varchar](30) NULL,
	[ClientIpAddress] [nvarchar](128) NULL,
	[UserName] [nvarchar](150) NULL,
	[ControlNo] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
