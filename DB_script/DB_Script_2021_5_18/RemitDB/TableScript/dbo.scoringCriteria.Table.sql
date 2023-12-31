USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scoringCriteria]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scoringCriteria](
	[scoringId] [int] IDENTITY(1,1) NOT NULL,
	[scoreFrom] [money] NOT NULL,
	[scoreTo] [money] NOT NULL,
	[rating] [varchar](10) NOT NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isActive] [char](1) NULL,
 CONSTRAINT [PK_scoringCriteria] PRIMARY KEY CLUSTERED 
(
	[scoringId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
