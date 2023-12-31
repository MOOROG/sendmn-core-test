USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[commissionPackage]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[commissionPackage](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[packageId] [int] NOT NULL,
	[ruleId] [int] NOT NULL,
	[ruleType] [varchar](10) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_commissionPackage_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commissionPackage] ADD  CONSTRAINT [MSrepl_tran_version_default_78186DDF_6B6C_4930_9070_81513B3F0B15_1856985942]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
