USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[luckyDrawSetUp]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[luckyDrawSetUp](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[sCountry] [varchar](100) NULL,
	[sAgent] [int] NULL,
	[pAgent1] [varchar](50) NULL,
	[pAgent2] [varchar](50) NULL,
	[pAgent3] [varchar](50) NULL,
	[pAgent4] [varchar](50) NULL,
	[pAgent5] [varchar](50) NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[luckyDrawType] [varchar](50) NULL,
	[flag] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
