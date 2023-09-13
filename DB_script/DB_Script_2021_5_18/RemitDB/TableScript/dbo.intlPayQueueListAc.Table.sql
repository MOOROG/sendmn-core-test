USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[intlPayQueueListAc]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[intlPayQueueListAc](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[tranNos] [varchar](max) NULL,
	[pAgentMapCode] [varchar](10) NULL,
	[paidBy] [varchar](50) NULL,
	[paidDate] [datetime] NULL,
	[pAgentComm] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
