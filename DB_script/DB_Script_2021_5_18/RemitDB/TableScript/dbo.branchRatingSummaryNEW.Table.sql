USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[branchRatingSummaryNEW]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branchRatingSummaryNEW](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[brMasterId] [int] NULL,
	[brDetailId] [int] NULL,
	[riskCategory] [varchar](100) NULL,
	[score] [money] NULL,
	[rating] [varchar](10) NULL
) ON [PRIMARY]
GO
