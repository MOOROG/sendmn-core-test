USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentCountryWiseCustomMargin]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentCountryWiseCustomMargin](
	[agentCountryWiseCustomMarginId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[updateCount] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[agentCountryWiseCustomMarginId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentCountryWiseCustomMargin] ADD  CONSTRAINT [MSrepl_tran_version_default_763B78C2_D9D1_48FE_A03C_E736CE39AD5C_18815129]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
