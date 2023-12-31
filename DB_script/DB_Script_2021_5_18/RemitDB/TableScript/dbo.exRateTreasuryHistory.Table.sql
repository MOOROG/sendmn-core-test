USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[exRateTreasuryHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exRateTreasuryHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[exRateTreasuryId] [int] NULL,
	[cRateId] [int] NULL,
	[cCurrency] [varchar](3) NULL,
	[cCountry] [int] NULL,
	[cAgent] [int] NULL,
	[cRateFactor] [char](1) NULL,
	[cRate] [float] NULL,
	[cMargin] [float] NULL,
	[cHoMargin] [float] NULL,
	[cAgentMargin] [float] NULL,
	[pRateId] [int] NULL,
	[pCurrency] [varchar](3) NULL,
	[pCountry] [int] NULL,
	[pAgent] [int] NULL,
	[pRateFactor] [char](1) NULL,
	[pRate] [float] NULL,
	[pMargin] [float] NULL,
	[pHoMargin] [float] NULL,
	[pAgentMargin] [float] NULL,
	[sharingValue] [float] NULL,
	[sharingType] [char](1) NULL,
	[pSharingValue] [float] NULL,
	[pSharingType] [char](1) NULL,
	[toleranceOn] [char](1) NULL,
	[agentTolMin] [float] NULL,
	[agentTolMax] [float] NULL,
	[customerTolMin] [float] NULL,
	[customerTolMax] [float] NULL,
	[tranType] [int] NULL,
	[crossRate] [float] NULL,
	[crossRateOperation] [float] NULL,
	[maxCrossRate] [float] NULL,
	[customerRate] [float] NULL,
	[tolerance] [float] NULL,
	[toleranceOperation] [float] NULL,
	[premium] [float] NULL,
	[crossRateFactor] [char](1) NULL,
	[isActive] [char](1) NULL,
	[modType] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modFor] [char](1) NULL,
	[agentCrossRateMargin] [float] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_exRateTreasuryHistory] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exRateTreasuryHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_1663640B_16B5_45DD_93DA_E7EF9A554F6C_705085948]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
