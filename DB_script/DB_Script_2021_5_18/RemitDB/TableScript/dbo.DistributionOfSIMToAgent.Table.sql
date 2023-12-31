USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[DistributionOfSIMToAgent]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistributionOfSIMToAgent](
	[agentId] [int] NULL,
	[iccId] [varchar](20) NULL,
	[mobile] [varchar](10) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [pk_idx_DistributionOfSIMToAgent_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
