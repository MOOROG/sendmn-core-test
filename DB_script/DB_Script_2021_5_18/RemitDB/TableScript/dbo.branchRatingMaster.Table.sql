USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[branchRatingMaster]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branchRatingMaster](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[type] [varchar](1) NOT NULL,
	[displayOrder] [varchar](10) NOT NULL,
	[weight] [money] NULL,
	[description] [varchar](2500) NOT NULL,
	[isActive] [varchar](1) NULL,
	[summaryDescription] [varchar](250) NULL
) ON [PRIMARY]
GO
