USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tpControlNo]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tpControlNo](
	[controlNo] [varchar](20) NOT NULL,
	[provider] [int] NOT NULL,
	[repeatCount] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[controlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
