USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[exRateCalcHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exRateCalcHistory](
	[FOREX_SESSION_ID] [varchar](36) NULL,
	[AGENT_TXN_REF_ID] [varchar](36) NULL,
	[AGENT_CODE] [varchar](100) NULL,
	[USER_ID] [varchar](100) NULL,
	[serviceCharge] [money] NULL,
	[pAmt] [money] NULL,
	[customerRate] [float] NULL,
	[sCurrCostRate] [float] NULL,
	[sCurrHoMargin] [float] NULL,
	[sCurrAgentMargin] [float] NULL,
	[pCurrCostRate] [float] NULL,
	[pCurrHoMargin] [float] NULL,
	[pCurrAgentMargin] [float] NULL,
	[agentCrossSettRate] [float] NULL,
	[treasuryTolerance] [float] NULL,
	[customerPremium] [float] NULL,
	[sharingValue] [float] NULL,
	[sharingType] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[isExpired] [char](1) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[ControlNo] [varchar](30) NULL,
	[CUSTOMER_ID] [bigint] NULL,
	[tAmt] [money] NULL,
	[schemeId] [int] NULL,
 CONSTRAINT [pk_idx_exRateCalcHistory_rowid] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exRateCalcHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_FA0084AF_825E_4F6F_B703_803847A969BD_2113090964]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
