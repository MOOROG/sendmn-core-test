USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[referralMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[referralMaster](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NULL,
	[mobile] [varchar](20) NULL,
	[email] [varchar](100) NULL,
	[userId] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[status] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
