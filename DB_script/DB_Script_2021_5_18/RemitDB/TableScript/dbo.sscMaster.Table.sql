USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sscMaster]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sscMaster](
	[sscMasterId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[ve] [money] NULL,
	[veType] [int] NULL,
	[ne] [money] NULL,
	[neType] [int] NULL,
	[effectiveFrom] [datetime] NULL,
	[effectiveTo] [datetime] NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__sscMaste__568472E443A1D464] PRIMARY KEY CLUSTERED 
(
	[sscMasterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sscMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_9277AAF9_AFB4_46AA_9117_8A9477F12EBB_2128986911]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
