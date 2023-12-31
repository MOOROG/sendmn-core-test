USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[csMasterHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[csMasterHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csMasterId] [int] NULL,
	[sCountry] [int] NULL,
	[sAgent] [int] NULL,
	[sState] [int] NULL,
	[sZip] [int] NULL,
	[sGroup] [int] NULL,
	[sCustType] [int] NULL,
	[rCountry] [int] NULL,
	[rAgent] [int] NULL,
	[rState] [int] NULL,
	[rZip] [int] NULL,
	[rGroup] [int] NULL,
	[rCustType] [int] NULL,
	[currency] [int] NULL,
	[isEnable] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[ruleScope] [varchar](5) NULL,
 CONSTRAINT [pk_idx_csMasterHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csMasterHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_7E643B88_8504_4AC9_A1E6_3754C10FBB6F_878014259]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
