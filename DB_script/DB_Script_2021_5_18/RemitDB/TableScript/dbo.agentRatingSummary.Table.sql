USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentRatingSummary]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentRatingSummary](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[arMasterId] [int] NULL,
	[arDetailId] [int] NULL,
	[riskCategory] [varchar](100) NULL,
	[score] [money] NULL,
	[rating] [char](1) NULL
) ON [PRIMARY]
GO
