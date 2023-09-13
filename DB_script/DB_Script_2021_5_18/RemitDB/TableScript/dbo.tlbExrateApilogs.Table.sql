USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tlbExrateApilogs]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tlbExrateApilogs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[requestXml] [varchar](500) NULL,
	[responseXml] [varchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlbExrateApilogs] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
