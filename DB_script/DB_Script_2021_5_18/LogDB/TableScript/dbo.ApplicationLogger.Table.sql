USE [SendMnPro_LogDb]
GO
/****** Object:  Table [dbo].[ApplicationLogger]    Script Date: 5/18/2021 5:12:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationLogger](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[processId] [varchar](50) NULL,
	[payoutPartnerId] [varchar](100) NULL,
	[methodName] [varchar](50) NULL,
	[controlNo] [varchar](30) NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NOT NULL,
	[message] [nvarchar](max) NULL,
	[exception] [varchar](max) NULL,
	[logger] [varchar](max) NULL,
	[level] [varchar](20) NULL,
	[Category] [varchar](20) NULL,
 CONSTRAINT [PK__Applicat__4B58DB80E42053AC] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApplicationLogger] ADD  CONSTRAINT [DF__Applicati__creat__4CA06362]  DEFAULT (getdate()) FOR [createdDate]
GO
