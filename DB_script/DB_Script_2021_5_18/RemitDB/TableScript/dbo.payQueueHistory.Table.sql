USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[payQueueHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payQueueHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](20) NULL,
	[routeId] [varchar](10) NULL,
	[processId] [varchar](40) NULL,
	[qStatus] [varchar](10) NULL,
	[completedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
