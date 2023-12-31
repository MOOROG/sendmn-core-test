USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[Logs]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logs](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[errorPage] [varchar](max) NULL,
	[errorMsg] [varchar](max) NULL,
	[errorDetails] [varchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[referer] [varchar](max) NULL,
	[dcUserName] [varchar](200) NULL,
	[dcIdNo] [varchar](2000) NULL,
	[ipAddress] [varchar](50) NULL,
 CONSTRAINT [pk_idx_Logs_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
