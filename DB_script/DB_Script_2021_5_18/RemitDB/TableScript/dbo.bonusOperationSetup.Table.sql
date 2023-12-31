USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bonusOperationSetup]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bonusOperationSetup](
	[bonusSchemeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[schemeName] [varchar](50) NULL,
	[sendingCountry] [varchar](50) NULL,
	[sendingAgent] [varchar](500) NULL,
	[sendingBranch] [varchar](50) NULL,
	[receivingCountry] [varchar](50) NULL,
	[receivingAgent] [varchar](50) NULL,
	[schemeStartDate] [datetime] NULL,
	[schemeEndDate] [datetime] NULL,
	[basis] [varchar](100) NULL,
	[unit] [int] NULL,
	[points] [int] NULL,
	[isActive] [varchar](2) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[minTxnForRedeem] [int] NULL,
	[maxPointsPerTxn] [int] NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_bonusOperationSetup_bonusSchemeId] PRIMARY KEY CLUSTERED 
(
	[bonusSchemeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bonusOperationSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_CD92EDE2_7D10_42BD_967B_AC0B617587FD_598657576]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
