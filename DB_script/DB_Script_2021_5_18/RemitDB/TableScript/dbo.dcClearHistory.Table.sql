USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dcClearHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dcClearHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[dcRequestId] [int] NULL,
	[dcSerialNumber] [varchar](100) NULL,
	[dcUserName] [varchar](100) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
