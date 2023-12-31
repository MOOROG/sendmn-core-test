USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[branchRating]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branchRating](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[brMasterId] [int] NOT NULL,
	[brDetailid] [int] NOT NULL,
	[score] [money] NULL,
	[remarks] [varchar](5000) NULL,
	[modifiedBy] [varchar](150) NULL,
	[modifieddate] [datetime] NULL
) ON [PRIMARY]
GO
