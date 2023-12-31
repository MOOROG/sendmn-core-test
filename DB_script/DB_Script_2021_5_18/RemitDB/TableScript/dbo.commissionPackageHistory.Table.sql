USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[commissionPackageHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[commissionPackageHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id] [int] NULL,
	[packageId] [int] NOT NULL,
	[ruleId] [int] NOT NULL,
	[ruleType] [varchar](10) NOT NULL,
	[modType] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_commissionPackageHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commissionPackageHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_2C059F28_FBBF_452D_8C02_187C43334021_1203079622]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
