USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentCountryWiseCustomMarginHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentCountryWiseCustomMarginHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentCountryWiseCustomMarginId] [bigint] NULL,
	[sAgentId] [int] NULL,
	[sRate] [int] NULL,
	[sMargin] [float] NULL,
	[sMin] [float] NULL,
	[sMax] [float] NULL,
	[pCountryId] [int] NULL,
	[pRate] [int] NULL,
	[pMargin] [float] NULL,
	[pMin] [float] NULL,
	[pMax] [float] NULL,
	[SCRCRate] [float] NULL,
	[SCRCMargin] [float] NULL,
	[rndSExRate] [int] NULL,
	[rndPAmount] [int] NULL,
	[isDeleted] [char](1) NULL,
	[modType] [varchar](10) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentCountryWiseCustomMarginHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_A80C8B71_2B55_4081_8D70_A578835FFAF6_1766297352]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
