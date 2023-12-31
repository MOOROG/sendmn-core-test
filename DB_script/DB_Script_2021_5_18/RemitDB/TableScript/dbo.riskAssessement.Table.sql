USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[riskAssessement]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[riskAssessement](
	[assessementId] [int] IDENTITY(1,1) NOT NULL,
	[agentId] [int] NOT NULL,
	[assessementDate] [date] NOT NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[reviewdBy] [varchar](50) NULL,
	[reviewedDate] [datetime] NULL,
	[score] [money] NULL,
	[rating] [varchar](10) NULL,
	[reviewerComment] [varchar](2500) NULL,
	[isActive] [varchar](1) NOT NULL,
 CONSTRAINT [PK_riskAssessement] PRIMARY KEY CLUSTERED 
(
	[assessementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
