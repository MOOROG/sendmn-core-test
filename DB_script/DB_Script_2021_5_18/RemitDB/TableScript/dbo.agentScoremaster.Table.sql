USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentScoremaster]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentScoremaster](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[scoreFrom] [money] NOT NULL,
	[scoreTo] [money] NOT NULL,
	[rating] [varchar](10) NOT NULL
) ON [PRIMARY]
GO
