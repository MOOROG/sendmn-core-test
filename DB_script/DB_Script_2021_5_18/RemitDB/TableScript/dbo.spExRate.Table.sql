USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[spExRate]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[spExRate](
	[spExRateId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranType] [int] NULL,
	[cCountry] [int] NULL,
	[cAgent] [int] NULL,
	[cAgentGroup] [int] NULL,
	[cBranch] [int] NULL,
	[cBranchGroup] [int] NULL,
	[pCountry] [int] NULL,
	[pAgent] [int] NULL,
	[pAgentGroup] [int] NULL,
	[pBranch] [int] NULL,
	[pBranchGroup] [int] NULL,
	[cCurrency] [varchar](3) NULL,
	[pCurrency] [varchar](3) NULL,
	[cRateFactor] [char](1) NULL,
	[pRateFactor] [char](1) NULL,
	[cRate] [float] NULL,
	[pRate] [float] NULL,
	[cCurrHOMargin] [float] NULL,
	[pCurrHOMargin] [float] NULL,
	[cCurrAgentMargin] [float] NULL,
	[pCurrAgentMargin] [float] NULL,
	[cHOTolMax] [float] NULL,
	[cHOTolMin] [float] NULL,
	[pHOTolMax] [float] NULL,
	[pHOTolMin] [float] NULL,
	[cAgentTolMax] [float] NULL,
	[cAgentTolMin] [float] NULL,
	[pAgentTolMax] [float] NULL,
	[pAgentTolMin] [float] NULL,
	[crossRate] [float] NULL,
	[crossRateFactor] [char](1) NULL,
	[effectiveFrom] [datetime] NULL,
	[effectiveTo] [datetime] NULL,
	[isActive] [varchar](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_spExRate_spExRateId] PRIMARY KEY CLUSTERED 
(
	[spExRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[spExRate] ADD  CONSTRAINT [MSrepl_tran_version_default_D32A1148_166B_4111_9D18_A6508647547C_1815221767]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
