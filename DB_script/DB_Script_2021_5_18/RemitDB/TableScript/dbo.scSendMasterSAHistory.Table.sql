USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scSendMasterSAHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scSendMasterSAHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[scSendMasterSAId] [int] NULL,
	[code] [varchar](100) NULL,
	[description] [varchar](200) NULL,
	[sCountry] [int] NULL,
	[ssAgent] [int] NULL,
	[sAgent] [int] NULL,
	[sBranch] [int] NULL,
	[rCountry] [int] NULL,
	[rsAgent] [int] NULL,
	[rAgent] [int] NULL,
	[rBranch] [int] NULL,
	[state] [int] NULL,
	[zip] [varchar](20) NULL,
	[agentGroup] [int] NULL,
	[rState] [int] NULL,
	[rZip] [varchar](20) NULL,
	[rAgentGroup] [int] NULL,
	[baseCurrency] [varchar](3) NULL,
	[tranType] [int] NULL,
	[commissionBase] [int] NULL,
	[effectiveFrom] [datetime] NULL,
	[effectiveTo] [datetime] NULL,
	[isEnable] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_scSendMasterSAHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scSendMasterSAHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_B82A5BC3_19B6_48B2_89B2_07E2BEAF259F_393312711]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
